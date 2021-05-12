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

#UI
ui = shinyUI(fluidPage(
  titlePanel("Generar paletas desde una imagen"),
  sidebarLayout(
    sidebarPanel(
      fileInput(inputId = 'files',
                label = 'Seleccione una imagen',
                multiple = TRUE,
                accept=c('image/png', 'image/jpeg'))
    ),
    mainPanel(
      # tableOutput('files'),
      # textOutput("text"),
      uiOutput('images', width = "100%")
    )
  )
))

#Servidor
server = shinyServer(function(input, output) {

  # Generaación de tabla de archivos
  img <- reactive({
      a = load.image(str_c(files()$datapath)) %>%
        as.data.frame()
      print(a)
  })

  # output$files <- renderTable(
  #   img()
  # )

  # Generamos un objeto reactivo
  files <- reactive({
    # Files va a guardar los datos del upload
    files <- input$files
    print(str_c("files: ", files))
    # Quitamos cosas a la linea de los archivos (corregimos las rutas)
    files$datapath <- gsub("\\\\", "/", files$datapath)
    # print(str_c("files$datapath: ", files$datapath))
    files # Objeto que contiene datos de la imagen subida

    # print(files$datapath)
  })

  # datapath = reactive({
  #   files()
  # })
  #
  # output$text <- renderText({
  #   datapath()
  # })


  output$images <- renderUI({

    # Lista de imagenes de salida
    image_output_list <-
      # Para todos los elementos del objeto files()
      lapply(seq_along(nrow(files())),
             function(i)
             {
               # Se guarda en una carpeta llamada "images"
               imagename = paste0("image", i)
               # Programamos el Output
               imageOutput(imagename)
             })

    # print(image_output_list)
    # Generamos el TAG y lo renderizamos como tal
    do.call(tagList, image_output_list)
    # print(str_c("AAA: ", do.call(tagList, image_output_list)))
    # <div id=\"image1\" class=\"shiny-image-output\" style=\"width:100%;height:400px;\"></div>
  })

  observe({
    for (i in seq_along(nrow(files())))
    {
      local({
        my_i <- i
        imagename = paste0("image", my_i)
        # print(imagename)
        output[[imagename]] <-
          renderImage({
            list(src = files()$datapath[my_i],
                 alt = "No se pudo generar la imagen")
          }, deleteFile = FALSE)
      })
    }
  })

})

# App
shinyApp(ui = ui, server = server)
