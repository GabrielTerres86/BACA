BEGIN
---------------------------//------------------------------------//------------------------------//--------------------------------  
 -- ICF607
 -- Modalidade Header
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  (NULL,    NULL,      100,          1,            'Arquivo aceito', 'Arquivo processado sem ocorrência de header e trailer',  5);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-007',      101,      1,            'Controle do Header inválido', 'Arquivo sem header se diferente de ‘0000000’ e/ou sem trailer se diferente de ‘9999999’',  5);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '008-015',      102,      1,            'Data Remessa inválida', 'Conteúdo não numérico ou diferente da data do movimento',  5);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      103,      1,            'Código IF Remetente inválido', 'Conteúdo não numérico',  5);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      104,      1,            'Código IF Remetente inválido', 'Banco remetente do arquivo diferente do banco do header',  5);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      105,      1,            'Código IF Remetente inválido', 'Banco excluído',  5);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      106,      1,            'Código IF Remetente inválido', 'Banco suspenso',  5);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      107,      1,            'Código IF Remetente inválido', 'Banco inválido ou não participa da COMPE',  5);      
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '019-022',      108,      1,            'Versão do Arquivo inválido', 'Número da versão não informado ou não numérico',  5);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '019-022',      109,      1,            'Versão do Arquivo inválido', 'Versão duplicada',  5);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',    '023-028',      110,      1,            'Nome do Arquivo inválido', 'Nome do arquivo diferente de ICF607',  5);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '029-190',      111,      1,            'Caracteres binários', 'Caracteres binários em campos "Filler"',  5);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '191-200',      112,      1,            'Sequencial do Arquivo inválido', 'Conteúdo não numérico ou inválido',  5);      
---------------------------//------------------------------------//------------------------------//--------------------------------
-- ICF607
-- Trailer  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-007',      901,      2,            'Controle do Trailer inválido', 'Arquivo sem trailer',  5);      

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2, 3, 4 e 5',    '008-028',      902,      2,            'Data Remessa inválida', 'Conteúdo não numérico ou diferente da data do movimento',  5);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '029-038',      903,      2,            'Total de Registros', 'Total de Registros não numérico ou zerado quando houver registros detalhe',  5);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '039-190',      903,      2,            'Caracteres binários', 'Caracteres binários em campos "Filler"',  5);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '191-200',      905,      2,            'Sequencial do Arquivo inválido', 'Conteúdo não numérico ou inválido',  5);    
  

---------------------------//------------------------------------//------------------------------//--------------------------------
-- ICF607
-- Detalhes

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-003',      201,          3,     'Compe destino inválida', 'Conteúdo não numérico', 5);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      202,          3,     'Banco sacado inválido', 'Conteúdo não numérico ou não participante da compe ou diferente do banco do header', 5);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '007-010',      203,          3,     'Agência sacada inválida', 'Conteúdo não numérico', 5);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '011-011',      204,          3,     'DV2 inválido', 'Conteúdo não numérico', 5);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',    '012-023',      205,          3,     'Conta sacada inválida', 'Conteúdo não numérico', 5);      

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '024-024',      206,          3,     'DV1 inválido', 'Conteúdo não numérico', 5);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '025-030',      207,          3,     'N° Documento inválido', 'Conteúdo não numérico', 5);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '031-031',      208,          3,     'DV3 inválido', 'Conteúdo não numérico', 5);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('9',    '032-033',      209,          3,     'UF inválida', 'Valor não previsto', 5);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '034-050',      210,          3,     'Valor inválido', 'Conteúdo não numérico', 5);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '034-050',      211,          3,     'Valor incompatível', 'Valor zerado', 5);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',    '051-051',      212,          3,     'Tipificação inválida', 'Valor não previsto', 5);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',    '052-052',      213,          3,     'Tipo de conta acolhedora inválido', 'Conteúdo não numérico', 5);                
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',    '052-052',      214,          3,     'Tipo de conta acolhedora inválido', 'Valor não previsto', 5);                  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',    '053-053',      215,          3,     'Canal de Atendimento Utilizado', 'Conteúdo não numérico', 5);                    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',    '053-053',      216,          3,     'Canal de Atendimento Utilizado', 'Valor não previsto', 5);                      
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14, 19 e 27',    '054-055 079-081 152-190',      217,          3,     'Caracteres binários', 'Caracteres binários em campos "Filler"', 5);   
    
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',    '056-058',      218,          3,     'Banco apres. Inválido', 'Conteúdo não numérico ou não participante da compe', 5);                          

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',    '059-062',      219,          3,     'Agência apres. Inválida', 'Conteúdo não numérico', 5);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',    '059-062',      220,          3,     'Agência apres. Inválida', 'Conteúdo zerado', 5);                              
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',    '063-066',      221,          3,     'N° Agen. acolhedora Inválido', 'Conteúdo não numérico', 5);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',    '063-066',      222,          3,     'N° Agen. acolhedora Inválido', 'Conteúdo zerado', 5);                                
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('18',    '067-078',      223,          3,     'N° Conta acolhedora Inválido', 'Conteúdo não numérico', 5);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('18',    '067-078',      224,          3,     'N° Conta acolhedora Inválido', 'Conteúdo zerado', 5);                                  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('20',    '082-089',      225,          3,     'Data Apresentação Inválida', 'Conteúdo não numérico ou data inválida', 5);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('20',    '082-089',      226,          3,     'Data Apresentação Inválida', 'Informações enviadas fora do prazo máximo de 05 dias úteis.', 5);                                    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('21',    '090-091',      227,          3,     'Código Solicitação Sacado inválido', 'Conteúdo não numérico', 5);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('21',    '090-091',      228,          3,     'Código Solicitação Sacado inválido', 'Conteúdo zerado', 5);                                  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('22',    '092-093',      229,          3,     'Código Solicitação Sacado inválido', 'Conteúdo não numérico', 5);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('22',    '092-093',      230,          3,     'Código Solicitação Sacado inválido', 'Valor não previsto ou incompatível com o campo “Código Solicitação Sacado” (posição 090-091)', 5);         
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('23',    '094-107',      231,          3,     'CPF/CNPJ Sacado inválido', 'Conteúdo não numérico', 5);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('23',    '094-107',      232,          3,     'CPF/CNPJ Sacado inválido', 'Valor incompatível com o campo “Código Solicitação Sacado” (posição 090-091)', 5);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('23',    '094-107',      233,          3,     'CPF/CNPJ Sacado inválido', 'Valor incompatível com o campo “Tipo de Pessoa Conta Sacada” (posição 092-093)', 5);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('24',    '108-147',      234,          3,     'Nome Sacado inválido', 'Valor incompatível com o campo “Tipo de Pessoa Conta Sacada” (posição 092-093)', 5);    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('25',    '148-149',      235,          3,     'Sequencial Titular Sacado', 'Conteúdo não numérico ou inválido', 5);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '150-151',      236,          3,     'Total Titular Sacado', 'Conteúdo não numérico.', 5);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '150-151',      237,          3,     'Total Titular Sacado', 'Conteúdo divergente do informado no primeiro titular do cheque.', 5);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '150-151',      238,          3,     'Total Titular Sacado', 'Valor incompatível com o campo “Tipo de Pessoa Conta Sacada” (posição 092-093)', 5);    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('28',    '191-200',      239,          3,     'Sequencial de arquivo', 'Conteúdo não numérico ou inválido', 5);   

---------------------------//------------------------------------//------------------------------//--------------------------------
-- ICF609
-- Header
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  (NULL,    NULL,      100,          1,     'Arquivo aceito', 'Arquivo processado sem ocorrência de header e trailer', 6);   

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-007',      101,          1,     'Controle do Header inválido', 'Arquivo sem header se diferente de ‘0000000’', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '008-015',      102,          1,     'Data Remessa inválida', 'Conteúdo não numérico ou diferente da data do movimento', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      103,          1,     'Código IF Remetente inválido', 'Conteúdo não numérico', 6);       
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      104,          1,     'Código IF Remetente inválido', 'Banco remetente do arquivo diferente do banco do header', 6);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      105,          1,     'Código IF Remetente inválido', 'Banco excluído', 6);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      106,          1,     'Código IF Remetente inválido', 'Banco suspenso', 6);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '016-018',      107,          1,     'Código IF Remetente inválido', 'Banco inválido ou não participa da COMPE', 6);        
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '019-022',      108,          1,     'Versão do Arquivo inválido', 'Número da versão não informado ou não numérico', 6);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '019-022',      109,          1,     'Versão do Arquivo inválido', 'Versão duplicada', 6);            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',    '023-028',      110,          1,     'Nome do Arquivo inválido', 'Nome do arquivo diferente de ICF609', 6);            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '029-190',      111,          1,     'Caracteres binários', 'Caracteres binários em campos "Filler"', 6);            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '191-200',      112,          1,     'Sequencial do Arquivo inválido', 'Conteúdo não numérico ou inválido', 6);                  
  
  
  
---------------------------//------------------------------------//------------------------------//--------------------------------
-- ICF609
-- Trailer
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-007',      901,          2,     'Controle do Trailer inválido', 'Arquivo sem trailer', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2, 3, 4 e 5',    '008-028',      902,          2,     'Data Remessa inválida', 'Conteúdo não numérico ou diferente da data do movimento', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '029-038',      903,          2,     'Total de Registros', 'Total de Registros não numérico ou zerado quando houver registros detalhe', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '039-190',     904,          2,     'Caracteres binários', 'Caracteres binários em campos "Filler"', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '191-200',      905,          2,     'Sequencial do Arquivo inválido', 'Conteúdo não numérico ou inválido', 6);   
  
 
  
---------------------------//------------------------------------//------------------------------//--------------------------------
-- ICF609
-- Detalhes  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-003',      201,          3,     'Compe destino inválida', 'Conteúdo não numérico', 6);     
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      202,          3,     'Banco sacado inválido', 'Conteúdo não numérico ou não participante da compe', 6); 
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '007-010',      203,          3,     'Agência sacada inválida', 'Conteúdo não numérico', 6); 
 
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '011-011',      204,          3,     'DV2 inválido', 'Conteúdo não numérico', 6);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',    '012-023',      205,          3,     'Conta sacada inválida', 'Conteúdo não numérico', 6);      

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '024-024',      206,          3,     'DV1 inválido', 'Conteúdo não numérico', 6);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '025-030',      207,          3,     'N° Documento inválido', 'Conteúdo não numérico', 6);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '031-031',      208,          3,     'DV3 inválido', 'Conteúdo não numérico', 6);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('9',    '032-033',      209,          3,     'UF inválida', 'Valor não previsto', 6);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '034-050',      210,          3,     'Valor inválido', 'Conteúdo não numérico', 6);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '034-050',      211,          3,     'Valor incompatível', 'Valor zerado', 6);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',    '051-051',      212,          3,     'Tipificação inválida', 'Valor não previsto', 6);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',    '052-052',      213,          3,     'Tipo de conta acolhedora inválido', 'Conteúdo não numérico', 6);                
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',    '052-052',      214,          3,     'Tipo de conta acolhedora inválido', 'Valor não previsto', 6);                  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',    '053-053',      215,          3,     'Canal de Atendimento Utilizado', 'Conteúdo não numérico', 6);                    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',    '053-053',      216,          3,     'Canal de Atendimento Utilizado', 'Valor não previsto', 6);                      
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14, 19 e 28',    '054-055 079-081 160-190',      217,          3,     'Caracteres binários', 'Caracteres binários em campos "Filler"', 6);   
    
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',    '056-058',      218,          3,     'Banco apres. Inválido', 'Conteúdo não numérico ou não participante da compe', 6);                          

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',    '059-062',      219,          3,     'Agência apres. Inválida', 'Conteúdo não numérico', 6);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',    '059-062',      220,          3,     'Agência apres. Inválida', 'Conteúdo inválido', 6);                              
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',    '063-066',      221,          3,     'N° Agen. acolhedora Inválido', 'Conteúdo zerado', 6);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',    '063-066',      222,          3,     'N° Agen. acolhedora Inválido', 'Conteúdo zerado', 6);                                
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('18',    '067-078',      223,          3,     'N° Conta acolhedora Inválido', 'Conteúdo não numérico', 6);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('18',    '067-078',      224,          3,     'N° Conta acolhedora Inválido', 'Conteúdo zerado', 6);                                  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('20',    '082-089',      225,          3,     'Data Apresentação Inválida', 'Conteúdo não numérico ou data inválida', 6);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('20',    '082-089',      226,          3,     'Data Apresentação Inválida', 'Informações enviadas fora do prazo máximo de 05 dias úteis.', 6);                                    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('21',    '090-091',      227,          3,     'Código Solicitação Depositante inválido', 'Conteúdo não numérico', 6);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('21',    '090-091',      228,          3,     'Código Solicitação Depositante inválido', 'Conteúdo zerado', 6);                                  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('22',    '092-093',      229,          3,     'Tipo de Pessoa Conta Depositante inválido', 'Conteúdo não numérico', 6);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('22',    '092-093',      230,          3,     'Tipo de Pessoa Conta Depositante inválido', 'Valor não previsto ou incompatível com o campo “Código Solicitação Depositante” (posição 090-091)', 6);         
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('23',    '094-107',      231,          3,     'CPF/CNPJ Depositante inválido', 'Conteúdo não numérico', 6);                            
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('23',    '094-107',      232,          3,     'CPF/CNPJ Depositante inválido', 'Valor incompatível com o campo “Código Solicitação Depositante” (posição 090-091)', 6);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('23',    '094-107',      233,          3,     'CPF/CNPJ Depositante inválido', 'Valor incompatível com o campo “Tipo de Pessoa Conta Depositante” (posição 092-093)', 6);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('24',    '108-147',      234,          3,     'Nome Depositante inválido', 'Valor incompatível com o campo “Tipo de Pessoa Conta Depositante” (posição 092-093)', 6);    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('25',    '148-149',      235,          3,     'Sequencial Titular Depositante', 'Conteúdo não numérico ou inválido', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '150-151',      236,          3,     'Total Titular Depositante', 'Conteúdo não numérico.', 6);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '150-151',      237,          3,     'Total Titular Depositante', 'Conteúdo divergente do informado no primeiro titular do cheque.', 6);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '150-151',      238,          3,     'Total Titular Depositante', 'Valor incompatível com o campo “Tipo de Pessoa Conta Depositante” (posição 092-093)', 6);    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('27',    '152-159',      239,          3,     'Data do Recebimento Inválida', 'Conteúdo não numérico ou inválido', 6);     
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('27',    '152-159',      240,          3,     'Data do Recebimento Inválida', 'Informações enviadas fora do prazo máximo de 05 dias úteis (*).', 6);       

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('29',    '191-200',      241,          3,     'Sequencial de arquivo', 'Conteúdo não numérico ou inválido', 6);         

  
                             

COMMIT;

END;  
