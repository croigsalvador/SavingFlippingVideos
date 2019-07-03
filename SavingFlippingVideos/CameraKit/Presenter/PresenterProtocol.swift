//
//  Presenter.swift
//  EasyCamera
//
//  Created by Carlos Roig on 18/1/18.
//  Copyright © 2018 CRS. All rights reserved.
//

import Foundation

protocol PresenterProtocol {
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
}

extension PresenterProtocol {
    func viewDidLoad() {}
    func viewWillAppear() {}
    func viewWillDisappear() {}
    func viewDidAppear() {}
}
