# Librerias necesarias para que corra el programa
library(shiny)
library(wordcloud2)
library(tm)
library(colourpicker)
library(RColorBrewer)

# Cambiamos el locale (esto es necesario en computadoras Mac)
Sys.setlocale("LC_ALL", 'en_US.UTF-8')

a <- read.delim("principito.txt", encoding = "UTF-8", stringsAsFactors = T)
names(a) <- "Texto"
a$Texto <- as.character(a$Texto)

# Funcion para romper cadenas de texto
romper <- function(string, patron = ", "){
  string <- stringr::str_replace(string, pattern = " y ", replacement = patron)
  string <- strsplit(string, patron)
  string <- as.vector(string)
  return(string)
}

# Funcion para crear el wordcloud
create_wordcloud <- function(data, num_words = 100, background = "white", stop_words, mask = NULL) {
  # Pre-Función para eliminar simbolos raros
  quitar_signos <- function(x)  stringr::str_remove_all(x, pattern = rebus::char_class("¿¡"))
  
  # If text is provided, convert it to a dataframe of word frequencies
  # Si se provee el texto, convertirlo a un dataframe de frecuencia de palabras 
  if (is.character(data)) {
    # Convertimos a Corpus
    corpus <- Corpus(VectorSource(data))
    # Convertimos el texto dentro del Corpus a Minusculas
    corpus <- tm_map(corpus, tolower)
    # Removemos la puntuacion (.,-!?)
    corpus <- tm_map(corpus, removePunctuation)
    # Removemos los numeros
    corpus <- tm_map(corpus, removeNumbers)
    # Removemos los signos de admiracion e interrogacion al reves
    corpus <- tm_map(corpus, quitar_signos)    
    # Removemos las stopwords (palabras muy muy comunes que se usan para dar coherencia
    # a las oraciones. Para saber cuales, escribir: stopwords("spanish))
    corpus <- tm_map(corpus, removeWords, c(stopwords("spanish"), stop_words))
    # Generamos una matriz para hacer el conteo
    tdm <- as.matrix(TermDocumentMatrix(corpus))
    # Obtenemos el numero de la frecuencia de cada palabra
    data <- sort(rowSums(tdm), decreasing = TRUE)
    # Generamos una tabla con la palabra en una columna y su frecuencia de uso en otra 
    data <- data.frame(word = names(data), freq = as.numeric(data))
  }
  
  # Make sure a proper num_words is provided
  # Nos aseguramos que un numero adecuado de palabras `num_provider` es generado`
  if (!is.numeric(num_words) || num_words < 3) {
    num_words <- 3
  }  
  
  # Grab the top n most common words
  # Recortamos la base de datos de palabras a un numero `n` especificado
  data <- head(data, n = num_words)
  if (nrow(data) == 0) {
    return(NULL)
  }
  wordcloud2(data, backgroundColor = background, figPath = mask,  color = "random-light", size = 1.5) 
}

#######################
# UI - User Interface #
######################

# Generamos el UI - La pagina web donde el usuario va a interactuar con el programa.
ui <- fluidPage(
  # 1. Titulo
  h1("Word Cloud"),
  # 2. Plantilla del panel lateral izquierdo
  sidebarLayout(
    # 2.1 Creacion del panel lateral izquierdo
    sidebarPanel(width = 4,
                 # 2.1.1 Seleccionador de la fuente de los datos
                 radioButtons(
                   inputId = "source",
                   label = "Texto a analizar",
                   choices = c(
                     "El Principito" = "book",
                     "Escribe tu propio texto" = "own",
                     "Cargar un archivo externo" = "file"
                   )
                 ),
                 
                 # 2.1.1.1 Panel condicional; se crea si el usuario quiere escribir su propio texto.
                 conditionalPanel(
                   condition = "input.source == 'own'",
                   textAreaInput("text", "Introduzca texto", rows = 7)
                 ),
                 
                 # 2.1.1.2 Panel condicional; se crea si el usuario quiere subir un archivo.
                 conditionalPanel(
                   condition = "input.source == 'file'",
                   fileInput("file", "Seleccione un archivo (*.txt)")
                 ),
                 
                 # 2.1.2 Entrada numerica del maximo numero de palabras en la nube de texto.
                 numericInput("num", "Maximo numero de palabras en la WordCloud",
                              value = 100, min = 5),
                 
                 # 2.1.3 Seleccion del color de fondo.
                 colourInput("col", "Color de Fondo", value = "white"),
                 
                 # Add a "draw" button to the app
                 # Agregar un boton de dibujo de la WordCloud
                 actionButton(inputId = "draw", label = "Graficar!")
    ),
    
    # 3. Panel Principal
    mainPanel(width = 8,
              # 3.1 Contenido del panel principal!
              wordcloud2Output("cloud", height = "600px", width = "1200px")
    )
  ),
  br(),
  wellPanel(h4("Opciones Adicionales"), 
            textInput("newStopWords", "Introduzca palabras a eliminar (separadas por un espacio)")
            # # OPCIONES ADICIONALES EN BETA
            # ,
            # radioButtons(
            #   inputId = "forma",
            #   label = "Forma de la WordCloud",
            #   choices = c(
            #     "Forma de Texto" = "texto",
            #     "Forma de Figura" = "imagen"), 
            #   selected = 'texto'
            # ),
            # 
            # conditionalPanel(
            #   condition = "input.forma == 'texto'",
            #   textInput("Palabras", "Darle forma de texto a la nube")
            # ),
            # 
            # conditionalPanel(
            #   condition = "input.forma == 'imagen'",
            #   fileInput("image", "Seleccione una imágen (La imagen tiene que ser formato .*png)")
            # )
            
  )
  
) # Fin del UI 

##########
# Server #
#########

# Generamos el server; el conjunto de codigos que crean el contenido de la aplicacion 
# y donde se hacen los calculos.

server <- function(input, output) {
  
  data_source <- reactive({
    if (input$source == "book") {
      data <- a$Texto
    } else if (input$source == "own") {
      data <- input$text
    } else if (input$source == "file") {
      data <- input_file()
    }
    return(data)
  })
  
  input_file <- reactive({
    if (is.null(input$file)) {
      return("")
    }
    readLines(input$file$datapath)
  })
  
  # Palabra 
  pal_forma <- reactive({
    if(is.null(input$Palabras)){
      palabra <- NULL
    } else {
      palabra <- input$Palabras
    }
  })
  
  # STOPWORDS
  stp_wrd <- reactive({
    if(is.null(input$newStopWords)){
      stop_words <- c()
    } else {
      stop_words <- input$newStopWords
    }
    stop_words <- romper(stop_words, patron = " ")[[1]]
    return(stop_words)
  })
  
  #mascara <- "APP.png"
  
  output$cloud <- renderWordcloud2({
    # Add the draw button as a dependency to
    # cause the word cloud to re-render on click
    input$draw
    isolate({
      create_wordcloud(data_source(), num_words = input$num,
                       background = input$col, stop_words = stp_wrd()#, mask = mascara
      )
      #, palabra = input$Palabras
    })
  })
}

shinyApp(ui = ui, server = server)
