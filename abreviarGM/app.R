library(leaflet)
library(tidyverse)
library(sf)
library(shiny)
library(DT)
library(kableExtra)

kablam <- function(df) {
  df %>% 
    knitr::kable("html") %>%
    kable_styling("striped", full_width = F) 
}


# Define UI
ui <- fluidPage(
  
  # Application title
  titlePanel("Abreviacion GroupMap"),
  
  sidebarLayout(
    
    # Sidebar with a slider input
    sidebarPanel(
      fileInput("file1", "Sube tu archivo *.csv de GM",
                multiple = FALSE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv"))
      
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      # plotOutput("distPlot")
      tabsetPanel(
        tabPanel("Tabla", tableOutput("datatable")), 
        tabPanel("Grafica", leafletOutput("plot", height = 500), 
                 br(),
                 fluidPage(
                   fluidRow(
                     column(6, numericInput(inputId = "numImpacto", label = "Impacto: ", value = 0)), 
                     column(6, numericInput(inputId = "numFactibilidad", label = "Factibilidad: ", value = 0))
                   )
                 ),
                 br(),
                 #DT::dataTableOutput("datatable2"))
                 tableOutput("datatable2")
      ))
    )
  )
)

# Server logic
server <- function(input, output, session) {
  
  # Beta
  beta <- reactive({
    req(input$file1)
    tryCatch(
      {
        beta <- read_csv(input$file1$datapath) %>% 
          head(2) %>% 
          names() %>% 
          str_remove(pattern = "^# ")
        
      },
      error = function(e) {
        stop(safeError(e))
      }
    )
    return(beta)
  })
  
  
  bd <- reactive({
    req(input$file1)
    tryCatch(
      {
        df <- read_csv(input$file1$datapath,
                       skip = 3) %>% 
          mutate(Region = beta()) %>% 
          mutate(Title = str_replace_all(string = Title, 
                                         pattern = "\\s+", 
                                         replacement = " ")) %>% 
          #mutate(Region = beta) %>% 
          mutate(`Promedio X` = mean(X),
                 `Promedio Y` = mean(Y),
                 `Impacto` = X - `Promedio X`,
                 `Factibilidad` = Y - `Promedio Y`) %>% 
          mutate(No = "1")
        
      },
      error = function(e) {
        stop(safeError(e))
      }
    )
    return(df)
    
  })
  
  output$datatable <- function(){
    bd() %>% 
      kablam()
    # DT::renderDataTable({
    
    # DT::datatable(bd(), 
    #               extensions = 'FixedColumns',
    #               rownames= FALSE,
    #               options = list(
    #                 pageLength = 5,
    #                 language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json'),
    #                 scrollX = TRUE,
    #                 escape = T))
  }
  
  
  k <- reactive({
    bd() %>%
      mutate(ImpactoNorm = Impacto + (0.02 - min(Impacto)),
             FactibilidadNorm = Factibilidad + (0.02 - min(Factibilidad)), 
             ImpactoN = Impacto + (0.02 - min(Impacto)),
             FactibilidadN = Factibilidad + (0.02 - min(Factibilidad))) %>%
      st_as_sf(coords = c("ImpactoNorm", "FactibilidadNorm"))
    
  })
  
  
  output$datatable2 <- function(){
    k() %>% 
      as_tibble() %>% 
      select(Title,ImpactoN,FactibilidadN) %>% 
      kablam()
    
  #   DT::renderDataTable({
  #   
  #   DT::datatable(k() %>% as_tibble() %>% select(Title,ImpactoN,FactibilidadN) , 
  #                 extensions = 'FixedColumns',
  #                 rownames= FALSE,
  #                 options = list(
  #                   pageLength = 5,
  #                   language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json'),
  #                   scrollX = TRUE,
  #                   escape = T))
  # })
  
  }
  
  
  output$plot <- renderLeaflet({
    
    k <- k()    
    
    puntos <- tibble(x = c(0,0.5,0), y = c(0,0,0.5)) %>% 
      st_as_sf(coords = c("x", "y")) 
    
    l1 <- st_linestring(x = rbind(st_coordinates(puntos[1,"geometry"]), 
                                  st_coordinates(puntos[2,"geometry"])))
    
    l2 <- st_linestring(x = rbind(st_coordinates(puntos[1,"geometry"]), 
                                  st_coordinates(puntos[3,"geometry"])))
    
    content <- c("Factibilidad", "Impacto")
    
    leaflet(puntos) %>% 
      addCircleMarkers() %>% 
      addPopups(c(0,0.5), c(0.5,0), popup = content,
                options = popupOptions(closeButton = FALSE)) %>% 
      addCircleMarkers(data = k, 
                       label = lapply(paste("<b>Propuesta:</b>", k$Title, "<br>", 
                                            "<b>Impacto:</b>", prettyNum(k$ImpactoN, digit = 4), "<br>",
                                            "<b>Factibilidad:</b>", prettyNum(k$FactibilidadN, digit = 4), "<br>"), htmltools::HTML), 
                       color = "red") %>% 
      addPolylines(data = l1, opacity = 1) %>% 
      addPolylines(data = l2, opacity = 1) %>%
      addCircleMarkers(data = pointo(), color = "green") %>% 
      addLegend(position = "bottomright", colors = c("red", "green"), labels = c("Puntos de la sesión", "Punto de control<br>para sacar coordenadas"))
    
  })
  
  # point <- reactive({
  #   punto <- tibble(y = pol_of_click$lat, x = pol_of_click$lng) %>% 
  #     st_as_sf(coords = c("x", "y")) 
  # })
  
  
  pointo <- reactive({
    punto <- tibble(y = input$numImpacto, x =input$numFactibilidad) %>%
      st_as_sf(coords = c("x", "y"))
  })
  
  observe({
    if(is.null(input$plot_click)){
      
    } else {
      
      observeEvent(input$plot_click,
                   {
                     pol_of_click <- input$plot_click
                     print(pol_of_click)
                     updateNumericInput(session, "numImpacto",      value = pol_of_click$lat)
                     updateNumericInput(session, "numFactibilidad", value = pol_of_click$lng)
                     # Función para calcular las distancias. 
                     
                     # point <- reactive({
                     #   punto <- tibble(y = pol_of_click$lat, x = pol_of_click$lng) %>% 
                     #     st_as_sf(coords = c("x", "y")) 
                     # })               
                     # 
                     # dist <- reactive({
                     #   longitud <- distancia(X = pol_of_click$lng, Y = pol_of_click$lat) 
                     # })
                     # updateNumericInput(session, "numDistancia", value = formatC(dist(), 5))
                   })
    }
  })
  
  
  
}

# Complete app with UI and server components
shinyApp(ui, server)
