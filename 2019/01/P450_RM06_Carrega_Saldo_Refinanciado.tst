PL/SQL Developer Test script 3.0
65
-- TEMPO EXECUCAO HOMOL3 => 9MIN
declare 
  CURSOR cr_cop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
--       AND c.cdcooper = 5
    ORDER BY c.cdcooper DESC;
  rw_cop   cr_cop%ROWTYPE;

  CURSOR cr_emprestimos(pr_cdcooper IN crawepr.cdcooper%TYPE) IS
    SELECT e.nrdconta
          ,e.nrctremp
          ,e.cdcooper
          ,e.cdlcremp
          ,e.tpemprst
          ,e.vlsaldo_refinanciado
          ,e.vlemprst
          ,w.idquapro  -- Qualificação da Operação Controles
          ,e.idquaprc  -- Qualificação da Operação Controles
      FROM crapepr e
      JOIN crawepr w
        ON w.cdcooper = e.cdcooper
       AND w.nrdconta = e.nrdconta
       AND w.nrctremp = e.nrctremp
     WHERE e.cdcooper = pr_cdcooper
       -- OU Ativo OU Com prejuizo
       AND (e.inliquid = 0 OR e.inprejuz = 1)
       AND e.idquaprc IN(3,4)
       AND e.tpemprst IN (1,2)
     ORDER BY e.nrdconta, e.nrctremp;
  rw_emprestimos cr_emprestimos%ROWTYPE;


  vr_contador integer;
BEGIN
  vr_contador := 0;
  FOR rw_cop IN cr_cop LOOP
    vr_contador := 0;
  
    FOR rw_emprestimos IN cr_emprestimos(pr_Cdcooper => rw_cop.cdcooper) LOOP
      vr_contador := vr_contador + 1;
/*     dbms_output.put_line(vr_contador || ' -> '||
                          rw_emprestimos.nrdconta || ' - ' 
                           || rw_emprestimos.nrctremp || 
                '-> Valor: R$  '|| rw_emprestimos.vlemprst ||
                '-> Sld Ref: R$  '|| rw_emprestimos.vlsaldo_refinanciado
                );*/ 
     UPDATE crapepr e
        SET e.vlsaldo_refinanciado = rw_emprestimos.vlemprst
      WHERE e.cdcooper = rw_emprestimos.cdcooper
        AND e.nrdconta = rw_emprestimos.nrdconta
        AND e.nrctremp = rw_emprestimos.nrctremp
        ;
      IF (vr_contador MOD 1000) = 0 THEN
        -- commit a cada 1000 registros
        COMMIT;
      END IF;
    END LOOP;
    -- commit por cooperativa
    dbms_output.put_line('FIM COOP '||rw_cop.cdcooper  || ' -> '|| vr_contador);
    COMMIT;
  END LOOP;
end;
0
0
