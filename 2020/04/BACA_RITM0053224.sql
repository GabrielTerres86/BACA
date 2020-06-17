DECLARE
  vr_idcampo tbgen_layout.IDLAYOUT%TYPE;
BEGIN
  
  SELECT MAX(IDLAYOUT)+1 INTO vr_idcampo FROM tbgen_layout;
  
  -- PARAMETRO DE EMAIL
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'CRPS714_1_EMAIL', 'Email para recebimento de erros no processamento dos estornos de cessao', 'cristiane.dregoti@ailos.coop.br;eduardo.santos@ailos.coop.br;tainara.nunes@ailos.coop.br;adriane.nunes@ailos.coop.br');

  -- Insere o novo layout
  insert into tbgen_layout (IDLAYOUT, NMLAYOUT, DSLAYOUT, DSDELIMITADOR, DSOBSERVACAO)
  values (vr_idcampo, 'EST_CESSAO_CARTAO', 'Arquivo de Estorno de Cessão de fatura de cartão de credito', ';', null);

  -- Insere nome do programa para rastreabilidade
  insert into tbgen_layout_programa (IDLAYOUT, CDPROGRA)
  values (vr_idcampo, 'PC_CRPS714_1');

  -- Insere campos do layout
  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'A', 1, 'DTDARQUI', 'D', 'DD/MM/RRRR', null, null, null, 'DATA DO ARQUIVO', null);

  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'A', 2, 'CDCENTRA', 'N', null, null, null, null, 'CODIGO DA CENTRAL', null);

  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'A', 3, 'CDCOOPER', 'N', null, null, null, null, 'CODIGO DA COOPERATIVA', null);

  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'A', 4, 'CDAGENCI', 'N', null, null, null, null, 'CODIGO DA AGENCIA PA', null);

  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'A', 5, 'NRCPFCGC', 'N', null, null, null, null, 'NUMERO CPF/CNPJ COOPERADO', null);

  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'A', 6, 'NRCARTAO', 'N', null, null, null, null, 'NUMERO DA CONTA CARTAO', null);

  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'A', 7, 'NMTITCRD', 'T', null, null, null, null, 'NOME DO TITULAR DA CONTA CARTAO', null);
  
  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'A', 8, 'NMBANDEI', 'T', null, null, null, null, 'NOME DA BANDEIRA', null);

  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'A', 9, 'VLLIQUID', 'N', null, null, null, null, 'VALOR LIQUIDADO DO CARTÃO DE CREDITO', null);

  -----------------------------------------

  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'H', 1, 'DTDARQUI', 'T', null, null, null, null, 'DATA DO ARQUIVO', null);

  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'H', 2, 'CDCENTRA', 'T', null, null, null, null, 'CODIGO DA CENTRAL', null);

  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'H', 3, 'CDCOOPER', 'T', null, null, null, null, 'CODIGO DA COOPERATIVA', null);

  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'H', 4, 'CDAGENCI', 'T', null, null, null, null, 'CODIGO DA AGENCIA PA', null);

  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'H', 5, 'NRCPFCGC', 'T', null, null, null, null, 'NUMERO CPF/CNPJ COOPERADO', null);

  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'H', 6, 'NRCARTAO', 'T', null, null, null, null, 'NUMERO DA CONTA CARTAO', null);

  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'H', 7, 'NMTITCRD', 'T', null, null, null, null, 'NOME DO TITULAR DA CONTA CARTAO', null);
  
  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'H', 8, 'NMBANDEI', 'T', null, null, null, null, 'NOME DA BANDEIRA', null);
  
  insert into tbgen_layout_campo (IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, 'H', 9, 'VLLIQUID', 'T', NULL, null, null, null, 'VALOR LIQUIDADO DO CARTÃO DE CREDITO', null);

  commit;  
END;
