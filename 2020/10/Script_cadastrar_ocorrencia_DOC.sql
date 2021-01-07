BEGIN
 -- Modalidade Header
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-020',      010,      1,            'Arquivo sem header', 'Arquivo sem registro com controle igual a zeros',  4);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '048-053',      030,      1,            'Nome do arquivo inválido', 'Conteúdo não previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC',  4);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '027-029',      050,      1,           'Participante remetente inválido', 'Conteúdo não numérico ou igual a zero',  4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '027-029',      090,      1,           'Participante remetente não autorizado', 'Conteúdo não previsto ou não autorizado no produto DOC/TEC, conforme Cadastro de Bancos Participantes',  4);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '030-030',      060,          1,     'DV participante remetente inválido', 'Dígito verificador do número código do participante remetente inválido',  4);        

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',    '031-038',      040,          1,     'Data inválida', 'Data divergente da data de movimento',  4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',    '031-038',      065,          1,     'Data não numérica ou zerada', 'Conteúdo não numérico ou zerado',  4); 

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '039-041',      070,          1,     'Local de origem inválido', 'Conteúdo não previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC',  4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '042-042',      052,          1,     'Indicador de remessa informado para grade de Troca inválido', 'Conteúdo não previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC',  4);

INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '042-042',      053,          1,     'Indicador de remessa informado para grade Devolução inválido', 'Conteúdo não previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC',  4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '043-049',      075,          1,     'Sequencial inválido', 'Conteúdo não numérico ou diferente de 1',  4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '043-049',      078,          1,     'Versão duplicada', 'Versão já processada no movimento',  4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',    '248-255',      085,          1,     'Sequencial inválido', 'Conteúdo não numérico ou zerado',  4);  
  
--
-- Ocorrenvia de trailer

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-020',      015,          2,     'Arquivo sem trailer', 'Arquivo sem registro com controle igual a noves',  4);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '027-029',      050,          2,     'Participante remetente inválido', 'Conteúdo não numérico, zerado ou divergente do número código do remetente do arquivo', 4);
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '027-029',      063,          2,     'Participante inválido', 'Conteúdo divergente do informado no header', 4);
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',    '027-029',      090,          2,     'Participante remetente não autorizado', 'Conteúdo não previsto ou não autorizado no produto DOC/TEC, conforme Cadastro de Bancos Participantes', 4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',    '030-030',      060,          2,     'DV participante remetente inválido', 'Dígito verificador do número código do participante remetente inválido', 4);  
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',    '039-041',      070,          2,     'Local origem inválido', 'Conteúdo não previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC', 4);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',    '043-049',      095,          2,     'Versão inválida', 'Conteúdo divergente do informado no header', 4);    
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',    '248-255',      085,          2,     'Sequencial inválido', 'Conteúdo não numérico ou zerado', 4);    

-- 
-- Detalhes

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',    '001-003',      110,          3,     'Local destino inválido', 'Conteúdo não previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC', 4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1 a 25',    '001-214',      190,          3,     'Devolução inválida', 'Devolução de registro não trocado', 4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1 a 25',    '001-214',      566,          3,     'Devolução fora do prazo', 'Devolução fora do prazo exceto para finalidade 15 (informativa)', 4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1 a 25',    '001-214',      567,          3,     'Devolução fora do prazo', 'Devolução fora do prazo para finalidade 15', 4);    

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',    '004-006',      157,          3,     'Participante destinatário inválido', 'Conteúdo não numérico ou divergente do informado no header', 4);

INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '031-048',      180,          3,     'Valor zerado ou não numérico', 'Conteúdo não numérico ou zerado', 4);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',    '031-048',      185,          3,     'Valor acima do permitido', 'Conteúdo não previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC', 4);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',    '105-106',      160,          3,     'Finalidade não numérica', 'Conteúdo não numérico', 4);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',    '118-120',      215,          3,     'Local origem inválido', 'Conteúdo não previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC', 4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',    '121-123',      156,          3,     'Participante remetente inválido', 'Conteúdo não numérico ou zerado', 4);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',    '121-123',      198,          3,     'Participante remetente não autorizado', 'Conteúdo não previsto ou não autorizado no produto DOC/TEC, conforme Cadastro de Bancos Participantes', 4);          
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('22, 24, 30',    '200-202 204-208 241-247',      248,          3,     'Detalhe com caracteres binários', 'Conteúdo com caracteres binários', 4); 
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('23',    '203-203',      212,          3,     'Tipo de documento não numérico', 'Conteúdo não numérico', 4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '215-222',      219,          3,     'Data inválida', 'Conteúdo não numérico ou não inferior à data de devolução', 4);
  
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('26',    '215-222',      220,          3,     'Data inválida', 'Conteúdo divergente do informado no header', 4);

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('28',    '230-238',      226,          3,     'Conteúdo inválido', 'Conteúdo diferente de brancos ou zeros', 4);  

 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('29',    '239-240',      240,          3,     'Motivo de devolução inválido', 'Conteúdo não previsto, conforme Manual dos Leiautes e Processamento de DOC e TEC', 4);  
 
 INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('31',    '248-255',      230,          3,     'Sequencial não numérico ou zerado', 'Conteúdo não numérico ou zerado', 4);  
  

COMMIT;

END;  
