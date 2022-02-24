//
//  ContentView.swift
//  QuotesApp
//
//  Created by gabi brown on 2022-02-22.
//

import SwiftUI

struct ContentView: View {
    //MARK: Stored Properties
    //Holds the current quote
    
    @State var currentQuote: Quote = Quote(quoteText: "",
                                           quoteAuthor: "",
                                           senderName: "",
                                           senderLink: "",
                                           quoteLink: "")
    
    
    @State var favourites: [Quote] = []
    
    @State var currentQuoteAddedToFavourites: Bool = false
    
    var body: some View {
        VStack {
            
            Text(currentQuote.quoteText)
                .multilineTextAlignment(.leading)
                .padding(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary, lineWidth: 4)
                )
                .padding(10)
            
            Image(systemName: "heart.circle")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(currentQuoteAddedToFavourites == true ? .red : .secondary)
                .onTapGesture {
                    if currentQuoteAddedToFavourites ==
                        false {
                        favourites.append(currentQuote)
                        
                        currentQuoteAddedToFavourites = true
                    }
                }
            
            Button(action: {
                print("Button was pressed")
                
                Task {
                    await loadNewQuote()
                }
            }, label: {
                Text("Another one!")
            })
                .buttonStyle(.bordered)
            
            HStack {
                Text("Favourites")
                    .bold()
                    .font(.title3)
                Spacer()
            }
            
            List {
                Text("quote 1")
                Text("quote 2")
                Text("quote 3")
            }
            
            Spacer()
            
        }
        
        .task {

            await loadNewQuote()
            
            print("Have just attempted to load new quote")
            
        }
        
        .navigationTitle("quotes!")
        .padding()
    }
    
    func loadNewQuote() async {
        let url = URL(string: "http://forismatic.com/en/31b0d37c07/")!
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let urlSession = URLSession.shared
        
        do {
            let (data, _) = try await urlSession.data(for: request)
            
            currentQuote = try JSONDecoder().decode(Quote.self, from: data)
            
        } catch {
            print("Could not retrieve or decode the JSON from endpoint.")
            
            
            print(error)
        }
        currentQuoteAddedToFavourites = false
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
            
        }
    }
}
