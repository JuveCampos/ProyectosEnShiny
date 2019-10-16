#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# CHUNK 1 El minimo viable
####################################################

# shinyUI({
#   head <- dashboardHeader()
#   side <- dashboardSidebar()
#   body <- dashboardBody()
#
#   dashboardPage(header = head,
#                 sidebar = side,
#                 body = body,
#                 title = "Titulo",
#                 skin = "yellow"
#                 )
# })

# CHUNK 2 / Todo menos el body
####################################################
# shinyUI({
#   head <- dashboardHeader(title = "Mi primer shiny",
#                           titleWidth = 350,
#                           # Aniadimos una imagen en el encabezado
#                           tags$li(a(href = 'https://www.cide.edu',
#                                     img(src = 'https://www.cide.edu/wp-content/themes/cide_general/img/logo_cide.png',
#                                         title = "CIDE", height = "30px"),
#                                     style = "padding-top:10px; padding-bottom:10px;"),
#                                   class = "dropdown"))
#   side <- dashboardSidebar(
#     width = 350,
#     sidebarMenu(
#       menuItem("Introducción", tabName = "INTRO")
#     )
#   )
#   body <- dashboardBody()
#
#   dashboardPage(header = head,
#                 sidebar = side,
#                 body = body,
#                 title = "Titulo",
#                 skin = "yellow"
#                 )
# })

# CHUNK 3 / EL BODY ESTATICO
####################################################
shinyUI({
  head <- dashboardHeader(title = "Mi primer shiny",
                          titleWidth = 350,
                          # Aniadimos una imagen en el encabezado
                          tags$li(a(href = 'https://www.cide.edu',
                                    img(src = 'https://www.cide.edu/wp-content/themes/cide_general/img/logo_cide.png',
                                        title = "CIDE", height = "30px"),
                                    style = "padding-top:10px; padding-bottom:10px;"),
                                  class = "dropdown"))
  side <- dashboardSidebar(
    width = 350,
    sidebarMenu(
      menuItem("Resultados Municipales", tabName = "MUNI")
    )
  )



body <- dashboardBody(
  # Metemos la hoja de estilo en forma de Archivo .css
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "estilos.css")
    ),

  tabItems(
    tabItem("MUNI",
            h1("Resultados municipales"),
            p("En esta sección se puede consultar el desempeño de los municipios en el ejercicio de la Métrica de
              Gobierno Abierto 2019. Al seleccionar un municipio, se muestra la ficha de información con los resultados
              obtenidos en el Índice de Gobierno Abierto y en sus principales dimensiones, así como un mapa estatal que
              muestra los municipios considerados en el estudio."),
            HTML("<p class='em'>Sólo se tiene información para los municipios incluidos en la muestra de la Métrica de Gobierno Abierto 2019.<p>"),
            box(title = 'Seleccionar criterios para la consulta de información', status = 'warning', solidHeader = TRUE, width = 1000,
                selectInput("selSolEstado3", label = "Estado", choices = niveles(bd$NOM_ENT),
                            selected =niveles(bd$NOM_ENT)[1])
                ,
                uiOutput("selSolSORender2")
            ),
        fluidPage(
              fluidRow(
                column(12,
                       box(title = "Resultados municipales", status = 'warning', solidHeader = TRUE, width = 100,
                           tabsetPanel(
                             tabPanel("Municipios del estado considerados en la Métrica 2019", shinycssloaders::withSpinner(leafletOutput("mapa_mpal", height = 500)))
                           )
                       )
                )
              )
            )
    )
  )
)

  dashboardPage(header = head,
                sidebar = side,
                body = body,
                title = "Titulo",
                skin = "black"
  )
})


