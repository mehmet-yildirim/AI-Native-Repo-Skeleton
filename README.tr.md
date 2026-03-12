# AI-Native Geliştirme İskeleti — Geliştirici Kılavuzu

Bu iskelet, yeni veya mevcut projelerde **yapay zeka destekli otonom yazılım geliştirme** için hazır bir başlangıç yapısı sunar. [Cursor](https://cursor.sh), [Continue](https://continue.dev) ve [Claude Code](https://claude.ai/code) araçlarını kutudan çıkar çıkmaz destekler.

İnteraktif, insan destekli geliştirmeden; JIRA backlog'undan iş alıp Pull Request teslim eden **tam otonom ajan moduna** kadar çalışır.

> **English:** See [README.md](README.md) for the English version.

---

## İçindekiler

1. [Bu İskelet Ne Sağlar?](#bu-i̇skelet-ne-sağlar)
2. [Hızlı Başlangıç](#hızlı-başlangıç)
3. [Proje Yapısı](#proje-yapısı)
4. [AI Araç Desteği](#ai-araç-desteği)
5. [Dil ve Framework Becerileri](#dil-ve-framework-becerileri)
6. [Slash Komutları Referansı](#slash-komutları-referansı)
7. [Otonom Ajan Döngüsü](#otonom-ajan-döngüsü)
8. [MCP Sunucuları](#mcp-sunucuları)
9. [Claude Code Hook'ları](#claude-code-hookları)
10. [Geliştirme İş Akışları](#geliştirme-i̇ş-akışları)
11. [Yapılandırma Rehberi](#yapılandırma-rehberi)
12. [Sıkça Sorulan Sorular](#sıkça-sorulan-sorular)

---

## Bu İskelet Ne Sağlar?

| Katman | Yapılandırma | Amaç |
|--------|-------------|------|
| **Claude Code** | `CLAUDE.md`, `.claude/` | Proje talimatları, 16 slash komutu, olay hook'ları |
| **Cursor** | `.cursor/rules/`, `.cursor/prompts/` | 18 bağlamsal kural dosyası + 16 iş akışı prompt dosyası |
| **Continue** | `.continue/` | Çok-model yapılandırması, satır içi slash komutları, kalıcı kurallar |
| **Otonom Ajan** | `agent.config.yaml`, `docs/agent/` | JIRA taraması, domain doğrulama, tam geliştirme döngüsü, eskalasyon |
| **GitHub** | `.github/` | PR şablonu, issue şablonları, CI iş akışı |
| **Tüm editörler** | `.editorconfig` | Diller arası tutarlı biçimlendirme |

---

## Hızlı Başlangıç

### 1. Depoyu Klonlayın

```bash
git clone <bu-repo-url> benim-projem
cd benim-projem
```

### 2. Kurulum Betiğini Çalıştırın

```bash
./scripts/setup.sh
```

Bu betik şunları yapar:
- Git deposunu başlatır (varsa iskelet uzak adresini kaldırır)
- `.env.example` dosyasından `.env` oluşturur
- Temel yapılandırma dosyalarının varlığını kontrol eder

### 3. Başlatma Sihirbazını Çalıştırın

```bash
bash scripts/init.sh
```

Şunları yapılandırır: proje adı ve türü, teknoloji yığını, issue tracker bağlantısı (JIRA/Linear/GitHub), domain anahtar kelimeleri. `agent.config.yaml` ve `CLAUDE.md` içindeki mekanik alanları otomatik doldurur.

### 4. Yapay Zeka Destekli İçerik Üretimi

Claude Code veya Cursor'da aşağıdaki komutu çalıştırın:

```
# Claude Code
/init Sipariş yönetimi yapan bir B2C e-ticaret API'si geliştiriyorum. Yığın: TypeScript, Fastify, PostgreSQL.

# Cursor
@.cursor/prompts/init.md
[ardından projenizi açıklayan bir mesaj yazın]
```

Hedefli doldurma için:
```
/init domain: <alan açıklaması>
/init stack: <teknoloji yığını>
/init ci: <CI/CD ve deployment hedefi>
/init agent: <tracker anahtarları, GitHub owner, eskalasyon kanalı>
```

**Otomatik doldurulan dosyalar:**

| Dosya | Doldurma Yöntemi |
|-------|-----------------|
| `CLAUDE.md` | `init.sh` + `/init` |
| `.cursor/rules/00-project-overview.mdc` | `init.sh` + `/init` |
| `docs/context/project-brief.md` | `/init` |
| `docs/context/tech-stack.md` | `/init stack:` |
| `docs/context/domain-boundaries.md` | `/init domain:` ← **ajan triage için kritik** |
| `docs/context/domain-glossary.md` | `/init` |
| `docs/architecture/overview.md` | `/init` |
| `agent.config.yaml` (kimlik, anahtar, kelimeler) | `init.sh` + `/init agent:` |
| `.github/workflows/ci.yml` | `/init ci:` |

### 5. Manuel Tamamlama

**Hâlâ manuel müdahale gereken dosyalar:**
- `.continue/config.yaml` — API anahtarlarını ekleyin
- `.env` — kimlik bilgilerini doldurun
- `.cursor/mcp.json` — MCP sunucularını etkinleştirin
- `docs/architecture/decisions/` — `0001-template.md` şablonundan ADR oluşturun
- Üretilen içerikleri ilk commit'ten önce gözden geçirin

**Önerilen:**

| Dosya / Adım | Açıklama |
|---|---|
| `.cursor/mcp.json` | MCP sunucularını etkinleştirin |
| `.continue/config.yaml` becerileri | Yalnızca stack'inizle eşleşen kuralları yorumdan çıkarın |
| `docs/architecture/decisions/` | `0001-template.md` dosyasından ilk ADR'ınızı oluşturun |

### 4. Manuel Kurulum Adımları

`setup.sh` tarafından otomatik yapılmayan işlemler:

**Pre-commit gizli tarama hook'u** — `docs/workflows/05-security-evaluation.md` dosyasında belgelenmiştir ancak otomatik olarak kurulmaz. Tercih ettiğiniz araçla kurun:
```bash
# Seçenek A — Husky (Node.js projeleri)
npx husky init
echo "npx secretlint '**/*'" > .husky/pre-commit

# Seçenek B — pre-commit (Python / çok dilli)
pip install pre-commit
# .pre-commit-config.yaml dosyasına detect-secrets veya gitleaks ekleyin
pre-commit install
```

**Webhook alıcısı** — Otonom modu etkinleştirmeden önce Jira Server webhook şablonunu kopyalayın:
```bash
mkdir -p .agent
cp .agent-templates/webhook-receiver.mjs .agent/webhook-receiver.mjs
# .env dosyasına JIRA_WEBHOOK_SECRET ekleyin, ardından: node .agent/webhook-receiver.mjs
```

**Çalışma zamanı ajan dizinleri** — Hook'lar `.agent/audit/` ve `.agent/state/` dizinlerine ilk kullanımda otomatik yazar; bu dizinler git-ignored'dur. İsterseniz önceden oluşturabilirsiniz:
```bash
mkdir -p .agent/{state,audit,outputs}
```

**PagerDuty entegrasyonu** — `agent.config.yaml`, CRITICAL eskalasyonları PagerDuty'ye yönlendirir; ancak iskelet bir PagerDuty MCP sunucusu veya SDK entegrasyonu içermez. Otonom modu üretime almadan önce bu entegrasyonu kendiniz uygulamanız veya CRITICAL olayları Slack/e-posta'ya yönlendirmeniz gerekir.

### 5. Yapılandırmayı Doğrulayın

```bash
bash scripts/validate-ai-config.sh
# Beklenen: 73 PASS, 0 FAIL
# WARN: Doldurulması gereken TODO alanları (kabul edilebilir)
```

### 6. Geliştirmeye Başlayın

```bash
# Claude Code'u başlatın
claude

# İlk komutunuz — gereksinimleri analiz edin
/requirements Kullanıcı girişi için JWT tabanlı kimlik doğrulama ekle
```

---

## Proje Yapısı

```
.
├── CLAUDE.md                                  # ← DÜZENLE — Claude Code talimatları
├── agent.config.yaml                          # ← DÜZENLE — otonom ajan yapılandırması
│
├── .cursor/
│   ├── prompts/                               # 16 iş akışı prompt dosyası (@ ile çağrılır)
│   │   ├── README.md                         # Cursor prompt dosyaları kullanım kılavuzu
│   │   ├── requirements.md  architect.md  implement.md  review.md
│   │   ├── qa.md  test.md  debug.md  deploy.md  migrate.md
│   │   ├── sprint.md  docs.md  standup.md  security-audit.md
│   │   └── triage.md  groom.md  loop.md  escalate.md
│   ├── rules/
│   │   ├── 00-project-overview.mdc           # ← DÜZENLE — her dosyada yüklenir
│   │   ├── 01-coding-standards.mdc           # Genel kodlama standartları
│   │   ├── 02-architecture.mdc               # Mimari kılavuzlar ve katman kuralları
│   │   ├── 03-testing.mdc                    # Test piramidi, mock stratejisi
│   │   ├── 04-git-workflow.mdc               # Branch adlandırma, commit'ler, PR'lar
│   │   ├── 05-security.mdc                   # OWASP Top 10 (her zaman yüklü)
│   │   └── skills/                           # Dosya uzantısına göre otomatik etkinleşir
│   │       ├── lang-java.mdc                 # Spring Boot, JPA, JUnit 5, Java 21
│   │       ├── lang-dotnet.mdc               # ASP.NET Core, EF Core, xUnit, C# 12
│   │       ├── lang-python.mdc               # FastAPI, SQLAlchemy, pytest, tip belirtimi
│   │       ├── lang-typescript.mdc           # Strict TS, ESM, Bun/Node.js
│   │       ├── lang-go.mdc                   # Deyimsel Go, stdlib, eşzamanlılık
│   │       ├── fe-react.mdc                  # Hooks, React Query, RTL, formlar
│   │       ├── fe-nextjs.mdc                 # App Router, Server Components, Actions
│   │       ├── fe-vue.mdc                    # Composition API, Pinia, Vue Router
│   │       ├── fe-angular.mdc                # Standalone, Signals, NgRx, RxJS
│   │       ├── mobile-ios.mdc                # Swift, SwiftUI, async/await, SwiftData
│   │       ├── mobile-android.mdc            # Kotlin, Compose, Hilt, Room, Flow
│   │       ├── mobile-flutter.mdc            # Dart 3, Riverpod, GoRouter, Freezed
│   │       ├── mobile-reactnative.mdc        # Expo, TS strict, React Navigation, EAS
│   │       ├── be-microservices.mdc          # Servis tasarımı, dayanıklılık, gözlemlenebilirlik
│   │       ├── devops-docker.mdc             # Dockerfile, Compose, güvenlik
│   │       └── devops-cicd.mdc               # GitHub Actions, kalite kapıları, deployment
│   └── mcp.json                               # MCP: GitHub, Jira, Linear, Slack, Sentry…
│
├── .continue/
│   ├── config.yaml                            # ← API ANAHTARLARI EKLE
│   └── rules/
│       ├── 01-coding-standards.md
│       ├── 02-architecture.md
│       ├── 03-testing.md
│       ├── 04-security.md
│       └── skills/                            # config.yaml'da yorumdan çıkararak aktive et
│           ├── lang-java.md
│           ├── lang-dotnet.md
│           ├── lang-python.md
│           ├── fe-react.md
│           ├── fe-nextjs.md
│           ├── fe-vue.md
│           ├── fe-angular.md
│           ├── mobile-ios.md
│           ├── mobile-android.md
│           ├── mobile-flutter.md
│           └── mobile-reactnative.md
│
├── .claude/
│   ├── settings.json                          # Araç izinleri + olay hook'ları
│   ├── commands/                              # 16 slash komutu
│   │   ├── requirements.md                   # /requirements
│   │   ├── architect.md                      # /architect
│   │   ├── implement.md                      # /implement
│   │   ├── review.md                         # /review
│   │   ├── qa.md                             # /qa
│   │   ├── test.md                           # /test
│   │   ├── debug.md                          # /debug
│   │   ├── deploy.md                         # /deploy
│   │   ├── migrate.md                        # /migrate
│   │   ├── sprint.md                         # /sprint
│   │   ├── docs.md                           # /docs
│   │   ├── standup.md                        # /standup
│   │   ├── triage.md                         # /triage    ← otonom ajan
│   │   ├── groom.md                          # /groom     ← otonom ajan
│   │   ├── loop.md                           # /loop      ← otonom ajan
│   │   └── escalate.md                       # /escalate  ← otonom ajan
│   └── hooks/                                # Olay tetikleyicileri
│       ├── post-write.mjs                    # Yazma sonrası korunan yol denetimi
│       ├── audit-log.mjs                     # Bash komutu kaydı + yasak komut tespiti
│       └── on-stop.mjs                       # Oturum sonu: devam eden görev uyarısı
│
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── ISSUE_TEMPLATE/
│   └── workflows/ci.yml                       # CI şablonu — stack'inize göre uyarlayın
│
├── docs/
│   ├── ai-workflow.md                         # AI geliştirme rehberi
│   ├── onboarding.md                          # Yeni geliştirici kılavuzu
│   ├── context/                               # ← TÜMÜNÜ DÜZENLE
│   │   ├── project-brief.md
│   │   ├── tech-stack.md
│   │   ├── domain-glossary.md
│   │   └── domain-boundaries.md              # ← DÜZENLE — ajan triage kapsamı
│   ├── architecture/
│   │   ├── overview.md                        # ← DÜZENLE — sistem mimarisi
│   │   └── decisions/                         # Mimari Karar Kayıtları (ADR)
│   ├── agent/                                 # Otonom ajan belgeleri
│   │   ├── autonomous-workflow.md             # Durum makinesi, fazlar, kapılar
│   │   ├── escalation-protocol.md            # Tetikleyiciler, önem dereceleri, yanıt komutları
│   │   ├── decision-log-template.md          # Audit izi şeması ve örnekleri
│   │   ├── security-evaluator.md             # Güvenlik mimarisi ve entegrasyon noktaları
│   │   ├── jira-server-setup.md              # Şirket içi Jira Server kurulum kılavuzu
│   │   └── schemas/                          # Fazlar arası JSON şemaları
│   │       ├── task-state.json               # Görev başına kalıcı durum
│   │       ├── decision.json                 # Yapısal karar kaydı
│   │       ├── requirement-analysis.json     # /requirements yapısal çıktısı
│   │       ├── qa-report.json                # /qa kapı sonuçları
│   │       └── security-report.json          # /security-audit çıktı şeması
│   └── workflows/                             # Geliştirme iş akışı kılavuzları
│       ├── 01-requirements-analysis.md
│       ├── 02-feature-development.md
│       ├── 03-testing-strategy.md
│       ├── 04-deployment.md
│       └── 05-security-evaluation.md         # Güvenlik kontrol noktaları ve düzeltme iş akışı
│
├── skills/
│   └── README.md                              # Beceri indeksi ve aktivasyon rehberi
│
├── .agent-templates/
│   └── webhook-receiver.mjs                   # Jira Server webhook alıcısı (.agent/ altına kopyalayın)
│
└── scripts/
    ├── setup.sh                               # Tek seferlik kurulum
    └── validate-ai-config.sh                  # Yapılandırma doğrulayıcı (73 kontrol, 16 slash komutundan 14'ü)
```

---

## AI Araç Desteği

### Claude Code

`CLAUDE.md` dosyasını doldurun — Claude Code bunu proje dizininde otomatik olarak yükler.

```bash
claude       # Claude Code'u başlatın
/help        # Tüm özel komutları görün
```

**Otomatik yüklenen bağlam:**
- `CLAUDE.md` — proje talimatları, mimari, kodlama kuralları
- `.claude/commands/` — 16 özel slash komutu
- `.claude/settings.json` — araç izinleri ve hook yapılandırması

### Cursor

`.cursor/rules/` klasöründeki `.mdc` dosyaları, dosya türüne göre **otomatik olarak** etkinleşir:

```
*.java dosyası açıldığında  → lang-java.mdc yüklenir
*.tsx dosyası açıldığında   → fe-react.mdc + fe-nextjs.mdc yüklenir
Dockerfile açıldığında      → devops-docker.mdc yüklenir
*.vue dosyası açıldığında   → fe-vue.mdc yüklenir
```

### Continue

`.continue/config.yaml` dosyasını iki adımda yapılandırın:

**Adım 1 — API anahtarı ekleyin:**
```yaml
models:
  - name: Claude Sonnet 4.6
    provider: anthropic
    model: claude-sonnet-4-6
    apiKeyVar: ANTHROPIC_API_KEY
```

**Adım 2 — Projenize uygun beceri kurallarını aktif edin:**
```yaml
rules:
  # Temel kurallar (her zaman aktif)
  - .continue/rules/01-coding-standards.md
  - .continue/rules/02-architecture.md
  - .continue/rules/03-testing.md
  - .continue/rules/04-security.md

  # Backend — birini seçin:
  - .continue/rules/skills/lang-java.md
  # - .continue/rules/skills/lang-dotnet.md
  # - .continue/rules/skills/lang-python.md

  # Frontend — birini seçin:
  # - .continue/rules/skills/fe-react.md
  # - .continue/rules/skills/fe-nextjs.md
  # - .continue/rules/skills/fe-vue.md
  # - .continue/rules/skills/fe-angular.md

  # Mobil — birini seçin:
  # - .continue/rules/skills/mobile-ios.md
  # - .continue/rules/skills/mobile-android.md
  # - .continue/rules/skills/mobile-flutter.md
  # - .continue/rules/skills/mobile-reactnative.md
```

---

## Dil ve Framework Becerileri

| Kategori | Beceri | Temel Kapsam |
|----------|--------|-------------|
| **Backend** | Java / Spring Boot | Constructor injection (field injection yasak), JPA N+1 önleme, Flyway, JUnit 5, Java 21: record, sealed class, virtual thread |
| | .NET / C# | Minimal API, Clean Architecture (MediatR CQRS), EF Core, xUnit, NSubstitute, C# 12 |
| | Python / FastAPI | Pydantic v2, SQLAlchemy 2 async, pytest, strict tip belirtimi, uv paket yöneticisi |
| | TypeScript / Node.js | Strict mod, discriminated union, Zod, Bun, Vitest |
| | Go | Deyimsel Go, tüketici tarafında arayüz, hata sarmalama, tablo odaklı testler |
| **Frontend** | React | Hooks, TanStack Query, React Hook Form + Zod, RTL + MSW |
| | Next.js App Router | Server Components, Server Actions, ISR önbellekleme, streaming |
| | Vue 3 | Composition API, Pinia Setup Stores, composable'lar |
| | Angular 17+ | Standalone bileşenler, Signals, NgRx Signal Store, RxJS disiplini |
| **Mobil** | iOS (Swift / SwiftUI) | async/await + actor'lar, @Observable, NavigationStack, SwiftData, Swift Testing |
| | Android (Kotlin / Compose) | StateFlow, Hilt, Room + Flow, Compose UDF, Turbine testi |
| | Kotlin Multiplatform (KMP) | Paylaşımlı mantık + Compose Multiplatform UI, Ktor, SQLDelight, Koin, expect/actual, SKIE Swift entegrasyonu |
| | Flutter / Dart | Riverpod + kod üretimi, GoRouter, Freezed, drift, EAS / Fastlane |
| | React Native / Expo | Strict TS, FlashList, React Navigation v7, Zustand + TanStack Query, EAS |
| **Altyapı** | Docker | Çok aşamalı build, root olmayan kullanıcı, Compose healthcheck, güvenlik taraması |
| | GitHub Actions CI/CD | Kalite kapıları, OIDC kimlik doğrulama, canary/blue-green |
| | Microservices | Sınırlı bağlamlar, devre kesici, Saga deseni, OpenTelemetry |

Yeni beceri ekleme için [skills/README.md](skills/README.md) dosyasına bakın.

> **Continue beceri eşitliği notu:** Cursor'da 17 beceri dosyası bulunur. `.continue/rules/skills/` ile 12 dosya gelir — `lang-typescript`, `lang-go`, `be-microservices`, `devops-docker` ve `devops-cicd` eksiktir. Projenizde bu teknolojilerden birini kullanıyorsanız, `.continue/rules/skills/` altında ilgili `.md` dosyasını oluşturun ve `.continue/config.yaml` dosyasına ekleyin. Mevcut `.continue` beceri dosyalarının yapısını örnek alın.

---

## Cursor Prompt Dosyaları

Cursor'un Claude Code gibi yerel bir slash komut kaydı yoktur; ancak **prompt dosyaları** —
`@` referansıyla sohbete enjekte edilen Markdown iş akışı şablonları — desteklenmektedir.
`.cursor/prompts/` dizini, Claude Code slash komutlarıyla birebir eşdeğer bir yapı sunar.

### Nasıl Kullanılır

```
@.cursor/prompts/requirements.md

Giriş endpoint'ine JWT tabanlı kimlik doğrulama ekle.
```

Cursor, prompt şablonunu sohbete enjekte eder. `@` referansından sonra yazdığınız metin,
Claude komutlarındaki `$ARGUMENTS` değişkeninin karşılığıdır.

Daha zengin bağlam için kaynak dosyalarla birleştirilebilir:

```
@.cursor/prompts/review.md @src/api/orders.ts
```

### Claude Code ile Karşılaştırma

| Claude Code | Cursor | Aynı iş akışı? |
|------------|--------|---------------|
| `/requirements Kimlik doğrulama ekle` | `@.cursor/prompts/requirements.md` + "Kimlik doğrulama ekle" | Evet |
| `/architect` | `@.cursor/prompts/architect.md` | Evet |
| `/qa` | `@.cursor/prompts/qa.md` | Evet |
| `/loop PROJ-42` | `@.cursor/prompts/loop.md` + "PROJ-42" | Evet |

Temel farklar:
- Cursor, proje kurallarını (`.cursor/rules/`) otomatik yükler — prompt dosyaları bunu tekrarlamaz
- `standup.md` prompt'u, git komutunu terminalde çalıştırıp çıktıyı yapıştırmanızı ister
- Prompt dosyalarındaki bash komutları Cursor'ın entegre terminalinde manuel olarak çalıştırılmalıdır
- Cursor, prompt dosyalarının içinde doğrudan `@file` çapraz referansını destekler

Tam referans için [`.cursor/prompts/README.md`](.cursor/prompts/README.md) dosyasına bakın.

---

## Slash Komutları Referansı

### İnsan Destekli Komutlar

Her adımı siz tetikler ve çıktıyı incelersiniz.

| Komut | Amaç | Ne Zaman Kullanılır |
|-------|------|---------------------|
| `/requirements` | Ham gereksinimleri → kullanıcı hikayeleri, kabul kriterleri, sıralı görev listesi ve Tamamlanma Tanımına dönüştürür | Her özelliğe başlamadan önce |
| `/architect` | Tek bir satır kod yazmadan önce tasarım belgesi oluşturur | 50 satırı aşan her görev için |
| `/implement` | Alt-üst yapılandırılmış uygulama + yerleşik öz-inceleme kontrol listesi | Kodlama sırasında |
| `/qa` | Tam kalite döngüsü: lint, tip kontrolü, testler, kapsam, güvenlik denetimi | PR açmadan önce |
| `/review` | Proje standartları ve OWASP'a göre derin kod incelemesi | Uygulamadan sonra |
| `/test` | Kapsamlı test paketi üretir (mutlu yol, kenar durumlar, hata durumları) | Herhangi bir modül veya fonksiyon için |
| `/debug` | Sistematik hata teşhisi: hipotezler → araştırma → düzeltme → önleme | Bir hatada takılı kalındığında |
| `/deploy` | Deployment öncesi kontrol listesi, yürütme adımları, deployment sonrası izleme planı | Her deployment'tan önce |
| `/migrate` | Güvenli DB migrasyonu: Expand-Contract deseni, toplu strateji, geri alma planı | Şema değişiklikleri için |
| `/sprint` | Sprint planlaması: kapasite analizi, backlog seçimi, görev dağılımı, risk kaydı | Sprint başlangıcında |
| `/docs` | Kaynaktan API belgeleri, mimari belgeleri veya kullanıcı kılavuzları oluşturur | Uygulamadan sonra |
| `/standup` | Git geçmişinden günlük standup özeti üretir | Günün başında |

### Otonom Ajan Komutları

Her adım için insan müdahalesi olmadan çalışır — ajan karar verir ve harekete geçer.

| Komut | Amaç | Nasıl Çalışır |
|-------|------|---------------|
| `/triage <issue>` | Bir JIRA/Linear/GitHub issue'sunun bu projeye ait olup olmadığını değerlendirir | 4 boyutta güven skoru hesaplar (varlık eşleşmesi, fonksiyonel alan, kod sahipliği, hariç tutma). ≥ 0.80 → otomatik kabul, < 0.30 → otomatik red, 0.30–0.79 → eskalasyon |
| `/groom` | Bir backlog grubunu triage + gereksinim analizinden geçirir | Yapılandırılmış issue tracker'ı tarar, her adaya `/triage` uygular, kabul edilenlere `/requirements` çalıştırır. `max_concurrent_tasks` sınırına uyar |
| `/loop <görev-id>` | Tek görev için tam otonom geliştirme döngüsünü çalıştırır | Çalıştırır: tasarım → branch oluşturma → uygulama (yeniden deneme döngüsüyle) → QA → PR oluşturma → CI izleme → deployment → deployment sonrası izleme. Kesintide kaldığı yerden devam eder |
| `/escalate <önem> <tetikleyici> <görev>` | Ajan ilerleyemediğinde yapısal eskalasyon başlatır | Bağlamı paketler, Slack/GitHub/e-posta bildirimleri gönderir, insan yanıt komutlarını dinler (`AGENT_RESUME`, `AGENT_SKIP_TASK`, `AGENT_ABANDON`, vb.) |

---

## Otonom Ajan Döngüsü

JIRA issue'sundan üretime kadar tam yaşam döngüsü:

```
Issue Tracker (JIRA / Linear / GitHub)
         │
         ▼
  /groom — zamanlanmış yoklama veya webhook tetikleyicisi
         │
         ▼
  /triage — domain doğrulama
  ┌──────────────────────────────────────────┐
  │  Güven skoru hesaplaması:                │
  │    Varlık eşleşmesi       maks. +0.30   │
  │    Fonksiyonel alan       maks. +0.40   │
  │    Kod sahipliği          maks. +0.20   │
  │    Hariç tutma sinyali    ceza  -0.30   │
  └──────────────────────────────────────────┘
         │
  ≥0.80 KABUL   0.30–0.79 ESKALASYON   <0.30 RED
         │
         ▼
  /requirements — kullanıcı hikayeleri + sıralı görev listesi (JSON + Markdown)
         │
  güven kapısı ── düşükse ──▶ /escalate medium requirements_confidence_low
         │
         ▼
  /architect — tasarım belgesi + risk değerlendirmesi
         │
  risk = YÜKSEK ──▶ /escalate high design_risk_high ──▶ AGENT_APPROVE_DESIGN bekle
         │
         ▼
  /loop — uygulama döngüsü (görev başına):
  ┌──────────────────────────────────────────────────────┐
  │  görevi uygula → testleri çalıştır                  │
  │  BAŞARISIZ → /debug → düzelt → yeniden test          │
  │              (max_retries kadar)                     │
  │  hâlâ BAŞARISIZ → /escalate high implement_max_retries│
  └──────────────────────────────────────────────────────┘
         │
         ▼
  /qa — lint + tip kontrolü + test kapsamı + güvenlik
  BAŞARISIZ → otomatik düzeltme girişimi → hâlâ BAŞARISIZ → /escalate high qa_gate_failure
         │
         ▼
  PR oluştur (issue'ya bağlantılı, QA raporu + risk seviyesiyle)
  CI izle → BAŞARISIZ → /escalate high ci_pipeline_failure
         │
         ▼
  Birleştirmeyi bekle (yapılandırılmışsa otomatik, değilse insan bekle)
         │
         ▼
  /deploy staging (otomatik) → /deploy production (insan onayı kapısı)
         │
         ▼
  Deployment sonrası izleme (30 dakika)
  Hata oranı yükselişi → otomatik geri alma + /escalate critical post_deploy_error_spike
         │
         ▼
  Issue tracker güncelle → Tamamlandı ✓
  Audit kaydı yaz
```

### Ajan Güvenlik Mekanizmaları

| Mekanizma | Nasıl Çalışır |
|-----------|--------------|
| **Kalıcı durum** | Her görevin ilerlemesi `.agent/state/<görev-id>.json` dosyasına kaydedilir — ajan kesintide kaldığı yerden devam eder |
| **Kill switch** | `touch .agent/STOP` — ajan bir sonraki faz geçişinden önce durur |
| **Audit izi** | Her karar, komut ve maliyet `.agent/audit/<tarih>-*.jsonl` dosyasına kaydedilir |
| **Korunan yollar** | `agent.config.yaml` dosyasında ajanın hiçbir zaman değiştiremeyeceği dosya ve komutlar tanımlanır |

### Eskalasyona İnsan Yanıtı

Ajan eskalasyon yaptığında GitHub issue'suna veya JIRA ticket'ına yorum ekleyin:

| Yorum | Etki |
|-------|------|
| `AGENT_RESUME` | Mevcut fazdan devam et |
| `AGENT_RESUME phase=architect` | Belirli bir fazdan yeniden başla |
| `AGENT_CLARIFY: <metin>` | Açıklama ver; ajan bunu kullanarak yeniden dener |
| `AGENT_APPROVE_DESIGN` | Yüksek riskli tasarımı onayla; uygulamaya geç |
| `AGENT_APPROVE_DEPLOY` | Üretim deployment'ını onayla |
| `AGENT_SKIP_TASK` | Mevcut alt görevi atla; bir sonrakine geç |
| `AGENT_REASSIGN` | Ajan kuyruğundan çıkar; insan geliştiriciye aktar |
| `AGENT_ABANDON` | Bu ticket üzerindeki tüm çalışmayı durdur |

---

## MCP Sunucuları

`.cursor/mcp.json` dosyasında önceden yapılandırılmıştır. İlgili sunucunun `"disabled": true` satırını kaldırın ve gerekli ortam değişkenlerini `.env` dosyasına ekleyin:

| Sunucu | Amaç | Gerekli Ortam Değişkenleri |
|--------|------|---------------------------|
| `filesystem` | Çalışma alanı dosyalarını oku/yaz | — (otomatik) |
| `git` | Git geçmişi, diff'ler, blame | — (otomatik) |
| `github` | Issue'lar, PR'lar, CI durumu | `GITHUB_TOKEN` |
| `postgres` | Şema inceleme, sorgu testi | `DATABASE_URL` |
| `jira` | Issue çek, durumu güncelle — `/triage` ve `/groom` için | `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` |
| `linear` | Jira'ya alternatif | `LINEAR_API_KEY` |
| `slack` | Eskalasyon bildirimleri gönder | `SLACK_BOT_TOKEN`, `SLACK_TEAM_ID` |
| `sentry` | Deployment sonrası hata izleme | `SENTRY_AUTH_TOKEN`, `SENTRY_ORG` |
| `brave-search` | Dokümantasyon için web araması | `BRAVE_API_KEY` |
| `memory` | Oturumlar arası kalıcı bellek | — |
| `puppeteer` | Tarayıcı otomasyonu / E2E | — |

---

## Claude Code Hook'ları

Araç kullanımında otomatik çalışan olay tetikleyicileri:

| Hook | Dosya | Ne Yapar |
|------|-------|---------|
| `UserPromptSubmit` | `toon.mjs` | Her prompt öncesi token kullanım optimizasyonu |
| `PostToolUse(Write)` | `post-write.mjs` | Korunan yol yazımında uyarı verir; audit izine kaydeder |
| `PostToolUse(Bash)` | `audit-log.mjs` | Her komutu + çıkış kodunu kaydeder; yasak komut desenlerini işaretler |
| `Stop` | `on-stop.mjs` | Oturum sonu özeti: devam eden görevleri listeler, kill switch aktifse uyarır |

---

## Geliştirme İş Akışları

### Önerilen Sıra

```
Gereksinim Geldi
      │
      ▼
/requirements   → Kullanıcı hikayeleri ve görev listesi
      │
      ▼
/architect      → Tasarım belgesi (kod yazmadan önce zorunlu)
      │
      ▼
/implement      → Alt-üst katmanlı uygulama + testler
      │
      ▼
/qa             → Kalite kapıları (lint + testler + güvenlik)
      │
      ▼
/review         → Kod incelemesi
      │
      ▼
PR Aç → Birleştir → Staging Deployment
      │
      ▼
/deploy production   → Üretim deployment kontrol listesi
```

### Etkili Prompt Kalıpları

**Bağlam verin:**
```
Hexagonal mimari kullandığımızı ve domain katmanının altyapı
bağımlılığı olmadığını göz önünde bulundurarak, ödeme servisi için
yeniden deneme mantığı ekle.
```

**Minimal değişiklik isteyin:**
```
Başarısız testi düzeltmek için en küçük değişikliği yap.
Çevresindeki kodu refactor etme.
```

**AI'yı rotada tutun:**
```
Tasarım aşamasında repository desenini kullanmaya karar verdik.
O yaklaşımda kal; doğrudan DB erişimi kullanma.
```

### AI Çıktısını İncelerken Dikkat Edilecekler

Şunları görürseniz **duraksayın ve dikkatlice inceleyin:**
- Tartışmadığınız yeni bir bağımlılık ekleniyor
- Kod tabanının geri kalanıyla tutarsız bir desen kullanılıyor
- Hata yönetimi eksik
- Test edilmeyen bir kod yolu var
- Dokunmadığınız dosyalar değiştiriliyor
- "Gelecekteki esneklik için" gereksiz soyutlama ekleniyor

---

## Yapılandırma Rehberi

### agent.config.yaml

`agent.config.yaml` dosyasındaki TODO alanlarını doldurun:

```yaml
agent:
  mode: semi-autonomous          # autonomous | semi-autonomous | assisted
  id: "benim-projem-ajan"

issue_tracker:
  provider: jira
  jira:
    server_url: "${JIRA_URL}"
    project_key: "PROJ"          # Jira proje anahtarınız
    poll_interval_minutes: 15

domain:
  acceptance_threshold: 0.80     # Bu eşiğin üstü → otomatik kabul
  rejection_threshold: 0.30      # Bu eşiğin altı → otomatik red

autonomy:
  gates:
    implement:
      max_retries: 3             # Test başarısızlığında maks. deneme sayısı
      max_hours: 8               # Görev başına zaman aşımı (saat)
  require_approval_for_risk:
    - high                       # Yüksek riskli değişiklikler insan onayı gerektirir

escalation:
  primary_channel: slack
  slack:
    webhook_url_env: "SLACK_WEBHOOK_URL"
    channel: "#geliştirici-uyarıları"
```

### Domain Sınırlarını Tanımlama

`docs/context/domain-boundaries.md` dosyasını doldurun. Bu dosya ajanın triage kararının temelidir:

```markdown
## Bu Proje Neyin Sorumlusu?

### Kapsam İçi
- Sipariş yönetimi (oluşturma, güncelleme, iptal, sorgulama)
- Ödeme işleme (ödeme alma, iade, mutabakat)
- Stok takibi (stok seviyeleri, rezervasyonlar, yeniden sipariş tetikleyicileri)

### Kapsam Dışı
- Kullanıcı kimlik doğrulama → Auth servisi
- Ürün kataloğu → Catalog servisi
- Pazarlama sayfaları → Marketing ekibi

### Tipik Kapsam İçi İstekler
✅ "Ödeme webhook zaman aşımında yeniden deneme mantığı ekle"
✅ "Sipariş geçmişi API'sini sayfalandır"

### Tipik Kapsam Dışı İstekler
❌ "Google ile SSO girişi ekle"        → Auth servisi
❌ "Ürün açıklamasını güncelle"        → Catalog servisi
```

### Git'e Ne Commit Edilir?

| ✅ Commit Et | ❌ Commit Etme |
|-------------|---------------|
| `.cursor/rules/**` | `.env` |
| `.continue/config.yaml` (API anahtarsız) | `.agent/state/**` (çalışma zamanı) |
| `.claude/commands/**` | `.agent/audit/**` (çalışma zamanı) |
| `agent.config.yaml` (gizli bilgisiz) | `.claude/settings.local.json` |
| `docs/**` | `.env.*` gerçek değerlerle |
| `CLAUDE.md` | `node_modules/`, `__pycache__/` vb. |

`.gitignore` bu kuralları zaten uygular.

---

## Sıkça Sorulan Sorular

**S: /loop ile /implement arasındaki fark nedir?**

`/implement` insan destekli bir komuttur — siz her adımı tetikler ve çıktıyı onaylarsınız. Tek bir görev için yapılandırılmış kod + test üretir.

`/loop` ise tam otonom ajan komutudur. JIRA'dan alınan onaylanmış bir görevi baştan sona teslim eder: tasarım belgesi oluşturur, branch açar, kodu yazar, testleri çalıştırır (başarısız olursa otomatik düzeltir), QA kapılarından geçirir, PR oluşturur, CI'ı izler ve deployment sonrası metrikleri kontrol eder. İnsan müdahalesi yalnızca `/escalate` koşullarında gerekir.

---

**S: Otonom ajan ne zaman insan onayı ister?**

Ajan şu durumlarda durur ve bekler:
- Tasarım riski `yüksek` olarak değerlendirildiğinde (`AGENT_APPROVE_DESIGN` beklenir)
- Bir test `max_retries` kez denenmesine rağmen geçemediğinde
- QA kalite kapısı başarısız olduğunda ve otomatik düzeltme çalışmadığında
- Üretim deployment'ı yapılmak istendiğinde (her zaman insan onayı gerekir)
- Triage güven skoru eşikler arasında kaldığında (0.30–0.80)

---

**S: Ajan yanlış bir JIRA issue'su alırsa ne olur?**

`docs/context/domain-boundaries.md` dosyasındaki kapsam tanımını güncelleyin — bu ajanın triage kararının temelidir. Anlık müdahale için:

```bash
# Ajanı hemen durdurun
touch .agent/STOP

# Belirli bir görevi bırakın (GitHub issue veya JIRA ticket'ına yorum ekleyin)
AGENT_ABANDON
```

---

**S: /groom ile /loop birlikte nasıl kullanılır?**

```bash
# 1. Backlog'u tara ve gereksinim analizi yap
/groom

# 2. Belirli bir görevi otonom olarak geliştir
/loop PROJ-42

# 3. Kesilen bir görevi kaldığı yerden devam ettir
/loop resume PROJ-42
```

`/groom`, onaylanan görevler için `/loop`'u otomatik çalıştırabilir veya sadece hazırlık yapıp bırakabilir — bu `agent.config.yaml` dosyasındaki `mode` ayarına bağlıdır.

---

**S: Birden fazla ajan paralel çalışabilir mi?**

`agent.config.yaml` dosyasında `max_concurrent_tasks: N` değerini artırabilirsiniz. Her görev kendi git branch'i ve durum dosyasına sahip olur. Bağımlı görevler, bağımlılıklarının PR'ları birleştirilene kadar bekler.

---

**S: Hangi modeller destekleniyor?**

`.continue/config.yaml` dosyasındaki `models` bölümünü düzenleyerek seçebilirsiniz:
- **Claude Sonnet 4.6** — sohbet, uygulama, karmaşık görevler (önerilen)
- **Claude Haiku 4.5** — otomatik tamamlama (hızlı ve ekonomik)
- **Ollama (yerel model)** — internet bağlantısı gerektirmez, ücretsiz

---

**S: Doğrulama betiği ne kontrol eder?**

```bash
bash scripts/validate-ai-config.sh
```

73 dosyayı kontrol eder:
- **PASS** — Dosya mevcut
- **WARN** — Dosya mevcut ama TODO içeriyor (özelleştirme bekleniyor)
- **FAIL** — Dosya eksik (geliştirmeye başlamadan önce düzeltilmeli)

---

## Mimari Karar Kayıtları (ADR)

İskelet, `docs/architecture/decisions/0001-template.md` dosyasında tek bir ADR şablonu içerir. Projenizdeki her önemli tasarım kararı için gerçek ADR'lar oluşturun:

```bash
# Her yeni karar için şablonu kopyalayın
cp docs/architecture/decisions/0001-template.md \
   docs/architecture/decisions/0002-veritabani-secimi.md
```

Sıralı numaralama kullanın. Kabul edilen her ADR'ı `docs/architecture/overview.md` dosyasına bağlayın.

---

## Doğrulama Betiği Referansı

```bash
bash scripts/validate-ai-config.sh
```

Tüm yapılandırma dosyalarında 73 kontrol çalıştırır:

| Sonuç | Anlam |
|-------|-------|
| `PASS` | Dosya mevcut |
| `WARN` | Dosya mevcut ama TODO içeriyor (özelleştirme bekleniyor) |
| `FAIL` | Dosya eksik — geliştirmeye başlamadan önce düzeltilmeli |

> **Bilinen kapsam eksikliği:** Betik, 16 slash komutundan 14'ünü doğrular. `standup.md` ve `security-audit.md` dosyaları `.claude/commands/` altında mevcuttur ve çalışır; ancak doğrulama betikine dahil edilmemiştir. Yanlışlıkla silinmeleri durumunda betik bunu tespit etmez.

---

## Yardım ve Geri Bildirim

- Sorunlar için: [GitHub Issues](https://github.com/mehmet-yildirim/AI-Native-Repo-Skeleton/issues)
- İskelet katkıları için bu depoyu fork'layın ve PR açın
