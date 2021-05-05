PL/SQL Developer Test script 3.0
129
-- Created on 22/02/2021 by T0032717 
DECLARE 
  
  CURSOR cr_crapcop IS
    SELECT cdcooper, nmrescop
      FROM crapcop
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_principal(pr_cdcooper IN crapepr.cdcooper%TYPE) IS
    SELECT dtprejuz, nrdconta, nrctremp, vlprejuz, cdcooper
      FROM crapepr 
     WHERE cdcooper = pr_cdcooper
       AND tpemprst = 1
       AND inprejuz = 1 
       AND inliquid = 1 
       AND dtprejuz > '01/01/2020' --AND '30/12/2020'
       AND vlsdprej > 0  -- prejuizos nao liquidados
       ORDER BY dtprejuz ASC;
  rw_principal cr_principal%ROWTYPE;
  
  CURSOR cr_lancamento(pr_cdcooper IN craplem.cdcooper%TYPE
                      ,pr_nrdconta IN craplem.nrdconta%TYPE
                      ,pr_nrctremp IN craplem.nrctremp%TYPE
                      ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS
    SELECT vllanmto
      FROM craplem 
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND dtmvtolt = pr_dtmvtolt 
       AND cdhistor = 2381;
  rw_lancamento cr_lancamento%ROWTYPE;

  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_exc_erro       EXCEPTION;
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_cdcritic       crapcri.cdcritic%TYPE; 
    
  vr_vllanmto NUMBER;
  vr_flgativo INTEGER;  
BEGIN
  dbms_output.enable(NULL);
  vr_nmdireto       := gene0001.fn_param_sistema('CRED', 0, 'ROOT_MICROS');
  vr_nmdireto       := vr_nmdireto || 'cpd/bacas/INC0073397/';
  vr_nmarqbkp       := 'ROLLBACK_INC0073397_' || to_char(SYSDATE, 'ddmmyyyy_hh24miss') || '.sql';
  vr_dados_rollback := NULL;
  
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          '-- Programa para rollback das informacoes' || chr(13),
                          FALSE);
                          
  FOR rw_crapcop IN cr_crapcop LOOP
    FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      vr_vllanmto := 0;
      OPEN cr_lancamento(pr_cdcooper => rw_principal.cdcooper
                        ,pr_nrdconta => rw_principal.nrdconta
                        ,pr_nrctremp => rw_principal.nrctremp
                        ,pr_dtmvtolt => rw_principal.dtprejuz);
      FETCH cr_lancamento INTO rw_lancamento;
      IF cr_lancamento%NOTFOUND THEN
        CLOSE cr_lancamento;
        CONTINUE;
      END IF;
      vr_vllanmto := rw_lancamento.vllanmto;
      CLOSE cr_lancamento;
      IF rw_principal.vlprejuz < vr_vllanmto THEN
        RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => rw_crapcop.cdcooper,
                                          pr_nrdconta => rw_principal.nrdconta,
                                          pr_nrctremp => rw_principal.nrctremp,
                                          pr_cdorigem => 3,
                                          pr_flgativo => vr_flgativo,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
        
        IF vr_flgativo <> 1 THEN
          gene0002.pc_escreve_xml(vr_dados_rollback,
                                vr_texto_rollback,
                                'UPDATE crapepr SET vlprejuz = '|| rw_principal.vlprejuz ||
                                ' WHERE cdcooper = ' || rw_crapcop.cdcooper   || 
                                '   AND nrdconta = ' || rw_principal.nrdconta || 
                                '   AND nrctremp = ' || rw_principal.nrctremp || ';' || chr(13),
                                FALSE);
          UPDATE crapepr 
             SET vlprejuz = vr_vllanmto 
           WHERE cdcooper = rw_crapcop.cdcooper
             AND nrdconta = rw_principal.nrdconta
             AND nrctremp = rw_principal.nrctremp;
          
        END IF;
      END IF;
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
