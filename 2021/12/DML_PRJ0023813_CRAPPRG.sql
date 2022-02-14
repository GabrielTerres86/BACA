DECLARE
  --Cooperativas ativas que não possuem o cadastro de programa
  CURSOR cr_crapcop(pr_nmsistem IN crapprg.nmsistem%TYPE
                   ,pr_cdprogra IN crapprg.cdprogra%TYPE) IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND NOT EXISTS (SELECT 1
              FROM crapprg prg
             WHERE prg.nmsistem = pr_nmsistem
               AND prg.cdprogra = pr_cdprogra
               AND prg.cdcooper = cop.cdcooper);
  --Busca a última ordem de programa
  CURSOR cr_crapprg(pr_nrsolici crapprg.nrsolici%TYPE) IS
    SELECT nvl(MAX(prg.nrordprg), 0) + 1
      FROM crapprg prg
     WHERE prg.nrsolici = pr_nrsolici;

  vr_nrordprg    crapprg.nrordprg%TYPE;
  vr_nmsistem    crapprg.nmsistem%TYPE := 'CRED';
  vr_cdprogra    crapprg.cdprogra%TYPE := 'PEAC';
  vr_dsprogra##1 crapprg.dsprogra##1%TYPE := 'Acompanhamento Operacoes PEAC';
  vr_nrsolici    crapprg.nrsolici%TYPE := 50;
BEGIN
  OPEN cr_crapprg(vr_nrsolici);
  FETCH cr_crapprg
    INTO vr_nrordprg;
  CLOSE cr_crapprg;

  FOR rw_crapcop IN cr_crapcop(vr_nmsistem, vr_cdprogra) LOOP
    INSERT INTO crapprg
      (nmsistem
      ,cdprogra
      ,dsprogra##1
      ,nrsolici
      ,nrordprg
      ,cdcooper)
    VALUES
      (vr_nmsistem
      ,vr_cdprogra
      ,vr_dsprogra##1
      ,vr_nrsolici
      ,vr_nrordprg
      ,rw_crapcop.cdcooper);
    COMMIT;      
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20500, SQLERRM);
END;
