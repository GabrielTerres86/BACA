create or replace view CREDITO.tbepr_renegociacao_contrato as
select  trc.cdcooper
       ,trc.nrdconta
       ,trc.nrctremp
       ,trc.nrctrepr
       ,trc.nrversao
from CECRED.tbepr_renegociacao_contrato   trc
/
