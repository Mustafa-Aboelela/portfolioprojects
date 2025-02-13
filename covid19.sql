

ALTER DATABASE [portoflio project] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
EXEC sp_renamedb 'portoflio project', 'PortfolioProject';
ALTER DATABASE [PortfolioProject] SET MULTI_USER;
 -----------------------------------

 select * from coviddeath
 where population is not null
 order by 1,2
 
  --select * from covidvaccination
 --order by 1,3

 select country ,date ,total_cases, new_cases, total_deaths, population
 from coviddeath
 order by 1,2

 select country, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
 from coviddeath
 where country like '%states%' and total_cases <> 0
 order by 1,2

 select country, date, total_cases, population, (total_cases/population)*100 as casepercentage
 from coviddeath
 where country like '%states%' and population is not null and total_cases is not null
 and continent is not null
 order by 1,2

 select country,population ,max(total_cases)as highestinfectioncount, max(total_cases/population)*100 as percentpopulationinfected
 from coviddeath
 where continent is not null
 group by country,population
 order by percentpopulationinfected desc

 select country,max(total_deaths)as totaldeathcount 
 from coviddeath
 where continent is not null
 group by country
 order by totaldeathcount desc

 select continent ,max(total_deaths )as totaldeathcount
 from coviddeath
 where continent is not null 
 group  by continent
 order by totaldeathcount desc

 
 select sum(new_cases)as totalcases ,sum(new_deaths)as totaldeath ,
 sum(new_deaths)/sum(new_cases)*100 as deathpercentage
 from coviddeath
 where continent is not null 
 order by 1,2

 with popvsvac (continent, location, date ,population,new_vaccination,rollingpeoplevaccinated)
 as 
 (select dea.continent ,dea.country, dea.date,dea.population, vac.new_vaccinations
 ,sum(convert(bigint,new_vaccinations))over (partition by dea.country order by dea.country,dea.date)as
 rollingpeoplevaccinated
 from coviddeath dea join covidvaccination vac
 on dea.country =vac.country
 and dea.date = vac.date
 where dea.continent is not null)

 select *,(rollingpeoplevaccinated/population)*100
 from popvsvac


--------------------------
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
country nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent ,dea.country, dea.date,dea.population, vac.new_vaccinations
 ,sum(convert(numeric,new_vaccinations))over (partition by dea.country order by dea.country,dea.date)as
 rollingpeoplevaccinated
 from coviddeath dea join covidvaccination vac
 on dea.country =vac.country
 and dea.date = vac.date
 --where dea.continent is not null

 select * ,(rollingpeoplevaccinated/population)*100
 from #percentpopulationvaccinated


 create view percentpopulationvaccinated as 
select dea.continent ,dea.country, dea.date,dea.population, vac.new_vaccinations
 ,sum(convert(numeric,new_vaccinations))over (partition by dea.country order by dea.country,dea.date)as
 rollingpeoplevaccinated
 from coviddeath dea join covidvaccination vac
 on dea.country =vac.country
 and dea.date = vac.date
 where dea.continent is not null

 select * from percentpopulationvaccinated