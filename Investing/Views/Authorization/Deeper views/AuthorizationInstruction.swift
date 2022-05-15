//
//  AuthorizationInstruction.swift
//  Investing
//
//  Created by Sergey Balashov on 23.04.2021.
//

import Foundation
import SwiftUI

struct AuthorizationInstruction: View {
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                infoText("Токен API будет использоваться ТОЛЬКО ДЛЯ ЧТЕНИЯ. Он необходим для получения информации о портфеле и истории всех операций. Это нужно для подсчета аналитических данных которые предоставляет приложение. Приложение использует только официальное API Тинькофф и не передает данные третьим лицам.")
                tab
                Divider()
                settings
                Divider()
                tokenBlock
                Divider()
                tokenCopy
            }.padding()
        }
    }

    func stepBlock(step: Int, image: String, text: String) -> some View {
        HStack(alignment: .top) {
            stepLabel(step: step)
            VStack(alignment: .leading) {
                Image(image)
                    .resizable()
                    .scaledToFit()

                infoText(text)
            }
        }
    }

    func stepLabel(step: Int) -> some View {
        Text(step.string)
            .font(.headline)
            .bold()
            .foregroundColor(.white)
            .padding(8)
            .background(Color.yellow)
            .clipShape(Circle())
    }

    func infoText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
    }

    var tab: some View {
        stepBlock(step: 1,
                  image: "invest_tab_instruction",
                  text: "Войдите в ваш аккаунт тинькофф, в веб версиии, и выберете таб \"Инвестиции\"")
    }

    var settings: some View {
        stepBlock(step: 2,
                  image: "settings_tab_instruction",
                  text: "Далее откройте вкладку \"Настройки\"")
    }

    var tokenBlock: some View {
        stepBlock(step: 3,
                  image: "token_block_instruction",
                  text: "Внизу экрана нажмите на кнопку \"Токен для торговли\"")
    }

    var tokenCopy: some View {
        stepBlock(step: 4,
                  image: "token_field_instruction",
                  text: "Скопируйте токен в поле авторизации в приложении")
    }
}
