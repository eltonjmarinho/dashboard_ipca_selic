load_data <- function() {
  ipca_csv_path <- "../data/ipca_df.csv"
  selic_csv_path <- "../data/selic_df.csv"
  
  ipca_rds_path <- "../data/ipca_data.rds"
  selic_rds_path <- "../data/selic_data.rds"

  # Prioritize reading from CSV files
  if (file.exists(ipca_csv_path) && file.exists(selic_csv_path)) {
    ipca_df <- read.csv(ipca_csv_path, stringsAsFactors = FALSE)
    selic_df <- read.csv(selic_csv_path, stringsAsFactors = FALSE)
  } else {
    # Fallback to BETSget if CSVs don't exist
    ipca_df <- BETSget(433, data.frame = TRUE)
    selic_df <- BETSget(432, data.frame = TRUE)
    
    # Save the downloaded data to RDS and CSV for future use
    saveRDS(ipca_df, ipca_rds_path)
    saveRDS(selic_df, selic_rds_path)
    write.csv(ipca_df, ipca_csv_path, row.names = FALSE)
    write.csv(selic_df, selic_csv_path, row.names = FALSE)
  }
  
  # Rename the first two columns to ensure merge works as expected
  if (!is.null(ipca_df) && is.data.frame(ipca_df) && ncol(ipca_df) >= 2) {
    colnames(ipca_df)[1:2] <- c("data", "valor")
    ipca_df$data <- as.Date(ipca_df$data) # Convert to Date
  }
  if (!is.null(selic_df) && is.data.frame(selic_df) && ncol(selic_df) >= 2) {
    colnames(selic_df)[1:2] <- c("data", "valor")
    selic_df$data <- as.Date(selic_df$data) # Convert to Date
  }
  
  # Merge the data
  dados_combinados <- merge(ipca_df, selic_df, 
                           by = "data", 
                           suffixes = c("_ipca", "_selic"))
  
  return(dados_combinados)
}

dados_combinados <- load_data()