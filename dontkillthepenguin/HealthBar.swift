import SwiftUI
import SwiftData

struct HealthBar: View {
    @Binding var value: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color.red)
                
                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width / 100, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color.green)
                    .animation(.linear)
            }
        }
    }
}