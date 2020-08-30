//
//  DetailMonitoringViewController.swift
//  PenitipanHewanApp
//
//  Created by Ari Gonta on 24/08/20.
//  Copyright © 2020 JOJA. All rights reserved.
//

import UIKit

enum MonitoringSectionType: Int {
    case HeadMonitoring
    case DetailMonitoring
    
    init(index: Int) {
        switch index {
        case 0:
            self = .HeadMonitoring
        default :
            self = .DetailMonitoring
        }
    }
}

class DetailMonitoringViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var isHidden = true
    var isEdited = false
    var selectedRow = 0
    var currentDate = ""
    var tempMonitoringModel: MonitoringModel?
    var historyModel = [History]()
    var dataOwner: UserModel?
    var reservationPackageID: Int?
    var indexPathFoccus: IndexPath?
    var spinner: UIView?
    var currentRow: Int = 0
    var role = UserDefaultsUtils.shared.getRole()
    lazy var refreshController: UIRefreshControl = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Detail Hewan"
        getCurrentDate()
        getDataMonitoring()
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshController
        refreshController.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        tempMonitoringModel = nil
    }
    
    
    /// Method for Get Current Date with Format "yyyy-MM-dd"
    private func getCurrentDate() {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: date)
        currentDate = formattedDate
    }
    
    @objc func pullToRefresh() {
        getDataMonitoring()
        refreshController.endRefreshing()
    }
}

// MARK: - loading
extension DetailMonitoringViewController {
    
    /// Show loading
    private func showLoading() {
        self.showSpinner { [weak self] (spinner) in
            guard let self = self else { return }
            self.spinner = spinner
        }
    }
    
    
    /// remove loading
    private func removeLoading() {
        guard let spinner = self.spinner else { return }
        self.removeSpinner(spinner)
    }
}

// MARK: - API
extension DetailMonitoringViewController {
    
    // MARK: Post Action Petshop
    /// Method for post Action Changed perDay
    /// - Parameter dataPost: Model Action perDay
    func postData(dataPost: History) {
        let url = "\(CommonHelper.shared.BASE_URL)petshop/package/reservation/history/action"
        
        showLoading()
        NetworkHelper.shared.connect(url: url, params: dataPost.representation, model: History.self) { [weak self] (result) in
            guard let self = self else { return }
            self.removeLoading()
            
            switch result {
            case .failure(let err):
                self.errorResponse(error: err)
                
            case .success( _):
                self.showToast(message: "Success submit data")
                self.getDataMonitoring()
            }
        }
    }
    
    // MARK: Get Detail Pet
    /// Method for Get Data Monitoring Pet
    private func getDataMonitoring() {
        let url = "\(CommonHelper.shared.BASE_URL)petshop/package/reservation/details/history?reservation_package_id=\(tempMonitoringModel?.reservationPackageID ?? 0)"
        
        showLoading()
        NetworkHelper.shared.connect(url: url, params: nil, model: ReservationActionAPIModel.self) { [weak self] (result) in
            guard let self = self else { return }
            
            if self.role.contains("customer") {
                self.removeLoading()
            }
            
            switch result {
            case .failure(let err):
                self.removeLoading()
                self.errorResponse(error: err)
                
            case .success(let value):
                guard let userIdOwner = value.data.userID, let dataList = value.data.history else {
                    self.showToast(message: "gagal mendapatkan data")
                    return
                }
                self.historyModel = dataList
                
                if self.role.contains("customer") {
                    self.tableView.reloadData()
                    
                } else {
                    self.getDataOwner(userIdOwner: userIdOwner)
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    // MARK: get data Owner Pet
    /// Method for get data Owner Pet
    /// - Parameter userIdOwner: user ID owner Pet
    private func getDataOwner(userIdOwner: Int) {
        let url = "\(CommonHelper.shared.BASE_URL)user/\(userIdOwner)"
        NetworkHelper.shared.connect(url: url, params: nil, model: UserAPIModel.self) { [weak self] (result) in
            guard let self = self else { return }
            self.removeLoading()
            
            switch result {
            case .failure(let err):
                self.errorResponse(error: err)
                
            case .success(let value):
                self.dataOwner = value.data
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: error handling
    /// Method for handling error response from network threading
    /// - Parameter error: Model Error From network threading
    private func errorResponse(error: Error) {
        if let newError = error as? ErrorResponse {
            self.showToast(message: newError.messages)
        }
    }
}
