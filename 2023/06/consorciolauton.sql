begin
  DECLARE
    vr_dados_rollback CLOB;
    vr_texto_rollback VARCHAR2(32600);
    vr_nmarqbkp       VARCHAR2(100);
    vr_nmdireto       VARCHAR2(4000);
    vr_rootmicros     VARCHAR2(5000);
    vr_dscritic       crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;
    vr_cdcritic     NUMBER;
    
  
    CURSOR cr_conslautom IS
           SELECT l.dtdebito,
            l.insitlau,
            GENE0005.fn_calc_qtd_dias_uteis(a.cdcooper, a.dtmvtopg, d.dtmvtolt) diasrepique,
            d.dtmvtolt
            ,a.nrdconta
            ,a.cdcooper
            ,l.idlancto
            ,decode(l.nrcrcard,0,l.nrdocmto,l.nrcrcard) nrcrcard
            ,l.vllanaut
            ,l.cdagenci
            , a.nrctacns
            ,l.cdseqtel
            , l.cdhistor
            ,b.cdsegmento tpconsor
            ,b.nmsegmento tpconstr
            ,lpad(A.cdcooper, 5, '0') || '-' || lpad(A.nrdconta, 10, '0') || '-' ||
             lpad(a.IDLANCTO, 8, '0') || '-' || b.cdsegmento || '-' || A.rowid AS chave
            ,A.ROWID
        FROM cecred.TBCNS_REPIQUE A
        LEFT JOIN cecred.tbconsor_segmento b ON b.cdhistordebito = a.cdhistor
        inner join cecred.craplau l on l.cdcooper= a.cdcooper and l.nrdconta = a.nrdconta and a.vllanaut = l.vllanaut
        inner join cecred.crapdat d on d.cdcooper = a.cdcooper
       WHERE a.cdsitlct = 1 
         and a.cdhistor in (1230, 1231, 1232, 1233, 1234, 2027)
         and l.dtdebito is null
         and l.insitlau = 1
         and (cecred.GENE0005.fn_calc_qtd_dias_uteis(a.cdcooper, a.dtmvtopg, d.dtmvtolt))>10;
  
    PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2,
                               pr_dscritic OUT crapcri.dscritic%TYPE) IS
    BEGIN
      DECLARE
        vr_dscritic  crapcri.dscritic%TYPE;
        vr_typ_saida VARCHAR2(3);
        vr_des_saida VARCHAR2(1000);
      BEGIN
        IF NOT cecred.gene0001.fn_exis_diretorio(pr_nmdireto) THEN
          cecred.gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                        pr_nmdireto ||
                                                        ' 1> /dev/null',
                                      pr_typ_saida   => vr_typ_saida,
                                      pr_des_saida   => vr_des_saida);
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                           vr_des_saida;
            RAISE vr_exc_erro;
          END IF;
          cecred.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
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
    vr_rootmicros := cecred.gene0001.fn_param_sistema('CRED', 3, 'ROOT_MICROS');
    vr_nmdireto   := vr_rootmicros || 'cpd/bacas';
    pc_valida_direto(pr_nmdireto => vr_nmdireto || '/INC0275135',
                     pr_dscritic => vr_dscritic);
  
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  
    vr_nmdireto := vr_nmdireto || '/INC0275135';
  
    vr_dados_rollback := NULL;
    dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);
  
    cecred.gene0002.pc_escreve_xml(vr_dados_rollback,
                            vr_texto_rollback,
                            '-- Programa para rollback das informacoes' ||
                            chr(13),
                            FALSE);
    cecred.gene0002.pc_escreve_xml(vr_dados_rollback,
                            vr_texto_rollback,
                            'BEGIN' || chr(13),
                            FALSE);
  
    vr_nmarqbkp := 'ROLLBACK_INC0275135' || to_char(sysdate, 'hh24miss') ||
                   '.sql';
    for rw_cons in cr_conslautom loop
        cecred.cnso0001.pc_gera_crapndb(rw_cons.cdcooper,
                                 rw_cons.dtmvtolt,
                                 rw_cons.nrdconta,
                                 'J5',
                                 rw_cons.nrcrcard,
                                 rw_cons.nrctacns,
                                 rw_cons.vllanaut,
                                 rw_cons.cdagenci,
                                 rw_cons.cdseqtel,
                                 rw_cons.cdhistor,
                                 pr_cdcritic => vr_cdcritic,
                                 pr_dscritic => vr_dscritic);
                                 
      cecred.gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                              ' delete cedred.crapndb      ' || chr(13) ||
                              '   WHERE DTMVTOLT = ' || rw_cons.dtmvtolt ||chr(13) ||
                              '   and NRDCONTA =  ' || rw_cons.nrdconta ||chr(13) ||
                              '   and cdhistor =  ' || rw_cons.cdhistor ||chr(13) ||
                              '   and FLGPROCE = 0  ' ||chr(13) ||
                              '   and CDCOOPER =    '    || rw_cons.CDCOOPER ||chr(13) ||                              
                              '   and dstexarq = fff ' ||chr(13) || ';' || chr(13),
                              FALSE);                           

      UPDATE cecred.TBCNS_REPIQUE 
         SET cdsitlct = 3, 
             dtcancel  = rw_cons.dtmvtolt, 
             cdopecan = '1' 
       WHERE ROWID = rw_cons.ROWID;

      cecred.gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                              'UPDATE cedred.TBCNS_REPIQUE      ' || chr(13) ||
                              '   SET cdsitlct =  1 ' || chr(13) ||
                              ' , dtcancel = null ' || chr(13) ||
                              ' , cdopecan = null ' || chr(13) ||
                              ' WHERE idlancto = ' || rw_cons.idlancto ||
                              chr(13) || ';' || chr(13),
                              FALSE);
       
                   
      update cecred.craplau aa
         set aa.insitlau = 3,
             aa.dtdebito = rw_cons.dtmvtolt
       where aa.idlancto = rw_cons.idlancto;
    
      cecred.gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                              'UPDATE cedred.craplau      ' || chr(13) ||
                              '   SET insitlau =   ' || rw_cons.insitlau ||
                              chr(13) || ' , dtdebito = null ' || chr(13) ||
                              ' WHERE idlancto = ' || rw_cons.idlancto ||
                              chr(13) || ';' || chr(13),
                              FALSE);
                              
    
    end loop;
    cecred.gene0002.pc_escreve_xml(vr_dados_rollback,
                            vr_texto_rollback,
                            'COMMIT;' || chr(13),
                            FALSE);
    cecred.gene0002.pc_escreve_xml(vr_dados_rollback,
                            vr_texto_rollback,
                            'END;' || chr(13),
                            FALSE);
  
    cecred.gene0002.pc_escreve_xml(vr_dados_rollback,
                            vr_texto_rollback,
                            chr(13),
                            TRUE);
  
    cecred.GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3,
                                        pr_cdprogra  => 'ATENDA',
                                        pr_dtmvtolt  => trunc(SYSDATE),
                                        pr_dsxml     => vr_dados_rollback,
                                        pr_dsarqsaid => vr_nmdireto || '/' ||
                                                        vr_nmarqbkp,
                                        pr_flg_impri => 'N',
                                        pr_flg_gerar => 'S',
                                        pr_flgremarq => 'N',
                                        pr_nrcopias  => 1,
                                        pr_des_erro  => vr_dscritic);
  
    dbms_lob.close(vr_dados_rollback);
    dbms_lob.freetemporary(vr_dados_rollback);
    COMMIT;
  END;
end;
