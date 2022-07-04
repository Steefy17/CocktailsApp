//
//  Shared.swift
//  CocktailsAppSwiftUI2.0
//
//  Created by user on 29/06/22.
//
import SwiftUI
import Foundation

//classe che permette di fare il fetch dei dati del drink cercato
class SingleDrink : ObservableObject {
    
    @State var favDrinks : [MyFavDrink] = []
    @Published var drinks: drinkContainer?
    
    func searchDrink (_ passedDrinkName : String){
        
        guard let url = URL (string: "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=" + passedDrinkName.replacingOccurrences(of: " ", with: "_")) else {fatalError("Missing URL")}
        
        let urlRequest = URLRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: urlRequest){(data, response, error)in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {return}
            if response.statusCode == 200{
                guard let data = data else{return}
                DispatchQueue.main.async {
                    
                    do{
                        let decodedDrink = try JSONDecoder().decode(drinkContainer.self, from: data)
                        
                        self.drinks = decodedDrink
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }
            
        }
        dataTask.resume()
        
    }
    
}

struct SelectedDrink : View{
    //View che restituisce le informazioni di un drink dato il suo nome
    @State var drinkId : drinkContainer?
    @EnvironmentObject var network : SingleDrink
    @State var drinkToAdd = MyFavDrink()
    var drinkName : String
    @State var selected = false
    
    var body: some View{
        ZStack{
            ScrollView{
                
                //stampa delle informazioni
                let _ = network.searchDrink(drinkName)
                let myDrink = network.drinks?.drinks?[0]
                
                if(selected){
                    ShowRate(drinkName: drinkName)
                }
                ShowInfo(myDrink: myDrink ?? nil )
                ShowIngredients(myDrink: myDrink)
                ShowInstructions (myDrink: myDrink ?? nil)
                ShowImage(linkImage: myDrink?.strDrinkThumb ?? " ")
                
            }
        }.navigationTitle(drinkName)
            .toolbar{
                
                Button(action: {
                    
                    if selected{
                        DB_Manager().removeDrink(drinkName)
                        selected = false
                        
                    } else{
                        DB_Manager().addDrink(drinkName, (network.drinks?.drinks?[0].strDrinkThumb)!)
                        selected = true
                    }
                    
                }, label: {
                    if !selected {
                        Label("􁎤", systemImage : "checkmark.circle")
                    } else {
                        Label("􁎤", systemImage : "checkmark.circle.fill")
                    }
                    
                }).tint(.red)
            }.onAppear(perform: {
                selected = DB_Manager().getDrink(drinkName)
            })
            .lineLimit(100).frame(alignment: .leading)
        
    }
    //Inizializzazione parametri da passare tra views
    init(_ passedDrinkName : String){
        self.drinkName = passedDrinkName
    }
}

struct ShowRate : View{
    @State var selected = [false, false, false, false, false]
    @State var supp : Int = 5
    var drinkName : String
    var body: some View{
        
        Text("Have you tried? Save how much did you liked it")
        Text("")
        HStack{
            Button(action: {
                supp = 0
                setTF(supp)
                DB_Manager().rate(supp, drinkName)
            }, label: {
                if !selected[0] {
                    Label("", systemImage: "star")
                } else {
                    Label("", systemImage: "star.fill")
                }
                
            }).tint(.yellow)
            
            Button(action: {
                supp = 1
                setTF(supp)
                DB_Manager().rate(supp, drinkName)
            }, label: {
                if !selected[1] {
                    Label("", systemImage: "star")
                } else {
                    Label("", systemImage: "star.fill")
                }
                
            }).tint(.yellow)
            Button(action: {
                supp = 2
                setTF(supp)
                DB_Manager().rate(supp, drinkName)
            }, label: {
                if !selected[2] {
                    Label("", systemImage: "star")
                } else {
                    Label("", systemImage: "star.fill")
                }
                
            }).tint(.yellow)
            Button(action: {
                supp = 3
                setTF(supp)
                DB_Manager().rate(supp, drinkName)
            }, label: {
                if !selected[3] {
                    Label("", systemImage: "star")
                } else {
                    Label("", systemImage: "star.fill")
                }
                
            }).tint(.yellow)
            Button(action: {
                supp = 4
                setTF(supp)
                DB_Manager().rate(supp, drinkName)
            }, label: {
                if !selected[4] {
                    Label("", systemImage: "star")
                } else {
                    Label("", systemImage: "star.fill")
                }
                
            }).tint(.yellow)
            
        }.onAppear(perform: {
            supp = DB_Manager().getRate(drinkName)
            setTF(supp)
            
        })
        Text("")
    }
    private func setTF (_ c : Int){
        for i in 0...(self.selected.count-1) {
            if c != 5{
                if i <= c {
                    self.selected[i] = true
                } else{
                    self.selected[i] = false
                }
            }
            
        }
    }
    
}

//Struct che permette di visualizzare le informazioni principali
struct ShowInfo : View{
    var myDrink : Drinks?
    var body: some View{
        if myDrink != nil{
            Text("Drink Category: " + (myDrink?.strCategory ?? " ")).frame(maxWidth: 500, alignment: .leading).padding(.bottom, 1)
            Text("Drink Type: " + (myDrink?.strAlcoholic ?? " ")).frame(maxWidth: 500, alignment: .leading).padding(.bottom, 1)
            Text("Glass Type: " + (myDrink?.strGlass ?? " ")).frame(maxWidth: 500, alignment: .leading).padding(.bottom, 1)
        }else{
            Text("We haven't find the drink you are looking for, please check if you typed well").frame(maxWidth: 500).multilineTextAlignment(.center).font(.system(size: 25).bold())
            Text("Attention! Pay attention if yuo put a space at the end of the text!)").frame(maxWidth: 500).multilineTextAlignment(.center)
        }
    }
}
//Struct che permette di mostrare le istruzioni per preparare il drink
struct ShowInstructions : View{
    var myDrink : Drinks?
    
    var body: some View{
        if  myDrink != nil {
            Text("Instructions :").frame(maxWidth: 380, alignment: .leading).padding(.bottom,2)
            Text(myDrink?.strInstructions ?? " ").padding(.bottom,6)
            //Se c'è in italiano printalo
            if myDrink?.strInstructionsIT != nil{
                Text("Istruzioni :").frame(maxWidth: 380, alignment: .leading).padding(.bottom,2)
                Text(myDrink?.strInstructionsIT ?? " ").padding(.bottom,6)
            }
        }
    }
}
//struct che permette di mostrare l'immagine del drink
struct ShowImage : View{
    var linkImage : String
    var body: some View{
        if linkImage != " "{
            AsyncImage(url: URL(string: linkImage)){ phase in
                
                switch phase {
                    
                case .success(let image):
                    image.resizable()
                        .cornerRadius(20)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                        .shadow(color: .gray, radius: 10)
                    
                case .failure:
                    Image(systemName: "photo")
                    
                default:
                    ProgressView()
                }
            }
        }
    }
}
//Struct che permette di mostrare tutti i drink
struct ShowIngredients : View{
    var myDrink : Drinks?
    var body: some View{
        if myDrink != nil{
            Text("Ingredients: ").frame(maxWidth: 380, alignment: .leading).padding(4)
            if myDrink?.strIngredient1 != nil && myDrink?.strIngredient1 != "" {
                Text("- \(myDrink?.strIngredient1 ?? " "), \(myDrink?.strMeasure1 ?? " ")").frame(maxWidth: 380, alignment: .leading).padding(2)
            }
            if myDrink?.strIngredient2 != nil  && myDrink?.strIngredient2 != ""{
                Text("- \(myDrink?.strIngredient2 ?? " ") \(myDrink?.strMeasure2 ?? " ")").frame(maxWidth: 380, alignment: .leading).padding(2)
            }
            if myDrink?.strIngredient3 != nil  && myDrink?.strIngredient3 != ""{
                Text("- \(myDrink?.strIngredient3 ?? " ") \(myDrink?.strMeasure3 ?? " ")").frame(maxWidth: 380, alignment: .leading).padding(2)
            }
            if myDrink?.strIngredient4 != nil  && myDrink?.strIngredient4 != "" {
                Text("- \(myDrink?.strIngredient4 ?? " ") \(myDrink?.strMeasure4 ?? " ")").frame(maxWidth: 380, alignment: .leading).padding(2)
            }
            if myDrink?.strIngredient5 != nil  && myDrink?.strIngredient5 != ""{
                Text("- \(myDrink?.strIngredient5 ?? " ") \(myDrink?.strMeasure5 ?? " ")").frame(maxWidth: 380, alignment: .leading).padding(2)
            }
            if myDrink?.strIngredient6 != nil  && myDrink?.strIngredient6 != ""{
                Text("- \(myDrink?.strIngredient6 ?? " ") \(myDrink?.strMeasure6 ?? " ")").frame(maxWidth: 380, alignment: .leading).padding(2)
            }
            if myDrink?.strIngredient7 != nil  && myDrink?.strIngredient7 != "" {
                Text("- \(myDrink?.strIngredient7 ?? " ") \(myDrink?.strMeasure7 ?? " ")").frame(maxWidth: 380, alignment: .leading).padding(2)
            }
            if myDrink?.strIngredient8 != nil  && myDrink?.strIngredient8 != ""{
                Text("- \(myDrink?.strIngredient8 ?? " ") \(myDrink?.strMeasure8 ?? " ")").frame(maxWidth: 380, alignment: .leading).padding(2)
            }
            if myDrink?.strIngredient9 != nil  && myDrink?.strIngredient9 != ""{
                Text("- \(myDrink?.strIngredient9 ?? " ") \(myDrink?.strMeasure9 ?? " ")").frame(maxWidth: 380, alignment: .leading).padding(2)
            }
        }
    }
}

class MyFavDrink : Identifiable{
    public var id : Int64 = 0
    public var drinkName : String = ""
    public var imgString : String = ""
}


struct drinkContainer : Codable {
    var drinks : [Drinks]?
}

struct Drinks : Codable, Hashable{
    //var id : String
    var idDrink : String?
    var strDrink : String?
    var strTags : String?
    var strCategory : String?
    var strAlcoholic : String?
    var strGlass : String?
    var strInstructions : String?
    var strInstructionsIT : String?
    var strDrinkThumb : String?
    var strIngredient1 : String?
    var strIngredient2 : String?
    var strIngredient3 : String?
    var strIngredient4 : String?
    var strIngredient5 : String?
    var strIngredient6 : String?
    var strIngredient7 : String?
    var strIngredient8 : String?
    var strIngredient9 : String?
    var strIngredient10 : String?
    var strMeasure1 : String?
    var strMeasure2 : String?
    var strMeasure3 : String?
    var strMeasure4 : String?
    var strMeasure5 : String?
    var strMeasure6 : String?
    var strMeasure7 : String?
    var strMeasure8 : String?
    var strMeasure9 : String?
    var strMeasure10 : String?

}
