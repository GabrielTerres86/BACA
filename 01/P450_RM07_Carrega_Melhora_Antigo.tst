PL/SQL Developer Test script 3.0
109
declare 
  CURSOR cr_cop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
     ORDER BY c.cdcooper DESC;
  rw_cop   cr_cop%ROWTYPE;

  CURSOR cr_emprestimos(pr_cdcooper IN crawepr.cdcooper%TYPE) IS
    SELECT  w.cdcooper, w.nrdconta, w.nrctremp
           ,e.vlsdeved
           ,w.dsnivori RIS_INC
           ,CASE WHEN w.dsnivris = 'A'  THEN 2
                        WHEN w.dsnivris = 'B'  THEN 3
                        WHEN w.dsnivris = 'C'  THEN 4
                        WHEN w.dsnivris = 'D'  THEN 5
                        WHEN w.dsnivris = 'E'  THEN 6
                        WHEN w.dsnivris = 'F'  THEN 7
                        WHEN w.dsnivris = 'G'  THEN 8
                        WHEN w.dsnivris = 'H'  THEN 9
                        WHEN w.dsnivris = 'HH' THEN 10
                     ELSE 2 END RISCO
      FROM crawepr w, crapepr e
     WHERE w.cdcooper = e.cdcooper
       AND w.nrdconta = e.nrdconta
       AND w.nrctremp = e.nrctremp
       AND e.cdcooper = pr_cdcooper
       AND e.inliquid = 0
       AND e.inprejuz = 0 -- Não carregar Melhora antigo para contratos com Prejuizo
--       AND e.idquaprc IN(3,4)
--       AND e.tpemprst IN (1,2)
       AND (w.dsnivris = 'A'AND
            w.dsnivris < w.dsnivori)
     ORDER BY w.cdcooper, w.nrdconta, w.nrctremp;
  rw_emprestimos cr_emprestimos%ROWTYPE;

  CURSOR cr_tbrisco_operacoes (pr_cdcooper IN crawepr.cdcooper%TYPE
                              ,pr_nrdconta IN crawepr.nrdconta%TYPE
                              ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
  SELECT r.inrisco_melhora 
    FROM tbrisco_operacoes r
   WHERE r.cdcooper = pr_cdcooper
     AND r.nrdconta = pr_nrdconta
     AND r.nrctremp = pr_nrctremp
     AND r.tpctrato = 90;
  rw_tbrisco_operacoes cr_tbrisco_operacoes%ROWTYPE;
      

  vr_contador integer;
BEGIN
  vr_contador := 0;

  FOR rw_cop IN cr_cop LOOP
    vr_contador := 0;
  
    FOR rw_emprestimos IN cr_emprestimos(pr_Cdcooper => rw_cop.cdcooper) LOOP
      
      vr_contador := vr_contador + 1;
      OPEN cr_tbrisco_operacoes (pr_cdcooper => rw_emprestimos.cdcooper
                                ,pr_nrdconta => rw_emprestimos.nrdconta
                                ,pr_nrctremp => rw_emprestimos.nrctremp);
      FETCH cr_tbrisco_operacoes INTO rw_tbrisco_operacoes;
      IF cr_tbrisco_operacoes%NOTFOUND THEN
        CLOSE cr_tbrisco_operacoes;
        
        INSERT INTO TBRISCO_OPERACOES 
                   (cdcooper, 
                    nrdconta, 
                    nrctremp, 
                    tpctrato, 
                    inrisco_inclusao, 
                    inrisco_calculado, 
                    inrisco_melhora, 
                    dtrisco_melhora, 
                    cdcritica_melhora)
              VALUES (rw_emprestimos.cdcooper,
                      rw_emprestimos.nrdconta,
                      rw_emprestimos.nrctremp,
                      90,
                      NULL,
                      NULL,
                      rw_emprestimos.risco,
                      to_date('20/12/2018 22:01:19','DD/MM/YYYY HH24:MI:SS'),
                      NULL
                     );
      ELSE
        CLOSE cr_tbrisco_operacoes;
         UPDATE TBRISCO_OPERACOES t
            SET t.inrisco_melhora   = rw_emprestimos.risco
               ,t.dtrisco_melhora   = SYSDATE
               ,t.cdcritica_melhora = NULL -- Quando atualizar, zera a critica
          WHERE t.cdcooper = rw_emprestimos.cdcooper
            AND t.nrdconta = rw_emprestimos.nrdconta
            AND t.nrctremp = rw_emprestimos.nrctremp
            AND t.tpctrato = 90;
      END IF;


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
