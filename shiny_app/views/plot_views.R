# Funções de plotagem

# Gráfico de séries temporais
generate_series_plot <- function(df, variavel) {
  p <- if(variavel == "IPCA") {
    plot_ly(df, x = ~data) %>%
      add_lines(y = ~valor_ipca, name = "IPCA", line = list(color = "blue"))
  } else if(variavel == "SELIC") {
    plot_ly(df, x = ~data) %>%
      add_lines(y = ~valor_selic, name = "SELIC", line = list(color = "red"))
  } else {
    plot_ly(df, x = ~data) %>%
      add_lines(y = ~valor_ipca, name = "IPCA", line = list(color = "blue")) %>%
      add_lines(y = ~valor_selic, name = "SELIC", line = list(color = "red"))
  }
  
  p %>% layout(title = list(text = "Série Temporal", font = list(size = 16)),
              xaxis = list(title = list(text = "Data", font = list(size = 14)), tickfont = list(size = 12)),
              yaxis = list(title = list(text = "Valor (%)", font = list(size = 14)), tickfont = list(size = 12)),
              legend = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.2, font = list(size = 12)),
              autosize = TRUE,
              margin = list(b = 100) # Aumenta a margem inferior para a legenda
              )
}

# Histogramas
generate_hist_plot <- function(df, variavel) {
  p <- if(variavel == "IPCA") {
    plot_ly(df, x = ~valor_ipca, type = "histogram", 
            name = "IPCA", marker = list(color = "blue"))
  } else if(variavel == "SELIC") {
    plot_ly(df, x = ~valor_selic, type = "histogram", 
            name = "SELIC", marker = list(color = "red"))
  } else {
    plot_ly() %>%
      add_histogram(x = df$valor_ipca, name = "IPCA", 
                   marker = list(color = "blue")) %>%
      add_histogram(x = df$valor_selic, name = "SELIC", 
                   marker = list(color = "red"))
  }
  
  p %>% layout(title = list(text = "Histograma", font = list(size = 16)),
              xaxis = list(title = list(text = "Valor (%)", font = list(size = 14)), tickfont = list(size = 12)),
              yaxis = list(title = list(text = "Frequência", font = list(size = 14)), tickfont = list(size = 12)),
              legend = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.2, font = list(size = 12)),
              autosize = TRUE,
              margin = list(b = 100) # Aumenta a margem inferior para a legenda
              )
}

# Gráfico de dispersão
generate_scatter_plot <- function(df, mostrar_regressao) {
  
  if(mostrar_regressao) {
    fit <- lm(valor_selic ~ valor_ipca, data = df)
    df$pred <- stats::predict(fit)
  }

  p <- plot_ly(df, x = ~valor_ipca, y = ~valor_selic, 
               type = "scatter", mode = "markers",
               marker = list(color = "purple", alpha = 0.6))
  
  if(mostrar_regressao) {
    p <- p %>% add_lines(x = ~valor_ipca, y = ~pred, 
                        line = list(color = "black"),
                        name = "Regressão")
  }
  
  p %>% layout(title = list(text = "IPCA vs SELIC", font = list(size = 16)),
              xaxis = list(title = list(text = "IPCA (%)", font = list(size = 14)), tickfont = list(size = 12)),
              yaxis = list(title = list(text = "SELIC (%)", font = list(size = 14)), tickfont = list(size = 12)),
              legend = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.2, font = list(size = 12)),
              autosize = TRUE,
              margin = list(b = 100) # Aumenta a margem inferior para a legenda
              )
}

# Decomposição da série temporal
generate_decomposition_plot <- function(ts_data) {
  decomposed <- decompose(ts_data)
  p <- plot_ly() %>%
    add_lines(x = time(ts_data), y = decomposed$x, name = "Observado") %>%
    add_lines(x = time(ts_data), y = decomposed$trend, name = "Tendência") %>%
    add_lines(x = time(ts_data), y = decomposed$seasonal, name = "Sazonalidade") %>%
    add_lines(x = time(ts_data), y = decomposed$random, name = "Resíduo")
  
  p %>% layout(title = list(text = "Decomposição da Série Temporal", font = list(size = 16)),
              xaxis = list(title = list(text = "Data", font = list(size = 14)), tickfont = list(size = 12)),
              yaxis = list(title = list(text = "Valor", font = list(size = 14)), tickfont = list(size = 12)),
              legend = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.2, font = list(size = 12)),
              autosize = TRUE,
              margin = list(b = 100) # Aumenta a margem inferior para a legenda
              )
}

# Gráfico ACF
generate_acf_plot <- function(ts_data) {
  acf_values <- acf(ts_data, plot = FALSE)
  ci <- qnorm((1 + 0.95)/2) / sqrt(length(ts_data))
  
  df <- data.frame(lag = acf_values$lag, acf = acf_values$acf)
  
  p <- plot_ly(df, x = ~lag, y = ~acf) %>%
    add_segments(xend = ~lag, yend = 0, line = list(color = 'gray')) %>%
    add_markers(marker = list(color = 'blue', size = 8)) %>%
    add_ribbons(ymin = -ci, ymax = ci, line = list(color = 'rgba(0, 0, 255, 0.05)'),
                fillcolor = 'rgba(0, 0, 255, 0.1)',
                name = 'Intervalo de Confiança')
  
  p %>% layout(
      title = list(text = "Função de Autocorrelação (ACF)", font = list(size = 16)),
      xaxis = list(title = list(text = "Lag", font = list(size = 14)), tickfont = list(size = 12)),
      yaxis = list(title = list(text = "ACF", font = list(size = 14)), tickfont = list(size = 12)),
      legend = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.2, font = list(size = 12)),
      autosize = TRUE,
      margin = list(b = 100) # Aumenta a margem inferior para a legenda
    )
}

# Gráfico PACF
generate_pacf_plot <- function(ts_data) {
  pacf_values <- pacf(ts_data, plot = FALSE)
  ci <- qnorm((1 + 0.95)/2) / sqrt(length(ts_data))
  
  df <- data.frame(lag = pacf_values$lag, pacf = pacf_values$acf)
  
  p <- plot_ly(df, x = ~lag, y = ~pacf) %>%
    add_segments(xend = ~lag, yend = 0, line = list(color = 'gray')) %>%
    add_markers(marker = list(color = 'red', size = 8)) %>%
    add_ribbons(ymin = -ci, ymax = ci, line = list(color = 'rgba(255, 0, 0, 0.05)'),
                fillcolor = 'rgba(255, 0, 0, 0.1)',
                name = 'Intervalo de Confiança')
  
  p %>% layout(
      title = list(text = "Função de Autocorrelação Parcial (PACF)", font = list(size = 16)),
      xaxis = list(title = list(text = "Lag", font = list(size = 14)), tickfont = list(size = 12)),
      yaxis = list(title = list(text = "PACF", font = list(size = 14)), tickfont = list(size = 12)),
      legend = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.2, font = list(size = 12)),
      autosize = TRUE,
      margin = list(b = 100) # Aumenta a margem inferior para a legenda
    )
}