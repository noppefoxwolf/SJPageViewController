//
//  ViewController.swift
//  SJPageViewController
//
//  Created by Tomoya Hirano on 2016/01/14.
//  Copyright © 2016年 Tomoya Hirano. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  var viewControllers:[UIViewController] = []
  var pageViewController:SJPageViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    for i in 0...10 {
      let vc = UIViewController()
      vc.view.backgroundColor = getRandomColor()
      let label = UILabel()
      label.text = "page\(i)"
      label.center = vc.view.center
      label.sizeToFit()
      vc.view.addSubview(label)
      viewControllers.append(vc)
    }
    pageViewController?.delegate = self
    pageViewController?.dataSource = self
    pageViewController?.initializationController = viewControllers[1]
    pageViewController?.panGestureRecognizer.addTarget(self, action: "panAction:")
  }
  
  func panAction(gesture:UIPanGestureRecognizer){
    let t = gesture.translationInView(pageViewController?.view)
    pageViewController?.disableSwipePrev = t.x < 40
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let vc = segue.destinationViewController as? SJPageViewController {
      pageViewController = vc
    }
  }
  func getRandomColor() -> UIColor{
    let randomRed:CGFloat = CGFloat(drand48())
    let randomGreen:CGFloat = CGFloat(drand48())
    let randomBlue:CGFloat = CGFloat(drand48())
    return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
  }
}

extension ViewController:SJPageViewControllerDataSource {
  func pageViewController(pageViewController: SJPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    guard var index = viewControllers.indexOf(viewController) else {return nil}
    index++
    return viewControllers[safe: index]
  }
  func pageViewController(pageViewController: SJPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    guard var index = viewControllers.indexOf(viewController) else {return nil}
    index--
    return viewControllers[safe: index]
  }
}
extension ViewController:SJPageViewControllerDelegate{
  func pageViewControllerWillTransition(pageViewController: SJPageViewController) {
    print("start")
  }
  func pageViewController(pageViewController: SJPageViewController, transitionProgress progress: NSProgress, isInverse: Bool) {
    print("\(progress.fractionCompleted) \(isInverse ? "prev" : "next" )")
  }
  func pageViewController(pageViewController: SJPageViewController, didFinishAnimating previousViewController: UIViewController?) {
    print("finish")
  }
}

extension Array {
  subscript (safe index: Int) -> Element? {
    return indices ~= index ? self[index] : nil
  }
}

