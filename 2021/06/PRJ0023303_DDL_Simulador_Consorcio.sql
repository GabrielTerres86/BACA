insert into tbconsor_tipotaxa values (1, 'Taxa Administrativa');
insert into tbconsor_tipotaxa values (2, 'Fundo de Reserva');
commit;
insert into tbconsor_taxa values (1,1,11,1);
insert into tbconsor_taxa values (2,1,12,1);
insert into tbconsor_taxa values (3,1,15,1);
insert into tbconsor_taxa values (4,1,16,1);
insert into tbconsor_taxa values (5,1,18,1);
insert into tbconsor_taxa values (6,2,3,1);
insert into tbconsor_taxa values (7,2,4,1);
insert into tbconsor_taxa values (8,1,10,1);
insert into tbconsor_taxa values (9,1,14,1);
insert into tbconsor_taxa values (10,2,2,1);
insert into tbconsor_taxa values (11,2,2.5,1);

commit;

insert into TBCONSOR_SEGMENTO values (1,'Motos',0.0552,1,1);
insert into TBCONSOR_SEGMENTO values (2,'Autos',0.0552,1,1);
insert into TBCONSOR_SEGMENTO values (3,'Pesados',0.0552,1,1);
insert into TBCONSOR_SEGMENTO values (4,'Náuticos',0.0552,1,1);
insert into TBCONSOR_SEGMENTO values (5,'Serviço',0.0552,1,0);
insert into TBCONSOR_SEGMENTO values (6,'Moveis Planejado',0.0552,1,0);
insert into TBCONSOR_SEGMENTO values (7,'Sustentaveis',0.0552,1,0);
insert into TBCONSOR_SEGMENTO values (8,'Imoveis',0.0450,1,0);
commit;
insert into TBCONSOR_PLANO values (1,60,1,1,'Moto 60 meses');
insert into TBCONSOR_PLANO values (2,48,2,1,'Carro 48 meses');
insert into TBCONSOR_PLANO values (3,60,2,1,'Carro 60 meses');
insert into TBCONSOR_PLANO values (4,75,2,1,'Carro 75 meses');
insert into TBCONSOR_PLANO values (5,100,2,1,'Carro 100 meses');
insert into TBCONSOR_PLANO values (6,100,3,1,'Pesados 100 meses');
insert into TBCONSOR_PLANO values (7,120,3,1,'Pesados 120 meses');
insert into TBCONSOR_PLANO values (8,48,4,1,'Náutico 48 meses');
insert into TBCONSOR_PLANO values (9,60,4,1,'Náutico 60 meses cartas de R$ 10.048,00 à R$ 23.582,00');
insert into TBCONSOR_PLANO values (10,75,4,1,'Náutico 75 meses');
insert into TBCONSOR_PLANO values (11,48,5,0,'Serviço 48 meses');
insert into TBCONSOR_PLANO values (12,36,5,1,'Serviço 36 meses');
insert into TBCONSOR_PLANO values (13,48,6,1,'Móveis Planejados 48 meses');
insert into TBCONSOR_PLANO values (14,48,7,1,'Sustentáveis 48 meses');
insert into TBCONSOR_PLANO values (15,60,7,1,'Sustentáveis 60 meses cartas R$ 9.200,00 até R$ 26.867,00');
insert into TBCONSOR_PLANO values (16,75,7,1,'Sustentáveis 75 meses');
insert into TBCONSOR_PLANO values (17,100,7,1,'Sustentáveis 100 meses');
insert into TBCONSOR_PLANO values (18,180,8,1,'Imóveis 180 meses cartas R$ 55.000,00 até R$ 110.000,00');
insert into TBCONSOR_PLANO values (19,180,8,1,'Imóveis 180 meses cartas R$ 110.001,00 até R$ 600.000,00');
insert into TBCONSOR_PLANO values (20,36,6,0,'Móveis Planejados 36 meses');
--insert into TBCONSOR_PLANO values (21,75,6,1,'Imoveis 75 meses');
insert into TBCONSOR_PLANO values (22,60,7,1,'Sustentáveis 60 meses cartas R$ 27.500,00 à R$ 53.590,00');
insert into TBCONSOR_PLANO values (23,60,4,1,'Náutico 60 meses cartas R$ R$ 27.500,00 à R$ 53.590,00');
insert into TBCONSOR_PLANO values (24,100,4,1,'Náutico 100 meses');
commit;
insert into TBCONSOR_TIPOBEM values (1, 'Carta de R$ 5.000,00'  , 5000  ,1);
insert into TBCONSOR_TIPOBEM values (2, 'Carta de R$ 6.000,00'  , 6000  ,1);
insert into TBCONSOR_TIPOBEM values (3, 'Carta de R$ 7.000,00'  , 7000  ,1);
insert into TBCONSOR_TIPOBEM values (4, 'Carta de R$ 8.000,00'  , 8000  ,1);
insert into TBCONSOR_TIPOBEM values (5, 'Carta de R$ 9.000,00'  , 9000  ,1);
insert into TBCONSOR_TIPOBEM values (6, 'Carta de R$ 9.200,00'  , 9200  ,1);
insert into TBCONSOR_TIPOBEM values (7, 'Carta de R$ 10.000,00' , 10000 ,1);
insert into TBCONSOR_TIPOBEM values (8, 'Carta de R$ 10.048,00' , 10048 ,1);
insert into TBCONSOR_TIPOBEM values (9, 'Carta de R$ 11.780,00' , 11780 ,1);
insert into TBCONSOR_TIPOBEM values (10, 'Carta de R$ 12.000,00' , 12000 ,1);
insert into TBCONSOR_TIPOBEM values (11, 'Carta de R$ 12.483,00' , 12483 ,1);
insert into TBCONSOR_TIPOBEM values (12, 'Carta de R$ 13.113,00' , 13113 ,1);
insert into TBCONSOR_TIPOBEM values (13, 'Carta de R$ 13.210,00' , 13210 ,1);
insert into TBCONSOR_TIPOBEM values (14, 'Carta de R$ 14.000,00' , 14000 ,1);
insert into TBCONSOR_TIPOBEM values (15, 'Carta de R$ 14.100,00' , 14100 ,1);
insert into TBCONSOR_TIPOBEM values (16, 'Carta de R$ 15.000,00' , 15000 ,1);
insert into TBCONSOR_TIPOBEM values (17, 'Carta de R$ 15.990,00' , 15990 ,1);
insert into TBCONSOR_TIPOBEM values (18, 'Carta de R$ 16.000,00' , 16000 ,1);
insert into TBCONSOR_TIPOBEM values (19, 'Carta de R$ 16.160,00' , 16160 ,1);
insert into TBCONSOR_TIPOBEM values (20, 'Carta de R$ 16.344,00' , 16344 ,1);
insert into TBCONSOR_TIPOBEM values (21, 'Carta de R$ 17.990,00' , 17990 ,1);
insert into TBCONSOR_TIPOBEM values (22, 'Carta de R$ 18.000,00' , 18000 ,1);
insert into TBCONSOR_TIPOBEM values (23, 'Carta de R$ 20.000,00' , 20000 ,1);
insert into TBCONSOR_TIPOBEM values (24, 'Carta de R$ 20.922,00' , 20922 ,1);
insert into TBCONSOR_TIPOBEM values (25, 'Carta de R$ 21.000,00' , 21000 ,1);
insert into TBCONSOR_TIPOBEM values (26, 'Carta de R$ 22.000,00' , 22000 ,1);
insert into TBCONSOR_TIPOBEM values (27, 'Carta de R$ 23.582,00' , 23582 ,1);
insert into TBCONSOR_TIPOBEM values (28, 'Carta de R$ 24.000,00' , 24000 ,1);
insert into TBCONSOR_TIPOBEM values (29, 'Carta de R$ 24.170,00' , 24170 ,1);
insert into TBCONSOR_TIPOBEM values (30, 'Carta de R$ 27.000,00' , 27000 ,1);
insert into TBCONSOR_TIPOBEM values (31, 'Carta de R$ 27.500,00' , 27500 ,1);
insert into TBCONSOR_TIPOBEM values (32, 'Carta de R$ 29.772,00' , 29772 ,1);
insert into TBCONSOR_TIPOBEM values (33, 'Carta de R$ 30.000,00' , 30000 ,1);
insert into TBCONSOR_TIPOBEM values (34, 'Carta de R$ 32.792,00' , 32792 ,1);
insert into TBCONSOR_TIPOBEM values (35, 'Carta de R$ 39.490,00' , 39490 ,1);
insert into TBCONSOR_TIPOBEM values (36, 'Carta de R$ 40.990,00' , 40990 ,1);
insert into TBCONSOR_TIPOBEM values (37, 'Carta de R$ 45.000,00' , 45000 ,1);
insert into TBCONSOR_TIPOBEM values (38, 'Carta de R$ 48.141,00' , 48141 ,1);
insert into TBCONSOR_TIPOBEM values (39, 'Carta de R$ 50.000,00' , 50000 ,1);
insert into TBCONSOR_TIPOBEM values (40, 'Carta de R$ 53.590,00' , 53590 ,1);
insert into TBCONSOR_TIPOBEM values (41, 'Carta de R$ 55.000,00' , 55000 ,1);
insert into TBCONSOR_TIPOBEM values (42, 'Carta de R$ 60.000,00' , 60000 ,1);
insert into TBCONSOR_TIPOBEM values (43, 'Carta de R$ 60.990,00' , 60990 ,1);
insert into TBCONSOR_TIPOBEM values (44, 'Carta de R$ 65.290,00' , 65290 ,1);
insert into TBCONSOR_TIPOBEM values (45, 'Carta de R$ 70.000,00' , 70000 ,1);
insert into TBCONSOR_TIPOBEM values (46, 'Carta de R$ 80.000,00' , 80000 ,1);
insert into TBCONSOR_TIPOBEM values (47, 'Carta de R$ 81.690,00' , 81690 ,1);
insert into TBCONSOR_TIPOBEM values (48, 'Carta de R$ 85.000,00' , 85000 ,1);
insert into TBCONSOR_TIPOBEM values (49, 'Carta de R$ 87.490,00' , 87490 ,1);
insert into TBCONSOR_TIPOBEM values (50, 'Carta de R$ 90.000,00' , 90000 ,1);
insert into TBCONSOR_TIPOBEM values (51, 'Carta de R$ 100.000,00'  , 100000  ,1);
insert into TBCONSOR_TIPOBEM values (52, 'Carta de R$ 110.000,00'  , 110000  ,1);
insert into TBCONSOR_TIPOBEM values (53, 'Carta de R$ 120.000,00'  , 120000  ,1);
insert into TBCONSOR_TIPOBEM values (54, 'Carta de R$ 125.000,00'  , 125000  ,1);
insert into TBCONSOR_TIPOBEM values (55, 'Carta de R$ 126.300,00'  , 126300  ,1);
insert into TBCONSOR_TIPOBEM values (56, 'Carta de R$ 129.190,00'  , 129190  ,1);
insert into TBCONSOR_TIPOBEM values (57, 'Carta de R$ 130.000,00'  , 130000  ,1);
insert into TBCONSOR_TIPOBEM values (58, 'Carta de R$ 140.000,00'  , 140000  ,1);
insert into TBCONSOR_TIPOBEM values (59, 'Carta de R$ 149.015,00'  , 149015  ,1);
insert into TBCONSOR_TIPOBEM values (60, 'Carta de R$ 150.000,00'  , 150000  ,1);
insert into TBCONSOR_TIPOBEM values (61, 'Carta de R$ 160.000,00'  , 160000  ,1);
insert into TBCONSOR_TIPOBEM values (62, 'Carta de R$ 168.000,00'  , 168000  ,1);
insert into TBCONSOR_TIPOBEM values (63, 'Carta de R$ 170.000,00'  , 170000  ,1);
insert into TBCONSOR_TIPOBEM values (64, 'Carta de R$ 171.540,23'  , 171540  ,1);
insert into TBCONSOR_TIPOBEM values (65, 'Carta de R$ 175.400,00'  , 175400  ,1);
insert into TBCONSOR_TIPOBEM values (66, 'Carta de R$ 180.000,00'  , 180000  ,1);
insert into TBCONSOR_TIPOBEM values (67, 'Carta de R$ 190.000,00'  , 190000  ,1);
insert into TBCONSOR_TIPOBEM values (68, 'Carta de R$ 190.097,00'  , 190097  ,1);
insert into TBCONSOR_TIPOBEM values (69, 'Carta de R$ 197.931,03'  , 197931  ,1);
insert into TBCONSOR_TIPOBEM values (70, 'Carta de R$ 198.666,00'  , 198666  ,1);
insert into TBCONSOR_TIPOBEM values (71, 'Carta de R$ 198.990,00'  , 198990  ,1);
insert into TBCONSOR_TIPOBEM values (72, 'Carta de R$ 200.000,00'  , 200000  ,1);
insert into TBCONSOR_TIPOBEM values (73, 'Carta de R$ 210.000,00'  , 210000  ,1);
insert into TBCONSOR_TIPOBEM values (74, 'Carta de R$ 215.000,00'  , 215000  ,1);
insert into TBCONSOR_TIPOBEM values (75, 'Carta de R$ 220.000,00'  , 220000  ,1);
insert into TBCONSOR_TIPOBEM values (76, 'Carta de R$ 230.000,00'  , 230000  ,1);
insert into TBCONSOR_TIPOBEM values (77, 'Carta de R$ 240.000,00'  , 240000  ,1);
insert into TBCONSOR_TIPOBEM values (78, 'Carta de R$ 247.318,00'  , 247318  ,1);
insert into TBCONSOR_TIPOBEM values (79, 'Carta de R$ 250.000,00'  , 250000  ,1);
insert into TBCONSOR_TIPOBEM values (80, 'Carta de R$ 260.000,00'  , 260000  ,1);
insert into TBCONSOR_TIPOBEM values (81, 'Carta de R$ 270.000,00'  , 270000  ,1);
insert into TBCONSOR_TIPOBEM values (82, 'Carta de R$ 276.418,00'  , 276418  ,1);
insert into TBCONSOR_TIPOBEM values (83, 'Carta de R$ 280.000,00'  , 280000  ,1);
insert into TBCONSOR_TIPOBEM values (84, 'Carta de R$ 290.000,00'  , 290000  ,1);
insert into TBCONSOR_TIPOBEM values (85, 'Carta de R$ 300.000,00'  , 300000  ,1);
insert into TBCONSOR_TIPOBEM values (86, 'Carta de R$ 310.000,00'  , 310000  ,1);
insert into TBCONSOR_TIPOBEM values (87, 'Carta de R$ 320.000,00'  , 320000  ,1);
insert into TBCONSOR_TIPOBEM values (88, 'Carta de R$ 330.000,00'  , 330000  ,1);
insert into TBCONSOR_TIPOBEM values (89, 'Carta de R$ 336.100,00'  , 336100  ,1);
insert into TBCONSOR_TIPOBEM values (90, 'Carta de R$ 339.100,00'  , 339100  ,1);
insert into TBCONSOR_TIPOBEM values (91, 'Carta de R$ 340.000,00'  , 340000  ,1);
insert into TBCONSOR_TIPOBEM values (92, 'Carta de R$ 346.700,00'  , 346700  ,1);
insert into TBCONSOR_TIPOBEM values (93, 'Carta de R$ 350.000,00'  , 350000  ,1);
insert into TBCONSOR_TIPOBEM values (94, 'Carta de R$ 360.000,00'  , 360000  ,1);
insert into TBCONSOR_TIPOBEM values (95, 'Carta de R$ 370.000,00'  , 370000  ,1);
insert into TBCONSOR_TIPOBEM values (96, 'Carta de R$ 380.000,00'  , 380000  ,1);
insert into TBCONSOR_TIPOBEM values (97, 'Carta de R$ 390.000,00'  , 390000  ,1);
insert into TBCONSOR_TIPOBEM values (98, 'Carta de R$ 400.000,00'  , 400000  ,1);
insert into TBCONSOR_TIPOBEM values (99, 'Carta de R$ 410.000,00'  , 410000  ,1);
insert into TBCONSOR_TIPOBEM values (100, 'Carta de R$ 420.000,00'  , 420000  ,1);
insert into TBCONSOR_TIPOBEM values (101, 'Carta de R$ 430.000,00'  , 430000  ,1);
insert into TBCONSOR_TIPOBEM values (102, 'Carta de R$ 440.000,00'  , 440000  ,1);
insert into TBCONSOR_TIPOBEM values (103, 'Carta de R$ 440.200,00'  , 440200  ,1);
insert into TBCONSOR_TIPOBEM values (104, 'Carta de R$ 443.600,00'  , 443600  ,1);
insert into TBCONSOR_TIPOBEM values (105, 'Carta de R$ 450.000,00'  , 450000  ,1);
insert into TBCONSOR_TIPOBEM values (106, 'Carta de R$ 460.000,00'  , 460000  ,1);
insert into TBCONSOR_TIPOBEM values (107, 'Carta de R$ 470.000,00'  , 470000  ,1);
insert into TBCONSOR_TIPOBEM values (108, 'Carta de R$ 477.000,00'  , 477000  ,1);
insert into TBCONSOR_TIPOBEM values (109, 'Carta de R$ 480.000,00'  , 480000  ,1);
insert into TBCONSOR_TIPOBEM values (110, 'Carta de R$ 490.000,00'  , 490000  ,1);
insert into TBCONSOR_TIPOBEM values (111, 'Carta de R$ 500.000,00'  , 500000  ,1);
insert into TBCONSOR_TIPOBEM values (112, 'Carta de R$ 510.000,00'  , 510000  ,1);
insert into TBCONSOR_TIPOBEM values (113, 'Carta de R$ 520.000,00'  , 520000  ,1);
insert into TBCONSOR_TIPOBEM values (114, 'Carta de R$ 530.000,00'  , 530000  ,1);
insert into TBCONSOR_TIPOBEM values (115, 'Carta de R$ 540.000,00'  , 540000  ,1);
insert into TBCONSOR_TIPOBEM values (116, 'Carta de R$ 550.000,00'  , 550000  ,1);
insert into TBCONSOR_TIPOBEM values (117, 'Carta de R$ 551.400,00'  , 551400  ,1);
insert into TBCONSOR_TIPOBEM values (118, 'Carta de R$ 560.000,00'  , 560000  ,1);
insert into TBCONSOR_TIPOBEM values (119, 'Carta de R$ 570.000,00'  , 570000  ,1);
insert into TBCONSOR_TIPOBEM values (120, 'Carta de R$ 580.000,00'  , 580000  ,1);
insert into TBCONSOR_TIPOBEM values (121, 'Carta de R$ 590.000,00'  , 590000  ,1);
insert into TBCONSOR_TIPOBEM values (122, 'Carta de R$ 600.000,00'  , 600000  ,1);
commit;
insert into TBCONSOR_PLANO_taxa values (1,1,3);--Moto
insert into TBCONSOR_PLANO_taxa values (2,1,6);--Moto
insert into TBCONSOR_PLANO_taxa values (3,2,8);--Autor
insert into TBCONSOR_PLANO_taxa values (4,2,10);--Autor
insert into TBCONSOR_PLANO_taxa values (5,3,2);--Auto
insert into TBCONSOR_PLANO_taxa values (6,3,10);--Autor
insert into TBCONSOR_PLANO_taxa values (7,4,2);--Auto
insert into TBCONSOR_PLANO_taxa values (8,4,10);--Autor
insert into TBCONSOR_PLANO_taxa values (9,5,9);--Autor
insert into TBCONSOR_PLANO_taxa values (10,5,10);--Auto
insert into TBCONSOR_PLANO_taxa values (11,6,1);--Pesados
insert into TBCONSOR_PLANO_taxa values (12,6,11);--Pesadosr
insert into TBCONSOR_PLANO_taxa values (13,7,1);--Pesados
insert into TBCONSOR_PLANO_taxa values (14,7,11);--Pesadosr
insert into TBCONSOR_PLANO_taxa values (15,8,8);--Nautico
insert into TBCONSOR_PLANO_taxa values (16,8,10);--Nautico
insert into TBCONSOR_PLANO_taxa values (17,9,3);--Nautico
insert into TBCONSOR_PLANO_taxa values (18,9,6);--Nautico
insert into TBCONSOR_PLANO_taxa values (19,10,2);--Nautico
insert into TBCONSOR_PLANO_taxa values (20,10,10);--Nautico
insert into TBCONSOR_PLANO_taxa values (21,11,1);--Nautico
insert into TBCONSOR_PLANO_taxa values (22,11,11);--Nautico
insert into TBCONSOR_PLANO_taxa values (23,12,4);--Serviço
insert into TBCONSOR_PLANO_taxa values (24,12,6); --Serviço
insert into TBCONSOR_PLANO_taxa values (25,13,5);--Planejado
insert into TBCONSOR_PLANO_taxa values (26,13,6);--Planejador
insert into TBCONSOR_PLANO_taxa values (27,14,8);--Sustentaveisr
insert into TBCONSOR_PLANO_taxa values (28,14,10);--Sustentaveisr
insert into TBCONSOR_PLANO_taxa values (29,15,3);--Sustentaveis
insert into TBCONSOR_PLANO_taxa values (30,15,6);--Sustentaveis
insert into TBCONSOR_PLANO_taxa values (31,16,2);--Sustentaveis
insert into TBCONSOR_PLANO_taxa values (32,16,10);--Sustentaveis
insert into TBCONSOR_PLANO_taxa values (33,17,1);--Sustentaveis
insert into TBCONSOR_PLANO_taxa values (34,17,11);--Sustentaveis
insert into TBCONSOR_PLANO_taxa values (35,18,4);--Imoveis
insert into TBCONSOR_PLANO_taxa values (36,18,10);--Imoveis
insert into TBCONSOR_PLANO_taxa values (37,19,4);--Imoveis
insert into TBCONSOR_PLANO_taxa values (38,19,7);--Imoveis
insert into TBCONSOR_PLANO_taxa values (39,22,2);--Sustentaveis
insert into TBCONSOR_PLANO_taxa values (40,22,10);--Sustentaveis
insert into TBCONSOR_PLANO_taxa values (41,23,2);--Nautico
insert into TBCONSOR_PLANO_taxa values (42,23,10);--Nautico
insert into TBCONSOR_PLANO_taxa values (43,24,1);--Nautico
insert into TBCONSOR_PLANO_taxa values (44,24,11);--Nautico
commit;

insert into TBCONSOR_PLANO_TIPOBEM values (1,1,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 11.780,00' ));--Moto
insert into TBCONSOR_PLANO_TIPOBEM values (2,1,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 13.113,00' ));--Moto
insert into TBCONSOR_PLANO_TIPOBEM values (3,1,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 13.210,00' ));--Moto
insert into TBCONSOR_PLANO_TIPOBEM values (4,1,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 14.100,00' ));--Moto
insert into TBCONSOR_PLANO_TIPOBEM values (5,1,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 15.990,00' ));--Moto
insert into TBCONSOR_PLANO_TIPOBEM values (6,1,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 16.160,00' ));--Moto
insert into TBCONSOR_PLANO_TIPOBEM values (7,1,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 16.344,00' ));--Moto
insert into TBCONSOR_PLANO_TIPOBEM values (8,1,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 17.990,00' ));--Moto
insert into TBCONSOR_PLANO_TIPOBEM values (9,1,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 20.922,00' ));--Moto
insert into TBCONSOR_PLANO_TIPOBEM values (10,1,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 24.170,00' ));--Moto
insert into TBCONSOR_PLANO_TIPOBEM values (11,1,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 29.772,00' ));--Moto
commit;
insert into TBCONSOR_PLANO_TIPOBEM values (12,2,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 32.792,00' ));-- carro
insert into TBCONSOR_PLANO_TIPOBEM values (13,2,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 40.990,00' ));-- carro
insert into TBCONSOR_PLANO_TIPOBEM values (14,2,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 53.590,00' ));-- carro
insert into TBCONSOR_PLANO_TIPOBEM values (15,3,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 32.792,00' ));-- carro
insert into TBCONSOR_PLANO_TIPOBEM values (16,3,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 40.990,00' ));-- carro
insert into TBCONSOR_PLANO_TIPOBEM values (17,3,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 53.590,00' ));-- carro
insert into TBCONSOR_PLANO_TIPOBEM values (18,4,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 81.690,00' ));-- carro
insert into TBCONSOR_PLANO_TIPOBEM values (19,4,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 87.490,00' ));-- carro
insert into TBCONSOR_PLANO_TIPOBEM values (20,4,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 129.190,00' ));-- carro
insert into TBCONSOR_PLANO_TIPOBEM values (21,5,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 40.990,00' ));-- carro
insert into TBCONSOR_PLANO_TIPOBEM values (22,5,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 53.590,00' ));-- carro
insert into TBCONSOR_PLANO_TIPOBEM values (23,5,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 60.990,00' ));-- carro
insert into TBCONSOR_PLANO_TIPOBEM values (24,5,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 65.290,00' ));-- carro
commit;

insert into TBCONSOR_PLANO_TIPOBEM values (25,6,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 149.015,00'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (26,6,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 171.540,23'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (27,6,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 175.400,00'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (28,6,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 190.097,00'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (29,6,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 197.931,03'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (30,6,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 198.666,00'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (31,6,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 198.990,00'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (32,6,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 215.000,00'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (137,6,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 247.318,00'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (33,7,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 276.418,00'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (34,7,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 336.100,00'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (35,7,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 339.100,00'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (36,7,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 346.700,00'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (37,7,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 440.200,00'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (38,7,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 443.600,00'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (39,7,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 477.000,00'));-- Pesados
insert into TBCONSOR_PLANO_TIPOBEM values (40,7,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 551.400,00'));-- Pesados
commit;

insert into TBCONSOR_PLANO_TIPOBEM values (41,8,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 39.490,00' ));--nauticos
insert into TBCONSOR_PLANO_TIPOBEM values (42,8,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 48.141,00' ));--nauticos
insert into TBCONSOR_PLANO_TIPOBEM values (43,9,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 10.048,00' ));--nauticos
insert into TBCONSOR_PLANO_TIPOBEM values (44,9,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 12.483,00' ));--nauticos
insert into TBCONSOR_PLANO_TIPOBEM values (45,9,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 23.582,00' ));--nauticos
insert into TBCONSOR_PLANO_TIPOBEM values (46,9,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 39.490,00' ));--nauticos
insert into TBCONSOR_PLANO_TIPOBEM values (47,10,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 126.300,00'  ));--nauticos
commit;

insert into TBCONSOR_PLANO_TIPOBEM values (48,12,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 5.000,00'  ));-- Serviços
insert into TBCONSOR_PLANO_TIPOBEM values (49,12,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 6.000,00'  ));-- Serviços
insert into TBCONSOR_PLANO_TIPOBEM values (50,12,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 7.000,00'  ));-- Serviços
insert into TBCONSOR_PLANO_TIPOBEM values (51,12,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 8.000,00'  ));-- Serviços
insert into TBCONSOR_PLANO_TIPOBEM values (52,12,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 9.000,00'  ));-- Serviços
insert into TBCONSOR_PLANO_TIPOBEM values (53,12,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 10.000,00' ));-- Serviços
insert into TBCONSOR_PLANO_TIPOBEM values (54,12,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 12.000,00' ));-- Serviços
insert into TBCONSOR_PLANO_TIPOBEM values (55,12,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 14.000,00' ));-- Serviços
insert into TBCONSOR_PLANO_TIPOBEM values (56,12,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 16.000,00' ));-- Serviços
insert into TBCONSOR_PLANO_TIPOBEM values (57,12,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 18.000,00' ));-- Serviços
insert into TBCONSOR_PLANO_TIPOBEM values (58,12,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 20.000,00' ));-- Serviços
insert into TBCONSOR_PLANO_TIPOBEM values (59,12,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 22.000,00' ));-- Serviços
insert into TBCONSOR_PLANO_TIPOBEM values (60,12,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 24.000,00' ));-- Serviços
insert into TBCONSOR_PLANO_TIPOBEM values (61,11,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 18.000,00' ));-- Serviços
insert into TBCONSOR_PLANO_TIPOBEM values (62,11,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 24.000,00' ));-- Serviços
commit;
insert into TBCONSOR_PLANO_TIPOBEM values (63,20,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 18.000,00'));--Planejados
insert into TBCONSOR_PLANO_TIPOBEM values (64,20,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 24.000,00'));--Planejados
insert into TBCONSOR_PLANO_TIPOBEM values (65,13,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 15.000,00'));--Planejados
insert into TBCONSOR_PLANO_TIPOBEM values (66,13,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 18.000,00'));--Planejados
insert into TBCONSOR_PLANO_TIPOBEM values (68,13,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 21.000,00'));--Planejados
insert into TBCONSOR_PLANO_TIPOBEM values (69,13,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 24.000,00'));--Planejados
insert into TBCONSOR_PLANO_TIPOBEM values (70,13,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 27.000,00'));--Planejados
insert into TBCONSOR_PLANO_TIPOBEM values (71,13,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 30.000,00'));--Planejados
commit;
insert into TBCONSOR_PLANO_TIPOBEM values (72,14,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 27.500,00' ));--Sustentaveis
insert into TBCONSOR_PLANO_TIPOBEM values (73,14,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 45.000,00' ));--Sustentaveis
insert into TBCONSOR_PLANO_TIPOBEM values (74,15,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 9.200,00'  ));--Sustentaveis
insert into TBCONSOR_PLANO_TIPOBEM values (75,15,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 27.500,00' ));--Sustentaveis
insert into TBCONSOR_PLANO_TIPOBEM values (76,15,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 45.000,00' ));--Sustentaveis
insert into TBCONSOR_PLANO_TIPOBEM values (77,16,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 70.000,00' ));--Sustentaveis
insert into TBCONSOR_PLANO_TIPOBEM values (78,16,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 85.000,00' ));--Sustentaveis
insert into TBCONSOR_PLANO_TIPOBEM values (79,17,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 125.000,00'  ));--Sustentaveis
insert into TBCONSOR_PLANO_TIPOBEM values (80,17,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 168.000,00'  ));--Sustentaveis
commit;
--insert into TBCONSOR_PLANO_TIPOBEM values (81,21,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 70.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (82,18,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 55.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (83,18,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 60.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (84,18,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 80.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (85,18,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 90.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (86,18,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 100.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (87,18,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 110.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (88,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 120.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (89,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 130.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (90,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 140.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (91,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 150.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (92,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 160.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (93,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 170.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (94,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 180.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (95,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 190.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (96,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 200.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (97,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 210.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (98,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 220.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (99,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 230.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (100,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 240.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (101,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 250.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (102,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 260.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (103,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 270.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (104,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 280.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (105,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 290.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (106,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 300.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (107,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 310.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (108,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 320.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (109,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 330.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (110,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 340.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (111,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 350.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (112,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 360.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (113,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 370.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (114,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 380.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (115,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 390.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (116,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 400.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (117,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 410.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (118,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 420.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (119,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 430.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (120,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 440.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (121,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 450.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (122,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 460.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (123,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 470.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (124,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 480.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (125,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 490.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (126,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 500.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (127,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 510.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (128,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 520.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (129,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 530.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (130,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 540.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (131,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 550.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (132,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 560.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (133,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 570.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (134,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 580.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (135,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 590.000,00')); -- imoveis
insert into TBCONSOR_PLANO_TIPOBEM values (136,19,(select id from TBCONSOR_TIPOBEM where trim(nmtipobem) = 'Carta de R$ 600.000,00')); -- imoveis
commit;
