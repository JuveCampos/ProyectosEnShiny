
library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    fluidRow(
        column(3, offset = 5, h1("Población por estado"))
    ), 
    
    fluidRow(
        column(4, 
               selectInput(inputId = "selEstado", 
                           label = "Seleccione Estados", 
                           choices = levels(as.factor(mapa$NOM_ENT))
                           )
               )
    ), 
    
    fluidRow(
        column(8, offset = 2, 
               leafletOutput("mapa", height = "500px")
               )
       )
    )
)
