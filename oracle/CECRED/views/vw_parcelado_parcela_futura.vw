  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : vw_parcelado_parcela_futura
  --  Sistema  : View de pagamento davulso
  --  Sigla    : CRED
  --  Autor    : Ornelas - Amcom
  --  Data     : 17/10/2018                  Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------
create or replace view cecred.vw_parcelado_parcela_futura as
select nr
     , nrdconta
     , DtAprc
     , CNPJCtrc
     , TipCli
     , IdfcCli
     , NrCtr
     , cdproduto
     , PercPclAnt
     , QtPclPgr
     , DtVnctPrxPcl
     , VlPrxPcl
     , QtPclVncr
from (
-- Contratos do tipo  1-PP ou 2-POS
select 1 as nr,
       --epr.tpemprst as nr,
       ass.nrdconta as nrdconta,
       to_char((sysdate), 'YYYYMMDD') as DtAprc,
       cop.nrdocnpj as CNPJCtrc,
       case
         when length(ass.nrcpfcgc) < 12 then
          1
         else
          2
       end as TipCli,
       ass.nrcpfcgc as IdfcCli,
       lpad(ass.cdcooper,2,0) || ass.nrdconta || epr.nrctremp as NrCtr, -- Ver a necessidade de acrescentar o tipo de contrato
       fn_busca_modalidade_bacen(case
                                   when (select dsoperac
                                           from craplcr
                                          where cdcooper = epr.cdcooper
                                            and cdlcremp = epr.cdlcremp) = 'FINANCIAMENTO' then
                                    0499
                                   else
                                    0299
                                 end,
                                 ass.cdcooper,
                                 ass.nrdconta,
                                 epr.nrctremp,
                                 ass.inpessoa,
                                 3,
                                 '') as cdproduto,
       'M' as PercPclAnt, -- Sempre Mensal
       (select max(nrparepr)
          from crappep
         where cdcooper = ass.cdcooper
           and nrdconta = ass.nrdconta
           and nrctremp = epr.nrctremp
           and inliquid = 0) as QtPclPgr,
       to_char(pep.dtvencto, 'YYYYMMDD')  as DtVnctPrxPcl,
       to_char(nvl(pep.vlparepr,0),'fm9999900V00')  as VlPrxPcl,  -- Valor da Próxima Parcela a Vencer
       (select count(1)
          from crappep
         where cdcooper = ass.cdcooper
           and nrdconta = ass.nrdconta
           and nrctremp = epr.nrctremp
           and dtvencto > sysdate
           and dtvencto >= sysdate
           and inliquid = 0)  as QtPclVncr   -- Quantidade de Parcelas a Vencer
  from crapcop cop,
       crapass ass,
       crapepr epr,-- Cadastro de emprestimos. (D-05)
       crappep pep -- Contem as parcelas do contrato de emprestimos e seus respectivos valores
where cop.cdcooper = ass.cdcooper
   --------------------------
   and ass.cdcooper = epr.cdcooper
   and ass.nrdconta = epr.nrdconta
   --------------------------
   and pep.cdcooper = epr.cdcooper
   and pep.nrdconta = epr.nrdconta
   and pep.nrctremp = epr.nrctremp
   --------------------------
   and pep.dtvencto >= sysdate
   and cop.flgativo = 1 -- indica se a cooperativa esta ativa
   and ass.incadpos = 2 -- indicador cadastro positivo (1 - nao autorizado, 2 - autorizado, 3 - cancelado)
   and epr.INLIQUID = 0    -- indica se foi efetuado pagamento total (0-pendente; 1-liquidada).
   and epr.dtliquid is null
   and epr.tpemprst IN (1, 2) -- 0-TR, 1-PP ou 2-POS
   and pep.inliquid = 0   -- indica se foi efetuado pagamento total (0-pendente; 1-liquidada).
   ---------------------------------------------------------------
   --and  cop.cdcooper = 13
   --and  epr.nrdconta = 2259
   ---------------------------------------------------------------
union
-- Contratos do tipo  0 - TR
select 2 as nr,
       --epr.tpemprst as nr,
       ass.nrdconta as nrdconta,
       to_char((sysdate), 'YYYYMMDD') as DtAprc,
       cop.nrdocnpj as CNPJCtrc,
       case
         when length(ass.nrcpfcgc) < 12 then
          1
         else
          2
       end as TipCli,
       ass.nrcpfcgc as IdfcCli,
       lpad(ass.cdcooper,2,0) || ass.nrdconta || epr.nrctremp as NrCtr, -- Ver a necessidade de acrescentar o tipo de contrato
       fn_busca_modalidade_bacen(case
                                   when (select dsoperac
                                           from craplcr
                                          where cdcooper = epr.cdcooper
                                            and cdlcremp = epr.cdlcremp) = 'FINANCIAMENTO' then
                                    0499
                                   else
                                    0299
                                 end,
                                 ass.cdcooper,
                                 ass.nrdconta,
                                 epr.nrctremp,
                                 ass.inpessoa,
                                 3,
                                 '') as cdproduto,
       'M' as PercPclAnt,     -- Sempre Mensal
       epr.qtpreemp as QtPclPgr,
       --to_char(epr.dtdpagto, 'YYYYMMDD')  as DtVnctPrxPcl,
       to_char(
           (case when epr.dtdpagto <= sysdate then
            to_date(to_char(add_months(epr.Dtmvtolt,epr.qtmesdec)  ,'yyyymmdd'),'yyyymmdd') else epr.dtdpagto end), 'yyyymmdd')  as DtVnctPrxPcl,
            --to_date( to_char(sysdate, 'yyyymm')|| to_char(epr.Dtmvtolt, 'dd')  ,'yyyymmdd') else epr.dtdpagto end), 'yyyymmdd')  as DtVnctPrxPcl,
       to_char(nvl(epr.vlpreemp,0),'fm9999900V00')  as VlPrxPcl,  -- Valor da Próxima Parcela a Vencer
       epr.qtpreemp as QtPclVncr   -- Quantidade de Parcelas a Vencer
  from crapcop cop,
       crapass ass,
       crapepr epr-- Cadastro de emprestimos. (D-05)
where cop.cdcooper = ass.cdcooper
   --------------------------
   and ass.cdcooper = epr.cdcooper
   and ass.nrdconta = epr.nrdconta
   --------------------------
   and cop.flgativo = 1    -- indica se a cooperativa esta ativa
   and ass.incadpos = 2    -- indicador cadastro positivo (1 - nao autorizado, 2 - autorizado, 3 - cancelado)
   and epr.tpemprst = 0    -- 0-TR, 1-PP ou 2-POS
   and epr.INLIQUID = 0    -- indica se foi efetuado pagamento total (0-pendente; 1-liquidada).
   and epr.dtliquid is null
   and add_months(epr.Dtmvtolt,epr.qtmesdec) > sysdate
   ---------------------------------------------------------------
   --and  cop.cdcooper = 13
   --and  epr.nrdconta = 2259
   ---------------------------------------------------------------
Union
-- Contratos liquidados ou que estão em prejuizo
select 3 as nr,
       ass.nrdconta as nrdconta,
       to_char((sysdate), 'YYYYMMDD') as DtAprc,
       cop.nrdocnpj as CNPJCtrc,
       case
         when length(ass.nrcpfcgc) < 12 then
          1
         else
          2
       end as TipCli,
       ass.nrcpfcgc as IdfcCli,
       lpad(ass.cdcooper,2,0) || ass.nrdconta || epr.nrctremp as NrCtr, -- Ver a necessidade de acrescentar o tipo de contrato
       fn_busca_modalidade_bacen(case
                                   when (select dsoperac
                                           from craplcr
                                          where cdcooper = epr.cdcooper
                                            and cdlcremp = epr.cdlcremp) = 'FINANCIAMENTO' then
                                    0499
                                   else
                                    0299
                                 end,
                                 ass.cdcooper,
                                 ass.nrdconta,
                                 epr.nrctremp,
                                 ass.inpessoa,
                                 3,
                                 '') as cdproduto,
       'M'   as PercPclAnt,     -- Sempre Mensal
       0     as QtPclPgr,       -- Quitada -> sempre 0
       null  as DtVnctPrxPcl,   -- Quitada -> sempre null
       to_char(0,'0V00')  as VlPrxPcl,  -- Valor da Próxima Parcela a Vencer
       0                  as QtPclVncr   -- Quantidade de Parcelas a Vencer
  from crapcop cop,
       crapass ass,
       crapepr epr    -- Cadastro de emprestimos. (D-05)
where cop.cdcooper = ass.cdcooper
   --------------------------
   and ass.cdcooper = epr.cdcooper
   and ass.nrdconta = epr.nrdconta
   --------------------------
   and epr.dtultpag >= add_months(sysdate, -13)  -- que foram liquidados a menos de 13 meses
   and cop.flgativo = 1    -- indica se a cooperativa esta ativa
   and ass.incadpos = 2    -- indicador cadastro positivo (1 - nao autorizado, 2 - autorizado, 3 - cancelado)
   --and epr.tpemprst = 0    -- 0-TR, 1-PP ou 2-POS
   and epr.INLIQUID = 1    -- indica se foi efetuado pagamento total (0-pendente; 1-liquidada).
   and (epr.dtliquid is not null or
        epr.inprejuz = 1)        -- Se a conta estiver em prejuizo, liquida o contrato e tranfere a conta, mas o saldo continua

   ---------------------------------------------------------------
   --and  cop.cdcooper = 13
   --and  epr.nrdconta = 2259
   ---------------------------------------------------------------
Union
-- Contratos em aberto vencidos e não pagos em dia
select 4 as nr,
       ass.nrdconta as nrdconta,
       to_char((sysdate), 'YYYYMMDD') as DtAprc,
       cop.nrdocnpj as CNPJCtrc,
       case
         when length(ass.nrcpfcgc) < 12 then
          1
         else
          2
       end as TipCli,
       ass.nrcpfcgc as IdfcCli,
       lpad(ass.cdcooper,2,0) || ass.nrdconta || epr.nrctremp as NrCtr, -- Ver a necessidade de acrescentar o tipo de contrato
       fn_busca_modalidade_bacen(case
                                   when (select dsoperac
                                           from craplcr
                                          where cdcooper = epr.cdcooper
                                            and cdlcremp = epr.cdlcremp) = 'FINANCIAMENTO' then
                                    0499
                                   else
                                    0299
                                 end,
                                 ass.cdcooper,
                                 ass.nrdconta,
                                 epr.nrctremp,
                                 ass.inpessoa,
                                 3,
                                 '') as cdproduto,
       'M'   as PercPclAnt,     -- Sempre Mensal
       0     as QtPclPgr,       -- Quitada -> sempre 0
       null  as DtVnctPrxPcl,   -- Quitada -> sempre null
       to_char(0,'0V00')  as VlPrxPcl,  -- Valor da Próxima Parcela a Vencer
       0               as QtPclVncr   -- Quantidade de Parcelas a Vencer
  from crapcop cop,
       crapass ass,
       crapepr epr    -- Cadastro de emprestimos. (D-05)
       
where cop.cdcooper = ass.cdcooper
   --------------------------
   and ass.cdcooper = epr.cdcooper
   and ass.nrdconta = epr.nrdconta
   --------------------------
   and epr.dtultpag >= add_months(sysdate, -13)  -- que foram liquidados a menos de 13 meses
   and cop.flgativo = 1    -- indica se a cooperativa esta ativa
   and ass.incadpos = 2    -- indicador cadastro positivo (1 - nao autorizado, 2 - autorizado, 3 - cancelado)
   --and epr.tpemprst = independe do tipo 0-TR, 1-PP ou 2-POS
   and epr.dtliquid is null
   and epr.INLIQUID = 0    -- indica se foi efetuado pagamento total (0-pendente; 1-liquidada).
   and epr.inprejuz = 0    -- Se a conta não estiver em prejuizo
   ---------------------------------------------------------------
   --and  cop.cdcooper = 13
   --and  epr.nrdconta = 2259
   ---------------------------------------------------------------
)
