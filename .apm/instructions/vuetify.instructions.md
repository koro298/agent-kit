---
applyTo: "**/*.vue, **/vite.config.*, **/src/plugins/**, **/src/stores/**, **/src/router/**"
description: Vue 3 + Vuetify フロントエンドの構成・設計規約
---

# Vuetify Frontend Guidelines (for AI agents)

These rules apply whenever Vue 3 + Vuetify code is written in this repository. They fix the shape of the project — what is adopted, where each thing lives, and what proves the code works.

They contain no component API facts on purpose. Props, slots, events, and version differences live in the documentation: read <https://vuetifyjs.com/llms.txt> and follow the page you need, or query the Vuetify MCP server (`https://mcp.vuetifyjs.com/mcp`) where one is configured. Never write a prop or slot name from memory.

Vuetify 4 is the default for new projects and Vuetify 3 (LTS 3.13) is supported; nothing below depends on the difference.

## Adopted libraries

One library per concern. Do not add a second one — another state manager, another chart library, or a CSS framework alongside Vuetify. Vuetify carries its own CSS reset, utility classes, theme, and SASS variables; a second utility framework puts two vocabularies in the templates and makes breakpoints and colors have two sources of truth. If a case genuinely needs one, say why and get the user's agreement before installing it.

| Concern | Adopted |
|---|---|
| Scaffold | `npm create vuetify` |
| Build | Vite with `vite-plugin-vuetify` (treeshaking, `styles.configFile`) |
| Routing | Vue Router 5's built-in file-based routing (`vue-router/vite`) over `src/pages/`. On Vue Router 4, the same thing through `unplugin-vue-router` |
| Layouts | `vite-plugin-vue-layouts-next`. Layouts stayed a plugin when file-based routing moved into Vue Router |
| State | Pinia |
| Charts | `vue-chartjs` on Chart.js 4 |
| Icons | `@mdi/font` |
| Styling | Vuetify utility classes and SASS variables in `src/styles/settings.scss` |
| Lint | `eslint-config-vuetify` |
| Types | TypeScript with `vue-tsc` |

## Layout

The scaffold's directories are the contract. Do not create new top-level directories under `src/` without saying so.

| Directory | Holds | Does not hold |
|---|---|---|
| `pages/` | One component per route; the file path is the URL | Reusable UI, data-fetching helpers |
| `layouts/` | Application shells: `v-app`, `v-main`, navigation | Page-specific markup |
| `components/` | Reusable components, presentational by default | Routes, store definitions |
| `stores/` | Pinia stores, one per domain | HTTP calls issued directly |
| `services/` | External I/O (HTTP clients, auth SDKs) and the types crossing that boundary | Vue-specific code |
| `composables/` | Reusable stateful logic named `useX` | Logic used by exactly one component |
| `plugins/` | `createVuetify` configuration and plugin registration | Business logic |
| `styles/` | `settings.scss`, holding SASS variable overrides | Per-component styles |

- Auto-import is enabled. Do not add explicit imports for Vuetify components, `vue` APIs, router composables, or `defineStore` / `storeToRefs`.
- The generated declaration files (`auto-imports.d.ts`, `components.d.ts`, `typed-router.d.ts`) are committed and never hand-edited.

## Components

- Use `<script setup lang="ts">` and the Composition API. No Options API.
- Declare props and emits with types: `defineProps<Props>()`, `defineEmits<Emits>()`.
- Keep state as local as it can be. `ref` / `computed` inside the component, then props and emits between parent and child, and a Pinia store only when two routes or two unrelated subtrees need the same state. A store read by exactly one component is misplaced state.
- Stores are setup stores (`defineStore('x', () => { ... })`), one per domain. They hold state and derivations and call `services/` for I/O. Components never call an HTTP client directly.
- A page component wires things together: read route params, call stores, render components. Shaping data belongs in a store or a composable, not in a template expression.
- Split a component when its template has more than one reason to change.

## Vuetify specifics

- Repeated props are a configuration problem, not a copy-paste problem. Set them once under `defaults` in `src/plugins/vuetify.ts`, using contextual defaults for nested cases. `class` and `style` are honoured per component key only, never under `global`.
- Colors come from the theme and are referenced by name (`color="primary"`, `text-primary`). No hex literals in templates.
- Reach for Vuetify's utility classes before writing CSS. They cover spacing, display, flex, position, sizing, text and typography, elevation, borders, radius, overflow, opacity, and cursor; check the Styles section of the documentation instead of assuming a case is uncovered. Write `<style scoped>` only for what utilities and SASS variables cannot express, and never use a descendant selector to reach inside a Vuetify component — override the SASS variable in `settings.scss` instead.
- Responsive behaviour uses `useDisplay()` or the grid and display utilities, not hand-written media queries.
- The application shell (`v-app`, `v-main`, `v-app-bar`, `v-navigation-drawer`) lives in a layout, never in a page.
- Forms use `v-form` with rules returning `true | string`, and submission waits on the form's validation result.

## Routing

- Routes come from the file tree under `src/pages/`; do not hand-maintain a route table.
- Every route renders inside a layout. Wrap the generated routes once — `routes: setupLayouts(routes)` — and put the application shell in `src/layouts/default.vue`. A page that needs a different shell names its own layout rather than building one inline.
- Navigation guards live in `src/router/`. A guard that needs store state calls the store inside the guard body — a store created at module scope runs before Pinia is installed.
- Route params arrive as strings. Validate and convert them at the page boundary.

## Charts

- Register only the Chart.js pieces a chart actually uses (`ChartJS.register(...)`). Never register `registerables` wholesale; it defeats treeshaking.
- One wrapper component per chart type under `components/`, taking already-shaped data as props. Chart.js registration and chart options stay inside that wrapper; pages and stores never import from `chart.js`.
- Chart colors come from the Vuetify theme (`useTheme().current.value.colors`) so that charts follow the light and dark switch.

## Checks

Every change proves itself with at least the type check and the lint. Run them and report their output, not a claim.

| Check | Command | Required |
|---|---|---|
| Types | The project's type-check script (`vue-tsc`) | Yes |
| Lint | The project's lint script (`eslint-config-vuetify`) | Yes |
| Build | The project's build script | When build config, plugins, or dependencies change |
| Component tests | Vitest with `@vue/test-utils`, installing Vuetify as a global plugin | Optional |

A type error inside a generated `.d.ts` means the generator has not run. Start the dev server or the build to regenerate it, then check again. Do not edit the file.

## Invariants

- No component API written from memory. Look it up in the documentation or the MCP server.
- No second library for a concern that already has an adopted one.
- No hex colors, no hand-written media queries, no selectors reaching inside Vuetify components.
- Repeated props go to `defaults`, not to every call site.
- Generated `.d.ts` files are committed and never edited.
- Stores hold shared state, never single-component state, and never HTTP calls.
