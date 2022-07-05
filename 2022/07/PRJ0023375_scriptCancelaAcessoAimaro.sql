DECLARE
  
  CURSOR cr_opcao_bloq IS
    SELECT ace.*
         , ROWID dsdrowid
      FROM crapace  ace
     WHERE UPPER(ace.nmdatela) = 'CONTAS'
       AND ace.idambace = 2 
       AND (UPPER(ace.nmrotina),UPPER(ace.cddopcao)) IN (('CONJUGE','A')
                                                        ,('E_MAILS','A')
                                                        ,('E_MAILS','E')
                                                        ,('E_MAILS','I')
                                                        ,('ENDERECO','A')
                                                        ,('FATCA CRS','A')
                                                        ,('COMERCIAL','A')
                                                        ,('BENS','A')
                                                        ,('BENS','E')
                                                        ,('BENS','I')
                                                        ,('FINANCEIRO-FATURAMENTO','A')
                                                        ,('FINANCEIRO-FATURAMENTO','E')
                                                        ,('FINANCEIRO-FATURAMENTO','I')
                                                        ,('IMUNIDADE TRIBUTARIA','A'));

  vr_dsrollback    CLOB;
  vr_base_ins      CONSTANT VARCHAR2(100) := 'INSERT INTO crapace(nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace) values ';
  vr_dscritic      VARCHAR2(2000);
  vr_caminho       CONSTANT VARCHAR2(100) := '/progress/t0034474/usr/coop/cecred/log'; -- /cpd/bacas/PRJ0023375/
  vr_arquivo       CONSTANT VARCHAR2(100) := 'PRJ0023375_rollbackAcessosAimaroWeb.sql';

BEGIN
  
  vr_dsrollback := 'BEGIN '||CHR(10);
  
  GENE0002.pc_clob_para_arquivo(pr_clob     => vr_dsrollback
                               ,pr_caminho  => vr_caminho
                               ,pr_arquivo  => vr_arquivo
                               ,pr_flappend => 'N'
                               ,pr_des_erro => vr_dscritic);
      
  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20010,'Erro ao gerar arquivo de rollback: '||vr_dscritic);
  END IF;
      
  vr_dsrollback := NULL;
  
  FOR reg IN cr_opcao_bloq LOOP
    
    IF LENGTH(vr_dsrollback) >= 30000 THEN
      GENE0002.pc_clob_para_arquivo(pr_clob     => vr_dsrollback
                                   ,pr_caminho  => vr_caminho
                                   ,pr_arquivo  => vr_arquivo
                                   ,pr_flappend => 'S'
                                   ,pr_des_erro => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        raise_application_error(-20011,'Erro ao gerar arquivo de rollback: '||vr_dscritic);
      END IF;
      
      vr_dsrollback := NULL;
    END IF;
  
    BEGIN
      vr_dsrollback := vr_dsrollback||vr_base_ins||'('''||reg.nmdatela||''','''||
                                                          reg.cddopcao||''','''||
                                                          reg.cdoperad||''','''||
                                                          reg.nmrotina||''','||
                                                          reg.cdcooper||','||
                                                          reg.nrmodulo||','||
                                                          reg.idevento||','||
                                                          reg.idambace||'); '||CHR(10);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20002,'Erro ao montar comando rollback: '||SQLERRM);
    END;
    
    BEGIN
      DELETE crapace 
       WHERE ROWID = reg.dsdrowid;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20001,'Erro ao excluir registro de acesso: '||SQLERRM);
    END;
      
  END LOOP;

  vr_dsrollback := vr_dsrollback||' COMMIT; '||CHR(10)||'END; ';
       
  GENE0002.pc_clob_para_arquivo(pr_clob     => vr_dsrollback
                               ,pr_caminho  => vr_caminho
                               ,pr_arquivo  => vr_arquivo
                               ,pr_flappend => 'S'
                               ,pr_des_erro => vr_dscritic);
  
  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20012,'Erro ao gerar arquivo de rollback: '||vr_dscritic);
  END IF;
  
  --COMMIT;
  ROLLBACK;
  
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000,'ERRO SCRIPT ACESSOS: '||SQLERRM);
END;
