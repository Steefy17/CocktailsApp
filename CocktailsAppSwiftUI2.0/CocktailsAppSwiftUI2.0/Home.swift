//
//  Home.swift
//  CocktailsAppSwiftUI2.0
//
//  Created by user on 29/06/22.
//

import SwiftUI

struct Home: View {
    @State var searchingDrink = ""
    //@State var myDrink : [Drinks] = []
    @EnvironmentObject var network2 : AllDrinks
    @State var selected = false
    var body: some View {
        
        ZStack{
            //set background color
            backgroundGradient3.ignoresSafeArea()
            VStack{
                HStack{
                    TextField("Search here", text: $searchingDrink).font(.system(size: 40)).frame(maxWidth : 300, alignment: .center).multilineTextAlignment(.center)
                    if (searchingDrink != "") {
                        NavigationLink(destination: SelectedDrink(searchingDrink).environmentObject(SingleDrink())){
                            Text(">").font(.system(size: 40))
                        }
                    }
                }
                
                let myDrink = network2.myDrinks
                //Lista per stampare tutti i nomi e le immagini dei drink
                List(myDrink, id:\.self) { i in
                    HStack{
                        //stampa di tutti i drink come navigation link
                        NavigationLink(destination: SelectedDrink(i.strDrink!).environmentObject(SingleDrink())){
                            Text((i.strDrink)!).lineLimit(2).frame(width: 250, alignment : .leading)
                            Spacer() //spazia tra testo e foto
                            ShowImage3(linkImage: i.strDrinkThumb ?? " ")
                        }
                    }.swipeActions{
                        
                        Button(action: {
                            let dbManager : DB_Manager = DB_Manager()
                            dbManager.addDrink(i.strDrink!, i.strDrinkThumb!)
                        }, label: {
                            Label("􁎤", systemImage : "checkmark.circle")
                        }).tint(.red)
                    }
                }
            }
        }
    }
    
}

class AllDrinks : ObservableObject {
    
    @Published var myDrinks: [Drinks] = []
    func saveAllDrinks(){
        
        
        let chars = ["0", "1","2","3","4", "5","6","7","8","9", "a", "b", "c", "d", "e", "f","g","h","i","j","k","l","m","n","o","p", "q","r","s","t","u","v","w","x","y","z"]
        for i in chars{
            guard let url = URL (string: "https://www.thecocktaildb.com/api/json/v1/1/search.php?f=" + i) else {fatalError("Missing URL")}
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
                            for j in 0...((decodedDrink.drinks?.count ?? 1)-1){
                                
                                if decodedDrink.drinks?[j].strDrink != nil{
                                    self.myDrinks.append((decodedDrink.drinks?[j])!)
                                }
                            }
                            self.myDrinks = (self.myDrinks.sorted{($0.strDrink)! < ($1.strDrink)!})
                        } catch let error {
                            print("Error decoding: ", error)
                        }
                    }
                }
            }
            dataTask.resume()
        }
    }
}

struct ShowImage3 : View{
    var linkImage : String
    var body: some View{
        
        AsyncImage(url: URL(string: linkImage)){ phase in
            
            switch phase {
                
            case .success(let image):
                image.resizable()
                    .cornerRadius(20)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .shadow(color: .gray, radius: 10)
                
            case .failure:
                ShowImage3(linkImage: linkImage)
                
            default:
                ProgressView()
            }
        }
    }
}
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .environmentObject(SingleDrink())
    }
}

let backgroundGradient3 = LinearGradient(
    gradient: Gradient(colors: [Color.purple, Color.orange]), startPoint: .top, endPoint: .bottom)
