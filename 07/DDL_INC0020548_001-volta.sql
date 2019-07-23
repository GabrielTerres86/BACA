/*
INC0020548 - Voltar risco para 'F'
Ana Volles - 22/07/2019

select DSNIVORI, CRAWEPR.Dtmvtolt from CRAWEPR WHERE CDCOOPER = 9 AND NRDCONTA = 78239 AND NRCTREMP = 15642;
select * from crapris where CDCOOPER = 9 AND NRDCONTA = 78239 AND NRCTREMP = 15642;
select * from crapvri where CDCOOPER = 9 AND NRDCONTA = 78239 AND NRCTREMP = 15642;
select * from tbrisco_central_ocr where CDCOOPER = 9 AND NRDCONTA = 78239 AND NRCTREMP = 15642;

*/


BEGIN
  UPDATE CRAWEPR
     SET DSNIVORI = 'F'
   WHERE CDCOOPER = 9
     AND NRDCONTA = 78239
     AND NRCTREMP = 15642;

--commit;

EXCEPTION
  WHEN OTHERS THEN
    rollback;
END;
