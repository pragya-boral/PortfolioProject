/*  
Covid 19 Data Exploration
*/



 SELECT *
 FROM PortfolioProject..coviddeaths$
 WHERE continent is not null
 ORDER BY 3,4


SELECT Location ,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..coviddeaths$
Order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contact covid in your country
SELECT Location ,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..coviddeaths$
where location like '%india%'
Order by 1,2


--Looking at total cases vs population
--showswhat percentage of population got covid

SELECT Location ,date,total_cases,population,(total_deaths/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..coviddeaths$
--where location like '%india%'
Order by 1,2

--Looking at countries with highest infection rate compared to population
SELECT Location ,MAX(total_cases),population,MAX((total_deaths/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..coviddeaths$
--where location like '%india%'
GROUP BY location,population
Order by PercentagePopulationInfected desc


--BREAKING INTO CONTINENTS
--showing continent with highest death count per population
SELECT continent ,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..coviddeaths$
--where location like '%india%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--global numbers
SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)  *100 as DeathPercentage -- ,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..coviddeaths$
--where location like '%india%'
WHERE continent is not null
--GROUP BY date
order by 1,2


-- Joining two tables

SELECT *
FROM PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..covidvaccines$ vac
ON dea.location = vac.location
and dea.date=vac.date



--Looking  at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
FROM PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..covidvaccines$ vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.continent is not null
ORDER by 1,2,3



--Looking  at total population vs vaccinations in India
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
FROM PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..covidvaccines$ vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.location like '%india%'
ORDER by 3,4


--looking at total vaccines ordered by location and date,so tat the new number of vaccines keep on adding to it.
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..covidvaccines$ vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.continent is not null
ORDER by 2,3


--Looking for total population vs vaccination
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..covidvaccines$ vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.continent is not null
ORDER by 2,3


--USE CTE
with PopvsVac ( continent,location,date,population,new_vaccinations,RollingPopulationVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location ,dea.date) as RollingPopulationVaccinated

FROM PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..covidvaccines$ vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.continent is not null
)
SELECT *,(RollingPopulationVaccinated/population)*100 as Vaccines_per_Population
FRom PopvsVac



CREATE VIEW PopvsVac AS
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location ,dea.date) as RollingPopulationVaccinated

FROM PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..covidvaccines$ vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.continent is not null


SELECT *
FROM PopvsVac
