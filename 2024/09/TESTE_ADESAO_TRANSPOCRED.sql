BEGIN
INSERT INTO tbtarif_contas_pacote (cdcooper,nrdconta,cdpacote,dtadesao,dtinicio_vigencia,nrdiadebito,indorigem,flgsituacao,cdoperador_adesao)
                                 VALUES (9,99716879,240,SYSDATE,(SYSDATE + 1),5,1,1,'F0033201');
INSERT INTO tbtarif_contas_pacote (cdcooper,nrdconta,cdpacote,dtadesao,dtinicio_vigencia,nrdiadebito,indorigem,flgsituacao,cdoperador_adesao)
                                 VALUES (9,99716763,240,SYSDATE,(SYSDATE + 1),5,1,1,'F0033201');
INSERT INTO tbtarif_contas_pacote (cdcooper,nrdconta,cdpacote,dtadesao,dtinicio_vigencia,nrdiadebito,indorigem,flgsituacao,cdoperador_adesao)
                                 VALUES (9,99715791,241,SYSDATE,(SYSDATE + 1),5,1,1,'F0033201');
INSERT INTO tbtarif_contas_pacote (cdcooper,nrdconta,cdpacote,dtadesao,dtinicio_vigencia,nrdiadebito,indorigem,flgsituacao,cdoperador_adesao)
                                 VALUES (9,99713721,241,SYSDATE,(SYSDATE + 1),5,1,1,'F0033201');
COMMIT;
END;