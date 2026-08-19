# Telecom Customer Churn Analysis & Prediction

## Overview  
End-to-end analytics and machine learning pipeline to analyze and predict telecom customer churn. The pipeline uses SQL for data processing and Python (Scikit-learn) for modeling.  

## Dataset  
The project uses the **IBM Telco Customer Churn** dataset (7043 rows × 21 columns). It contains customer demographics, account and service information, billing (monthly/total charges), and churn outcome (Yes/No). The data combines features such as tenure, contract type, payment method, internet service, support add-ons, and churn labels. *(Note: if using a modified version, verify the exact row/column count.)*  

## Technologies  
- **SQL Server / T-SQL**: Data ingestion, staging, cleaning and transformation. Analytical views for reporting (e.g., churn by contract, payment, service, tenure).  
- **Power BI**: (Optional) Used for interactive dashboards and KPIs (not included here).  
- **Python (Pandas, NumPy)**: Data loading, preprocessing, encoding and feature engineering.  
- **Scikit-learn**: RandomForestClassifier model training, prediction and evaluation.  
- **Matplotlib/Seaborn**: Visualization of feature importance and results.  
- **Joblib**: Save and load trained model and encoders.  
- **Jupyter Notebook / Model Script**: Experimentation, development and documentation of the ML pipeline.  

## Pipeline  
1. **SQL ETL**: Raw data loaded into a staging table; SQL scripts handle nulls, deduplication, type conversions and derive new metrics. A fact table is created with numeric churn flag and relevant features. Analytical views calculate churn rates by segment (contract, payment method, internet service, tenure band, etc.).  
2. **Data Analysis**: Aggregate queries (in SQL or Power BI) reveal churn patterns. For example, churn rate is ~42.7% for month-to-month vs 11.3% for one-year contracts, and 45.3% for electronic check payment vs ~16–19% for other methods. These insights guide focus on high-risk segments.  
3. **Machine Learning**: Python script loads the same data, encodes categorical fields, and splits into train/test sets. A Random Forest classifier (100 trees, random_state=42) is trained to predict churn. We evaluate using a confusion matrix, classification report, and ROC-AUC. Feature importance is plotted to highlight top churn predictors.  
4. **Integration**: The trained model is saved and used to predict churn on new or test data. Predictions (with probabilities) can be exported to CSV for use in Power BI or CRM tools to flag high-risk customers.  

## Key Insights  
- **Contract type:** Month-to-month customers have much higher churn (~42.7%) than 1-year (~11.3%) or 2-year contracts. Focus retention on short-term plans.  
- **Payment method:** Customers paying by electronic check churn at ~45.3%, far above other methods.  
- **Internet service:** Fiber-optic users churn (~41.9%) more than DSL (~19.0%) or no internet (~7.4%).  
- **Support services:** Lack of online security or tech support is linked to ~41–42% churn vs ~15% with these services.  
- **Tenure and charges:** Churners average ~18 months tenure vs ~37 for loyal users, and pay higher monthly fees (~$74 vs $61). Early-tenure customers on high plans are especially at risk.  

## Usage Instructions  
1. **SQL Setup:** Run `queries.sql` in SQL Server to create the staging and fact tables and views. Adjust table/column names as needed.  
2. **Python Model:** Install requirements (`pandas`, `scikit-learn`, etc.). Place the `Telco-Customer-Churn.csv` data file in the project directory. Run `model.py` to train the model and evaluate results. This will output `rf_model.joblib` and `churn_predictions.csv`.  
3. **Dashboard (optional):** Connect Power BI to the SQL views or the `churn_predictions.csv` to build dashboards for business stakeholders.  

## Repository Structure  
- `README.md` – Project description, insights, and usage.  
- `queries.sql` – SQL scripts for ETL and analytic queries.  
- `model.py` – Python script for preprocessing, training, evaluation, and saving outputs. 
- `LICENSE` – License file (e.g. MIT License).  
