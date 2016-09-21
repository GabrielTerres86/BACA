CREATE OR REPLACE FORCE VIEW CECRED.VW_ROTATIVO_FECHAMENTO_ANT AS
select
  ass.nrdconta CONTA,
  cop.nrdocnpj as CNPJCtrc,
  case
    when length(ass.nrcpfcgc) < 12 then 1
    else 2
  end TipCli,
  ass.nrcpfcgc as IdfcCli,
  ass.nrdconta as NrCtr,
  '0101' as CdProduto,
  to_char(ris.dtrefere,'YYYYMMDD') as DtFchAnt,
  to_char(nvl(ris.vldivida,0),'fm9999900V00') as SdoUtlzFchtAnt
from
  crapass ass,
  crapcop cop,
  crapris ris
where
  cop.cdcooper = ass.cdcooper
  and ris.cdcooper = ass.cdcooper
  and ris.nrdconta = ass.nrdconta
  and ass.incadpos = 2 --autorizado
  --and ass.nrcpfcgc in (03297156902,91596670959,08486610000159,01268248940,18515174000152,05370297703,10381840000103,65468252287,11212502000100,73481289987)
  and ris.cdmodali = 0101
  and ris.dtrefere >= (sysdate - 366) --somente fechamentos dos últimos 12 meses.
  and ris.dtrefere < TRUNC(sysdate, 'MONTH') -- somente do mês anterior ao atual.
  and ris.inddocto = 1
union
select
  ass.nrdconta CONTA,
  cop.nrdocnpj as CNPJCtrc,
  case
    when length(ass.nrcpfcgc) < 12 then 1
    else 2
  end TipCli,
  ass.nrcpfcgc as IdfcCli,
  ris.nrctremp as NrCtr,
  '0201' as CdProduto,
  to_char(ris.dtrefere,'YYYYMMDD') as DtFchAnt,
  to_char(nvl(ris.vldivida,0),'fm9999900V00') as SdoUtlzFchtAnt
from
  crapass ass,
  crapcop cop,
  crapris ris
WHERE
  cop.cdcooper = ass.cdcooper
  AND ris.cdcooper = ass.cdcooper
  and ris.nrdconta = ass.nrdconta
  and ass.incadpos = 2
  --and ass.nrcpfcgc in (03297156902,91596670959,08486610000159,01268248940,18515174000152,05370297703,10381840000103,65468252287,11212502000100,73481289987)
  AND EXISTS (SELECT 1
              FROM       crapass ass1,
                         craplim lim1
                       WHERE
                             ris.nrctremp =  lim1.nrctrlim
                         and ris.cdcooper =  lim1.cdcooper
                         and ris.nrdconta =  lim1.nrdconta
                         and lim1.cdcooper = ass1.cdcooper
                         and lim1.nrdconta = ass1.nrdconta --inner join na LIM já exclui a modalidade 101 (101 não tem contrato)
                         and ass1.incadpos = 2
                         --and ass1.nrcpfcgc in (03297156902,91596670959,08486610000159,01268248940,18515174000152,05370297703,10381840000103,65468252287,11212502000100,73481289987)
                         AND ((LIM1.DTFIMVIG >= (SYSDATE - 366)) OR (lim1.insitlim = 2)) --ativos ou que terminaram dentro do periodo apurado)
                         and lim1.tpctrlim = 1 ) --fim where contrato
  and ris.dtrefere > (sysdate - 366) --somente dos últimos 12 meses (tem que ver se é dtrefere ou dtdrisco)
  and ris.dtrefere < trunc(sysdate,'MONTH') -- apenas os fechamentos até o mês anterior
  and ris.inddocto = 1
  and ris.cdmodali = 201 --cheque especial
order by
  cnpjctrc, idfccli, cdproduto, nrctr, dtfchant
;

