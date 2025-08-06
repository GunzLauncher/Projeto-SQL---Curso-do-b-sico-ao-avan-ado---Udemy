-- (Query 1) Receita, leads, conversão e ticket médio mês a mês
-- Colunas: mês, leads (#), vendas (#), receita (k, R$), conversão (%), ticket médio (k, R$)
with
	leads as (
		select
			date_trunc('month', visit_page_date)::date as visit_page_month,
			count(*) as visitas
		from sales.funnel
		group by 
			visit_page_month
		order by 
			visit_page_month
	),

	payments as (

		select
			date_trunc('month', paid_date)::date as paid_month,
			count(paid_date) as total_vendas,
			sum(sales.products.price * (1+sales.funnel.discount)) as receita
		from sales.funnel
		left join sales.products
			on sales.funnel.product_id = sales.products.product_id
		where paid_date is not null
		group by 
			paid_month
		order by 
			paid_month
)

select 
	leads.visit_page_month as "mês",
	leads.visitas as "leads (#)",
	pay.total_vendas as "vendas (#)",
	pay.receita/1000 as "receita (k, R$)",
	(pay.total_vendas::float/leads.visitas::float) * 100 as "conversão (%)",
	(pay.receita/pay.total_vendas)/1000 as "ticket médio (k, R$)"
from leads
	left join payments as pay
		on leads.visit_page_month = pay.paid_month


-- (Query 2) Estados que mais venderam
-- Colunas: país, estado, vendas (#)

select 
	'Brazil' as "país",
	cus.state as "estado",
	count(fun.paid_date) as "vendas (#)"
from sales.funnel as fun
left join sales.customers as cus
	on fun.customer_id = cus.customer_id
where fun.paid_date between '2021-08-01' and '2021-08-31'
group by cus.state
order by "vendas (#)" desc
limit 5


-- (Query 3) Marcas que mais venderam no mês
-- Colunas: marca, vendas (#)

select
	prod.brand as Marca,
	count(fun.paid_date) as "vendas(#)"
from sales.funnel as fun
left join sales.products as prod
	on fun.product_id = prod.product_id
where (fun.paid_date is not null) and (fun.paid_date between '2021-08-01' and '2021-08-31')
group by Marca
order by "vendas(#)" desc
limit 5

-- (Query 4) Lojas que mais venderam
-- Colunas: loja, vendas (#)

select
	sto.store_name as Loja,
	count(fun.paid_date) as "vendas(#)"
from sales.funnel as fun
left join sales.stores as sto
	on fun.store_id = sto.store_id
where (fun.paid_date is not null) and (fun.paid_date between '2021-08-01' and '2021-08-31')
group by Loja
Order by "vendas(#)" desc
limit 5

-- (Query 5) Dias da semana com maior número de visitas ao site
-- Colunas: dia_semana, dia da semana, visitas (#)

select
	extract ('dow' from visit_page_date) as dia_semana,
	case 
		when extract ('dow' from visit_page_date) = 0 then 'domingo'
		when extract ('dow' from visit_page_date) = 1 then 'segunda'
		when extract ('dow' from visit_page_date) = 2 then 'terca'
		when extract ('dow' from visit_page_date) = 3 then 'quarta'
		when extract ('dow' from visit_page_date) = 4 then 'quinta'
		when extract ('dow' from visit_page_date) = 5 then 'sexta'
		when extract ('dow' from visit_page_date) = 6 then 'sabado'
		else null end as "dia da semana",
	count(*) as "visitas (#)"
from sales.funnel
where visit_page_date between '2021-08-01' and '2021-08-31'
group by dia_semana
order by dia_semana


