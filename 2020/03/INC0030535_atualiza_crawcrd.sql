declare 
  vr_cdcooper crawcrd.cdcooper%TYPE := 1;
  vr_nrdconta crawcrd.nrdconta%TYPE := 3002756;
  vr_nrctrcrd crawcrd.nrctrcrd%TYPE := 265802; 
begin

  -- Marca a proposta do cartao como encerrada
  UPDATE crawcrd wcrd
     SET wcrd.insitcrd = 6
        ,wcrd.cdopeexc = 1
        ,wcrd.cdageexc = 0
      ,wcrd.dtinsexc = SYSDATE
      ,wcrd.flgctitg = 0
      ,wcrd.dtcancel = SYSDATE
      ,wcrd.cdmotivo = 4
      ,wcrd.cdoperad = 1
  WHERE wcrd.cdcooper = vr_cdcooper
    AND wcrd.nrdconta= vr_nrdconta
    AND wcrd.nrctrcrd= vr_nrctrcrd;
      
  -- Marca o cartao como cancelado
  UPDATE crapcrd crd
     SET crd.dtcancel = SYSDATE
        ,crd.cdmotivo = 4
  WHERE crd.cdcooper = vr_cdcooper
     AND crd.nrdconta= vr_nrdconta
     AND crd.nrctrcrd= vr_nrctrcrd;
  
  commit;
end;
