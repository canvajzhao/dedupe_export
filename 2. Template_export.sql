
create or replace transient table ds_prod.scratch.jzhao_dedupe_export_data as (

-- Grab raw template usage table
WITH cte_raw_template_history AS
(
          SELECT    t1.event_id,
                    t1.usage_period AS payment_period,
                    t1.user_id,
                    t1.brand_id,
                    t1.template_id AS resource_id,
                    t1.usage_type,
                    t2.resource_type,
                    t2.resource_subtype,
                    t2.locale_code AS resource_locale,
                    CASE
                        WHEN t2.is_pro_resource THEN 'Pro'
                        ELSE 'Free'
                    END AS resource_pro_status,
                    t2.resource_brand_display_name,
                    t2.resource_brand_type,
                    t2.is_creators_program,
                    t2.is_internal_creator,
                    t2.is_internal_resource_brand,
                    t3.resource_brand_created_at,
                    t3.resource_brand_country_code,
                    t3.resource_brand_locale_code,
                    t3.is_super_creator,
                    t3.is_ambassador
          FROM      ds_prod.model.fact_template_usage t1
          LEFT JOIN ds_prod.model.dim_resource t2
          ON        t1.template_id=t2.resource_id
          LEFT JOIN ds_prod.model.dim_creator t3
          ON        t1.brand_id = t3.resource_brand_id
          WHERE     usage_type ='export'
          AND       is_billable_usage
          --- adding sample month for testing
          AND       usage_period in ('2022-05-01', '2021-12-01','2021-10-01','2021-05-01') 
          -- AND       usage_period >='2022-03-01'
          -- AND       usage_period <'2022-07-01'),
    ),
-- Join raw usage data with usage multiplier table
cte_tempalte_usage_jan22tojun22 AS
(
          SELECT    t1.*,
                    CASE
                        WHEN weight IS NULL
                        AND       t1.resource_pro_status='Pro' THEN 27
                        WHEN weight IS NULL
                        AND       t1.resource_pro_status='Free' THEN 15
                        ELSE weight
                    END                  AS usage_multiplier,
                    (1*usage_multiplier) AS weighted_usages
          FROM      cte_raw_template_history t1
          LEFT JOIN
                    (
                           SELECT *
                           FROM   ds_prod.scratch.jzhao_ref_multiplier
                           WHERE  calculation_type ='locale' ) t2
          ON        t1.resource_locale=t2.multiplier_name
          AND       t1.resource_pro_status=t2.resource_pro_status
          AND       t1.payment_period BETWEEN t2.eff_from_dt AND   t2.eff_to_dt 
          WHERE     t1.payment_period >='2022-01-01'
          AND       t1.payment_period <'2022-07-01'

),

cte_tempalte_usage_dec21 AS
(
          SELECT    t1.*,
                    CASE
                        WHEN weight IS NULL
                        AND       t1.resource_pro_status='Pro' THEN 30
                        WHEN weight IS NULL
                        AND       t1.resource_pro_status='Free' THEN 15
                        ELSE weight
                    END                  AS usage_multiplier,
                    (1*usage_multiplier) AS weighted_usages
          FROM      cte_raw_template_history t1
          LEFT JOIN
                    (
                           SELECT *
                           FROM   ds_prod.scratch.jzhao_ref_multiplier
                           WHERE  calculation_type ='locale' ) t2
          ON        t1.resource_locale=t2.multiplier_name
          AND       t1.resource_pro_status=t2.resource_pro_status
          AND       t1.payment_period BETWEEN t2.eff_from_dt AND   t2.eff_to_dt 
          WHERE     t1.payment_period >='2021-12-01'
          AND       t1.payment_period <'2022-01-01'

),


cte_tempalte_usage_oct21tonov21 AS
(
          SELECT    t1.*,
                    CASE
                        WHEN weight IS NULL
                        AND       t1.resource_pro_status='Pro' THEN 3
                        WHEN weight IS NULL
                        AND       t1.resource_pro_status='Free' THEN 1
                        ELSE weight
                    END                  AS usage_multiplier,
                    (1*usage_multiplier) AS weighted_usages
          FROM      cte_raw_template_history t1
          LEFT JOIN
                    (
                           SELECT *
                           FROM   ds_prod.scratch.jzhao_ref_multiplier
                           WHERE  calculation_type ='locale' ) t2
          ON        t1.resource_locale=t2.multiplier_name
          AND       t1.resource_pro_status=t2.resource_pro_status
          AND       t1.payment_period BETWEEN t2.eff_from_dt AND   t2.eff_to_dt 
          WHERE     t1.payment_period >='2021-10-01'
          AND       t1.payment_period <'2021-12-01'

),
cte_tempalte_usage_jan21tosep21 AS
(
          SELECT    t1.*,
                    CASE
                        WHEN 
                             t1.resource_pro_status='Pro' THEN 3
                       
                        ELSE 1                    
                        END                  AS usage_multiplier,
                    (1*usage_multiplier) AS weighted_usages
          FROM      cte_raw_template_history t1
         
          WHERE     t1.payment_period >='2021-01-01'
          AND       t1.payment_period <'2021-10-01'
),
    
    
cte_tempalte_usage_raw as 
(
 select * from cte_tempalte_usage_jan22tojun22
 union all
 select * from  cte_tempalte_usage_dec21
 union all 
 select * from cte_tempalte_usage_oct21tonov21
 union all 
 select * from cte_tempalte_usage_jan21tosep21
 ),

-- Create element level data

 cte_raw_elements_history AS
(
          SELECT    t1.event_id,
                    t1.payment_period,
                    t1.usage_user_id     AS user_id,
                    t1.resource_brand_id AS brand_id,
                    t1.resource_id,
                    t1.usage_type,
                    t1.usage_multiplier,
                    t1.resource_type,
                    t1.resource_subtype,
                    t2.locale_code AS resource_locale,
    
                     CASE
                        WHEN t2.is_pro_resource THEN 'Pro'
                        ELSE 'Free'
                    END AS resource_pro_status,
                    t2.resource_brand_display_name,
                    t3.resource_brand_created_at,
                    t3.resource_brand_type,
                    t3.resource_brand_country_code,
                    t3.resource_brand_locale_code,
                    t3.is_super_creator,
                    t3.is_ambassador
          FROM      ds_prod.staging._fact_license_usage t1
          LEFT JOIN ds_prod.model.dim_resource t2
          ON        t1.resource_id = t2.resource_id
          LEFT JOIN ds_prod.model.dim_creator t3
          ON        t1.usage_user_id = t3.resource_brand_id
          WHERE     t1.event_time >= '2022-06-01'
          AND       t1.event_time < '2022-07-01'
          AND       t1.is_billable_usage
          AND       prerequisite IS NOT NULL
          AND       usage_type ='export' ),
          
          
cte_dedupe_data as (          
-- Create brand-level aggreation
SELECT   payment_period,
         brand_id, 
     'element' as resource_overall_type,
         resource_brand_display_name,
         resource_type,
         resource_subtype,
         resource_locale,
         resource_pro_status,
         resource_brand_type,
         is_super_creator,
         is_ambassador,
         Count(DISTINCT event_id) AS usage,
         Sum(usage_multiplier)    AS weighted_usage
FROM     cte_raw_elements_history
group by 
payment_period,
         brand_id, 
         resource_brand_display_name,
         resource_type,
         resource_subtype,
         resource_locale,
         resource_pro_status,
         resource_brand_type,
         is_super_creator,
         is_ambassador
union all 

SELECT   payment_period,
         brand_id,
         'tempalte' as resource_overall_type,
         resource_brand_display_name,
         resource_type,
         resource_subtype,
         resource_locale,
         resource_pro_status,
         resource_brand_type,
         is_super_creator,
         is_ambassador,
         Count(DISTINCT event_id) AS usage,
         Sum(usage_multiplier)    AS weighted_usage
FROM     cte_tempalte_usage_raw
GROUP BY payment_period,
         brand_id,
         resource_overall_type,
         resource_brand_display_name,
         resource_type,
         resource_subtype,
         resource_locale,
         resource_pro_status,
         resource_brand_type,
         is_super_creator,
         is_ambassador
    )
    
    select * from cte_dedupe_data
    
);
    

-- This is QA to see there are no duplicated recordsSELECT Count(*) AS cnt

