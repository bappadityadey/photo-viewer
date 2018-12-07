//
//  NTSPhotoDetailController.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 25/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import UIKit

class NTSPhotoDetailController: UIViewController {

    @IBOutlet weak var actualImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Variables
    var viewModel: NTSPhotoDetailViewModel? {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.viewModel?.downloadActualPhoto()
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = viewModel?.getTitle()
        self.activityIndicator.startAnimating()
    }
}

// MARK: - Configurable
extension NTSPhotoDetailController: Configurable {
    func bind(to viewModel: NTSPhotoDetailViewModel) {
        self.viewModel = viewModel
        
        /// Observes the image path for actual photo
        viewModel.observe(for: [viewModel.imagePath]) { [weak self] (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self?.updateData()
            })
        }
        
        /// Observes the error while downloading photo
        viewModel.observe(for: [viewModel.error]) { [weak self] (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self?.showErrorAlert(viewModel.error.value)
            })
        }
    }
    
    /// Update the imageView with actual photo
    func updateData() {
        if let imagePath = viewModel?.imagePath.value, !imagePath.isEmpty, let image = UIImage(contentsOfFile: imagePath) {
            self.actualImageView?.image = image
            self.activityIndicator.stopAnimating()
        }
    }
}

//MARK: Show Alert
extension NTSPhotoDetailController {
    private func showErrorAlert(_ error: Error?) {
        let message = error?.localizedDescription ?? "No internet connection available"
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString(message, comment: ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: { (_) in
            self.activityIndicator.stopAnimating()
        }))
        
        present(alert, animated: true, completion: {
        })
    }
}
