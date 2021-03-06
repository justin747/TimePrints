// Kevin Li - 10:42 AM - 3/2/20

import SwiftUI

struct ThemePickerView: View {
    @State private var selectedColor: UIColor = .clear
    @State private var instructionsScale: CGFloat = 0

    let startingThemeColor: UIColor
    let onSelected: (UIColor) -> Void

    let themeColors = AppColors.themes.chunked(into: 2)

    init(startingThemeColor: UIColor, onSelected: @escaping (UIColor) -> Void) {
        self.startingThemeColor = startingThemeColor
        self.onSelected = onSelected
    }

    var body: some View {
        ZStack {
            ColorAdaptiveVisitsView(color: selectedColor.color)
                .frame(maxHeight: screen.height)
                .animation(.easeInOut)
            colorPickerList
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                .extendToScreenEdges()
            bottomAlignedInstructionsText
        }
        .onAppear(perform: setSelectedThemeWithAnimation)
    }

    private func setSelectedThemeWithAnimation() {
        selectedColor = startingThemeColor
        instructionsScale = 1
    }
}

private extension ThemePickerView {
    private var colorPickerList: some View {
        colorPickerStack
            .frame(width: screen.width)
            .padding()
    }

    private var colorPickerStack: some View {
        VStack(spacing: 50) {
            ForEach(themeColors, id: \.self) { rowUiColors in
                HStack(spacing: 50) {
                    self.scalingCircleView(for: rowUiColors[0])
                    self.scalingCircleView(for: rowUiColors[1])
                }
            }
        }
    }

    private func scalingCircleView(for uiColor: UIColor) -> some View {
        ScalingCircle(selectedColor: $selectedColor, uiColor: uiColor)
            .onTapGesture {
                self.onSelected(uiColor)
        }
    }

    private var bottomAlignedInstructionsText: some View {
        VStack {
            Spacer()
            instructionsText
                .padding(.bottom)
                .scaleEffect(instructionsScale)
                .animation(.spring())
        }
    }

    private var instructionsText: some View {
        Text("What's your favorite color?")
            .font(.headline)
    }
}

struct ThemePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ThemePickerView(startingThemeColor: AppColors.themes.first!, onSelected: { _ in })
    }
}
