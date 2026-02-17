import streamlit as st
import pandas as pd
import sqlite3
import plotly.express as px

# Configuración de la página
st.set_page_config(page_title="Retail Analytics Dashboard", layout="wide")

st.title("📊 Dashboard de Inteligencia de Negocios - Online Retail")
st.markdown("Este dashboard analiza el comportamiento de compra y segmentación de clientes.")

# Conectar a la base de datos SQL que creamos antes
conexion = sqlite3.connect('retail_database.db')

#--- Cargar Datos ---
@st.cache_data
def load_data():
    df = pd.read_sql("SELECT * FROM sales", conexion)
    return df

df = load_data()

# --- Sidebar / Filtros ---
st.sidebar.header("Filtros")
paises = st.sidebar.multiselect("Selecciona el País:", options=df['Country'].unique(), default=['United Kingdom', 'France', 'Germany'])

df_selection = df[df['Country'].isin(paises)]

# --- Métricas Principales ---
total_sales = df_selection['TotalRevenue'].sum()
total_orders = df_selection['Invoice'].nunique()
avg_ticket = total_sales / total_orders

col1, col2, col3 = st.columns(3)
col1.metric("Ingresos Totales", f"£{total_sales:,.2f}")
col2.metric("Total Pedidos", f"{total_orders:,}")
col3.metric("Ticket Promedio", f"£{avg_ticket:.2f}")

st.divider()

# --- Gráficos ---
c1, c2 = st.columns(2)
with c1:
    st.subheader("Ventas Mensuales")
    # Agrupar por mes (ya que MonthYear es string ahora)
    monthly_sales = df_selection.groupby('MonthYear')['TotalRevenue'].sum().reset_index()
    fig_monthly = px.line(monthly_sales, x='MonthYear', y='TotalRevenue', title="Tendencia de Ventas")
    st.plotly_chart(fig_monthly, use_container_width=True)

with c2:
    st.subheader("Top 10 Productos más Vendidos")
    top_products = df_selection.groupby('Description')['Quantity'].sum().sort_values(ascending=False).head(10).reset_index()
    fig_products = px.bar(top_products, x='Quantity', y='Description', orientation='h', color='Quantity')
    st.plotly_chart(fig_products, use_container_width=True)

# --- Análisis RFM (Visualización de Segmentos) ---
st.subheader("📍 Segmentación de Clientes (Recencia vs Monetario)")
# Simulamos una visualización rápida del RFM cargándolo si lo guardaste o calculándolo rápido
fig_rfm = px.scatter(df_selection.groupby('Customer ID').agg({'TotalRevenue':'sum', 'Quantity':'sum'}).reset_index(), 
                 x='Quantity', y='TotalRevenue', hover_name='Customer ID', 
                 title="Dispersión de Clientes (Volumen vs Gasto)")
st.plotly_chart(fig_rfm, use_container_width=True)

st.write("✅ **Tip para el Portafolio:** Este dashboard demuestra habilidades en SQL, Python, Limpieza de Datos y Visualización.")
