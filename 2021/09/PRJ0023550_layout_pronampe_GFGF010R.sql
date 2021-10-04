DECLARE
  vr_idcampo tbgen_layout.IDLAYOUT%TYPE;
BEGIN

  DELETE FROM tbgen_layout_programa c 
    WHERE EXISTS (SELECT 1 FROM tbgen_layout l WHERE l.idlayout = c.idlayout AND l.nmlayout = 'GFGF010R');
  DELETE FROM tbgen_layout_campo c 
    WHERE EXISTS (SELECT 1 FROM tbgen_layout l WHERE l.idlayout = c.idlayout AND l.nmlayout = 'GFGF010R');
  DELETE FROM tbgen_layout l WHERE l.nmlayout = 'GFGF010R';

  SELECT MAX(IDLAYOUT)+1 INTO vr_idcampo FROM tbgen_layout;

  -- Insere o novo layout
  INSERT INTO tbgen_layout (IDLAYOUT, NMLAYOUT, DSLAYOUT, DSDELIMITADOR, DSOBSERVACAO)
  VALUES (vr_idcampo, 'GFGF010R', 'Pronampe - Confirmação de Recebimento da Remessa', null, '1º Retorno');

  -- Insere nome do programa para rastreabilidade
  INSERT INTO tbgen_layout_programa (IDLAYOUT, CDPROGRA)
  VALUES (vr_idcampo, 'atualizarPronampeGFGF010R');

  insert into tbgen_layout_campo ( IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, '01', 1, 'CDTIPOREG', 'T', null, 8, 2, null, 'TIPO DE REGISTRO', '01');

  insert into tbgen_layout_campo ( IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, '01', 2, 'NRSEQUENCIAL', 'N', null, 32, 4, null, 'NUMERO SEQUENCIAL REMESSA', null);

  insert into tbgen_layout_campo ( IDLAYOUT, TPREGISTRO, NRSEQUENCIA_CAMPO, NMCAMPO, TPDADO, DSFORMATO, NRPOSICAO_INICIAL, QTDPOSICOES, QTDDECIMAIS, DSOBSERVACAO, DSIDENTIFICADOR_REGISTRO)
  values (vr_idcampo, '01', 3, 'CDREJEICAO', 'T', null, 209, 3, null, 'CODIGO DA REJEICAO', null);

  COMMIT;  
END;
