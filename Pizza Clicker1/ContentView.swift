import SwiftUI

struct Generator {
    var cost: Int
    let pizzaPerSecond: Int
    var count: Int
    var timer: Timer?
}

struct ContentView: View {
    @State private var pizzaCount = 0
    @State private var generators = [
        Generator(cost: 10, pizzaPerSecond: 1, count: 0, timer: nil),
        Generator(cost: 100, pizzaPerSecond: 5, count: 0, timer: nil),
        Generator(cost: 1000, pizzaPerSecond: 11, count: 0, timer: nil),
        Generator(cost: 10000, pizzaPerSecond: 12, count: 0, timer: nil),
        Generator(cost: 100000, pizzaPerSecond: 125, count: 0, timer: nil)
    ]
    @State private var selectedQuantity = 1 // Default quantity
    @State private var shouldShake = false
    
    let pizzaPerClick = 5
    let quantities = [1, 5, 10, 50, 100]
    let generatorImages = ["granny", "chef", "farm", "fab", "lab"]
    let generatorText = ["Hire a Granny", "Hire a Italian Chef", "Buy a Pizza Farm", "Buy a Pizza Factory", "Buy a Pizza Lab"]
    let howmanyText = ["Granny's","Cook's", "Farm's", "Factory's", "Pizza Laboratory"]

    let screenWidth = UIScreen.main.bounds.size.width

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("")
                        .padding(-50)
                        .navigationTitle("Pizza Clicker")
                    Text("Pizza's: \(formattedCount(count: pizzaCount))")
                        .font(.title)
                        .padding()
                    
                    Button(action: {
                        self.pizzaCount += pizzaPerClick
                        withAnimation {
                            self.shouldShake = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            withAnimation {
                                self.shouldShake = false
                            }
                        }
                    }) {
                        Image("pizza")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .offset(x: shouldShake ? CGFloat.random(in: -7...7) : 0)
                            .offset(y: shouldShake ? CGFloat.random(in: -7...5) : 0)
                    }
                    
                    HStack{
                        Picker(selection: $selectedQuantity, label: Text("Quantity")) {
                            ForEach(quantities, id: \.self) { number in
                                Text("\(number)").tag(number)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(height: 150)
                        .padding(.top, -50)
                        .padding(.bottom, -30)
                        .padding(.horizontal, 30) // Applies padding only to the left and right sides
                    }
                    
                    // Display buy buttons for each type of generator
                    ForEach(generators.indices, id: \.self) { index in
                        Button(action: {
                            self.buyGenerators(for: index)
                        }) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(self.pizzaCount >= self.totalCost(for: self.selectedQuantity, index: index) ? Color.green : Color.gray) // Verifica se o usuário tem pizzas suficientes para comprar o gerador
                                .frame(width: 360, height: 70)
                                .overlay(
                                    HStack {
                                        Image(self.generators[index].count >= 1 ? generatorImages[index] : "none")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                        Text(self.pizzaCount >= self.totalCost(for: self.selectedQuantity, index: index) ? "\(generatorText[index]) \(self.generators[index].cost)" : "??? \(self.generators[index].cost)")
                                            .opacity(self.pizzaCount >= self.totalCost(for: self.selectedQuantity, index: index) ? 1 : 0.5) // Ajusta a opacidade do texto com base na capacidade de compra
                                    }
                                    .font(.title)
                                    .foregroundColor(.white)
                                )
                        }
                        .disabled(self.pizzaCount < self.totalCost(for: self.selectedQuantity, index: index)) // Desativa o botão se o usuário não tiver pizzas suficientes
                    
                        Text("\(self.generators[index].count > 0 ? "\(howmanyText[index])" : "") \(self.generators[index].count > 0 ? "\(self.generators[index].count)" : "??")")
                            .font(.title)
                            .padding(3)
                    }
                    
                    Button(action: {}) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray)
                            .frame(width: 360, height: 70)
                            .opacity(0.7)
                            .overlay(
                                HStack {
                                    Image("monster")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .opacity(0.7)
                                    Text("??? coming in")
                                        .foregroundColor(.white)
                                        .font(.title)
                                        .opacity(0.7)
                                }
                            )
                    }
                }
                Text("???")
                    .font(.title)
                Spacer()
                NavigationLink(destination: SecondPageView()) {
                    Text("Next page")
                }
            }
            .onAppear {
                self.startTimers()
            }
        }
    }
    
    private func buyGenerators(for index: Int) {
        let totalCost = self.totalCost(for: selectedQuantity, index: index)
        if self.pizzaCount >= totalCost {
            self.pizzaCount -= totalCost
            self.generators[index].count += selectedQuantity
            
            // Increase the cost by 5%
            let currentCost = Double(self.generators[index].cost)
            let increasedCost = currentCost * 1.2
            self.generators[index].cost = Int(increasedCost)
        }
    }
    
    private func totalCost(for quantity: Int, index: Int) -> Int {
        return generators[index].cost * quantity
    }
    
    private func startTimers() {
        for index in generators.indices {
            generators[index].timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.pizzaCount += self.generators[index].count * self.generators[index].pizzaPerSecond
            }
        }
    }
}

private func formattedCount(count: Int) -> String {
    if count < 1000 {
        return "\(count)"
    } else if count < 1_000_000 {
        return String(format: "%.1fk", Double(count) / 1_000)
    } else if count < 1_000_000_000 {
        return String(format: "%.1fM", Double(count) / 1_000_000)
    } else if count < 1_000_000_000_000 {
        return String(format: "%.1fB", Double(count) / 1_000_000_000)
    } else {
        return String(format: "%.1fT", Double(count) / 1_000_000_000_000)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
