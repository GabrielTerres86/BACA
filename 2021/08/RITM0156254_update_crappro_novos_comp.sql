BEGIN
  -- BANCOOB -> Tamanho 1380 = SIMPLES NACIONAL --300.000
  MERGE
   INTO crappro PRO
  USING (SELECT PRO2.*
           FROM CRAPPRO PRO
          INNER JOIN (
                      SELECT TRIM(SUBSTR(PRO8.INFO, 362,  5)) CDARR,
                             TRIM(SUBSTR(PRO8.INFO, 367, 24)) NMARR,
                             TRIM(SUBSTR(PRO8.INFO, 261,  5)) CDAGE,
                             TRIM(SUBSTR(PRO8.INFO, 268, 30)) NMAGE,
                             PRO8.DSPROTOC
                       FROM (
                             SELECT UTL_ENCODE.TEXT_DECODE(PRO9.DSCOMPROVANTE_PARCEIRO, 'WE8ISO8859P1', 1) INFO, DSPROTOC
                               FROM CRAPPRO PRO9
                              WHERE LENGTH(PRO9.DSCOMPROVANTE_PARCEIRO) = 1380
                            ) PRO8
                     ) PRO2 ON PRO2.DSPROTOC = PRO.DSPROTOC
        ) PRO1
     ON (PRO1.DSPROTOC = PRO.DSPROTOC)
   WHEN MATCHED THEN UPDATE
    SET PRO.cdagearr = PRO1.CDARR,
        PRO.nmagearr = PRO1.NMARR,
        PRO.cdagenci = PRO1.CDAGE,
        PRO.nmagenci = PRO1.NMAGE;

  COMMIT;
      
  -- BANCOOB -> Tamanho 2156 = DARF SIMPLES --166.962
  MERGE
   INTO crappro PRO
  USING (SELECT PRO2.*
           FROM CRAPPRO PRO
          INNER JOIN (
                      SELECT TRIM(SUBSTR(PRO8.INFO, 251,  5)) CDARR,
                             TRIM(SUBSTR(PRO8.INFO, 268,  9)) NMARR,
                             TRIM(SUBSTR(PRO8.INFO, 261,  5)) CDAGE,
                             TRIM(SUBSTR(PRO8.INFO, 268, 30)) NMAGE,
                             PRO8.DSPROTOC
                       FROM (
                             SELECT UTL_ENCODE.TEXT_DECODE(PRO9.DSCOMPROVANTE_PARCEIRO, 'WE8ISO8859P1', 1) INFO, DSPROTOC
                               FROM CRAPPRO PRO9
                              WHERE LENGTH(PRO9.DSCOMPROVANTE_PARCEIRO) = 2156
                            ) PRO8
                     ) PRO2 ON PRO2.DSPROTOC = PRO.DSPROTOC
        ) PRO1
     ON (PRO1.DSPROTOC = PRO.DSPROTOC)
   WHEN MATCHED THEN UPDATE
    SET PRO.cdagearr = PRO1.CDARR,
        PRO.nmagearr = PRO1.NMARR,
        PRO.cdagenci = PRO1.CDAGE,
        PRO.nmagenci = PRO1.NMAGE;

  COMMIT;
        
  -- BANCOOB -> Tamanho 2424 e 2292 = DARF e GPS SEM CODIGO DE BARRAS - 260221
  MERGE
   INTO crappro PRO
  USING (SELECT PRO2.*
           FROM CRAPPRO PRO
          INNER JOIN (
                      SELECT REPLACE(PRO6.CDARR, '.', '') CDARR,
                             PRO6.NMARR,
                             REPLACE(PRO6.CDAGE, '.', '') CDAGE,
                             PRO6.NMAGE,
                             PRO6.DSPROTOC, INFO, DSINFORM##3
                       FROM (
                             SELECT TRIM(SUBSTR(PRO7.INFO, P1_CDARR, P2_CDARR - P1_CDARR)) CDARR,
                                    TRIM(SUBSTR(PRO7.INFO, P1_NMARR, P2_NMARR - P1_NMARR)) NMARR,
                                    TRIM(SUBSTR(PRO7.INFO, P1_CDAGE, P2_CDAGE - P1_CDAGE)) CDAGE,
                                    TRIM(SUBSTR(PRO7.INFO, P1_NMAGE, P2_NMAGE - P1_NMAGE)) NMAGE,
                                    PRO7.DSPROTOC, INFO, DSINFORM##3
                               FROM (
                                     SELECT 315 P1_CDARR, INSTR(INFO, '-', 315) P2_CDARR,
                                            INSTR(INFO, '-', 315) + 1 P1_NMARR, 343 P2_NMARR,
                                            353 P1_CDAGE, INSTR(INFO, '-', 353) P2_CDAGE,
                                            INSTR(INFO, '-', 353) + 1 P1_NMAGE, 392 P2_NMAGE,
                                            PRO8.INFO, PRO8.DSPROTOC, DSINFORM##3
                                       FROM (
                                             SELECT UTL_ENCODE.TEXT_DECODE(PRO9.DSCOMPROVANTE_PARCEIRO, 'WE8ISO8859P1', 1) INFO, DSPROTOC, DSINFORM##3
                                               FROM CRAPPRO PRO9
                                              WHERE LENGTH(PRO9.DSCOMPROVANTE_PARCEIRO) IN (2424, 2292)
                                            ) PRO8
                                    ) PRO7
                            ) PRO6 
                     ) PRO2 ON PRO2.DSPROTOC = PRO.DSPROTOC 
        ) PRO1
     ON (PRO1.DSPROTOC = PRO.DSPROTOC)
   WHEN MATCHED THEN UPDATE
    SET PRO.cdagearr = PRO1.CDARR,
        PRO.nmagearr = PRO1.NMARR,
        PRO.cdagenci = PRO1.CDAGE,
        PRO.nmagenci = PRO1.NMAGE;

  COMMIT;

  -- BANCOOB -> Tamanho 1468 e 1464 = GPS
  MERGE
   INTO crappro PRO
  USING (SELECT PRO2.*
           FROM CRAPPRO PRO
          INNER JOIN (
                      SELECT TRIM(SUBSTR(PRO7.INFO, P1_CDAGE, P2_CDAGE - P1_CDAGE)) CDAGE,
                             TRIM(SUBSTR(PRO7.INFO, P1_NMAGE, P2_NMAGE - P1_NMAGE)) NMAGE, 
                             PRO7.DSPROTOC 
                        FROM (
                              SELECT P1_CDAGE, INSTR(INFO, '-', P1_CDAGE) P2_CDAGE,
                                     INSTR(INFO, '-', P1_CDAGE) + 1 P1_NMAGE, 292 P2_NMAGE,
                                     PRO8.INFO, PRO8.DSPROTOC
                                FROM (
                                      SELECT INSTR(INFO, 'PAC:') + 4 P1_CDAGE,
                                             PRO6.INFO, PRO6.DSPROTOC
                                        FROM (
                                              SELECT UTL_ENCODE.TEXT_DECODE(PRO9.DSCOMPROVANTE_PARCEIRO, 'WE8ISO8859P1', 1) INFO, DSPROTOC, DSINFORM##3
                                                FROM CRAPPRO PRO9
                                               WHERE LENGTH(PRO9.DSCOMPROVANTE_PARCEIRO) IN (1464, 1468)
                                             ) PRO6
                                     ) PRO8
                             ) PRO7
                     ) PRO2 ON PRO2.DSPROTOC = PRO.DSPROTOC 
        ) PRO1
     ON (PRO1.DSPROTOC = PRO.DSPROTOC)
   WHEN MATCHED THEN UPDATE
    SET PRO.cdagearr = '756',
        PRO.nmagearr = 'BANCO SICOOB S.A.',
        PRO.cdagenci = PRO1.CDAGE,
        PRO.nmagenci = PRO1.NMAGE;

  COMMIT;
END;