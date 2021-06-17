PL/SQL Developer Test script 3.0
92
-- Created on 17/03/2021 by T0032717 
DECLARE
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_exc_erro       EXCEPTION;
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_cdcritic       crapcri.cdcritic%TYPE;  
  
  CURSOR cr_crapcop IS
    SELECT cdcooper, nmrescop
      FROM crapcop
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_principal(pr_cdcooper IN crapepr.cdcooper%TYPE) IS 
    SELECT dtprejuz, nrdconta, nrctremp, vlprejuz, cdcooper, vlpgjmpr, vlttjmpr, vlpiofpr, vltiofpr
      FROM crapepr 
     WHERE cdcooper = pr_cdcooper
       AND tpemprst = 1
       AND inprejuz = 1 
       AND inliquid = 1 
       AND dtprejuz BETWEEN '01/01/2019' AND '30/12/2021'
       AND vlsdprej = 0
       AND vlttjmpr < vlpgjmpr  -- total < pago
       ORDER BY dtprejuz ASC;
  rw_principal cr_principal%ROWTYPE;
  
BEGIN
  vr_nmdireto       := gene0001.fn_param_sistema('CRED', 0, 'ROOT_MICROS');
  vr_nmdireto       := vr_nmdireto || 'cpd/bacas/INC0078093/';
  vr_nmarqbkp       := 'ROLLBACK_INC0078093_' || to_char(SYSDATE, 'ddmmyyyy_hh24miss') || '.sql';
  vr_dados_rollback := NULL;
  
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          '-- Programa para rollback das informacoes' || chr(13),
                          FALSE);
  FOR rw_crapcop IN cr_crapcop LOOP
    FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      
      UPDATE crapepr 
         SET vlpgjmpr = rw_principal.vlttjmpr,
             vlpiofpr = rw_principal.vltiofpr
       WHERE cdcooper = rw_crapcop.cdcooper   
         AND nrdconta = rw_principal.nrdconta 
         AND nrctremp = rw_principal.nrctremp;
                                       
      gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                              'UPDATE crapepr SET vlpgjmpr = ' || rw_principal.vlpgjmpr || 
                                               ', vlpiofpr = 0' ||
                              ' WHERE cdcooper = ' || rw_crapcop.cdcooper   || 
                                ' AND nrdconta = '   || rw_principal.nrdconta ||
                                ' AND nrctremp = '   || rw_principal.nrctremp || ';' || chr(13),
                               FALSE);
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
