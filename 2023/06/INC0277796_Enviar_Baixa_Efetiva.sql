DECLARE
  CURSOR cr_crapcob IS
    SELECT cob.cdcooper
          ,dat.dtmvtolt
          ,cob.rowid rowid_cob
      FROM crapcob cob
     INNER JOIN crapdat dat
        ON cob.cdcooper = dat.cdcooper
      LEFT JOIN crapdda dda
        ON cob.rowid = dda.cobrowid
       AND dda.dscritic IS NULL
     WHERE cob.cdcooper IN (1, 2, 7, 9, 11)
       AND cob.dtdpagto = TO_DATE('06/06/2023', 'DD/MM/YYYY')
       AND cob.flgcbdda = 1
       AND cob.incobran = 5
       AND cob.nrdident > 0
       AND dda.cobrowid IS NULL;

  TYPE typ_tab_crapcob IS TABLE OF cr_crapcob%ROWTYPE INDEX BY PLS_INTEGER;
  vr_tab_crapcob typ_tab_crapcob;

  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);

  vr_exc_erro EXCEPTION;

BEGIN

  vr_cdcritic := 0;
  vr_dscritic := NULL;

  OPEN cr_crapcob;
  FETCH cr_crapcob BULK COLLECT
    INTO vr_tab_crapcob;
  CLOSE cr_crapcob;

  BEGIN
    FORALL idx IN INDICES OF vr_tab_crapcob SAVE EXCEPTIONS
      INSERT INTO crapdda
        (cdcooper
        ,dtsolici
        ,dtmvtolt
        ,flgerado
        ,cobrowid)
      VALUES
        (vr_tab_crapcob(idx).cdcooper
        ,SYSDATE
        ,vr_tab_crapcob(idx).dtmvtolt
        ,'N'
        ,vr_tab_crapcob(idx).rowid_cob);
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao inserir na tabela crapdda. ' ||
                     SQLERRM(- (SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
      SISTEMA.excecaoInterna(pr_cdcooper => 3, pr_compleme => vr_dscritic);
      RAISE vr_exc_erro;
  END;

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    IF nvl(vr_cdcritic, 0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    RAISE;
  WHEN OTHERS THEN
    ROLLBACK;
    SISTEMA.excecaoInterna(pr_cdcooper => 3);
    RAISE;
  
END;
