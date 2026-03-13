# AI-Driven Indigenous Language Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-43853D?style=flat&logo=node.js&logoColor=white)](https://nodejs.org/)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=flat&logo=supabase&logoColor=white)](https://supabase.com/)

## Preserving Cultural Heritage Through Technology

The **Indigenous Language App** is a mobile application designed to preserve, document, and revitalize indigenous languages in Malaysia. Focused on the communities of **Sabah** and **Sarawak**, the platform enables users to learn vocabulary, practice pronunciation with AI-powered feedback, and contribute to language preservation as a community.

The app currently supports **6 indigenous languages** across **2 regions**, with **50+ vocabulary concepts** organized into **6 categories**.

## Supported Languages

| Language | Region | Speakers | Status |
|----------|--------|----------|--------|
| Kadazan-Dusun | Sabah | ~500,000 | Active |
| Bajau | Sabah | ~400,000 | Active |
| Murut | Sabah | ~100,000 | Endangered |
| Iban | Sarawak | ~700,000 | Active |
| Bidayuh | Sarawak | ~200,000 | Vulnerable |
| Melanau | Sarawak | ~120,000 | Vulnerable |

## Key Features

### Language Learning
- Browse languages by region (Sabah & Sarawak)
- Learn vocabulary organized by category: Family, Fruit & Food, Nature, Daily Objects, Actions, Greetings
- View pronunciation guides, reference audio, and images for each concept
- Track learning progress with scores and attempt history

### AI-Powered Pronunciation Practice
- Record your pronunciation and receive AI-scored feedback
- Get phonetic tips for improvement
- Score-based progression system

### Community Contributions
- **Add Pronunciation**: Record audio for existing words to help build the language archive
- **Suggest New Words**: Submit new vocabulary with translations and optional audio recordings
- Contributions are reviewed before being added to the platform
- Supports beginner, intermediate, and native speaker contributor levels

### Quality Assurance
- Report incorrect pronunciations, translations, or images
- AI-powered contribution analysis detects anomalies and flags items for review
- Community-driven content moderation

### Offline Support
- Local SQLite database for offline functionality
- Supabase sync when connected to the internet

## Technology Stack

### Frontend
| Technology | Purpose |
|------------|---------|
| **Flutter** (Dart SDK ^3.6.0) | Cross-platform mobile framework |
| **Riverpod** v2.6.1 | State management |
| **Go Router** v16.1.0 | Navigation & routing |
| **Supabase Flutter** v2.12.0 | Backend integration |
| **Audioplayers** v6.6.0 | Audio playback |
| **Record** v6.2.0 | Audio recording |
| **Google Fonts** v7.1.0 | Typography (Noto Serif, Playfair Display) |
| **Cached Network Image** v3.4.1 | Image caching |

### Backend
| Technology | Purpose |
|------------|---------|
| **Node.js** + **Express.js** v4.21.0 | REST API server |
| **SQLite** (better-sqlite3 v11.7.0) | Local database with WAL mode |
| **Multer** v1.4.5 | File upload handling |
| **UUID** v10.0.0 | Unique ID generation |

### Infrastructure
| Technology | Purpose |
|------------|---------|
| **Supabase** | Authentication, real-time database, cloud sync |
| **SQLite** | Offline-first local storage |

## Project Structure

```
AI-Driven-Indigenous-Language-Platform/
├── frontend/
│   └── lib/
│       ├── main.dart                # App entry point & Supabase init
│       ├── app.dart                 # App configuration
│       ├── models/                  # Data models (Region, Language, Category, Concept, Contribution)
│       ├── services/                # Supabase service & Audio service
│       ├── providers/               # Riverpod state providers
│       ├── screens/                 # 11 UI screens
│       │   ├── welcome_screen.dart
│       │   ├── region_select_screen.dart
│       │   ├── language_select_screen.dart
│       │   ├── user_level_screen.dart
│       │   ├── native_intent_screen.dart
│       │   ├── quick_check_screen.dart
│       │   ├── home_screen.dart
│       │   ├── category_screen.dart
│       │   ├── concept_screen.dart
│       │   ├── practice_screen.dart
│       │   └── contribute_screen.dart
│       ├── router/                  # GoRouter configuration
│       ├── theme/                   # App theme, colors & typography
│       └── widgets/                 # Reusable UI components
├── backend/
│   └── src/
│       ├── index.js                 # Express server entry point
│       ├── database.js              # SQLite schema & seed data
│       └── routes/                  # API route handlers
│           ├── regions.js
│           ├── languages.js
│           ├── categories.js
│           ├── concepts.js
│           ├── contributions.js
│           ├── reports.js
│           └── ai.js
└── README.md
```

## App Navigation Flow

```
Welcome → Region Select → Language Select → User Level → Native Intent → Quick Check → Home
                                                                                        │
                                                          Category ← ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
                                                             │
                                                   ┌────────┴────────┐
                                                   │                 │
                                              Concept          Practice
                                                                     │
                                                               Contribute
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/regions` | List all regions |
| `GET` | `/api/regions/:id` | Get region with its languages |
| `GET` | `/api/languages` | List languages (optional `?region_id` filter) |
| `GET` | `/api/languages/:id` | Get language with categories |
| `GET` | `/api/categories` | List all categories |
| `GET` | `/api/categories/:id/concepts` | Get concepts for a category (`?language_id` required) |
| `GET` | `/api/concepts` | List concepts (`?language_id`, `?category_id` filters) |
| `GET` | `/api/concepts/:id` | Get single concept details |
| `POST` | `/api/concepts/:id/progress` | Save user progress (score, attempts) |
| `POST` | `/api/contributions` | Submit a contribution |
| `GET` | `/api/contributions` | List contributions (`?language_id` filter) |
| `POST` | `/api/reports` | Report an issue (wrong_pronunciation, wrong_translation, wrong_image, other) |
| `POST` | `/api/ai/pronunciation-check` | AI pronunciation scoring with feedback |
| `POST` | `/api/ai/analyze-contributions` | Analyze pending contributions for anomalies |
| `GET` | `/api/health` | Health check |

## Database Schema

```
regions ──┐
          ├──< languages ──┐
categories ──┐             │
             ├──< concepts ──┬──< contributions
             │               ├──< reports
             │               └──< user_progress
```

**7 tables**: `regions`, `languages`, `categories`, `concepts`, `contributions`, `reports`, `user_progress`

## Getting Started

### Prerequisites
- Flutter SDK (^3.6.0)
- Node.js (v16 or higher)
- npm

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/meorezz/AI-Driven-Indigenous-Language-Platform.git
   cd AI-Driven-Indigenous-Language-Platform
   ```

2. **Setup Backend**
   ```bash
   cd backend
   npm install
   npm run seed
   npm start
   ```

3. **Setup Frontend @ Run The App**
   ```bash
   cd frontend
   flutter pub get
   flutter run
   ```

4. **Build Release APK**
   ```bash
   cd frontend
   flutter build apk --release
   ```
   The APK will be at `frontend/build/app/outputs/flutter-apk/app-release.apk`

## Our Team

| Name | Role |
|------|------|
| **Meor Hazrul Hakim Bin Meor Harman** | Project Lead & Backend Developer |
| **Muthuraman Palaniappan** | AI/ML Developer |
| **Yong Su Kah** | Flutter Developer & UI/UX Designer |
| **Wan Nuraqilah Amni bt Wan Ab. Fatah** | Full-Stack Developer & Researcher |

## Project Impact

This platform addresses the indigenous language preservation crisis in Malaysia:

- **Language at Risk**: Multiple indigenous languages in Sabah and Sarawak are classified as vulnerable or endangered
- **Community Empowerment**: Native speakers can directly contribute pronunciations and vocabulary
- **Cultural Preservation**: Languages carry unique worldviews, traditions, and knowledge systems
- **Accessible Learning**: Mobile-first approach brings language learning to anyone, anywhere

## Contributing

We welcome contributions from developers, linguists, and indigenous community members. Please see [Contributing Guidelines](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Indigenous communities of Sabah and Sarawak for their invaluable linguistic heritage
- Linguistic researchers and anthropologists supporting preservation efforts
- Open-source community for the tools and frameworks that power this platform

## Contact

- Email: meorhazrul69@gmail.com
- GitHub Issues: [Report bugs or request features](https://github.com/meorezz/AI-Driven-Indigenous-Language-Platform/issues)

---

*Preserving indigenous languages of East Malaysia through technology — one word at a time.*
