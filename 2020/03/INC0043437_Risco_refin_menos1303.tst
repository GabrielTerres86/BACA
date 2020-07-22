PL/SQL Developer Test script 3.0
211
declare 
    CURSOR cr_crapepr IS 
        select p.cdcooper,
               p.nrdconta,
               p.nrctremp,
               w.dtdpagto dtdpripg,
               p.dtmvtolt,
               w.flgreneg flgreneg,
               p.dtinicio_atraso_refin,
               w.dsnivori
       from crapepr p              
       inner join crawepr w on p.cdcooper = w.cdcooper and p.nrdconta = w.nrdconta and p.nrctremp = w.nrctremp
       where w.flgreneg = 1 
             and p.inrisco_refin > 0         
             and p.dtmvtolt >= '28/01/2020' and p.dtmvtolt < '13/03/2020' 
             and p.idquaprc in (3,4)
             and p.cdcooper not in (3)
             and p.dtinicio_atraso_refin is not null;
             
    CURSOR cr_crappep_maior (pr_cdcooper IN tbepr_renegociacao_crappep.cdcooper%TYPE,
                            pr_dtmvtoan IN crapdat.dtmvtoan%TYPE,
						                pr_nrdconta IN tbepr_renegociacao_crappep.nrdconta%TYPE,
                            pr_nrctremp IN tbepr_renegociacao_crappep.nrctremp%TYPE) IS           
        select pep.nrdconta
              ,pep.nrctremp
              ,MIN(pep.dtvencto) dtvencto
          from crappep pep
         where pep.cdcooper = pr_cdcooper
           and (pep.inliquid = 0 OR pep.inprejuz = 1)
           and pep.dtvencto <= pr_dtmvtoan
           and pep.nrdconta = pr_nrdconta
           and pep.nrctremp = pr_nrctremp
         group by pep.nrdconta
                 ,pep.nrctremp;
  
  pr_qtdiaref        NUMBER;          --> Dias do Refin Atual
  vr_dtvencto        DATE;
  vr_qtdiaatr_reneg PLS_INTEGER;
  vr_qtdiaatr       PLS_INTEGER;  
  pr_qtdias_atr   PLS_INTEGER;
  vr_datarefe       DATE;             -- Variavel A
  vr_risco_refin    PLS_INTEGER:=2;   -- Risco baseado na quantidade de dias
  --pr_qtdiaatr   PLS_INTEGER;
  vr_dias           PLS_INTEGER; --> Número de dias em relação as parcelas pagas * meses decorridos
  
  -- Erro em chamadas da pc_gera_erro
  vr_des_reto        VARCHAR(4000);
  vr_tab_erro        GENE0001.typ_tab_erro;  
  vr_exc_erro        EXCEPTION;
  vr_dscritic        VARCHAR2(2000);
  
  rw_crappep_maior   cr_crappep_maior%ROWTYPE;
  rw_crapdat         btch0001.cr_crapdat%ROWTYPE;
  vr_idxpep          VARCHAR2(50);   
  
begin

  FOR rw_crapepr IN cr_crapepr LOOP  
  
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapepr.cdcooper);
        FETCH btch0001.cr_crapdat
          INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
  
  -- FORMULA: X = (A - B) + C
    -- X => QUANTIDADE DIAS ATRASO PARA CALCULO DO RISCO REFIN
    -- A => DATA ATUAL OU DATA DO VENCTO DA PRIMEIRA PARCELA
    -- B => DATA DE INICIO DO PIOR ATRASO DOS CONTRATOS REFINANCIADOS
    -- C => QUANTIDADE DIAS ATRASO DO CONTRATO ATUAL

    -- Se o vencimento da primeira parcela for superior a data atual da central
    -- de risco, deverá ser a data da Central. Caso contrario, deverá ser a
    -- data do vencimento da primeira parcela

    -- 11/09/18 - Alteração da Regra por solicitação do Gilmar/Credito
    --   "Se o contrato for efetivado antes do dia 05/09 e vencimento da primeira parcela
    --    for maior que  a data atual (sistema), para esses casos o sistema atribui o
    --    risco original no risco refin"
    --   Tratamento para diferenciar contratos novos após a liberação 

    pr_qtdias_atr := 0; 

    -- 1o Vencto >= Data do Dia ?
    IF rw_crapepr.dtdpripg >= rw_crapdat.dtmvtolt THEN
      vr_datarefe := rw_crapdat.dtmvtolt;
    ELSE
      vr_datarefe := rw_crapepr.dtdpripg;
    END IF;
  
  ----------------------- RISCO ATRASO ---------------------
    -- Sem atraso e risco A
    vr_qtdiaatr       := 0;    
    vr_dias           := 0;    

    -- Buscar a parcela com maior atraso
    vr_dtvencto := NULL;
    vr_idxpep   := lpad(rw_crapepr.cdcooper, 5, '0') ||
                   lpad(rw_crapepr.nrdconta, 10, '0') ||
                   lpad(rw_crapepr.nrctremp, 10, '0');
                   
    OPEN cr_crappep_maior(pr_cdcooper => rw_crapepr.cdcooper,
                          pr_dtmvtoan => rw_crapdat.dtmvtoan,
                          pr_nrdconta => rw_crapepr.nrdconta,
                          pr_nrctremp => rw_crapepr.nrctremp);
    FETCH cr_crappep_maior INTO rw_crappep_maior;                      
    IF cr_crappep_maior%FOUND THEN
      vr_dtvencto := rw_crappep_maior.dtvencto;
    END IF;
    CLOSE cr_crappep_maior;

    -- Se encontrou
    IF vr_dtvencto IS NOT NULL THEN
      -- Calcular a quantidade de dias em atraso
      vr_qtdiaatr  := rw_crapdat.dtmvtolt - vr_dtvencto;
      vr_dias      := vr_qtdiaatr;
    ELSE
      -- Sem atraso e risco A
      vr_qtdiaatr  := 0;
      vr_dias      := 0;
    END IF;
    ----------------------- RISCO ATRASO ---------------------
  
  -- Inicio -- PRJ577 -- EST24028
  --  vr_qtdiaatr_reneg := 0;
  --  IF rw_crapepr.flgreneg = 0  THEN -- Faria TODO:
  --    vr_qtdiaatr_reneg := EMPR0021.fn_dias_atraso_ctr_reneg(pr_cdcooper => rw_crapepr.cdcooper
  --                                                    ,pr_nrdconta => rw_crapepr.nrdconta
   --                                                   ,pr_nrctremp => rw_crapepr.nrctremp
    --                                                  );
   -- END IF;
    -- Fim -- PRJ577 - EST24028
    -- PJ577 contrato renegociado o risco continua mesmo que o contrato seja renegociado e fique em dia
    --pr_qtdiaatr := vr_qtdiaatr + vr_qtdiaatr_reneg;

    -- Valido para contratos EFETIVADOS APOS 05/Set/2018
    IF  rw_crapepr.dtmvtolt >= to_date('05/09/2018','DD/MM/YYYY') THEN

    -- X => QUANTIDADE DIAS ATRASO PARA CALCULO DO RISCO REFIN =>  X = (A - B) + C
    pr_qtdias_atr := (vr_datarefe - rw_crapepr.dtinicio_atraso_refin) + vr_qtdiaatr;

    -- Baseado na quantidade de dias, retorna o nivel de risco (Numerico para Alfa)
    vr_risco_refin := RISC0004.fn_calcula_niv_risco_atraso(qtdiaatr   => pr_qtdias_atr
                                                          ,flrisco_aa => FALSE);
    ELSE
      --  Se a parcela ainda nao venceu, assume risco original
      IF rw_crapepr.dtdpripg >= rw_crapdat.dtmvtolt THEN
        -- Assume o Risco Original / Inclusao
        pr_qtdias_atr := CASE WHEN rw_crapepr.dsnivori = 'A'  THEN 0
                              WHEN rw_crapepr.dsnivori = 'B'  THEN 15
                              WHEN rw_crapepr.dsnivori = 'C'  THEN 31
                              WHEN rw_crapepr.dsnivori = 'D'  THEN 61
                              WHEN rw_crapepr.dsnivori = 'E'  THEN 91
                              WHEN rw_crapepr.dsnivori = 'F'  THEN 121
                              WHEN rw_crapepr.dsnivori = 'G'  THEN 151
                              WHEN rw_crapepr.dsnivori = 'H'  THEN 181
                              WHEN rw_crapepr.dsnivori = 'HH' THEN 181
                              ELSE 0 END;
        -- Baseado na quantidade de dias, retorna o nivel de risco (Numerico para Alfa)
        vr_risco_refin := RISC0004.fn_calcula_niv_risco_atraso(qtdiaatr   => pr_qtdias_atr
                                                              ,flrisco_aa => FALSE);
      ELSE
        -- X => QUANTIDADE DIAS ATRASO PARA CALCULO DO RISCO REFIN =>  X = (A - B) + C
        pr_qtdias_atr := (vr_datarefe - rw_crapepr.dtinicio_atraso_refin) + vr_qtdiaatr;

        -- Baseado na quantidade de dias, retorna o nivel de risco (Numerico para Alfa)
        vr_risco_refin := RISC0004.fn_calcula_niv_risco_atraso(qtdiaatr   => pr_qtdias_atr
                                                              ,flrisco_aa => FALSE);
      END IF;

    END IF;

    -- Tratamento para Trava Minima do Risco Refin
    IF pr_qtdiaref > pr_qtdias_atr THEN
      -- Se o dias em atraso do Refin atual(pr_qtdiaref) é
      -- maior que o dias atraso Calculado(pr_qtdias_atr),
      -- assume a qtde dias existente.
      pr_qtdias_atr := pr_qtdiaref;
      -- Baseado na quantidade de dias, retorna o nivel de risco (Numerico para Alfa)
      vr_risco_refin := RISC0004.fn_calcula_niv_risco_atraso(qtdiaatr   => pr_qtdias_atr
                                                            ,flrisco_aa => FALSE);
    END IF; 
    
    BEGIN
  
	      UPDATE crapepr
                SET crapepr.inrisco_refin = vr_risco_refin, crapepr.qtdias_atraso_refin = NVL(pr_qtdias_atr,0)
                WHERE crapepr.cdcooper = rw_crapepr.cdcooper
                and crapepr.nrdconta = rw_crapepr.nrdconta
                and crapepr.nrctremp = rw_crapepr.nrctremp;
         
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar crapepr. ' || SQLERRM;
        RAISE vr_exc_erro;
        
    END;
  
  END LOOP;
  
  commit;
  :result := 'Sucesso';   
  
exception
  WHEN vr_exc_erro THEN
    ROLLBACK;
    :result := vr_dscritic;
  when others then
    ROLLBACK;
    :result := sqlerrm;

end;
