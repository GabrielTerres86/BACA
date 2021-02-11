BEGIN
 -- Modalidade Header
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-020',      010,      1,            'Arquivo sem header', 'Arquivo sem registro com controle igual a zeros',  4);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '048-053',      030,      1,            'Nome do arquivo inv�lido', 'Conte�do n�o previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC',  4);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '027-029',      050,      1,           'Participante remetente inv�lido', 'Conte�do n�o num�rico ou igual a zero',  4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '027-029',      090,      1,           'Participante remetente n�o autorizado', 'Conte�do n�o previsto ou n�o autorizado no produto DOC/TEC, conforme Cadastro de Bancos Participantes',  4);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '030-030',      060,          1,     'DV participante remetente inv�lido', 'D�gito verificador do n�mero c�digo do participante remetente inv�lido',  4);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',    '031-038',      040,          1,     'Data inv�lida', 'Data divergente da data de movimento',  4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',    '031-038',      065,          1,     'Data n�o num�rica ou zerada', 'Conte�do n�o num�rico ou zerado',  4); 

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '039-041',      070,          1,     'Local de origem inv�lido', 'Conte�do n�o previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC',  4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '042-042',      052,          1,     'Indicador de remessa informado para grade de Troca inv�lido', 'Conte�do n�o previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC',  4);

INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '042-042',      053,          1,     'Indicador de remessa informado para grade Devolu��o inv�lido', 'Conte�do n�o previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC',  4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '043-049',      075,          1,     'Sequencial inv�lido', 'Conte�do n�o num�rico ou diferente de 1',  4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '043-049',      078,          1,     'Vers�o duplicada', 'Vers�o j� processada no movimento',  4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',    '248-255',      085,          1,     'Sequencial inv�lido', 'Conte�do n�o num�rico ou zerado',  4);  
  
--
-- Ocorrenvia de trailer

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-020',      015,          2,     'Arquivo sem trailer', 'Arquivo sem registro com controle igual a noves',  4);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '027-029',      050,          2,     'Participante remetente inv�lido', 'Conte�do n�o num�rico, zerado ou divergente do n�mero c�digo do remetente do arquivo', 4);
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '027-029',      063,          2,     'Participante inv�lido', 'Conte�do divergente do informado no header', 4);
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '027-029',      090,          2,     'Participante remetente n�o autorizado', 'Conte�do n�o previsto ou n�o autorizado no produto DOC/TEC, conforme Cadastro de Bancos Participantes', 4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '030-030',      060,          2,     'DV participante remetente inv�lido', 'D�gito verificador do n�mero c�digo do participante remetente inv�lido', 4);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '039-041',      070,          2,     'Local origem inv�lido', 'Conte�do n�o previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC', 4);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '043-049',      095,          2,     'Vers�o inv�lida', 'Conte�do divergente do informado no header', 4);    
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',    '248-255',      085,          2,     'Sequencial inv�lido', 'Conte�do n�o num�rico ou zerado', 4);    

-- 
-- Detalhes

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-003',      110,          3,     'Local destino inv�lido', 'Conte�do n�o previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC', 4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1 a 25',    '001-214',      190,          3,     'Devolu��o inv�lida', 'Devolu��o de registro n�o trocado', 4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1 a 25',    '001-214',      566,          3,     'Devolu��o fora do prazo', 'Devolu��o fora do prazo exceto para finalidade 15 (informativa)', 4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1 a 25',    '001-214',      567,          3,     'Devolu��o fora do prazo', 'Devolu��o fora do prazo para finalidade 15', 4);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      157,          3,     'Participante destinat�rio inv�lido', 'Conte�do n�o num�rico ou divergente do informado no header', 4);

INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '031-048',      180,          3,     'Valor zerado ou n�o num�rico', 'Conte�do n�o num�rico ou zerado', 4);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '031-048',      185,          3,     'Valor acima do permitido', 'Conte�do n�o previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC', 4);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',    '105-106',      160,          3,     'Finalidade n�o num�rica', 'Conte�do n�o num�rico', 4);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',    '118-120',      215,          3,     'Local origem inv�lido', 'Conte�do n�o previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC', 4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',    '121-123',      156,          3,     'Participante remetente inv�lido', 'Conte�do n�o num�rico ou zerado', 4);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',    '121-123',      198,          3,     'Participante remetente n�o autorizado', 'Conte�do n�o previsto ou n�o autorizado no produto DOC/TEC, conforme Cadastro de Bancos Participantes', 4);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('22, 24, 30',    '200-202 204-208 241-247',      248,          3,     'Detalhe com caracteres bin�rios', 'Conte�do com caracteres bin�rios', 4); 
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('23',    '203-203',      212,          3,     'Tipo de documento n�o num�rico', 'Conte�do n�o num�rico', 4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '215-222',      219,          3,     'Data inv�lida', 'Conte�do n�o num�rico ou n�o inferior � data de devolu��o', 4);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '215-222',      220,          3,     'Data inv�lida', 'Conte�do divergente do informado no header', 4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('28',    '230-238',      226,          3,     'Conte�do inv�lido', 'Conte�do diferente de brancos ou zeros', 4);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('29',    '239-240',      240,          3,     'Motivo de devolu��o inv�lido', 'Conte�do n�o previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC', 4);  
 
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('31',    '248-255',      230,          3,     'Sequencial n�o num�rico ou zerado', 'Conte�do n�o num�rico ou zerado', 4);  
  

COMMIT;

END;  
