import os
import re
import time
from datetime import datetime

import googlemaps
from supabase import Client, create_client

# --- CONFIGURAÇÕES ---
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY", "")
SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "")

# Coordenadas centrais de Castanhal, PA
CASTANHAL_COORDS = (-1.2974, -47.9274)
RADIUS_METERS = 5000 # 5km de raio

CATEGORIES = [
    "Restaurante", 
    "Salão de Beleza", 
    "Advocacia", 
    "Açougue"
]

# Inicialização dos Clientes
gmaps = googlemaps.Client(key=GOOGLE_API_KEY)
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def clean_phone(phone_str):
    """Remove caracteres não numéricos e garante o padrão 5591..."""
    if not phone_str:
        return None
    
    # Remove tudo que não é dígito
    digits = re.sub(r'\D', '', phone_str)
    
    # Se começar com 0, remove
    if digits.startswith('0'):
        digits = digits[1:]
        
    # Se tiver 8 ou 9 dígitos, é número local sem DDD
    if len(digits) <= 9:
        digits = f"5591{digits}"
    # Se tiver 11 dígitos (ex: 91988887777), adiciona o código do país
    elif len(digits) == 11 and digits.startswith('91'):
        digits = f"55{digits}"
        
    return digits

def get_street_view_url(lat, lng):
    """Gera URL da API Static do Street View para a fachada"""
    base = "https://maps.googleapis.com/maps/api/streetview"
    return f"{base}?size=600x400&location={lat},{lng}&fov=90&heading=235&pitch=10&key={GOOGLE_API_KEY}"

def fetch_and_sync():
    all_businesses = []

    print(f"🚀 Iniciando extração para Castanhal Hub - {datetime.now()}")

    for category in CATEGORIES:
        print(f"🔎 Buscando categoria: {category}...")
        
        # Busca inicial (Nearby Search)
        places_result = gmaps.places_nearby(
            location=CASTANHAL_COORDS,
            radius=RADIUS_METERS,
            keyword=category
        )

        while True:
            for place in places_result.get('results', []):
                place_id = place['place_id']
                
                # Detalhes específicos (Telefone não vem no Nearby Search padrão)
                # Nota: Cada call de details custa uma fração de centavo na cota
                details = gmaps.place(
                    place_id=place_id, 
                    fields=['name', 'formatted_phone_number', 'geometry', 'rating', 'vicinity']
                ).get('result', {})

                lat = details['geometry']['location']['lat']
                lng = details['geometry']['location']['lng']
                
                biz_data = {
                    "business_name": details.get('name'),
                    "category_name": category,
                    "address": details.get('vicinity'),
                    "phone_number": clean_phone(details.get('formatted_phone_number')),
                    "rating": details.get('rating', 5.0),
                    "latitude": lat,
                    "longitude": lng,
                    "cover_url": get_street_view_url(lat, lng),
                    "is_premium": False, # Default
                    "created_at": datetime.now().isoformat()
                }

                # Filtro simples: Só adiciona se tiver telefone (essencial para o Hub)
                if biz_data["phone_number"]:
                    all_businesses.append(biz_data)
                    print(f" ✅ Adicionado: {biz_data['business_name']}")
                
                # Respeitar Rate Limit do Google Details API
                time.sleep(0.2)

            # Verifica se há mais páginas de resultados
            next_page_token = places_result.get('next_page_token')
            if not next_page_token:
                break
            
            # Aguarda o token da próxima página ficar ativo
            time.sleep(2)
            places_result = gmaps.places_nearby(page_token=next_page_token)

    # Inserção em Lote no Supabase
    if all_businesses:
        print(f"\n📦 Enviando {len(all_businesses)} registros para o Supabase...")
        try:
            # Batch insert
            data, count = supabase.table("businesses").insert(all_businesses).execute()
            print(f"🔥 SUCESSO! {len(all_businesses)} empresas sincronizadas.")
        except Exception as e:
            print(f"❌ Erro ao inserir no Supabase: {e}")
    else:
        print("⚠️ Nenhuma empresa com telefone encontrada.")

if __name__ == "__main__":
    fetch_and_sync()