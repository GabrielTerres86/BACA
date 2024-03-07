DECLARE
  
  CURSOR cr_crapcop IS 
    SELECT cdcooper 
      FROM cecred.crapcop
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  PROCEDURE cargaGrupoEconomico(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE) IS

    CURSOR cr_grupo(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE) IS
       SELECT g.flgcumulatividade,
              g.idgrupo
        FROM cecred.tbcc_grupo_economico g
            ,cecred.crapass a
       WHERE g.cdcooper = pr_cdcooper
         AND a.cdcooper = g.cdcooper
         AND a.nrdconta = g.nrdconta
         AND g.flgcumulatividade = 1
         AND EXISTS (SELECT 1 FROM cecred.tbcc_grupo_economico_integ i WHERE i.idgrupo = g.idgrupo AND i.dtexclusao IS NULL);
    rw_grupo cr_grupo%ROWTYPE;
        
  BEGIN
    dbms_output.enable(NULL);
    FOR rw_grupo IN cr_grupo(pr_cdcooper => pr_cdcooper) LOOP
      BEGIN
        INSERT INTO investimento.tbinvest_grupo_economico_cumulatividade (CDGRUPO_ECONOMICO, FLCUMULATIVIDADE, DHREGISTRO)
             VALUES (rw_grupo.idgrupo, rw_grupo.flgcumulatividade, SYSDATE);
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          raise_application_error(-20010, SQLERRM);
      END;
      END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20010, SQLERRM);
  END cargaGrupoEconomico;

BEGIN

  FOR rw_crapcop IN cr_crapcop LOOP
    cargaGrupoEconomico(pr_cdcooper => rw_crapcop.cdcooper);
    COMMIT;
  END LOOP;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20010, SQLERRM);
END;
