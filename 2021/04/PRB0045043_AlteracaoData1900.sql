DECLARE
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_rootmicros    VARCHAR2(5000);
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
  --Buscar os cons�rcios inadimplentes inativos.
  CURSOR cr_consInad IS
    select *
      from crapcns b
     where b.dtfimcns = '01/01/1900';

  -- Validacao de diretorio
  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2,
                             pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic  crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);
    BEGIN
      -- Primeiro garantimos que o diretorio exista
      IF NOT gene0001.fn_exis_diretorio(pr_nmdireto) THEN
        -- Efetuar a cria��o do mesmo
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                      pr_nmdireto ||
                                                      ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
        -- Adicionar permiss�o total na pasta
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                      pr_nmdireto ||
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

  vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => 3);
  --vr_rootmicros     := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS'); --prd
  --vr_nmdireto       := vr_rootmicros|| 'cpd/bacas';  --prd
  pc_valida_direto(pr_nmdireto => vr_nmdireto || '/INC0084123',
                   pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  vr_nmdireto := vr_nmdireto || '/INC0084123';

  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);

  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          '-- Programa para rollback das informacoes' ||
                          chr(13),
                          FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          'BEGIN' || chr(13),
                          FALSE);

  vr_nmarqbkp := 'ROLLBACK_INC0084123' || to_char(sysdate, 'hh24miss') ||
                 '.sql';
  ----------------------------------------------------------------------
  for rw_cons in cr_consInad loop
              update crapcns cns
               set cns.dtfimcns = add_months(cns.dtinicns,cns.qtparcns)
             where cns.CDCOOPER = rw_cons.CDCOOPER
               and cns.NRDGRUPO = rw_cons.NRDGRUPO
               and cns.NRCTACNS = rw_cons.NRCTACNS
               and cns.NRCOTCNS = rw_cons.NRCOTCNS
               and cns.NRCTRATO = rw_cons.NRCTRATO
               and cns.cdsitcns = rw_cons.cdsitcns;

      ---------------------------------------------------------------------
      gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                              'UPDATE crapcns      ' || chr(13) ||
                              '   SET dtfimcns =   ' || ''''|| rw_cons.dtfimcns ||'''' ||chr(13) ||
                              ' WHERE CDCOOPER = ' || rw_cons.cdcooper || chr(13) ||
                              '   AND NRDGRUPO = ' || rw_cons.NRDGRUPO || chr(13) ||
                              '   AND NRCTACNS = ' || rw_cons.NRCTACNS || chr(13) ||
                              '   AND NRCOTCNS = ' || rw_cons.NRCOTCNS || chr(13) ||
                              '   AND NRCTRATO = ' || rw_cons.NRCTRATO || chr(13) ||
                              '   AND cdsitcns = ' || ''''||rw_cons.cdsitcns||'''' || ';' || chr(13),
                              FALSE);

  end loop;
  ---------------------------------------------------------------
  -- Adiciona TAG de commit
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          'COMMIT;' || chr(13),
                          FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          'END;' || chr(13),
                          FALSE);

  -- Fecha o arquivo
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          chr(13),
                          TRUE);

  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3 --> Cooperativa conectada
                                     ,
                                      pr_cdprogra  => 'ATENDA' --> Programa chamador - utilizamos apenas um existente
                                     ,
                                      pr_dtmvtolt  => trunc(SYSDATE) --> Data do movimento atual
                                     ,
                                      pr_dsxml     => vr_dados_rollback --> Arquivo XML de dados
                                     ,
                                      pr_dsarqsaid => vr_nmdireto || '/' ||
                                                      vr_nmarqbkp --> Path/Nome do arquivo PDF gerado
                                     ,
                                      pr_flg_impri => 'N' --> Chamar a impress�o (Imprim.p)
                                     ,
                                      pr_flg_gerar => 'S' --> Gerar o arquivo na hora
                                     ,
                                      pr_flgremarq => 'N' --> remover arquivo apos geracao
                                     ,
                                      pr_nrcopias  => 1 --> N�mero de c�pias para impress�o
                                     ,
                                      pr_des_erro  => vr_dscritic); --> Retorno de Erro

  -- Liberando a mem�ria alocada pro CLOB
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);

  -- Efetuamos a transa��o
  COMMIT;
END;
