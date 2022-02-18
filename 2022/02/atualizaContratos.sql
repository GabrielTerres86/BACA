BEGIN
update credito.tbepr_contrato_imobiliario imo
   set imo.nrdconta_aval1 = 3057399,
       imo.nrdconta_aval2 = 2841568,
       imo.situacao_analise = 0,
       imo.situacao_aprovacao = 0
 where imo.cdcooper = 16
   and imo.nrctremp = 308010
   and imo.nrdconta = 124;
   
update credito.tbepr_contrato_imobiliario imo
   set imo.nrdconta_aval1 = 964271,
       imo.nrdconta_aval2 = 666246,
       imo.situacao_analise = 0,
       imo.situacao_aprovacao = 0
 where imo.cdcooper = 16
   and imo.nrctremp = 308024
   and imo.nrdconta = 6157262;  
   COMMIT;
EXCEPTION
 WHEN OTHERS THEN
   NULL;
END;   