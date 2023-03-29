/*
Covid 19 Data Exploration 
*/

SELECT *
FROM PortafolioProjects.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

-- Seleccionar los datos que vamos a utilizar: 
-- (Select the data that we're going to use)

SELECT location, date, total_cases, new_cases, total_deaths,population
FROM PortafolioProjects.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Total de Casos vs Total de Muertes: 
-- (Total Cases vs Total Deaths)
-- Muestra la probabilidad de morir, si contrajiste COVID, en Argetina:
-- (Shows likelyhood of dying if you contratc COVID in Argentina)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortafolioProjects.dbo.CovidDeaths
WHERE location like '%rgentina%' and
continent is not null
ORDER BY 1, 2

-- Total de Casos vs Población:
-- (Total Cases vs Population)
-- Pporcentaje de la Población que contrajo COVID en Argentina:
-- (Percentage of Population that got COVID in Argentina)
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortafolioProjects.dbo.CovidDeaths
WHERE location like '%rgentina%'
and continent is not null
ORDER BY 1, 2

-- Paises con mayor Índice de Contagio con respecto a su Población:
-- (Countries with Highest Infection Rate compared to Population)
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortafolioProjects.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Paises con mayor Índice de Muertes con respecto a la Población:
-- (Countries with the Highest Death Count per Populaton)
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM PortafolioProjects.dbo.CovidDeaths
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathsCount DESC

-- Continentes con mayor Índice de Muertes
-- (Continents with the Highest Death Count per Population)
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM PortafolioProjects.dbo.CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathsCount DESC

-- Continentes con mayor Índice de Contagio con respecto a su Población:
-- (Continents with Highest Infection Rate compared to Population)
SELECT continent, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortafolioProjects.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY PercentPopulationInfected DESC

-- Índices mundiales:
-- (Global numbers)

-- Porcentaje de Muertes Totales por Cantidad de Casos Totales según la Fecha:
-- (Percentage of Deaths per Cases by Date)
SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths AS int)) as TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentageGlobaly
FROM PortafolioProjects.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- Muestra el Porcentaje de Muertes Totales por Cantidad de Casos Totales:
-- (Percentage of Deaths by Cases)
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths AS int)) as TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentageGlobaly
FROM PortafolioProjects.dbo.CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

-- Total de Población Vacunada
-- (Total Population vs Vaccianation)
-- Muestra el Porcentaje de la población que recibión, como mínimo, una vacuna contra el COVID
-- (Shows Percentage of Populations that has recived at least one COVID vaccine)
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, 
vacc.new_vaccinations, SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY
deaths.location, deaths.date) AS RollingPeopleVaccination, 
-- (RollingPeopleVaccination/population)*100
FROM PortafolioProjects..CovidDeaths AS deaths
JOIN PortafolioProjects.dbo.CovidVaccinations AS vacc
	ON deaths.location = vacc.location and
	deaths.date = vacc.date
WHERE deaths.continent is not null
ORDER BY 2, 3

-- Usamos CTE para realizar el cálculo anterior:
-- (Using CTE to perform calculation on PARTITION BY)
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccination)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, 
vacc.new_vaccinations, SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY
deaths.location, deaths.date) AS RollingPeopleVaccination 
--, (RollingPeopleVaccination/population)*100
FROM PortafolioProjects..CovidDeaths AS deaths
JOIN PortafolioProjects.dbo.CovidVaccinations AS vacc
	ON deaths.location = vacc.location and
	deaths.date = vacc.date
WHERE deaths.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccination/Population)*100
FROM PopvsVac
ORDER BY 2, 3

-- Temp Table - Forma Alternativa para el cálculo anterior:
-- (Using Temp Table to perform calculation on PARTITION BY)

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccination numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, 
vacc.new_vaccinations, SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY
deaths.location, deaths.date) AS RollingPeopleVaccination 
--, (RollingPeopleVaccination/population)*100
FROM PortafolioProjects..CovidDeaths AS deaths
JOIN PortafolioProjects.dbo.CovidVaccinations AS vacc
	ON deaths.location = vacc.location and
	deaths.date = vacc.date
WHERE deaths.continent is not null
--ORDER BY 2, 3
SELECT *, (RollingPeopleVaccination/Population)*100
FROM #PercentPopulationVaccinated
ORDER BY 2, 3

-- Creamos una view para realizar visualizaciones futuras: 
-- (Creating view to store data for lates visualizations)

CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, 
vacc.new_vaccinations, SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY
deaths.location, deaths.date) AS RollingPeopleVaccination 
--, (RollingPeopleVaccination/population)*100
FROM PortafolioProjects..CovidDeaths AS deaths
JOIN PortafolioProjects.dbo.CovidVaccinations AS vacc
	ON deaths.location = vacc.location and
	deaths.date = vacc.date
WHERE deaths.continent is not null
--ORDER BY 2, 3