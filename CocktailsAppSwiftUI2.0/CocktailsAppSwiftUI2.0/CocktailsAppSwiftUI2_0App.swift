//
//  CocktailsAppSwiftUI2_0App.swift
//  CocktailsAppSwiftUI2.0
//
//  Created by user on 29/06/22.
//

import SwiftUI

@main
struct CocktailsAppSwiftUI2_0App: App {
    
    var network = SingleDrink()
    var network2 = AllDrinks()
    var body: some Scene {
        WindowGroup {
            NavigationView{
            ContentView()
                .environmentObject(network)
                .environmentObject(network2)
            }
        }
    }
}
