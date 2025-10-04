-- Create storage bucket for user uploaded images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'user-images',
  'user-images',
  true,
  10485760, -- 10MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
);

-- Create storage policies for user images
CREATE POLICY "Anyone can upload images"
ON storage.objects
FOR INSERT
WITH CHECK (bucket_id = 'user-images');

CREATE POLICY "Anyone can view images"
ON storage.objects
FOR SELECT
USING (bucket_id = 'user-images');

CREATE POLICY "Users can delete their own images"
ON storage.objects
FOR DELETE
USING (bucket_id = 'user-images');

-- Create table for uploaded images metadata
CREATE TABLE public.uploaded_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  original_url TEXT NOT NULL,
  enhanced_url TEXT,
  thumbnail_url TEXT,
  file_name TEXT NOT NULL,
  file_size INTEGER,
  width INTEGER,
  height INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.uploaded_images ENABLE ROW LEVEL SECURITY;

-- Create RLS policies - allow everyone to view and create (for demo purposes)
CREATE POLICY "Anyone can view uploaded images"
ON public.uploaded_images
FOR SELECT
USING (true);

CREATE POLICY "Anyone can upload images"
ON public.uploaded_images
FOR INSERT
WITH CHECK (true);

CREATE POLICY "Anyone can delete uploaded images"
ON public.uploaded_images
FOR DELETE
USING (true);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.uploaded_images
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();