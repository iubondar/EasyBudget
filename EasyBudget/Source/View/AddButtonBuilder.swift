import SwiftUI

struct AddButtonBuilder {
    static func buildAddButton(action: @escaping () -> ()) -> some View {
        return Button(
            action: { action() },
            label: {
                Text("+")
                    .font(
                        .system(.largeTitle)
                    )
                    .frame(width: 77, height: 70)
                    .foregroundColor(Color.white)
                    .padding(.bottom, 7)
            }
        )
        .background(Color.blue)
        .cornerRadius(38.5)
        .padding()
        .shadow(
            color: Color.black.opacity(0.3),
            radius: 3,
            x: 3,
            y: 3
        )
    }
}
