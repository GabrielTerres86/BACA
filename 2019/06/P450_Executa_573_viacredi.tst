PL/SQL Developer Test script 3.0
47

DECLARE
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    vr_contareg       PLS_INTEGER;                                 --> Número da conta
    vr_cdcooper       crapcop.cdcooper%TYPE;                       --> Codigo da Cooperativa
    
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   crapcri.dscritic%TYPE;
    pr_stprogra   PLS_INTEGER;
    pr_infimsol   PLS_INTEGER;

    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper)
         AND cop.flgativo = 1
         AND cop.cdcooper <> 3
       ORDER BY cop.cdcooper DESC;
    rw_crapcop cr_crapcop%ROWTYPE;


BEGIN
  vr_cdcooper := 1; -- deve ser 0, outro numero so para testes
  
  FOR rw_crapcop IN cr_crapcop(vr_cdcooper) LOOP
    vr_contareg := 0;  

    dbms_output.put_line('COP: ' ||  rw_crapcop.cdcooper);   
    
    vr_cdcritic := 0;
    vr_dscritic := NULL;
    cecred.pc_crps573_jaison(pr_cdcooper => rw_crapcop.cdcooper,
                             pr_stprogra => pr_stprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic,
                             pr_dscritic => vr_dscritic);
    IF vr_cdcritic > 0
    OR vr_dscritic IS NOT NULL THEN
        dbms_output.put_line('  => ERRO COP : ' ||  rw_crapcop.cdcooper ||
                             ' -> ' || vr_cdcritic || ' - ' || vr_dscritic);   
    END IF;
    
  END LOOP; -- CRAPCOP
  
END;
0
0
