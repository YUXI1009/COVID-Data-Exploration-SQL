SELECT
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM COVID_19.coviddeaths2023
ORDER BY location;

-- Total cases vs. Total deaths
-- Show likelihood of deaths if people got infected by virus
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    round((total_deaths/total_cases)*100,2) AS Death_Percentage
FROM coviddeaths2023
WHERE continent <> '';

-- Total cases vs. Populations
-- Percentage of population got covid
SELECT
    location,
    date,
    total_cases,
    population,
    round((total_cases/population)*100,2) AS TotalCases_percentage
FROM coviddeaths2023
WHERE continent <> ''
ORDER BY location;

-- Countries with highest infection rate compared to population
SELECT
    location,
    max(total_cases) AS max_totalcases,
    max(round((total_cases/population)*100,2)) AS TotalCases_percentage
FROM coviddeaths2023
WHERE continent <> ''
GROUP BY location
ORDER BY TotalCases_percentage DESC;

-- Countries with highest death count compared to population
SELECT
    location,
    max(convert(total_deaths, UNSIGNED)) AS total_deaths,
    max(round((total_deaths/population)*100,2)) AS deaths_percentage
FROM coviddeaths2023
WHERE continent <> ''
GROUP BY location
ORDER BY total_deaths DESC;

-- Showing continent with deaths counts
SELECT
    continent,
    max(convert(total_deaths, UNSIGNED)) AS total_deaths,
    max(round((total_deaths/population)*100,2)) AS deaths_percentage
FROM coviddeaths2023
WHERE continent <> ''
GROUP BY continent
ORDER BY total_deaths DESC;

-- Global Number
SELECT
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    SUM(new_deaths)/SUM(new_cases)*100 AS Death_percentage
FROM coviddeaths2023
WHERE continent <> '';

-- Vaccination people vs. Population 
-- Use CTE to perform calculations on percentage of vaccinated people compared to population
WITH VaccinationPeople AS (
SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    CAST(v.new_vaccinations AS UNSIGNED) AS new_vaccinations,
    SUM(new_vaccinations)OVER(PARTITION BY location ORDER BY location,date) AS rolling_new_vaccinations
FROM coviddeaths2023 d
JOIN covidvaccinations2023 v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent <> '')

SELECT 
    *,
    (rolling_new_vaccinations/population)*100 AS vaccination_percentage
FROM VaccinationPeople;

-- Use Temp Table to perform calculations on percentage of vaccinated people compared to population
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population bigint,
New_vaccinations text,
RollingPeopleVaccinated text
);

INSERT INTO PercentPopulationVaccinated
SELECT
    d.continent, 
    d.location, 
    d.date, 
    d.population, 
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.Location ORDER BY d.location, d.Date) AS RollingPeopleVaccinated
FROM CovidDeaths2023 d
JOIN CovidVaccinations2023 v 
ON d.location = v.location
AND d.date = v.date
WHERE d.continent <> '' 
ORDER BY 2,3;

SELECT
    *, 
    (RollingPeopleVaccinated/Population)*100 AS Percentage_Vaccinated
FROM PercentPopulationVaccinated;




-- Create View to store data for further visulization
CREATE VIEW Vaccinated_People1 AS(
SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    CAST(v.new_vaccinations AS UNSIGNED) AS new_vaccinations,
    SUM(new_vaccinations)OVER(PARTITION BY location ORDER BY location,date) AS rolling_new_vaccinations
FROM coviddeaths2023 d
JOIN covidvaccinations2023 v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent <> '');


