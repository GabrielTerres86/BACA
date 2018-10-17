  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : vw_parcelado_contrato
  --  Sistema  : View de parcelas de emprestimos
  --  Sigla    : CRED
  --  Autor    : DESCONHECIDO
  --  Data     : DESCONHECIDO                  Ultima atualizacao: 17/10/2018
  --
  -- Dados referentes ao programa:
  --
  -- Alteracoes: 08/08/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)
  --
  --             17/10/2018 - Alteracoes conforme demanda regulatoria. (Ornelas - Amcom)
  ---------------------------------------------------------------------------------------------------------------
create or replace force view cecred.vw_parcelado_contrato as
select
  '1' nr,
  ass.nrdconta,
  to_char((sysdate),'YYYYMMDD') as DtAprc,
  cop.nrdocnpj as CNPJCtrc,
  case when length(ass.nrcpfcgc) < 12 then 1 else 2 end TipCli,
  ass.nrcpfcgc as IdfcCli,
  --bdc.nrborder as NrCtr,
  lpad(ass.cdcooper,2,0) || ass.nrdconta || bdc.nrborder as NrCtr, -- Ver a necessidade de acrescentar o tipo de contrato
  '0302' as CdProduto, --contrato de desconto de cheque
  to_char((bdc.dtlibbdc),'YYYYMMDD') as DtCtrc,
  ass.cdagenci as PrfAg,
  'S' as InPrefix,
  to_char(nvl((select sum(vlcheque)from crapcdb
    where cdcooper = ass.cdcooper and nrdconta = ass.nrdconta and nrborder = bdc.nrborder),0),'fm9999900V00') as VlCtrdFut,
  (select  count(DISTINCT extract (MONTH FROM dtlibera)) Meses from crapcdb
    where cdcooper = ass.cdcooper and nrdconta = ass.nrdconta and nrborder = bdc.nrborder) as QtPcl,
  to_char(((select max(dtlibera) from crapcdb
    where cdcooper = ass.cdcooper and nrdconta = ass.nrdconta and nrborder = bdc.nrborder)),'YYYYMMDD') as DtVnctUltPcl,
  /*(select  count(DISTINCT extract (MONTH FROM dtlibera)) Meses from crapcdb
    where cdcooper = ass.cdcooper and nrdconta = ass.nrdconta and nrborder = bdc.nrborder and insitchq = 2 and dtlibera > sysdate) as QtPclPgr,
  '' as DtVnctPrxPcl,
  0 as VlPrxPcl,
  (select  count(DISTINCT extract (MONTH FROM dtlibera)) Meses from crapcdb
    where cdcooper = ass.cdcooper and nrdconta = ass.nrdconta and nrborder = bdc.nrborder and insitchq = 2 and dtlibera > sysdate ) as QtPclVncr,*/
  null as AdndContrato
from
  crapass ass,
  crapcop cop,
  crapbdc bdc
where
  cop.cdcooper = ass.cdcooper
  and bdc.nrdconta = ass.nrdconta
  and bdc.cdcooper = ass.cdcooper
  and bdc.dtlibbdc >= (sysdate - 366)
  and cop.flgativo = 1
  and ass.incadpos = 2
  and bdc.insitbdc = 3 --liberado
union
select
  '2' nr,
  ass.nrdconta,
  to_char((sysdate),'YYYYMMDD') as DtAprc,
  cop.nrdocnpj as CNPJCtrc,
  case when length(ass.nrcpfcgc) < 12 then 1 else 2 end TipCli,
  ass.nrcpfcgc as IdfcCli,
  --bdt.nrborder as NrCtr,
  lpad(ass.cdcooper,2,0) || ass.nrdconta || bdt.nrborder as NrCtr, -- Ver a necessidade de acrescentar o tipo de contrato
  '0301' as CdProduto, --contrato de desconto de títulos
  to_char(bdt.dtlibbdt,'YYYYMMDD') as DtCtrc,
  ass.cdagenci as PrfAg,
  'S' as InPrefix,
  to_char(nvl((select  sum(vltitulo)from craptdb
    where cdcooper = ass.cdcooper and nrdconta = ass.nrdconta and nrborder = bdt.nrborder),0),'fm9999900V00') as VlCtrdFut,
  (select  count(DISTINCT extract (MONTH FROM dtvencto)) Meses from craptdb
    where cdcooper = ass.cdcooper and nrdconta = ass.nrdconta and nrborder = bdt.nrborder) as QtPcl,
  to_char((select max(dtvencto) from craptdb
    where cdcooper = ass.cdcooper and nrdconta = ass.nrdconta and nrborder = bdt.nrborder),'YYYYMMDD') as DtVnctUltPcl,
  /*(select  count(DISTINCT extract (MONTH FROM dtvencto)) Meses from craptdb
    where cdcooper = ass.cdcooper and nrdconta = ass.nrdconta and nrborder = bdt.nrborder and insittit = 4) as QtPclPgr,
  '' as DtVnctPrxPcl,
  0 as VlPrxPcl,
  (select  count(DISTINCT extract (MONTH FROM dtvencto)) Meses from craptdb
    where cdcooper = ass.cdcooper and nrdconta = ass.nrdconta and nrborder = bdt.nrborder and insittit = 4 ) as QtPclVncr,*/
  null as AdndContrato
from
  crapass ass,
  crapcop cop,
  crapbdt bdt
where
  cop.cdcooper = ass.cdcooper
  and bdt.nrdconta = ass.nrdconta
  and bdt.cdcooper = ass.cdcooper
  and bdt.dtlibbdt >= (sysdate - 366)
  and cop.flgativo = 1
  and ass.incadpos = 2
UNION
select
  '3' nr,
  ass.nrdconta,
  to_char((sysdate),'YYYYMMDD') as DtAprc,
  cop.nrdocnpj as CNPJCtrc,
  case when length(ass.nrcpfcgc) < 12 then 1 else 2 end TipCli,
  ass.nrcpfcgc as IdfcCli,
  --epr.nrctremp as NrCtr,
  lpad(ass.cdcooper,2,0) || ass.nrdconta || epr.nrctremp as NrCtr, -- Ver a necessidade de acrescentar o tipo de contrato
  --case when (select dsoperac from craplcr where cdcooper = epr.cdcooper and cdlcremp = epr.cdlcremp) = 'FINANCIAMENTO' then 0499 else 0299 end cdproduto,
  fn_busca_modalidade_bacen(case when (select dsoperac from craplcr where cdcooper = epr.cdcooper and cdlcremp = epr.cdlcremp) = 'FINANCIAMENTO' then 0499 else 0299 end , ass.cdcooper, ass.nrdconta, epr.nrctremp, ass.inpessoa, 3, '') as cdproduto,
  to_char(epr.dtmvtolt,'YYYYMMDD') as DtCtrc,
  ass.cdagenci as PrfAg,
  'S' as InPrefix,
  to_char(nvl(epr.vlemprst,0),'fm9999900V00') as VlCtrdFut,
  epr.qtpreemp as QtPcl,
  to_char(ADD_MONTHS((select dtdpagto from crawepr where cdcooper = ass.cdcooper and nrdconta = ass.nrdconta and nrctremp = epr.nrctremp),decode(epr.qtpreemp, 1,1,epr.qtpreemp-1)),'YYYYMMDD') as DtVnctUltPcl,
  /*case
    when epr.inliquid = 1 then 0
    else
      ceil((case
        when (epr.qtpreemp - epr.qtpcalat) < 0 then 0
        else (epr.qtpreemp - epr.qtpcalat)
  end)) end as QtPclPgr,
  '' as DtVnctPrxPcl,
  0 as VlPrxPcl,
  case
    when epr.inliquid = 1 then 0
    else
      ceil((case
        when trunc(months_between(sysdate,epr.dtmvtolt)) >= epr.qtpreemp then 0
        else (epr.qtpreemp - epr.qtpcalat)
  end)) end as QtPclVncr,*/
  null as AdndContrato
from
  crapass ass,
  crapcop cop,
  crapepr epr
where
  cop.cdcooper = ass.cdcooper
  and ass.cdcooper = epr.cdcooper
  and ass.nrdconta = epr.nrdconta
  AND EPR.DTULTPAG >= (sysdate - 366)
  and cop.flgativo = 1
  and ass.incadpos = 2
  and epr.tpemprst = 0 --emprestimo VELHO
UNION
select
  '4' nr,
  ass.nrdconta,
  to_char((sysdate),'YYYYMMDD') as DtAprc,
  cop.nrdocnpj as CNPJCtrc,
  case when length(ass.nrcpfcgc) < 12 then 1 else 2 end TipCli,
  ass.nrcpfcgc as IdfcCli,
  --epr.nrctremp as NrCtr,
  lpad(ass.cdcooper,2,0) || ass.nrdconta || epr.nrctremp as NrCtr, -- Ver a necessidade de acrescentar o tipo de contrato
  --case when (select dsoperac from craplcr where cdcooper = epr.cdcooper and cdlcremp = epr.cdlcremp) = 'FINANCIAMENTO' then 0499 else 0299 end cdproduto,
  fn_busca_modalidade_bacen(case when (select dsoperac from craplcr where cdcooper = epr.cdcooper and cdlcremp = epr.cdlcremp) = 'FINANCIAMENTO' then 0499 else 0299 end , ass.cdcooper, ass.nrdconta, epr.nrctremp, ass.inpessoa, 3, '') as cdproduto,
  to_char(epr.dtmvtolt,'YYYYMMDD') as DtCtrc,
  ass.cdagenci as PrfAg,
  case epr.tpemprst
    when 1 then 'S'
    when 2 then 'N'
  end InPrefix,
  to_char(nvl(epr.vlemprst,0),'fm9999900V00') as VlCtrdFut,
  epr.qtpreemp as QtPcl,
  to_char(ADD_MONTHS((select dtdpagto from crawepr where cdcooper = ass.cdcooper and nrdconta = ass.nrdconta and nrctremp = epr.nrctremp),decode(epr.qtpreemp, 1,1,epr.qtpreemp-1)),'YYYYMMDD') as DtVnctUltPcl,
  /*(select count(progress_recid) from crappep where cdcooper = ass.cdcooper and nrdconta = ass.nrdconta and nrctremp = epr.nrctremp and inliquid = 0) as QtPclPgr,
  '' as DtVnctPrxPcl,
  0 as VlPrxPcl,
  (select count(progress_recid) from crappep where cdcooper = ass.cdcooper and nrdconta = ass.nrdconta and nrctremp = epr.nrctremp and dtvencto > sysdate and inliquid = 0) as QtPclVncr,*/
  null as AdndContrato
from
  crapass ass,
  crapepr epr,
  crapcop cop
where
  cop.cdcooper = ass.cdcooper
  and ass.cdcooper = epr.cdcooper
  and ass.nrdconta = epr.nrdconta
--  AND (EPR.DTULTPAG >= (sysdate - 366) OR EPR.INLIQUID = 0 )
  and (exists (select 1 from crappep pep
              where pep.cdcooper = epr.cdcooper
                and pep.nrdconta = epr.nrdconta
                and pep.nrctremp = epr.nrctremp
                and (((pep.dtultpag >= (sysdate-366)) and (pep.dtultpag <= (sysdate))) or
                     ((pep.dtvencto >= (sysdate-366)) and (pep.dtvencto <= (sysdate))and (pep.dtultpag is null or pep.dtultpag >= (sysdate-366)) ))  --pagamento ou vencimento superior a Um ano atrás a até hoje e em se tratando apenas de vencimento .... verificar senão está quitada há mais de um ano.
              ) OR EPR.INLIQUID = 0 )
  and cop.flgativo = 1
  and ass.incadpos = 2
  and epr.tpemprst IN (1,2) -- PP ou POS
order by
  CNPJCtrc, idfccli, nrctr
