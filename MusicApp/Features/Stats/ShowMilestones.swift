struct ShowMilestones: View {
    let title: String
    var milestoneData: [Int: Int]
    
    let color: Color = .customPurple

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)

            DonutChartView(data: milestoneData)
                .frame(height: 160)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(milestoneData.keys.sorted(by: >), id: \.self) { threshold in
                    let count = milestoneData[threshold, default: 0]
                    let achieved = count > 0

                    HStack(spacing: 8) {
                        Image(systemName: achieved ? "trophy.fill" : "trophy")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(achieved ? color : .gray)

                        VStack(spacing: 2) {
                            Text(threshold >= 1000 ? "≥ \(threshold/1000)k plays" : "≥ \(threshold) plays")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text("\(count)")
                                .font(.headline.bold())
                                .foregroundStyle(achieved ? color : .gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: .infinity)
                            .fill(
                                achieved
                                ? color.opacity(0.1)
                                : Color.gray.opacity(0.05)
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: .infinity)
                            .strokeBorder(
                                achieved ? color.opacity(0.25) : Color.gray.opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .animation(.easeInOut(duration: 0.25), value: achieved)
                }
            }
        }
    }
}
