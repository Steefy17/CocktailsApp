//
//  SearchByIngredient.swift
//  CocktailsAppSwiftUI2.0
//
//  Created by user on 29/06/22.
//

import SwiftUI

struct SearchByIngredient: View {
    @State var myDrink : drinkContainer?
    @State var img : [String] = []
    @State var drinkId : [drinknames] = []
    @State private var name: String = ""
    @State var shouldHide = true
    
    
    var body: some View {
        
        ZStack{
            backgroundGradient2
                .ignoresSafeArea()
            VStack{
                HStack{
                    
                    NavigationLink(destination: DrinkByIngredientSecView("Rum")){
                        Text("Rum").background(Capsule().fill(Color.yellow).shadow(radius: 3).frame(width: 150, height: 75)).frame(width: 175, height: 100).foregroundColor(.black)
                    }
                    
                    NavigationLink(destination: DrinkByIngredientSecView("Vodka")){
                        Text("Vodka").background(Capsule().fill(Color.yellow).shadow(radius: 3).frame(width: 150, height: 75)).frame(width: 175, height: 100).foregroundColor(.black)
                    }
                }
                HStack{
                    NavigationLink(destination: DrinkByIngredientSecView("Gin")){
                        Text("Gin").background(Capsule().fill(Color.yellow).shadow(radius: 3).frame(width: 150, height: 75)).frame(width: 175, height: 100).foregroundColor(.black)
                    }
                    NavigationLink(destination: DrinkByIngredientSecView("Tequila")){
                        Text("Tequila").background(Capsule().fill(Color.yellow).shadow(radius: 3).frame(width: 150, height: 75)).frame(width: 175, height: 100).foregroundColor(.black)
                    }
                }
                HStack{
                    NavigationLink(destination: DrinkByIngredientSecView("Whiskey")){
                        Text("Whiskey").background(Capsule().fill(Color.yellow).shadow(radius: 3).frame(width: 150, height: 75)).frame(width: 175, height: 100).foregroundColor(.black)
                    }
                    NavigationLink(destination: DrinkByIngredientSecView("Brandy")){
                        Text("Brandy").background(Capsule().fill(Color.yellow).shadow(radius: 3).frame(width: 150, height: 75)).frame(width: 175, height: 100).foregroundColor(.black)
                    }
                }
            }
        }.navigationBarHidden(true)
    }
}

struct drinknames : Identifiable{
    var id = UUID()
    var drinkId : String
    var img: String
}


struct DrinkByIngredientSecView :View{
    let baseUrl = "https://www.thecocktaildb.com/api/json/v1/1/filter.php?i="
    
    @State var url : String
    @State var drinkId : [drinknames] = []
    
    var body: some View{
        VStack{
            List(drinkId) {i in
                HStack{
                    NavigationLink(destination: SelectedDrink(i.drinkId).environmentObject(SingleDrink())){
                        Text(i.drinkId).lineLimit(2).frame(width: 250, alignment : .leading)
                        Spacer()
                        ShowImage3(linkImage: i.img)
                    }
                }.swipeActions{
                    Button (action: {
                        
                        print("hello")
                    }, label: {
                        Label("Delete", systemImage : "flame")
                    }).tint(.red)
                }
            }.task {
                await self.search(baseUrl + url)
            }
        }.offset(y: -25)
    }
    
    init(_ passedNameUrl: String){
        self.url = passedNameUrl
    }
    
    func search(_ myUrl : String) async{
        do{
            let (data, _) = try!  await URLSession.shared.data(from: URL(string: myUrl)!)
            let decodedResponse = try? JSONDecoder().decode(drinkContainer.self, from: data)
            
            //Reset dell'array
            drinkId = []
            for i in 0...((decodedResponse?.drinks?.count ?? 1)-1) {
                drinkId.append(drinknames(drinkId : decodedResponse?.drinks?[i].strDrink ?? " ", img: String(decodedResponse?.drinks?[i].strDrinkThumb ?? " ")))
            }
        }
    }
}

struct MyButton2: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(12).background(Color(UIColor.systemYellow)).foregroundColor(.black).cornerRadius(8).multilineTextAlignment(.center)
    }
}




let backgroundGradient2 = LinearGradient(
    gradient: Gradient(colors: [Color.green, Color.cyan]), startPoint: .top, endPoint: .bottom)

struct SearchByIngredient_Previews: PreviewProvider {
    static var previews: some View {
        SearchByIngredient()
    }
}
