# UMI - Unified Modern Intelligence

Enterprise SaaS platform for digital reputation management, automation, and analytics. Built for Saudi Arabian enterprises.

## 🎨 Design System

This website matches **Linear.app's exact design standards**:

- Pure black background (#000000)
- Glass morphism with backdrop blur
- Geist Sans typography
- 8px spacing grid system
- Spring-physics animations
- Bilingual support (Arabic RTL + English)

## 🚀 Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Supabase

1. Copy `.env.example` to `.env.local`:
```bash
cp .env.example .env.local
```

2. Add your Supabase credentials:
```
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

### 3. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

## 📦 Deployment to Vercel

### Option 1: Vercel CLI

```bash
npm i -g vercel
vercel
```

### Option 2: GitHub Integration

1. Push code to GitHub
2. Import repository in Vercel dashboard
3. Add environment variables
4. Deploy

## 🗄️ Database Setup (Supabase)

Run this SQL in your Supabase SQL Editor:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. SERVICES TABLE
CREATE TABLE services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  description TEXT,
  icon_name VARCHAR(50),
  price_monthly DECIMAL(10,2),
  price_yearly DECIMAL(10,2),
  features JSONB,
  is_active BOOLEAN DEFAULT true,
  display_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. PRICING PLANS TABLE
CREATE TABLE pricing_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  plan_name VARCHAR(50) NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  monthly_price DECIMAL(10,2),
  yearly_price DECIMAL(10,2),
  max_locations INT,
  features JSONB,
  is_popular BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 3. CLIENTS TABLE
CREATE TABLE clients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_name VARCHAR(200) NOT NULL,
  industry VARCHAR(100),
  plan_id UUID REFERENCES pricing_plans(id),
  total_locations INT DEFAULT 0,
  subscription_status VARCHAR(20) DEFAULT 'active',
  primary_contact_email VARCHAR(255),
  primary_contact_phone VARCHAR(20),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 4. BRANCHES TABLE
CREATE TABLE branches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
  branch_name VARCHAR(200),
  google_maps_url TEXT,
  google_place_id VARCHAR(255) UNIQUE,
  city VARCHAR(100),
  region VARCHAR(100),
  qr_code_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 5. REVIEW LOGS TABLE (ReviewShield)
CREATE TABLE review_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  branch_id UUID REFERENCES branches(id) ON DELETE CASCADE,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  review_type VARCHAR(20), -- 'internal_form' or 'google_redirect'
  customer_name VARCHAR(200),
  customer_phone VARCHAR(20),
  customer_email VARCHAR(255),
  feedback_text TEXT,
  sentiment_score DECIMAL(3,2),
  was_resolved BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);

-- INDEXES
CREATE INDEX idx_clients_plan ON clients(plan_id);
CREATE INDEX idx_branches_client ON branches(client_id);
CREATE INDEX idx_review_logs_branch ON review_logs(branch_id);
CREATE INDEX idx_review_logs_created ON review_logs(created_at DESC);

-- ROW LEVEL SECURITY
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE pricing_plans ENABLE ROW LEVEL SECURITY;

-- Public read access for landing page
CREATE POLICY "Public can view active services" ON services
  FOR SELECT USING (is_active = true);

CREATE POLICY "Public can view active pricing" ON pricing_plans
  FOR SELECT USING (is_active = true);

-- INSERT SAMPLE DATA
INSERT INTO pricing_plans (plan_name, display_name, monthly_price, yearly_price, max_locations, features, is_popular) VALUES
('starter', 'Starter', 499.00, 4790.40, 5, 
 '["Up to 5 locations", "ReviewShield Basic", "WhatsApp (500 msgs/mo)", "Email support"]', false),
('pro', 'Pro', 1499.00, 14390.40, 50,
 '["Up to 50 locations", "Advanced Analytics", "WhatsApp (5000 msgs/mo)", "Priority support", "Custom integrations"]', true),
('enterprise', 'Enterprise', NULL, NULL, NULL,
 '["Unlimited locations", "White-label options", "Dedicated account manager", "SLA guarantees"]', false);

INSERT INTO services (name, description, icon_name, price_monthly, features, display_order) VALUES
('ReviewShield', 'Smart reputation management with conditional redirects', 'Shield', 49.00,
 '["1-3★ → Internal form", "4-5★ → Google redirect", "WhatsApp alerts"]', 1),
('WhatsApp Automation', 'Automated customer engagement workflows', 'MessageSquare', 29.00,
 '["POS-triggered messages", "Campaign management"]', 2);
```

## 🏗️ Project Structure

```
umi-website/
├── app/
│   ├── globals.css          # Linear.app design tokens
│   ├── layout.tsx            # Root layout with Geist Sans
│   └── page.tsx              # Landing page
├── components/
│   ├── HeroSection.tsx       # Hero with bilingual support
│   ├── ServicesGrid.tsx      # Bento grid layout
│   ├── PricingSection.tsx    # Dynamic pricing table
│   ├── AdminPreview.tsx      # Admin dashboard preview
│   ├── LanguageToggle.tsx    # EN/AR switcher
│   └── Footer.tsx            # Footer links
├── lib/
│   └── language-context.tsx  # i18n provider
└── package.json
```

## ✨ Key Features

### 1. **Bilingual Support**
- Arabic (RTL) and English
- Font switching (Geist Sans / Noto Sans Arabic)
- Complete translations for all content

### 2. **Linear.app Design Quality**
- Pure black (#000) theme
- Glass morphism cards
- Spring-physics animations (Framer Motion)
- Micro-interactions on hover
- 8px spacing grid

### 3. **Supabase Integration Ready**
- Dynamic pricing from database
- Real-time updates (ISR: 60s)
- RLS policies configured
- Sample data included

### 4. **Performance Optimized**
- Next.js 14 App Router
- Server Components
- Optimized fonts (Geist Sans)
- CSS transforms (not margins)

## 🎯 Services Showcase

The website highlights UMI's 6 core services:

1. **Digital Reputation Management** (ReviewShield)
   - Smart review filtering (1-3★ vs 4-5★)
   - Google Maps integration
   - Sentiment analysis

2. **Communication Automation**
   - WhatsApp Business API
   - POS-triggered messages
   - Real-time alerts

3. **Data & Analytics**
   - Multi-location dashboard
   - CRM database building
   - Performance reports

4. **Integration & Custom SaaS**
   - POS system integration
   - Custom API development
   - Workflow automation

5. **Admin Control Center**
   - Dynamic service management
   - Real-time pricing updates
   - Subscription control

6. **SEO Optimization**
   - Search engine optimization
   - Organic traffic growth

## 🔧 Tech Stack

- **Framework**: Next.js 14 (App Router)
- **Styling**: Tailwind CSS
- **Animations**: Framer Motion
- **Database**: Supabase (PostgreSQL)
- **Font**: Geist Sans + Noto Sans Arabic
- **Deployment**: Vercel
- **Language**: TypeScript

## 📝 Environment Variables

Required variables for production:

```env
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
```

## 🌐 Custom Domain Setup (Vercel)

1. Go to Vercel dashboard → Project Settings → Domains
2. Add your domain: `umi.sa` or `www.umi.sa`
3. Update DNS records as instructed
4. SSL automatically provisioned

## 📊 Analytics Integration

To add Google Analytics:

1. Install package:
```bash
npm install @next/third-parties
```

2. Add to `layout.tsx`:
```tsx
import { GoogleAnalytics } from '@next/third-parties/google'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>{children}</body>
      <GoogleAnalytics gaId="G-XXXXXXXXXX" />
    </html>
  )
}
```

## 🔐 Security Best Practices

- ✅ Row Level Security (RLS) enabled
- ✅ Environment variables for credentials
- ✅ HTTPS enforced (Vercel default)
- ✅ No sensitive data in client code
- ✅ Rate limiting (add via Vercel Edge Config if needed)

## 🎨 Customization Guide

### Changing Colors

Edit `app/globals.css`:

```css
:root {
  --accent-blue: 245 59% 60%; /* Change to your brand color */
}
```

### Adding New Services

Edit `components/ServicesGrid.tsx` and add to the `services` array.

### Updating Pricing

Either:
1. **Database**: Update Supabase `pricing_plans` table
2. **Code**: Edit `lib/language-context.tsx` translations

## 📞 Support

For questions or issues:
- Email: support@umi.sa
- GitHub Issues: [Create Issue]

## 📄 License

Proprietary - © 2025 UMI (Unified Modern Intelligence)

---

**Built with ❤️ for Saudi Arabia's digital future**
