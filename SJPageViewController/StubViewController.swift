//
//  StubViewController.swift
//  SJPageViewController
//
//  Created by Tomoya Hirano on 2016/01/14.
//  Copyright © 2016年 Tomoya Hirano. All rights reserved.
//

import UIKit

class StubViewController: UIViewController {
  @IBOutlet weak var label: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    label.text = title
    label.sizeToFit()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    print("viewWillAppear:\(title)")
  }
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    print("viewDidAppear:\(title)")
  }
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    print("viewWillDisappear:\(title)")
  }
  override func viewDidDisappear(animated: Bool) {
    super.viewDidAppear(animated)
    print("viewDidDisappear:\(title)")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}
