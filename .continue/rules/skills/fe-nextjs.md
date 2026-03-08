# Next.js App Router Standards

## Server vs Client Components
- Default: Server Components (async, no hooks, direct DB/API access)
- Add `'use client'` only for: hooks, event handlers, browser APIs
- Push `'use client'` to leaf components — never on layout or page unless required
- Server → Client: only serializable data as props

## Data Fetching
- Server Components: direct `async/await` — no `useEffect`, no React Query
- Caching: `cache: 'no-store'` (dynamic), `next: { revalidate: N }` (ISR), default (static)
- `unstable_cache()` for non-fetch data sources (DB, SDKs)
- `revalidateTag()` / `revalidatePath()` after mutations

## Server Actions (preferred for mutations)
- `'use server'` directive; validate input with Zod inside the action
- Return `{ success: true, data } | { success: false, error }`
- `revalidateTag()` after successful mutations

## Routing Conventions
- `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx` (`'use client'`), `not-found.tsx`, `route.ts`
- `<Link>` for all navigation; `redirect()` in Server Components
- Lazy-load routes; always export `generateMetadata` for public pages

## Environment Variables
- `NEXT_PUBLIC_` exposes to browser — minimize; validate all vars with Zod at startup
- Never access `process.env` in Client Components

## Performance
- `next/image` for all images; `next/font` for fonts
- Streaming via `<Suspense>` for slow sections
- `output: 'standalone'` for Docker deployment
