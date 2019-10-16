# Setup
Sys.setlocale("LC_ALL", "es_ES.UTF-8")

# Checar si esta instalado Pacman
if (!require("pacman")) install.packages("pacman")

# Librerias
pacman::p_load("tidyverse",
               "shinydashboard",
               "leaflet",
               "shinycssloaders",
               "stringr"
               )

# Mis funciones propias
niveles <- function(x) levels(as.factor(x)) # Saca las categorias de un vector cualquiera!
specify_decimal <- function(x, k) trimws(format(round(x, k), nsmall=k)) # Redondea a un decimal dado!
myLabelFormat = function(..., reverse_order = FALSE){
  if(reverse_order){
    function(type = "numeric", cuts){
      cuts <- sort(cuts, decreasing = T)
    }
  }else{
    labelFormat(...)
  }
}

# Leemos base de datos
bd <- readRDS("www/Mapa_municipios.rds")
