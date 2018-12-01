//
//  HomeViewController.swift
//  StateOfChain
//
//  Created by Hoang Hiep Ho on 12/1/18.
//  Copyright © 2018 Gamedex. All rights reserved.
//

import UIKit
import CircleSlider
import XJYChart

class HomeViewController: UIViewController, XJYChartDelegate {

    @IBOutlet var barchartView: UIView!
    @IBOutlet var activityView: UIView!
    @IBOutlet var bodyCircle: UIView!
    @IBOutlet var lifestyleCircle: UIView!
    @IBOutlet var moodCircle: UIView!
    
    var circleSlider1: CircleSlider!
    var circleSlider2: CircleSlider!
    var circleSlider3: CircleSlider!
    
    private var sliderOptions: [CircleSliderOption] {
        return [
            CircleSliderOption.barColor(UIColor(red: 77 / 255, green: 77 / 255, blue: 255 / 255, alpha: 1)),
            CircleSliderOption.thumbColor(UIColor(red: 127 / 255, green: 185 / 255, blue: 204 / 255, alpha: 1)),
            CircleSliderOption.trackingColor(UIColor(red: 238 / 255, green: 68 / 255, blue: 68 / 255, alpha: 1)),
            CircleSliderOption.barWidth(10),
            CircleSliderOption.startAngle(-45),
            CircleSliderOption.maxValue(100),
            CircleSliderOption.minValue(0),
            CircleSliderOption.thumbImage(UIImage(named: "thumb_image_1")!),
            CircleSliderOption.sliderEnabled(false)
        ]
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.circleSlider1 = CircleSlider(frame: self.lifestyleCircle.bounds, options: sliderOptions)
        self.circleSlider2 = CircleSlider(frame: self.lifestyleCircle.bounds, options: sliderOptions)
        self.circleSlider3 = CircleSlider(frame: self.lifestyleCircle.bounds, options: sliderOptions)
        
        self.lifestyleCircle.addSubview(self.circleSlider1)
        self.moodCircle.addSubview(self.circleSlider2)
        self.bodyCircle.addSubview(self.circleSlider3)
        
        // Do any additional setup after loading the view.
        
        activityView.layer.cornerRadius = 10
        activityView.layer.masksToBounds = true
        
        setupChartbar()
    }
    
    func setupChartbar(){
        var itemArray: [AnyHashable] = []
        let waveColor = UIColor.wave()
        
        let item2 = XBarItem(dataNumber: 90.04, color: waveColor, dataDescribe: "26 Nov")
        itemArray.append(item2!)
        let item3 = XBarItem(dataNumber: 80.99, color: waveColor, dataDescribe: "27 Nov")
        itemArray.append(item3!)
        let item4 = XBarItem(dataNumber: 110.48, color: waveColor, dataDescribe: "28 Nov")
        itemArray.append(item4!)
        let item5 = XBarItem(dataNumber: 192.91, color: waveColor, dataDescribe: "29 Nov")
        itemArray.append(item5!)
        let item6 = XBarItem(dataNumber: 74.93, color: waveColor, dataDescribe: "30 Nov")
        itemArray.append(item6!)
        let item7 = XBarItem(dataNumber: 90.04, color: waveColor, dataDescribe: "1 Dec")
        itemArray.append(item7!)
        let item1 = XBarItem(dataNumber: 185, color: waveColor, dataDescribe: "Today")
        itemArray.append(item1!)
        
       
        let configuration = XBarChartConfiguration()
        configuration.isScrollable = false
        configuration.x_width = 27
        let barChart = XBarChart(frame: CGRect(x: 0, y: 0, width: 375, height: 200), dataItemArray: NSMutableArray(array: itemArray), topNumber: 300, bottomNumber: 0, chartConfiguration: configuration)
        barChart!.barChartDeleagte = self
        
        barchartView.addSubview(barChart!)
    }

    @IBAction func invokeBtn(_ sender: Any) {
        self.circleSlider1.value = 100
    }
    
}
