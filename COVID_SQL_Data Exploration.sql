select *
FROM CovidDeaths
ORDER BY 3, 4

--Select *
--FROM CovidVaccinations
--ORDER BY 3, 4


--Select data that is required for use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2


--Looking at total_cases vs total_deaths
-- Mortality(Probability of dying) rate of COVID in India

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases*100) AS DeathPercentage
FROM CovidDeaths
WHERE location = 'India'
ORDER BY 1, 2

-- Looking at total_cases vs population
--Shows what percentage of population has contracted COVID
--(population = 1.4B)

SELECT location, date, total_cases, population, (total_cases/population*100) AS CovidPercentage
FROM CovidDeaths
WHERE location = 'India'
ORDER BY 1, 2

/* Creating View for India */

CREATE VIEW InfectionRateIndia
AS
SELECT location, date, total_cases, population, (total_cases/population*100) AS CovidPercentage
FROM CovidDeaths
WHERE location = 'India'


-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS InfectionRate, (MAX(total_cases/population)*100) AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Countries with highest death rate compared to population

SELECT location, population, MAX(total_deaths) AS DeathCount, (MAX(total_deaths/population)*100) AS TotalDeaths
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeaths desc


-- Looking at the same data by continent

SELECT continent,population, MAX(cast(total_deaths as int)) AS DeathCount, (MAX(total_deaths/population)*100) AS TotalDeaths
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent, population
ORDER BY TotalDeaths desc

SELECT continent, location ,population, MAX(cast(total_deaths as int)) AS DeathCount, (MAX(total_deaths/population)*100) AS TotalDeaths
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent, location, population
ORDER BY TotalDeaths desc



SELECT continent, MAX(cast(total_deaths as int)) AS DeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY DeathCount desc

/* Creating View of DeathCount */

CREATE VIEW DeathCount
AS
SELECT continent, MAX(cast(total_deaths as int)) AS DeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent


-- Global Daily Chart

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
(SUM(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2


-- How many people have been vaccinated around the world

SELECT  CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, 
CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(CONVERT(bigint, CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location
ORDER BY CovidDeaths.location, CovidDeaths.date)  AS SumVaccinations,
FROM CovidDeaths
JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location and 
		CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null
ORDER BY 2, 3



--CTE

With PopVacc (Continent, Location, Date, Population, new_vaccinations, SumVaccinations)
AS
(
SELECT  CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, 
CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(CONVERT(bigint, CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location
ORDER BY CovidDeaths.location, CovidDeaths.date)  AS SumVaccinations
FROM CovidDeaths
JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location and 
		CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null
--ORDER BY 2, 3
)
Select *, (SumVaccinations/Population)*100 AS PercentVaccinated
FROM PopVacc



-- Temp Table for easier access

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
SumPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT  CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, 
CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(CONVERT(bigint, CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location
ORDER BY CovidDeaths.location, CovidDeaths.date)  AS SumVaccinations
FROM CovidDeaths
JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location and 
		CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null

Select *, (SumPeopleVaccinated/Population)*100 AS PercentVaccinated
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE VIEW PercentPeopleVaccinated
AS
SELECT  CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, 
CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(CONVERT(bigint, CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location
ORDER BY CovidDeaths.location, CovidDeaths.date)  AS SumVaccinations
FROM CovidDeaths
JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location and 
		CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null
