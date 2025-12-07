//
//  LogTableViewCell.swift
//  BackgroundFetchLifecycleDemo
//
//  Created by Copilot on 2025/12/07.
//

import UIKit

class LogTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .default
        
        // Use default cell style for simplicity
        textLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        textLabel?.numberOfLines = 0
        
        detailTextLabel?.font = .systemFont(ofSize: 11, weight: .regular)
        detailTextLabel?.textColor = .secondaryLabel
        detailTextLabel?.numberOfLines = 0
    }
    
    func configure(with logEntry: String, index: Int) {
        // Parse log entry: [timestamp] event: message
        let components = logEntry.components(separatedBy: "] ")
        guard components.count >= 2 else {
            textLabel?.text = "\(index). Invalid log format"
            detailTextLabel?.text = logEntry
            accessoryView = createColorIndicator(.systemGray)
            return
        }
        
        // Extract timestamp (remove the opening bracket)
        let timestamp = String(components[0].dropFirst())
        let formattedTime = formatTimestamp(timestamp)
        
        // Extract event and message
        let eventAndMessage = components[1]
        let eventComponents = eventAndMessage.components(separatedBy: ": ")
        
        if eventComponents.count >= 2 {
            let eventType = eventComponents[0]
            let message = eventComponents[1]
            
            textLabel?.text = "\(index). [\(formattedTime)] \(eventType)"
            detailTextLabel?.text = message
            
            // Set color indicator based on event type
            accessoryView = createColorIndicator(colorForEventType(eventType))
        } else {
            textLabel?.text = "\(index). [\(formattedTime)] General"
            detailTextLabel?.text = eventAndMessage
            accessoryView = createColorIndicator(.systemGray)
        }
    }
    
    private func createColorIndicator(_ color: UIColor) -> UIView {
        let indicator = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
        indicator.backgroundColor = color
        indicator.layer.cornerRadius = 4
        return indicator
    }
    
    private func formatTimestamp(_ timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "HH:mm:ss"
            return displayFormatter.string(from: date)
        }
        return String(timestamp.prefix(8)) // fallback to first 8 chars
    }
    
    private func colorForEventType(_ eventType: String) -> UIColor {
        switch eventType {
        case "Lifecycle":
            return .systemBlue
        case "BackgroundFetch":
            return .systemGreen
        case "UI":
            return .systemPurple
        case "Scene":
            return .systemOrange
        case "Test":
            return .systemRed
        case "Launch":
            return .systemIndigo
        default:
            return .systemGray
        }
    }
}