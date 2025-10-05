# Instalação e carregamento dos pacotes necessários
if (!require("shiny")) install.packages("shiny")
if (!require("shinythemes")) install.packages("shinythemes")
if (!require("shinyjs")) install.packages("shinyjs")
if (!require("BETS")) install.packages("BETS")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("plotly")) install.packages("plotly")
if (!require("stats")) install.packages("stats")
if (!require("zoo")) install.packages("zoo")
if (!require("forecast")) install.packages("forecast")

library(shiny)
library(shinythemes)
library(shinyjs)
library(BETS)
library(tidyverse)
library(plotly)
library(stats)
library(zoo)
library(forecast)

# Carregar módulos
source("models/data_model.R")
source("views/ui.R")
source("controllers/server.R")

# Execução do aplicativo
shinyApp(ui = ui, server = server)
