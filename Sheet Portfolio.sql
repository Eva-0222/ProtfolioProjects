select *
from Sheet1$

-- Standard Date Format --
UPDATE Sheet1$
set SaleDate = convert(Date,SaleDate)

alter table Sheet1$
add SaleDateconverted Date ;

update Sheet1$
set SaleDateconverted = convert(Date,SaleDate)

SELECT SaleDateconverted
FROM sheet1$

-- Populated Property Address data--
--(當ParcelID和PropertyAddress資料都一樣 -->第二個PropertyAddress資料會出現NULL，此時要合併同一份資料的ParcelID ，用isnull)
--(除掉null資料)
SELECT  *
FROM SHEET1$
WHERE PropertyAddress is null
order by ParcelID desc

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from sheet1$ as a
join sheet1$ as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress = isnull(a. propertyaddress, 'No Address')
from sheet1$ as a
join sheet1$ as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into Individual Column(Address, City, State)--

SELECT  PropertyAddress
FROM SHEET1$


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1)  as PropertySplitAddress
, SUBSTRING(PropertyAddress, CHARINDEX( ',' , PropertyAddress)+1  , LEN(propertyaddress) + 1 )  as PropertySplitCity

FROM SHEET1$

alter table Sheet1$
add PropertySplitAddress nvarchar(255) ;

update Sheet1$
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',' , PropertyAddress) -1 ) 

alter table Sheet1$
add PropertySplitCity nvarchar(255) ;

update Sheet1$
set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',' , PropertyAddress) + 1 , LEN(propertyaddress))

SELECT  *
FROM SHEET1$

--將'SUBSTRING 改成PARSENAME(簡單)

SELECT
PARSENAME(replace(owneraddress, ',' , '.' ) , 3 ) as OwnerSplitAddress
,PARSENAME(replace(owneraddress, ',' , '.' ) , 2 ) as  OwnerSplitCity
,PARSENAME(replace(owneraddress, ',' , '.' ) , 1 ) as OwnerSplitState
FROM SHEET1$

alter table Sheet1$
add OwnerSplitAddress nvarchar(255) ;

update Sheet1$
set OwnerSplitAddress = PARSENAME(replace(owneraddress, ',' , '.' ) , 3 )

alter table Sheet1$
add OwnerSplitCity nvarchar(255) ;

update Sheet1$
set OwnerSplitCity = PARSENAME(replace(owneraddress, ',' , '.' ) , 2 )

alter table Sheet1$
add OwnerSplitState nvarchar(255) ;

update Sheet1$
set OwnerSplitState = PARSENAME(replace(owneraddress, ',' , '.' ) , 1 )

select *
from sheet1$

-- Change Y and N to Yes and No in "Sold as Vacant" field

update sheet1$
set SoldAsVacant = 
case when SoldAsVacant = 'Y' THEN 'Yes'
		 when SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

select distinct(SoldAsVacant) , count(SoldAsVacant)
from sheet1$
group by SoldAsVacant
order by 2

-- Remove Duplicate

with RowNumCTE AS( 
select *,
	row_number() over(
	partition by parcelID,
					  propertyaddress,
					  saledate,
					  saleprice,
					  legalreference
					  order by
						uniqueID
						) as row_num

from sheet1$
)

select *
FROM RowNumCTE
where row_num >1

--Delete Unused Columns

alter table sheet1$
drop column owneraddress, taxdistrict, propertyaddress

select *
from Sheet1$