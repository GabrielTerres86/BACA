DECLARE
  vr_diretorio VARCHAR2(300);
  vr_arquivo   utl_file.file_type;
  vr_dslinha   VARCHAR2(6000);
  vr_nrdconta  cecred.crapcyb.nrdconta%TYPE;
  vr_nrctremp  cecred.crapcyb.nrctremp%TYPE;
  vr_cooperado cecred.GENE0002.typ_split;
  vr_inderr    PLS_INTEGER := 0;
  vr_dscritic  cecred.crapcri.dscritic%TYPE;
  vr_exc_saida EXCEPTION;

  CURSOR cr_crapcyb(pr_nrcpfcgc IN cecred.crapass.nrcpfcgc%TYPE
                   ,pr_nrctrdsc IN NUMBER) IS
    SELECT cyb.nrdconta
          ,cyb.nrctremp
      FROM cecred.craptdb tdb
     INNER JOIN cecred.tbdsct_titulo_cyber tcy
        ON tcy.cdcooper = tdb.cdcooper
       AND tcy.nrdconta = tdb.nrdconta
       AND tcy.nrborder = tdb.nrborder
       AND tcy.nrtitulo = tdb.nrtitulo
     INNER JOIN cecred.crapcyb cyb
        ON cyb.cdcooper = tcy.cdcooper
       AND cyb.nrdconta = tcy.nrdconta
       AND cyb.nrctremp = tcy.nrctrdsc
       AND cyb.cdorigem = 4
     INNER JOIN cecred.crapass ass
        ON cyb.cdcooper = ass.cdcooper
       AND cyb.nrdconta = ass.nrdconta
     WHERE ass.nrcpfcgc = pr_nrcpfcgc
       AND tcy.nrctrdsc || tdb.nrdocmto = pr_nrctrdsc;
  rw_crapcyb cr_crapcyb%ROWTYPE;

  TYPE typ_reg_arquivo IS RECORD(
    dslinha VARCHAR2(32000));

  TYPE typ_tab_arquivo IS TABLE OF typ_reg_arquivo INDEX BY PLS_INTEGER;

  vr_arquivoerr typ_tab_arquivo;
BEGIN
  vr_diretorio := sistema.obterParametroSistema(pr_nmsistem => 'CRED', pr_cdacesso => 'ROOT_MICROS') ||
                  'cpd/bacas/INC0281999';
  IF vr_diretorio IS NULL THEN
    vr_dscritic := 'Erro ao obter diretorio BACAS.';
    RAISE vr_exc_saida;
  END IF;

  sistema.abrirArquivo(pr_nmdireto => vr_diretorio,
                       pr_nmarquiv => 'desconto.txt',
                       pr_tipabert => 'R',
                       pr_utlfileh => vr_arquivo,
                       pr_dscritic => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro ao abrir arquivo.';
    RAISE vr_exc_saida;
  END IF;

  LOOP
    IF utl_file.IS_OPEN(vr_arquivo) THEN
      BEGIN
        sistema.leituraLinhaArquivo(pr_utlfileh => vr_arquivo, pr_des_text => vr_dslinha);
      
        BEGIN
          vr_cooperado := cecred.GENE0002.fn_quebra_string(pr_string  => vr_dslinha,
                                                           pr_delimit => ';');
          IF vr_cooperado.count > 0 THEN
            IF vr_cooperado(3) = 4 THEN
              rw_crapcyb := NULL;
            
              OPEN cr_crapcyb(pr_nrcpfcgc => vr_cooperado(2), pr_nrctrdsc => vr_cooperado(5));
              FETCH cr_crapcyb
                INTO rw_crapcyb;
              CLOSE cr_crapcyb;
            
              IF nvl(rw_crapcyb.nrdconta, 0) > 0 THEN
                vr_nrdconta := rw_crapcyb.nrdconta;
                vr_nrctremp := rw_crapcyb.nrctremp;
              ELSE
                vr_inderr := vr_inderr + 1;
                vr_arquivoerr(vr_inderr).dslinha := 'Não encontrado - ' || vr_dslinha;
                CONTINUE;
              END IF;
            ELSE
              vr_nrdconta := vr_cooperado(4);
              vr_nrctremp := vr_cooperado(5);
            END IF;
          
            INSERT INTO cecred.craprea
              (cdcooper
              ,dtmvtolt
              ,nrcpfcgc
              ,nrdconta
              ,cdorigem
              ,nrctremp
              ,cdoperad
              ,flenvarq)
            VALUES
              (vr_cooperado(1)
              ,trunc(SYSDATE)
              ,vr_cooperado(2)
              ,vr_nrdconta
              ,vr_cooperado(3)
              ,vr_nrctremp
              ,'f0030546'
              ,0);
            COMMIT;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            vr_inderr := vr_inderr + 1;
            vr_arquivoerr(vr_inderr).dslinha := SQLERRM || ' - ' || vr_dslinha;
        END;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          sistema.fecharArquivo(pr_utlfileh => vr_arquivo);
          EXIT;
      END;
    END IF;
  END LOOP;

  IF vr_arquivoerr.count > 0 THEN
    sistema.abrirArquivo(pr_nmdireto => vr_diretorio,
                         pr_nmarquiv => 'Erros.txt',
                         pr_tipabert => 'W',
                         pr_utlfileh => vr_arquivo,
                         pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Erro ao abrir arquivo.';
      RAISE vr_exc_saida;
    END IF;
  
    FOR vr_indice IN vr_arquivoerr.first .. vr_arquivoerr.last LOOP
      sistema.escreveLinhaArquivo(pr_utlfileh => vr_arquivo,
                                  pr_des_text => vr_arquivoerr(vr_indice).dslinha);
    END LOOP;
    sistema.fecharArquivo(pr_utlfileh => vr_arquivo);
  END IF;

  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
    raise_application_error(-20500, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
