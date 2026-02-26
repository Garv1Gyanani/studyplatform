# Programming Tails — Product Requirements Document
## Full-Stack EdTech Web Application
### Built with SvelteKit & Supabase

Version 1.0

---

## 1. Project Overview

Programming Tails is a modern, feature-rich educational web application designed to serve two primary user groups: **Administrators** who manage and publish educational content, and **Students** who consume that content in an engaging, gamified environment.

### Core Principles
- **Content-first**: All learning materials (videos, quizzes, notes, books, blogs) are managed by admins and delivered to students seamlessly.
- **Lazy authentication**: Students can browse content previews freely but must sign up/log in to consume full content.
- **Gamification**: Leaderboards, quizzes, and fun games keep students motivated and engaged.
- **Modern UI**: Clean, responsive design using Tailwind CSS with a fresh, student-friendly aesthetic.
- **Scalable architecture**: Supabase handles auth, database, file storage, and real-time updates out of the box.

## 2. Technology Stack

| Layer | Technology |
|-------|-----------|
| Frontend | SvelteKit (latest) — SSR + SPA hybrid with file-based routing |
| Styling | Tailwind CSS + shadcn-svelte component library |
| Backend / BaaS | Supabase — PostgreSQL, Auth, Storage, Edge Functions, Realtime |
| Video Hosting | Supabase Storage (direct upload) or YouTube embed (admin choice) |
| Deployment | Vercel or Netlify (SvelteKit adapter) + Supabase cloud |
| State Management | Svelte stores + SvelteKit load functions |
| Icons | Lucide Svelte |

## 3. User Roles & Permissions

### 3.1 Guest (Unauthenticated)
- Can browse homepage, content listings, blog previews, and leaderboard.
- Clicking any content item triggers a signup/login modal.
- Can view public blog post previews (first 200 words), book titles, course titles.

### 3.2 Student (Authenticated)
- Full access to all published content: videos, quizzes, tests, notes, books, blogs, news.
- Can attempt quizzes and tests; scores are recorded and contribute to leaderboard.
- Has a personal dashboard showing progress, completed content, and quiz scores.
- Cannot access the admin panel.

### 3.3 Admin
- Full access to the Admin Dashboard at /admin (protected route).
- Can create, edit, delete, and publish/unpublish all content types.
- Can upload videos directly or embed YouTube links.
- Can manage user accounts and view analytics.

## 4. Application Routes

### Public / Student Routes
| Route | Description |
|-------|------------|
| / | Home — Hero section, featured content |
| /courses | Browse all video courses |
| /courses/[id] | Course Detail — Video player + description |
| /quizzes | List of available quizzes |
| /quizzes/[id] | Interactive quiz with timer and scoring |
| /leaderboard | Global rankings by score |
| /blogs | Blog listing with previews |
| /blogs/[slug] | Full blog post |
| /books | Digital library listing |
| /notes | Study notes by subject/topic |
| /news | Education news feed |
| /games | Fun educational games hub |

### Student (Authenticated) Routes
| Route | Description |
|-------|------------|
| /dashboard | Personal progress, scores, history |
| /bookmarks | Saved content |
| /settings | Account settings |

### Admin Routes
| Route | Description |
|-------|------------|
| /admin | Admin dashboard overview with stats |
| /admin/videos | Manage video courses |
| /admin/quizzes | Create and manage quizzes |
| /admin/tests | Create formal tests |
| /admin/blogs | Write and publish blog posts |
| /admin/books | Upload PDFs or link external books |
| /admin/notes | Create study notes |
| /admin/news | Post education news |
| /admin/users | View registered users, manage roles |

## 5. Database Schema

See `supabase/migrations/` for full SQL schema.

## 6. Supabase Storage Buckets
- `videos` — MP4/WebM uploads by admin
- `book-pdfs` — PDF book files
- `thumbnails` — Course/video thumbnail images
- `avatars` — Student profile pictures
- `blog-images` — Inline images for blog posts
- `covers` — Book cover images

## 7. Security
- All content mutation requires admin role via Supabase RLS
- File uploads validated by type and size
- YouTube URLs validated to prevent XSS
- Environment variables stored securely
