library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(leaflet)
library(DT)
library(lubridate)

# ============================================================
# 1. CHARGEMENT DES DONNEES
# ============================================================

data_path <- if (file.exists("../data/accidents_clean.rds")) {
  "../data/accidents_clean.rds"
} else {
  "data/accidents_clean.rds"
}

usagers_path <- if (file.exists("../data/usagers_2024.rds")) {
  "../data/usagers_2024.rds"
} else {
  "data/usagers_2024.rds"
}

accidents <- readRDS(data_path)
usagers <- readRDS(usagers_path)

# Harmonisation des identifiants
accidents <- accidents |>
  mutate(
    Num_Acc = as.character(Num_Acc),
    dep = as.character(dep)
  )

usagers <- usagers |>
  mutate(Num_Acc = as.character(Num_Acc))

# ============================================================
# 2. PREPARATION DES DONNEES
# ============================================================

# Préparation des usagers
usagers_prepares <- usagers |>
  mutate(
    sexe_libelle = case_when(
      sexe == 1 ~ "Masculin",
      sexe == 2 ~ "Féminin",
      TRUE ~ "Non renseigné"
    ),
    
    grav_libelle = case_when(
      grav == 1 ~ "Indemne",
      grav == 2 ~ "Tué",
      grav == 3 ~ "Blessé hospitalisé",
      grav == 4 ~ "Blessé léger",
      TRUE ~ "Non renseigné"
    ),
    
    catu_libelle = case_when(
      catu == 1 ~ "Conducteur",
      catu == 2 ~ "Passager",
      catu == 3 ~ "Piéton",
      TRUE ~ "Non renseigné"
    ),
    
    age = 2024 - as.numeric(an_nais),
    
    classe_age = case_when(
      is.na(age) ~ "Non renseigné",
      age < 15 ~ "Enfants",
      age <= 17 ~ "Adolescents",
      age <= 24 ~ "Jeunes adultes",
      age <= 44 ~ "Adultes",
      age <= 64 ~ "Adultes mûrs",
      age >= 65 ~ "Seniors",
      TRUE ~ "Non renseigné"
    )
  )

ordre_age <- c(
  "Enfants",
  "Adolescents",
  "Jeunes adultes",
  "Adultes",
  "Adultes mûrs",
  "Seniors",
  "Non renseigné"
)

usagers_prepares$classe_age <- factor(
  usagers_prepares$classe_age,
  levels = ordre_age
)

# Liste des départements
departements_disponibles <- sort(unique(accidents$dep))

# Noms des mois
noms_mois <- c(
  "Janvier", "Février", "Mars", "Avril",
  "Mai", "Juin", "Juillet", "Août",
  "Septembre", "Octobre", "Novembre", "Décembre"
)

# ============================================================
# 3. INTERFACE UTILISATEUR
# ============================================================

ui <- navbarPage(
  title = "Accidents de la route - France 2024",
  
  tabPanel(
    "Tableau de bord",
    
    sidebarLayout(
      
      # ------------------------------------------------------
      # BARRE LATERALE DES FILTRES
      # ------------------------------------------------------
      
      sidebarPanel(
        width = 3,
        
        h3("Filtres"),
        
        selectInput(
          inputId = "departement",
          label = "Département :",
          choices = c(
            "Tous les départements" = "Tous",
            departements_disponibles
          ),
          selected = "Tous"
        ),
        
        selectInput(
          inputId = "mois",
          label = "Mois :",
          choices = c(
            "Tous les mois" = "Tous",
            setNames(as.character(1:12), noms_mois)
          ),
          selected = "Tous"
        ),
        
        dateRangeInput(
          inputId = "periode",
          label = "Période d'analyse :",
          start = as.Date("2024-01-01"),
          end = as.Date("2024-12-31"),
          min = as.Date("2024-01-01"),
          max = as.Date("2024-12-31"),
          format = "dd/mm/yyyy",
          language = "fr"
        ),
        
        actionButton(
          inputId = "reinitialiser",
          label = "Réinitialiser les filtres",
          icon = icon("refresh"),
          class = "btn-primary",
          width = "100%"
        ),
        
        br(),
        br(),
        
        helpText(
          "Les graphiques, indicateurs et la carte",
          "s'adaptent automatiquement aux filtres sélectionnés."
        )
      ),
      
      # ------------------------------------------------------
      # CONTENU PRINCIPAL
      # ------------------------------------------------------
      
      mainPanel(
        width = 9,
        
        tabsetPanel(
          
          # ==================================================
          # MODULE 1 : VUE GENERALE
          # ==================================================
          
          tabPanel(
            "Vue générale",
            
            br(),
            
            h3("Tableau de bord général"),
            
            fluidRow(
              column(
                3,
                wellPanel(
                  h4("Accidents"),
                  h2(textOutput("kpi_total", inline = TRUE))
                )
              ),
              
              column(
                3,
                wellPanel(
                  h4("Accidents graves"),
                  h2(textOutput("kpi_graves", inline = TRUE))
                )
              ),
              
              column(
                3,
                wellPanel(
                  h4("Accidents mortels"),
                  h2(textOutput("kpi_mortels", inline = TRUE))
                )
              ),
              
              column(
                3,
                wellPanel(
                  h4("En agglomération"),
                  h2(textOutput("kpi_agglomeration", inline = TRUE))
                )
              )
            ),
            
            h4("Présentation du projet"),
            
            p(
              "Cette application interactive présente une analyse",
              "des accidents corporels de la circulation routière",
              "en France en 2024 à partir des données BAAC."
            )
          ),
          
          # ==================================================
          # MODULE 2 : ANALYSE TEMPORELLE
          # ==================================================
          
          tabPanel(
            "Analyse temporelle",
            
            br(),
            
            h3("Analyse temporelle des accidents"),
            
            fluidRow(
              column(
                6,
                plotlyOutput("graphique_mois")
              ),
              
              column(
                6,
                plotlyOutput("graphique_heure")
              )
            )
          ),
          
          # ==================================================
          # MODULE 3 : ANALYSE GEOGRAPHIQUE
          # ==================================================
          
          tabPanel(
            "Analyse géographique",
            
            br(),
            
            h3("Répartition géographique des accidents"),
            
            fluidRow(
              column(
                6,
                plotlyOutput("graphique_departement")
              ),
              
              column(
                6,
                plotlyOutput("graphique_agglomeration")
              )
            )
          ),
          
          # ==================================================
          # MODULE 4 : CARTOGRAPHIE
          # ==================================================
          
          tabPanel(
            "Cartographie",
            
            br(),
            
            h3("Cartographie des accidents"),
            
            p(
              "Localisation des accidents dans la zone retenue",
              "pour la France métropolitaine."
            ),
            
            leafletOutput(
              "carte_accidents",
              height = "600px"
            )
          ),
          
          # ==================================================
          # MODULE 5 : PROFIL DES USAGERS
          # ==================================================
          
          tabPanel(
            "Profil des usagers",
            
            br(),
            
            h3("Analyse du profil des usagers"),
            
            p(
              "Caractéristiques des personnes impliquées",
              "dans les accidents de la route."
            ),
            
            fluidRow(
              column(
                6,
                plotlyOutput("graphique_sexe")
              ),
              
              column(
                6,
                plotlyOutput("graphique_age")
              )
            ),
            
            fluidRow(
              column(
                6,
                plotlyOutput("graphique_gravite")
              ),
              
              column(
                6,
                plotlyOutput("graphique_categorie")
              )
            )
          )
        )
      )
    )
  )
)

# ============================================================
# 4. SERVEUR
# ============================================================

server <- function(input, output, session) {
  
  # ----------------------------------------------------------
  # REINITIALISATION DES FILTRES
  # ----------------------------------------------------------
  
  observeEvent(input$reinitialiser, {
    
    updateSelectInput(
      session,
      "departement",
      selected = "Tous"
    )
    
    updateSelectInput(
      session,
      "mois",
      selected = "Tous"
    )
    
    updateDateRangeInput(
      session,
      "periode",
      start = as.Date("2024-01-01"),
      end = as.Date("2024-12-31")
    )
    
  })
  
  # ----------------------------------------------------------
  # DONNEES FILTREES
  # ----------------------------------------------------------
  accidents_filtres <- reactive({
    
    req(input$periode)
    
    donnees <- accidents |>
      filter(
        date >= input$periode[1],
        date <= input$periode[2]
      )
    
    if (!is.null(input$departement) &&
        input$departement != "Tous") {
      
      donnees <- donnees |>
        filter(dep == input$departement)
    }
    
    if (!is.null(input$mois) &&
        input$mois != "Tous") {
      
      mois_selectionne <- as.integer(input$mois)
      
      donnees <- donnees |>
        filter(as.integer(mois) == mois_selectionne)
    }
    
    donnees
  })
  
  # ----------------------------------------------------------
  # DONNEES USAGERS FILTREES
  # ----------------------------------------------------------
  
  usagers_filtres <- reactive({
    
    donnees_accidents <- accidents_filtres()
    
    usagers_prepares |>
      semi_join(
        donnees_accidents |>
          select(Num_Acc),
        by = "Num_Acc"
      )
  })
  
  # ==========================================================
  # MODULE 1 : INDICATEURS GENERAUX
  # ==========================================================
  
  output$kpi_total <- renderText({
    
    nrow(accidents_filtres())
  })
  
  output$kpi_graves <- renderText({
    
    sum(
      accidents_filtres()$grave,
      na.rm = TRUE
    )
  })
  
  output$kpi_mortels <- renderText({
    
    sum(
      accidents_filtres()$tue,
      na.rm = TRUE
    )
  })
  
  output$kpi_agglomeration <- renderText({
    
    sum(
      accidents_filtres()$agg == 2,
      na.rm = TRUE
    )
  })
  
  # ==========================================================
  # MODULE 2 : ANALYSE TEMPORELLE
  # ==========================================================
  
  output$graphique_mois <- renderPlotly({
    
    donnees <- accidents_filtres() |>
      count(mois, name = "nombre") |>
      arrange(mois)
    
    p <- ggplot(
      donnees,
      aes(
        x = factor(mois, levels = 1:12, labels = noms_mois),
        y = nombre
      )
    ) +
      geom_col(fill = "#2878B5") +
      labs(
        title = "Nombre d'accidents par mois",
        x = "Mois",
        y = "Nombre d'accidents"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(
          angle = 45,
          hjust = 1
        )
      )
    
    ggplotly(p)
  })
  
  output$graphique_heure <- renderPlotly({
    
    donnees <- accidents_filtres() |>
      count(heure, name = "nombre") |>
      arrange(heure)
    
    p <- ggplot(
      donnees,
      aes(x = heure, y = nombre)
    ) +
      geom_col(fill = "#E07A5F") +
      labs(
        title = "Nombre d'accidents par heure",
        x = "Heure",
        y = "Nombre d'accidents"
      ) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # ==========================================================
  # MODULE 3 : ANALYSE GEOGRAPHIQUE
  # ==========================================================
  
  output$graphique_departement <- renderPlotly({
    
    donnees <- accidents_filtres() |>
      count(dep, name = "nombre") |>
      arrange(desc(nombre)) |>
      slice_head(n = 10)
    
    p <- ggplot(
      donnees,
      aes(
        x = reorder(dep, nombre),
        y = nombre
      )
    ) +
      geom_col(fill = "#2878B5") +
      coord_flip() +
      labs(
        title = "Top 10 des départements",
        x = "Département",
        y = "Nombre d'accidents"
      ) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$graphique_agglomeration <- renderPlotly({
    
    donnees <- accidents_filtres() |>
      count(agg_libelle, name = "nombre")
    
    p <- ggplot(
      donnees,
      aes(
        x = agg_libelle,
        y = nombre,
        fill = agg_libelle
      )
    ) +
      geom_col(show.legend = FALSE) +
      labs(
        title = "Accidents en et hors agglomération",
        x = "Localisation",
        y = "Nombre d'accidents"
      ) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # ==========================================================
  # MODULE 4 : CARTOGRAPHIE
  # ==========================================================
  
  output$carte_accidents <- renderLeaflet({
    
    donnees <- accidents_filtres() |>
      filter(
        !is.na(latitude),
        !is.na(longitude),
        between(latitude, 41, 52),
        between(longitude, -6, 10)
      )
    
    set.seed(123)
    
    donnees <- donnees |>
      slice_sample(
        n = min(5000, nrow(donnees))
      ) |>
      mutate(
        popup_info = paste0(
          "<b>Date :</b> ", date,
          "<br><b>Heure :</b> ", heure,
          "<br><b>Département :</b> ", dep,
          "<br><b>Gravité :</b> ",
          ifelse(
            grave,
            "Accident grave",
            "Accident non grave"
          )
        )
      )
    
    leaflet(donnees) |>
      addTiles() |>
      addCircleMarkers(
        lng = ~longitude,
        lat = ~latitude,
        radius = 2,
        stroke = FALSE,
        fillOpacity = 0.5,
        popup = ~popup_info
      )
  })
  
  # ==========================================================
  # MODULE 5 : PROFIL DES USAGERS
  # ==========================================================
  
  output$graphique_sexe <- renderPlotly({
    
    donnees <- usagers_filtres() |>
      count(sexe_libelle, name = "nombre")
    
    p <- ggplot(
      donnees,
      aes(
        x = sexe_libelle,
        y = nombre,
        fill = sexe_libelle
      )
    ) +
      geom_col(show.legend = FALSE) +
      labs(
        title = "Répartition des usagers par sexe",
        x = "Sexe",
        y = "Nombre d'usagers"
      ) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$graphique_age <- renderPlotly({
    
    donnees <- usagers_filtres() |>
      count(classe_age, name = "nombre")
    
    p <- ggplot(
      donnees,
      aes(
        x = classe_age,
        y = nombre
      )
    ) +
      geom_col(fill = "#2878B5") +
      labs(
        title = "Répartition des usagers par âge",
        x = "Classe d'âge",
        y = "Nombre d'usagers"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(
          angle = 35,
          hjust = 1
        )
      )
    
    ggplotly(p)
  })
  
  output$graphique_gravite <- renderPlotly({
    
    donnees <- usagers_filtres() |>
      count(grav_libelle, name = "nombre")
    
    p <- ggplot(
      donnees,
      aes(
        x = grav_libelle,
        y = nombre,
        fill = grav_libelle
      )
    ) +
      geom_col(show.legend = FALSE) +
      labs(
        title = "Gravité des blessures",
        x = "Gravité",
        y = "Nombre d'usagers"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(
          angle = 35,
          hjust = 1
        )
      )
    
    ggplotly(p)
  })
  
  output$graphique_categorie <- renderPlotly({
    
    donnees <- usagers_filtres() |>
      count(catu_libelle, name = "nombre")
    
    p <- ggplot(
      donnees,
      aes(
        x = catu_libelle,
        y = nombre,
        fill = catu_libelle
      )
    ) +
      geom_col(show.legend = FALSE) +
      labs(
        title = "Répartition par catégorie d'usager",
        x = "Catégorie",
        y = "Nombre d'usagers"
      ) +
      theme_minimal()
    
    ggplotly(p)
  })
  
}

# ============================================================
# 5. LANCEMENT DE L'APPLICATION
# ============================================================

shinyApp(ui = ui, server = server)
