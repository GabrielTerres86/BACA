DECLARE
  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_rootmicros    VARCHAR2(5000);
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
  
  CURSOR cr_conslautom IS
   select a.INSITLAU,
       a.DTDEBITO,
       a.cdcooper,
       a.nrdconta,
       a.idlancto
  from craplau a
 where a.CDHISTOR = 1234
   and a.DTDEBITO is null
   and a.INSITLAU = 1
   and a.DTMVTOPG < trunc(sysdate)
   and not exists (select 1
          from TBCNS_REPIQUE b
         where b.Cdsitlct in (1, 3)
           and b.idlancto = a.idlancto);


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
  pc_valida_direto(pr_nmdireto => vr_nmdireto || '/INC0275135',
                   pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  vr_nmdireto := vr_nmdireto || '/INC0275135';

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

  vr_nmarqbkp := 'ROLLBACK_INC0275135' || to_char(sysdate, 'hh24miss') ||
                 '.sql';
  for rw_cons in cr_conslautom loop
      update craplau aa 
         set aa.insitlau = 3, 
             aa.dtdebito= (select a.dtmvtolt from cecred.crapdat a where a.cdcooper = rw_cons.CDCOOPER)  
      where aa.idlancto = rw_cons.idlancto;    
      
      gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,
                              'UPDATE cedred.craplau      ' || chr(13) ||
                              '   SET insitlau =   ' || rw_cons.insitlau    ||chr(13) || 
                              ' , dtdebito = null ' || chr(13) ||                            
                              ' WHERE idlancto = ' || rw_cons.idlancto || chr(13) || ';' || chr(13),
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
END;
