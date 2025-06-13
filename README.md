# 📊 AtliQ Finance Analytics Project

Welcome to the **AtliQ Finance Analytics** project repository!
This project dives deep into SQL-based business intelligence using real-world sales and finance data to deliver powerful, data-driven insights. 🚀

---

## ⭐ Project Summary

🔍 **Objective**: Analyze and generate meaningful financial insights for **AtliQ Hardware**, a company selling computer hardware and accessories across markets like **Amazon, Croma, Flipkart, Best Buy**, and more.

🧠 **Skill Focus**: SQL, data cleaning, joining complex tables, creating stored procedures, working with fiscal calendars, and generating market/customer/product performance reports.

---

## 🦮 Situation

AtliQ Hardware wanted to:

* Track **net sales**, **product performance**, **market performance**, and **forecast accuracy**.
* Drill down into specific customers (e.g., **Croma India**) and their buying behavior.
* Segment data by **fiscal year** (Sep–Aug) instead of the calendar year.
* Make decisions based on customer segmentation, product trends, and regional contribution.

---

## 🎯 Task

Your goal was to extract, transform, and analyze transactional and master data from multiple SQL tables to:

* Build end-to-end queries for **gross and net sales analysis**
* Join product, customer, and pricing dimensions
* Work with custom fiscal logic
* Evaluate **forecast accuracy**
* Create reusable **views and stored procedures**

---

## 🔨 Action

Here's what I did using **pure SQL**:

### 🧹 Data Preparation

* Pulled specific customer data (e.g., Croma India).
* Used `DATE_ADD` and custom functions to calculate **fiscal years and quarters**.
* Created **views** like `sales_preinv_discount` and `sales_postinv` for simplified reporting.

### ⚛️ Data Integration

* Joined `fact_sales_monthly` with:

  * `dim_customer` 🧑‍💼
  * `dim_product` 📦
  * `fact_gross_price` 💲
  * `fact_pre_invoice_deductions` and `fact_post_invoice_deductions` ✂️

### 📊 KPI Calculation

* ✅ **Gross Sales** = Sold Quantity × Gross Price
* ✅ **Net Sales** = Gross Sales – (Pre + Post Invoice Discounts)
* ✅ **Forecast Accuracy** using absolute and net error % formulas

### 🧠 Insights Generated

* Top 5 📍 **Markets**, 🧑 **Customers**, and 📦 **Products** by net sales
* % Contribution of net sales by market and region
* Top N products in each division (by sold quantity)
* Region-wise % net sales by customers
* Top 2 markets in each region by gross sales
* Forecast accuracy (%) for each customer

### 🛠️ Stored Procedure

* Created logic for **Market Badges**:

  * 🥇 Gold: Sales > 5 million
  * 🥈 Silver: Otherwise

---

## ✅ Result

The SQL queries enabled:

* 📌 Targeted performance evaluation at the market, product, and customer level
* 📊 Forecasting vs. actual sales performance
* 🗫 Strategy building for marketing and sales teams
* 🔄 Reusable, scalable queries via **views and stored logic**

---

## 📚 What I Learned

✅ Working with **fiscal calendars** (non-Jan to Dec)
✅ Creating **complex joins** across fact and dimension tables
✅ Using **window functions** like `DENSE_RANK` and `SUM OVER()`
✅ Performing **ETL-like transformations** in SQL
✅ Building **forecast accuracy models**
✅ Writing **clean and modular SQL** using CTEs and views
✅ Using **stored procedures** to encapsulate logic

---

## 🧹 Tools & Tech Used

* **SQL (MySQL)**
* Stored Procedures
* CTEs
* Views
* Window Functions
* Aggregate Functions
* Data Cleaning & Transformation

---

## 💡 Future Enhancements

* Convert queries into **Power BI reports or Excel dashboards**
* Automate forecasting logic with Python
* Visualize market/customer segmentation using dashboards

---

## 🙌 Let's Connect

If this project helped you or you'd like to collaborate, feel free to connect or star the repo! 🌟
📧 agrawalnikita1909@gmail.com
🔗 https://www.linkedin.com/in/nikkiagrawal/
