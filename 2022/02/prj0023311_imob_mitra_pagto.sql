begin
  EXECUTE IMMEDIATE 'ALTER SESSION SET
    nls_calendar = ''GREGORIAN''
    nls_comp = ''BINARY''
    nls_date_format = ''DD-MON-RR''
    nls_date_language = ''AMERICAN''
    nls_iso_currency = ''AMERICA''
    nls_language = ''AMERICAN''
    nls_length_semantics = ''BYTE''
    nls_nchar_conv_excp = ''FALSE''
    nls_numeric_characters = ''.,''
    nls_sort = ''BINARY''
    nls_territory = ''AMERICA''
    nls_time_format = ''HH.MI.SSXFF AM''
    nls_time_tz_format = ''HH.MI.SSXFF AM TZR''
    nls_timestamp_format = ''DD-MON-RR HH.MI.SSXFF AM''
    nls_timestamp_tz_format = ''DD-MON-RR HH.MI.SSXFF AM TZR''';

  BEGIN
    sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBEPR_IMOB_MITRA_TEMP');
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  sys.dbms_scheduler.create_job(job_name            => 'CECRED.JBEPR_IMOB_MITRA_TEMP',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'DECLARE 
                                                           CURSOR cr_parc IS 
                                                            SELECT p.cdcooper, p.nrdconta, p.nrctremp, MAX(p.dtdebitado) dtdebitado
                                                              FROM credito.tbepr_parcelas_cred_imob p
                                                             WHERE p.nrparcel > 0
                                                               AND p.dtdebitado is not null
                                                               AND p.idsituacao = ''D''
                                                             GROUP BY p.cdcooper, p.nrdconta, p.nrctremp
                                                             ORDER BY p.cdcooper, p.nrdconta, p.nrctremp;

                                                          BEGIN

                                                            FOR rw_parc in cr_parc LOOP
                                                              UPDATE credito.tbepr_contrato_imobiliario imob
                                                                 SET imob.dt_ultimo_pagamento = rw_parc.dtdebitado
                                                               WHERE imob.cdcooper = rw_parc.cdcooper
                                                                 AND imob.nrdconta = rw_parc.nrdconta
                                                                 AND imob.nrctremp = rw_parc.nrctremp;
                                                            END LOOP;
                                                            COMMIT;
                                                          EXCEPTION
                                                            WHEN others THEN
                                                              ROLLBACK;
                                                              CECRED.pc_internal_exception(pr_cdcooper => 3);
                                                          END;',
                                start_date          => to_date('25-02-2022 23:10:00', 'dd-mm-yyyy hh24:mi:ss'),
                                repeat_interval    => '',
                                end_date            => to_date(NULL),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => true,
                                auto_drop           => true,
                                comments            => 'Inclusão de data do pagamento de parcelas na tabela de contratos para o mitra');
end;
