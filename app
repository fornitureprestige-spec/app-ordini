import streamlit as st
import pandas as pd
from datetime import datetime

st.set_page_config(page_title="Gestione Ordini Commerciali", layout="wide")

# Database simulato (in un'app reale useremmo SQL)
if 'ordini' not in st.session_state:
    st.session_state.ordini = []

st.title("📦 Sistema Ordini Rapido")

# --- INTERFACCIA COMMERCIALE (MOBILE) ---
with st.expander("📝 Nuovo Ordine (Area Commerciale)", expanded=True):
    nome_cliente = st.text_input("Nome Cliente")
    
    col1, col2 = st.columns(2)
    prodotto = col1.selectbox("Prodotto", ["Trapano X1", "Bulloni M8", "Cacciavite Y"])
    quantita = col2.number_input("Quantità", min_value=1, step=1)
    
    foto = st.file_uploader("Allega Foto", type=["jpg", "png", "jpeg"])
    audio = st.audio_input("Registra Nota Vocale") # Funziona su browser moderni e Android
    
    if st.button("Invia Ordine"):
        nuovo_ordine = {
            "id": len(st.session_state.ordini) + 1,
            "data": datetime.now().strftime("%d/%m/%Y %H:%M"),
            "cliente": nome_cliente,
            "prodotto": prodotto,
            "ordinato": quantita,
            "consegnato": 0,
            "stato": "In attesa",
            "foto": foto.name if foto else "Nessuna",
            "nota": "Audio presente" if audio else "Nessuna"
        }
        st.session_state.ordini.append(nuovo_ordine)
        st.success("Ordine inviato con successo!")

---

# --- INTERFACCIA MAGAZZINO / ADMIN (PC) ---
st.header("🖥️ Gestione e Consegne (Area Admin)")

if not st.session_state.ordini:
    st.info("Nessun ordine presente.")
else:
    df = pd.DataFrame(st.session_state.ordini)
    st.table(df)

    st.subheader("Modifica Stato Consegna")
    ordine_id = st.selectbox("Seleziona ID Ordine da gestire", df["id"])
    
    # Trova l'ordine selezionato
    for o in st.session_state.ordini:
        if o["id"] == ordine_id:
            consegnato_ora = st.number_input(f"Quantità consegnata per {o['prodotto']}", 
                                             max_value=o["ordinato"], value=o["consegnato"])
            
            if st.button("Aggiorna Consegna"):
                o["consegnato"] = consegnato_ora
                if consegnato_ora == o["ordinato"]:
                    o["stato"] = "Completato"
                elif consegnato_ora > 0:
                    o["stato"] = "Parziale (Rimanenza: " + str(o["ordinato"] - consegnato_ora) + ")"
                st.rerun()
