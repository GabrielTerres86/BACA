BEGIN

  INSERT INTO tbgen_layout_campo
    (IDLAYOUT
    ,TPREGISTRO
    ,NRSEQUENCIA_CAMPO
    ,NMCAMPO
    ,TPDADO
    ,DSFORMATO
    ,NRPOSICAO_INICIAL
    ,QTDPOSICOES
    ,QTDDECIMAIS
    ,DSOBSERVACAO
    ,DSIDENTIFICADOR_REGISTRO)
  VALUES
    (13
    ,'B5'
    ,1
    ,'CDREGISTRO'
    ,'T'
    ,NULL
    ,1
    ,2
    ,NULL
    ,'Código do Registro'
    ,'B5');

  INSERT INTO tbgen_layout_campo
    (IDLAYOUT
    ,TPREGISTRO
    ,NRSEQUENCIA_CAMPO
    ,NMCAMPO
    ,TPDADO
    ,DSFORMATO
    ,NRPOSICAO_INICIAL
    ,QTDPOSICOES
    ,QTDDECIMAIS
    ,DSOBSERVACAO
    ,DSIDENTIFICADOR_REGISTRO)
  VALUES
    (13
    ,'B5'
    ,2
    ,'INTERMINAL'
    ,'T'
    ,NULL
    ,3
    ,8
    ,NULL
    ,'Identificação do Terminal'
    ,NULL);

  INSERT INTO tbgen_layout_campo
    (IDLAYOUT
    ,TPREGISTRO
    ,NRSEQUENCIA_CAMPO
    ,NMCAMPO
    ,TPDADO
    ,DSFORMATO
    ,NRPOSICAO_INICIAL
    ,QTDPOSICOES
    ,QTDDECIMAIS
    ,DSOBSERVACAO
    ,DSIDENTIFICADOR_REGISTRO)
  VALUES
    (13
    ,'B5'
    ,3
    ,'CDNSUOPERACAO'
    ,'N'
    ,NULL
    ,11
    ,12
    ,NULL
    ,'NSU da Operação'
    ,NULL);

  INSERT INTO tbgen_layout_campo
    (IDLAYOUT
    ,TPREGISTRO
    ,NRSEQUENCIA_CAMPO
    ,NMCAMPO
    ,TPDADO
    ,DSFORMATO
    ,NRPOSICAO_INICIAL
    ,QTDPOSICOES
    ,QTDDECIMAIS
    ,DSOBSERVACAO
    ,DSIDENTIFICADOR_REGISTRO)
  VALUES
    (13
    ,'B5'
    ,4
    ,'DTOPERACAO'
    ,'T'
    ,'MMDD'
    ,23
    ,4
    ,NULL
    ,'Data da Operação'
    ,NULL);

  INSERT INTO tbgen_layout_campo
    (IDLAYOUT
    ,TPREGISTRO
    ,NRSEQUENCIA_CAMPO
    ,NMCAMPO
    ,TPDADO
    ,DSFORMATO
    ,NRPOSICAO_INICIAL
    ,QTDPOSICOES
    ,QTDDECIMAIS
    ,DSOBSERVACAO
    ,DSIDENTIFICADOR_REGISTRO)
  VALUES
    (13
    ,'B5'
    ,5
    ,'HROPERACAO'
    ,'T'
    ,NULL
    ,27
    ,4
    ,NULL
    ,'Hora da Operação'
    ,NULL);

  INSERT INTO tbgen_layout_campo
    (IDLAYOUT
    ,TPREGISTRO
    ,NRSEQUENCIA_CAMPO
    ,NMCAMPO
    ,TPDADO
    ,DSFORMATO
    ,NRPOSICAO_INICIAL
    ,QTDPOSICOES
    ,QTDDECIMAIS
    ,DSOBSERVACAO
    ,DSIDENTIFICADOR_REGISTRO)
  VALUES
    (13
    ,'B5'
    ,6
    ,'DTLANCAMENTO'
    ,'D'
    ,'YYYYMMDD'
    ,31
    ,8
    ,NULL
    ,'Data de Lançamento'
    ,NULL);

  INSERT INTO tbgen_layout_campo
    (IDLAYOUT
    ,TPREGISTRO
    ,NRSEQUENCIA_CAMPO
    ,NMCAMPO
    ,TPDADO
    ,DSFORMATO
    ,NRPOSICAO_INICIAL
    ,QTDPOSICOES
    ,QTDDECIMAIS
    ,DSOBSERVACAO
    ,DSIDENTIFICADOR_REGISTRO)
  VALUES
    (13
    ,'B5'
    ,7
    ,'CDOPERACAO'
    ,'N'
    ,NULL
    ,39
    ,6
    ,NULL
    ,'Código da Operação'
    ,NULL);

  INSERT INTO tbgen_layout_campo
    (IDLAYOUT
    ,TPREGISTRO
    ,NRSEQUENCIA_CAMPO
    ,NMCAMPO
    ,TPDADO
    ,DSFORMATO
    ,NRPOSICAO_INICIAL
    ,QTDPOSICOES
    ,QTDDECIMAIS
    ,DSOBSERVACAO
    ,DSIDENTIFICADOR_REGISTRO)
  VALUES
    (13
    ,'B5'
    ,8
    ,'VLOPERACAO'
    ,'N'
    ,NULL
    ,45
    ,8
    ,2
    ,'Valor da Operação'
    ,NULL);

  INSERT INTO tbgen_layout_campo
    (IDLAYOUT
    ,TPREGISTRO
    ,NRSEQUENCIA_CAMPO
    ,NMCAMPO
    ,TPDADO
    ,DSFORMATO
    ,NRPOSICAO_INICIAL
    ,QTDPOSICOES
    ,QTDDECIMAIS
    ,DSOBSERVACAO
    ,DSIDENTIFICADOR_REGISTRO)
  VALUES
    (13
    ,'B5'
    ,9
    ,'INCLIENTE'
    ,'T'
    ,NULL
    ,53
    ,18
    ,NULL
    ,'Identificação do Cliente'
    ,NULL);

  INSERT INTO tbgen_layout_campo
    (IDLAYOUT
    ,TPREGISTRO
    ,NRSEQUENCIA_CAMPO
    ,NMCAMPO
    ,TPDADO
    ,DSFORMATO
    ,NRPOSICAO_INICIAL
    ,QTDPOSICOES
    ,QTDDECIMAIS
    ,DSOBSERVACAO
    ,DSIDENTIFICADOR_REGISTRO)
  VALUES
    (13
    ,'B5'
    ,10
    ,'CDNSUREGISTRO'
    ,'N'
    ,NULL
    ,74
    ,6
    ,NULL
    ,'NSU do Registro'
    ,NULL);

  INSERT INTO tbgen_layout_campo
    (IDLAYOUT
    ,TPREGISTRO
    ,NRSEQUENCIA_CAMPO
    ,NMCAMPO
    ,TPDADO
    ,DSFORMATO
    ,NRPOSICAO_INICIAL
    ,QTDPOSICOES
    ,QTDDECIMAIS
    ,DSOBSERVACAO
    ,DSIDENTIFICADOR_REGISTRO)
  VALUES
    (13
    ,'B5'
    ,11
    ,'INEXTENSAO'
    ,'T'
    ,NULL
    ,80
    ,1
    ,NULL
    ,'Indicador de Extensão'
    ,NULL);

  COMMIT;

END;
