--Validados
--Retorno
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 0, 'QT_REG_JOBRETORNOBO', 'Quantidade de registros minimo para gerar Jobs de retorno de remessas de baixa operacional em paralelo', '200', NULL);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 0, 'QT_JOBS_RETORNOBO', 'Quantidade máxima de Jobs executados em paralelo no retorno da baixa operacional', '5', NULL);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 0, 'QT_COMMIT_RMSRETORNOBO', 'Quantidade de registro para commitar no processo de consultar o retorno remessa da baixa operacional', '25', NULL);

--Remessa Aimaro
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 0, 'QT_REG_JOB_RMSBO_AIMARO', 'Quantidade de registros minimo para gerar Jobs para geracao de remessas de baixas operacionais - AIMARO', '50', NULL);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 0, 'QT_JOB_PAR_RMSBO_AIMARO', 'Quantidade máxima de Jobs executados em paralelo na geracao de remessas de baixas operacionais - AIMARO', '5', NULL);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 0, 'QT_COMMIT_RMSBO_AIMARO', 'Quantidade de registro para commitar após o envio da remessa da baixa operacional', '5', NULL);

--Remessa Aimaro Contingencia
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 0, 'QT_REG_JOB_RMSBO_AIM_CTG', 'Quantidade de registros minimo para gerar Jobs para geracao de remessas de baixas operacionais em contingencia - AIMARO (montarJobRemessaBoAimaroCtg)', '50', NULL);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 0, 'QT_JOB_PAR_RMSBO_AIM_CTG', 'Quantidade máxima de Jobs executados em paralelo na geracao de remessas de baixas operacionais em contingencia - AIMARO (montarJobRemessaBoAimaroCtg)', '5', NULL);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 0, 'QT_COMMIT_RMSBO_AIM_CTG', 'Quantidade de registro para commitar após o envio da remessa da baixa operacional em contingencia - AIMARO (consumirJobRmsBoAimaroCtg)', '5', NULL);

--Remessa JDNPC
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 0, 'QT_REG_JOB_RMSBO_JDNPC', 'Quantidade de registros minimo para gerar Jobs em paralelo na baixa operacional para a JDNPC', '200', NULL);

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 0, 'QT_JOB_PAR_RMSBO_JDNCP', 'Quantidade máxima de Jobs executados em paralelo na baixa operacional para o processo de envio da remessa para a JDNPC', '5', NULL);

--Adicionar nomes das procs nos comentarios

COMMIT;

