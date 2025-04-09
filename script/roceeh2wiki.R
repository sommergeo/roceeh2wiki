library(tidyverse)
library(sf)
library(RPostgreSQL)
library(RPostgres)
library(jsonlite)
library(lubridate)
library(geojsonsf)
library(readxl)

#### Functions -----------------------------------------------------------------

# Connect to ROAD
con <- dbConnect(RPostgres::Postgres(), dbname = "roceeh", host="134.2.216.14", port=5432, user=rstudioapi::askForPassword("Database username"), password=rstudioapi::askForPassword("Database password"))

# Query function
road_query_culture <- function(culture, color='1e3283', size='small'){
  
  # Prepare query
  if(exists('culture')){
    # Load sql query template
    query_culture <- "SELECT DISTINCT on (archaeological_layer.locality_idlocality, archaeological_layer.archstratigraphy_idarchstrat, locality.x, locality.y) archaeological_layer.locality_idlocality, archaeological_layer.archstratigraphy_idarchstrat, locality.x, locality.y FROM archaeological_layer, locality WHERE (locality.idlocality = archaeological_layer.locality_idlocality and archaeological_layer.archstratigraphy_idarchstrat like '%s')"
    
    # Integrate query 
    query <- sprintf(query_culture, culture)
  }
  
  # Run the query
  dat <- dbGetQuery(con, query)
  
  # Rename columns
  dat <- dat %>% 
    rename(lon = x,
           lat = y,
           title = locality_idlocality) %>%
    select(-archstratigraphy_idarchstrat) %>% 
    arrange(title)
  
  # Add link to ROAD Summary Data Sheets
  dat <- dat %>% 
    mutate(description = paste0("[https://www.roceeh.uni-tuebingen.de/roadweb/tcpdf/localityInfoPDF/localityInfoPDF.php?locality=",
                               str_replace_all(title, " " ,"%20"),
                               " Summary Data Sheet]"),
           "marker-color" = color,
           "marker-size" = size)
    

  return(dat)
}

road_query_period <- function(period){
  
  # Prepare query
  if(exists('period')){
    # Load sql query template
    query_period <- "SELECT DISTINCT on (locality.idlocality, locality.x, locality.y) locality.idlocality, locality.x, locality.y FROM archaeological_layer, archaeological_stratigraphy, assemblage, locality WHERE (assemblage.locality_idlocality = locality.idlocality and archaeological_layer.locality_idlocality = assemblage.locality_idlocality and archaeological_stratigraphy.idarchstrat = archaeological_layer.archstratigraphy_idarchstrat and archaeological_stratigraphy.cultural_period like '%s')"
    
    # Integrate query 
    query <- sprintf(query_period, period)
  }
  
  # Run the query
  dat <- dbGetQuery(con, query)
  
  # Rename columns
  dat <- dat %>% 
    rename(lon = x,
           lat = y,
           title = idlocality) %>%
    arrange(title)
  
  # Add link to ROAD Summary Data Sheets
  dat <- dat %>% 
    mutate(description = paste0("[https://www.roceeh.uni-tuebingen.de/roadweb/tcpdf/localityInfoPDF/localityInfoPDF.php?locality=",
                                str_replace_all(title, " " ,"%20"),
                                " Summary Data Sheet]"),
           "marker-color" = '1e3283',
           "marker-size" = 'small')
  
  
  return(dat)
}

road_query_table <- function(table, desc=F, color='1e3283', size='small'){

  dat <- table %>% na.omit()
  dat <- dat %>% arrange(title)
  
  # Append ROAD Summary Data Sheet link
  if(desc==T){
    dat <- dat %>% 
      mutate(description = paste0("[https://www.roceeh.uni-tuebingen.de/roadweb/tcpdf/localityInfoPDF/localityInfoPDF.php?locality=",
                                  str_replace_all(title, " " ,"%20"),
                                  " Summary Data Sheet]"))

  }
  dat <- dat %>%  mutate( "marker-color" = color, "marker-size" = size)
  
  return(dat)
}

wiki_json <- function(df, commons_description = ' ') {
  # Head of JSON
  commons_license <- "CC-BY-SA-4.0"
  commons_source <- paste0("Data retrieved from the [https://www.roceeh.uni-tuebingen.de/roadweb ROCEEH Out Of Africa Database (ROAD)] on ", Sys.Date(), ".")
  
  # Geodata JSON
  df$lon <- round(df$lon, 3)
  df$lat <- round(df$lat, 3)
  
  # Create the spatial object using sf
  gdf <- st_as_sf(df, coords = c("lon", "lat"), crs = 4326)
  
  geojson <- sf_geojson(gdf)
  
  #geojson <- st_as_text(gdf)
  #geojson <- st_as_text(st_geometry(gdf))
  geojson <- fromJSON(geojson)
  
  # Add CRS to geojson
  geojson$crs <- list(
    type = "name",
    properties = list(
      name = "urn:ogc:def:crs:OGC:1.3:CRS84"
    )
  )
  
  # Merge head and geodata
  wikidict <- list(
    license = commons_license,
    description = fromJSON(commons_description),
    sources = commons_source,
    data = geojson
  )
  
  # Convert to JSON string
  wikistring <- toJSON(wikidict, pretty = TRUE, auto_unbox = TRUE, na = "null")
  
  return(wikistring)
}

# ESA
road_query_period('ESA') %>%
  wiki_json(commons_description = '{"en": "Selected Early Stone Age sites from the ROAD Database"}') %>%
  writeLines("output/Early Stone Age.json")

# MSA
road_query_period('MSA') %>%
  wiki_json(commons_description = '{"en": "Selected Middle Stone Age sites from the ROAD Database"}') %>%
  writeLines("output/Middle Stone Age.json")

# LSA
road_query_period('LSA') %>%
  wiki_json(commons_description = '{"en": "Selected Later Stone Age sites from the ROAD Database"}') %>%
  writeLines("output/Later Stone Age.json")

# Lower Paleolithic
road_query_period('Lower Paleolithic') %>%
  wiki_json(commons_description = '{"en": "Selected Lower Paleolithic sites from the ROAD Database"}') %>%
  writeLines("output/Lower Paleolithic.json")

# Middle Paleolithic
road_query_period('Middle Paleolithic') %>%
  wiki_json(commons_description = '{"en": "Selected Middle Paleolithic sites from the ROAD Database"}') %>%
  writeLines("output/Middle Paleolithic.json")

# Upper Paleolithic
road_query_period('Upper Paleolithic') %>%
  wiki_json(commons_description = '{"en": "Selected Upper Paleolithic sites from the ROAD Database"}') %>%
  writeLines("output/Upper Paleolithic.json")

# Acheulean
road_query_culture('%Acheule%') %>%
  wiki_json(commons_description = '{"en": "Selected Acheulean sites from the ROAD Database"}') %>%
  writeLines("output/Acheulean.json")

# Ahmarian
road_query_culture('Ahmarian') %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Ahmarien Fundstellen aus der ROAD Datenbank", "en": "Selected Ahmarian sites from the ROAD Database"}') %>%
  writeLines("output/Ahmarian.json")

# Aterian
road_query_culture('Aterian') %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Atérien Fundstellen aus der ROAD Datenbank", "en": "Selected Aterian sites from the ROAD Database"}') %>%
  writeLines("output/Aterian.json")

# Aurignacian
rbind(
  road_query_culture('Aurignacian'),
  road_query_culture('Proto-Aurignacian')) %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Aurignacien Fundstellen aus der ROAD Datenbank", "en": "Selected Aurignacian sites from the ROAD Database"}') %>%
  writeLines("output/Aurignacian.json")

# Chatelperronian
road_query_culture('Chatelperronian') %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Châtelperronien Fundstellen aus der ROAD Datenbank", "en": "Selected Châtelperronian sites from the ROAD Database"}') %>%
  writeLines("output/Chatelperronian.json")

# Early Upper Paleolithic
rbind(
  road_query_culture('Early Upper Paleolithic - E Asia'),
  road_query_culture('Early Upper Paleolithic - Eurasia')) %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Fundstellen des Early Upper Paleolithic aus der ROAD Datenbank", "en": "Selected Early Upper Paleolithic sites from the ROAD Database"}') %>%
  writeLines("output/Early Upper Paleolithic.json")

# Fauresmith
road_query_culture('Fauresmith') %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Fauresmith Fundstellen aus der ROAD Datenbank", "en": "Selected Fauresmith sites from the ROAD Database"}') %>%
  writeLines("output/Fauresmith.json")

# Gravettian
road_query_culture('Gravettian') %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Gravettien Fundstellen aus der ROAD Datenbank", "en": "Selected Gravettian sites from the ROAD Database"}') %>%
  writeLines("output/Gravettian.json")

# Howiesonspoort
road_query_culture('Howiesonspoort') %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Howiesonspoort Fundstellen aus der ROAD Datenbank", "en": "Selected Howiesonspoort sites from the ROAD Database"}') %>%
  writeLines("output/Howiesonspoort.json")

# Initial Upper Paleolithic
road_query_culture('Initial Upper Paleolithic - Eurasia') %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Fundstellen des Initial Upper Paleolithic aus der ROAD Datenbank", "en": "Selected Initial Upper Paleolithic sites from the ROAD Database"}') %>%
  writeLines("output/Initial Upper Paleolithic.json")

# Levantine Aurignacian
road_query_culture('Levantine Aurignacian') %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Fundstellen des levante-Aurignacien aus der ROAD Datenbank", "en": "Selected Levantine Aurignacian sites from the ROAD Database"}') %>%
  writeLines("output/Levantine Aurignacian.json")

# Micoquian
road_query_culture('Micoquian') %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Micoquien Fundstellen aus der ROAD Datenbank", "en": "Selected Micoquian sites from the ROAD Database"}') %>%
  writeLines("output/Micoquian.json")

# Mousterian
road_query_culture('%Mousterian%') %>%
  wiki_json(commons_description = '{"en": "Selected Mousterian sites from the ROAD Database"}') %>%
  writeLines("output/Mousterian.json")

# Proto-Aurignacian
road_query_culture('Proto-Aurignacian') %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Proto-Aurignacien Fundstellen aus der ROAD Datenbank", "en": "Selected Proto-Aurignacian sites from the ROAD Database"}') %>%
  writeLines("output/Proto-Aurignacian.json")

# Solutrean
road_query_culture('Solutrean') %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Solutréen Fundstellen aus der ROAD Datenbank", "en": "Selected Solutrean sites from the ROAD Database"}') %>%
  writeLines("output/Solutrean.json")

# Still Bay
road_query_culture('Still Bay') %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Still Bay Fundstellen aus der ROAD Datenbank", "en": "Selected Still Bay sites from the ROAD Database"}') %>%
  writeLines("output/Still Bay.json")

# Uluzzian
road_query_culture('Uluzzian') %>%
  wiki_json(commons_description = '{"de": "Ausgewählte Uluzzien Fundstellen aus der ROAD Datenbank", "en": "Selected Uluzzian sites from the ROAD Database"}') %>%
  writeLines("output/Uluzzian.json")

# Early fire use 
read_excel('input/Early fire.xlsx') %>% road_query_table(desc=T, color='f73718') %>% 
  wiki_json(commons_description = '{"en": "Selected sites with early human fire use from the ROAD Database"}') %>% 
  writeLines("output/Early fire.json")

# Ochre use 
read_excel('input/Ochre.xlsx') %>% road_query_table(desc=T, color='CC7722') %>% 
  wiki_json(commons_description = '{"en": "Selected sites with early human ochre use in Africa from the ROAD Database"}') %>% 
  writeLines("output/Ochre.json")

# Eyed needle
read_excel('input/Eyed needle.xlsx') %>% road_query_table(desc=T) %>% 
  wiki_json(commons_description = '{"en": "Selected sites with early human use of eyed needles from the ROAD Database"}') %>% 
  writeLines("output/Eyed needles.json")

# Sahelanthropus tchadensis
read_excel('input/Sahelanthropus tchadensis.xlsx') %>% road_query_table(desc=T) %>% 
  wiki_json(commons_description = '{"en": "Selected Sahelanthropus tchadensis sites from the ROAD Database"}') %>% 
  writeLines("output/Sahelanthropus tchadensis.json")

# Ardipithecus ramidus and kadaba
read_excel('input/Ardipithecus ramidus and kadaba.xlsx') %>% road_query_table(desc=T) %>% 
  wiki_json(commons_description = '{"en": "Selected Ardipithecus ramidus and A. kadaba sites from the ROAD Database"}') %>% 
  writeLines("output/Ardipithecus ramidus and kadaba.json")

# Australopithecus afarensis
read_excel('input/Australopithecus afarensis.xlsx') %>% road_query_table(desc=T) %>% 
  wiki_json(commons_description = '{"en": "Selected Australopithecus afarensis sites from the ROAD Database"}') %>% 
  writeLines("output/Australopithecus afarensis.json")

# Australopithecus africanus
read_excel('input/Australopithecus africanus.xlsx') %>% road_query_table(desc=T) %>% 
  wiki_json(commons_description = '{"en": "Selected Australopithecus africanus sites from the ROAD Database"}') %>% 
  writeLines("output/Australopithecus africanus.json")

# Paranthropus boisei
read_excel('input/Paranthropus boisei.xlsx') %>% road_query_table(desc=T) %>% 
  wiki_json(commons_description = '{"en": "Selected Paranthropus boisei sites from the ROAD Database"}') %>% 
  writeLines("output/Paranthropus boisei.json")

# Homo rudolfensis
read_excel('input/Homo rudolfensis.xlsx') %>% road_query_table(desc=T) %>% 
  wiki_json(commons_description = '{"en": "Selected Homo rudolfensis sites from the ROAD Database"}') %>% 
  writeLines("output/Homo rudolfensis.json")

# Homo habilis
read_excel('input/Homo habilis.xlsx') %>% road_query_table(desc=T) %>% 
  wiki_json(commons_description = '{"en": "Selected Homo habilis sites from the ROAD Database"}') %>% 
  writeLines("output/Homo habilis.json")

# Homo erectus
read_excel('input/Homo erectus.xlsx') %>% road_query_table(desc=T) %>% 
  wiki_json(commons_description = '{"en": "Selected Homo erectus sites from the ROAD Database"}') %>% 
  writeLines("output/Homo erectus.json")

# Homo ergaster
read_excel('input/Homo ergaster.xlsx') %>% road_query_table(desc=T) %>% 
  wiki_json(commons_description = '{"en": "Selected Homo ergaster sites from the ROAD Database"}') %>% 
  writeLines("output/Homo ergaster.json")

# Homo heidelbergensis
read_excel('input/Homo heidelbergensis.xlsx') %>% road_query_table(desc=T) %>% 
  wiki_json(commons_description = '{"en": "Selected Homo heidelbergensis sites from the ROAD Database"}') %>% 
  writeLines("output/Homo heidelbergensis.json")

# Homo sapiens neanderthalensis
read_excel('input/Homo sapiens neanderthalensis.xlsx') %>% road_query_table(desc=T) %>% 
  wiki_json(commons_description = '{"en": "Selected Homo sapiens neanderthalensis sites from the ROAD Database"}') %>% 
  writeLines("output/Homo sapiens neanderthalensis.json")

# Homo sapiens
read_excel('input/Homo sapiens.xlsx') %>% road_query_table(desc=T) %>% 
  wiki_json(commons_description = '{"en": "Selected Homo sapiens sites from the ROAD Database"}') %>% 
  writeLines("output/Homo sapiens.json")

#### Test Area ----
# Uluzzian
road_query_culture('Uluzzian') %>%
  wiki_json(commons_description = '{"en": "Selected Uluzzian sites from the ROAD Database"}') %>%
  writeLines("output/test.json")
