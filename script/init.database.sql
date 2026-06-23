-- PROJECT DATA WAREHOUSE --
-- CREATE A NEW DATABASE --

create database DataWarehouse;

use DataWarehouse 

-- create schemas

CREATE SCHEMA BRONZE;
GO  -- separate batches while working with multiple sql statements
CREATE SCHEMA SILVER;
GO
CREATE SCHEMA GOLD;
GO
