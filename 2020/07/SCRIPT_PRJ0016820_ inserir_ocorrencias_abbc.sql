BEGIN

  -- COB605
  -- Ocorr�ncias de Header

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',        '001-047',                    03,01, 'Arquivo sem header',                  'Arquivo sem registro tipo header',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',        '048-053',                    01,01,  'Arquivo inv�lido',                    'Conte�do n�o previsto, conforme Manual dos Leiautes e Processamento da Cobran�a',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',        '054-060',                    10,01,  'Vers�o n�o num�rica',                 'Conte�do n�o num�rico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('3',        '054-060',                    12,01,  'Vers�o duplicada',                    'Vers�o j� processada no movimento',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4,7 e 9',  '061-064 074-131 140-150',    92,01,  'Registro com caracteres bin�rios',    'Conte�do com caracteres bin�rios',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',        '065-065',                    06,01,  'Tipo de remessa n�o num�rico',        'Conte�do n�o num�rico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('5',        '065-065',                    07,01,  'Tipo de remessa inv�lido',            'Conte�do n�o previsto, conforme Manual dos Leiautes e Processamento da Cobran�a',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',        '066-073',                    08,01,  'Data de movimento n�o num�rica',      'Conte�do n�o num�rico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',        '066-073',                    09,01,  'Data de movimento inv�lida',          'Conte�do divergente da data de movimento',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',        '132-139',                    04,01,  'Participante remetente n�o num�rico', 'Conte�do n�o num�rico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',        '132-139',                    05,01,  'Participante remetente inv�lido',    'Conte�do n�o previsto, conforme Cadastro de Bancos Participantes',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',        '132-139',                    13,01,  'Participante remetente divergente',   'Conte�do informado divergente do c�digo ISPB do remetente do arquivo',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',        '132-139',                    20,01,  'Participante n�o autorizado no REP',  'Participante n�o autorizado a participar do REP',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',       '151-160',                    14,01,  'Sequencial inv�lido',                 'Conte�do diferente de 1',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('10',       '151-160',                    15,01,  'Sequencial n�o num�rico',             'Conte�do n�o num�rico',01);

  -- COB605
  -- Ocorr�ncias de Trailer

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  (NULL,              NULL,                          16,02,      'Arquivo recusado',                  'Arquivo recusado',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',              '001-047',                      18,02,      'Arquivo sem trailer',               'Arquivo sem registro tipo trailer',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2, 3, 5, 6, 9',  '048-060 065-073 132-139',      11,02,      'Trailer divergente do header',      'Conte�do dos campos 2, 3, 5, 6 e/ou 9 divergentes dos campos correspondentes no registro tipo header',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4, 8 e 10',      '061-064 091-131 140-150',      92,02,      'Registro com caracteres bin�rios',  'Conte�do com caracteres bin�rios',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',              '074-090',                      82,02,      'Valor n�o num�rico',                'Conte�do n�o num�rico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',              '074-090',                      83,02,      'Valor inv�lido',                    'Conte�do divergente do somat�rio dos detalhes do arquivo',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',             '151-160',                      14,02,      'Sequencial inv�lido',               'Conte�do divergente da quantidade total de registros no arquivo',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',             '151-160',                      15,02,      'Sequencial n�o num�rico',           'Conte�do n�o num�rico',01);

  -- Ocorr�ncias de Detalhe

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1',              '001-044',                          90,03,      'C�digo de Barras inv�lido',            'Conte�do n�o num�rico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2, 3, 5 e 14',   '045-046 047-049 051-056 114-131',  92,03,      'Registro com caracteres bin�rios',     'Conte�do com caracteres bin�rios',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',              '050-050',                          65,03,      'Tipo de captura inv�lido',             'Conte�do n�o num�rico ou n�o previsto, conforme Manual dos Leiautes e Processamento da Cobran�a',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('6',              '057-060',                          72,03,      'Ag�ncia remetente n�o num�rica',       'Conte�do n�o num�rico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',              '061-067',                          73,03,      'N�mero do lote n�o num�rico',          'Conte�do n�o num�rico ou divergente do informado no fechamento de lote',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',              '068-070',                          77,03,      'Sequencial do lote inv�lido',          'Conte�do n�o num�rico ou divergente do sequencial do registro no lote',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('9',              '071-078',                          23,03,      'Data do movimento inv�lida' ,          'Conte�do n�o num�rico ou divergente do informado no header',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',             '085-096',                          82,03,      'Valor n�o num�rico'         ,          'Conte�do n�o num�rico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',             '085-096',                          83,03,      'Valor inv�lido'              ,         'Valor informado igual ou superior ao VR- Boleto, ou igual a zero',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',             '097-103',                          84,03,      'Vers�o inv�lida'              ,        'Conte�do divergente do informado no header',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',             '097-103',                          85,03,      'Vers�o n�o num�rica'          ,        'Conte�do n�o num�rico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',             '104-113',                          93,03,      'Sequencial de troca n�o num�rico' ,    'Conte�do n�o num�rico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('13',             '104-113',                          97,03,      'Sequencial de troca inv�lido'  ,       'Conte�do informado divergente do sequencial do registro no arquivo',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',             '132-139',                          70,03,      'Participante recebedor n�o num�rico',  'Conte�do n�o num�rico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',             '132-139',                          71,03,      'Participante recebedor inv�lido'  ,    'Conte�do informado divergente do c�digo ISPB informado no header',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',             '140-147',                          53,03,      'Participante favorecido n�o num�rico', 'Conte�do n�o num�rico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',             '140-147',                          54,03,      'Participante favorecido inv�lido',     'Conte�do informado divergente do n�mero c�digo ISPB informado no fechamento de lote (campo 15)',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',             '148-150',                          63,03,      'Tipo de documento n�o num�rico'  ,     'Conte�do n�o num�rico',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',             '148-150',                          64,03,      'Tipo de documento inv�lido'      ,     'Conte�do divergente do informado no fechamento de lote',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('18',             '151-160',                          14,03,      'Sequencial inv�lido'             ,     'Conte�do fora da sequ�ncia prevista',01);

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('18',             '151-160',                          15,03,      'Sequencial n�o num�rico'         ,     'Conte�do n�o num�rico',01);
  
  -- Ocorr�ncias de Fechamento de Lote

  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  (NULL,            NULL,                              29,04,      'Lote com mais de 400 detalhes',          'Quantidade de registros que comp�e o lote � superior a 400',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  (NULL,            NULL,                              32,04,      'Lote sem fechamento',                    'Registros detalhe sem o fechamento de lote correspondente',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  (NULL,            NULL,                              33,04,      'Lote sem detalhes',                      'Fechamento de lote sem registros detalhe correspondentes',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('1, 3, 6 e 13',  '001-006 032-033 054-060 094-131',  92,04,     'Registro com caracteres bin�rios',       'Conte�do com caracteres bin�rios',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('2',              '007-031',                          24,04,    'Controle inv�lido',                      'Conte�do diferente de noves',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',              '034-050',                          82,04,    'Valor n�o num�rico',                     'Conte�do n�o num�rico',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('4',              '034-050',                          83,04,      'Valor inv�lido',                       'Conte�do divergente do somat�rio dos detalhes do lote',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('7',              '061-067',                          21,04,      'N�mero do lote n�o num�rico',          'Conte�do n�o num�rico',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('8',              '068-070',                          22,04,      'Sequencial do lote n�o num�rico',      'Conte�do n�o num�rico ou fora da sequ�ncia',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('9',              '071-078',                          23,04,      'Data do movimento inv�lida',           'Conte�do n�o num�rico ou divergente do informado no header',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('11',             '085-091',                          37,04,      'Vers�o inv�lida',                      'Conte�do n�o num�rico ou divergente do informado no header',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('12',             '092-093',                          40,04,      'UF inv�lida',                          'Conte�do n�o previsto',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',             '132-139',                          70,04,      'Participante recebedor n�o num�rico',  'Conte�do n�o num�rico',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('14',             '132-139',                          71,04,      'Participante recebedor inv�lido',      'Conte�do informado divergente do c�digo ISPB informado no header',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',             '140-147',                          53,04,      'Participante favorecido n�o num�rico', 'Conte�do n�o num�rico',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('15',             '140-147',                          54,04,      'Participante favorecido inv�lido',     'Conte�do n�o previsto, conforme Cadastro de Bancos Participantes',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',             '148-150',                          63,04,      'Tipo de documento n�o num�rico',       'Conte�do n�o num�rico',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('16',             '148-150',                          64,04,      'Tipo de documento inv�lido',           'Conte�do n�o previsto, ou incompat�vel com a grade, conforme Manual dos Leiautes e Processamento da Cobran�a',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',             '151-160',                          14,04,      'Sequencial inv�lido',                  'Conte�do fora da sequ�ncia prevista',01);
  INSERT INTO tbcompe_tipo_ocorrencia
  (dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
  ('17',             '151-160',                          15,04,      'Sequencial n�o num�rico',              'Conte�do n�o num�rico',01);

-- Arquivo DVC605
-- Ocorr�ncias de Header

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
(NULL,           NULL,                              02,01,   'Arquivo aceito',                       'Arquivo sem ocorr�ncias de header e trailer',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('1',            '001-047',                         03,01,   'Arquivo sem header',                   'Arquivo sem registro tipo header',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('2',            '048-053',                         01,01,   'Arquivo inv�lido',                     'Conte�do n�o previsto, conforme Manual dos Leiautes e Processamento da Cobran�a',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('3',            '054-060',                         10,01,   'Vers�o n�o num�rica',                  'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('3',            '054-060',                         12,01,   'Vers�o duplicada',                     'Vers�o j� processada no movimento',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('4, 7 e 9',     '061-064 074-131 140-150',         92,01,   'Registro com caracteres bin�rios',     'Conte�do com caracteres bin�rios',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('5',            '065-065',                         06,01,   'Tipo de remessa n�o num�rico',         'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('5',            '065-065',                         07,01,   'Tipo de remessa inv�lido',             'Conte�do n�o previsto, conforme Manual dos Leiautes e Processamento da Cobran�a',02); 

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('6',            '066-073',                         08,01,   'Data de movimento n�o num�rica',       'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('6',            '066-073',                         09,01,   'Data de movimento inv�lida',           'Conte�do divergente da data de movimento',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('8',            '132-139',                         04,01,   'Participante remetente n�o num�rico',  'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('8',            '132-139',                         05,01,   'Participante remetente inv�lido',      'Conte�do n�o previsto, conforme Cadastro de Bancos Participantes',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('8',            '132-139',                         13,01,   'Participante remetente divergente',    'Conte�do informado divergente do c�digo ISPB do remetente do arquivo',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('10',           '151-160',                         14,01,   'Sequencial inv�lido',                  'Conte�do diferente de 1',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('10',           '151-160',                         15,01,   'Sequencial n�o num�rico',              'Conte�do n�o num�rico',02);



-- Ocorr�ncias de Trailer

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
(NULL,            NULL,                              16,02,  'Arquivo recusado',                    'Arquivo recusado',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('1',             '001-047',                         18,02,  'Arquivo sem trailer',                 'Arquivo sem registro tipo trailer',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('2, 3, 5, 6, 9', '048-060 065-073 132-139',         11,02,  'Trailer divergente do header',        'Conte�do dos campos 2, 3, 5, 6 e/ou 9 divergentes dos campos correspondentes no registro tipo header',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('4, 8 e 10',     '061-064 091-131 140-150',         92,02,  'Registro com caracteres bin�rios',    'Conte�do com caracteres bin�rios',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('7',             '074-090',                         82,02,  'Valor n�o num�rico',                  'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('7',             '074-090',                         83,02,  'Valor inv�lido',                      'Conte�do divergente do somat�rio dos detalhes do arquivo',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('11',            '151-160',                         14,02,  'Sequencial inv�lido',                 'Conte�do divergente da quantidade total de registros no arquivo',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('11',            '151-160',                         15,02,  'Sequencial n�o num�rico',             'Conte�do n�o num�rico',02);

--Ocorr�ncias de Detalhe

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('1, 4, 7 a 14, 16 e 17',  '001-044 050-050 057-113 132-147',  89,03,  'Campos n�o conferem',                 'Conte�do dos campos 1, 4, 7 a 14, 16 e 17 do arquivo DVC605 divergentes dos campos correspondentes no arquivo da troca',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('2, 3, 6 e 15',           '045-046 047-049 053-056 114-131',  92,03,  'Registro com caracteres bin�rios',    'Conte�do com caracteres bin�rios',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('5',                      '051-052',                          69,03,  'Motivo de devolu��o n�o num�rico',    'Conte�do n�o num�rico ou valor n�o previsto',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('7',                      '057-060',                          72,03,  'Ag�ncia remetente n�o num�rica',      'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('8',                      '061-067',                          73,03,  'N�mero do lote n�o num�rico',         'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('9',                      '068-070',                          77,03,  'Sequencial do lote inv�lido',         'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('10',                     '071-078',                          23,03,  'Data do movimento inv�lida',          'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('10',                     '071-078',                          87,03,  'Devolu��o fora do prazo',             'Data de movimento da troca anterior a cinco dias �teis',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('12',                     '085-096',                          82,03,  'Valor n�o num�rico',                  'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('13',                     '097-103',                          85,03,  'Vers�o n�o num�rica',                 'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('14',                     '104-113',                          93,03,  'Sequencial de troca n�o num�rico',    'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('16',                     '132-139',                          70,03,  'Participante recebedor n�o num�rico', 'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('16',                     '132-139',                          71,03,  'Participante recebedor inv�lido',     'Conte�do informado divergente do c�digo ISPB informado no fechamento de lote (campo 15)',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('17',                     '140-147',                          53,03,  'Participante favorecido n�o num�rico', 'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('17',                     '140-147',                          54,03,  'Participante favorecido inv�lido',     'Conte�do informado divergente do c�digo ISPB informado no header',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('18',                     '148-150',                          63,03,  'Tipo de documento n�o num�rico',       'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('18',                     '148-150',                          64,03,  'Tipo de documento inv�lido',           'Conte�do divergente do informado no fechamento de lote',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('19',                     '151-160',                           14,03,  'Sequencial inv�lido',                  'Conte�do fora da sequ�ncia prevista',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('19',                     '151-160',                           15,03,  'Sequencial n�o num�rico',              'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('19',                     '151-160',                           88,03,  'Registro n�o localizado',              'Registro n�o localizado no arquivo da troca',02);

-- Ocorr�ncias de Fechamento de Lote

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
(NULL,            NULL,                              29,04,  'Lote com mais de 400 detalhes',        'Quantidade de registros que comp�e o lote � superior a 400',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
(NULL,            NULL,                              32,04,  'Lote sem fechamento',                  'Registros detalhe sem o fechamento de lote correspondente',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
(NULL,            NULL,                              33,04,  'Lote sem detalhes',                    'Fechamento de lote sem registros detalhe correspondentes',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('1, 3, 6 e 13', '001-006 032-033 054-060 094-131',  92,04,  'Registro com caracteres bin�rios',     'Conte�do com caracteres bin�rios',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('2',            '007-031',                          24,04,  'Controle inv�lido',                    'Conte�do diferente de noves',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('4',            '034-050',                          82,04,  'Valor n�o num�rico',                   'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('4',            '034-050',                          83,04,  'Valor inv�lido',                       'Conte�do divergente do somat�rio dos detalhes do lote',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('7',            '061-067',                          21,04,  'N�mero do lote n�o num�rico',          'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('8',            '068-070',                          22,04,  'Sequencial do lote n�o num�rico',       'Conte�do n�o num�rico ou fora da sequ�ncia',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('9',            '071-078',                          23,04,  'Data do movimento inv�lida',           'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('11',           '085-091',                          37,04,  'Vers�o inv�lida',                      'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('12',           '092-093',                          40,04,  'UF inv�lida',                          'Conte�do n�o previsto',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('14',           '132-139',                          70,04,  'Participante recebedor n�o num�rico',  'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('14',           '132-139',                          71,04,  'Participante recebedor inv�lido',      'Conte�do n�o previsto, conforme Cadastro de Bancos Participantes',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('15',           '140-147',                          53,04,  'Participante favorecido n�o num�rico', 'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('15',           '140-147',                          54,04,  'Participante favorecido inv�lido',     'Conte�do informado divergente do c�digo ISPB informado no header',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('16',           '148-150',                           63,04,  'Tipo de documento n�o num�rico',       'Conte�do n�o num�rico',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('16',           '148-150',                           64,04,  'Tipo de documento inv�lido',           'Conte�do n�o previsto, ou incompat�vel com a grade, conforme Manual dos Leiautes e Processamento da Cobran�a',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('17',           '151-160',                          14,04,  'Sequencial inv�lido',                  'Conte�do fora da sequ�ncia prevista',02);

INSERT INTO tbcompe_tipo_ocorrencia
(dscampo, dsposicao, cdocorrencia, tpmodalidade, dsocorrencia, dscritic, tparquiv) VALUES
('17',           '151-160',                          15,04,  'Sequencial n�o num�rico',              'Conte�do n�o num�rico',02);
 
  COMMIT;
  
  dbms_output.put_line('Script rodou com sucesso' );
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Falha Script: '||SQLERRM);
END;






        
    

        
