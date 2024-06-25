/*

Cleaining Data in SQL Queries 

*/

SELECT *
FROM PortfolioProject..NashvilleHousing


---------------------------------------------------------------------------------------------------

-- Standardise Date Format

SELECT 
    SaleDate, 
    CONVERT(Date, SaleDate)

FROM 
    PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- Alternative solution

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



---------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *

FROM 
    PortfolioProject..NashvilleHousing

-- WHERE
    -- PropertyAddress is null
ORDER BY ParcelID



SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    ISNULL(a.PropertyAddress, b.PropertyAddress)

FROM 
    PortfolioProject..NashvilleHousing AS a 
    JOIN PortfolioProject..NashvilleHousing AS b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID

WHERE
    a.PropertyAddress is null


UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
    PortfolioProject..NashvilleHousing AS a 
    JOIN PortfolioProject..NashvilleHousing AS b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE
    a.PropertyAddress is null



---------------------------------------------------------------------------------------------------

-- Breaking out Adress into Individual Columns (Adress, City, State)

    ------ Spliting Address and City from PropertyAddress column by using Substring 

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing 

SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City  

FROM 
    PortfolioProject..NashvilleHousing 


ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 )


ALTER TABLE NashvilleHousing 
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))




        ------ Spliting Address, City, and State from OwnerAddress column by using Parsename

SELECT OwnerAddress
FROM 
    PortfolioProject..NashvilleHousing

SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) As State
FROM 
    PortfolioProject..NashvilleHousing




ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing 
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)





---------------------------------------------------------------------------------------------------\


--- Change Y and N to Yes and No in "SoldAsVacant" column

SELECT 
    Distinct(SoldAsVacant),
    COUNT(SoldAsVacant)

FROM 
    PortfolioProject..NashvilleHousing

GROUP BY SoldAsVacant
ORDER BY 2


SELECT 
    SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
         WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END

FROM 
    PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                        END





---------------------------------------------------------------------------------------------------\


--- Remove Duplicates 

WITH RowNumCTE AS(
SELECT 
    *,
    ROW_NUMBER() OVER(
        PARTITION BY ParcelID,
                     PropertyAddress,
                     SalePrice,
                     SaleDate,
                     LegalReference
                     ORDER BY 
                        UniqueID) row_num

FROM 
    PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress




---------------------------------------------------------------------------------------------------\


--- Delete Unused Columns


SELECT *
FROM 
    PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate