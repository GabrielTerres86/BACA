DECLARE

  vr_des_reto VARCHAR2 (1000) := NULL;
  vr_tab_reto gene0001.typ_tab_erro;
  vr_descritc VARCHAR2(4000) := NULL;
  
  CURSOR cr_crapepr IS                   
    SELECT x.cdcooper
          ,x.nrdconta
          ,x.nrctremp
          ,x.tpemprst
     FROM (
       SELECT MIN(p.dtvencimento) dtproximo_vencto
             ,CASE
                 WHEN to_date('19/12/2023', 'DD/MM/RRRR') > MIN(p.dtvencimento) THEN
                   to_date('19/12/2023', 'DD/MM/RRRR') - MIN(p.dtvencimento)
                 ELSE
                   0
                 END qtd_atraso_calc
             ,a.cdcooper
             ,a.nrdconta
             ,b.nrctremp
             ,p.nracordo
             ,b.cdorigem
             ,e.tpemprst
             ,e.progress_recid
         FROM tbrecup_acordo_parcela  p
             ,tbrecup_acordo          a
             ,tbrecup_acordo_contrato b
             ,crapepr                 e
       WHERE a.nracordo   = b.nracordo
         AND a.nracordo   = p.nracordo
         AND a.cdcooper   = e.cdcooper
         AND a.nrdconta   = e.nrdconta
         AND b.nrctremp   = e.nrctremp
         AND a.cdsituacao = 1
         AND p.vlpago     = 0
         AND e.inprejuz   = 1
         AND e.dtprejuz   = to_date('19/12/2023', 'DD/MM/RRRR')
    GROUP BY a.cdcooper
            ,a.nrdconta
            ,b.nrctremp
            ,p.nracordo
            ,b.cdorigem
            ,e.tpemprst
            ,e.progress_recid ) x
    WHERE x.qtd_atraso_calc < 180;
  rw_crapepr cr_crapepr%rowtype;  
     
  CURSOR cr_crapdat(pr_cdcooper cecred.crapepr.cdcooper%TYPE) IS
    SELECT crapdat.dtmvtolt     
      FROM cecred.crapdat
     WHERE crapdat.cdcooper = pr_cdcooper;  
  rw_crapdat cr_crapdat%rowtype;      
  
BEGIN
  
  FOR rw_crapepr IN cr_crapepr LOOP
                              
    OPEN cr_crapdat(rw_crapepr.cdcooper);
      FETCH cr_crapdat INTO rw_crapdat;
    CLOSE cr_crapdat;
                                                                      
    IF rw_crapepr.tpemprst = 1 THEN
      PREJ0001.pc_estorno_trf_prejuizo_PP(pr_cdcooper => rw_crapepr.Cdcooper,
                                          pr_cdagenci => 1,
                                          pr_nrdcaixa => 1,
                                          pr_cdoperad => '1',
                                          pr_nrdconta => rw_crapepr.nrdconta,
                                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                          pr_nrctremp => rw_crapepr.nrctremp,
                                          pr_des_reto => vr_des_reto,
                                          pr_tab_erro => vr_tab_reto);                                                                 
    END IF;
  END LOOP;
  
  COMMIT;
EXCEPTION                                         
  WHEN OTHERS THEN
    ROLLBACK; 
    RAISE_application_error(-20500, 'Erro: ' || SQLERRM);
END;
