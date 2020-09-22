BEGIN
 -- Modalidade Header
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  (NULL,    NULL,      100,          1,     'Arquivo aceito', 'Arquivo aceito sem ocorrência de header/trailer',  3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-047',      101,      1,            'Arquivo sem header', 'Arquivo sem registro tipo Header',  3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '048-053',      105,          1,     'Arquivo inválido', 'Nome do arquivo diferente de "DVD604" (sessão de devolução) ou "DVN604" (sessão de prevenção a fraudes e de impedimentos) ou "DCG604" (sessão de devolução em contingência)',  3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '054-060',      108,          1,     'Versão inválida', 'Conteúdo não numérico ou igual a zero',  3);      

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '054-060',      109,          1,     'Versão duplicada', 'Versão já processada na sessão',  3);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '061-063',      102,          1,     'Banco inválido', 'Conteúdo não numérico; ou valor não previsto; ou banco do header diferente do remetente do arquivo',  3);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '061-063',      103,          1,     'Banco não participa', 'Banco apresentante inativo ou excluído da Compe',  3);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '061-063',      104,          1,     'Banco suspenso', 'Banco apresentante suspenso da sessão',  3);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '061-063',      113,          1,     'Banco não participa do DCG', 'Banco apresentante não participa do DCG',  3);              
      
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '065-065',      106,          1,     'Remessa inválida', 'Indicador de remessa inválido para a sessão',  3);              

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '066-073',      111,          1,     'Data inválida', 'Conteúdo não numérico ou valor diferente da data sessão',  3);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '151-160',      112,          1,     'Sequencial inválido', 'Conteúdo não numérico ou diferente de 1',  3);    
  
--
-- Ocorrenvia de trailer

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-047',      901,          2,     'Arquivo sem trailer', 'Arquivo sem registro tipo Trailer',  3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-047',      902,          2,     'Arquivo só com trailer', 'Arquivo somente com registro tipo Trailer', 3);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2, 3, 4, 6, 7',    '048-063 065-073',      903,          2,     'Trailer diverge do header', 'Nome do arquivo, versão, banco, remessa ou data divergente entre header e trailer', 3);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '074-090',      904,          2,     'Valor do arquivo inválido', 'Conteúdo não numérico ou valor divergente do somatório dos valores dos registros tipo Detalhe', 3);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('9',    '151-160',      905,          2,     'Sequencial inválido', 'Conteúdo não numérico ou valor divergente do total de registros do arquivo', 3);    
  
--
-- Fechamento de Lote

  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-003',      701,          4,     'Compe destino inválida', 'Conteúdo não numérico ou valor não previsto', 3);      

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      702,          4,     'Banco destino inválido', 'Conteúdo não numérico', 3);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      703,          4,     'Banco destino excluído', 'Banco destino excluído da Compe', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      704,          4,     'Banco destino suspenso', 'Banco destino suspenso da sessão', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      705,          4,     'Banco destino não participa da Compe', 'Banco destino não participante da Comp', 3);      
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '034-050',      706,          4,     'Valor do Lote inválido', 'Conteúdo não numérico ou valor divergente do somatório dos valores dos registros tipo detalhe do lote', 3);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '056-058',      707,          4,     'Banco apres. inválido', 'Conteúdo não numérico', 3);          

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '056-058',      708,          4,     'Banco apres. divergente', 'Código do banco apresentante diferente do banco do Header', 3); 
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '056-058',      709,          4,     'Banco apres. excluído', 'Banco apresentante excluído da Compe', 3); 
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '056-058',      710,          4,     'Banco apres. suspenso', 'Banco apresentante suspenso da sessão', 3); 
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '056-058',      711,          4,     'Banco apres. não participa da Compe', 'Banco apresentante não participante da Compe', 3);         
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '082-089',      712,          4,     'Data inválida', 'Conteúdo não numérico ou valor diferente da data da sessão', 3);
     
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('9',    '090-096',      713,          4,     'N° do Lote inválido', 'Conteúdo não numérico', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '097-099',      715,          4,     'N° seql. Lote inválido', 'Conteúdo não numérico ou valor diferente de 999', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',    '141-147',      717,          4,     'Versão inválida', 'Conteúdo não numérico ou diferente da versão do Header', 3);      
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',    '148-150',      718,          4,     'TD inválido', 'Conteúdo não numérico ou valor não previsto', 3);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',    '148-150',      719,          4,     'TD incompatível', 'Tipo de Documento incompatível com sessão de processamento', 3);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('s/c',    NULL,      720,          4,     'Lote sem detalhe', 'Lote sem registros tipo Detalhe', 3);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('s/c',    NULL,      721,          4,     'Lote sem Fechamento', 'Existência de registros tipo Detalhe sem Fechamento correspondente', 3);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('s/c',    NULL,      722,          4,     'Lote c/+ 400 detalhes', 'Lote com mais de 400 registros tipo Detalhe', 3);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',    '151-160',      723,          4,     'Sequencial inválido', 'Conteúdo não numérico ou valor divergente do sequencial do registro no arquivo', 3);

-- 
-- Detalhes

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-003',      201,          3,     'Compe destino inválida', 'Conteúdo não numérico', 3);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      202,          3,     'Banco sacado inválido', 'Conteúdo não numérico ou diferente do banco do Header', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '007-010',      203,          3,     'Agência sacada inválida', 'Conteúdo não numérico', 3);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '011-011',      204,          3,     'DV2 inválido', 'Conteúdo não numérico', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',    '012-023',      205,          3,     'Conta sacada inválida', 'Conteúdo não numérico', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '024-024',      206,          3,     'DV1 inválido', 'Conteúdo não numérico', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '025-030',      207,          3,     'N° Documento inválido', 'Conteúdo não numérico', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '031-031',      208,          3,     'DV3 inválido', 'Conteúdo não numérico', 3);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('9',    '032-033',      209,          3,     'UF inválida', 'Valor não previsto', 3); 
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '034-050',      210,          3,     'Valor inválido', 'Conteúdo não numérico', 3);     

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',    '034-050',      211,          3,     'Valor incompatível', 'Valor zerado', 3);       

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',    '051-051',      212,          3,     'Tipificação inválida', 'Valor não previsto', 3);     
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',    '053-053',      226,          3,     'Caracteres binários', 'Caracteres binários em campos "Filler"', 3);         

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',    '054-055',      229,          3,     'Motivo devolução inválido', 'Conteúdo não numérico ou valor não previsto', 3);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',    '054-055',      232,          3,     'Motivo devolução incompatível', 'Motivo de devolução 14 utilizado indevidamente para cheque de valor superior ao CPA', 3);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',    '054-055',      237,          3,     'Motivo devolução inválido', 'Motivo de devolução inválido para a sessão de prevenção a fraudes e impedimentos.', 3);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',    '056-058',      213,          3,     'Banco apres. Inválido', 'Conteúdo não numérico ou diferente do banco destinatário do lote', 3); 

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',    '059-062',      214,          3,     'Agência apres. Inválida', 'Conteúdo não numérico', 3);   
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',    '063-066',      215,          3,     'N° Agenc. acolhedora Inválido', 'Conteúdo não numérico', 3);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('18',    '067-078',      216,          3,     'N° Conta acolhedora Depos. Inválido', 'Conteúdo não numérico', 3);    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('19',    '079-081',      226,          3,     'Caracteres binários', 'Caracteres binários em campos "Filler"', 3);   

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('20',    '082-089',      218,          3,     'Data inválida', 'Conteúdo não numérico', 3);   

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('21',    '090-096',      219,          3,     'N° do Lote inválido', 'Conteúdo não numérico', 3);     
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('22',    '097-099',      220,          3,     'N° seql. Lote inválido', 'Conteúdo não numérico', 3);       
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('24',    '106-130',      221,          3,     'N° Identificador inválido', 'Conteúdo não numérico ou igual a zeros', 3);         
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('25',    '131-140',      233,          3,     'Sequencial original inválido', 'Conteúdo não numérico ou diferente do conteúdo do campo 28', 3);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '141-147',      223,          3,     'Versão inválida', 'Conteúdo não numérico ou diferente da versão do Header', 3);    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('27',    '148-150',      224,          3,     'TD inválido', 'Conteúdo não numérico', 3);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('27',    '148-150',      225,          3,     'TD incompatível', 'Tipo de Documento incompatível com sessão de processamento', 3);    
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('28',    '151-160',      227,          3,     'Sequencial inválido', 'Conteúdo não numérico ou diferente do sequencial do registro no arquivo', 3);

COMMIT;

END;  
