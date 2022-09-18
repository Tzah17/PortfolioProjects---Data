/* 
Cleaning data
*/

Select * from PortfolioProject.dbo.NashvilleHousing

--- Standardize date format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

Update NashvilleHousing
set SaleDateConverted=convert(date,SaleDate)

Select SaleDateConverted from PortfolioProject.dbo.NashvilleHousing

--- Populate property address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a join PortfolioProject.dbo.NashvilleHousing b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

---Breaking out address into individual colums (Address, City, State)

--PropertyAdress
Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress,1,Charindex(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,len(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyAddressNew varchar(255),
PropertyCity varchar(255);

Update NashvilleHousing
set PropertyAddressNew=SUBSTRING(PropertyAddress,1,Charindex(',',PropertyAddress)-1),
PropertyCity=SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,len(PropertyAddress));

--OwnerAdress

Select parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerAddressNew varchar(255),
OwnerCityNew varchar(255),
OwnerStateNew varchar(255);

Update NashvilleHousing
set OwnerAddressNew=parsename(replace(OwnerAddress,',','.'),3),
OwnerCityNew=parsename(replace(OwnerAddress,',','.'),2),
OwnerStateNew=parsename(replace(OwnerAddress,',','.'),1);


---Change Y and N to Yes and No in "Sold as Vacant" field

Update NashvilleHousing
set SoldAsVacant = CASE When SoldAsVacant='Y' then 'Yes'
	When SoldAsVacant='N' then 'No'
	Else SoldAsVacant
		END
--Check that theres no 'Y'/'N' in SoldAsVacant
select SoldAsVacant
from PortfolioProject.dbo.NashvilleHousing
where SoldAsVacant='Y' or SoldAsVacant='N';



---Remove duplicates
With RowNumCTE as(
Select * ,
      ROW_NUMBER() over (
	  PARTITION BY
	      ParcelID,
		  PropertyAddress,
		  SalePrice,
		  SaleDate,
		  LegalReference
		  Order by UniqueID
		  ) row_num
from PortfolioProject.dbo.NashvilleHousing
)
Delete
From RowNumCTE
where row_num > 1 


---Remove unused columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


