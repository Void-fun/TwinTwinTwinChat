import Foundation
import SwiftData

@Model
final class Message: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
    let chatID: UUID // Added to group messages into chats
    
    init(id: UUID = UUID(), text: String, isUser: Bool, timestamp: Date = Date(), chatID: UUID = UUID()) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
        self.chatID = chatID
    }
}
