# Sprint 1 · Topic 1 — Accessibility & Inclusion  
## WWDC25-238: Assistive Access (iOS/iPadOS 26)

### Summary — Key takeaways
- **Two integration paths**  
  1) **Full-screen, unchanged UI** for apps already designed for people with cognitive disabilities — enable with `UISupportsFullScreenInAssistiveAccess=true`.  
  2) **New Assistive Access scene** for a streamlined, tailored UI that adopts the large, familiar control style used by built-in apps like Camera and Messages. When unsure, prefer the scene path.

- **Declare support so your app is listed as Optimized Apps and runs full-screen in Assistive Access** by setting `UISupportsAssistiveAccess=true`, then add the Assistive Access scene to supply your simplified experience.

- **SwiftUI & UIKit support**  
  SwiftUI apps add an Assistive Access scene; UIKit apps can **bridge in** a SwiftUI scene via the scene delegate (`static rootScene`) and app delegate.

- **Design principles for cognitive accessibility**  
  Distill to essentials; reduce on-screen choices; avoid hidden gestures; prefer prominent, visible controls; avoid timed interactions; guide users with **incremental, step-by-step flows**; gate destructive actions (or remove them).

- **Present information in multiple ways**  
  Pair **icons + labels** for buttons, links, and even navigation titles (Assistive Access supports nav-bar icons).

- **Layouts and navigation are handled for you**  
  Controls automatically adopt the Assisted Access **grid/row layout** chosen in Settings; a persistent **system back button** appears along the bottom and pops your navigation stack.

- **Preview & test**  
  You can pass the Assistive Access trait to **SwiftUI previews** to check layout and affordances as they’ll appear in Assistive Access.
