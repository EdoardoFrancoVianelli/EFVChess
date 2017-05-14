//
//  SlidingMenu.swift
//  Chess
//
//  Created by Edoardo Franco Vianelli on 2/24/17.
//  Copyright © 2017 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

protocol SlidingMenuDelegate {
    func selectedIndex(i : IndexPath, content : (text : String, subtitle : String))
    func switchChangedValue(sender : UISwitch, i : IndexPath)
}

class SlidingMenu: UIView, UITableViewDelegate, UITableViewDataSource{
    
    static let cellIdentifier = "RegularCell"
    static let switchIdentifier = "SwitchCell"
    
    var delegate : SlidingMenuDelegate?
    
    private var table : UITableView?
    
    private let heightOffset : CGFloat = 20
    private let subViewHeight : CGFloat = 40
    private let windowRatio : CGFloat = 0.60
    private var switchValues = [[Bool]]()
    
    init(sp : UIView){
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor.lightGray
        
        self.frame.origin = CGPoint(x: sp.frame.size.width, y: 0)
        self.frame.size = sp.frame.size
        self.frame.size.width *= windowRatio
        
        sp.addSubview(self)
        
        initPanGesture(sp: sp)
        
        table = UITableView(frame: CGRect(origin: CGPoint.zero, size: self.frame.size), style: UITableViewStyle.grouped)
        table?.delegate = self
        table?.dataSource = self
        self.addSubview(table!)
    }
    
    func setSwitchValue(section : Int, row : Int, value : Bool){
        while row >= self.switchValues[section].count{
            self.switchValues[section].append(true)
        }
        self.switchValues[section][row] = value
    }
    
    func initPanGesture(sp : UIView){
        let screenEdgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        screenEdgeGesture.edges = .right
        sp.addGestureRecognizer(screenEdgeGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        self.addGestureRecognizer(panGesture)
    }
    
    func setX(x : CGFloat, duration : TimeInterval){
        UIView.animate(withDuration: duration, animations: {
            self.frame.origin.x = x
        })
    }
    
    func objectFrame() -> CGRect{
        let startingY = CGFloat(self.subviews.count) * subViewHeight + heightOffset
        let width = self.frame.size.width
        let x : CGFloat = 0.0
        return CGRect(x: x, y: startingY, width: width, height: subViewHeight)
    }
    
    func addSwitch(text : String, section : Int, on : Bool){
        while section >= self.switchValues.count{
            self.switchValues.append([Bool]())
        }
        setSwitchValue(section: section, row: switchValues[section].count, value: on)
        addElement(text: text, subtitle: "", kind : SlidingMenu.switchIdentifier, section: section)
    }
    
    func addElement(text : String, subtitle : String, kind : String, section : Int){
        if section >= elements.count{
            elements.append([(String, String, String)]())
        }
        elements[section].append((text, subtitle, kind))
    }
    
    private var elements = [[(text : String, subtitle : String, kind : String)]](){
        didSet{
           table?.reloadData()
        }
    }
    
    func addHeader(name : String){
        headers.append(name)
    }
    
    private var headers = ["Game Options"]
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headers.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section >= elements.count{
            return 0
        }
        return elements[section].count
    }
    
    internal func handleValueChanged(sender : UISwitch){
        if let cell = (sender.superview as? UITableViewCell){
            if let cellPath = table?.indexPath(for: cell){
                delegate?.switchChangedValue(sender: sender, i: cellPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "elementCell")
        cell.textLabel?.text = elements[indexPath.section][indexPath.row].text
        cell.textLabel?.textAlignment = .right
        let current = elements[indexPath.section][indexPath.row]
        if current.kind == SlidingMenu.cellIdentifier{
           cell.detailTextLabel?.text = current.subtitle
        }else if current.kind == SlidingMenu.switchIdentifier{
            let opt_switch = UISwitch(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 51.0, height: 31.0)))
            opt_switch.isOn = true
            if indexPath.section < self.switchValues.count{
                if indexPath.row < self.switchValues[indexPath.section].count{
                    opt_switch.isOn = self.switchValues[indexPath.section][indexPath.row]
                }
            }
            opt_switch.frame.origin = CGPoint(x: frame.size.width - opt_switch.frame.width - 10, y: (cell.frame.size.height / 2) - opt_switch.frame.size.height / 2)
            opt_switch.addTarget(self, action: #selector(handleValueChanged), for: .valueChanged)
            cell.addSubview(opt_switch)
        }
        cell.detailTextLabel?.textAlignment = .right
        return cell
    }
    
    private func selectedRow(indexPath : IndexPath){
        table?.deselectRow(at: indexPath, animated: true)
        let current = elements[indexPath.section][indexPath.row]
        delegate?.selectedIndex(i: indexPath, content: (current.text, current.subtitle))
        if current.kind == SlidingMenu.cellIdentifier{
            hide()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow(indexPath: indexPath)
    }
    
    func show(){
        setX(x: superview!.frame.width * windowRatio, duration: 0.3)
    }
    
    func hide(){
        setX(x: superview!.frame.width, duration: 0.3)
    }
    
    func handlePan(sender : UIGestureRecognizer){
        let x : CGFloat = sender.location(in: superview).x
        switch sender.state{
            case .ended:
                let endLocation = (x < superview!.frame.size.width * (1 - (windowRatio * 0.5)))  ? superview!.frame.size.width * (1 - windowRatio) : superview!.frame.size.width
                setX(x: endLocation, duration: 0.3)
            case .changed:
                if x > superview!.frame.width * (1 - windowRatio){
                    setX(x: x, duration: 0.1)
                }
            default:
                break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
