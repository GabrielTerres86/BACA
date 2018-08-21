create or replace view cecred.vw_parcelado_parcela_futura as
select '1' nr,
       ass.nrdconta,
       to_char((sysdate), 'YYYYMMDD') as DtAprc,
       cop.nrdocnpj as CNPJCtrc,
       case
         when length(ass.nrcpfcgc) < 12 then
          1
         else
          2
       end TipCli,
       ass.nrcpfcgc as IdfcCli,
       ass.cdcooper || ass.nrdconta || epr.nrctremp as NrCtr, -- Conforme definição do Fernando Ornelas em 14/08/2018. Orientação: Ver a necessidade de acrescentar o tipo de contrato
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
       'M' PercPclAnt, --Conforme definição do Fernando Ornelas em 14/08/2018. Periodicidade das parcelas - Tem que definir a forma de como buscar esta informação.
       (select max(nrparepr)
          from crappep
         where cdcooper = ass.cdcooper
           and nrdconta = ass.nrdconta
           and nrctremp = epr.nrctremp
           and inliquid = 0) as QtPclPgr,
       to_char(pep.dtvencto, 'YYYYMMDD')  as DtVnctPrxPcl,
       to_char(nvl(pep.vlsdvpar,0),'fm9999900V00')  as VlPrxPcl,  -- Valor da Próxima Parcela a Vencer
       (select count(1)
          from crappep
         where cdcooper = ass.cdcooper
           and nrdconta = ass.nrdconta
           and nrctremp = epr.nrctremp
           and dtvencto > sysdate
           and inliquid = 0
           and dtvencto >= sysdate) as QtPclVncr   -- Quantidade de Parcelas a Vencer
  from crapass ass,
       crapcop cop,
       crapepr epr,-- Cadastro de emprestimos. (D-05)
       crappep pep -- Contem as parcelas do contrato de emprestimos e seus respectivos valores
 where cop.cdcooper = ass.cdcooper
   and cop.flgativo = 1 -- indica se a cooperativa esta ativa
   and ass.cdcooper = epr.cdcooper
   and ass.nrdconta = epr.nrdconta
   and ass.incadpos = 2 -- indicador cadastro positivo (1 - nao autorizado, 2 - autorizado, 3 - cancelado)
   and epr.tpemprst IN (0, 1, 2) -- 0-TR, 1-PP ou 2-POS
   and EPR.INLIQUID = 0    -- indica se foi efetuado pagamento total (0-pendente; 1-liquidada). 
   and pep.cdcooper = epr.cdcooper
   and pep.nrdconta = epr.nrdconta
   and pep.nrctremp = epr.nrctremp
   and pep.dtvencto >= sysdate
   and pep.inliquid = 0   -- indica se foi efetuado pagamento total (0-pendente; 1-liquidada).
   ---------------------------------------------------------------
   --and  epr.cdcooper = 1
   --and  epr.nrdconta = 669210
   --and  epr.nrctremp = 1010272
   ---------------------------------------------------------------
order by CNPJCtrc, idfccli, nrctr;
