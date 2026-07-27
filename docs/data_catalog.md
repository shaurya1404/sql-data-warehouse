# Data Catalog — Gold Layer

The Gold layer is the business-level representation of the data, modeled as a star schema to support analytics and reporting. It consists of dimension views and fact views built on top of the cleansed Silver layer.

> Data types are given in PostgreSQL syntax (`VARCHAR`). The equivalents in SQL Server would be `NVARCHAR`.

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

# 2. gold.dim_products

- **Purpose:** Stores product details enriched with categorization and cost information. Contains only current product records — historical versions are filtered out.
- **Columns:**

| Column Name | Data Type | Description |
|---|---|---|
| product_key | INT | Surrogate key uniquely identifying each product record in the dimension table. |
| product_id | INT | Unique numerical identifier assigned to each product for internal tracking. |
| product_number | VARCHAR(50) | Structured alphanumeric code representing the product, often used for categorization or inventory. |
| product_name | VARCHAR(50) | Descriptive name of the product, including key details such as type, color, and size. |
| category_id | VARCHAR(50) | Unique identifier for the product's category, linking to its high-level classification. |
| category | VARCHAR(50) | The broader classification of the product (e.g., 'Bikes', 'Components') to group related items. |
| subcategory | VARCHAR(50) | A more detailed classification of the product within the category, such as product type. |
| maintenance | VARCHAR(50) | Indicates whether the product requires maintenance (e.g., 'Yes', 'No'). |
| product_cost | INT | The cost or base price of the product, measured in monetary units. |
| product_line | VARCHAR(50) | The specific product line or series the product belongs to (e.g., 'Road', 'Mountain'). |
| product_start_date | DATE | The date when the product became available for sale or use, formatted as YYYY-MM-DD. |

**Note:** The view applies `WHERE prd_end_dt IS NULL`, so it returns only the currently active version of each product. No historization is retained in this dimension.
