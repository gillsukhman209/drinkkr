import SwiftUI

struct LibraryView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
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
        LibraryItem(title: "The Science Behind Alcohol Cravings", category: "Articles", duration: "6 min", icon: "doc.text.fill", content: "Understanding why we crave alcohol is the first step to overcoming addiction. When we drink regularly, our brain's reward system becomes hijacked. The neurotransmitter dopamine, which normally helps us feel pleasure from everyday activities, becomes primarily associated with alcohol.\n\nCravings aren't a sign of weakness—they're a normal part of recovery. Your brain has been rewired to expect alcohol, and it takes time to heal. The good news? Every day without alcohol is helping your brain rebuild healthier neural pathways.\n\nCravings typically peak in the first few weeks of sobriety but become less frequent and intense over time. Some triggers include stress, certain places, people, or emotions. The key is recognizing these triggers and having a plan ready."),
        
        LibraryItem(title: "How Alcohol Affects Your Sleep", category: "Articles", duration: "4 min", icon: "doc.text.fill", content: "Many people believe alcohol helps them sleep better, but this is one of the biggest myths about drinking. While alcohol might make you fall asleep faster, it severely disrupts your sleep quality.\n\nAlcohol prevents you from reaching deep, restorative sleep stages. Instead, you spend more time in lighter sleep phases, which is why you wake up feeling tired even after 8 hours. It also acts as a diuretic, causing frequent bathroom trips that interrupt your rest.\n\nWithin just one week of quitting alcohol, most people notice significant improvements in their sleep quality. You'll fall asleep more naturally, stay asleep longer, and wake up feeling genuinely refreshed. This improved sleep then helps with mood, energy, and decision-making throughout the day."),
        
        LibraryItem(title: "The Hidden Costs of Drinking", category: "Articles", duration: "5 min", icon: "doc.text.fill", content: "Beyond the obvious expense of buying alcohol, drinking costs us in ways we rarely calculate. The average person who drinks regularly spends $1,500-$3,000 per year on alcohol alone. But that's just the beginning.\n\nConsider the hidden costs: rideshares instead of driving, expensive bar food, impulse purchases while intoxicated, missed work opportunities due to hangovers, and potential health care costs. Many people discover they were spending 20-30% more than they realized.\n\nThen there are the opportunity costs—time that could have been spent on hobbies, relationships, or personal growth. When you quit drinking, you're not just saving money; you're investing in a better version of yourself. Many people use their 'drinking money' to fund new experiences, travel, or long-term goals."),
        
        // Stories
        LibraryItem(title: "Sarah's 100-Day Journey", category: "Stories", duration: "7 min", icon: "person.fill", content: "I never thought I had a 'drinking problem.' I was a successful marketing manager, had great friends, and drank 'normally'—just a glass or two of wine every night to unwind. But those glasses kept getting bigger, and the nights I didn't drink became rare.\n\nThe turning point came after a work presentation where I was noticeably hungover. My boss didn't say anything, but I saw the look. That night, I committed to 100 days without alcohol, just to prove to myself I could do it.\n\nThe first week was brutal. I felt anxious and couldn't figure out how to relax without wine. But by week three, something shifted. I was sleeping better, had more energy, and actually started enjoying my evenings. I rediscovered reading, tried cooking new recipes, and had deeper conversations with friends.\n\nDay 100 came and went. I realized I didn't want to go back. Today, I'm approaching two years alcohol-free, and my life is fuller and more vibrant than I ever imagined possible."),
        
        LibraryItem(title: "From Rock Bottom to Recovery", category: "Stories", duration: "8 min", icon: "person.fill", content: "My name is Mike, and I lost everything to alcohol before I found everything in sobriety. By age 35, I had lost my job, my marriage, and nearly lost my relationship with my kids. I was drinking from morning until night, lying to everyone including myself.\n\nThe wake-up call came when my 8-year-old daughter asked my ex-wife, 'Why does daddy always smell funny?' That question shattered me. I realized my kids would grow up remembering me as the dad who was never really present.\n\nI checked into rehab the next week. It was the hardest thing I'd ever done, but also the beginning of getting my life back. The first six months were a daily struggle, but I had counseling, AA meetings, and slowly rebuilt trust with my family.\n\nToday, three years later, I have a new career I love, a healthy relationship with my children, and genuine happiness. Sobriety didn't just save my life—it gave me a life worth living. If someone like me can turn it around, anyone can."),
        
        LibraryItem(title: "The Social Butterfly's Dilemma", category: "Stories", duration: "6 min", icon: "person.fill", content: "As someone whose entire social life revolved around bars and wine tastings, quitting alcohol felt like social suicide. I was the friend who organized happy hours and knew every bartender in town. How could I maintain friendships without our shared drinking culture?\n\nThe first few months were lonely, I won't lie. Some friends didn't understand my choice and gradually faded away. But something beautiful happened—I discovered who my real friends were. The ones who truly cared about me supported my decision and found new ways to spend time together.\n\nI started hosting morning hikes instead of evening drinks. We tried cooking classes, art museums, and coffee shop conversations that went deeper than our alcohol-fueled chats ever had. I also found an amazing community of sober people who were fun, adventurous, and living their best lives.\n\nNow I realize that alcohol wasn't enhancing my social life—it was limiting it. Sober socializing is more authentic, memorable, and fulfilling than anything I experienced while drinking."),
        
        LibraryItem(title: "Breaking the Family Cycle", category: "Stories", duration: "9 min", icon: "person.fill", content: "Alcoholism runs in my family like a river. My grandfather, my father, and two of my uncles all struggled with drinking. Growing up, I swore I'd be different. Yet by my late twenties, I found myself following the same path.\n\nI tried to convince myself that because I held down a job and paid my bills, I was fine. But inside, I knew I was using alcohol the same way my family had—to numb emotions, avoid problems, and escape reality. The genetic predisposition was real, but so was my power to choose differently.\n\nDeciding to get sober felt like breaking a generational curse. My family didn't understand at first. Some even took it as judgment of their choices. But I stayed committed to my path, knowing I was not just changing my life but potentially influencing the next generation.\n\nMy young nephew recently told me I'm his 'coolest uncle' because I'm always present and fun without needing drinks. That moment made every difficult day of sobriety worth it. I'm not just sober—I'm the one who broke the cycle."),
        
        // Tips
        LibraryItem(title: "Managing Social Situations", category: "Tips", duration: "5 min", icon: "lightbulb.fill", content: "Social events can be challenging in early sobriety, but with the right strategies, you can enjoy them even more than before:\n\n• Always have an exit plan. Drive yourself or arrange alternative transportation so you can leave if you feel uncomfortable.\n\n• Bring your own non-alcoholic drinks. Fancy sparkling water in a wine glass looks festive and keeps your hands occupied.\n\n• Practice your responses. 'I'm not drinking tonight' is usually enough. You don't owe anyone a detailed explanation.\n\n• Find the other non-drinkers. They're often there and happy to have someone to talk to who's also sober.\n\n• Volunteer to be the designated driver. This gives you a clear reason for not drinking and makes you the hero of the group.\n\n• Leave early if needed. It's better to preserve your sobriety than to stay and struggle.\n\nRemember: most people are too focused on themselves to care much about what you're drinking."),
        
        LibraryItem(title: "Building New Evening Routines", category: "Tips", duration: "4 min", icon: "lightbulb.fill", content: "If you used to drink in the evenings, you'll need to rebuild this time period. Here are proven strategies:\n\n• Create a 'closing ceremony' for your workday. This could be a walk, journaling, or changing clothes to signal the transition.\n\n• Keep your hands and mind busy. Try puzzles, knitting, drawing, or learning a musical instrument.\n\n• Establish a tea or coffee ritual. The ceremony of preparation can be as satisfying as a cocktail routine.\n\n• Exercise in the evening. Even light yoga or stretching can shift your energy and mood positively.\n\n• Plan evening activities outside your home. Classes, volunteer work, or social events keep you engaged.\n\n• Batch cook or meal prep. It's productive and keeps you busy during traditional 'drinking hours.'\n\n• Call a friend or family member. Deepening relationships fills the social aspect that alcohol used to provide.\n\nThe key is having a plan before the urge hits."),
        
        LibraryItem(title: "Dealing with Triggers", category: "Tips", duration: "6 min", icon: "lightbulb.fill", content: "Triggers are situations, emotions, or environments that make you want to drink. Here's how to handle them:\n\n• Identify your personal triggers. Common ones include stress, loneliness, celebration, and certain social situations.\n\n• Use the HALT method. Ask yourself: Am I Hungry, Angry, Lonely, or Tired? Address the real need behind the craving.\n\n• Practice the 20-minute rule. Cravings typically peak and pass within 20 minutes. Distract yourself until it passes.\n\n• Change your environment immediately. If you're triggered at home, go for a walk. If you're out, move to a different area.\n\n• Call your support network. Having someone to talk to can instantly shift your mindset.\n\n• Use grounding techniques. Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste.\n\n• Remember your 'why.' Keep a list on your phone of reasons you quit drinking to review during difficult moments.\n\nTriggers don't disappear, but your response to them becomes automatic with practice."),
        
        LibraryItem(title: "Creating Accountability Systems", category: "Tips", duration: "5 min", icon: "lightbulb.fill", content: "Accountability is crucial for long-term sobriety success. Here's how to build strong support systems:\n\n• Find an accountability partner. This could be a friend, family member, or fellow person in recovery who checks in regularly.\n\n• Join support groups, either in-person or online. Regular meetings provide structure and community.\n\n• Use sobriety apps to track your progress and connect with others on similar journeys.\n\n• Be open with trusted friends and family about your goals. Hiding your sobriety makes it harder to maintain.\n\n• Set up regular check-ins. Weekly coffee dates or phone calls create consistent touchpoints.\n\n• Find a mentor or sponsor who has longer-term sobriety and can provide guidance.\n\n• Consider professional counseling. Therapists specializing in addiction provide expert support.\n\n• Create visible reminders of your commitment, like photos of your goals or motivational quotes.\n\nRemember: asking for help isn't weakness—it's the smartest strategy for success."),
        
        LibraryItem(title: "Handling Slip-Ups and Setbacks", category: "Tips", duration: "4 min", icon: "lightbulb.fill", content: "If you slip up, remember that recovery is a process, not perfection. Here's how to bounce back:\n\n• Don't let one drink become a week-long bender. The moment you realize you've slipped, stop and recommit immediately.\n\n• Avoid all-or-nothing thinking. One mistake doesn't erase all your previous progress or mean you're a failure.\n\n• Analyze what led to the slip without judgment. What triggered it? What could you do differently next time?\n\n• Reach out for support immediately. Don't isolate yourself in shame—that's when slips turn into relapses.\n\n• Reset your counter if it helps, but don't discount your previous sober time. That experience and growth still count.\n\n• Adjust your strategy based on what you learned. Maybe you need more support, different activities, or to avoid certain situations.\n\n• Practice self-compassion. Treat yourself with the same kindness you'd show a good friend facing the same challenge.\n\n• Get back to your routine as quickly as possible. Don't wait for Monday or next month—start again now.\n\nSlips are learning opportunities, not failures."),
        
        LibraryItem(title: "Rediscovering Your Interests", category: "Tips", duration: "5 min", icon: "lightbulb.fill", content: "Sobriety gives you time and mental clarity to rediscover who you are beyond drinking. Here's how to explore:\n\n• Think back to childhood interests. What did you love before alcohol became a focus? Reconnect with those activities.\n\n• Try the 'yes experiment.' Say yes to invitations and opportunities you'd normally decline. You might discover new passions.\n\n• Take classes or workshops. Community colleges, community centers, and online platforms offer endless learning opportunities.\n\n• Volunteer for causes you care about. It's fulfilling, social, and helps you see beyond your own challenges.\n\n• Start creative projects. Write, paint, make music, or craft. Creation is therapeutic and builds confidence.\n\n• Explore nature. Hiking, gardening, or just spending time outdoors can be profoundly healing and inspiring.\n\n• Learn a skill you've always wanted. Cooking, languages, coding, or any new competency builds self-esteem.\n\n• Document your journey. Writing, photography, or video journaling helps process your transformation.\n\nSobriety isn't about losing something—it's about finding everything you've been missing.")
    ]
    
    var filteredItems: [LibraryItem] {
        libraryItems.filter { item in
            (selectedCategory == "All" || item.category == selectedCategory) &&
            (searchText.isEmpty || item.title.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationView {
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
                                    contentToShow = item
                                    showingContent = true
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
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            hasAppeared = true
        }
        .sheet(isPresented: $showingContent, onDismiss: {
            contentToShow = nil
        }) {
            if let item = contentToShow {
                ContentDetailView(item: item, isPresented: $showingContent)
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
        .background(ColorTheme.cardBackground)
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
                    AnyView(ColorTheme.cardBackground)
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
                .background(ColorTheme.accentPurple.opacity(0.2))
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