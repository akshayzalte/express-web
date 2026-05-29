---
name: Glacier
colors:
  surface: '#f5faff'
  surface-dim: '#d5dbe1'
  surface-bright: '#f5faff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eef4fa'
  surface-container: '#e9eff5'
  surface-container-high: '#e3e9ef'
  surface-container-highest: '#dde3e9'
  on-surface: '#161c21'
  on-surface-variant: '#44474e'
  inverse-surface: '#2b3136'
  inverse-on-surface: '#ebf1f7'
  outline: '#74777e'
  outline-variant: '#c4c6cf'
  surface-tint: '#4a5f81'
  primary: '#000d22'
  on-primary: '#ffffff'
  primary-container: '#0a2342'
  on-primary-container: '#768baf'
  inverse-primary: '#b2c7ef'
  secondary: '#006c4e'
  on-secondary: '#ffffff'
  secondary-container: '#83f5c6'
  on-secondary-container: '#007151'
  tertiary: '#000f17'
  on-tertiary: '#ffffff'
  tertiary-container: '#002635'
  on-tertiary-container: '#0095c4'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d5e3ff'
  primary-fixed-dim: '#b2c7ef'
  on-primary-fixed: '#021c3a'
  on-primary-fixed-variant: '#324768'
  secondary-fixed: '#86f8c9'
  secondary-fixed-dim: '#68dbae'
  on-secondary-fixed: '#002115'
  on-secondary-fixed-variant: '#00513a'
  tertiary-fixed: '#c2e8ff'
  tertiary-fixed-dim: '#75d1ff'
  on-tertiary-fixed: '#001e2b'
  on-tertiary-fixed-variant: '#004d67'
  background: '#f5faff'
  on-background: '#161c21'
  surface-variant: '#dde3e9'
typography:
  headline-lg:
    fontFamily: DM Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: DM Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  body-md:
    fontFamily: DM Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: DM Sans
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 16px
  card-gap: 12px
  gutter: 16px
  margin-mobile: 20px
---

## Brand & Style

The design system is engineered for a high-end dental lab environment, blending clinical precision with the ethereal clarity of arctic ice. The brand personality is professional, hi-tech, and reassuring, targeting dental practitioners and lab technicians who require speed and accuracy. 

The visual style is a strict **Glassmorphism** execution. It leverages multi-layered translucency to represent the sterile yet advanced nature of modern dentistry. Surfaces should feel like polished frosted glass—cool to the touch, light, and organized. Every interactive container must maintain a high level of background blur to ensure legibility while preserving a sense of depth and spatial continuity.

## Colors

The palette is anchored in deep oceanic blues and crisp clinical greens. 

**Light Mode (Default):**
- **Background:** #EAF0F6 (Soft, cool grey-blue)
- **Surface:** rgba(255, 255, 255, 0.72) (The frost layer)
- **Primary:** #0A2342 (Deep navy for high-contrast text and primary actions)
- **Accent:** #1D9E75 (Emerald green for success and secondary highlights)

**Dark Mode:**
- **Background:** #0A1628 (Midnight blue)
- **Primary:** #1D9E75 (Shift to green for better visibility on dark)
- **Accent:** #4FC3F7 (Electric blue for interactive highlights)

Status badges use a semi-transparent version of their respective colors to maintain the glass aesthetic while providing semantic feedback.

## Typography

This design system uses **DM Sans** exclusively to maintain a modern, geometric, and clean appearance. The typeface provides excellent legibility for technical data and patient names. 

- **Titles:** Bold 28px for page headings and primary navigation nodes.
- **Headers:** SemiBold 22px for section headers within glass cards.
- **Body:** Regular 16px for all descriptions, form labels, and patient details.
- **Scale:** On mobile devices, ensure titles do not wrap awkwardly; use 24px for smaller screens if necessary (headline-lg-mobile).

## Layout & Spacing

The layout follows a **fluid grid** model optimized for handheld dental devices. It uses an 8px base grid to ensure consistent alignment.

- **Margins:** A standard 20px side margin is applied to the main viewport.
- **Gaps:** Vertical spacing between cards is set to 12px to allow the background to "breathe" through the glass layers.
- **Mobile/Tablet:** The layout is single-column on mobile. On tablets, glass cards can span two columns (6-6) in a 12-column grid to display patient charts alongside order histories.

## Elevation & Depth

Hierarchy is established through **Backdrop Blurs** rather than traditional drop shadows.

- **The Glass Standard:** Every card, modal, and navigation bar must utilize a `BackdropFilter` with a blur radius of `24`. 
- **Borders:** A `1px` solid white border at `0.25` opacity must be applied to all container edges. This "specular highlight" defines the shape of the glass against the background.
- **Stacking:** Modals and AppBars sit on a higher Z-index but use the same blur intensity. To differentiate stacked layers, use a slightly higher opacity white fill (`0.85`) for the top-most layer.

## Shapes

The shape language is friendly yet structured. A consistent `20px` (rounded-lg) corner radius is used for all glass containers, buttons, and input fields. This softened geometry balances the technical nature of the lab data, making the app feel approachable.

## Components

**Buttons**
Primary buttons are solid fills of the Primary color with white text. Secondary buttons use the glass style (translucent white) with primary colored text. All buttons must include a `scale(0.96)` transform on press for tactile feedback.

**Glass Cards**
The core unit of the UI. Must contain a 24px blur and the 0.25 opacity white border. Use staggered `fadeIn` + `slideUp` animations when a list of cards is loaded.

**Status Badges**
Small pill-shaped containers using the Glassmorphism style. The fill color should be a tinted version (20% opacity) of the status color (Orange, Blue, Green, or Purple) with a solid text color for readability.

**Input Fields**
Glass-style backgrounds with a `1px` border that increases to `0.5` opacity white when focused.

**Loading State**
Use a shimmer (skeleton) effect that mimics light passing through a glass pane, moving diagonally across the surface.

**Navigation**
The AppBar and Bottom Nav are "docked" glass panes. Use a subtle gradient overlay to ensure icons remain visible over high-contrast background content.