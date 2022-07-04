//
//  DB_Manager.swift
//  CocktailsAppSwiftUI2.0
//
//  Created by user on 04/07/22.
//

import Foundation
import SQLite

class DB_Manager {
    //Instanzia database
    private var db: Connection!
    
    var allDrinks: [String] = []
    //istanza tabella del database
    private var drinks: Table!
    
    //Istanza colonne tabella
    private var id : Expression<Int64>!
    private var drinkName : Expression<String>!
    private var imgString : Expression <String>!
    private var rate : Expression<Int>!
    
    //costruttore classe
    init() {
        do {
            //cerca il path della cartella del database
            let path : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
            
            //crea connessione con il database
            db = try Connection("\(path)/my_fav_drinks.sqlite3")
            
            //crea oggetto tabella
            drinks = Table("Drinks")
            
            //creazione istanza di ogni colonna
            id = Expression<Int64> ("id")
            drinkName = Expression<String> ("Drink Name")
            imgString = Expression<String> ("Img link")
            rate = Expression<Int> ("Rate")
            
            //Controlla se la tabella di questa nota è già stata creata
            if (!UserDefaults.standard.bool(forKey: "is_db_created")) {
                
                //se non è stata creata
                try db.run(drinks.create{(t) in
                    t.column(id, primaryKey: true)
                    t.column(drinkName)
                    t.column(imgString)
                    t.column(rate)
                })
                
                // setta il valore a true così non provera a crearla di nuovo
                UserDefaults.standard.set(true, forKey: "is_db_created")
            }
            
        } catch {
            //mostra il messaggio d'errore
            print(error.localizedDescription)
        }
    }
    
    //Aggiunge un drink
    public func addDrink (_ drinkNameValue : String, _ imgStringValue : String) {
        var supp = 0
        
        for i in self.getDrinks(){
            if i.drinkName == drinkNameValue {
                supp = 1
                break
            }
        }
        if supp != 1{
            print("Aggiunto")
            do{
                try db.run(drinks.insert(drinkName <- drinkNameValue, imgString <- imgStringValue, rate <- 5))
            } catch {
                print("2")
                print(error.localizedDescription)
            }
        } else {
            print("Non aggiunto")
        }
    }
    
    //Rimuove un drink
    public func removeDrink (_ drinkNameValue : String) {
        do{
            let temp: Table = drinks.filter(drinkName == drinkNameValue)
            
            try db.run(temp.delete())
            print("rimosso")
        } catch{
            print("3")
            print(error.localizedDescription)
        }
    }
    
    //Ritorna TUTTI i drink
    public func getDrinks () -> [MyFavDrink] {
        var drinksModel : [MyFavDrink] = []
        drinks = drinks.order(id.desc)
        
        do {
            for temp in try db.prepare(drinks) {
                let drinkModel : MyFavDrink = MyFavDrink()
                
                drinkModel.id = temp[id]
                drinkModel.drinkName = temp[drinkName]
                drinkModel.imgString = temp[imgString]
                
                
                drinksModel.append(drinkModel)
            }
        } catch {
            print("4")
            print(error.localizedDescription)
        }
        //ritorno il mio array
        return drinksModel
    }
    
    //Controlla se il drink è presente
    public func getDrink(_ drinkNameValue : String) -> Bool{
        do{
            for i in try db.prepare(drinks){
                if i[drinkName] == drinkNameValue{
                    return true
                }
            }} catch {
                print(error.localizedDescription)
            }
        
        return false
    }
    
    public func getRate(_ drinkNameValue : String) -> Int{
        do{
            for i in try db.prepare(drinks){
                if i[drinkName] == drinkNameValue{
                    return i[rate]
                }
            }} catch {
                print(error.localizedDescription)
            }
        return 5
    }
    
    //cancella tutti i preferiti
    public func deleteAll () {
        do{
            for i in try db.prepare(drinks){
                self.removeDrink(i[drinkName])
            }} catch {
                print("6")
                print(error.localizedDescription)
            }
    }
    
    public func order() -> [MyFavDrink]{
        var supp : [MyFavDrink] = []
        supp = DB_Manager().getDrinks()
        supp = supp.sorted(by: {$0.drinkName < $1.drinkName})
        return supp
    }
    
    public func rate(_ rated : Int, _ drinkNameValue : String){
        do{
            let temp : Table = drinks.filter(drinkNameValue == drinkName)
            
            try db.run(temp.update(rate <- rated ))
        }catch {
            print(error.localizedDescription)
        }
    }
}
