//
//  AFBrushBoard.swift
//  AFBrushBoardDemo
//
//  Created by Afry on 16/1/23.
//  Copyright © 2016年 AfryMask. All rights reserved.
//

import UIKit
let size = UIScreen.mainScreen().bounds.size

class AFKnifeView: UIImageView {
    // 存放点集和半径集的数组
    var points:[CGPoint] = [CGPoint]()
    var radius:[CGFloat] = [CGFloat]()
    
    // 初始图片
    var defaultImage:UIImage?
    
    // 差值间隔
    let delta:CGFloat = 1
    
    // 图形上下文
    var ctx:CGContextRef?
    
    override init(frame: CGRect) {
        
        // 控件基本设定
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.userInteractionEnabled = true
        
        // 清除按钮设定
        let btn = UIButton(frame: CGRectMake(0, self.frame.size.height-50, self.frame.size.width, 50))
        btn.backgroundColor = UIColor.cyanColor()
        btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btn.setTitle("清空", forState: UIControlState.Normal)
        btn.addTarget(self, action: "btnClick", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(btn)
        
        // 默认图片设定
        image = UIImage(named: "apple")
        defaultImage = image
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     图片回复初始化
     */
    func btnClick() {
        self.image = defaultImage
    }
    
    /**
     画图
     */
    func changeImage(){
        
        UIGraphicsBeginImageContext(frame.size)
        image!.drawInRect(self.bounds)
        
        // 画线
        for (index,point) in points.enumerate(){
            
            let path = UIBezierPath()
            path.lineWidth = radius[index]
            if index == 0 && points.count != 1{
                continue
            }else if index == 0{
                path.moveToPoint(points[index])
            }else{
                path.moveToPoint(points[index-1])
            }
            path.addLineToPoint(point)
            path.lineJoinStyle = .Round
            path.lineCapStyle = .Round
            path.strokeWithBlendMode(CGBlendMode.Normal, alpha: radius[index]*0.02+0.1)
        }
        
        // 保存图片
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}

// 触摸事件
extension AFKnifeView {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let p = touch?.locationInView(self)
        
        points = [p!]
        radius = [10]
        changeImage()
        
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let p = touch!.locationInView(self)
        
        
        points = [points.last!]
        radius = [radius.last!]
        
        // 线集的首点
        let firstP = points.last!
        let firstR = radius.last!
        
        // 线集两端点的x、y方向差值
        let lineX = firstP.x - p.x
        let lineY = firstP.y - p.y
        
        // 线集两端点的相对距离
        let maxLine = sqrt(pow(lineX, 2) + pow(lineY, 2))
        // 插值数量
        let cou = abs(maxLine/delta)
        // x、y方向的插值距离
        let delX = lineX/cou
        let delY = lineY/cou
        
        // 计算半径的预估值
        let countR = 130/maxLine
        
        // 上一个点的半径
        var baseR = firstR
        for i in 0..<Int(cou) {
            if i == 0 {continue}
            // 半径调整
            var currentR:CGFloat = 0
            if countR > baseR {
                currentR = baseR + 0.1
            }else if countR < baseR{
                currentR = baseR - 0.1
            }else {
                currentR = baseR
            }
            // 半径矫正
            if currentR > 10 {currentR=10}
            if currentR <  1 {currentR=1}
            
            // 计算出插值点
            let currentP = CGPointMake(firstP.x - CGFloat(i)*delX, firstP.y - CGFloat(i)*delY)
            // baseR用语下次插值点的计算
            baseR = currentR
            points.append(currentP)
            radius.append(currentR)
            
        }
        
        changeImage()
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
}