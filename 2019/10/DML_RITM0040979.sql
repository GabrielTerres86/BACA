--RITM0040979
--Ana Volles - 10/10/2019
--Reabilitar a proposta
/*
select a.nrctrlim, a.insitlim, a.insitblq, a.insitest, a.insitapr, a.dtpropos, a.dtenefes, a.dtaprova, a.hraprova, a.dtexpira, a.dtenvest, a.hrenvest,a.dtenvmot, a.*
from CRAWLIM a where cdcooper = 1 and nrdconta = 7901038 and a.nrctrlim = 11786;
*/
BEGIN
  
  UPDATE crawlim a 
  SET dtexpira = NULL
     ,insitlim = 1
     ,dtpropos = '17/09/2019'
  where a.cdcooper = 1 
  and   a.nrdconta = 7901038 
  and   a.nrctrlim = 11786;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    rollback;
END;
