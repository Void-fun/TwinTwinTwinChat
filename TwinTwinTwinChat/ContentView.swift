import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Message.timestamp) private var messages: [Message]
    @State private var newMessage: String = ""
    @State private var showingSidebar = false
    @State private var selectedChat: UUID? // Текущий выбранный чат
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main chat view
                VStack {
                    if let selectedChat = selectedChat {
                        List(messages.filter { $0.chatID == selectedChat }) { message in
                            MessageRow(message: message)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    } else {
                        Text("Начните новый чат")
                            .foregroundColor(.gray)
                            .frame(maxHeight: .infinity)
                    }
                    
                    HStack {
                        TextField("Введите сообщение...", text: $newMessage)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: sendMessage) {
                            Text("Отправить")
                        }
                        .padding(.leading, 5)
                    }
                    .padding()
                }
                
                // Sidebar
                GeometryReader { geometry in
                    HStack {
                        SidebarView(selectedChat: $selectedChat, showingSidebar: $showingSidebar)
                            .frame(width: geometry.size.width * 0.7)
                            .offset(x: showingSidebar ? 0 : -geometry.size.width * 0.7)
                            .animation(.easeInOut, value: showingSidebar)
                        
                        Spacer()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSidebar.toggle()
                    }) {
                        Image(systemName: "sidebar.left")
                    }
                }
            }
        }
    }
    
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        let chatID = selectedChat ?? UUID() // Если чат не выбран, создаем новый
        let message = Message(text: newMessage, isUser: true, chatID: chatID)
        modelContext.insert(message)
        let messageAnswer = Message(text: newMessage, isUser: false, chatID: chatID)
        modelContext.insert(messageAnswer)
        newMessage = ""
        selectedChat = chatID // Устанавливаем текущий чат
    }
}
