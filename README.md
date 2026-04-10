# Maak (معاك) 🤝
> Empowering administrative accessibility in Tunisia through AI and Computer Vision.

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.9+-3776AB.svg?logo=python&logoColor=white)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Description
Maak is an AI-powered administrative assistant designed to bridge the accessibility gap for people with disabilities in Tunisia. By leveraging Computer Vision and Generative AI, the platform simplifies complex administrative procedures, automates form filling, and provides real-time indoor navigation within government offices.

## Features
- **AI Chatbot**: Multilingual administrative guidance using Google Gemini.
- **Form Automation**: OCR-based document scanning and automatic PDF generation.
- **AR Navigation**: Real-time camera-based guidance to specific office counters.
- **Visit Optimizer**: Predictive crowd analysis to recommend the best visiting times.
- **Procedure Assistant**: Step-by-step walkthroughs for localized Tunisian admin tasks.
- **Voice-First UI**: Seamless accessibility via Text-to-Speech (TTS) and Speech-to-Text (STT).
- **Secure Storage**: Encrypted local database using SQLCipher for user sensitive data.

## Tech Stack
**Frontend:** Flutter, Provider, Google ML Kit, Sensors Plus.  
**Backend:** Python, FastAPI, SQLAlchemy, Tesseract OCR.  
**AI Services:** Google Gemini (Generative AI).  
**Database:** SQLite (sqflite_sqlcipher).

## Prerequisites
- **Flutter SDK**: `^3.4.3`
- **Dart SDK**: `^3.0.0`
- **Python**: `3.9` or higher
- **Tesseract OCR**: Installed on host machine (for backend OCR).
- **Gemini API Key**: Required for AI chatbot functionality.

## Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/Yassminefeki/Maak.git
cd Maak
```

### 2. Frontend Setup (Flutter)
```bash
# Install dependencies
flutter pub get

# Configure environment variables
# Create a .env file in the root directory
# GEMINI_API_KEY=your_api_key_here
```

### 3. Backend Setup (FastAPI)
```bash
cd backend
# Install Python dependencies
pip install -r recuirement.txt

# Run the backend server
uvicorn main:app --reload
```

## Usage
To run the mobile application:
```bash
flutter run
```
*Note: Ensure the backend is running if using form-scanning features.*

## Project Structure
```text
Maak/
├── assets/             # Images and local configuration files
├── backend/            # FastAPI server for OCR and PDF handling
├── lib/
│   ├── core/           # Routing, themes, and constants
│   ├── data/           # Repositories and local DB providers
│   ├── models/         # Data structures
│   ├── screens/        # UI Pages (Chatbot, Navigation, Forms)
│   ├── services/       # API and AI logic
│   └── widgets/        # Reusable UI components
└── test/               # Unit and widget tests
```

## Contributing
We welcome contributions! Please fork the repository, create a feature branch, and submit a PR. For major changes, please open an issue first to discuss what you would like to change.

## License
Distributed under the [MIT License](https://opensource.org/licenses/MIT).
