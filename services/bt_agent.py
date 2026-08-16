#!/usr/bin/env python3
"""
Bluetooth DisplayYesNo agent for Quickshell Venus.

Started on-demand when the user initiates a pairing operation.
Handles exactly one RequestConfirmation, then exits cleanly.

IPC with Quickshell via two temp files:
  /tmp/bt_pair_request.json  — written here when confirmation is needed
                               { "device": "<dbus-path>", "passkey": "123456" }
  /tmp/bt_pair_response.json — written by Quickshell when user decides
                               { "accepted": true|false }
"""
import sys
import os
import json
import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib

AGENT_PATH   = "/com/venus/BluetoothAgent"
CAPABILITY   = "DisplayYesNo"
REQUEST_FILE = "/tmp/bt_pair_request.json"
RESPONSE_FILE = "/tmp/bt_pair_response.json"
POLL_MS      = 100
TIMEOUT_MS   = 60_000


class VenusAgent(dbus.service.Object):
    def __init__(self, bus, path, loop):
        super().__init__(bus, path)
        self._loop      = loop
        self._return_cb = None
        self._error_cb  = None
        self._poll_id   = None
        self._elapsed   = 0

    # ── BlueZ Agent1 interface ────────────────────────────────────────────────

    @dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
    def Release(self):
        self._abort()
        self._loop.quit()

    @dbus.service.method(
        "org.bluez.Agent1",
        in_signature="ou",
        out_signature="",
        async_callbacks=("return_cb", "error_cb"),
    )
    def RequestConfirmation(self, device, passkey, return_cb, error_cb):
        """BlueZ is asking the user to confirm the passkey matches."""
        self._return_cb = return_cb
        self._error_cb  = error_cb
        self._elapsed   = 0

        for f in (REQUEST_FILE, RESPONSE_FILE):
            try:
                os.remove(f)
            except FileNotFoundError:
                pass

        with open(REQUEST_FILE, "w") as fh:
            json.dump({"device": str(device), "passkey": f"{int(passkey):06d}"}, fh)

        self._poll_id = GLib.timeout_add(POLL_MS, self._check_response)

    @dbus.service.method(
        "org.bluez.Agent1",
        in_signature="o",
        out_signature="",
        async_callbacks=("return_cb", "error_cb"),
    )
    def RequestAuthorization(self, device, return_cb, error_cb):
        return_cb()

    @dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
    def Cancel(self):
        """BlueZ cancelled before the user responded."""
        self._abort()
        for f in (REQUEST_FILE,):
            try:
                os.remove(f)
            except FileNotFoundError:
                pass
        # Schedule exit so the event loop can flush
        GLib.timeout_add(200, self._quit)

    # ── GLib polling ──────────────────────────────────────────────────────────

    def _check_response(self):
        self._elapsed += POLL_MS
        if self._elapsed >= TIMEOUT_MS:
            self._finish(accepted=False, reason="Pairing confirmation timed out")
            return False

        if not os.path.exists(RESPONSE_FILE):
            return True  # keep polling

        try:
            with open(RESPONSE_FILE) as fh:
                data = json.load(fh)
        except Exception:
            return True

        self._finish(accepted=bool(data.get("accepted", False)))
        return False

    # ── Helpers ───────────────────────────────────────────────────────────────

    def _finish(self, accepted: bool, reason: str = "Pairing rejected by user"):
        self._stop_poll()
        for path in (REQUEST_FILE, RESPONSE_FILE):
            try:
                os.remove(path)
            except FileNotFoundError:
                pass

        if accepted:
            if self._return_cb:
                self._return_cb()
        else:
            if self._error_cb:
                self._error_cb(dbus.DBusException("org.bluez.Error.Rejected", reason))

        self._return_cb = None
        self._error_cb  = None

        # Exit after one request — Quickshell will restart us next time.
        GLib.timeout_add(200, self._quit)

    def _abort(self):
        self._stop_poll()
        self._return_cb = None
        self._error_cb  = None

    def _stop_poll(self):
        if self._poll_id is not None:
            GLib.source_remove(self._poll_id)
            self._poll_id = None

    def _quit(self):
        self._loop.quit()
        return False


def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus     = dbus.SystemBus()
    loop    = GLib.MainLoop()
    agent   = VenusAgent(bus, AGENT_PATH, loop)
    manager = dbus.Interface(
        bus.get_object("org.bluez", "/org/bluez"),
        "org.bluez.AgentManager1",
    )
    manager.RegisterAgent(AGENT_PATH, CAPABILITY)
    manager.RequestDefaultAgent(AGENT_PATH)
    print("READY", flush=True)
    loop.run()


if __name__ == "__main__":
    main()
