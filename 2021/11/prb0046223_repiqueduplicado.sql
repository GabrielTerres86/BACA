DECLARE
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_rootmicros     VARCHAR2(5000);
  vr_idrepique      integer;
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
  --Buscar os consórcios inadimplentes inativos.
  CURSOR cr_repcnsdup IS
    select tr.idlancto, count(*)
      from TBCNS_REPIQUE tr
     group by tr.idlancto
    having count(*) > 1;

  CURSOR cr_repcnslanc(pr_idlanca TBCNS_REPIQUE.Idlancto%TYPE) IS
    select re.*, rownum linha
      from TBCNS_REPIQUE re
     where re.idlancto in (pr_idlanca);

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

--  vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => 3); --amb ind.
  vr_rootmicros     := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto       := vr_rootmicros|| 'cpd/bacas';
  pc_valida_direto(pr_nmdireto => vr_nmdireto || '/PRB0046223',
                   pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  vr_nmdireto := vr_nmdireto || '/PRB0046223';

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

  vr_nmarqbkp := 'ROLLBACK_PRB0046223' || to_char(sysdate, 'hh24miss') ||
                 '.sql';
  ----------------------------------------------------------------------
  for rw_cons in cr_repcnsdup loop
  
    BEGIN
      select r.idrepiqu
        into vr_idrepique
        from TBCNS_REPIQUE r
       where r.idlancto in (rw_cons.idlancto)
         and (r.dtdebito is not null or r.dtcancel is not null)
         and rownum = 1;
    EXCEPTION
      WHEN OTHERS THEN
        vr_idrepique := 0;
    END;
    if vr_idrepique > 0 then
      for rw_replanc in cr_repcnslanc(rw_cons.idlancto) loop
        if rw_replanc.idrepiqu != vr_idrepique then
          gene0002.pc_escreve_xml(vr_dados_rollback,
                                  vr_texto_rollback,
                                  'insert into TBCNS_REPIQUE values ( ' ||
                                  chr(13) || rw_replanc.idrepiqu || chr(13) || ',' ||
                                  chr(13) || rw_replanc.cdcooper || chr(13) || ',' ||
                                  chr(13) || rw_replanc.nrdconta || chr(13) || ',' ||
                                  chr(13) || rw_replanc.nrdocmto || chr(13) || ',' ||
                                  chr(13) || rw_replanc.cdhistor || chr(13) || ',' ||
--                                  chr(13) || rw_replanc.vllanaut || chr(13) || ',' ||
                                  chr(13) || ' to_char('|| ''''||rw_replanc.vllanaut|| ''''|| ','||'''FM9999999999990D00'','|| '''NLS_NUMERIC_CHARACTERS=,.'''||'),'||
                                  chr(13) || rw_replanc.cdsitlct || chr(13) || ',' ||
                                  chr(13) || ''''|| rw_replanc.dtmvtolt || ''''|| chr(13) || ',' ||
                                  chr(13) || ''''|| rw_replanc.dtmvtopg || ''''|| chr(13) || ',' ||
                                  chr(13) || ''''|| rw_replanc.dtdebito || ''''|| chr(13) || ',' ||
                                  chr(13) || ''''|| rw_replanc.dtcancel || ''''|| chr(13) || ',' ||
                                  chr(13) || ''''|| rw_replanc.cdopecan || ''''|| chr(13) || ',' ||
                                  chr(13) || rw_replanc.idlancto || chr(13) || ',' ||
                                  chr(13) || ''''|| rw_replanc.cdseqtel || ''''|| chr(13) || ',' ||
                                  chr(13) || rw_replanc.nrcrcard || chr(13) || ',' ||
                                  chr(13) || rw_replanc.nrctacns || chr(13) || ',' ||
                                  chr(13) || rw_replanc.cdcritic || chr(13) || 
                                  chr(13) || ')' || ';' || chr(13),
                                  FALSE);
          delete TBCNS_REPIQUE rep
           where rep.idrepiqu = rw_replanc.idrepiqu;
        end if;
      end loop;
    else
      for rw_replanc2 in cr_repcnslanc(rw_cons.idlancto) loop
        if rw_replanc2.linha > 1 then
          gene0002.pc_escreve_xml(vr_dados_rollback,
                                  vr_texto_rollback,
                                  'insert into TBCNS_REPIQUE values ( ' ||
                                  chr(13) || rw_replanc2.idrepiqu || chr(13) || ',' ||
                                  chr(13) || rw_replanc2.cdcooper || chr(13) || ',' ||
                                  chr(13) || rw_replanc2.nrdconta || chr(13) || ',' ||
                                  chr(13) || rw_replanc2.nrdocmto || chr(13) || ',' ||
                                  chr(13) || rw_replanc2.cdhistor || chr(13) || ',' ||
                                  chr(13) || ' to_char('|| ''''||rw_replanc2.vllanaut|| ''''|| ','||'''FM9999999999990D00'','|| '''NLS_NUMERIC_CHARACTERS=,.'''||'),'||
--                                  chr(13) || rw_replanc2.vllanaut || chr(13) || ',' ||
                                  chr(13) || rw_replanc2.cdsitlct || chr(13) || ',' ||
                                  chr(13) || ''''|| rw_replanc2.dtmvtolt || ''''|| chr(13) || ',' ||
                                  chr(13) || ''''|| rw_replanc2.dtmvtopg || ''''|| chr(13) || ',' ||
                                  chr(13) || ''''|| rw_replanc2.dtdebito || ''''|| chr(13) || ',' ||
                                  chr(13) || ''''|| rw_replanc2.dtcancel || ''''|| chr(13) || ',' ||
                                  chr(13) || ''''|| rw_replanc2.cdopecan || ''''|| chr(13) || ',' ||
                                  chr(13) || rw_replanc2.idlancto || chr(13) || ',' ||
                                  chr(13) || ''''|| rw_replanc2.cdseqtel || ''''|| chr(13) || ',' ||
                                  chr(13) || rw_replanc2.nrcrcard || chr(13) || ',' ||
                                  chr(13) || rw_replanc2.nrctacns || chr(13) || ',' ||
                                  chr(13) || rw_replanc2.cdcritic || chr(13) ||
                                  chr(13) || ')' || ';' || chr(13),
                                  FALSE);
          delete TBCNS_REPIQUE rep
           where rep.idrepiqu = rw_replanc2.idrepiqu;
        end if;
      end loop;
    end if;
  end loop;

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
