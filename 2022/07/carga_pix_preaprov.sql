begin 
 insert into credito.TBCRED_PREAPROV
(select 142 idcarga,
       2 tppreapr,
       a.cdcooper,
       a.tpcarga,
       '13/07/2022' dtmvtolt,
       a.cdcarga_sas,
       'Carga PIX teste' dscarga,
       1 insituacao,
       a.cdprocesso_sas,
       a.dsmensagem_aviso,
       'pix.csv' nmarquivo,
       a.dsusername,
       a.dhinicio_importacao,
       a.dhfim_importacao,
       a.dtliberacao,
       1 cdoperador_liberacao,
       a.dtbloqueio,
       a.cdoperador_bloqueio,
       '12/12/2022'
from TBCRED_PREAPROV a
where a.idcarga = 121);  

insert into credito.TBCRED_PREAPROV_DET
select "CREDITO"."ISEQ$$_81310".nextval,
       142 idcarga,
       a.nrcpfcnpj,
       a.cdlinha,
       a.tppessoa,
       a.infaixa_risco,
       a.dtmvtolt,
       a.vlcalpre,
       a.vlctrpre,
       a.vlcalcot,
       a.vlcaldes,
       a.vlcalpar,
       a.vlcalren,
       a.vlcalven,
       a.dscalris,
       a.vllimdis,
       'A' insituacao,
       null dtbloqueio,
       a.cdoperador_bloqueio
from TBCRED_PREAPROV_DET a
where a.idcarga = 121;

  commit;
end;
