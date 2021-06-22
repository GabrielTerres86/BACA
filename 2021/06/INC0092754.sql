-- Created on 21/06/2021 by t0033292 
DECLARE
  CURSOR cr_ren IS
    select y.cdcooper
          ,y.nrdconta
          ,y.dtdpagto 
    from   tbepr_renegociacao y 
    where  y.cdcooper  = 1 
    and    y.nrdconta in (11404736,6321739)
    and    y.nrctremp  = 0;
  --
  CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                   ,pr_nrdconta IN crawepr.nrdconta%TYPE
                   ,pr_dtdpagto IN crawepr.dtdpagto%TYPE) IS      
    select nrctremp
    from   crawepr      x 
    where  x.cdcooper = pr_cdcooper
    and    x.nrdconta = pr_nrdconta 
    and    x.tpemprst = 3 
    and    x.dtdpagto = pr_dtdpagto;
  rw_crawepr cr_crawepr%ROWTYPE;      
  --
BEGIN
  FOR rw_ren IN cr_ren LOOP
    OPEN cr_crawepr(pr_cdcooper => rw_ren.cdcooper
                   ,pr_nrdconta => rw_ren.nrdconta
                   ,pr_dtdpagto => rw_ren.dtdpagto);
    FETCH cr_crawepr INTO rw_crawepr;
    IF cr_crawepr%NOTFOUND THEN
      --
      delete tbepr_renegociacao          where cdcooper = rw_ren.cdcooper and nrdconta = rw_ren.nrdconta and nrctremp = 0;
      delete tbepr_renegociacao_contrato where cdcooper = rw_ren.cdcooper and nrdconta = rw_ren.nrdconta and nrctremp = 0; 
      --       
    ELSE
      --
      update tbepr_renegociacao
      set    nrctremp = rw_crawepr.nrctremp
      where  cdcooper = rw_ren.cdcooper 
      and    nrdconta = rw_ren.nrdconta 
      and    nrctremp = 0;
      --
      update tbepr_renegociacao_contrato
      set    nrctremp = rw_crawepr.nrctremp
      where  cdcooper = rw_ren.cdcooper 
      and    nrdconta = rw_ren.nrdconta 
      and    nrctremp = 0; 
      --       
    END IF;
    CLOSE cr_crawepr;
  END LOOP;
  COMMIT;
END;
