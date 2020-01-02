# Librerias
library(sf)
library(leaflet)
library(tidyverse)
source("https://raw.githubusercontent.com/JuveCampos/DataVizRepo/f134de2ce6bb42478fa6b2a0dd5076705cfca48c/R/R%20-%20leaflet/Mapas_zona_metropolitana/Norte.R")
niveles <- function(x) levels(as.factor(x))
b <- function(x) paste0("<b>", x, "</b>")


# Abrimos datos 
# bd <- st_read("889463674641_s/conjunto_de_datos/red_vial.shp") %>% 
#   st_transform(crs = 4326)

# saveRDS(bd, "caminos.rds")

bd <- readRDS("caminos.rds")

# Abrimos mapa de mexico sin islas
map <- st_read("https://raw.githubusercontent.com/JuveCampos/MexicoSinIslas/master/Sin_islas.geojson") %>% 
  st_transform(crs = 4326)


# Nombres de los estados 
estados <- niveles(map$ENTIDAD)



#for (i in 1:32){
for (i in 15:32){
#  i <- 16
# Caminos de los estados
# Filtramos para quedarnos con el poligono de un estado
estado <- map %>% 
  filter(ENTIDAD == estados[i])

# Seccionamos un estado y le sacamos las carreteras
edosRoads <- st_intersection(estado, bd) %>% 
  mutate(isCarretera = case_when(TIPO_VIAL == "Carretera" ~ 0.24, 
                                  TIPO_VIAL != "Carretera" ~ 0.08
                                  )) %>% 
  st_simplify(dTolerance = 0.01)

saveRDS(edosRoads, paste0(estados[i], ".rds"))
# 
# lobstr::obj_size(edosRoads)
# edosRoads2 <- edosRoads %>% 
#   st_simplify(dTolerance = 0.1)
# lobstr::obj_size(edosRoads2)
# 
# # estado %>% 
# #   st_simplify(dTolerance = 0.01) %>% 
# #   plot(max.plot = 1)
# #   # object.size()
# 
# 
# # Labels
# lab <-  lapply(paste0(b("Nombre: "), edosRoads$NOMBRE, "<br>", 
#               b("Condición: "), edosRoads$CONDICION, "<br>", 
#               b("Tipo de Vialidad: "), edosRoads$TIPO_VIAL
#               ), htmltools::HTML)
# 
# # Paleta
# pal <- colorFactor(palette = c("salmon", "#3182bd"), domain = edosRoads$isCarretera)
# 
# # Mapa guardado en el objeto mapa
# (mapa <- leaflet(edosRoads2) %>% 
#   addProviderTiles("CartoDB.Positron",
#                    options = providerTileOptions(opacity = 0.55)
#                    ) %>%
#   addPolylines(data = estado, 
#                weight = 0.8, 
#                dashArray = c(3,2), 
#                color = "black"
#                ) %>%   
#   addPolylines(weight = edosRoads$isCarretera*10, 
#                opacity = 0.9,
#                #label = lab, 
#                color = pal(edosRoads$isCarretera)) %>% 
#     addLegend(title = "Vialidades", 
#               colors = c("salmon", "#3182bd"), 
#               labels = c("Caminos", "Carreteras"), 
#               position = "bottomright"
#               ) 
#   %>%
#     norte(posicion = "topright")
#     )
# 
# lobstr::obj_size(mapa)
# # saveRDS(mapa, paste0("leaflets/", estados[i], ".rds"))

}









# (a <- readRDS("leaflets/MICHOACAN DE OCAMPO.rds"))



