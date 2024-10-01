import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var foodLog = FoodLog()
    @State private var selectedTab = 0
    @State private var showImagePicker = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                
                AnalyticsView()
                    .tabItem {
                        Label("Analytics", systemImage: "chart.bar")
                    }
                    .tag(1)
                
                Text("Battle")
                    .tabItem {
                        Label("Battle", systemImage: "flag")
                    }
                    .tag(2)
                
                Text("Wallet")
                    .tabItem {
                        Label("Wallet", systemImage: "wallet.pass")
                    }
                    .tag(3)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(4)
            }
            .accentColor(.black)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.black)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 80)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $capturedImage, foodLog: foodLog)
        }
        .environmentObject(foodLog)
    }
}

struct HomeView: View {
    @EnvironmentObject var foodLog: FoodLog
    @AppStorage("dailyCalories") private var dailyCalories = 2000
    @AppStorage("dailyProtein") private var dailyProtein = 150
    @AppStorage("dailyCarbs") private var dailyCarbs = 250
    @AppStorage("dailyFat") private var dailyFat = 65
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Today")
                            .font(.headline)
                        Text("Yesterday")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                    
                    HStack {
                        NutrientRingView(value: foodLog.caloriesConsumed, total: dailyCalories, title: "Calories", color: .orange)
                        NutrientRingView(value: foodLog.proteinConsumed, total: dailyProtein, title: "Protein", color: .red)
                        NutrientRingView(value: foodLog.carbsConsumed, total: dailyCarbs, title: "Carbs", color: .yellow)
                        NutrientRingView(value: foodLog.fatConsumed, total: dailyFat, title: "Fat", color: .blue)
                    }
                    .frame(height: 150)
                    
                    Text("Recently eaten")
                        .font(.headline)
                    
                    ForEach(foodLog.entries.prefix(5)) { entry in
                        RecentlyEatenItemView(entry: entry)
                    }
                }
                .padding()
            }
            .navigationTitle("FitLens")
        }
    }
}

struct NutrientRingView: View {
    var value: Int
    var total: Int
    var title: String
    var color: Color
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: min(CGFloat(value) / CGFloat(total), 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack {
                    Text("\(max(total - value, 0))")
                        .font(.system(size: 14, weight: .bold))
                    Text(title)
                        .font(.system(size: 10))
                }
            }
        }
    }
}

struct NutrientInfoView: View {
    var value: Int
    var total: Int
    var title: String
    var color: Color
    
    var body: some View {
        HStack {
            Text("\(value)g")
                .font(.headline)
            Text(title)
                .font(.subheadline)
            Spacer()
            Circle()
                .fill(color)
                .frame(width: 30, height: 30)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct RecentlyEatenItemView: View {
    var entry: FoodEntry
    
    var body: some View {
        HStack {
            if let image = entry.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading) {
                Text(entry.foodName)
                    .font(.headline)
                HStack {
                    Image(systemName: "flame.fill")
                    Text("\(entry.calories) calories")
                    Text("• \(entry.protein)g")
                        .foregroundColor(.red)
                    Text("• \(entry.carbs)g")
                        .foregroundColor(.yellow)
                    Text("• \(entry.fat)g")
                        .foregroundColor(.blue)
                }
                .font(.caption)
            }
            
            Spacer()
            
            Text(entry.timestamp, style: .time)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct AnalyticsView: View {
    @EnvironmentObject var foodLog: FoodLog
    
    var body: some View {
        NavigationView {
            List {
                ForEach(foodLog.entries) { entry in
                    HStack {
                        if let image = entry.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                        VStack(alignment: .leading) {
                            Text(entry.foodName)
                                .font(.headline)
                            Text("Calories: \(entry.calories), Protein: \(entry.protein)g, Carbs: \(entry.carbs)g, Fat: \(entry.fat)g")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Food Log")
        }
    }
}

struct SettingsView: View {
    @AppStorage("dailyCalories") private var dailyCalories = 2000
    @AppStorage("dailyProtein") private var dailyProtein = 150
    @AppStorage("dailyCarbs") private var dailyCarbs = 250
    @AppStorage("dailyFat") private var dailyFat = 65
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Goals")) {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("Calories", value: $dailyCalories, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("Protein", value: $dailyProtein, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Carbs (g)")
                        Spacer()
                        TextField("Carbs", value: $dailyCarbs, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Fat (g)")
                        Spacer()
                        TextField("Fat", value: $dailyFat, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    var foodLog: FoodLog

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                OpenAIService.shared.analyzeImage(image) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let foodAnalysis):
                            let entry = FoodEntry(foodName: foodAnalysis.foodName,
                                                  calories: foodAnalysis.calories,
                                                  protein: foodAnalysis.protein,
                                                  carbs: foodAnalysis.carbs,
                                                  fat: foodAnalysis.fat,
                                                  image: image,
                                                  timestamp: Date())
                            self.parent.foodLog.addEntry(entry)
                        case .failure(let error):
                            print("Failed to analyze image: \(error.localizedDescription)")
                        }
                        self.parent.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

class FoodLog: ObservableObject {
    @Published var entries: [FoodEntry] = []
    
    var caloriesConsumed: Int {
        entries.reduce(0) { $0 + $1.calories }
    }
    
    var proteinConsumed: Int {
        entries.reduce(0) { $0 + $1.protein }
    }
    
    var carbsConsumed: Int {
        entries.reduce(0) { $0 + $1.carbs }
    }
    
    var fatConsumed: Int {
        entries.reduce(0) { $0 + $1.fat }
    }
    
    func addEntry(_ entry: FoodEntry) {
        entries.append(entry)
    }
}

struct FoodEntry: Identifiable {
    let id = UUID()
    let foodName: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let image: UIImage?
    let timestamp: Date
}

struct DailyLogView: View {
    @EnvironmentObject var foodLog: FoodLog
    
    var body: some View {
        NavigationView {
            List {
                ForEach(foodLog.entries) { entry in
                    HStack {
                        if let image = entry.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                        VStack(alignment: .leading) {
                            Text(entry.foodName)
                                .font(.headline)
                            Text("Calories: \(entry.calories)")
                                .font(.subheadline)
                        }
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
        foodLog.entries.remove(atOffsets: offsets)
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

class OpenAIService {
    static let shared = OpenAIService()
    private let apiKey: String
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    private init() {
        print("Initializing OpenAIService")
        
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
              let apiKey = dict["OPENAI_API_KEY"] as? String else {
            print("Failed to load API key from Config.plist")
            fatalError("API Key not found in Config.plist")
        }
        
        self.apiKey = apiKey
        print("API Key loaded successfully")
    }
    
    func analyzeImage(_ image: UIImage, completion: @escaping (Result<FoodAnalysis, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Failed to convert image to data")
            completion(.failure(NSError(domain: "Image Conversion", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Analyze this image and provide the name of the food and its nutritional information in the following JSON format: {\"foodName\": \"Name of the food\", \"calories\": 0, \"protein\": 0, \"carbs\": 0, \"fat\": 0}. If the image doesn't contain food or nutritional information, return {\"foodName\": \"No food detected\", \"calories\": 0, \"protein\": 0, \"carbs\": 0, \"fat\": 0}."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 300
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Error creating request body: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        print("Sending request to OpenAI API...")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received from the server")
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from the server"])))
                return
            }
            
            print("Received data from API. Attempting to parse...")
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Received JSON: \(json)")
                    
                    if let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        // Remove code block markers and extract JSON
                        let jsonString = content.replacingOccurrences(of: "```json", with: "")
                            .replacingOccurrences(of: "```", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if let data = jsonString.data(using: .utf8),
                           let foodAnalysis = try? JSONDecoder().decode(FoodAnalysis.self, from: data) {
                            print("Successfully parsed response. Food name: \(foodAnalysis.foodName)")
                            completion(.success(foodAnalysis))
                        } else {
                            print("Failed to parse the expected structure from the JSON")
                            completion(.failure(NSError(domain: "Parsing Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse the response"])))
                        }
                    } else {
                        print("Failed to extract content from the JSON response")
                        completion(.failure(NSError(domain: "Parsing Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to extract content from the response"])))
                    }
                } else {
                    print("Failed to parse JSON from the response data")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Raw response: \(responseString)")
                    }
                    completion(.failure(NSError(domain: "Parsing Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse the response"])))
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
}

struct FoodAnalysis: Codable {
    let foodName: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
}
