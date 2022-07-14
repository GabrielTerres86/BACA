BEGIN
  update cecred.TBEPR_CONSIGNADO_PAGAMENTO
     set instatus = 2
   where cdcooper = 5
     and nrdconta = 41297 
     and nrctremp = 31491
     and ((trunc(dtupdreg) = to_date('12/07/2022','DD/MM/YYYY')) or (trunc(dtincreg) = to_date('12/07/2022','DD/MM/YYYY')));
     
  update cecred.crappep e
    set e.dtultpag = to_date('12/07/2022','DD/MM/YYYY'),
        e.vlpagpar = 167.68,
        e.inliquid = 1,
        e.vldespar = 0,
        e.vlsdvpar = 0,
        e.vlsdvatu = 0,
        e.vlsdvsji = 0
    where e.cdcooper = 5 
    and e.nrdconta = 41297 
    and e.nrctremp = 31491
    and e.nrparepr = 20;
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
