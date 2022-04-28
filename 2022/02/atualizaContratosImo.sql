BEGIN
update credito.tbepr_contrato_imobiliario imo
   set imo.cdlcremp = 10000,
       imo.cdfinemp = 100
 where imo.cdcooper = 16
   and imo.nrctremp = 308010
   and imo.nrdconta = 124;
   
  credito.acionarmotorcontratoimobiliario(
   
update credito.tbepr_contrato_imobiliario imo
   set imo.cdlcremp = 10000,
       imo.cdfinemp = 100
 where imo.cdcooper = 16
   and imo.nrctremp = 308024
   and imo.nrdconta = 6157262;  
   COMMIT;
EXCEPTION
 WHEN OTHERS THEN
   NULL;
END; 