declare
  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_rootmicros    VARCHAR2(5000);
  vr_qtd            INTEGER;
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;

  CURSOR cr_segprestnaocont IS
    select   c.CDCOOPER
       , c.NRDCONTA
       , c.TPSEGURO
       , c.NRCTRSEG
       , d.dtmvtolt
       , c.dtfimvig
       , p.NRPROPOSTA
       , p.TPCUSTEI
       , c.dtcancel
       , c.cdsitseg
       , c.cdopeexc
       , c.cdageexc
       , c.dtinsexc
       , c.cdopecnl
    from cecred.tbseg_prestamista p
    inner join cecred.crapseg c on (c.NRDCONTA= p.NRDCONTA and c.CDCOOPER = p.CDCOOPER and c.nrctrseg = p.nrctrseg)
    inner join cecred.crapdat d on p.cdcooper   = d.cdcooper
    WHERE p.TPCUSTEI= 0
    and c.cdsitseg !=5
    and p.nrproposta in(770628751870	,
770629454730	,
770629456430	,
770628759456	,
770629024514	,
770629371591	,
770629451188	,
770629031812	,
770629373730	,
770629373365	,
770628749558	,
770629336966	,
770629191038	,
770629019898	,
770629034447	,
770628859469	,
770629453920	,
770629022627	,
770629190759	,
770629081127	,
770628751056	,
770629454217	,
770629034234	,
770629079220	,
770629146032	,
770628858349	,
770629372237	,
770629088962	,
770628858365	,
770629214267	,
770628858616	,
770629456406	,
770629193057	,
770629088105	,
770629335021	,
770629022910	,
770629456082	
);

  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2,
                             pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic  crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);
    BEGIN
      IF NOT gene0001.fn_exis_diretorio(pr_nmdireto) THEN
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                      pr_nmdireto ||
                                                      ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                      pr_nmdireto ||
                                                      ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
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
  vr_rootmicros     := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto       := vr_rootmicros|| 'cpd/bacas';
  pc_valida_direto(pr_nmdireto => vr_nmdireto || '/INC0231613',
                   pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  vr_nmdireto := vr_nmdireto || '/INC0231613';

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

  vr_nmarqbkp := 'ROLLBACK_INC0231613_CONT' || to_char(sysdate, 'hh24miss') ||
                 '.sql';
    for rw_segprestnaocont in cr_segprestnaocont loop
          UPDATE crapseg p
             SET p.dtfimvig = rw_segprestnaocont.dtfimvig,
                 p.dtcancel = rw_segprestnaocont.dtmvtolt,
                 p.cdsitseg = 5,
                 p.cdopeexc = 1,
                 p.cdageexc = 1,
                 p.dtinsexc = rw_segprestnaocont.dtmvtolt,
                 p.cdopecnl = 1
           WHERE p.cdcooper = rw_segprestnaocont.cdcooper
             AND p.nrdconta = rw_segprestnaocont.nrdconta
             AND p.nrctrseg = rw_segprestnaocont.nrctrseg
             AND p.tpseguro = rw_segprestnaocont.tpseguro;
      gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                              'UPDATE crapseg    ' || chr(13) ||
                              '   SET dtfimvig            = ' || '''' ||rw_segprestnaocont.dtfimvig  || '''' ||
                              chr(13) || ',   dtcancel    = ' || '''' ||rw_segprestnaocont.dtcancel || '''' ||
                              chr(13) || ',   cdsitseg    = ' || '''' ||rw_segprestnaocont.cdsitseg || '''' ||
                              chr(13) || ',   cdopeexc    = ' || '''' ||rw_segprestnaocont.cdopeexc || '''' ||
                              chr(13) || ',   cdageexc    = ' || '''' ||rw_segprestnaocont.cdageexc || '''' ||
                              chr(13) || ',   dtinsexc    = ' || '''' ||rw_segprestnaocont.dtinsexc || '''' ||
                              chr(13) || ',   cdopecnl    = ' || '''' ||rw_segprestnaocont.cdopecnl || '''' ||

                              chr(13) ||' WHERE CDCOOPER =  ' || rw_segprestnaocont.cdcooper ||
                              chr(13) || '   AND nrdconta = ' ||rw_segprestnaocont.nrdconta ||
                              chr(13) || '   AND nrctrseg = ' || rw_segprestnaocont.nrctrseg ||
                              chr(13) || '   AND tpseguro = ' ||rw_segprestnaocont.tpseguro || ';' ||
                              chr(13),
                              FALSE);

    end loop;
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          'COMMIT;' || chr(13),
                          FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          'END;' || chr(13),
                          FALSE);

  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          chr(13),
                          TRUE);

  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3
                                     ,
                                      pr_cdprogra  => 'ATENDA'
                                     ,
                                      pr_dtmvtolt  => trunc(SYSDATE)
                                     ,
                                      pr_dsxml     => vr_dados_rollback
                                     ,
                                      pr_dsarqsaid => vr_nmdireto || '/' ||
                                                      vr_nmarqbkp
                                     ,
                                      pr_flg_impri => 'N'
                                     ,
                                      pr_flg_gerar => 'S'
                                     ,
                                      pr_flgremarq => 'N'
                                     ,
                                      pr_nrcopias  => 1
                                     ,
                                      pr_des_erro  => vr_dscritic);


  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);
  COMMIT;
END ;
