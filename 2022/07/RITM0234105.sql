BEGIN
  INSERT INTO cecred.tbgen_layout_campo
    (idlayout
    ,tpregistro
    ,nrsequencia_campo
    ,nmcampo
    ,tpdado
    ,dsformato
    ,nrposicao_inicial
    ,qtdposicoes
    ,qtddecimais
    ,dsobservacao
    ,dsidentificador_registro)
  VALUES
    (18
    ,'95'
    ,1
    ,'TPREGISTRO'
    ,'N'
    ,NULL
    ,8
    ,2
    ,NULL
    ,NULL
    ,'95');

  INSERT INTO cecred.tbgen_layout_campo
    (idlayout
    ,tpregistro
    ,nrsequencia_campo
    ,nmcampo
    ,tpdado
    ,dsformato
    ,nrposicao_inicial
    ,qtdposicoes
    ,qtddecimais
    ,dsobservacao
    ,dsidentificador_registro)
  VALUES
    (18
    ,'95'
    ,2
    ,'IDCONTRATO'
    ,'T'
    ,NULL
    ,10
    ,20
    ,NULL
    ,'CODIGO IDENTIFICADOR DA OPERACAO DE CREDITO'
    ,NULL);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
