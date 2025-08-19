-- Insert sample profiles (these will be created after users sign up)
-- This is just for reference - actual profiles are created via the app

-- Insert sample achievements types for reference
INSERT INTO achievements (player_id, type, title, description, month, year) VALUES
  -- These will be populated by the app based on user activity
  (uuid_generate_v4(), 'artilheiro_mes', 'Artilheiro do Mês', 'Maior número de gols no mês', 12, 2024),
  (uuid_generate_v4(), 'fair_play', 'Fair Play', 'Melhor comportamento em campo', 12, 2024);

-- Note: Most data will be created through the app interface
-- This script mainly sets up the structure
