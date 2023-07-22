--Looking at Total_Cases VS Total_deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From Portfolio_Project.dbo.CovidDeath
WHERE Location Like '%state%'
and continent is not null
Order By 1,2

--Looking at Total_Cases VS Populations

Select location, date, total_cases, population, (total_cases/population)*100 AS DeathPercentage
From Portfolio_Project.dbo.CovidDeath
--WHERE Location Like 'Eg%'
Order By 1,2


-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as Heightsinfectioncount
From Portfolio_Project.dbo.CovidDeath
WHere continent is not null
Group By location, population
order By 1,2


-- Countries with Highest Death Count per Population

SELECT Location, MAX(total_deaths) AS TotalDeaths
FROM Portfolio_Project..CovidDeath
Group By Location
Order By TotalDeaths


-- Continent Total Deaths

SELECT Continent, MAX(total_deaths) AS TotalDeaths
FROM Portfolio_Project..CovidDeath
WHERE continent is not null
Group By Continent
Order By TotalDeaths DESC

-- Check The Accuraty Of Data

SELECT MAX(total_deaths) FROM Portfolio_Project..CovidDeath
WHERE location = 'world'


-- Showing Continent With Height Death Count Pr Popultion

SELECT Continent, MAX(total_deaths) AS TotalDeaths
FROM Portfolio_Project..CovidDeath
WHERE continent is not null
Group By Continent
Order By TotalDeaths DESC

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Looking To Total Population VS Vacciations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(Float , vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.date) As Total_vacciations
--(total_vaccinations/dea.population)*100 AS PercentageOf
FROM Portfolio_Project..CovidDeath dea
Join Portfolio_Project..CovidVacciation vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
	Order By 2,3


-- Use CTE

With PopVsVacc (Continent, Location, Date, Population, New_Vaccinations, Total_vacciation)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(Float , vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.date) As Total_vacciations
--(total_vaccinations/dea.population)*100 AS PercentageOf
FROM Portfolio_Project..CovidDeath dea
Join Portfolio_Project..CovidVacciation vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
	)

SELECT *, (Total_vacciation/Population)*100
From PopVsVacc


-- Temp Table
Drop Table If Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population numeric,
New_Vacciation numeric,
Total_vacciation numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(Float , vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.date) As Total_vacciations
--(total_vaccinations/dea.population)*100 AS PercentageOf
FROM Portfolio_Project..CovidDeath dea
Join Portfolio_Project..CovidVacciation vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null


SELECT *, (Total_vacciation/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinatedd as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Total_vacciations
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeath dea
Join Portfolio_Project..CovidVacciation vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select * from PercentPopulationVaccinatedd