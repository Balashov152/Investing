//
//  URLImage.swift
//  Investing
//
//  Created by Sergey Balashov on 22.01.2021.
//

import Foundation
import Kingfisher
import SwiftUI

struct URLImage<EndImage: View>: View {
    let url: URL
    let configure: (KFImage) -> EndImage

    @State var fail: KingfisherError?

    init(url: URL, @ViewBuilder configure: @escaping (KFImage) -> EndImage) {
        self.url = url
        self.configure = configure
    }

    var body: some View {
        if fail != nil {
            EmptyView()
        } else {
            configure(KFImage(url)
                .resizable()
                .cancelOnDisappear(true)
                .placeholder {
                    ProgressView()
                }
                .onProgress { _, _ in }
                .onSuccess { _ in }
                .onFailure { fail in
                    self.fail = fail
                }
            )
        }
    }
}
