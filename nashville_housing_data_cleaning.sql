use nashville_housing;

Select * from housing_data;


-- STANDARDIZE DATE FORMAT

select SaleDate from housing_data; -- current column shows date and time, we don't need time

select SaleDate, convert(SaleDate, date) as SaleDateOnly from housing_data; -- creates a new column that displays only the date, but it doesn't alter the table

alter table housing_data
modify column SaleDate DATE; -- alters/updates the table to show only date in the SaleDate column

select * from housing_data
limit 10;




-- POPULATE PROPERTY ADDRESS DATA

-- property address is missing, but we noticed that for some entries propertyaddress is the same if parcelid is the same,
-- so we will change those entries to show the address instead of null

select * from housing_data
-- where PropertyAddress is null
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress,b.PropertyAddress) -- if a.propertyadress is null then populate with b.property adress
from housing_data as a
join housing_data as b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

SET SQL_SAFE_UPDATES = 0; -- run this separately to turn safe mode off

update housing_data as a -- then run this, to update the table with populated PropertyAddress
join housing_data as b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
set a.PropertyAddress = b.PropertyAddress
where a.PropertyAddress is null
	and b.PropertyAddress is not null;

SET SQL_SAFE_UPDATES = 1; -- then run this to turn safe mode back on

select * from housing_data -- check if it worked
where PropertyAddress is null;




-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

-- PROPERTY ADDRESS

select PropertyAddress
from housing_data;

select
	substring(PropertyAddress, 1, locate(',', PropertyAddress) -1) as PropertyStreetAddress -- extracts only the street-address portion before the comma
	-- , locate(',', PropertyAddress)
    , substring(PropertyAddress, locate(',', PropertyAddress) +1, length(PropertyAddress)) as CityAddress -- extracts the city portion of the address after comma
from housing_data;

alter table housing_data
add PropertyStreetAddress VARCHAR(100);

SET SQL_SAFE_UPDATES = 0;

UPDATE housing_data
SET PropertyStreetAddress = substring(PropertyAddress, 1, locate(',', PropertyAddress) -1);

alter table housing_data
add PropertyCity  VARCHAR(100);

UPDATE housing_data
SET PropertyCity = substring(PropertyAddress, locate(',', PropertyAddress) +1, length(PropertyAddress));

SET SQL_SAFE_UPDATES = 1;

select * from housing_data;

-- OWNER ADDRESS

select OwnerAddress
from housing_data;

-- select
-- parsename(replace(OwnerAddress, ',', '.') , 1) - this function is native to Microsoft SQL Server
-- from housing_data;

select
SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerStreetAddress,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) as OwnerCity,
SUBSTRING_INDEX(OwnerAddress, ',', -1) AS OwnerState
from housing_data;

-- select
    -- TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)) AS OwnerStreetAddress, -- removes the spaces, it is more accurate
    -- TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) as OwnerCity,
    -- TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS OwnerState
-- from housing_data;

alter table housing_data
add OwnerStreetAddress VARCHAR(100);

SET SQL_SAFE_UPDATES = 0;

update housing_data
set OwnerStreetAddress = trim(substring_index(OwnerAddress, ',', 1));

alter table housing_data
add OwnerCity  VARCHAR(100);

update housing_data
set OwnerCity = trim(substring_index(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));

alter table housing_data
add OwnerState  VARCHAR(100);

update housing_data
set OwnerState = trim(substring_index(OwnerAddress, ',', -1));

SET SQL_SAFE_UPDATES = 1;

select *
from housing_data;



-- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

select distinct (SoldAsVacant), count(SoldAsVacant)
from housing_data
group by SoldAsVacant
order by 2;

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from housing_data;

SET SQL_SAFE_UPDATES = 0;

update housing_data
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end;

SET SQL_SAFE_UPDATES = 1;




-- REMOVE DUPLICATES

-- not standard practice, better to create a temp table

-- Preview the duplicates:

with RowNumCTE as (
Select *,
	row_number() over (
	partition by ParcelID,
				PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                Order by ParcelID ) row_num -- where it shows 2 it means it is a duplicate, for example ParcelID 098 05 0B 051.00
from housing_data
-- order by ParcelID;
)

Select * from RowNumCTE
where row_num > 1
order by PropertyAddress;

-- DELETE THE DUPLICATES

SET SQL_SAFE_UPDATES = 0;

with RowNumCTE as (
Select *,
	row_number() over (
	partition by ParcelID,
				PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                Order by ParcelID ) row_num
from housing_data
-- order by ParcelID;
)
Delete h
from housing_data h
join RowNumCTE r
on h.UniqueID = r.UniqueID
where r.row_num > 1;

SET SQL_SAFE_UPDATES = 1;




-- Delete Unused Columns
-- used very rarely

Select * from housing_data;

Alter table housing_data
drop column OwnerAddress,
drop column PropertyAddress,
drop column TaxDistrict;

