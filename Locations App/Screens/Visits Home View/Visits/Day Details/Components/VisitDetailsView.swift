import MapKit
import SwiftUI

struct VisitDetailsView: View {
    @Environment(\.appTheme) private var appTheme: UIColor

    @State private var isMapOpen = false
    @State private var isFavorite = false
    @State private var isEditingNotes = false

    @State private var notesInput = ""
    @State private var activeTranslation: CGSize = .zero

    @Binding var selectedIndex: Int

    let index: Int
    let visit: Visit
    let setActiveVisitLocationAndDisplayMap: (Visit) -> Void

    private var isSelected: Bool {
        selectedIndex == index
    }

    var body: some View {
        ZStack(alignment: .top) {
            visitDetailsView
                .padding(.top, isSelected ? 80 : 12)
                .padding(.leading, isSelected ? 0 : 40)
                .padding(.trailing, isSelected ? 0 : 40)
                .frame(height: VisitCellConstants.height(if: isSelected))
                .frame(maxWidth: VisitCellConstants.maxWidth(if: isSelected))
                .background(appTheme.color)
                .clipShape(RoundedRectangle(cornerRadius: isSelected ? 30 : 10, style: .continuous))
                .onTapGesture(perform: setSelectedVisitIndex)
                .simultaneousGesture(exitGestureIfSelected)
        }
        .onAppear(perform: setFavoritedStateAndNotesInput)
        .frame(height: VisitCellConstants.height(if: isSelected))
        .extendToScreenEdges()
        .scaleEffect(1 - (self.activeTranslation.height+self.activeTranslation.width)/1000)
        .animation(.spring())
    }
}

private extension VisitDetailsView {
    private var visitDetailsView: some View {
        VStack(spacing: 2) {
            header
                .padding(.bottom, isSelected ? 10 : 0)
                .padding(.horizontal, isSelected ? 30 : 0)
            coreDetailsView
                .scaleEffect(isMapOpen || isEditingNotes ? 0 : 1)
                .fade(if: isMapOpen || isEditingNotes)
            interactableMapViewIfSelected
                .scaleEffect(isEditingNotes ? 0 : 1)
                .fade(if: isEditingNotes)
            notesIfSelected
                .fade(if: isMapOpen)
                .scaleEffect(isMapOpen ? 0 : 1)
                .padding(.bottom, 100)
            Spacer()
        }
    }
}

private extension VisitDetailsView {
    private var header: some View {
        HStack(alignment: .center) {
            backButton
                .fade(if: !isSelected)
            Spacer()
            HStack {
                locationNameText
                starImageIfNotSelectedAndIsFavorite
            }
            Spacer()
            favoriteButton
                .fade(if: !isSelected)
        }
    }

    private var backButton: some View {
        BackButton(isMapOpen: isMapOpen, isEditingNotes: isEditingNotes, onBack: navigateBack)
    }

    private struct BackButton: View {
        let isMapOpen: Bool
        let isEditingNotes: Bool

        let onBack: () -> Void

        var body: some View {
            ZStack {
                Color(.white)
                    .fade(if: !isMapOpen)
                BImage(perform: onBack, image: backButtonImage)
                    .foregroundColor(isMapOpen ? .clear : .white)
            }
            .frame(width: 30, height: 30)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }

        private var backButtonImage: Image {
            Image(systemName: !isEditingNotes ? "arrow.left" : "xmark.circle.fill")
        }
    }

    private func navigateBack() {
        if isMapOpen {
            minimizeMap()
        } else if isEditingNotes {
            resetNoteState()
        } else {
            unselectRow()
        }
    }

    private func minimizeMap() {
        isMapOpen = false
    }

    private func resetNoteState() {
        isEditingNotes = false
        UIApplication.shared.endEditing(true)
        updateNotesInput()
    }

    private func unselectRow() {
        selectedIndex = -1
    }

    private var locationNameText: some View {
        Text(visit.location.name)
            .font(isSelected ? .system(size: 22) : .headline)
            .fontWeight(isSelected ? .bold : .regular)
            .lineLimit(isSelected ? nil : 1)
            .multilineTextAlignment(.center)
            .animation(nil)
    }

    private var starImageIfNotSelectedAndIsFavorite: some View {
        Group {
            if !isSelected && isFavorite {
                Image("star.fill")
                    .foregroundColor(.yellow)
            }
        }
    }

    private var favoriteButton: some View {
        FavoriteButton(isFavorite: $isFavorite, visit: visit)
    }

    private struct FavoriteButton: View {
        @Binding var isFavorite: Bool
        let visit: Visit

        var body: some View {
            BImage(perform: favorite, image: favoriteImage)
                .foregroundColor(.yellow)
        }

        private func favorite() {
            isFavorite = visit.favorite()
        }

        private var favoriteImage: Image {
            isFavorite ? Image("star.fill") : Image("star")
        }
    }
}

private extension VisitDetailsView {
    private var coreDetailsView: some View {
        Group {
            if !isMapOpen && !isEditingNotes {
                visitDurationText
                fullMonthWithDayOfWeekTextIfSelected
                    .padding(.top, isSelected ? 8 : 0)
                    .padding(.bottom, isSelected ? 10 : 0)
                locationTagView
                    .padding(.top, 6)
                    .padding(.bottom, isSelected ? 20 : 4)
            }
        }
    }

    private var visitDurationText: some View {
        Text(visit.visitDuration)
            .font(isSelected ? .system(size: 18) : .system(size: 10))
            .tracking(isSelected ? 2 : 0)
            .animation(nil)
    }

    private var fullMonthWithDayOfWeekTextIfSelected: some View {
        Group {
            if isSelected {
                fullMonthWithDayOfWeekText
            }
        }
    }

    private var fullMonthWithDayOfWeekText: some View {
        Text(visit.arrivalDate.fullMonthWithDayOfWeek.uppercased())
            .font(.caption)
    }

    private var locationTagView: some View {
        TagView(tag: visit.location.tag, displayName: isSelected)
    }
}

private extension VisitDetailsView {
    private var interactableMapViewIfSelected: some View {
        Group {
            if isSelected && !isEditingNotes {
                staticMapView
                    .padding(.bottom, 10)
                VStack(spacing: 16) {
                    locationAddressText
                    mapOptionButtons
                        .fade(if: !isMapOpen)
                        .scaleEffect(isMapOpen ? 1 : 0)
                }
                .padding(.leading, 80)
                .padding(.trailing, 80)
            }
        }
    }

    private var staticMapView: some View {
        StaticMapView(coordinate: visit.location.coordinate, name: visit.location.name, color: .blue)
            .frame(width: isMapOpen ? screen.width : screen.width / 2.5, height: isMapOpen ? screen.height * 8 / 15 : screen.width / 2.5)
            .cornerRadius(isMapOpen ? 0 : screen.width / 5)
            .onTapGesture(perform: toggleMapState)
            .animation(.spring())
    }

    private func toggleMapState() {
        isMapOpen.toggle()
    }

    private var locationAddressText: some View {
        Text(visit.location.address.uppercased())
            .font(.headline)
            .lineLimit(nil)
            .multilineTextAlignment(.center)
            .animation(nil)
    }

    private var mapOptionButtons: some View {
        HStack(spacing: 20) {
            focusLocationOnAnnotatedMapButton
            openAppleMapsButton
        }
    }

    private var focusLocationOnAnnotatedMapButton: some View {
        Button(action: focusLocationOnAnnotatedMap) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 35, height: 35)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func focusLocationOnAnnotatedMap() {
        setActiveVisitLocationAndDisplayMap(visit)
    }

    private var openAppleMapsButton: some View {
        Button(action: openAppleMaps) {
            Image(systemName: "arrow.up.right.diamond")
                .resizable()
                .frame(width: 35, height: 35)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func openAppleMaps() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: visit.location.coordinate, addressDictionary:nil))
        mapItem.name = "Visit Location"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
}

private extension VisitDetailsView {
    private var notesIfSelected: some View {
        Group {
            if isSelected && !isMapOpen {
                notesButton
            }
        }
    }

    private var notesButton: some View {
        Button(action: displayEditNotesView) {
            VStack(spacing: 2) {
                dividerView
                    .padding(.bottom, 20)

                notesHeaderText

                notesContainer

                dividerView
                    .padding(.top, 20)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func displayEditNotesView() {
        isEditingNotes = true
    }

    private var dividerView: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.black)
            .frame(width: isEditingNotes ? screen.width-100 : screen.width/10, height: 3)
    }

    private var notesHeaderText: some View {
        Text("NOTES")
            .font(.system(size: 22))
            .fontWeight(.bold)
            .tracking(2)
    }

    private var notesContainer: some View {
        Group {
            if !isEditingNotes {
                visitNotesTextViewWithDefaultTextIfEmpty
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
            } else {
                notesTextView
                    .frame(width: screen.width-100)
            }
        }
    }

    private var visitNotesTextViewWithDefaultTextIfEmpty: some View {
        Group {
            if !visit.notes.isEmpty {
                visitNotesTextView
            } else {
                emptyNotesText
            }
        }
    }

    private var visitNotesTextView: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                Text(self.visit.notes)
                    .font(.caption)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .frame(
                        minWidth: geometry.size.width,
                        idealWidth: geometry.size.width,
                        maxWidth: geometry.size.width,
                        minHeight: geometry.size.height,
                        idealHeight: geometry.size.height,
                        maxHeight: .infinity,
                        alignment: .top
                )
            }
        }
    }

    private var emptyNotesText: some View {
        Text("TAP TO ADD")
            .font(.caption)
    }

    private var notesTextView: some View {
        AutoResizingTextField(isActive: $isEditingNotes, text: $notesInput, onCommit: commitNoteEdits)
    }

    private func commitNoteEdits() {
        visit.setNotes(notesInput)
        updateNotesInput()
    }
}

private extension VisitDetailsView {
    private func setSelectedVisitIndex() {
        self.selectedIndex = index
    }

    private var exitGestureIfSelected: some Gesture {
        return isSelected ? exitGesture : nil
    }

    private var exitGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard value.translation.height > 0 else { return }
                guard value.translation.height < 100 else { return }
                guard value.translation.width < 100 else { return }

                self.activeTranslation = value.translation
        }
        .onEnded { value in
            if self.activeTranslation.height > 20 || self.activeTranslation.width > 10 {
                self.resetViewState()
            }
            self.resetActiveTranslation()
        }
    }

    private func resetViewState() {
        resetNoteState()
        minimizeMap()
        unselectRow()
    }

    private func resetActiveTranslation() {
        activeTranslation = .zero
    }

    private func setFavoritedStateAndNotesInput() {
        setFavoriteState()
        updateNotesInput()
    }

    private func setFavoriteState() {
        isFavorite = visit.isFavorite
    }

    private func updateNotesInput() {
        notesInput = visit.notes
    }
}

struct VisitDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VisitDetailsView(selectedIndex: .constant(1), index: -1, visit: .preview, setActiveVisitLocationAndDisplayMap: { _ in }).previewLayout(.sizeThatFits)
            
            VisitDetailsView(selectedIndex: .constant(1), index: 1,  visit: .preview, setActiveVisitLocationAndDisplayMap: { _ in })
        }
        .environment(\.appTheme, .violetGum)
    }
}
