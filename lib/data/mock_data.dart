class AppUser {
  final String name;
  final String email;
  final String gender;
  final int age;
  final String status;
  final String joined;
  final int likes;
  final int downvotes;
  final int karma;
  final int dailyRank;
  final String profileId;
  final String phone;
  final String mode; 
  final List<int> karmaHistory;

  const AppUser({
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.status,
    required this.joined,
    required this.likes,
    required this.downvotes,
    required this.karma,
    required this.dailyRank,
    required this.profileId,
    required this.phone,
    required this.mode,
    required this.karmaHistory,
  });
}

class ReportRecord {
  final int id;
  final String reporter;
  final String reported;
  final String category;
  final String mode; 
  final String detail;
  final String submittedAgo;

  const ReportRecord({
    required this.id,
    required this.reporter,
    required this.reported,
    required this.category,
    required this.mode,
    required this.detail,
    required this.submittedAgo,
  });
}

class VerificationRecord {
  final int id;
  final String name;
  final String submittedAgo;
  final String profileIdLabel;

  const VerificationRecord({
    required this.id,
    required this.name,
    required this.submittedAgo,
    required this.profileIdLabel,
  });
}

class TicketRecord {
  final int id;
  final String user;
  final String subject;
  final String category;
  final String priority;
  final String status;
  final String updatedAgo;

  const TicketRecord({
    required this.id,
    required this.user,
    required this.subject,
    required this.category,
    required this.priority,
    required this.status,
    required this.updatedAgo,
  });
}

class MatchPair {
  final String userA;
  final String userB;
  final String matchedOn;
  final String status;

  const MatchPair({
    required this.userA,
    required this.userB,
    required this.matchedOn,
    required this.status,
  });
}

class ChatThread {
  final String participants;
  final String lastMessage;
  final String time;
  final int unread;

  const ChatThread({
    required this.participants,
    required this.lastMessage,
    required this.time,
    required this.unread,
  });
}

class SubscriptionRow {
  final String user;
  final String plan;
  final String renews;
  final String amount;
  final String status;

  const SubscriptionRow({
    required this.user,
    required this.plan,
    required this.renews,
    required this.amount,
    required this.status,
  });
}

class ActivityEvent {
  final String name;
  final String action;
  final IconIdentifier icon;

  const ActivityEvent(this.name, this.action, this.icon);
}

enum IconIdentifier { like, match, message, join, upload }

class LocationStat {
  final String country;
  final int users;
  final double percent;

  const LocationStat(this.country, this.users, this.percent);
}

class VerificationRequest {
  final String name;
  final String submittedAgo;
  final int documentCount;

  const VerificationRequest(this.name, this.submittedAgo, this.documentCount);
}

class NewSignup {
  final String name;
  final String email;
  final String timeAgo;

  const NewSignup(this.name, this.email, this.timeAgo);
}

class MockData {
  MockData._();

  static const totalUsers = 98442;
  static const activeToday = 5822;
  static const newSignups = 1256;
  static const reportsCount = 63;
  static const revenue = 12450;
  static const onlineNow = 312;

  static const userGrowthTotal = <double>[
    62, 68, 74, 79, 83, 86, 88, 90, 92, 93, 95, 96, 97, 98.4,
  ];
  static const userGrowthNew = <double>[
    8, 10, 12, 14, 15, 17, 18, 19, 20, 21, 22, 23, 24, 24.8,
  ];

  static const genderMale = 68;
  static const genderFemale = 30;
  static const genderOther = 2;
  static const maleUsers = 66953;
  static const femaleUsers = 29570;
  static const otherUsers = 1955;

  static const liveActivity = <ActivityEvent>[
    ActivityEvent('Emma Watson', 'liked your profile', IconIdentifier.like),
    ActivityEvent('Liam Carter', 'matched with Olivia', IconIdentifier.match),
    ActivityEvent('Noah Bennett', 'sent a message', IconIdentifier.message),
    ActivityEvent('Sophia Turner', 'joined RightONE', IconIdentifier.join),
    ActivityEvent('James Wilson', 'uploaded a photo', IconIdentifier.upload),
  ];

  static const newSignupsRecent = <NewSignup>[
    NewSignup('Olivia Rhye', 'olivia@example.com', '2m ago'),
    NewSignup('Liam Parker', 'liam@example.com', '8m ago'),
    NewSignup('Ava Martinez', 'ava@example.com', '12m ago'),
    NewSignup('Ethan Harper', 'ethan@example.com', '18m ago'),
  ];

  static const pendingVerifications = <VerificationRequest>[
    VerificationRequest('Jacob Jones', '2h ago', 2),
    VerificationRequest('Isabella Clark', '5h ago', 2),
    VerificationRequest('Mason White', '8h ago', 2),
    VerificationRequest('Charlotte Brown', '12h ago', 2),
  ];

  static const topLocations = <LocationStat>[
    LocationStat('United States', 24531, 24.9),
    LocationStat('India', 18652, 18.9),
    LocationStat('United Kingdom', 7821, 7.9),
    LocationStat('Canada', 5642, 5.7),
  ];


  static const users = <AppUser>[
    AppUser(name: 'Ava Thompson', email: 'ava.t@mail.com', gender: 'Female', age: 26, status: 'Active', joined: 'Jul 28, 2026', likes: 482, downvotes: 6, karma: 96, dailyRank: 1, profileId: 'RO-100482', phone: '+1 415 555 0182', mode: 'Dating', karmaHistory: [78, 82, 85, 88, 90, 93, 96]),
    AppUser(name: 'Liam Carter', email: 'liam.c@mail.com', gender: 'Male', age: 29, status: 'Active', joined: 'Jul 27, 2026', likes: 411, downvotes: 12, karma: 89, dailyRank: 2, profileId: 'RO-100411', phone: '+1 415 555 0119', mode: 'Both', karmaHistory: [70, 74, 77, 80, 83, 86, 89]),
    AppUser(name: 'Sofia Rossi', email: 'sofia.r@mail.com', gender: 'Female', age: 24, status: 'Pending', joined: 'Jul 26, 2026', likes: 356, downvotes: 4, karma: 93, dailyRank: 3, profileId: 'RO-100356', phone: '+39 351 555 0344', mode: 'Dating', karmaHistory: [80, 84, 86, 88, 90, 91, 93]),
    AppUser(name: 'Noah Williams', email: 'noah.w@mail.com', gender: 'Male', age: 31, status: 'Active', joined: 'Jul 25, 2026', likes: 298, downvotes: 21, karma: 74, dailyRank: 4, profileId: 'RO-100298', phone: '+1 212 555 0173', mode: 'Friends', karmaHistory: [60, 63, 66, 69, 71, 72, 74]),
    AppUser(name: 'Mia Chen', email: 'mia.c@mail.com', gender: 'Female', age: 27, status: 'Suspended', joined: 'Jul 22, 2026', likes: 145, downvotes: 38, karma: 41, dailyRank: 6, profileId: 'RO-100145', phone: '+1 628 555 0221', mode: 'Dating', karmaHistory: [58, 54, 50, 47, 45, 43, 41]),
    AppUser(name: 'Ethan Brooks', email: 'ethan.b@mail.com', gender: 'Male', age: 28, status: 'Active', joined: 'Jul 20, 2026', likes: 264, downvotes: 9, karma: 87, dailyRank: 5, profileId: 'RO-100264', phone: '+1 646 555 0167', mode: 'Both', karmaHistory: [72, 76, 79, 81, 83, 85, 87]),
    AppUser(name: 'Isabella Kim', email: 'isabella.k@mail.com', gender: 'Female', age: 23, status: 'Active', joined: 'Jul 18, 2026', likes: 203, downvotes: 7, karma: 91, dailyRank: 7, profileId: 'RO-100203', phone: '+1 917 555 0198', mode: 'Friends', karmaHistory: [79, 82, 84, 86, 88, 90, 91]),
  ];

  static const reports = <ReportRecord>[
    ReportRecord(id: 1, reporter: 'Ava Thompson', reported: 'Mia Chen', category: 'Inappropriate photo', mode: 'Dating', detail: 'Photo violates content guidelines.', submittedAgo: '25m ago'),
    ReportRecord(id: 2, reporter: 'Noah Williams', reported: 'Unknown Profile', category: 'Fake profile', mode: 'Friends', detail: 'Profile photos appear to be stock images.', submittedAgo: '1h ago'),
    ReportRecord(id: 3, reporter: 'Isabella Kim', reported: 'Liam Carter', category: 'Harassment', mode: 'Dating', detail: 'Sent repeated unwanted messages after being asked to stop.', submittedAgo: '3h ago'),
    ReportRecord(id: 4, reporter: 'Sofia Rossi', reported: 'Mia Chen', category: 'Spam / scam', mode: 'Dating', detail: 'Asked to move conversation off-platform to sell crypto.', submittedAgo: '6h ago'),
    ReportRecord(id: 5, reporter: 'Ethan Brooks', reported: 'Noah Williams', category: 'Other', mode: 'Friends', detail: 'Made the reporter uncomfortable during a voice call.', submittedAgo: '9h ago'),
    ReportRecord(id: 6, reporter: 'Ava Thompson', reported: 'Noah Williams', category: 'Fake profile', mode: 'Friends', detail: 'Age listed does not match photos.', submittedAgo: '1d ago'),
  ];

  static const verifications = <VerificationRecord>[
    VerificationRecord(id: 1, name: 'Jacob Jones', submittedAgo: '2h ago', profileIdLabel: 'RO-100901'),
    VerificationRecord(id: 2, name: 'Isabella Clark', submittedAgo: '5h ago', profileIdLabel: 'RO-100902'),
    VerificationRecord(id: 3, name: 'Mason White', submittedAgo: '8h ago', profileIdLabel: 'RO-100903'),
    VerificationRecord(id: 4, name: 'Charlotte Brown', submittedAgo: '12h ago', profileIdLabel: 'RO-100904'),
  ];

  static const tickets = <TicketRecord>[
    TicketRecord(id: 1, user: 'Ava Thompson', subject: 'Cannot restore purchased tokens', category: 'Billing', priority: 'High', status: 'Open', updatedAgo: '12m ago'),
    TicketRecord(id: 2, user: 'Noah Williams', subject: 'Match disappeared after app update', category: 'Bug', priority: 'Medium', status: 'Open', updatedAgo: '48m ago'),
    TicketRecord(id: 3, user: 'Mia Chen', subject: 'Requesting account data export', category: 'Privacy', priority: 'Medium', status: 'In Progress', updatedAgo: '2h ago'),
    TicketRecord(id: 4, user: 'Ethan Brooks', subject: 'Verification stuck on pending', category: 'Verification', priority: 'Low', status: 'In Progress', updatedAgo: '5h ago'),
    TicketRecord(id: 5, user: 'Isabella Kim', subject: 'App crashes opening chat screen', category: 'Bug', priority: 'High', status: 'Resolved', updatedAgo: '1d ago'),
    TicketRecord(id: 6, user: 'Sofia Rossi', subject: 'Refund request for Gold plan', category: 'Billing', priority: 'Medium', status: 'Resolved', updatedAgo: '2d ago'),
  ];

  static const datingVsFriends = <String, int>{
    'Dating': 62,
    'Friends': 24,
    'Both': 14,
  };

  static const matchesPerDay = <double>[
    120, 140, 132, 158, 172, 165, 190,
  ];

  static const tokenPurchases7d = <double>[
    240, 310, 265, 380, 420, 395, 460,
  ];

  static const premiumSubscribersTotal = 8214;
  static const premiumSubscribersDelta = '↑ 5.1% from last week';

  static const matches = <MatchPair>[
    MatchPair(userA: 'Ava Thompson', userB: 'Liam Carter', matchedOn: 'Jul 29, 2026', status: 'Chatting'),
    MatchPair(userA: 'Sofia Rossi', userB: 'Ethan Brooks', matchedOn: 'Jul 28, 2026', status: 'New Match'),
    MatchPair(userA: 'Mia Chen', userB: 'Noah Williams', matchedOn: 'Jul 26, 2026', status: 'Chatting'),
    MatchPair(userA: 'Isabella Kim', userB: 'Liam Carter', matchedOn: 'Jul 24, 2026', status: 'Unmatched'),
  ];

  static const chats = <ChatThread>[
    ChatThread(participants: 'Ava Thompson & Liam Carter', lastMessage: 'Sounds good, see you then!', time: '2m ago', unread: 0),
    ChatThread(participants: 'Sofia Rossi & Ethan Brooks', lastMessage: 'Haha that\'s hilarious', time: '18m ago', unread: 2),
    ChatThread(participants: 'Mia Chen & Noah Williams', lastMessage: 'Reported: inappropriate content', time: '1h ago', unread: 1),
    ChatThread(participants: 'Isabella Kim & Liam Carter', lastMessage: 'Chat ended', time: '3h ago', unread: 0),
  ];

  static const subscriptions = <SubscriptionRow>[
    SubscriptionRow(user: 'Ava Thompson', plan: 'Premium', renews: 'Aug 15, 2026', amount: '\$19.99', status: 'Active'),
    SubscriptionRow(user: 'Noah Williams', plan: 'Gold', renews: 'Aug 10, 2026', amount: '\$9.99', status: 'Active'),
    SubscriptionRow(user: 'Mia Chen', plan: 'Premium', renews: 'Aug 02, 2026', amount: '\$19.99', status: 'Past Due'),
    SubscriptionRow(user: 'Ethan Brooks', plan: 'Gold', renews: 'Jul 30, 2026', amount: '\$9.99', status: 'Cancelled'),
  ];

  static const userGrowth = <double>[
    8.2, 8.6, 8.9, 9.4, 9.8, 10.5, 11.1, 11.4, 11.9, 12.1, 12.3, 12.45,
  ];

  static List<AppUser> get topRankedUsers {
    final sorted = [...users]..sort((a, b) => a.dailyRank.compareTo(b.dailyRank));
    return sorted;
  }

  static const reportCategories = <String, int>{
    'Inappropriate photo': 14,
    'Fake profile': 9,
    'Harassment': 6,
    'Spam / scam': 4,
    'Other': 3,
  };
}
