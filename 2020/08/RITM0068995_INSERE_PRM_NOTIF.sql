/* TELA ENVNOT */
INSERT INTO tbgen_notif_params (cdacesso, dsparametro, dsvalor) VALUES ('QTD_LINHAS_QBR_ARQ', 'Quantidade de linhas para efetuar a quebra do arquivo', 50000);
INSERT INTO tbgen_notif_params (cdacesso, dsparametro, dsvalor) VALUES ('QTD_PUSHS_LOTE', 'Quantidade de pushs enviados em cada lote', 30000);
INSERT INTO tbgen_notif_params (cdacesso, dsparametro, dsvalor) VALUES ('INTERV_TEMPO_LOTE', 'Intervalo de tempo de envio de cada lote em minutos', 15);
INSERT INTO tbgen_notif_params (cdacesso, dsparametro, dsvalor) VALUES ('HRFIM_ENV_PUSH', 'Horário final de envio de push em segundos', 78900);
INSERT INTO tbgen_notif_params (cdacesso, dsparametro, dsvalor) VALUES ('HRINI_ENV_PUSH', 'Horário de início de envio de push em segundos', 32400);
INSERT INTO tbgen_notif_params (cdacesso, dsparametro, dsvalor) VALUES ('TAM_SUFIX_ARQ', 'Tamanho do sufixo dos arquivos quebrados', 3);
INSERT INTO tbgen_notif_params (cdacesso, dsparametro, dsvalor) VALUES ('DHULT_EXEC_ENV_PUSH', 'Data hora da última execução de envio de push', to_char(SYSDATE-1, 'dd/mm/rrrr hh24:mi:ss'));
INSERT INTO tbgen_notif_params (cdacesso, dsparametro, dsvalor) VALUES ('QTD_MAX_PUSH_AYMARU', 'Quantidade máxima de pushs enviados por lote para o Aymaru', 500);
INSERT INTO tbgen_notif_msg_situacao (cdsituacao_mensagem, dssituacao_mensagem) VALUES (4, 'Com Erros');

/* TELA PARBAN */
INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED', 0, 'PARBAN_QTD_LINH_QBR_ARQ', 'Quantidade de linhas para efetuar a quebra do arquivo na tela PARBAN', 50000);
INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED', 0, 'PARBAN_TAM_SUFIX_ARQ', 'Tamanho do sufixo dos arquivos quebrados na tela PARBAN', 3);

COMMIT;
