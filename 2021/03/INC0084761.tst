PL/SQL Developer Test script 3.0
170
-- Created on 31/03/2021 by T0032717 
DECLARE 
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_cdcritic crapcri.cdcritic%TYPE;
  
  CURSOR cr_crapcop IS
    SELECT * 
      FROM crapcop 
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_tbgrv_registro_contrato(pr_cdcooper IN tbgrv_registro_contrato.cdcooper%TYPE
                                   ,pr_nrdconta IN tbgrv_registro_contrato.nrdconta%TYPE
                                   ,pr_nrctrpro IN tbgrv_registro_contrato.nrctrpro%TYPE) IS
    SELECT t.*
      FROM tbgrv_registro_contrato t
     WHERE t.cdcooper = pr_cdcooper
       AND (t.nrdconta = pr_nrdconta OR pr_nrdconta = 0)
       AND (t.nrctrpro = pr_nrctrpro OR pr_nrctrpro = 0)
       AND t.cdsituacao_contrato = 2 -- registrados
       AND EXISTS (SELECT 1  
                     FROM tbgrv_registro_contrato c 
                    WHERE c.cdcooper = t.cdcooper 
                      AND c.nrdconta = t.nrdconta 
                      AND c.nrctrpro = t.nrctrpro
                      AND c.cdsituacao_contrato = 1 -- solicitado
                      AND c.idseqbem = t.idseqbem
                      AND c.dtregistro_contrato > t.dtregistro_contrato) -- registro menor que solicitação
       AND EXISTS (SELECT 1
                     FROM tbgrv_registro_contrato c 
                    WHERE c.cdcooper = t.cdcooper 
                      AND c.nrdconta = t.nrdconta 
                      AND c.nrctrpro = t.nrctrpro
                      AND c.cdsituacao_contrato = 1 -- solicitado
                      AND c.idseqbem = t.idseqbem
                    GROUP BY c.nrdconta
                   HAVING COUNT(c.nrdconta) = 1); -- 1/1
  rw_tbgrv_registro_contrato cr_tbgrv_registro_contrato%ROWTYPE;
  -- Validacao de diretorio
  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2
                            ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic  crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);
    BEGIN
      -- Primeiro garantimos que o diretorio exista
      IF NOT gene0001.fn_exis_diretorio(pr_nmdireto) THEN
      
        -- Efetuar a criação do mesmo
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' || pr_nmdireto || ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
      
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      
        -- Adicionar permissão total na pasta
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' || pr_nmdireto ||
                                                      ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
      
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;
  END;
BEGIN
  vr_nmdireto := gene0001.fn_param_sistema('CRED', 0, 'ROOT_MICROS');
  -- Primeiro criamos o diretorio da RITM, dentro de um diretorio ja existente
  pc_valida_direto(pr_nmdireto => vr_nmdireto || 'INC0084761_GRV', pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;
  vr_nmdireto       := vr_nmdireto || 'INC0084761_GRV/';
  vr_nmarqbkp       := 'ROLLBACK_INC0084761_GRV_' || to_char(SYSDATE, 'ddmmyyyy_hh24miss') || '.sql';
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          '-- Programa para rollback das informacoes' || chr(13),
                          FALSE);
  FOR rw_crapcop IN cr_crapcop LOOP
    FOR rw_tbgrv_registro_contrato IN cr_tbgrv_registro_contrato(pr_cdcooper => rw_crapcop.cdcooper
                                                                ,pr_nrdconta => 0
                                                                ,pr_nrctrpro => 0) LOOP
      
      UPDATE tbgrv_registro_contrato c 
         SET c.dtregistro_contrato = c.dtregistro_contrato + interval '60' SECOND
            ,c.dtinsori = c.dtinsori + interval '60' SECOND
            ,c.dtrefatu = c.dtrefatu + interval '60' SECOND
       WHERE c.cdcooper = rw_tbgrv_registro_contrato.cdcooper
         AND c.nrdconta = rw_tbgrv_registro_contrato.nrdconta
         AND c.nrctrpro = rw_tbgrv_registro_contrato.nrctrpro
         AND c.idseqbem = rw_tbgrv_registro_contrato.idseqbem
         AND c.cdsituacao_contrato = 2;

      gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                             'UPDATE tbgrv_registro_contrato c ' || chr(13) || '
                                 SET c.dtregistro_contrato = "' || to_char(rw_tbgrv_registro_contrato.dtregistro_contrato, 'DD/MM/RRRR HH24:MI:SS') || '"' || chr(13) || '
                                    ,c.dtinsori = "' || to_char(rw_tbgrv_registro_contrato.dtinsori, 'DD/MM/RRRR HH24:MI:SS') || '"' || chr(13) || '
                                    ,c.dtrefatu = "' || to_char(rw_tbgrv_registro_contrato.dtrefatu, 'DD/MM/RRRR HH24:MI:SS') || '"' || chr(13) || '
                               WHERE c.cdcooper = '  || rw_tbgrv_registro_contrato.cdcooper || '' || chr(13) || '
                                 AND c.nrdconta = '  || rw_tbgrv_registro_contrato.nrdconta || '' || chr(13) || '
                                 AND c.nrctrpro = '  || rw_tbgrv_registro_contrato.nrctrpro || '' || chr(13) || '
                                 AND c.idseqbem = '  || rw_tbgrv_registro_contrato.idseqbem || '' || chr(13) || '
                                 AND c.cdsituacao_contrato = 2;' || chr(13) || chr(13), 
                              FALSE);
      
      
      --dbms_output.put_line('Coop: ' || rpad(rw_crapcop.nmrescop, 20, ' ') || 'Conta: ' || rpad(rw_tbgrv_registro_contrato.nrdconta, 15, ' ') || 'Contrato: ' || rpad(rw_tbgrv_registro_contrato.nrctrpro, 15, ' '));

    END LOOP;
  END LOOP;
  
  -- Adiciona TAG de commit 
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;' || chr(13), FALSE);

  -- Fecha o arquivo          
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);
  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 1,
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
    raise_application_error(-20111, vr_dscritic);
  WHEN OTHERS THEN
    raise_application_error(-20111, SQLERRM);

END;
0
0
