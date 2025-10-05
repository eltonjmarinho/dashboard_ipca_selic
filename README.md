# Análise IPCA e SELIC

Este projeto realiza uma análise detalhada dos índices IPCA e SELIC utilizando dados do Banco Central do Brasil através do pacote BETS.

## Estrutura do Projeto

```
trabalho_05/
├── data/                # Armazenamento de dados
│   ├── ipca_data.rds
│   ├── selic_data.rds
│   ├── ipca_df.csv
│   └── selic_df.csv
│
├── notebooks/          # Análise exploratória em Jupyter
│   └── analise_IPCA_SELIC.ipynb
│
├── shiny_app/         # Aplicativo Shiny
│   ├── models/        # Funções para manipulação de dados
│   │   └── data_model.R
│   ├── views/        # Interface do usuário e visualizações
│   │   ├── plot_views.R
│   │   └── ui.R
│   ├── controllers/  # Lógica do aplicativo
│   │   └── server.R
│   └── app.R        # Arquivo principal do Shiny
│
└── README.md         # Este arquivo
```

## Componentes

### 1. Dados (data/)
- Armazena os dados baixados em diferentes formatos:
  - `.rds`: Formato nativo R para séries temporais
  - `.csv`: Formato tabular para fácil acesso

### 2. Análise (notebooks/)
- `analise_IPCA_SELIC.ipynb`: Jupyter Notebook com análise exploratória interativa completa

### 3. Aplicativo Shiny (shiny_app/)
- **Models**: Funções para manipulação de dados
  - `data_model.R`: Funções para obter e processar dados do IPCA e SELIC
- **Views**: Interface do usuário e visualizações
  - `plot_views.R`: Funções para criação de gráficos
  - `ui.R`: Interface do usuário Shiny
- **Controllers**: Lógica do aplicativo
  - `server.R`: Controlador principal do aplicativo
- `app.R`: Arquivo principal que integra todos os componentes

## Features

- Visualização de séries temporais para IPCA e SELIC.
- Histogramas para análise de distribuição.
- Análise de correlação com gráfico de dispersão e linha de regressão.
- Decomposição de séries temporais em componentes de tendência, sazonalidade e resíduos.
- Gráficos de Autocorrelação (ACF) e Autocorrelação Parcial (PACF).
- Modelagem ARIMA automatizada.

## Como Usar

### Jupyter Notebook
1. Abra o VS Code
2. Navegue até `notebooks/analise_IPCA_SELIC.ipynb`
3. Execute as células sequencialmente

### Aplicativo Shiny
1. Abra o RStudio ou seu editor de R preferido.
2. Execute o arquivo `main.R` na raiz do projeto.

## Dependências

Todas as dependências do projeto estão listadas no arquivo `requirements.txt`. Para instalar todas as dependências, execute o seguinte comando no terminal do R:

```R
install.packages(readLines("requirements.txt"))
```