SELECT *
FROM PortfolioProject..covidDeaths
WHERE continent is not null
ORDER by 3,4 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covidDeaths
WHERE continent is not null
order by 1,2

-- Deaths to Total cases percentage in Egypt

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
FROM PortfolioProject..covidDeaths
Where location like '%egypt%'
AND continent is not null
order by 1,2

-- Total cases to population percentage in Egypt

SELECT Location, date, total_cases, population, (total_cases/population)*100 as CovidPrecentage
FROM PortfolioProject..covidDeaths
Where location like '%egypt%'
And continent is not null
order by 1,2

-- Percentage of people infected to total population by country

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PopulationInfectedPercentage
FROM PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY location, population
order by PopulationInfectedPercentage Desc

-- Highest death count by country

SELECT Location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY location
order by HighestDeathCount Desc

SELECT Location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent is null
GROUP BY location
order by HighestDeathCount Desc

-- Highest death count by continent

--SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
--FROM PortfolioProject..covidDeaths
--WHERE continent is not null
--GROUP BY continent
--order by HighestDeathCount Desc

-- Total death count by continent

SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent is null
and location not in ('World', 'European Union', 'International')
and location not like '%income'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Daily statistics

SELECT date, SUM(new_cases) as DailyCases, SUM(cast(new_deaths as int)) as DailyDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPrecentage
FROM PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY date
order by 1

-- Totals

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPrecentage
FROM PortfolioProject..covidDeaths
WHERE continent is not null

-- Daily vaccination numbers by country

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
from PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- Rolling Total vaccination numbers by country

-- Using CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingTotalVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingTotalVaccinated
from PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingTotalVaccinated/population)*100 as RollingPercentageVaccinated
FROM PopVsVac

-- Using temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingTotalVaccinated numeric
)
insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingTotalVaccinated
from PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
SELECT *, (RollingTotalVaccinated/population)*100 as RollingPercentageVaccinated
FROM #PercentPopulationVaccinated

-- Creating view

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingTotalVaccinated
from PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated