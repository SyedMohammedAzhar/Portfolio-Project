select * from [dbo].[CovidDeaths] 
where continent is not null
order by 3,4


--select data that we need to use-----

select
	location, date, total_cases, new_cases,total_deaths,population

from [dbo].[CovidDeaths]
order by 1,2


-- looking at total cases vs total deaths
--likelyhood of dyin if you contract the virus in India

select
	location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as PercentageDeath

from [dbo].[CovidDeaths]
where Location like 'India'
order by 1,2

--total cases vs population in India
select
	location, date, total_cases,population,(total_cases/population)*100 as PercentageInfectedPopulation

from [dbo].[CovidDeaths]
where continent is not null
--where Location like 'India'
order by 1,2

--looking at countries with highest infection rate compared to population
select
	location,population, max(total_cases) as HighestInfectionCount,population,max((total_cases/population))*100 as PercentageInfectedPopulation

from [dbo].[CovidDeaths]
--where Location like 'India'
where continent is not null
group by location,population
order by PercentageInfectedPopulation desc

--showing the countries with most amount of death per population due to covid


select
	location, max(cast(total_deaths as int)) as HighestDeathCount
from [dbo].[CovidDeaths]
--where Location like 'India'
where continent is not null
group by location
order by HighestDeathCount desc

--looking things at continental level
--showing the continent with highest death counts
select
	continent, max(cast(total_deaths as int)) as HighestDeathCount
from [dbo].[CovidDeaths]
--where Location like 'India'
where continent is not  null
group by continent
order by HighestDeathCount desc

--global numbers

select
	 sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeath, (sum(cast(new_deaths as int))/sum(new_cases))*100 as TotalPercentageDeath--,total_deaths, (total_deaths/total_cases)*100 as PercentageDeath

from [dbo].[CovidDeaths]
--where Location like 'India'

where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccination
select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated,
(
from dbo.CovidDeaths cd
join [dbo].[CovidVaccinations] cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null and cd.location = 'Albania'
order by 2,3

--Use CTE

With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from dbo.CovidDeaths cd
join [dbo].[CovidVaccinations] cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null and cd.location = 'Albania'
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp Table
DROP Table if Exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_Vaccination numeric,RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from dbo.CovidDeaths cd
join [dbo].[CovidVaccinations] cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null and cd.location = 'Albania'
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating views for later visualization
Drop view PercentPopulationVaccinated
Create view PercentPopulationVaccinated as 
select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from dbo.CovidDeaths cd
join [dbo].[CovidVaccinations] cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated