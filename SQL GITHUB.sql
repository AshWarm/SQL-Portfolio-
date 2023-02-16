USE [Portfolio Project]

--SELECT *
FROM [Portfolio Project].DBO.CovidDeaths

SELECT location, population, total_cases, total_deaths,new_cases
FROM [Portfolio Project].DBO.CovidDeaths

-----Looking at Total Cases vs Total Deaths
SELECT location, continent, date, total_cases, total_deaths, Total_Deaths/total_cases * 100 as Death_Percentage
FROM [Portfolio Project].DBO.CovidDeaths
Where total_cases is not null and total_deaths is not null


-----Looking at Total Cases vs Total Deaths in Cyprus
SELECT location, continent, date, total_cases, total_deaths, Total_Deaths/total_cases * 100 as Death_Percentage
FROM [Portfolio Project].DBO.CovidDeaths
Where total_cases is not null and total_deaths is not null and location like '%Cyp%'



-----Looking at Total Cases vs Total Deaths by Location
SELECT location, sum(total_cases) as Sum_Total_Cases, sum(total_deaths) as Sum_Total_Deaths, ((sum(Total_Deaths))/(sum(total_cases))) * 100 as Death_Percentage
FROM [Portfolio Project].DBO.CovidDeaths
Where total_cases is not null
Group by location
Order by location desc

------Ordering Locations by Highest Infection Rate
SELECT location, population,date, total_cases,total_deaths, (total_cases/population)*100 as Infection_Rate, (total_deaths/total_cases) * 100 as Death_Percentage
FROM [Portfolio Project].DBO.CovidDeaths
Where total_cases is not null and total_deaths is not null 
--Group by location, population, total_cases
Order by location, Infection_Rate

------Find Country with the Highest Infection Rate compared to Population
SELECT location, population, max(total_cases) as Highest_Infection_count, max(total_cases/population)*100 as PerecntofPopuInfected
FROM [Portfolio Project].DBO.CovidDeaths
--Where total_cases is not null and total_deaths is not null 
Group by location, population
Order by PerecntofPopuInfected desc


---Showing Countries with the Highest Death Count Per Population
Select location,continent, max(total_deaths) as Total_Death_Count
FROM [Portfolio Project].DBO.CovidDeaths
Where continent is not null
Group by location, continent
Order by Total_Death_Count desc


---BY Continent
Select continent, max(total_deaths) as Total_Death_Count
FROM [Portfolio Project].DBO.CovidDeaths
Where continent is not null
Group by continent
Order by Total_Death_Count desc

--Global Numbers Grouped by Month of the Year
SELECT  datepart(MONTH,date) as Month_of_Year,sum(new_cases)as sumofnewcases, sum(new_deaths) as sumofnewdeaths, sum(new_deaths)/sum(new_cases)*100 as deathpercentage
FROM [Portfolio Project].DBO.CovidDeaths
Where continent is not null
Group by datepart(MONTH,date)
Order by Month_of_Year asc



----Total Population vs. Vaccinations
--use [Portfolio Project]

SELECT cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations 
FROM [Portfolio Project]..[CovidVaccinations] as cv
Join [Portfolio Project].dbo.CovidDeaths as cd
on cv.location = cv.location and cv.date = cd.date
Where cd.continent is not null
Order by continent

----Paritioned by Location, Total Population and New Vaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, cd.new_cases,
sum(cd.new_cases) OVER (Partition by cd.location) as InfectedPop_by_Location, 
sum(cv.new_vaccinations)OVER (Partition by cd.location) as Vaccincation_BY_Location
FROM [Portfolio Project].DBO.CovidDeaths AS CD
JOIN [Portfolio Project].DBO.CovidVaccinations AS CV
on cd.location = cv.location and cd.date = cv.date
Where cd.continent is not null
Order by cd.continent

----Paritioned by Location, Rolling Population and New Vaccinations


SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, cd.new_cases,
sum(cd.new_cases) OVER (Partition by cd.location) as Population_by_Location, 
sum(cv.new_vaccinations)OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingVac_By_Location
FROM [Portfolio Project].DBO.CovidDeaths AS CD
JOIN [Portfolio Project].DBO.CovidVaccinations AS CV
on cd.location = cv.location and cd.date = cv.date
Where cd.continent is not null and cv.new_vaccinations is not null and cd.location is not null
Order by cd.continent

---Using CTE----
With PopvsVac (continent, location, date, population, new_vaccinations, new_cases, RollingVac_By_Location)

as

(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, cd.new_cases,
--sum(cd.new_cases) OVER (Partition by cd.location) as Population_by_Location, 
sum(cv.new_vaccinations)OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingVac_By_Location
FROM [Portfolio Project].DBO.CovidDeaths AS CD
JOIN [Portfolio Project].DBO.CovidVaccinations AS CV
on cd.location = cv.location and cd.date = cv.date
Where cd.continent is not null and cv.new_vaccinations is not null
--and cd.location is not null
--Order by cd.continent
)
SELECT *, (RollingVac_By_Location/population)*100 as PercentPopVacc
from PopvsVac



---TEMP TABLE
Create Table #PercentPopulation
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_Vaccinations float,
New_Cases float,
RollingVac_By_Location float
)

Insert into #PercentPopulation

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, cd.new_cases,
--sum(cd.new_cases) OVER (Partition by cd.location) as Population_by_Location, 
sum(cv.new_vaccinations)OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingVac_By_Location
FROM [Portfolio Project].DBO.CovidDeaths AS CD
JOIN [Portfolio Project].DBO.CovidVaccinations AS CV
on cd.location = cv.location and cd.date = cv.date
--Where cd.continent is not null and cv.new_vaccinations is not null
--and cd.location is not null
Order by cd.continent
 
