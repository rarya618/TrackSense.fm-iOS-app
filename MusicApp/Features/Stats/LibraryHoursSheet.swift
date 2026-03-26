NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        
                        // MARK: - Chart Card
                        ChartCard(
                            title: "Hours Over Time",
                            cloudData: cloudLibraryPlayedHoursData,
                            hasValueProp: true
                        )

                        // MARK: - Description
                        Text("This chart shows how your total listening hours have changed over time. Data updates when content is synced to the cloud.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 20)
                }
                .foregroundStyle(Color.resonatePurple)
                .background(Color.resonateWhite.ignoresSafeArea())
                .navigationTitle("Cloud History")
                .navigationBarTitleDisplayMode(.inline)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.automatic)
                .presentationCompactAdaptation(.sheet)
            }