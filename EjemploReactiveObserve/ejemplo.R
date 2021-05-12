library(shiny)


# INTERFAZ DE USUARIO. 
ui<-
  # Interfaz en un layout fluído.
  fluidPage(
    # Renglón fluído: Nos da 12 columnas para acomodar a nuestro gusto los elementos de la interfaz de usuario. 
    fluidRow(
      # Utilizamos las primeras cuatro columnas para acomodar controles.
      column(4,
             # Probamos la función `reactive()`
             h2("Reactive Test"), # Título de nivel 2
             textInput("Test_R","Test_R"),
             textInput("Test_R2","Test_R2"),
             textInput("Test_R3","Test_R3"),
             tableOutput("React_Out")
      ),
      column(4,
             # Probamos el funcionamiento de la función `observe()`
             h2("Observe Test"),  # Título de nivel 2
             textInput("Test","Test"),
             textInput("Test2","Test2"),
             textInput("Test3","Test3"),
             tableOutput("Observe_Out")
      ),
      column(4,
             # Probamos el funcionamiento de la función `observeEvent()`
             h2("Observe Event Test"),  # Título de nivel 2 (subtítulo)
             textInput("Test_OE","Test_OE"), 
             textInput("Test_OE2","Test_OE2"),
             textInput("Test_OE3","Test_OE3"),
             tableOutput("Observe_Out_E"),
             actionButton("Go","Test") # Botón de acción. 
      )
      
    ), # Fin del primer renglón fluido. 
    
    # Inicio del segundo renglón fluido. 
    fluidRow(
      column(8, # Utilizamos 8 de las 12 columnas disponibles. 
          # Metemos un título de nivel 4 con trocitos de texto formateado con la clase código.
          h4("Notese que ", code("observe"), " y ", code("reactive"), " funcionan muy parecido en la superficie; es cuando
          observamos bien el código en el ", code("server"), " donde se ven las diferencias.")
      ))
    )


# SERVIDOR. 
server<-function(input,output,session){
  
  # NOTA DEL AUTOR ORIGINAL. -REACTIVE-
  # Create a reactive Evironment. Note that we can call the variable outside same place
  # where it was created by calling Reactive_Var(). When the variable is called by
  # renderTable is when it is evaluated. No real diffrence on the surface, all in the server.
  
  # Recordemos que reactive sirve para generar objetos intermedios que van a ir a parar 
  #   a un objeto final. 
  Reactive_Var<-reactive({ # Creamos un entorno reactivo. 
    
    # Generamos un vector con el contenido de los textInputs de la primera columna.
    c(input$Test_R, input$Test_R2, input$Test_R3)
    })
  
  # Como lo guardamos en la lista output, es un elemento final. 
  # Vamos a generar una tabla a partir del vector intermedio creado arriba. 
  output$React_Out<-renderTable({ # Creamos un entorno reactivo. 
    
    Reactive_Var()
  })
  
  # NOTA DEL AUTOR. - OBSERVE-
  # Create an observe Evironment. Note that we cannot access the created "df" outside 
  # of the env. A, B,and C will update with any input into any of the three Text Fields.
  
  # Generamos nuestro observador
  observe({ # Creamos un entorno reactivo. 
    
    A<-input$Test # Guardamos en la variable A el contenido del control Test de la columna 2
    B<-input$Test2 # Guardamos en la variable B el contenido del control Test2 de la columna 2
    C<-input$Test3 # Guardamos en la variable C el contenido del control Test2 de la columna 2
    
    # Nota de los observers: 
    # Los observe() son similares a la funcion reactive(). Una de las diferencias es que las expresiones
    # dentro de un observe() estan monitoreando siempre cambios en sus dependencias. En este caso, 
    # el código dentro de este observe se va a re-evaluar cada que haya un cambio en cualquiera de los
    # input$Tests
    
    # Generamos un vector con los valores de estas tres entradas de texto. 
    df<-c(A,B,C)
    
    # Renderizamos la tabla dentro del observe. 
    output$Observe_Out<-renderTable({df})
  })
  
  #We can change any input as much as we want, but the code wont run until the trigger
  # input$Go is pressed.
  observeEvent(input$Go, # Detonador. 
               { # Creamos un entorno reactivo. 
    # Hacemos lo mismo que dentro del Observe
    A<-input$Test_OE
    B<-input$Test_OE2
    C<-input$Test_OE3
    df<-c(A,B,C)
    output$Observe_Out_E<-renderTable({df})
  })
  
}

# Corremos la aplicación. 
shinyApp(ui, server)

