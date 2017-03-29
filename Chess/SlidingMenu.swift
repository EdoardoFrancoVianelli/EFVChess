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
    
    var delegate : SlidingMenuDelegate?
    
    private var table : UITableView?
    
    let heightOffset : CGFloat = 20
    let subViewHeight : CGFloat = 40
    let windowRatio : CGFloat = 0.60
    
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
    /*
    
    func addLabel(text : String){
        let new_label = UILabel(frame: objectFrame())
        new_label.font = UIFont.systemFont(ofSize: 30)
        new_label.text = text
        new_label.textAlignment = .center
        self.addSubview(new_label)
    }
    
    func addButton(text : String){
        let new_button = UIButton(frame: objectFrame())
        new_button.setTitle(text, for: .normal)
        new_button.setTitleColor(UIColor.black, for: .normal)
        new_button.setTitleColor(UIColor.gray, for: .highlighted)
        self.addSubview(new_button)
    }
 
 */
    
    func addSwitch(text : String, section : Int){
        addElement(text: text, subtitle: "", section: section)
    }
    
    func addElement(text : String, subtitle : String, section : Int){
        if section >= elements.count{
            elements.append([(String, String)]())
        }
        elements[section].append((text, subtitle))
    }
    
    private var elements = [[(text : String, subtitle : String)]](){
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
        return elements[section].count
    }
    
    internal func handleValueChanged(sender : UISwitch){
        if let cell = (sender.superview as? UITableViewCell){
            if let cellPath = table?.indexPath(for: cell){
                delegate?.switchChangedValue(sender: sender, i: cellPath)
                hide()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "elementCell")
        cell.textLabel?.text = elements[indexPath.section][indexPath.row].text
        cell.textLabel?.textAlignment = .right
        let subtitle = elements[indexPath.section][indexPath.row].subtitle
        if !subtitle.isEmpty{
           cell.detailTextLabel?.text = subtitle
        }else{
            let opt_switch = UISwitch(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 51.0, height: 31.0)))
            opt_switch.frame.origin = CGPoint(x: frame.size.width - opt_switch.frame.width - 10, y: (cell.frame.size.height / 2) - opt_switch.frame.size.height / 2)
            opt_switch.addTarget(self, action: #selector(handleValueChanged), for: .valueChanged)
            cell.addSubview(opt_switch)
        }
        cell.detailTextLabel?.textAlignment = .right
        return cell
    }
    
    private func selectedRow(indexPath : IndexPath){
        table?.deselectRow(at: indexPath, animated: true)
        delegate?.selectedIndex(i: indexPath, content: elements[indexPath.section][indexPath.row])
        hide()
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
