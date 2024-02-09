Select * 
From [Portfolio Project]..CovidDeaths
Where continent is not null
ORDER BY 3,4


--Select * 
--From [Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

Select Location, Date, Total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location, Date,population, total_cases,(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Where location = 'United States'
Order by 1,2

--Looking at Countries with highest infection rate compared to population

Select Location,population, MAX(total_cases) as HighestInfectionCount, Max((cast(total_cases as float))/cast(population as float))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location = 'United States'
Group by Location, Population
Order by PercentPopulationInfected DESC


--Showing countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location = 'United States'
Where continent is not null
Group by Location, Population
Order by TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continent with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location = 'United States'
Where continent is not null
Group by continent
Order by TotalDeathCount DESC


-- GLOBAL NUMBERS

Select SUM(new_cases)as Total_Cases, SUM(cast(new_deaths as int))as Total_Deaths,ISNULL(Sum(cast(New_Deaths as int))/NULLIF(Sum(new_cases),0),0)*100 as DeathPercentage 
From [Portfolio Project]..CovidDeaths
--Where location = 'United States'
Where Continent is not null
--Group By date
Order by 1,2

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations,  RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

Select * 
From PercentPopulationVaccinated