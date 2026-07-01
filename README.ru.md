<h1 align="center">FocusQuest</h1>

<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a></sub></p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17%2B-7C4CFF?logo=apple&logoColor=white" alt="iOS 17+">
  <img src="https://img.shields.io/badge/macOS-14%2B-7C4CFF?logo=apple&logoColor=white" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-5.9%2B-9B6BFF?logo=swift&logoColor=white" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/Built%20with-SwiftUI-46E6FF" alt="Built with SwiftUI">
  <img src="https://img.shields.io/badge/status-MVP-8B81AD" alt="Status: MVP">
</p>

<p align="center">
Pomodoro-таймер с RPG-геймификацией в стиле тёмного фэнтези.<br>
За выполненные сессии фокуса персонаж качает уровни, открывает локации,
собирает предметы и достижения. Под фокус играет lofi-эмбиент.
</p>

<p align="center">
<img src="docs/screenshots/timer.png" width="280" alt="Экран таймера">
</p>

## Экраны

<table>
  <tr>
    <td align="center"><img src="docs/screenshots/map.png" width="220"><br><sub>Карта странствий</sub></td>
    <td align="center"><img src="docs/screenshots/inventory.png" width="220"><br><sub>Инвентарь</sub></td>
    <td align="center"><img src="docs/screenshots/achievements.png" width="220"><br><sub>Достижения</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/settings.png" width="220"><br><sub>Настройки</sub></td>
    <td align="center"><img src="docs/screenshots/reward.png" width="220"><br><sub>Награда за сессию</sub></td>
    <td align="center"><img src="docs/screenshots/demo.gif" width="220"><br><sub>В движении</sub></td>
  </tr>
</table>

<!-- Скриншоты и demo.gif кладутся в docs/screenshots/ (см. .gitkeep там). -->

## Что это

Приложение для управления фокус-сессиями (техника Pomodoro) с элементами RPG.
Идея простая: превратить рутину концентрации в маленькое приключение — каждая
завершённая сессия двигает персонажа вперёд, открывает новые места и даёт добычу.

Платформы: iOS 17+, macOS 14+. Внешних зависимостей нет.

## Что внутри

- Таймер считает оставшееся время от абсолютной `Date`, а не накоплением тиков —
  корректно переживает сворачивание, блокировку экрана и возврат в приложение.
- Прогрессия: опыт за сессию (с бонусом за отсутствие пауз), уровни, разблокировка
  шести локаций по уровню, выпадение предметов четырёх редкостей, семь достижений.
- Тёмно-фэнтезийный интерфейс: полноэкранные сцены локаций, свечения, кольцо
  таймера с пульсом, живые частицы под каждую локацию (светлячки, снег, искры, листья).
- Lofi-музыка под фокус — треки чередуются от сессии к сессии.
- Локализация RU/EN с мгновенным переключением в настройках.
- Экран статистики с недельным графиком фокус-времени.
- Live Activity и Dynamic Island с обратным отсчётом (опционально, отдельный Widget Extension).
- Учитывает системные «Уменьшение движения» и Dynamic Type.

## Архитектура

MVVM на Observation (`@Observable`), хранение — SwiftData (модели спроектированы
под будущую синхронизацию через CloudKit). Бизнес-логика вынесена в отдельные сервисы:
`TimerEngine`, `Progression`, `LootService`, `LocationService`, `AchievementService`,
`StatsCalculator`, `AudioService`, `NotificationService`. UI-слой (SwiftUI) построен
поверх них и переиспользует общую тему и токены дизайна.

## Сборка

Открыть проект в Xcode и запустить нужный таргет (симулятор iPhone или macOS).
Внешних зависимостей нет.

## Статус

В разработке, MVP.

## Ассеты и лицензии

- Lofi-музыка — CC0 1.0 (public domain).
- Арт локаций — плейсхолдер-иллюстрации, при желании заменяются финальными.
- Шрифты — Space Grotesk и Manrope (OFL); при их отсутствии используются системные.
