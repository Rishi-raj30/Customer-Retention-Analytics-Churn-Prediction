# model.py: Python data preprocessing, model training and evaluation

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score
import matplotlib.pyplot as plt
import joblib

# Load dataset
df = pd.read_csv('Telco-Customer-Churn.csv')

# Data cleaning
# Convert TotalCharges to numeric (may have blanks)
df['TotalCharges'] = pd.to_numeric(df['TotalCharges'], errors='coerce')
df = df.dropna().reset_index(drop=True)

# Preserve CustomerID for output, then drop it
if 'customerID' in df.columns:
    customer_ids = df['customerID']
    df = df.drop(columns=['customerID'])

# Encode churn target
df['Churn'] = df['Churn'].map({'Yes': 1, 'No': 0})

# One-hot encode categorical features
X = pd.get_dummies(df.drop('Churn', axis=1))
y = df['Churn']

# Split into train and test sets
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Train Random Forest classifier
rf = RandomForestClassifier(n_estimators=100, random_state=42)
rf.fit(X_train, y_train)

# Predictions and evaluation
y_pred = rf.predict(X_test)
print("Classification Report:")
print(classification_report(y_test, y_pred))
print("Confusion Matrix:")
print(confusion_matrix(y_test, y_pred))

# Compute ROC AUC
y_prob = rf.predict_proba(X_test)[:,1]
print("ROC AUC:", roc_auc_score(y_test, y_prob))

# Feature importance (plot top 10)
importances = pd.Series(rf.feature_importances_, index=X.columns)
top10 = importances.nlargest(10)
plt.figure(figsize=(8,6))
top10.plot(kind='barh')
plt.xlabel('Importance')
plt.title('Top 10 Feature Importances')
plt.tight_layout()
plt.savefig('feature_importances.png')

# Save the trained model
joblib.dump(rf, 'rf_model.joblib')

# Save predictions (with CustomerID if available)
try:
    results = pd.DataFrame({
        'CustomerID': customer_ids.iloc[y_test.index],
        'Churn_Prob': y_prob,
        'Churn_Pred': y_pred
    })
    results.to_csv('churn_predictions.csv', index=False)
except NameError:
    # customer_ids not available
    pass
