-- Cleaning data in SQL Queries

SELECT *
FROM PortafolioProjects..NashvilleHousing

-- Standarize Data Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortafolioProjects..NashvilleHousing

--UPDATE NashvilleHousing 
--SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date; 

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address data

SELECT *
FROM PortafolioProjects..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- (Hay filas con el mismo ParcelID. Podemos utilizar dicha información para completar
-- aquellas filas que no contienen la dirección). 

SELECT TA.ParcelID, TA.PropertyAddress, TB.ParcelID, TB.PropertyAddress, 
ISNULL(TA.PropertyAddress, TB.PropertyAddress)
FROM PortafolioProjects..NashvilleHousing TA
JOIN PortafolioProjects..NashvilleHousing TB
	ON TA.ParcelID = TB.ParcelID
	AND TA.[UniqueID ] <> TB.[UniqueID ]
WHERE TA.PropertyAddress is null

UPDATE TA
SET PropertyAddress = ISNULL(TA.PropertyAddress, TB.PropertyAddress)
FROM PortafolioProjects..NashvilleHousing TA
JOIN PortafolioProjects..NashvilleHousing TB
	ON TA.ParcelID = TB.ParcelID
	AND TA.[UniqueID ] <> TB.[UniqueID ]
WHERE TA.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT *
FROM PortafolioProjects..NashvilleHousing

--SELECT 
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
--SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
--FROM PortafolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress varchar(255); 

UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity varchar(255); 

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- Vemos otra forma más simple de hacerlo:

SELECT *
FROM PortafolioProjects..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortafolioProjects..NashvilleHousing

-- (Vamos del 3 al 1 porque la función va de atrás hacia adelante). 

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress varchar(255); 

UPDATE NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity varchar(255); 

UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState varchar(255); 

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

-- Change Y and N to Yes and No in 'Sold as Vacant' field. 

SELECT distinct(SoldAsVacant), count(*)
FROM PortafolioProjects..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY count(*)

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortafolioProjects..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference
				ORDER  BY UniqueID
				) row_num 
FROM PortafolioProjects..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
--DELETE 
--FROM RowNumCTE
--WHERE row_num > 1

-- Delete Unused Columns

SELECT *
FROM PortafolioProjects..NashvilleHousing

ALTER TABLE PortafolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortafolioProjects..NashvilleHousing
DROP COLUMN SaleDate

