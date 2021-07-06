select *
from Portfolioproject..Coviddata1
where continent is not null
order by 3,4

--select *
--from Portfolioproject..Coviddatavaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from Portfolioproject..Coviddata1
where continent is not null
order by 1,2

--Total cases vs Total deaths
--showing the likelihood of dying if ou contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/ total_Cases)*100 as death_percentage
from Portfolioproject..Coviddata1
where location like '%India%'
and continent is not null
order by 1,2


--Total cases vs Population
--shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
from Portfolioproject..Coviddata1
--where location like '%India%'
order by 1,2

--Countries with the highest infection rate compared to the population
select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population)*100) as percent_population_infected
from Portfolioproject..Coviddata1
--where location like '%India%'
group by population, location
order by percent_population_infected desc

--Countries showing highest death count per population
select location, MAX(cast(total_deaths as int)) as total_death_count
from Portfolioproject..Coviddata1
--where location like '%India%'
where continent is not null
group by location
order by total_death_count desc

--showing the continents with highest death count per population

select continent, MAX(cast(total_deaths as int)) as total_death_count
from Portfolioproject..Coviddata1
--where location like '%India%'
where continent is not null
group by continent
order by total_death_count desc

--global numbers

select  SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as death_percentage
from Portfolioproject..Coviddata1 
--where location like '%India%'
where continent is not null
--group by date
order by 1,2

--total population vs vaccinations
select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
sum(convert(int, va.new_vaccinations)) over (partition by de.location order by de.location, de.date) as rolling_people_vaccinated
from Portfolioproject..Coviddata1 de
join Portfolioproject..Coviddatavaccinations va
on de.location = va.location
and de.date = va.date
where de.continent is not null
order by 2,3

--CTE

With popvsvac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
sum(convert(int, va.new_vaccinations)) over (partition by de.location order by de.location, de.date) as rolling_people_vaccinated
from Portfolioproject..Coviddata1 de
join Portfolioproject..Coviddatavaccinations va
on de.location = va.location
and de.date = va.date
where de.continent is not null
--order by 2,3
)
select *, (rolling_people_vaccinated/population)*100
from popvsvac

--Temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
insert into #percentpopulationvaccinated
select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
sum(convert(int, va.new_vaccinations)) over (partition by de.location order by de.location, de.date) as rolling_people_vaccinated
from Portfolioproject..Coviddata1 de
join Portfolioproject..Coviddatavaccinations va
on de.location = va.location
and de.date = va.date
where de.continent is not null
order by 2,3
select *, (rolling_people_vaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store the data later for visualization

create view percentpopulationvaccinated as
select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
sum(convert(int, va.new_vaccinations)) over (partition by de.location order by de.location, de.date) as rolling_people_vaccinated
from Portfolioproject..Coviddata1 de
join Portfolioproject..Coviddatavaccinations va
on de.location = va.location
and de.date = va.date
where de.continent is not null
--order by 2,3

select * from percentpopulationvaccinated
