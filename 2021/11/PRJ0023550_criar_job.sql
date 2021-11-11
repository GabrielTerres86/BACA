begin
  insert into cecred.tbgen_batch_jobs (NMJOB, DSDETALHE, DSPREFIXO_JOBS, IDATIVO, IDPERIODICI_EXECUCAO, TPINTERVALO, QTINTERVALO, DSDIAS_HABILITADOS, DTPROX_EXECUCAO, FLEXECUTA_FERIADO, FLSAIDA_EMAIL, DSDESTINO_EMAIL, FLSAIDA_LOG, DSNOME_ARQ_LOG, DSCODIGO_PLSQL, CDOPERAD_CRIACAO, DTCRIACAO, CDOPERAD_ALTERACAO, DTALTERACAO, HRJANELA_EXEC_INI, HRJANELA_EXEC_FIM, FLAGUARDA_PROCESSO, FLEXEC_ULTIMO_DIA_ANO)
  values ('JBPRONAMPE', 'Processa os arquivos de retorno do pronampe e realiza a movto financeira', 'JBPRONAMPE', 1, 'R', 'M', 5, '0111110', to_date('25-11-2021 19:30:00', 'dd-mm-yyyy hh24:mi:ss'), 0, 'N', null, 'N', null, 'BEGIN
  credito.PCJOBPRONAMPE;
  END;', null, to_date('26-01-2021 23:38:14', 'dd-mm-yyyy hh24:mi:ss'), '1', to_date('04-11-2021 13:32:13', 'dd-mm-yyyy hh24:mi:ss'), '09:00', '23:59', 'S', 0);
  commit;
exception
when others then
  rollback;
end;