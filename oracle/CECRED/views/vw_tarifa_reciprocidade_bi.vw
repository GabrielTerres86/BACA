create or replace view cecred.vw_tarifa_reciprocidade_bi as
select cco.cdcooper, cco.nrconven,
       fn_retorna_val_trf_reciproc(cco.cdcooper,cco.nrconven,2,'A4',1) as vltarcooreg_pf,
       fn_retorna_val_trf_reciproc(cco.cdcooper,cco.nrconven,6,'',1) as vltarcooliq_pf,
       fn_retorna_val_trf_reciproc(cco.cdcooper,cco.nrconven,2,'P1',1) as vltarceereg_pf,
       fn_retorna_val_trf_reciproc(cco.cdcooper,cco.nrconven,76,'',1) as vltarceeliq_pf,
       fn_retorna_val_trf_reciproc(cco.cdcooper,cco.nrconven,2,'A4',2) as vltarcooreg_pj,
       fn_retorna_val_trf_reciproc(cco.cdcooper,cco.nrconven,6,'',2) as vltarcooliq_pj,
       fn_retorna_val_trf_reciproc(cco.cdcooper,cco.nrconven,2,'P1',2) as vltarceereg_pj,
       fn_retorna_val_trf_reciproc(cco.cdcooper,cco.nrconven,76,'',2) as vltarceeliq_pj
from crapcco cco
/*where cco.flrecipr = 1*/;