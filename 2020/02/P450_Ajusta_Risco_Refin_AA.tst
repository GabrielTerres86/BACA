PL/SQL Developer Test script 3.0
58
-- ^^^^^
--  FAVOR CONFERIR O DBMS OUTPUT PARA VERIFICAR SE HOUVE ERROS, APÓS A EXECUÇÃO DO SCRIPT
--
--  FAVOR CONFERIR O DBMS OUTPUT PARA VERIFICAR SE HOUVE ERROS, APÓS A EXECUÇÃO DO SCRIPT
--
--  FAVOR CONFERIR O DBMS OUTPUT PARA VERIFICAR SE HOUVE ERROS, APÓS A EXECUÇÃO DO SCRIPT
--
DECLARE

  CURSOR cr_cop IS
    SELECT c.cdcooper 
      FROM crapcop c
     WHERE c.flgativo = 1;
  rw_cop  cr_cop%ROWTYPE;
  
  CURSOR cr_epr (pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT epr.cdcooper
        ,epr.nrdconta
        ,epr.nrctremp
        ,epr.inrisco_refin
       , epr.qtdias_atraso_refin
       , decode(wpr.dsnivris, ' ', 'A', wpr.dsnivris) dsnivris
       , decode(wpr.dsnivori, ' ', 'A', wpr.dsnivori) dsnivori
    FROM crapepr epr
       , crawepr wpr
   WHERE epr.cdcooper = pr_cdcooper
     AND wpr.cdcooper = epr.cdcooper
     AND wpr.nrdconta = epr.nrdconta
     AND wpr.nrctremp = epr.nrctremp
     AND epr.inrisco_refin = 1
     ORDER BY epr.cdcooper
             ,epr.nrdconta
             ,epr.nrctremp;
  rw_epr cr_epr%ROWTYPE;
  vr_contador integer;
BEGIN
  vr_contador := 0;
  FOR rw_cop IN cr_cop LOOP
    vr_contador := 0;
    FOR rw_epr IN cr_epr (rw_cop.cdcooper) LOOP
      BEGIN
        UPDATE crapepr e
           SET e.inrisco_refin = 2
         WHERE e.cdcooper = rw_epr.cdcooper
           AND e.nrdconta = rw_epr.nrdconta
           AND e.nrctremp = rw_epr.nrctremp;     
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro ao atualizar Coop/Conta/Contrato: ' ||
                               '  => ' || rw_epr.cdcooper || '/'|| rw_epr.nrdconta || '/' || rw_epr.nrctremp);
      END;
      vr_contador := vr_contador + 1;
    END LOOP;
    COMMIT;
    dbms_output.put_line('Coop ' || rw_cop.cdcooper || ' - Atualizados: ' || vr_contador);
  END LOOP;
  
end;
0
0
