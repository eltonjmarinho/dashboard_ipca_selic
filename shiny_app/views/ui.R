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
      /* Esconder o botão em telas maiores que 768px (tamanho de tablet) */
      @media (min-width: 768px) {
        #toggle_sidebar_btn {
          display: none !important; /* Garante que esteja escondido em desktop */
        }
      }
      /* Mostrar o botão em telas menores que 768px */
      @media (max-width: 767px) {
        #toggle_sidebar_btn {
          display: block !important; /* Mostra o botão em mobile */
          margin-top: 10px; /* Adiciona um pouco de espaço acima do botão */
          margin-bottom: 10px; /* Adiciona um pouco de espaço abaixo do botão */
        }
        .col-sm-4 { /* Largura da sidebar em fluidRow */
          width: 100%;
        }
        .col-sm-8 { /* Largura do mainPanel em fluidRow */
          width: 100%;
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
                 # Botão para alternar a sidebar em dispositivos móveis (visível apenas em mobile)
                 actionButton("toggle_sidebar_btn", "", icon = icon("filter"),
                              class = "btn-primary pull-right",
                              style = "margin-bottom: 15px; display: none;"), # Escondido por padrão
                 tabsetPanel(
                   # Painel de Análise Geral
                   tabPanel("Análise Geral",
                            tabsetPanel(
                              tabPanel("Séries Temporais",
                                       br(),
                                       plotlyOutput("series_plot", height = "auto")),
                              tabPanel("Histogramas",
                                       br(),
                                       plotlyOutput("hist_plot", height = "auto")
                              ),
                              tabPanel("Correlação",
                                       br(),
                                       plotlyOutput("scatter_plot", height = "auto"),
                                       verbatimTextOutput("correlacao")
                              )
                            )
                   ),
                   
                   # Painel de Análise Avançada
                   tabPanel("Análise Avançada",
                            fluidRow(
                              column(12,
                                     tabsetPanel(
                                       tabPanel("Decomposição da Série Temporal",
                                                br(),
                                                plotlyOutput("decomposition_plot", height = "auto")),
                                       tabPanel("Autocorrelação (ACF/PACF)",
                                                br(),
                                                plotlyOutput("acf_plot", height = "auto"),
                                                plotlyOutput("pacf_plot", height = "auto")),
                                       tabPanel("Modelo ARIMA",
                                                br(),
                                                verbatimTextOutput("arima_summary")),
                                       tabPanel("Projeção SELIC",
                                                br(),
                                                plotlyOutput("projection_plot", height = "auto")),
                                       tabPanel("Regressão (Taylor Rule)",
                                                br(),
                                                plotlyOutput("taylor_plot", height = "auto"),
                                                verbatimTextOutput("taylor_summary"))
                                     ))
                            ))
                 )
               )
             )
    ),
    tabPanel("Suporte",
             fluidPage( # Este fluidPage é redundante, mas vou mantê-lo por enquanto para evitar mais erros de sintaxe
               h3("Precisa de Suporte?"),
               p("Se você precisar de ajuda ou tiver alguma dúvida sobre a aplicação, por favor, entre em contato conosco."),
               p(HTML("Envie um e-mail para: <strong>eltonjmarinho@gmail.com</strong>")),
               br(),
               p(HTML("Desenvolvido por <a href=\"https://github.com/eltonjmarinho\" target=\"_blank\">Elton Marinho</a>."))
             )
    )
  ) # Fecha navbarPage
) # Fecha fluidPage principal