ALTER TABLE body_records ADD CONSTRAINT body_records_member_date_unique UNIQUE (member_id, date);
