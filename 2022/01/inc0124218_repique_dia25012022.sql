DECLARE 
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_rootmicros    VARCHAR2(5000);
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_exc_erro  EXCEPTION;
  vr_tem_repique     Integer;
  vr_numctacns   crapcns.nrcotcns%TYPE;
  --Buscar os consórcios inadimplentes inativos.
  CURSOR cr_consor IS
SELECT p.cdcooper, p.nrdconta, p.nrdocmto,  p.cdhistor, p.vllanaut, p.dtmvtopg, p.IDLANCTO, p.CDSEQTEL, p.NRCRCARD
  FROM craplau p
 inner join crapcop c
    on p.cdcooper = c.cdcooper
 inner join (SELECT TO_DATE('01/01/2022', 'DD/MM/RRRR') - 1 + LEVEL dtmvtolt
               FROM dual
             CONNECT BY LEVEL <= TO_DATE('25/01/2022', 'DD/MM/RRRR') -
                        TO_DATE('01/01/2022', 'DD/MM/RRRR') + 1) aux
    on p.dtmvtopg = aux.dtmvtolt
 WHERE c.flgativo = 1
   AND p.cdhistor IN (1230, 1231, 1232, 1233, 1234, 2027)
   AND p.dtdebito IS NULL
   AND p.insitlau = 1
   AND NOT EXISTS
 (SELECT 1 FROM tbcns_repique r WHERE r.idlancto = p.idlancto);


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

--  vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => 3);
  vr_rootmicros     := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto       := vr_rootmicros|| 'cpd/bacas';
  pc_valida_direto(pr_nmdireto => vr_nmdireto || '/INC0124218',
                   pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  vr_nmdireto := vr_nmdireto || '/INC0124218';

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

  vr_nmarqbkp := 'ROLLBACK_INC0124218' || to_char(sysdate, 'hh24miss') ||
                 '.sql';
  ----------------------------------------------------------------------
  for rw_cons in cr_consor loop
      select count(*) into vr_tem_repique from TBCNS_REPIQUE rep where rep.idlancto = rw_cons.idlancto;
      if vr_tem_repique = 0 then
          select cns.nrcotcns into vr_numctacns from crapcns cns 
          where cns.nrdconta = rw_cons.nrdconta and cns.cdcooper = rw_cons.cdcooper and rownum =1;

          INSERT INTO TBCNS_REPIQUE
                   (-- IDREPIQU,  Auto inc
                    CDCOOPER,
                    NRDCONTA,
                    NRDOCMTO,
                    CDHISTOR,
                    VLLANAUT,
                    CDSITLCT,
                    DTMVTOLT,
                    DTMVTOPG,
                    DTDEBITO,
                    DTCANCEL,
                    CDOPECAN,
                    IDLANCTO,
                    CDSEQTEL,
                    NRCRCARD,
                    NRCTACNS,
                    CDCRITIC )
                  VALUES
                  ( 
                    rw_cons.cdcooper,
                    rw_cons.nrdconta,
                    rw_cons.nrdocmto,
                    rw_cons.cdhistor,
                    rw_cons.vllanaut,
                    1,---Situação (1-Pendente, 2-Efetivado, 3- Cancelado)   
                    rw_cons.dtmvtopg,
                    rw_cons.dtmvtopg,
                    null,
                    null,
                    null,
                    rw_cons.IDLANCTO,  
                    rw_cons.CDSEQTEL,
                    rw_cons.NRCRCARD,
                    vr_numctacns, 
                    '717'                 
                  );

      ---------------------------------------------------------------------
      gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                              'delete cecred.TBCNS_REPIQUE ' ||chr(13)||
                              ' WHERE IDLANCTO = ' || rw_cons.Idlancto || chr(13) || ';' || chr(13)
                              ,
                              FALSE);
      commit;
      end if;

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
