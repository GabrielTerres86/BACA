BEGIN
 -- Modalidade Header
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  (NULL,    NULL,      100,          1,     'Arquivo aceito', 'Arquivo aceito sem ocorr�ncia de header/trailer',  3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-047',      101,      1,            'Arquivo sem header', 'Arquivo sem registro tipo Header',  3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '048-053',      105,          1,     'Arquivo inv�lido', 'Nome do arquivo diferente de "DVD604" (sess�o de devolu��o) ou "DVN604" (sess�o de preven��o a fraudes e de impedimentos) ou "DCG604" (sess�o de devolu��o em conting�ncia)',  3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '054-060',      108,          1,     'Vers�o inv�lida', 'Conte�do n�o num�rico ou igual a zero',  3);      

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '054-060',      109,          1,     'Vers�o duplicada', 'Vers�o j� processada na sess�o',  3);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '061-063',      102,          1,     'Banco inv�lido', 'Conte�do n�o num�rico; ou valor n�o previsto; ou banco do header diferente do remetente do arquivo',  3);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '061-063',      103,          1,     'Banco n�o participa', 'Banco apresentante inativo ou exclu�do da Compe',  3);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '061-063',      104,          1,     'Banco suspenso', 'Banco apresentante suspenso da sess�o',  3);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '061-063',      113,          1,     'Banco n�o participa do DCG', 'Banco apresentante n�o participa do DCG',  3);              
      
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '065-065',      106,          1,     'Remessa inv�lida', 'Indicador de remessa inv�lido para a sess�o',  3);              

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '066-073',      111,          1,     'Data inv�lida', 'Conte�do n�o num�rico ou valor diferente da data sess�o',  3);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '151-160',      112,          1,     'Sequencial inv�lido', 'Conte�do n�o num�rico ou diferente de 1',  3);    
  
--
-- Ocorrenvia de trailer

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-047',      901,          2,     'Arquivo sem trailer', 'Arquivo sem registro tipo Trailer',  3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-047',      902,          2,     'Arquivo s� com trailer', 'Arquivo somente com registro tipo Trailer', 3);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2, 3, 4, 6, 7',    '048-063 065-073',      903,          2,     'Trailer diverge do header', 'Nome do arquivo, vers�o, banco, remessa ou data divergente entre header e trailer', 3);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '074-090',      904,          2,     'Valor do arquivo inv�lido', 'Conte�do n�o num�rico ou valor divergente do somat�rio dos valores dos registros tipo Detalhe', 3);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('9',    '151-160',      905,          2,     'Sequencial inv�lido', 'Conte�do n�o num�rico ou valor divergente do total de registros do arquivo', 3);    
  
--
-- Fechamento de Lote

  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-003',      701,          4,     'Compe destino inv�lida', 'Conte�do n�o num�rico ou valor n�o previsto', 3);      

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      702,          4,     'Banco destino inv�lido', 'Conte�do n�o num�rico', 3);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      703,          4,     'Banco destino exclu�do', 'Banco destino exclu�do da Compe', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      704,          4,     'Banco destino suspenso', 'Banco destino suspenso da sess�o', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      705,          4,     'Banco destino n�o participa da Compe', 'Banco destino n�o participante da Comp', 3);      
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '034-050',      706,          4,     'Valor do Lote inv�lido', 'Conte�do n�o num�rico ou valor divergente do somat�rio dos valores dos registros tipo detalhe do lote', 3);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '056-058',      707,          4,     'Banco apres. inv�lido', 'Conte�do n�o num�rico', 3);          

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '056-058',      708,          4,     'Banco apres. divergente', 'C�digo do banco apresentante diferente do banco do Header', 3); 
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '056-058',      709,          4,     'Banco apres. exclu�do', 'Banco apresentante exclu�do da Compe', 3); 
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '056-058',      710,          4,     'Banco apres. suspenso', 'Banco apresentante suspenso da sess�o', 3); 
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '056-058',      711,          4,     'Banco apres. n�o participa da Compe', 'Banco apresentante n�o participante da Compe', 3);         
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '082-089',      712,          4,     'Data inv�lida', 'Conte�do n�o num�rico ou valor diferente da data da sess�o', 3);
     
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('9',    '090-096',      713,          4,     'N� do Lote inv�lido', 'Conte�do n�o num�rico', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '097-099',      715,          4,     'N� seql. Lote inv�lido', 'Conte�do n�o num�rico ou valor diferente de 999', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',    '141-147',      717,          4,     'Vers�o inv�lida', 'Conte�do n�o num�rico ou diferente da vers�o do Header', 3);      
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',    '148-150',      718,          4,     'TD inv�lido', 'Conte�do n�o num�rico ou valor n�o previsto', 3);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',    '148-150',      719,          4,     'TD incompat�vel', 'Tipo de Documento incompat�vel com sess�o de processamento', 3);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('s/c',    NULL,      720,          4,     'Lote sem detalhe', 'Lote sem registros tipo Detalhe', 3);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('s/c',    NULL,      721,          4,     'Lote sem Fechamento', 'Exist�ncia de registros tipo Detalhe sem Fechamento correspondente', 3);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('s/c',    NULL,      722,          4,     'Lote c/+ 400 detalhes', 'Lote com mais de 400 registros tipo Detalhe', 3);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',    '151-160',      723,          4,     'Sequencial inv�lido', 'Conte�do n�o num�rico ou valor divergente do sequencial do registro no arquivo', 3);

-- 
-- Detalhes

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-003',      201,          3,     'Compe destino inv�lida', 'Conte�do n�o num�rico', 3);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      202,          3,     'Banco sacado inv�lido', 'Conte�do n�o num�rico ou diferente do banco do Header', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '007-010',      203,          3,     'Ag�ncia sacada inv�lida', 'Conte�do n�o num�rico', 3);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '011-011',      204,          3,     'DV2 inv�lido', 'Conte�do n�o num�rico', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',    '012-023',      205,          3,     'Conta sacada inv�lida', 'Conte�do n�o num�rico', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '024-024',      206,          3,     'DV1 inv�lido', 'Conte�do n�o num�rico', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '025-030',      207,          3,     'N� Documento inv�lido', 'Conte�do n�o num�rico', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '031-031',      208,          3,     'DV3 inv�lido', 'Conte�do n�o num�rico', 3);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('9',    '032-033',      209,          3,     'UF inv�lida', 'Valor n�o previsto', 3); 
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '034-050',      210,          3,     'Valor inv�lido', 'Conte�do n�o num�rico', 3);     

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '034-050',      211,          3,     'Valor incompat�vel', 'Valor zerado', 3);       

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',    '051-051',      212,          3,     'Tipifica��o inv�lida', 'Valor n�o previsto', 3);     
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',    '053-053',      226,          3,     'Caracteres bin�rios', 'Caracteres bin�rios em campos "Filler"', 3);         

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',    '054-055',      229,          3,     'Motivo devolu��o inv�lido', 'Conte�do n�o num�rico ou valor n�o previsto', 3);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',    '054-055',      232,          3,     'Motivo devolu��o incompat�vel', 'Motivo de devolu��o 14 utilizado indevidamente para cheque de valor superior ao CPA', 3);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',    '054-055',      237,          3,     'Motivo devolu��o inv�lido', 'Motivo de devolu��o inv�lido para a sess�o de preven��o a fraudes e impedimentos.', 3);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',    '056-058',      213,          3,     'Banco apres. Inv�lido', 'Conte�do n�o num�rico ou diferente do banco destinat�rio do lote', 3); 

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',    '059-062',      214,          3,     'Ag�ncia apres. Inv�lida', 'Conte�do n�o num�rico', 3);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',    '063-066',      215,          3,     'N� Agenc. acolhedora Inv�lido', 'Conte�do n�o num�rico', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('18',    '067-078',      216,          3,     'N� Conta acolhedora Depos. Inv�lido', 'Conte�do n�o num�rico', 3);    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('19',    '079-081',      226,          3,     'Caracteres bin�rios', 'Caracteres bin�rios em campos "Filler"', 3);   

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('20',    '082-089',      218,          3,     'Data inv�lida', 'Conte�do n�o num�rico', 3);   

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('21',    '090-096',      219,          3,     'N� do Lote inv�lido', 'Conte�do n�o num�rico', 3);     
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('22',    '097-099',      220,          3,     'N� seql. Lote inv�lido', 'Conte�do n�o num�rico', 3);       
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('24',    '106-130',      221,          3,     'N� Identificador inv�lido', 'Conte�do n�o num�rico ou igual a zeros', 3);         
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('25',    '131-140',      233,          3,     'Sequencial original inv�lido', 'Conte�do n�o num�rico ou diferente do conte�do do campo 28', 3);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '141-147',      223,          3,     'Vers�o inv�lida', 'Conte�do n�o num�rico ou diferente da vers�o do Header', 3);    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('27',    '148-150',      224,          3,     'TD inv�lido', 'Conte�do n�o num�rico', 3);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('27',    '148-150',      225,          3,     'TD incompat�vel', 'Tipo de Documento incompat�vel com sess�o de processamento', 3);    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('28',    '151-160',      227,          3,     'Sequencial inv�lido', 'Conte�do n�o num�rico ou diferente do sequencial do registro no arquivo', 3);

COMMIT;

END;  
