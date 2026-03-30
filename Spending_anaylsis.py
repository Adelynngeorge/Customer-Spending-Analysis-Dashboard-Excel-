# ================================
# CUSTOMER SPENDING ANALYSIS
# ================================

import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
import matplotlib.pyplot as plt

# -------------------------------
# 1. LOAD DATA
# -------------------------------
df = pd.read_csv("customer_data.csv")

# -------------------------------
# 2. DATA CLEANING
# -------------------------------
# Remove duplicates
df = df.drop_duplicates()

# Drop missing values
df = df.dropna()

# Convert date column
df['order_date'] = pd.to_datetime(df['order_date'])

# Ensure correct data types
df['amount'] = df['amount'].astype(float)

print("Data cleaned successfully\n")

# -------------------------------
# 3. FEATURE ENGINEERING
# -------------------------------
df['month'] = df['order_date'].dt.to_period('M')

# -------------------------------
# 4. ANALYSIS
# -------------------------------

# Total spending per customer
customer_spend = df.groupby('customer_id')['amount'].sum()

# Top 10 customers
top_customers = customer_spend.sort_values(ascending=False).head(10)

print("Top 10 Customers:\n", top_customers, "\n")

# Monthly revenue
monthly_revenue = df.groupby('month')['amount'].sum()

print("Monthly Revenue:\n", monthly_revenue, "\n")

# -------------------------------
# 5. CUSTOMER SEGMENTATION
# -------------------------------
def segment(x):
    if x > 1000:
        return "High Value"
    elif x > 500:
        return "Medium Value"
    else:
        return "Low Value"

customer_segment = customer_spend.apply(segment)

segment_summary = customer_segment.value_counts()

print("Customer Segments:\n", segment_summary, "\n")

# -------------------------------
# 6. PREDICTION MODEL
# -------------------------------
# Convert dates to numeric
df['date_ordinal'] = df['order_date'].map(pd.Timestamp.toordinal)

X = df[['date_ordinal']]
y = df['amount']

model = LinearRegression()
model.fit(X, y)

# Predict future date
future_date = pd.Timestamp('2026-12-31').toordinal()
prediction = model.predict([[future_date]])

print(f"Predicted spending for future date: {prediction[0]:.2f}\n")

# -------------------------------
# 7. VISUALIZATION
# -------------------------------

# Monthly Revenue Plot
monthly_revenue.plot()
plt.title("Monthly Revenue Trend")
plt.xlabel("Month")
plt.ylabel("Revenue")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# Top Customers Plot
top_customers.plot(kind='bar')
plt.title("Top 10 Customers by Spending")
plt.xlabel("Customer ID")
plt.ylabel("Total Spend")
plt.tight_layout()
plt.show()

# -------------------------------
# 8. SAVE OUTPUTS
# -------------------------------
customer_spend.to_csv("customer_spending_summary.csv")
monthly_revenue.to_csv("monthly_revenue.csv")

print("Analysis complete. Files saved.")