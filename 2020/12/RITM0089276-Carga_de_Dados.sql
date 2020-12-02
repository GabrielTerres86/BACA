BEGIN
  -- Insert na tabela TBCRD_LAYOUT_ARQUIVO
  BEGIN
    insert into cartao.TBCRD_LAYOUT_ARQUIVO (IDLAYOUT, DSSIGLA, DSLAYOUT, INATIVO, DTVIGENCIA, NRPOS_TIPO_REGISTRO, NRTAM_TIPO_REGISTRO)
    values (1, 'CCR3', 'Interface cadastral do cart�o de cr�dito', 1, to_date('31-12-2100', 'dd-mm-yyyy'), 5, 2);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '00', 'TPREGISTRO', 'Tipo de Registro', 5, 2);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '00', 'CDBANCO', 'N�mero do Banco/Entidade', 7, 4);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '00', 'CDAGENCIA', 'N�MERO DA AG�NCIA/COOPERATIVA', 11, 4);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '00', 'SEQARQUIVO', 'N�MERO SEQ�ENCIAL DO ARQUIVO', 15, 7);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '00', 'DTARQUIVO', 'Data do Arquivo', 22, 8);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '00', 'TPPROPOSTA', '0 - Proposta Avulsa e 1 - Alta Massificada', 30, 1);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'TPREGISTRO', 'Tipo de Registro', 5, 2);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'TPOPERACAO', 'Tipo da Opera��o', 7, 2);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'NROPERACAO', 'N�mero da Opera��o', 9, 8);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'DTOPERACAO', 'Data da Opera��o', 17, 8);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'NRCONTA_CARTAO', 'N�mero da Conta Cart�o', 25, 13);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'NREMPRESA', 'N�mero da Empresa', 38, 4);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'NRGRUPO_AFINIDADE', 'Grupo de Afinidade', 42, 7);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'NRBIN', 'Bin', 49, 6);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'NRCLASSE', 'Classe do Cart�o', 55, 2);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'TPENDERECO', 'Tipo de Endere�o', 57, 2);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'DSENDERECO', 'Endere�o Completo', 60, 50);

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
    values (1, '01', 'CDAGENCIA_DEBITAR', 'Ag�ncia da Conta a Debitar', 202, 4);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'NRCONTA_DEBITAR', 'N�mero da Conta a Debitar', 206, 12);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'VLPERC_DEBITO_AUTOMATICO', 'Porcentagem D�bito Autom�tico', 218, 3);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'NMSOCIO', 'N�mero do S�cio', 221, 8);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'VLRENDA_TITULAR', 'Renda Titular', 229, 12);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'DSVENCIMENTOS_EMISSOR', 'Vencimentos v�lidos do Emissor', 243, 2);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'VLLIMITE_CREDITO', 'Limite de cr�dito. ', 250, 9);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'DTVENCIMENTO_CONTRATO', 'Data de Vencimento do Contrato', 259, 8);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'QTCARTOES', 'Quantidade de Cart�es', 268, 1);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'INGERA_CARTAO_NOVO', 'Gera cart�o Novo', 269, 1);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'INORIGEM_ANULACAO', 'Origem de Anula��o', 270, 1);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'INMUDANCA_ESTADO', 'Indicador de Mudan�a de Estado', 272, 1);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'INSITUACAO_CONTA', 'Situa��o da Conta. ', 273, 2);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'CDREJEICAO', 'C�digo de Rejei��o', 275, 3);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'DSPROMOCAO', 'Promo��o', 278, 8);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'DSCANAL_VENDA', 'Canal de Venda', 286, 8);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'DSVENDEDOR', 'Vendedor', 294, 8);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'INCLIENTE_VIP', 'Indicador de Cliente VIP (0 � Normal; 1 � VIP)', 302, 1);

    insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
    values (1, '01', 'DSLOCAL_ENTREGA_1_CARTAO', 'Local de entrega do primeiro cart�o', 303, 1);

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
    values (1, '01', 'VLPATRIMONIO_TITULAR', 'Patrim�nio do Titular', 332, 12);

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
    values (null, 1, 1, 'Inclus�o de Cart�o', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 2, 'Modifica��o de Conta Cart�o', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 3, 'Cancelamento de Cart�o', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 4, 'Inclus�o de Adicional', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 7, 'Reativa��o de Contas', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 12, 'Altera��o de Estado', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 13, 'Altera��o de Estado Conta', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 48, null, 1);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 59, null, 1);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 99, null, 1);
  END;
  
  COMMIT;
  
END;
