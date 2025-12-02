import SwiftUI

struct LibraryView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var dataService: DataService
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var showingContent = false
    @State private var hasAppeared = false
    @State private var contentToShow: LibraryItem?
    
    let categories = ["All", "Articles", "Stories", "Tips"]
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    let libraryItems = [
        // Articles
        LibraryItem(title: "The Science Behind Food Cravings", category: "Articles", duration: "6 min", icon: "doc.text.fill", content: "Understanding why we crave junk food is the first step to overcoming addiction. When we eat processed foods regularly, our brain's reward system becomes hijacked. The neurotransmitter dopamine, which normally helps us feel pleasure from everyday activities, becomes primarily associated with sugar and fat.\n\nCravings aren't a sign of weakness—they're a normal part of recovery. Your brain has been rewired to expect high-calorie rewards, and it takes time to heal. The good news? Every day without fast food is helping your brain rebuild healthier neural pathways.\n\nCravings typically peak in the first few weeks of clean eating but become less frequent and intense over time. Some triggers include stress, certain places, people, or emotions. The key is recognizing these triggers and having a plan ready."),
        
        LibraryItem(title: "How Fast Food Affects Your Sleep", category: "Articles", duration: "4 min", icon: "doc.text.fill", content: "Many people believe a heavy meal helps them sleep better, but this is one of the biggest myths. While a 'food coma' might make you fall asleep faster, it severely disrupts your sleep quality.\n\nHeavy, greasy foods prevent you from reaching deep, restorative sleep stages. Instead, your body works overtime to digest, keeping your core temperature high and causing restlessness. This is why you wake up feeling groggy even after 8 hours.\n\nWithin just one week of quitting late-night fast food, most people notice significant improvements in their sleep quality. You'll fall asleep more naturally, stay asleep longer, and wake up feeling genuinely refreshed. This improved sleep then helps with mood, energy, and decision-making throughout the day."),
        
        LibraryItem(title: "The Hidden Costs of Fast Food", category: "Articles", duration: "5 min", icon: "doc.text.fill", content: "Beyond the obvious expense of buying meals, fast food costs us in ways we rarely calculate. The average person who eats out regularly spends $3,000-$5,000 per year on takeout alone. But that's just the beginning.\n\nConsider the hidden costs: delivery fees, impulse add-ons, wasted groceries at home, potential medical costs for diet-related issues, and the cost of larger clothes. Many people discover they were spending 20-30% more than they realized.\n\nThen there are the opportunity costs—energy that could have been spent on hobbies, relationships, or personal growth. When you quit fast food, you're not just saving money; you're investing in a better version of yourself. Many people use their 'takeout money' to fund new experiences, travel, or long-term goals."),
        
        // Stories
        LibraryItem(title: "Sarah's 100-Day Journey", category: "Stories", duration: "7 min", icon: "person.fill", content: "I never thought I had a 'food problem.' I was a successful marketing manager, had great friends, and ate 'normally'—just takeout for dinner every night to unwind. But the orders kept getting bigger, and the nights I cooked became rare.\n\nThe turning point came after a work presentation where I felt noticeably sluggish and bloated. My boss didn't say anything, but I felt off. That night, I committed to 100 days without fast food, just to prove to myself I could do it.\n\nThe first week was brutal. I felt anxious and couldn't figure out what to eat quickly. But by week three, something shifted. I was sleeping better, had more energy, and actually started enjoying cooking. I rediscovered recipes, tried new vegetables, and had deeper conversations with friends over home-cooked meals.\n\nDay 100 came and went. I realized I didn't want to go back. Today, I'm approaching two years fast-food-free, and my life is fuller and more vibrant than I ever imagined possible."),
        
        LibraryItem(title: "From Rock Bottom to Recovery", category: "Stories", duration: "8 min", icon: "person.fill", content: "My name is Mike, and I lost my health to food addiction before I found everything in clean eating. By age 35, I was pre-diabetic, had high blood pressure, and couldn't keep up with my kids. I was eating from morning until night, hiding wrappers from everyone including myself.\n\nThe wake-up call came when my 8-year-old daughter asked my ex-wife, 'Why is daddy always tired?' That question shattered me. I realized my kids would grow up remembering me as the dad who couldn't play with them.\n\nI started a program the next week. It was the hardest thing I'd ever done, but also the beginning of getting my life back. The first six months were a daily struggle, but I had counseling, support groups, and slowly rebuilt my health.\n\nToday, three years later, I have a new energy I love, a healthy relationship with my children, and genuine happiness. Clean eating didn't just save my life—it gave me a life worth living. If someone like me can turn it around, anyone can."),
        
        LibraryItem(title: "The Foodie's Dilemma", category: "Stories", duration: "6 min", icon: "person.fill", content: "As someone whose entire social life revolved around trying new burger joints and food trucks, quitting fast food felt like social suicide. I was the friend who knew every menu in town. How could I maintain friendships without our shared food culture?\n\nThe first few months were lonely, I won't lie. Some friends didn't understand my choice. But something beautiful happened—I discovered who my real friends were. The ones who truly cared about me supported my decision and found new ways to spend time together.\n\nI started hosting potlucks instead of takeout nights. We tried cooking classes, farmers markets, and coffee shop conversations that went deeper than our food-focused chats ever had. I also found an amazing community of healthy eaters who were fun, adventurous, and living their best lives.\n\nNow I realize that junk food wasn't enhancing my social life—it was limiting it. Healthy socializing is more authentic, memorable, and fulfilling than anything I experienced while binge eating."),
        
        LibraryItem(title: "Breaking the Family Cycle", category: "Stories", duration: "9 min", icon: "person.fill", content: "Poor eating habits run in my family like a river. My grandfather, my father, and two of my uncles all struggled with obesity and heart issues. Growing up, I swore I'd be different. Yet by my late twenties, I found myself following the same path.\n\nI tried to convince myself that because I held down a job, I was fine. But inside, I knew I was using food the same way my family had—to numb emotions, avoid problems, and escape reality. The genetic predisposition was real, but so was my power to choose differently.\n\nDeciding to eat clean felt like breaking a generational curse. My family didn't understand at first. Some even took it as judgment of their choices. But I stayed committed to my path, knowing I was not just changing my life but potentially influencing the next generation.\n\nMy young nephew recently told me I'm his 'coolest uncle' because I'm always energetic and fun without needing to rest. That moment made every difficult day of clean eating worth it. I'm not just healthy—I'm the one who broke the cycle."),
        
        // Tips
        LibraryItem(title: "Managing Social Situations", category: "Tips", duration: "5 min", icon: "lightbulb.fill", content: "Social events can be challenging in early clean eating, but with the right strategies, you can enjoy them even more than before:\n\n• Always have an exit plan. Drive yourself or arrange alternative transportation so you can leave if you feel uncomfortable.\n\n• Bring your own healthy snacks. Nuts, fruit, or a protein bar keeps your hands occupied and hunger at bay.\n\n• Practice your responses. 'I'm eating healthy right now' is usually enough. You don't owe anyone a detailed explanation.\n\n• Find the other healthy eaters. They're often there and happy to have someone to talk to who's also mindful.\n\n• Volunteer to pick the restaurant. This gives you control over the menu options and ensures there's something you can eat.\n\n• Leave early if needed. It's better to preserve your progress than to stay and struggle.\n\nRemember: most people are too focused on themselves to care much about what you're eating."),
        
        LibraryItem(title: "Building New Evening Routines", category: "Tips", duration: "4 min", icon: "lightbulb.fill", content: "If you used to snack in the evenings, you'll need to rebuild this time period. Here are proven strategies:\n\n• Create a 'closing ceremony' for your kitchen. Clean up, turn off the lights, and signal that eating time is over.\n\n• Keep your hands and mind busy. Try puzzles, knitting, drawing, or learning a musical instrument.\n\n• Establish a tea ritual. The ceremony of preparation can be as satisfying as a snack routine.\n\n• Exercise in the evening. Even light yoga or stretching can shift your energy and mood positively.\n\n• Plan evening activities outside the kitchen. Reading in a different room keeps you away from temptation.\n\n• Meal prep for tomorrow. It's productive and keeps you focused on healthy choices.\n\n• Call a friend or family member. Deepening relationships fills the void that food used to fill.\n\nThe key is having a plan before the urge hits."),
        
        LibraryItem(title: "Dealing with Triggers", category: "Tips", duration: "6 min", icon: "lightbulb.fill", content: "Triggers are situations, emotions, or environments that make you want to binge. Here's how to handle them:\n\n• Identify your personal triggers. Common ones include stress, loneliness, celebration, and certain social situations.\n\n• Use the HALT method. Ask yourself: Am I Hungry, Angry, Lonely, or Tired? Address the real need behind the craving.\n\n• Practice the 20-minute rule. Cravings typically peak and pass within 20 minutes. Distract yourself until it passes.\n\n• Change your environment immediately. If you're triggered at home, go for a walk. If you're out, move to a different area.\n\n• Call your support network. Having someone to talk to can instantly shift your mindset.\n\n• Use grounding techniques. Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste.\n\n• Remember your 'why.' Keep a list on your phone of reasons you quit junk food to review during difficult moments.\n\nTriggers don't disappear, but your response to them becomes automatic with practice."),
        
        LibraryItem(title: "Creating Accountability Systems", category: "Tips", duration: "5 min", icon: "lightbulb.fill", content: "Accountability is crucial for long-term success. Here's how to build strong support systems:\n\n• Find an accountability partner. This could be a friend, family member, or fellow person on a health journey who checks in regularly.\n\n• Join support groups, either in-person or online. Regular meetings provide structure and community.\n\n• Use apps to track your progress and connect with others on similar journeys.\n\n• Be open with trusted friends and family about your goals. Hiding your diet makes it harder to maintain.\n\n• Set up regular check-ins. Weekly coffee dates or phone calls create consistent touchpoints.\n\n• Find a mentor or coach who has experience and can provide guidance.\n\n• Consider professional counseling. Therapists specializing in food relationships provide expert support.\n\n• Create visible reminders of your commitment, like photos of your goals or motivational quotes.\n\nRemember: asking for help isn't weakness—it's the smartest strategy for success."),
        
        LibraryItem(title: "Handling Slip-Ups and Setbacks", category: "Tips", duration: "4 min", icon: "lightbulb.fill", content: "If you slip up, remember that healthy living is a process, not perfection. Here's how to bounce back:\n\n• Don't let one cheat meal become a week-long binge. The moment you realize you've slipped, stop and recommit immediately.\n\n• Avoid all-or-nothing thinking. One mistake doesn't erase all your previous progress or mean you're a failure.\n\n• Analyze what led to the slip without judgment. What triggered it? What could you do differently next time?\n\n• Reach out for support immediately. Don't isolate yourself in shame—that's when slips turn into relapses.\n\n• Reset your counter if it helps, but don't discount your previous clean time. That experience and growth still count.\n\n• Adjust your strategy based on what you learned. Maybe you need more support, different activities, or to avoid certain situations.\n\n• Practice self-compassion. Treat yourself with the same kindness you'd show a good friend facing the same challenge.\n\n• Get back to your routine as quickly as possible. Don't wait for Monday or next month—start again now.\n\nSlips are learning opportunities, not failures."),
        
        LibraryItem(title: "Rediscovering Your Interests", category: "Tips", duration: "5 min", icon: "lightbulb.fill", content: "Clean eating gives you time and mental clarity to rediscover who you are beyond food. Here's how to explore:\n\n• Think back to childhood interests. What did you love before food became a focus? Reconnect with those activities.\n\n• Try the 'yes experiment.' Say yes to invitations and opportunities you'd normally decline. You might discover new passions.\n\n• Take classes or workshops. Community colleges, community centers, and online platforms offer endless learning opportunities.\n\n• Volunteer for causes you care about. It's fulfilling, social, and helps you see beyond your own challenges.\n\n• Start creative projects. Write, paint, make music, or craft. Creation is therapeutic and builds confidence.\n\n• Explore nature. Hiking, gardening, or just spending time outdoors can be profoundly healing and inspiring.\n\n• Learn a skill you've always wanted. Cooking, languages, coding, or any new competency builds self-esteem.\n\n• Document your journey. Writing, photography, or video journaling helps process your transformation.\n\nClean eating isn't about losing something—it's about finding everything you've been missing.")
    ]
    
    var filteredItems: [LibraryItem] {
        libraryItems.filter { item in
            (selectedCategory == "All" || item.category == selectedCategory) &&
            (searchText.isEmpty || item.title.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        ZStack {
                OptimizedBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    searchBar
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    categoryPicker
                        .padding(.vertical, 10)
                    
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredItems, id: \.id) { item in
                                Button(action: {
                                    // Ensure content is set before showing sheet
                                    contentToShow = item
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        showingContent = true
                                    }
                                }) {
                                    libraryItemCard(item)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("\(dataService.currentUser?.name ?? "Your") Learning")
            .navigationBarTitleDisplayMode(.large)
        .onAppear {
            hasAppeared = true
        }
        .sheet(isPresented: $showingContent, onDismiss: {
            // Clean up state when sheet is dismissed
            contentToShow = nil
        }) {
            if let item = contentToShow {
                ContentDetailView(item: item, isPresented: $showingContent)
            } else {
                // Fallback loading view
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                    Text("Loading content...")
                        .foregroundColor(ColorTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(ColorTheme.backgroundGradient)
                .onAppear {
                    // If we somehow got here without content, dismiss the sheet
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        if contentToShow == nil {
                            showingContent = false
                        }
                    }
                }
            }
        }
    }
    
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ColorTheme.textSecondary)
            
            TextField("Search learning content...", text: $searchText)
                .foregroundColor(ColorTheme.textPrimary)
                .accentColor(ColorTheme.accentCyan)
        }
        .padding(12)
        .background(Color.white.opacity(0.04))
        .cornerRadius(10)
    }
    
    var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    categoryChip(category)
                }
            }
            .padding(.horizontal)
        }
    }
    
    func categoryChip(_ category: String) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedCategory = category
            }
        }) {
            Text(category)
                .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                .foregroundColor(selectedCategory == category ? .black : ColorTheme.textPrimary)
                .padding(.horizontal, isCompact ? 16 : 20)
                .padding(.vertical, isCompact ? 8 : 10)
                .background(
                    selectedCategory == category ?
                    AnyView(ColorTheme.accentCyan) :
                    AnyView(Color.white.opacity(0.03))
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selectedCategory == category ? Color.clear : ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func libraryItemCard(_ item: LibraryItem) -> some View {
        HStack(spacing: 15) {
            Image(systemName: item.icon)
                .font(.system(size: isCompact ? 24 : 28))
                .foregroundColor(ColorTheme.accentPurple)
                .frame(width: isCompact ? 50 : 60, height: isCompact ? 50 : 60)
                .background(ColorTheme.accentPurple.opacity(0.1))
                .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                    .foregroundColor(ColorTheme.textPrimary)
                    .lineLimit(2)
                
                HStack {
                    Text(item.category)
                        .font(.system(size: isCompact ? 12 : 14))
                        .foregroundColor(ColorTheme.accentCyan)
                    
                    Text("•")
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Text(item.duration)
                        .font(.system(size: isCompact ? 12 : 14))
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
        }
        .padding(isCompact ? 15 : 20)
        .futuristicCard()
    }
}

struct LibraryItem: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let duration: String
    let icon: String
    let content: String
}

#Preview {
    LibraryView()
}