--PROGRAMAS/PRIORIDADES
insert into TBGEN_DEBITADOR_PARAM (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE)
values ('PC_CRPS750', 'PAGAMENTOS DAS PARCELAS DE EMPRÉSTIMOS (TR E PP)', 'N', 'S', null, 1);

insert into TBGEN_DEBITADOR_PARAM (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE)
values ('PC_CRPS724', 'PAGAR AS PARCELAS DOS CONTRATOS DO PRODUTO POS-FIXADO', 'N', 'S', null, 2);

insert into TBGEN_DEBITADOR_PARAM (CDPROCESSO, DSPROCESSO, INDEB_SEM_SALDO, INDEB_PARCIAL, QTDIAS_REPESCAGEM, NRPRIORIDADE)
values ('TARI0001.PC_DEB_TARIFA_PEND', 'COBRANCA DE TARIFAS PENDENTES', 'N', 'S', null, 3);

COMMIT;

--HORÁRIOS
insert into tbgen_debitador_horario (IDHORA_PROCESSAMENTO, DHPROCESSAMENTO)
values (1, to_date(To_Char(sysdate+1,'dd-mm-yyyy')||' 04:00:00', 'dd-mm-yyyy hh24:mi:ss'));

insert into tbgen_debitador_horario (IDHORA_PROCESSAMENTO, DHPROCESSAMENTO)
values (2, to_date(To_Char(sysdate+1,'dd-mm-yyyy')||' 11:00:00', 'dd-mm-yyyy hh24:mi:ss'));

insert into tbgen_debitador_horario (IDHORA_PROCESSAMENTO, DHPROCESSAMENTO)
values (3, to_date(To_Char(sysdate+1,'dd-mm-yyyy')||' 17:00:00', 'dd-mm-yyyy hh24:mi:ss'));

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
