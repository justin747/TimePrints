// Kevin Li - 10:46 AM - 2/28/20

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var isLoggingIn = false

    private var alert: Alert? {
        userStore.alert
    }

    var body: some View {
        ZStack {
            mainView

            loggingInViewIfLoggingIn

            alertViewIfExists
        }
    }

}

private extension LoginView {
    private var mainView: some View {
        VStack {
            profileLottieView
            iCloudLoginButton
            Spacer()
        }
    }

    private var profileLottieView: some View {
        LottieView(fileName: "profile", repeatAnimation: !userStore.isLoggedIn)
            .frame(width: 250, height: 250)
    }

    private var iCloudLoginButton: some View {
        HStack {
            iCloudImage
            iCloudSignInText
        }
        .frame(width: 343, height: 68)
        .background(BlurView(style: .systemMaterial))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color(.kingFisherDaisy).opacity(0.5), radius: 20)
        .onTapGesture(perform: logInToICloud)
    }

    private var iCloudImage: some View {
        Image(systemName: "icloud.fill")
            .imageScale(.large)
            .foregroundColor(Color(.white))
    }

    private var iCloudSignInText: some View {
        Text("Sign in With iCloud")
            .font(.headline)
    }

    private var loggingInAnimationDuration: Double { 2 }

    private func logInToICloud() {
        showLoggingInView()

        DispatchQueue.main.asyncAfter(deadline: .now() + loggingInAnimationDuration) {
            self.logIn()
        }
    }

    private func showLoggingInView() {
        isLoggingIn = true
    }

    private func logIn() {
        self.userStore.logIn()
        isLoggingIn = false
    }
}

private extension LoginView {
    private var loggingInViewIfLoggingIn: some View {
        Group {
            if isLoggingIn {
                loggingInView
            }
        }
    }

    private var loggingInView: some View {
        VStack {
            LottieView(fileName: "loading", repeatAnimation: true)
                .frame(width: 200, height: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var alertViewIfExists: some View {
        Group {
            if alert != nil {
                alertView
            }
        }
    }

    private var alertView: some View {
        AlertView(alert: userStore.alert!)
    }

    private struct AlertView: View {
        @State var show = false
        let alert: Alert

        var body: some View {
            VStack {
                Text(alert.message)
                    .font(.system(.title))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .animation(nil)
                LottieView(fileName: alert.lottieFile)
                    .frame(width: 150, height: 150)
                    .opacity(show ? 1 : 0)
                    .animation(Animation.linear(duration: 1).delay(0.4))
                    .scaleEffect(1.3)
            }
            .frame(width: 300)
            .padding()
            .background(BlurView(style: .systemMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color.black.opacity(0.2), radius: 30, x: 0, y: 30)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaleEffect(show ? 1 : 0.5)
            .background(Color.black.opacity(show ? 0.7 : 0))
            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
            .onAppear {
                self.show = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserStore(loginService: MockSuccessLoginService()))
    }
}
