struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.bold)
                .foregroundStyle(Color.resonatePurple)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(Color.resonateLightPurple)
        }
        .font(Font.system(size: 16))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}