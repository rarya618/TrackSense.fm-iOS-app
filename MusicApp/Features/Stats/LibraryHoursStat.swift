struct LibraryHoursStat: View {
    var hours: Int
    
    var days: Int {
        Int(hours / 24)
    }

    var body: some View {
        HStack {
            if (hours == 0) {
                // Loading state
                VStack {
                    ClassicLoadingView(text: "Loading library stats")
                }
            } else {
                VStack (alignment: .leading, spacing: 16) {
                    VStack (alignment: .leading, spacing: 2) {
                        Text(hours.formatted())
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.customPurple)

                        Text("hours of music played")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.customLightPurple)
                    }

                    Text({
                        var s = AttributedString("That’s a bit more than ")
                        var d = AttributedString("\(days.formatted()) days")
                        d.inlinePresentationIntent = .stronglyEmphasized
                        s.append(d)
                        s.append(AttributedString(" worth of music"))
                        return s
                    }())
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.customLightPurple)
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.resonateWhite)
                .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.customPurple.opacity(0.1), lineWidth: 1)
        )
    }
}