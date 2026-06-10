// ── Supabase 설정 ──────────────────────────────────────────────────
// Supabase 대시보드 → Settings → API 에서 복사
const SUPABASE_URL  = 'https://blyehdfgrbfzjpsitgzh.supabase.co';
const SUPABASE_KEY  = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJseWVoZGZncmJmempwc2l0Z3poIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAxMjcwMTIsImV4cCI6MjA5NTcwMzAxMn0.QAR042FPKFP-EK2AthUElsk-eTCKnNg1Z-WsorMUYd8';

const { createClient } = supabase;
const db = createClient(SUPABASE_URL, SUPABASE_KEY);

// ── 공통 헬퍼 ─────────────────────────────────────────────────────
const today = () => new Date().toISOString().split('T')[0];

function weekRange() {
  const d = new Date();
  const day = d.getDay(); // 0=일
  const mon = new Date(d); mon.setDate(d.getDate() - (day === 0 ? 6 : day - 1));
  const sun = new Date(mon); sun.setDate(mon.getDate() + 6);
  return [mon.toISOString().split('T')[0], sun.toISOString().split('T')[0]];
}

function fmt(n, dec = 1) {
  if (n == null) return '—';
  return Number(n).toFixed(dec);
}

function ko_date(iso) {
  if (!iso) return '';
  const [y, m, d] = iso.split('-');
  return `${y}년 ${+m}월 ${+d}일`;
}
