DECLARE
  
  CURSOR cr_crapcop IS 
    SELECT cdcooper 
      FROM cecred.crapcop
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  PROCEDURE carregarNovoGrupo(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE) IS

    CURSOR cr_grupo(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE) IS
      SELECT g.nrdconta
            ,g.idgrupo
            ,a.nrcpfcgc
        FROM cecred.tbcc_grupo_economico g
            ,cecred.crapass a
       WHERE g.cdcooper = pr_cdcooper
         AND a.cdcooper = g.cdcooper
         AND a.nrdconta = g.nrdconta
         AND EXISTS (SELECT 1 FROM cecred.tbcc_grupo_economico_integ i WHERE i.idgrupo = g.idgrupo AND i.dtexclusao IS NULL);
    rw_grupo cr_grupo%ROWTYPE;
    
    CURSOR cr_integ(pr_idgrupo IN cecred.tbcc_grupo_economico.idgrupo%TYPE) IS
      SELECT i.nrcpfcgc
            ,i.nrdconta
        FROM cecred.tbcc_grupo_economico_integ i
       WHERE i.idgrupo = pr_idgrupo
         AND i.dtexclusao IS NULL;
    rw_integ cr_integ%ROWTYPE;
    
  BEGIN
    dbms_output.enable(NULL);
    FOR rw_grupo IN cr_grupo(pr_cdcooper => pr_cdcooper) LOOP
      BEGIN
        INSERT INTO gestaoderisco.tbrisco_grupo_economico_integ(idgrupo_economico, cdcooper, nrdconta, nrcpfcgc, dhtransmissao)
        VALUES (rw_grupo.idgrupo, pr_cdcooper, rw_grupo.nrdconta, rw_grupo.nrcpfcgc, SYSDATE);
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          raise_application_error(-20010, SQLERRM);
      END;
      FOR rw_integ IN cr_integ(pr_idgrupo => rw_grupo.idgrupo) LOOP
        BEGIN
          INSERT INTO gestaoderisco.tbrisco_grupo_economico_integ(idgrupo_economico, cdcooper, nrdconta, nrcpfcgc, dhtransmissao)
          VALUES (rw_grupo.idgrupo, pr_cdcooper, rw_integ.nrdconta, rw_integ.nrcpfcgc, SYSDATE);
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            raise_application_error(-20010, SQLERRM);
        END;
      END LOOP;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20010, SQLERRM);
  END carregarNovoGrupo;

BEGIN

  FOR rw_crapcop IN cr_crapcop LOOP
    carregarNovoGrupo(pr_cdcooper => rw_crapcop.cdcooper);
    COMMIT;
  END LOOP;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20010, SQLERRM);
END;
