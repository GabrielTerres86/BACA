DECLARE
  vr_cdcritic    cecred.crapcri.cdcritic%TYPE;
  vr_dscritic    cecred.crapcri.dscritic%TYPE;
  vr_diretorio   VARCHAR2(200);
  vr_rollback    VARCHAR2(4000);
  vr_log         VARCHAR2(4000);
  vr_arqrollback UTL_FILE.file_type;
  vr_arqlog      UTL_FILE.file_type;
  vr_exec_erro   EXCEPTION;

  CURSOR cr_tbrecup_acordo_contrato IS
    SELECT DISTINCT a.cdcooper
                   ,a.nrdconta
                   ,a.nracordo
                   ,b.nrgrupo
                   ,b.cdorigem
                   ,b.nrctremp
                   ,b.cdmodelo
      FROM cecred.tbrecup_acordo a
          ,cecred.tbrecup_acordo_contrato b
          ,cecred.crapcyb c
          ,(SELECT a.nracordo
                  ,a.cdcooper
                  ,a.nrdconta
                  ,b.cdorigem
                  ,b.nrctremp
                  ,b.cdmodelo
                  ,coalesce(c.inprejuz,
                            d.inprejuz,
                            CASE
                              WHEN nvl(e.nrdconta, 0) > 0 THEN
                               1
                              ELSE
                               0
                            END) flgpreju
                  ,c.inliquid
                  ,d.insitbdt
                  ,d.nrborder
                  ,e.dtinclusao
                  ,e.dtliquidacao
              FROM cecred.tbrecup_acordo a
             INNER JOIN cecred.tbrecup_acordo_contrato b
                ON (a.nracordo = b.nracordo)
              LEFT JOIN crapepr c
                ON (a.cdcooper = c.cdcooper AND a.nrdconta = c.nrdconta AND b.nrctremp = c.nrctremp)
              LEFT JOIN (SELECT t.cdcooper
                              ,t.nrdconta
                              ,t.nrctrdsc
                              ,t.nrborder
                              ,b.inprejuz
                              ,b.insitbdt
                          FROM cecred.tbdsct_titulo_cyber t
                         INNER JOIN cecred.crapbdt b
                            ON t.nrdconta = b.nrdconta
                           AND t.cdcooper = b.cdcooper
                           AND t.nrborder = b.nrborder) d
                ON (a.cdcooper = d.cdcooper AND a.nrdconta = d.nrdconta AND b.nrctremp = d.nrctrdsc)
              LEFT JOIN cecred.tbcc_prejuizo e
                ON (a.cdcooper = e.cdcooper AND a.nrdconta = e.nrdconta AND
                   e.dtinclusao < trunc(a.dhacordo) AND
                   (e.dtliquidacao IS NULL OR e.dtliquidacao > trunc(a.dhacordo)))) d
          ,(SELECT a.cdcooper
                  ,a.nrdconta
                  ,a.nrctremp
                  ,a.dtrefere dtcentral
                  ,a.vldivida
                  ,a.qtdiaatr
                  ,a.innivris
                  ,(a.dtrefere - a.qtdiaatr) + 1 dtiniatraso
              FROM cecred.crapris a
                  ,cecred.crapdat b
             WHERE a.cdcooper = b.cdcooper
               AND a.dtrefere = b.dtmvcentral) e
     WHERE a.nracordo = b.nracordo
       AND a.cdcooper = c.cdcooper
       AND a.nrdconta = c.nrdconta
       AND b.cdorigem = c.cdorigem
       AND b.nrctremp = c.nrctremp
          
       AND a.nracordo = d.nracordo
       AND a.cdcooper = d.cdcooper
       AND a.nrdconta = d.nrdconta
       AND b.cdorigem = d.cdorigem
       AND b.nrctremp = d.nrctremp
          
       AND a.cdcooper = e.cdcooper
       AND a.nrdconta = e.nrdconta
       AND (b.nrctremp = e.nrctremp 
         OR d.nrborder = e.nrctremp)
          
       AND c.flgpreju = 0
       AND d.flgpreju = 0
       AND nvl(d.inliquid, 0) = 0
       AND nvl(d.insitbdt, 0) <> 4
       AND a.cdsituacao = 1
       AND b.cdorigem NOT IN (5, 6)
       AND b.cdmodelo = 1
       AND EXISTS (SELECT 1
              FROM cecred.tbrecup_acordo_parcela d
             WHERE d.nracordo = a.nracordo
               AND d.nrparcela = 0
               AND d.vlpago > 0)
     ORDER BY a.dhacordo
             ,a.cdcooper
             ,a.nrdconta
             ,a.nracordo
             ,b.cdorigem
             ,b.nrctremp;

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
                       ' SET cdmodelo = ' || vr_tbrecup_acordo_contrato(vr_indice).cdmodelo ||
                     ' WHERE nracordo = ' || vr_tbrecup_acordo_contrato(vr_indice).nracordo ||
                       ' AND nrgrupo = ' || vr_tbrecup_acordo_contrato(vr_indice).nrgrupo ||
                       ' AND cdorigem = ' || vr_tbrecup_acordo_contrato(vr_indice).cdorigem ||
                       ' AND nrctremp = ' || vr_tbrecup_acordo_contrato(vr_indice).nrctremp || ';';
      sistema.escreveLinhaArquivo(pr_utlfileh => vr_arqrollback
                                 ,pr_des_text => vr_rollback);
    END LOOP;
  
    BEGIN
      FORALL vr_indice IN INDICES OF vr_tbrecup_acordo_contrato SAVE EXCEPTIONS
        UPDATE cecred.tbrecup_acordo_contrato
           SET cdmodelo = 2
         WHERE nracordo = vr_tbrecup_acordo_contrato(vr_indice).nracordo
           AND nrgrupo = vr_tbrecup_acordo_contrato(vr_indice).nrgrupo
           AND cdorigem = vr_tbrecup_acordo_contrato(vr_indice).cdorigem
           AND nrctremp = vr_tbrecup_acordo_contrato(vr_indice).nrctremp;
    EXCEPTION
      WHEN OTHERS THEN
        FOR vr_indice IN 1 .. SQL%bulk_exceptions.count LOOP
          vr_log := 'nracordo: ' || vr_tbrecup_acordo_contrato(SQL%BULK_EXCEPTIONS(vr_indice).error_index).nracordo ||
                    ' nrgrupo: ' || vr_tbrecup_acordo_contrato(SQL%BULK_EXCEPTIONS(vr_indice).error_index).nrgrupo ||
                    ' cdorigem: ' || vr_tbrecup_acordo_contrato(SQL%BULK_EXCEPTIONS(vr_indice).error_index).nrdconta ||
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
