
###CLEANING DATA IN SQL QUERIES

SELECT * 
FROM nashvilleHousing;

#Standardize date format

SELECT str_to_date(saleDate, '%m/%d/%Y')
FROM nashvillehousing;

UPDATE nashvilleHousing
SET saleDate = str_to_date(saleDate, '%m/%d/%Y');

SELECT saleDate
FROM nashvilleHousing;

#If it doesnt update property...

ALTER TABLE nashvilleHousing
ADD saleDateConverted DATE;

UPDATE nashvilleHousing
SET saleDateConverted = str_to_date(saleDate, '%m/%d/%Y');

#Populate property adress data
	#Set blank rows to null

UPDATE nashvilleHousing
SET propertyAddress = NULL
WHERE propertyAddress = '';


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, coalesce(a.PropertyAddress, b.PropertyAddress)
FROM nashvilleHousing a
JOIN nashvilleHousing b
   ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID
WHERE a.propertyAddress IS NULL;

UPDATE nashvilleHousing a
  JOIN nashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.propertyAddress = coalesce(a.PropertyAddress, b.PropertyAddress)
WHERE a.propertyAddress IS NULL;

SELECT uniqueID, propertyAddress
FROM nashvilleHousing
WHERE propertyAddress IS NULL;


#Breaking out Address into Individual Columns (Address, City, State)

SELECT propertyAddress
FROM nashvilleHousing;

SELECT 
substring(PropertyAddress, 1,locate(',', propertyAddress) -1) AS Address,
substring(PropertyAddress,locate(',', propertyAddress)+1),length(propertyAddress) AS Address
FROM nashvilleHousing;

ALTER TABLE nashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE nashvilleHousing
SET PropertySplitAddress = substring(propertyAddress, 1, LOCATE(',', propertyAddress) -1);

ALTER TABLE nashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE nashvilleHousing
SET PropertySplitCity = substring(propertyAddress, LOCATE(',', propertyAddress) + 1 , length(propertyAddress));

SELECT *
FROM nashvillehousing;

#Different way of splitting the address into columns

SELECT OwnerAddress
FROM nashvilleHousing;

SELECT parsename(REPLACE(ownerAddress,',', '.') , 3),
PARSENAME(REPLACE(ownerAddress,',', '.') , 2),
PARSENAME(REPLACE(ownerAddress,',', '.') , 1)
FROM nashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

SELECT *
FROM nashvillehousing;

##change Y and N to yes and No in "sold as Vacant Field"

SELECT DISTINCT(SoldAsVacant), count(SoldAsVacant)
FROM nashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM nashvilleHousing;

#Remove Duplicates

WITH RowNumCTE AS
(SELECT *,
   ROW_NUMBER() OVER
   (PARTITION BY ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
 ORDER BY UniqueID) row_num
 FROM nashvilleHousing)
 
SELECT *
FROM RowNumCTE 
WHERE row_num>1
ORDER BY propertyAddress;

#another way to delete the rows selected in the cte

DELETE
FROM nashvilleHousing USING nashvilleHousing JOIN RowNumCTE ON nashvilleHousing.parcelID = RowNumCTE.parcelID  
WHERE row_num > 1;

#Drop Unused Columns

ALTER TABLE nashvilleHousing
DROP COLUMN ownerAddress, DROP COLUMN TaxDistrict, DROP COLUMN propertyAddress;

ALTER TABLE nashvilleHousing
DROP COLUMN saleDate; 
