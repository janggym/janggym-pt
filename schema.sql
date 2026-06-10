-- ══════════════════════════════════════════════════════════════════
--  PT Manager — Supabase Schema
--  Supabase SQL Editor에서 전체 실행하세요
-- ══════════════════════════════════════════════════════════════════

-- 기존 테이블 삭제 (재실행 시)
DROP TABLE IF EXISTS weekly_reports  CASCADE;
DROP TABLE IF EXISTS one_rm_records  CASCADE;
DROP TABLE IF EXISTS body_records    CASCADE;
DROP TABLE IF EXISTS checkins        CASCADE;
DROP TABLE IF EXISTS members         CASCADE;

-- ── members ──────────────────────────────────────────────────────
CREATE TABLE members (
  id         BIGSERIAL PRIMARY KEY,
  name       TEXT NOT NULL,
  phone      TEXT,
  memo       TEXT,
  sheets_id  TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── checkins ─────────────────────────────────────────────────────
CREATE TABLE checkins (
  id                 BIGSERIAL PRIMARY KEY,
  member_id          BIGINT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  date               DATE NOT NULL,
  exercise_type      TEXT,
  exercise_memo      TEXT,
  sleep_score        INT,
  sleep_memo         TEXT,
  pain               TEXT,
  pain_memo          TEXT,
  diet_score         INT,
  diet_memo          TEXT,
  message_to_trainer TEXT,
  created_at         TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(member_id, date)
);

-- ── body_records ──────────────────────────────────────────────────
CREATE TABLE body_records (
  id          BIGSERIAL PRIMARY KEY,
  member_id   BIGINT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  date        DATE NOT NULL,
  weight      NUMERIC,
  fat_pct     NUMERIC,
  muscle_kg   NUMERIC,
  weight_goal NUMERIC,
  fat_goal    NUMERIC,
  muscle_goal NUMERIC
);

-- ── one_rm_records ────────────────────────────────────────────────
CREATE TABLE one_rm_records (
  id            BIGSERIAL PRIMARY KEY,
  member_id     BIGINT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  date          DATE NOT NULL,
  squat         NUMERIC,
  deadlift      NUMERIC,
  bench         NUMERIC,
  squat_goal    NUMERIC,
  deadlift_goal NUMERIC,
  bench_goal    NUMERIC
);

-- ── weekly_reports ────────────────────────────────────────────────
CREATE TABLE weekly_reports (
  id               BIGSERIAL PRIMARY KEY,
  member_id        BIGINT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  date             DATE NOT NULL,
  summary          TEXT,
  last_session     JSONB,
  changes_3session JSONB,
  recurring_issues JSONB,
  coach_summary    TEXT,
  coach_detail     TEXT,
  next_step1_title TEXT,
  next_step1_body  TEXT,
  next_step2_title TEXT,
  next_step2_body  TEXT,
  next_step3_title TEXT,
  next_step3_body  TEXT,
  UNIQUE(member_id, date)
);

-- ── nutrition_goals ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS nutrition_goals (
  id            BIGSERIAL PRIMARY KEY,
  member_id     BIGINT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  calories_goal NUMERIC,
  carb_goal     NUMERIC,
  protein_goal  NUMERIC,
  fat_goal      NUMERIC,
  updated_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(member_id)
);

-- ── food_logs ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS food_logs (
  id            BIGSERIAL PRIMARY KEY,
  member_id     BIGINT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  date          DATE NOT NULL,
  foods         JSONB,
  total_calories NUMERIC,
  total_carb    NUMERIC,
  total_protein NUMERIC,
  total_fat     NUMERIC,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ── 인덱스 ────────────────────────────────────────────────────────
CREATE INDEX idx_ci_member ON checkins(member_id);
CREATE INDEX idx_ci_date   ON checkins(date);
CREATE INDEX idx_br_member ON body_records(member_id);
CREATE INDEX idx_rm_member ON one_rm_records(member_id);
CREATE INDEX idx_wr_member ON weekly_reports(member_id);
CREATE INDEX IF NOT EXISTS idx_ng_member ON nutrition_goals(member_id);
CREATE INDEX IF NOT EXISTS idx_fl_member ON food_logs(member_id);

-- ── RLS: anon 전체 허용 (사내 도구용) ──────────────────────────────
ALTER TABLE members         ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkins        ENABLE ROW LEVEL SECURITY;
ALTER TABLE body_records    ENABLE ROW LEVEL SECURITY;
ALTER TABLE one_rm_records  ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_reports  ENABLE ROW LEVEL SECURITY;
ALTER TABLE nutrition_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_logs       ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_all" ON members         FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON checkins        FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON body_records    FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON one_rm_records  FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON weekly_reports  FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON nutrition_goals FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON food_logs       FOR ALL TO anon USING (true) WITH CHECK (true);
