BEGIN
INSERT INTO tbtarif_contas_pacote (cdcooper,nrdconta,cdpacote,dtadesao,dtinicio_vigencia,nrdiadebito,indorigem,flgsituacao,cdoperador_adesao)
                                 VALUES (9,99724944,240,TRUNC(SYSDATE),(SYSDATE + 1),5,1,1,'F0033201');
INSERT INTO tbtarif_contas_pacote (cdcooper,nrdconta,cdpacote,dtadesao,dtinicio_vigencia,nrdiadebito,indorigem,flgsituacao,cdoperador_adesao)
                                 VALUES (9,99700247,240,TRUNC(SYSDATE),(SYSDATE + 1),5,1,1,'F0033201');
INSERT INTO tbtarif_contas_pacote (cdcooper,nrdconta,cdpacote,dtadesao,dtinicio_vigencia,nrdiadebito,indorigem,flgsituacao,cdoperador_adesao)
                                 VALUES (9,99698625,241,TRUNC(SYSDATE),(SYSDATE + 1),5,1,1,'F0033201');
INSERT INTO tbtarif_contas_pacote (cdcooper,nrdconta,cdpacote,dtadesao,dtinicio_vigencia,nrdiadebito,indorigem,flgsituacao,cdoperador_adesao)
                                 VALUES (9,99697343,241,TRUNC(SYSDATE),(SYSDATE + 1),5,1,1,'F0033201');
COMMIT;
END;

