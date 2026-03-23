import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Environment(\.dismiss)private var dismiss
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var error: String? = nil
    @State private var navigateToContentView = false
    @State private var navigateToSignup = false
    
    var body: some View {
        
        // login form, needs visual feedback for what is wrong when user inputs incorrect form
        Form {
            Section(header: Text("Email")) {
                TextField("Email", text: $email)
            }
            Section(header: Text("Password")) {
                TextField("Password", text: $password)
            }
            Button(action: {
                login(email: email, password: password)
            }) { 
                Text("Login")
            }
            Button(action: {
                createAcc()
            })
            {
                Text("Don't have an account? Create one here")
            }
        }
        .navigationTitle("Log In")
        .background(
            
            // rework navigation link to stack
            NavigationLink(
                destination: SignupView(),
                isActive: $navigateToSignup
            ) {
                EmptyView()
            }
        )
        .scrollDismissesKeyboard(.interactively)
        .onAppear() {
            addTapGestureToDismissKeyboard()
        }
    }
    
    func addTapGestureToDismissKeyboard() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first else {
            return
        }
        
        let tapGesture = UITapGestureRecognizer(target: UIApplication.shared, action: #selector( UIApplication.dismissKeyboard ))
        tapGesture.cancelsTouchesInView = false 
        window.addGestureRecognizer(tapGesture)
    }
    
    // when create account button is pressed, this sets navigateToSignup to true which triggers the navigation link above to go to signup view
    // shouldnt be too hard to rework for navigation stack
    func createAcc(){
        navigateToSignup = true
    }
    
    // login function that sends auth info to firebase
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print(error)
            } else {
                dismiss()
            }
        }
    }
}       
