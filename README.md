# Data Cleaning in SQL 🧹📊

This project focuses on the essential task of data cleaning using SQL. Data cleaning, also known as data cleansing or scrubbing, is a critical step in the data analysis process, ensuring the quality and accuracy of data before any analysis or reporting. This project demonstrates various techniques and methods to clean and preprocess raw data, making it ready for analysis.

🔍 SQL queries? Check them out here: 
https://github.com/suttiprapasutara/SQL_Project_Data_Cleaning/blob/main/data_cleaning_project.sql

## Motivation
In real-world scenarios, data often comes with inconsistencies, missing values, duplicates, and errors. Properly cleaned data leads to more accurate analysis and reliable insights. This project aims to showcase the importance of data cleaning and how SQL can be used effectively to achieve high-quality data.


## Dataset
The dataset used in this project is a sample of Nashville housing data, which includes information on property sales, addresses, dates, prices, and more. This dataset is intentionally left raw and unprocessed to illustrate common data issues and how to resolve them using SQL.

## Objectives
The main objectives of this project are to:

- Identify and handle missing values.
- Remove duplicate records.
- Standardize and format data.
- Correct inconsistencies and errors.
- Ensure data integrity and accuracy.


## Tools Used
- **SQL:** The primary language used for data cleaning operations.
- **Docker:** For containerizing the SQL database.
- **Azure Data Studio:** My preferred tool for database management and executing SQL queries.
- **GitHub:** For version control and collaboration.

## Data Cleaning Steps
### 1. Standardise Date Format

```sql
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
```

### 2. Populate Property Address data
```sql
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
```

### 3. Breaking out Address into Individual Columns (Address, City, State)
```sql
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
```

### 4. Change Y and N to Yes and No in "SoldAsVacant" Column
```sql
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
```


### 5. Remove Duplicates 

```sql
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
```


### 6. Delete Unused Columns

```sql
SELECT *
FROM 
    PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
```

## What I Learned

Throughout this project, I gained a deeper understanding of:

- The importance of data cleaning in the data analysis workflow.
- Various SQL techniques for cleaning and preprocessing data.
- Best practices for ensuring data quality and integrity.
- Efficiently using SQL Server Management Studio for managing and cleaning data.


## Conclusion
Data cleaning is a fundamental step in any data analysis project. By using SQL, this project demonstrates effective methods to clean and preprocess raw data, making it ready for accurate analysis and reporting. Ensuring data quality at this stage leads to more reliable insights and better decision-making.




