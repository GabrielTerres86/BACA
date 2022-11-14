BEGIN
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5461851 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Itajai'                  where  cdcooper =  1 and nrctremp =  5503549 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Balneario Barra do Sul'  where  cdcooper =  1 and nrctremp =  5248889 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5376031 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5465592 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Balneario Barra do Sul'  where  cdcooper =  1 and nrctremp =  5306435 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5619053 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5299559 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5501151 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5528210 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5499661 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5390090 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5371858 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Itajai'                  where  cdcooper =  1 and nrctremp =  5569303 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5306616 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Itajai'                  where  cdcooper =  1 and nrctremp =  5619184 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5350544 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5625132 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5042871 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  4763764 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  4924277 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  4988515 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  4876649 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Jaragua do Sul'          where  cdcooper =  1 and nrctremp =  5188424 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  4680967 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Jaragua do Sul'          where  cdcooper =  1 and nrctremp =  4997509 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  5174910 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  4950308 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Blumenau'                where  cdcooper =  1 and nrctremp =  4829600 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Brusque'                 where  cdcooper =  1 and nrctremp =  5121637 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Jaragua do Sul'          where  cdcooper =  1 and nrctremp =  4953412 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Ibirama'                 where  cdcooper =  16 and nrctremp =  366856 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Ibirama'                 where  cdcooper =  16 and nrctremp =  421162 ;
  UPDATE credito.tbepr_contrato_bem_imobiliario set NMCIDADE =  'Ibirama'                 where  cdcooper =  16 and nrctremp =  427288 ;   
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
