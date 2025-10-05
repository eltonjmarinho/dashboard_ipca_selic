# Servidor
server <- function(input, output, session) { # Adicionado 'session' para usar shinyjs
  
  # Carregar visualizações
  source("views/plot_views.R", local = TRUE)
  
  # Adicionar CSS para sidebar pegajosa usando shinyjs
  shinyjs::runjs("$('#sidebar').css('position', 'sticky').css('top', '80px');")
  
  # Filtragem dos dados baseada no período selecionado
  dados_filtrados <- reactive({
    dados_combinados %>%
      filter(data >= input$data_range[1] & data <= input$data_range[2])
  })
  
  # Gráfico de séries temporais
  output$series_plot <- renderPlotly({
    generate_series_plot(dados_filtrados(), input$variavel)
  })
  
  # Histogramas
  output$hist_plot <- renderPlotly({
    generate_hist_plot(dados_filtrados(), input$variavel)
  })
  
  # Gráfico de dispersão e correlação
  output$scatter_plot <- renderPlotly({
    generate_scatter_plot(dados_filtrados(), input$mostrar_regressao)
  })
  
  # Estatísticas descritivas
  output$estatisticas <- renderPrint({
    df <- dados_filtrados()
    
    if(input$variavel == "IPCA") {
      summary(df$valor_ipca)
    } else if(input$variavel == "SELIC") {
      summary(df$valor_selic)
    } else {
      list(
        IPCA = summary(df$valor_ipca),
        SELIC = summary(df$valor_selic)
      )
    }
  })
  
  # Correlação
  output$correlacao <- renderPrint({
    df <- dados_filtrados()
    cor_valor <- stats::cor(df$valor_ipca, df$valor_selic)
    cat("Correlação entre IPCA e SELIC:", round(cor_valor, 4))
  })
  
  # Reactive para obter a série temporal selecionada
  selected_ts <- reactive({
    df <- dados_filtrados()
    if(input$variavel == "IPCA") {
      ts(df$valor_ipca, frequency = 12)
    } else if(input$variavel == "SELIC") {
      ts(df$valor_selic, frequency = 12)
    } else {
      # Default to IPCA if 'Ambos' is selected
      ts(df$valor_ipca, frequency = 12)
    }
  })
  
  # Decomposição da série temporal
  output$decomposition_plot <- renderPlotly({
    generate_decomposition_plot(selected_ts())
  })
  
  # Gráficos ACF e PACF
  output$acf_plot <- renderPlotly({
    generate_acf_plot(selected_ts())
  })
  
  output$pacf_plot <- renderPlotly({
    generate_pacf_plot(selected_ts())
  })
  
  # Modelo ARIMA
  output$arima_summary <- renderPrint({
    fit <- auto.arima(selected_ts())
    summary(fit)
  })
  
  # Projeção SELIC
  output$projection_plot <- renderPlotly({
    # Carregar bibliotecas necessárias
    library(ggplot2)
    library(dplyr)
    library(plotly)
    library(forecast)
    
    # PROJEÇÃO DIRETA DA SELIC USANDO ARIMA
    # Não usa IPCA, apenas o comportamento histórico da própria Selic
    
    cat("=== PROJETANDO SELIC DIRETAMENTE COM ARIMA ===\n\n")
    
    # Usar dados filtrados pelo usuário
    dados_modelo <- dados_filtrados() # Agora dados_modelo já contém as colunas valor_ipca e valor_selic
    
    if (nrow(dados_modelo) < 24) { # Mínimo de 2 anos de dados para ARIMA sazonal
      return(plotly_empty(type = "scatter", mode = "markers") %>%
               layout(title = "Dados insuficientes para projeção ARIMA (mínimo 24 meses)"))
    }
    
    cat("Período de análise para projeção:", format(min(dados_modelo$data), "%b/%Y"), 
        "a", format(max(dados_modelo$data), "%b/%Y"), "\n")
    cat("Número de observações para projeção:", nrow(dados_modelo), "\n")
    cat("Selic atual (", format(max(dados_modelo$data), "%b/%Y"), "):", 
        tail(dados_modelo$valor_selic, 1), " %\n\n")
    
    # Criar série temporal da Selic a partir dos dados filtrados
    ts_selic <- ts(dados_modelo$valor_selic, 
                   start = c(year(min(dados_modelo$data)), month(min(dados_modelo$data))),
                   frequency = 12)
    
    # Ajustar modelo ARIMA automaticamente
    cat("Ajustando modelo ARIMA para a Selic...\n")
    modelo_arima_selic <- auto.arima(ts_selic, 
                                     seasonal = TRUE,
                                     stepwise = FALSE,
                                     approximation = FALSE)
    
    # Fazer projeção para os próximos 12 meses
    previsao_selic <- forecast(modelo_arima_selic, h = 12)
    
    # Definir a data de início da projeção
    ultima_data_historica <- max(dados_modelo$data)
    data_inicio_projecao <- seq(ultima_data_historica, by = "month", length.out = 2)[2]
    
    # Criar dataframe com projeções
    selic_projetada <- data.frame(
      data = seq(data_inicio_projecao, by = "month", length.out = 12),
      valor_selic = as.numeric(previsao_selic$mean),
      lower_80 = as.numeric(previsao_selic$lower[, 1]),
      upper_80 = as.numeric(previsao_selic$upper[, 1]),
      lower_95 = as.numeric(previsao_selic$lower[, 2]),
      upper_95 = as.numeric(previsao_selic$upper[, 2])
    )
    
    # Criar dataframe com dados históricos + projeção
    dados_historicos <- dados_modelo %>%
      select(data, valor_selic) %>%
      mutate(tipo = "Histórico")
    
    dados_projecao <- selic_projetada %>%
      select(data, valor_selic) %>%
      mutate(tipo = "Projeção")
    
    # Combinar dados
    dados_completos <- bind_rows(dados_historicos, dados_projecao)
    
    # Usar todos os dados históricos + projeção para o gráfico
    dados_grafico <- dados_completos
    
    # Criar gráfico base
    p <- ggplot(dados_grafico, aes(x = data, y = valor_selic, color = tipo, 
                                    text = paste0("Data: ", format(data, "%b/%Y"),
                                                 "<br>Selic: ", round(valor_selic, 2), "%",
                                                 "<br>Tipo: ", tipo))) + 
      geom_line(aes(group = 1), size = 1) +
      geom_point(data = dados_grafico %>% filter(tipo == "Projeção"), 
                 size = 3, alpha = 0.8) +
      scale_color_manual(values = c("Histórico" = "#2C3E50", "Projeção" = "#E74C3C"),
                         name = "") +
      labs(
        title = "Taxa Selic - Série Histórica Completa e Projeção ARIMA",
        subtitle = paste0("Dados de ", format(min(dados_modelo$data), "%b/%Y"), " a ", format(max(dados_modelo$data), "%b/%Y"), " | Projeção ", format(min(selic_projetada$data), "%b/%Y"), " a ", format(max(selic_projetada$data), "%b/%Y"), " com modelo ARIMA direto na Selic"),
        x = "Data",
        y = "Taxa Selic (%)",
        color = ""
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(size = 16, face = "bold"),
        plot.subtitle = element_text(size = 10, color = "gray40"),
        legend.position = "top",
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1)
      ) +
      scale_x_date(date_breaks = "2 years", date_labels = "%Y")
    
    # Converter para gráfico interativo com plotly
    grafico_interativo <- ggplotly(p, tooltip = "text") %>%
      layout(
        hovermode = "x unified",
        legend = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.2, font = list(size = 12)), # Legenda abaixo
        title = list(font = list(size = 16)), # Título com fonte maior
        xaxis = list(title = list(font = list(size = 14)), tickfont = list(size = 12)), # Eixo X com fonte maior
        yaxis = list(title = list(font = list(size = 14)), tickfont = list(size = 12)), # Eixo Y com fonte maior
        autosize = TRUE,
        margin = list(b = 100) # Aumenta a margem inferior para a legenda
      )
    
    # Exibir gráfico interativo
    grafico_interativo
  })
  
  # Taylor Rule Plot
  output$taylor_plot <- renderPlotly({
    df <- dados_filtrados()
    
    fit <- lm(valor_selic ~ valor_ipca, data = df)
    df$pred <- stats::predict(fit)
    
    p <- plot_ly(df, x = ~valor_ipca, y = ~valor_selic, 
                 type = "scatter", mode = "markers",
                 name = "Observado",
                 marker = list(color = "purple", alpha = 0.6))
    
    p <- p %>%
      add_lines(x = ~valor_ipca, y = ~pred, 
                          line = list(color = "black"),
                          name = "Regressão (Regra de Taylor Simplificada)")
    
    p %>%
      layout(title = list(text = "Regressão Simplificada (Tipo Taylor Rule)", font = list(size = 16)),
                xaxis = list(title = list(text = "IPCA (%)", font = list(size = 14)), tickfont = list(size = 12)),
                yaxis = list(title = list(text = "SELIC (%)", font = list(size = 14)), tickfont = list(size = 12)),
                legend = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.2, font = list(size = 12)), # Legenda abaixo
                autosize = TRUE,
                margin = list(b = 100) # Aumenta a margem inferior para a legenda
                )
  })

  # Taylor Rule Summary
  output$taylor_summary <- renderPrint({
    df <- dados_filtrados()
    fit <- lm(valor_selic ~ valor_ipca, data = df)
    cat("=== Sumário da Regressão (SELIC ~ IPCA) ===\n\n")
    summary(fit)
  })
}