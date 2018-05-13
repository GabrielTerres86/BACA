  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : vw_parcelado_parcela_ant
  --  Sistema  : View de parcelas de emprestimos
  --  Sigla    : CRED
  --  Autor    : Tiago Machado Flor
  --  Data     : Junho/2017.                   Ultima atualizacao: 13/06/2017
  --
  -- Dados referentes ao programa:
  --
  -- Alteracoes: 13/06/2017 - Trazendo as parcelas ao inves de apenas o total(Tiago/Thiago #640821).
  ---------------------------------------------------------------------------------------------------------------
create or replace force view cecred.vw_parcelado_parcela_ant as
select
  nrdconta,
  CNPJCtrc,
  TipCli,
  IdfcCli,
  NrCtr,
  CdProduto,
  row_number() over (partition by nrdconta,NrCtr,CdProduto order by nrdconta,NrCtr,CdProduto) as NrPclAnt,
  to_char(vencimento, 'YYYYMMDD') as DtVnctPclAnt,
  to_char(vltitulo, 'fm9999900V00') as VlPclAnt,
  to_char(pagamento,'YYYYMMDD') as DtPgtoPclAnt,
  to_char(vlpago,'fm9999900V00') as VlPgtoPclAnt,
  case when vlpago = 0 then 'I'
       when vlpago > 0 and vltitulo <> vlpago then 'P'
       else 'T' end as SitPlcAnt
from (
select
  ass.nrdconta nrdconta,
  cop.nrdocnpj as CNPJCtrc,
  case
    when length(ass.nrcpfcgc) < 12 then 1
    else 2
  end TipCli,
  ass.nrcpfcgc as IdfcCli,
  bdt.nrborder as NrCtr,
  '0301' as CdProduto, --contrato de desconto de titulos
  max(tdb.dtvencto) as vencimento,
  sum(tdb.vltitulo) as vltitulo,
  max(case when trunc(tdb.dtvencto) < trunc(sysdate) then tdb.dtvencto else null end) as pagamento,
  sum(case
    when trunc(tdb.dtvencto) < trunc(sysdate) then tdb.vltitulo
    else 0 end) vlpago
  --case
  --  when sum(decode(tdb.dtdpagto,null,0,tdb.vltitulo)) > 0 and sum(decode(tdb.dtdpagto,null,0,tdb.vltitulo)) < sum(tdb.vltitulo) then 'P' --pagamento parcial
  --  when sum(decode(tdb.dtdpagto,null,0,tdb.vltitulo)) = 0 and max(tdb.dtvencto) < sysdate then 'I' --Vencida sem pagamento
  --  when sum(decode(tdb.dtdpagto,null,0,tdb.vltitulo)) > 0 and sum(decode(tdb.dtdpagto,null,0,tdb.vltitulo)) >= sum(tdb.vltitulo) then 'T' --pagamento total
  --  else 'X' end as SitPclAnt
from
  crapass ass,
  crapcop cop,
  crapbdt bdt,
  craptdb tdb
where
  ass.cdcooper = cop.cdcooper
  and cop.flgativo = 1
  and ass.cdcooper = bdt.cdcooper
  and ass.nrdconta = bdt.nrdconta
  and bdt.cdcooper = tdb.cdcooper
  and bdt.nrdconta = tdb.nrdconta
  and bdt.nrborder = tdb.nrborder
  and ass.incadpos = 2
  --and ass.nrdconta = 2543923
  --and tdb.nrborder in (118791,118172)
  --and ass.nrcpfcgc in (03297156902,91596670959,08486610000159,01268248940,18515174000152,05370297703,10381840000103,65468252287,11212502000100,73481289987, 67548610963, 9013972000195, 6130589000129, 97007277934, 59203919953, 82991191000165, 625159934, 43959636920, 86024299915)
  and bdt.dtlibbdt >= (sysdate - 366)
  and ((tdb.dtvencto >= (sysdate -366) and tdb.dtvencto <= (sysdate)) or (tdb.dtdpagto >= (sysdate -366) and tdb.dtdpagto <= (sysdate)))
group by
  ass.nrdconta,
  cop.nrdocnpj,
  case
    when length(ass.nrcpfcgc) < 12 then 1
  else 2  end,
  ass.nrcpfcgc,
  bdt.nrborder,
  '0301',
  trunc(tdb.dtvencto,'MM')
) tab1
group by
  CNPJCtrc,
  TipCli,
  IdfcCli,
  nrdconta,
  NrCtr,
  CdProduto,
  vencimento,
  vltitulo,
  to_char(pagamento,'YYYYMMDD'),
  vlpago
  --SitPcl
------------------------------------------------------
union
select
  nrdconta,
  CNPJCtrc,
  TipCli,
  IdfcCli,
  NrCtr,
  CdProduto,
  row_number() over (partition by nrdconta,NrCtr,CdProduto order by nrdconta,NrCtr,CdProduto) as NrPclAnt,
  to_char(vencimento,'YYYYMMDD') as DtVnctPclAnt,
  to_char(vltitulo,'fm9999900V00') as VlPclAnt,
  to_char(pagamento,'YYYYMMDD') as DtPgtoPclAnt,
  to_char(vlpago,'fm9999900V00') as VlPgtoPclAnt,
  SitPclAnt as SitPlcAnt
from (
select
  ass.nrdconta nrdconta,
  cop.nrdocnpj as CNPJCtrc,
  case
    when length(ass.nrcpfcgc) < 12 then 1
    else 2
  end TipCli,
  ass.nrcpfcgc as IdfcCli,
  bdc.nrborder as NrCtr,
  '0302' as CdProduto, --contrato de desconto de cheques
  max(cdb.dtlibera) as vencimento,
  sum(cdb.vlcheque) as vltitulo,
  max(cdb.dtlibera) as pagamento,
  sum(cdb.vlcheque) as vlpago,
  case
    when cdb.dtlibera < sysdate then 'T' --total
    when cdb.dtlibera >= sysdate then 'V' -- a vencer sem pagamento
    else 'X' end as SitPclAnt
from
  crapass ass,
  crapcop cop,
  crapbdc bdc, --bordero de cheques
  crapcdb cdb --cheques do Bordero
where
  ass.cdcooper = cop.cdcooper
  and cop.flgativo = 1
  and ass.cdcooper = bdc.cdcooper
  and ass.nrdconta = bdc.nrdconta
  and bdc.cdcooper = cdb.cdcooper
  and bdc.nrdconta = cdb.nrdconta
  and bdc.nrborder = cdb.nrborder
  and ass.incadpos = 2
  --and ass.nrcpfcgc in (03297156902,91596670959,08486610000159,01268248940,18515174000152,05370297703,10381840000103,65468252287,11212502000100,73481289987, 67548610963, 9013972000195, 6130589000129, 97007277934, 59203919953, 82991191000165, 625159934, 43959636920, 86024299915)
  and bdc.dtlibbdc >= (sysdate - 366)
  and ((cdb.dtlibera >= (sysdate -366) and cdb.dtlibera <= (sysdate))) --or verificar lance devolução (tdb.dtdpagto >= (sysdate -366) and tdb.dtdpagto <= (sysdate))
group by
  ass.nrdconta,
  cop.nrdocnpj,
  case
    when length(ass.nrcpfcgc) < 12 then 1
    else 2
  end,
  ass.nrcpfcgc,
  bdc.nrborder,
  '0302',
  case
    when cdb.dtlibera < sysdate then 'T' --total
    when cdb.dtlibera >= sysdate then 'V' -- a vencer sem pagamento
    else 'X' end,
  trunc(cdb.dtlibera,'MM')
) tab1
group by
  CNPJCtrc,
  TipCli,
  IdfcCli,
  nrdconta,
  NrCtr,
  CdProduto,
  vencimento,
  vltitulo,
  to_char(pagamento,'YYYYMMDD'),
  SitPclAnt
------------------------------------------------------
union
select
  ass.nrdconta as nrdconta,
  cop.nrdocnpj as CNPJCtrc,
  case when length(ass.nrcpfcgc) < 12 then 1
    else 2 end TipCli,
  ass.nrcpfcgc as IdfcCli,
  epr.nrctremp as NrCtr,
  --case when (select dsoperac from craplcr where cdcooper = epr.cdcooper and cdlcremp = epr.cdlcremp) = 'FINANCIAMENTO' then 0499 else 0299 end cdproduto,
  fn_busca_modalidade_bacen(case when (select dsoperac from craplcr where cdcooper = epr.cdcooper and cdlcremp = epr.cdlcremp) = 'FINANCIAMENTO' then 0499 else 0299 end , ass.cdcooper, ass.nrdconta, epr.nrctremp, ass.inpessoa, 3, '') as cdproduto,
  lem.nrparepr as NrPclAnt,
  to_char(pep.dtvencto,'YYYYMMDD') as DtVnctPclAnt,
  to_char(pep.vlparepr,'fm9999900V00') as VlPclAnt,
  to_char(lem.dtpagemp,'YYYYMMDD') as DtPgtoPclAnt,
  to_char(lem.vllanmto,'fm9999900V00') as VlPgtoPclAnt,
  case
    when pep.dtultpag is null and pep.dtvencto < sysdate then 'I' --vencida
    when pep.dtultpag is not null and pep.inliquid = 1 then 'T' --pagamento total
    when pep.dtultpag is not null and pep.inliquid = 0 then 'P' --pagamento parcial
    when pep.dtultpag is null and pep.dtvencto >= sysdate then 'V' -- a vencer
      else 'X' end as SitPclAnt
from
  crapass ass,
  crapcop cop,
  crapepr epr,
  crappep pep,
  craplem lem
WHERE ass.cdcooper = cop.cdcooper
  AND cop.flgativo = 1
  AND ass.cdcooper = epr.cdcooper
  AND ass.nrdconta = epr.nrdconta
  AND epr.cdcooper = pep.cdcooper
  AND epr.nrdconta = pep.nrdconta
  AND epr.nrctremp = pep.nrctremp
  AND lem.cdhistor IN (1039, 1057, 1058, 1044, 1045, 1046)
  AND lem.cdcooper = epr.cdcooper
  AND lem.nrdconta = epr.nrdconta
  AND lem.nrctremp = epr.nrctremp
  AND pep.cdcooper = lem.cdcooper
  AND pep.nrdconta = lem.nrdconta
  AND pep.nrctremp = lem.nrctremp
  AND pep.nrparepr = lem.nrparepr
  AND ass.cdcooper = lem.cdcooper
  AND ass.nrdconta = lem.nrdconta
  AND ass.incadpos = 2
  --and ass.nrcpfcgc in (03297156902,91596670959,08486610000159,01268248940,18515174000152,05370297703,10381840000103,65468252287,11212502000100,73481289987, 67548610963, 9013972000195, 6130589000129, 97007277934, 59203919953, 82991191000165, 625159934, 43959636920, 86024299915)
  AND epr.tpemprst = 1 --emprestimo NOVO
  AND ((((pep.dtultpag >= (sysdate-366)) and (pep.dtultpag <= (sysdate)))) or
        ((pep.dtvencto >= (sysdate-366)) and (pep.dtvencto <= (sysdate))and (pep.dtultpag is null or pep.dtultpag >= (sysdate-366)) ))  --pagamento ou vencimento superior a Um ano atrás a até hoje e em se tratando apenas de vencimento .... verificar senão está quitada há mais de um ano.
ORDER BY cnpjctrc, idfccli, cdproduto, nrctr, nrpclant
