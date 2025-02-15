--Data Cleaning..

select *
from NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,saledate)

alter table nashvillehousing
add saledateconverted date

update NashvilleHousing
set saledateconverted = convert(date,saledate)


--populate or fill property address data which is null

select * from NashvilleHousing
where PropertyAddress is null

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.propertyaddress,b.PropertyAddress)
from NashvilleHousing a 
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a 
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from NashvilleHousing a join NashvilleHousing b
on a.parcelid = b.parcelid
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual columns (address ,city) 

SELECT 
    propertyAddress,
    LEFT(propertyaddress, CHARINDEX(',',propertyaddress) - 1) AS Street,  -- Extract street
    RIGHT(propertyaddress, LEN(propertyaddress) - CHARINDEX(',',propertyaddress)) AS City -- Extract city
FROM NashvilleHousing

alter table nashvillehousing
add propertysplitaddress nvarchar(255)

update NashvilleHousing
set propertysplitaddress = LEFT(propertyaddress, CHARINDEX(',',propertyaddress) - 1)

alter table nashvillehousing
add propertysplitcity nvarchar(255)

update NashvilleHousing
set propertysplitcity = RIGHT(propertyaddress, LEN(propertyaddress) - CHARINDEX(',',propertyaddress))

select * 
from NashvilleHousing

--also seperate owner address but with PARSENAME function

SELECT 
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS ownersplitaddress,  --as it work with dot so we replaced
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS ownersplitcity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS ownersplitstate
FROM NashvilleHousing
where owneraddress is not null

alter table nashvillehousing
add ownersplitaddress nvarchar(255)

update NashvilleHousing
set ownersplitaddress =     PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

alter table nashvillehousing
add ownersplitcity nvarchar(255)

update NashvilleHousing
set ownersplitcity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table nashvillehousing
add ownersplitstate nvarchar(255)

update NashvilleHousing
set ownersplitstate = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select * from NashvilleHousing

--replace  y and n with yes and no in soldasvacant column

select distinct(soldasvacant),count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant


select soldasvacant,
case when SoldAsVacant ='y' then 'Yes'
	 when SoldAsVacant = 'n' then 'No'
	 else SoldAsVacant
	 end as newsoldasvacant
from NashvilleHousing

update NashvilleHousing 
set SoldAsVacant =case when SoldAsVacant ='y' then 'Yes'
	 when SoldAsVacant = 'n' then 'No'
	 else SoldAsVacant
	 end

--remove duplicates
with rownumcte as(
select *,row_number() over(partition by parcelid,propertyaddress,saleprice,saledate,legalreference
order by uniqueid)rownum
from NashvilleHousing
)
delete  from rownumcte 
where rownum >1

--confirm
with rownumcte as(
select *,row_number() over(partition by parcelid,propertyaddress,saleprice,saledate,legalreference
order by uniqueid)rownum
from NashvilleHousing
)
select *  from rownumcte 
where rownum >1

