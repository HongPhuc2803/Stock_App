---
name: SmartStock Identity
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#434655'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#006c49'
  on-secondary: '#ffffff'
  secondary-container: '#6cf8bb'
  on-secondary-container: '#00714d'
  tertiary: '#784b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#996100'
  on-tertiary-container: '#ffeedd'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  display-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  stats-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  edge-margin: 16px
  gutter: 12px
---

## Brand & Style

The design system is engineered for efficiency, reliability, and precision. It targets small to medium-sized business owners who require a high-density information environment that remains legible and low-friction during high-speed operations like point-of-sale transactions.

The visual style is **Corporate Modern** with a focus on **Tonal Layering**. It adopts the structural logic of Material 3 but applies a SaaS-specific refinement: reducing the playfulness of M3 in favor of a crisp, "Stripe-like" professional aesthetic. The interface relies on generous white space (breathability) to offset high-density data tables and inventory lists.

**Key visual principles:**
- **Clarity over Decoration:** Every element serves a functional purpose.
- **Utility-First:** Primary actions are always high-contrast; secondary actions are subtle.
- **Trust through Precision:** Perfect alignment, consistent stroke weights, and systematic spacing.

## Colors

This design system utilizes a functional color palette where hue signifies state. 

- **Primary (Deep Blue):** Used for primary actions, active navigation states, and brand presence.
- **Secondary (Emerald Green):** Reserved for "Success" states, positive financial trends, and "In Stock" indicators.
- **Warning (Orange):** Exclusively for "Low Stock" alerts and pending actions.
- **Danger (Red):** Used for "Out of Stock" alerts, deletions, and critical errors.
- **Neutrals:** A slate-based neutral scale is used to maintain a cool, professional temperature across the UI.

**Dark Mode Implementation:**
In dark mode, surfaces should use a deep navy-gray (`#0F172A`) rather than pure black to maintain soft contrast. Primary and secondary colors should be desaturated by 10% to ensure AAA accessibility against dark backgrounds.

## Typography

**Inter** is the sole typeface, chosen for its exceptional legibility in data-heavy mobile interfaces. 

- **Hierarchy:** Use `display-lg` for dashboard totals and `stats-lg` for tabular numeric data to ensure key metrics are scannable at a glance.
- **Caps Usage:** `label-md` should be used in ALL CAPS with 0.05em letter spacing for section headers and table column titles.
- **Numerical Data:** For POS screens, use tabular lining figures (if available in the font weight) to ensure price columns align perfectly.
- **Mobile Scaling:** On small devices, `display-lg` should scale down to 28px to prevent awkward line breaks in inventory titles.

## Layout & Spacing

The layout follows a **Fluid Grid** model optimized for mobile-first SaaS workflows. 

- **Grid:** Use a 4-column grid for mobile and an 8-column grid for tablet/landscape orientations.
- **Rhythm:** All spacing must be multiples of 4px. 
- **Margins:** Standard screen padding is 16px (`md`). Elements within cards use 12px (`gutter`) to maximize content density without feeling cramped.
- **Vertical Rhythm:** Use 24px (`lg`) between distinct logical sections (e.g., between a "Recent Transactions" list and a "Stock Alerts" carousel).

## Elevation & Depth

This design system uses **Tonal Layers** combined with **Ambient Shadows** to define hierarchy.

- **Level 0 (Background):** `#F8FAFC`. The lowest plane.
- **Level 1 (Cards/Surface):** White `#FFFFFF` with a very soft shadow: `0px 1px 3px rgba(0,0,0,0.05), 0px 1px 2px rgba(0,0,0,0.03)`.
- **Level 2 (Active/Selected):** Used for pressed states or active modals. Shadow: `0px 10px 15px -3px rgba(0,0,0,0.1)`.
- **Glassmorphism:** Use only for the Bottom Navigation Bar (10px Blur, 80% opacity) to allow the content to scroll subtly behind the navigation, providing a sense of depth and place.

## Shapes

The shape language is **Rounded**, reflecting a modern, approachable enterprise tool.

- **Standard Containers:** Use `rounded-lg` (16px) for cards and main surface areas.
- **Buttons/Inputs:** Use `rounded-md` (12px) to maintain a professional, slightly more structured look for interactive elements.
- **Badges/Chips:** Use `rounded-full` (Pill) for status indicators (e.g., "Available").
- **Icons:** Use a 2px stroke weight with rounded caps and joins to match the UI's geometry.

## Components

### Buttons
- **Primary:** Solid `#2563EB` fill, white text, 12px radius. High emphasis.
- **Secondary:** White fill, 1px `#E2E8F0` border, `#1E293B` text.
- **Floating Action Button (FAB):** Always primary color, elevated (Level 2), containing a simple '+' icon for quick inventory entry or new sale.

### Input Fields
- **Default State:** White background, 1px `#E2E8F0` border.
- **Focus State:** 2px `#2563EB` border with a subtle 4px outer glow of the same color at 10% opacity.
- **Labels:** Always persistent above the field in `label-md` weight.

### Status Badges
- **Low Stock:** Orange background (10% opacity), Orange text.
- **In Stock:** Green background (10% opacity), Green text.
- **Out of Stock:** Red background (10% opacity), Red text.

### Cards
- **Stat Cards:** Must feature a `stats-lg` number, a `label-md` description, and a small sparkline or percentage trend indicator in the top right corner.
- **List Items:** 72px height, subtle bottom border (`#F1F5F9`), with an image/icon slot (48px) on the left.

### Navigation
- **Bottom Bar:** 4-5 icons max. Active state uses the Primary color for both icon and a small 4px dot indicator underneath.