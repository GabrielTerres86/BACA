DECLARE 
  vr_valor_limite    NUMBER := 20000;
  vr_cdcooper        crapass.cdcooper%TYPE := 14;
  vr_nrdconta        crapass.nrdconta%TYPE := 329126;
  vr_nrcpfcgc        crapass.nrcpfcgc%TYPE := 14405416800;
  vr_cdoperad        craplcm.cdoperad%TYPE := 't0035324';
  vr_nmprograma      tbgen_prglog.cdprograma%TYPE := 'Alterar Limite Web - INC0327200';
  vr_nrdrowid        ROWID;
  vr_data_alteracao  DATE := SYSDATE;
  
  CURSOR cr_limite_preposto IS
   SELECT tlp.vllimite_transf
         ,tlp.dtlimite_transf
         ,tlp.vllimite_pagto
         ,tlp.dtlimite_pagto
     FROM tbcc_limite_preposto tlp
    WHERE tlp.cdcooper = vr_cdcooper
      AND tlp.nrdconta = vr_nrdconta;
  rw_limite_preposto cr_limite_preposto%ROWTYPE;
  
  CURSOR cr_limites_conta IS
   SELECT snh.vllimweb
         ,snh.dtlimweb
         ,snh.vllimtrf
         ,snh.dtlimtrf
         ,snh.vllimpgo
         ,snh.dtlimpgo
     FROM crapsnh snh
    WHERE snh.nrdconta = vr_nrdconta
      AND snh.cdcooper = vr_cdcooper
      AND snh.nrcpfcgc = vr_nrcpfcgc
      AND snh.tpdsenha = 1;
  rw_limites_conta cr_limites_conta%ROWTYPE;

BEGIN
  OPEN cr_limites_conta;
  FETCH cr_limites_conta INTO rw_limites_conta;
  
  IF cr_limites_conta%NOTFOUND THEN
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => vr_nrdconta
                               ,pr_idseqttl => vr_nrcpfcgc
                               ,pr_cdoperad => vr_cdoperad
                               ,pr_dscritic => 'Nao foram encontrados valores de limites para o preposto de CPF: ' || vr_nrcpfcgc
                               ,pr_dsorigem => 'AIMARO'
                               ,pr_dstransa => vr_nmprograma
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 1
                               ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                               ,pr_nmdatela => 'SCRIPT ADHOC'
                               ,pr_nrdrowid => vr_nrdrowid);
  ELSE
    UPDATE crapsnh snh
       SET snh.vllimweb = vr_valor_limite
          ,snh.dtlimweb = vr_data_alteracao
          ,snh.vllimtrf = vr_valor_limite
          ,snh.dtlimtrf = vr_data_alteracao
          ,snh.vllimpgo = vr_valor_limite
          ,snh.dtlimpgo = vr_data_alteracao
     WHERE snh.nrdconta = vr_nrdconta
       AND snh.cdcooper = vr_cdcooper
       AND snh.nrcpfcgc = vr_nrcpfcgc
       AND snh.tpdsenha = 1;
       
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => vr_nrdconta
                               ,pr_idseqttl => vr_nrcpfcgc
                               ,pr_cdoperad => vr_cdoperad
                               ,pr_dscritic => 'Atualizacao do limite da conta'
                               ,pr_dsorigem => 'AIMARO'
                               ,pr_dstransa => vr_nmprograma
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 1
                               ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                               ,pr_nmdatela => 'SCRIPT ADHOC'
                               ,pr_nrdrowid => vr_nrdrowid);
 
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapsnh.vllimweb'
                                    ,pr_dsdadant => rw_limites_conta.vllimweb
                                    ,pr_dsdadatu => vr_valor_limite);
                                    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapsnh.dtlimweb'
                                    ,pr_dsdadant => rw_limites_conta.dtlimweb
                                    ,pr_dsdadatu => vr_data_alteracao); 
                                                                        
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapsnh.vllimtrf'
                                    ,pr_dsdadant => rw_limites_conta.vllimtrf
                                    ,pr_dsdadatu => vr_valor_limite); 
                                        
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapsnh.dtlimtrf'
                                    ,pr_dsdadant => rw_limites_conta.dtlimtrf
                                    ,pr_dsdadatu => vr_data_alteracao); 
                                        
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapsnh.vllimpgo'
                                    ,pr_dsdadant => rw_limites_conta.vllimpgo
                                    ,pr_dsdadatu => vr_valor_limite); 
                                        
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapsnh.dtlimpgo'
                                    ,pr_dsdadant => rw_limites_conta.dtlimpgo
                                    ,pr_dsdadatu => vr_data_alteracao);  
                                    
  END IF;
  CLOSE cr_limites_conta;
  
  OPEN cr_limite_preposto;
  FETCH cr_limite_preposto INTO rw_limite_preposto;
  
  IF cr_limite_preposto%NOTFOUND THEN
    INSERT INTO tbcc_limite_preposto
      (cdcooper
      ,nrdconta
      ,nrcpf
      ,cdoperad
      ,vllimite_transf
      ,dtlimite_transf
      ,vllimite_pagto
      ,dtlimite_pagto
      ,vllimite_ted
      ,dtlimite_ted
      ,vllimite_vrboleto
      ,dtlimite_vrboleto
      ,vllimite_folha
      ,dtlimite_folha)
    VALUES
      (vr_cdcooper
      ,vr_nrdconta
      ,vr_nrcpfcgc
      ,'996'
      ,vr_valor_limite
      ,vr_data_alteracao
      ,vr_valor_limite
      ,vr_data_alteracao
      ,vr_valor_limite
      ,vr_data_alteracao
      ,vr_valor_limite
      ,vr_data_alteracao
      ,vr_valor_limite
      ,vr_data_alteracao);
      
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => vr_nrdconta
                               ,pr_idseqttl => vr_nrcpfcgc
                               ,pr_cdoperad => vr_cdoperad
                               ,pr_dscritic => 'Inclusao de limite para preposto'
                               ,pr_dsorigem => 'AIMARO'
                               ,pr_dstransa => vr_nmprograma
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 1
                               ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                               ,pr_nmdatela => 'SCRIPT ADHOC'
                               ,pr_nrdrowid => vr_nrdrowid);
      
  ELSE
    UPDATE tbcc_limite_preposto tlp
       SET tlp.vllimite_transf = vr_valor_limite
          ,tlp.dtlimite_transf = vr_data_alteracao
          ,tlp.vllimite_pagto  = vr_valor_limite
          ,tlp.dtlimite_pagto  = vr_data_alteracao
     WHERE tlp.cdcooper = vr_cdcooper
       AND tlp.nrdconta = vr_nrdconta
       AND tlp.nrcpf    = vr_nrcpfcgc;
       
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => vr_nrdconta
                               ,pr_idseqttl => vr_nrcpfcgc
                               ,pr_cdoperad => vr_cdoperad
                               ,pr_dscritic => 'Atualizacao do limite do preposto'
                               ,pr_dsorigem => 'AIMARO'
                               ,pr_dstransa => vr_nmprograma
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 1
                               ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                               ,pr_nmdatela => 'SCRIPT ADHOC'
                               ,pr_nrdrowid => vr_nrdrowid);
 
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'tbcc_limite_preposto.vllimite_transf'
                                    ,pr_dsdadant => rw_limite_preposto.vllimite_transf
                                    ,pr_dsdadatu => vr_valor_limite);
                                    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'tbcc_limite_preposto.dtlimite_transf'
                                    ,pr_dsdadant => rw_limite_preposto.dtlimite_transf
                                    ,pr_dsdadatu => vr_data_alteracao); 
                                                                        
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'tbcc_limite_preposto.vllimite_pagto'
                                    ,pr_dsdadant => rw_limite_preposto.vllimite_pagto
                                    ,pr_dsdadatu => vr_valor_limite); 
                                        
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'tbcc_limite_preposto.dtlimite_pagto'
                                    ,pr_dsdadant => rw_limite_preposto.dtlimite_pagto
                                    ,pr_dsdadatu => vr_data_alteracao);  
  END IF;
  
  CLOSE cr_limite_preposto;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper
                                ,pr_compleme => ' Script: => ' || vr_nmprograma    ||
                                                ' cdcooper:'   || vr_cdcooper      ||
                                                ';nrdconta:'   || vr_nrdconta      ||
                                                ';nrcpfcgc:'   || vr_nrcpfcgc);
END;
