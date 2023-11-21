//
//  ContentView.swift
//  WebViewTest01
//
//  Created by julio.collado on 11/17/23.
//

import SwiftUI

struct ContentView: View {
    let webSiteURL = URL(string: "https://tools.pdf24.org/en/pdf-converter")!
    
    var body: some View {
        WebView(websiteURL: webSiteURL)
    }
}

#Preview {
    ContentView()
}
