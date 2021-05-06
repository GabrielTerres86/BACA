UPDATE tbgen_batch_jobs a SET a.flexec_ultimo_dia_ano = 1 WHERE a.nmjob = 'JBCYB_GERA_DADOS_CYBER'
/
UPDATE CRAPACA
   SET LSTPARAM = 'pr_tpmantem,pr_nmjob,pr_dsdetalhe,pr_dsprefixo_jobs,pr_idativo,pr_idperiodici_execucao,pr_tpintervalo,pr_qtintervalo,pr_dsdias_habilitados,pr_dtprox_execucao,pr_hrprox_execucao,pr_hrjanela_exec_ini,pr_hrjanela_exec_fim,pr_flaguarda_processo,pr_flexecuta_feriado,pr_flexecuta_ultdiano,pr_flsaida_email,pr_dsdestino_email,pr_flsaida_log,pr_dsnome_arq_log,pr_dscodigo_plsql'
 WHERE UPPER(NMPROCED) = 'PC_MANTEM_JOB'
/
COMMIT;
/