/*SCRIPT PURPOSE -
this script creates a new database named 'data warehouse' after checking ifit already exists , if the database exists , it is dropped and recreated.
additionally the script sets up three schemas within the datasbase , bronze , silver . gold */
/* warning -
running this script will drop the entire 'data warehouse' database if it exists / all data in the database will be permanently deleted ,
proceed with caution and ensure you have proper backups before running this script */



create database DataWarehouse;

use DataWarehouse 

-- create schemas

CREATE SCHEMA BRONZE;
GO  -- separate batches while working with multiple sql statements
CREATE SCHEMA SILVER;
GO
CREATE SCHEMA GOLD;
GO
