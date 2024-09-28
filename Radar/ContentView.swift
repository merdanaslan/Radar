import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var foodLog = FoodLog()
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
        .accentColor(.green)
        .environmentObject(foodLog)
    }
}

struct FoodScanView: View {
    @State private var showImagePicker = false
    @State private var capturedImage: UIImage?
    @State private var recognizedFood: String = ""
    @State private var nutritionInfo: String = ""
    @State private var isAnalyzing = false
    @EnvironmentObject var foodLog: FoodLog
    
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
                    
                    if isAnalyzing {
                        ProgressView("Analyzing...")
                    } else {
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
                    }
                    
                    if !recognizedFood.isEmpty {
                        Text("Recognized Food: \(recognizedFood)")
                            .font(.title2)
                            .padding()
                        
                        Text("Nutrition Info:")
                            .font(.headline)
                        Text(nutritionInfo)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        
                        Button(action: logFood) {
                            Text("Log Food")
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
                } else {
                    Button(action: { showImagePicker = true }) {
                        Text("Take Photo")
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $capturedImage)
            }
            .navigationTitle("Scan Food")
        }
    }
    
    func analyzeFood() {
        isAnalyzing = true
        guard let image = capturedImage else { return }
        
        OpenAIService.shared.analyzeImage(image) { result in
            DispatchQueue.main.async {
                isAnalyzing = false
                switch result {
                case .success(let analysis):
                    recognizedFood = analysis.foodName
                    nutritionInfo = analysis.nutritionInfo
                case .failure(let error):
                    print("Error analyzing food: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func logFood() {
        let newEntry = FoodEntry(foodName: recognizedFood, calories: 0) // You might want to parse calories from nutritionInfo
        foodLog.addEntry(newEntry)
        capturedImage = nil
        recognizedFood = ""
        nutritionInfo = ""
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode

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
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

class FoodLog: ObservableObject {
    @Published var entries: [FoodEntry] = []
    
    func addEntry(_ entry: FoodEntry) {
        entries.append(entry)
    }
}

struct FoodEntry: Identifiable {
    let id = UUID()
    let foodName: String
    let calories: Int
}

struct DailyLogView: View {
    @EnvironmentObject var foodLog: FoodLog
    
    var body: some View {
        NavigationView {
            List {
                ForEach(foodLog.entries) { entry in
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
    
    func analyzeImage(_ image: UIImage, completion: @escaping (Result<(foodName: String, nutritionInfo: String), Error>) -> Void) {
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
                            "text": "Analyze this image and provide the name of the food and its nutritional information."
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
                        let lines = content.components(separatedBy: .newlines)
                        let foodName = lines.first ?? "Unknown Food"
                        let nutritionInfo = lines.dropFirst().joined(separator: "\n")
                        print("Successfully parsed response. Food name: \(foodName)")
                        completion(.success((foodName: foodName, nutritionInfo: nutritionInfo)))
                    } else {
                        print("Failed to parse the expected structure from the JSON")
                        completion(.failure(NSError(domain: "Parsing Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse the response"])))
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
