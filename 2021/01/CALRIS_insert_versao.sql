declare

l_sequ  craprdr.NRSEQRDR%type;

begin

insert into TBCALRIS_PARAMETROS (DSCALRIS, INPESSOA, TPCOOPERADO, DHCADASTRO, DHLIBERACAO, CDSITUACAO, CDUSUARIO, DHFIMVIGENCIA, QTLIBERACOES)
values ('PF Novo', 1, 'N', SYSDATE, SYSDATE, 2, '1', null, 2);

insert into TBCALRIS_PARAMETROS (DSCALRIS, INPESSOA, TPCOOPERADO, DHCADASTRO, DHLIBERACAO, CDSITUACAO, CDUSUARIO, DHFIMVIGENCIA, QTLIBERACOES)
values ('PJ Novo', 2, 'N', SYSDATE, SYSDATE, 2, '1', null, 2);

insert into TBCALRIS_PARAMETROS (DSCALRIS, INPESSOA, TPCOOPERADO, DHCADASTRO, DHLIBERACAO, CDSITUACAO, CDUSUARIO, DHFIMVIGENCIA, QTLIBERACOES)
values ('PF Legado', 1, 'L', SYSDATE, SYSDATE, 2, '1', null, 2);

insert into TBCALRIS_PARAMETROS (DSCALRIS, INPESSOA, TPCOOPERADO, DHCADASTRO, DHLIBERACAO, CDSITUACAO, CDUSUARIO, DHFIMVIGENCIA, QTLIBERACOES)
values ('PJ Legado', 2, 'L', SYSDATE, SYSDATE, 2, '1', null, 2);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('DATA_NASCIMENTO', 'Risco atribuído por faixa de idade', 1, 0, 'Somente considerar se a IF entender que nos casos comunicados ao COAF este item tem representatividade');

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('OCUPACAO', 'Risco atribuído conforme ocupação profissional', 1, 1, null);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('RENDA', 'Risco atribuído por faixa de renda', 1, 0, null);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('CONFIABILIDADE_RENDA', 'Risco atribuído pela origem de informação da renda', 1, 2, null);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('CEP', 'Risco atribuído conforme local de residência', 1, 1, null);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('ABERTURA_RELACIONAMENTO', 'Risco atribuído pela origem do canal de abertura do relacionamento', 1, 2, null);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('ABERTURA_PROCURADOR', 'Risco atribuído pelo motivo de representação por procurador', 1, 2, null);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('DATA_CONSTITUICAO', 'Risco atribuído por tempo de existência', 2, 0, null);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('ATIVIDADE', 'Risco atribuído conforme ramo de atividade', 2, 1, null);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('FATURAMENTO_BRUTO', 'Risco atribuído por faixa de faturamento', 2, 0, null);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('FATURAMENTO_SETOR_PUBLICO', 'Risco se possui faturamento com setor público', 2, 2, 'Possibilidade de diferenciar o risco pelo % de faturamento com o setor público');

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('CONFIABILIDADE_FAT', 'Risco atribuído pela origem de informação do faturamento', 2, 2, null);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('IMPORTADOR_EXPORTADOR', 'Risco em função de operações de câmbio', 2, 2, null);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('ABERTURA_RELACIONAMENT_PJ', 'Risco atribuído pela origem do canal de abertura do relacionamento', 2, 2, null);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('CEP_PJ', 'Risco atribuído conforme localização', 2, 1, null);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Menor que [MIN]', 'DATA_NASCIMENTO', 4, '<');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('De [MIN] a [MAX]', 'DATA_NASCIMENTO', 3, 'BETWEEN');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('De [MIN] a [MAX]', 'DATA_NASCIMENTO', 2, 'BETWEEN');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Maior que [MAX]', 'DATA_NASCIMENTO', 1, '>');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO)
values ('De acordo com a tabela Ocupação', 'OCUPACAO', 0);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Maior que [MAX]', 'RENDA', 4, '>');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('De [MIN] a [MAX]', 'RENDA', 3, 'BETWEEN');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('De [MIN] a [MAX]', 'RENDA', 2, 'BETWEEN');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Menor que [MIN]', 'RENDA', 1, '<');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Fornecido pelo Cliente - Renda Declarada', 'CONFIABILIDADE_RENDA', 4, 1);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Coletada em Bureau', 'CONFIABILIDADE_RENDA', 3, 2);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Renda presumida modelo próprio', 'CONFIABILIDADE_RENDA', 2, 3);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Renda comprovada', 'CONFIABILIDADE_RENDA', 1, 4);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO)
values ('Tabela de Risco por CEP', 'CEP', 0);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Correspondente Região de Risco', 'ABERTURA_RELACIONAMENTO', 4, 4);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Correspondente', 'ABERTURA_RELACIONAMENTO', 3, 3);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Digital (Via Internet ou App)', 'ABERTURA_RELACIONAMENTO', 2, 2);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Presencial', 'ABERTURA_RELACIONAMENTO', 1, 1);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Representado Capaz', 'ABERTURA_PROCURADOR', 4, 2);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Representado Incapaz', 'ABERTURA_PROCURADOR', 3, 3);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Representado Absolutamente Incapaz', 'ABERTURA_PROCURADOR', 2, 4);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Sem representante', 'ABERTURA_PROCURADOR', 1, 1);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Menor que [MIN]', 'DATA_CONSTITUICAO', 4, '<');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('De [MIN] a [MAX]', 'DATA_CONSTITUICAO', 3, 'BETWEEN');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('De [MIN] a [MAX]', 'DATA_CONSTITUICAO', 2, 'BETWEEN');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Maior que [MAX]', 'DATA_CONSTITUICAO', 1, '>');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO)
values ('De acordo com a tabela Ocupação', 'ATIVIDADE', 0);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Maior que [MAX]', 'FATURAMENTO_BRUTO', 4, '>');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('De [MIN] a [MAX]', 'FATURAMENTO_BRUTO', 3, 'BETWEEN');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('De [MIN] a [MAX]', 'FATURAMENTO_BRUTO', 2, 'BETWEEN');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Menor que [MIN]', 'FATURAMENTO_BRUTO', 1, '<');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Possui', 'FATURAMENTO_SETOR_PUBLICO', 3, 'S');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Não possui', 'FATURAMENTO_SETOR_PUBLICO', 1, 'N');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Fornecido pelo Cliente - Fatur. Declarado', 'CONFIABILIDADE_FAT', 4, 1);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Coletado em Bureau', 'CONFIABILIDADE_FAT', 3, 2);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Declaração do Contador', 'CONFIABILIDADE_FAT', 2, 3);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Demonstrações Financeiras', 'CONFIABILIDADE_FAT', 1, 4);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Sim', 'IMPORTADOR_EXPORTADOR', 3, 'S');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Não', 'IMPORTADOR_EXPORTADOR', 1, 'N');

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Correspondente Região de Risco', 'ABERTURA_RELACIONAMENT_PJ', 4, 4);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Correspondente', 'ABERTURA_RELACIONAMENT_PJ', 3, 3);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Digital (Via Internet ou App)', 'ABERTURA_RELACIONAMENT_PJ', 2, 2);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Presencial', 'ABERTURA_RELACIONAMENT_PJ', 1, 1);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO)
values ('Tabela de Risco por CEP', 'CEP_PJ', 0);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (1, 10, 26, 0, 1, 1, 4, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (1, 10, 26, 35, 1, 2, 3, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (1, 10, 36, 55, 1, 3, 2, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (1, 10, 0, 55, 1, 4, 1, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (2, 30, 0, 0, 1, 5, 0, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (3, 20, 0, 30000, 1, 6, 4, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (3, 20, 15000, 30000, 1, 7, 3, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (3, 20, 5000, 15000, 1, 8, 2, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (3, 20, 5000, 0, 1, 9, 1, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (4, 20, 0, 0, 1, 10, 4, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (4, 20, 0, 0, 1, 11, 3, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (4, 20, 0, 0, 1, 12, 2, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (4, 20, 0, 0, 1, 13, 1, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (5, 30, 0, 0, 1, 14, 0, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (6, 10, 0, 0, 1, 15, 4, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (6, 10, 0, 0, 1, 16, 3, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (6, 10, 0, 0, 1, 17, 2, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (6, 10, 0, 0, 1, 18, 1, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (7, 30, 0, 0, 1, 19, 4, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (7, 30, 0, 0, 1, 20, 3, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (7, 30, 0, 0, 1, 21, 2, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (7, 30, 0, 0, 1, 22, 1, 1);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (8, 30, 1, 0, 1, 23, 4, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (8, 30, 1, 3, 1, 24, 3, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (8, 30, 3, 5, 1, 25, 2, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (8, 30, 0, 5, 1, 26, 1, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (9, 30, 0, 0, 1, 27, 0, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (10, 20, 0, 4800000, 1, 28, 4, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (10, 20, 1800000, 4800000, 1, 29, 3, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (10, 20, 360000, 1800000, 1, 30, 2, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (10, 20, 360000, 0, 1, 31, 1, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (11, 20, 0, 0, 1, 32, 3, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (11, 20, 0, 0, 1, 33, 1, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (12, 20, 0, 0, 1, 34, 4, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (12, 20, 0, 0, 1, 35, 3, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (12, 20, 0, 0, 1, 36, 2, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (12, 20, 0, 0, 1, 37, 1, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (13, 20, 0, 0, 1, 38, 3, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (13, 20, 0, 0, 1, 39, 1, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (14, 10, 0, 0, 1, 40, 4, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (14, 10, 0, 0, 1, 41, 3, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (14, 10, 0, 0, 1, 42, 2, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (14, 10, 0, 0, 1, 43, 1, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (15, 30, 0, 0, 1, 44, 0, 2);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (1, 10, 26, 0, 1, 1, 4, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (1, 10, 26, 35, 1, 2, 3, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (1, 10, 36, 55, 1, 3, 2, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (1, 10, 0, 55, 1, 4, 1, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (2, 30, 0, 0, 1, 5, 0, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (3, 20, 0, 30000, 1, 6, 4, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (3, 20, 15000, 30000, 1, 7, 3, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (3, 20, 5000, 15000, 1, 8, 2, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (3, 20, 5000, 0, 1, 9, 1, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (4, 20, 0, 0, 1, 10, 4, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (4, 20, 0, 0, 1, 11, 3, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (4, 20, 0, 0, 1, 12, 2, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (4, 20, 0, 0, 1, 13, 1, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (5, 30, 0, 0, 1, 14, 0, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (6, 10, 0, 0, 1, 15, 4, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (6, 10, 0, 0, 1, 16, 3, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (6, 10, 0, 0, 1, 17, 2, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (6, 10, 0, 0, 1, 18, 1, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (7, 30, 0, 0, 1, 19, 4, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (7, 30, 0, 0, 1, 20, 3, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (7, 30, 0, 0, 1, 21, 2, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (7, 30, 0, 0, 1, 22, 1, 3);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (8, 30, 1, 0, 1, 23, 4, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (8, 30, 1, 3, 1, 24, 3, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (8, 30, 3, 5, 1, 25, 2, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (8, 30, 0, 5, 1, 26, 1, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (9, 30, 0, 0, 1, 27, 0, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (10, 20, 0, 4800000, 1, 28, 4, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (10, 20, 1800000, 4800000, 1, 29, 3, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (10, 20, 360000, 1800000, 1, 30, 2, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (10, 20, 360000, 0, 1, 31, 1, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (11, 20, 0, 0, 1, 32, 3, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (11, 20, 0, 0, 1, 33, 1, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (12, 20, 0, 0, 1, 34, 4, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (12, 20, 0, 0, 1, 35, 3, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (12, 20, 0, 0, 1, 36, 2, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (12, 20, 0, 0, 1, 37, 1, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (13, 20, 0, 0, 1, 38, 3, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (13, 20, 0, 0, 1, 39, 1, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (14, 10, 0, 0, 1, 40, 4, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (14, 10, 0, 0, 1, 41, 3, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (14, 10, 0, 0, 1, 42, 2, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (14, 10, 0, 0, 1, 43, 1, 4);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (15, 30, 0, 0, 1, 44, 0, 4);

insert into TBCALRIS_ALCADA (CDUSUARIO, DHALTERACAO, CDACAO, IDCALRIS)
values ('1', SYSDATE, '1', 1);

insert into TBCALRIS_ALCADA (CDUSUARIO, DHALTERACAO, CDACAO, IDCALRIS)
values ('1', SYSDATE, '1', 1);

insert into TBCALRIS_ALCADA (CDUSUARIO, DHALTERACAO, CDACAO, IDCALRIS)
values ('1', SYSDATE, '1', 2);

insert into TBCALRIS_ALCADA (CDUSUARIO, DHALTERACAO, CDACAO, IDCALRIS)
values ('1', SYSDATE, '1', 2);

insert into TBCALRIS_ALCADA (CDUSUARIO, DHALTERACAO, CDACAO, IDCALRIS)
values ('1', SYSDATE, '1', 3);

insert into TBCALRIS_ALCADA (CDUSUARIO, DHALTERACAO, CDACAO, IDCALRIS)
values ('1', SYSDATE, '1', 3);

insert into TBCALRIS_ALCADA (CDUSUARIO, DHALTERACAO, CDACAO, IDCALRIS)
values ('1', SYSDATE, '1', 4);

insert into TBCALRIS_ALCADA (CDUSUARIO, DHALTERACAO, CDACAO, IDCALRIS)
values ('1', SYSDATE, '1', 4);

begin
	insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
	values ('CALRIS', 5, 'C,A,M', 'CALCULO RISCO', 'CALCULO RISCO', 0, 1, ' ', 'CONSULTAR,ALTERAR,MANUTENCAO', 1, 3, 1, 0, 1, 1, ' ', 2);

	insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
	values ('RISPAR', 5, '@,C,A,D', 'Consulta e Gerenciamento dos Parâmetros de Risco', 'Parâmetros de Risco', 0, 1, ' ', 'ACESSO,CONSULTA,ALTERACAO,DEFERIR', 2, 3, 1, 0, 0, 0, ' ', 0);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'CALRIS', 'CALCULO RISCO', '.', '.', '.', 10014, 0, 1, 0, 0, 0, 0, 0, 1, 2, null);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'CALRIS', 'CALCULO RISCO', '.', '.', '.', 10014, 0, 1, 0, 0, 0, 0, 0, 1, 3, null);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'CALRIS', 'CALCULO RISCO', '.', '.', '.', 10014, 0, 1, 0, 0, 0, 0, 0, 1, 5, null);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'CALRIS', 'CALCULO RISCO', '.', '.', '.', 10014, 0, 1, 0, 0, 0, 0, 0, 1, 6, null);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'CALRIS', 'CALCULO RISCO', '.', '.', '.', 10014, 0, 1, 0, 0, 0, 0, 0, 1, 7, null);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'CALRIS', 'CALCULO RISCO', '.', '.', '.', 10014, 0, 1, 0, 0, 0, 0, 0, 1, 8, null);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'CALRIS', 'CALCULO RISCO', '.', '.', '.', 10014, 0, 1, 0, 0, 0, 0, 0, 1, 14, null);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'CALRIS', 'CALCULO RISCO', '.', '.', '.', 10014, 0, 1, 0, 0, 0, 0, 0, 1, 16, null);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'CALRIS', 'CALCULO RISCO', '.', '.', '.', 10014, 0, 1, 0, 0, 0, 0, 0, 1, 10, null);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'CALRIS', 'CALCULO RISCO', '.', '.', '.', 10014, 0, 1, 0, 0, 0, 0, 0, 1, 11, null);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'CALRIS', 'CALCULO RISCO', '.', '.', '.', 10014, 0, 1, 0, 0, 0, 0, 0, 1, 12, null);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'CALRIS', 'CALCULO RISCO', '.', '.', '.', 10014, 0, 1, 0, 0, 0, 0, 0, 1, 9, null);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'CALRIS', 'CALCULO RISCO', '.', '.', '.', 10014, 0, 1, 0, 0, 0, 0, 0, 1, 13, null);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'CALRIS', 'CALCULO RISCO', '.', '.', '.', 10014, 0, 1, 0, 0, 0, 0, 0, 1, 1, null);

	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'RISPAR', 'Consulta e Gerenciamento dos Parâmetros de Risco', null, null, null, 990, 998, 1, 0, 0, 0, 0, 0, 0, 3, null);

	insert into craprdr (NMPROGRA, DTSOLICI)
	values ('TELA_CALRIS', TRUNC(SYSDATE)) RETURNING NRSEQRDR INTO l_sequ;

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('LISTA_RISCO_CALRIS', 'TELA_CALRIS', 'pc_lista_versao', 'pr_inpessoa,pr_tpcooperado,pr_cdsituacao', l_sequ);

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('BUSCA_RISCO_CALRIS', 'TELA_CALRIS', 'pc_busca_versao', 'pr_idcalris', l_sequ);

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('GRAVA_RISCO_CALRIS', 'TELA_CALRIS', 'pc_grava_versao', 'pr_dsversao,pr_inpessoa,pr_tpcooperado,pr_dsjustificativa,pr_risco1,pr_risco2,pr_risco3,pr_risco4,pr_risco5,pr_risco6,pr_risco7,pr_risco8,pr_risco9,pr_risco10,pr_risco11,pr_risco12,pr_risco13,pr_risco14,pr_risco15,pr_risco16,pr_risco17,pr_risco18,pr_risco19,pr_risco20,pr_risco21,pr_risco22', l_sequ);

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('APROVA_RISCO_CALRIS', 'TELA_CALRIS', 'pc_grava_acao', 'pr_idcalris,pr_acao,pr_dsjustificativa', l_sequ);

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('ALTERA_CLASSIF_RISCO', 'TELA_CALRIS', 'pc_altera_classif_risco', 'pr_idcalris_pessoa,pr_dsjustificativa,pr_cdclasrisco_espe_aten,pr_cdclasrisco_list_rest,pr_cdclasrisco_final,pr_tprelacionamento,pr_dtproxcalculo', l_sequ);

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('LISTA_VERSAO_PESSOA', 'TELA_CALRIS', 'pc_lista_versao_pessoa', 'pr_nrcpfcgc,pr_nriniseq,pr_nrregist', l_sequ);

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('BUSCA_VERSAO_CALCULO', 'TELA_CALRIS', 'pc_busca_versao_calculo', 'pr_idcalris_pessoa', l_sequ);

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('BUSCA_TANQUE', 'TELA_CALRIS', 'pc_busca_tanque', 'pr_dtinicio,pr_dtfim,pr_status,pr_tppessoa,pr_nriniseq,pr_nrregist', l_sequ);
	
	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('BUSCA_STATUS_TANQUE', 'TELA_CALRIS', 'pc_busca_status_tanque', null, l_sequ);
	
	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('MANUTENCAO_TANQUE', 'TELA_CALRIS', 'pc_manutencao_tanque', 'pr_cdopcao,pr_listaids', l_sequ);

	insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
	values ('MANUTENCAO_TANQUE_TODOS', 'TELA_CALRIS', 'pc_manutencao_tanque_todos', 'pr_dtinicio,pr_dtfim,pr_status,pr_tppessoa,pr_cdopcao', l_sequ);

	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('RISPAR', 'C', 'f0030503', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('RISPAR', 'C', 'f0030464', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('RISPAR', 'C', 'f0031053', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('RISPAR', 'C', 'f0030588', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('RISPAR', 'C', 'f0030438', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('RISPAR', 'C', 'f0031251', ' ', 3, 1, 0, 2);

	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('RISPAR', 'A', 'f0030464', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('RISPAR', 'A', 'f0031053', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('RISPAR', 'A', 'f0030588', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('RISPAR', 'A', 'f0030438', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('RISPAR', 'A', 'f0031251', ' ', 3, 1, 0, 2);

	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('RISPAR', 'D', 'f0030503', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('RISPAR', 'D', 'f0030464', ' ', 3, 1, 0, 2);

	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'C', 'f0030464', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'C', 'f0031053', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'C', 'f0030588', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'C', 'f0030438', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'C', 'f0031251', ' ', 3, 1, 0, 2);

	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'A', 'f0030464', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'A', 'f0031053', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'A', 'f0030588', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'A', 'f0030438', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'A', 'f0031251', ' ', 3, 1, 0, 2);

	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'M', 'f0030464', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'M', 'f0031053', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'M', 'f0030588', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'M', 'f0030438', ' ', 3, 1, 0, 2);
	INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) VALUES ('CALRIS', 'M', 'f0031251', ' ', 3, 1, 0, 2);

exception
	when others then
		null;
end;

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO)
values (180, 379, 1, 1);

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO)
values (380, 449, 2, 1);

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO)
values (450, 599, 3, 1);

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO)
values (600, 680, 4, 1);

commit;
end;
/