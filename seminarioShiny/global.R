library(pacman)
library(sf)
library(leaflet)
library(tidyverse)
library(shiny)

# 1. Leemos los datos 
mapa <- st_read("www/mpios.geojson")

# 2. Mapa de Aguascalientes
ags <- mapa %>% 
  filter(NOM_ENT == "Sinaloa")

pal = colorNumeric(palette = "magma", 
                   domain = ags$POBTOT
                   )

leaflet(ags) %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  addPolygons(color = "white", 
              weight = 1, 
              fillColor = ~pal(POBTOT), 
              fillOpacity = 1, 
              label = paste0("Poblacion: ", 
                             prettyNum(ags$POBTOT, big.mark = ",") )
              ) %>% 
  addLegend(title = "Poblacion ", 
            pal = pal, 
            values = ags$POBTOT, 
            position = "bottomleft")


popEstado <- function(estado = "Aguascalientes"){
  
  ags <- mapa %>% 
    filter(NOM_ENT == estado)
  
  pal = colorNumeric(palette = "magma", 
                     domain = ags$POBTOT
  )
  
leaflet(ags) %>% 
    addProviderTiles("CartoDB.Positron") %>% 
    addPolygons(color = "white", 
                weight = 1, 
                fillColor = ~pal(POBTOT), 
                fillOpacity = 1,
                highlightOptions = highlightOptions(color = "white", 
                                                    weight = 4,
                                                    opacity = 1,
                                                    bringToFront = TRUE),
                popup = paste0("Municipio: ", ags$NOM_MUN),
                label = paste0("Poblacion: ", 
                               prettyNum(ags$POBTOT, big.mark = ",") )
    ) %>% 
    addLegend(title = "Poblacion ", 
              pal = pal, 
              values = ags$POBTOT, 
              position = "bottomleft")

}



