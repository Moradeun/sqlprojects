

/*
Covid 19 Data Exploration

Skills used : Joins, CTE's Temp Tables, Window Functions
Aggregate Functions, Creating Views and Converting Data Types

*/

SELECT * 
FROM PotfolioProjectDB..CovidDeaths$
WHERE continent is not null
order by 3, 4

--Selecting the data I am starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PotfolioProjectDB..CovidDeaths$
WHERE continent is not null
order by 1, 2

--Total Cases vs Total Deaths
--Shows likelihood of death if covid is contracted in different countries

SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
FROM PotfolioProjectDB..CovidDeaths$
WHERE Location like '%canada%'
order by 1, 2



--Total Cases vs Poplulation
--shows percentage of the population infected with covid

SELECT Location, date, total_cases, new_cases, population, (total_cases/population)*100 as Death_percentage
FROM PotfolioProjectDB..CovidDeaths$
--WHERE Location like '%canada%'
order by Death_percentage DESC

--Countries with Highest Infection Rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
FROM PotfolioProjectDB..CovidDeaths$
--WHERE Location like '%canada%'
GROUP BY Location, population
order by PercentagePopulationInfected DESC

--Countries with Highest Death Count per Population

SELECT Location, MAX(Cast(total_deaths AS int)) AS TotalDeathCount
FROM PotfolioProjectDB..CovidDeaths$
--WHERE Location like '%canada%'
where continent is NOT NULL
GROUP BY Location
order by TotalDeathCount DESC

--Grouping by Continent

-- Showing continents with the highest death count per population

SELECT continent, MAX(Cast(total_deaths AS int)) AS TotalDeathCount
FROM PotfolioProjectDB..CovidDeaths$
--WHERE Location like '%canada%'
where continent is NOT NULL
GROUP BY continent
order by TotalDeathCount DESC

--Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(Cast(new_deaths AS int)) AS total_deaths,
 SUM(Cast(new_deaths AS int))/SUM(new_cases)* 100 AS DeathPercentage
FROM PotfolioProjectDB..CovidDeaths$
--WHERE Location like '%canada%'
where continent is NOT NULL
--GROUP BY date
order by 1,2

--Total Population vs Vaccinations

-- Shows percentage of Population that has received at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)* 100
FROM PotfolioProjectDB..CovidDeaths$ dea
JOIN PotfolioProjectDB..CovidVaccinations$ vac
ON  dea.location = vac.location
and dea.date = vac.date
where dea.continent is NOT NULL
--GROUP BY date
order by 2,3;

-- Using CTE Common Table Expression to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinationa, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)* 100
FROM PotfolioProjectDB..CovidDeaths$ dea
JOIN PotfolioProjectDB..CovidVaccinations$ vac
ON  dea.location = vac.location
and dea.date = vac.date
where dea.continent is NOT NULL
--GROUP BY date
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/population)* 100 AS RPVpercentage
 FROM PopvsVac

 -- Uing Temp Table to perform Calculation on Partition By in previous query

 DROP Table if exists #percentpopulationvaccinated

 Create Table #percentpopulationvaccinated
 (continent nvarchar(255), 
 location nvarchar(255), 
 date datetime, 
 population numeric, 
 new_vaccinations numeric, 
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #percentpopulationvaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)* 100
FROM PotfolioProjectDB..CovidDeaths$ dea
JOIN PotfolioProjectDB..CovidVaccinations$ vac
ON  dea.location = vac.location
and dea.date = vac.date
--where dea.continent is NOT NULL
--GROUP BY date
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)* 100 AS RPVpercentage
 FROM #percentpopulationvaccinated

 --  Creating View to store data for visualization

 Create View percentpopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)* 100
FROM PotfolioProjectDB..CovidDeaths$ dea
JOIN PotfolioProjectDB..CovidVaccinations$ vac
ON  dea.location = vac.location
and dea.date = vac.date
where dea.continent is NOT NULL
--GROUP BY date
--order by 2,3

SELECT * FROM percentpopulationvaccinated
