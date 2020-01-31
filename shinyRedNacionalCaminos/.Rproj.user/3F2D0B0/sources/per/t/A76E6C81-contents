# Pos-procesamiento de bds
# Sugerencia de Juan Javier Santos Ochoa

library(purrr)

nombres <- list.files("www/BasesDeDatosCompletas")
abreviar <- function(i){ 
bd2 <- readRDS(paste0("www/BasesDeDatosCompletas/", i)) %>% 
  select(-c("AREA","PERIMETER","COV_","COV_ID","ID_RED",
            "ESTATUS","UNION_INI","UNION_FIN","LONGITUD","ANCHO","FECHA_ACT", "ESCALA_VIS", 
            "NIVEL","PEAJE","ADMINISTRA","JURISDI","CIRCULA","CALIREPR", 
            "CODIGO", "CAPITAL", "CVE_EDO")) %>% 
  saveRDS(paste0("www/BasesDeDatosAbreviadas/", i))
}

# Mi primer Purrr
purrr::map(nombres, abreviar)
