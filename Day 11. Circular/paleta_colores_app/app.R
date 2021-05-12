# # Librerias ----
library(shiny)
library(imager)
library(tidyverse)
library(kableExtra)
library(here)
library(extrafont)
library(ggtext)
library(magick)
library(TSP)
#
# # Funciones ----
#
# # Función para ordenar colores
# orden_color = function(my_colours){
#     rgb <- col2rgb(my_colours)
#     tsp <- as.TSP(dist(t(rgb)))
#     sol <- solve_TSP(tsp, control = list(repetitions = 1e3))
#     ordered_cols <- my_colours[sol]
#     return(ordered_cols)
# }
#
# # Funcion para saber si el color es muy oscuro ----
# isDark <- function(colr) { (sum( col2rgb(colr) * c(299, 587,114))/1000 < 123) }
#
# # Función para leer una imagen ----
# img_wide <- load.image("acnh.png") %>%
#     as.data.frame() %>%
#     mutate(channel = case_when(
#         cc == 1 ~ "Red",
#         cc == 2 ~ "Green",
#         cc == 3 ~ "Blue")) %>%
#     select(x, y, channel, value) %>%
#     spread(key = channel, value = value) %>%
#     mutate(color = rgb(Red, Green, Blue))
#
# # Angulo del texto ----
# grados <- function(x){
#     x = 1:10
#     y = length(x)
#     grados = 360-(360/(2*y))-((360*(x-1))/(y))
#     return(grados)
#     }
#
# # Tamaño de muestra ----
# sample_size <- 10000
# img_sample <- img_wide[sample(nrow(img_wide), sample_size), ]
# img_sample$size <- runif(sample_size)
#
# img_1 = img_sample %>%
#     group_by(color) %>%
#     count()
#
# colores = tibble(cols = sample(img_1$color, 100),
#                  grupo = rep(1:10, 10)) %>%
#     arrange(-grupo) %>%
#     group_by(grupo) %>%
#     mutate(cols = orden_color(cols)) %>%
#     ungroup() %>%
#     mutate(id = rep(1:10, 10))
#
# colores$isDark = sapply(colores$cols, isDark)
#
# # Angulo del texto ----
# angulos = tibble(grupo = 1:10,
#                  angulo = rev(c(
#                      378,#1
#                      414,  #2
#                      90, #3
#                      126, #4
#                      162, #5
#                      198, #6
#                      234, #7
#                      270, #8
#                      306, #9
#                      342))) #10
#
# colores2 = left_join(colores, angulos)
#
# # Grafica final ----
# colores2 %>%
#     ggplot(aes(x = grupo, y = id)) +
#     geom_tile(fill = colores$cols) +
#     geom_text(aes(label = cols),
#               color = ifelse(colores2$isDark,
#                              "white",
#                              "black"),
#               size = 3,
#               family = "Poppins",
#               angle = colores2$angulo) +
#     labs(title = "Distribución de colores a partir de una imagen.",
#          subtitle = "#30DayChartChallenge - Día 11 - Distribuciones + Circular") +
#     scale_x_continuous(breaks = 1:10) +
#     coord_polar() +
#     ylim(-5,11) +
#     theme_void() +
#     theme(plot.subtitle = element_text(color = "black", family = "Poppins", hjust = 0.5),
#           plot.title = element_text(color = "navyblue", family = "Poppins", hjust = 0.5, face = "bold"))
#
#


# Interfaz de usuario ----
ui <- fluidPage(


    titlePanel("Paletas de colores desde imagen"),

    sidebarLayout(
        sidebarPanel(
            p("Panel"),
            fileInput(inputId = 'files',
                      label = 'Select an Image',
                      multiple = TRUE,
                      accept=c('image/png', 'image/jpeg')),
        ),

        mainPanel(
           p("Background"),
           uiOutput("renderImg")
        )
    )
)

# Servidor ----
server <- function(input, output) {

output$renderImg <- renderUI({
    print(input$files$datapath)

    HTML(str_c("<img src = '",
               input$file1$datapath,
               "'>"))

        # tryCatch(
        #             {
        #                 img_up <- load.file(input$file$datapath)
        #             },
        #             error = function(e) {
        #                 # return a safeError if a parsing error occurs
        #                 stop(safeError(e))
        #             }
        #         )
                })

    # str_c("<img src = ", img_up)


}

# Run the application
shinyApp(ui = ui, server = server)
