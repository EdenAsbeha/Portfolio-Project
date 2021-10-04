# Covid 19 data exploration

#Skills used joins, CTE's temp tables, windows functions, aggregate function,creating views and coverting data types

SELECT date 
FROM covidVaccinations;

SELECT * 
FROM coviddeaths
order by 3,4;

#Select data we will be working with

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

 #Total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from coviddeaths
order by 1,2;

 #This shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from coviddeaths
where location like '%states%'
order by 1,2;

 #Total Cases vs Population
 #Show the total percentage of population infected

select location, date, total_cases, population, (total_cases/population) *100 as percentpopulationinfected
from coviddeaths
where location like '%states%'
order by 1,2;

#Shows countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as percentpopulationinfected
from coviddeaths
group by location, population
order by percentpopulationinfected desc;

#Shows countries with highest death count per population

select location, MAX(cast(total_deaths AS REAl)) as TotalDeathsCount
from coviddeaths
where continent is not null
Group by location
Order by TotalDeathsCount desc;

#Breaking things down by continent
#Showing continents with  highest death count per population

select continent, max(cast(total_deaths AS REAL)) AS 'Total Death Count'
from coviddeaths
where continent is not null
group by continent
order by 'Total Death Count' desc;

#Showing the global daily total cases and total deaths

select date, SUM(cast(new_cases as real)) as total_cases, SUM(cast(new_deaths as real)) AS total_deaths, SUM(cast(new_deaths as real))/SUM(cast(new_cases as real))*100 as 'Death Percentage'
from coviddeaths
where continent is not null
group by date
order by 1,2;

#join deaths and vaccinations table on location and date

select *
from coviddeaths dea 
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date;

## Looking at total population vs vaccination
#Shows percentage of population that has recieved at least one Covid vaccine

select dea.continent, dea.location, dea.date, dea.population as Population, vac.people_vaccinated as 'Total Vaccinated'
from coviddeaths dea 
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;

## sum of new vaccinations per day by location and date

select dea.continent, dea.location, dea.date, dea.population as Population, vac.people_vaccinated as 'Total Vaccinated'
, sum(cast(vac.new_vaccinations as real)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated 
from coviddeaths dea 
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;

#Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population as Population, vac.people_vaccinated as 'Total Vaccinated'
, sum(cast(vac.new_vaccinations as real)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated 
from coviddeaths dea 
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
##order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac;

#Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
	(continent varchar(255),
    location varchar(255),
    ddate date,
    population numeric,
    new_vaccinations text,
    RollingPeopleVaccinated double);
Insert into PercentPopulationVaccinated
	select dea.continent, dea.location, str_to_date(dea.date,'%m/%d/%Y'), dea.population as Population, vac.people_vaccinated as 'Total Vaccinated'
     , sum(cast(vac.new_vaccinations as real)) over (partition by dea.location order by dea.location, dea.date) 
	as RollingPeopleVaccinated 
    from coviddeaths dea 
	join covidvaccinations vac
	  on dea.location = vac.location
      and dea.date = vac.date
    where dea.continent is not null;
    ##order by 2,3
select *, (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated;

# Creating view to store data for later visualization

create or replace view PercentPopulationVax as
select dea.continent, dea.location, str_to_date(dea.date,'%m/%d/%Y'), dea.population as Population, vac.people_vaccinated as 'Total Vaccinated'
     , sum(cast(vac.new_vaccinations as real)) over (partition by dea.location order by dea.location, dea.date) 
	as RollingPeopleVaccinated 
    from coviddeaths dea 
	join covidvaccinations vac
	  on dea.location = vac.location
      and dea.date = vac.date
    where dea.continent is not null;
    ##order by 2,3
	
