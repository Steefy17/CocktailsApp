//
//  ContentView.swift
//  CocktailsAppSwiftUI2.0
//
//  Created by user on 29/06/22.
//

import SwiftUI

struct ContentView: View {
    @State var i = true
    @EnvironmentObject var network : SingleDrink
    @EnvironmentObject var network2 : AllDrinks
    var body: some View {
        TabView{
            Home().tabItem{
                    Label("Home", systemImage: "house")
                }
            RandomDrink().tabItem{
                    Label("Random drink", systemImage: "paperplane")
                }
            SearchByIngredient().tabItem{
                    Label("Search by ingredient", systemImage: "magnifyingglass").foregroundColor(.black)
                } .tag(2)
            FavView().tabItem{
                Label("Tried drink", systemImage: "checkmark.circle").foregroundColor(.black)
            }
        }.onAppear{
            if i {
                network2.saveAllDrinks()
                i = false
            }
        }
    }
    init(){
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        UITabBar.appearance().backgroundColor = UIColor.black
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
        ContentView()
            .environmentObject(SingleDrink())
            .environmentObject(AllDrinks())
        }
    }
}
