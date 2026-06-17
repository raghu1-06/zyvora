# ZYVORA - Complete App Analysis & Feature Inventory

**App Purpose:** Dual-life productivity system combining reminders, attendance tracking, alarms, calendar management, and analytics for both personal and professional modes.

**Version:** 1.0.0 | **Built With:** Flutter, Provider, SQLite, flutter_local_notifications

---

## 1. COMPLETE APP STRUCTURE

### Directory Tree
```
lib/
├── main.dart                          # App entry, MultiProvider setup, theme init
├── data/
│   └── database_service.dart          # SQLite database operations
├── models/
│   ├── reminder.dart                  # Reminder data model
│   ├── alarm.dart                     # Alarm data model
│   ├── attendance_record.dart         # Attendance & SubjectAttendance models
│   ├── insight.dart                   # AI-generated insight model
│   └── zyvora_role.dart              # Enums: LifeMode, ZyvoraRole
├── screens/
│   ├── splash_screen.dart             # Initialization & routing
│   ├── onboarding_screen.dart         # First-time app introduction
│   ├── auth_screen.dart               # User authentication
│   ├── mode_selection_screen.dart     # Choose Personal/Professional
│   ├── role_selection_screen.dart     # Choose Professional role
│   ├── main_wrapper.dart              # Main navigation hub (5-tab floating dock)
│   ├── home_dashboard.dart            # OLD unified dashboard
│   ├── tasks_screen.dart              # Reminders grouped by day
│   ├── attendance_screen.dart         # Attendance tracking UI
│   ├── calendar_screen.dart           # Calendar view (table_calendar)
│   ├── alarms_screen.dart             # Manage alarms
│   ├── profile_screen.dart            # User stats & quick settings
│   ├── settings_screen.dart           # App preferences
│   ├── analytics_screen.dart          # Charts, insights, stats
│   ├── attendance_placeholder_screen.dart # Placeholder for personal mode
│   ├── edit_reminder_sheet.dart       # (Possibly unused)
│   ├── personal/
│   │   └── personal_dashboard.dart    # Personal mode dashboard (embedded nav)
│   └── professional/
│       └── professional_dashboard.dart # Professional mode dashboard (embedded nav)
└── widgets/
    ├── add_reminder_sheet.dart        # Modal to create/edit reminders
    ├── add_alarm_sheet.dart           # Modal to create/edit alarms
    ├── reminder_tile.dart             # Single reminder UI component
    ├── alarm_tile.dart                # Single alarm UI component
    ├── attendance_bar.dart            # Subject attendance progress bar
    ├── bunk_calculator_card.dart      # "Classes you can skip" calculator
    ├── countdown_card.dart            # Next upcoming reminder timer
    ├── dashboard_overview_card.dart   # Dashboard summary card
    ├── empty_state.dart               # Empty list placeholder
    ├── greeting_header.dart           # Time-based greeting
    ├── insight_card.dart              # AI insight display
    ├── mode_card.dart                 # Mode selection card
    ├── premium_card.dart              # Premium feature showcase
    ├── premium_dashboard_header.dart  # Dashboard hero header
    ├── productivity_ring.dart         # Circular progress indicator
    ├── quick_action_card.dart         # Action button card
    ├── quick_action_strip.dart        # Row of quick actions
    ├── reminder_tile.dart             # Reminder list item
    ├── safe_form_widgets.dart         # Reusable form inputs
    ├── section_header.dart            # Section title/subtitle
    ├── smart_summary_card.dart        # AI summary widget
    ├── stat_card.dart                 # Statistics display card
    ├── today_timeline.dart            # Timeline of today's reminders
    ├── week_summary_card.dart         # Weekly completion summary
    └── zyvora_floating_nav.dart       # Custom floating dock navigator

├── services/
│   ├── app_controller.dart            # ChangeNotifier: Main state (reminders, user, mode, streak)
│   ├── attendance_service.dart        # ChangeNotifier: Subject & attendance management
│   ├── alarm_service.dart             # ChangeNotifier: Alarm CRUD & scheduling
│   ├── notification_service.dart      # Notification scheduling & initialization
│   ├── intelligence_engine.dart       # AI insights generator
│   └── main_tab_index.dart            # ChangeNotifier: Current tab state
└── utils/
    ├── app_theme.dart                 # Color system, typography, radius, animations
    ├── app_constants.dart             # Days, categories, role enums
    ├── time_utils.dart                # Time parsing and formatting
    ├── error_handler.dart             # Input validation, error messages
    ├── notification_prefs.dart        # Notification preferences
    └── safe_notifier.dart             # SafeNotifier mixin for state management
```

---

## 2. CURRENT FEATURES - DETAILED

### A. REMINDERS (Core Feature)
- **Life Mode Split:** Personal vs. Professional
  - **Personal:** Medicine, Gym, Study, Water, Sleep, Family, Habit, Custom
  - **Professional:** 
    - Student: Class, Assignment, Exam, Study Session, Lab, Project, Custom
    - Employee: Meeting, Task, Deadline, Shift, Focus Session, Custom
    - Teacher/Freelancer: Custom categories
- **Reminder Properties:**
  - Title, Day (Monday-Sunday), Time (hour:minute)
  - Repeat Type: Once, Daily, Weekly
  - Priority: Low, Medium, High
  - Notifications: Toggle on/off
  - Alarms: Toggle on/off (plays system sound + vibrate)
  - Notes: Optional text field
  - Completion Status: Mark done/incomplete
  - Category per life mode
- **CRUD Operations:** Create, read, update, delete reminders
- **Views:**
  - Tasks Screen: Grouped by weekday, sorted by time
  - Calendar Screen: Table calendar with reminders displayed
  - Home Dashboard: Quick view of today's reminders

### B. ATTENDANCE TRACKING (Professional Mode)
- **Subject Management:**
  - Add/remove subjects dynamically
  - Track multiple subjects independently
- **Attendance Records:**
  - Mark present/absent for each date
  - Optional notes for each record
  - Historical data persistence
- **Statistics:**
  - Per-subject: Total, Present, Absent counts
  - Overall attendance percentage
  - At-risk detection (< 75%)
  - Bunkable classes calculator: How many more absences allowed?
- **Views:**
  - Attendance Screen: Overall stats + per-subject bars
  - Bunk Calculator Card: Predict how many classes can be skipped

### C. ALARMS (System-level)
- **Lightweight Alarm System:**
  - Label, Hour, Minute
  - Repeat Patterns: One-shot, Daily, Weekdays, Weekends, Custom days
  - Sounds: Default, Gentle, Chime
  - Vibration: Toggle
  - Enable/Disable: Without deleting
- **Scheduling:** System notifications with sound + vibrate
- **Storage:** SharedPreferences persistence
- **View:** Alarms Screen with add/edit modal

### D. CALENDAR (Interactive)
- **table_calendar Integration:**
  - Month view, week view toggle
  - Click date to see day's reminders
  - Navigate months
- **Reminder Display on Calendar:**
  - Color-coded by category
  - Click to edit/delete
- **Responsive Design:**
  - Adapts to screen size

### E. ANALYTICS & INSIGHTS (AI-Powered)
- **Intelligence Engine Generates:**
  - "Productivity Today" insight (% completed)
  - "Best Focus Window" (hour with most completions)
  - "Consistency Check" (weakest day of week)
  - Burnout detection
  - Streak tracking (current day streak)
- **Charts:**
  - Weekly completion bar chart (7-day history)
  - Category distribution pie chart
  - Productivity ring (circular % progress)
- **Stats Cards:**
  - Completed, Pending, Day Streak, Today's Count
- **Views:**
  - Analytics Screen (charts + insights)
  - Dashboard Overview Cards

### F. NOTIFICATIONS & REMINDERS
- **Two Systems:**
  1. **Reminder Notifications:** Per-reminder toggle, scheduled weekly
  2. **System Alarms:** Separate alarm system with own scheduling
- **Features:**
  - Push notifications to device
  - Timezone support (flutter_timezone)
  - Sound + vibration
  - Android-specific channel setup

### G. PROFILE & STREAKS
- **User Profile:**
  - Name (customizable)
  - Life Mode + Role display
  - Current day streak
  - Today's productivity %
- **Streak System:**
  - 30-day lookback
  - Tracks completion on each day
  - Resets on 0 completions in a day

### H. SETTINGS & PREFERENCES
- **Available:**
  - Username edit
  - Dark/Light mode toggle
  - Theme switching
  - Notification preferences
  - Reset/logout options

---

## 3. NAVIGATION FLOW

### App Navigation Architecture
```
SplashScreen (routing logic)
│
├─→ [Not onboarded] → OnboardingScreen → AuthScreen → ModeSelectionScreen
├─→ [Not auth] → AuthScreen → ModeSelectionScreen
├─→ [First launch] → ModeSelectionScreen → [Role if Professional]
└─→ [All set] → MainWrapper
       │
       ├─ Personal Mode:
       │   PersonalDashboard (embedded)
       │   ├─ Tab 0: Dashboard (home)
       │   ├─ Tab 1: Tasks (TasksScreen)
       │   ├─ Tab 2: Attendance Placeholder (stub)
       │   ├─ Tab 3: Calendar (CalendarScreen)
       │   └─ Tab 4: Profile (ProfileScreen)
       │
       └─ Professional Mode:
           ProfessionalDashboard (embedded)
           ├─ Tab 0: Dashboard (home)
           ├─ Tab 1: Tasks (TasksScreen)
           ├─ Tab 2: Attendance (AttendanceScreen)
           ├─ Tab 3: Calendar (CalendarScreen)
           └─ Tab 4: Profile (ProfileScreen)

Secondary Screens (accessed from Profile):
├─ Settings Screen
├─ Analytics Screen
└─ Alarms Screen

Modals:
├─ AddReminderSheet (create/edit reminder)
├─ AddAlarmSheet (create/edit alarm)
├─ EditReminderSheet (possible alternative)
```

### Navigation Implementation
- **Pattern:** Named routes + direct MaterialPageRoute
- **Tab Navigation:** 
  - MainWrapper: IndexedStack with 5 screens
  - Uses MainTabIndex provider for state
  - Custom floating dock at bottom (blur + glassmorphism effect)
- **Modal Navigation:**
  - showModalBottomSheet for reminder/alarm forms
  - Returns data via Result pattern
- **Deep Linking:** Minimal support (framework ready but not fully implemented)

---

## 4. UI/UX ISSUES & DESIGN PROBLEMS

### Critical Issues:
1. **Navigation Inconsistency:**
   - MainWrapper has old HomeDashboard route (not used)
   - PersonalDashboard & ProfessionalDashboard have duplicate nav inside them
   - Embedded navigation in dashboards causes complexity
   - Mixed patterns: MainWrapper uses IndexedStack + floating dock, while dashboards have internal navigation
   - **Action:** Consolidate to single navigation pattern

2. **Floating Dock Styling Inconsistency:**
   - MainWrapper has custom _FloatingDockNav (blur, border, shadow)
   - ZyvoraFloatingNav widget exists separately but may be unused
   - Unclear which is the source of truth
   - **Action:** Choose one navigation widget, remove duplicate

3. **Modal Bottom Sheet Consistency:**
   - AddReminderSheet used everywhere
   - EditReminderSheet exists but not actively used
   - Should consolidate: single sheet handles both add & edit

4. **Empty States:**
   - Some screens lack empty state widgets
   - Profile screen has no empty state for alarms/analytics
   - **Action:** Add EmptyState components across all lists

5. **Responsive Design Gaps:**
   - No tablet optimization
   - Desktop web not supported (SQLite + local notifications unavailable)
   - Floating dock may overflow on small screens
   - **Action:** Add responsive breakpoints, test on various sizes

6. **Color Usage Scattered:**
   - Some widgets use hardcoded colors instead of ZyvoraColors
   - Inconsistent opacity values (.35, .72, .2, .1, etc.)
   - **Action:** Audit all colors, enforce design tokens

7. **Typography Inconsistencies:**
   - Mix of Inter font via GoogleFonts
   - Some widgets override text styles without reason
   - Line heights vary: 1.2, 1.3, default
   - **Action:** Create standardized text classes/mixins

8. **Spacing Issues:**
   - Padding varies: 18, 16, 12, 8, 4 (not standardized)
   - Gaps between sections: sometimes 14, 12, 8
   - No defined spacing scale (8px, 16px, 24px, etc.)
   - **Action:** Define spacing tokens (xs: 4, sm: 8, md: 16, lg: 24, xl: 32)

9. **Loading States:**
   - Some async operations lack loaders
   - AlarmsScreen has no loading feedback for operations
   - AttendanceScreen operations silently fail if errors occur
   - **Action:** Add SkeletonLoaders or progress indicators

10. **Form Validation:**
    - AddReminderSheet uses SafeFormWidgets but validation is minimal
    - No clear error feedback for failed operations
    - Email/auth validation is present but not comprehensive
    - **Action:** Add real-time validation, better error UX

### Medium Issues:
- Insight cards could be more prominent/actionable
- Settings screen is text-heavy, could use more visual organization
- Analytics charts could benefit from legends/labels
- Reminder tile completion animation is nice but subtle—some users may not notice
- No quick actions for "Mark all today as done"
- Attendance bar doesn't show specific class counts clearly

---

## 5. CODE QUALITY ISSUES

### State Management:
- **Provider Usage:** Good foundation (ChangeNotifier + MultiProvider)
- **Issues:**
  - AppController is a "kitchen sink"—manages reminders, user, mode, streak, week stats (too many responsibilities)
  - Mixed use of context.watch() and context.read() (inconsistent patterns)
  - No clear separation: business logic vs. UI state
  - **Recommendation:** Split into: `UserController`, `ReminderController`, `StatisticsController`

### Widget Structure:
- **Good:**
  - Reusable components (StatCard, InsightCard, etc.)
  - Proper use of StatefulWidget where needed
  - Good separation of concerns in most widgets
- **Issues:**
  - Some widgets are too large (>200 lines)
  - Deep nesting in build methods (ReminderTile has 5+ levels)
  - ReminderTile logic (category color, priority badge) should extract to helpers
  - **Recommendation:** Extract widget building into helper methods or separate classes

### Error Handling:
- **Current:**
  - Try/catch blocks exist but often catch-all with `(_) {}`
  - Error messages sometimes shown via SnackBar, sometimes silently ignored
  - No centralized error handling strategy
  - **Issues:**
    - Users won't know if operations failed
    - Debugging is difficult with silent failures
  - **Recommendation:**
    - Implement ErrorHandler throughout
    - Use consistent error dialogs/snackbars
    - Log errors for debugging

### Database/Persistence:
- **DatabaseService:**
  - Good: Structured SQL schema
  - Issues:
    - No transaction support (batch operations unsafe)
    - No migration strategy documented (onUpgrade exists but sparse)
    - No connection pooling (single DB instance, should be fine)
  - **Recommendation:** Add migration helper, document upgrade path

### Performance:
- **Issues:**
  - IndexedStack keeps all 5 screens in memory (PersonalDashboard)
  - No lazy loading for large reminder lists
  - IntelligenceEngine queries might be slow on large datasets
  - **Recommendation:** 
    - Consider PageView + lazy loading for tab navigation
    - Paginate reminder lists
    - Cache insights with TTL

### Testing:
- **Status:** No test files found
- **Recommendation:** Add:
  - Unit tests for AppController, AttendanceService
  - Widget tests for key UI components
  - Integration tests for reminder CRUD flow

---

## 6. COLOR SYSTEM (Design Tokens)

### Primary Palette:
```dart
// Dark-first, premium feel
background = #0D0D0D (pure black offset)
backgroundSecondary = #151515
card = #1E1E1E (surfaces)

// Accent colors
accentBlue = #5B8CFF (primary: meetings, tasks)
accentPurple = #8A5CFF (secondary: focus, insights)
success/green = #3CCF91 (completed tasks, good metrics)
warning/orange/yellow/coral = #FFB84D (alerts, pending)
error/red = #FF5C5C (critical, absent, at-risk)
cyan = #5BC0DE (less used, alternative)

// Text
textPrimary/white = #FFFFFF
textSecondary/muted = #B0B0B0

// Light theme
bgLight = #FFFFFF
surfaceLight = #F5F5F7
textLight = #0D0D0D
textSecondaryLight = #6B6B6B
borderLight = #E0E0E0
```

### Soft/Tinted Colors (transparent backgrounds):
- primarySoft (#1A2744): Blue tint
- purpleSoft (#221833): Purple tint
- greenSoft (#15251F): Green tint
- coralSoft/orangeSoft (#2A2418): Orange tint
- redSoft (#2A1818): Red tint
- cyanSoft (#15252A): Cyan tint
- yellowSoft: Same as coralSoft

### Usage:
- Blue: Headers, primary actions, primary stats
- Purple: Secondary actions, premium features
- Green: Success states, completed items, good metrics
- Orange: Warnings, pending items, skipped classes
- Red: Errors, absent attendance, negative metrics
- Cyan: Accent, less common

### Issues:
- Too many color aliases (blue/primary/accentBlue)
- Soft color calculation is hardcoded instead of derived
- No clear hierarchy of which colors are primary vs. accent
- **Recommendation:** Consolidate to 6-8 core colors with generated tints

---

## 7. TYPOGRAPHY

### Font Family:
- **Primary:** Inter (via google_fonts)
- **Fallback:** System default
- **Usage:** 100% of app text

### Type Scale (via TextTheme):
```
headlineLarge:  30px, w700, 1.2x height    → Page titles
headlineMedium: 26px, w700, 1.2x height    → Section headers
headlineSmall:  22px, w600, 1.3x height    → Major content
titleLarge:     20px, w600, 1.3x height    → Card titles, primary text
titleMedium:    17px, w500, 1.3x height    → Secondary titles
titleSmall:     14px, w600, 1.3x height    → Labels (high emphasis)
bodyLarge:      16px, w400, 1.3x height    → Body copy (primary)
bodyMedium:     14px, w400, 1.3x height    → Body copy (secondary)
bodySmall:      13px, w400, 1.3x height    → Captions, hints
labelLarge:     14px, w600, 1.3x height    → Button labels
labelMedium:    13px, w500, 1.3x height    → Small labels
labelSmall:     11px, w500, 1.3x height    → Tiny labels
```

### Letter Spacing:
- **All:** -0.2px (slight tightening for premium feel)

### Issues:
- **Body Small (13px) is barely readable** on small fonts
- Line heights are mostly 1.3x, but headlines use 1.2x (inconsistent)
- No defined usage guidance: when to use bodyMedium vs. bodyLarge?
- **Recommendation:** 
  - Document which text styles are for what (body text, labels, etc.)
  - Test readability at 13px
  - Consider 14px as minimum for body text

---

## 8. SPACING & LAYOUT PATTERNS

### Border Radius:
```dart
ZyvoraRadius.sm = 8px     → Inputs, small buttons, checkboxes
ZyvoraRadius.md = 12px    → Cards, modals, buttons
ZyvoraRadius.lg = 16px    → (rarely used)
ZyvoraRadius.hero = 28px  → Floating dock, large modals, FABs
```

### Spacing Scale (Current - Inconsistent):
- 4px: Minimal gaps
- 6px: Small gaps (vertical padding)
- 8px: Common standard
- 9px: (not standard, should be 8)
- 10px: (redundant, should be 8)
- 11px: Padding on reminder tiles
- 12px: Common (SizedBox.width gaps)
- 14px: Section gaps, some padding
- 16px: Common (card padding, list padding)
- 18px: Very common (large padding)
- 20px: Hero card padding
- 24px: Large gaps, list padding

### Issues:
- **Too many values:** 4, 6, 8, 9, 10, 11, 12, 14, 16, 18, 20, 24
- Should be: 4, 8, 12, 16, 24, 32, 48
- Hard to maintain consistency
- **Recommendation:** Create `ZyvoraSpacing` enum/class:
```dart
class ZyvoraSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}
```

### Animation Durations:
```dart
ZyvoraMotion.fast = 180ms  → Quick toggles (checkboxes, favorite)
ZyvoraMotion.regular = 280ms → Standard transitions, color changes
ZyvoraMotion.curve = Curves.easeOutCubic → All animations
```

### Layout Patterns:
- **Padding:** Horizontal 18, vertical 8 (standard for lists)
- **List bottom padding:** 100px (to avoid floating dock)
- **Gap between list items:** 10-12px
- **Card padding:** 12px-20px
- **Floating dock:** 24px from edges, 72px height

### Issues:
- List padding (18, 8, 18, 100) is verbose
- 100px bottom padding is magic number (dock height + margin)
- No standardized card padding
- **Recommendation:** Create `EdgeInsets` constants or extension methods

---

## 9. REUSABLE COMPONENTS & WIDGETS

### Comprehensive Widget Inventory:

| Widget | Purpose | Status |
|--------|---------|--------|
| **StatCard** | Display key metric (completed, pending, streak) | ✅ Good |
| **InsightCard** | Show AI-generated insight with icon | ✅ Good |
| **ProductivityRing** | Circular % progress for today | ✅ Good |
| **DashboardOverviewCard** | Hero summary card (name, streak, %) | ✅ Good |
| **SmartSummaryCard** | Summary of week/today | ✅ Good |
| **ReminderTile** | List item: reminder with checkbox | ✅ Good |
| **AlarmTile** | List item: alarm with toggle/actions | ✅ Good |
| **AttendanceBar** | Progress bar for subject attendance | ✅ Good |
| **BunkCalculatorCard** | "Classes you can skip" calculator | ✅ Good |
| **CountdownCard** | Next reminder timer | ⚠️ Used only in HomeDashboard |
| **TodayTimeline** | Vertical timeline of day's reminders | ⚠️ Minimal usage |
| **WeekSummaryCard** | Weekly completion summary | ⚠️ Minimal usage |
| **QuickActionCard** | Single action button | ✅ Good |
| **QuickActionStrip** | Row of action buttons | ✅ Used in dashboard |
| **SectionHeader** | Title + subtitle divider | ✅ Good |
| **EmptyState** | Empty list placeholder | ✅ Good |
| **GreetingHeader** | Time-based greeting (Good morning, etc.) | ⚠️ Unused? |
| **ModeCard** | Mode selection card (personal/professional) | ✅ Good |
| **PremiumCard** | Premium feature showcase | ✅ Good |
| **PremiumDashboardHeader** | Dashboard hero header (gradient) | ✅ Good |
| **ZyvoraFloatingNav** | Custom floating dock navigation | ⚠️ May be duplicate of _FloatingDockNav |

### Component Issues:
1. **GreetingHeader:** Defined but unclear if used
2. **ZyvoraFloatingNav:** Potential duplicate with MainWrapper's _FloatingDockNav
3. **CountdownCard, TodayTimeline:** Only used in old HomeDashboard
4. **AddReminderSheet, AddAlarmSheet:** Work but could be more polished
5. **SafeFormWidgets:** Mentioned but not inspected

### Missing Components:
- No Loading skeleton/shimmer
- No Error dialog/alert standard
- No ConfirmDialog for destructive actions
- No Toast/Snackbar wrapper
- No Image lazy loader

---

## 10. STATE MANAGEMENT (Provider)

### Current Setup:
```dart
// main.dart
MultiProvider(
  providers: [
    Provider<DatabaseService>.value(),       // Singleton
    Provider<NotificationService>.value(),   // Singleton
    ChangeNotifierProvider<AppController>(), // Main state
    ChangeNotifierProvider<AttendanceService>(),
    ChangeNotifierProvider<AlarmService>(),
    ChangeNotifierProvider<MainTabIndex>(),  // Tab index
  ],
)
```

### AppController (The Kitchen Sink):
**Manages:** reminders, life mode, role, user name, dark mode, productivity, streak, completion logs

**Issues:**
- 700+ lines (needs splitting)
- Multiple responsibilities: CRUD reminders, track streaks, manage settings, compute stats
- setState() patterns duplicated across services
- No clear separation: presentation logic vs. business logic

**Methods:**
```
initialize()              → Load from DB
addReminder()            → CRUD
editReminder()
deleteReminder()
markReminderCompleted()
resetCompletedToday()
setLifeMode()
setRole()
setUserName()
toggleDarkMode()
getters for: lifeMode, role, reminders, activeReminders, todayReminders, 
            todayProductivity, currentStreak, weekCompletionStats
```

### AttendanceService:
**Manages:** subjects, attendance records

**Issues:**
- Good isolation, but could be simpler
- Some utility methods mixed with service logic

### AlarmService:
**Manages:** alarms, scheduling

**Status:** Clean, focused, good design

### MainTabIndex:
**Manages:** Current tab index

**Status:** Simple, good

### SafeNotifier Mixin:
- Prevents setState() errors on disposed widgets
- Good defensive programming pattern

### State Update Flow:
1. User action (e.g., tap complete button)
2. Call method on service (e.g., `ctrl.markReminderCompleted(id)`)
3. Service updates state → `notifyListeners()`
4. Widgets rebuild via `context.watch()`

### Issues:
- **Too Centralized:** AppController is a bottleneck
- **Async Operations:** No clear loading state handling
- **No Business Logic Layer:** Services mix DB + logic + notification side-effects
- **No ViewModel Pattern:** Logic spread across multiple places

### Recommendations:
1. **Split AppController:**
   - `UserController`: name, mode, role, dark mode
   - `ReminderController`: reminder CRUD + completion
   - `AnalyticsController`: streak, productivity, insights
   
2. **Add Business Logic Layer:**
   - `ReminderUseCase`: Handle add/edit/delete + notifications
   - `AttendanceUseCase`: Mark attendance + stats
   - `NotificationUseCase`: Schedule all notifications
   
3. **Add Loading States:**
   - Enum: `AsyncState.idle | loading | success | error`
   - Each service has `state` property
   
4. **Add Error Handling:**
   - Dedicated error state in each controller
   - Error messages passed to UI

---

## 11. NAVIGATION & ROUTING DETAILS

### Routes:
- **Implicit:** Navigator.push/pop with MaterialPageRoute
- **No Named Routes:** App uses direct widget instantiation
- **Deep Linking:** Not implemented

### Modals:
- **showModalBottomSheet:** For reminder/alarm forms
- **showDialog:** For authentication (in auth_screen)
- **showDatePicker:** For calendar date selection

### Issues:
- No route guards (e.g., ensure user is authenticated before accessing MainWrapper)
- No deep linking support for external notifications
- Modal dismissal doesn't validate/save data (Result pattern used, but could be improved)
- **Recommendation:** Implement GoRouter for better navigation management

---

## 12. DATABASE SCHEMA

### Tables:
```sql
reminders (id, title, day, hour, minute, category, lifeMode, 
           repeatType, notificationEnabled, alarmEnabled, 
           isCompleted, completedAt, createdAt, updatedAt, priority, notes)

attendance (id, subject, date, isPresent, note)

completion_logs (id, reminderId, completedAt, dayOfWeek, hourOfDay)

subjects (id, name, requiredPercentage, createdAt)
```

### Indexes:
- `idx_reminders_day`
- `idx_reminders_lifeMode`
- `idx_attendance_subject`
- `idx_completion_logs_reminderId`

### Issues:
- No foreign keys (should link completion_logs.reminderId → reminders.id)
- No deletion cascade behavior defined
- Schema v2 upgrade path is sparse
- No backup/restore mechanism

---

## 13. DEPENDENCIES & EXTERNAL PACKAGES

| Package | Version | Purpose | Issue? |
|---------|---------|---------|--------|
| flutter | ^3.11.5 | Framework | ✅ No |
| provider | ^6.1.5 | State management | ✅ No |
| shared_preferences | ^2.5.5 | Local storage (prefs) | ✅ No |
| sqflite | ^2.4.2 | SQLite database | ✅ No |
| flutter_local_notifications | ^21.0.0 | Notifications | ⚠️ Android-heavy |
| flutter_timezone | ^5.0.2 | Timezone support | ✅ No |
| timezone | ^0.11.0 | Timezone data | ✅ No |
| table_calendar | ^3.2.0 | Calendar widget | ✅ No |
| fl_chart | ^1.2.0 | Charts (bar, pie) | ✅ No |
| google_fonts | ^8.1.0 | Inter font | ✅ No |
| lottie | ^3.3.3 | Animations | ⚠️ Unused? |
| flutter_animate | ^4.5.2 | Animation utilities | ⚠️ Check usage |
| intl | ^0.20.2 | Internationalization | ⚠️ Used for date formatting only |
| cupertino_icons | ^1.0.8 | iOS icons | ✅ No |
| path | ^1.9.1 | Path utilities | ✅ No |

### Unused Dependencies:
- lottie: Imported but not found in any screen
- flutter_animate: Check if actually used for animations

### Version Analysis:
- All modern versions (2024+)
- No major breaking version jumps needed

---

## 14. SCREENS - COMPLETE INVENTORY

### Authentication Flow:
| Screen | Purpose | Params | State Management |
|--------|---------|--------|------------------|
| **SplashScreen** | Init routing | None | AppController, AlarmService |
| **OnboardingScreen** | First-time intro | None | ✓ (viewed flag in SharedPrefs) |
| **AuthScreen** | User login/register | None | ✓ (auth completion flag) |
| **ModeSelectionScreen** | Choose personal/professional | None | AppController (setLifeMode) |
| **RoleSelectionScreen** | Choose professional role | None | AppController (setRole) |

### Main Tabs:
| Screen | Purpose | Users | Features |
|--------|---------|-------|----------|
| **MainWrapper** | Navigation hub | All | IndexedStack, floating dock (5 tabs) |
| **HomeDashboard** | OLD unified dashboard | All | Unused in current version |
| **PersonalDashboard** | Personal mode home | Personal | Dashboard + embedded nav |
| **ProfessionalDashboard** | Professional mode home | Professional | Dashboard + embedded nav + attendance |
| **TasksScreen** | Reminder list | All | Grouped by day, sort by time, edit/delete |
| **AttendanceScreen** | Attendance tracker | Professional | Subject list, add/mark, stats |
| **CalendarScreen** | Month/week calendar | All | table_calendar, day reminders view |
| **ProfileScreen** | User profile | All | Name, mode, streak, stats, quick nav |

### Secondary Screens:
| Screen | Purpose | Launch | Features |
|--------|---------|--------|----------|
| **SettingsScreen** | App settings | Profile → Settings | Dark mode, name edit, logout |
| **AnalyticsScreen** | Statistics & insights | Profile → Analytics | Charts, insights, completion rate |
| **AlarmsScreen** | Alarm management | Profile → Alarms (TBD) | List, add/edit, toggle, delete |

### Placeholder/Unused:
| Screen | Status | Notes |
|--------|--------|-------|
| **AttendancePlaceholder** | Stub | Used for personal mode instead of real attendance |
| **EditReminderSheet** | Unused | AddReminderSheet handles both add/edit |
| **HomeDashboard** | Unused | Replaced by PersonalDashboard + ProfessionalDashboard |

---

## 15. MISSING FEATURES / GAPS

1. **Notification Deep Linking:** Tapping notification doesn't open the specific reminder
2. **Reminder Drag-to-Snooze:** Not implemented
3. **Batch Operations:** Can't mark all today's tasks as done
4. **Undo/Redo:** No undo system for deletions
5. **Recurring Patterns:** Only simple weekly/daily/once (no bi-weekly, monthly, etc.)
6. **Smart Scheduling:** No "repeat only on school days" or custom patterns
7. **Collaboration:** No shared reminders/attendance with others
8. **Rich Notifications:** Plain text only, no image/action buttons
9. **Backup/Export:** No data export or cloud sync
10. **Search/Filter:** No search across reminders
11. **Widget/Shortcut:** No home screen widget or app shortcuts
12. **Accessibility:** No detailed a11y testing mentioned
13. **Localization:** No language support (intl imported but not used)
14. **Biometric Auth:** No fingerprint/face unlock

---

## SUMMARY TABLE

| Aspect | Status | Quality | Notes |
|--------|--------|---------|-------|
| **Architecture** | Mixed | ⭐⭐⭐ | Provider good, but AppController is too large |
| **State Management** | Provider | ⭐⭐⭐ | Functional but needs splitting |
| **UI Components** | Good | ⭐⭐⭐⭐ | Many reusable widgets, design tokens defined |
| **Navigation** | Basic | ⭐⭐⭐ | Manual routes, no deep linking |
| **Design System** | Defined | ⭐⭐⭐ | Colors, typography, radius, spacing mostly consistent |
| **Error Handling** | Weak | ⭐⭐ | Silent failures, catch-all blocks |
| **Performance** | Adequate | ⭐⭐⭐ | No major bottlenecks visible |
| **Testing** | None | ⭐ | No tests found |
| **Documentation** | Improving | ⭐⭐⭐ | Code is mostly self-documenting, `main.dart` docstrings added |
| **Accessibility** | Not tested | ? | No accessibility audit visible |
| **Feature Completeness** | 80% | ⭐⭐⭐⭐ | Core features solid, nice extras (insights, alarms) |

---

## KEY RECOMMENDATIONS (Priority Order)

### HIGH (Breaking Issues):
1. **Consolidate Navigation:** Choose between MainWrapper/PersonalDashboard/ProfessionalDashboard pattern and remove duplicates
2. **Split AppController:** Create UserController, ReminderController, AnalyticsController
3. **Fix Database Foreign Keys:** Link completion_logs to reminders properly
4. **Add Error Handling:** Implement consistent error dialogs and logging

### MEDIUM (Quality Improvements):
5. **Standardize Spacing:** Use ZyvoraSpacing constants (4, 8, 12, 16, 24, 32)
6. **Reduce Color Aliases:** Clean up ZyvoraColors (remove duplicates like blue/accentBlue)
7. **Add Loading States:** Show loaders for async operations (add reminder, mark attendance, etc.)
8. **Extract Widget Builders:** Break down large build methods (ReminderTile, AddReminderSheet)
9. **Add Unit Tests:** Test AppController, AttendanceService, IntelligenceEngine

### LOW (Nice-to-Have):
10. **Implement GoRouter:** Migrate from manual navigation
11. **Add Batch Operations:** Mark multiple reminders as done
12. **Implement Search:** Filter reminders by text
13. **Add Home Widget:** iOS/Android home screen widget
14. **Cloud Sync:** Optional backup/restore

---

**Document Generated:** May 16, 2026 (Updated: May 20, 2026)
**Analysis Scope:** Complete codebase walkthrough (lib/ directory)
**Status:** Ready for redesign while maintaining all current functionality. Documentation updates in progress.
