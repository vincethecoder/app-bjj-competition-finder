//
//  EventsViewController.swift
//  Prototype
//
//  Created by Kobe Sam on 10/31/24.
//

import UIKit

struct EventViewModel {
    let dateRange: String
    let title: String
    let location: String
    let color: UIColor
}

final class EventsViewController: UITableViewController {
    private let events = EventViewModel.protoypeEvents
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .systemGroupedBackground
        
        // Add padding to the table view
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        // Enable automatic dimension calculation
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        
        // Remove extra padding between sections
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.reuseIdentifier, for: indexPath) as? EventTableViewCell else {
            fatalError("Invalid tableview cell declaration")
        }
        cell.configure(with: events[indexPath.row])
        return cell
    }
}

