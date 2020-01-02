library(shiny)
library(leaflet)
library(sf)
library(tidyverse)
source("https://raw.githubusercontent.com/JuveCampos/DataVizRepo/f134de2ce6bb42478fa6b2a0dd5076705cfca48c/R/R%20-%20leaflet/Mapas_zona_metropolitana/Norte.R")
niveles <- function(x) levels(as.factor(x))
b <- function(x) paste0("<b>", x, "</b>")

edos <- list.files("www", pattern = ".rds")[-4] %>% 
  str_remove(pattern = ".rds")

mapx <- st_read("https://raw.githubusercontent.com/JuveCampos/MexicoSinIslas/master/Sin_islas.geojson") %>% 
  st_transform(crs = 4326)


# Define UI for application that draws a histogram
ui <- navbarPage(title = "Red Caminos", id = "intro",
                 
                 tabPanel("*",
                          div(class="outer",
                              tags$head(
                                # Include our custom CSS
                                includeCSS("styles.css"),
                                includeScript("gomap.js")
                              ),  
                              
                              leafletOutput("mapita", width="100%", height="100%"),    
                              
                              absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                            draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                            width = 330, height = "auto",    
                                            h2("Entidades federativas"),    
                                            #column(4,
                                            selectInput(inputId = "selEdo", label = "Seleccionar Estado",
                                                        choices = edos, 
                                                        selected = edos[1]
                                                        #       )
                                            ), 
                                            p("Fuente: INEGI. Red Nacional de Caminos 2018.")
                                            
                                            
                              )
                          )
                 )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$mapita <- renderLeaflet({
    # root <- paste0("www/leaflets/", input$selEdo, ".rds")    
    # a <- readRDS("www/leaflets/AGUASCALIENTES.rds")
    # a
    # print(root)
    # #
    # # print(input$selEdo)
    # 
    
    estado <- mapx %>% 
      filter(ENTIDAD == #"AGUASCALIENTES" 
               input$selEdo
             )
    
    
    edosRoads2 <- readRDS(paste0("www/",input$selEdo, ".rds")
                          #"AGUASCALIENTES.rds"
    )
    
    # Labels
    lab <-  lapply(paste0(b("Nombre: "), edosRoads2$NOMBRE, "<br>",
                          b("Condición: "), edosRoads2$CONDICION, "<br>",
                          b("Tipo de Vialidad: "), edosRoads2$TIPO_VIAL
    ), htmltools::HTML)
    
    # Paleta
    pal <- colorFactor(palette = c("salmon", "#3182bd"), domain = edosRoads2$isCarretera)
    
    # Mapa guardado en el objeto mapa
    (mapa <- leaflet(edosRoads2) %>%
        addProviderTiles("CartoDB.Positron",
                         options = providerTileOptions(opacity = 0.55)
        ) %>%
        addPolylines(data = estado,
                     weight = 0.8,
                     dashArray = c(3,2),
                     color = "black"
        ) %>%
        addPolylines(weight = edosRoads2$isCarretera*10,
                     opacity = 0.9,
                     label = lab,
                     color = pal(edosRoads2$isCarretera)) %>%
        addLegend(title = "Vialidades",
                  colors = c("salmon", "#3182bd"),
                  labels = c("Caminos", "Carreteras"),
                  position = "bottomright"
        )
      %>%
        norte(posicion = "topright")
    )
    
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
