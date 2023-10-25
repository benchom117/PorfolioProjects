--Covid 19 Data Exploration (from 2020-02-24 to 2021-04-30)
--Skills used: Joins, CTE´s, Tem Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types



SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--Select the data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows likehood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%spain'AND continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT Location, date, population, total_cases,  (total_cases/population)*100 PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at countries with Highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--let´s break things down by continent


--Showing continents with the highest count per population

SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths 
--WHERE Location like '%states'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states'
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states'
WHERE continent IS NOT NULL
--GROUP BY date 
ORDER BY 1,2



--Looking at total population vs vaccinations
--Shows percentage of population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.Location, dea.date)
as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



--Using CTE to perform Calculation on partition by in previous Query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.Location, dea.date)
as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--Using Temp Table to perform Calculation on Partition by in previous Query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.Location, dea.date)
as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.Location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated