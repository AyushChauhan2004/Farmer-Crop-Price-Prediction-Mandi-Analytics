#ImportLibrary
from pathlib import Path
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
pd.set_option("display.max_columns", 100)
pd.set_option("display.max_rows", 50)
sns.set_style("whitegrid")

#LoadDataset
PROJECT_ROOT = Path.cwd().parent if Path.cwd().name == "notebooks" else Path.cwd()
RAW_PATH = PROJECT_ROOT / "data" / "raw" / "sample_mandi_prices.csv"
df = pd.read_csv(RAW_PATH)
print("Dataset Loaded Successfully")
print("Rows :", df.shape[0])
print("Columns :", df.shape[1])
df.head()

#DataOverview
print("="*50)
print("DATASET INFORMATION")
print("="*50)
display(df.head())
print("\nShape :", df.shape)
print("\nColumns")
print(df.columns.tolist())
print("\nData Types")
display(df.dtypes)
print("\nStatistical Summary")
display(df.describe(include='all'))

#MissingValues
missing = df.isnull().sum()
missing_df = pd.DataFrame({
    "Column": missing.index,
    "Missing Values": missing.values,
    "Missing %": round((missing.values/len(df))*100,2)
})
missing_df.sort_values(
    by="Missing Values",
    ascending=False,
    inplace=True
)
display(missing_df)

#Visualization
plt.figure(figsize=(12,6))
sns.barplot(
    data=missing_df,
    x="Missing Values",
    y="Column"
)
plt.title("Missing Values in Dataset")
plt.xlabel("Count")
plt.ylabel("Columns")
plt.show()

#DuplicateRecords
duplicates = df.duplicated().sum()
print("Duplicate Rows :", duplicates)

#ColumnStandardization
df.columns = (
    df.columns
    .str.lower()
    .str.strip()
    .str.replace(" ","_")
    .str.replace("-","_")
)
column_mapping = {
    "arrival_date":"date",
    "state_name":"state",
    "district_name":"district",
    "market_name":"market",
    "commodity":"crop",
    "minimum_price":"min_price",
    "maximum_price":"max_price",
    "model_price":"modal_price"
}

df.rename(columns=column_mapping, inplace=True)

required_columns = [
    "date",
    "state",
    "district",
    "market",
    "crop",
    "variety",
    "grade",
    "min_price",
    "max_price",
    "modal_price"
]

available_columns = [
    col for col in required_columns
    if col in df.columns
]
df = df[available_columns]
df.head()


#DataCleaning
df["date"] = pd.to_datetime(
    df["date"],
    errors="coerce"
)
price_cols = [
    "min_price",
    "max_price",
    "modal_price"
]
for col in price_cols:
    df[col] = pd.to_numeric(
        df[col],
        errors="coerce"
    )
  text_cols = [
    "state",
    "district",
    "market",
    "crop",
    "variety",
    "grade"
]

for col in text_cols:
    df[col] = (
        df[col]
        .astype(str)
        .str.strip()
        .str.title()
    )

df.drop_duplicates(inplace=True)
print("Shape After Cleaning :", df.shape)

#FeatureEngineering
df["year"] = df["date"].dt.year
df["month"] = df["date"].dt.month
df["month_name"] = df["date"].dt.month_name()
df["quarter"] = df["date"].dt.quarter
df["day_name"] = df["date"].dt.day_name()
df["price_spread"] = (
    df["max_price"] - df["min_price"]
)
df["premium_percent"] = (
    (
        df["modal_price"] - df["min_price"]
    )
    /
    df["min_price"]
) * 100



#Outlier Detection
plt.figure(figsize=(12,6)
sns.boxplot(
    x=df["modal_price"]
)
plt.title("Outliers in Modal Price")
plt.show()



Top 10 Most Expensive Crops
crop_price = (
    df.groupby("crop")
    ["modal_price"]
    .mean()
    .sort_values(ascending=False)
    .head(10)
    .reset_index()
)
plt.figure(figsize=(12,6))

sns.barplot(
    data=crop_price,
    x="modal_price",
    y="crop",
    palette="viridis"
)

plt.title("Top 10 Crops by Average Price")

plt.xlabel("Average Modal Price")

plt.ylabel("Crop")

plt.show()

#Monthly Price Trend
monthly_price = (
    df.groupby("month_name")
    ["modal_price"]
    .mean()
    .reset_index()
)
plt.figure(figsize=(14,6))

sns.lineplot(
    data=monthly_price,
    x="month_name",
    y="modal_price",
    marker="o"
)

plt.title("Monthly Average Price Trend")

plt.xticks(rotation=45)

plt.show()


#State Wise Average Prices
state_price = (
    df.groupby("state")
    ["modal_price"]
    .mean()
    .sort_values(ascending=False)
    .head(15)
    .reset_index()
)
plt.figure(figsize=(12,7))

sns.barplot(
    data=state_price,
    x="modal_price",
    y="state",
    palette="magma"
)

plt.title("Top States by Average Crop Price")

plt.show()


#Correlation Heatmap
numerical_cols = [
    "min_price",
    "max_price",
    "modal_price",
    "price_spread",
    "premium_percent"
]

plt.figure(figsize=(8,6))

sns.heatmap(
    df[numerical_cols].corr(),
    annot=True,
    cmap="coolwarm"
)

plt.title("Price Correlation Heatmap")

plt.show()

#Save Processed Dataset
PROCESSED_PATH = (
    PROJECT_ROOT /
    "data" /
    "processed" /
    "mandi_prices_clean.csv"
)

df.to_csv(
    PROCESSED_PATH,
    index=False
)
print(PROCESSED_PATH)
