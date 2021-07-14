DECLARE
  dserro VARCHAR2(1000);
BEGIN
  FOR i IN (SELECT *
              FROM crapsle e
             WHERE e.cdcooper = 8
               AND e.dsendere = 'fabricio.michelato@ailos.coop.br'
               AND e.flenviad = 'N') LOOP
  
    gene0003.pc_process_email_penden(i.nrseqsol, dserro);
  
    UPDATE crapsle
       SET flenviad = 'S'
     WHERE nrseqsol = i.nrseqsol;
  
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
