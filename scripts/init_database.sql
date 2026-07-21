/*
============================
CREATE DATABASE AND SCHEMAS
============================
Script Purtpose:

  This script creates a new database "DataWarehouse" after checking if it already exists.
  If the database exists, it is dropped and recreated.
  The script also sets up three schemas in the Database: 'bronze', 'silver', and 'gold'

WARNING:
  The script will drop any existing Database named 'DataWarehouse' immediately.
  All data in the database will be permanently deleted.
*/

-- Drop the database if it already exists, then create it fresh
DROP DATABASE IF EXISTS "DataWarehouse";
CREATE DATABASE "DataWarehouse";

-- Switch to the new 'DataWarehouse' Query Tool
-- Create the three schemas for the medallion layers
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
