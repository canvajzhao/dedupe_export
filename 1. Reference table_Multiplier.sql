create or replace transient table ds_prod.scratch.jzhao_ref_multiplier as (

with cte_ref_multiplier as (
    select * from 
(
  values 
 ('2022-03-01'::TIMESTAMP_LTZ,'2022-12-31'::TIMESTAMP_LTZ,'pt-BR',20,'locale','Free')
,('2022-03-01','2022-12-31','es-CO',20,'locale','Free')
,('2022-03-01','2022-12-31','es-AR',20,'locale','Free')
,('2022-03-01','2022-12-31','es-ES',20,'locale','Free')
,('2022-03-01','2022-12-31','ru-RU',20,'locale','Free')
,('2022-03-01','2022-12-31','tl-PH',20,'locale','Free')
,('2022-03-01','2022-12-31','tu-TR',20,'locale','Free')
,('2022-03-01','2022-12-31','es-MX',20,'locale','Free')
,('2022-03-01','2022-12-31','fr-FR',20,'locale','Free')
,('2022-03-01','2022-12-31','it-IT',20,'locale','Free')
,('2022-03-01','2022-12-31','de-DE',20,'locale','Free')
,('2022-03-01','2022-12-31','id-ID',20,'locale','Free')
,('2022-03-01','2022-12-31','es-419',20,'locale','Free')
,('2022-03-01','2022-12-31','uk-UA',20,'locale','Free')
,('2022-03-01','2022-12-31','Pro',27,'subscription','Pro')
,('2022-03-01','2022-12-31','Free',15,'subscription','Free')

,('2022-01-01','2022-02-28','pt-BR',20,'locale','Free')
,('2022-01-01','2022-02-28','es-CO',20,'locale','Free')
,('2022-01-01','2022-02-28','es-AR',20,'locale','Free')
,('2022-01-01','2022-02-28','es-ES',20,'locale','Free')
,('2022-01-01','2022-02-28','ru-RU',20,'locale','Free')
,('2022-01-01','2022-02-28','tl-PH',20,'locale','Free')
,('2022-01-01','2022-02-28','tu-TR',20,'locale','Free')
,('2022-01-01','2022-02-28','es-MX',20,'locale','Free')
,('2022-01-01','2022-02-28','fr-FR',20,'locale','Free')
,('2022-01-01','2022-02-28','it-IT',20,'locale','Free')
,('2022-01-01','2022-02-28','de-DE',20,'locale','Free')
,('2022-01-01','2022-02-28','id-ID',20,'locale','Free')
,('2022-01-01','2022-02-28','es-419',20,'locale','Free')
,('2022-01-01','2022-02-28','Pro',15,'subscription','Pro')
,('2022-01-01','2022-02-28','Free',27,'subscription','Free')
    

    
    
    
    
    
    
,('2021-10-01','2021-11-30','pt-BR',2,'locale','Free')
,('2021-10-01','2021-11-30','es-CO',2,'locale','Free')
,('2021-10-01','2021-11-30','es-AR',2,'locale','Free')
,('2021-10-01','2021-11-30','es-ES',2,'locale','Free')
,('2021-10-01','2021-11-30','ru-RU',2,'locale','Free')
,('2021-10-01','2021-11-30','tl-PH',2,'locale','Free')
,('2021-10-01','2021-11-30','Pro',3,'subscription','Pro')
,('2021-10-01','2022-11-30','Free',1,'subscription','Free')    
,('2021-01-01','2022-09-30','Pro',3,'subscription','Pro')
,('2021-01-01','2022-09-30','Free',1,'subscription','Free')

    
     )
AS  column_names 
    (eff_from_dt,
     eff_to_dt,
     multiplier_name , 
     weight,
     calculation_type,
     resource_pro_status
    ))
    
select * 
from cte_ref_multiplier
); 
    
