with 
	latest_run_batch_id as (
		select 
			a.object_name 
			,max(a.id_batch) as id_batch
		from
			job.logging_channel_log_table a
		where
			cast(a.log_date as date) = current_date
			and
			a.channel_id = a.root_channel_id
		group by
			a.object_name
	)
	,job_log_combination as (
		select
			b.channel_id 
			,b.logdate 
			,b.jobname as root_job_name
			,b.log_field as root_job_log_field 
			,c.transname as executing_job_name
			,b.log_field as executing_job_log_field 
			,c.stepname as job_step_name 
			,c.log_field as job_step_error_log_field
			,b.executing_server 
			,b.executing_user 
			,b.client
			,c.log_date 
			,case
				when c.stepname = 'Abort job' then 0
				else c.errors 
			end as errors
		from
			latest_run_batch_id as a
			left join
			job.job_log_table b
				on
				a.id_batch = b.id_job
			left join
			job.job_entry_log_table c
				on
				b.id_job = c.id_batch 
		union all
		select
			lclt2.root_channel_id as channel_id
			,jlt1.logdate
			,jlt1.jobname as root_job_name
			,jlt1.log_field as root_job_log_field 
			,jelt1.transname as executing_job_name
			,jlt2.log_field as executing_job_log_field
			,jelt1.stepname as job_step_name
			,jelt1.log_field as job_step_error_log_field
			,jlt1.executing_server 
			,jlt1.executing_user 
			,jlt1.client
			,lclt1.log_date 
			,jelt1.errors 
		from
			job.logging_channel_log_table lclt1
			inner join
			latest_run_batch_id
				on
				lclt1.id_batch = latest_run_batch_id.id_batch 
			inner join
			job.logging_channel_log_table lclt2
				on
				lclt1.parent_channel_id = lclt2.channel_id 
				and
				lclt1.logging_object_type  = 'JOB'
			left join
			job.job_log_table jlt1
				on
				lclt2.root_channel_id  = jlt1.channel_id  
			left join
			job.job_log_table jlt2
				on
				lclt1.channel_id  = jlt2.channel_id 
			left join
			job.job_entry_log_table jelt1
				on
				jlt2.id_job = jelt1.id_batch	
	)
select
	job_log_combination.logdate
	,job_log_combination.root_job_name
	,job_log_combination.root_job_log_field 
	,job_log_combination.executing_job_name
	,job_log_combination.executing_job_log_field
	,job_log_combination.job_step_name
	,job_log_combination.job_step_error_log_field
	,case
		when 		
			job_log_combination.channel_id = d.root_channel_id 
			and
			e.logging_object_type = 'STEP'
				then '1'
		else '0'
	end as is_transformation
	,f.log_field as transformation_log_field
	,g.stepname as transformation_step_name
	,g.log_field as transformation_step_log_field
	,case
		when 
			job_log_combination.errors = 1 
			and
			job_log_combination.root_job_name = job_log_combination.executing_job_name
				then
					concat_ws('/',job_log_combination.root_job_name,job_log_combination.job_step_name)
		when 
			job_log_combination.errors = 1 
			and
			job_log_combination.root_job_name <> job_log_combination.executing_job_name
				then
					concat_ws('/',job_log_combination.root_job_name,job_log_combination.executing_job_name,job_log_combination.job_step_name)
		when f.errors = 1 then concat_ws('/',job_log_combination.root_job_name,job_log_combination.executing_job_name,job_log_combination.job_step_name,g.stepname)
	end as error_path
	,case
		when
			job_log_combination.errors = 1
			or
			f.errors = 1
				then 1
		else 0
	end as is_error
	,job_log_combination.executing_server 
	,job_log_combination.executing_user 
	,job_log_combination.client 
from
	job_log_combination
	left join
	job.logging_channel_log_table d
		on
		job_log_combination.channel_id = d.root_channel_id
		and
		job_log_combination.job_step_name = d.object_name
		and 
		d.logging_object_type in ('TRANS')
	left join
	transformation.logging_channels e
		on
		d.channel_id = e.root_channel_id 
		and
		e.logging_object_type = 'STEP'
	left join
	transformation.transformation f
		on
		e.root_channel_id = f.channel_id 
	left join
	transformation.step g
		on
		e.channel_id = g.channel_id 
--where
--	job_log_combination.errors = 1
--	or
--	f.errors = 1
order by
	job_log_combination.logdate 
;