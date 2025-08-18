# Sprint 1 · Topic 1 — Accessibility & Inclusion  

## 🎯 Demo App Overview

This is a **simplified drawing app** designed to demonstrate **cognitive accessibility** principles for users with cognitive disabilities. The app showcases how to implement **iOS Assistive Access** integration and universal design practices.

### What the App Does:
- **Draw** → Pick a color, tap canvas to create dot patterns, save artwork
- **Gallery** → View saved drawings, tap any item to see details

### Accessibility Purpose:
- **Assistive Access Ready** - Appears as "Optimized App" in iOS Assistive Access mode
- **Cognitive Accessibility** - Demonstrates simplified UI with only 2 core actions
- **Universal Design** - Benefits all users through clearer, more focused interface
- **Step-by-step workflow** - Color selection isolated from drawing to reduce cognitive load
- **Safe interactions** - Confirmation dialogs for destructive actions, no timeouts
- **Large, clear controls** - Icon + text labels, explicit buttons (no hidden gestures)

This serves as a **real-world example** of implementing Apple's WWDC 2025 accessibility guidelines for inclusive app design.

---

## Assistive Access Implementation Notes & Example Use Cases

### 1) Choose your integration mode
- **Mode A: Full-screen (unchanged UI)**  
  Use if your app is *already* purpose-built for cognitive accessibility (e.g., AAC apps).  
  - Add `UISupportsFullScreenInAssistiveAccess = true` to `Info.plist`.  
  - Result: Your existing UI fills the screen; otherwise unchanged.

- **Mode B: Assistive Access Scene (recommended default)**  
  Use to deliver a **streamlined** experience with large, consistent controls and auto grid/row layout.  
  - Add `UISupportsAssistiveAccess = true` to `Info.plist`.  
  - Implement an **Assistive Access scene** that hosts a focused hierarchy (your “essentials only” UI).

> Tip: If you’re unsure, **pick the scene** to leverage the system’s control styling/layout and reduce cognitive load.

---

### 2) App structure (high level)
- **SwiftUI lifecycle**: keep your regular `WindowGroup` for the full app, and add an **Assistive Access scene** with a simplified root view (e.g., a short list of primary actions). Controls automatically adopt the larger visual style and the user’s grid/row preference.
- **UIKit lifecycle**: **bridge** in the SwiftUI Assistive Access scene via your scene delegate (`static rootScene`) and activate it from the app delegate.

---

### 3) Design checklist (apply to your AA scene)
- **Distill to 1–2 core tasks** for the root screen (e.g., “Draw” and “Gallery” only).  
- **Reduce choices per view**; avoid long lists, nested menus, and hidden gestures. Prefer explicit buttons.  
- **Avoid timed UI**; never auto-dismiss crucial controls.  
- **Guide with steps**; break multi-choice flows into smaller screens.  
- **Handle destructive actions safely** (double-confirm or omit).  
- **Always pair icons + labels** (including navigation titles via Assistive Access nav-icon modifiers).

---

### 4) Info.plist snippets
```xml
<!-- Enables listing under Optimized Apps + full-screen launch in Assistive Access -->
<key>UISupportsAssistiveAccess</key>
<true/>

<!-- Use only if your existing, accessibility-first layout should run full-screen unchanged -->
<key>UISupportsFullScreenInAssistiveAccess</key>
<true/>
```

---

### 5) Navigation & layout behavior
- **Back to Home**: persistent system **Back** button along the bottom; no custom wiring needed.  
- **Grid/Row**: your SwiftUI lists/buttons **auto-adapt** to the grid/row setting in Assistive Access Settings.

---

### 6) Testing
- **SwiftUI Previews**: pass the **Assistive Access trait** to preview your scene in AA style/layout.  
- **User testing**: plan sessions with the **Assistive Access community** for real feedback.

---

### 7) Example use cases

**A. Drawing app (from session pattern, adapted)**  
- Root: just **“Draw”** and **“Gallery”**.  
- Insert a **Color Choose** step *before* canvas to isolate that decision; offer a **small, curated palette**; tap-to-select.  
- Remove/guard **Undo** and **Delete** to avoid accidental actions.

**B. Banking**  
- Root: **“Check balance”**, **“Transfer to saved contact”**.  
- Transfer flow: step 1 choose contact (with avatar icon), step 2 amount, step 3 confirm; **no hidden swipe actions**; **no timeouts**.

**C. Food ordering**  
- Root: **“Favorites”**, **“Reorder last”**.  
- Each step shows **2–4 choices max** with icon+label (e.g., pizza slice, burger), then a **single confirmation**.

---

### 8) Done-Definition (DoD)
- **Summary** committed at `1-accessibility-inclusion/WWDC25-238-summary.md`.  
- **Documentation** committed at `1-accessibility-inclusion/assistive-access-implementation.md` including:  
  - Decision on Mode A vs Mode B (with rationale).  
  - `Info.plist` changes.  
  - High-level scene wiring notes.  
  - A **UI map** for the AA scene (2–3 screens max on the happy path).  
  - A **QA checklist** derived from the Design checklist.  
  - **Test plan** notes (Preview + at least one real-user feedback step).  
  - 1–2 **example flows** expressed as numbered steps with screenshots/wireframes.
