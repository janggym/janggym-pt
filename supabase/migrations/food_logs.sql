CREATE TABLE IF NOT EXISTS food_logs (
  id             BIGSERIAL PRIMARY KEY,
  member_id      BIGINT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  date           DATE NOT NULL,
  foods          JSONB,
  total_calories NUMERIC,
  total_carb     NUMERIC,
  total_protein  NUMERIC,
  total_fat      NUMERIC,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fl_member ON food_logs(member_id);

ALTER TABLE food_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_all" ON food_logs FOR ALL TO anon USING (true) WITH CHECK (true);
