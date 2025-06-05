-- SELECT * 
-- FROM PortfolioProject.covid_deaths
-- Where continent IS NOT NULL
-- Order by 3,4;

-- Select Data that we are going to be using


SELECT location, date , total_cases, new_cases, total_deaths, population
FROM PortfolioProject.covid_deaths
Where continent IS NOT NULL
order by 1,2;


-- Looking at total cases vs Total deaths
-- Show likelyhood of dying if you contract covid in your country



SELECT location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject.covid_deaths
Where continent IS NOT NULL
order by 1,2;


SELECT location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject.covid_deaths
Where location like '%Japan%'
AND continent IS NOT NULL
order by 1,2;


-- looking at Total Cases vs Population
-- Show what percentage of population got Covid


SELECT location, date ,population, total_cases, (total_cases/population)*100 AS percentageoftotalcases
FROM PortfolioProject.covid_deaths
  -- Where location like '%Japan%'
order by 1,2;


-- Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100 AS percentageofpopulationInfected
FROM PortfolioProject.covid_deaths
Where continent IS NOT NULL
Group by location, population
order by percentageofpopulationinfected desc;

-- Showing Countries with Higest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject.covid_deaths 
Where continent IS NOT NULL
Group by location
order by TotalDeathsCount desc;

-- IF total_deaths is not Double but (255,NULL) you'll get error and get wrong answer.
-- So you'll need to change the type or you'll need to change the Query.
-- Below is the query to execute When the data type is wrong.

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM PortfolioProject.covid_deaths 
Where continent IS NOT NULL
Group by location
order by TotalDeathsCount desc;

SELECT location, MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject.covid_deaths 
WHERE continent IS NOT NULL 
  AND location NOT IN ('World', 'Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceania','European Union')
GROUP BY location
ORDER BY TotalDeathsCount DESC;


-- Let's Break things Down by Continent

SELECT continent, MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject.covid_deaths 
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathsCount DESC;


SELECT location, MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject.covid_deaths 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC;

SELECT COALESCE(continent, 'World') AS continent,
       MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject.covid_deaths
GROUP BY COALESCE(continent, 'World')
ORDER BY TotalDeathsCount DESC;

SELECT 
    CASE 
        WHEN continent IS NULL OR continent = '' THEN 'World'
        ELSE continent 
    END AS continent,
    MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject.covid_deaths
GROUP BY 
    CASE 
        WHEN continent IS NULL OR continent = '' THEN 'World'
        ELSE continent 
    END
ORDER BY TotalDeathsCount DESC;


SELECT 
    COALESCE(NULLIF(continent, ''), 'World') AS continent,
    MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject.covid_deaths
GROUP BY continent
ORDER BY TotalDeathsCount DESC;


-- Showing Continent with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject.covid_deaths 
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathsCount DESC;

SELECT continent, MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject.covid_deaths 
WHERE continent IS NOT NULL AND continent <> ''
GROUP BY continent
ORDER BY TotalDeathsCount DESC;


-- Global NUMBER

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as Deathpercentage
-- total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM PortfolioProject.covid_deaths
Where continent IS NOT NULL AND continent <>''
-- GROUP BY date
order by 1,2;


-- Looking at total population vs Vaccinations


SELECT*
FROM PortfolioProject.covid_deaths dea
JOIN PortfolioProject.covid_vaccinations vac
     ON dea.location = vac.location
     and dea.date = vac.date;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.covid_deaths dea
JOIN PortfolioProject.covid_vaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <>''
ORDER BY 1,2,3;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 AS RollingpeoplePopulationPercentage
FROM PortfolioProject.covid_deaths dea
JOIN PortfolioProject.covid_vaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <>''
ORDER BY 2,3;

-- USE CTE

WITH PopvsVac (Continent, location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 AS RollingpeoplePopulationPercentage
FROM PortfolioProject.covid_deaths dea
JOIN PortfolioProject.covid_vaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <>''
-- ORDER BY 2,3;
)
SELECT * , (RollingPeopleVaccinated/population)*100
FROM PopvsVac;


-- TEMP TABLE


CREATE TABLE PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC DEFAULT NULL,
New_vaccinations DOUBLE DEFAULT NULL,
RollingPeopleVaccinated DOUBLE DEFAULT NULL
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 AS RollingpeoplePopulationPercentage
FROM PortfolioProject.covid_deaths dea
JOIN PortfolioProject.covid_vaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <>'';
-- ORDER BY 2,3;


SELECT * ,(RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated;


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS


CREATE VIEW PercentPopulationVaccinated2 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 AS RollingpeoplePopulationPercentage
FROM PortfolioProject.covid_deaths dea
JOIN PortfolioProject.covid_vaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <>'';
-- ORDER BY 2,3


SELECT count(*)
FROM PercentPopulationVaccinated2;



