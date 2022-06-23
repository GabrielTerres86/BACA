BEGIN
INSERT INTO tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
VALUES
('STATUS_ANALISE_PIX_RECEBIDO', 1, 'Aguardando análise');
INSERT INTO tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
VALUES
('STATUS_ANALISE_PIX_RECEBIDO', 2, 'Recebimento liberado');
INSERT INTO tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
VALUES
('STATUS_ANALISE_PIX_RECEBIDO', 3, 'Recebimento bloqueado para analise');
INSERT INTO tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
VALUES
('STATUS_ANALISE_PIX_RECEBIDO', 4, 'Recebimento rejeitado aguardando devolução');
INSERT INTO tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
VALUES
('STATUS_ANALISE_PIX_RECEBIDO', 5, 'Recebimento rejeitado, transação devolvida a origem');
INSERT INTO tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
VALUES
('STATUS_ANALISE_PIX_RECEBIDO', 6, 'Liberado por expiração do tempo de análise');
INSERT INTO tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
VALUES
('STATUS_ANALISE_PIX_RECEBIDO', 7, 'Não enviado por falta de informações');
COMMIT;
END;