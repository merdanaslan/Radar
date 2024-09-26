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
            VStack {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                    
                    Text("Dimensions: \(foodDimensions)")
                    Text("Recognized Food: \(recognizedFood)")
                    
                    if !nutritionInfo.isEmpty {
                        Text("Nutrition Info:")
                        Text(nutritionInfo)
                            .padding()
                    }
                    
                    Button("Analyze Food") {
                        analyzeFood()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else {
                    Button("Measure and Capture Food") {
                        showARView = true
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .sheet(isPresented: $showARView) {
                ARMeasurementView(capturedImage: $capturedImage, foodDimensions: $foodDimensions)
            }
            .navigationTitle("Scan Food")
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
                
                Button("Save Profile") {
                    saveProfile()
                }
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
