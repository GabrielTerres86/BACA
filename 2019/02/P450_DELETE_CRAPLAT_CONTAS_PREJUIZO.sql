DELETE FROM craplat lat
 WHERE lat.dtmvtolt >= to_date('01/10/2018', 'DD/MM/YYYY')
   AND lat.cdhistor IN (1441,1465)
   AND EXISTS (
         SELECT 1
           FROM tbcc_prejuizo prj
          WHERE prj.cdcooper = lat.cdcooper
            AND prj.nrdconta = lat.nrdconta
            AND prj.dtinclusao <= lat.dtmvtolt 
            AND (prj.dtliquidacao IS NULL
             OR prj.dtliquidacao >= lat.dtmvtolt)
       )
;

COMMIT;
