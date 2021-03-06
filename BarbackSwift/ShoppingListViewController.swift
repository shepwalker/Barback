//
//  ShoppingListViewController.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/19/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import UIKit

class ShoppingListViewController: RecipeListViewController {

    var ingredients: [IngredientBase] = [IngredientBase]() {
    willSet(newIngredients) {
        ingredientTypes = IngredientType.allValues.filter({
            (type: IngredientType) -> Bool in
            return (
                newIngredients.filter({ $0.type == type }).count > 0
            )
        })
    }
    }
    var ingredientTypes: [IngredientType] = [IngredientType]()
    var selectedCellIndices = [Int]()
    
    override var viewTitle: String {
        get {
            return "Shopping List"
        }
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        // Custom initialization
    }
override     
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func setIngredients(ingredients: [IngredientBase]) {
        self.ingredients = ingredients
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create ourselves a back button.
        let backButton = UIBarButtonItem(title: "Back", style:UIBarButtonItemStyle.Bordered, target: self, action: "goBack")
        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: UIFont.primaryFont(), size: 16)], forState: UIControlState.Normal)
        navigationItem.leftBarButtonItem = backButton
        
        // Preserve selection of table elements.
        clearsSelectionOnViewWillAppear = false
    }
    
    func goBack() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return ingredientTypes.count
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        let ingredientType = ingredientTypes[section]
        let ingredientsForType = ingredients.filter({$0.type == ingredientType})
        return ingredientsForType.count
    }
    
    override func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        var sectionLabel = UILabel()
        sectionLabel.frame = CGRectMake(20, 0, 320, 40)
        sectionLabel.font = UIFont(name: UIFont.heavyFont(), size: 16)
        sectionLabel.textAlignment = NSTextAlignment.Left
        sectionLabel.textColor = UIColor.lightColor()
        
        sectionLabel.text = ingredientTypes[section].pluralize().capitalizedString
        
        var headerView = UIView()
        headerView.addSubview(sectionLabel)
        
        return headerView
    }
    
    
    override func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 40
    }

    override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        return ingredientTypes[section].toRaw()
    }
    
    
    // Used in conjunction with selectedCellIndices to keep track of selected cells
    func cellKeyForIndexPath(indexPath: NSIndexPath!) -> Int {
        return indexPath.section * 100 + indexPath.row
    }
    
    // Used in conjunction with selectedCellIndices to keep track of selected cells
    func selectedCellTableIndexForIndexPath(indexPath: NSIndexPath!) -> Int? {
        let cellKey = cellKeyForIndexPath(indexPath)
        return find(selectedCellIndices, cellKey)
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {
        
        let cellIdentifier = "shoppingCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if !(cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: cellIdentifier)
        }
        
        let ingredientType = ingredientTypes[indexPath.section]
        let ingredientsForType = ingredients.filter({$0.type == ingredientType})
        cell!.textLabel.text = ingredientsForType[indexPath.row].name
        cell!.stylePrimary()
        
        if (selectedCellTableIndexForIndexPath(indexPath) != nil) {
            cell!.textLabel.textColor = UIColor.lighterColor()
        }
        
        return cell!
    }

    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        
        if let cellIndex = selectedCellTableIndexForIndexPath(indexPath) {
            selectedCell.textLabel.textColor = UIColor.lightColor()
            selectedCellIndices.removeAtIndex(cellIndex)
        } else {
            selectedCell.textLabel.textColor = UIColor.lighterColor()
            selectedCellIndices.append(cellKeyForIndexPath(indexPath))
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
