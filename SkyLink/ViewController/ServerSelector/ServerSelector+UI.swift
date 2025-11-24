// MARK: - UI
extension ServerSelectionViewController
{
    private func constructUI()
    {
        titleLabel = createTitleLabel()
        searchContainerView = createSearchContainerView()

        view.addSubview(titleLabel)
        view.addSubview(searchContainerView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),

            searchContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
}