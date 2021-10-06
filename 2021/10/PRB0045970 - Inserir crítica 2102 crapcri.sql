DECLARE
  CURSOR cr_crapcri(pr_cdcritic crapcri.cdcritic%TYPE
                   ,pr_dscritic crapcri.dscritic%TYPE) IS
    SELECT 1
      FROM crapcri
     WHERE cdcritic = pr_cdcritic
       AND dscritic = pr_dscritic;

  rw_crapcri  cr_crapcri%ROWTYPE;
  vr_cdcritic crapcri.cdcritic%TYPE := 2102;
  vr_dscritic crapcri.dscritic%TYPE := '2102 - Valor da parcela é inferior ao mínimo permitido';
BEGIN
  OPEN cr_crapcri(pr_cdcritic => vr_cdcritic
                 ,pr_dscritic => vr_dscritic);
  FETCH cr_crapcri
    INTO rw_crapcri;

  IF cr_crapcri%NOTFOUND THEN
    INSERT INTO crapcri
      (cdcritic
      ,dscritic
      ,tpcritic
      ,flgchama)
    VALUES
      (vr_cdcritic
      ,vr_dscritic
      ,4
      ,0);
    COMMIT;
  END IF;
  CLOSE cr_crapcri;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, 'Erro ao inserir na tabela CRAPCRI: ' || SQLERRM);
END;
