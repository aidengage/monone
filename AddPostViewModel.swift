// AddPostViewModel.swift @Observable
@Binding var centerLat: Double = 0 // Now updates dynamically when added from parent overlay!
@Binding var centerLong: Double = 0

// Then fix this in your form
Section(header: Text("Coordinates")) {
    TextField("Latitude", value: $centerLat, format: .number)
        .keyboardType(.decimalPad)
    TextField("Longitude", value: $centerLong, format: .number)
        .keyboardType(.decimalPad)
}
``` This keeps the coordinates perfectly aligned with your MapView's movements!