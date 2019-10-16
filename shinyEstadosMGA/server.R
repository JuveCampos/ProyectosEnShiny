#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define la logica del servidor para dibujar un mapa
shinyServer(function(input, output) {

# Aqui vamos a declarar las funciones de las graficas!
# Funcion para hacer el mapa
output$mapa_mpal <- renderLeaflet({

  # Filtramos la base de datos
   mappa <- bd %>%
      filter(NOM_ENT == input$selSolEstado3)

   # Generamos las paletas y toda la estetica
        pal_ga <- colorNumeric('Blues', domain = na.omit(mappa$ga))
        labels <- paste0("<b style = 'color:blue;'>Municipio: </b><br>", mappa$NOM_MUN, ", ", mappa$NOM_ENT)
        mnpopup_2 <- paste0("<b>", mappa$NOM_MUN, ", ", mappa$NOM_ENT,   "</b><br>",
                            "<b style = 'color: green;'>",   mappa$considerado2, "</b><br>",
                            "<b>", "Índice de Gobierno Abierto: ",    "</b>", specify_decimal(mappa$ga , 2) , "<br>",
                            "<b>", "Subíndice de Transparencia: ",     "</b>", specify_decimal(mappa$t ,2)  , "<br>",
                            "<b>", "Subíndice de Participación: ",     "</b>", specify_decimal(mappa$p ,2)  , "<br>") %>%
            str_replace(pattern = "style = 'color: green;'>No considerado</b><br><b>Índice de Gobierno Abierto: </b>NA<br><b>Subíndice de Transparencia: </b>NA<br><b>Subíndice de Participación: </b>NA<br>",
                        replacement = "style = 'color: red;'>No considerado</b>")

      # Hacemos el mapa
        leaflet(mappa, options = leafletOptions(zoomControl = FALSE)) %>%
            addProviderTiles("CartoDB.Positron") %>%
            addPolygons(weight = 0.9,
                        fillColor = pal_ga(mappa$ga),
                        color = 'black',
                        fillOpacity = '0.8',
                        popup = mnpopup_2,
                        label = lapply(labels, htmltools::HTML)
            ) %>%
            addLegend(position = "bottomright", pal = pal_ga, values = ~na.omit(mappa$ga),
                      title = "Índice de Gobierno Abierto", labFormat = myLabelFormat(reverse_order = F))
    })

})
