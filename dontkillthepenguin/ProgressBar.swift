//
//  ProgressBar.swift
//  dontkillthepenguin
//
//  Created by Michael Chen on 11/4/23.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var value: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.7)
                    .foregroundColor(Color.gray)

                Rectangle()
                    .frame(width: min(CGFloat(value) / 100 * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(healthBarColor(for: value))
                    .animation(.linear)
            }
        }
    }
    private func healthBarColor(for value: Int) -> Color {
        if value > 66 {
            return Color.green
        } else if value > 33 {
            return Color.yellow
        } else {
            return Color.red
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(value: .constant(50)) // You can adjust the initial value here
            .frame(height: 20)
    }
}
