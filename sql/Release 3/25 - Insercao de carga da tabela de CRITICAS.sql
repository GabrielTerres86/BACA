-- PAGADOR
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (1,'Qtd Remessa em Cartório acima do permitido',1);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (2,'Qtd de Títulos Protestados acima do permitido',1);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (3,'Qtd de Títulos Não Pagos pelo Pagador acima do permitido',1);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (4,'Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Qtd. de Títulos).',1);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (5,'Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Valor dos Títulos)',1);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (6,'Perc. Concentração Máxima Permitida de Títulos excedida',1);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (7,'Emitente é Cônjuge/Sócio do Pagador',1);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (8,'Cooperado possui Títulos Descontados na Conta deste Pagador',1);
-- TITULO
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (9,'Valor Máximo Permitido por CNAE excedido',3);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (10,'Tit. não possui instr. de protesto e/ou negativação',3);
-- CEDENTE
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (11,'Quantidade de Titulos protestados acima do permitido (carteira cooperado)',4);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (12,'Coop com titulos não pagos acima do permitido',4);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (13,'Perc. de Tit. com Mínimo de Liquidez de Títulos Geral do Cedente abaixo do permitido. (Qtd. de Títulos)',4);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (14,'Perc. de Tit. com Mínimo de Liquidez de Títulos Geral do Cedente abaixo do permitido. (Valor dos Títulos)',4);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (15,'Valores utilizados excedidos',4);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (16,'Valor Legal Excedido',4;
-- BORDERO	
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (17,'Quantidade de títulos por borderô excedido',2);
-- Nao Critica
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (18,'Concentração',0);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (19,'Liquidez Cedente Pagador',0);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (20,'Liquidez Geral',0);

