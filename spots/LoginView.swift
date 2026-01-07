import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var error: String? = nil
    @State private var navigateToContentView = false
    @State private var navigateToSignup = false
    @Environment(\.dismiss)private var dismiss
    var body: some View {
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
            NavigationLink(
                destination: SignupView(),
                isActive: $navigateToSignup
            ) {
                EmptyView()
            }
        )
    }
    func createAcc(){
        navigateToSignup = true
    }
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
