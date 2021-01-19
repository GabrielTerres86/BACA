declare

  vr_idoperacao_adm  tbcrd_operacao_adm.idoperacao_adm%type;

begin
  
  -- TBCRD_LAYOUT_ARQUIVO
  insert into cartao.TBCRD_LAYOUT_ARQUIVO (IDLAYOUT, DSSIGLA, DSLAYOUT, INATIVO, DTVIGENCIA, NRPOS_TIPO_REGISTRO, NRTAM_TIPO_REGISTRO)
  values (1, 'CCR3', 'Interface cadastral do cartão de crédito', 1, to_date('31-12-2100', 'dd-mm-yyyy'), 5, 2);
  
  -- TBCRD_LAYOUT_ARQUIVO_ITEM
  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '00', 'TPREGISTRO', 'Tipo de Registro', 5, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '00', 'CDBANCO', 'Número do Banco/Entidade', 7, 4);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '00', 'CDAGENCIA', 'NÚMERO DA AGÊNCIA/COOPERATIVA', 11, 4);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '00', 'SEQARQUIVO', 'NÚMERO SEQÜENCIAL DO ARQUIVO', 15, 7);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '00', 'DTARQUIVO', 'Data do Arquivo', 22, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '00', 'TPPROPOSTA', '0 - Proposta Avulsa e 1 - Alta Massificada', 30, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'TPREGISTRO', 'Tipo de Registro', 5, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'TPOPERACAO', 'Tipo da Operação', 7, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'NROPERACAO', 'Número da Operação', 9, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DTOPERACAO', 'Data da Operação', 17, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'NRCONTA_CARTAO', 'Número da Conta Cartão', 25, 13);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'NREMPRESA', 'Número da Empresa', 38, 4);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'NRGRUPO_AFINIDADE', 'Grupo de Afinidade', 42, 7);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'NRBIN', 'Bin', 49, 6);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'NRCLASSE', 'Classe do Cartão', 55, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'TPENDERECO', 'Tipo de Endereço', 57, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSENDERECO', 'Endereço Completo', 60, 50);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'CDUF', 'UF', 110, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSCIDADE', 'Cidade', 112, 40);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSBAIRRO', 'Bairro', 152, 25);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'NRCEP', 'CEP', 177, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSTELEFONE', 'Telefone', 185, 9);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'TPCONTA_DEBITAR', 'Tipo de Conta a Debitar', 198, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'CDBANCO_DEBITAR', 'Banco da Conta a Debitar', 199, 3);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'CDAGENCIA_DEBITAR', 'Agência da Conta a Debitar', 202, 4);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'NRCONTA_DEBITAR', 'Número da Conta a Debitar', 206, 12);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'VLPERC_DEBITO_AUTOMATICO', 'Porcentagem Débito Automático', 218, 3);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'NMSOCIO', 'Número do Sócio', 221, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'VLRENDA_TITULAR', 'Renda Titular', 229, 12);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSVENCIMENTOS_EMISSOR', 'Vencimentos válidos do Emissor', 243, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'VLLIMITE_CREDITO', 'Limite de crédito. ', 250, 9);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DTVENCIMENTO_CONTRATO', 'Data de Vencimento do Contrato', 259, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'QTCARTOES', 'Quantidade de Cartões', 268, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'INGERA_CARTAO_NOVO', 'Gera cartão Novo', 269, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'INORIGEM_ANULACAO', 'Origem de Anulação', 270, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'INMUDANCA_ESTADO', 'Indicador de Mudança de Estado', 272, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'INSITUACAO_CONTA', 'Situação da Conta. ', 273, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'CDREJEICAO', 'Código de Rejeição', 275, 3);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSPROMOCAO', 'Promoção', 278, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSCANAL_VENDA', 'Canal de Venda', 286, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSVENDEDOR', 'Vendedor', 294, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'INCLIENTE_VIP', 'Indicador de Cliente VIP (0 – Normal; 1 – VIP)', 302, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSLOCAL_ENTREGA_1_CARTAO', 'Local de entrega do primeiro cartão', 303, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'INRETORNO_CCB3', 'Indica retorno do CCB3', 304, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSTELEFONE_RESIDENCIAL', 'DDD Telefone Residencial', 305, 3);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSDDD_TELEFONE_COMERCIAL', 'DDD do Telefone Comercial', 308, 3);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSTELEFONE_COMERCIAL', 'Telefone Comercial', 311, 9);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSDDD_TELEFONE_CELULAR', 'DDD do Telefone Celular', 320, 3);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSTELEFONE_CELULAR', 'Telefone Celular', 323, 9);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'VLPATRIMONIO_TITULAR', 'Patrimônio do Titular', 332, 12);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'INPUBLICAR_SCR', 'Publicar SCR', 344, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '01', 'DSPORTE', 'Porte', 345, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'TPREGISTRO', 'Tipo de Registro', 5, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'TPOPERACAO', 'Tipo da Operação', 7, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NROPERACAO', 'Número da Operação', 9, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'DTOPERACAO', 'Data da Operação', 17, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NRCONTA_CARTAO', 'Número da Conta Cartão', 25, 13);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NRCRCARD', 'Número do Cartão', 38, 19);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NMTITCRD', 'Nome do Titular', 57, 23);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NMEXTTTL', 'Nome no Plástico', 57, 23);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'DTDONASC', 'Data de Nascimento', 80, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDSEXO', 'Sexo. 0 – Não informado, 1 - Feminino e 2 - Masculino.', 88, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDESTCIVIL', '0-Não Informado, 1-Solteiro, 2-Casado, 3-Divorciado, 4-Viúvo, 5-Outros, 6-DESQUITADO, 7-OUTROS', 89, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'TPDOCMTO', 'Tipo de Documento', 93, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CPF', 'CPF', 95, 11);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NRCPFCGC', 'CPF/CNPJ', 95, 15);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDGERARNOVOCARTAO', '1 = novidade VAI gerar um cartão novo, 0 = novidade NÃO VAI gerar', 110, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDORIGEMCANCEL', '1-Entidade, 2-Usuário, Só para Tipo de Operação 3. O resto fixo 0', 111, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDMUDANCAESTADO', '1 = Mudar Estado para o da Situacao do Cartao, 2 = Voltar Estado Anterior ao da Situacao do Cartao', 112, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDTITULARIDADE', '1-Titular, 2-Dependentes', 113, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'SITCARTA', 'Situação do Cartão', 114, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CODREJEI', 'Código de Rejeição', 211, 3);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'DSSENHAPIN', 'Senha Criptografada. So para Operacao tipo 50, para o resto fica em branco.', 214, 16);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NRDOCCRD', 'Número de Documento', 230, 15);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'DSORGAOCCRD', 'Orgao Emissor da Identidade', 245, 3);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'DSESTADOCCRD', 'Estado Emissor da Identidade', 248, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NMPORTADOR', 'Nome completo do portador', 250, 80);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDBANCOCONTAVINCULADA', 'Banco qual pertence a conta Vinculada para funcao Deb.Se informado transforma o cartao em Multiplo', 330, 3);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDAGEBCB', 'Agência bancoob', 333, 4);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NRCONTA_DEBITAR', 'Número de Conta', 337, 12);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'INDRETORNO', 'Retorno evento interno, S – indica retorno, N - Nao retorno', 349, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '09', 'TPARQUIVO', 'Tipo de Arquivo', 1, 4);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '09', 'TPREGISTRO', 'Tipo de Registro', 5, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '09', 'QTDREGISTRO1', 'Quantidade de Registros Tipo 1', 7, 7);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '09', 'QTDREGISTRO2', 'Quantidade de Registros Tipo 2', 14, 7);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '09', 'DSFILLERTRAILLER', 'Filler', 21, 80);
  
  -- TBCRD_OPERACAO_ADM
  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 0, 'ERRO - TIPO DE SOLICITAÇÃO EM BRANCO', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 1, 'INCLUSÃO DE CARTÃO', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 2, 'MODIFICAÇÃO DE CONTA CARTÃO', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 3, 'CANCELAMENTO DE CARTÃO', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 4, 'INCLUSÃO DE CARTÃO ADICIONAL/REPOSIÇÃO DE CARTÃO', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 5, 'MODIFICAÇÃO DE CARTÃO', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 6, 'MODIFICAÇÃO DE DOCUMENTO', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 7, 'REATIVAÇÃO DE CARTÃO', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 8, 'REIMPRESSÃO DE PIN', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 9, 'BAIXA DE PARCELADOS', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 10, 'DESBLOQUEIO DE CARTÃO', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 11, 'ENTREGA DE CARTÃO', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 12, 'TROCA DE ESTADO DE CARTÃO', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 13, 'ALTERAÇÃO DE CONTA CARTÃO', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 14, 'CAD. DEB. AUTOMATICO', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 16, 'BAIXA DE PARCELAS', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 25, 'REATIVAR CARTÃO DO ADICIONAL', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 50, 'MODIFICAÇÃO DE PIN', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 99, 'EXCLUSÃO DE CARTÃO', 1);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 48, null, 1);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 59, null, 1);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 1, 'INCLUSÃO DE CARTÃO', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 3, 'CANCELAMENTO DE CARTÃO', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 4, 'INCLUSÃO DE CARTÃO ADICIONAL/REPOSIÇÃO DE CARTÃO', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 5, 'MODIFICAÇÃO DE CARTÃO', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 7, 'REATIVAÇÃO DE CARTÃO', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 10, 'DESBLOQUEIO DE CARTÃO', 3) returning IDOPERACAO_ADM into vr_idoperacao_adm;

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 12, 'TROCA DE ESTADO DE CARTÃO', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 13, 'ALTERAÇÃO DE CONTA CARTÃO', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 25, 'REATIVAR CARTÃO DO ADICIONAL', 3);
  
  -- TBCRD_OPERACAO_ADM_SITUACAO
  insert into tbcrd_operacao_adm_situacao (IDOPERACAO_ADM, CDSITUACAO_ADM, CDSITUACAO_CARTAO, CDMOTIVO_CANCELAMENTO)
  values (vr_idoperacao_adm, 10, 6, 10);

  insert into tbcrd_operacao_adm_situacao (IDOPERACAO_ADM, CDSITUACAO_ADM, CDSITUACAO_CARTAO, CDMOTIVO_CANCELAMENTO)
  values (vr_idoperacao_adm, 16, 5, 16);

  insert into tbcrd_operacao_adm_situacao (IDOPERACAO_ADM, CDSITUACAO_ADM, CDSITUACAO_CARTAO, CDMOTIVO_CANCELAMENTO)
  values (vr_idoperacao_adm, 26, 6, 10);

  insert into tbcrd_operacao_adm_situacao (IDOPERACAO_ADM, CDSITUACAO_ADM, CDSITUACAO_CARTAO, CDMOTIVO_CANCELAMENTO)
  values (vr_idoperacao_adm, 1, 4, 0);
  
  dbms_output.put_line('Insert concluído!');
  commit;
exception 
  when others then
    dbms_output.put_line('Erro no insert - '|| sqlerrm);
end;
