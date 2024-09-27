
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not Null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not Null
ORDER BY 1,2

-- Looking at Total cases vs Total deaths
-- shows the likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not Null and total_cases <> 0 and location like '%Italy%'  
ORDER BY 1,2

-- Looking at the total cases vs the population

SELECT location, date, total_cases, Population, (total_cases/population)*100 as Prevalence
FROM PortfolioProject..CovidDeaths
WHERE continent is not Null and total_cases <> 0 and location like '%States%'  
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not Null and total_cases <> 0 
GROUP BY location, Population
ORDER BY PercentPopulationInfected Desc

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not Null
GROUP BY location
ORDER BY TotalDeathCount Desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continent with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not Null
GROUP BY continent
ORDER BY TotalDeathCount Desc

 --Global numbers

SELECT Date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as Death_Rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not Null and new_cases <> 0
GROUP BY date
ORDER BY 1,2


--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))  OVER (partition by dea.location order by dea.location) as SumofNewVac
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not Null 
	ORDER BY 2,3



	--use CTE

	with PopsVasc (Continent, Location, Date, population, New_vaccinations, SumofNewVac)
	as
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))  OVER (partition by dea.location order by dea.location) as SumofNewVac
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not Null 
	)
	Select*, (SumofNewVac/population)*100 as VaccinationRate
	From PopsVasc


	--Temp Table

	DROP TABLE if exists #VaccinationRate
	CREATE Table #VaccinationRate
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	SumofNewVac numeric
	)

Insert into #VaccinationRate
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))  OVER (partition by dea.location order by dea.location) as SumofNewVac
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not Null

Select*, (SumofNewVac/population)*100 as VaccinationRate
	From #VaccinationRate




-- Creating View to store data later visualizations

Create View VaccinationRatess as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))  OVER (partition by dea.location order by dea.location) as SumofNewVac
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not Null 
	--ORDER BY 2,3



