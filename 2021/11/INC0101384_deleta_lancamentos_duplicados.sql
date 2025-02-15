DECLARE

CURSOR C_EXEC IS
SELECT 1 FROM DUAL UNION ALL
SELECT 2 FROM DUAL;

CURSOR C1 IS
  SELECT A.CDCOOPER,
         A.NRDCONTA,
         A.NRCTREMP, 
         A.VLLANMTO,
         A.DTMVTOLT,
         MAX(ROWID) REG,
         COUNT(*)
    FROM CRAPLEM A
   WHERE A.CDCOOPER = 1
     AND A.NRDCONTA = 9727647
     AND A.NRCTREMP = 3552623
     AND A.DTMVTOLT = TO_DATE('22/07/2021', 'DD/MM/RRRR')
    GROUP BY A.CDCOOPER,
             A.NRDCONTA,
             A.NRCTREMP, 
             A.VLLANMTO,
             A.DTMVTOLT
   HAVING COUNT(*) > 1
UNION ALL
  SELECT A.CDCOOPER,
         A.NRDCONTA,
         A.NRCTREMP, 
         A.VLLANMTO,
         A.DTMVTOLT,
         MAX(ROWID) REG,
         COUNT(*)
    FROM CRAPLEM A
   WHERE A.CDCOOPER = 1
     AND A.NRDCONTA = 9727647
     AND A.NRCTREMP = 3547162
     AND A.DTMVTOLT = TO_DATE('22/07/2021', 'DD/MM/RRRR')
    GROUP BY A.CDCOOPER,
             A.NRDCONTA,
             A.NRCTREMP, 
             A.VLLANMTO,
             A.DTMVTOLT
   HAVING COUNT(*) > 1  
UNION ALL
  SELECT A.CDCOOPER,
         A.NRDCONTA,
         A.NRCTREMP, 
         A.VLLANMTO,
         A.DTMVTOLT,
         MAX(ROWID) REG,
         COUNT(*)
    FROM CRAPLEM A
   WHERE A.CDCOOPER = 2
     AND A.NRDCONTA = 466077
     AND A.NRCTREMP = 295372
     AND A.DTMVTOLT = TO_DATE('05/08/2021', 'DD/MM/RRRR')
    GROUP BY A.CDCOOPER,
             A.NRDCONTA,
             A.NRCTREMP, 
             A.VLLANMTO,
             A.DTMVTOLT
   HAVING COUNT(*) > 1         
  ORDER BY NRCTREMP, VLLANMTO;  
  
CURSOR C2 IS
  SELECT A.CDCOOPER,
         A.NRDCONTA,
         A.NRCTREMP, 
         A.VLLANMTO,
         A.DTMVTOLT,
         ROWID REG
    FROM CRAPLEM A
   WHERE A.CDCOOPER = 16
     AND A.NRDCONTA = 762466
     AND A.NRCTREMP = 251809
     AND A.DTMVTOLT = TO_DATE('12/08/2021', 'DD/MM/RRRR');                          

BEGIN
  FOR R_EXEC IN C_EXEC LOOP
    FOR R1 IN C1 LOOP
      DELETE CRAPLEM
       WHERE ROWID = R1.REG; 
    END LOOP;
  END LOOP;  
  FOR R2 IN C2 LOOP
    DELETE CRAPLEM
     WHERE ROWID = R2.REG; 
  END LOOP;  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
