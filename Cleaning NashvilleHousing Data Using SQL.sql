-- Standarize the date format 

select * from NashvilleHousingData;

Alter table NashvilleHousingData
add SalesDateConverted date;

update NashvilleHousingData
set SalesDateConverted = convert(SaleDate, Date);

-- Populate Property Address Data
-- cheking the null propery address

select ParcelID, PropertyAddress
from NashvilleHousingData
where PropertyAddress ='';


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
,IF(a.PropertyAddress = '', b.PropertyAddress, a.PropertyAddress)
from NashvilleHousingData a
join NashvilleHousingData b
on a.ParcelID = b.ParcelID	
and a.UniqueID <> b.UniqueID
where a.PropertyAddress ='';

-- Update the address column

update NashvilleHousingData a
join NashvilleHousingData b
on a.ParcelID = b.ParcelID	
and a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IF(a.PropertyAddress = '', b.PropertyAddress, a.PropertyAddress)
where a.PropertyAddress ='';


 


-- Break Down Property Address
select PropertyAddress
from NashvilleHousingData;

--  Remove the string after .
	select SUBSTRING_INDEX(PropertyAddress, ',', 1) AS address1,
SUBSTRING_INDEX(PropertyAddress, ',', -1) AS address2
	from NashvilleHousingData;

-- Updating the table
Alter table NashvilleHousingData
add PropertySplitAddress nvarchar(255);

update NashvilleHousingData
set PropertySplitAddress= SUBSTRING_INDEX(PropertyAddress, ',', 1);

Alter table NashvilleHousingData
add PropertySplitCity nvarchar(255);

update NashvilleHousingData
set PropertySplitCity= SUBSTRING_INDEX(PropertyAddress, ',', -1);

-- Retriving the owner address

select 
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1),',',-1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',',-1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3),',',-1) from NashvilleHousingData;


Alter table NashvilleHousingData
add OwnerSplitAddress nvarchar(255);


update NashvilleHousingData
set OwnerSplitAddress= SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1),',',-1);


Alter table NashvilleHousingData
add OwnerSplitCity nvarchar(255);


update NashvilleHousingData
set OwnerSplitCity= SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',',-1);



Alter table NashvilleHousingData
add OwnerSplitState nvarchar(255);


update NashvilleHousingData
set OwnerSplitState= SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',',-1);


-- Change of yes or no to the SoldAsVacant field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousingData
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case when SoldAsVacant ='Y' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	else SoldAsVacant
    end
from NashvilleHousingData;

-- Update the SoldasVacant field 


update NashvilleHousingData
set SoldAsVacant = 
	case when SoldAsVacant ='Y' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	else SoldAsVacant
    end;

-- Removing the duplicates using the CTE function

WITH RowNumCTE as(
select *, 
	row_number() over(
		partition by ParcelID,
					PropertyAddress,
                    SalePrice,
                    LegalReference
                    order by UniqueID) as row_num
from NashvilleHousingData
-- order by ParcelID 
)
select * from RowNumCTE where row_num >1;



DELETE FROM NashvilleHousingData
WHERE UniqueID IN (
  SELECT UniqueID
  FROM RowNumCTE
  WHERE row_num > 1
	);

-- dropping the unused column


alter table NashvilleHousingData
drop column SaleDate;


 

 