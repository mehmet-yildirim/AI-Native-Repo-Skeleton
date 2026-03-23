# Initium — Geliştirici Kılavuzu

İnteraktif insan destekli geliştirmeden, JIRA backlog'undan iş alıp Pull Request teslim eden **tam otonom ajan moduna** kadar çalışan, AI-native yazılım geliştirme için üreteme hazır bir proje şablonu.

[Cursor](https://cursor.sh), [Continue](https://continue.dev) ve [Claude Code](https://claude.ai/code) araçlarını kutudan çıkar çıkmaz destekler.

> **English:** [README.md](README.md) · **AI İş Akışı:** [docs/guides/ai-workflow.tr.md](docs/guides/ai-workflow.tr.md)

---

## Initium Ne Sağlar?

| Katman | Yapılandırma | Amaç |
|--------|-------------|------|
| **Claude Code** | `CLAUDE.md`, `.claude/` | Proje talimatları, 27 slash komutu, olay hook'ları |
| **Cursor** | `.cursor/rules/`, `.claude/commands/` | 6 temel kural + 22 beceri kuralı (dosya türüne göre otomatik) + paylaşılan slash komutları |
| **Continue** | `.continue/` | Çok-model yapılandırması, 22 beceri kuralı, kalıcı yönergeler |
| **Otonom Ajan** | `agent.config.yaml`, `docs/guides/agent/` | JIRA taraması, domain doğrulama, tam geliştirme döngüsü, eskalasyon |
| **GitHub** | `.github/` | PR şablonu, issue şablonları, CI iş akışı |
| **Initium senkronizasyonu** | `.initium/initium.json`, `.initium/scripts/sync.{sh,ps1,cmd}` | Özelleştirmelerin üzerine yazmadan Initium güncellemelerini projelerinize aktarma |

---

## Hızlı Başlangıç

```bash
# 1. Klonla
git clone <bu-repo-url> benim-projem && cd benim-projem

# 2. Başlat (git, .env, kontroller)
./.initium/scripts/setup.sh          # macOS/Linux
# .initium\scripts\setup.cmd         # Windows (Batch)
# .\.initium\scripts\setup.ps1       # Windows (PowerShell)

# 3. Etkileşimli sihirbazı çalıştır — proje adı, teknoloji yığını, tracker anahtarlarını doldurur
bash .initium/scripts/init.sh

# 4. AI'nın kalan TODO dosyalarını doldurmasına izin ver
claude
/init <tür> için <kullanıcılar> amacıyla <ad> adlı bir proje geliştiriyorum. Yığın: <dil, framework, DB>.

# 5. Doğrula
bash .initium/scripts/validate.sh   # beklenen: tüm PASS, FAIL yok
```

Kurulumun ardından AI döngüsüyle kodlamaya başla:
```
/requirements <ilk özelliğin>   →  /architect  →  /task plan  →  /implement  →  /qa  →  /deploy
```

> **Projeye yeni misiniz veya ne yapacağınızdan emin değil misiniz?** Claude Code'da veya Cursor'da `/help` yazın — AI sizi durumunuza uygun komuta yönlendirir.

---

## Özelleştirme Kontrol Listesi

### `.initium/scripts/init.sh` + `/init` tarafından otomatik doldurulanlar

| Dosya | Nasıl dolduruluyor |
|-------|--------------------|
| `CLAUDE.md` | Sihirbaz mekanik alanları doldurur; AI kuralları üretir |
| `.cursor/rules/00-project-overview.mdc` | CLAUDE.md ile aynı |
| `docs/context/project-brief.md` | Açıklamandan AI tarafından üretilir |
| `docs/context/tech-stack.md` | Onaylanan yığından AI tarafından üretilir |
| `docs/context/domain-boundaries.md` | AI tarafından üretilir — **otonom ajan için kritik** |
| `docs/context/domain-glossary.md` | Domain analizinden AI tarafından üretilir |
| `docs/architecture/overview.md` | AI tarafından üretilen mimari şablonu |
| `agent.config.yaml` | Sihirbaz kimlikleri; `/init agent:` tracker anahtarlarını doldurur |
| `.github/workflows/ci.yml` | `/init ci:` yığına göre üretir |

### Manuel eylem gerektirenler
- [ ] `.continue/config.yaml` — API anahtarı ekle; yığınına uyan beceri kurallarını yorum satırından çıkar
- [ ] `.env` — kimlik bilgilerini doldur (`.env.example` dosyasından kopyala)
- [ ] `.cursor/mcp.json` — `"disabled": true` kaldırarak MCP sunucularını etkinleştir
- [ ] Tüm AI tarafından üretilen içeriği ilk commit'ten önce gözden geçir ve iyileştir

---

## Proje Yapısı

```
.
├── CLAUDE.md                           # ← DÜZENLE — Claude Code proje talimatları
├── agent.config.yaml                   # ← DÜZENLE — otonom ajan yapılandırması
├── .initium/
│   ├── initium.json                   # Bu projenin hangi Initium sürümünü baz aldığını takip eder
│   ├── scripts/                       # Initium yaşam döngüsü betikleri (setup, sync, validate)
│   └── docs/                          # Initium belgeleri (sync kılavuzu, güncelleme notları)
│
├── .claude/
│   ├── settings.json                   # Araç izinleri + olay hook'ları
│   ├── commands/                       # 27 slash komutu (Claude Code'da / yazarak erişilir)
│   │   ├── help.md                     # /help — komutlara ve iş akışlarına rehberlik
│   │   ├── init.md                     # /init — proje kurulum sihirbazı
│   │   ├── requirements.md … docs.md   # İnsan destekli komutlar (16 adet)
│   │   ├── doc-api.md                  # /doc-api — OpenAPI spec üretimi
│   │   ├── doc-site.md                 # /doc-site — belgelendirme sitesi
│   │   ├── doc-changelog.md            # /doc-changelog — CHANGELOG üretimi
│   │   ├── doc-schema.md               # /doc-schema — veritabanı ERD + tablo referansı
│   │   ├── sync-initium.md            # /sync-initium — Initium güncellemelerini uygula
│   │   ├── triage.md                   # /triage  ← otonom ajan
│   │   ├── groom.md                    # /groom   ← otonom ajan
│   │   ├── loop.md                     # /loop    ← otonom ajan
│   │   └── escalate.md                 # /escalate ← otonom ajan
│   └── hooks/                          # Olay tetikleyicileri (post-write, audit-log, on-stop)
│
├── .cursor/
│   ├── prompts/                        # Cursor prompt dosyaları — Claude komutlarının aynısı
│   ├── rules/
│   │   ├── 00-project-overview.mdc    # ← DÜZENLE — her zaman yüklenir
│   │   ├── 01 … 05-security.mdc       # Temel kurallar (OWASP her zaman yüklü)
│   │   └── skills/ (22 dosya)         # Dosya uzantısına göre otomatik etkinleşir
│   └── mcp.json                       # MCP: GitHub, Jira, Linear, Slack, Sentry…
│
├── .continue/
│   ├── config.yaml                    # ← API ANAHTARLARI EKLE + becerileri etkinleştir
│   └── rules/                         # Temel kurallar + 22 beceri dosyası
│
├── docs/
│   ├── ai-workflow.md / .tr.md        # AI iş akışı rehberi (İngilizce / Türkçe)
│   ├── onboarding.md                  # Yeni geliştirici kılavuzu
│   ├── initium-sync.md               # Initium güncellemelerini projeye aktarma rehberi
│   ├── context/                       # ← TÜMÜNÜ DÜZENLE (AI bağlamı + ajan kapsamı)
│   ├── architecture/                  # ← DÜZENLE + ADR'ler
│   ├── agent/                         # Otonom ajan belgeleri (iş akışı, eskalasyon, güvenlik, belgelendirme…)
│   │   └── schemas/                   # JSON şemaları: görev durumu, QA raporu, güvenlik raporu…
│   └── workflows/                     # 7 iş akışı kılavuzu (gereksinimler → dağıtım)
│
├── skills/README.md                   # Beceri indeksi ve aktivasyon rehberi
├── .agent-templates/webhook-receiver.mjs
└── .initium/
    ├── setup / init / validate        # Her biri için .sh, .cmd, .ps1 sürümleri
    └── sync.{sh,ps1,cmd}             # Initium güncellemelerini uygula
```

---

## Slash Komutları Referansı

### Yardım ve Navigasyon

| Komut | Amaç |
|-------|------|
| `/help` | Tüm mevcut komutları ve tipik iş akışını göster |
| `/help <soru>` | Belirli durumunuz için doğru komuta yönlendir |
| `/help <faz>` | "Bir özelliğe nasıl başlarım?" — o faz için adım adım komut dizisi |

> **Yeni geliştirici ipucu:** Sırada ne yapacağınızdan emin olmadığınızda `/help` her zaman ilk komutunuzdur. Durumunuzu sade bir dille anlatın, AI sizi doğru iş akışı ve komutlara yönlendirir.

### Başlatma

| Komut | Amaç |
|-------|------|
| `/init <açıklama>` | Serbest biçimli proje açıklamasından tüm TODO dosyalarını doldur |
| `/init domain: <açıklama>` | Domain sınırları, sözlük ve ajan anahtar kelimeleri üret |
| `/init stack: <yığın>` | Teknoloji yığını belgesi ve CLAUDE.md komut bölümünü üret |
| `/init ci: <yığın>` | Yığına özgü CI iş akışı adımları üret |
| `/init agent: <anahtarlar>` | Tracker anahtarları, GitHub sahibi/deposu, eskalasyon kanallarını yapılandır |

### İnsan Destekli Geliştirme

| Komut | Amaç | Ne Zaman |
|-------|------|---------|
| `/requirements` | Kullanıcı hikayeleri + kabul kriterleri + sıralı görev listesi + Tamamlanma Tanımı | Her özellikten önce |
| `/architect` | Tek satır kod yazmadan önce tasarım | 50+ satır görevler |
| `/task plan` | Tasarımı takip edilebilir `.agent/tasks/*.md` dosyalarına böl | Tasarım sonrası, kodlama öncesi |
| `/task next` | Bağımlılıklara göre sonraki işlem yapılabilir görevi getir | Uygulama sırasında |
| `/task done <id>` | Görevi tamamlandı olarak işaretle, bağımlıları aç | Her commit sonrası |
| `/task list` | Tüm görevleri ve durumlarını göster | Her zaman |
| `/implement` | Alt-üst yapılandırılmış uygulama + öz-inceleme | Kodlama sırasında |
| `/qa` | Lint + tip + testler + kapsam + güvenlik | PR açmadan önce |
| `/security-audit [hedef]` | OWASP Top 10 + CVE + gizli bilgi taraması | Her PR'dan önce |
| `/review` | Standartlara ve OWASP'a göre kod incelemesi | Uygulamadan sonra |
| `/test` | Kapsamlı testler üret (mutlu yol + kenar + hata) | Her modül için |
| `/debug` | Sistematik teşhis: hipotez → düzeltme → önleme | Takıldığında |
| `/deploy` | Deployment öncesi kontrol listesi + izleme planı | Her deployment |
| `/infra <platform>` | AWS / GCP / şirket içi için Terraform / K8s şablonu | Yeni deployment hedefi |
| `/migrate` | Güvenli DB migrasyonu: Expand-Contract + toplu + geri alma | Şema değişiklikleri |
| `/db <alt-komut>` | DB yaşam döngüsü: `init`, `create`, `dml`, `seed`, `status`, `diff` | DB yönetimi |
| `/sprint` | Sprint planlaması: kapasite + backlog + görevler + risk kaydı | Sprint başlangıcı |
| `/standup` | Git geçmişinden günlük özet | Günün başında |
| `/docs <dosya>` | Kod düzeyinde belgelendirme üret (JSDoc, docstring, GoDoc…) | Uygulamadan sonra |

### Belgelendirme Üretimi

| Komut | Amaç | Çıktı |
|-------|------|-------|
| `/doc-api` | OpenAPI 3.x spec üret + doğrula + ReDoc HTML | `openapi.json` + `docs/api/` |
| `/doc-site` | Belgelendirme sitesi kur veya yeniden oluştur (Docusaurus / MkDocs) | Dağıtılabilir statik site |
| `/doc-changelog` | Git geçmişinden `CHANGELOG.md` üret (git-cliff) | `CHANGELOG.md` + paydaş özeti |
| `/doc-schema` | Veritabanı ERD + tablo referansı + indeks analizi | `docs/database/` |

### Otonom Ajan

| Komut | Amaç |
|-------|------|
| `/triage <issue>` | Domain uygunluk kontrolü: ≥ 0.80 otomatik kabul, 0.30–0.79 eskalasyon, < 0.30 red |
| `/groom` | Toplu backlog işleme: kabul edilenler için triage + gereksinimler |
| `/loop <görev-id>` | Tam otonom döngü: tasarım → uygulama → belgelendirme → QA → güvenlik → PR → deployment |
| `/escalate <önem> <tetikleyici> <id>` | Slack/GitHub/e-posta yönlendirmeli yapısal insan bildirimi |

### İskelet Bakımı

| Komut | Amaç |
|-------|------|
| `/sync-initium` | Initium yeni geliştirmelerini bu projeye aktar |
| `/sync-initium --dry-run` | Herhangi bir şeyi uygulamadan neyin değişeceğini önizle |
| `/sync-initium --check` | Initium güncellemesi mevcut mu kontrol et |

---

## Otonom Ajan Döngüsü

```
JIRA / Linear / GitHub İssue'ları
    │
    ▼ /groom (zamanlanmış veya webhook)
    ▼ /triage — güven puanı hesaplama
    │   Varlık eşleşmesi +0.30 · Fonksiyonel alan +0.40 · Kod sahipliği +0.20
    │   ≥ 0.80 → KABUL   0.30–0.79 → ESKALASYON   < 0.30 → RED
    ▼
    ▼ /requirements — kullanıcı hikayeleri + görev listesi (JSON + Markdown)
    ▼ /architect — tasarım belgesi + risk seviyesi
    │   risk=YÜKSEK → insan onayı kapısı (AGENT_APPROVE_DESIGN)
    ▼ /task plan — tasarımı .agent/tasks/*.md dosyalarına böl
    │   her dosya: durum, kabul kriterleri, bağımlılıklar
    ▼
    ▼ /loop her görev için (.agent/tasks/ mevcutsa okur):
    │   /task next → uygula → /docs → test → /task done → sonraki görev
    │   başarısız? → /debug (maks deneme) → eskalasyon
    ▼ Belgelendirme senkronizasyonu (koşullu):
    │   apiChanges → /doc-api diff · schemaChanges → /doc-schema migrations
    ▼ /qa — lint + tipler + kapsam + güvenlik
    ▼ /security-audit diff — OWASP + CVE kontrolü
    ▼ PR oluştur (issue'ya bağlantılı, QA raporu, risk seviyesi)
    ▼ CI izle → birleştir (otomatik veya insan)
    ▼ /deploy staging (otomatik) → üretim (insan kapısı)
    ▼ 30 dakika deployment sonrası izleme
    │   metrik düşüşü → otomatik geri alma + kritik eskalasyon
    ▼ Issue tracker: Tamamlandı ✓ · Audit kaydı yazıldı
```

**Güvenlik:** kalıcı durum (kesintide kaldığı yerden devam) · kill switch (`touch .agent/STOP`) · korunan yollar · JSONL audit izi

**İnsan yanıt komutları** (GitHub issue veya JIRA ticket'ına yorum ekle):
`AGENT_RESUME` · `AGENT_APPROVE_DESIGN` · `AGENT_APPROVE_DEPLOY` · `AGENT_CLARIFY: <metin>` · `AGENT_SKIP_TASK` · `AGENT_REASSIGN` · `AGENT_ABANDON`

---

## Dil ve Framework Becerileri

Cursor, beceri kurallarını dosya uzantısına göre otomatik etkinleştirir. Continue için `.continue/config.yaml` dosyasında yorumdan çıkarman gerekir.

| Kategori | Beceriler |
|----------|-----------|
| **Backend** | Java/Spring Boot · .NET/ASP.NET Core · Python/FastAPI · TypeScript/Node.js · Go |
| **Frontend** | React · Next.js App Router · Vue 3 · Angular 17+ |
| **Mobil** | iOS/Swift · Android/Kotlin · Kotlin Multiplatform · Flutter/Dart · React Native/Expo |
| **Altyapı** | Docker · GitHub Actions CI/CD · AWS · GCP · Şirket İçi (k3s/Vault/Ansible) |
| **Çapraz kesen** | Veritabanı Migrasyonları · Microservices · Güvenlik SAST · Belgelendirme Üretimi |

Tam indeks, aktivasyon kılavuzu ve yeni beceri ekleme için: [skills/README.md](skills/README.md)

---

## MCP Sunucuları

`.cursor/mcp.json` dosyasında yapılandırılmıştır. Etkinleştirmek için: `"disabled": true` satırını kaldır ve gerekli ortam değişkenlerini `.env` dosyasına ekle.

| Sunucu | Amaç | Ortam Değişkenleri |
|--------|------|-------------------|
| `filesystem` · `git` | Çalışma alanı dosyaları, git geçmişi | — (otomatik) |
| `github` | Issue'lar, PR'lar, CI durumu | `GITHUB_TOKEN` |
| `jira` | Issue çek/güncelle — `/triage`, `/groom` tarafından kullanılır | `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` |
| `linear` | Jira'ya alternatif | `LINEAR_API_KEY` |
| `slack` | Eskalasyon bildirimleri | `SLACK_BOT_TOKEN`, `SLACK_TEAM_ID` |
| `sentry` | Deployment sonrası hata izleme | `SENTRY_AUTH_TOKEN`, `SENTRY_ORG` |
| `postgres` · `brave-search` · `memory` · `puppeteer` | DB incelemesi, web araması, bellek, tarayıcı otomasyonu | bkz. `.cursor/mcp.json` |

---

## Projeyi Güncel Tutma

Initium yeni komutlar, güncellenmiş beceri kuralları veya güvenlik düzeltmeleri aldığında:

```bash
# macOS / Linux / Git Bash
bash .initium/scripts/sync.sh          # etkileşimli: diff gösterir, güvenli dosyaları otomatik uygular
bash .initium/scripts/sync.sh --auto   # etkileşimsiz: tüm Initium-owned dosyaları uygula
bash .initium/scripts/sync.sh --check  # sadece güncelleme mevcut mu kontrol et
```

```powershell
# Windows (PowerShell — önerilir)
.\.initium\scripts\sync.ps1            # etkileşimli
.\.initium\scripts\sync.ps1 -Auto     # etkileşimsiz
.\.initium\scripts\sync.ps1 -Check    # sadece kontrol et
```

```bat
:: Windows (Batch — PowerShell'e otomatik yönlendirir)
.initium\scripts\sync.cmd
.initium\scripts\sync.cmd --auto
.initium\scripts\sync.cmd --check
```

Senkronizasyon betiği `.initium/initium.json` kullanarak her dosyayı sınıflandırır:
- **Initium-owned** (komutlar, beceri kuralları, ajan belgeleri) → güvenle otomatik uygulanır
- **birleştirme gerekli** (`.continue/config.yaml`, `mcp.json`, `ci.yml`) → diff olarak gösterilir, sen karar verirsin
- **proje-owned** (`CLAUDE.md`, `docs/context/`, `agent.config.yaml`) → asla dokunulmaz

Tam rehber ve her dosya türü için birleştirme stratejileri: [.initium/docs/sync-guide.md](.initium/docs/sync-guide.md)

---

## Temel Prensipler

1. **Bağlam her şeydir.** AI, projenin amacını ve kısıtlamalarını anladığında daha iyi çıktı üretir. `docs/context/` dosyaları ve beceri kuralları bu bağlamı kalıcı olarak sağlar — her prompt'ta tekrarlamak gerekmez.

2. **Kurallar tekrara karşı.** Standartları beceri dosyalarında bir kez tanımla. "Constructor injection kullan", "her zaman test yaz", "tüm sorguları parametreleştir" — bir kez söyle, her oturum uygulasın.

3. **Yapılandırılmış iş akışları.** Slash komutları tekrarlayan iş akışlarını kodlar; AI bunları tutarlı şekilde uygular — ham gereksinimden birleştirilmiş, dağıtılmış, belgelenmiş PR'a kadar.

4. **İnsanlar sınırı belirler, ajanlar çalıştırır.** Ajan yapılandırılmış eşikler dahilinde özerk hareket eder. Her riskli karar (yüksek riskli tasarım, üretim deployment'ı) insan onayı gerektirir. Her eylem kayıt altına alınır.

---

## Daha Fazla Okuma

| Belge | İçerik |
|-------|--------|
| [docs/guides/ai-workflow.tr.md](docs/guides/ai-workflow.tr.md) | Tam AI-native geliştirme iş akışı referansı |
| [docs/guides/team.tr.md](docs/guides/team.tr.md) | AI-native geliştirme için ekip rolleri, yapısı ve optimizasyonu |
| [docs/guides/onboarding.md](docs/guides/onboarding.md) | Yeni geliştirici kurulum kılavuzu (İngilizce) |
| [docs/guides/onboarding.tr.md](docs/guides/onboarding.tr.md) | Yeni geliştirici kurulum kılavuzu (Türkçe) |
| [.initium/docs/sync-guide.md](.initium/docs/sync-guide.md) | Initium güncellemelerini projeye aktarma |
| [docs/guides/agent/autonomous-workflow.md](docs/guides/agent/autonomous-workflow.md) | Ajan durum makinesi, fazlar, kapılar |
| [docs/guides/agent/jira-server-setup.md](docs/guides/agent/jira-server-setup.md) | Şirket içi Jira Server operatör kılavuzu |
| [docs/guides/agent/security-evaluator.md](docs/guides/agent/security-evaluator.md) | Güvenlik değerlendirme mimarisi |
| [docs/guides/agent/documentation-agent.md](docs/guides/agent/documentation-agent.md) | Belgelendirme üretim araçları ve pipeline |
| [skills/README.md](skills/README.md) | Tam beceri indeksi ve aktivasyon kılavuzu |
| [.initium/docs/UPDATES.md](.initium/docs/UPDATES.md) | Initium sürümleri için değişiklik kaydı |
