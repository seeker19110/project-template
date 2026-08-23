'use client';

import { useCallback, useSyncExternalStore } from 'react';
import { useTranslations } from 'next-intl';

/**
 * Nút chuyển theme (Dark blue mặc định ↔ Light).
 * Đi kèm `styles/theme.css` (design tokens) + script no-flash trong app/layout.tsx.
 * Xem docs/framework/quality-supplements.md PHẦN 3.
 *
 * Nguyên tắc: dùng token (bg-background/text-foreground...), không hard-code màu;
 * lựa chọn được nhớ trong localStorage; có aria-label cho accessibility.
 *
 * NGUỒN SỰ THẬT là thuộc tính `data-theme` trên <html> (do script no-flash đặt TRƯỚC khi
 * React hydrate), không phải state của React. Vì vậy dùng `useSyncExternalStore` thay vì
 * `useState` + `useEffect`: đọc-state-trong-effect vừa bị React Compiler lint chặn
 * (`react-hooks/set-state-in-effect`), vừa gây một lượt render thừa sau hydrate.
 * `useSyncExternalStore` là cách React chính thức để đọc trạng thái ngoài React mà vẫn
 * khớp SSR (server dùng `getServerSnapshot`, client đồng bộ lại ngay sau hydrate).
 */
type Theme = 'light' | 'dark';

const THEME_EVENT = 'themechange';

function subscribe(onChange: () => void) {
  // `storage`: theme đổi ở tab khác. `THEME_EVENT`: đổi ở chính tab này (toggle bên dưới).
  window.addEventListener('storage', onChange);
  window.addEventListener(THEME_EVENT, onChange);
  return () => {
    window.removeEventListener('storage', onChange);
    window.removeEventListener(THEME_EVENT, onChange);
  };
}

function getSnapshot(): Theme {
  return document.documentElement.dataset.theme === 'light' ? 'light' : 'dark';
}

// Trên server không có DOM — mặc định Dark blue, đúng mặc định của khung.
function getServerSnapshot(): Theme {
  return 'dark';
}

export function ThemeToggle() {
  const theme = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);
  // Nhãn/aria đi qua next-intl (messages/vi.json + messages/en.json, khối "theme").
  const t = useTranslations('theme');

  const toggle = useCallback(() => {
    const next: Theme = theme === 'dark' ? 'light' : 'dark';
    document.documentElement.dataset.theme = next;
    localStorage.setItem('theme', next);
    window.dispatchEvent(new Event(THEME_EVENT));
  }, [theme]);

  return (
    <button
      type="button"
      onClick={toggle}
      aria-label={theme === 'dark' ? t('switchToLight') : t('switchToDark')}
      className="border-border text-foreground rounded-lg border px-3 py-2"
    >
      {theme === 'dark' ? `☀️ ${t('light')}` : `🌙 ${t('dark')}`}
    </button>
  );
}
