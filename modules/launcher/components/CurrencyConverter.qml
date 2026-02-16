pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Parse currency conversion query
    // Supports: "500 USD to EUR" or "100 GBP in ZAR 14/01/2026"
    function parseQuery(query) {
        if (!query || query.trim() === "")
            return null;

        // Regex to match: <amount> <currency> [to|in] <currency> [date]
        // Date format: DD/MM/YYYY or YYYY-MM-DD
        let pattern = /^(\d+(?:\.\d+)?)\s*([a-zA-Z]{3})\s+(?:to|in)\s+([a-zA-Z]{3})(?:\s+(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{4}))?$/i;

        let match = query.trim().match(pattern);
        if (!match)
            return null;

        let amount = parseFloat(match[1]);
        let from = match[2].toUpperCase();
        let to = match[3].toUpperCase();
        let dateStr = match[4];

        // Parse date if provided
        let date = null;
        if (dateStr) {
            // Try DD/MM/YYYY or DD-MM-YYYY
            let dateMatch = dateStr.match(/^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})$/);
            if (dateMatch) {
                let day = dateMatch[1].padStart(2, '0');
                let month = dateMatch[2].padStart(2, '0');
                let year = dateMatch[3];
                date = year + "-" + month + "-" + day;
            }
        }

        return {
            amount: amount,
            from: from,
            to: to,
            date: date,
            query: query.trim()
        };
    }

    // Fetch exchange rate
    function fetchRate(conversion, callback) {
        if (!conversion) {
            callback(null);
            return;
        }

        let url;
        if (conversion.date) {
            // Historical rate
            url = "https://api.frankfurter.dev/v1/" + conversion.date + "?from=" + conversion.from + "&to=" + conversion.to;
        } else {
            // Latest rate
            url = "https://api.frankfurter.dev/v1/latest?from=" + conversion.from + "&to=" + conversion.to;
        }

        // Create a component to hold the data
        let processData = {
            conversion: conversion,
            callback: callback
        };

        // Use curl to fetch the API
        let fetchProcess = Qt.createQmlObject('
            import Quickshell.Io
            Process {
                property var processData: null
                
                command: ["curl", "-s"]
                running: false
                
                stdout: StdioCollector {
                    onStreamFinished: {
                        let cb = processData.callback
                        let conv = processData.conversion
                        try {
                            let data = JSON.parse(text)
                            if (data && data.rates && data.rates[conv.to]) {
                                let rate = data.rates[conv.to]
                                let result = conv.amount * rate
                                cb({
                                    success: true,
                                    amount: conv.amount,
                                    from: conv.from,
                                    to: conv.to,
                                    rate: rate,
                                    result: parseFloat(result.toFixed(2)),
                                    date: data.date,
                                    query: conv.query
                                })
                            } else {
                                cb({
                                    success: false,
                                    error: "Currency not found",
                                    query: conv.query
                                })
                            }
                        } catch (e) {
                            cb({
                                success: false,
                                error: "Failed to fetch rate",
                                query: conv.query
                            })
                        }
                    }
                }
                
                onExited: function(exitCode) {
                    if (exitCode !== 0) {
                        let cb = processData.callback
                        let conv = processData.conversion
                        cb({
                            success: false,
                            error: "Network error",
                            query: conv.query
                        })
                    }
                }
            }
        ', root);

        fetchProcess.processData = processData;
        fetchProcess.command = ["curl", "-s", url];
        fetchProcess.running = true;
    }
}
