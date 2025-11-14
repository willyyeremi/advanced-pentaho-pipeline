create table public.dim_date as (
	select
		id
		,datum as date
		,EXTRACT(EPOCH FROM datum)::bigint AS epoch
		,EXTRACT(YEAR FROM datum)::int AS year
		,EXTRACT(QUARTER FROM datum)::int as quarter
		,EXTRACT(MONTH FROM datum)::int as month
		,TO_CHAR(datum, 'TMMonth') AS month_name
		,EXTRACT(WEEK FROM datum)::int AS "week_of_year"
		,EXTRACT(DOY FROM datum)::int as day_of_year
		,EXTRACT(DAY FROM datum)::int as day_of_month
		,EXTRACT(ISODOW FROM datum)::int as day_of_week
		,TO_CHAR(datum, 'TMDay') AS day_name
	FROM 
		(SELECT 
			"day" + 1 as "id"
			,'1970-01-01'::DATE + SEQUENCE.DAY AS datum
		FROM 
			GENERATE_SERIES(0, 47846) AS SEQUENCE (DAY)) as list_date
)
;

