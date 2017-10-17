/*
31/03/2017 - #633147 Retirar o programa da cadeia da CECRED e coloc�-lo em job as 11h (JBCRD_BANCOOB_ENVIA_DEB_FAT) 
             Modificada a solicita��o de 40 para 999 e a ordem de 2 para 104.
             Verificar o inproces da CECRED para definir a data de refer�ncia da execu��o. (Carlos)
*/
BEGIN

  -- Retirar programa 675 do processo
  UPDATE crapprg p
     SET p.nrsolici = 999
        ,p.nrordprg = 104 -- ordem dispon�vel
   WHERE p.cdprogra = 'CRPS675'
     AND p.cdcooper = 3
     AND p.nrsolici = 40
     AND p.nrordprg = 2;

  -- Create do job do mesmo
  sys.dbms_scheduler.create_job(
    job_name            => 'CECRED.JBCRD_BANCOOB_ENVIA_DEB_FAT',
    job_type            => 'PLSQL_BLOCK',
    job_action          => 'DECLARE
    ww_dscritic VARCHAR2(500);
    ww_cdcritic crapcri.cdcritic%TYPE;
    BEGIN
      PC_CRPS675(3, ww_cdcritic, ww_dscritic);
      
      IF ww_dscritic IS NOT NULL THEN
        raise_application_error(-20001,ww_dscritic);
      END IF;
    END;',
    start_date          => '30/03/2017 11:00:00,000000 AMERICA/SAO_PAULO',
    repeat_interval     => 'Freq=Daily;Interval=1;ByHour=11;ByDay=MON,TUE,WED,THU,FRI',
    end_date            => to_date(null),
    job_class           => 'DEFAULT_JOB_CLASS',
    enabled             => true,
    auto_drop           => true,
    comments            => 'Gerar arquivo de retorno de D�bito em conta das faturas (Bancoob/CABAL)');
    
    COMMIT;
END;
