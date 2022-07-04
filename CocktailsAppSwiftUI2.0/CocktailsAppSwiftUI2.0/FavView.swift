//
//  FavView.swift
//  
//
//  Created by user on 04/07/22.
//

import SwiftUI

struct FavView: View {
    @State var drinksModel : [MyFavDrink] = []
    @State var selected = false
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Text("Your Drinks").font(Font.custom("", size: 40))
                    Spacer()
                    Button(action: {
                        DB_Manager().deleteAll()
                        drinksModel = DB_Manager().order()
                        
                    }, label: {
                        Label("", systemImage: "trash")
                        
                    })
                    
                }
                
                List(drinksModel) { i in
                    HStack{
                        NavigationLink(destination: SelectedDrink(i.drinkName).environmentObject(SingleDrink())){
                            Text(i.drinkName).lineLimit(2).frame(width: 250, alignment : .leading)
                            Spacer() //spazia tra testo e foto
                            ShowImage3(linkImage: i.imgString )
                        }
                    }.swipeActions{
                        
                        Button(action: {
                            DB_Manager().removeDrink(i.drinkName)
                            drinksModel = DB_Manager().order()
                        }, label: {
                            Label("􁎤", systemImage : "trash")
                        }).tint(.red)
                    }
                }
            }
            
        }.onAppear(perform : {
            self.drinksModel = DB_Manager().order()
        })
        
        
    }
}

struct FavView_Previews: PreviewProvider {
    static var previews: some View {
        FavView()
    }
}
