declare
-- Busca os JOB's do Debitador Único
  CURSOR u_job_debitador(p_like_nm_job IN VARCHAR2) IS 
    SELECT job.owner
          ,job.job_name
          ,job.next_run_date
    FROM   dba_scheduler_jobs job
    WHERE  job.owner = 'CECRED'
    AND    job.job_name LIKE p_like_nm_job 
    ORDER BY job.job_name;
    
begin    
  -- Exclui os JOBs do Debitador Único
  FOR r_job_debitador IN u_job_debitador(p_like_nm_job => '%DEB%UNI%') LOOP
    dbms_output.put_line('r_job_debitador.job_nam: '||r_job_debitador.job_name);
    dbms_scheduler.drop_job(job_name => r_job_debitador.owner||'.'||r_job_debitador.job_name);    
  END LOOP;
end; 
/
commit;

--Exclui horários dos programas existentes
DELETE TBGEN_DEBITADOR_HORARIO_PROC;
COMMIT;

--Exclui programas e prioridades existentes
DELETE TBGEN_DEBITADOR_PARAM;
COMMIT;

--Exclui horários existentes
DELETE TBGEN_DEBITADOR_HORARIO;
COMMIT;

--Exclui históricos de alterações
DELETE TBGEN_DEBITADOR_HISTORICO;
COMMIT;

--INSERIR TODOS PROGRAMAS/PRIORIDADES
insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS750', 'PAGAMENTOS DAS PARCELAS DE EMPRÉSTIMOS (TR E PP)', 'N', 'S', null, 1, 'S', 3);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS724', 'PAGAR AS PARCELAS DOS CONTRATOS DO PRODUTO POS-FIXADO', 'N', 'S', null, 2, 'S', 0);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB', 'EFETIVAR LANCAMENTO PENDENTE MULTA/JUROS TR CONTRATOS EMP/FINANC POS-FIXADA', 'N', 'N', null, 3, 'N', 0);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS674', 'DEBITO DE FATURA - LANCAMENTO DE DEBITO AUTOMATICO - BANCOOB/CABAL', 'N', 'S', 1, 4, 'N', 2);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS268', 'DEBITO EM CONTA REFERENTE SEGURO DE VIDA EM GRUPO', 'S', 'N', null, 5, 'N', 0);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS439', 'DEBITO DIARIO DO SEGURO', 'S', 'N', null, 6, 'S', 0);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS663', 'DEBCNS - EFETUAR DEBITOS DE CONSORCIOS PENDENTES', 'N', 'N', null, 7, 'N', 2);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS509_PRIORI', 'DEBNET - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS PRIORITARIOS DA CECRED FEITOS NA INTERNET', 'N', 'N', null, 8, 'N', 2);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS642_PRIORI', 'DEBSIC - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS PRIORITARIOS DA SICREDI FEITOS NA INTERNET ', 'N', 'N', null, 9, 'N', 2);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS509', 'DEBNET - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS DA CECRED FEITOS NA INTERNET', 'N', 'N', null, 10, 'N', 2);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS642', 'DEBSIC - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS DA SICREDI FEITOS NA INTERNET', 'N', 'N', null, 11, 'N', 2);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PAGA0003.PC_PROCESSA_AGEND_BANCOOB', 'DEBITOS PAGAMENTO PENDENTES BANCOOB (FGTS)', 'N', 'N', null, 12, 'N', 2);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('TARI0001.PC_DEB_TARIFA_PEND', 'COBRANCA DE TARIFAS PENDENTES', 'N', 'S', null, 13, 'N', 0);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA', 'EFETIVAR OS AGENDAMENTOS DE RECARGA DE CELULAR', 'N', 'N', null, 14, 'N', 2);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS172', 'DEBITO EM CONTA DAS PRESTACOES DE PLANO DE CAPITAL', 'N', 'N', null, 15, 'N', 0);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS654', 'TENTATIVA DIARIA DEBITO DE COTAS', 'N', 'S', null, 16, 'N', 0);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS688', 'EFETUAR RESGATE DE APLICAÇÕES AGENDADAS PELO INTERNET BANK', 'N', 'N', null, 17, 'N', 2);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS145', 'DEBITO EM CONTA REF POUPANCA PROGRAMADA', 'N', 'N', null, 18, 'N', 0);

insert into tbgen_debitador_param (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS123', 'EFETUAR OS LANCAMENTOS AUTOMATICOS NO SISTEMA REF. A DEBITO EM CONTA', 'S', 'N', null, 19, 'N', 0);

COMMIT;

--INSERIR NOVOS HORÁRIOS
insert into tbgen_debitador_horario (IDHORA_PROCESSAMENTO, DHPROCESSAMENTO)
values (1, to_date(To_Char(sysdate+1,'dd-mm-yyyy')||' 07:00:00', 'dd-mm-yyyy hh24:mi:ss'));

insert into tbgen_debitador_horario (IDHORA_PROCESSAMENTO, DHPROCESSAMENTO)
values (2, to_date(To_Char(sysdate+1,'dd-mm-yyyy')||' 12:30:00', 'dd-mm-yyyy hh24:mi:ss'));

insert into tbgen_debitador_horario (IDHORA_PROCESSAMENTO, DHPROCESSAMENTO)
values (3, to_date(To_Char(sysdate+1,'dd-mm-yyyy')||' 17:30:00', 'dd-mm-yyyy hh24:mi:ss'));

insert into tbgen_debitador_horario (IDHORA_PROCESSAMENTO, DHPROCESSAMENTO)
values (4, to_date(To_Char(sysdate+1,'dd-mm-yyyy')||' 18:00:00', 'dd-mm-yyyy hh24:mi:ss'));

insert into tbgen_debitador_horario (IDHORA_PROCESSAMENTO, DHPROCESSAMENTO)
values (5, to_date(To_Char(sysdate+1,'dd-mm-yyyy')||' 19:00:00', 'dd-mm-yyyy hh24:mi:ss'));

insert into tbgen_debitador_horario (IDHORA_PROCESSAMENTO, DHPROCESSAMENTO)
values (6, to_date(To_Char(sysdate+1,'dd-mm-yyyy')||' 21:00:00', 'dd-mm-yyyy hh24:mi:ss'));

insert into tbgen_debitador_horario (IDHORA_PROCESSAMENTO, DHPROCESSAMENTO)
values (7, to_date(To_Char(sysdate+1,'dd-mm-yyyy')||' 21:50:00', 'dd-mm-yyyy hh24:mi:ss'));

COMMIT;

--INSERIR HORÁRIOS DOS PROGRAMAS
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB', 6);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PAGA0003.PC_PROCESSA_AGEND_BANCOOB', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PAGA0003.PC_PROCESSA_AGEND_BANCOOB', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PAGA0003.PC_PROCESSA_AGEND_BANCOOB', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PAGA0003.PC_PROCESSA_AGEND_BANCOOB', 4);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS123', 6);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS145', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS145', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS145', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS145', 6);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS172', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS172', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS172', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS172', 6);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS268', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS268', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS268', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS268', 6);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS439', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS439', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS439', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS439', 6);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS509', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS509', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS509', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS509', 7);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS509_PRIORI', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS509_PRIORI', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS509_PRIORI', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS509_PRIORI', 7);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS642', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS642', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS642', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS642', 5);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS642_PRIORI', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS642_PRIORI', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS642_PRIORI', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS642_PRIORI', 5);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS654', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS654', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS654', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS654', 6);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS663', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS663', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS663', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS663', 5);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS674', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS674', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS674', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS674', 6);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS688', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS688', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS688', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS688', 6);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS724', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS724', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS724', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS724', 6);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS750', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS750', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS750', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS750', 6);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA', 6);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('TARI0001.PC_DEB_TARIFA_PEND', 1);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('TARI0001.PC_DEB_TARIFA_PEND', 2);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('TARI0001.PC_DEB_TARIFA_PEND', 3);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('TARI0001.PC_DEB_TARIFA_PEND', 6);

COMMIT;

--CRIA JOBS DOS HORARIOS PARA AS COOPERATIVAS
BEGIN
  gen_debitador_unico.pc_job_debitador_unico(pr_idhora_processamento => 1
                                            ,pr_idtipo_operacao      => 'I'); 
END;
/
BEGIN
  gen_debitador_unico.pc_job_debitador_unico(pr_idhora_processamento => 2
                                            ,pr_idtipo_operacao      => 'I'); 
END;
/
BEGIN
  gen_debitador_unico.pc_job_debitador_unico(pr_idhora_processamento => 3
                                            ,pr_idtipo_operacao      => 'I'); 
END;
/
BEGIN
  gen_debitador_unico.pc_job_debitador_unico(pr_idhora_processamento => 4
                                            ,pr_idtipo_operacao      => 'I'); 
END;
/
BEGIN
  gen_debitador_unico.pc_job_debitador_unico(pr_idhora_processamento => 5
                                            ,pr_idtipo_operacao      => 'I'); 
END;
/
BEGIN
  gen_debitador_unico.pc_job_debitador_unico(pr_idhora_processamento => 6
                                            ,pr_idtipo_operacao      => 'I'); 
END;
/
BEGIN
  gen_debitador_unico.pc_job_debitador_unico(pr_idhora_processamento => 7
                                            ,pr_idtipo_operacao      => 'I'); 
END;
/
COMMIT;
