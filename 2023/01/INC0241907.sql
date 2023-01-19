DECLARE
CURSOR cr_parcelas IS
    select t.NMEXTTTL, p.cdcooper, p.nrdconta, p.nrctremp, p.nrparcel, p.vlnominal, p.dtvencto, p.DSNOSNUM, c.DIAS_ATRASO, p.IDPARCELA
   from credito.tbepr_parcelas_cred_imob p 
       , cecred.crapttl t
       , credito.tbepr_contrato_imobiliario c
  where t.cdcooper = p.cdcooper
    and t.nrdconta = p.nrdconta
    and t.IDSEQTTL = 1
    and p.cdcooper = 1
    and p.dtvencto = '17/01/2023'
    and (p.VLMORA > 0 or p.VLMULTA > 0)
    and c.cdcooper = p.cdcooper
    and c.nrdconta = p.nrdconta
    and c.nrctremp = p.nrctremp
    and c.DIAS_ATRASO < 3;
    
  rw_parcelas cr_parcelas%ROWTYPE;
  
BEGIN
  FOR rw_parcelas IN cr_parcelas LOOP
    
    UPDATE credito.tbepr_parcelas_cred_imob 
       SET IDSITUACAO = 'C' 
       WHERE nrdconta = rw_parcelas.nrdconta
         AND nrctremp = rw_parcelas.nrctremp
         AND idparcela = rw_parcelas.idparcela
         AND DSNOSNUM = rw_parcelas.DSNOSNUM;

    COMMIT;  
  END LOOP;

  UPDATE credito.tbepr_parcelas_cred_imob SET IDSITUACAO = 'C' where nrdconta = 0;
  COMMIT;  

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
