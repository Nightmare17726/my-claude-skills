---
name: design-system-first
description: Use when starting any frontend feature, UI component, page, or styling work. Establishes design tokens before writing any component code to ensure visual consistency and prevent redesign cycles.
---

# Design System First

## Overview

Visual inconsistency — mismatched spacing, slightly different blues, three font sizes that should be one — accumulates when components are styled ad-hoc. Fixing it later means touching every file. This skill prevents that by establishing a single source of truth for visual values before the first component is written.

**Trigger:** Before writing any component, page, or CSS — check for a design tokens file first.

---

## The Rule

```
No component styling without a tokens file.
No tokens file? Create one before the first component.
```

---

## Step 1: Locate or Create the Tokens File

Check for an existing file first:

```
Glob: "**/{tokens,variables,theme,design-tokens}.{css,ts,js,scss}"
```

If found — read it and use it. If not found — create it now.

---

## Step 2: Define the Tokens

Create `src/styles/tokens.css` (or `src/styles/tokens.ts` for JS-in-CSS systems).

### CSS Custom Properties (recommended default)

```css
/* src/styles/tokens.css */

:root {
  /* ─── Color Palette ─── */
  --color-primary-50:  #eff6ff;
  --color-primary-100: #dbeafe;
  --color-primary-500: #3b82f6;
  --color-primary-600: #2563eb;
  --color-primary-700: #1d4ed8;

  --color-neutral-50:  #f9fafb;
  --color-neutral-100: #f3f4f6;
  --color-neutral-200: #e5e7eb;
  --color-neutral-500: #6b7280;
  --color-neutral-700: #374151;
  --color-neutral-900: #111827;

  --color-success: #22c55e;
  --color-warning: #f59e0b;
  --color-error:   #ef4444;

  /* ─── Semantic Colors (reference palette above) ─── */
  --color-bg:           var(--color-neutral-50);
  --color-surface:      #ffffff;
  --color-text:         var(--color-neutral-900);
  --color-text-muted:   var(--color-neutral-500);
  --color-border:       var(--color-neutral-200);
  --color-accent:       var(--color-primary-600);
  --color-accent-hover: var(--color-primary-700);

  /* ─── Spacing Scale (4px base) ─── */
  --space-1:  0.25rem;  /*  4px */
  --space-2:  0.5rem;   /*  8px */
  --space-3:  0.75rem;  /* 12px */
  --space-4:  1rem;     /* 16px */
  --space-6:  1.5rem;   /* 24px */
  --space-8:  2rem;     /* 32px */
  --space-12: 3rem;     /* 48px */
  --space-16: 4rem;     /* 64px */

  /* ─── Typography ─── */
  --font-sans:  system-ui, -apple-system, sans-serif;
  --font-mono:  ui-monospace, "Cascadia Code", monospace;

  --text-xs:   0.75rem;   /* 12px */
  --text-sm:   0.875rem;  /* 14px */
  --text-base: 1rem;      /* 16px */
  --text-lg:   1.125rem;  /* 18px */
  --text-xl:   1.25rem;   /* 20px */
  --text-2xl:  1.5rem;    /* 24px */
  --text-3xl:  1.875rem;  /* 30px */

  --font-normal:   400;
  --font-medium:   500;
  --font-semibold: 600;
  --font-bold:     700;

  --leading-tight:  1.25;
  --leading-normal: 1.5;
  --leading-loose:  1.75;

  /* ─── Borders & Radius ─── */
  --radius-sm: 0.25rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;
  --radius-xl: 0.75rem;
  --radius-full: 9999px;
  --border-width: 1px;

  /* ─── Shadows ─── */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);

  /* ─── Transitions ─── */
  --transition-fast:   150ms ease;
  --transition-normal: 250ms ease;
}
```

### TypeScript / Tailwind config alternative

```typescript
// src/styles/tokens.ts
export const tokens = {
  colors: {
    primary: { 500: "#3b82f6", 600: "#2563eb", 700: "#1d4ed8" },
    neutral: { 50: "#f9fafb", 900: "#111827" },
    accent: "#2563eb",
    error:  "#ef4444",
  },
  space: { 1: "0.25rem", 2: "0.5rem", 4: "1rem", 8: "2rem" },
  text:  { sm: "0.875rem", base: "1rem", lg: "1.125rem", xl: "1.25rem" },
} as const;
```

---

## Step 3: Enforce Usage in Components

Every component must reference tokens — no raw values.

```css
/* BAD */
.button {
  background: #2563eb;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 14px;
}

/* GOOD */
.button {
  background: var(--color-accent);
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius-md);
  font-size: var(--text-sm);
}
```

---

## Quick Reference

| Token Category | Prefix |
|----------------|--------|
| Colors (palette) | `--color-primary-*`, `--color-neutral-*` |
| Colors (semantic) | `--color-bg`, `--color-text`, `--color-accent` |
| Spacing | `--space-1` through `--space-16` |
| Typography | `--text-sm` … `--text-3xl`, `--font-*`, `--leading-*` |
| Borders | `--radius-*`, `--border-width` |
| Shadows | `--shadow-sm/md/lg` |
| Transitions | `--transition-fast/normal` |

---

## Common Mistakes

**Skipping tokens for "just one component"** — inconsistency always starts with "just this once."

**Duplicating palette colors as semantic tokens** — `--color-primary-600` is a palette value; `--color-accent` is a semantic alias. Use semantic names in components so the palette can change without touching components.

**Defining tokens per-component** — tokens are global. If you find yourself writing `--button-blue`, it belongs in the global palette as `--color-primary-600`.
