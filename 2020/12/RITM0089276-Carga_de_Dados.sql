BEGIN
  -- Insert na tabela TBCRD_LAYOUT_ARQUIVO
  BEGIN
    insert into cartao.TBCRD_LAYOUT_ARQUIVO (IDLAYOUT, DSSIGLA, DSLAYOUT, INATIVO, DTVIGENCIA, NRPOS_TIPO_REGISTRO, NRTAM_TIPO_REGISTRO)
    values (1, 'CCR3', 'Interface cadastral do cartão de crédito', 1, to_date('31-12-2100', 'dd-mm-yyyy'), 5, 2);

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
    values (1, '09', 'TPREGISTRO', 'Tipo de Registro', 5, 2);
  END;
  
  -- Insert na tabela tbcrd_operacao_adm
  BEGIN
    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 1, 'Inclusão de Cartão', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 2, 'Modificação de Conta Cartão', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 3, 'Cancelamento de Cartão', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 4, 'Inclusão de Adicional', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 7, 'Reativação de Contas', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 12, 'Alteração de Estado', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 13, 'Alteração de Estado Conta', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 48, null, 1);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 59, null, 1);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 99, null, 1);
  END;
  
  COMMIT;
  
END;
