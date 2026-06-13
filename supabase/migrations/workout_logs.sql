CREATE TABLE IF NOT EXISTS workout_logs (
  id            BIGSERIAL PRIMARY KEY,
  member_id     BIGINT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  date          DATE NOT NULL,
  day           TEXT NOT NULL,
  exercise_name TEXT NOT NULL,
  reps_done     TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(member_id, date, day, exercise_name)
);

CREATE INDEX IF NOT EXISTS idx_wl_member_date ON workout_logs(member_id, date);

ALTER TABLE workout_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_all" ON workout_logs FOR ALL TO anon USING (true) WITH CHECK (true);
