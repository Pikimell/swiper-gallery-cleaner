import SwiftUI

struct FAQSectionView: View {
    @Environment(\.theme) private var theme
    @State private var expandedQuestions: Set<Int> = []

    private let faqItemIDs: [Int] = Array(0...6)

    var body: some View {
        Section(header: Text("settings_faq_header".localized)) {
            ForEach(faqItemIDs, id: \.self) { id in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedQuestions.contains(id) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedQuestions.insert(id)
                            } else {
                                expandedQuestions.remove(id)
                            }
                        }
                    )
                ) {
                    Text("faq_a_\(id)".localized)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                } label: {
                    Text("faq_q_\(id)".localized)
                        .font(.subheadline)
                        .foregroundColor(theme.textPrimary)
                }
                .padding(.vertical, 6)
            }
        }
    }
}
