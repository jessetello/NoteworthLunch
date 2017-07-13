//
//  GraphsViewController.swift
//  NoteworthLunch
//
//  Created by Jesse Tello on 7/7/17.
//  Copyright © 2017 jt. All rights reserved.
//

import UIKit
import Charts

enum GraphType {
    case price
    case hours
    case openClosed
}

class GraphsViewController: UIViewController {

    var restaurantViewModel:NLRestaurantViewModel?
    var restaurant: NLRestaurant?
    var graphType = GraphType.price
    
    init(restaurant:NLRestaurant, model:NLRestaurantViewModel) {
        self.restaurant = restaurant
        self.restaurantViewModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch graphType {
        case .price:
            priceVsRating()
            break
        case .hours:
            hoursOpen()
            break
        case .openClosed:
            openClosed()
            break
        }
    }
    
    func priceVsRating() {
        self.navigationItem.title = "Price vs Rating"
        let lineChartView = LineChartView(frame: self.view.frame)
        lineChartView.chartDescription?.text = "Price Level vs Rating"
        var dataEntries1: [ChartDataEntry] = []
        self.view.addSubview(lineChartView)

        //Sort price levels
        let prices0 = self.restaurantViewModel?.restaurants.filter {  $0.rating > 0 && $0.rating < 1 }.count
        let prices1 = self.restaurantViewModel?.restaurants.filter {  $0.rating > 1 && $0.rating < 2 }.count
        let prices2 = self.restaurantViewModel?.restaurants.filter {  $0.rating > 2 && $0.rating < 3 }.count
        let prices3 = self.restaurantViewModel?.restaurants.filter {  $0.rating > 3 && $0.rating < 4 }.count
        let prices4 = self.restaurantViewModel?.restaurants.filter {  $0.rating > 4 && $0.rating < 5 }.count
        
        let priceE0 = ChartDataEntry(x:Double(0), y: Double(prices0!))
        let priceE1 = ChartDataEntry(x:Double(1), y: Double(prices1!))
        let priceE2 = ChartDataEntry(x:Double(2), y: Double(prices2!))
        let priceE3 = ChartDataEntry(x:Double(3), y: Double(prices3!))
        let priceE4 = ChartDataEntry(x:Double(4), y: Double(prices4!))
        
        dataEntries1.append(priceE0)
        dataEntries1.append(priceE1)
        dataEntries1.append(priceE2)
        dataEntries1.append(priceE3)
        dataEntries1.append(priceE4)
        
        let lineChartDataSet1 = LineChartDataSet(values: dataEntries1, label: "Price Level")

        let lineChartData = LineChartData()
        lineChartData.addDataSet(lineChartDataSet1)

        lineChartData.setDrawValues(true)
        lineChartDataSet1.colors = [UIColor.red]
        lineChartDataSet1.setCircleColor(UIColor.red)
        lineChartDataSet1.circleHoleColor = UIColor.red
        lineChartDataSet1.circleRadius = 4.0
        
        //Gradient
        let gradientColors = [UIColor.red.cgColor, UIColor.clear.cgColor] as CFArray
        let colorLocations: [CGFloat] = [1.0,0.0]
        guard let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) else {
            return
        }
        
        lineChartDataSet1.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        lineChartDataSet1.drawFilledEnabled = true
        
        //Axis setup
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.setLabelCount(10, force: true)

        lineChartView.chartDescription?.enabled = true
        lineChartView.legend.enabled = true
        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawLabelsEnabled = true
        lineChartView.leftAxis.setLabelCount(6, force: true)

        lineChartView.data = lineChartData
    }
    
    func hoursOpen() {
        //TODO:
    }
    
    func openClosed() {
        self.navigationItem.title = "Open vs Closed"
        let pieChartView = PieChartView(frame: self.view.frame)
        self.view.addSubview(pieChartView)
        
        var dataEntries: [PieChartDataEntry] = []
       
        //Filter for open and closed
        let open = self.restaurantViewModel?.restaurants.filter { $0.openNow == true }
        let closed = self.restaurantViewModel?.restaurants.filter { $0.openNow == false }

        
        //Create entries
        let openEntry = PieChartDataEntry(value: Double((open?.count)!)/Double((self.restaurantViewModel?.restaurants.count)!), label: "Open")
        let closedEntry = PieChartDataEntry(value: Double((closed?.count)!)/Double((self.restaurantViewModel?.restaurants.count)!), label: "Closed")
        dataEntries.append(openEntry)
        dataEntries.append(closedEntry)
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Open Vs Closed")
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        formatter.multiplier = 100
        pieChartDataSet.valueFormatter = DefaultValueFormatter(formatter:formatter)

        let data = PieChartData(dataSets: [pieChartDataSet])
        
        data.setDrawValues(true)
        pieChartView.data = data
        pieChartView.legend.enabled = true
        
        pieChartView.holeRadiusPercent = 0.75
        
        let colors: [UIColor] = [UIColor.green, UIColor.gray]
        pieChartDataSet.colors = colors
    }
}
