-- ============================================================
-- CATEGORIAS para o Castanhal HUB
-- Execute no SQL Editor do Supabase
--
-- ⚠️  ATENÇÃO: O script completo de migração está em:
--     scripts/migracao_completa.sql
--     Execute aquele arquivo para criar toda a estrutura do zero.
--
-- Este arquivo serve apenas como referência para o seed.
-- ============================================================

INSERT INTO categories (name, icon_name) VALUES
  ('Alimentação',       'restaurant'),
  ('Compras',           'shopping_bag'),
  ('Serviços',          'build'),
  ('Saúde & Beleza',    'spa'),
  ('Educação',          'school'),
  ('Lazer & Entretenimento', 'sports_esports'),
  ('Hospedagem',        'hotel'),
  ('Automotivo',        'directions_car'),
  ('Imobiliário',       'real_estate_agent'),
  ('Tecnologia',        'computer'),
  ('Moda & Acessórios', 'checkroom'),
  ('Agro & Negócios',   'agriculture')
ON CONFLICT (name) DO NOTHING;
