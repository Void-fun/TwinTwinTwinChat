import SwiftUI
import SwiftData
import UIKit // Добавляем для UIImpactFeedbackGenerator

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Message.timestamp) private var messages: [Message]
    @State private var newMessage: String = ""
    @State private var showingSidebar = false
    @State private var selectedChat: UUID? // Текущий выбранный чат
    @State private var dragOffset: CGFloat = 0 // Для отслеживания смещения при свайпе

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
                .offset(x: showingSidebar ? (UIScreen.main.bounds.width * 0.7 + dragOffset) : 0) // Сдвигаем основной контент полностью при открытии
                
                // Sidebar
                GeometryReader { geometry in
                    HStack {
                        SidebarView(selectedChat: $selectedChat, showingSidebar: $showingSidebar)
                            .frame(width: geometry.size.width * 0.7)
                            .offset(x: showingSidebar ? dragOffset : -geometry.size.width * 0.7)
                            .animation(.easeInOut, value: showingSidebar)
                        
                        Spacer()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            showingSidebar.toggle()
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred() // Тактильная обратная связь для кнопки
                        }
                    }) {
                        Image(systemName: "sidebar.left")
                    }
                }
            }
            // Добавляем жест свайпа с ограничениями и тактильной обратной связью
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let width = UIScreen.main.bounds.width * 0.7 // Ширина боковой панели
                        if showingSidebar {
                            // Свайп влево для закрытия
                            dragOffset = max(min(value.translation.width, 0), -width)
                        } else if value.translation.width > 0 {
                            // Свайп вправо для открытия
                            dragOffset = min(value.translation.width, width)
                        }
                    }
                    .onEnded { value in
                        withAnimation {
                            let threshold = UIScreen.main.bounds.width * 0.2 // Порог для открытия/закрытия
                            if showingSidebar && value.translation.width < -threshold {
                                showingSidebar = false
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred() // Тактильная обратная связь при закрытии
                            } else if !showingSidebar && value.translation.width > threshold {
                                showingSidebar = true
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred() // Тактильная обратная связь при открытии
                            }
                            dragOffset = 0
                        }
                    }
            )
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
