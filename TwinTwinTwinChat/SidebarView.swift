import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Message.timestamp) private var messages: [Message]
    @Binding var selectedChat: UUID?
    @Binding var showingSidebar: Bool
    
    // Структура для хранения информации о чате
    private struct ChatInfo {
        let id: UUID
        let firstMessageText: String
        let firstMessageTimestamp: Date
    }
    
    // Вычисляемое свойство для получения отсортированного списка чатов
    private var sortedChats: [ChatInfo] {
        // Группируем сообщения по chatID
        let grouped = Dictionary(grouping: messages, by: { $0.chatID })
        
        // Создаем массив ChatInfo с первым сообщением и его временем
        return grouped.map { chatID, messages in
            let firstMessage = messages.min(by: { $0.timestamp < $1.timestamp })!
            return ChatInfo(
                id: chatID,
                firstMessageText: firstMessage.text,
                firstMessageTimestamp: firstMessage.timestamp
            )
        }
        .sorted { $0.firstMessageTimestamp > $1.firstMessageTimestamp } // Сортировка по времени создания
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // New Chat Button
            Button(action: {
                selectedChat = UUID() // Создаем новый chatID
                showingSidebar = false
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Новый чат")
                }
                .padding()
            }
            .foregroundColor(.blue)
            
            // Chat List
            List {
                ForEach(sortedChats, id: \.id) { chat in
                    Button(action: {
                        selectedChat = chat.id
                        showingSidebar = false
                    }) {
                        Text(chat.firstMessageText)
                            .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .background(Color(.systemBackground))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
