SELECT *
FROM PortfolioProject_Covid.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject_Covid.dbo.CovidVaccinations
--ORDER BY 3,4

----START (replace location with continent to get break down by continent) -----------------------------------------------------------------------------------------------------------------------------------------------

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject_Covid.dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total cases vs Total Deaths
--Shows liklihood of death if you contract covid, by country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject_Covid.dbo.CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
--Shows percentage of population that contracted covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopInfected
FROM PortfolioProject_Covid.dbo.CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopInfected
FROM PortfolioProject_Covid.dbo.CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopInfected desc


-- Countries with highest Death count per population

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject_Covid.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Death count by continent

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject_Covid.dbo.CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS-----------------------------------------------------------------------------------------------------------------------------------------------

--Global Death% by day
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS Total_Deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject_Covid.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2
--Global Death %
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS Total_Deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject_Covid.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Looking at total pop vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject_Covid.dbo.CovidDeaths dea
Join PortfolioProject_Covid.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject_Covid.dbo.CovidDeaths dea
Join PortfolioProject_Covid.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(
continent nvarchar (255),
location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject_Covid.dbo.CovidDeaths dea
Join PortfolioProject_Covid.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopVaccinated


--Creating View for later visualizations-----------------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW PercentPopVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject_Covid.dbo.CovidDeaths dea
Join PortfolioProject_Covid.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

--SOLO VIEWS------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Countries with highest Death count per population

CREATE VIEW TotalDeathCount as
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject_Covid.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
--ORDER BY TotalDeathCount desc


--Looking at Total cases vs Total Deaths
--Shows liklihood of death if you contract covid, by country

CREATE VIEW DeathPercentage  as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject_Covid.dbo.CovidDeaths
--WHERE location like '%states%'
--ORDER BY 1,2