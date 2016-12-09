/*
 * Alterações: 07/03/2016 - Ajustar a data de fechamento "DtFchtAtu" do produto "0201" para que seja gerado da mesma forma
 *                          do produto "0101"  (Douglas - Chamado 412546)
 */
create or replace force view cecred.vw_rotativo_contrato as
select
  ass.nrdconta CONTA,
  to_char((sysdate),'YYYYMMDD') as DtAprc,
  cop.nrdocnpj as CNPJCtrc,
  case when length(ass.nrcpfcgc) < 12 then 1 else 2 end TipCli,
  ass.nrcpfcgc as IdfcCli,
  ass.nrdconta as NrCtr,
  '0101' as CdProduto,
  case
    when ass.dtabtcct is null then to_char(ass.dtadmiss,'YYYYMMDD')
    else to_char((ass.dtabtcct),'YYYYMMDD') end as DtCtrc,
  ass.cdagenci as PrfAg,
  '99991231' as DtVnctOpr,
  to_char((sysdate-1),'YYYYMMDD') as DtFchtAtu,
  case
    when exists (select 1 from crapris ris2
                 where ris2.cdcooper = ris.cdcooper
                   and ris2.nrdconta = ris.nrdconta
                   and ris2.cdmodali = ris.cdmodali
                   and to_char(ris2.dtrefere,'dd/mm/RRRR') = to_char(sysdate - 1,'dd/mm/RRRR'))
      then (select to_char(ris2.vldivida,'fm9999900V00') from crapris ris2
            where ris2.cdcooper = ris.cdcooper
              and ris2.nrdconta = ris.nrdconta
              and ris2.cdmodali = ris.cdmodali
              and to_char(ris2.dtrefere,'dd/mm/RRRR') = to_char(sysdate - 1,'dd/mm/RRRR'))
    else '0'
  end as SdoUtlzFchtAtu,
  null as AdndContrat
from
  crapris ris,
  crapass ass,
  crapcop cop
where
  cop.cdcooper = ass.cdcooper
  and cop.flgativo = 1
  and ris.cdcooper = ass.cdcooper
  and ris.nrdconta = ass.nrdconta
  and ass.incadpos = 2
  --and ass.nrcpfcgc in (03297156902,91596670959,08486610000159,01268248940,18515174000152,05370297703,10381840000103,65468252287,11212502000100,73481289987)
  and ris.cdmodali = 0101
  and ris.inddocto = 1
  and ris.progress_recid = (select max(progress_recid) from crapris where cdcooper = ass.cdcooper
                            and nrdconta = ass.nrdconta and cdmodali = 0101 and dtrefere >= (sysdate - 366) and inddocto = 1) --tem que ter ao menos uma apuração nos últimos 12 meses
union
select
  ass.nrdconta CONTA,
  to_char((sysdate),'YYYYMMDD') as DtAprc,
  cop.nrdocnpj as CNPJCtrc,
  case when length(ass.nrcpfcgc) < 12 then 1 else 2 end TipCli,
  ass.nrcpfcgc as IdfcCli,
  lim.nrctrlim as NrCtr,
  '0201' as CdProduto,
  to_char((lim.dtinivig),'YYYYMMDD') as DtCtrc,
  ass.cdagenci as PrfAg,
  to_char(((lim.dtinivig + lim.qtdiavig)),'YYYYMMDD') as DtVnctOpr,
  to_char((sysdate-1),'YYYYMMDD') as DtFchtAtu,
  case
    when lim.insitlim <> 2 then
      '0'
    when exists (select 1 from crapris ris2
                 where ris2.cdcooper = ris.cdcooper
                   and ris2.nrdconta = ris.nrdconta
                   and ris2.cdmodali = ris.cdmodali
                   and to_char(ris2.dtrefere,'dd/mm/RRRR') = to_char(sysdate - 1,'dd/mm/RRRR')) then
      to_char(nvl(ris.vldivida,0),'fm9999900V00')
    else
      '0'
  end as SdoUtlzFchtAtu,
  null as AdndContrato
from
  craplim lim,
  crapass ass,
  crapcop cop,
  crapris ris
WHERE
  cop.cdcooper = ass.cdcooper
  and cop.flgativo = 1
  and lim.cdcooper = ass.cdcooper
  and lim.nrdconta = ass.nrdconta --101 não tem contrato
  and ass.incadpos = 2
  -- Carregar a última informação do RISCO
  and ris.progress_recid = (select max(ris1.progress_recid)
                            from crapris ris1
                            where ris1.nrctremp = lim.nrctrlim
                              and ris1.cdcooper = lim.cdcooper
                              and ris1.nrdconta = lim.nrdconta
                              and ris1.cdmodali = 201)
  --and ass.nrcpfcgc in (03297156902,91596670959,08486610000159,01268248940,18515174000152,05370297703,10381840000103,65468252287,11212502000100,73481289987)
  AND ((LIM.DTFIMVIG >= (SYSDATE - 366)) OR (lim.insitlim = 2)) --ativos ou que terminaram dentro do periodo apurado
  and lim.tpctrlim = 1  --cheque especial
order by
  cnpjctrc, idfccli, cdproduto, nrctr
;

