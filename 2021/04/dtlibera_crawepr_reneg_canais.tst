PL/SQL Developer Test script 3.0
102
-- Created on 27/04/2021 by T0032717 
declare 
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_exc_erro       EXCEPTION;
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_cdcritic       crapcri.cdcritic%TYPE;  

  CURSOR cr_coop IS
    SELECT * FROM crapcop WHERE flgativo = 1;
  rw_coop cr_coop%ROWTYPE;
  
  CURSOR cr_propostas(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT * 
      FROM credito.tbepr_renegociacao_simula
     WHERE cdcooper = pr_cdcooper;
  rw_propostas cr_propostas%ROWTYPE;
  
  CURSOR cr_crawepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crawepr.nrdconta%TYPE
                   ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
    SELECT * 
      FROM crawepr
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta 
       AND nrctremp = pr_nrctremp
       AND dtlibera IS NULL
       AND tpemprst = 3;
  rw_crawepr cr_crawepr%ROWTYPE;
  
  rw_crapdat btch0001.rw_crapdat%type;
  
BEGIN
  dbms_output.enable(NULL);
  vr_nmdireto       := gene0001.fn_param_sistema('CRED', 0, 'ROOT_MICROS');
  vr_nmdireto       := vr_nmdireto || 'cpd/bacas/INC000000/';
  vr_nmarqbkp       := 'ROLLBACK_INC000000_' || to_char(SYSDATE, 'ddmmyyyy_hh24miss') || '.sql';
  vr_dados_rollback := NULL;
  
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          '-- Programa para rollback das informacoes' || chr(13),
                          FALSE);
                          
  FOR rw_coop IN cr_coop LOOP
    
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_coop.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat; 
    
    FOR rw_propostas IN cr_propostas(pr_cdcooper => rw_coop.cdcooper) LOOP
      OPEN cr_crawepr(pr_cdcooper => rw_coop.cdcooper 
                     ,pr_nrdconta => rw_propostas.nrdconta
                     ,pr_nrctremp => rw_propostas.nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
      IF cr_crawepr%FOUND THEN 
        gene0002.pc_escreve_xml(vr_dados_rollback,
                                vr_texto_rollback,
                                'UPDATE crawepr SET dtlibera = NULL WHERE cdcooper = ' || rw_coop.cdcooper || 
                                ' AND nrdconta = ' || rw_propostas.nrdconta || 
                                ' AND nrctremp = ' ||rw_propostas.nrctremp || ';' || chr(13),
                                FALSE);
        UPDATE crawepr SET dtlibera = rw_crapdat.dtmvtocd WHERE cdcooper = rw_coop.cdcooper AND nrdconta = rw_propostas.nrdconta AND nrctremp = rw_propostas.nrctremp;
      END IF;
      CLOSE cr_crawepr; 
      
    END LOOP;
  END LOOP;
  -- Adiciona TAG de commit 
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;' || chr(13), FALSE);

  -- Fecha o arquivo          
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);
  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3,
                                      pr_cdprogra  => 'ATENDA',
                                      pr_dtmvtolt  => trunc(SYSDATE),
                                      pr_dsxml     => vr_dados_rollback,
                                      pr_dsarqsaid => vr_nmdireto || '/' || vr_nmarqbkp,
                                      pr_flg_impri => 'N',
                                      pr_flg_gerar => 'S',
                                      pr_flgremarq => 'N',
                                      pr_nrcopias  => 1,
                                      pr_des_erro  => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);
  COMMIT;
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20111, vr_dscritic);
END;
0
0
