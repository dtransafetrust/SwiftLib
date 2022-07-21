//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit

class SystemLogViewController: BaseUIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadMoreView: UIView!
    
    private let eventLogService =  SWDK.sharedInstance().eventLogService()
    
    private let LIMIT_EACH_PAGE: Int32 = 50
    
    private var refresh = UIRefreshControl()
    
    var events: [Event] = []
    var fetchPosition: Int32 = 0
    var capacity: Int32 = 0
    
    var filterEvents: [Event] = []
    
    var isSearchBarEmpty: Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return !isSearchBarEmpty
    }
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("HISTORY_TITLE", comment: "")
        
        // Add refresh controll to tableview
        refresh.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        refresh.tintColor = .white
        tableView.addSubview(refresh)
        tableView.alwaysBounceVertical = true
        
        loadMoreView.isHidden = true
        
        loadSystemLogWithPagination()
    }
    
    // MARK: - Private methods
    
    @objc func refreshData() {
        events.removeAll()
        fetchPosition = 0
        tableView.reloadData()
        
        loadSystemLogWithPagination()
    }
    
    private func bindSystemLogs(newEvents: Array<Event>) {
        if newEvents.count == 0 {
            return
        }
        
        // Order by timestamp
        let sortedArray = newEvents.sorted {
            $0.timestampAsTicks > $1.timestampAsTicks
        }
        
        // Add new IndexPath list
        var newIndexPaths = [IndexPath]()
        for rowPosition in 0..<sortedArray.count {
            let newIndexPath = IndexPath(row: self.events.count + rowPosition, section: 0)
            newIndexPaths.append(newIndexPath)
        }
        
        sortedArray.forEach { (item) in
            events.append(item)
        }
        fetchPosition = Int32(events.count)
        
        tableView.insertRows(at: newIndexPaths, with: .automatic)
    }
    
    private func loadFilterEventsFrom(_ events: Array<Event>) -> Array<Event> {
        let result: Array<Event>
        
        result = events.filter {
            ($0.filterText.lowercased().contains(searchBar.text!.lowercased()))
        }
        
        return result
    }
    
    private func loadSystemLogWithPagination() {
        if isFiltering {
            return
        }
        
        loadMoreView.isHidden = false
        eventLogService.getEventLogs(fromTicks: lastMonthTicks(),
                                     toTicks: currentTicks(),
                                     startIndex: fetchPosition,
                                     limit: LIMIT_EACH_PAGE) { (logItems, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0)) {
                self.loadMoreView.isHidden = true
                self.refresh.endRefreshing()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                if (error != nil) {
                    self.showErrorDialog(error: error)
                    return;
                }
                self.capacity = logItems!.Capacity
                self.bindSystemLogs(newEvents: logItems!.Datas)
            }
        }
    }
}

// MARK: -

extension Event {
    
    var filterText: String {
        return "\(readerName) \(username) \(action)"
    }
}

// MARK: - UISearchBar Delegate

extension SystemLogViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterEvents = loadFilterEventsFrom(events)
        tableView.reloadData()
    }
}

// MARK: - UITableView DataSource

extension SystemLogViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filterEvents.count
        }
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventLogViewCell
        
        let event: Event
        
        if isFiltering {
            event = self.filterEvents[indexPath.row]
        } else {
            event = self.events[indexPath.row]
        }
        cell.setup(event)
        
        return cell
    }
}

// MARK: - UITableView delegates

extension SystemLogViewController: UITableViewDelegate {
    
    // Call fetchData method when last row is about to be presented
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isFiltering {
            if (indexPath.row == events.count - 1 && self.fetchPosition < self.capacity) {
                loadSystemLogWithPagination()
            }
        }
    }
}
