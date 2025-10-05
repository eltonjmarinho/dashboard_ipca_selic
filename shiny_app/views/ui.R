# Interface do usuário com design aprimorado e sidebar persistente
library(shiny)
library(shinythemes)
library(plotly)
library(shinyjs)
library(shinyWidgets)

ui <- fluidPage(
  theme = shinytheme("cerulean"),
  useShinyjs(),
  
  tags$head(
    tags$style(HTML("
      .datepicker {
        z-index: 1060 !important; /* Ensure datepicker is above the navbar (default z-index is 1050) */
      }
    "))
  ),
  
  # Use navbarPage with fixed-top for a persistent header
  navbarPage(
    title = "Análise Econômica: IPCA e SELIC",
    collapsible = TRUE,
    
    # Main content with sidebar layout
    tabPanel("Dashboard",
             sidebarLayout(
               sidebarPanel(
                 id = "sidebar",
                 h4("Controles de Análise"),
                 selectInput("variavel", 
                             "Escolha a variável para análise:",
                             choices = c("IPCA", "SELIC", "Ambos"),
                             selected = "Ambos"),
                 
                 dateRangeInput("data_range",
                                "Selecione o período:",
                                start = "2000-01-01",
                                end = Sys.Date(),
                                format = "yyyy-mm-dd"
                 ),
                 
                 checkboxInput("mostrar_regressao",
                               "Mostrar linha de regressão (em gráficos de dispersão)",
                               value = TRUE),
                 
                 hr(),
                 
                 h4("Estatísticas Descritivas"),
                 verbatimTextOutput("estatisticas")
               ),
               
               mainPanel(
                 tabsetPanel(
                   # Painel de Análise Geral
                   tabPanel("Análise Geral",
                            tabsetPanel(
                              tabPanel("Séries Temporais",
                                       br(),
                                       plotlyOutput("series_plot", height = "600px")),
                              tabPanel("Histogramas",
                                       br(),
                                       plotlyOutput("hist_plot", height = "600px")),
                              tabPanel("Correlação",
                                       br(),
                                       plotlyOutput("scatter_plot", height = "500px"),
                                       verbatimTextOutput("correlacao"))
                            )
                   ),
                   
                   # Painel de Análise Avançada
                   tabPanel("Análise Avançada",
                            fluidRow(
                              column(12,
                                     tabsetPanel(
                                       tabPanel("Decomposição da Série Temporal",
                                                br(),
                                                plotlyOutput("decomposition_plot", height = "700px")),
                                       tabPanel("Autocorrelação (ACF/PACF)",
                                                br(),
                                                plotlyOutput("acf_plot", height = "400px"),
                                                plotlyOutput("pacf_plot", height = "400px")),
                                       tabPanel("Modelo ARIMA",
                                                br(),
                                                verbatimTextOutput("arima_summary")),
                                       tabPanel("Projeção SELIC",
                                                br(),
                                                plotlyOutput("projection_plot", height = "600px")),
                                       tabPanel("Regressão (Taylor Rule)",
                                                br(),
                                                plotlyOutput("taylor_plot", height = "500px"),
                                                verbatimTextOutput("taylor_summary"))
                                     ))
                            ))
                 )
               )
             )
    )
  )
)