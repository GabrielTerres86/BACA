begin 
  insert into crapprm(nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               values('CRED',0,'INTEGRA_EXTD_EMAIL_ALERT','Email para alertas em caso de problema na falta do arquivo EXTD','tesouraria@ailos.coop.br');
               
  insert into crapprm(nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               values('CRED',0,'INTEGRA_EXTD_DATA_OK','Ultimo dia com integração OK perante arquivo Centralização Bancoob','17/05/2020');             
               
               
  insert into crapprm(nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               values('CRED',0,'INTEGRA_EXTD_HORA_LIM','Horário limite para integração arquivo Centralização Bancoob, após este horário toda execução gerará alerta a Tesouraria','17:00');                          
               
               
  insert into tbgen_batch_jobs (NMJOB, DSDETALHE, DSPREFIXO_JOBS, IDATIVO, IDPERIODICI_EXECUCAO, TPINTERVALO, QTINTERVALO, DSDIAS_HABILITADOS, DTPROX_EXECUCAO, FLEXECUTA_FERIADO, FLSAIDA_EMAIL, DSDESTINO_EMAIL, FLSAIDA_LOG, DSNOME_ARQ_LOG, DSCODIGO_PLSQL, CDOPERAD_CRIACAO, DTCRIACAO, CDOPERAD_ALTERACAO, DTALTERACAO, HRJANELA_EXEC_INI, HRJANELA_EXEC_FIM, FLAGUARDA_PROCESSO)
  values ('JBTES_BANCOOB_EXTD', 'Integracao dos arquivos do Bancoob apos processo batch', 'JBTES_INTEGRA_EXTD', 1, 'R', 'H', 2, '0111110', to_date(to_char(sysdate,'ddmmrrrr')||'0930','ddmmrrrrhh24mi'), 0, 'N', null, 'N', null, 'declare
    vr_cdcooper pls_integer := 3;
    vr_stprogra number;
    vr_infimsol number;
    vr_cdcritic number;
    vr_dscritic varchar2(4000);
  begin
    cecred.pc_crps512(pr_cdcooper => vr_cdcooper
                     ,pr_stprogra => vr_stprogra
                     ,pr_infimsol => vr_infimsol
                     ,pr_cdcritic => vr_cdcritic
                     ,pr_dscritic => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            raise_application_error(-20001, vr_dscritic);
          END IF;
  end;', '1', sysdate, '1', sysdate, '09:25', '17:35', 'S');
  
  commit;
  
end;