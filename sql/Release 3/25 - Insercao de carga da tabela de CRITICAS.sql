-- PAGADOR
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (1,'Qtd Remessa em Cartorio acima do permitido',1);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (2,'Qtd de Titulos Protestados acima do permitido',1);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (3,'Qtd de Titulos Nao Pagos pelo Pagador acima do permitido',1);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (4,'Perc. Minimo de Liquidez Cedente x Pagador abaixo do permitido (Qtd. de Titulos).',1);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (5,'Perc. Minimo de Liquidez Cedente x Pagador abaixo do permitido (Valor dos Titulos)',1);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (6,'Perc. Concentracao Maxima Permitida de Titulos excedida',1);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (7,'Emitente e Conjuge/Socio do Pagador',1);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (8,'Cooperado possui Titulos Descontados na Conta deste Pagador',1);
-- TITULO
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (9,'Valor Maximo Permitido por CNAE excedido',3);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (10,'Tit. nao possui instr. de protesto e/ou negativacao',3);
-- CEDENTE
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (11,'Quantidade de Titulos protestados acima do permitido (carteira cooperado)',4);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (12,'Coop com titulos nao pagos acima do permitido',4);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (13,'Perc. de Tit. com Minimo de Liquidez de Titulos Geral do Cedente abaixo do permitido. (Qtd. de Titulos)',4);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (14,'Perc. de Tit. com Minimo de Liquidez de Titulos Geral do Cedente abaixo do permitido. (Valor dos Titulos)',4);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (15,'Valores utilizados excedidos',4);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (16,'Valor Legal Excedidoo',4;
-- BORDERO	
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (17,'Quantidade de titulos por bordero excedido',2);
-- Nao Critica
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (18,'Concentracao',0);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (19,'Liquidez Cedente Pagador',0);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (20,'Liquidez Geral',0);
INSERT INTO tbdsct_criticas (cdcritica,dscritica,tpcritica) VALUES (21,'Pagador Possui Restricoes',0);

