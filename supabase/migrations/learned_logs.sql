CREATE TABLE IF NOT EXISTS learned_logs (
  id         BIGSERIAL PRIMARY KEY,
  member_id  BIGINT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  date       DATE NOT NULL,
  exercises  JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(member_id, date)
);

CREATE INDEX IF NOT EXISTS idx_ll_member ON learned_logs(member_id);

ALTER TABLE learned_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_all" ON learned_logs FOR ALL TO anon USING (true) WITH CHECK (true);
