declare
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_qtd            INTEGER;
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
  --Buscar os consórcios que possui transferências.
  CURSOR cr_consransf IS
    select s.nrcotcns, s.nrdgrupo, s.nrctrato, count(*)
      from crapcns s
     group by s.nrcotcns, s.nrdgrupo, s.nrctrato
    having count(*) > 1;

  --buscar as contas de consórcio que ocorreu as trasnferencias por ordem decrescente.
  CURSOR cr_consorcio(pr_nrCota     crapcns.nrcotcns%TYPE,
                      pr_nrGrupo    crapcns.nrdgrupo%TYPE,
                      pr_nrContrato crapcns.nrctrato%TYPE) IS
    select rownum ordem, x.*
      from (select a.*
              from crapcns a
             where a.nrcotcns = pr_nrCota
               and a.nrdgrupo = pr_nrGrupo
               and a.nrctrato = pr_nrContrato
             order by a.dtinclus desc) x;

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
        -- Efetuar a criação do mesmo
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
        -- Adicionar permissão total na pasta
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
  pc_valida_direto(pr_nmdireto => vr_nmdireto || '/INC0076030',
                   pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  vr_nmdireto := vr_nmdireto || '/INC0076030';

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

  vr_nmarqbkp := 'ROLLBACK_INC0076030' || to_char(sysdate, 'hh24miss') ||
                 '.sql';
  ----------------------------------------------------------------------
  for rw_consransf in cr_consransf loop
    for rw_consorcio in cr_consorcio(rw_consransf.nrcotcns,
                                     rw_consransf.nrdgrupo,
                                     rw_consransf.nrctrato) loop
      if rw_consorcio.ordem = 1 then
        select count(*)
          into vr_qtd
          from tbconsor_situacao k
         where k.cdclassificacao in (0, 2, 5)
           and k.cdsituacao = rw_consorcio.cdsitcns;
           
        if (vr_qtd = 0) THEN
          if rw_consorcio.qtparpag = rw_consorcio.qtparcns then
            --quitado e cancelado pois só tem esses 2 status
            update crapcns cns
               set cns.flgativo = 0, cns.cdsitcns = 'QUI'
             where cns.CDCOOPER = rw_consorcio.CDCOOPER
               and cns.NRDGRUPO = rw_consorcio.NRDGRUPO
               and cns.NRCTACNS = rw_consorcio.NRCTACNS
               and cns.NRCOTCNS = rw_consorcio.NRCOTCNS
               and cns.NRCTRATO = rw_consorcio.NRCTRATO;
          else
            update crapcns cns
               set cns.flgativo = 1, cns.cdsitcns = 'NOR'
             where cns.CDCOOPER = rw_consorcio.CDCOOPER
               and cns.NRDGRUPO = rw_consorcio.NRDGRUPO
               and cns.NRCTACNS = rw_consorcio.NRCTACNS
               and cns.NRCOTCNS = rw_consorcio.NRCOTCNS
               and cns.NRCTRATO = rw_consorcio.NRCTRATO;
          
          end if;
        end if;
      else
        update crapcns cns
           set cns.flgativo = 0, cns.cdsitcns = 'TRA'
         where cns.CDCOOPER = rw_consorcio.CDCOOPER
           and cns.NRDGRUPO = rw_consorcio.NRDGRUPO
           and cns.NRCTACNS = rw_consorcio.NRCTACNS
           and cns.NRCOTCNS = rw_consorcio.NRCOTCNS
           and cns.NRCTRATO = rw_consorcio.NRCTRATO;
      end if;
      ---------------------------------------------------------------------
      gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                              'UPDATE crapcns      ' || chr(13) ||
                              '   SET flgativo = ' || rw_consorcio.flgativo ||
                              chr(13) || ',   cdsitcns    = ' || '''' ||
                              rw_consorcio.cdsitcns || '''' || chr(13) ||
                              ' WHERE CDCOOPER = ' || rw_consorcio.cdcooper ||
                              chr(13) || '   AND NRDGRUPO = ' ||
                              rw_consorcio.NRDGRUPO || chr(13) ||
                              '   AND NRCTACNS = ' || rw_consorcio.NRCTACNS ||
                              chr(13) || '   AND NRCOTCNS = ' ||
                              rw_consorcio.NRCOTCNS || chr(13) ||
                              '   AND NRCTRATO = ' || rw_consorcio.NRCTRATO || ';' ||
                              chr(13),
                              FALSE);
    
    end loop;
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
                                      pr_flg_impri => 'N' --> Chamar a impressão (Imprim.p)
                                     ,
                                      pr_flg_gerar => 'S' --> Gerar o arquivo na hora
                                     ,
                                      pr_flgremarq => 'N' --> remover arquivo apos geracao
                                     ,
                                      pr_nrcopias  => 1 --> Número de cópias para impressão
                                     ,
                                      pr_des_erro  => vr_dscritic); --> Retorno de Erro

  -- Liberando a memória alocada pro CLOB    
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);

  -- Efetuamos a transação  
  COMMIT;
END;
/
