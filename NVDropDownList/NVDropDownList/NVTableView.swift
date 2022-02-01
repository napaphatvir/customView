//
//  NVTableView.swift
//  NVDropDownList
//
//  Created by boicomp21070029 on 20/11/2564 BE.
//

import UIKit

final class NVTableView: UITableView {
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
