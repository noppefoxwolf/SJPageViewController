//
//  SJPageViewController.swift
//  SJPageViewController
//
//  Created by Tomoya Hirano on 2016/01/14.
//  Copyright © 2016年 Tomoya Hirano. All rights reserved.
//

import UIKit

protocol SJPageViewControllerDataSource{
  func pageViewController(pageViewController: SJPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
  func pageViewController(pageViewController: SJPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
}
protocol SJPageViewControllerDelegate{
  func pageViewControllerWillTransition(pageViewController: SJPageViewController)
  func pageViewController(pageViewController: SJPageViewController,transitionProgress progress: NSProgress,isInverse:Bool)
  func pageViewController(pageViewController: SJPageViewController,didFinishAnimating previousViewController:UIViewController?)
}

class SJPageViewController: UIViewController {
  var delegate:SJPageViewControllerDelegate?
  var dataSource:SJPageViewControllerDataSource?
  
  var panGestureRecognizer:UIPanGestureRecognizer!
  var currentViewController:UIViewController?{
    return currentContainer.viewController
  }
  
  private var containers:[SJPageContainerView] = []
  private var prevContainer:SJPageContainerView{return containers[0]}
  private var currentContainer:SJPageContainerView{return containers[1]}
  private var nextContainer:SJPageContainerView{return containers[2]}
  private var duringTransition = false
  private var beforeTranslation = CGPointZero
  
  ///Configs
  var initializationController:UIViewController!{
    didSet{
      currentContainer.viewController = self.initializationController
    }
  }
  var interPageSpacing:CGFloat = 3.0
  var requireVelocity:CGFloat = 20.0
  var disableSwipeNext  = false
  var disableSwipePrev = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    for _ in 0..<3 {containers.append(SJPageContainerView())}
    view.addSubview(currentContainer)
    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panAction:")
    view.addGestureRecognizer(panGestureRecognizer)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    currentContainer.frame = view.bounds
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  func panAction(gesture:UIPanGestureRecognizer){
    guard let currentVC = currentContainer.viewController else {return}
    let t = gesture.translationInView(view)
    let v = gesture.velocityInView(view)
    
    if gesture.state == .Began {
      guard duringTransition == false else {return}
      duringTransition = true
      if let nextVC = dataSource?.pageViewController(self, viewControllerAfterViewController: currentVC) {
        nextContainer.viewController = nextVC
        nextContainer.frame = view.bounds
        nextContainer.center = CGPoint(x: view.center.x * 3.0 + interPageSpacing,y: view.center.y)
        view.addSubview(nextContainer)
      }
      if let prevVC = dataSource?.pageViewController(self, viewControllerBeforeViewController: currentVC) {
        prevContainer.viewController = prevVC
        prevContainer.frame = view.bounds
        prevContainer.center = CGPoint(x: -view.center.x - interPageSpacing,y: view.center.y)
        view.addSubview(prevContainer)
      }
      beforeTranslation = t
      delegate?.pageViewControllerWillTransition(self)
    }else if gesture.state == .Changed {
      guard duringTransition == true else {return}
      let tX = t.x - beforeTranslation.x
      if (tX < 0 && currentContainer.center.x <= view.center.x && (nextContainer.viewController == nil || disableSwipeNext )) ||
         (tX > 0 && currentContainer.center.x >= view.center.x && (prevContainer.viewController == nil || disableSwipePrev )) {
        currentContainer.center.x = view.center.x
      }else{
        currentContainer.center.x = currentContainer.center.x + tX
        prevContainer.center.x = prevContainer.center.x + tX
        nextContainer.center.x = nextContainer.center.x + tX
      }
      beforeTranslation = t
      let progress = NSProgress(totalUnitCount: Int64(view.bounds.width))
      progress.completedUnitCount = abs(Int64(view.center.x - currentContainer.center.x))
      delegate?.pageViewController(self, transitionProgress: progress, isInverse: currentContainer.center.x > view.center.x)
    }else{
      beforeTranslation = CGPointZero
      guard duringTransition == true else {return}
      let duration = NSTimeInterval(min(200.0 / abs(v.x),0.3))
      if v.x < -requireVelocity && currentContainer.center.x < view.center.x && nextContainer.viewController != nil {
        nextPageMovingAnimation(duration)
      }else if v.x > requireVelocity && currentContainer.center.x > view.center.x && prevContainer.viewController != nil {
        beforePageMovingAnimation(duration * 0.9)
      }else{
        resetPositionAnimation()
      }
    }
  }
  
  func resetPositionAnimation(){
    UIView.animateWithDuration(0.2, delay: 0.0, options: [.AllowAnimatedContent], animations: { () -> Void in
      self.prevContainer.center    = CGPoint(x: -self.view.center.x - self.interPageSpacing,y: self.view.center.y)
      self.currentContainer.center = self.view.center
      self.nextContainer.center    = CGPoint(x: self.view.center.x * 3.0 + self.interPageSpacing,y: self.view.center.y)
      },completion: { (finish) -> Void in
        self.prevContainer.viewController = nil
        self.nextContainer.viewController = nil
        self.prevContainer.removeFromSuperview()
        self.nextContainer.removeFromSuperview()
        self.currentContainer.center = self.view.center
        self.duringTransition = false
        self.delegate?.pageViewController(self, didFinishAnimating: self.currentContainer.viewController)
    })
  }
  
  func beforePageMovingAnimation(duration: NSTimeInterval){
    UIView.animateWithDuration(duration, delay: 0.0, options: [.AllowAnimatedContent], animations: { () -> Void in
      self.prevContainer.center    = self.view.center
      self.currentContainer.center = CGPoint(x: self.view.center.x * 3.0 + self.interPageSpacing, y: self.view.center.y)
      self.nextContainer.center    = CGPoint(x: self.view.center.x * 5.0 + (self.interPageSpacing * 2.0), y: self.view.center.y)
      },completion: { (finish) -> Void in
        let prevVC = self.currentContainer.viewController
        self.currentContainer.viewController = self.prevContainer.viewController
        self.prevContainer.viewController = nil
        self.nextContainer.viewController = nil
        self.prevContainer.removeFromSuperview()
        self.nextContainer.removeFromSuperview()
        self.currentContainer.center = self.view.center
        self.duringTransition = false
        self.delegate?.pageViewController(self, didFinishAnimating: prevVC)
    })
  }
  func nextPageMovingAnimation(duration: NSTimeInterval){
    UIView.animateWithDuration(duration, delay: 0.0, options: [.AllowAnimatedContent], animations: { () -> Void in
      self.prevContainer.center    = CGPoint(x: -self.view.center.x * 5.0 - (self.interPageSpacing * 2.0), y: self.view.center.y)
      self.currentContainer.center = CGPoint(x: -self.view.center.x - self.interPageSpacing, y: self.view.center.y)
      self.nextContainer.center    = self.view.center
      },completion: { (finish) -> Void in
        let prevVC = self.currentContainer.viewController        
        self.currentContainer.viewController = self.nextContainer.viewController
        self.prevContainer.viewController = nil
        self.nextContainer.viewController = nil
        self.prevContainer.removeFromSuperview()
        self.nextContainer.removeFromSuperview()
        self.currentContainer.center = self.view.center
        self.duringTransition = false
        self.delegate?.pageViewController(self, didFinishAnimating: prevVC)
    })
  }
}


private class SJPageContainerView:UIView{
  var viewController:UIViewController?{
    didSet{
      subviews.forEach({$0.removeFromSuperview()})
      if let vcv = self.viewController?.view {
        vcv.frame = bounds
        addSubview(vcv)
      }
    }
  }
}