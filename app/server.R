library(shiny)
library(dplyr)
library(RPostgreSQL)

source("auth_public.R")

DB_PORT <- as.integer(Sys.getenv("POSTGRES_PORT"))
if (is.na(DB_PORT)) {
  DB_PORT <- 5432
}

# Povežemo se z gonilnikom za PostgreSQL
drv <- dbDriver("PostgreSQL")

shinyServer(function(input, output, session) {
  # Vzpostavimo povezavo
  conn <- dbConnect(drv, dbname=auth$db, host=auth$host, user=auth$user, password=auth$password,
                    port=DB_PORT)
  # Pripravimo tabelo
  tbl.transakcija <- tbl(conn, "transakcija")
  
  # Povezava naj se prekine ob izhodu
  cancel.onSessionEnded <- session$onSessionEnded(function() {
    dbDisconnect(conn)
  })
  
  output$transakcije <- DT::renderDataTable({
    # Naredimo poizvedbo
    # x %>% f(y, ...) je ekvivalentno f(x, y, ...)
    t <- tbl.transakcija %>% filter(znesek > !!input$min) %>%
      arrange(znesek) %>% data.frame()
    # Preverimo, da smo dobili kako transakcijo
    validate(need(nrow(t) > 0, "Ni transakcij!"))
    # Vrnemo dobljeno razpredelnico
    t
  })

})
