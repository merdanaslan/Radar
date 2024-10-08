import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var foodLog = FoodLog()
    @State private var selectedTab = 0
    @State private var showImagePicker = false
    @State private var capturedImage: UIImage?
    @State private var isLoading = false
    @State private var showMenu = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
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
                
                CompeteView()
                    .tabItem {
                        Label("Compete", systemImage: "trophy.fill")
                    }
                    .tag(2)
                
                WalletView()
                    .tabItem {
                        Label("Wallet", systemImage: "wallet.pass")
                    }
                    .tag(3)
                
                SettingsView()
                    .tabItem {
                        Label("More", systemImage: "ellipsis")
                    }
                    .tag(4)
            }
            .accentColor(.black)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        // Pop-up menu
                        if showMenu {
                            VStack(spacing: 15) {
                                MenuButton(icon: "camera", action: {
                                    showImagePicker = true
                                    showMenu = false
                                })
                                MenuButton(icon: "cube", text: "3D", action: {
                                    // 3D functionality to be implemented
                                    showMenu = false
                                })
                                MenuButton(icon: "text.bubble", action: {
                                    // Text functionality to be implemented
                                    showMenu = false
                                })
                            }
                            .transition(.scale)
                            .offset(y: -140) // Adjust this value as needed
                        }
                        
                        // Main plus button
                        Button(action: {
                            withAnimation {
                                showMenu.toggle()
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.black)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 80)
                }
            }
            
            if isLoading {
                ModernLoadingView()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $capturedImage, isLoading: $isLoading, foodLog: foodLog)
        }
        .environmentObject(foodLog)
        .preferredColorScheme(.light) // Force light mode
    }
}

struct HomeView: View {
    @EnvironmentObject var foodLog: FoodLog
    @AppStorage("dailyCalories") private var dailyCalories = 2400
    @AppStorage("dailyCarbs") private var dailyCarbs = 330
    @AppStorage("dailyProtein") private var dailyProtein = 120
    @AppStorage("dailyFat") private var dailyFat = 66
    
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
                    
                    VStack {
                        HStack(spacing: 10) {
                            NutrientRingView(value: foodLog.caloriesConsumed, total: dailyCalories, title: "Calories", color: .orange)
                            NutrientRingView(value: foodLog.carbsConsumed, total: dailyCarbs, title: "Carbs", color: .yellow)
                            NutrientRingView(value: foodLog.proteinConsumed, total: dailyProtein, title: "Protein", color: .red)
                            NutrientRingView(value: foodLog.fatConsumed, total: dailyFat, title: "Fat", color: .blue)
                        }
                    }
                    .frame(height: 150) // Increased height
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 10, x: 0, y: 5)
                    
                    Text("Recently eaten")
                        .font(.headline)
                    
                    ForEach(foodLog.entries.prefix(5)) { entry in
                        NavigationLink(destination: FoodDetailView(entry: entry)) {
                            RecentlyEatenItemView(entry: entry)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("FitLens")
            .background(Color(UIColor.systemGroupedBackground))
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
                    .stroke(color.opacity(0.2), lineWidth: 8) // Increased thickness
                Circle()
                    .trim(from: 0, to: min(CGFloat(value) / CGFloat(total), 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round)) // Increased thickness
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(max(total - value, 0))\(title == "Calories" ? "" : "g")")
                        .font(.system(size: 16, weight: .bold)) // Reduced font size
                    Text(title)
                        .font(.system(size: 12)) // Reduced font size
                    Text("left")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 80, height: 80) // Keep the same size
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
                    Text("• \(entry.carbs)g")
                        .foregroundColor(.yellow)
                    Text("• \(entry.protein)g")
                        .foregroundColor(.red)
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
        .consistentShadow()
    }
}

struct AnalyticsView: View {
    @EnvironmentObject var foodLog: FoodLog
    @State private var selectedDate: Date? = Date() // Change to optional Date
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    CalendarView(selectedDate: $selectedDate)
                    
                    if let date = selectedDate {
                        SummaryCardView(foodLog: foodLog, date: date)
                        
                        Text(formatDate(date))
                            .font(.headline)
                        
                        ForEach(entriesForSelectedDate, id: \.id) { entry in
                            NavigationLink(destination: FoodDetailView(entry: entry)) {
                                FoodEntryCard(entry: entry)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Nutrition Insights")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    var entriesForSelectedDate: [FoodEntry] {
        guard let date = selectedDate else { return [] }
        return foodLog.entries.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct CalendarView: View {
    @EnvironmentObject var foodLog: FoodLog
    @Binding var selectedDate: Date?
    @State private var currentMonth: Date = Date()
    
    var body: some View {
        VStack {
            monthHeader
            dayOfWeekHeader
            calendarGrid
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .consistentShadow()
        .onAppear {
            if selectedDate == nil {
                selectedDate = Date() // Set to current date if not already set
            }
        }
    }
    
    private var monthHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(monthYearString(from: currentMonth))
                .font(.headline)
            Spacer()
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
            }
        }
    }
    
    private var dayOfWeekHeader: some View {
        HStack {
            ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .font(.caption)
            }
        }
    }
    
    private var calendarGrid: some View {
        let days = daysInMonth(for: currentMonth)
        let today = Calendar.current.startOfDay(for: Date())
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(days, id: \.self) { date in
                if let date = date {
                    DayCell(date: date, isSelected: Binding(
                        get: { self.selectedDate == date },
                        set: { _ in self.selectedDate = date }
                    ), isTracked: foodLog.hasEntry(on: date), isToday: Calendar.current.isDate(date, inSameDayAs: today))
                } else {
                    Color.clear
                }
            }
        }
    }
    
    private func previousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
    }
    
    private func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func daysInMonth(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        
        var days: [Date?] = []
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        for _ in 1..<weekday {
            days.append(nil)
        }
        
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
}

struct DayCell: View {
    let date: Date
    @Binding var isSelected: Bool
    let isTracked: Bool
    let isToday: Bool
    
    var body: some View {
        Text("\(Calendar.current.component(.day, from: date))")
            .frame(width: 32, height: 32)
            .font(.system(size: 16))
            .foregroundColor(isTracked ? .white : (isToday ? .blue : .primary))
            .background(
                Group {
                    if isTracked {
                        Color.green
                    } else if isSelected {
                        Color.blue.opacity(0.2)
                    } else if isToday {
                        Color.blue.opacity(0.1)
                    } else {
                        Color.clear
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : (isToday ? Color.blue : Color.clear), lineWidth: 2)
            )
            .onTapGesture {
                isSelected.toggle()
            }
    }
}

struct SummaryCardView: View {
    let foodLog: FoodLog
    let date: Date
    
    var body: some View {
        VStack {
            Text("Summary for \(formatDate(date))")
                .font(.headline)
            
            HStack {
                NutrientSummaryView(value: foodLog.caloriesConsumed(on: date), title: "Calories", color: .orange)
                NutrientSummaryView(value: foodLog.carbsConsumed(on: date), title: "Carbs", color: .yellow)
                NutrientSummaryView(value: foodLog.proteinConsumed(on: date), title: "Protein", color: .red)
                NutrientSummaryView(value: foodLog.fatConsumed(on: date), title: "Fat", color: .blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .consistentShadow()
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct NutrientSummaryView: View {
    let value: Int
    let title: String
    let color: Color
    
    var body: some View {
        VStack {
            Text("\(value)")
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
        }
    }
}

struct FoodEntryCard: View {
    let entry: FoodEntry
    
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
                    NutrientBadge(value: entry.calories, unit: "cal", color: .orange)
                    NutrientBadge(value: entry.carbs, unit: "g", color: .yellow)
                    NutrientBadge(value: entry.protein, unit: "g", color: .red)
                    NutrientBadge(value: entry.fat, unit: "g", color: .blue)
                }
            }
            
            Spacer()
            
            Text(entry.timestamp, style: .time)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .consistentShadow()
    }
}

struct NutrientBadge: View {
    let value: Int
    let unit: String
    let color: Color
    
    var body: some View {
        Text("\(value)\(unit)")
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(5)
    }
}

struct SettingsView: View {
    @State private var showingReferralView = false

    var body: some View {
        NavigationView {
            List {
                userInfoSection
                
                Section(header: Text("General")) {
                    NavigationLink(destination: UserProfileView()) {
                        SettingsRow(title: "Profile", iconName: "person.circle")
                    }
                    NavigationLink(destination: Text("Data & Privacy Settings")) {
                        SettingsRow(title: "Data & Privacy", iconName: "lock.shield")
                    }
                    NavigationLink(destination: Text("Subscription Settings")) {
                        SettingsRow(title: "Subscription", iconName: "creditcard")
                    }
                    NavigationLink(destination: Text("Password Settings")) {
                        SettingsRow(title: "Password", iconName: "key")
                    }
                    NavigationLink(destination: Text("Sign Out Confirmation")) {
                        SettingsRow(title: "Sign Out", iconName: "arrow.right.square")
                    }
                }
                
                Section(header: Text("Feature Settings")) {
                    NavigationLink(destination: Text("Shortcuts Settings")) {
                        SettingsRow(title: "Shortcuts", iconName: "command")
                    }
                    NavigationLink(destination: Text("Integrations Settings")) {
                        SettingsRow(title: "Integrations", iconName: "link")
                    }
                }
                
                Section(header: Text("Referral")) {
                    Button(action: {
                        showingReferralView = true
                    }) {
                        SettingsRow(title: "Invite Friends", iconName: "person.2.fill")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("More")
            .sheet(isPresented: $showingReferralView) {
                ReferralView()
            }
        }
    }
    
    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("ME")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text("Merdan")
                        .font(.headline)
                    Text("Member Since 1. Oktober 2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical)
    }
}

struct SettingsRow: View {
    let title: String
    let iconName: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .frame(width: 30)
            Text(title)
            Spacer()
        }
    }
}

struct UserProfileView: View {
    @AppStorage("dailyCalories") private var dailyCalories = 2400
    @AppStorage("dailyProtein") private var dailyProtein = 120
    @AppStorage("dailyCarbs") private var dailyCarbs = 330
    @AppStorage("dailyFat") private var dailyFat = 66
    @AppStorage("userName") private var userName = ""
    @AppStorage("userHeight") private var userHeight = ""
    @AppStorage("userWeight") private var userWeight = ""
    
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Name", text: $userName)
                TextField("Height (cm)", text: $userHeight)
                    .keyboardType(.numberPad)
                TextField("Weight (kg)", text: $userWeight)
                    .keyboardType(.numberPad)
            }
            
            Section(header: Text("Daily Goals")) {
                goalRow(title: "Calories", value: $dailyCalories)
                goalRow(title: "Protein (g)", value: $dailyProtein)
                goalRow(title: "Carbs (g)", value: $dailyCarbs)
                goalRow(title: "Fat (g)", value: $dailyFat)
            }
        }
        .navigationTitle("Profile")
    }
    
    private func goalRow(title: String, value: Binding<Int>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("", value: value, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isLoading: Bool
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
                self.parent.image = image
                self.parent.isLoading = true
                self.parent.presentationMode.wrappedValue.dismiss()
                
                OpenAIService.shared.analyzeImage(image) { result in
                    DispatchQueue.main.async {
                        self.parent.isLoading = false
                        switch result {
                        case .success(let foodAnalysis):
                            let entry = FoodEntry(foodName: foodAnalysis.foodName,
                                                  calories: foodAnalysis.calories,
                                                  protein: foodAnalysis.protein,
                                                  carbs: foodAnalysis.carbs,
                                                  fat: foodAnalysis.fat,
                                                  image: image,
                                                  timestamp: Date(),
                                                  healthScore: foodAnalysis.healthScore,
                                                  ingredients: foodAnalysis.ingredients)
                            self.parent.foodLog.addEntry(entry)
                        case .failure(let error):
                            print("Failed to analyze image: \(error.localizedDescription)")
                            // Show an alert to the user
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first,
                               let rootViewController = window.rootViewController {
                                let alert = UIAlertController(title: "Image Analysis Failed", message: error.localizedDescription, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                rootViewController.present(alert, animated: true, completion: nil)
                            }
                        }
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
    
    func hasEntry(on date: Date) -> Bool {
        let calendar = Calendar.current
        return entries.contains { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: date)
        }
    }
    
    func caloriesConsumed(on date: Date) -> Int {
        entriesForDate(date).reduce(0) { $0 + $1.calories }
    }
    
    func carbsConsumed(on date: Date) -> Int {
        entriesForDate(date).reduce(0) { $0 + $1.carbs }
    }
    
    func proteinConsumed(on date: Date) -> Int {
        entriesForDate(date).reduce(0) { $0 + $1.protein }
    }
    
    func fatConsumed(on date: Date) -> Int {
        entriesForDate(date).reduce(0) { $0 + $1.fat }
    }
    
    private func entriesForDate(_ date: Date) -> [FoodEntry] {
        entries.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
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
    let healthScore: Int
    let ingredients: String?
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
                            "text": "Analyze this image and provide the name of the food and its nutritional information. If there are multiple food items, sum up their nutritional values. Also, provide a health score from 1 to 10, where 1 is very unhealthy and 10 is very healthy. Include a list of main ingredients. Respond in the following JSON format: {\"foodName\": \"Name of the food(s)\", \"calories\": 0, \"protein\": 0, \"carbs\": 0, \"fat\": 0, \"healthScore\": 0, \"ingredients\": \"comma-separated list of main ingredients\"}. If the image doesn't contain food or nutritional information, return {\"foodName\": \"No food detected\", \"calories\": 0, \"protein\": 0, \"carbs\": 0, \"fat\": 0, \"healthScore\": 0, \"ingredients\": \"\"}."
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
                            
                            // Handle "No food detected" case
                            if foodAnalysis.foodName == "No food detected" || foodAnalysis.foodName == "Multiple food items" {
                                completion(.failure(NSError(domain: "Food Detection", code: 0, userInfo: [NSLocalizedDescriptionKey: foodAnalysis.foodName])))
                            } else {
                                completion(.success(foodAnalysis))
                            }
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
    let healthScore: Int
    let ingredients: String
}

struct ModernLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.white, lineWidth: 5)
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                
                Text("Analyzing...")
                    .foregroundColor(.white)
                    .padding(.top, 10)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// Create a consistent shadow style
struct ConsistentShadowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func consistentShadow() -> some View {
        self.modifier(ConsistentShadowStyle())
    }
}

// New WalletView
struct WalletView: View {
    @State private var points = 1000 // Example value
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Points:")
                            .font(.headline)
                        Text("\(points)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.top)
                    
                    // Updated HStack with closer spacing
                    HStack(spacing: 20) {
                        WalletActionButton(title: "Transfer", icon: "arrow.right")
                        WalletActionButton(title: "Buy", icon: "plus")
                        WalletActionButton(title: "Trade", icon: "arrow.2.squarepath")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    
                    Text("Your Coins")
                        .font(.headline)
                        .padding(.top)
                    
                    CoinRow(name: "SOL", fullName: "Solana", amount: "1.5", value: "$218.69")
                    CoinRow(name: "USDC", fullName: "USD Coin", amount: "100.0", value: "$100.00")
                    // Add more coin rows as needed
                }
                .padding()
            }
            .navigationTitle("Portfolio")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

// For Wallet actions
struct WalletActionButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.black)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.black)
        }
    }
}

struct CoinRow: View {
    let name: String
    let fullName: String
    let amount: String
    let value: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                Text(fullName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(amount)
                    .font(.headline)
                Text(value)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .consistentShadow()
    }
}

struct CompeteView: View {
    @EnvironmentObject var foodLog: FoodLog
    @State private var friends: [Friend] = [
        Friend(name: "Emma", calories: 1916, carbs: 220, protein: 95, fat: 70, goal: 2000, wagerAmount: 100),
        Friend(name: "Liam", calories: 1235, carbs: 150, protein: 80, fat: 45, goal: 2000, wagerAmount: 50),
        Friend(name: "Olivia", calories: 1730, carbs: 200, protein: 90, fat: 60, goal: 2000, wagerAmount: 75),
        Friend(name: "Noah", calories: 1850, carbs: 210, protein: 100, fat: 65, goal: 2000, wagerAmount: 120),
        Friend(name: "Ava", calories: 1540, carbs: 180, protein: 85, fat: 55, goal: 2000, wagerAmount: 80)
    ]
    @State private var selectedPeriod = 0
    @State private var periods = ["Today", "Yesterday", "Week", "Month"]
    @State private var showingChatView = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Period Selector
                    Picker("Time Period", selection: $selectedPeriod) {
                        ForEach(0..<periods.count) { index in
                            Text(periods[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Nutrition Summary
                    VStack(alignment: .leading, spacing: 10) {
                        Text("calories in \(periods[selectedPeriod])")
                            .font(.headline)
                        Text("\(foodLog.caloriesConsumed)")
                            .font(.system(size: 40, weight: .bold))
                        HStack {
                            Text("\(foodLog.carbsConsumed)g carbs")
                            Text("•")
                            Text("\(foodLog.proteinConsumed)g protein")
                            Text("•")
                            Text("\(foodLog.fatConsumed)g fat")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)

                    // Friends Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Friends")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(friends.sorted { $0.calories > $1.calories }.enumerated().map({ $0 }), id: \.element.id) { index, friend in
                            NavigationLink(destination: FriendComparisonView(friend: friend)) {
                                FriendRow(friend: friend, rank: index + 1)
                                    .padding(.horizontal)
                            }
                            Divider()
                        }
                        
                        Button(action: { /* Add friend action */ }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Invite your friends")
                            }
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Compete")
            .navigationBarItems(trailing:
                Button(action: {
                    showingChatView = true
                }) {
                    Image(systemName: "bell.fill")
                }
            )
            .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        }
        .sheet(isPresented: $showingChatView) {
            ChatView()
        }
    }
}

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let carbs: Int
    let protein: Int
    let fat: Int
    let goal: Int
    let wagerAmount: Int
}

struct FriendRow: View {
    let friend: Friend
    let rank: Int

    var body: some View {
        HStack {
            Text("\(rank)")
                .font(.headline)
                .frame(width: 30)
            Text(friend.name)
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(friend.calories)")
                    .font(.headline)
                Text("\(friend.goal) goal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ChatView: View {
    @State private var chats = [
        Chat(name: "Emma", lastMessage: "Great job on your calories today!", time: "2m ago"),
        Chat(name: "Liam", lastMessage: "Want to start a new challenge?", time: "1h ago"),
        Chat(name: "Olivia", lastMessage: "How's your protein intake going?", time: "3h ago"),
        Chat(name: "Noah", lastMessage: "Let's compare our progress!", time: "Yesterday"),
        Chat(name: "Ava", lastMessage: "Congrats on winning the last challenge!", time: "2d ago")
    ]

    var body: some View {
        NavigationView {
            List(chats) { chat in
                HStack {
                    VStack(alignment: .leading) {
                        Text(chat.name)
                            .font(.headline)
                        Text(chat.lastMessage)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(chat.time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Chats")
        }
    }
}

struct Chat: Identifiable {
    let id = UUID()
    let name: String
    let lastMessage: String
    let time: String
}

struct ReferralView: View {
    @State private var referralCode = "1bXNd"
    @State private var referralLink = "https://www...Code=1bXNd"
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Referral Code")
                    .font(.headline)
                
                HStack {
                    Text(referralCode)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Button(action: {
                        UIPasteboard.general.string = referralCode
                    }) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.black) // Changed from blue to black
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Text("Referral link")
                    .font(.headline)
                
                HStack {
                    Text(referralLink)
                        .font(.subheadline)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Button(action: {
                        UIPasteboard.general.string = referralLink
                    }) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.black) // Changed from blue to black
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Button(action: {
                    // Implement invite friends action here
                }) {
                    Text("Invite Friends")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black) // Changed from blue to black
                        .cornerRadius(10)
                }
                .padding(.top)
                
                Spacer()
                
                Text("Find out how your referral works")
                    .font(.footnote)
                    .foregroundColor(.black) // Changed from blue to black
            }
            .padding()
            .navigationTitle("Referral")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct FriendComparisonView: View {
    let friend: Friend
    @EnvironmentObject var foodLog: FoodLog
    @State private var selectedPeriod = 0
    private let periods = ["Today", "Yesterday", "Week", "Month"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Period Selector
                Picker("Time Period", selection: $selectedPeriod) {
                    ForEach(0..<periods.count) { index in
                        Text(periods[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Comparison View
                HStack(spacing: 30) {
                    ComparisonColumn(name: "You", calories: foodLog.caloriesConsumed, carbs: foodLog.carbsConsumed, protein: foodLog.proteinConsumed, fat: foodLog.fatConsumed)
                    Text("VS")
                        .font(.title)
                        .fontWeight(.bold)
                    ComparisonColumn(name: friend.name, calories: friend.calories, carbs: friend.carbs, protein: friend.protein, fat: friend.fat)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)

                // Statistics
                VStack(alignment: .leading, spacing: 10) {
                    StatRow(title: "calories today", you: "\(foodLog.caloriesConsumed)", friend: "\(friend.calories)")
                    StatRow(title: "yesterday", you: "1354", friend: "2003")
                    StatRow(title: "last 7 days avg", you: "1459", friend: "1855")
                    StatRow(title: "best day", you: "2009", friend: "2180")
                    StatRow(title: "best week", you: "15640", friend: "17509")
                    StatRow(title: "days won", you: "2", friend: "5")
                    StatRow(title: "longest win streak", you: "2", friend: "4")
                }
                .padding(.horizontal)

                // Wager Amount
                Text("Wager Amount: \(friend.wagerAmount) points")
                    .font(.headline)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)

                // Action Buttons
                HStack {
                    FriendActionButton(title: "Cheer", icon: "👍")
                    FriendActionButton(title: "Taunt", icon: "😜")
                    FriendActionButton(title: "Nudge", icon: "👉")
                }
            }
            .padding()
        }
        .navigationTitle("You vs \(friend.name)")
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

struct ComparisonColumn: View {
    let name: String
    let calories: Int
    let carbs: Int
    let protein: Int
    let fat: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(name)
                .font(.headline)
            Text("\(calories)")
                .font(.title)
                .fontWeight(.bold)
            Text("\(carbs)g carbs")
            Text("\(protein)g protein")
            Text("\(fat)g fat")
        }
    }
}

struct StatRow: View {
    let title: String
    let you: String
    let friend: String

    var body: some View {
        HStack {
            Text(title)
                .frame(width: 120, alignment: .leading)
            Spacer()
            Text(you)
            Spacer()
            Text(friend)
        }
    }
}

struct FoodDetailView: View {
    let entry: FoodEntry
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let image = entry.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                }
                
                Text(entry.foodName)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                HStack(spacing: 10) {
                    NutrientBox(title: "Calories", value: entry.calories, unit: "")
                    NutrientBox(title: "Carbs", value: entry.carbs, unit: "g")
                    NutrientBox(title: "Protein", value: entry.protein, unit: "g")
                    NutrientBox(title: "Fat", value: entry.fat, unit: "g")
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Health Score")
                        .font(.headline)
                    HStack {
                        Text("\(entry.healthScore)/10")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        HealthScoreBar(score: entry.healthScore)
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ingredients")
                        .font(.headline)
                    Text(entry.ingredients ?? "No ingredients information available")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Food Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NutrientBox: View {
    let title: String
    let value: Int
    let unit: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(value)\(unit)")
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct HealthScoreBar: View {
    let score: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray5))
                Rectangle()
                    .fill(scoreColor)
                    .frame(width: CGFloat(score) / 10 * geometry.size.width)
            }
        }
        .frame(height: 10)
        .cornerRadius(5)
    }
    
    var scoreColor: Color {
        switch score {
        case 1...3: return .red
        case 4...6: return .yellow
        case 7...10: return .green
        default: return .gray
        }
    }
}

// For Friend Comparison actions
struct FriendActionButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack {
            Text(icon)
                .font(.system(size: 24))
                .frame(width: 60, height: 60)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.black)
        }
    }
}

struct MenuButton: View {
    let icon: String
    var text: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 50, height: 50)
                    .shadow(radius: 4)
                
                if let text = text {
                    Text(text)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

