//
//  ViewController.swift
//  AFBrushBoardDemo
//
//  Created by Afry on 16/1/23.
//  Copyright © 2016年 AfryMask. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(AFKnifeView(frame:self.view.frame))
        
    }
}
