PL/SQL Developer Test script 3.0
46
declare 
   CURSOR cr_craplcr IS 
     SELECT l.cdcooper
           ,l.cdlcremp 
      FROM craplcr l 
      WHERE l.flgrepro = 1;

   rw_craplcr cr_craplcr%ROWTYPE;

   vr_excsaida  EXCEPTION;
BEGIN

   FOR rw_craplcr IN cr_craplcr LOOP
       BEGIN
         INSERT INTO credito.tbcred_reciprocidade_linha
                     (cdcooper
                      ,cdlcremp
                      ,cdcatego
                      ,vlmincat
                      ,insituacao
                      ,cdoperad
                      ,dtrefatu)
             VALUES (rw_craplcr.cdcooper
                    ,rw_craplcr.cdlcremp
                    ,0
                    ,0.0
                    ,1
                    ,1
                    ,SYSDATE);
       EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
           CONTINUE;
         WHEN OTHERS THEN
          RAISE vr_excsaida;
       END;

   END LOOP;

   COMMIT;

EXCEPTION
  WHEN vr_excsaida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
end;
0
0
