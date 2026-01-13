# Loan Limit Increase Optimization Model

## Overview
This project implements a **Loan Limit Increase Optimization Model** designed to help lending institutions determine the optimal number of credit limit increases to offer each customer. Using customer repayment history, the model classifies borrowers into risk groups, predicts how their risk profile may evolve over time, simulates multiple credit increase scenarios, and selects the strategy that maximizes expected profit while accounting for default risk and customer acceptance behavior.

The model is built in **R** and applies a combination of **risk segmentation**, **Markov transition modeling**, **Monte Carlo simulation**, and **optimization**. It is scalable and designed to run on large datasets (e.g., 30,000 customers), producing individualized, data-driven credit decisions rather than relying on one-size-fits-all rules.

---

## Methodology

### 1. Data Ingestion
Customer loan repayment data is read from an Excel file into the R environment. The data captures repayment discipline and is used as the foundation for risk classification and behavioral modeling.

### 2. Risk Classification
Each borrower is segmented into one of three risk groups based on on-time repayment rates:
- **Prime**: 92–100% repayment probability  
- **NearPrime**: 85–91% repayment probability  
- **SubPrime**: Below 85% repayment probability  

This mirrors standard banking credit risk practices.

### 3. Behavioral Prediction (Markov Model)
A Markov transition model is used to simulate how customer risk evolves over time. Each risk category is assigned a baseline default rate:
- Prime: 1%  
- NearPrime: 3%  
- SubPrime: 10%  

For every simulation step, customers can **improve**, **remain stable**, or **worsen** in risk status, with transition probabilities summing to one.

### 4. Simulation
For each customer, the model simulates **0–6 loan limit increases**, running **200 Monte Carlo simulations per scenario**. Each simulation accounts for:
- Acceptance or rejection of the offer (capped at 95%)
- Risk movement across categories
- Probability of default
- Expected profit  

If a customer rejects an offer, the simulation stops for that path.

### 5. Optimization
For every customer, the model selects the number of loan limit increases that yields the **highest expected profit**, balancing acceptance likelihood, repayment behavior, and default risk.

---

## Output
The final output contains:
- **Customer_ID**
- **Optimal_Increases** (number of loan limit increases)
- **Expected_Profit** from the selected strategy

### Sample Output
![Optimization Results](Result_customer%20classification_and_profit.png)

---

## Summary

This model provides a robust, data-driven framework for optimizing credit limit increase decisions at the individual customer level. By combining repayment behavior, risk classification, and probabilistic modeling, it enables lenders to identify which customers are most suitable for additional credit while minimizing exposure to default risk. The use of Markov transitions allows the model to realistically capture how borrower risk changes over time rather than assuming static behavior.

Through extensive Monte Carlo simulation, the system evaluates multiple real-world scenarios, including acceptance, rejection, and default outcomes, ensuring that profitability estimates are grounded in uncertainty rather than single-point assumptions. The optimization step ensures that each borrower is offered a tailored credit strategy that maximizes expected returns, moving beyond uniform lending policies.

While the simulation component is computationally intensive, the model is highly scalable and well-suited for large portfolios. Future enhancements can significantly reduce runtime by introducing **parallel computing** or **distributed processing**, allowing simulations to run concurrently across multiple cores or machines without compromising accuracy or consistency.

---

## Notes
- Designed for portfolios of **30,000+ customers**
- Fully automated and reproducible
- Parallelization recommended for production-scale deployment
