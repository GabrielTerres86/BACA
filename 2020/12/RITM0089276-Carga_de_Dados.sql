declare

  vr_idoperacao_adm  tbcrd_operacao_adm.idoperacao_adm%type;

begin
  
  -- TBCRD_LAYOUT_ARQUIVO
  insert into cartao.TBCRD_LAYOUT_ARQUIVO (IDLAYOUT, DSSIGLA, DSLAYOUT, INATIVO, DTVIGENCIA, NRPOS_TIPO_REGISTRO, NRTAM_TIPO_REGISTRO)
  values (1, 'CCR3', 'Interface cadastral do cart�o de cr�dito', 1, to_date('31-12-2100', 'dd-mm-yyyy'), 5, 2);
  
  -- TBCRD_LAYOUT_ARQUIVO_ITEM
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
  values (1, '02', 'TPOPERACAO', 'Tipo da Opera��o', 7, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NROPERACAO', 'N�mero da Opera��o', 9, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'DTOPERACAO', 'Data da Opera��o', 17, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NRCONTA_CARTAO', 'N�mero da Conta Cart�o', 25, 13);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NRCRCARD', 'N�mero do Cart�o', 38, 19);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NMTITCRD', 'Nome do Titular', 57, 23);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NMEXTTTL', 'Nome no Pl�stico', 57, 23);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'DTDONASC', 'Data de Nascimento', 80, 8);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDSEXO', 'Sexo. 0 � N�o informado, 1 - Feminino e 2 - Masculino.', 88, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDESTCIVIL', '0-N�o Informado, 1-Solteiro, 2-Casado, 3-Divorciado, 4-Vi�vo, 5-Outros, 6-DESQUITADO, 7-OUTROS', 89, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'TPDOCMTO', 'Tipo de Documento', 93, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CPF', 'CPF', 95, 11);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NRCPFCGC', 'CPF/CNPJ', 95, 15);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDGERARNOVOCARTAO', '1 = novidade VAI gerar um cart�o novo, 0 = novidade N�O VAI gerar', 110, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDORIGEMCANCEL', '1-Entidade, 2-Usu�rio, S� para Tipo de Opera��o 3. O resto fixo 0', 111, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDMUDANCAESTADO', '1 = Mudar Estado para o da Situacao do Cartao, 2 = Voltar Estado Anterior ao da Situacao do Cartao', 112, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDTITULARIDADE', '1-Titular, 2-Dependentes', 113, 1);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'SITCARTA', 'Situa��o do Cart�o', 114, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CODREJEI', 'C�digo de Rejei��o', 211, 3);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'DSSENHAPIN', 'Senha Criptografada. So para Operacao tipo 50, para o resto fica em branco.', 214, 16);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NRDOCCRD', 'N�mero de Documento', 230, 15);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'DSORGAOCCRD', 'Orgao Emissor da Identidade', 245, 3);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'DSESTADOCCRD', 'Estado Emissor da Identidade', 248, 2);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NMPORTADOR', 'Nome completo do portador', 250, 80);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDBANCOCONTAVINCULADA', 'Banco qual pertence a conta Vinculada para funcao Deb.Se informado transforma o cartao em Multiplo', 330, 3);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'CDAGEBCB', 'Ag�ncia bancoob', 333, 4);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'NRCONTA_DEBITAR', 'N�mero de Conta', 337, 12);

  insert into cartao.TBCRD_LAYOUT_ARQUIVO_ITEM (IDLAYOUT, DSREGISTRO, NMCAMPO, DSCAMPO, NRPOS_CAMPO, NRTAM_CAMPO)
  values (1, '02', 'INDRETORNO', 'Retorno evento interno, S � indica retorno, N - Nao retorno', 349, 1);

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
  values (null, 1, 0, 'ERRO - TIPO DE SOLICITA��O EM BRANCO', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 1, 'INCLUS�O DE CART�O', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 2, 'MODIFICA��O DE CONTA CART�O', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 3, 'CANCELAMENTO DE CART�O', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 4, 'INCLUS�O DE CART�O ADICIONAL/REPOSI��O DE CART�O', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 5, 'MODIFICA��O DE CART�O', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 6, 'MODIFICA��O DE DOCUMENTO', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 7, 'REATIVA��O DE CART�O', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 8, 'REIMPRESS�O DE PIN', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 9, 'BAIXA DE PARCELADOS', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 10, 'DESBLOQUEIO DE CART�O', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 11, 'ENTREGA DE CART�O', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 12, 'TROCA DE ESTADO DE CART�O', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 13, 'ALTERA��O DE CONTA CART�O', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 14, 'CAD. DEB. AUTOMATICO', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 16, 'BAIXA DE PARCELAS', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 25, 'REATIVAR CART�O DO ADICIONAL', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 50, 'MODIFICA��O DE PIN', null);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 99, 'EXCLUS�O DE CART�O', 1);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 48, null, 1);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 1, 59, null, 1);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 1, 'INCLUS�O DE CART�O', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 3, 'CANCELAMENTO DE CART�O', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 4, 'INCLUS�O DE CART�O ADICIONAL/REPOSI��O DE CART�O', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 5, 'MODIFICA��O DE CART�O', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 7, 'REATIVA��O DE CART�O', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 10, 'DESBLOQUEIO DE CART�O', 3) returning IDOPERACAO_ADM into vr_idoperacao_adm;

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 12, 'TROCA DE ESTADO DE CART�O', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 13, 'ALTERA��O DE CONTA CART�O', 3);

  insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values (null, 2, 25, 'REATIVAR CART�O DO ADICIONAL', 3);
  
  -- TBCRD_OPERACAO_ADM_SITUACAO
  insert into tbcrd_operacao_adm_situacao (IDOPERACAO_ADM, CDSITUACAO_ADM, CDSITUACAO_CARTAO, CDMOTIVO_CANCELAMENTO)
  values (vr_idoperacao_adm, 10, 6, 10);

  insert into tbcrd_operacao_adm_situacao (IDOPERACAO_ADM, CDSITUACAO_ADM, CDSITUACAO_CARTAO, CDMOTIVO_CANCELAMENTO)
  values (vr_idoperacao_adm, 16, 5, 16);

  insert into tbcrd_operacao_adm_situacao (IDOPERACAO_ADM, CDSITUACAO_ADM, CDSITUACAO_CARTAO, CDMOTIVO_CANCELAMENTO)
  values (vr_idoperacao_adm, 26, 6, 10);

  insert into tbcrd_operacao_adm_situacao (IDOPERACAO_ADM, CDSITUACAO_ADM, CDSITUACAO_CARTAO, CDMOTIVO_CANCELAMENTO)
  values (vr_idoperacao_adm, 1, 4, 0);
  
  dbms_output.put_line('Insert conclu�do!');
  commit;
exception 
  when others then
    dbms_output.put_line('Erro no insert - '|| sqlerrm);
end;
