-- Created on 10/02/2022 by T0032717 
DECLARE

  CURSOR cr_crapcop IS
    SELECT cdcooper, nmrescop 
      FROM crapcop
     WHERE flgativo = 1
       AND cdcooper <> 3;
  rw_crapcop cr_crapcop%ROWTYPE;

  CURSOR cr_principal(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT o.cdcooper,
           o.nrdconta,
           o.nrctremp,
           o.inrisco_rating,
           o.dtrisco_rating,
           o.inrisco_inclusao,
           w.dsnivori
      FROM tbrisco_operacoes o, crapepr e, crawepr w
     WHERE o.cdcooper = e.cdcooper
       AND o.nrdconta = e.nrdconta
       AND o.nrctremp = e.nrctremp
       AND e.cdcooper = w.cdcooper
       AND e.nrdconta = w.nrdconta
       AND e.nrctremp = w.nrctremp
       AND o.tpctrato = 90
       AND e.inliquid = 0
       AND o.cdcooper = pr_cdcooper
       AND w.flgreneg = 1
       AND ((o.inrisco_rating IS NULL) OR
           (o.dtvencto_rating < SYSDATE - 1 AND o.flintegrar_sas = 0))
     ORDER BY o.cdcooper, o.nrdconta ASC;
  rw_principal cr_principal%ROWTYPE;
  
  --Variaveis para retorno de erro
  vr_cdcritic      INTEGER:= 0;
  vr_dscritic      VARCHAR2(4000);
  vr_exc_erro      EXCEPTION;
  
  vr_nmarqrbk       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(400); 
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);

BEGIN
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0124950';
  
  FOR rw_crapcop IN cr_crapcop LOOP
    vr_nmarqrbk := 'ROLLBACK_'||rw_crapcop.nmrescop||'_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
    
    vr_dados_rollback := NULL;

    dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);     

    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  
    FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
    
     UPDATE tbrisco_operacoes a 
         SET a.flintegrar_sas = 1,
             a.inrisco_rating = a.inrisco_rating_autom,
             a.dtrisco_rating = a.dtrisco_rating_autom,
             a.inrisco_inclusao = 2
       WHERE a.cdcooper = rw_principal.cdcooper 
         AND a.nrdconta = rw_principal.nrdconta
         AND a.nrctremp = rw_principal.nrctremp
         AND a.tpctrato = 90;
         
      UPDATE crawepr e
         SET e.dsnivori = 'A'
       WHERE e.cdcooper = rw_principal.cdcooper 
         AND e.nrdconta = rw_principal.nrdconta 
         AND e.nrctremp = rw_principal.nrctremp;
         
      gene0002.pc_escreve_xml(vr_dados_rollback
                             ,vr_texto_rollback
                             ,'UPDATE tbrisco_operacoes a ' || chr(13) || 
                              '   SET a.flintegrar_sas = 0'|| chr(13) ||
                              '      ,a.inrisco_rating = ' || rw_principal.inrisco_rating || chr(13) ||
                              '      ,a.dtrisco_rating = to_date(''' || to_char(rw_principal.dtrisco_rating, 'dd/mm/yyyy') || ''', ''dd/mm/yyyy'')' || chr(13) ||
                              '      ,a.inrisco_inclusao = ' || rw_principal.inrisco_inclusao || chr(13) ||
                              ' WHERE a.cdcooper = ' || rw_principal.cdcooper  || chr(13) ||
                              '   AND a.nrdconta = ' || rw_principal.nrdconta  || chr(13) ||
                              '   AND a.nrctremp = ' || rw_principal.nrctremp  || chr(13) ||
                              '   AND a.tpctrato = 90;' ||chr(13)||chr(13) ||
                              'UPDATE crawepr e ' || chr(13) || 
                              '   SET e.dsnivori = ''' || rw_principal.dsnivori || '''' || chr(13) ||
                              ' WHERE e.cdcooper = ' || rw_principal.cdcooper  || chr(13) ||
                              '   AND e.nrdconta = ' || rw_principal.nrdconta  || chr(13) ||
                              '   AND e.nrctremp = ' || rw_principal.nrctremp  || ';' ||chr(13)||chr(13), FALSE);    
    END LOOP;
    
    -- Adiciona TAG de commit 
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
          
    -- Fecha o arquivo          
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);    
    
    -- Grava o arquivo de rollback
    GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                     --> Cooperativa conectada
                                       ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador - utilizamos apenas um existente 
                                       ,pr_dtmvtolt  => trunc(SYSDATE)                --> Data do movimento atual
                                       ,pr_dsxml     => vr_dados_rollback             --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqrbk --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                             --> Número de cópias para impressão
                                       ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
          
    IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;  
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_dados_rollback);
    dbms_lob.freetemporary(vr_dados_rollback);  
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    raise_application_error(-20111, vr_dscritic);
END;
