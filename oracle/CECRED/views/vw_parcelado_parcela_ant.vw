  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : vw_parcelado_parcela_ant
  --  Sistema  : View de parcelas de emprestimos
  --  Sigla    : CRED
  --  Autor    : Tiago Machado Flor
  --  Data     : Junho/2017.                   Ultima atualizacao: 17/10/2018
  --
  -- Dados referentes ao programa:
  --
  -- Alteracoes: 13/06/2017 - Trazendo as parcelas ao inves de apenas o total(Tiago/Thiago #640821).
  --
  --             08/08/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)
  --
  --             17/10/2018 - Alteracoes conforme demanda regulatoria. (Ornelas - Amcom)
  ---------------------------------------------------------------------------------------------------------------
create or replace force view cecred.vw_parcelado_parcela_ant as
select
  nrdconta,
  CNPJCtrc,
  TipCli,
  IdfcCli,
  NrCtr,
  CdProduto,
  --row_number() over (partition by nrdconta,NrCtr,CdProduto order by nrdconta,NrCtr,CdProduto) as NrPclAnt,
  'M' PercPclAnt, --Sempre Fixo M - Mensal
  to_char(vencimento, 'YYYYMMDD') as DtVnctPclAnt,
  to_char(sum(vltitulo), 'fm9999900V00') as VlPclAnt,
  to_char(pagamento,'YYYYMMDD') as DtPgtoPclAnt,
  to_char(sum(vlpago),'fm9999900V00')    as VlPgtoPclAnt,
  /*case when vlpago = 0 then 'I'
       when vlpago > 0 and vltitulo <> vlpago then 'P'
       else 'T' end                      as SitPclAnt */
  SitPclAnt
from (


select
  ass.nrdconta as nrdconta,
  cop.nrdocnpj as CNPJCtrc,
  case
    when length(ass.nrcpfcgc) < 12 then 1
    else 2
  end          as TipCli,
  ass.nrcpfcgc as IdfcCli,
  --bdt.nrborder as NrCtr,
  lpad(ass.cdcooper,2,0) || ass.nrdconta || bdt.nrborder as NrCtr, -- Ver a necessidade de acrescentar o tipo de contrato
  '0301' as CdProduto, --contrato de desconto de titulos
  max(tdb.dtvencto) as vencimento,
  sum(tdb.vltitulo) as vltitulo,
  max(case when trunc(tdb.dtvencto) < trunc(sysdate) then tdb.dtvencto else null end) as pagamento,
  sum(case
    when trunc(tdb.dtvencto) < trunc(sysdate) then tdb.vltitulo
    else 0 end) as vlpago,
  --case
  --  when sum(decode(tdb.dtdpagto,null,0,tdb.vltitulo)) > 0 and sum(decode(tdb.dtdpagto,null,0,tdb.vltitulo)) < sum(tdb.vltitulo) then 'P' --pagamento parcial
  --  when sum(decode(tdb.dtdpagto,null,0,tdb.vltitulo)) = 0 and max(tdb.dtvencto) < sysdate then 'I' --Vencida sem pagamento
  --  when sum(decode(tdb.dtdpagto,null,0,tdb.vltitulo)) > 0 and sum(decode(tdb.dtdpagto,null,0,tdb.vltitulo)) >= sum(tdb.vltitulo) then 'T' --pagamento total
  --  else 'X' end as SitPclAnt
  to_char(null)  as  SitPclAnt
from
  crapass ass,
  crapcop cop,
  crapbdt bdt,
  craptdb tdb
where
  ass.cdcooper = cop.cdcooper
  and ass.cdcooper = bdt.cdcooper
  and ass.nrdconta = bdt.nrdconta
  and bdt.cdcooper = tdb.cdcooper
  and bdt.nrdconta = tdb.nrdconta
  and bdt.nrborder = tdb.nrborder
  and cop.flgativo = 1
  and ass.incadpos = 2
  and bdt.dtlibbdt >= (sysdate - 366)
  and ((tdb.dtvencto >= (sysdate -366) and tdb.dtvencto <= (sysdate)) or (tdb.dtdpagto >= (sysdate -366) and tdb.dtdpagto <= (sysdate)))
group by
  ass.nrdconta,
  cop.nrdocnpj,
  case
    when length(ass.nrcpfcgc) < 12 then 1
  else 2  end,
  ass.nrcpfcgc,
  --bdt.nrborder,
  lpad(ass.cdcooper,2,0) || ass.nrdconta || bdt.nrborder, -- Conforme definição do Fernando Ornelas em 14/08/2018. Orientação: Ver a necessidade de acrescentar o tipo de contrato
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
  --vltitulo,   -- Comentado devido ao grupo by
  to_char(pagamento,'YYYYMMDD'),
  --vlpago,     -- Comentado devido ao grupo by
  --SitPcl
  SitPclAnt
------------------------------------------------------
union

select
  nrdconta,
  CNPJCtrc,
  TipCli,
  IdfcCli,
  NrCtr,
  CdProduto,
  --row_number() over (partition by nrdconta,NrCtr,CdProduto order by nrdconta,NrCtr,CdProduto) as NrPclAnt,
  'M' PercPclAnt, --Sempre fixo M - Mensal
  to_char(vencimento,'YYYYMMDD') as DtVnctPclAnt,
  to_char(sum(vltitulo),'fm9999900V00') as VlPclAnt,
  to_char(pagamento,'YYYYMMDD') as DtPgtoPclAnt,
  to_char(sum(vlpago),'fm9999900V00')   as VlPgtoPclAnt,
  /*
  SitPclAnt as SitPclAnt*/
  SitPclAnt
from (
select
  ass.nrdconta as nrdconta,
  cop.nrdocnpj as CNPJCtrc,
  case
    when length(ass.nrcpfcgc) < 12 then 1
    else 2
  end          as TipCli,
  ass.nrcpfcgc as IdfcCli,
  --bdc.nrborder as NrCtr,
  lpad(ass.cdcooper,2,0) || ass.nrdconta || bdc.nrborder as NrCtr, -- Ver a necessidade de acrescentar o tipo de contrato
  '0302' as CdProduto, --contrato de desconto de cheques
  max(cdb.dtlibera) as vencimento,
  sum(cdb.vlcheque) as vltitulo,
  max(cdb.dtlibera) as pagamento,
  sum(cdb.vlcheque) as vlpago,
  /*
  case
    when cdb.dtlibera < sysdate then 'T' --total
    when cdb.dtlibera >= sysdate then 'V' -- a vencer sem pagamento
    else 'X' end as SitPclAnt*/
  to_char(null)  as  SitPclAnt
from
  crapass ass,
  crapcop cop,
  crapbdc bdc, --bordero de cheques
  crapcdb cdb --cheques do Bordero
where
  ass.cdcooper = cop.cdcooper
  and ass.cdcooper = bdc.cdcooper
  and ass.nrdconta = bdc.nrdconta
  and bdc.cdcooper = cdb.cdcooper
  and bdc.nrdconta = cdb.nrdconta
  and bdc.nrborder = cdb.nrborder
  and cop.flgativo = 1
  and ass.incadpos = 2
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
  --bdc.nrborder,
  lpad(ass.cdcooper,2,0) || ass.nrdconta || bdc.nrborder, -- Ver a necessidade de acrescentar o tipo de contrato
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
  --vltitulo,   -- Comentado devido ao grupo by
  to_char(pagamento,'YYYYMMDD'),
  --vlpago     
  SitPclAnt
------------------------------------------------------
union


select
  nrdconta,
  CNPJCtrc,
  TipCli,
  IdfcCli,
  NrCtr,
  CdProduto,
  PercPclAnt, 
  DtVnctPclAnt,
  to_char(sum(VlPclAnt),'fm9999900V00')     as VlPclAnt,
  DtPgtoPclAnt,
  to_char(sum(VlPgtoPclAnt),'fm9999900V00') as VlPgtoPclAnt,
  SitPclAnt
from (



select
  ass.nrdconta as nrdconta,
  cop.nrdocnpj as CNPJCtrc,
  case when length(ass.nrcpfcgc) < 12 then 1
    else 2 end as TipCli,
  ass.nrcpfcgc as IdfcCli,
  --epr.nrctremp as NrCtr,
  lpad(ass.cdcooper,2,0) || ass.nrdconta || epr.nrctremp as NrCtr, -- Ver a necessidade de acrescentar o tipo de contrato
  --case when (select dsoperac from craplcr where cdcooper = epr.cdcooper and cdlcremp = epr.cdlcremp) = 'FINANCIAMENTO' then 0499 else 0299 end cdproduto,
  fn_busca_modalidade_bacen(case when (select dsoperac from craplcr where cdcooper = epr.cdcooper and cdlcremp = epr.cdlcremp) = 'FINANCIAMENTO' then 0499 else 0299 end , ass.cdcooper, ass.nrdconta, epr.nrctremp, ass.inpessoa, 3, '') as cdproduto,
  --lem.nrparepr as NrPclAnt,
  'M' PercPclAnt, --Conforme definição do Fernando Ornelas em 14/08/2018. Periodicidade das parcelas - Tem que definir a forma de como buscar esta informação
  to_char(pep.dtvencto,'YYYYMMDD') as DtVnctPclAnt,
  to_char(pep.vlparepr,'fm9999900V00') as VlPclAnt,
  to_char(lem.dtpagemp,'YYYYMMDD') as DtPgtoPclAnt,
  to_char(lem.vllanmto,'fm9999900V00') as VlPgtoPclAnt,
  /*,
  case
    when pep.dtultpag is null and pep.dtvencto < sysdate then 'I' --vencida
    when pep.dtultpag is not null and pep.inliquid = 1 then 'T' --pagamento total
    when pep.dtultpag is not null and pep.inliquid = 0 then 'P' --pagamento parcial
    when pep.dtultpag is null and pep.dtvencto >= sysdate then 'V' -- a vencer
      else 'X' end as SitPclAnt*/
  to_char(null)  as  SitPclAnt
from
  crapass ass,
  crapcop cop,
  crapepr epr,
  crappep pep,
  craplem lem
WHERE ass.cdcooper = cop.cdcooper
  AND ass.cdcooper = epr.cdcooper
  AND ass.nrdconta = epr.nrdconta
  AND epr.cdcooper = pep.cdcooper
  AND epr.nrdconta = pep.nrdconta
  AND epr.nrctremp = pep.nrctremp
  AND lem.cdcooper = epr.cdcooper
  AND lem.nrdconta = epr.nrdconta
  AND lem.nrctremp = epr.nrctremp
  AND pep.cdcooper = lem.cdcooper
  AND pep.nrdconta = lem.nrdconta
  AND pep.nrctremp = lem.nrctremp
  AND pep.nrparepr = lem.nrparepr
  AND ass.cdcooper = lem.cdcooper
  AND ass.nrdconta = lem.nrdconta
  AND lem.cdhistor IN (1039, 1057, 1058, 1044, 1045, 1046, 2330, 2331, 2334, 2335, 2338, 2339)
  AND cop.flgativo = 1
  AND ass.incadpos = 2
  AND epr.tpemprst IN (1,2) -- PP ou POS
  AND ((((pep.dtultpag >= (sysdate-366)) and (pep.dtultpag <= (sysdate)))) or
        ((pep.dtvencto >= (sysdate-366)) and (pep.dtvencto <= (sysdate))and (pep.dtultpag is null or pep.dtultpag >= (sysdate-366)) ))  --pagamento ou vencimento superior a Um ano atrás a até hoje e em se tratando apenas de vencimento .... verificar senão está quitada há mais de um ano.

  )
group by 

  nrdconta,
  CNPJCtrc,
  TipCli,
  IdfcCli,
  NrCtr,
  CdProduto,
  PercPclAnt, 
  DtVnctPclAnt,
  DtPgtoPclAnt,
  SitPclAnt
  
ORDER BY cnpjctrc, idfccli, cdproduto, nrctr--, nrpclant
