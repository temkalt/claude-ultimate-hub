# 🌟 Claude Code Ultimate Hub — Веб-Портал и Интерактивный Центр Управления v3.0

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude_Code-2.1.235+-blue.svg)](https://github.com/anthropics/claude-code)
[![Verified Tools](https://img.shields.io/badge/Tools-1%2C000%2B_Verified-emerald.svg)](https://github.com/temkalt/claude-ultimate-hub)
[![Translations](https://img.shields.io/badge/Language-English_%7C_Русский-purple.svg)](README.md)

**Крупнейшая в мире открытая инженерная экосистема и центр управления для Anthropic Claude Code.**  
*1,000+ проверенных MCP серверов, скиллов, плагинов, LSP, субагентов, экономия токенов (-65%) и 7 слоев защиты.*

[🌐 Открыть Онлайн-Портал Экосистемы](#-1-онлайн-портал-экосистемы-на-сайте) • [⚡ Запуск Центра Управления в 1 команду](#-2-запуск-локального-центра-управления-на-компьютере) • [14 Профилей](#-откалиброванный-флагманский-профиль-master-34-инструмента) • [English Guide (EN)](README.md)

</div>

---

## 🌐 1. Онлайн-Портал Экосистемы (на сайте)

Наш официальный веб-портал позволяет разработчикам в любой момент без установки изучать всю базу:
* **Каталог 1,000+ инструментов**: поиск по 350+ MCP серверам, 320+ скиллам, 80+ субагентам, 40+ LSP.
* **14 Калиброванных профилей**: детальное сравнение стеков под Web, Backend, Security, Data, DevOps, Russia.
* **Интерактивный Калькулятор ROI**: наглядный расчет экономии бюджета API ($100 – $400/мес) с режимом Caveman (-65%).
* **Матрица 300+ Промптов**: готовые проверенные шаблоны для архитектуры, TDD, SQL и безопасности.

---

## ⚡ 2. Запуск Локального Центра Управления (на компьютере)

Чтобы подключить экосистему к вашему локальному **Claude Code** (`~/.claude/`), выполните всего **1 команду в терминале**:

### 💻 Windows (PowerShell):
```powershell
irm https://raw.githubusercontent.com/temkalt/claude-ultimate-hub/main/install.ps1 | iex
```

### 🐧 Linux & macOS (Bash):
```bash
curl -fsSL https://raw.githubusercontent.com/temkalt/claude-ultimate-hub/main/install.sh | bash
```

### 🎯 Что происходит автоматически:
1. Терминал проверяет окружение (Node.js, Git, Claude CLI).
2. Запускается локальный мост исполнения на `http://localhost:3456/`.
3. **Автоматически открывается браузер** со студией управления:
   - **🌟 14 Готовых Профилей**: Применение любого стека в 1 клик.
   - **🧩 Конструктор Сборки**: Сборка кастомного набора из 1,000+ каталога с live-счетчиком токенов.
   - **📁 Мульти-Воркспейс Сканер**: Авто-определение стека проекта и создание локального `.claude/`.
   - **🌐 Менеджер MCP с Live-Пингом**: Проверка соединения и добавление баз данных.
   - **🎯 Создатель SKILL.md**: Визуальный редактор инструкций.
   - **🤖 Студия Субагентов (80+ ролей)**: Роли на Opus, Sonnet, Haiku.
   - **📝 CLAUDE.md Оптимизатор**: Авто-сжатие инструкций (-53% токенов).
   - **🩺 Доктор Системы**: 15 проверок готовности с авторемонтом.
   - **⏪ Снапшоты (Time-Machine)**: Бэкапы и мгновенный откат конфигурации.
   - **⚡ Потоковый Терминал**: Вывод логов исполнения в реальном времени.

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
