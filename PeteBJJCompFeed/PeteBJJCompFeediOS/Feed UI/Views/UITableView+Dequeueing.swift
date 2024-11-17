//
//  UITableView+Dequeueing.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/17/24.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
