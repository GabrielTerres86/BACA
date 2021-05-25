declare

v_idcalris_n TBCALRIS_PARAMETROS.idcalris%type;
v_idcalris_l TBCALRIS_PARAMETROS.idcalris%type;
v_idrisco TBCALRIS_RISCOS.idrisco%type;
v_idcriterio tbcalris_criterios.idcriterio%type;

begin

insert into TBCALRIS_PARAMETROS (DSCALRIS, INPESSOA, TPCOOPERADO, DHCADASTRO, DHLIBERACAO, CDSITUACAO, CDUSUARIO, DHFIMVIGENCIA, QTLIBERACOES)
values ('Fornecedor Novo', 3, 'N', SYSDATE, SYSDATE, 2, '1', null, 2) RETURNING idcalris INTO v_idcalris_n;

insert into TBCALRIS_PARAMETROS (DSCALRIS, INPESSOA, TPCOOPERADO, DHCADASTRO, DHLIBERACAO, CDSITUACAO, CDUSUARIO, DHFIMVIGENCIA, QTLIBERACOES)
values ('Fornecedor Legado', 3, 'L', SYSDATE, SYSDATE, 2, '1', null, 2) RETURNING idcalris INTO v_idcalris_l;

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('DATA_CONST_FORNECEDOR', 'Risco atribuído por tempo de existência', 3, 0, NULL) RETURNING idrisco INTO v_idrisco;

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Maior que [MAX]', 'DATA_CONST_FORNECEDOR', 1, '>') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 5, 1, v_idcriterio, 1, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 5, 1, v_idcriterio, 1, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('De [MIN] a [MAX]', 'DATA_CONST_FORNECEDOR', 2, 'BETWEEN') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 3, 5, 1, v_idcriterio, 2, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 3, 5, 1, v_idcriterio, 2, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Menor que [MIN]', 'DATA_CONST_FORNECEDOR', 3, '<') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 3, 0, 1, v_idcriterio, 3, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 3, 0, 1, v_idcriterio, 3, v_idcalris_l);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('ATIVIDADE_FORNECEDOR', 'Risco atribuído conforme ramo de atividade', 3, 1, NULL) RETURNING idrisco INTO v_idrisco;

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('De acordo com a tabela CNAE', 'ATIVIDADE_FORNECEDOR', 0, NULL) RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 30, 0, 0, 1, v_idcriterio, 0, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 30, 0, 0, 1, v_idcriterio, 0, v_idcalris_l);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('FATU_SETOR_PUBL_FORNEC', 'Risco se possui faturamento com setor público', 3, 2, NULL) RETURNING idrisco INTO v_idrisco;

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Possui', 'FATU_SETOR_PUBL_FORNEC', 3, 'S') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 3, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 3, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Não possui', 'FATU_SETOR_PUBL_FORNEC', 1, 'N') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 1, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 1, v_idcalris_l);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('SERV_PROD_FORNECEDOR', 'Risco atribuído conforme serviço ou produto fornecido', 3, 1, NULL) RETURNING idrisco INTO v_idrisco;

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('De acordo com a tabela de serviços/produtos', 'SERV_PROD_FORNECEDOR', 0, NULL) RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 30, 0, 0, 1, v_idcriterio, 0, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 30, 0, 0, 1, v_idcriterio, 0, v_idcalris_l);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('VALOR_CONTRATO_FORNECEDOR', 'Risco atribuído por valor do contrato com o fornecedor', 3, 0, NULL) RETURNING idrisco INTO v_idrisco;

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Maior que [MAX]', 'VALOR_CONTRATO_FORNECEDOR', 3, '>') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 5000000, 1, v_idcriterio, 3, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 5000000, 1, v_idcriterio, 3, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('De [MIN] a [MAX]', 'VALOR_CONTRATO_FORNECEDOR', 2, 'BETWEEN') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 1000000, 5000000, 1, v_idcriterio, 2, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 1000000, 5000000, 1, v_idcriterio, 2, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Menor que [MIN]', 'VALOR_CONTRATO_FORNECEDOR', 1, '<') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 1000000, 0, 1, v_idcriterio, 1, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 1000000, 0, 1, v_idcriterio, 1, v_idcalris_l);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('LEI_PLDFT_FORNECEDOR', 'É pessoa obrigada (Lei 9.613/98), portanto, deve possuir controles de PLDFT', 3, 2, NULL) RETURNING idrisco INTO v_idrisco;

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Sim', 'LEI_PLDFT_FORNECEDOR', 3, 'S') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 3, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 3, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Não', 'LEI_PLDFT_FORNECEDOR', 1, 'N') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 1, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 1, v_idcalris_l);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('CEP_FORNECEDOR', 'Risco atribuído conforme localização', 3, 1, NULL) RETURNING idrisco INTO v_idrisco;

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Tabela de Risco por CEP', 'CEP_FORNECEDOR', 0, NULL) RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 30, 0, 0, 1, v_idcriterio, 0, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 30, 0, 0, 1, v_idcriterio, 0, v_idcalris_l);

insert into TBCALRIS_PARAMETROS (DSCALRIS, INPESSOA, TPCOOPERADO, DHCADASTRO, DHLIBERACAO, CDSITUACAO, CDUSUARIO, DHFIMVIGENCIA, QTLIBERACOES)
values ('Candidato', 4, 'N', SYSDATE, SYSDATE, 2, '1', null, 2) RETURNING idcalris INTO v_idcalris_n;

insert into TBCALRIS_PARAMETROS (DSCALRIS, INPESSOA, TPCOOPERADO, DHCADASTRO, DHLIBERACAO, CDSITUACAO, CDUSUARIO, DHFIMVIGENCIA, QTLIBERACOES)
values ('Colaborador', 4, 'L', SYSDATE, SYSDATE, 2, '1', null, 2) RETURNING idcalris INTO v_idcalris_l;

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('RELACIONAMENTO_COLAB', 'Risco atribuído por tipo de relacionamento do colaborador', 4, 2, NULL) RETURNING idrisco INTO v_idrisco;

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Relacionamento direto (com migração de carteira)', 'RELACIONAMENTO_COLAB', 4, '4') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 30, 0, 0, 1, v_idcriterio, 4, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 30, 0, 0, 1, v_idcriterio, 4, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Relacionamento direto (sem migração de carteira)', 'RELACIONAMENTO_COLAB', 3, '3') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 30, 0, 0, 1, v_idcriterio, 3, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 30, 0, 0, 1, v_idcriterio, 3, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Relacionamento indireto com o cliente', 'RELACIONAMENTO_COLAB', 2, '2') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 30, 0, 0, 1, v_idcriterio, 2, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 30, 0, 0, 1, v_idcriterio, 2, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Não tem relacionamento com cliente', 'RELACIONAMENTO_COLAB', 1, '1') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 30, 0, 0, 1, v_idcriterio, 1, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 30, 0, 0, 1, v_idcriterio, 1, v_idcalris_l);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('REGIAO_ATUACAO_COLAB', 'Risco atribuído pela região de atuação do colaborador', 4, 2, NULL) RETURNING idrisco INTO v_idrisco;

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Municipio de fronteira', 'REGIAO_ATUACAO_COLAB', 4, '1') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 4, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 4, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Região de fronteira', 'REGIAO_ATUACAO_COLAB', 3, '2') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 3, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 3, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Capitais', 'REGIAO_ATUACAO_COLAB', 2, '3') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 2, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 2, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Demais municipios', 'REGIAO_ATUACAO_COLAB', 1, '4') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 1, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 1, v_idcalris_l);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('PENDENCIA_FINAN_COLAB', 'Risco atribuído pelas pendências financeiras do colaborador', 4, 0, NULL) RETURNING idrisco INTO v_idrisco;

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Maior que [MAX]', 'PENDENCIA_FINAN_COLAB', 4, '>') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 10, 0, 50, 1, v_idcriterio, 4, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 10, 0, 50, 1, v_idcriterio, 4, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('De [MIN] a [MAX]', 'PENDENCIA_FINAN_COLAB', 3, 'BETWEEN') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 10, 20, 50, 1, v_idcriterio, 3, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 10, 20, 50, 1, v_idcriterio, 3, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Menor que [MIN]', 'PENDENCIA_FINAN_COLAB', 2, '<') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 10, 20, 0, 1, v_idcriterio, 2, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 10, 20, 0, 1, v_idcriterio, 2, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Igual a [MIN]', 'PENDENCIA_FINAN_COLAB', 1, '=') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 10, 0, 0, 1, v_idcriterio, 1, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 10, 0, 0, 1, v_idcriterio, 1, v_idcalris_l);

insert into TBCALRIS_RISCOS (CDRISCO, DSABREV, INPESSOA, TPCRITERIO, DSRISCO)
values ('GRAU_ENDIVIDAMENTO_COLAB', 'Risco atribuído pelo grau de endividamento do colaborador', 4, 0, NULL) RETURNING idrisco INTO v_idrisco;

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Maior que [MAX]', 'GRAU_ENDIVIDAMENTO_COLAB', 4, '>') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 50, 1, v_idcriterio, 4, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 50, 1, v_idcriterio, 4, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('De [MIN] a [MAX]', 'GRAU_ENDIVIDAMENTO_COLAB', 3, 'BETWEEN') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 20, 50, 1, v_idcriterio, 3, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 20, 50, 1, v_idcriterio, 3, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Menor que [MIN]', 'GRAU_ENDIVIDAMENTO_COLAB', 2, '<') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 20, 0, 1, v_idcriterio, 2, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 20, 0, 1, v_idcriterio, 2, v_idcalris_l);

insert into tbcalris_criterios (DSCRITERIO, CDRISCO, CDCLASRISCO, CDCRITERIO)
values ('Igual a [MIN]', 'GRAU_ENDIVIDAMENTO_COLAB', 1, '=') RETURNING idcriterio INTO v_idcriterio;

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 1, v_idcalris_n);

insert into tbcalris_param_dados (IDRISCO, VLPESO, VLCRITINICIAL, VLCRITFINAL, FLGATIVO, IDCRITERIO, VLRISCO, IDCALRIS)
values (v_idrisco, 20, 0, 0, 1, v_idcriterio, 1, v_idcalris_l);

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO, TPCALCULADORA)
values (180, 379, 1, 1, 2);

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO, TPCALCULADORA)
values (380, 449, 2, 1, 2);

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO, TPCALCULADORA)
values (450, 599, 3, 1, 2);

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO, TPCALCULADORA)
values (600, 680, 4, 1, 2);

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO, TPCALCULADORA)
values (210, 349, 1, 1, 3);

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO, TPCALCULADORA)
values (350, 469, 2, 1, 3);

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO, TPCALCULADORA)
values (470, 630, 3, 1, 3);

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO, TPCALCULADORA)
values (80, 139, 1, 1, 4);

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO, TPCALCULADORA)
values (140, 199, 2, 1, 4);

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO, TPCALCULADORA)
values (200, 259, 3, 1, 4);

insert into tbcalris_faixa_risco (VLMIN, VLMAX, CDCLASRISCO, CDSITUACAO, TPCALCULADORA)
values (260, 320, 4, 1, 4);

insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('BUSCA_NOME_FORNECEDOR', 'TELA_CALRIS', 'pc_busca_nome_fornecedor', 'pr_nrcpfcgc', 2184);

insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('BUSCA_NOME_CANDIDATO', 'TELA_CALRIS', 'pc_busca_nome_candidato', 'pr_nrcpfcgc', 2184);

UPDATE crapaca x
   SET x.lstparam = 'pr_idcalris_pessoa,pr_dsjustificativa,pr_cdclasrisco_espe_aten,pr_cdclasrisco_list_rest,pr_cdclasrisco_list_inte,pr_cdclasrisco_final,pr_tprelacionamento,pr_dtproxcalculo,pr_cdstatus'
 WHERE x.nmdeacao = 'ALTERA_CLASSIF_RISCO'
   AND x.nmpackag = 'TELA_CALRIS';

UPDATE crapaca x
   SET x.lstparam = 'pr_nrcpfcgc,pr_nriniseq,pr_nrregist,pr_tpcalculadora'
 WHERE x.nmdeacao = 'LISTA_VERSAO_PESSOA'
   AND x.nmpackag = 'TELA_CALRIS';

UPDATE crapaca x
   SET x.lstparam = 'pr_dtinicio,pr_dtfim,pr_status,pr_tppessoa,pr_nriniseq,pr_nrregist,pr_cdclasrisco,pr_tpcooperado'
 WHERE x.nmdeacao = 'BUSCA_TANQUE'
   AND x.nmpackag = 'TELA_CALRIS';

UPDATE crapaca x
   SET x.lstparam = 'pr_dtinicio,pr_dtfim,pr_status,pr_tppessoa,pr_cdopcao,pr_cdclasrisco,pr_tpcooperado'
 WHERE x.nmdeacao = 'MANUTENCAO_TANQUE_TODOS'
   AND x.nmpackag = 'TELA_CALRIS';

COMMIT;

exception
	when others then
		ROLLBACK;
end;
/