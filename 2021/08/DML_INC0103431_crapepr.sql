
BEGIN
  UPDATE crapepr epr
     SET epr.diarefju = '28',
         epr.mesrefju = '07',
         epr.anorefju = '2021',
         epr.dtrefjur = to_date('28/07/2021','DD/MM/RRRR')
   WHERE EXISTS (SELECT 1
                   FROM crapass a
                  WHERE a.cdagenci = 28
                   AND a.cdcooper = epr.cdcooper
                   AND a.nrdconta = epr.nrdconta 
                   AND a.cdcooper = 9)
     AND ((epr.inprejuz = 1 AND epr.vlsdprej > 0 ) OR
           epr.inliquid = 0)
     AND epr.dtrefjur < to_date('28/07/2021','DD/MM/RRRR');             
    
  COMMIT;           
END;         
