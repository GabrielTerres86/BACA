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
  FOR r_job_debitador IN u_job_debitador(p_like_nm_job => '%JBDEB%UNI%') LOOP
    dbms_output.put_line('r_job_debitador.job_nam: '||r_job_debitador.job_name);
    dbms_scheduler.drop_job(job_name => r_job_debitador.owner||'.'||r_job_debitador.job_name);    
  END LOOP;
end; 
/
commit;


DELETE TBGEN_DEBITADOR_HORARIO_PROC;
COMMIT;

DELETE TBGEN_DEBITADOR_PARAM;
COMMIT;

DELETE TBGEN_DEBITADOR_HORARIO;
COMMIT;

DELETE TBGEN_DEBITADOR_HISTORICO;
COMMIT;

--PROGRAMAS/PRIORIDADES
insert into TBGEN_DEBITADOR_PARAM (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS750', 'PAGAMENTOS DAS PARCELAS DE EMPRÉSTIMOS (TR E PP)', 'N', 'S', null, 1, 'S', 3);

insert into TBGEN_DEBITADOR_PARAM (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS724', 'PAGAR AS PARCELAS DOS CONTRATOS DO PRODUTO POS-FIXADO', 'N', 'S', null, 2, 'S', 0);

insert into TBGEN_DEBITADOR_PARAM (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB', 'EFETIVAR LANCAMENTO PENDENTE MULTA/JUROS TR CONTRATOS EMP/FINANC POS-FIXADA', 'N', 'N', null, 3, 'N', 0);

insert into TBGEN_DEBITADOR_PARAM (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS674', 'DEBITO DE FATURA - LANCAMENTO DE DEBITO AUTOMATICO - BANCOOB/CABAL', 'N', 'S', 1, 4, 'N', 2);

insert into TBGEN_DEBITADOR_PARAM (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS268', 'DEBITO EM CONTA REFERENTE SEGURO DE VIDA EM GRUPO', 'S', 'N', null, 5, 'N', 0);

insert into TBGEN_DEBITADOR_PARAM (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('PC_CRPS439', 'DEBITO DIARIO DO SEGURO', 'S', 'N', null, 6, 'S', 0);

insert into TBGEN_DEBITADOR_PARAM (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE, INEXEC_CADEIA_NOTURNA, INCONTROLE_EXEC_PROG)
values ('TARI0001.PC_DEB_TARIFA_PEND', 'COBRANCA DE TARIFAS PENDENTES', 'N', 'S', null, 7, 'N', 1);

COMMIT;

--HORÁRIOS
insert into tbgen_debitador_horario (IDHORA_PROCESSAMENTO, DHPROCESSAMENTO)
values (1, to_date(To_Char(sysdate+1,'dd-mm-yyyy')||' 07:00:00', 'dd-mm-yyyy hh24:mi:ss'));

insert into tbgen_debitador_horario (IDHORA_PROCESSAMENTO, DHPROCESSAMENTO)
values (2, to_date(To_Char(sysdate+1,'dd-mm-yyyy')||' 12:30:00', 'dd-mm-yyyy hh24:mi:ss'));

insert into tbgen_debitador_horario (IDHORA_PROCESSAMENTO, DHPROCESSAMENTO)
values (3, to_date(To_Char(sysdate+1,'dd-mm-yyyy')||' 15:30:00', 'dd-mm-yyyy hh24:mi:ss'));

insert into tbgen_debitador_horario (IDHORA_PROCESSAMENTO, DHPROCESSAMENTO)
values (4, to_date(To_Char(sysdate+1,'dd-mm-yyyy')||' 21:00:00', 'dd-mm-yyyy hh24:mi:ss'));

COMMIT;

--HORÁRIOS DOS PROGRAMAS
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS750', 1);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS750', 2);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS750', 3);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS750', 4);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS724', 1);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS724', 2);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS724', 3);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS724', 4);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB', 1);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB', 2);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB', 3);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB', 4);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS674', 1);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS674', 2);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS674', 3);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS674', 4);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS268', 1);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS268', 2);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS268', 3);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS268', 4);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS439', 1);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS439', 2);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS439', 3);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('PC_CRPS439', 4);

insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('TARI0001.PC_DEB_TARIFA_PEND', 1);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('TARI0001.PC_DEB_TARIFA_PEND', 2);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('TARI0001.PC_DEB_TARIFA_PEND', 3);
insert into tbgen_debitador_horario_proc (CDPROCESSO, IDHORA_PROCESSAMENTO)
values ('TARI0001.PC_DEB_TARIFA_PEND', 4);

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

COMMIT;
