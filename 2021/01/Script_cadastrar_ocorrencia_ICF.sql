BEGIN
---------------------------//------------------------------------//------------------------------//--------------------------------  
 -- ICF607
 -- Modalidade Header
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  (NULL,    NULL,      100,          1,            'Arquivo aceito', 'Arquivo processado sem ocorr�ncia de header e trailer',  5);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-007',      101,      1,            'Controle do Header inv�lido', 'Arquivo sem header se diferente de �0000000� e/ou sem trailer se diferente de �9999999�',  5);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '008-015',      102,      1,            'Data Remessa inv�lida', 'Conte�do n�o num�rico ou diferente da data do movimento',  5);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      103,      1,            'C�digo IF Remetente inv�lido', 'Conte�do n�o num�rico',  5);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      104,      1,            'C�digo IF Remetente inv�lido', 'Banco remetente do arquivo diferente do banco do header',  5);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      105,      1,            'C�digo IF Remetente inv�lido', 'Banco exclu�do',  5);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      106,      1,            'C�digo IF Remetente inv�lido', 'Banco suspenso',  5);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      107,      1,            'C�digo IF Remetente inv�lido', 'Banco inv�lido ou n�o participa da COMPE',  5);      
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '019-022',      108,      1,            'Vers�o do Arquivo inv�lido', 'N�mero da vers�o n�o informado ou n�o num�rico',  5);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '019-022',      109,      1,            'Vers�o do Arquivo inv�lido', 'Vers�o duplicada',  5);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',    '023-028',      110,      1,            'Nome do Arquivo inv�lido', 'Nome do arquivo diferente de ICF607',  5);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '029-190',      111,      1,            'Caracteres bin�rios', 'Caracteres bin�rios em campos "Filler"',  5);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '191-200',      112,      1,            'Sequencial do Arquivo inv�lido', 'Conte�do n�o num�rico ou inv�lido',  5);      
---------------------------//------------------------------------//------------------------------//--------------------------------
-- ICF607
-- Trailer  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-007',      901,      2,            'Controle do Trailer inv�lido', 'Arquivo sem trailer',  5);      

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2, 3, 4 e 5',    '008-028',      902,      2,            'Data Remessa inv�lida', 'Conte�do n�o num�rico ou diferente da data do movimento',  5);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '029-038',      903,      2,            'Total de Registros', 'Total de Registros n�o num�rico ou zerado quando houver registros detalhe',  5);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '039-190',      903,      2,            'Caracteres bin�rios', 'Caracteres bin�rios em campos "Filler"',  5);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '191-200',      905,      2,            'Sequencial do Arquivo inv�lido', 'Conte�do n�o num�rico ou inv�lido',  5);    
  

---------------------------//------------------------------------//------------------------------//--------------------------------
-- ICF607
-- Detalhes

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-003',      201,          3,     'Compe destino inv�lida', 'Conte�do n�o num�rico', 5);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      202,          3,     'Banco sacado inv�lido', 'Conte�do n�o num�rico ou n�o participante da compe ou diferente do banco do header', 5);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '007-010',      203,          3,     'Ag�ncia sacada inv�lida', 'Conte�do n�o num�rico', 5);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '011-011',      204,          3,     'DV2 inv�lido', 'Conte�do n�o num�rico', 5);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',    '012-023',      205,          3,     'Conta sacada inv�lida', 'Conte�do n�o num�rico', 5);      

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '024-024',      206,          3,     'DV1 inv�lido', 'Conte�do n�o num�rico', 5);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '025-030',      207,          3,     'N� Documento inv�lido', 'Conte�do n�o num�rico', 5);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '031-031',      208,          3,     'DV3 inv�lido', 'Conte�do n�o num�rico', 5);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('9',    '032-033',      209,          3,     'UF inv�lida', 'Valor n�o previsto', 5);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '034-050',      210,          3,     'Valor inv�lido', 'Conte�do n�o num�rico', 5);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '034-050',      211,          3,     'Valor incompat�vel', 'Valor zerado', 5);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',    '051-051',      212,          3,     'Tipifica��o inv�lida', 'Valor n�o previsto', 5);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',    '052-052',      213,          3,     'Tipo de conta acolhedora inv�lido', 'Conte�do n�o num�rico', 5);                
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',    '052-052',      214,          3,     'Tipo de conta acolhedora inv�lido', 'Valor n�o previsto', 5);                  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',    '053-053',      215,          3,     'Canal de Atendimento Utilizado', 'Conte�do n�o num�rico', 5);                    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',    '053-053',      216,          3,     'Canal de Atendimento Utilizado', 'Valor n�o previsto', 5);                      
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14, 19 e 27',    '054-055 079-081 152-190',      217,          3,     'Caracteres bin�rios', 'Caracteres bin�rios em campos "Filler"', 5);   
    
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',    '056-058',      218,          3,     'Banco apres. Inv�lido', 'Conte�do n�o num�rico ou n�o participante da compe', 5);                          

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',    '059-062',      219,          3,     'Ag�ncia apres. Inv�lida', 'Conte�do n�o num�rico', 5);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',    '059-062',      220,          3,     'Ag�ncia apres. Inv�lida', 'Conte�do zerado', 5);                              
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',    '063-066',      221,          3,     'N� Agen. acolhedora Inv�lido', 'Conte�do n�o num�rico', 5);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',    '063-066',      222,          3,     'N� Agen. acolhedora Inv�lido', 'Conte�do zerado', 5);                                
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('18',    '067-078',      223,          3,     'N� Conta acolhedora Inv�lido', 'Conte�do n�o num�rico', 5);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('18',    '067-078',      224,          3,     'N� Conta acolhedora Inv�lido', 'Conte�do zerado', 5);                                  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('20',    '082-089',      225,          3,     'Data Apresenta��o Inv�lida', 'Conte�do n�o num�rico ou data inv�lida', 5);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('20',    '082-089',      226,          3,     'Data Apresenta��o Inv�lida', 'Informa��es enviadas fora do prazo m�ximo de 05 dias �teis.', 5);                                    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('21',    '090-091',      227,          3,     'C�digo Solicita��o Sacado inv�lido', 'Conte�do n�o num�rico', 5);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('21',    '090-091',      228,          3,     'C�digo Solicita��o Sacado inv�lido', 'Conte�do zerado', 5);                                  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('22',    '092-093',      229,          3,     'C�digo Solicita��o Sacado inv�lido', 'Conte�do n�o num�rico', 5);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('22',    '092-093',      230,          3,     'C�digo Solicita��o Sacado inv�lido', 'Valor n�o previsto ou incompat�vel com o campo �C�digo Solicita��o Sacado� (posi��o 090-091)', 5);         
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('23',    '094-107',      231,          3,     'CPF/CNPJ Sacado inv�lido', 'Conte�do n�o num�rico', 5);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('23',    '094-107',      232,          3,     'CPF/CNPJ Sacado inv�lido', 'Valor incompat�vel com o campo �C�digo Solicita��o Sacado� (posi��o 090-091)', 5);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('23',    '094-107',      233,          3,     'CPF/CNPJ Sacado inv�lido', 'Valor incompat�vel com o campo �Tipo de Pessoa Conta Sacada� (posi��o 092-093)', 5);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('24',    '108-147',      234,          3,     'Nome Sacado inv�lido', 'Valor incompat�vel com o campo �Tipo de Pessoa Conta Sacada� (posi��o 092-093)', 5);    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('25',    '148-149',      235,          3,     'Sequencial Titular Sacado', 'Conte�do n�o num�rico ou inv�lido', 5);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '150-151',      236,          3,     'Total Titular Sacado', 'Conte�do n�o num�rico.', 5);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '150-151',      237,          3,     'Total Titular Sacado', 'Conte�do divergente do informado no primeiro titular do cheque.', 5);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '150-151',      238,          3,     'Total Titular Sacado', 'Valor incompat�vel com o campo �Tipo de Pessoa Conta Sacada� (posi��o 092-093)', 5);    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('28',    '191-200',      239,          3,     'Sequencial de arquivo', 'Conte�do n�o num�rico ou inv�lido', 5);   

---------------------------//------------------------------------//------------------------------//--------------------------------
-- ICF609
-- Header
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  (NULL,    NULL,      100,          1,     'Arquivo aceito', 'Arquivo processado sem ocorr�ncia de header e trailer', 6);   

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-007',      101,          1,     'Controle do Header inv�lido', 'Arquivo sem header se diferente de �0000000�', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '008-015',      102,          1,     'Data Remessa inv�lida', 'Conte�do n�o num�rico ou diferente da data do movimento', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      103,          1,     'C�digo IF Remetente inv�lido', 'Conte�do n�o num�rico', 6);       
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      104,          1,     'C�digo IF Remetente inv�lido', 'Banco remetente do arquivo diferente do banco do header', 6);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      105,          1,     'C�digo IF Remetente inv�lido', 'Banco exclu�do', 6);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      106,          1,     'C�digo IF Remetente inv�lido', 'Banco suspenso', 6);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      107,          1,     'C�digo IF Remetente inv�lido', 'Banco inv�lido ou n�o participa da COMPE', 6);        
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '019-022',      108,          1,     'Vers�o do Arquivo inv�lido', 'N�mero da vers�o n�o informado ou n�o num�rico', 6);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '019-022',      109,          1,     'Vers�o do Arquivo inv�lido', 'Vers�o duplicada', 6);            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',    '023-028',      110,          1,     'Nome do Arquivo inv�lido', 'Nome do arquivo diferente de ICF609', 6);            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '029-190',      111,          1,     'Caracteres bin�rios', 'Caracteres bin�rios em campos "Filler"', 6);            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '191-200',      112,          1,     'Sequencial do Arquivo inv�lido', 'Conte�do n�o num�rico ou inv�lido', 6);                  
  
  
  
---------------------------//------------------------------------//------------------------------//--------------------------------
-- ICF609
-- Trailer
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-007',      901,          2,     'Controle do Trailer inv�lido', 'Arquivo sem trailer', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2, 3, 4 e 5',    '008-028',      902,          2,     'Data Remessa inv�lida', 'Conte�do n�o num�rico ou diferente da data do movimento', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '029-038',      903,          2,     'Total de Registros', 'Total de Registros n�o num�rico ou zerado quando houver registros detalhe', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '039-190',     904,          2,     'Caracteres bin�rios', 'Caracteres bin�rios em campos "Filler"', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '191-200',      905,          2,     'Sequencial do Arquivo inv�lido', 'Conte�do n�o num�rico ou inv�lido', 6);   
  
 
  
---------------------------//------------------------------------//------------------------------//--------------------------------
-- ICF609
-- Detalhes  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-003',      201,          3,     'Compe destino inv�lida', 'Conte�do n�o num�rico', 6);     
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      202,          3,     'Banco sacado inv�lido', 'Conte�do n�o num�rico ou n�o participante da compe', 6); 
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '007-010',      203,          3,     'Ag�ncia sacada inv�lida', 'Conte�do n�o num�rico', 6); 
 
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '011-011',      204,          3,     'DV2 inv�lido', 'Conte�do n�o num�rico', 6);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',    '012-023',      205,          3,     'Conta sacada inv�lida', 'Conte�do n�o num�rico', 6);      

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '024-024',      206,          3,     'DV1 inv�lido', 'Conte�do n�o num�rico', 6);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '025-030',      207,          3,     'N� Documento inv�lido', 'Conte�do n�o num�rico', 6);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '031-031',      208,          3,     'DV3 inv�lido', 'Conte�do n�o num�rico', 6);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('9',    '032-033',      209,          3,     'UF inv�lida', 'Valor n�o previsto', 6);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '034-050',      210,          3,     'Valor inv�lido', 'Conte�do n�o num�rico', 6);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '034-050',      211,          3,     'Valor incompat�vel', 'Valor zerado', 6);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',    '051-051',      212,          3,     'Tipifica��o inv�lida', 'Valor n�o previsto', 6);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',    '052-052',      213,          3,     'Tipo de conta acolhedora inv�lido', 'Conte�do n�o num�rico', 6);                
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',    '052-052',      214,          3,     'Tipo de conta acolhedora inv�lido', 'Valor n�o previsto', 6);                  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',    '053-053',      215,          3,     'Canal de Atendimento Utilizado', 'Conte�do n�o num�rico', 6);                    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',    '053-053',      216,          3,     'Canal de Atendimento Utilizado', 'Valor n�o previsto', 6);                      
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14, 19 e 28',    '054-055 079-081 160-190',      217,          3,     'Caracteres bin�rios', 'Caracteres bin�rios em campos "Filler"', 6);   
    
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',    '056-058',      218,          3,     'Banco apres. Inv�lido', 'Conte�do n�o num�rico ou n�o participante da compe', 6);                          

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',    '059-062',      219,          3,     'Ag�ncia apres. Inv�lida', 'Conte�do n�o num�rico', 6);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',    '059-062',      220,          3,     'Ag�ncia apres. Inv�lida', 'Conte�do inv�lido', 6);                              
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',    '063-066',      221,          3,     'N� Agen. acolhedora Inv�lido', 'Conte�do zerado', 6);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',    '063-066',      222,          3,     'N� Agen. acolhedora Inv�lido', 'Conte�do zerado', 6);                                
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('18',    '067-078',      223,          3,     'N� Conta acolhedora Inv�lido', 'Conte�do n�o num�rico', 6);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('18',    '067-078',      224,          3,     'N� Conta acolhedora Inv�lido', 'Conte�do zerado', 6);                                  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('20',    '082-089',      225,          3,     'Data Apresenta��o Inv�lida', 'Conte�do n�o num�rico ou data inv�lida', 6);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('20',    '082-089',      226,          3,     'Data Apresenta��o Inv�lida', 'Informa��es enviadas fora do prazo m�ximo de 05 dias �teis.', 6);                                    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('21',    '090-091',      227,          3,     'C�digo Solicita��o Depositante inv�lido', 'Conte�do n�o num�rico', 6);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('21',    '090-091',      228,          3,     'C�digo Solicita��o Depositante inv�lido', 'Conte�do zerado', 6);                                  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('22',    '092-093',      229,          3,     'Tipo de Pessoa Conta Depositante inv�lido', 'Conte�do n�o num�rico', 6);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('22',    '092-093',      230,          3,     'Tipo de Pessoa Conta Depositante inv�lido', 'Valor n�o previsto ou incompat�vel com o campo �C�digo Solicita��o Depositante� (posi��o 090-091)', 6);         
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('23',    '094-107',      231,          3,     'CPF/CNPJ Depositante inv�lido', 'Conte�do n�o num�rico', 6);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('23',    '094-107',      232,          3,     'CPF/CNPJ Depositante inv�lido', 'Valor incompat�vel com o campo �C�digo Solicita��o Depositante� (posi��o 090-091)', 6);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('23',    '094-107',      233,          3,     'CPF/CNPJ Depositante inv�lido', 'Valor incompat�vel com o campo �Tipo de Pessoa Conta Depositante� (posi��o 092-093)', 6);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('24',    '108-147',      234,          3,     'Nome Depositante inv�lido', 'Valor incompat�vel com o campo �Tipo de Pessoa Conta Depositante� (posi��o 092-093)', 6);    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('25',    '148-149',      235,          3,     'Sequencial Titular Depositante', 'Conte�do n�o num�rico ou inv�lido', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '150-151',      236,          3,     'Total Titular Depositante', 'Conte�do n�o num�rico.', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '150-151',      237,          3,     'Total Titular Depositante', 'Conte�do divergente do informado no primeiro titular do cheque.', 6);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '150-151',      238,          3,     'Total Titular Depositante', 'Valor incompat�vel com o campo �Tipo de Pessoa Conta Depositante� (posi��o 092-093)', 6);    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('27',    '152-159',      239,          3,     'Data do Recebimento Inv�lida', 'Conte�do n�o num�rico ou inv�lido', 6);     
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('27',    '152-159',      240,          3,     'Data do Recebimento Inv�lida', 'Informa��es enviadas fora do prazo m�ximo de 05 dias �teis (*).', 6);       

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('29',    '191-200',      241,          3,     'Sequencial de arquivo', 'Conte�do n�o num�rico ou inv�lido', 6);         

  
                             

COMMIT;

END;  
