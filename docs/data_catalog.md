# Data Catalog — Gold Layer

The Gold layer is the business-level representation of the data, modeled as a star schema to support analytics and reporting. It consists of dimension views and fact views built on top of the cleansed Silver layer.

> Data types are given in PostgreSQL syntax (`VARCHAR`, `BIGINT`). The equivalents in SQL Server would be `NVARCHAR` and `INT`/`BIGINT`.

---

## 1. gold.dim_customers

- **Purpose:** Stores customer details enriched with demographic and geographic data.
- **Source:** `silver.crm_cust_info` left joined to `silver.erp_cust_az12` and `silver.erp_loc_a101` on the customer key.
- **Grain:** One row per customer.
- **Columns:**

| Column Name | Data Type | Description |
|---|---|---|
| customer_key | BIGINT | Surrogate key uniquely identifying each customer record in the dimension table. |
| customer_id | INT | Unique numerical identifier assigned to each customer in the source CRM system. |
| customer_number | VARCHAR(50) | Alphanumeric identifier representing the customer, used for tracking and referencing. |
| first_name | VARCHAR(50) | The customer's first name, as recorded in the system. |
| last_name | VARCHAR(50) | The customer's last name or family name. |
| country | VARCHAR(50) | The country of residence for the customer (e.g., 'Australia'). |
| gender | VARCHAR(50) | The gender of the customer (e.g., 'Male', 'Female', 'n/a'). CRM is the source of truth; the ERP value is used only when CRM is unavailable. |
| birth_date | DATE | The date of birth of the customer, formatted as YYYY-MM-DD (e.g., 1971-10-06). |
| marital_status | VARCHAR(50) | The marital status of the customer (e.g., 'Married', 'Single'). |
| create_date | DATE | The date when the customer record was created in the system. |
