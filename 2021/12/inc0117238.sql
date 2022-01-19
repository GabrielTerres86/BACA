-- Created on 22/12/2021 by T0032717 
DECLARE
  vr_exc_erro EXCEPTION;
  vr_dscritic crapcri.dscritic%TYPE;

  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
  
  vr_attmotor INTEGER := 0;
  
  -- Local variables here
  CURSOR cr_principal IS
    SELECT t.cdcooper, t.nrdconta, t.nrctremp, t.tpctrato, t.dtvencto_rating, t.insituacao_rating, t.inrisco_rating, t.inrisco_rating_autom 
      FROM tbrisco_operacoes t
         , craplim l
         , crapdat d
     WHERE t.cdcooper = l.cdcooper
       AND t.nrdconta = l.nrdconta
       AND t.nrctremp = l.nrctrlim
       AND d.cdcooper = l.cdcooper
       AND t.tpctrato = 1
       AND l.insitlim = 2
       AND l.tpctrlim = 1
       AND (t.dtvencto_rating < d.dtmvtoan OR t.insituacao_rating <> 4)
       AND t.inrisco_rating IS NULL;
  rw_principal cr_principal%ROWTYPE;
  
BEGIN
  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  vr_nmdireto := vr_nmdireto||'cpd/bacas/INC0117238'; 
  vr_nmarqbkp  := 'ROLLBACK_INC0117238_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  
  FOR rw_principal IN cr_principal LOOP
    -- Se nao existir inrisco_rating_autom
    IF nvl(rw_principal.inrisco_rating_autom, 0) = 0 THEN
      vr_attmotor := 1;
      BEGIN 
        UPDATE tbrisco_operacoes
           SET inrisco_rating = 2
              ,inrisco_rating_autom = 2
              ,flintegrar_sas = 1
         WHERE cdcooper = rw_principal.cdcooper
           AND nrdconta = rw_principal.nrdconta
           AND nrctremp = rw_principal.nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro ao atualizar tbrisco_operacoes. Coop: ' || rw_principal.cdcooper || ' Conta: ' || rw_principal.nrdconta || ' Contrato: ' || rw_principal.nrctremp);
          CONTINUE;
      END;
    -- Se existir inrisco_rating_autom
    ELSE
      vr_attmotor := 0;
      BEGIN 
        UPDATE tbrisco_operacoes
           SET inrisco_rating = inrisco_rating_autom
              ,flintegrar_sas = 1
         WHERE cdcooper = rw_principal.cdcooper
           AND nrdconta = rw_principal.nrdconta
           AND nrctremp = rw_principal.nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro ao atualizar tbrisco_operacoes. Coop: ' || rw_principal.cdcooper || ' Conta: ' || rw_principal.nrdconta || ' Contrato: ' || rw_principal.nrctremp);
          CONTINUE;
      END;
    END IF;
    -- grava rollback
    gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , 'UPDATE tbrisco_operacoes ' || chr(13) || 
                            '   SET inrisco_rating = NULL' || chr(13) ||
                          CASE vr_attmotor 
                          WHEN 1 THEN 
                            ' ,inrisco_rating_autom = NULL' END || chr(13) ||
                            ' WHERE cdcooper = ' || rw_principal.cdcooper || chr(13) ||
                            '   AND nrdconta = ' || rw_principal.nrdconta || chr(13) ||
                            '   AND nrctremp = ' || rw_principal.nrctremp || '; ' ||chr(13)||chr(13), FALSE); 
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
    raise_application_error(-20100, 'Erro ao atualizar contratos - ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao atualizar contratos - ' || SQLERRM);
END;
