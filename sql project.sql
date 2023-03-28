-- Covid19 data exploration based on Covid Deaths and covid vaccinations datasets. 

-- Begining with reviewing the covid deaths data  :

Select *  From project.coviddeaths
Where continent is not null 

-- Selecting the Data that we are going to be starting with :

select Location, date, total_cases, new_cases, total_deaths, population
From project.coviddeaths
Where continent is not null 

-- Lookig upon Total Cases vs Total Deaths :
-- It shows the likelihood of dying if someone got infected with covid in his/her country.

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From project.coviddeaths
Where location like '%india%'
and continent is not null 
                        

-- Looking upon Total Cases vs Population : 
-- Shows what percentage of population infected with Covid.

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From project.coviddeaths
Where location like '%india%'
and continent is not null 


-- looking at Countries with Highest Infection Rate compared to Population :

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as     
PercentPopulationInfected
From project.coviddeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Looking Countries with Highest Death Count per Population :
Select Location,Population, MAX(total_deaths) as TotalDeathCount ,  Max((total_deaths/population))*100 as PercentPopulationDied
From project.coviddeaths
Where continent is not null 
Group by Location,population
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population : 

Select continent , population , MAX(Total_deaths) as TotalDeathCount , Max((total_deaths/population))*100 as PercentPopulationDied
From project.coviddeaths
Where continent is not null 
Group by continent, population
order by TotalDeathCount desc



-- GLOBAL NUMBERS
-- it shows total cases vs total death worldwide 
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From project.coviddeaths
where continent is not null 

 -- reviewing the covid vaccinations data  :

Select *  From project.covidvaccinations 
Where continent is not null 

-- Looking upon Total Population vs Vaccinations
-- it Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations  
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
From project.coviddeaths dea
Join project.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
( Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Project.CovidDeaths dea
Join Project.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null )


Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated

Create Temporary Table PercentPopulationVaccinated
(
Continent text,
Location text,
Date text,
Population int,
New_vaccinations text,
RollingPeopleVaccinated text
)

Insert into PercentPopulationVaccinated
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Project.CovidDeaths dea
Join Project.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null )

Select * , (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From project.coviddeaths dea
Join project.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * From PercentPopulationVaccinated 
_____________________________________________________________________________________________________________________________