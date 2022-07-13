begin 
 insert into credito.TBCRED_PREAPROV
(select 142 idcarga,
       2 tppreapr,
       a.cdcooper,
       a.tpcarga,
       to_date('13/07/2022','dd/mm/yyyy') dtmvtolt,
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
       to_date('13/12/2022','dd/mm/yyyy') DTFINAL_VIGENCIA
from TBCRED_PREAPROV a
where a.idcarga = 121);  

insert into credito.TBCRED_PREAPROV_DET
values(idcarga,nrcpfcnpj,cdlinha,tppessoa,infaixa_risco,dtmvtolt,vlcalpre,vlctrpre,vlcalcot,vlcaldes,vlcalpar,vlcalren,vlcalven,dscalris,vllimdis,insituacao,dtbloqueio,cdoperador_bloqueio)
(select 142 idcarga,
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
       'B' insituacao,
       null dtbloqueio,
       a.cdoperador_bloqueio
from TBCRED_PREAPROV_DET a
where a.idcarga = 121);

  commit;
end;