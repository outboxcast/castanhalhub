-- ============================================================
-- CONFIGURAÇÃO DO STORAGE (Bucket de imagens)
--
-- ⚠️  ATENÇÃO: O script completo de migração está em:
--     scripts/migracao_completa.sql
--     Execute aquele arquivo para criar toda a estrutura do zero.
--
-- Este arquivo serve apenas como referência para o setup do storage.
-- ============================================================

-- Cria bucket público para imagens
INSERT INTO storage.buckets (id, name, public, avif_autodetection)
VALUES ('business-images', 'business-images', true, false)
ON CONFLICT (id) DO NOTHING;

-- Remove políticas antigas para evitar duplicatas
DROP POLICY IF EXISTS "Imagens públicas" ON storage.objects;
DROP POLICY IF EXISTS "Upload por admin autenticado" ON storage.objects;
DROP POLICY IF EXISTS "Update por admin autenticado" ON storage.objects;
DROP POLICY IF EXISTS "Delete por admin autenticado" ON storage.objects;

-- Política: qualquer um pode ver imagens
CREATE POLICY "Imagens públicas"
ON storage.objects FOR SELECT
USING (bucket_id = 'business-images');

-- Política: apenas admin autenticado pode fazer upload
CREATE POLICY "Upload por admin autenticado"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'business-images');

-- Política: apenas admin autenticado pode atualizar
CREATE POLICY "Update por admin autenticado"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'business-images')
WITH CHECK (bucket_id = 'business-images');

-- Política: apenas admin autenticado pode deletar
CREATE POLICY "Delete por admin autenticado"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'business-images');
