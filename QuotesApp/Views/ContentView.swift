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
    
    @State var currentQuote: Quote = Quote(quoteText: "lala",
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
            
            List(favourites, id : \.self) {
                currentFavourite in
                Text(currentFavourite.quoteText)
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
        let url = URL(string: "https://api.forismatic.com/api/1.0/?method=getQuote&key=457653&format=json&lang=en")!
        
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
    
    // Saves (persists) the data to local storage on the device
    func persistQuotes() {
        
        // Get a URL that points to the saved JSON data containing our list of tasks
        let filename = getDocumentsDirectory().appendingPathComponent(savedQuotesLabel)
        
        // Try to encode the data in our people array to JSON
        do {
            // Create an encoder
            let encoder = JSONEncoder()
            
            // Ensure the JSON written to the file is human-readable
            encoder.outputFormatting = .prettyPrinted
            
            // Encode the list of favourites we've collected
            let data = try encoder.encode(favourites)
            
            // Actually write the JSON file to the documents directory
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            
            // See the data that was written
            print("Saved data to documents directory successfully.")
            print("===")
            print(String(data: data, encoding: .utf8)!)
            
        } catch {
            
            print(error.localizedDescription)
            print("Unable to write list of favourites to documents directory in app bundle on device.")
            
        }

    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
            
        }
    }
}
