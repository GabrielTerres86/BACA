DELETE FROM craplat lat
 WHERE lat.dtmvtolt >= to_date('01/10/2018', 'DD/MM/YYYY')
   AND lat.cdhistor IN (1441,1465)
   AND lat.insitlat = 1
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

--Altera o indicador de historico de credito deve ser transferido para a conta transitoria caso a conta esteja em prejuizo 
UPDATE craphis 
SET    intransf_cred_prejuizo = 0 --(0 = nao, 1 = sim)
WHERE  cdhistor = 662; 
 
--Salva 
COMMIT;
