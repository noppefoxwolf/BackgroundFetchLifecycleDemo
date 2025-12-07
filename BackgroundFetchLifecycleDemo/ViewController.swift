//
//  ViewController.swift
//  BackgroundFetchLifecycleDemo
//
//  Created by Tomoya Hirano on 2025/12/07.
//

import UIKit

class ViewController: UIViewController {
    
    private var statusLabel: UILabel!
    private var logCountLabel: UILabel!
    private var lastEventLabel: UILabel!
    private var triggerBackgroundFetchButton: UIButton!
    private var viewLogsButton: UIButton!
    private var clearLogsButton: UIButton!
    private var backgroundFetchStatusLabel: UILabel!
    private var logsTableView: UITableView!
    
    private var refreshTimer: Timer?
    private var logs: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        BackgroundFetchLogger.shared.log("ViewController viewDidLoad", event: "UI")
        setupUI()
        startPeriodicUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BackgroundFetchLogger.shared.log("ViewController viewWillAppear", event: "UI")
        updateStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BackgroundFetchLogger.shared.log("ViewController viewDidAppear", event: "UI")
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Background Fetch Demo"
        
        // Status Card
        let statusCardView = createCardView()
        
        statusLabel = UILabel()
        statusLabel.text = "Background Fetch Status"
        statusLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        statusLabel.textAlignment = .center
        statusLabel.textColor = .label
        
        backgroundFetchStatusLabel = UILabel()
        backgroundFetchStatusLabel.text = "Status: Active"
        backgroundFetchStatusLabel.font = .systemFont(ofSize: 16)
        backgroundFetchStatusLabel.textAlignment = .center
        backgroundFetchStatusLabel.textColor = .systemGreen
        
        logCountLabel = UILabel()
        logCountLabel.text = "Logs: 0"
        logCountLabel.font = .systemFont(ofSize: 16)
        logCountLabel.textAlignment = .center
        logCountLabel.textColor = .secondaryLabel
        
        lastEventLabel = UILabel()
        lastEventLabel.text = "Last Event: None"
        lastEventLabel.font = .systemFont(ofSize: 14)
        lastEventLabel.textAlignment = .center
        lastEventLabel.textColor = .secondaryLabel
        lastEventLabel.numberOfLines = 2
        
        // Add to card
        let statusStackView = UIStackView(arrangedSubviews: [
            statusLabel,
            backgroundFetchStatusLabel,
            createSeparatorView(),
            logCountLabel,
            lastEventLabel
        ])
        statusStackView.axis = .vertical
        statusStackView.spacing = 12
        statusStackView.translatesAutoresizingMaskIntoConstraints = false
        statusCardView.addSubview(statusStackView)
        
        // Buttons
        let buttonsStackView = UIStackView()
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 12
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        viewLogsButton = createStyledButton(
            title: "📋 Detailed View",
            backgroundColor: .systemBlue,
            action: #selector(viewLogsTapped)
        )
        
        triggerBackgroundFetchButton = createStyledButton(
            title: "🚀 Trigger Fetch",
            backgroundColor: .systemGreen,
            action: #selector(triggerBackgroundFetchTapped)
        )
        
        clearLogsButton = createStyledButton(
            title: "🗑️ Clear",
            backgroundColor: .systemRed,
            action: #selector(clearLogsTapped)
        )
        
        buttonsStackView.addArrangedSubview(viewLogsButton)
        buttonsStackView.addArrangedSubview(triggerBackgroundFetchButton)
        buttonsStackView.addArrangedSubview(clearLogsButton)
        
        // Logs Table View
        let logsCardView = createCardView()
        let logsHeaderLabel = UILabel()
        logsHeaderLabel.text = "📝 Recent Logs"
        logsHeaderLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        logsHeaderLabel.textColor = .label
        logsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        logsTableView = UITableView(frame: .zero, style: .plain)
        logsTableView.delegate = self
        logsTableView.dataSource = self
        logsTableView.backgroundColor = .clear
        logsTableView.separatorStyle = .singleLine
        logsTableView.rowHeight = UITableView.automaticDimension
        logsTableView.estimatedRowHeight = 60
        logsTableView.register(LogTableViewCell.self, forCellReuseIdentifier: "LogCell")
        logsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        logsCardView.addSubview(logsHeaderLabel)
        logsCardView.addSubview(logsTableView)
        
        // Instructions Card
        let instructionsCardView = createCardView()
        let instructionsLabel = UILabel()
        instructionsLabel.text = """
        📱 How to test Background Fetch:
        
        1. Press 'Trigger Fetch' to simulate
        2. Press home button to background the app
        3. Wait a few minutes for system fetch
        4. Return to app and check logs
        
        💡 Enable: Settings → General → Background App Refresh
        """
        instructionsLabel.font = .systemFont(ofSize: 14)
        instructionsLabel.textColor = .secondaryLabel
        instructionsLabel.numberOfLines = 0
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsCardView.addSubview(instructionsLabel)
        
        // Main container
        let mainStackView = UIStackView(arrangedSubviews: [
            statusCardView,
            buttonsStackView,
            logsCardView,
            instructionsCardView
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Status stack in card
            statusStackView.topAnchor.constraint(equalTo: statusCardView.topAnchor, constant: 16),
            statusStackView.leadingAnchor.constraint(equalTo: statusCardView.leadingAnchor, constant: 16),
            statusStackView.trailingAnchor.constraint(equalTo: statusCardView.trailingAnchor, constant: -16),
            statusStackView.bottomAnchor.constraint(equalTo: statusCardView.bottomAnchor, constant: -16),
            
            // Instructions in card
            instructionsLabel.topAnchor.constraint(equalTo: instructionsCardView.topAnchor, constant: 16),
            instructionsLabel.leadingAnchor.constraint(equalTo: instructionsCardView.leadingAnchor, constant: 16),
            instructionsLabel.trailingAnchor.constraint(equalTo: instructionsCardView.trailingAnchor, constant: -16),
            instructionsLabel.bottomAnchor.constraint(equalTo: instructionsCardView.bottomAnchor, constant: -16),
            
            // Logs card
            logsHeaderLabel.topAnchor.constraint(equalTo: logsCardView.topAnchor, constant: 16),
            logsHeaderLabel.leadingAnchor.constraint(equalTo: logsCardView.leadingAnchor, constant: 16),
            logsHeaderLabel.trailingAnchor.constraint(equalTo: logsCardView.trailingAnchor, constant: -16),
            
            logsTableView.topAnchor.constraint(equalTo: logsHeaderLabel.bottomAnchor, constant: 12),
            logsTableView.leadingAnchor.constraint(equalTo: logsCardView.leadingAnchor),
            logsTableView.trailingAnchor.constraint(equalTo: logsCardView.trailingAnchor),
            logsTableView.bottomAnchor.constraint(equalTo: logsCardView.bottomAnchor),
            logsTableView.heightAnchor.constraint(equalToConstant: 200),
            
            // Main stack
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            // Button heights
            viewLogsButton.heightAnchor.constraint(equalToConstant: 44),
            triggerBackgroundFetchButton.heightAnchor.constraint(equalToConstant: 44),
            clearLogsButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        updateStatus()
    }
    
    private func createCardView() -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 4
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }
    
    private func createSeparatorView() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return separator
    }
    
    private func createStyledButton(title: String, backgroundColor: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func startPeriodicUpdate() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateStatus()
            }
        }
    }
    
    private func updateStatus() {
        let newLogs = BackgroundFetchLogger.shared.getLogs()
        let logCount = newLogs.count
        
        // Update logs array and table view if changed
        if logs != newLogs {
            logs = newLogs
            logsTableView.reloadData()
            
            // Auto-scroll to bottom if there are logs
            if !logs.isEmpty {
                let lastIndexPath = IndexPath(row: logs.count - 1, section: 0)
                logsTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
            }
        }
        
        logCountLabel.text = "Logs: \(logCount)"
        
        // Last event
        if let lastLog = logs.last {
            let components = lastLog.components(separatedBy: "] ")
            if components.count >= 2 {
                let eventPart = components[1]
                lastEventLabel.text = "Last: \(eventPart)"
            } else {
                lastEventLabel.text = "Last: \(String(lastLog.prefix(50)))..."
            }
        } else {
            lastEventLabel.text = "Last Event: None"
        }
        
        // Background fetch status
        let backgroundRefreshStatus = UIApplication.shared.backgroundRefreshStatus
        switch backgroundRefreshStatus {
        case .available:
            backgroundFetchStatusLabel.text = "Status: Available ✅"
            backgroundFetchStatusLabel.textColor = .systemGreen
        case .denied:
            backgroundFetchStatusLabel.text = "Status: Denied ❌"
            backgroundFetchStatusLabel.textColor = .systemRed
        case .restricted:
            backgroundFetchStatusLabel.text = "Status: Restricted ⚠️"
            backgroundFetchStatusLabel.textColor = .systemOrange
        @unknown default:
            backgroundFetchStatusLabel.text = "Status: Unknown"
            backgroundFetchStatusLabel.textColor = .systemGray
        }
    }
    
    @objc private func viewLogsTapped() {
        BackgroundFetchLogger.shared.log("View logs button tapped", event: "UI")
        let logViewerVC = LogViewerViewController()
        let navController = UINavigationController(rootViewController: logViewerVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc private func triggerBackgroundFetchTapped() {
        BackgroundFetchLogger.shared.log("Manual trigger button tapped", event: "UI")
        
        // Visual feedback
        triggerBackgroundFetchButton.setTitle("🔄 Running...", for: .normal)
        triggerBackgroundFetchButton.isEnabled = false
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            BackgroundFetchLogger.shared.log("Manually triggering background fetch for testing", event: "Test")
            appDelegate.application(UIApplication.shared, performFetchWithCompletionHandler: { result in
                BackgroundFetchLogger.shared.log("Manual background fetch result: \(result)", event: "Test")
                DispatchQueue.main.async {
                    self.triggerBackgroundFetchButton.setTitle("✅ Done", for: .normal)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.triggerBackgroundFetchButton.setTitle("🚀 Trigger Fetch", for: .normal)
                        self.triggerBackgroundFetchButton.isEnabled = true
                    }
                }
            })
        }
    }
    
    @objc private func clearLogsTapped() {
        let alert = UIAlertController(
            title: "Clear All Logs",
            message: "Are you sure you want to delete all logged events?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            BackgroundFetchLogger.shared.log("All logs cleared from main screen", event: "UI")
            BackgroundFetchLogger.shared.clearLogs()
            self.updateStatus()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as! LogTableViewCell
        cell.configure(with: logs[indexPath.row], index: indexPath.row + 1)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let log = logs[indexPath.row]
        let alert = UIAlertController(title: "Log Detail", message: log, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Copy action
        alert.addAction(UIAlertAction(title: "Copy", style: .default) { _ in
            UIPasteboard.general.string = log
            BackgroundFetchLogger.shared.log("Log copied to clipboard", event: "UI")
        })
        
        present(alert, animated: true)
    }
}

