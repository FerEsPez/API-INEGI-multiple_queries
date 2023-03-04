rm(list = ls())

options(scipen = 9999, digits = 1)

pacman::p_load(tidyverse, httr, jsonlite)
#Generamos los vectores con la llave de la API del INEGI
key="a5f9df25-64cc-22f5-597a-4887e8513141"

#Un vector con las localidades que queremos llamar (0700 es nacional)
localidades <- c("07000001","07000002","07000003","07000004","07000005","07000006","07000007","07000008","07000009","07000010",
                 "07000011","07000012","07000013","07000014","07000015","07000016","07000017","07000018","07000019","07000020",
                 "07000021","07000022","07000023","07000024","07000025","07000026","07000027","07000028","07000029","07000030",
                 "07000031","07000032")
#Llamamos a los códigos de la API (los códigos de las variables) que vamos a ocupar.
#En este caso los dividimos en 2 bloques ya que a partir del código número 13, comienza a a dar problemas.
#Es recomendable llamar variables en bloques de 10.

B1I <- "6200032080,6200032081,6200032082,6200032083,6200032084,6200032085,6200032086,6200032087,6200032088,6200032089,6200032090,6200032091"
B2I<-  "6200032092,6200032093,6200032094,6200032095,6200032096,6200032097,6200032098,6200032099"

#Generamos un vector con los metadatos de cada una de las localidades
#Los datos"
#Llamamos a los metadatos de la información para los dos bloques.

urlMetO1 <- paste0("https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/CL_INDICATOR/",B1I,"/es/BISE/2.0/",
                   key,"?type=json")

urlMetO2 <- paste0("https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/CL_INDICATOR/",B2I,"/es/BISE/2.0/",
                   key,"?type=json")


metaOcup1 <- GET(urlMetO1)

metaOcup2 <- GET(urlMetO2)

#Generamos los vectores con la metadata
OcupaMeta <- content(metaOcup1, as = 'text')%>%
  fromJSON()%>%
  pluck("CODE")

OcupaMeta2 <- content(metaOcup2, as = 'text')%>%
  fromJSON()%>%
  pluck("CODE")

#Mediante un loop, generamos los metadatos de cada una de las localidades y los guardamos en un solo dataframe.

GeogMeta <- data.frame()

for (i in localidades) {
  
  GeoMetadata <- paste0("https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/CL_GEO_AREA/",i,"/es/BISE/2.0/",
                        key,"?type=json")
  
  metaGeo1 <- GET(GeoMetadata)
  
  GeoMeta <- content(metaGeo1, as = 'text')%>%
    fromJSON()%>%
    pluck("CODE")
  
  GeogMeta <- rbind(GeoMeta,GeogMeta)
  
}

colnames(GeogMeta) <- c("Cobertura_Geografica", "Entidad")


#Mediante un loop, llamamos a la información, generando URLS para cada una de las localidades y uniendolos en una sola base.
#Esto lo hacemos para los 2 bloques
#Bloque 1: 

ocupado <- data.frame()

for (i in localidades) {
  urlOcupa <- paste0("https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/",B1I,"/es/",i,"/false/BISE/2.0/",
                     key,"?type=json")
  resmetOcup <- GET(urlOcupa)
  
  COMPAACTIVO <-content(resmetOcup, as = 'text')%>%
    fromJSON()%>%
    pluck("Series")
  
  for (j in unique(COMPAACTIVO$INDICADOR)) {
    
    filtro <-  COMPAACTIVO %>% filter( INDICADOR == j)
    
    Data <- (filtro %>% pluck("OBSERVATIONS"))[[1]]
    Data$indicador <- j
    ocupado <- rbind(ocupado,Data) 
    
  }
  
}

#Bloque 2 : 

ocupado2 <- data.frame()

for (i in localidades) {
  urlOcupa2 <- paste0("https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/",B2I,"/es/",i,"/false/BISE/2.0/",
                      key,"?type=json")
  resmetOcup2 <- GET(urlOcupa2)
  
  COMPAACTIVO <-content(resmetOcup2, as = 'text')%>%
    fromJSON()%>%
    pluck("Series")
  
  for (j in unique(COMPAACTIVO$INDICADOR)) {
    
    filtro2 <-  COMPAACTIVO %>% filter( INDICADOR == j)
    
    Data2 <- (filtro2 %>% pluck("OBSERVATIONS"))[[1]]
    Data2$indicador <- j
    ocupado2 <- rbind(ocupado2,Data2) 
    
  }
  
}

#Cambiamos los nombres de los dataframes

colnames(ocupado) <- c("Anio","Valor",
                       "OBS_EXCEPTION", "OBS_STATUS", "OBS_SOURCE", "OBS_NOTE",
                       "Cobertura_Geografica","Indicador")
colnames(ocupado2) <- c("Anio","Valor",
                        "OBS_EXCEPTION", "OBS_STATUS", "OBS_SOURCE", "OBS_NOTE",
                        "Cobertura_Geografica","Indicador")

colnames(OcupaMeta) <- c("Indicador","Nombre_Indicador")
colnames(OcupaMeta2) <- c("Indicador","Nombre_Indicador")


i2 <- merge(ocupado, OcupaMeta, by = "Indicador" )
i3 <- merge(ocupado2, OcupaMeta2, by = "Indicador" )

final <- merge(rbind(i2,i3) ,GeogMeta, by = "Cobertura_Geografica")

#------------- Manipulación de base de datos -------------

pacman::p_load(dplyr,tidyr,stringr,writexl,sf)

#Llamamos la base de datos

df <- final

#Eliminamos las columnas que no nos sirven

colnames(df)

df <- df[ ,c(-1:-2,-5:-8)]

#Separamos la fecha en Anio y mes

df <- df %>% separate(Anio, c('Anio', 'Trimestre'))

#Convertimos los valores de Trimestre en valores de tipo character.

df$Trimestre[df$Trimestre=="01"] <- "I"
df$Trimestre[df$Trimestre=="02"] <- "II"
df$Trimestre[df$Trimestre=="03"] <- "III"
df$Trimestre[df$Trimestre=="04"] <- "IV"


#Cambiamos las columnas con valores numéricos a numeros enteros

df[,c(1,3)] <- lapply(df[,c(1,3)], as.integer)

#Realizamos una serie de separaciones para tener columnas de "Sexo", "Edad", "Salario" e "Indicador"
#Todo esto extraido de la columna inicial "Nombre_Indicador".
#Después de separar, rellenamos los valores nulos (o vacíos) con el valor restante segun el caso.


df <- df %>% separate(Nombre_Indicador, c("Nombre_Indicador","Sexo"), sep = ",")

df <- df %>% separate(Nombre_Indicador, c("Nombre_Indicador","Edad"), sep = "-")

df <- df %>% separate(Nombre_Indicador, c("Nombre_Indicador","Salario"), sep = "con")

df$Nombre_Indicador <- "Población ocupada con "

df <- df %>% unite("Indicador", c(Nombre_Indicador,Edad), remove = TRUE, sep = "")

df$Salario <- gsub(" ingresos de ",'',df$Salario)

df$Sexo <- df$Sexo %>% replace_na("Total")

df$Salario <- df$Salario %>% replace_na("No recibe ingresos")

#Funcion para convertir en Mayusculas la primer letra de cada palabra.

df$Salario <- str_to_title(df$Salario) 


### Por ultimo, agregamos las coordenadas geográficas a la base.

#Llamamos al archivo .shape

Entidades <- read_sf("México_Estados.shp")

#Eliminamos las columnas que no sirven.

Entidades <- Entidades[,c(-1)]

#Cambiamos el nombre de la columna
colnames(Entidades)[1] <- c("Entidad")

#Entidades <- as.data.frame(Entidades$NOM_ENT)

#LatLong <- data.frame(lon = coordinates(Coordenadas)[,1], lat = coordinates(Coordenadas)[,2])
#Geograf <- cbind(Entidades,LatLong)
#colnames(Geograf) <- c("Entidad","Latitud","Longitud")

#Verificamos que los nombres coincidan

colnames(df)
Entidades$Entidad
unique(df$Entidad)

#Cambiamos los nombres que no coinciden

df$Entidad[df$Entidad=="Coahuila de Zaragoza"] <- "Coahuila"
Entidades$Entidad[Entidades$Entidad=="Distrito Federal"] <- "Ciudad de México"
df$Entidad[df$Entidad=="Michoacán de Ocampo"] <- "Michoacán"
df$Entidad[df$Entidad=="Veracruz de Ignacio de la Llave"] <- "Veracruz"

#Hacemos un merge de las bases que contienen las coordenadas y la base con la información
dff <- merge(df,Entidades, by= "Entidad")

#Se guarda el archivo en .shape para que puedan generarse mapas con facilidad en cualqueir software
#Se guarda también en formato excel para darle distintos usos (no se guardan la variable de geometry)

write_sf(dff, "EntidadesMex.shp")
write_xlsx(dff,"EntidadesMex.xlsx")
