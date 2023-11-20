--select  location, max(total_cases) as HighestInfectionCount, population, (cast(total_cases as float)/cast(population as float)*100) as InfectionPercentage
--from CovidDeaths$
----where location like '%states'
--group by location, population, total_cases
-- order by 4  desc

 -- countries with highest  death count per population

select  location, max(cast(total_deaths as int)) as DeathTotal
from CovidDeaths$
where continent is not null
group by location
order by 2 desc

-- CTE

with PoPvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations))  over  (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$  as dea
join CovidVaccinations$  as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated / population)*100 as PercentPopulationVaccinated
from PoPvsVac

-- Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations))  over  (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$  as dea
join CovidVaccinations$  as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated / population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated