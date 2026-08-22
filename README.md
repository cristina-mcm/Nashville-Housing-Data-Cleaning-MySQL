# Nashville Housing Data Cleaning in MySQL

## Project Overview

This project cleans and prepares Nashville housing data using MySQL to improve its accuracy, consistency, and usability.

## Data Cleaning Steps

- Standardized the sale date format.
- Populated missing property addresses using self-joins.
- Split property and owner addresses into separate address, city, and state columns.
- Standardized `SoldAsVacant` values from `Y` and `N` to `Yes` and `No`.
- Identified and removed duplicate records using `ROW_NUMBER()` and a CTE.
- Removed unnecessary columns.

## Repository Contents

- nashville_housing_data — original Nashville housing dataset;
- nashville_housing_cleaning — database setup;
- nashville_housing_database — data-cleaning scripts.

## Acknowledgment

Project inspired by Alex the Analyst’s SQL data-cleaning tutorial and adapted for MySQL.
