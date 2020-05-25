PL/SQL Developer Test script 3.0
57
DECLARE
  -------------------------------------------------------------------
  w_cdcooper NUMBER := 16; -- Atualizar com a cooperativa desejada!!!!
  -------------------------------------------------------------------
  w_dtrefere DATE := to_date('31/03/2020','DD/MM/YYYY');

  w_stprogra NUMBER;
  w_infimsol NUMBER;
  w_cdcritic NUMBER;
  w_dscritic VARCHAR2(32767);
BEGIN
  
  DELETE crapris ris
   WHERE ris.cdcooper = w_cdcooper
     AND ris.inddocto = 2
     AND ris.dtrefere = w_dtrefere; -- Se atentar a data da mensal

  UPDATE crapris ris
     SET ris.flgindiv = 0
   WHERE ris.cdcooper = w_cdcooper
     AND ris.dtrefere = w_dtrefere; -- Se atentar a data da mensal

  COMMIT;  
  dbms_output.put_line('Limpou as tabelas...');

  -- Call the procedure
  cecred.pc_crps660_wag(pr_cdcooper => w_cdcooper,
                        pr_stprogra => w_stprogra,
                        pr_infimsol => w_infimsol,
                        pr_cdcritic => w_cdcritic,
                        pr_dscritic => w_dscritic);
  IF w_cdcritic IS NOT NULL THEN
    dbms_output.put_line('Erro: '||w_cdcritic||' e '||w_dscritic);
    RETURN;
  ELSE
    dbms_output.put_line('Executou pc_crps660_wag..');
  END IF;   
  
  COMMIT;
  
  cecred.pc_crps573_wag(pr_cdcooper => w_cdcooper,
                        pr_stprogra => w_stprogra,
                        pr_infimsol => w_infimsol,
                        pr_cdcritic => w_cdcritic,
                        pr_dscritic => w_dscritic);
  IF w_cdcritic IS NOT NULL THEN
    dbms_output.put_line('Erro: '||w_cdcritic||' e '||w_dscritic);
    RETURN;
  ELSE
    dbms_output.put_line('Executou pc_crps573_wag.');
  END IF; 
   
  COMMIT;
  
  dbms_output.put_line('Fim do Script, cooperativa '||w_cdcooper||' gerada com sucesso.');
   
END;
0
0
