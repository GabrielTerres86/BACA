DECLARE
  vr_exc_erro EXCEPTION;
  vr_dscritic crapcri.dscritic%TYPE;

  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
  
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1 AND cdcooper = 2;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_contratos(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE) IS
    SELECT e.cdfinemp, o.*
      FROM cecred.tbrisco_operacoes o, cecred.crapepr e
     WHERE o.cdcooper = e.cdcooper 
       AND o.nrdconta = e.nrdconta
       AND o.nrctremp = e.nrctremp
       AND o.cdcooper = pr_cdcooper
       AND e.inliquid = 0
       AND e.inprejuz = 0
       AND o.flencerrado = 1
       AND o.tpctrato = 90
       AND e.cdfinemp <> 68;
  rw_contratos cr_contratos%ROWTYPE;
  
BEGIN
  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'Rollback das informacoes'||chr(13), FALSE);

  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  vr_nmdireto := vr_nmdireto||'cpd/bacas/INC0198682'; 
  vr_nmarqbkp  := 'ROLLBACK_INC0198682_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';

  FOR rw_crapcop IN cr_crapcop LOOP
    FOR rw_contratos IN cr_contratos(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      BEGIN
        UPDATE cecred.tbrisco_operacoes o
           SET o.flintegrar_sas = 1
              ,o.flencerrado = 0
         WHERE o.cdcooper = rw_contratos.cdcooper
           AND o.nrdconta = rw_contratos.nrdconta
           AND o.nrctremp = rw_contratos.nrctremp
           AND o.tpctrato = 90;
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro ao atualizar contrato' ||
                               ' - cdcooper: ' || rw_contratos.cdcooper ||
                               ' - nrdconta: ' || rw_contratos.nrdconta ||
                               ' - nrctremp: ' || rw_contratos.nrctremp);
      END;

      gene0002.pc_escreve_xml(vr_dados_rollback
                             ,vr_texto_rollback
                             ,'UPDATE cecred.tbrisco_operacoes o' || chr(13) || 
                              '   SET o.flencerrado = 1' || chr(13) || 
                              ' WHERE o.cdcooper = ' || rw_contratos.cdcooper || chr(13) || 
                              '   AND o.nrdconta = ' || rw_contratos.nrdconta || chr(13) || 
                              '   AND o.nrctremp = ' || rw_contratos.nrctremp || chr(13) || 
                              '   AND o.tpctrato = 90;' ||chr(13)||chr(13), FALSE); 
    END LOOP;
  END LOOP;
  
  -- Adiciona TAG de commit rollback
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  -- Fecha o arquivo rollback
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE); 
             
  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                             --> Cooperativa conectada
                                     ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador - utilizamos apenas um existente 
                                     ,pr_dtmvtolt  => trunc(SYSDATE)                --> Data do movimento atual
                                     ,pr_dsxml     => vr_dados_rollback             --> Arquivo XML de dados
                                     ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp --> Path/Nome do arquivo PDF gerado
                                     ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                     ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                     ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                     ,pr_nrcopias  => 1                             --> Número de cópias para impressão
                                     ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;   
  
  COMMIT;
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro - ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, SQLERRM);
END;
