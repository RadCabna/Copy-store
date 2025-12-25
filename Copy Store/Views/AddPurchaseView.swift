//
//  AddPurchaseView.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 24.12.2025.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AddPurchaseView: View {
    @Environment(\.dismiss) var dismiss
    
    // Input fields
    @State private var productName: String = ""
    @State private var shopName: String = ""
    @State private var purchaseDate: Date = Date()
    @State private var showDatePicker: Bool = false
    
    // Warranty period
    @State private var selectedWarrantyPeriod: Int? = nil // 0-3 for presets, 4 for custom
    @State private var customWarrantyYears: Int = 4
    @State private var isLifetimeWarranty: Bool = false
    @State private var showCustomWarrantyPicker: Bool = false
    
    let warrantyOptions = ["6 months", "1 year", "2 years", "3 years"]
    let warrantyMonths = [6, 12, 24, 36]
    let customYearsOptions = Array(4...99) + [0] // 0 = Lifetime
    
    // Photo
    @State private var selectedPhoto: UIImage? = nil
    @State private var showImagePicker: Bool = false
    @State private var showImageSourceAlert: Bool = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // PDF
    @State private var selectedPDFURL: URL? = nil
    @State private var showDocumentPicker: Bool = false
    
    // Validation
    @State private var showValidationErrors: Bool = false
    
    var isNameValid: Bool { !productName.trimmingCharacters(in: .whitespaces).isEmpty }
    var isShopValid: Bool { !shopName.trimmingCharacters(in: .whitespaces).isEmpty }
    var isWarrantyValid: Bool { selectedWarrantyPeriod != nil }
    var isFormValid: Bool { isNameValid && isShopValid && isWarrantyValid }
    
    // Computed dates
    var warrantyEndDate: Date {
        if selectedWarrantyPeriod == 4 {
            if isLifetimeWarranty {
                return Calendar.current.date(byAdding: .year, value: 100, to: purchaseDate) ?? purchaseDate
            } else {
                return Calendar.current.date(byAdding: .year, value: customWarrantyYears, to: purchaseDate) ?? purchaseDate
            }
        } else {
            let months = selectedWarrantyPeriod != nil ? warrantyMonths[selectedWarrantyPeriod!] : 12
            return Calendar.current.date(byAdding: .month, value: months, to: purchaseDate) ?? purchaseDate
        }
    }
    
    var customWarrantyDisplayText: String {
        if isLifetimeWarranty {
            return "Lifetime"
        } else {
            return "\(customWarrantyYears) years"
        }
    }
    
    var refundEndDate: Date {
        return Calendar.current.date(byAdding: .day, value: 14, to: purchaseDate) ?? purchaseDate
    }
    
    var warrantyDaysLeft: Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: warrantyEndDate).day ?? 0
        return max(0, days)
    }
    
    var refundDaysLeft: Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: refundEndDate).day ?? 0
        return max(0, days)
    }
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: screenHeight * 0.02) {
                        // Name field
                        inputSection(title: "Name", text: $productName, icon: "nameIcon", isValid: isNameValid)
                        
                        // Shop field
                        inputSection(title: "Shop", text: $shopName, icon: "shopIcon", isValid: isShopValid)
                        
                        // Date of purchase
                        dateSection
                        
                        // Warranty period
                        warrantyPeriodSection
                        
                        // Warranty and Refund frames
                        warrantyRefundSection
                        
                        // Attachments
                        attachmentsSection
                        
                        // Add button
                        Button(action: {
                            showValidationErrors = true
                            if isFormValid {
                                savePurchase()
                                dismiss()
                            }
                        }) {
                            Image("addButton")
                                .resizable()
                                .scaledToFit()
                                .opacity(isFormValid ? 1.0 : 0.5)
                        }
                        .padding(.top, screenHeight * 0.02)
                        .padding(.bottom, screenHeight * 0.05)
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.top, screenHeight * 0.02)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedPhoto, sourceType: imageSourceType)
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(selectedURL: $selectedPDFURL)
        }
        .alert("Choose photo source", isPresented: $showImageSourceAlert) {
            Button("Camera") {
                imageSourceType = .camera
                showImagePicker = true
            }
            Button("Photo Library") {
                imageSourceType = .photoLibrary
                showImagePicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image("arrowBack")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.05)
            }
            
            Spacer()
            
            Text("Adding a purchase")
                .font(.custom("SF Pro Display", size: screenHeight * 0.022))
                .fontWeight(.semibold)
                .foregroundColor(Color("text_2Color"))
            
            Spacer()
            
            // Placeholder for symmetry
            Color.clear
                .frame(width: screenHeight * 0.025, height: screenHeight * 0.025)
        }
        .padding(.horizontal, screenWidth * 0.05)
        .padding(.top, screenHeight * 0.01)
        .padding(.bottom, screenHeight * 0.01)
    }
    
    // MARK: - Input Section
    private func inputSection(title: String, text: Binding<String>, icon: String, isValid: Bool) -> some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.005) {
            Text(title)
                .font(.custom("SF Pro Display", size: screenHeight * 0.02))
                .foregroundColor(Color("text_2Color"))
            
            ZStack {
                Image("enterDataFrame")
                    .resizable()
                    .scaledToFit()
                
                HStack {
                    TextField("", text: text)
                        .font(.custom("SF Pro Display", size: screenHeight * 0.018))
                        .foregroundColor(.black)
                        .padding(.leading, screenWidth * 0.04)
                    
                    Spacer()
                    
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.03)
                        .padding(.trailing, screenWidth * 0.04)
                }
                
                // Red border when invalid
                if showValidationErrors && !isValid {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.red, lineWidth: 2)
                }
            }
            .frame(height: screenHeight * 0.06)
            
            // Error message
            if showValidationErrors && !isValid {
                Text("You need to fill in this field")
                    .font(.custom("SF Pro Display", size: screenHeight * 0.014))
                    .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - Date Section
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.01) {
            Text("Date of purchase")
                .font(.custom("SF Pro Display", size: screenHeight * 0.02))
                .foregroundColor(Color("text_2Color"))
            
            ZStack {
                Image("enterDataFrame")
                    .resizable()
                    .scaledToFit()
                
                HStack {
                    Text(purchaseDate.formatted(date: .numeric, time: .omitted))
                        .font(.custom("SF Pro Display", size: screenHeight * 0.018))
                        .foregroundColor(.black)
                        .padding(.leading, screenWidth * 0.04)
                    
                    Spacer()
                    
                    Image("dateIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.03)
                        .padding(.trailing, screenWidth * 0.04)
                }
            }
            .frame(height: screenHeight * 0.06)
            .onTapGesture {
                withAnimation {
                    showDatePicker.toggle()
                }
            }
            
            if showDatePicker {
                DatePicker("", selection: $purchaseDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Color("text_1Color"))
                    .colorScheme(.light)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.white)
                    )
                    .padding(.top, screenHeight * 0.01)
            }
        }
    }
    
    // MARK: - Warranty Period Section
    private var warrantyPeriodSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.005) {
            Text("Warranty period")
                .font(.custom("SF Pro Display", size: screenHeight * 0.02))
                .foregroundColor(Color("text_2Color"))
            
            HStack(spacing: screenWidth * 0.02) {
                ForEach(0..<4, id: \.self) { index in
                    warrantyButton(index: index, text: warrantyOptions[index])
                }
                
                // Custom period button
                Button(action: {
                    if selectedWarrantyPeriod == 4 {
                        withAnimation {
                            showCustomWarrantyPicker.toggle()
                        }
                    } else {
                        selectedWarrantyPeriod = 4
                        withAnimation {
                            showCustomWarrantyPicker = true
                        }
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedWarrantyPeriod == 4 ? Color("text_1Color") : .white)
                        
                        Image("customPeriodIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.02)
                            .foregroundColor(selectedWarrantyPeriod == 4 ? .white : .black)
                        
                        // Red border when invalid
                        if showValidationErrors && !isWarrantyValid {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 2)
                        }
                    }
                    .frame(width: screenWidth * 0.1, height: screenHeight * 0.045)
                }
            }
            .overlay(
                // Red border around all warranty buttons when invalid
                Group {
                    if showValidationErrors && !isWarrantyValid {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.red, lineWidth: 2)
                            .padding(-4)
                    }
                }
            )
            
            // Error message
            if showValidationErrors && !isWarrantyValid {
                Text("You need to fill in this field")
                    .font(.custom("SF Pro Display", size: screenHeight * 0.014))
                    .foregroundColor(.red)
            }
            
            // Custom warranty picker
            if selectedWarrantyPeriod == 4 && showCustomWarrantyPicker {
                customWarrantyPickerView
            }
        }
    }
    
    // MARK: - Custom Warranty Picker
    private var customWarrantyPickerView: some View {
        VStack(spacing: screenHeight * 0.01) {
            ZStack {
                Image("enterDataFrame")
                    .resizable()
                    .scaledToFit()
                
                HStack {
                    Text(customWarrantyDisplayText)
                        .font(.custom("SF Pro Display", size: screenHeight * 0.018))
                        .foregroundColor(.black)
                        .padding(.leading, screenWidth * 0.04)
                    
                    Spacer()
                    
                    Image("dateIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.03)
                        .padding(.trailing, screenWidth * 0.04)
                }
            }
            .frame(height: screenHeight * 0.06)
            
            Picker("", selection: Binding(
                get: { isLifetimeWarranty ? 0 : customWarrantyYears },
                set: { newValue in
                    if newValue == 0 {
                        isLifetimeWarranty = true
                    } else {
                        isLifetimeWarranty = false
                        customWarrantyYears = newValue
                    }
                }
            )) {
                ForEach(4..<100, id: \.self) { year in
                    Text("\(year) years").tag(year)
                }
                Text("Lifetime").tag(0)
            }
            .pickerStyle(.wheel)
            .colorScheme(.light)
            .frame(height: screenHeight * 0.15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.white)
            )
        }
    }
    
    private func warrantyButton(index: Int, text: String) -> some View {
        Button(action: {
            selectedWarrantyPeriod = index
            withAnimation {
                showCustomWarrantyPicker = false
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedWarrantyPeriod == index ? Color("text_1Color") : .white)
                
                Text(text)
                    .font(.custom("SF Pro Display", size: screenHeight * 0.014))
                    .foregroundColor(selectedWarrantyPeriod == index ? .white : .black)
                    .multilineTextAlignment(.center)
            }
            .frame(height: screenHeight * 0.045)
        }
    }
    
    // MARK: - Warranty & Refund Section
    private var warrantyRefundSection: some View {
        HStack(spacing: screenWidth * 0.03) {
            // Warranty Frame
            ZStack(alignment: .leading) {
                Image("warrantyFrame")
                    .resizable()
                    .scaledToFit()
                
                VStack(alignment: .leading, spacing: screenHeight * 0.008) {
                    HStack(spacing: screenWidth * 0.02) {
                        Image("warrantyIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.04)
                        
                        Text("Warranty\nup to")
                            .font(.custom("SF Pro Display", size: screenHeight * 0.017))
                            .foregroundColor(Color("text_5Color"))
                            .textCase(.uppercase)
                            .lineLimit(2)
                    }
                    HStack {
                        Text(formatDate(warrantyEndDate))
                            .font(.custom("SF Pro Display", size: screenHeight * 0.022))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.trailing, screenWidth * 0.04)
                    Text("There are \(warrantyDaysLeft)days left")
                        .font(.custom("SF Pro Display", size: screenHeight * 0.015))
                        .foregroundColor(Color("text_5Color"))
                        .lineLimit(2)
                }
                .padding(.leading, screenWidth * 0.04)
            }
            
            // Refund Frame
            ZStack(alignment: .leading) {
                Image("refundFrame")
                    .resizable()
                    .scaledToFit()
                
                VStack(alignment: .leading, spacing: screenHeight * 0.008) {
                    HStack(spacing: screenWidth * 0.02) {
                        Image("refundIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.04)
                        
                        Text("Refund\nbefore")
                            .font(.custom("SF Pro Display", size: screenHeight * 0.017))
                            .foregroundColor(Color("text_4Color"))
                            .textCase(.uppercase)
                            .lineLimit(2)
                    }
                    
                    Text(formatDate(refundEndDate))
                        .font(.custom("SF Pro Display", size: screenHeight * 0.022))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.trailing, screenWidth * 0.04)
                    
                    Text("\(refundDaysLeft) days from purchase")
                        .font(.custom("SF Pro Display", size: screenHeight * 0.015))
                        .foregroundColor(Color("text_4Color"))
                        .lineLimit(2)
                }
                .padding(.leading, screenWidth * 0.04)
            }
        }
    }
    
    // MARK: - Attachments Section
    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.015) {
            Text("Attachments")
                .font(.custom("SF Pro Display", size: screenHeight * 0.02))
                .foregroundColor(Color("text_2Color"))
            
            // Photo section
            VStack(spacing: screenHeight * 0.01) {
                if let photo = selectedPhoto {
                    Text("Receipt photo")
                        .font(.custom("SF Pro Display", size: screenHeight * 0.016))
                        .foregroundColor(Color("text_3Color"))
                    
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenHeight * 0.1, height: screenHeight * 0.1)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    showImageSourceAlert = true
                }) {
                    Image("uploadPhotoButton")
                        .resizable()
                        .scaledToFit()
                }
            }
            
            // PDF section
            VStack(spacing: screenHeight * 0.01) {
                if let pdfURL = selectedPDFURL {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("text_3Color"), lineWidth: 1)
                        .frame(height: screenHeight * 0.1)
                        .overlay(
                            VStack {
                                Image(systemName: "doc.fill")
                                    .font(.system(size: screenHeight * 0.03))
                                    .foregroundColor(Color("text_2Color"))
                                
                                Text(pdfURL.lastPathComponent)
                                    .font(.custom("SF Pro Display", size: screenHeight * 0.012))
                                    .foregroundColor(Color("text_3Color"))
                                    .lineLimit(1)
                                    .padding(.horizontal, screenWidth * 0.02)
                            }
                        )
                }
                
                Button(action: {
                    showDocumentPicker = true
                }) {
                    Image("uploadInstructionsButton")
                        .resizable()
                        .scaledToFit()
                }
            }
        }
    }
    
    // MARK: - Helper
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: date)
    }
    
    private func savePurchase() {
        // Рассчитываем месяцы гарантии
        var warrantyMonths: Int
        if selectedWarrantyPeriod == 4 {
            // Кастомный период в годах, конвертируем в месяцы
            warrantyMonths = customWarrantyYears * 12
        } else if let period = selectedWarrantyPeriod {
            warrantyMonths = self.warrantyMonths[period]
        } else {
            warrantyMonths = 12
        }
        
        // Конвертируем фото в Data
        let photoData = selectedPhoto?.jpegData(compressionQuality: 0.8)
        
        // Создаем покупку
        let purchase = Purchase(
            name: productName.trimmingCharacters(in: .whitespaces),
            shop: shopName.trimmingCharacters(in: .whitespaces),
            purchaseDate: purchaseDate,
            warrantyMonths: warrantyMonths,
            isLifetimeWarranty: selectedWarrantyPeriod == 4 && isLifetimeWarranty,
            photoData: photoData,
            pdfURL: selectedPDFURL?.absoluteString
        )
        
        // Сохраняем
        PurchaseManager.shared.addPurchase(purchase)
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Document Picker
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.selectedURL = urls.first
            parent.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
    }
}

#Preview {
    AddPurchaseView()
}

