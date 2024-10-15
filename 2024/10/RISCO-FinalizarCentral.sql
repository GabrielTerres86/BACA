declare 
  vr_cdcritic integer;
  vr_dscritic VARCHAR2(4000);
  
  vr_exc_erro EXCEPTION;
    vr_idcarga    gestaoderisco.tbrisco_central_carga.idcentral_carga%TYPE;

BEGIN

  UPDATE gestaoderisco.tbrisco_central_carga c
    SET c.CDSTATUS = 4
   WHERE c.cdcooper = 1
     AND c.dtrefere = '14/10/2024'
     AND c.tpproduto = 3
     AND c.idcentral_carga = 55994;  

  vr_idcarga := 56012;
    GESTAODERISCO.gravarFimCarga(pr_cdcooper    => 1
                                ,pr_idcarga     => vr_idcarga
                                ,pr_cdcritic    => vr_cdcritic
                                ,pr_dscritic    => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

end;
