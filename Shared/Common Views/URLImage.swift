//
//  URLImage.swift
//  Investing
//
//  Created by Sergey Balashov on 22.01.2021.
//

import Foundation
import InvestModels
import Kingfisher
import SwiftUI

extension Position: LogoPosition {}

struct URLImage: View {
    let position: LogoPosition

    @State var text: String?

    init(position: LogoPosition) {
        self.position = position
    }

    var body: some View {
        if let text = text {
            Text(text)
        } else if let url = InstrumentLogoService.logoUrl(for: position) {
            KFImage(url)
                .resizable()
                .cancelOnDisappear(true)
                .placeholder {
                    ProgressView()
                }
                .onProgress { _, _ in }
                .onSuccess { _ in }
                .onFailure { _ in
                    let first = position.ticker ?? position.instrumentType.rawValue
                    self.text = String(first.first!)
                }
        } else {
            Text("E")
                .background(Color.litleGray)
        }
    }
}
