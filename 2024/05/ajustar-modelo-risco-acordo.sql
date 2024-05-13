DECLARE
  vr_indice      NUMBER := 0;
  vr_dscritic    cecred.crapcri.dscritic%TYPE;
  vr_diretorio   VARCHAR2(200);
  vr_log         VARCHAR2(4000);
  vr_dslinha     VARCHAR2(200);
  vr_arqlinha    cecred.gene0002.typ_split;
  vr_arqcontrato utl_file.file_type;
  vr_arqlog      utl_file.file_type;
  vr_exec_erro   EXCEPTION;

  TYPE typ_tab_tbrecup_acordo_contrato IS TABLE OF cecred.tbrecup_acordo_contrato%ROWTYPE INDEX BY PLS_INTEGER;

  vr_tbrecup_acordo_contrato typ_tab_tbrecup_acordo_contrato;

  PROCEDURE fecharArquivos IS
  BEGIN
    IF utl_file.IS_OPEN(vr_arqcontrato) THEN
      sistema.fecharArquivo(pr_utlfileh => vr_arqcontrato);
    END IF;
  
    IF utl_file.IS_OPEN(vr_arqlog) THEN
      sistema.fecharArquivo(pr_utlfileh => vr_arqlog);
    END IF;
  END;
BEGIN
  vr_diretorio := sistema.obterParametroSistema(pr_nmsistem => 'CRED'
                                               ,pr_cdacesso => 'ROOT_MICROS') || 'cpd/bacas/INC0331637';

  sistema.abrirArquivo(pr_nmdireto => vr_diretorio,
                       pr_nmarquiv => 'contratos.csv',
                       pr_tipabert => 'R',
                       pr_utlfileh => vr_arqcontrato,
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

  LOOP
    IF utl_file.is_open(vr_arqcontrato) THEN
      BEGIN
        sistema.leituraLinhaArquivo(pr_utlfileh => vr_arqcontrato
                                   ,pr_des_text => vr_dslinha);      
        vr_arqlinha := cecred.gene0002.fn_quebra_string(pr_string  => vr_dslinha
                                                       ,pr_delimit => ';');      
        IF vr_arqlinha.count > 0 THEN
          vr_indice := vr_indice + 1;        
          vr_tbrecup_acordo_contrato(vr_indice).nracordo       := vr_arqlinha(1);
          vr_tbrecup_acordo_contrato(vr_indice).nrgrupo        := 1;
          vr_tbrecup_acordo_contrato(vr_indice).cdorigem       := vr_arqlinha(2);
          vr_tbrecup_acordo_contrato(vr_indice).nrctremp       := vr_arqlinha(3);
          vr_tbrecup_acordo_contrato(vr_indice).cdmodelo       := 2;
          vr_tbrecup_acordo_contrato(vr_indice).inrisco_acordo := cecred.risc0004.fn_traduz_nivel_risco(pr_dsnivris => vr_arqlinha(4));
        END IF;
      EXCEPTION
        WHEN no_data_found THEN
          sistema.fecharArquivo(pr_utlfileh => vr_arqcontrato);
          EXIT;
      END;
    END IF;
  END LOOP;

  BEGIN
    FORALL vr_indice IN INDICES OF vr_tbrecup_acordo_contrato SAVE EXCEPTIONS
      UPDATE cecred.tbrecup_acordo_contrato
         SET cdmodelo       = vr_tbrecup_acordo_contrato(vr_indice).cdmodelo
            ,inrisco_acordo = vr_tbrecup_acordo_contrato(vr_indice).inrisco_acordo
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
                  ' Erro: '     || SQLERRM;
        sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqlog
                                   ,pr_des_text => vr_log);
      END LOOP;
  END;
  COMMIT;

  fecharArquivos;
EXCEPTION
  WHEN vr_exec_erro THEN
    fecharArquivos;
    raise_application_error(-20500, vr_dscritic);
  WHEN OTHERS THEN
    fecharArquivos;
    raise_application_error(-20500, SQLERRM);
END;
