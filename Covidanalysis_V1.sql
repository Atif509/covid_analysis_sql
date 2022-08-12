Select *
 From PortfolioProject ..CovidDeaths
 where continent is not null
 order by 3,4
 --Select *
 --From PortfolioProject ..CovidDeaths
 --order by 3,4
 Select location, date, total_cases, new_cases, total_deaths, population
 From PortfolioProject ..CovidDeaths
 order by 1,2
 --Looking at total death and total cases

 -- Likelihood of dying in your country
  Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 From PortfolioProject ..CovidDeaths
 where location like '%Pakistan%'
 order by 1,2

  -- What percentage got covid
  Select location, date, total_cases, population, ((total_cases/population)*100) as CovidPositive
 From PortfolioProject ..CovidDeaths
 where location like '%Pakistan%'
 order by 1,2
 
   -- Looking at countries with highest infection rates compared to population
 Select location,max( total_cases) as Highestinfectioncount, population, max ((total_cases/population)*100) as CovidPositive
 From PortfolioProject ..CovidDeaths
 --where location like '%Pakistan%'
 Group by location, population
 order by CovidPositive desc





 -- Showing countires with Highest death count for population
  Select location, max(cast(Total_deaths as int)) as Totaldeathcount
 From PortfolioProject ..CovidDeaths
 --where location like '%Pakistan%'
  where continent is not null
 Group by location, population
 order by Totaldeathcount desc

  -- Lets break things down by continent


 -- Showing countires with Highest death count for population
  Select continent, max(cast(Total_deaths as int)) as Totaldeathcount
 From PortfolioProject ..CovidDeaths
 --where location like '%Pakistan%'
  where continent is not null
 Group by continent
 order by Totaldeathcount desc

 -- Global numbers

 -- Deaths in entire world
  --Select  sum(new_cases) as total cases, sum(cast(new_deaths as int)) as total cases, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
 select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
 From PortfolioProject ..CovidDeaths
 --where location like '%Pakistan%'
 where continent is not null
 --group by date
 order by 1,2


 -- looking at total population vs vaccination 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

	With PopvsVac (Continent, location, date, population,New_Vaccinations, RollingPeopleVaccinated)
	as
	(
	  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast (vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *
From PopvsVac


-- TEMP TABLE
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast (vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visulaizations
Create view  PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT (INT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
