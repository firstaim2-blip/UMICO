-- ============================================
-- UMI Database Schema - Supabase Setup
-- ============================================
-- Run this entire file in your Supabase SQL Editor
-- Project: UMI (Unified Modern Intelligence)
-- ============================================

-- Enable Required Extensions
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing tables if re-running (optional - comment out for first run)
-- ============================================
-- DROP TABLE IF EXISTS review_logs CASCADE;
-- DROP TABLE IF EXISTS whatsapp_campaigns CASCADE;
-- DROP TABLE IF EXISTS branches CASCADE;
-- DROP TABLE IF EXISTS clients CASCADE;
-- DROP TABLE IF EXISTS pricing_plans CASCADE;
-- DROP TABLE IF EXISTS services CASCADE;

-- 1. SERVICES TABLE
-- ============================================
-- Stores all available services (ReviewShield, WhatsApp, etc.)
CREATE TABLE services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  description TEXT,
  description_ar TEXT, -- Arabic description
  icon_name VARCHAR(50), -- lucide-react icon name
  price_monthly DECIMAL(10,2),
  price_yearly DECIMAL(10,2),
  features JSONB, -- Array of features in English
  features_ar JSONB, -- Array of features in Arabic
  is_active BOOLEAN DEFAULT true,
  display_order INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. PRICING PLANS TABLE
-- ============================================
-- Three tiers: Starter, Pro, Enterprise
CREATE TABLE pricing_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  plan_name VARCHAR(50) NOT NULL UNIQUE, -- 'starter', 'pro', 'enterprise'
  display_name VARCHAR(100) NOT NULL,
  display_name_ar VARCHAR(100), -- Arabic name
  monthly_price DECIMAL(10,2), -- NULL for custom pricing
  yearly_price DECIMAL(10,2), -- NULL for custom pricing
  max_locations INT, -- NULL for unlimited
  features JSONB NOT NULL, -- Array of features
  features_ar JSONB, -- Arabic features
  is_popular BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. CLIENTS TABLE
-- ============================================
-- Enterprise customers using UMI platform
CREATE TABLE clients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_name VARCHAR(200) NOT NULL,
  industry VARCHAR(100),
  plan_id UUID REFERENCES pricing_plans(id) ON DELETE SET NULL,
  total_locations INT DEFAULT 0,
  subscription_status VARCHAR(20) DEFAULT 'active', -- active, paused, cancelled
  subscription_start_date DATE,
  subscription_end_date DATE,
  primary_contact_name VARCHAR(200),
  primary_contact_email VARCHAR(255) UNIQUE,
  primary_contact_phone VARCHAR(20),
  company_website VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. BRANCHES/LOCATIONS TABLE
-- ============================================
-- Individual branch locations for each client
CREATE TABLE branches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  branch_name VARCHAR(200) NOT NULL,
  branch_name_ar VARCHAR(200), -- Arabic name
  google_maps_url TEXT,
  google_place_id VARCHAR(255) UNIQUE,
  address VARCHAR(500),
  city VARCHAR(100),
  region VARCHAR(100),
  postal_code VARCHAR(20),
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  qr_code_url TEXT, -- Generated QR for ReviewShield
  qr_code_id VARCHAR(100) UNIQUE, -- Unique identifier for tracking
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. REVIEW LOGS TABLE (ReviewShield Core)
-- ============================================
-- Tracks all customer reviews and filtering
CREATE TABLE review_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review_type VARCHAR(20) NOT NULL, -- 'internal_form' or 'google_redirect'
  customer_name VARCHAR(200),
  customer_phone VARCHAR(20),
  customer_email VARCHAR(255),
  feedback_text TEXT,
  feedback_text_ar TEXT, -- If customer wrote in Arabic
  sentiment_score DECIMAL(3,2), -- -1.00 to 1.00 (AI sentiment analysis)
  sentiment_category VARCHAR(20), -- 'positive', 'neutral', 'negative'
  was_resolved BOOLEAN DEFAULT false,
  resolved_at TIMESTAMP WITH TIME ZONE,
  resolved_by VARCHAR(200), -- Staff member who resolved
  internal_notes TEXT, -- Private notes for management
  source VARCHAR(50) DEFAULT 'qr_code', -- 'qr_code', 'sms', 'email', 'whatsapp'
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. WHATSAPP CAMPAIGNS TABLE
-- ============================================
-- WhatsApp Business automation campaigns
CREATE TABLE whatsapp_campaigns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  campaign_name VARCHAR(200) NOT NULL,
  campaign_name_ar VARCHAR(200),
  message_template TEXT NOT NULL,
  message_template_ar TEXT, -- Arabic version
  trigger_type VARCHAR(50) NOT NULL, -- 'pos_purchase', 'manual', 'scheduled', 'review_response'
  target_audience VARCHAR(50), -- 'all_customers', 'low_ratings', 'high_ratings', 'no_review'
  sent_count INT DEFAULT 0,
  delivered_count INT DEFAULT 0,
  read_count INT DEFAULT 0,
  response_count INT DEFAULT 0,
  status VARCHAR(20) DEFAULT 'draft', -- 'draft', 'active', 'paused', 'completed'
  scheduled_at TIMESTAMP WITH TIME ZONE,
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_by VARCHAR(200),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. ANALYTICS SNAPSHOTS TABLE (Optional - for historical tracking)
-- ============================================
-- Store daily/weekly analytics snapshots
CREATE TABLE analytics_snapshots (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
  branch_id UUID REFERENCES branches(id) ON DELETE CASCADE, -- NULL for company-wide
  snapshot_date DATE NOT NULL,
  period_type VARCHAR(20) NOT NULL, -- 'daily', 'weekly', 'monthly'
  total_reviews INT DEFAULT 0,
  positive_reviews INT DEFAULT 0, -- 4-5 stars
  negative_reviews INT DEFAULT 0, -- 1-3 stars
  avg_rating DECIMAL(3,2),
  google_redirects INT DEFAULT 0,
  internal_forms INT DEFAULT 0,
  resolved_complaints INT DEFAULT 0,
  whatsapp_sent INT DEFAULT 0,
  metadata JSONB, -- Additional metrics
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Services
CREATE INDEX idx_services_active ON services(is_active) WHERE is_active = true;
CREATE INDEX idx_services_order ON services(display_order);

-- Pricing Plans
CREATE INDEX idx_pricing_active ON pricing_plans(is_active) WHERE is_active = true;
CREATE INDEX idx_pricing_popular ON pricing_plans(is_popular) WHERE is_popular = true;

-- Clients
CREATE INDEX idx_clients_plan ON clients(plan_id);
CREATE INDEX idx_clients_status ON clients(subscription_status);
CREATE INDEX idx_clients_email ON clients(primary_contact_email);

-- Branches
CREATE INDEX idx_branches_client ON branches(client_id);
CREATE INDEX idx_branches_active ON branches(is_active) WHERE is_active = true;
CREATE INDEX idx_branches_place_id ON branches(google_place_id);
CREATE INDEX idx_branches_qr ON branches(qr_code_id);

-- Review Logs
CREATE INDEX idx_review_logs_branch ON review_logs(branch_id);
CREATE INDEX idx_review_logs_created ON review_logs(created_at DESC);
CREATE INDEX idx_review_logs_rating ON review_logs(rating);
CREATE INDEX idx_review_logs_type ON review_logs(review_type);
CREATE INDEX idx_review_logs_resolved ON review_logs(was_resolved);

-- WhatsApp Campaigns
CREATE INDEX idx_whatsapp_client ON whatsapp_campaigns(client_id);
CREATE INDEX idx_whatsapp_status ON whatsapp_campaigns(status);

-- Analytics
CREATE INDEX idx_analytics_date ON analytics_snapshots(snapshot_date DESC);
CREATE INDEX idx_analytics_client ON analytics_snapshots(client_id);
CREATE INDEX idx_analytics_branch ON analytics_snapshots(branch_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE pricing_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_snapshots ENABLE ROW LEVEL SECURITY;

-- PUBLIC ACCESS: Services & Pricing (for landing page)
CREATE POLICY "Public can view active services" ON services
  FOR SELECT USING (is_active = true);

CREATE POLICY "Public can view active pricing" ON pricing_plans
  FOR SELECT USING (is_active = true);

-- CLIENT ACCESS: Users can only see their own data
-- Note: Implement auth.uid() mapping to client_id in your application

-- Example: Clients view own data
CREATE POLICY "Clients view own data" ON clients
  FOR SELECT USING (auth.uid()::text = id::text); -- Adjust based on your auth setup

CREATE POLICY "Clients view own branches" ON branches
  FOR SELECT USING (
    client_id IN (SELECT id FROM clients WHERE auth.uid()::text = id::text)
  );

CREATE POLICY "Clients view own reviews" ON review_logs
  FOR SELECT USING (
    branch_id IN (
      SELECT id FROM branches 
      WHERE client_id IN (SELECT id FROM clients WHERE auth.uid()::text = id::text)
    )
  );

-- ============================================
-- SAMPLE DATA
-- ============================================

-- Insert Pricing Plans
INSERT INTO pricing_plans (plan_name, display_name, display_name_ar, monthly_price, yearly_price, max_locations, features, features_ar, is_popular) VALUES
('starter', 'Starter', 'المبتدئ', 499.00, 4790.40, 5, 
 '["Up to 5 locations", "ReviewShield Basic", "WhatsApp (500 msgs/month)", "Email support", "Basic analytics dashboard", "QR code generation"]',
 '["حتى 5 مواقع", "ReviewShield أساسي", "واتساب (500 رسالة/شهر)", "دعم عبر البريد", "لوحة تحليلات أساسية", "إنشاء رموز QR"]',
 false),

('pro', 'Pro', 'الاحترافي', 1499.00, 14390.40, 50,
 '["Up to 50 locations", "Advanced Analytics", "WhatsApp (5,000 msgs/month)", "Priority support", "Custom integrations", "Sentiment analysis", "API access", "White-label options"]',
 '["حتى 50 موقع", "تحليلات متقدمة", "واتساب (5,000 رسالة/شهر)", "دعم ذو أولوية", "تكاملات مخصصة", "تحليل المشاعر", "وصول API", "خيارات العلامة البيضاء"]',
 true),

('enterprise', 'Enterprise', 'المؤسسات', NULL, NULL, NULL,
 '["Unlimited locations", "Dedicated account manager", "SLA guarantees", "Custom workflows", "Full API access", "Advanced security", "On-premise deployment option", "Custom training"]',
 '["مواقع غير محدودة", "مدير حساب مخصص", "ضمانات SLA", "سير عمل مخصص", "وصول API كامل", "أمان متقدم", "خيار النشر الداخلي", "تدريب مخصص"]',
 false);

-- Insert Services
INSERT INTO services (name, description, description_ar, icon_name, price_monthly, price_yearly, features, features_ar, display_order) VALUES
('ReviewShield', 
 'Smart reputation management with conditional redirects. Route 1-3★ ratings to internal complaint forms, 4-5★ to Google Maps.',
 'إدارة سمعة ذكية مع تحويل مشروط. توجيه التقييمات 1-3★ لنموذج الشكاوى الداخلي، و4-5★ لخرائط Google.',
 'Shield', 
 49.00, 
 470.40,
 '["1-3★ → Internal form", "4-5★ → Google redirect", "WhatsApp alerts", "Sentiment analysis", "Dynamic QR codes"]',
 '["1-3★ → نموذج داخلي", "4-5★ → تحويل Google", "تنبيهات واتساب", "تحليل المشاعر", "رموز QR ديناميكية"]',
 1),

('WhatsApp Business API', 
 'Automated customer engagement workflows. Post-visit messages, instant management alerts, and POS-triggered automation.',
 'سير عمل آلي لتفاعل العملاء. رسائل بعد الزيارة، تنبيهات فورية للإدارة، وأتمتة محفزة بنقاط البيع.',
 'MessageSquare', 
 29.00, 
 278.40,
 '["POS-triggered messages", "Campaign management", "Real-time delivery tracking", "Template management"]',
 '["رسائل محفزة بنقاط البيع", "إدارة الحملات", "تتبع التسليم الفوري", "إدارة القوالب"]',
 2),

('Multi-Location Dashboard', 
 'Centralized command center. Compare branch performance, build customer databases, and generate automated reports.',
 'مركز قيادة مركزي. مقارنة أداء الفروع، بناء قواعد بيانات العملاء، وإنشاء تقارير آلية.',
 'BarChart3', 
 79.00, 
 758.40,
 '["Performance benchmarking", "Customer database", "Automated reports", "Real-time insights"]',
 '["قياس الأداء", "قاعدة بيانات العملاء", "تقارير آلية", "رؤى فورية"]',
 3);

-- Sample Client (for testing)
INSERT INTO clients (company_name, industry, plan_id, total_locations, primary_contact_name, primary_contact_email, primary_contact_phone) VALUES
('مطاعم النخيل', 'Food & Beverage', (SELECT id FROM pricing_plans WHERE plan_name = 'pro'), 12, 'Ahmed Al-Saud', 'ahmed@alnakheel.sa', '+966501234567');

-- Sample Branch
INSERT INTO branches (client_id, branch_name, branch_name_ar, city, region, qr_code_id, is_active) VALUES
((SELECT id FROM clients WHERE company_name = 'مطاعم النخيل'), 
 'Al-Nakheel Restaurant - Riyadh', 
 'مطعم النخيل - الرياض',
 'Riyadh', 
 'Riyadh',
 'QR_ALNAKHEEL_RUH_001',
 true);

-- ============================================
-- FUNCTIONS & TRIGGERS (Optional but recommended)
-- ============================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to relevant tables
CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON services
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pricing_plans_updated_at BEFORE UPDATE ON pricing_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_branches_updated_at BEFORE UPDATE ON branches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- COMPLETION MESSAGE
-- ============================================
DO $$
BEGIN
    RAISE NOTICE '✅ UMI Database Schema created successfully!';
    RAISE NOTICE '📊 Tables: services, pricing_plans, clients, branches, review_logs, whatsapp_campaigns, analytics_snapshots';
    RAISE NOTICE '🔐 RLS enabled on all tables';
    RAISE NOTICE '📝 Sample data inserted';
    RAISE NOTICE '🚀 Ready for deployment!';
END $$;
