# AI-Native Geliştirme İskeleti — Geliştirici Kılavuzu

Bu iskelet, yeni veya mevcut projelerde **yapay zeka destekli otonom yazılım geliştirme** için hazır bir başlangıç yapısı sunar. [Cursor](https://cursor.sh), [Continue](https://continue.dev) ve [Claude Code](https://claude.ai/code) araçlarını kutudan çıkar çıkmaz destekler.

---

## İçindekiler

1. [Bu İskelet Ne Sağlar?](#bu-i̇skelet-ne-sağlar)
2. [Hızlı Başlangıç](#hızlı-başlangıç)
3. [Proje Yapısı](#proje-yapısı)
4. [AI Araç Desteği](#ai-araç-desteği)
5. [Dil ve Framework Becerileri](#dil-ve-framework-becerileri)
6. [Slash Komutları Referansı](#slash-komutları-referansı)
7. [Otonom Ajan Döngüsü](#otonom-ajan-döngüsü)
8. [Geliştirme İş Akışları](#geliştirme-i̇ş-akışları)
9. [Yapılandırma Rehberi](#yapılandırma-rehberi)
10. [Sıkça Sorulan Sorular](#sıkça-sorulan-sorular)

---

## Bu İskelet Ne Sağlar?

| Katman | Ne Sağlar |
|--------|-----------|
| **Claude Code** | `CLAUDE.md` proje talimatları + 16 özel slash komutu |
| **Cursor** | Dosya türüne göre otomatik etkinleşen 18 kural dosyası (`.mdc`) |
| **Continue** | Çok-model yapılandırması, satır içi slash komutları, kalıcı kurallar |
| **GitHub** | PR şablonu, issue şablonları, CI iş akışı |
| **Otonom Ajan** | JIRA/Linear entegrasyonu, domain doğrulama, tam geliştirme döngüsü |

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

### 3. Projenizi Özelleştirin

Aşağıdaki dosyaları projenize göre doldurun:

| Dosya | Ne Yazılacak |
|-------|-------------|
| `CLAUDE.md` | Proje adı, teknoloji yığını, temel komutlar, kodlama kuralları |
| `.cursor/rules/00-project-overview.mdc` | Proje bağlamı (Cursor için) |
| `.continue/config.yaml` | Model API anahtarları, etkin beceri kuralları |
| `docs/context/project-brief.md` | Projenin ne yaptığı ve kimler için olduğu |
| `docs/context/tech-stack.md` | Teknoloji seçimleri ve gerekçeleri |
| `docs/context/domain-boundaries.md` | Otonom ajan için hangi JIRA işlerinin bu projeye ait olduğu |
| `docs/architecture/overview.md` | Sistem mimarisi |
| `agent.config.yaml` | JIRA/Linear bağlantısı, otonom ajan davranışı |

### 4. Yapılandırmayı Doğrulayın

```bash
bash scripts/validate-ai-config.sh
```

73 PASS, 0 FAIL görmelisiniz. WARN mesajları doldurulması gereken TODO alanlarını gösterir.

### 5. AI Kodlamaya Başlayın

```bash
# Claude Code ile başlatın
claude

# İlk komut — projeyi tasarlamadan önce gereksinimleri analiz edin
/requirements Kullanıcı girişi için JWT tabanlı kimlik doğrulama ekle
```

---

## Proje Yapısı

```
.
├── CLAUDE.md                               # ← MUTLAKA DÜZENLE
├── agent.config.yaml                       # ← MUTLAKA DÜZENLE (otonom ajan için)
│
├── .cursor/
│   ├── rules/                              # Cursor kural dosyaları
│   │   ├── 00-project-overview.mdc        # ← MUTLAKA DÜZENLE
│   │   ├── 01-coding-standards.mdc        # Kodlama standartları
│   │   ├── 02-architecture.mdc            # Mimari kılavuzlar
│   │   ├── 03-testing.mdc                 # Test standartları
│   │   ├── 04-git-workflow.mdc            # Git iş akışı
│   │   ├── 05-security.mdc               # Güvenlik (OWASP)
│   │   └── skills/                        # Dil/framework becerileri
│   │       ├── lang-java.mdc
│   │       ├── lang-dotnet.mdc
│   │       ├── lang-python.mdc
│   │       ├── lang-typescript.mdc
│   │       ├── lang-go.mdc
│   │       ├── fe-react.mdc
│   │       ├── fe-nextjs.mdc
│   │       ├── fe-vue.mdc
│   │       ├── fe-angular.mdc
│   │       ├── be-microservices.mdc
│   │       ├── devops-docker.mdc
│   │       └── devops-cicd.mdc
│   └── mcp.json                            # MCP sunucu yapılandırması
│
├── .continue/
│   ├── config.yaml                         # ← API anahtarlarını buraya ekle
│   └── rules/
│       ├── 01-coding-standards.md
│       ├── 02-architecture.md
│       ├── 03-testing.md
│       ├── 04-security.md
│       └── skills/                         # Continue için beceri kuralları
│
├── .claude/
│   ├── settings.json                       # Claude Code izinleri + hook'lar
│   ├── commands/                           # Özel slash komutları (16 adet)
│   └── hooks/                              # Olay tetikleyicileri
│       ├── post-write.mjs                  # Yazma sonrası güvenlik denetimi
│       ├── audit-log.mjs                   # Komut audit kaydı
│       └── on-stop.mjs                     # Oturum sonu özeti
│
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── ISSUE_TEMPLATE/
│   └── workflows/ci.yml
│
├── docs/
│   ├── context/                            # ← TÜMÜNÜ DÜZENLE
│   │   ├── project-brief.md
│   │   ├── tech-stack.md
│   │   ├── domain-glossary.md
│   │   └── domain-boundaries.md           # Otonom ajan için kapsam tanımı
│   ├── architecture/
│   │   ├── overview.md                     # ← DÜZENLE
│   │   └── decisions/                      # Mimari Karar Kayıtları (ADR)
│   ├── agent/                              # Otonom ajan belgeleri
│   │   ├── autonomous-workflow.md          # Tam durum makinesi
│   │   ├── escalation-protocol.md          # Eskalasyon kılavuzu
│   │   ├── decision-log-template.md        # Audit izi şeması
│   │   └── schemas/                        # JSON şemaları
│   ├── workflows/                          # Geliştirme iş akışları
│   ├── ai-workflow.md                      # AI geliştirme rehberi
│   └── onboarding.md                       # Yeni geliştirici rehberi
│
├── skills/
│   └── README.md                           # Beceri indeksi ve aktivasyon rehberi
│
└── scripts/
    ├── setup.sh                            # Tek seferlik kurulum
    └── validate-ai-config.sh              # 73 noktalı doğrulama
```

---

## AI Araç Desteği

### Claude Code

Claude Code, projenizin kök dizininde çalıştırdığınızda `CLAUDE.md` dosyasını otomatik yükler.

```bash
# Claude Code'u başlatın
claude

# Tüm özel komutları görüntüleyin
/help
```

**Otomatik yüklenen bağlam:**
- `CLAUDE.md` — proje talimatları, mimari, kodlama kuralları
- `.claude/commands/` — 16 özel slash komutu
- `.claude/settings.json` — izinler ve hook'lar

### Cursor

`.cursor/rules/` klasöründeki `.mdc` dosyaları, dosya türüne göre **otomatik olarak** etkinleşir. Hiçbir manuel ayar gerekmez.

```
*.java dosyası açıldığında → lang-java.mdc otomatik yüklenir
*.tsx dosyası açıldığında  → fe-react.mdc ve fe-nextjs.mdc yüklenir
Dockerfile açıldığında     → devops-docker.mdc yüklenir
```

**MCP sunucularını etkinleştirmek için** `.cursor/mcp.json` dosyasında ilgili sunucunun `"disabled": true` satırını kaldırın ve gerekli ortam değişkenlerini `.env` dosyasına ekleyin.

### Continue

`.continue/config.yaml` dosyasını açıp şu ayarları yapın:

**1. API anahtarı ekleyin:**
```yaml
models:
  - name: Claude Sonnet 4.6
    provider: anthropic
    model: claude-sonnet-4-6
    apiKeyVar: ANTHROPIC_API_KEY   # .env dosyasında bu değişkeni tanımlayın
```

**2. Projenize uygun beceri kurallarını aktif edin:**
```yaml
rules:
  # Temel kurallar (her zaman aktif)
  - .continue/rules/01-coding-standards.md
  - .continue/rules/02-architecture.md
  - .continue/rules/03-testing.md
  - .continue/rules/04-security.md

  # Projenize uygun dil/framework kuralını yorumdan çıkarın:
  - .continue/rules/skills/lang-java.md       # Java projesi için
  # - .continue/rules/skills/lang-dotnet.md   # .NET projesi için
  # - .continue/rules/skills/fe-react.md      # React projesi için
  # - .continue/rules/skills/fe-nextjs.md     # Next.js projesi için
```

---

## Dil ve Framework Becerileri

Beceriler, AI araçlarına dile özgü derin bağlam sağlar. Cursor'da dosya uzantısına göre **otomatik**, Continue'da `.continue/config.yaml` üzerinden **manuel** olarak etkinleştirilir.

### Backend Diller

| Beceri | Kapsam |
|--------|--------|
| **Java** | Spring Boot (constructor injection zorunlu), JPA/Hibernate, Flyway, JUnit 5, Java 21 özellikleri (record, sealed class, virtual thread) |
| **.NET / C#** | ASP.NET Core minimal API, Clean Architecture, EF Core, xUnit, NSubstitute, FluentAssertions, C# 12 |
| **Python** | FastAPI, Pydantic v2, SQLAlchemy 2.x async, pytest, strict tip belirtimi, uv paket yöneticisi |
| **TypeScript** | Strict mod, discriminated union, Zod, Bun/Node.js ESM, Vitest |
| **Go** | Deyimsel Go, arayüzler tüketici tarafında tanımlanır, hata sarmalama, tablo odaklı testler |

### Frontend Framework'ler

| Beceri | Kapsam |
|--------|--------|
| **React** | Hooks, TanStack Query, React Hook Form + Zod, RTL + MSW testi |
| **Next.js** | App Router, Server Components, Server Actions, ISR önbellekleme |
| **Vue 3** | Composition API, Pinia Setup Stores, composable'lar, Vue Router |
| **Angular** | Standalone bileşenler, Signals, NgRx Signal Store, RxJS disiplini |

### Altyapı

| Beceri | Kapsam |
|--------|--------|
| **Docker** | Çok aşamalı build, root olmayan kullanıcı, Compose healthcheck, güvenlik taraması |
| **CI/CD** | GitHub Actions pipeline, kalite kapıları, canary/blue-green, OIDC kimlik doğrulama |
| **Microservices** | Sınırlı bağlamlar, devre kesici, Saga deseni, OpenTelemetry |

---

## Slash Komutları Referansı

### İnsan Destekli Komutlar

Bu komutlar sizin yönetiminizde çalışır — her adımda siz kontroldasınız.

| Komut | Kullanım |
|-------|---------|
| `/requirements <konu>` | Gereksinimleri kullanıcı hikayeleri, kabul kriterleri ve görev listesine dönüştürür |
| `/architect <özellik>` | Kod yazmadan önce tasarım belgesi oluşturur |
| `/implement <görev>` | Yapılandırılmış alt-üst uygulamayla kod + test yazar |
| `/qa` | Tam kalite döngüsü: lint, tip kontrolü, test kapsamı, güvenlik |
| `/review` | Proje standartlarına göre derin kod incelemesi |
| `/test <dosya>` | Belirtilen dosya için kapsamlı test paketi oluşturur |
| `/debug <hata>` | Sistematik hata teşhisi (hipotez → araştırma → düzeltme) |
| `/deploy <ortam>` | Deployment öncesi kontrol listesi + izleme planı |
| `/migrate <açıklama>` | Güvenli veritabanı migrasyon planlaması (Expand-Contract deseni) |
| `/sprint <tema>` | Sprint planlaması: kapasite, görev dağılımı, risk kaydı |
| `/docs <dosya>` | API veya modül belgelendirmesi oluşturur |
| `/standup` | Git geçmişinden günlük standup özeti üretir |

### Otonom Ajan Komutları

Bu komutlar insan müdahalesi olmadan çalışmak üzere tasarlanmıştır.

| Komut | Kullanım |
|-------|---------|
| `/triage <issue>` | JIRA/Linear issue'nun bu projeye ait olup olmadığını güven skoru ile değerlendirir |
| `/groom` | Backlog'dan toplu issue işler: triage + gereksinim analizi |
| `/loop <görev-id>` | Tek görev için tam otonom geliştirme döngüsünü çalıştırır |
| `/escalate <önem> <tetikleyici> <görev>` | İnsan müdahalesi gereken durumları iletir |

---

## Otonom Ajan Döngüsü

İskelet, JIRA/Linear backlog'undan issue alıp eksiksiz Pull Request oluşturana kadar bağımsız çalışabilen bir ajan altyapısı içerir.

### Nasıl Çalışır?

```
JIRA / Linear / GitHub Issues
          │
          ▼
    /groom — Backlog tarama
    (her 15 dakikada bir ya da webhook ile)
          │
          ▼
    /triage — Domain doğrulama
    ┌───────────────────────────────┐
    │ Bu issue projeye ait mi?      │
    │ Güven skoru hesaplanır:       │
    │   Varlık eşleşmesi    +0.30  │
    │   Fonksiyonel alan    +0.40  │
    │   Kod sahipliği       +0.20  │
    │   Hariç tutma sinyali  -0.30 │
    └───────────────────────────────┘
          │
    ≥0.80 → KABUL   0.30-0.79 → ESKALASYON   <0.30 → RED
          │
          ▼
    /requirements — Gereksinim analizi
    (kullanıcı hikayeleri + görev listesi JSON olarak kaydedilir)
          │
          ▼
    /architect — Tasarım
    (risk=yüksek ise insan onayı beklenir)
          │
          ▼
    /loop — Uygulama döngüsü
    ┌─────────────────────────────────┐
    │ Her görev için:                 │
    │   1. Uygula                     │
    │   2. Testleri çalıştır          │
    │   3. Başarısızsa → /debug + dene│
    │   4. Maks. deneme aşıldıysa →   │
    │      /escalate                  │
    └─────────────────────────────────┘
          │
          ▼
    /qa — Kalite kapıları
    (lint + tip + test + kapsam + güvenlik)
          │
          ▼
    Pull Request oluştur
    CI izle → birleştir
          │
          ▼
    /deploy → Staging otomatik
    Production → İnsan onayı
          │
          ▼
    30 dk. izleme
    Metrik düşüşü → Otomatik geri alma
          │
          ▼
    JIRA: Tamamlandı ✓
```

### Yapılandırma

`agent.config.yaml` dosyasını açın ve şu alanları doldurun:

```yaml
agent:
  mode: semi-autonomous          # autonomous | semi-autonomous | assisted

issue_tracker:
  provider: jira                 # jira | linear | github | azure-devops
  jira:
    server_url: "${JIRA_URL}"
    project_key: "PROJ"          # ← Jira proje anahtarınız

domain:
  acceptance_threshold: 0.80     # Bu eşiğin üstü otomatik kabul
  rejection_threshold: 0.30      # Bu eşiğin altı otomatik red

autonomy:
  gates:
    implement:
      max_retries: 3             # Test başarısızlığında maks. deneme
      max_hours: 8               # Görev başına zaman aşımı
  require_approval_for_risk:
    - high                       # Yüksek riskli değişiklikler insan onayı gerektirir
```

### Domain Sınırları Tanımlama

`docs/context/domain-boundaries.md` dosyasını doldurun. Ajan bu dosyayı okuyarak hangi JIRA issue'larının bu projeyle ilgili olduğuna karar verir:

```markdown
## Bu Proje Neyin Sorumlusu?

### Kapsam İçi
- Sipariş yönetimi (oluşturma, güncelleme, iptal)
- Ödeme işleme (ödeme, iade)
- Stok takibi

### Kapsam Dışı
- Kullanıcı kimlik doğrulama (Auth servisi)
- Ürün kataloğu (Catalog servisi)
- Pazarlama sayfaları

### Tipik Kapsam İçi İstekler
✅ "Ödeme webhook zaman aşımında yeniden deneme ekle"
✅ "Sipariş durumu API'sini sayfalandır"

### Tipik Kapsam Dışı İstekler
❌ "Google ile SSO girişi ekle"  → Auth servisi
❌ "Ürün açıklamasını güncelle"  → Catalog servisi
```

---

## Geliştirme İş Akışları

### Önerilen Geliştirme Sırası

```
Gereksinim Geldi
      │
      ▼
/requirements   → Kullanıcı hikayeleri ve görev listesi
      │
      ▼
/architect      → Tasarım belgesi (kod yazmadan önce)
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
PR Aç → Birleştir → Staging Deploy
      │
      ▼
/deploy production   → Üretim deployment kontrol listesi
```

### Etkili Prompt Yazma

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
O yaklaşımda kal, doğrudan DB erişimi kullanma.
```

### Dikkat Edilmesi Gerekenler

AI tarafından üretilen kod şunları içeriyorsa **duraksayın ve inceleyin:**

- Tartışmadığınız yeni bir bağımlılık ekleniyor
- Kod tabanının geri kalanıyla tutarsız bir desen kullanılıyor
- Hata yönetimi eksik
- Test edilmeyen bir kod yolu var
- "Gelecekteki esneklik için" gereksiz soyutlama ekleniyor
- Dokunmadığınız dosyalar değiştiriliyor

---

## Yapılandırma Rehberi

### .env Dosyası

`.env.example` dosyasını kopyalayın ve değerleri doldurun:

```bash
cp .env.example .env
```

```env
# Uygulama
NODE_ENV=development
PORT=3000

# Veritabanı
DATABASE_URL=postgresql://kullanici:sifre@localhost:5432/veritabanim

# AI Araçları
ANTHROPIC_API_KEY=sk-ant-...

# Otonom Ajan (isteğe bağlı)
JIRA_URL=https://sirketim.atlassian.net
JIRA_EMAIL=gelistirici@sirketim.com
JIRA_API_TOKEN=...
SLACK_WEBHOOK_URL=https://hooks.slack.com/...
```

### MCP Sunucularını Etkinleştirme

`.cursor/mcp.json` dosyasında ilgili sunucunun `"disabled": true` satırını silin:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_TOKEN}"
      }
      // "disabled": true  ← Bu satırı silin
    },
    "jira": {
      "command": "npx",
      "args": ["-y", "mcp-server-jira"],
      "env": {
        "JIRA_URL": "${env:JIRA_URL}",
        "JIRA_EMAIL": "${env:JIRA_EMAIL}",
        "JIRA_API_TOKEN": "${env:JIRA_API_TOKEN}"
      }
      // "disabled": true  ← Bu satırı silin
    }
  }
}
```

### Yeni Beceri Ekleme

Projenize ait olmayan bir dil veya framework için beceri eklemek istiyorsanız:

**1. Cursor kuralı oluşturun** (`.cursor/rules/skills/lang-rust.mdc`):
```markdown
---
description: Rust geliştirme standartları
globs: ["**/*.rs", "**/Cargo.toml"]
alwaysApply: false
---

# Rust Standartları
...
```

**2. Continue kuralı oluşturun** (`.continue/rules/skills/lang-rust.md`):
```markdown
# Rust Standartları (özet)
...
```

**3. `skills/README.md` indeksine ekleyin.**

**4. `.continue/config.yaml`'da aktif edin:**
```yaml
rules:
  - .continue/rules/skills/lang-rust.md
```

---

## Sıkça Sorulan Sorular

**S: Otonom ajan ne zaman insan onayı ister?**

Ajan şu durumlarda durur ve bekler:
- Tasarım riski `yüksek` olarak değerlendirildiğinde
- Bir test `max_retries` (varsayılan: 3) kez denenmesine rağmen geçemediğinde
- QA kalite kapısı başarısız olduğunda
- Üretim deployment'ı yapılmak istendiğinde (her zaman insan onayı gerekir)
- Güven skoru eşiğin altında kaldığında

---

**S: Ajan yanlış bir JIRA issue'su alıp çalışmaya başlarsa ne olur?**

`docs/context/domain-boundaries.md` dosyasındaki kapsam tanımını güncelleyin.
Ayrıca şu yöntemlerle manuel müdahale edebilirsiniz:

```bash
# Ajanı hemen durdurun
touch .agent/STOP

# Belirli bir görevi bırakın (JIRA issue'suna yorum ekleyin)
AGENT_ABANDON
```

---

**S: Birden fazla ajan paralel çalışabilir mi?**

`agent.config.yaml` dosyasında `max_concurrent_tasks: N` değerini artırabilirsiniz. Her görev kendi git branch'i ve durum dosyasına sahip olur. Bağımlı görevler, bağımlılıklarının PR'ları birleştirilene kadar bekler.

---

**S: Tüm AI komutları Claude kullanıyor mu?**

Hayır. Farklı modeller kullanabilirsiniz:
- **Claude Sonnet 4.6** — sohbet, uygulama, karmaşık görevler (önerilen)
- **Claude Haiku 4.5** — otomatik tamamlama (hızlı ve ekonomik)
- **Ollama (yerel model)** — internet bağlantısı olmadan çalışma

`.continue/config.yaml` dosyasındaki `models` bölümünü düzenleyerek yapılandırabilirsiniz.

---

**S: Hangi dosyaları Git'e commit etmeliyim?**

| Commit ET | Commit ETME |
|-----------|-------------|
| Tüm `.cursor/rules/**` | `.env` |
| `.continue/config.yaml` (API anahtarları olmadan) | `.agent/state/**` (çalışma zamanı) |
| `.claude/commands/**` | `.agent/audit/**` (çalışma zamanı) |
| `agent.config.yaml` (secrets olmadan) | `.claude/settings.local.json` |
| `docs/**` | `node_modules/`, `__pycache__/` vb. |
| `CLAUDE.md` | `.env.*` ile gerçek değerler |

`.gitignore` bu kuralları zaten uygular.

---

**S: Doğrulama betiği nasıl çalışır?**

```bash
bash scripts/validate-ai-config.sh
```

Betik 73 dosyayı kontrol eder:
- **PASS** — Dosya mevcut
- **WARN** — Dosya mevcut ama hâlâ TODO içeriyor (özelleştirme gerekli)
- **FAIL** — Dosya eksik (geliştirmeye başlamadan önce düzeltilmeli)

---

## Yardım ve Geri Bildirim

- Sorunlar için: [GitHub Issues](https://github.com/mehmet-yildirim/AI-Native-Repo-Skeleton/issues)
- İskelet katkıları için bu depoyu fork'layın ve PR açın
