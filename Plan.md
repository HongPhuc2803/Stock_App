# SmartStock Flutter Application

## Development Plan

Version: 1.0

Status: Planning

Project Type:
Flutter Mobile Application

Architecture:
Clean Architecture + Feature First

Backend:
Firebase BaaS

---

# 1. Project Overview

## 1.1 Product Name

SmartStock

## 1.2 Product Description

SmartStock is a retail management mobile application designed for small businesses.

The application provides a complete solution for:

- Product management
- Inventory management
- Point of Sale (POS)
- Order management
- Customer management
- Employee management
- Revenue analytics

The purpose of this project is to replace manual inventory tracking and Excel-based management with a professional mobile solution.

---

# 2. Main Objectives

## Business Management

The application allows store owners to:

- Manage store information
- Manage employees
- Control user permissions
- Monitor business performance

---

## Product Management

Features:

- Create products
- Update products
- Delete products
- Manage product categories
- Manage product variants
- Upload product images
- Search and filter products

---

## Inventory Management

Features:

- Track product quantity
- Import stock
- Adjust stock
- View inventory history
- Monitor low stock products

---

## Sales Management

Features:

- POS checkout
- Barcode scanning
- Shopping cart
- Create orders
- Manage payment status
- Track sales history

---

## Reporting

Features:

- Revenue dashboard
- Sales statistics
- Best selling products
- Inventory reports
- Export reports

---

## System Features

Features:

- Authentication
- Role-based authorization
- Offline support
- Data synchronization
- Push notifications

---

# 3. System Actors

The system contains three main user roles:

```
                 SmartStock


        ----------------------------

        |             |            |

      Owner         Staff     Warehouse

```

---

# 3.1 Owner

Description:

Store owner or administrator.

Responsibilities:

- Manage entire store
- Monitor revenue
- Manage employees
- Manage products
- Manage inventory

Permissions:

Dashboard:

- View revenue
- View sales analytics
- View inventory status

Products:

- Create
- Update
- Delete
- Manage variants

Inventory:

- Import stock
- Adjust stock
- View history

Employees:

- Create employee accounts
- Assign roles
- Manage permissions

Reports:

- View financial reports
- Export reports

---

# 3.2 Staff

Description:

Sales employee.

Responsibilities:

- Handle customer purchases
- Create orders

Permissions:

Allowed:

- Search products
- Scan barcode
- Add products to cart
- Checkout
- View own orders

Restricted:

- Cannot delete products
- Cannot manage employees
- Cannot view profit reports

---

# 3.3 Warehouse Manager

Description:

Inventory employee.

Responsibilities:

- Maintain stock accuracy
- Handle incoming products

Permissions:

Allowed:

- View inventory
- Import products
- Adjust quantity
- View stock history

Restricted:

- Cannot create sales orders
- Cannot manage employees

---

# 4. Technology Stack

# Frontend

Framework:

Flutter

Language:

Dart

Version:

Dart 3.x

---

# Architecture

Pattern:

Clean Architecture

-

Feature First Architecture

---

# State Management

Library:

Riverpod

Reasons:

- Scalable
- Testable
- Modern Flutter approach
- Dependency injection support

---

# Navigation

Library:

go_router

Usage:

- Route management
- Authentication redirect
- Role-based navigation

---

# Firebase Services

## Firebase Authentication

Package:

firebase_auth

Purpose:

- User login
- Register
- Password management

---

## Cloud Firestore

Package:

cloud_firestore

Purpose:

- Store application data
- Real-time updates

---

## Firebase Storage

Package:

firebase_storage

Purpose:

- Product images
- User avatars

---

## Firebase Cloud Messaging

Package:

firebase_messaging

Purpose:

- Push notifications
- Stock alerts
- Order notifications

---

## Firebase Analytics

Package:

firebase_analytics

Purpose:

- Track user behavior
- Application analytics

---

# Local Database

Library:

Isar Database

Purpose:

- Offline storage
- Local cache
- Synchronization queue

---

---

# 5. Application Architecture

SmartStock follows:

Clean Architecture

-

Feature First Architecture

The purpose:

- Separate business logic from UI
- Easy testing
- Easy maintenance
- Easy feature expansion

---

# 5.1 Architecture Layers

The application is divided into three main layers:

```
Presentation Layer

        |
        |

Domain Layer

        |
        |

Data Layer

        |
        |

Firebase / Local Database

```

---

# Presentation Layer

Responsible for:

- UI rendering
- User interaction
- State management

Contains:

```
Screens

Widgets

Providers

Controllers

```

Example:

```
ProductScreen

      |

ProductProvider

      |

ProductState

```

---

# Domain Layer

Responsible for:

- Business rules
- Application logic
- Use cases

Contains:

```
Entities

Repository Interfaces

Use Cases

```

Example:

```
CreateOrderUseCase

GetProductsUseCase

UpdateInventoryUseCase

```

---

# Data Layer

Responsible for:

- Data access
- External services
- Data conversion

Contains:

```
Models

Repository Implementations

Firebase Services

Local Database Services

```

Example:

```
ProductRepositoryImpl

        |

ProductFirestoreService

        |

Cloud Firestore

```

---

# 6. Project Folder Structure

The project follows Feature First Architecture.

```
lib/


├── main.dart


├── app/


│   ├── app.dart

│   ├── router.dart

│   └── providers.dart



├── core/


│   ├── constants/

│   ├── theme/

│   ├── utils/

│   ├── extensions/

│   ├── services/

│   └── exceptions/



├── shared/


│   ├── widgets/

│   ├── components/

│   ├── dialogs/

│   └── buttons/



├── features/


│
├── auth/


│
├── dashboard/


│
├── products/


│
├── inventory/


│
├── orders/


│
├── pos/


│
├── employees/


│
├── reports/


│
└── settings/

```

---

# 7. Feature Structure

Every feature must follow the same structure.

Example:

Products Feature:

```
products/


├── data/


│
├── models/

│     product_model.dart


│
├── repositories/

│     product_repository_impl.dart


│
├── services/

│     product_firestore_service.dart




├── domain/


│
├── entities/

│     product.dart


│
├── repositories/

│     product_repository.dart


│
└── usecases/


      create_product.dart

      delete_product.dart

      get_products.dart




├── presentation/


│
├── screens/


│     product_list_screen.dart

│     product_detail_screen.dart


│
├── widgets/


│     product_card.dart


│
└── providers/


      product_provider.dart

```

---

# 8. Core Folder Responsibility

## constants/

Contains:

- App constants
- Firebase collection names
- App configuration

Example:

```
app_constants.dart

firebase_constants.dart

```

---

## theme/

Contains:

```
app_theme.dart

app_colors.dart

app_text_styles.dart

```

Purpose:

Centralized design system.

---

## services/

Contains global services:

Examples:

```
notification_service.dart

storage_service.dart

network_service.dart

sync_service.dart

```

---

## utils/

Contains:

```
validators

formatters

helpers

extensions

```

---

# 9. Navigation Blueprint

Library:

go_router

The application starts from:

```
Splash Screen

        |

Authentication Check

        |

Check User Role

        |

Navigate To Correct Dashboard

```

---

# 10. Authentication Navigation Flow

```
                 App Start


                    |

                    |

              Splash Screen


                    |

                    |

          Check Firebase Authentication


              /                 \


       Logged In              Guest


          |                      |


   Load User Profile            Login


          |

          |

    Check User Role


          |

--------------------------------------


       |              |              |


    Owner           Staff       Warehouse


```

---

# 11. Route Structure

## Public Routes

```
/

/login

/register

/forgot-password

```

---

# Owner Routes

```
/owner/dashboard


/owner/products


/owner/products/:id


/owner/products/create


/owner/products/edit/:id


/owner/inventory


/owner/orders


/owner/reports


/owner/employees


/owner/settings

```

---

# Staff Routes

```
/staff/home


/staff/pos


/staff/scanner


/staff/cart


/staff/checkout


/staff/orders


/staff/profile

```

---

# Warehouse Routes

```
/warehouse/home


/warehouse/inventory


/warehouse/receive-stock


/warehouse/adjust-stock


/warehouse/history

```

---

# 12. Application Navigation Layout

## Owner Bottom Navigation

```
Dashboard

Products

Inventory

Orders

Profile

```

---

## Staff Bottom Navigation

```
Home

POS

Orders

Products

Profile

```

---

## Warehouse Bottom Navigation

```
Home

Inventory

Receive

History

Profile

```

---

# 13. UI Component Strategy

Reusable components should be created in:

```
shared/widgets/

```

Examples:

## Common Components

```
AppButton

AppTextField

LoadingWidget

ErrorWidget

EmptyStateWidget

ConfirmDialog

```

---

## Business Components

```
ProductCard

OrderCard

InventoryCard

StatisticCard

ChartCard

```

---

# 14. Dependency Injection Strategy

Riverpod will manage dependencies.

Example:

```
Screen


 |

Provider


 |

UseCase


 |

Repository


 |

Firebase Service

```

---

Example:

Product Provider:

```
productProvider


        |

ProductRepository


        |

Firestore

```

---

# 15. Naming Convention

## Files

Use snake_case:

Correct:

```
product_repository.dart

order_detail_screen.dart

```

Incorrect:

```
ProductRepository.dart

OrderScreen.dart

```

---

# Classes

Use PascalCase:

Example:

```
ProductRepository

OrderController

InventoryService

```

---

# Variables

Use camelCase:

Example:

```
productList

currentUser

orderTotal

```

---

# 16. Code Quality Rules

Every feature must contain:

```
Model

Repository

Provider

Screen

Reusable Widgets

Error Handling

Loading State

Empty State

```

---

---

# 17. Firebase Database Design

SmartStock uses:

Cloud Firestore

Database design follows:

- Document-oriented structure
- Scalable collections
- Role-based access
- Store isolation

---

# 18. Firestore Root Collections

The system contains:

```
Firestore


├── users

├── stores

├── categories

├── products

├── variants

├── customers

├── orders

├── inventory_transactions

├── notifications

└── audit_logs

```

---

# 19. Database Relationship Overview

Firestore does not use traditional SQL relationships.

Relationships are managed using document references.

Architecture:

```
Users

 |

 |

Stores

 |

 |---------------------

 |                    |

Products          Employees


 |

 |

Variants


 |

 |---------------------

 |                    |

Orders        Inventory Transactions


 |

 |

Order Items


```

---

# 20. Users Collection

Purpose:

Store authentication profile and permissions.

Collection:

```
users/{uid}

```

Document:

```json
{
  "uid": "user001",

  "name": "David Smith",

  "email": "david@gmail.com",

  "role": "STAFF",

  "storeId": "store001",

  "avatarUrl": "",

  "phone": "",

  "createdAt": "timestamp",

  "isActive": true
}
```

---

## User Fields

| Field     | Type      | Description               |
| --------- | --------- | ------------------------- |
| uid       | String    | Firebase Auth UID         |
| name      | String    | User full name            |
| email     | String    | Login email               |
| role      | String    | OWNER / STAFF / WAREHOUSE |
| storeId   | String    | Belonging store           |
| avatarUrl | String    | Profile image             |
| createdAt | Timestamp | Creation date             |
| isActive  | Boolean   | Account status            |

---

# 21. Roles

Available roles:

```
OWNER

STAFF

WAREHOUSE_MANAGER

```

---

# 22. Stores Collection

Purpose:

Store information.

Path:

```
stores/{storeId}

```

Example:

```json
{
  "name": "Smart Fashion Store",

  "address": "New York",

  "phone": "+123456789",

  "ownerId": "user001",

  "logoUrl": "",

  "createdAt": "timestamp"
}
```

---

# 23. Categories Collection

Purpose:

Group products.

Path:

```
categories/{categoryId}

```

Example:

```json
{
  "name": "Hoodie",

  "description": "Winter clothing",

  "storeId": "store001",

  "createdAt": "timestamp"
}
```

---

# 24. Products Collection

Purpose:

Store general product information.

Path:

```
products/{productId}

```

Example:

```json
{
  "name": "Vintage Oversized Hoodie",

  "description": "Premium cotton hoodie",

  "imageUrl": "image_url",

  "categoryId": "category001",

  "storeId": "store001",

  "createdAt": "timestamp",

  "updatedAt": "timestamp"
}
```

---

# Product Rules

A product represents a common item.

Example:

```
Product:

Nike Hoodie


Variants:

Black - M

Black - L

White - M

```

Product does not store stock quantity.

Stock belongs to Variant.

---

# 25. Variants Collection

Purpose:

Store different versions of a product.

Path:

```
variants/{variantId}

```

Example:

```json
{
  "productId": "product001",

  "sku": "HD-BLK-L",

  "barcode": "893456789",

  "color": "Black",

  "size": "L",

  "costPrice": 20,

  "sellingPrice": 45,

  "stock": 50,

  "storeId": "store001"
}
```

---

# Variant Fields

| Field        | Type   | Description           |
| ------------ | ------ | --------------------- |
| productId    | String | Parent product        |
| sku          | String | Internal product code |
| barcode      | String | Scanner code          |
| color        | String | Product color         |
| size         | String | Product size          |
| costPrice    | Number | Import cost           |
| sellingPrice | Number | Selling price         |
| stock        | Number | Available quantity    |

---

# 26. Customers Collection

Purpose:

Store customer information.

Path:

```
customers/{customerId}

```

Example:

```json
{
  "name": "John Smith",

  "phone": "+123456",

  "email": "john@gmail.com",

  "storeId": "store001",

  "totalSpent": 2500,

  "createdAt": "timestamp"
}
```

---

# 27. Orders Collection

Purpose:

Store sales transactions.

Path:

```
orders/{orderId}

```

Example:

```json
{
  "orderCode": "ORD-10001",

  "storeId": "store001",

  "staffId": "user001",

  "customerId": "customer001",

  "subtotal": 100,

  "discount": 10,

  "tax": 5,

  "total": 95,

  "paymentMethod": "CASH",

  "status": "COMPLETED",

  "createdAt": "timestamp"
}
```

---

# Order Status

```
PENDING

CONFIRMED

COMPLETED

CANCELLED

```

---

# Payment Method

```
CASH

CARD

BANK_TRANSFER

ONLINE

```

---

# 28. Order Items Subcollection

Purpose:

Store purchased products.

Path:

```
orders/{orderId}/items/{itemId}

```

Example:

```json
{
  "variantId": "variant001",

  "productName": "Vintage Hoodie",

  "color": "Black",

  "size": "L",

  "quantity": 2,

  "price": 45,

  "subtotal": 90
}
```

---

# 29. Inventory Transactions Collection

Purpose:

Track every stock change.

Path:

```
inventory_transactions/{transactionId}

```

Example:

```json
{
  "variantId": "variant001",

  "type": "SALE",

  "quantity": -2,

  "beforeStock": 50,

  "afterStock": 48,

  "createdBy": "user001",

  "createdAt": "timestamp"
}
```

---

# Transaction Types

```
IMPORT

SALE

RETURN

ADJUSTMENT

DAMAGE

```

---

# Inventory Business Rule

Never update stock without creating transaction history.

Example:

Customer buys 2 products:

Wrong:

```
stock = stock - 2

```

Correct:

```
Create Order


↓

Update Stock


↓

Create Inventory Transaction

```

---

# 30. Notifications Collection

Purpose:

Store application notifications.

Path:

```
notifications/{notificationId}

```

Example:

```json
{
  "userId": "user001",

  "title": "Low Stock Alert",

  "message": "Nike Hoodie only 5 left",

  "type": "LOW_STOCK",

  "isRead": false,

  "createdAt": "timestamp"
}
```

---

# Notification Types

```
LOW_STOCK

ORDER_CREATED

ORDER_COMPLETED

STOCK_RECEIVED

SYSTEM

```

---

# 31. Audit Logs Collection

Purpose:

Track important user actions.

Path:

```
audit_logs/{logId}

```

Example:

```json
{
  "userId": "user001",

  "action": "DELETE_PRODUCT",

  "target": "product001",

  "description": "Deleted Hoodie",

  "createdAt": "timestamp"
}
```

---

# 32. Firestore Index Requirements

Required indexes:

## Products

Search:

```
storeId

categoryId

createdAt

```

---

## Orders

Filter:

```
storeId

status

createdAt

```

---

## Inventory

Filter:

```
storeId

type

createdAt

```

---

# 33. Data Access Rules Concept

All data must be isolated by store.

Example:

A user from:

```
store001

```

Cannot access:

```
store002

```

---

# Access Rules Overview

## Owner

Can:

```
Read all store data

Create data

Update data

Delete data

```

---

## Staff

Can:

```
Read products

Create orders

Read own orders

```

Cannot:

```
Delete products

View reports

Manage employees

```

---

## Warehouse

Can:

```
Read inventory

Update stock

Create inventory transactions

```

---

# 34. Data Flow Example

## Creating an Order

Flow:

```
Staff Checkout


        |

Validate Cart


        |

Create Order Document


        |

Create Order Items


        |

Update Variant Stock


        |

Create Inventory Transaction


        |

Send Notification


        |

Refresh Dashboard

```

---

# 35. Product Loading Flow

```
Product Screen


        |

productProvider


        |

ProductRepository


        |

Firestore Query


        |

Return Product List


        |

Update UI

```

---

# 36. Database Design Rules

Rules:

1. Never store duplicated business data unnecessarily.

2. Product and Variant must be separated.

3. Every stock change requires transaction history.

4. Every document must contain storeId.

5. All timestamps use Firebase Timestamp.

6. Business calculations should happen in application logic.

---

---

# 37. State Management Architecture

SmartStock uses:

Riverpod

Architecture:

```
UI Screen

    |

Provider / Notifier

    |

UseCase

    |

Repository

    |

Firebase / Local Database

```

---

# 38. Provider Organization

Providers are separated by feature.

Structure:

```
features/


auth/

    providers/


products/

    providers/


inventory/

    providers/


orders/

    providers/


pos/

    providers/


dashboard/

    providers/

```

---

# 39. Authentication State Management

Purpose:

Manage login state and user information.

Providers:

## authStateProvider

Responsible for:

- Firebase authentication state
- Login status
- Logout status

Flow:

```
Firebase Auth


        |

authStateProvider


        |

Application Router


        |

Navigate User

```

---

## currentUserProvider

Stores:

```
User UID

Name

Email

Role

Store ID

```

---

## roleProvider

Purpose:

Determine application access.

Example:

```
OWNER

↓

Owner Dashboard



STAFF

↓

POS Screen



WAREHOUSE

↓

Inventory Screen

```

---

# 40. Product State Management

Product module providers:

## productListProvider

Purpose:

Load product list.

Flow:

```
Product Screen


        |

productListProvider


        |

ProductRepository


        |

Firestore


```

---

## productDetailProvider

Purpose:

Load a single product.

Input:

```
productId

```

Output:

```
Product Detail

Variants

Stock Information

```

---

## productSearchProvider

Purpose:

Search products.

Example:

```
User types:

hoodie


↓

Query Firestore


↓

Return products

```

---

# 41. Inventory State Management

Providers:

## inventoryProvider

Purpose:

Manage inventory list.

Contains:

```
Products

Variants

Stock Quantity

```

---

## lowStockProvider

Purpose:

Find products below minimum stock.

Logic:

```
if(stock <= minimumStock)

return product

```

---

## inventoryTransactionProvider

Purpose:

Display stock history.

Example:

```
+100 Hoodie Imported

-2 Hoodie Sold

-1 Damaged

```

---

# 42. Cart State Management

Cart is a local application state.

Provider:

```
cartProvider

```

Stores:

```
Selected Products

Quantity

Price

Subtotal

Discount

Total

```

---

Cart Flow:

```
Scan Product


      |

Find Variant


      |

Add To Cart


      |

Update cartProvider


      |

Checkout

```

---

# 43. Order State Management

Providers:

## orderProvider

Purpose:

Create and manage orders.

Functions:

```
createOrder()

cancelOrder()

updateOrderStatus()

```

---

## orderHistoryProvider

Purpose:

Load previous orders.

Filter:

```
Today

This Week

This Month

Status

```

---

# 44. Dashboard State Management

Providers:

## dashboardProvider

Returns:

```
Total Revenue

Total Orders

Total Products

Low Stock Count

```

---

## salesChartProvider

Returns:

```
Daily Sales

Weekly Sales

Monthly Sales

```

---

# 45. Repository Pattern

Every feature communicates through repository.

Example:

```
ProductScreen


      |

ProductProvider


      |

ProductRepository


      |

ProductFirebaseService


      |

Cloud Firestore

```

---

# 46. Repository Responsibilities

Repository handles:

- Data fetching
- Data saving
- Data conversion
- Error handling

Repository does NOT handle:

- UI logic
- Widget state
- Navigation

---

# 47. Product Repository Example

Interface:

```
ProductRepository

```

Functions:

```
getProducts()

getProductById()

createProduct()

updateProduct()

deleteProduct()

searchProducts()

```

---

Implementation:

```
ProductRepositoryImpl


        |

ProductFirebaseService


        |

Firestore

```

---

# 48. Use Case Layer

Use cases represent business actions.

Example:

Create Product:

```
CreateProductUseCase


Input:

Product Data


Process:

Validate

Save Product

Create Variant


Output:

Success / Failure

```

---

# 49. Main Business Logic

---

# 49.1 Authentication Flow

```
Application Start


↓

Firebase Auth Check


↓

Get User UID


↓

Load User Document


↓

Check Role


↓

Navigate Dashboard

```

---

# 49.2 Create Product Flow

Actor:

Owner

Flow:

```
Open Add Product Screen


↓

Enter Product Information


↓

Upload Image


↓

Validate Data


↓

Create Product Document


↓

Create Variant Documents


↓

Refresh Product Provider


↓

Show Success Message

```

---

# 49.3 Update Product Flow

```
Owner Edit Product


↓

Update Product Document


↓

Update Variant


↓

Refresh State

```

---

# 49.4 Delete Product Flow

Before deleting:

Check:

```
Does product have existing orders?

Does product have stock?

```

If yes:

Option:

```
Disable Product

```

Instead of deleting.

---

# 49.5 Inventory Import Flow

Actor:

Warehouse Manager

Flow:

```
Select Product Variant


↓

Enter Quantity


↓

Validate


↓

Increase Stock


↓

Create Inventory Transaction


↓

Send Notification

```

---

# 49.6 Inventory Adjustment Flow

Example:

Damaged item:

```
Current Stock:

100


Adjustment:

-5


Reason:

Damaged


↓

Update Stock:

95


↓

Create Transaction

```

---

# 49.7 POS Selling Flow

Actor:

Staff

Complete flow:

```
Open POS


↓

Search Product

or

Scan Barcode


↓

Find Variant


↓

Add To Cart


↓

Modify Quantity


↓

Checkout


↓

Validate Stock


↓

Create Order


↓

Decrease Inventory


↓

Create Transaction


↓

Generate Receipt


```

---

# 49.8 Order Creation Transaction

Important rule:

Order creation must be atomic.

Process:

```
BEGIN


Create Order


Create Order Items


Update Stock


Create Inventory Transaction


COMMIT


```

If error:

```
ROLLBACK

```

---

# 50. Offline Architecture

Goal:

Application can continue working without Internet.

---

# Offline Data Strategy

Local database:

Isar

Stores:

```
Cached Products

Pending Orders

Pending Transactions

User Preferences

```

---

# 51. Offline Flow

```
User Action


        |

Check Internet


        |

-----------------------

|                     |

Online              Offline


|                     |

Firebase             Isar


|                     |

Success          Sync Queue


```

---

# 52. Sync System

When internet returns:

```
Sync Service


      |

Find Pending Data


      |

Upload Firebase


      |

Update Local Status


      |

Remove Queue

```

---

# 53. Offline Order Example

Without internet:

Staff creates order:

```
Order ID:

local_001


syncStatus:

PENDING

```

Internet returns:

```
Upload Order


↓

Firebase Order Created


↓

syncStatus:

COMPLETED

```

---

# 54. Error Handling Strategy

Every feature must handle:

## Loading

Example:

```
Loading products...

```

---

## Empty

Example:

```
No products found

```

---

## Error

Example:

```
Something went wrong

Retry

```

---

# 55. Application Services

Global services:

## Authentication Service

Handles:

```
Login

Register

Logout

Current User

```

---

## Storage Service

Handles:

```
Upload Image

Delete Image

Get URL

```

---

## Notification Service

Handles:

```
Push Notification

Local Notification

```

---

## Sync Service

Handles:

```
Offline Queue

Data Synchronization

```

---

# 56. Business Rules Summary

Important rules:

1. Every user belongs to a store.

2. Every product belongs to a store.

3. Every stock change creates transaction history.

4. Staff cannot access financial reports.

5. Orders cannot exceed available stock.

6. Product deletion should be avoided if historical data exists.

7. Offline actions must be synchronized safely.

8. Every critical action should create audit logs.

---

---

# 57. Firebase Security Strategy

SmartStock uses Firebase Security Rules to protect business data.

Main principle:

```
Every user can only access data belonging to their store.

```

---

# 58. Authentication Security

Firebase Authentication manages:

- Email/password authentication
- User identity
- Session management
- Password reset

User identity:

```
Firebase UID

        |

users collection

        |

Application permission

```

---

# 59. Role-Based Access Control

User role is stored in:

```
users/{uid}

```

Example:

```json
{
  "role": "OWNER"
}
```

Application checks role before allowing access.

---

# 60. Permission Matrix

| Feature          | Owner | Staff    | Warehouse |
| ---------------- | ----- | -------- | --------- |
| View Dashboard   | ✓     | Limited  | Limited   |
| View Products    | ✓     | ✓        | ✓         |
| Create Product   | ✓     | ✗        | ✗         |
| Update Product   | ✓     | ✗        | ✗         |
| Delete Product   | ✓     | ✗        | ✗         |
| Create Order     | ✓     | ✓        | ✗         |
| View Orders      | ✓     | Own only | ✗         |
| Manage Inventory | ✓     | ✗        | ✓         |
| Import Stock     | ✓     | ✗        | ✓         |
| View Reports     | ✓     | ✗        | ✗         |
| Manage Employees | ✓     | ✗        | ✗         |

---

# 61. Firestore Security Rules Logic

Example:

## Product Access

Requirement:

A user can only access products from their own store.

Logic:

```
Request User UID

        |

Get User Store ID

        |

Compare Product Store ID

        |

Allow / Deny

```

---

# 62. Data Validation Rules

Before writing data:

Validate:

## Product

Required:

```
name

categoryId

storeId

variant

price

```

---

## Order

Required:

```
items

total

paymentMethod

staffId

storeId

```

---

## Inventory

Required:

```
variantId

quantity

transactionType

createdBy

```

---

# 63. Development Roadmap

The project will be developed in multiple phases.

---

# Phase 0: Planning & Blueprint

Status:

Completed

Tasks:

✓ Define product requirements

✓ Define actors

✓ Design architecture

✓ Design Firestore schema

✓ Define application flow

✓ Define folder structure

Output:

```
PLAN.md

```

---

# Phase 1: Flutter Foundation

Goal:

Create the application foundation.

Tasks:

## Flutter Setup

- Create Flutter project
- Configure package structure
- Configure app theme
- Configure environment

## Firebase Setup

Install:

```
firebase_core

firebase_auth

cloud_firestore

firebase_storage

firebase_messaging

```

Configure:

- Firebase project
- Android configuration
- iOS configuration

## Architecture Setup

Create:

```
core

shared

features

app

```

## State Management Setup

Configure:

```
Riverpod

Provider structure

Dependency injection

```

## Navigation Setup

Implement:

```
go_router

Route protection

Authentication redirect

```

Output:

Application can run with a clean architecture foundation.

---

# Phase 2: Authentication System

Goal:

Implement user authentication.

Features:

## Login

Flow:

```
Input Email

Input Password

Firebase Authentication

Load User Profile

Check Role

Navigate

```

---

## Register

Features:

- Create Firebase account
- Create user document
- Assign default role

---

## Forgot Password

Features:

- Email reset
- Validation

---

## User Profile

Features:

- View information
- Update avatar
- Update personal data

Output:

Users can access the correct application area based on role.

---

# Phase 3: Product Management

Goal:

Complete product module.

Features:

## Category Management

- Create category
- Update category
- Delete category

---

## Product CRUD

Features:

- Create product
- Edit product
- Delete product
- View product detail

---

## Product Variant

Support:

```
Color

Size

SKU

Barcode

Cost Price

Selling Price

Stock

```

---

## Image Management

Features:

- Pick image
- Upload Firebase Storage
- Display cached image

---

## Search

Features:

- Search by name
- Search by SKU
- Search by barcode

Output:

Owner can fully manage products.

---

# Phase 4: Inventory Management

Goal:

Control stock movement.

Features:

## Stock Overview

Display:

- Total products
- Available stock
- Low stock products

---

## Import Stock

Flow:

```
Select Product

Input Quantity

Confirm

Increase Stock

Create Transaction

```

---

## Stock Adjustment

Reasons:

```
Damaged

Lost

Expired

Manual Correction

```

---

## Inventory History

Display:

```
+100 Imported

-5 Damaged

-2 Sold

```

Output:

Warehouse workflow completed.

---

# Phase 5: POS & Order System

Goal:

Implement selling workflow.

Features:

## Product Selection

Methods:

- Search
- Barcode scanner

---

## Cart

Features:

- Add item
- Remove item
- Change quantity
- Calculate total

---

## Checkout

Support:

```
Cash

Card

Online

```

---

## Order Creation

Process:

```
Create Order

Create Order Items

Decrease Stock

Create Inventory Transaction

Clear Cart

```

Output:

Staff can complete real sales.

---

# Phase 6: Dashboard & Analytics

Goal:

Provide business insights.

Features:

## Dashboard Cards

Display:

```
Revenue

Orders

Products

Low Stock

```

---

## Charts

Include:

- Revenue trend
- Sales by category
- Top products

Library:

```
fl_chart

```

---

## Reports

Features:

- Export PDF
- Export CSV

---

# Phase 7: Advanced Features

Goal:

Improve production quality.

---

## Offline Mode

Implement:

- Isar local database
- Offline queue
- Sync service

---

## Notifications

Implement:

Firebase Cloud Messaging

Examples:

```
Low stock alert

New order created

Stock updated

```

---

## Crash Reporting

Add:

```
Firebase Crashlytics

```

---

## Application Analytics

Add:

```
Firebase Analytics

```

---

# 64. Testing Strategy

Testing is required for every important feature.

---

# Unit Testing

Purpose:

Test business logic.

Examples:

## Cart Calculation

Input:

```
Product A

Quantity 2

Price 20

```

Expected:

```
Total = 40

```

---

## Inventory Update

Input:

```
Stock 100

Sale -5

```

Expected:

```
Stock 95

```

---

# Widget Testing

Test:

- Login screen
- Product card
- Cart widget
- Checkout screen

---

# Integration Testing

Test complete flows.

Example:

```
Login

↓

Add Product

↓

Create Order

↓

Stock Decreases

```

---

# 65. Performance Optimization

Implement:

## Image Optimization

Use:

```
cached_network_image

```

---

## Pagination

For large data:

```
Products

Orders

Transactions

```

---

## Lazy Loading

Load data when needed.

---

## Firestore Optimization

Avoid:

- Excessive reads
- Unnecessary listeners
- Large documents

---

# 66. Deployment Strategy

## Android

Release:

```
Google Play Store

```

Generate:

```
AAB file

```

---

## iOS

Release:

```
App Store

```

Generate:

```
IPA file

```

---

# 67. Documentation

Project should include:

## README.md

Contains:

- Project overview
- Features
- Screenshots
- Architecture
- Installation guide

---

## Documentation

Include:

```
docs/


architecture.md

database.md

api_reference.md

development_guide.md

```

---

# 68. Git Workflow

Branch strategy:

```
main

 |

develop

 |

feature/*

```

---

Example:

Create feature:

```
feature/authentication

feature/product-management

feature/order-system

```

---

Commit convention:

Examples:

```
feat: add login screen


fix: resolve cart calculation bug


docs: update project plan


refactor: improve product repository

```

---

# 69. Definition Of Done

A feature is considered completed when:

## UI

✓ Screen implemented

✓ Responsive layout

✓ Loading state

✓ Empty state

✓ Error state

---

## Logic

✓ Business logic completed

✓ State management implemented

✓ Repository connected

---

## Data

✓ Firebase integration completed

✓ Data validation added

✓ Error handling added

---

## Quality

✓ Unit test added

✓ Code formatted

✓ Documentation updated

---

# 70. Final Project Goal

After completion, SmartStock should demonstrate:

Technical Skills:

✓ Flutter development

✓ Clean Architecture

✓ Riverpod state management

✓ Firebase integration

✓ Firestore database design

✓ Offline-first application

✓ Role-based authorization

✓ POS business logic

✓ Inventory management

✓ Testing

Portfolio Result:

A production-style Flutter application suitable for:

- Junior Flutter Developer
- Mobile Developer
- Flutter Full-stack Developer

---
