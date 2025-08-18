import SwiftUI

struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Welcome to the support chat! How are you feeling today?", isUser: false, timestamp: Date().addingTimeInterval(-300)),
        ChatMessage(text: "I'm feeling strong today! 3 days sober!", isUser: true, timestamp: Date().addingTimeInterval(-240)),
        ChatMessage(text: "That's amazing! Keep up the great work. Every day is a victory.", isUser: false, timestamp: Date().addingTimeInterval(-180))
    ]
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                OptimizedBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    chatHeader
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(messages) { message in
                                    messageView(message)
                                        .id(message.id)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) { _ in
                            withAnimation {
                                proxy.scrollTo(messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                    
                    messageInputBar
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var chatHeader: some View {
        VStack(spacing: 5) {
            Text("Support Chat")
                .font(.system(size: isCompact ? 20 : 24, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
            
            Text("You're not alone in this journey")
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(isCompact ? 15 : 20)
        .background(ColorTheme.cardBackground.opacity(0.5))
    }
    
    func messageView(_ message: ChatMessage) -> some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 5) {
                Text(message.text)
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(message.isUser ? .black : ColorTheme.textPrimary)
                    .padding(isCompact ? 12 : 15)
                    .background(
                        message.isUser ?
                        AnyView(ColorTheme.accentCyan) :
                        AnyView(ColorTheme.cardBackground)
                    )
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                message.isUser ? Color.clear : ColorTheme.accentCyan.opacity(0.3),
                                lineWidth: 1
                            )
                    )
                
                Text(timeString(from: message.timestamp))
                    .font(.system(size: isCompact ? 10 : 12))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser { Spacer() }
        }
    }
    
    var messageInputBar: some View {
        HStack(spacing: 10) {
            TextField("Type a message...", text: $messageText)
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textPrimary)
                .accentColor(ColorTheme.accentCyan)
                .padding(isCompact ? 10 : 12)
                .background(ColorTheme.cardBackground)
                .cornerRadius(20)
            
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: isCompact ? 20 : 24))
                    .foregroundColor(messageText.isEmpty ? ColorTheme.textSecondary : ColorTheme.accentCyan)
                    .rotationEffect(.degrees(45))
            }
            .disabled(messageText.isEmpty)
            .frame(width: isCompact ? 44 : 50, height: isCompact ? 44 : 50)
            .background(ColorTheme.cardBackground)
            .cornerRadius(25)
        }
        .padding()
        .background(ColorTheme.cardBackground.opacity(0.5))
    }
    
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        withAnimation {
            messages.append(ChatMessage(text: messageText, isUser: true, timestamp: Date()))
            messageText = ""
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    messages.append(ChatMessage(
                        text: "Thank you for sharing! Remember, every moment sober is a victory worth celebrating.",
                        isUser: false,
                        timestamp: Date()
                    ))
                }
            }
        }
    }
    
    func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
}

#Preview {
    ChatView()
}