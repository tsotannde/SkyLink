//
//  LogsViewController.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 11/21/25.
//

import UIKit

#warning("CLASS NEEDS WORK!!")
final class LogsViewController: UIViewController
{
    // UI
    private lazy var closeButton: UIButton = makeCloseButton()
    private lazy var titleLabel: UILabel = makeTitleLabel()
    private lazy var textSizeButton: UIButton = makeTextSizeMenuButton()

    private var closeCopyStackView: UIStackView!
    private lazy var copyButton: UIButton = makeCopyButton()
    private lazy var clearButton: UIButton = makeClearButton()

    private lazy var cardView: UIView = makeCardView()
    private lazy var logsTextView: UITextView = makeLogsTextView()

    private var currentLogFontSize: CGFloat = 8
    private let minFontSize: CGFloat = 6
    private let maxFontSize: CGFloat = 16
    
    //Dats
    private var logRefreshTimer: Timer?
    private var didInitialScrollToBottom = false
    private var didPerformFirstLayout = false
    private var isAutoFollowingBottom = true
    private var isRefreshingLogs = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        // Ensure logs are loaded before first scroll.
        refreshLogs(scrollIfNearBottom: false)
        startLogRefreshing()
    }
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        // Run once, after the first real layout pass.
        guard !didInitialScrollToBottom else { return }
        // Force layout calculations so contentSize is correct.
        logsTextView.layoutManager.ensureLayout(for: logsTextView.textContainer)
        logsTextView.layoutIfNeeded()
        didInitialScrollToBottom = true
        // Scroll on next runloop to avoid starting in the middle.
        DispatchQueue.main.async {
            self.isAutoFollowingBottom = true
            self.scrollToBottom(animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        stopLogRefreshing()
    }
}

//MARK: - Create UI Elements
extension LogsViewController
{
    private func hideNaviagationBar()
    {
        NavigationManager.shared.toggleNavigationBar(on: self.navigationController,shouldShow: false)
    }

    private func setbackgroundColor()
    {
        view.backgroundColor = SkyLinkAssets.Colors.Themes.primary
    }

    private func makeCloseButton() -> UIButton {
        let button = UIButton(type: .system)

        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let image = SkyLinkAssets.Images.xMark?.withConfiguration(config)

        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = SkyLinkAssets.Colors.redColor
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }

    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = SkyLinkAssets.Fonts.semiBold(ofSize: 19)
        label.textAlignment = .center
        label.text = SkyLinkAssets.Text.logKey
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeTextSizeMenuButton() -> UIButton {
        let button = UIButton(type: .system)

        let image = UIImage(
            systemName: "textformat.size",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        )

        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false

        // Attach menu
        button.menu = createTextSizeMenu()
        button.showsMenuAsPrimaryAction = true

        return button
    }

    private func makeClearButton() -> UIButton {
        let button = UIButton(type: .system)
        let title = SkyLinkAssets.Text.clearKey
        button.backgroundColor = SkyLinkAssets.Colors.whiteColor
        button.setTitleColor(SkyLinkAssets.Colors.Themes.primary, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = SkyLinkAssets.Fonts.semiBold(ofSize: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func makeCopyButton() -> UIButton {
        let button = UIButton(type: .system)
        let title = SkyLinkAssets.Text.copyKey
        button.backgroundColor = SkyLinkAssets.Colors.whiteColor
        button.setTitleColor(SkyLinkAssets.Colors.Themes.primary, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = SkyLinkAssets.Fonts.semiBold(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func makeCardView() -> UIView {
        let view = UIView()
        view.backgroundColor = SkyLinkAssets.Colors.whiteColor
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = false

        // Shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func makeLogsTextView() -> UITextView {
        let textView = UITextView()
        textView.text = AppLoggerManager.shared.readLogs()
        textView.backgroundColor = .clear
        textView.textColor = SkyLinkAssets.Colors.Themes.primary
        textView.font = SkyLinkAssets.Fonts.regular(ofSize: currentLogFontSize)
        textView.isEditable = false
        textView.isSelectable = true
        textView.alwaysBounceVertical = true
        textView.showsVerticalScrollIndicator = true
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }
}

//MARK: - Construct UI
extension LogsViewController
{
   private func addCloseButton()
    {
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    private func addTitleLabel()
    {
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }
    
    private func addTextSizeButton()
    {
        view.addSubview(textSizeButton)

        NSLayoutConstraint.activate([
            textSizeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            textSizeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textSizeButton.widthAnchor.constraint(equalToConstant: 32),
            textSizeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func addCopyAndClearButton()
    {
        // Create stack view
        closeCopyStackView = UIStackView(arrangedSubviews: [copyButton, clearButton])
        closeCopyStackView.axis = .horizontal
        closeCopyStackView.alignment = .center
        closeCopyStackView.distribution = .fillEqually
        closeCopyStackView.spacing = 20
        clearButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        copyButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        closeCopyStackView.translatesAutoresizingMaskIntoConstraints = false

        // Add to view
        view.addSubview(closeCopyStackView)

        // Constrain to bottom safe area
        NSLayoutConstraint.activate([
            closeCopyStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            closeCopyStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            closeCopyStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    
    private func addCardView()
    {
        view.addSubview(cardView)
        cardView.addSubview(logsTextView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: closeCopyStackView.topAnchor, constant: -20),

            logsTextView.topAnchor.constraint(equalTo: cardView.topAnchor),
            logsTextView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            logsTextView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            logsTextView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
    }

    private func setupUI()
    {
        hideNaviagationBar()
        setbackgroundColor()
        addCloseButton()
        addTitleLabel()
        addCopyAndClearButton()
        addCardView()
        addTextSizeButton()
        logsTextView.delegate = self
    }
}

//MARK: - Actions
extension LogsViewController
{
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    private func startLogRefreshing() {
        stopLogRefreshing()
        // Delay initial refresh to let layout + initial scroll settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self else { return }
            // First refresh (safe)
            self.refreshLogs(scrollIfNearBottom: true)
            // Start repeating timer
            self.logRefreshTimer = Timer.scheduledTimer(
                withTimeInterval: 1.0,
                repeats: true
            ) { [weak self] _ in
                guard let self else { return }
                self.refreshLogs(scrollIfNearBottom: true)
            }
            RunLoop.main.add(self.logRefreshTimer!, forMode: .common)
        }
    }
    private func stopLogRefreshing()
    {
        logRefreshTimer?.invalidate()
        logRefreshTimer = nil
    }
    
    private func refreshLogs(scrollIfNearBottom: Bool = true)
    {

        let shouldAutoScroll = isAutoFollowingBottom

        isRefreshingLogs = true
        logsTextView.text = AppLoggerManager.shared.readLogs()
        logsTextView.layoutManager.ensureLayout(for: logsTextView.textContainer)
        logsTextView.layoutIfNeeded()
        isRefreshingLogs = false

        if scrollIfNearBottom && shouldAutoScroll {
            DispatchQueue.main.async {
                self.scrollToBottom(animated: false)
            }
        }
    }

    
    private func scrollToBottom(animated: Bool = false)
    {
        let length = logsTextView.text.count
        guard length > 0 else { return }
        let range = NSRange(location: length - 1, length: 1)
        if animated {
            logsTextView.scrollRangeToVisible(range)
        } else {
            UIView.performWithoutAnimation {
                self.logsTextView.scrollRangeToVisible(range)
            }
        }
    }
    
    private func trackUserScrollPosition() {
        guard !isRefreshingLogs else {
            return
        }

        // Allow a tolerance window so user does not need to be exactly at the bottom for auto-follow.
        let threshold: CGFloat = 120
        let contentHeight = logsTextView.contentSize.height
        let visibleHeight = logsTextView.bounds.height
        let yOffset = logsTextView.contentOffset.y
        let bottomInset = logsTextView.contentInset.bottom

        let nearBottom = yOffset + visibleHeight + bottomInset >= contentHeight - threshold
        isAutoFollowingBottom = nearBottom

    }
    
    private func createTextSizeMenu() -> UIMenu
    {
        let increase = UIAction(
            title: "Increase Text Size",
            image: UIImage(systemName: "plus")
        ) { [weak self] _ in
            self?.increaseTextSize()
        }

        let decrease = UIAction(
            title: "Decrease Text Size",
            image: UIImage(systemName: "minus")
        ) { [weak self] _ in
            self?.decreaseTextSize()
        }

        return UIMenu(
            title: "Text Size",
            options: [.displayInline],
            children: [increase, decrease]
        )
    }
    
    private func increaseTextSize() {
        guard currentLogFontSize < maxFontSize else { return }
        currentLogFontSize += 1
        updateLogsFont()
        textSizeButton.menu = createTextSizeMenu()
    }
    
   
    private func decreaseTextSize() {
        guard currentLogFontSize > minFontSize else { return }
        currentLogFontSize -= 1
        updateLogsFont()
        textSizeButton.menu = createTextSizeMenu()
    }

    private func updateLogsFont() {
        logsTextView.font = SkyLinkAssets.Fonts.regular(ofSize: currentLogFontSize)
    }
}

extension LogsViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        trackUserScrollPosition()
    }
}
