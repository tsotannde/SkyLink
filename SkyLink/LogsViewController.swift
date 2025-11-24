//
//  LogsViewController.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 11/21/25.
//

import UIKit

final class LogsViewController: UIViewController {

    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = true
        tv.alwaysBounceVertical = true
        tv.showsVerticalScrollIndicator = true
        tv.font = UIFont.monospacedSystemFont(ofSize: 8, weight: .regular)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.systemBackground
        tv.textColor = UIColor.label
        tv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavBar()
        loadLogs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupUI() {
        title = "Logs"
        view.backgroundColor = .systemBackground

        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupNavBar() {
        let clearButton = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearLogs)
        )

        let copyButton = UIBarButtonItem(
            title: "Copy",
            style: .plain,
            target: self,
            action: #selector(copyLogs)
        )

        navigationItem.rightBarButtonItems = [clearButton, copyButton]

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(dismissSelf)
        )
    }

    @objc private func clearLogs() {
        AppLogger.shared.clearLogs()
        textView.text = "Logs cleared."
    }

    @objc private func copyLogs() {
        let logs = textView.text ?? ""
        UIPasteboard.general.string = logs
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    private func loadLogs()
    {
        let logs = AppLogger.shared.readLogs()

        // Handle empty logs to avoid crash
        if logs.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "No logs available."
            return
        }

        textView.text = logs

        // Auto-scroll to bottom safely
        DispatchQueue.main.async {
            let length = self.textView.text.count
            if length > 0 {
                let range = NSRange(location: length - 1, length: 1)
                self.textView.scrollRangeToVisible(range)
            }
        }
    }
}
