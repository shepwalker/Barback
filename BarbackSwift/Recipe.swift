//
//  Recipe.swift
//  BarbackSwift
//
//  Created by Justin Duke on 6/13/14.
//  Copyright (c) 2014 Justin Duke. All rights reserved.
//

import Foundation

class Recipe: Equatable {
    var name: String
    var lowercaseName: String // Actually making this a variable for performance reasons.
    var directions: String
    var glassware: String
    var ingredients: [Ingredient]
    
    var favorited: Bool {
        get {
            var currentFavorites: NSMutableArray = NSMutableArray(array: NSUserDefaults.standardUserDefaults().arrayForKey("saved"))
            return currentFavorites.containsObject(name)
        }
        set(newBool) {
            var currentFavorites: NSMutableArray = NSMutableArray(array: NSUserDefaults.standardUserDefaults().arrayForKey("saved"))
            if currentFavorites.containsObject(name) && !newBool {
                currentFavorites.removeObject(name)
            } else if newBool {
                currentFavorites.addObject(name)
            }
            NSUserDefaults.standardUserDefaults().setObject(currentFavorites, forKey: "saved")
        }
    }
    
    var detailDescription: String {
        get {
        let ingredients = self.ingredients.filter({ingredient in !ingredient.isSpecial}).map({
            (ingredient: Ingredient) -> String in
            return ingredient.base.name
            })
        return join(", ", ingredients)
        }
    }
    
    // Should only be used for 'fake' recipes.
    convenience init(name: String) {
        self.init(name: name, directions: "", glassware: "", ingredients: [Ingredient]())
    }
    
    init(name: String, directions: String, glassware: String, ingredients: [Ingredient]) {
        self.name = name
        self.lowercaseName = name.lowercaseString
        self.directions = directions
        self.glassware = glassware
        self.ingredients = ingredients
    }
    
    convenience init(rawRecipe: NSDictionary) {
        let name = rawRecipe.objectForKey("name") as String
        let directions = rawRecipe.objectForKey("preparation") as String
        let glassware = rawRecipe.objectForKey("glass") as String
        
        let rawIngredients = rawRecipe.objectForKey("ingredients") as [NSDictionary]
        let ingredients = rawIngredients.map({
            (rawIngredient: NSDictionary) -> Ingredient in
            return Ingredient(rawIngredient: rawIngredient)
            })
        
        self.init(name: name, directions: directions, glassware: glassware, ingredients: ingredients)
    }
    
    class func random() -> Recipe {
        let allRec = AllRecipes.sharedInstance
        return allRec[Int(arc4random_uniform(UInt32(allRec.count)))]
    }
    
    func similarRecipes(recipeCount: Int) -> [Recipe] {
        let ingredientBases = ingredients.map({$0.base.name})
        let numberOfSimilarIngredientsRequired = Int(ceil(Double(ingredients.count) / 2.0))
        
        var similarRecipes = AllRecipes.sharedInstance.filter({
            (recipe: Recipe) -> Bool in
            let comparisonBases = recipe.ingredients.map({$0.base.name})
            let matchedIngredients = ingredientBases.filter({ contains(comparisonBases, $0) })
            return matchedIngredients.count >= numberOfSimilarIngredientsRequired && recipe.name != self.name
        })
        
        if similarRecipes.count <= recipeCount {
            return similarRecipes
        }
        
        var chosenRecipes: [Recipe] = [Recipe]()
        while chosenRecipes.count < recipeCount {
            let randomIndex = Int(arc4random_uniform(UInt32(similarRecipes.count)))
            chosenRecipes.append(similarRecipes[randomIndex])
            similarRecipes.removeAtIndex(randomIndex)
        }
        return chosenRecipes
    }

    func matchesTerms(searchTerms: [NSString]) -> Bool {
        for term: NSString in searchTerms {
            
            // If the term is nil (e.g. the second item in "orange,", match errything.
            if term == "" {
                continue
            }
            
            // If the term matches the name of the recipe..
            if (lowercaseName.rangeOfString(term) != nil) {
                continue
            }
            
            // Or at least one ingredient in it.
            let matchedIngredients = ingredients.filter({
                (ingredient: Ingredient) -> Bool in
                return ingredient.matchesTerm(term)
            })
            if matchedIngredients.count > 0 {
                continue
            }
            
            // Otherwise, no luck.
            return false
        }
        return true
    }
}


func == (lhs: Recipe, rhs: Recipe) -> Bool {
    return lhs.name == rhs.name
}


class AllRecipes {
    class var sharedInstance : [Recipe] {
        struct Static {
            static let instance : [Recipe] = Static.allRecipes()
            static func allRecipes() -> [Recipe] {
                let filepath = NSBundle.mainBundle().pathForResource("recipes", ofType: "json")
                let jsonData = NSString.stringWithContentsOfFile(filepath!, encoding:NSUTF8StringEncoding, error: nil)
                let recipeData = jsonData.dataUsingEncoding(NSUTF8StringEncoding)
                var rawRecipes = NSJSONSerialization.JSONObjectWithData(recipeData!, options: nil, error: nil) as [NSDictionary]
                
                var allRecipes: [Recipe] = rawRecipes.map({
                    (rawRecipe: NSDictionary) -> Recipe in
                    return Recipe(rawRecipe: rawRecipe)
                    })
                allRecipes = allRecipes.sorted({ $0.name < $1.name })
                return allRecipes
            }
        }
        return Static.instance
    }
}