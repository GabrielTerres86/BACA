SELECT count(*)
FROM dba_Scheduler_Jobs         j
where upper(j.job_name) like upper('%NPC_TST_CNS_PRL%');

--dados dos títulos processados
select plog.cdprograma
      ,plog.idprglog
      ,plog.dhinicio
      ,plog.dhfim
      ,plogoco.idocorrencia
      ,plogoco.dhocorrencia
      ,trim(substr(plogoco.dsmensagem,1,instr(plogoco.dsmensagem,' - ')-1))
      ,to_number(to_char(to_timestamp(substr(plogoco.dsmensagem,135,18),'hh24:mi:ss.ff'),'sssss,ff'))
from tbgen_prglog_ocorrencia plogoco
    ,tbgen_prglog plog
where plogoco.idprglog (+) = plog.idprglog
  and trunc(plog.dhinicio) >= to_date('01112018','ddmmyyyy')--trunc(sysdate)
  and upper(plog.cdprograma) like upper('%NPC_TST_CNS_PRL%')
--  and plogoco.dsmensagem like '%PRL20181005142157535984000%'
order by
       substr(plogoco.dsmensagem,1,26) desc
      ,plog.idprglog
      ,plogoco.idocorrencia;
      
--quantidade de jobs por segundo
select trim(substr(plogoco.dsmensagem,97,8))
      ,avg(to_number(replace(substr(plogoco.dsmensagem,141,12),'.',',')))
      ,count(*)
from tbgen_prglog_ocorrencia plogoco
    ,tbgen_prglog plog
where plogoco.idprglog (+) = plog.idprglog
  and trunc(plog.dhinicio) >= to_date('01112018','ddmmyyyy')--trunc(sysdate)-1
  and upper(plog.cdprograma) like upper('%NPC_TST_CNS_PRL%')
--  and plogoco.dsmensagem like '%PRL20181108231938178895000%'
group by
       trim(substr(plogoco.dsmensagem,97,8))
order by 1 asc;

select trim(substr(plogoco.dsmensagem,76,20)) cdctrlcs
      ,trim(substr(plogoco.dsmensagem,97,8)) horario
      ,to_number(replace(substr(plogoco.dsmensagem,141,12),'.',',')) tempo_consulta
from tbgen_prglog_ocorrencia plogoco
    ,tbgen_prglog plog
where plogoco.idprglog (+) = plog.idprglog
  and trunc(plog.dhinicio) >= to_date('01112018','ddmmyyyy')--trunc(sysdate)-1
  and upper(plog.cdprograma) like upper('%NPC_TST_CNS_PRL%')
  and plogoco.dsmensagem like '%PRL20181109001040762255000%'
order by 1 asc;
