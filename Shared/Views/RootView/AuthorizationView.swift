//
//  AuthorizationView.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2021.
//

import Foundation
import Introspect
import SwiftUI
import UIKit

struct AuthorizationView: View {
    @State var apiToken: Binding<String>
    let doneButton: () -> Void

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack {
                    Text("Что бы пользоваться приложением, необходимо ввести токен Тинькофф инвестиций. Его можно взять в настройках, в веб версии")
                    VStack(alignment: .leading) {
                        Text("Enter token")
                        TextField("api token", text: apiToken)
                            .introspectTextField(customize: { textField in
                                textField.becomeFirstResponder()
                            })
                        Divider()
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 50)

                    Button(action: doneButton, label: {
                        Text("Done")
                            .font(.title3)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .multilineTextAlignment(.center)
                            .background(Color.litleGray)
                            .cornerRadius(5)
                    })
                        .buttonStyle(DefaultButtonStyle())
                }.padding()
            }
            .accentColor(.appBlack)
            .navigationTitle("Autorization")
        }
    }
}
