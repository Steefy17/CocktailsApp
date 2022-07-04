//
//  RandomDrink.swift
//  CocktailsAppSwiftUI2.0
//
//  Created by user on 29/06/22.
//

import SwiftUI

struct RandomDrink: View {
    
    @State private var img: String = ""
    @State var myDrink : drinkContainer?
    @State var shouldHide = true
    @State var drinkId : String = "Find your drink "
    
    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()
            
            Text(drinkId).frame(alignment: .top).foregroundColor(.black).font(Font.custom("Montserrat-Bold", size: 30.0)).multilineTextAlignment(.center).offset(x: 0, y : -300)
            
            Button("Generate a random drink"){
                
                self.shouldHide = false
                Task{
                    await self.new()
                }
            }.buttonStyle(MyButton()).offset(x:0, y: 100)
            
            ShowImage(linkImage: img).offset(x: 0, y: -100)
            
            NavigationLink(destination: SelectedDrink(drinkId).environmentObject(SingleDrink())) {
                Text("See details").foregroundColor(.black)
            }.opacity(shouldHide ? 0 : 1).offset(x: 0, y: 250)
        }
    }
    
    func new () async{
        
        let (data, _) = try! await URLSession.shared.data(from: URL(string: "https://www.thecocktaildb.com/api/json/v1/1/random.php")!)
        
        let decodedResponse = try? JSONDecoder().decode(drinkContainer.self, from: data)
        
        drinkId = String(decodedResponse?.drinks?[0].strDrink ?? " ")
        img = String(decodedResponse?.drinks?[0].strDrinkThumb ?? " ")
        myDrink = decodedResponse
    }
}

struct RandomDrink_Previews: PreviewProvider {
    static var previews: some View {
        RandomDrink()
    }
}

let backgroundGradient = LinearGradient(
    gradient: Gradient(colors: [Color.red, Color.yellow]), startPoint: .top, endPoint: .bottom)

struct MyButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(12).background(Color(UIColor.systemRed)).foregroundColor(.black).cornerRadius(8).multilineTextAlignment(.center)
    }
}
