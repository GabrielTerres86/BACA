declare 
  CURSOR c_cooper IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;
begin
  FOR t_cooper IN c_cooper LOOP
    
    MERGE
     INTO crappro PRO
    USING (
           SELECT REPLACE(PRO6.CDARR, '.', '') CDARR,
                  PRO6.NMARR,
                  REPLACE(PRO6.CDAGE, '.', '') CDAGE,
                  PRO6.NMAGE,
                  PRO6.PROGRESS_RECID
             FROM (
                   SELECT TRIM(SUBSTR(PRO7.INFO, P1_CDARR, P2_CDARR - P1_CDARR)) CDARR,
                          TRIM(SUBSTR(PRO7.INFO, P1_NMARR, P2_NMARR - P1_NMARR)) NMARR,
                          TRIM(SUBSTR(PRO7.INFO, P1_CDAGE, P2_CDAGE - P1_CDAGE)) CDAGE,
                          TRIM(SUBSTR(PRO7.INFO, P1_NMAGE, P2_NMAGE - P1_NMAGE)) NMAGE,
                          PRO7.PROGRESS_RECID
                     FROM (
                           SELECT 315 P1_CDARR, INSTR(INFO, '-', 315) P2_CDARR,
                                  INSTR(INFO, '-', 315) + 1 P1_NMARR, 343 P2_NMARR,
                                  353 P1_CDAGE, INSTR(INFO, '-', 353) P2_CDAGE,
                                  INSTR(INFO, '-', 353) + 1 P1_NMAGE, 392 P2_NMAGE,
                                  PRO8.INFO, PRO8.PROGRESS_RECID
                             FROM (
                                   SELECT UTL_ENCODE.TEXT_DECODE(PRO9.DSCOMPROVANTE_PARCEIRO, 'WE8ISO8859P1', 1) INFO, PROGRESS_RECID
                                     FROM CRAPPRO PRO9
                                    WHERE PRO9.CDCOOPER = t_cooper.cdcooper
                                      AND PRO9.DTMVTOLT = to_date('12/08/2021', 'DD/MM/YYYY')
                                      AND PRO9.CDTIPPRO IN (13, 16) AND PRO9.cdagearr is null
                                      AND LENGTH(PRO9.DSCOMPROVANTE_PARCEIRO) IN (2424, 2292) AND INSTR(DSINFORM##3, 'Arrecadador: 93') > 0
                                  ) PRO8
                          ) PRO7
                   ) PRO6 
          ) PRO1 
       ON (PRO.PROGRESS_RECID = PRO1.PROGRESS_RECID)
  WHEN MATCHED THEN UPDATE
   SET PRO.cdagearr = PRO1.CDARR,
       PRO.nmagearr = PRO1.NMARR,
       PRO.cdagenci = PRO1.CDAGE,
       PRO.nmagenci = PRO1.NMAGE;
    
    COMMIT;
    
  END LOOP;
END;