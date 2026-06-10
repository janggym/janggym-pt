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

CREATE INDEX IF NOT EXISTS idx_ng_member ON nutrition_goals(member_id);

ALTER TABLE nutrition_goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_all" ON nutrition_goals FOR ALL TO anon USING (true) WITH CHECK (true);
