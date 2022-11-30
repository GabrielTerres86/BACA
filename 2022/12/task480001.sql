DECLARE
  vr_exc_erro       EXCEPTION;
  vr_dsdireto       VARCHAR2(2000);
  vr_dscritic       VARCHAR2(4000);
  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);

  TYPE typ_reg_contratos IS RECORD (
    cdcooper cecred.crapepr.cdcooper%TYPE,
    nrdconta cecred.crapepr.nrdconta%TYPE,
    nrctremp cecred.crapepr.nrctremp%TYPE,
    qtprepag cecred.crapepr.qtprepag%TYPE,
    qtpagpep cecred.crapepr.qtprepag%TYPE
  );

  TYPE typ_tab_contratos IS TABLE OF typ_reg_contratos INDEX BY VARCHAR2(100);
  vr_index VARCHAR2(100);

  vr_tab_contratos typ_tab_contratos;

  CURSOR cr_contratos IS
  SELECT e.cdcooper
        ,e.nrdconta
        ,e.nrctremp
        ,e.qtprepag
        ,COUNT(p.nrparepr) qtpagpep
    FROM cecred.crapepr e
    JOIN cecred.crappep p
      ON (e.cdcooper = p.cdcooper AND e.nrdconta = p.nrdconta AND
        e.nrctremp = p.nrctremp AND p.inliquid = 1)
  WHERE e.inliquid = 0
    AND e.tpemprst = 2 
  HAVING COUNT(p.nrparepr) <> e.qtprepag
  GROUP BY e.cdcooper
          ,e.nrdconta
          ,e.nrctremp
          ,e.qtprepag;

BEGIN

  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);

  vr_dsdireto := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto := vr_dsdireto||'cpd/bacas/INC0234580/';
  vr_nmarqbkp := 'rollback_task480001_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';

  FOR rw_contratos IN cr_contratos LOOP
    vr_index := rw_contratos.cdcooper || ';' || rw_contratos.nrdconta || ';' || rw_contratos.nrctremp;
    vr_tab_contratos(vr_index).cdcooper := rw_contratos.cdcooper;
    vr_tab_contratos(vr_index).nrdconta := rw_contratos.nrdconta;
    vr_tab_contratos(vr_index).nrctremp := rw_contratos.nrctremp;
    vr_tab_contratos(vr_index).qtprepag := rw_contratos.qtprepag;
    vr_tab_contratos(vr_index).qtpagpep := rw_contratos.qtpagpep;

    gene0002.pc_escreve_xml(vr_dados_rollback
                          ,vr_texto_rollback
                          ,'UPDATE cecred.crapepr' || chr(13) ||
                           'SET qtprepag = '   || rw_contratos.qtprepag || chr(13) ||
                           'WHERE cdcooper = ' || rw_contratos.cdcooper || chr(13) ||
                           '  AND nrdconta = ' || rw_contratos.nrdconta || chr(13) ||
                           '  AND nrctremp = ' || rw_contratos.nrctremp || ';' || chr(13) || chr(13), FALSE);
  END LOOP;                                
  
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);
             
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                             
                                     ,pr_cdprogra  => 'ATENDA'                      
                                     ,pr_dtmvtolt  => trunc(SYSDATE)                
                                     ,pr_dsxml     => vr_dados_rollback             
                                     ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp 
                                     ,pr_flg_impri => 'N'                           
                                     ,pr_flg_gerar => 'S'                           
                                     ,pr_flgremarq => 'N'                           
                                     ,pr_nrcopias  => 1                             
                                     ,pr_des_erro  => vr_dscritic);                 
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  vr_index := vr_tab_contratos.first;
  WHILE vr_index IS NOT NULL LOOP

    UPDATE cecred.crapepr
      SET qtprepag = vr_tab_contratos(vr_index).qtpagpep
      WHERE cdcooper = vr_tab_contratos(vr_index).cdcooper
        AND nrdconta = vr_tab_contratos(vr_index).nrdconta
        AND nrctremp = vr_tab_contratos(vr_index).nrctremp; 

    vr_index := vr_tab_contratos.next(vr_index);
  END LOOP;
  
  COMMIT;
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro: ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, SQLERRM);
END;
