/*
Select * From NashvilleHousing.dbo.NH
*/

-- Sale Date


Select SaleDateConverted, CONVERT(Date, SaleDate)
From
NashvilleHousing.dbo.NH;

Update NashvilleHousing.dbo.nh
Set SaleDate = CONVERT(Date, SaleDate);

Alter Table NashvilleHousing.dbo.NH
Add SaleDateConverted Date;

Update NashvilleHousing.dbo.nh
Set SaleDateConverted = CONVERT(Date, SaleDate);

Select SaleDate, SaleDateConverted 
From
NH;

-------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data in case where Parcel ID is same, but missing address for some duplicates

Select PropertyAddress
From NH
Where PropertyAddress is null

Select *
From NH
--Where PropertyAddress is null
Order by ParcelID

Select table1.ParcelID, table1.PropertyAddress, table2.ParcelID, table2.PropertyAddress 
From NH as table1
join NH as table2
on table1.ParcelID = table2.ParcelID
and table1.[UniqueID ] <> table2.[UniqueID ]
where table1.PropertyAddress is null;

Select table1.ParcelID, table1.PropertyAddress, table2.ParcelID, table2.PropertyAddress, ISNULL(table1.PropertyAddress, table2.PropertyAddress)
From NH as table1
join NH as table2
on table1.ParcelID = table2.ParcelID
and table1.[UniqueID ] <> table2.[UniqueID ]
where table1.PropertyAddress is null;

update table1
set PropertyAddress = ISNULL(table1.PropertyAddress, table2.PropertyAddress)
From NH as table1
join NH as table2
on table1.ParcelID = table2.ParcelID
and table1.[UniqueID ] <> table2.[UniqueID ]
where table1.PropertyAddress is null;

-------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (address, city, state)

Select PropertyAddress
From NH

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
From NH;

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From NH;

Alter Table NashvilleHousing.dbo.NH
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing.dbo.nh
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

Alter Table NashvilleHousing.dbo.NH
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing.dbo.nh
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

Select * 
From NH;


-- Making similar changes to owner address

Select OwnerAddress 
From NH;

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From NH;

Alter Table NashvilleHousing.dbo.NH
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing.dbo.nh
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3);

Alter Table NashvilleHousing.dbo.NH
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing.dbo.nh
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2);

Alter Table NashvilleHousing.dbo.NH
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing.dbo.nh
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1);

Select *
From NH;

-------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes & No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), count(SoldAsVacant)
From NH
Group By SoldAsVacant
Order By 2


Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
 	 End
From NH;


Update NH
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End;

Select Distinct (SoldAsVacant), count(SoldAsVacant)
From NH
Group By SoldAsVacant
Order By 2;


-------------------------------------------------------------------------------------------------------------------------------------------------
 
--Remove duplicates

With RowNumCTE AS (
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order By
		UniqueID)
		row_num
From NH
--Order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1
Order By PropertyAddress




With RowNumCTE AS (
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order By
		UniqueID)
		row_num
From NH
--Order by ParcelID
)
Delete
From RowNumCTE
where row_num > 1
--Order By PropertyAddress


-------------------------------------------------------------------------------------------------------------------------------------------------


-- Deleting unused columns

Select * 
From NH

Alter Table NH
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NH
Drop Column SaleDate
