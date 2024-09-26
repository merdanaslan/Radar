import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FoodScanView()
                .tabItem {
                    Label("Scan Food", systemImage: "camera")
                }
                .tag(0)
            
            DailyLogView()
                .tabItem {
                    Label("Daily Log", systemImage: "list.bullet")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)
        }
        .accentColor(.green) // Change the tab bar accent color
    }
}

struct FoodScanView: View {
    @State private var showARView = false
    @State private var capturedImage: UIImage?
    @State private var foodDimensions: String = ""
    @State private var recognizedFood: String = ""
    @State private var nutritionInfo: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                    
                    Text("Dimensions: \(foodDimensions)")
                        .font(.headline)
                        .padding()
                    
                    Text("Recognized Food: \(recognizedFood)")
                        .font(.title2)
                        .padding()
                    
                    if !nutritionInfo.isEmpty {
                        Text("Nutrition Info:")
                            .font(.headline)
                        Text(nutritionInfo)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    
                    Button(action: analyzeFood) {
                        Text("Analyze Food")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                } else {
                    Button(action: { showARView = true }) {
                        Text("Measure and Capture Food")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .sheet(isPresented: $showARView) {
                ARMeasurementView(capturedImage: $capturedImage, foodDimensions: $foodDimensions)
            }
            .navigationTitle("Foooooood")
        }
    }
    
    func analyzeFood() {
        // Placeholder function for food analysis
        recognizedFood = "Banana"
        nutritionInfo = "Calories: 105\nProtein: 1.3g\nCarbs: 27g\nFat: 0.4g"
    }
}

struct DailyLogView: View {
    @State private var foodEntries: [FoodEntry] = []
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Today")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Text("19:44")
                        .font(.title2)
                }
                .padding()
                
                Text("You can still eat 2,400 calories")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                ProgressView(value: 0, total: 2400)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    .padding(.horizontal)
                
                HStack {
                    MacroView(macroName: "Carbs", macroValue: 0, macroLeft: 330, color: .red)
                    MacroView(macroName: "Protein", macroValue: 0, macroLeft: 120, color: .blue)
                    MacroView(macroName: "Fat", macroValue: 0, macroLeft: 66, color: .orange)
                }
                .padding(.vertical)
                
                if foodEntries.isEmpty {
                    Spacer()
                    Image(systemName: "applelogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                    Text("You have nothing logged for this day")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        ForEach(foodEntries) { entry in
                            VStack(alignment: .leading) {
                                Text(entry.foodName)
                                    .font(.headline)
                                Text("Calories: \(entry.calories)")
                                    .font(.subheadline)
                            }
                        }
                        .onDelete(perform: deleteEntry)
                    }
                }
            }
            .navigationTitle("Daily Log")
            .toolbar {
                EditButton()
            }
        }
    }
    
    func deleteEntry(at offsets: IndexSet) {
        foodEntries.remove(atOffsets: offsets)
    }
}

struct MacroView: View {
    var macroName: String
    var macroValue: Double
    var macroLeft: Int
    var color: Color
    
    var body: some View {
        VStack {
            Text("\(Int(macroValue))%")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(macroName)
                .font(.headline)
                .foregroundColor(color)
            Text("\(macroLeft)g left")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct ProfileView: View {
    @State private var name = ""
    @State private var age = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var goal = "Maintain Weight"
    
    let goals = ["Lose Weight", "Maintain Weight", "Gain Weight"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.numberPad)
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Goal")) {
                    Picker("Goal", selection: $goal) {
                        ForEach(goals, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                Button(action: saveProfile) {
                    Text("Save Profile")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Profile")
        }
    }
    
    func saveProfile() {
        // Placeholder function for saving profile
        print("Profile saved")
    }
}

struct FoodEntry: Identifiable {
    let id = UUID()
    let foodName: String
    let calories: Int
}

struct ARMeasurementView: UIViewRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var foodDimensions: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
