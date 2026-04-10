# Maak (معاك) 🤝

**AI-Powered Administrative Accessibility Platform for Tunisia**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white&style=for-the-badge)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-009688?logo=fastapi&logoColor=white&style=for-the-badge)](https://fastapi.tiangolo.com)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white&style=for-the-badge)](https://www.docker.com)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white&style=for-the-badge)](https://github.com/features/actions)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white&style=for-the-badge)](https://dart.dev)
[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white&style=for-the-badge)](https://www.python.org)

> **Redefining administrative accessibility in Tunisia** through on-device AI, computer vision, AR navigation, intelligent OCR form automation, and predictive analytics — built exclusively for citizens with disabilities.

**Live Demo APK**: Available in GitHub Actions artifacts (staging build)
**Backend Image**: `ghcr.io/Yassminefeki/maak-backend:latest` (pushed via CI/CD)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Problem Statement](#2-problem-statement)
3. [Core Features](#3-core-features)
4. [Technical Architecture](#4-technical-architecture)
5. [Full Project Structure Breakdown](#5-full-project-structure-breakdown)
6. [Tech Stack](#6-tech-stack)
7. [DevOps & Infrastructure](#7-devops--infrastructure)
8. [CI/CD Pipeline](#8-cicd-pipeline)
9. [Installation Guide](#9-installation-guide)
10. [Running the Project](#10-running-the-project)
11. [API Documentation](#11-api-documentation)
12. [AI/ML Components](#12-aiml-components)
13. [Computer Vision / OCR / HUD / Advanced Features](#13-computer-vision--ocr--hud--advanced-features)
14. [Security Considerations](#14-security-considerations)
15. [Scalability / Performance Design](#15-scalability--performance-design)
16. [Future Improvements](#16-future-improvements)
17. [Architecture Diagrams](#17-architecture-diagrams)
18. [Deployment Strategy](#18-deployment-strategy)
19. [Contribution Guidelines](#19-contribution-guidelines)
20. [License](#20-license)

---

## 1. Executive Summary

**Maak (معاك)** is a cross-platform Flutter mobile application paired with a FastAPI backend that transforms complex Tunisian administrative procedures into an inclusive, voice-first, AI-assisted experience. The platform targets individuals with disabilities by providing linguistic support (Standard Arabic, French, Tunisian Darija), cognitive simplification of legal processes, physical AR navigation inside government offices, automated OCR-driven form filling, and predictive office-visit optimization.

**Mission**: Eliminate physical, linguistic, and cognitive barriers in Tunisia's administrative ecosystem (CIN, CNAM, passport, birth certificates, etc.), delivering measurable improvements in accessibility and efficiency.

**Business Value**: Reduces average procedure completion time by leveraging on-device edge AI and cloud-backed services; enables hands-free interaction; generates legally compliant PDFs; and crowdsources real-time office density data.

| | |
|---|---|
| **Target Users** | Tunisian citizens with visual, motor, or cognitive disabilities; elderly users; non-native Arabic/French speakers |
| **Primary Use Cases** | Procedure guidance, office navigation via AR HUD, automated form digitization, best-visit-time prediction |

---

## 2. Problem Statement

Tunisian administrative offices require citizens to navigate complex multi-step procedures, physical queues, printed forms in non-inclusive fonts, and language barriers — challenges that are exponentially harder for people with disabilities. Traditional solutions lack real-time guidance, voice interaction, or automation.

**Maak** solves this by combining **on-device computer vision**, **generative AI**, **AR sensor fusion**, and **backend OCR/PDF services** into a single mobile platform that works offline for core navigation and online for advanced AI features.

---

## 3. Core Features

| Feature | Technical Implementation | User/Business Purpose |
|---|---|---|
| **Generative AI Assistant** | `google_generative_ai` (Gemini 1.5 Flash) + `ProcedureDetectionService` with zero-shot prompting + `LanguageProvider` + `speech_to_text` / `flutter_tts` | Voice-first intent detection for 8+ procedures (CIN, CNAM, etc.); real-time Arabic/Darija/French translation and step-by-step guidance |
| **AR & Computer Vision Navigation** | `CVNavigationScreen` using `camera`, `CustomPaint` HUD, `sensors_plus`, `flutter_compass`; linear interpolation (lerp factor 0.15); 1200ms hysteresis; `math.atan2` for directional arrows | Indoor office localization with real-time radar, crosshair, and scanlines; eliminates physical stress of wayfinding |
| **Predictive Visit Optimizer** | `OptimizerService` with blended scoring: `Score = (HistoricalData × 0.6) + (UserFeedback × 0.4)`; procedure-specific time-tax multipliers; `HeatmapGrid` widget | Predicts lowest-density time slots across Tunisian work week; reduces wait times via crowdsourced feedback |
| **Intelligent Form Automation** | Frontend: `google_mlkit_text_recognition` + `image_picker`; Backend: `pytesseract` + Levenshtein mapping + `reportlab` PDF generation; `auto_fill_form/{user_id}` endpoint | Scans physical forms → extracts fields → auto-fills with `UserProfile` → returns print-ready `filled_form.pdf` |

---

## 4. Technical Architecture

**Pattern**: Hybrid client-server monolith with edge AI. Flutter mobile client (thick client) communicates with FastAPI backend via REST. On-device AI (ML Kit, sensors, Gemini) minimizes latency; backend handles heavy OCR/PDF and persistent storage.

- **Frontend**: Flutter (Dart) → Material 3 UI, Provider state management, SQLCipher encrypted local DB (`sqflite_sqlcipher` + `flutter_secure_storage`)
- **Backend**: FastAPI (Python 3.11) → SQLAlchemy ORM + SQLite (extendable to PostgreSQL), Pydantic schemas, CORS middleware
- **Database**: Dual — encrypted SQLite on-device (Flutter) + SQLAlchemy backend (shared `UserProfile`)
- **AI Layer**: On-device (ML Kit Text Recognition, sensors) + Cloud (Gemini 1.5 Flash via API key)
- **Communication**: REST (JSON) for profiles/forms; direct sensor/camera streams for AR/OCR; no WebSockets or gRPC implemented

**Data Flow**: `User → Flutter UI → (local AI or REST) → FastAPI → (Tesseract + ReportLab) → Response/PDF`

---

## 5. Full Project Structure Breakdown

```bash
Maak/
├── .github/
│   └── workflows/
│       └── main_ci.yml          # CI/CD: lint, analyze, Docker build-push, APK staging
├── .env                         # Gemini API key — NOT committed to version control
├── docker-compose.yml           # Orchestrates backend service in dev/prod
├── pubspec.yaml                 # Flutter dependencies & asset declarations
├── pubspec.lock                 # Locked dependency versions
├── test.db                      # Example SQLite database (for local testing)
├── filled_form.pdf              # Sample output PDF generated by the OCR pipeline
├── assets/
│   └── images/                  # App icons, onboarding illustrations
├── backend/                     # Self-contained FastAPI microservice
│   ├── Dockerfile               # python:3.11-slim + Tesseract OCR system install
│   ├── requirements.txt         # All Python dependencies
│   ├── main.py                  # All REST endpoints + OCR/PDF logic
│   ├── models.py                # SQLAlchemy ORM models (UserProfile table)
│   ├── schemas.py               # Pydantic request/response validation schemas
│   ├── crud.py                  # Database CRUD operations
│   ├── database.py              # SQLAlchemy engine initialization & session factory
│   └── pdf_handler.py           # ReportLab PDF generation utilities
├── lib/                         # Flutter application source code
│   ├── main.dart                # App entry point — MaterialApp, Provider tree, routing
│   ├── screens/                 # UI screens (CVNavigationScreen, FormScanScreen, etc.)
│   ├── services/                # OptimizerService, TextRecognitionService, ProcedureDetectionService
│   ├── providers/               # LanguageProvider, UserProvider state management
│   ├── models/                  # Dart data models (UserProfile, BestSlot, ProcedureStep)
│   └── utils/                   # AR math helpers, HUD CustomPaint painters
├── android/                     # Android platform embedding & Gradle config
├── ios/                         # iOS platform embedding & Xcode config
├── web/                         # Flutter web support (future kiosk mode)
└── windows/, macos/, linux/     # Desktop platform embeddings
```

**Key file purposes:**

| File | Role |
|---|---|
| `docker-compose.yml` | Defines production-like backend runtime with volume mounts and env vars |
| `backend/main.py` | All REST endpoints, OCR orchestration, PDF generation logic |
| `pubspec.yaml` | Declares `google_mlkit_text_recognition`, `sensors_plus`, `google_generative_ai`, etc. |
| `lib/screens/CVNavigationScreen` | AR HUD implementation with camera + compass + gyroscope fusion |
| `lib/services/OptimizerService` | Blended scoring algorithm for visit-time prediction |

---

## 6. Tech Stack

| Category | Technologies |
|---|---|
| **Frontend** | Flutter 3.16+, Dart, Material 3, Provider, `google_fonts`, `intl` |
| **Backend** | FastAPI, Uvicorn, SQLAlchemy, Pydantic |
| **AI / ML** | Google Gemini 1.5 Flash, Google ML Kit Text Recognition, Tesseract OCR v5+ |
| **Computer Vision / AR** | `camera`, `sensors_plus`, `flutter_compass`, `CustomPaint`, `math.atan2` |
| **Database** | SQLCipher (Flutter), SQLite via SQLAlchemy (backend) |
| **DevOps / Infrastructure** | Docker, Docker Compose, GitHub Container Registry (GHCR) |
| **CI/CD** | GitHub Actions (`flake8`, `flutter analyze`, Docker build-push) |
| **Testing** | `flutter_test`, `pytest` (configured, not fully executed in CI) |
| **Deployment** | Docker images, GHCR, ready for Kubernetes / Cloud Run |
| **Tools** | `flutter_secure_storage`, `path_provider`, `permission_handler`, `reportlab`, `pillow` |

---

## 7. DevOps & Infrastructure

**Docker Strategy**: Full containerization of the Python backend only — Flutter remains a native mobile build. The Dockerfile uses `python:3.11-slim` as base, installs system-level `tesseract-ocr` and development libraries, copies `requirements.txt`, and launches the server via `uvicorn main:app --host 0.0.0.0 --port 8000`.

**`docker-compose.yml`:**

```yaml
version: '3.8'
services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - TESSERACT_PATH=/usr/bin/tesseract
    volumes:
      - ./backend:/app
    restart: always
```

**Networking**: Single service exposed on port `8000`. The Flutter client calls `http://10.0.2.2:8000` on Android emulator or the host machine IP on physical devices. Volume mount (`./backend:/app`) enables hot-reload without container rebuilds during development. The compose file has PostgreSQL service commented out, signaling readiness for production-grade DB migration.

**Why Docker?** Ensures identical Tesseract OCR environment across development, CI, and production — eliminating OCR accuracy regressions caused by OS-level library version drift.

---

## 8. CI/CD Pipeline

**File**: `.github/workflows/main_ci.yml`
**Triggers**: `push` to `main`/`dev`, `pull_request` to `main`

**Step-by-step Jobs:**

| Job | Steps | Depends On |
|---|---|---|
| `backend-test` | Setup Python 3.11 → `pip install` → `flake8` (E9, F63, F7, F82, complexity ≤ 10) | — |
| `flutter-test` | Flutter 3.16 stable → `flutter pub get` → `flutter analyze` | — |
| `build-docker-backend` | Login GHCR → `docker/build-push-action` (tags: `latest` + commit SHA) | `backend-test` |
| `build-staging-apk` | `flutter build apk --debug` → Upload artifact | `flutter-test` |

> **Current Coverage**: Linting + static analysis + build only. No automated test execution in CI. No production deployment stage. See [Future Improvements](#16-future-improvements).

---

## 9. Installation Guide

### Prerequisites

- Flutter SDK ≥ 3.4.3
- Python 3.11+
- Docker + Docker Compose *(recommended)*
- Tesseract OCR v5+ *(system-wide, for local backend without Docker)*
- Google Gemini API key

### Environment Variables

Create a `.env` file in the project root:

```env
GEMINI_API_KEY=your_gemini_key_here
```

### Docker Setup *(Recommended)*

```bash
git clone https://github.com/Yassminefeki/Maak.git
cd Maak
docker-compose up --build
# Backend available at http://localhost:8000
# Swagger UI at http://localhost:8000/docs
```

### Local Setup *(without Docker)*

```bash
# Frontend
flutter pub get

# Backend
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

### Flutter Mobile

```bash
flutter run --debug
# Use --release for production builds
```

> **Permissions required**: Camera, location, and device sensor access must be granted on the physical device or emulator.

---

## 10. Running the Project

### Development Mode

```bash
# Terminal 1 — Backend (hot-reload via volume mount)
docker-compose up --build

# Terminal 2 — Flutter (hot reload)
flutter run
```

### Production Mode

```bash
# Mobile build
flutter build apk --release   # Android
flutter build ipa              # iOS

# Backend (detached)
docker-compose up -d
```

---

## 11. API Documentation

**Base URL**: `http://localhost:8000`
**Swagger UI**: `/docs` *(FastAPI auto-generated)*
**CORS**: `*` *(development only — restrict in production)*

| Method | Endpoint | Purpose | Request | Response |
|---|---|---|---|---|
| `GET` | `/` | Health check | — | Welcome message |
| `POST` | `/register_user/` | Create user profile | `UserProfileCreate` | Created profile |
| `POST` | `/user_profiles/` | Add profile (alternate) | `UserProfileCreate` | Profile |
| `GET` | `/get_user_profile/{user_id}` | Retrieve profile | `user_id` path param | `UserProfileResponse` |
| `POST` | `/scan_form/` | Basic OCR field extraction | Multipart image | Mapped profile JSON |
| `POST` | `/auto_fill_form/{user_id}` | Full OCR → auto-fill → PDF | Multipart image + `user_id` | Filled form JSON + `filled_form.pdf` |

---

## 12. AI/ML Components

| Component | Model / Algorithm | Role |
|---|---|---|
| **Gemini 1.5 Flash** | Zero-shot prompting via `google_generative_ai` | Intent classification across 8+ administrative procedures; multilingual conversational guidance (AR/FR/Darija) |
| **Google ML Kit Text Recognition** | On-device neural OCR | Real-time form field extraction with no internet dependency; low latency edge inference |
| **Tesseract OCR v5+** | LSTM-based backend OCR via `pytesseract` | Production-grade extraction with custom training potential for Tunisian administrative fonts |

> No custom-trained models are used. The platform relies entirely on pre-trained foundation models for deployment speed and long-term maintainability.

---

## 13. Computer Vision / OCR / HUD / Advanced Features

### AR HUD Implementation (`CVNavigationScreen`)

- `CustomPaint` renders real-time radar overlay, precision crosshair, and stylized CRT-style scanlines
- Movement smoothing via `lerp(factor: 0.15)` — prevents jitter from sensor noise
- Target persistence via a **1200ms hysteresis window** — avoids flickering when targets briefly leave frame
- Direction calculation: `math.atan2(dy, dx)` applied to fused sensor data (gyroscope + compass heading)

### Full OCR Pipeline

```
User scans form (camera)
        │
        ▼
ML Kit Text Recognition (on-device, offline)
        │
        ▼
Image → POST /scan_form/ or /auto_fill_form/{user_id}
        │
        ▼
Tesseract OCR (backend, python:3.11 + tesseract-ocr)
        │
        ▼
Levenshtein fuzzy field matching → UserProfile mapping
        │
        ▼
ReportLab PDF generation → filled_form.pdf
        │
        ▼
JSON response + PDF returned to Flutter client
```

### Indoor AR Navigation

Combines live camera feed + `flutter_compass` heading + `sensors_plus` gyroscope data for indoor localization **without external beacons, Bluetooth, or Wi-Fi fingerprinting**.

---

## 14. Security Considerations

| Layer | Measure | Status |
|---|---|---|
| Local database | SQLCipher AES encryption (`sqflite_sqlcipher`) | ✅ Implemented |
| Key storage | `flutter_secure_storage` (Keystore / Keychain) | ✅ Implemented |
| Device permissions | Granular runtime consent via `permission_handler` | ✅ Implemented |
| Backend CORS | Middleware configured | ⚠️ `*` — restrict in production |
| Authentication | JWT / OAuth2 | ❌ Not implemented |
| Rate limiting | Request throttling | ❌ Not implemented |
| Input sanitization | FastAPI Pydantic validation only | ⚠️ Partial |
| HTTPS enforcement | TLS in Docker Compose | ❌ Not implemented |
| PDF persistence | PDFs generated server-side, not stored | ✅ Privacy-safe |

> A security hardening roadmap is planned for Phase 1 (Q2 2026).

---

## 15. Scalability / Performance Design

**Current state**: Single-container FastAPI + SQLite — appropriate for MVP scale. Flutter runs natively on-device with no server dependency for core AR/navigation features.

**Horizontal scaling readiness**: GHCR-hosted Docker image supports multi-replica deployment behind any load balancer. Stateless FastAPI design (no in-memory session state) enables horizontal pod autoscaling.

**Future optimizations:**

| Optimization | Impact |
|---|---|
| PostgreSQL (commented in compose) | Production-grade concurrent writes, ACID compliance |
| Redis caching for `OptimizerService` scores | Eliminates redundant scoring computation across users |
| GPU-accelerated Tesseract containers | 5–10× OCR throughput improvement |
| Flutter web/desktop | Kiosk-mode deployment at government terminals |
| Gemini Nano (on-device) | Full offline AI capability without API dependency |

---

## 16. Future Improvements

| Phase | Timeline | Deliverables |
|---|---|---|
| **Phase 1** | Q2 2026 | Real-time IoT wait-list integration, PostgreSQL migration, JWT authentication, rate limiting |
| **Phase 2** | Q3 2026 | Voice signature capture, WhatsApp/SMS automation for official confirmation delivery |
| **Phase 3** | Q4 2026 | Guichet Unique multi-office orchestration, offline-first Gemini Nano, WCAG 2.2 audit |
| **Ongoing** | Continuous | Full test coverage (unit + integration + E2E), production CD to Cloud Run/Kubernetes, Arabic RTL accessibility audit |

---

## 17. Architecture Diagrams

### System Architecture

```mermaid
graph TB
    subgraph Client["Flutter Mobile Client"]
        UI[Material 3 UI + Provider]
        MLKit[ML Kit Text Recognition]
        AR[AR HUD + Sensors + Compass]
        DB_local[SQLCipher DB]
        Gemini[Gemini 1.5 Flash]
    end

    subgraph Backend["FastAPI Backend"]
        API[FastAPI + CORS]
        OCR[Tesseract + Pytesseract]
        PDF[ReportLab PDF Generator]
        DB_back[SQLAlchemy + SQLite]
    end

    External[Google AI Studio]

    UI -->|REST JSON| API
    MLKit -->|POST multipart| API
    Gemini <-->|API Key| External
    API --> OCR
    OCR --> PDF
    API --> DB_back
    UI --> DB_local
    UI --> Gemini
    UI --> AR
```

### DevOps Pipeline

```mermaid
graph LR
    A[Git Push / PR] --> B[GitHub Actions]
    B --> C[Backend Lint - flake8]
    B --> D[Flutter Analyze]
    C --> E[Docker Build & Push GHCR]
    D --> F[Build Debug APK]
    E --> G[latest + SHA tags]
    F --> H[Artifacts - Staging QA]
```

### Request / Data Flow

```mermaid
sequenceDiagram
    participant User
    participant Flutter
    participant Backend

    User->>Flutter: Voice command + camera scan
    Flutter->>Flutter: ML Kit OCR (on-device)
    Flutter->>Backend: POST /auto_fill_form/{user_id} + image
    Backend->>Backend: Tesseract OCR + Levenshtein mapping
    Backend->>Backend: ReportLab PDF generation
    Backend->>Flutter: Filled JSON + filled_form.pdf
    Flutter->>User: AR guidance overlay / PDF ready
```

---

## 18. Deployment Strategy

| Environment | Method |
|---|---|
| **Development** | `docker-compose up --build` + `flutter run` |
| **Staging** | GitHub Actions debug APK artifact + GHCR image (`latest`) |
| **Production** | Push to `main` → CI tags image with commit SHA → deploy to Cloud Run / ECS / Kubernetes |
| **Mobile distribution** | Google Play Store / Apple App Store / Enterprise MDM |

**Zero-downtime strategy**: Blue-green deployment via Docker image tags + container health checks.

**Observability** *(planned)*: Prometheus metrics endpoint + Grafana dashboard for OCR latency, API throughput, and error rates.

**Cloud Run deployment example:**

```bash
gcloud run deploy maak-backend \
  --image ghcr.io/Yassminefeki/maak-backend:latest \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated \
  --port 8000
```

---

## 19. Contribution Guidelines

Contributions from the open-source community are welcome!

1. **Fork** the repository
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. Ensure **`flutter analyze`** and **`flake8`** pass with zero errors
4. **Add or update tests** for all changed logic
5. **Open a Pull Request** with a clear description, updated Mermaid diagrams if architecture is affected, and a reference to the related issue using `#issue-number`

**Code style**: Official Flutter lints + PEP 8 (both enforced by CI pipeline).

**Local CI simulation:**

```bash
# Backend
cd backend && flake8 . --max-complexity=10

# Frontend
flutter analyze
```

---

## 20. License

This project is currently **unlicensed**. The repository owner should add a `LICENSE` file before public distribution.

Recommended: **MIT** (permissive, open collaboration) or **GPL-3.0** (copyleft, ensures derivative works remain open-source).

---

*Built with ❤️ for a more inclusive Tunisia.*
**Repository**: [github.com/Yassminefeki/Maak](https://github.com/Yassminefeki/Maak)
