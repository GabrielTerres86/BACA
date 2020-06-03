PL/SQL Developer Test script 3.0
357
DECLARE
  -- Busca os logs de adiamento de parcelas e seu contrato
  CURSOR cr_craplgm_16 IS
    SELECT craplgm.cdcooper  
          ,craplgm.nrdconta 
          ,craplgm.cdoperad
          ,craplgm.nrsequen 
          ,craplgm.idseqttl
          ,craplgm.dttransa
          ,craplgm.hrtransa
          ,crapope.cdagenci
          ,(SELECT MAX(lgi.dsdadatu)
              FROM craplgi lgi
             WHERE lgi.cdcooper = craplgm.cdcooper
               and lgi.nrdconta = craplgm.nrdconta
               and lgi.idseqttl = craplgm.idseqttl
               and lgi.DTTRANSA = craplgm.DTTRANSA
               and lgi.HRTRANSA = craplgm.HRTRANSA
               and lgi.NRSEQUEN = craplgm.NRSEQUEN
               and lgi.nmdcampo = 'Contrato') nrctremp
          ,(select ADD_MONTHS(max(TO_DATE(lgi.dsdadant,'MM/DD/RRRR')),1)
              from craplgi lgi
             where lgi.cdcooper = craplgm.cdcooper
               and lgi.nrdconta = craplgm.nrdconta
               and lgi.idseqttl = craplgm.idseqttl
               and lgi.DTTRANSA = craplgm.DTTRANSA
               and lgi.HRTRANSA = craplgm.HRTRANSA
               and lgi.NRSEQUEN = craplgm.NRSEQUEN
               and lgi.nmdcampo = 'Vencimento') dtproxvencto

     FROM craplgm
     JOIN crapope
           ON crapope.cdcooper = craplgm.cdcooper
          AND crapope.cdoperad = craplgm.cdoperad
    WHERE craplgm.dttransa >= '16/04/2020'
      AND craplgm.dstransa = 'Adiamento Vencimento Parcelas';
      
  CURSOR cr_craplgm_15 IS
    select distinct craplgm.cdcooper
          ,craplgm.nrdconta
          ,craplgm.cdoperad
          ,crappep.nrctremp
          ,crappep.nrparepr
          ,crappep.vlparepr
          ,craplgm.idseqttl
          ,(select cdagenci 
              from crapope 
             where crapope.cdcooper = craplgm.cdcooper
               AND crapope.cdoperad = craplgm.cdoperad) cdagenci
          ,craplgi.dsdadant
          ,craplgi.dsdadatu
          ,craplgm.dttransa
      from craplgm
      join craplgi
        on craplgi.cdcooper = craplgm.cdcooper
       and craplgi.nrdconta = craplgm.nrdconta
       and craplgi.idseqttl = craplgm.idseqttl
       and craplgi.DTTRANSA = craplgm.DTTRANSA
       and craplgi.HRTRANSA = craplgm.HRTRANSA
       and craplgi.NRSEQUEN = craplgm.NRSEQUEN
      join crappep
        on crappep.cdcooper = craplgi.cdcooper
       and crappep.nrdconta = craplgi.nrdconta
       and crappep.dtvencto = TO_DATE(craplgi.dsdadatu,'MM/DD/RRRR')
     where craplgm.dttransa = '15/04/2020'
       and craplgm.dstransa = 'Adiamento Vencimento Parcelas'
       and craplgi.nmdcampo = 'Vencimento'
       and (select max(pep.dtvencto)
              from crappep pep
             where pep.cdcooper = crappep.cdcooper
               and pep.nrdconta = crappep.nrdconta
               and pep.nrctremp = crappep.nrctremp) = (select max(TO_DATE(lgi.dsdadatu,'MM/DD/RRRR'))
                                                          from craplgi lgi
                                                         where lgi.cdcooper = craplgm.cdcooper
                                                           and lgi.nrdconta = craplgm.nrdconta
                                                           and lgi.idseqttl = craplgm.idseqttl
                                                           and lgi.DTTRANSA = craplgm.DTTRANSA
                                                           and lgi.HRTRANSA = craplgm.HRTRANSA
                                                           and lgi.NRSEQUEN = craplgm.NRSEQUEN
                                                           and lgi.nmdcampo = 'Vencimento')
       and exists (select 1
                     from crawepr
                    where crawepr.cdcooper = crappep.cdcooper
                      and crawepr.nrdconta = crappep.nrdconta
                      and crawepr.nrctremp = crappep.nrctremp
                      and ADD_MONTHS(TO_DATE(crawepr.dtdpagto,'DD/MM/RRRR'),crawepr.qtpreemp - 1) <> (select max(pep.dtvencto)
                                                                                                        from crappep pep
                                                                                                       where pep.cdcooper = crawepr.cdcooper
                                                                                                         and pep.nrdconta = crawepr.nrdconta
                                                                                                         and pep.nrctremp = crawepr.nrctremp))
     order by 1,2,4,5;
 
  -- Busca os detalhes do log
  CURSOR cr_craplgi(pr_cdcooper IN craplgi.cdcooper%TYPE
                   ,pr_nrdconta IN craplgi.nrdconta%TYPE
                   ,pr_idseqttl IN craplgi.idseqttl%TYPE
                   ,pr_nrsequen IN craplgi.nrsequen%TYPE
                   ,pr_dttransa IN craplgi.dttransa%TYPE
                   ,pr_hrtransa IN craplgi.hrtransa%TYPE) IS
    SELECT craplgi.nmdcampo
          ,craplgi.dsdadant
          ,craplgi.dsdadatu
      FROM craplgi craplgi
     WHERE craplgi.cdcooper = pr_cdcooper
       and craplgi.nrdconta = pr_nrdconta
       and craplgi.idseqttl = pr_idseqttl
       and craplgi.DTTRANSA = pr_dttransa
       and craplgi.HRTRANSA = pr_hrtransa
       and craplgi.NRSEQUEN = pr_nrsequen
       and craplgi.nmdcampo = 'Vencimento';
       
  -- Bucar número de parcelas pagas
  CURSOR cr_crappep_pagas(pr_cdcooper IN crapepr.cdcooper%TYPE
                         ,pr_nrdconta IN crapepr.nrdconta%TYPE
                         ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT count(*)
      FROM crappep p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.nrctremp = pr_nrctremp
       AND p.inliquid = 1;
  
  -- Busca valor da parcela específica
  CURSOR cr_crappep(pr_cdcooper IN crapepr.cdcooper%TYPE
                   ,pr_nrdconta IN crapepr.nrdconta%TYPE
                   ,pr_nrctremp IN crapepr.nrctremp%TYPE
                   ,pr_dtvencto IN crappep.dtvencto%TYPE) IS 
                   
    SELECT crappep.vlparepr
      FROM crappep
     WHERE crappep.cdcooper = pr_cdcooper
       AND crappep.nrdconta = pr_nrdconta
       AND crappep.nrctremp = pr_nrctremp
       AND crappep.dtvencto = pr_dtvencto;
       
  -- Busca primeiro vencimento do contrato
  CURSOR cr_crawepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                   ,pr_nrdconta IN crapepr.nrdconta%TYPE
                   ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT crawepr.dtdpagto
      FROM crawepr
     WHERE crawepr.cdcooper = pr_cdcooper
       AND crawepr.nrdconta = pr_nrdconta
       AND crawepr.nrctremp = pr_nrctremp;                 
       
  vr_idadiamento cecred.tbepr_adiamento_contrato.idadiamento%TYPE;
  vr_qtmaxima_adiamento cecred.tbepr_adiamento_contrato.qtmaxima_adiamento%TYPE;
  vr_qtparcelas_pagas cecred.tbepr_adiamento_contrato.qtparcelas_pagas%TYPE;
  vr_idparcela_original crappep.nrparepr%TYPE;
  vr_vlparepr crappep.vlparepr%TYPE;
  vr_dtdpagto crawepr.dtdpagto%TYPE;
  
  vr_cdcooper cecred.tbepr_adiamento_contrato.cdcooper%TYPE;
  vr_nrdconta cecred.tbepr_adiamento_contrato.nrdconta%TYPE;
  vr_nrctremp cecred.tbepr_adiamento_contrato.nrctremp%TYPE;
  vr_cdoperad cecred.tbepr_adiamento_contrato.idoperador%TYPE;
  
  vr_qtd_contrato INTEGER := 0;
  vr_qtd_parcelas INTEGER := 0;
                        
   
BEGIN
  
  --Percorre os logs apenas do dia 15
  FOR rw_craplgm IN cr_craplgm_15 LOOP
    -- Se trocou a chave, faz novo lançamento na cecred.tbepr_adiamento_contrato
    IF vr_cdcooper <> rw_craplgm.cdcooper OR
       vr_nrdconta <> rw_craplgm.nrdconta OR    
       vr_nrctremp <> rw_craplgm.nrctremp OR 
       vr_cdoperad <> rw_craplgm.cdoperad THEN
       
       vr_cdcooper := rw_craplgm.cdcooper;
       vr_nrdconta := rw_craplgm.nrdconta;
       vr_nrctremp := rw_craplgm.nrctremp;
       vr_cdoperad := rw_craplgm.cdoperad;
       
      vr_dtdpagto := null;  
      -- Busca a primeira data de vencimento do contrato
      OPEN cr_crawepr(pr_cdcooper => rw_craplgm.cdcooper 
                     ,pr_nrdconta => rw_craplgm.nrdconta 
                     ,pr_nrctremp => rw_craplgm.nrctremp);
                             
      FETCH cr_crawepr INTO vr_dtdpagto;
      CLOSE cr_crawepr; 
      
      -- Pula se não encontrou a proposta ou a data preenchida
      IF vr_dtdpagto is null THEN
        CONTINUE;
      END IF;
     
      -- Busca parametro com numero maximo de parcelas que podem ser adiadas no momento                        
       vr_qtmaxima_adiamento := to_number(NVL(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                       ,pr_cdcooper => rw_craplgm.cdcooper 
                                                                       ,pr_cdacesso => 'COVID_QTDE_PARCELA_ADIAR'),0));
                                                                      
      -- Busca o número de parcelas pagas do contrato até o momento
      OPEN cr_crappep_pagas(pr_cdcooper => rw_craplgm.cdcooper 
                           ,pr_nrdconta => rw_craplgm.nrdconta 
                           ,pr_nrctremp => rw_craplgm.nrctremp);
                          
      FETCH cr_crappep_pagas INTO vr_qtparcelas_pagas;
      CLOSE cr_crappep_pagas; 
      
      INSERT INTO cecred.tbepr_adiamento_contrato
      (dtmovimento         
      ,cdcooper            
      ,nrdconta            
      ,nrctremp            
      ,idagencia           
      ,idoperador          
      ,qtparcelas_pagas    
      ,dtproximo_vencimento
      ,qtmaxima_adiamento)
     VALUES 
      (rw_craplgm.dttransa                
      ,rw_craplgm.cdcooper            
      ,rw_craplgm.nrdconta            
      ,rw_craplgm.nrctremp            
      ,rw_craplgm.cdagenci           
      ,rw_craplgm.cdoperad          
      ,vr_qtparcelas_pagas    
      ,rw_craplgm.dttransa -- Atualizado abaixo conforme as parcelas
      ,vr_qtmaxima_adiamento)
    RETURNING idadiamento INTO vr_idadiamento;
    vr_qtd_contrato := vr_qtd_contrato + 1;   
    END IF;
    
    -- Busca os dados da parcela adiada
    OPEN cr_crappep(pr_cdcooper => rw_craplgm.cdcooper
                   ,pr_nrdconta => rw_craplgm.nrdconta
                   ,pr_nrctremp => rw_craplgm.nrctremp
                   ,pr_dtvencto => TO_DATE(rw_craplgm.dsdadatu,'MM/DD/RRRR'));
    FETCH cr_crappep INTO vr_vlparepr;
    CLOSE cr_crappep;  
      
    vr_idparcela_original := MONTHS_BETWEEN (TO_DATE(rw_craplgm.dsdadant,'MM/DD/RRRR'), vr_dtdpagto ) + 1;                                              
     
    INSERT INTO cecred.tbepr_adiamento_parcela
      (idadiamento_contrato
      ,idparcela           
      ,dtvencimento_antiga 
      ,vlparcela_antiga    
      ,dtvencimento_novo   
      ,vlparcela_nova)
     VALUES 
      (vr_idadiamento
      ,vr_idparcela_original      
      ,TO_DATE(rw_craplgm.dsdadant,'MM/DD/RRRR')
      ,vr_vlparepr
      ,TO_DATE(rw_craplgm.dsdadatu,'MM/DD/RRRR') 
      ,0);
      vr_qtd_parcelas := vr_qtd_parcelas + 1;
    -- Atualiza a data do proximo vencimento do contrato
    UPDATE cecred.tbepr_adiamento_contrato
       SET dtproximo_vencimento = ADD_MONTHS(TO_DATE(rw_craplgm.dsdadant,'MM/DD/RRRR'),1)
     WHERE idadiamento = vr_idadiamento;   
  
  END LOOP;
  
  -- FIM DOS LOGS DO DIA 15
  


  -- Percorre os logs do dia 16 em diante para gravar na cecred.tbepr_adiamento_contrato
  FOR rw_craplgm IN cr_craplgm_16 LOOP
    vr_idadiamento := 0;
    
    -- Pular o registro caso não tenha número do contrato no LOG
    IF rw_craplgm.nrctremp is null THEN
      CONTINUE;
    END IF;
  
    vr_dtdpagto := null;  
    -- Busca a primeira data de vencimento do contrato
    OPEN cr_crawepr(pr_cdcooper => rw_craplgm.cdcooper 
                   ,pr_nrdconta => rw_craplgm.nrdconta 
                   ,pr_nrctremp => rw_craplgm.nrctremp);
                           
    FETCH cr_crawepr INTO vr_dtdpagto;
    CLOSE cr_crawepr; 
   
   -- Pula se não encontrou a proposta ou a data preenchida
   IF vr_dtdpagto is null THEN
     CONTINUE;
   END IF;
    
    -- Busca parametro com numero maximo de parcelas que podem ser adiadas no momento                        
    vr_qtmaxima_adiamento := to_number(NVL(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                    ,pr_cdcooper => rw_craplgm.cdcooper 
                                                                    ,pr_cdacesso => 'COVID_QTDE_PARCELA_ADIAR'),0));
                                                                      
    -- Busca o número de parcelas pagas do contrato até o momento
    OPEN cr_crappep_pagas(pr_cdcooper => rw_craplgm.cdcooper 
                         ,pr_nrdconta => rw_craplgm.nrdconta 
                         ,pr_nrctremp => rw_craplgm.nrctremp);
                          
    FETCH cr_crappep_pagas INTO vr_qtparcelas_pagas;
    CLOSE cr_crappep_pagas; 
   
    INSERT INTO cecred.tbepr_adiamento_contrato
      (dtmovimento         
      ,cdcooper            
      ,nrdconta            
      ,nrctremp            
      ,idagencia           
      ,idoperador          
      ,qtparcelas_pagas    
      ,dtproximo_vencimento
      ,qtmaxima_adiamento)
     VALUES 
      (rw_craplgm.dttransa                
      ,rw_craplgm.cdcooper            
      ,rw_craplgm.nrdconta            
      ,rw_craplgm.nrctremp            
      ,rw_craplgm.cdagenci           
      ,rw_craplgm.cdoperad          
      ,vr_qtparcelas_pagas    
      ,rw_craplgm.dtproxvencto
      ,vr_qtmaxima_adiamento)
    RETURNING idadiamento INTO vr_idadiamento;
    vr_qtd_contrato := vr_qtd_contrato + 1; 
    
    -- Busca dados das parcelas para gravar na cecred.tbepr_adiamento_parcela
    FOR rw_craplgi IN cr_craplgi(pr_cdcooper => rw_craplgm.cdcooper
                                ,pr_nrdconta => rw_craplgm.nrdconta 
                                ,pr_idseqttl => rw_craplgm.idseqttl
                                ,pr_nrsequen => rw_craplgm.nrsequen
                                ,pr_dttransa => rw_craplgm.dttransa
                                ,pr_hrtransa => rw_craplgm.hrtransa) LOOP
                                
      -- Busca dados da parcela
      OPEN cr_crappep(pr_cdcooper => rw_craplgm.cdcooper
                     ,pr_nrdconta => rw_craplgm.nrdconta
                     ,pr_nrctremp => rw_craplgm.nrctremp
                     ,pr_dtvencto => TO_DATE(rw_craplgi.dsdadatu,'MM/DD/RRRR'));
      FETCH cr_crappep INTO vr_vlparepr;
      CLOSE cr_crappep;  
      
      vr_idparcela_original := MONTHS_BETWEEN (TO_DATE(rw_craplgi.dsdadant,'MM/DD/RRRR'), vr_dtdpagto ) + 1;                                              
     
    INSERT INTO cecred.tbepr_adiamento_parcela
      (idadiamento_contrato
      ,idparcela           
      ,dtvencimento_antiga 
      ,vlparcela_antiga    
      ,dtvencimento_novo   
      ,vlparcela_nova)
     VALUES 
      (vr_idadiamento
      ,vr_idparcela_original      
      ,TO_DATE(rw_craplgi.dsdadant,'MM/DD/RRRR')
      ,vr_vlparepr
      ,TO_DATE(rw_craplgi.dsdadatu,'MM/DD/RRRR') 
      ,0);
      vr_qtd_parcelas := vr_qtd_parcelas + 1;                         
    END LOOP;
  
  END LOOP;
  
  DBMS_OUTPUT.put_line('Resumo - Contratos: ' || vr_qtd_contrato || ' Parcelas: ' || vr_qtd_parcelas);                
  COMMIT; 
 
EXCEPTION 
  WHEN OTHERS THEN
        
    dbms_output.put_line('Erro a executar o programa:' || SQLERRM);

    ROLLBACK;
     
END;
0
0
