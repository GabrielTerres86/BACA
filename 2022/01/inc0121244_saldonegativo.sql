DECLARE
   cursor cr_parcelas is
   select pep.cdcooper,
          pep.nrdconta,
          pep.nrctremp,
          pep.nrparepr
  from crappep pep, crapepr epr
 where epr.cdcooper = pep.cdcooper
   and epr.nrdconta = pep.nrdconta
   and epr.nrctremp = pep.nrctremp
   and pep.inliquid = 0
   and pep.vlpagpar + pep.vldstcor + pep.vldstrem > pep.vlparepr
   and epr.tpemprst = 2
   and epr.inliquid = 0
   and epr.inprejuz = 0;
   
  rw_parcelas cr_parcelas%ROWTYPE;

BEGIN
  
  FOR rw_parcelas IN cr_parcelas LOOP
    UPDATE crappep
    SET    vlpagpar = 0
          ,vldstcor = 0
          ,vldstrem = 0
    WHERE  cdcooper = rw_parcelas.cdcooper
    AND    nrdconta = rw_parcelas.nrdconta
    AND    nrctremp = rw_parcelas.nrctremp
    AND    nrparepr = rw_parcelas.nrparepr;
  END LOOP;
  
  COMMIT;

EXCEPTION 
  WHEN OTHERS THEN
    dbms_output.put_line( sqlerrm);
    dbms_output.put_line( sqlcode);
    ROLLBACK;
END;
