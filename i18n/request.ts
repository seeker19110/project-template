// next-intl (App Router, KHÔNG dùng i18n routing) — chọn locale theo cookie.
// Xem docs/framework/quality-supplements.md PHẦN 4 (i18n).
import { getRequestConfig } from 'next-intl/server';
import { cookies } from 'next/headers';

const SUPPORTED = ['vi', 'en'] as const;
type Locale = (typeof SUPPORTED)[number];
const DEFAULT_LOCALE: Locale = 'vi';

// Type guard: thu hẹp string | undefined → Locale mà không cần ép kiểu `as`.
function isLocale(value: string | undefined): value is Locale {
  return value !== undefined && (SUPPORTED as readonly string[]).includes(value);
}

export default getRequestConfig(async () => {
  const store = await cookies();
  const fromCookie = store.get('locale')?.value;
  const locale: Locale = isLocale(fromCookie) ? fromCookie : DEFAULT_LOCALE;

  return {
    locale,
    messages: (await import(`../messages/${locale}.json`)).default,
  };
});
