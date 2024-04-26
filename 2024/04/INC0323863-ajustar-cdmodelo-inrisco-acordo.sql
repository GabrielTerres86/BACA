DECLARE
  vr_cdcritic    cecred.crapcri.cdcritic%TYPE;
  vr_dscritic    cecred.crapcri.dscritic%TYPE;
  vr_diretorio   VARCHAR2(200);
  vr_rollback    VARCHAR2(4000);
  vr_log         VARCHAR2(4000);
  vr_arqrollback utl_file.file_type;
  vr_arqlog      utl_file.file_type;
  vr_exec_erro   EXCEPTION;

  CURSOR cr_tbrecup_acordo_contrato IS
    SELECT a.nracordo
          ,a.nrgrupo
          ,a.cdorigem
          ,a.nrctremp
          ,a.cdmodelo
          ,a.inrisco_acordo
          ,CASE a.nracordo
             WHEN 584053 THEN
             9
             WHEN 650902 THEN
             7
           END inrisco_correto
      FROM cecred.tbrecup_acordo_contrato a
     WHERE (a.nracordo, a.nrctremp) IN ((584053, 14668904), (650902, 21612));

  TYPE typ_tbrecup_acordo_contrato IS TABLE OF cr_tbrecup_acordo_contrato%ROWTYPE INDEX BY PLS_INTEGER;

  vr_tbrecup_acordo_contrato typ_tbrecup_acordo_contrato;

  PROCEDURE fecharArquivos IS
  BEGIN
    IF utl_file.IS_OPEN(vr_arqrollback) THEN
      sistema.fecharArquivo(pr_utlfileh => vr_arqrollback);
    END IF;
  
    IF utl_file.IS_OPEN(vr_arqlog) THEN
      sistema.fecharArquivo(pr_utlfileh => vr_arqlog);
    END IF;
  END;
BEGIN
  vr_diretorio := sistema.obterParametroSistema(pr_nmsistem => 'CRED'
                                               ,pr_cdacesso => 'ROOT_MICROS') || 'cpd/bacas/INC0323863';

  sistema.abrirArquivo(pr_nmdireto => vr_diretorio,
                       pr_nmarquiv => 'rollback.sql',
                       pr_tipabert => 'W',
                       pr_utlfileh => vr_arqrollback,
                       pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exec_erro;
  END IF;

  sistema.abrirArquivo(pr_nmdireto => vr_diretorio,
                       pr_nmarquiv => 'log.txt',
                       pr_tipabert => 'W',
                       pr_utlfileh => vr_arqlog,
                       pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exec_erro;
  END IF;

  sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                             ,pr_des_text => 'BEGIN');

  OPEN cr_tbrecup_acordo_contrato;
  LOOP
    FETCH cr_tbrecup_acordo_contrato BULK COLLECT
      INTO vr_tbrecup_acordo_contrato LIMIT 5000;
    EXIT WHEN vr_tbrecup_acordo_contrato.count = 0;
  
    FOR vr_indice IN vr_tbrecup_acordo_contrato.first .. vr_tbrecup_acordo_contrato.last LOOP
      vr_rollback := 'UPDATE cecred.tbrecup_acordo_contrato' ||
                       ' SET cdmodelo       = ' || vr_tbrecup_acordo_contrato(vr_indice).cdmodelo       ||
                           ',inrisco_acordo = ' || vr_tbrecup_acordo_contrato(vr_indice).inrisco_acordo ||
                     ' WHERE nracordo = ' || vr_tbrecup_acordo_contrato(vr_indice).nracordo ||
                       ' AND nrgrupo  = ' || vr_tbrecup_acordo_contrato(vr_indice).nrgrupo  ||
                       ' AND cdorigem = ' || vr_tbrecup_acordo_contrato(vr_indice).cdorigem ||
                       ' AND nrctremp = ' || vr_tbrecup_acordo_contrato(vr_indice).nrctremp || ';';
      sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                                 ,pr_des_text => vr_rollback);
    END LOOP;
  
    BEGIN
      FORALL vr_indice IN INDICES OF vr_tbrecup_acordo_contrato SAVE EXCEPTIONS
        UPDATE cecred.tbrecup_acordo_contrato
           SET cdmodelo       = 2
              ,inrisco_acordo = vr_tbrecup_acordo_contrato(vr_indice).inrisco_correto
         WHERE nracordo = vr_tbrecup_acordo_contrato(vr_indice).nracordo
           AND nrgrupo  = vr_tbrecup_acordo_contrato(vr_indice).nrgrupo
           AND cdorigem = vr_tbrecup_acordo_contrato(vr_indice).cdorigem
           AND nrctremp = vr_tbrecup_acordo_contrato(vr_indice).nrctremp;
    EXCEPTION
      WHEN OTHERS THEN
        FOR vr_indice IN 1 .. SQL%bulk_exceptions.count LOOP
          vr_log := 'nracordo: '  || vr_tbrecup_acordo_contrato(SQL%BULK_EXCEPTIONS(vr_indice).error_index).nracordo ||
                    ' nrgrupo: '  || vr_tbrecup_acordo_contrato(SQL%BULK_EXCEPTIONS(vr_indice).error_index).nrgrupo  ||
                    ' cdorigem: ' || vr_tbrecup_acordo_contrato(SQL%BULK_EXCEPTIONS(vr_indice).error_index).cdorigem ||
                    ' nrctremp: ' || vr_tbrecup_acordo_contrato(SQL%BULK_EXCEPTIONS(vr_indice).error_index).nrctremp ||
                    ' Erro: ' || SQLERRM;
          sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqlog
                                     ,pr_des_text => vr_log);
        END LOOP;
    END;  
    COMMIT;
  END LOOP;
  CLOSE cr_tbrecup_acordo_contrato;

  sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                             ,pr_des_text => 'COMMIT;');
  sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                             ,pr_des_text => 'END;');
  fecharArquivos;
EXCEPTION
  WHEN vr_exec_erro THEN
    fecharArquivos;
    raise_application_error(-20500, vr_dscritic);
  WHEN OTHERS THEN
    fecharArquivos;
    raise_application_error(-20500, SQLERRM);
END;
