PL/SQL Developer Test script 3.0
124
DECLARE
  --
  vr_nrregistro NUMBER := 0;

  vr_dsmensagem     VARCHAR2(500);
  vr_nmarq_rollback VARCHAR2(100);
  vr_nmarq_log      VARCHAR2(100);
  vr_des_erro       VARCHAR2(1000);
  vr_dscritic       VARCHAR2(1000);
  vr_handle         utl_file.file_type;
  vr_handle_log     utl_file.file_type;
  vr_exc_erro EXCEPTION;

  vr_dsdireto VARCHAR2(300);

BEGIN
  BEGIN
  
    -- Diretorio
    vr_dsdireto := GENE0001.fn_param_sistema('CRED', 3, 'ROOT_MICROS') || 'cecred/daniel/';
  
    vr_nmarq_rollback := vr_dsdireto || 'INC0082876_ROLLBACK.sql';
    vr_nmarq_log      := vr_dsdireto || 'INC0082876.log';
  
    -- Abrir o arquivo de rollback
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback,
                             pr_tipabert => 'W',
                             pr_utlfileh => vr_handle,
                             pr_des_erro => vr_des_erro);
    IF vr_des_erro IS NOT NULL THEN
      vr_dsmensagem := 'Erro ao abrir arquivo de rollback: ' || vr_des_erro;
      RAISE vr_exc_erro;
    END IF;
  
    -- Abrir o arquivo de LOG
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log,
                             pr_tipabert => 'W',
                             pr_utlfileh => vr_handle_log,
                             pr_des_erro => vr_des_erro);
    IF vr_des_erro IS NOT NULL THEN
      vr_dsmensagem := 'Erro ao abrir arquivo de LOG: ' || vr_des_erro;
      RAISE vr_exc_erro;
    END IF;
  
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                   pr_des_text => 'Coop;Conta;Bordero;Documento;Titulo;Mensagem');
  
    FOR rw_craptdb IN (SELECT bdt.cdcooper
                             ,bdt.nrdconta
                             ,bdt.nrborder
                             ,tdb.nrdocmto
                             ,tdb.nrtitulo
                             ,tdb.vliofcpl
                             ,tdb.vlpagiof
                             ,tdb.rowid
                         FROM craptdb tdb
                             ,crapbdt bdt
                             ,crapcop cop
                        WHERE tdb.vliofcpl = 0
                          AND tdb.vlpagiof > 0
                             
                          AND (tdb.vlsldtit + (tdb.vlmtatit - tdb.vlpagmta) +
                              (tdb.vlmratit - tdb.vlpagmra) + (tdb.vliofcpl - tdb.vlpagiof)) < 0
                          AND tdb.cdcooper = bdt.cdcooper
                          AND tdb.nrdconta = bdt.nrdconta
                          AND tdb.nrborder = bdt.nrborder
                          AND bdt.cdcooper = cop.cdcooper
                          AND bdt.flverbor = 1
                          AND bdt.dtmvtolt >= '01/01/2019'
                          AND bdt.dtlibbdt IS NOT NULL
                          AND cop.flgativo = 1) LOOP
    
      vr_dsmensagem := NULL;
      vr_nrregistro := vr_nrregistro + 1;
    
      BEGIN
      
        UPDATE craptdb tdb
           SET tdb.vliofcpl = rw_craptdb.vlpagiof
         WHERE tdb.rowid = rw_craptdb.rowid;
      
      EXCEPTION
        WHEN OTHERS THEN
          vr_dsmensagem := 'Erro na atualizacao:' || SQLERRM;
      END;
    
      IF vr_dsmensagem IS NULL THEN
      
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                       pr_des_text => 'UPDATE craptdb tdb' ||
                                                      ' SET tdb.vliofcpl = 0' ||
                                                      ' WHERE tdb.rowid = ' || rw_craptdb.rowid || ';');
      
      ELSE
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                       pr_des_text => rw_craptdb.cdcooper || ';' ||
                                                      rw_craptdb.nrdconta || ';' ||
                                                      rw_craptdb.nrborder || ';' ||
                                                      rw_craptdb.nrdocmto || ';' ||
                                                      rw_craptdb.nrtitulo || ';' || vr_dsmensagem);
      END IF;
    
    END LOOP;
  
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                   pr_des_text => 'Total de registros tratados no processo: ' ||
                                                  vr_nrregistro);
  
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle, pr_des_text => 'COMMIT;');
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                     pr_des_text => 'Erro: ' || vr_dsmensagem || ' SQLERRM: ' ||
                                                    SQLERRM);
    
      ROLLBACK;
  END;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
END;
0
0
