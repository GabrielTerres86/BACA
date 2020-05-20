BEGIN
  DECLARE 
    CURSOR cr_crapcop IS
      SELECT cdcooper
        FROM crapcop 
       WHERE flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE) IS
      SELECT nrdconta, nrctremp 
        FROM crapepr
       WHERE cdcooper = pr_cdcooper
         AND tpemprst = 0  -- TR
         AND inliquid = 0
         AND inprejuz = 0;
    rw_crapepr cr_crapepr%ROWTYPE;
    
    CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE
                     ,pr_nrdconta IN crapbpr.nrdconta%TYPE
                     ,pr_nrctremp IN crapbpr.nrctrpro%TYPE) IS
      SELECT * 
        FROM crapbpr 
       WHERE cdcooper = pr_cdcooper 
         AND nrdconta = pr_nrdconta
         AND nrctrpro = pr_nrctremp 
         AND tpctrpro = 90 
         AND dstipbem IN (' ', '')
         AND dscatbem IN ('AUTOMOVEL', 'CAMINHAO', 'MOTO', 'OUTROS VEICULOS');
    rw_crapbpr cr_crapbpr%ROWTYPE;
    
    vr_contador INTEGER := 0;
  BEGIN
    FOR rw_crapcop IN cr_crapcop LOOP
      FOR rw_crapepr IN cr_crapepr(rw_crapcop.cdcooper) LOOP
        FOR rw_crapbpr IN cr_crapbpr(rw_crapcop.cdcooper, rw_crapepr.nrdconta, rw_crapepr.nrctremp) LOOP
          vr_contador := vr_contador + 1;
          dbms_output.put_line('Idx: ' || vr_contador || 
                               ' - Cooper: '   || rw_crapbpr.cdcooper ||
                               ' - Nrdconta: ' || rw_crapbpr.nrdconta ||
                               ' - Contrato: ' || rw_crapbpr.nrctrpro);
        END LOOP;
        UPDATE crapbpr 
           SET dstipbem = 'USADO'
         WHERE cdcooper = rw_crapcop.cdcooper
           AND nrdconta = rw_crapepr.nrdconta
           AND nrctrpro = rw_crapepr.nrctremp
           AND tpctrpro = 90 
           AND dstipbem IN (' ', '')
           AND dscatbem IN ('AUTOMOVEL', 'CAMINHAO', 'MOTO', 'OUTROS VEICULOS');
      END LOOP;
    END LOOP;
    --ROLLBACK;
    COMMIT;
    
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao atualizar bens - ' || SQLERRM);
    ROLLBACK;
  END;
END;