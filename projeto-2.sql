-- (Query 1) Gênero dos leads
-- Colunas: gênero, leads(#)

select
	case
		when gen.gender = 'male' then 'homens'
		when gen.gender = 'female' then 'mulheres'
		end as "Genero",
	count(*) as "leads (#)"
from sales.customers as cus
left join temp_tables.ibge_genders as gen
 on lower(cus.first_name) = lower(gen.first_name)
group by gen.gender


-- (Query 2) Status profissional dos leads
-- Colunas: status profissional, leads (%)

select
	case
		when professional_status = 'freelancer' then 'freelancer'
		when professional_status = 'retired' then 'aposentado'
		when professional_status = 'clt' then 'clt'
		when professional_status = 'self_employed' then 'autonomo(a)'
		when professional_status = 'other' then 'outro'
		when professional_status = 'businessman' then 'empresario(a)'
		when professional_status = 'civil_servant' then 'funcionario(a) publico'
		when professional_status = 'student' then 'estudante'
		end as "status profissional",
	(count(*)::float)/(select count(*) from sales.customers) as "leads (%)"
from sales.customers
group by "status profissional"
order by "leads (%)"

-- (Query 3) Faixa etária dos leads
-- Colunas: faixa etária, leads (%)

select
	case
		when datediff('years', birth_date, current_date) < 20 then '0-20'
		when datediff('years', birth_date, current_date) < 40 then '20-40'
		when datediff('years', birth_date, current_date) < 60 then '40-60'
		when datediff('years', birth_date, current_date) < 80 then '60-80'
		else '80+'
		end as "faixa etária",
	(count(*)::float)/(select count(*) from sales.customers) as "leads (%)"
from sales.customers
group by "faixa etária"
order by "leads (%)"

-- (Query 4) Faixa salarial dos leads
-- Colunas: faixa salarial, leads (%), ordem

select
	case
		when  income < 5000 then '0-5000'
		when  income < 10000 then '5000-10000'
		when  income < 15000 then '10000-15000'
		when  income < 20000 then '15000-20000'
		else '20000+'
		end as "faixa salarial",
	(count(*)::float)/(select count(*) from sales.customers) as "leads (%)",
	case
		when  income < 5000 then 1
		when  income < 10000 then 2
		when  income < 15000 then 3
		when  income < 20000 then 4
		else 5
		end as "ordem"
from sales.customers
group by "faixa salarial", "ordem"
order by "ordem"

-- (Query 5) Classificação dos veículos visitados
-- Colunas: classificação do veículo, veículos visitados (#)
-- Regra de negócio: Veículos novos tem até 2 anos e seminovos acima de 2 anos


with
	class_veiculos as (
	
		select
			fun.visit_page_date,
			prod.model_year,
			extract('year' from fun.visit_page_date) - prod.model_year::int as "idade do carro na data da visita",
			case
				when extract('year' from fun.visit_page_date) - prod.model_year::int > 2 then 'seminovo'
				else 'novo'
				end as "classificação do veículo"
		from sales.funnel as fun
		left join sales.products as prod
			on fun.product_id = prod.product_id
	)

select
	"classificação do veículo",
	count(*) as "veículos visitados (#)"
from class_veiculos
group by "classificação do veículo"
order by "veículos visitados (#)"

-- (Query 6) Idade dos veículos visitados
-- Colunas: Idade do veículo, veículos visitados (%), ordem
-- , , 

with
	idade_veiculos as (
		select
			fun.visit_page_date,
			prod.model_year,
			extract('year' from fun.visit_page_date) - prod.model_year::int as "idade do carro na data da visita",
			case
				when extract('year' from fun.visit_page_date) - prod.model_year::int <= 2 then 'ate 2 anos'
				when extract('year' from fun.visit_page_date) - prod.model_year::int <= 4 then 'de 2 a 4 anos'
				when extract('year' from fun.visit_page_date) - prod.model_year::int <= 6 then 'de 4 a 6 anos'
				when extract('year' from fun.visit_page_date) - prod.model_year::int <= 8 then 'de 6 a 8 anos'
				when extract('year' from fun.visit_page_date) - prod.model_year::int <= 10 then 'de 8 a 10 anos'
				else 'acima de 10 anos'
				end as "Idade do veículo",
			case
				when extract('year' from fun.visit_page_date) - prod.model_year::int <= 2 then '1'
				when extract('year' from fun.visit_page_date) - prod.model_year::int <= 4 then '2'
				when extract('year' from fun.visit_page_date) - prod.model_year::int <= 6 then '3'
				when extract('year' from fun.visit_page_date) - prod.model_year::int <= 8 then '4'
				when extract('year' from fun.visit_page_date) - prod.model_year::int <= 10 then '5'
				else '6'
				end as "Ordem"
		from sales.funnel as fun
		left join sales.products as prod
			on fun.product_id = prod.product_id
		)

select
	"Idade do veículo",
	count(*)::float/(select count(*) from sales.funnel) as "veículos visitados (%)",
	"Ordem"
from idade_veiculos
group by "Idade do veículo", "Ordem"
order by "Ordem"

-- (Query 7) Veículos mais visitados por marca
-- Colunas: brand, model, visitas (#)

select
	prod.brand,
	prod.model,
	count (fun.*) as "visitas (#)"
from sales.products as prod
left join sales.funnel as fun
	on prod.product_id = fun.product_id
group by prod.brand, prod.model
order by prod.brand
