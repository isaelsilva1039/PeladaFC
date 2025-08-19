-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table (extends auth.users)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL,
  avatar_url TEXT,
  age INTEGER,
  preferred_position TEXT CHECK (preferred_position IN ('goleiro', 'lateral', 'zagueiro', 'volante', 'meia', 'atacante')),
  goals INTEGER DEFAULT 0,
  assists INTEGER DEFAULT 0,
  games_played INTEGER DEFAULT 0,
  wins INTEGER DEFAULT 0,
  rating DECIMAL(2,1) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
  total_ratings INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create peladas table
CREATE TABLE peladas (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  creator_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  date_time TIMESTAMP WITH TIME ZONE NOT NULL,
  location TEXT NOT NULL,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  players_per_team INTEGER DEFAULT 11,
  max_players INTEGER DEFAULT 22,
  field_cost DECIMAL(10, 2) DEFAULT 0,
  rules TEXT,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'full', 'in_progress', 'finished', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create pelada_participants table
CREATE TABLE pelada_participants (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  pelada_id UUID REFERENCES peladas(id) ON DELETE CASCADE NOT NULL,
  player_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  status TEXT DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'maybe', 'declined')),
  team INTEGER CHECK (team IN (1, 2)),
  position TEXT,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(pelada_id, player_id)
);

-- Create game_stats table
CREATE TABLE game_stats (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  pelada_id UUID REFERENCES peladas(id) ON DELETE CASCADE NOT NULL,
  player_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  goals INTEGER DEFAULT 0,
  assists INTEGER DEFAULT 0,
  fouls INTEGER DEFAULT 0,
  yellow_cards INTEGER DEFAULT 0,
  red_cards INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(pelada_id, player_id)
);

-- Create player_ratings table
CREATE TABLE player_ratings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  pelada_id UUID REFERENCES peladas(id) ON DELETE CASCADE NOT NULL,
  rated_player_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  rater_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  skill_rating INTEGER CHECK (skill_rating >= 1 AND skill_rating <= 5),
  fair_play_rating INTEGER CHECK (fair_play_rating >= 1 AND fair_play_rating <= 5),
  presence_rating INTEGER CHECK (presence_rating >= 1 AND presence_rating <= 5),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(pelada_id, rated_player_id, rater_id)
);

-- Create posts table (for social feed)
CREATE TABLE posts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  author_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  pelada_id UUID REFERENCES peladas(id) ON DELETE SET NULL,
  content TEXT,
  media_url TEXT,
  media_type TEXT CHECK (media_type IN ('image', 'video')),
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create post_likes table
CREATE TABLE post_likes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- Create post_comments table
CREATE TABLE post_comments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
  author_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create achievements table
CREATE TABLE achievements (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  player_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('artilheiro_mes', 'melhor_goleiro', 'fair_play', 'mais_ativo', 'veterano')),
  title TEXT NOT NULL,
  description TEXT,
  earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  month INTEGER,
  year INTEGER
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE peladas ENABLE ROW LEVEL SECURITY;
ALTER TABLE pelada_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Public profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Peladas are viewable by everyone" ON peladas FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create peladas" ON peladas FOR INSERT WITH CHECK (auth.uid() = creator_id);
CREATE POLICY "Creators can update their peladas" ON peladas FOR UPDATE USING (auth.uid() = creator_id);

CREATE POLICY "Participants are viewable by everyone" ON pelada_participants FOR SELECT USING (true);
CREATE POLICY "Users can join peladas" ON pelada_participants FOR INSERT WITH CHECK (auth.uid() = player_id);
CREATE POLICY "Users can update their participation" ON pelada_participants FOR UPDATE USING (auth.uid() = player_id);

CREATE POLICY "Game stats are viewable by everyone" ON game_stats FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert game stats" ON game_stats FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Player ratings are viewable by everyone" ON player_ratings FOR SELECT USING (true);
CREATE POLICY "Users can rate other players" ON player_ratings FOR INSERT WITH CHECK (auth.uid() = rater_id);

CREATE POLICY "Posts are viewable by everyone" ON posts FOR SELECT USING (true);
CREATE POLICY "Users can create posts" ON posts FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own posts" ON posts FOR UPDATE USING (auth.uid() = author_id);

CREATE POLICY "Post likes are viewable by everyone" ON post_likes FOR SELECT USING (true);
CREATE POLICY "Users can like posts" ON post_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unlike posts" ON post_likes FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Post comments are viewable by everyone" ON post_comments FOR SELECT USING (true);
CREATE POLICY "Users can comment on posts" ON post_comments FOR INSERT WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Achievements are viewable by everyone" ON achievements FOR SELECT USING (true);
CREATE POLICY "System can create achievements" ON achievements FOR INSERT WITH CHECK (true);

-- Create functions to update profile stats
CREATE OR REPLACE FUNCTION update_profile_stats()
RETURNS TRIGGER AS $$
BEGIN
  -- Update goals, assists, games played
  UPDATE profiles 
  SET 
    goals = (SELECT COALESCE(SUM(goals), 0) FROM game_stats WHERE player_id = NEW.player_id),
    assists = (SELECT COALESCE(SUM(assists), 0) FROM game_stats WHERE player_id = NEW.player_id),
    games_played = (SELECT COUNT(*) FROM game_stats WHERE player_id = NEW.player_id),
    updated_at = NOW()
  WHERE id = NEW.player_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profile_stats_trigger
  AFTER INSERT OR UPDATE ON game_stats
  FOR EACH ROW
  EXECUTE FUNCTION update_profile_stats();

-- Create function to update profile rating
CREATE OR REPLACE FUNCTION update_profile_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE profiles 
  SET 
    rating = (
      SELECT COALESCE(AVG((skill_rating + fair_play_rating + presence_rating) / 3.0), 0)
      FROM player_ratings 
      WHERE rated_player_id = NEW.rated_player_id
    ),
    total_ratings = (
      SELECT COUNT(*) 
      FROM player_ratings 
      WHERE rated_player_id = NEW.rated_player_id
    ),
    updated_at = NOW()
  WHERE id = NEW.rated_player_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profile_rating_trigger
  AFTER INSERT OR UPDATE ON player_ratings
  FOR EACH ROW
  EXECUTE FUNCTION update_profile_rating();

-- Create function to update post counts
CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET likes_count = likes_count - 1 WHERE id = OLD.post_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_post_likes_count_trigger
  AFTER INSERT OR DELETE ON post_likes
  FOR EACH ROW
  EXECUTE FUNCTION update_post_likes_count();

CREATE OR REPLACE FUNCTION update_post_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET comments_count = comments_count - 1 WHERE id = OLD.post_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_post_comments_count_trigger
  AFTER INSERT OR DELETE ON post_comments
  FOR EACH ROW
  EXECUTE FUNCTION update_post_comments_count();
