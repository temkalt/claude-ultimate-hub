# 🌟 Claude Code Ultimate Hub — Cloud Control Center & 1,000+ Ecosystem v3.0

<div align="center">

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Ftemkalt%2Fclaude-ultimate-hub)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude_Code-2.1.235+-blue.svg)](https://github.com/anthropics/claude-code)
[![Vercel Serverless](https://img.shields.io/badge/Platform-Vercel_Serverless_Edge-black.svg)](https://vercel.com)
[![Verified Tools](https://img.shields.io/badge/Tools-1%2C000%2B_Verified-emerald.svg)](https://github.com/temkalt/claude-ultimate-hub)
[![Translations](https://img.shields.io/badge/Language-English_%7C_Русский-purple.svg)](README_RU.md)

**Крупнейшая в мире открытая инженерная экосистема и облачный веб-центр управления для Claude Code на Vercel Serverless.**  
*1,000+ проверенных MCP серверов, скиллов, плагинов, LSP, субагентов, экономия токенов (-65%) и 7 слоев защиты.*

[☁️ Запустить на Vercel в 1 клик](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Ftemkalt%2Fclaude-ultimate-hub) • [Флагманский профиль Master](#-откалиброванный-флагманский-профиль-master-34-инструмента) • [Каталог 1,000+](#-каталог-из-1000-инструментов) • [Agency Studio](#-agency-studio-80-ai-ролей) • [English Guide (EN)](README.md)

</div>

---

## ☁️ Развертывание на Vercel

Проект полностью оптимизирован для работы в бессерверном облаке Vercel (Edge CDN + Serverless Functions в `api/`):

1. Нажмите кнопку **[Deploy with Vercel](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Ftemkalt%2Fclaude-ultimate-hub)** или выполните:
```bash
npx vercel --prod
```

2. Откройте ваш домен на Vercel (например, `https://claude-ultimate-hub.vercel.app`):
   - **🌟 14 Готовых Профилей**: Выбор и генерация команд установки в 1 клик.
   - **🧩 Конструктор Сборки**: 1,000+ инструментов с динамическим пересчетом токенов.
   - **📁 Мульти-Воркспейс Сканер**: Определение стека проекта и авто-подбор профиля.
   - **⚡ Матрица 300+ Промптов**: Готовые инженерные команды и экспорт в слеш-команды.
   - **📝 CLAUDE.md Оптимизатор**: Сжатие инструкций (-53% токенов) через Vercel Function.
   - **🤖 Студия Субагентов (80+ Ролей)**: Opus/Sonnet/Haiku роли с YAML-frontmatter.
   - **🌐 Менеджер MCP Серверов**: 40+ готовых интеграций (Postgres, Stripe, Playwright, Telegram).

---

## 🎮 Универсальные Команды Установки (CLI)

### Windows (PowerShell):
```powershell
irm https://raw.githubusercontent.com/temkalt/claude-ultimate-hub/main/install.ps1 | iex
```

### Linux & macOS (Bash):
```bash
curl -fsSL https://raw.githubusercontent.com/temkalt/claude-ultimate-hub/main/install.sh | bash
```

---

## 🎯 Откалиброванный флагманский профиль Master (34 инструмента)

| Категория | Инструментов | Состав инструментов | Основное назначение |
|:---|:---:|:---|:---|
| **🔌 Плагины** | 5 | `frontend-design`, `superpowers` (TDD), `context7` (Live Docs), `agentmemory` (Память), `github-plugin` | Интерфейсы без клише ИИ, TDD-дисциплина, свежая документация, 4-уровневая память |
| **🌐 MCP Серверы** | 10 | `stripe`, `supabase`, `postgres`, `sqlite`, `docker`, `playwright`, `notion`, `linear`, `sentry`, `aws` | Платежи, бессерверные БД, Read-Only SQL, E2E тесты Chromium, синхронизация задач |
| **🎯 Скиллы** | 8 | `skill-creator`, `skill-seo`, `skill-caveman` (-65%), `agent-security` (OWASP), `skill-uiux` (67 стилей), `skill-bulletproof`, `skill-dataviz`, `skill-commits` | Создание скиллов, SEO аудит, сжатие токенов, аудит уязвимостей, атомарные PR |
| **⚡ LSP Серверы** | 2 | `lsp-typescript`, `lsp-python` | Мгновенная навигация по AST символам в 10 раз быстрее grep |
| **🤖 Субагенты** | 5 | `agent-architect` (Opus), `agent-codereview`, `agent-tester`, `agent-researcher`, `agent-docs` | Архитектура на Opus, прагматичный код-ревью, генерация тестов, поиск документации |
| **🛡️ Хуки защиты** | 4 | `hook-secrets` (PreTool), `hook-danger` (PreTool), `hook-repomap` (SessionStart), `hook-selfheal` (Stop) | Сканер секретов, блокировщик деструктивных команд, кэш топологии, автодиагностика |
| **ИТОГО** | **34** | **Оптимальный глобальный стек** | **100% Full-Stack покрытие при ~1.2k токенах** |

---

## 📄 Лицензия
MIT License. Свободное и открытое программное обеспечение.
