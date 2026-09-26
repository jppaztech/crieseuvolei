---
name: CrieSeuVôlei
description: Interface enxuta para organizar torneios de vôlei e acompanhar jogos ao vivo.
colors:
  ink: "#17251f"
  muted: "#53665b"
  court: "#236b4d"
  court-dark: "#174d39"
  ball: "#f2ad44"
  paper: "#f4f7f4"
  white: "#ffffff"
  line: "#d8e2da"
  soft: "#eaf0eb"
  danger: "#a62929"
typography:
  display:
    fontFamily: "Space Grotesk, sans-serif"
    fontSize: "clamp(2.7rem, 5.7vw, 5.3rem)"
    fontWeight: 700
    lineHeight: 0.98
    letterSpacing: "-0.075em"
  body:
    fontFamily: "DM Sans, Segoe UI, sans-serif"
    fontSize: "1rem"
    fontWeight: 400
    lineHeight: 1.5
rounded:
  field: "8px"
  control: "10px"
  surface: "12px"
  large: "16px"
spacing:
  xs: "6px"
  sm: "10px"
  md: "16px"
  lg: "24px"
components:
  button-primary:
    backgroundColor: "{colors.court}"
    textColor: "{colors.white}"
    rounded: "{rounded.control}"
    padding: "11px 17px"
    height: "46px"
  button-outline:
    backgroundColor: "transparent"
    textColor: "{colors.court-dark}"
    rounded: "{rounded.control}"
    padding: "11px 17px"
    height: "46px"
  input:
    backgroundColor: "{colors.white}"
    textColor: "{colors.ink}"
    rounded: "{rounded.field}"
    padding: "9px 12px"
    height: "44px"
---

# Design System: CrieSeuVôlei

## Overview

**Creative North Star: "Placar de quadra"**

The interface takes its visual cues from a volleyball court and a clean match sheet: visible boundaries, clear labels, and scores that are easy to read in a busy gym or on a phone at the sideline. The public entrance stays sparse so organizers can start a tournament and spectators can find a live match without scanning a marketing dashboard.

Court green carries the main actions; chalk-white surfaces and dark ink keep the score legible. The volleyball illustration is drawn in the page itself rather than used as generic sports photography.

**Key Characteristics:**
- Court green for actions and active match context.
- A warm ball-orange detail; no decorative gradient.
- One clear home headline, two actions, then the live match list.

## Colors

The palette pairs court green and a small warm volleyball accent with quiet, high-contrast neutrals.

### Primary
- **Court Green** (`#236b4d`): Primary action and the court illustration.
- **Deep Court Green** (`#174d39`): Tournament header and stronger interactive states.
- **Volleyball Amber** (`#f2ad44`): The drawn ball, not a general-purpose action color.
- **Match Red** (`#a62929`): Error and destructive feedback only.

### Neutral
- **Score Ink** (`#17251f`): Main text and score emphasis.
- **Sideline Slate** (`#53665b`): Supporting copy and status text.
- **Court Paper** (`#f4f7f4`): Page background.
- **Chalk White** (`#ffffff`): Inputs, dialogs, and match rows.
- **Boundary Line** (`#d8e2da`): Dividers and quiet borders.
- **Soft Green** (`#eaf0eb`): Selected language and subtle control states.

### Named Rules
**The Match-Day Rule.** Amber belongs to the volleyball illustration; green owns the primary action. Do not make scores or errors depend on color alone.

## Typography

**Display Font:** Space Grotesk, sans-serif  
**Body Font:** DM Sans, Segoe UI, sans-serif

**Character:** Space Grotesk gives tournament names and headlines compact scoreboard clarity. DM Sans keeps instructions and controls readable across languages and mobile widths.

### Hierarchy
- **Display** (700, `clamp(2.7rem, 5.7vw, 5.3rem)`, `.98` line-height): The single landing headline.
- **Headline** (700, `clamp(1.45rem, 3vw, 2rem)`, `1.15` line-height): Section headings.
- **Title** (700, `1rem`–`1.35rem`): Tournament names and workspace headings.
- **Body** (400, `1rem`, `1.5` line-height): Instructions, forms, and spectator content.
- **Label** (700, `.78rem`–`.9rem`): Navigation, state, and form labels.

### Named Rules
**The Score First Rule.** Put team names and score ahead of metadata; use tabular clarity and weight, not decorative type, to distinguish results.

## Layout

The page uses a centered `1120px` maximum-width frame. At desktop size, a concise headline and the court illustration share the opening row; the live tournament list follows under a divider. At `800px`, the workspace becomes a single column; at `600px`, the hero stacks, match rows simplify, and forms remain usable at a narrow phone width. Tournament setup stays behind the create action so the home page is not an admin dashboard.

## Elevation & Depth

Depth is limited to physical cues: the court illustration has a soft offset shadow and the authentication dialog has a deeper shadow above its scrim. Match rows, setup sections, and fields use borders and surface contrast instead of floating-card effects.

## Shapes

Controls use compact `8px`–`10px` corners; list surfaces use `12px`; the hero artwork and workspace use `16px`. Court boundaries are square, thin white lines. Inputs and rows are rectangular and functional, not pill-shaped; only the language selector and volleyball mark are circular.

## Components

### Buttons
- **Primary:** Court green with white text, `10px` corner, `11px 17px` padding and `46px` minimum height.
- **Outline:** Transparent/paper surface, deep court-green text, muted green border.
- **Hover / Focus:** Slight upward hover; a visible amber focus outline for keyboard navigation.
- **Small action:** Same shape with `38px` minimum height for compact tournament rows.

### Cards / Containers
- **Match row:** White background, boundary border, `12px` corner; team name and score share the first scan line.
- **Workspace:** One white, bordered surface; a deep-green title strip carries tournament name and state.
- **Setup group:** Soft paper-green panel with labels and controls grouped by task.

### Inputs / Fields
- **Style:** White background, `#c6d4ca` border, `8px` corner, `9px 12px` padding.
- **Focus:** Three-pixel amber outline with offset, visible on keyboard and pointer focus.
- **Error:** Use explicit text and the danger color; do not rely on border color alone.

### Navigation
- **Desktop:** Wordmark left, lightweight section links, language selector and sign-in action right.
- **Mobile:** Keep the brand, language selector and sign-in action; section links collapse to keep the header usable.

### Live Match Row
- A restrained red live dot accompanies the textual “Ao vivo” state. Tournament name and current score remain the strongest information.

## Do's and Don'ts

### Do:
- **Do** keep the first screen focused on creating a volleyball tournament or watching games.
- **Do** keep the tournament name visible in the workspace header.
- **Do** label score, live, pending, and finished states with text as well as color.
- **Do** use the original court and ball illustration when a sports visual is needed.

### Don't:
- **Don't** add generic analytics, user-count claims, or decorative KPI cards to the home screen.
- **Don't** show setup fields before the user starts creating a tournament.
- **Don't** use the amber ball color for unrelated controls.
- **Don't** substitute a tie result for a volleyball winner.
