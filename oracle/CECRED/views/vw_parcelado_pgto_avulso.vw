create or replace force view cecred.vw_parcelado_pgto_avulso as
select
  ass.nrdconta nrdconta,
  cop.nrdocnpj as CNPJCtrc,
  case when length(ass.nrcpfcgc) < 12 then 1
    else 2 end TipCli,
  ass.nrcpfcgc as IdfcCli,
  epr.nrctremp as NrCtr,
  --case when (select dsoperac from craplcr where cdcooper = epr.cdcooper and cdlcremp = epr.cdlcremp) = 'FINANCIAMENTO' then 0499 else 0299 end cdproduto,
  fn_busca_modalidade_bacen(case when (select dsoperac from craplcr where cdcooper = epr.cdcooper and cdlcremp = epr.cdlcremp) = 'FINANCIAMENTO' then 0499 else 0299 end , ass.cdcooper, ass.nrdconta, epr.nrctremp, ass.inpessoa, 3, '') as cdproduto,
  case when max(lem.dtmvtolt) is not null then to_char(max(lem.dtmvtolt), 'YYYYMMDD')
    else to_char(max(lem.dtpagemp),'YYYYMMDD') end DtPgtoAvls,
  to_char(sum(nvl(lem.vllanmto,0)),'fm9999900V00') as VlPgtoAvls,
  case
    when sum(nvl(lem.vllanmto,0)) < (lem.vlpreemp) then 'P' --pagamento total
    else 'T' end as SitPclAnt
from
  crapass ass,
  crapcop cop,
  crapepr epr,
  craplem lem
where
  ass.cdcooper = cop.cdcooper
  and cop.flgativo = 1
  and ass.cdcooper = epr.cdcooper
  and ass.nrdconta = epr.nrdconta
  and epr.cdcooper = lem.cdcooper
  and epr.nrdconta = lem.nrdconta
  and epr.nrctremp = lem.nrctremp
  and ass.incadpos = 2
  --and ass.nrcpfcgc in (03297156902,91596670959,08486610000159,01268248940,18515174000152,05370297703,10381840000103,65468252287,11212502000100,73481289987, 67548610963, 9013972000195, 6130589000129, 97007277934, 59203919953, 82991191000165, 625159934, 43959636920, 86024299915)
  and epr.tpemprst = 0 --emprestimo Velho
  and epr.DTULTPAG >= (sysdate - 366) --mesmo where do contrato
  and (lem.dtmvtolt >= (sysdate-366) and (lem.dtmvtolt <= (sysdate)))
  and lem.cdhistor IN (91,92,93,94,95,277,353,382,383,391,392,393)
group by
  ass.cdcooper,
  ass.nrdconta,
  ass.inpessoa,
  cop.nrdocnpj,
  ass.nrcpfcgc,
  epr.nrctremp,
  epr.cdcooper,
  epr.cdlcremp,
  lem.vlpreemp,
  trunc(lem.dtmvtolt)
order by
  cnpjctrc, idfccli, nrctr
;

