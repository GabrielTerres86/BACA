declare 

  vr_cdprograma VARCHAR2(25) := 'geraCargaCentral';
  vr_dtinproc   CONSTANT DATE         := SYSDATE;
  vr_dscomple   VARCHAR2(2000);
  vr_idprglog   NUMBER;
  
  vr_exc_erro     EXCEPTION;
  vr_cdcritic     NUMBER;
  vr_dscritic     VARCHAR2(4000);
  
  vr_idcarga    gestaoderisco.tbrisco_central_carga.idcentral_carga%TYPE;
  vr_tpprodut   gestaoderisco.tbrisco_central_carga.tpproduto%TYPE;
  
  vr_totaljobs  INTEGER := gestaoderisco.tiposdadosriscos.totaljobs;
  
  pr_rw_crapdat datascooperativa;
  vr_dtmvtolt   crapdat.dtmvtolt%TYPE;
  

BEGIN
  
  -- Calcular o calendario com base na data de referencia enviada
  GESTAODERISCO.obterCalendario(pr_cdcooper   => 1
                               ,pr_dtrefere   => to_date('30/09/2024','dd/mm/rrrr')
                               ,pr_rw_crapdat => pr_rw_crapdat
                               ,pr_cdcritic   => vr_cdcritic
                               ,pr_dscritic   => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;



  GESTAODERISCO.gerarSaidasDescTitulo(pr_cdcooper => 1
                                     ,pr_idcarga  => 54822 -- IN
                                     ,pr_idprglog => 0
                                     ,pr_rw_crapdat => pr_rw_crapdat
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  
end;
