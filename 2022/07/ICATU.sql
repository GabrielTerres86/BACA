BEGIN
  UPDATE cecred.crapatr atr
  SET atr.cdopeexc = 'f0011244',
      atr.dtinsexc = to_date('02/05/2022', 'dd/mm/yyyy'),
      atr.dtfimatr = to_date('02/05/2022', 'dd/mm/yyyy')
  WHERE atr.nrdconta = 3596559
    AND atr.cdcooper = 1    
    AND atr.cdrefere = 930206887548;

  UPDATE cecred.crapatr atr
  SET atr.cdopeexc = 'f0011885',
      atr.dtinsexc = to_date('27/06/2022', 'dd/mm/yyyy'),
      atr.dtfimatr = to_date('27/06/2022', 'dd/mm/yyyy')
  WHERE atr.nrdconta = 14044510
    AND atr.cdcooper = 1    
    AND atr.cdrefere = 930427454700;
     
 COMMIT;
END;