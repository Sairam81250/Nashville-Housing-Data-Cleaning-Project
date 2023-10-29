--Covert SaleDate( DateTime to Date)
select SaleDateConverted, CONVERT(Date, SaleDate)
from PortfolioProjects..NashvilleHousingData

Alter Table PortfolioProjects..NashvilleHousingData  --It will add new column 'SaleDateConverted' in the Date datatype 
add SaleDateConverted Date;

Update PortfolioProjects..NashvilleHousingData -- It will add the values of existed column 'SaleDate' to new column 'SaleDateConverted' in Date Datatype
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populating Property Address

Update a    -- a table lo PropertyAddress null unna daggara, b table lo unna address vastadi
SET	PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjects..NashvilleHousingData a
join PortfolioProjects..NashvilleHousingData b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID] <> b.[UniqueID ]
where a.PropertyAddress is null;


---Splitting Address

SELECT Substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1) as Address,
 Substring(PropertyAddress, charindex(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from PortfolioProjects..NashvilleHousingData

Alter table PortfolioProjects..NashvilleHousingData
add SplitAddress1 nvarchar(255);

Update PortfolioProjects..NashvilleHousingData
set SplitAddress1=Substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1) 

Alter table PortfolioProjects..NashvilleHousingData
add SplitAddress2 nvarchar(255);

Update PortfolioProjects..NashvilleHousingData
set SplitAddress2=Substring(PropertyAddress, charindex(',',PropertyAddress)+1, LEN(PropertyAddress))

--Splitting OwnerAddress

select PARSENAME(Replace(OwnerAddress,',','.'),3), 
 PARSENAME(Replace(OwnerAddress,',','.'),2),
 PARSENAME(Replace(OwnerAddress,',','.'),1)
from PortfolioProjects..NashvilleHousingData

Alter table PortfolioProjects..NashvilleHousingData
add OwnerSplitAddress nvarchar(255);

Update PortfolioProjects..NashvilleHousingData
set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter table PortfolioProjects..NashvilleHousingData
Add Ownercity nvarchar(255)

Update PortfolioProjects..NashvilleHousingData
set Ownercity=PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter table PortfolioProjects..NashvilleHousingData
Add OwnersplitState nvarchar(255)

Update PortfolioProjects..NashvilleHousingData
set OwnersplitState=PARSENAME(Replace(OwnerAddress,',','.'),1)

Update PortfolioProjects..NashvilleHousingData
set SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 Else SoldAsVacant
	 End;


with RowNumCTE As(
select *, ROW_NUMBER() over (
		  Partition By ParcelID,
		  PropertyAddress,
		  SaleDate,
		  LegalReference
		  Order By UniqueID) row_num
from PortfolioProjects..NashvilleHousingData)
Delete from
RowNumCTE
where row_num>1

Alter table PortfolioProjects..NashvilleHousingData
drop column SaleDate, OwnerAddress, TaxDistrict, PropertyAddress

select * from PortfolioProjects..NashvilleHousingData
ORDER BY ParcelID;

