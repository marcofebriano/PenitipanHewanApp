//
//  UserProfileHeaderCell.swift
//  PenitipanHewanApp
//
//  Created by Marco Ramadhani (ID) on 31/07/20.
//  Copyright © 2020 JOJA. All rights reserved.
//

import UIKit

class UserProfileHeaderCell: UITableViewCell {

    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userPhoneLbl: UILabel!
    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var userAddressLbl: UILabel!
    
    public var onclickImage: (() -> Void)?
    
    var currentRole = UserDefaultsUtils.shared.getRole()
    
    func setCell(user: UserModel?) {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped))
        imageProfile.isUserInteractionEnabled = true
        imageProfile.addGestureRecognizer(tap)
        
        userNameLbl.text = user?.name ?? "User Fullname"
        userPhoneLbl.text = user?.phone ?? "+628xxxxxxx"
        userEmailLbl.text = user?.email ?? "xxxx@xxx.com"
        userAddressLbl.text = user?.address ?? "alamat petshop"
        
        userAddressLbl.isHidden = currentRole.elementsEqual("petshop") ? false : true
    }
    
    @objc private func imgTapped() {
        self.onclickImage?()
    }
}