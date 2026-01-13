library(dplyr)
library(ggplot2)
library(readxl)

Loan_repayment_data2 <- read_excel(
  "C:/Users/cengi/OneDrive/Desktop/Loan_replayment_data.xls",
  skip = 1
)

df <- Loan_repayment_data2

# -------------------------
# Assign Risk Category
# -------------------------
df <- df %>%
  mutate(
    Risk = case_when(
      On_time_Payments >= 92 ~ "Prime",
      On_time_Payments >= 85 ~ "NearPrime",
      TRUE ~ "SubPrime"
    )
  )

# -------------------------
# Markov Transition Function
# -------------------------
estimate_transition <- function(prob) {
  p_up   <- max(0.01, (prob - 80)/100)
  p_down <- max(0.01, (90 - prob)/130)
  p_same <- 1 - (p_up + p_down)
  return(c(p_up, p_same, p_down))
}

df$Transition <- lapply(df$On_time_Payments, estimate_transition)

# -------------------------
# Acceptance Probability
# -------------------------
df <- df %>%
  mutate(
    Accept_Prob = pmin(0.95, 0.40 + (On_time_Payments / 200))
  )

# -------------------------
# Default rate by risk
# -------------------------
risk_default <- c(
  "Prime" = 0.01,
  "NearPrime" = 0.03,
  "SubPrime" = 0.10
)

# -------------------------
# Customer Simulation Function
# -------------------------
simulate_customer <- function(initial_risk, accept_prob, transitions, max_increases = 6) {
  
  risk <- initial_risk
  profit <- 0
  discount_rate <- 0.19/365
  
  for(i in 1:max_increases) {
    
    # Accept probability
    if(runif(1) > accept_prob) break
    
    expected_default <- risk_default[risk]
    pv_profit <- 40 * (1 - expected_default) * exp(-discount_rate * 60)
    profit <- profit + pv_profit
    
    # Markov transition
    move <- sample(c("Up","Stay","Down"), prob = transitions, size = 1)
    
    risk <- switch(risk,
                   "Prime"      = ifelse(move == "Down", "NearPrime", "Prime"),
                   "NearPrime"  = ifelse(move == "Up", "Prime", 
                                         ifelse(move == "Down","SubPrime","NearPrime")),
                   "SubPrime"   = ifelse(move == "Up","NearPrime","SubPrime"))
  }
  
  return(profit)
}

# -------------------------
# Main Optimization Function
# -------------------------
optimize_limits <- function(customer_row) {
  
  risk <- customer_row$Risk
  accept_prob <- customer_row$Accept_Prob
  transitions <- unlist(customer_row$Transition)
  
  # Simulate for n = 0 to 6 increases
  results <- sapply(0:6, function(n) {
    if(n == 0) return(0)
    mean(replicate(200, simulate_customer(risk, accept_prob, transitions, n)))
  })
  
  best_n <- which.max(results) - 1
  best_profit <- max(results)
  
  return(
    data.frame(
      Customer_ID = customer_row$Customer_ID,
      Optimal_Increases = best_n,
      Expected_Profit = round(best_profit, 2)
    )
  )
}

# -------------------------
# Run optimization for all customers — NO ERRORS
# -------------------------

optimized_results <- bind_rows(
  lapply(1:nrow(df), function(i) optimize_limits(df[i, ]))
)

# -------------------------
# Inspect the results
# -------------------------
head(optimized_results)



