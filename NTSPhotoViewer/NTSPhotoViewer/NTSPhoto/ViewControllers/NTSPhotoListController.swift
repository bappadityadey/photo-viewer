//
//  NTSPhotoListController.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import UIKit

class NTSPhotoListController: UITableViewController {
    
    //MARK: Variables
    var viewModel: NTSPhotoListViewModel? {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.viewModel?.getPhotoList()
            })
        }
    }
    /// Add refresh controller for 'Pull To Refresh'
    private let refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.navigationItem.title = viewModel?.getTitle()
        
        /// Show spinner and configure refresh controller
        self.showSpinner()
        self.configureRefreshController()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows() ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReusableIdentifiers.photoThumbnailCell, for: indexPath) as? NTSThumbnailCell else {
            return UITableViewCell()
        }
        if let cellModel = viewModel?.getThumbnailCellModel(at: indexPath.row) {
            cell.bind(to: cellModel)
            cell.populate(from: cellModel)
        }
        return cell
    }
    
    // MARK: - Table view delegates
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: SegueIdentifiers.seguePhotoDetail, sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112.0
    }
}

extension NTSPhotoListController: Configurable {
    typealias T = NTSPhotoListViewModel
    
    func bind(to viewModel: NTSPhotoListViewModel) {
        self.viewModel = viewModel
        
        /// Observes the cellViewModel changes
        viewModel.observe(for: [viewModel.cellViewModels]) { [weak self] (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self?.updateData()
            })
        }
        
        /// Observes the error while downloading photo list
        viewModel.observe(for: [viewModel.error]) { [weak self] (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self?.showErrorAlert(viewModel.error.value)
            })
        }
    }
    
    //MARK: Update data after getting server response
    func updateData() {
        if let dataSource = viewModel?.cellViewModels.value, !dataSource.isEmpty {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        } else {
            self.tableView.isHidden = true
        }
        if self.refreshController.isRefreshing == true {
            self.refreshController.endRefreshing()
        }
    }
    
    //MARK: Segue for Photo detail controller
    /// - Parameters:
    ///     - sender: indexpath for selected photo
    /// - Returns:
    ///     - nil
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = sender as? IndexPath else {
            return
        }
        if segue.identifier == SegueIdentifiers.seguePhotoDetail {
            let photoDetail = segue.destination as? NTSPhotoDetailController
            if let cellModel = viewModel?.getThumbnailCellModel(at: indexPath.row) {
                let detailViewModel = NTSPhotoDetailViewModel(with: cellModel.url)
                photoDetail?.bind(to: detailViewModel)
            }
        }
    }
}

//MARK: Spinner methods
extension NTSPhotoListController {
    private func showSpinner() {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        tableView.backgroundView = spinner
    }
    
    private func hideSpinner() {
        tableView.backgroundView = nil
    }
}

//MARK: Refresh controller
extension NTSPhotoListController {
    /// configure refresh controller
    private func configureRefreshController() {
        refreshController.addTarget(self,
                                    action: #selector(NTSPhotoListController.refreshPhotoList),
                                    for: .valueChanged)
        tableView.refreshControl = refreshController
    }
    
    @objc
    func refreshPhotoList() {
        viewModel?.reloadDataSource(true)
    }
}

//MARK: Show Alert
extension NTSPhotoListController {
    private func showErrorAlert(_ error: Error?) {
        let message = error?.localizedDescription ?? "No internet connection available"
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString(message, comment: ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: { (_) in
            self.tableView.isHidden = false
            self.hideSpinner()
        }))
        
        present(alert, animated: true, completion: {
        })
    }
}
