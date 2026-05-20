# 🎯 Zyvora Premium Subscription - Complete Flow Analysis

**Analysis Date:** May 16, 2026  
**Status:** 🟡 **Placeholder UI / No Backend Integration**  
**Last Updated:** May 16, 2026

---

## 📊 QUICK SUMMARY

| Aspect | Status | Details |
|--------|--------|---------|
| **Premium Paywall UI** | ✅ Exists | [premium_subscription_screen.dart](lib/screens/premium_subscription_screen.dart) |
| **Entry Point** | ✅ Exists | [profile_screen.dart](lib/screens/profile_screen.dart) → Premium Button |
| **Backend Integration** | ❌ Missing | No API, no Stripe, no Firebase |
| **State Management** | ❌ Missing | No PremiumService, no premium status tracking |
| **Payment Processing** | ❌ Missing | Buttons show placeholders ("Billing connects at publish time") |
| **Cloud Backup/Sync** | ❌ Missing | No CloudSyncService, no data backup capability |
| **Authentication** | ❌ Missing | No user login system |
| **Database Schema** | ⚠️ Partial | Only local SQLite, no premium user tables |
| **Feature Gates** | ❌ Missing | No paywall widgets for premium-exclusive features |

---

## 🗺️ NAVIGATION & ENTRY POINTS

### Primary Entry Point
```
User Profile Screen
    ↓
Click "Zyvora Premium" button (workspace_premium_outlined icon)
    ↓
PremiumSubscriptionScreen (Marketing page)
    ↓
Select Annual ($39.99/year) OR Monthly ($5.99/month)
    ↓
[PLACEHOLDER - shows SnackBar]
```

**Files Involved:**
- [lib/screens/profile_screen.dart#L87-L101](lib/screens/profile_screen.dart#L87-L101) - Premium button & navigation

### Secondary Entry Points (Missing)
- ❌ Feature usage limit prompts (e.g., "Upgrade to add more reminders")
- ❌ Advanced analytics buttons
- ❌ Cloud backup prompts

---

## 🎨 UI SCREENS

### ✅ Existing Screens

#### 1. **PremiumSubscriptionScreen** - Marketing Paywall
**File:** [lib/screens/premium_subscription_screen.dart](lib/screens/premium_subscription_screen.dart)

**Components:**
- **Header Section**
  - Title: "Zyvora Premium"
  - Tagline: "Work without friction"
  - Description: "Deeper analytics, cloud backup, and priority layouts..."
  
- **Annual Plan Card** (`_GlassCard`)
  - Price: **$39.99/year** (~$3.33/month)
  - Badge: "Best value"
  - Button: "Start yearly" → **STUB** (SnackBar: "Billing connects at publish time")
  
- **Monthly Plan Card** (`_GlassCard`)
  - Price: **$5.99/month**
  - Button: "Subscribe monthly" → **STUB** (SnackBar: "Monthly plan selected (placeholder)")
  
- **Feature Comparison Table** (`_CompareTable`)
  - 3 columns: Feature | Free | Premium
  - Features listed:
    - ✅ Smart reminders & alarms (both)
    - ☁️ Cloud backup & sync (premium only)
    - 📊 Advanced analytics (premium only)
    - 🎨 Custom themes & icons (premium only)
  
- **Visual Design** (`_SoftGlowBackground` + `_GlassCard`)
  - Glass-morphism panels
  - Gradient background
  - Premium aesthetic (blur + transparency)

#### 2. **ProfileScreen** - User Profile & Settings Hub
**File:** [lib/screens/profile_screen.dart](lib/screens/profile_screen.dart)

**Relevant Section:**
```dart
ListTile(
  leading: Icon(Icons.workspace_premium_outlined),
  title: Text('Zyvora Premium'),
  subtitle: Text('Backup, themes, advanced insights'),
  trailing: Icon(Icons.chevron_right),
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PremiumSubscriptionScreen(),
      ),
    );
  },
)
```

### ❌ Missing Screens

| Screen | Purpose | Priority |
|--------|---------|----------|
| **SubscriptionManagementScreen** | View current plan, change plan, cancel subscription | HIGH |
| **BackupRestoreScreen** | List backups, restore from backup, manage storage quota | HIGH |
| **BillingHistoryScreen** | Payment history, receipts, invoices | MEDIUM |
| **AdvancedAnalyticsScreen** | Premium analytics dashboard (predictions, AI insights) | MEDIUM |

---

## 📦 DATA MODELS

### ✅ Existing Models
- `Reminder` - Task/reminder data
- `AttendanceRecord` - Attendance tracking
- `Alarm` - Alarm scheduling
- `Insight` - Analytics insights
- `ZyvoraRole` - User role enum

**Note:** None of these models have premium awareness (no `isPremiumFeature` field, no premium-specific data).

### ❌ Missing Models

**Must Create:**

```dart
/// lib/models/premium_user.dart
class PremiumUser {
  final String userId;           // Unique user identifier
  final String email;            // User email
  final SubscriptionPlan plan;   // Subscription tier
  final DateTime subscriptionStart;
  final DateTime subscriptionEnd;
  final bool isActive;           // Current subscription active?
  final String paymentMethodId;  // Stripe payment method
  final String stripeCustomerId; // Stripe customer ID
  final DateTime createdAt;
  final DateTime updatedAt;
  
  bool get isExpired => subscriptionEnd.isBefore(DateTime.now());
  int get daysRemaining => subscriptionEnd.difference(DateTime.now()).inDays;
}

enum SubscriptionPlan {
  free,      // No subscription
  monthly,   // $5.99/month
  yearly,    // $39.99/year
}

/// lib/models/subscription_transaction.dart
class SubscriptionTransaction {
  final String transactionId;    // Unique transaction ID
  final String userId;
  final SubscriptionPlan plan;
  final double amount;
  final String currency;         // "USD"
  final DateTime transactionDate;
  final String status;           // pending|completed|failed|cancelled
  final String paymentProvider;  // "stripe"|"revenucat"
  final String? receiptUrl;
  
  // For JSON serialization
  Map<String, dynamic> toJson() { }
  factory SubscriptionTransaction.fromJson(Map) { }
}

/// lib/models/backup_metadata.dart
class BackupMetadata {
  final String backupId;
  final String userId;
  final DateTime createdAt;
  final int dataSize;            // bytes
  final String status;           // pending|uploaded|synced
  final List<String> entityTypes; // ["reminders", "attendance", ...]
  final String? restoreInProgress; // backup ID being restored
}
```

---

## 🔧 SERVICES LAYER

### ✅ Existing Services
- **AppController** - Reminder management, app state
- **AttendanceService** - Attendance tracking
- **NotificationService** - System notifications
- **AlarmService** - Alarm scheduling
- **IntelligenceEngine** - Basic analytics (local only)
- **DatabaseService** - SQLite operations

### ❌ Missing Services (Critical)

**1. PremiumService** - Subscription state & logic
```dart
class PremiumService extends ChangeNotifier {
  PremiumUser? _currentUser;
  bool _isSubscribed = false;
  SubscriptionPlan _activePlan = SubscriptionPlan.free;
  
  bool isPremium() => _isSubscribed && !_currentUser!.isExpired;
  
  Future<void> initialize() async;
  Future<void> subscribeMonthly(String paymentToken) async;
  Future<void> subscribeYearly(String paymentToken) async;
  Future<void> cancelSubscription() async;
  Future<void> updatePaymentMethod(String newToken) async;
}
```

**2. PaymentService** - Stripe integration
```dart
class PaymentService {
  Future<String> createPaymentToken(
    String cardNumber, int expiryMonth, int expiryYear, String cvc
  ) async;
  
  Future<PaymentResult> processPayment(
    String paymentToken, double amount
  ) async;
  
  // Webhook handling
  Future<void> handlePaymentWebhook(Map<String, dynamic> webhook) async;
}
```

**3. CloudSyncService** - Cloud backup & sync
```dart
class CloudSyncService {
  Future<BackupMetadata> createBackup() async;
  Future<List<BackupMetadata>> listBackups() async;
  Future<void> restoreFromBackup(String backupId) async;
  Future<void> deleteBackup(String backupId) async;
  
  Stream<SyncEvent> streamSyncStatus();
}
```

**4. ApiService** - Backend communication
```dart
class ApiService {
  final String baseUrl = 'https://api.zyvora.app/v1';
  
  // Auth endpoints
  Future<AuthResponse> register(String email, String password) async;
  Future<AuthResponse> login(String email, String password) async;
  
  // Subscription endpoints
  Future<PaymentIntent> createPaymentIntent({
    required SubscriptionPlan plan,
  }) async;
  
  Future<SubscriptionResponse> confirmPayment({
    required String paymentIntentId,
  }) async;
  
  // Backup endpoints
  Future<BackupResponse> createBackup() async;
  Future<List<BackupMetadata>> listBackups() async;
}
```

**5. AuthService** - User authentication
```dart
class AuthService extends ChangeNotifier {
  Future<void> register(String email, String password) async;
  Future<void> login(String email, String password) async;
  Future<void> logout() async;
  String? get currentUserId;
  bool get isLoggedIn;
}
```

---

## 💾 STORAGE & DATABASE

### ✅ Current Storage
- **SQLite** (Mobile/Desktop)
  - Tables: `reminders`, `attendance`, `subjects`, `completion_logs`
  - No premium data storage
  
- **SharedPreferences** (Config)
  - Keys: `zyvora.lifeMode`, `zyvora.role`, `zyvora.darkMode`, `zyvora.userName`
  - No premium config

### ❌ Missing Database Tables (SQLite)

```sql
-- Premium Users Table
CREATE TABLE premium_users (
  id                  INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id             TEXT NOT NULL UNIQUE,
  email               TEXT NOT NULL UNIQUE,
  subscription_plan   TEXT NOT NULL DEFAULT 'free',
  subscription_start  TEXT,
  subscription_end    TEXT,
  is_active           INTEGER NOT NULL DEFAULT 0,
  payment_method_id   TEXT,
  stripe_customer_id  TEXT UNIQUE,
  created_at          TEXT NOT NULL,
  updated_at          TEXT NOT NULL,
  
  CONSTRAINT valid_plan CHECK(subscription_plan IN ('free', 'monthly', 'yearly'))
);

-- Subscription Transactions
CREATE TABLE subscription_transactions (
  id                  INTEGER PRIMARY KEY AUTOINCREMENT,
  transaction_id      TEXT NOT NULL UNIQUE,
  user_id             TEXT NOT NULL,
  subscription_plan   TEXT NOT NULL,
  amount              REAL NOT NULL,
  currency            TEXT NOT NULL DEFAULT 'USD',
  transaction_date    TEXT NOT NULL,
  status              TEXT NOT NULL DEFAULT 'pending',
  payment_provider    TEXT,
  receipt_url         TEXT,
  created_at          TEXT NOT NULL,
  
  FOREIGN KEY(user_id) REFERENCES premium_users(user_id),
  CONSTRAINT valid_status CHECK(status IN ('pending', 'completed', 'failed', 'cancelled'))
);

-- Backup Metadata
CREATE TABLE backup_metadata (
  id                  INTEGER PRIMARY KEY AUTOINCREMENT,
  backup_id           TEXT NOT NULL UNIQUE,
  user_id             TEXT NOT NULL,
  created_at          TEXT NOT NULL,
  updated_at          TEXT NOT NULL,
  data_size           INTEGER DEFAULT 0,
  status              TEXT NOT NULL DEFAULT 'pending',
  entity_types        TEXT,  -- JSON array
  
  FOREIGN KEY(user_id) REFERENCES premium_users(user_id),
  CONSTRAINT valid_status CHECK(status IN ('pending', 'uploading', 'uploaded', 'synced', 'error'))
);

-- Cloud Sync Metadata
CREATE TABLE cloud_sync_status (
  id                  INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id             TEXT NOT NULL UNIQUE,
  last_sync_time      TEXT,
  next_sync_time      TEXT,
  sync_status         TEXT NOT NULL DEFAULT 'idle',
  
  FOREIGN KEY(user_id) REFERENCES premium_users(user_id)
);
```

### ❌ Missing SharedPreferences Keys

```dart
'zyvora.premium.plan'           // 'free' | 'monthly' | 'yearly'
'zyvora.premium.subscription_id' // Stripe subscription ID
'zyvora.premium.user_id'        // Firebase/custom user ID
'zyvora.premium.auto_backup'    // true | false
'zyvora.premium.last_sync'      // ISO8601 timestamp
'zyvora.premium.sync_interval'  // milliseconds
```

---

## 🌐 API INTEGRATION

### Current Status: ❌ **NO BACKEND**

All subscription buttons currently show placeholder SnackBars. No actual backend integration exists.

### Required Backend API Endpoints

**Base URL:** `https://api.zyvora.app/v1`

#### Authentication Endpoints
```
POST /auth/register
  Request: { email, password }
  Response: { userId, token, expiresIn }

POST /auth/login
  Request: { email, password }
  Response: { userId, token, expiresIn }

POST /auth/logout
  Headers: { Authorization: Bearer {token} }

POST /auth/refresh-token
  Request: { refreshToken }
  Response: { token, expiresIn }

GET /auth/me
  Headers: { Authorization: Bearer {token} }
  Response: { userId, email, premiumUser }
```

#### Subscription Endpoints
```
POST /subscriptions/create-payment-intent
  Headers: { Authorization: Bearer {token} }
  Request: { plan: "monthly" | "yearly" }
  Response: { clientSecret, paymentIntentId, amount }

POST /subscriptions/confirm-payment
  Headers: { Authorization: Bearer {token} }
  Request: { paymentIntentId, paymentMethodId }
  Response: { success, subscription: PremiumUser, receipt }

GET /subscriptions/current
  Headers: { Authorization: Bearer {token} }
  Response: { subscription: PremiumUser }

POST /subscriptions/cancel
  Headers: { Authorization: Bearer {token} }
  Response: { success, cancelEffectiveDate }

POST /subscriptions/update-plan
  Headers: { Authorization: Bearer {token} }
  Request: { newPlan: "monthly" | "yearly" }
  Response: { success, subscription: PremiumUser }

GET /subscriptions/transactions
  Headers: { Authorization: Bearer {token} }
  Response: { transactions: List<SubscriptionTransaction> }
```

#### Cloud Backup & Sync Endpoints
```
POST /backups/create
  Headers: { Authorization: Bearer {token} }
  Request: { entityTypes: ["reminders", "attendance", "subjects"] }
  Response: { backupId, status, createdAt }

GET /backups
  Headers: { Authorization: Bearer {token} }
  Response: { backups: List<BackupMetadata> }

POST /backups/{backupId}/restore
  Headers: { Authorization: Bearer {token} }
  Response: { success, restoreJobId, estimatedTime }

DELETE /backups/{backupId}
  Headers: { Authorization: Bearer {token} }
  Response: { success }

GET /sync/status
  Headers: { Authorization: Bearer {token} }
  Response: { lastSync, nextSync, pendingChanges }

POST /sync/reminders
  Headers: { Authorization: Bearer {token} }
  Request: { reminders: List<Map> }
  Response: { synced, conflicts }
```

#### Advanced Analytics Endpoints
```
GET /analytics/advanced
  Headers: { Authorization: Bearer {token} }
  Response: { insights: List<AdvancedInsight> }

GET /analytics/predictions
  Headers: { Authorization: Bearer {token} }
  Response: { predictions: PredictiveAnalytics }
```

### Recommended Payment Provider: **Stripe**

**Integration Pattern:**
```dart
import 'package:flutter_stripe/flutter_stripe.dart';

// 1. Create payment intent on backend
final intent = await apiService.createPaymentIntent(plan: SubscriptionPlan.yearly);

// 2. Confirm with Stripe SDK
final result = await Stripe.instance.confirmPaymentIntent(
  clientSecret: intent.clientSecret,
  paymentMethodId: 'pm_xxx',
);

// 3. Confirm on backend
await apiService.confirmPayment(
  paymentIntentId: intent.id,
  paymentMethodId: 'pm_xxx',
);
```

---

## 📈 STATE MANAGEMENT (Provider)

### Missing ChangeNotifier Setup

**In `lib/main.dart` MultiProvider:**
```dart
MultiProvider(
  providers: [
    // Existing...
    ChangeNotifierProvider(create: (_) => AppController()),
    
    // ADD THESE:
    ChangeNotifierProvider(
      create: (_) => AuthService()..initialize(),
    ),
    ChangeNotifierProvider(
      create: (_) => PremiumService()..initialize(),
    ),
    ChangeNotifierProvider(
      create: (_) => CloudSyncService(
        premiumService: context.read<PremiumService>(),
        databaseService: context.read<DatabaseService>(),
      ),
    ),
    Provider(
      create: (_) => PaymentService(),
    ),
    Provider(
      create: (_) => ApiService(),
    ),
  ],
  child: MyApp(),
)
```

### Usage Pattern

```dart
// Check premium status
final premium = context.watch<PremiumService>();
if (!premium.isPremium()) {
  showPaywallDialog();
}

// Subscribe
await context.read<PaymentService>().processMonthlyPayment(
  paymentToken: token,
  amount: 5.99,
);

// Sync data
context.read<CloudSyncService>().syncReminders();
```

---

## 🗄️ COMPLETE FILE REFERENCE

### ✅ Files That Exist

| File | Lines | Purpose |
|------|-------|---------|
| [lib/screens/premium_subscription_screen.dart](lib/screens/premium_subscription_screen.dart) | ~350 | Premium paywall UI (placeholder) |
| [lib/screens/profile_screen.dart](lib/screens/profile_screen.dart) | ~150 | Profile page with premium button |
| [lib/utils/app_theme.dart](lib/utils/app_theme.dart) | ~100 | Premium design system (colors, spacing) |
| [lib/widgets/premium_card.dart](lib/widgets/premium_card.dart) | ~50 | Glass-morphism card component |
| [lib/widgets/premium_dashboard_header.dart](lib/widgets/premium_dashboard_header.dart) | ~80 | Premium header widget |
| [lib/data/database_service.dart](lib/data/database_service.dart) | 600+ | SQLite operations (non-premium) |
| [lib/services/app_controller.dart](lib/services/app_controller.dart) | 450+ | Reminder management |

### ❌ Files That Need to Be Created

| File | Lines | Priority | Purpose |
|------|-------|----------|---------|
| `lib/services/premium_service.dart` | ~300 | **CRITICAL** | Premium subscription state management |
| `lib/services/payment_service.dart` | ~250 | **CRITICAL** | Stripe/payment processing integration |
| `lib/services/cloud_sync_service.dart` | ~400 | **HIGH** | Cloud backup & sync logic |
| `lib/services/api_service.dart` | ~300 | **CRITICAL** | Backend API communication |
| `lib/services/auth_service.dart` | ~200 | **CRITICAL** | User authentication |
| `lib/models/premium_user.dart` | ~80 | **CRITICAL** | Premium user data model |
| `lib/models/subscription_transaction.dart` | ~60 | **CRITICAL** | Payment transaction model |
| `lib/models/backup_metadata.dart` | ~50 | **HIGH** | Cloud backup metadata |
| `lib/data/premium_database_extension.dart` | ~200 | **CRITICAL** | Premium database tables & queries |
| `lib/screens/subscription_management_screen.dart` | ~250 | **HIGH** | Manage current subscription |
| `lib/screens/backup_restore_screen.dart` | ~300 | **HIGH** | Backup/restore management UI |
| `lib/widgets/feature_gate.dart` | ~150 | **HIGH** | Paywall widget for premium features |
| `lib/widgets/sync_status_indicator.dart` | ~100 | **MEDIUM** | Cloud sync status display |
| `lib/utils/payment_utils.dart` | ~80 | **MEDIUM** | Payment-related helper functions |
| `lib/utils/sync_utils.dart` | ~100 | **MEDIUM** | Cloud sync helper functions |

---

## 🎯 PREMIUM FEATURES MAPPING

### Premium Features Promised (from comparison table)

| Feature | Free | Premium | Status |
|---------|------|---------|--------|
| Smart reminders & alarms | ✅ | ✅ | ✅ Implemented (free) |
| Cloud backup & sync | ❌ | ✅ | ❌ **NOT IMPLEMENTED** |
| Advanced analytics | ❌ | ✅ | ⚠️ Basic analytics only |
| Custom themes & icons | ❌ | ✅ | ⚠️ Light/dark only |

### Feature Gate Implementation Needed

```dart
// lib/widgets/feature_gate.dart
class FeatureGate extends StatelessWidget {
  final Widget child;
  final VoidCallback onUpgrade;
  
  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumService>();
    
    if (premium.isPremium()) {
      return child;
    }
    
    return Stack(
      children: [
        Opacity(opacity: 0.5, child: child),
        Center(
          child: ElevatedButton(
            onPressed: onUpgrade,
            child: Text('Upgrade to Premium'),
          ),
        ),
      ],
    );
  }
}
```

---

## ⚠️ CRITICAL BLOCKERS

1. **No Backend Infrastructure**
   - Need API server (Node.js, Python, Go, etc.)
   - Need database for premium users
   - Need payment webhook handlers

2. **No Payment Processor Integration**
   - Stripe account required
   - Live API keys needed
   - Payment flow untested

3. **No User Authentication**
   - No login system
   - No user session management
   - Premium status tied to user identity

4. **No Cloud Infrastructure**
   - Need cloud storage (Firebase, AWS, etc.)
   - Need backup/restore endpoints
   - Need conflict resolution logic

5. **Buttons Don't Work**
   - Subscription buttons are placeholders
   - No actual payment processing
   - No error handling

---

## 📋 IMPLEMENTATION ROADMAP

### Phase 1: Core Infrastructure (2-3 weeks)
- [ ] Set up backend API (choose framework)
- [ ] Set up Firebase/database
- [ ] Create premium database schema
- [ ] Create `PremiumService` ChangeNotifier
- [ ] Create `AuthService` for user login

### Phase 2: Payment Processing (2-3 weeks)
- [ ] Integrate Stripe SDK
- [ ] Create `PaymentService`
- [ ] Implement payment flow in UI
- [ ] Set up webhook handlers
- [ ] Test payment processing (sandbox)

### Phase 3: Cloud Sync (2-3 weeks)
- [ ] Create `CloudSyncService`
- [ ] Implement backup creation
- [ ] Implement backup restoration
- [ ] Handle offline sync queue
- [ ] Conflict resolution

### Phase 4: Feature Gates & Polish (1-2 weeks)
- [ ] Add feature gate widgets
- [ ] Implement paywall prompts
- [ ] Create subscription management UI
- [ ] Add auto-renewal handling
- [ ] Comprehensive testing

**Total Timeline:** 7-11 weeks (~2 months)

---

## 🧪 TESTING REQUIREMENTS

### Unit Tests
- [ ] PremiumService: subscribe, cancel, check expiry
- [ ] PaymentService: token creation, amount validation
- [ ] CloudSyncService: backup creation, restoration
- [ ] Models: serialization/deserialization

### Integration Tests
- [ ] End-to-end subscription flow
- [ ] Cloud sync with offline transitions
- [ ] Webhook event handling
- [ ] Payment retry logic

### E2E Tests
- [ ] Full premium user journey (signup → payment → unlock)
- [ ] Subscription renewal
- [ ] Cloud sync across devices
- [ ] Data conflict resolution

---

## 📝 SUMMARY TABLE

| Component | Status | Details |
|-----------|--------|---------|
| **UI Screens** | 🟡 40% | Paywall UI exists, placeholders for management |
| **Data Models** | 🟡 50% | Reminders/Attendance exist, missing Premium* |
| **Services** | 🔴 10% | AppController exists, missing Premium Services |
| **Database** | 🔴 5% | SQLite for reminders, no premium tables |
| **API Integration** | 🔴 0% | No backend at all |
| **Authentication** | 🔴 0% | No login system |
| **Payment Processing** | 🔴 0% | No Stripe integration |
| **Cloud Backup/Sync** | 🔴 0% | No CloudSyncService |
| **Feature Gates** | 🔴 0% | No paywall widgets |

**Overall Progress:** 🔴 **~15% Complete** (UI only, no backend/logic)

---

## 🚀 NEXT STEPS

1. **Decide on payment provider** (Stripe recommended)
2. **Set up backend API** (Node.js/Firebase recommended)
3. **Create premium database schema** (run migrations)
4. **Implement PremiumService** (state management)
5. **Integrate Stripe SDK** (payment processing)
6. **Create CloudSyncService** (backup/sync)
7. **Add feature gates throughout app**
8. **Implement webhook handlers** (payment events)
9. **Comprehensive testing & QA**
10. **Deploy to production**

---

**For detailed implementation guidance, see:** `/memories/session/premium_subscription_flow.md`

