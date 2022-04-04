BEGIN
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('0','Transacao OK',1,'Teste de Conexão');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('1','Transacao Registrada',2,'Pendente');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('2','Transacao Pendente',2,'Pendente');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('3','Transacao Confirmada',3,'Concluída');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('4','Transacao Confirmada por meio de resolucao de pendencias',3,'Concluída');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('5','Transacao Confirmada por meio de sonda',3,'Concluída');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('9','Transacao Concluida',	3,'Concluída');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('13','Transacao Desfeita Internamente',4,'Desfeita');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('6','Transacao Desfeita',4,'Desfeita');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('7','Transacao Desfeita por meio de resolucao de pendencias',4,'Desfeita');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('8','Transacao Desfeita por meio de sonda',4,'Desfeita');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('12','Transacao Desfeita pela sonda interna do sistema de captura',4,'Desfeita');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('10','Transacao Negada pelo autorizador',5,'Rejeitada');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('11','Transacao Negada pelo sistema de captura',5,'Rejeitada');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('17','Transacao Negada por suspeita de fraude',6,'Rejeitada Suspeita de Fraude');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('14','Transacao Pendente de Processamento',7,'Processamento');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('15','Transacao Processada',7,'Processamento');
    INSERT INTO TAA.TBTAA_SEP_OPERACAO_STATUS VALUES('16','Transacao em Processamento',7,'Processamento');

    COMMIT;
END;