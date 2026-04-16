# 🎯 دليل سريع - UMI Website

## ⚡ البداية السريعة (3 دقائق)

### 1. التثبيت
```bash
cd umi-website
npm install
```

### 2. إعداد Supabase
1. أنشئ مشروع في [supabase.com](https://supabase.com)
2. SQL Editor → الصق محتوى `SUPABASE_SETUP.sql` → Run
3. Settings → API → انسخ URL و anon key

### 3. Environment Variables
```bash
cp .env.example .env.local
```

أضف في `.env.local`:
```
NEXT_PUBLIC_SUPABASE_URL=your_url_here
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_key_here
```

### 4. تشغيل
```bash
npm run dev
```

---

## 🌐 النشر على Vercel

```bash
npm i -g vercel
vercel
```

أو ارفع على GitHub واستورد في [vercel.com/new](https://vercel.com/new)

**⚠️ مهم:** أضف Environment Variables في Vercel Dashboard!

---

## 🎨 التعديلات الشائعة

### تغيير اللون الرئيسي
`app/globals.css`:
```css
--accent-blue: 245 59% 60%; /* غيّر هذا */
```

### تعديل الأسعار
في Supabase → Table Editor → `pricing_plans` → Edit

أو في `lib/language-context.tsx` → `pricing` section

### إضافة خدمة
1. Supabase → `services` table → Insert row
2. `components/ServicesGrid.tsx` → أضف في `services` array
3. `lib/language-context.tsx` → أضف الترجمة

### تغيير شعار الشركة
`components/HeroSection.tsx`:
```jsx
<div className="w-12 h-12...">
  <span>U</span> {/* غيّر الحرف هنا */}
</div>
```

---

## 📱 روابط مهمة

- **Supabase Dashboard:** [app.supabase.com](https://app.supabase.com)
- **Vercel Dashboard:** [vercel.com/dashboard](https://vercel.com/dashboard)
- **التوثيق الكامل:** `README.md`
- **التوثيق بالعربي:** `DEPLOYMENT_AR.md`

---

## 🐛 حل المشاكل

### "Can't resolve @/components"
```bash
rm -rf node_modules .next
npm install
```

### "Supabase connection error"
تحقق من:
1. `.env.local` موجود
2. القيم صحيحة (بدون مسافات)
3. أعد تشغيل `npm run dev`

### "Build failed on Vercel"
1. Environment Variables موجودة
2. Node version = 18.x
3. Build Command = `next build`

---

## ✅ Checklist قبل الإطلاق

- [ ] قاعدة البيانات منشأة في Supabase
- [ ] Environment variables محددة
- [ ] الموقع يعمل محلياً بدون أخطاء
- [ ] تم اختبار تبديل اللغة
- [ ] تم اختبار جميع الأزرار
- [ ] SSL مفعّل (تلقائي في Vercel)
- [ ] Google Analytics مضاف (اختياري)
- [ ] النطاق المخصص مربوط

---

## 🚀 الخطوة التالية

بعد النشر:
1. شارك الموقع مع فريقك
2. اجمع feedback
3. راقب الأداء في Vercel Analytics
4. ابدأ في إضافة ميزات جديدة

**موفق!** 🎉
