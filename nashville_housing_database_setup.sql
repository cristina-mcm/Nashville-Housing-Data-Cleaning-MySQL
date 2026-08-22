use nashville_housing;

SET GLOBAL local_infile = ON;

DROP TABLE IF EXISTS housing_data;

CREATE TABLE housing_data
(
    UniqueID INT,
    ParcelID VARCHAR(20),
    LandUse VARCHAR(60),
    PropertyAddress VARCHAR(100),
    SaleDate DATETIME,
    SalePrice BIGINT,
    LegalReference VARCHAR(25),
    SoldAsVacant VARCHAR(3),
    OwnerName VARCHAR(100),
    OwnerAddress VARCHAR(100),
    Acreage DECIMAL(10,2),
    TaxDistrict VARCHAR(50),
    LandValue BIGINT,
    BuildingValue BIGINT,
    TotalValue BIGINT,
    YearBuilt SMALLINT,
    Bedrooms TINYINT,
    FullBath TINYINT,
    HalfBath TINYINT
);

LOAD DATA LOCAL INFILE
'path/to/nashville_housing_data.csv'
INTO TABLE housing_data
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    @UniqueID,
    @ParcelID,
    @LandUse,
    @PropertyAddress,
    @SaleDate,
    @SalePrice,
    @LegalReference,
    @SoldAsVacant,
    @OwnerName,
    @OwnerAddress,
    @Acreage,
    @TaxDistrict,
    @LandValue,
    @BuildingValue,
    @TotalValue,
    @YearBuilt,
    @Bedrooms,
    @FullBath,
    @HalfBath
)
SET
    UniqueID = NULLIF(TRIM(@UniqueID), ''),
    ParcelID = NULLIF(@ParcelID, ''),
    LandUse = NULLIF(@LandUse, ''),
    PropertyAddress = NULLIF(@PropertyAddress, ''),
    SaleDate = STR_TO_DATE(@SaleDate, '%M %e, %Y'),
    SalePrice = NULLIF(@SalePrice, ''),
    LegalReference = NULLIF(@LegalReference, ''),
    SoldAsVacant = NULLIF(@SoldAsVacant, ''),
    OwnerName = NULLIF(@OwnerName, ''),
    OwnerAddress = NULLIF(@OwnerAddress, ''),
    Acreage = NULLIF(@Acreage, ''),
    TaxDistrict = NULLIF(@TaxDistrict, ''),
    LandValue = NULLIF(@LandValue, ''),
    BuildingValue = NULLIF(@BuildingValue, ''),
    TotalValue = NULLIF(@TotalValue, ''),
    YearBuilt = NULLIF(@YearBuilt, ''),
    Bedrooms = NULLIF(@Bedrooms, ''),
    FullBath = NULLIF(@FullBath, ''),
    HalfBath = NULLIF(TRIM(@HalfBath), '');

select * from housing_data
limit 10;