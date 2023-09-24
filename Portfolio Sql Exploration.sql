  --select * from Projectportfolio..Coviddeaths


--select * from Projectportfolio..covidvaccinations

-- lets clean the data and have some columns to minimize the data 


--select location,date,total_cases,New_cases,total_Deaths,population from Projectportfolio..Coviddeaths
--order by 1,2

--looking at totalDeaths over total Cases 
--shoes likelihood dying percentage in your country 

select location,date,total_deaths,total_cases,(CONVERT(float, total_deaths) / nullif(CONVERT(float, total_cases),0))*100
as DeathPercentage
from Projectportfolio..Coviddeaths
where location like 'c%ina'
order by 1,2

--look into totaldeaths over population
--shows how much population get infected by the covid 
select location,date,total_cases,population,(CONVERT(float, total_cases) / nullif(CONVERT(float, population),0))*100
as DeathPercentageoverpopulation
from Projectportfolio..Coviddeaths
where location like 'c%ina'
order by 1,2











-- looking at the countries with highest infectious rates compared to populations 
select location,population,max(total_cases) as HighestInfectedCountriesDuringCovid,
(CONVERT(float, max(total_cases)) / nullif(CONVERT(float, population),0))*100
as Maxinfectedpopulation
from Projectportfolio..Coviddeaths
group by location,population
--where location like 'c%ina'
order by Maxinfectedpopulation desc 


--Showing countries with highest death count over population 
select location,MAX(cast (total_deaths as int)) as TotalDeathCount
from Projectportfolio..Coviddeaths
where continent is not null 
group by location
--where location like 'c%ina'
order by TotalDeathCount desc 


--Lets Just Dig into continental working 

--SHOWING THE DEATHCOUNT OF THE CONTINENT AS PER POPULATION 

select continent,MAX(cast (total_deaths as int)) as TotalDeathCount
from Projectportfolio..Coviddeaths
where continent is not null
group by continent 
--where location like 'c%ina'
order by TotalDeathCount desc 


-- GLOBAL NUMBERS 


select sum(new_cases) as ncases ,sum(new_deaths) as ndeaths,sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from Projectportfolio..Coviddeaths
WHERe continent is not null 
--GROUP BY DATE	
order by 1,2

select * from Projectportfolio..Coviddeaths ndeaths
join Projectportfolio.dbo.covidvaccinations nvaccination
	on ndeaths.location = nvaccination.location	
	and ndeaths.date= nvaccination.date


--Looking at total population vs vaccinations


select ndeaths.continent, ndeaths.location, ndeaths.date,ndeaths.population,nvaccination.new_vaccinations	
,sum(convert(float,nvaccination.new_vaccinations)) over (partition by ndeaths.location,ndeaths.date) as Sumofvac
from Projectportfolio..Coviddeaths ndeaths
join Projectportfolio..covidvaccinations nvaccination
	on ndeaths.location = nvaccination.location	
	and ndeaths.date= nvaccination.date
	where ndeaths.continent is not null
	order by 2,3


-- With Cte we are to use and check the percentage 


WITH SUMOFVACVSPOPULATION (CONTINENT,LOCATION,DATE,POPULATION,NEW_VACCINATION,SUMOFVAC)
AS
(

select ndeaths.continent, ndeaths.location, ndeaths.date,ndeaths.population,nvaccination.new_vaccinations	
,sum(CAST(nvaccination.new_vaccinations AS FLOAT)) over (partition by ndeaths.location ORDER BY NDEATHS.LOCATION,ndeaths.date) as Sumofvac
from Projectportfolio..Coviddeaths ndeaths
join Projectportfolio..covidvaccinations nvaccination
	on ndeaths.location = nvaccination.location	
	and ndeaths.date= nvaccination.date
	where ndeaths.continent is not null
	--order by 2,3

)
SELECT *, (SUMOFVAC/POPULATION)* 100 AS PERCENTVACPEOPLE
FROM SUMOFVACVSPOPULATION



--BY USING TEMP_TABLES 
drop table if exists #PERCPOPPEOPLEVAC
CREATE TABLE #PERCPOPPEOPLEVAC
(
CONTINENT nVARCHAR(255),LOCATION NVARCHAR(255),DATE DATETIME,POPULATION NUMERIC ,
NEW_VACCINATIONS numeric,SUMOFVAC numeric 
)

INSERT INTO #PERCPOPPEOPLEVAC 
select ndeaths.continent, ndeaths.location, ndeaths.date,ndeaths.population,nvaccination.new_vaccinations	
,sum(CAST(nvaccination.new_vaccinations AS FLOAT)) over (partition by ndeaths.location ORDER BY NDEATHS.LOCATION,ndeaths.date) as Sumofvac
from Projectportfolio..Coviddeaths ndeaths
join Projectportfolio..covidvaccinations nvaccination
	on ndeaths.location = nvaccination.location	
	and ndeaths.date= nvaccination.date
	--where ndeaths.continent is not null
	--order by 2,3


SELECT *, (SUMOFVAC/POPULATION)*100 AS PERCENTVACPEOPLE
FROM #PERCPOPPEOPLEVAC




-- Creating view to use for later visualizations 

create view PERCPOPPEOPLEVAC as 
select ndeaths.continent, ndeaths.location, ndeaths.date,ndeaths.population,nvaccination.new_vaccinations	
,sum(CAST(nvaccination.new_vaccinations AS FLOAT)) over (partition by ndeaths.location ORDER BY NDEATHS.LOCATION,ndeaths.date) as Sumofvac
from Projectportfolio..Coviddeaths ndeaths
join Projectportfolio..covidvaccinations nvaccination
	on ndeaths.location = nvaccination.location	
	and ndeaths.date= nvaccination.date
	where ndeaths.continent is not null
	--order by 2,3.



select * from PERCPOPPEOPLEVAC