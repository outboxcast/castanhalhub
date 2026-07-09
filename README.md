# Castanhal Hub

App para conectar moradores de Castanhal, PA, aos melhores negócios locais.

## Estrutura do Projeto

| Pacote | Descrição |
|--------|-----------|
| `app/` | App mobile (Android + iOS) — para usuários finais |
| `admin/` | Painel administrativo web — para gerenciar negócios |
| `shared/` | Pacote compartilhado entre app e admin (modelos, serviços, tema) |

## Plataformas Suportadas

- **App:** Android e iOS
- **Admin:** Web

## Principais Funcionalidades

- 📍 Mapa interativo com comércios locais
- 🔍 Busca e filtro por categorias
- ⭐ Negócios em destaque (premium)
- 📱 Contato direto via WhatsApp e Instagram
- ❤️ Favoritos (requer login)
- 🔐 Autenticação: Email, Google e Apple
- 👤 Modo convidado (navegação limitada)

## Configuração

1. Certifique-se de ter o [Flutter SDK](https://flutter.dev) instalado
2. Configure as variáveis de ambiente `SUPABASE_URL` e `SUPABASE_ANON_KEY`
3. Execute `flutter pub get` em `shared/`, `app/` e `admin/`
4. Execute `flutter run` no pacote desejado