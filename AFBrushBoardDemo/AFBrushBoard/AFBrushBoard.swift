//
//  AFBrushBoard.swift
//  AFBrushBoardDemo
//
//  Created by Afry on 16/1/23.
//  Copyright © 2016年 AfryMask. All rights reserved.
//

import UIKit
let size = UIScreen.mainScreen().bounds.size

class AFBrushBoard: UIImageView {
    // 存放点集的数组
    var points:[CGPoint] = [CGPoint]()
    // 当前半径
    var currentRadius:CGFloat = 10
    
    // 初始图片
    var defaultImage:UIImage?
    // 上次图片
    var lastImage:UIImage?
    
    // 最大和最小半径
    let minRadius:CGFloat = 5
    let maxRadius:CGFloat = 13
    
    // 设置调试
    let debug = false
    
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
        lastImage = image
        
        if debug{
            points = [CGPointMake(100, 100),CGPointMake(200, 100),CGPointMake(200, 200)]
            currentRadius = 10
            changeImage()
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /**
     图片恢复初始化
     */
    func btnClick() {
        image = defaultImage
        lastImage = defaultImage
        currentRadius = 10
    }
    
    /**
     画图
     */
    func changeImage(){
        UIGraphicsBeginImageContext(frame.size)
        lastImage!.drawInRect(self.bounds)
        
        if debug{
            var pointPath = UIBezierPath(arcCenter: points[2], radius: 3, startAngle: 0, endAngle: CGFloat(M_PI)*2.0, clockwise: true)
            UIColor.redColor().set()
            pointPath.stroke()
            pointPath = UIBezierPath(arcCenter: points[1], radius: 3, startAngle: 0, endAngle: CGFloat(M_PI)*2.0, clockwise: true)
            pointPath.stroke()
            pointPath = UIBezierPath(arcCenter: points[0], radius: 3, startAngle: 0, endAngle: CGFloat(M_PI)*2.0, clockwise: true)
            pointPath.stroke()
        }
        

        // 贝赛尔曲线的起始点和末尾点
        let tempPoint1 = CGPointMake((points[0].x+points[1].x)/2, (points[0].y+points[1].y)/2)
        let tempPoint2 = CGPointMake((points[1].x+points[2].x)/2, (points[1].y+points[2].y)/2)
        
        
        // 贝赛尔曲线的估算长度
        let x1 = abs(tempPoint1.x-tempPoint2.x)
        let x2 = abs(tempPoint1.y-tempPoint2.y)
        let len = Int(sqrt(pow(x1, 2) + pow(x2,2))*10)
        
        // 如果仅仅点击一下
        if len == 0 {
            let zeroPath = UIBezierPath(arcCenter: points[1], radius: 6, startAngle: 0, endAngle: CGFloat(M_PI)*2.0, clockwise: true)
            zeroPath.fill()
            UIColor.blackColor().setFill()
            
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return
        }
        
        // 如果距离过短，直接画线
        if len < 10 {
            let zeroPath = UIBezierPath()
            zeroPath.moveToPoint(tempPoint1)
            zeroPath.addLineToPoint(tempPoint2)
            
            currentRadius += 0.05
            if currentRadius > maxRadius {currentRadius = maxRadius}
            if currentRadius < minRadius {currentRadius = minRadius}
            
            // 画线
            zeroPath.lineWidth = currentRadius
            zeroPath.lineCapStyle = .Round
            zeroPath.lineJoinStyle = .Round

            UIColor(white: 0, alpha: (currentRadius-minRadius)/maxRadius*0.15+0.1).setStroke()
            zeroPath.stroke()
            
            lastImage = UIGraphicsGetImageFromCurrentImageContext()
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return
        }
        
        
        // 控制点的制作
        let controlPoint01 = CGPointMake((tempPoint1.x+points[1].x)/2, (tempPoint1.y+points[1].y)/2)
        let controlPoint02 = CGPointMake((tempPoint2.x+points[1].x)/2, (tempPoint2.y+points[1].y)/2)
        let controlPoint1 = CGPointMake((controlPoint01.x+points[1].x)/2, (controlPoint01.y+points[1].y)/2)
        let controlPoint2 = CGPointMake((controlPoint02.x+points[1].x)/2, (controlPoint02.y+points[1].y)/2)
        
        // 贝赛尔曲线的计算
        var s:CGFloat = 0.0
        var t:[CGFloat] = [CGFloat]()
        let pc:CGFloat = 1/CGFloat(len)

        for _ in 0...len+1 {t.append(s);s=s+pc}
        var newx:[CGFloat] = [CGFloat]()
        var newy:[CGFloat] = [CGFloat]()
        
        for i in 0...len+1 {
            newx.append(tempPoint1.x * bezMaker(3, k:0, t:t[i])
                + controlPoint1.x * bezMaker(3, k:1, t:t[i])
                + controlPoint2.x * bezMaker(3, k:2, t:t[i])
                + tempPoint2.x * bezMaker(3, k:3, t:t[i]))
            newy.append(tempPoint1.y * bezMaker(3, k:0, t:t[i])
                + controlPoint1.y * bezMaker(3, k:1, t:t[i])
                + controlPoint2.y * bezMaker(3, k:2, t:t[i])
                + tempPoint2.y * bezMaker(3, k:3, t:t[i]))
        }
        
        // 目标半径
        let aimRadius:CGFloat = CGFloat(500)/CGFloat(len)*(maxRadius-minRadius)
        
        // 画每条线段
        var lastPoint:CGPoint = tempPoint1
        for(var i=0;i<len+1;i++)
        {
            let bPath = UIBezierPath()
            bPath.moveToPoint(lastPoint)
            
            // 省略多余的点
            let delta = sqrt(pow(newx[i]-lastPoint.x, 2) + pow(newy[i]-lastPoint.y, 2))
            if delta < 1 {continue}
            lastPoint = CGPointMake(newx[i], newy[i])
            
            bPath.addLineToPoint(CGPointMake(newx[i], newy[i]))
            
            // 计算当前点
            if currentRadius > aimRadius {
                currentRadius -= 0.05
            }else{
                currentRadius += 0.05
            }
            if currentRadius > maxRadius {currentRadius = maxRadius}
            if currentRadius < minRadius {currentRadius=minRadius}
            
            
            // 画线
            bPath.lineWidth = currentRadius
            bPath.lineCapStyle = .Round
            bPath.lineJoinStyle = .Round
            UIColor(white: 0, alpha: (currentRadius-minRadius)/maxRadius*0.15+0.1).setStroke()
            bPath.stroke()

        }
        
        // 保存图片
        lastImage = UIGraphicsGetImageFromCurrentImageContext()
        
        let pointCount = Int(sqrt(pow(tempPoint2.x-points[2].x,2)+pow(tempPoint2.y-points[2].y,2)))*2
        let delX = (tempPoint2.x-points[2].x)/CGFloat(pointCount)
        let delY = (tempPoint2.y-points[2].y)/CGFloat(pointCount)
        
        var addRadius = currentRadius
        
        // 尾部线段
        for(var i=0;i<pointCount;i++)
        {
            let bpath = UIBezierPath()
            bpath.moveToPoint(lastPoint)
            
            let newPoint = CGPointMake(lastPoint.x-delX, lastPoint.y-delY)

            lastPoint = newPoint
            
            bpath.addLineToPoint(newPoint)
            
            // 计算当前点
            if addRadius > aimRadius {
                addRadius -= 0.02
            }else{
                addRadius += 0.02
            }
            if addRadius > maxRadius {addRadius = maxRadius}
            if addRadius < 0 {addRadius=0}
            
            
            // 画线
            bpath.lineWidth = addRadius
            bpath.lineCapStyle = .Round
            bpath.lineJoinStyle = .Round
            UIColor(white: 0, alpha: (currentRadius-minRadius)/maxRadius*0.07+0.05).setStroke()
            bpath.stroke()
            
        }

        
        image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
}

// 触摸事件
extension AFBrushBoard {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let p = touch!.locationInView(self)
        
        points = [p,p,p]
        currentRadius = 10
        changeImage()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let p = touch!.locationInView(self)
        
        points = [points[1],points[2],p]
        changeImage()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        lastImage = image
    }

    
}
extension AFBrushBoard {
    func comp(n:Int, k:Int) -> CGFloat{
        var s1:Int = 1
        var s2:Int = 1
        
        if k == 0 {return 1}
        
        for(var i=n;i>=n-k+1;i--) {s1=s1*i}
        for(var i=k;i>=2;i--) {s2=s2*i}
        
        return CGFloat(s1/s2)
    }
    
    func realPow(n:CGFloat, k:Int) -> CGFloat{
        if k==0 {return 1.0}
        return pow(n, CGFloat(k))
    }
    
    func bezMaker(n:Int, k:Int, t:CGFloat) -> CGFloat{
        return comp(n, k: k) * realPow(1-t, k: n-k) * realPow(t, k: k)
    }
}

