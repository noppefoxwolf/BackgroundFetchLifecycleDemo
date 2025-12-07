//
//  LogViewerViewController.swift
//  BackgroundFetchLifecycleDemo
//
//  Created by Copilot on 2025/12/07.
//

import UIKit

class LogViewerViewController: UIViewController {
    
    private var logTextView: UITextView!
    private var refreshButton: UIButton!
    private var clearButton: UIButton!
    private var filterSegmentedControl: UISegmentedControl!
    private var scrollToBottomButton: UIButton!
    private var exportButton: UIButton!
    
    private var allLogs: [String] = []
    private var filteredLogs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadLogs()
        startAutoRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadLogs()
    }
    
    private func setupNavigationBar() {
        title = "Background Fetch Logs"
        navigationItem.largeTitleDisplayMode = .never
        
        // Close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        
        // Info button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: #selector(infoTapped)
        )
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Filter Segmented Control
        filterSegmentedControl = UISegmentedControl(items: [
            "All", "Lifecycle", "BackgroundFetch", "UI", "Scene", "Test"
        ])
        filterSegmentedControl.selectedSegmentIndex = 0
        filterSegmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        filterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterSegmentedControl)
        
        // Log TextView
        logTextView = UITextView()
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        logTextView.isEditable = false
        logTextView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        logTextView.backgroundColor = .systemBackground
        logTextView.layer.borderColor = UIColor.systemGray4.cgColor
        logTextView.layer.borderWidth = 1
        logTextView.layer.cornerRadius = 8
        logTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.addSubview(logTextView)
        
        // Button Stack
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 8
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        // Refresh Button
        refreshButton = UIButton(type: .system)
        refreshButton.setTitle("Refresh", for: .normal)
        refreshButton.backgroundColor = .systemBlue
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.layer.cornerRadius = 8
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        
        // Clear Button
        clearButton = UIButton(type: .system)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.backgroundColor = .systemRed
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.layer.cornerRadius = 8
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        
        // Export Button
        exportButton = UIButton(type: .system)
        exportButton.setTitle("Export", for: .normal)
        exportButton.backgroundColor = .systemGreen
        exportButton.setTitleColor(.white, for: .normal)
        exportButton.layer.cornerRadius = 8
        exportButton.addTarget(self, action: #selector(exportTapped), for: .touchUpInside)
        
        buttonStackView.addArrangedSubview(refreshButton)
        buttonStackView.addArrangedSubview(clearButton)
        buttonStackView.addArrangedSubview(exportButton)
        
        // Scroll to Bottom Button (Floating)
        scrollToBottomButton = UIButton(type: .system)
        scrollToBottomButton.setImage(UIImage(systemName: "arrow.down.circle.fill"), for: .normal)
        scrollToBottomButton.backgroundColor = .systemBlue
        scrollToBottomButton.tintColor = .white
        scrollToBottomButton.layer.cornerRadius = 25
        scrollToBottomButton.addTarget(self, action: #selector(scrollToBottomTapped), for: .touchUpInside)
        scrollToBottomButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollToBottomButton)
        
        // Layout
        NSLayoutConstraint.activate([
            // Filter Control
            filterSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Log TextView
            logTextView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: 16),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Button Stack
            buttonStackView.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44),
            
            // Log TextView bottom
            logTextView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
            
            // Scroll to Bottom Button
            scrollToBottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollToBottomButton.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -20),
            scrollToBottomButton.widthAnchor.constraint(equalToConstant: 50),
            scrollToBottomButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func startAutoRefresh() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.loadLogs()
            }
        }
    }
    
    private func loadLogs() {
        allLogs = BackgroundFetchLogger.shared.getLogs()
        applyFilter()
        updateUI()
    }
    
    private func applyFilter() {
        let selectedIndex = filterSegmentedControl.selectedSegmentIndex
        
        switch selectedIndex {
        case 0: // All
            filteredLogs = allLogs
        case 1: // Lifecycle
            filteredLogs = allLogs.filter { $0.contains("Lifecycle:") }
        case 2: // BackgroundFetch
            filteredLogs = allLogs.filter { $0.contains("BackgroundFetch:") }
        case 3: // UI
            filteredLogs = allLogs.filter { $0.contains("UI:") }
        case 4: // Scene
            filteredLogs = allLogs.filter { $0.contains("Scene:") }
        case 5: // Test
            filteredLogs = allLogs.filter { $0.contains("Test:") }
        default:
            filteredLogs = allLogs
        }
    }
    
    private func updateUI() {
        let logText = filteredLogs.isEmpty ? "No logs found for selected filter..." : filteredLogs.joined(separator: "\n")
        logTextView.text = logText
        
        // Update title with count
        let totalCount = allLogs.count
        let filteredCount = filteredLogs.count
        title = "Logs (\(filteredCount)/\(totalCount))"
        
        // Show/hide scroll to bottom button
        let isAtBottom = logTextView.contentOffset.y >= (logTextView.contentSize.height - logTextView.bounds.size.height)
        scrollToBottomButton.isHidden = isAtBottom || filteredLogs.isEmpty
    }
    
    @objc private func filterChanged() {
        applyFilter()
        updateUI()
    }
    
    @objc private func refreshTapped() {
        BackgroundFetchLogger.shared.log("Log viewer refresh tapped", event: "UI")
        loadLogs()
        
        // Visual feedback
        refreshButton.setTitle("✓", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshButton.setTitle("Refresh", for: .normal)
        }
    }
    
    @objc private func clearTapped() {
        let alert = UIAlertController(
            title: "Clear Logs",
            message: "Are you sure you want to delete all logs?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            BackgroundFetchLogger.shared.log("All logs cleared from viewer", event: "UI")
            BackgroundFetchLogger.shared.clearLogs()
            self.loadLogs()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func exportTapped() {
        let logs = BackgroundFetchLogger.shared.getFormattedLogs()
        let activityVC = UIActivityViewController(activityItems: [logs], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = exportButton
        present(activityVC, animated: true)
        
        BackgroundFetchLogger.shared.log("Logs exported", event: "UI")
    }
    
    @objc private func scrollToBottomTapped() {
        guard !filteredLogs.isEmpty else { return }
        
        let bottom = NSMakeRange(logTextView.text.count - 1, 1)
        logTextView.scrollRangeToVisible(bottom)
        
        scrollToBottomButton.isHidden = true
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func infoTapped() {
        let alert = UIAlertController(
            title: "Background Fetch Logs",
            message: """
            This screen shows all Background Fetch lifecycle events.
            
            Filters:
            • All: All logged events
            • Lifecycle: App lifecycle events
            • BackgroundFetch: Background fetch events
            • UI: User interface events
            • Scene: Scene lifecycle events
            • Test: Manual test events
            
            Logs auto-refresh every 2 seconds.
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}