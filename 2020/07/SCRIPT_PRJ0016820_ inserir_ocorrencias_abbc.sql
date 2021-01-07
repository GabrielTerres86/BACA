BEGIN

  -- COB605
  -- Ocorrências de Header

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',        '001-047',                    03,01, 'Arquivo sem header',                  'Arquivo sem registro tipo header',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',        '048-053',                    01,01,  'Arquivo inválido',                    'Conteúdo não previsto, conforme Manual dos Leiautes e Processamento da Cobrança',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',        '054-060',                    10,01,  'Versão não numérica',                 'Conteúdo não numérico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',        '054-060',                    12,01,  'Versão duplicada',                    'Versão já processada no movimento',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4,7 e 9',  '061-064 074-131 140-150',    92,01,  'Registro com caracteres binários',    'Conteúdo com caracteres binários',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',        '065-065',                    06,01,  'Tipo de remessa não numérico',        'Conteúdo não numérico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',        '065-065',                    07,01,  'Tipo de remessa inválido',            'Conteúdo não previsto, conforme Manual dos Leiautes e Processamento da Cobrança',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',        '066-073',                    08,01,  'Data de movimento não numérica',      'Conteúdo não numérico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',        '066-073',                    09,01,  'Data de movimento inválida',          'Conteúdo divergente da data de movimento',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',        '132-139',                    04,01,  'Participante remetente não numérico', 'Conteúdo não numérico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',        '132-139',                    05,01,  'Participante remetente inválido',    'Conteúdo não previsto, conforme Cadastro de Bancos Participantes',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',        '132-139',                    13,01,  'Participante remetente divergente',   'Conteúdo informado divergente do código ISPB do remetente do arquivo',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',        '132-139',                    20,01,  'Participante não autorizado no REP',  'Participante não autorizado a participar do REP',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',       '151-160',                    14,01,  'Sequencial inválido',                 'Conteúdo diferente de 1',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',       '151-160',                    15,01,  'Sequencial não numérico',             'Conteúdo não numérico',01);

  -- COB605
  -- Ocorrências de Trailer

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  (NULL,              NULL,                          16,02,      'Arquivo recusado',                  'Arquivo recusado',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',              '001-047',                      18,02,      'Arquivo sem trailer',               'Arquivo sem registro tipo trailer',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2, 3, 5, 6, 9',  '048-060 065-073 132-139',      11,02,      'Trailer divergente do header',      'Conteúdo dos campos 2, 3, 5, 6 e/ou 9 divergentes dos campos correspondentes no registro tipo header',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4, 8 e 10',      '061-064 091-131 140-150',      92,02,      'Registro com caracteres binários',  'Conteúdo com caracteres binários',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',              '074-090',                      82,02,      'Valor não numérico',                'Conteúdo não numérico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',              '074-090',                      83,02,      'Valor inválido',                    'Conteúdo divergente do somatório dos detalhes do arquivo',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',             '151-160',                      14,02,      'Sequencial inválido',               'Conteúdo divergente da quantidade total de registros no arquivo',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',             '151-160',                      15,02,      'Sequencial não numérico',           'Conteúdo não numérico',01);

  -- Ocorrências de Detalhe

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',              '001-044',                          90,03,      'Código de Barras inválido',            'Conteúdo não numérico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2, 3, 5 e 14',   '045-046 047-049 051-056 114-131',  92,03,      'Registro com caracteres binários',     'Conteúdo com caracteres binários',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',              '050-050',                          65,03,      'Tipo de captura inválido',             'Conteúdo não numérico ou não previsto, conforme Manual dos Leiautes e Processamento da Cobrança',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',              '057-060',                          72,03,      'Agência remetente não numérica',       'Conteúdo não numérico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',              '061-067',                          73,03,      'Número do lote não numérico',          'Conteúdo não numérico ou divergente do informado no fechamento de lote',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',              '068-070',                          77,03,      'Sequencial do lote inválido',          'Conteúdo não numérico ou divergente do sequencial do registro no lote',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('9',              '071-078',                          23,03,      'Data do movimento inválida' ,          'Conteúdo não numérico ou divergente do informado no header',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',             '085-096',                          82,03,      'Valor não numérico'         ,          'Conteúdo não numérico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',             '085-096',                          83,03,      'Valor inválido'              ,         'Valor informado igual ou superior ao VR- Boleto, ou igual a zero',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',             '097-103',                          84,03,      'Versão inválida'              ,        'Conteúdo divergente do informado no header',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',             '097-103',                          85,03,      'Versão não numérica'          ,        'Conteúdo não numérico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',             '104-113',                          93,03,      'Sequencial de troca não numérico' ,    'Conteúdo não numérico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',             '104-113',                          97,03,      'Sequencial de troca inválido'  ,       'Conteúdo informado divergente do sequencial do registro no arquivo',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',             '132-139',                          70,03,      'Participante recebedor não numérico',  'Conteúdo não numérico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',             '132-139',                          71,03,      'Participante recebedor inválido'  ,    'Conteúdo informado divergente do código ISPB informado no header',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',             '140-147',                          53,03,      'Participante favorecido não numérico', 'Conteúdo não numérico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',             '140-147',                          54,03,      'Participante favorecido inválido',     'Conteúdo informado divergente do número código ISPB informado no fechamento de lote (campo 15)',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',             '148-150',                          63,03,      'Tipo de documento não numérico'  ,     'Conteúdo não numérico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',             '148-150',                          64,03,      'Tipo de documento inválido'      ,     'Conteúdo divergente do informado no fechamento de lote',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('18',             '151-160',                          14,03,      'Sequencial inválido'             ,     'Conteúdo fora da sequência prevista',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('18',             '151-160',                          15,03,      'Sequencial não numérico'         ,     'Conteúdo não numérico',01);
  
  -- Ocorrências de Fechamento de Lote

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  (NULL,            NULL,                              29,04,      'Lote com mais de 400 detalhes',          'Quantidade de registros que compõe o lote é superior a 400',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  (NULL,            NULL,                              32,04,      'Lote sem fechamento',                    'Registros detalhe sem o fechamento de lote correspondente',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  (NULL,            NULL,                              33,04,      'Lote sem detalhes',                      'Fechamento de lote sem registros detalhe correspondentes',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1, 3, 6 e 13',  '001-006 032-033 054-060 094-131',  92,04,     'Registro com caracteres binários',       'Conteúdo com caracteres binários',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',              '007-031',                          24,04,    'Controle inválido',                      'Conteúdo diferente de noves',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',              '034-050',                          82,04,    'Valor não numérico',                     'Conteúdo não numérico',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',              '034-050',                          83,04,      'Valor inválido',                       'Conteúdo divergente do somatório dos detalhes do lote',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',              '061-067',                          21,04,      'Número do lote não numérico',          'Conteúdo não numérico',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',              '068-070',                          22,04,      'Sequencial do lote não numérico',      'Conteúdo não numérico ou fora da sequência',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('9',              '071-078',                          23,04,      'Data do movimento inválida',           'Conteúdo não numérico ou divergente do informado no header',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',             '085-091',                          37,04,      'Versão inválida',                      'Conteúdo não numérico ou divergente do informado no header',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',             '092-093',                          40,04,      'UF inválida',                          'Conteúdo não previsto',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',             '132-139',                          70,04,      'Participante recebedor não numérico',  'Conteúdo não numérico',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',             '132-139',                          71,04,      'Participante recebedor inválido',      'Conteúdo informado divergente do código ISPB informado no header',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',             '140-147',                          53,04,      'Participante favorecido não numérico', 'Conteúdo não numérico',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',             '140-147',                          54,04,      'Participante favorecido inválido',     'Conteúdo não previsto, conforme Cadastro de Bancos Participantes',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',             '148-150',                          63,04,      'Tipo de documento não numérico',       'Conteúdo não numérico',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',             '148-150',                          64,04,      'Tipo de documento inválido',           'Conteúdo não previsto, ou incompatível com a grade, conforme Manual dos Leiautes e Processamento da Cobrança',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',             '151-160',                          14,04,      'Sequencial inválido',                  'Conteúdo fora da sequência prevista',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',             '151-160',                          15,04,      'Sequencial não numérico',              'Conteúdo não numérico',01);

-- Arquivo DVC605
-- Ocorrências de Header

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
(NULL,           NULL,                              02,01,   'Arquivo aceito',                       'Arquivo sem ocorrências de header e trailer',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('1',            '001-047',                         03,01,   'Arquivo sem header',                   'Arquivo sem registro tipo header',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('2',            '048-053',                         01,01,   'Arquivo inválido',                     'Conteúdo não previsto, conforme Manual dos Leiautes e Processamento da Cobrança',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('3',            '054-060',                         10,01,   'Versão não numérica',                  'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('3',            '054-060',                         12,01,   'Versão duplicada',                     'Versão já processada no movimento',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('4, 7 e 9',     '061-064 074-131 140-150',         92,01,   'Registro com caracteres binários',     'Conteúdo com caracteres binários',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('5',            '065-065',                         06,01,   'Tipo de remessa não numérico',         'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('5',            '065-065',                         07,01,   'Tipo de remessa inválido',             'Conteúdo não previsto, conforme Manual dos Leiautes e Processamento da Cobrança',02); 

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('6',            '066-073',                         08,01,   'Data de movimento não numérica',       'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('6',            '066-073',                         09,01,   'Data de movimento inválida',           'Conteúdo divergente da data de movimento',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('8',            '132-139',                         04,01,   'Participante remetente não numérico',  'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('8',            '132-139',                         05,01,   'Participante remetente inválido',      'Conteúdo não previsto, conforme Cadastro de Bancos Participantes',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('8',            '132-139',                         13,01,   'Participante remetente divergente',    'Conteúdo informado divergente do código ISPB do remetente do arquivo',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('10',           '151-160',                         14,01,   'Sequencial inválido',                  'Conteúdo diferente de 1',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('10',           '151-160',                         15,01,   'Sequencial não numérico',              'Conteúdo não numérico',02);



-- Ocorrências de Trailer

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
(NULL,            NULL,                              16,02,  'Arquivo recusado',                    'Arquivo recusado',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('1',             '001-047',                         18,02,  'Arquivo sem trailer',                 'Arquivo sem registro tipo trailer',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('2, 3, 5, 6, 9', '048-060 065-073 132-139',         11,02,  'Trailer divergente do header',        'Conteúdo dos campos 2, 3, 5, 6 e/ou 9 divergentes dos campos correspondentes no registro tipo header',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('4, 8 e 10',     '061-064 091-131 140-150',         92,02,  'Registro com caracteres binários',    'Conteúdo com caracteres binários',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('7',             '074-090',                         82,02,  'Valor não numérico',                  'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('7',             '074-090',                         83,02,  'Valor inválido',                      'Conteúdo divergente do somatório dos detalhes do arquivo',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('11',            '151-160',                         14,02,  'Sequencial inválido',                 'Conteúdo divergente da quantidade total de registros no arquivo',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('11',            '151-160',                         15,02,  'Sequencial não numérico',             'Conteúdo não numérico',02);

--Ocorrências de Detalhe

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('1, 4, 7 a 14, 16 e 17',  '001-044 050-050 057-113 132-147',  89,03,  'Campos não conferem',                 'Conteúdo dos campos 1, 4, 7 a 14, 16 e 17 do arquivo DVC605 divergentes dos campos correspondentes no arquivo da troca',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('2, 3, 6 e 15',           '045-046 047-049 053-056 114-131',  92,03,  'Registro com caracteres binários',    'Conteúdo com caracteres binários',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('5',                      '051-052',                          69,03,  'Motivo de devolução não numérico',    'Conteúdo não numérico ou valor não previsto',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('7',                      '057-060',                          72,03,  'Agência remetente não numérica',      'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('8',                      '061-067',                          73,03,  'Número do lote não numérico',         'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('9',                      '068-070',                          77,03,  'Sequencial do lote inválido',         'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('10',                     '071-078',                          23,03,  'Data do movimento inválida',          'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('10',                     '071-078',                          87,03,  'Devolução fora do prazo',             'Data de movimento da troca anterior a cinco dias úteis',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('12',                     '085-096',                          82,03,  'Valor não numérico',                  'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('13',                     '097-103',                          85,03,  'Versão não numérica',                 'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('14',                     '104-113',                          93,03,  'Sequencial de troca não numérico',    'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('16',                     '132-139',                          70,03,  'Participante recebedor não numérico', 'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('16',                     '132-139',                          71,03,  'Participante recebedor inválido',     'Conteúdo informado divergente do código ISPB informado no fechamento de lote (campo 15)',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('17',                     '140-147',                          53,03,  'Participante favorecido não numérico', 'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('17',                     '140-147',                          54,03,  'Participante favorecido inválido',     'Conteúdo informado divergente do código ISPB informado no header',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('18',                     '148-150',                          63,03,  'Tipo de documento não numérico',       'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('18',                     '148-150',                          64,03,  'Tipo de documento inválido',           'Conteúdo divergente do informado no fechamento de lote',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('19',                     '151-160',                           14,03,  'Sequencial inválido',                  'Conteúdo fora da sequência prevista',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('19',                     '151-160',                           15,03,  'Sequencial não numérico',              'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('19',                     '151-160',                           88,03,  'Registro não localizado',              'Registro não localizado no arquivo da troca',02);

-- Ocorrências de Fechamento de Lote

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
(NULL,            NULL,                              29,04,  'Lote com mais de 400 detalhes',        'Quantidade de registros que compõe o lote é superior a 400',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
(NULL,            NULL,                              32,04,  'Lote sem fechamento',                  'Registros detalhe sem o fechamento de lote correspondente',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
(NULL,            NULL,                              33,04,  'Lote sem detalhes',                    'Fechamento de lote sem registros detalhe correspondentes',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('1, 3, 6 e 13', '001-006 032-033 054-060 094-131',  92,04,  'Registro com caracteres binários',     'Conteúdo com caracteres binários',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('2',            '007-031',                          24,04,  'Controle inválido',                    'Conteúdo diferente de noves',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('4',            '034-050',                          82,04,  'Valor não numérico',                   'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('4',            '034-050',                          83,04,  'Valor inválido',                       'Conteúdo divergente do somatório dos detalhes do lote',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('7',            '061-067',                          21,04,  'Número do lote não numérico',          'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('8',            '068-070',                          22,04,  'Sequencial do lote não numérico',       'Conteúdo não numérico ou fora da sequência',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('9',            '071-078',                          23,04,  'Data do movimento inválida',           'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('11',           '085-091',                          37,04,  'Versão inválida',                      'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('12',           '092-093',                          40,04,  'UF inválida',                          'Conteúdo não previsto',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('14',           '132-139',                          70,04,  'Participante recebedor não numérico',  'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('14',           '132-139',                          71,04,  'Participante recebedor inválido',      'Conteúdo não previsto, conforme Cadastro de Bancos Participantes',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('15',           '140-147',                          53,04,  'Participante favorecido não numérico', 'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('15',           '140-147',                          54,04,  'Participante favorecido inválido',     'Conteúdo informado divergente do código ISPB informado no header',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('16',           '148-150',                           63,04,  'Tipo de documento não numérico',       'Conteúdo não numérico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('16',           '148-150',                           64,04,  'Tipo de documento inválido',           'Conteúdo não previsto, ou incompatível com a grade, conforme Manual dos Leiautes e Processamento da Cobrança',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('17',           '151-160',                          14,04,  'Sequencial inválido',                  'Conteúdo fora da sequência prevista',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('17',           '151-160',                          15,04,  'Sequencial não numérico',              'Conteúdo não numérico',02);
 
  COMMIT;
  
  dbms_output.put_line('Script rodou com sucesso' );
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Falha Script: '||SQLERRM);
END;






        
    

        
