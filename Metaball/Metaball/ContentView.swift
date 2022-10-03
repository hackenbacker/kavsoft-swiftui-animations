//
//  ContentView.swift
//  Metaball
//
//  Created by Hackenbacker on 2022/10/01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Home()
            .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
