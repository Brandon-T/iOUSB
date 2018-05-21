//
//  ViewController.swift
//  iOUSB
//
//  Created by Brandon on 2018-05-20.
//  Copyright © 2018 XIO. All rights reserved.
//

import UIKit
import Foundation
import ExternalAccessory

class ViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let refreshButton = UIButton(type: .custom)
    private var deviceList = [String]()
    private var connectedDevice: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Serial Devices"
        
        //Setup UI
        setupUI()
        
        //Register for Accessory Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(onAccessoryConnected(_:)), name: NSNotification.Name.EAAccessoryDidConnect, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onAccessoryDisconnected(_:)), name: NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
        
        EAAccessoryManager.shared().registerForLocalNotifications()
        
        //Setup Serial Communications
        listDevices()
    }
    
    deinit {
        //Unregister for Accessory Notifications
        EAAccessoryManager.shared().unregisterForLocalNotifications()
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //Accessory Notification Callbacks
    @objc
    private func onAccessoryConnected(_ notification: NSNotification) {
        print("Device Connected")
        
        EAAccessoryManager.shared().connectedAccessories.forEach({
            print("Manufacturer: \($0.manufacturer)")
            print("Name: \($0.name)")
            print("Model Number: \($0.modelNumber)")
            print("Serial Number: \($0.serialNumber)")
            print("Hardware Revision: \($0.hardwareRevision)")
            print("Firmware Revision: \($0.firmwareRevision)")
            print("Protocol Strings: \($0.protocolStrings)")
        })
    }
    
    @objc
    private func onAccessoryDisconnected(_ notification: NSNotification) {
        print("Device Disconnected")
    }
}

extension ViewController {
    func setupUI() {
        view.backgroundColor = .white
        
        let footerView = { () -> UIView in
            let view = UIView()
            view.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
            view.addSubview(refreshButton)
            refreshButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                refreshButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15.0),
                refreshButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15.0),
                refreshButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15.0),
                refreshButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15.0),
                refreshButton.heightAnchor.constraint(equalToConstant: 45.0)
            ])
            
            return view
        }()
        
        refreshButton.layer.cornerRadius = 5.0
        refreshButton.backgroundColor = .blue
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.setTitle("Reload", for: .normal)
        refreshButton.addTarget(self, action: #selector(onReload(_:)), for: .touchUpInside)
        
        view.addSubview(tableView)
        view.addSubview(footerView)
        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                
                footerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                footerView.rightAnchor.constraint(equalTo: view.rightAnchor),
                footerView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
                footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
        else {
            NSLayoutConstraint.activate([
                tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                
                footerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                footerView.rightAnchor.constraint(equalTo: view.rightAnchor),
                footerView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
                footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        view.subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        tableView.register(DeviceCell.self, forCellReuseIdentifier: "DeviceCell")
    }
    
    func listDevices() {
        let fileManager = FileManager.default
        if let pathURL = URL(string: "/dev") {
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: pathURL, includingPropertiesForKeys: nil)
                deviceList = fileURLs.map({ $0.path }).sorted()
                tableView.reloadData()
            } catch {
                print("Error while enumerating files \(pathURL): \(error.localizedDescription)")
            }
        }
        else {
            print("Error opening path: /dev")
        }
    }
    
    @objc
    private func onReload(_ button: UIButton) {
        listDevices()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceCell
        
        cell.configure(title: deviceList[indexPath.row]) { [weak self] in
            
            if let `self` = self {
                if self.deviceList.contains(self.connectedDevice) {
                    if Serial.shared().disconnect() {
                        self.connectedDevice = ""
                        cell.actionButton.setTitle("Connect", for: .normal)
                        cell.actionButton.backgroundColor = .blue
                        print("Disconnected!")
                    }
                }
                else {
                    if (Serial.shared().setup(self.deviceList[indexPath.row])) {
                        self.connectedDevice = self.deviceList[indexPath.row]
                        cell.actionButton.setTitle("Disconnect", for: .normal)
                        cell.actionButton.backgroundColor = .green
                        print("Connected!")
                    }
                    else {
                        let alert = UIAlertController(title: "Error", message: "Error Connecting: \(Serial.shared().lastError() ?? "UnknownError").", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        Serial.shared().eraseLastError()
                    }
                }
            }
        }
        
        if self.deviceList.contains(self.connectedDevice) {
            cell.actionButton.setTitle("Disconnect", for: .normal)
            cell.actionButton.backgroundColor = .green
        }
        else {
            cell.actionButton.setTitle("Connect", for: .normal)
            cell.actionButton.backgroundColor = .blue
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

class DeviceCell: UITableViewCell {
    private let titleView = UILabel()
    let actionButton = UIButton(type: .custom)
    private var eventHandler: (() -> Void)?
    
    func configure(title: String, eventHandler: @escaping () -> Void) {
        titleView.text = title
        self.eventHandler = eventHandler
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        actionButton.setTitle("Connect", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 15.0, bottom: 5.0, right: 15.0)
        actionButton.layer.cornerRadius = 5.0
        actionButton.backgroundColor = .blue
        
        contentView.addSubview(titleView)
        contentView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            titleView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15.0),
            titleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15.0),
            titleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15.0),
            
            actionButton.leftAnchor.constraint(greaterThanOrEqualTo: titleView.rightAnchor, constant: 15.0),
            actionButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15.0),
            actionButton.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 15.0),
            actionButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -15.0),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        contentView.subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        
        actionButton.addTarget(self, action: #selector(onActionPerformed(_:)), for: .touchUpInside)
    }
    
    @objc
    private func onActionPerformed(_ button: UIButton) {
        self.eventHandler?()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
