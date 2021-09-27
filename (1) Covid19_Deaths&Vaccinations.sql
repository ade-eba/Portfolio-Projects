--Covid 19 Data Exploratory Analysis
--Covid Deaths Data
Select *
From CovidDataAnalysis..CovidDeaths
Order by 3,4


Select location,date, total_cases,new_cases,total_deaths,population
From CovidDataAnalysis..CovidDeaths
Order by 1,2

-- Total Cases Vs Total Deaths
--Likelihood of dying if you contract covid in a specific country
Select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercent
From CovidDataAnalysis..CovidDeaths
Where location LIKE '%states%'
Order by 1,2

--Total Cases Vs Population
--Shows what percentage of population contracted covid
Select location,date, total_cases,population,(total_cases/population)*100 as casesperpopulation
From CovidDataAnalysis..CovidDeaths
Where location LIKE '%states%'
Order by 1,2



--Countries with the highest infection rates

Select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as percentagepopulationinfected
From CovidDataAnalysis..CovidDeaths
Group by location,population
Order by percentagepopulationinfected desc



--Countries with the highest Death count per popoulation

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidDataAnalysis..CovidDeaths
Where Continent IS NOT NULL
Group by location
Order by TotalDeathCount desc


-- Explore by Continent
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidDataAnalysis..CovidDeaths
Where continent IS NOT NULL
Group by continent
Order by TotalDeathCount desc

--explore by continent (special case where continent is null and location have continent names)

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidDataAnalysis..CovidDeaths
Where continent IS NULL
Group by location
Order by TotalDeathCount desc


-- Continents with the highest death count

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidDataAnalysis..CovidDeaths
Where continent IS NOT NULL
Group by continent
Order by TotalDeathCount desc




--Global Covid Numbers grouped by date

Select date, SUM(new_cases) as totalcases,SUM(cast(new_deaths as int)) as totaldeaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as deathpercent
From CovidDataAnalysis..CovidDeaths
Where continent is not null
Group by date
Order by 1,2


--Global Covid numbers total
Select SUM(new_cases) as totalcases,SUM(cast(new_deaths as int)) as totaldeaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as deathpercent
From CovidDataAnalysis..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2



--Joining tables CovidDeaths and CovidVaccinations

--Covid Deaths Data
Select *
From CovidDataAnalysis..CovidDeaths
Order by 3,4

--Covid Vaccinations Data
Select *
From CovidDataAnalysis..CovidVaccinations
Order by 3,4

--Total Population VS Total Vaccinations

--using partition by
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
SUM(cast(vac.new_vaccinations as int))OVER (Partition by dea.location order by dea.location ,dea.date ) as rollingtotalvaccinations
From CovidDataAnalysis..CovidDeaths as dea
JOIN CovidDataAnalysis..CovidVaccinations as vac
On dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
order by 2,3


--using cte to find percentage population vaccinated

With PopVsVac (continent, location,date,population,new_vaccinations,rollingtotalvaccinations)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
SUM(cast(vac.new_vaccinations as int))OVER (Partition by dea.location order by dea.location ,dea.date ) as rollingtotalvaccinations
From CovidDataAnalysis..CovidDeaths as dea
JOIN CovidDataAnalysis..CovidVaccinations as vac
On dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
--order by 2,3
)

Select *,(rollingtotalvaccinations/population)*100 as percentagevaccinations
From PopVsVac


--using Temp Table

Drop Table #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingtotalvaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
SUM(cast(vac.new_vaccinations as int))OVER (Partition by dea.location order by dea.location ,dea.date ) as rollingtotalvaccinations
From CovidDataAnalysis..CovidDeaths as dea
JOIN CovidDataAnalysis..CovidVaccinations as vac
On dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
--order by 2,3

Select *,(rollingtotalvaccinations/population)*100 as percentagevaccinations
From #PercentPopulationVaccinated


--Creating Views to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
SUM(cast(vac.new_vaccinations as int))OVER (Partition by dea.location order by dea.location ,dea.date ) as rollingtotalvaccinations
From CovidDataAnalysis..CovidDeaths as dea
JOIN CovidDataAnalysis..CovidVaccinations as vac
On dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated

