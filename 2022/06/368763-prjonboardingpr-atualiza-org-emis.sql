DECLARE

  CURSOR CR_IDORG IS
    SELECT ( MAX(E.IDORGAO_EXPEDIDOR) + 1 ) ID_NEXT
    FROM CECRED.TBGEN_ORGAO_EXPEDIDOR E;

  vr_idorgao_expedidor  CECRED.TBGEN_ORGAO_EXPEDIDOR.IDORGAO_EXPEDIDOR%TYPE;

BEGIN
  
  UPDATE CECRED.TBGEN_ORGAO_EXPEDIDOR E
    SET E.Nmorgao_Expedidor = 'Conselho Regional de Contabilidade'
  WHERE E.IDORGAO_EXPEDIDOR = 12;
  
  UPDATE CECRED.TBGEN_ORGAO_EXPEDIDOR E
    SET E.Nmorgao_Expedidor = 'Secretaria de Defesa Social'
  WHERE E.IDORGAO_EXPEDIDOR = 55;
  
  UPDATE CECRED.TBGEN_ORGAO_EXPEDIDOR E
    SET E.Nmorgao_Expedidor = 'Registro Civil das Pessoas Naturais'
      , E.Cdorgao_Expedidor = 'RCPN'
  WHERE E.IDORGAO_EXPEDIDOR = 69;
  
  OPEN CR_IDORG;
  FETCH CR_IDORG INTO vr_idorgao_expedidor;
  CLOSE CR_IDORG;
  
  INSERT INTO CECRED.TBGEN_ORGAO_EXPEDIDOR (
    idorgao_expedidor
    , cdorgao_expedidor
    , nmorgao_expedidor
  ) VALUES (
    vr_idorgao_expedidor
    , 'CAU'
    , 'Conselho de Arquitetura e Urbanismo do Brasil'
  );
  
  vr_idorgao_expedidor := vr_idorgao_expedidor + 1;
  
  INSERT INTO CECRED.TBGEN_ORGAO_EXPEDIDOR (
    idorgao_expedidor
    , cdorgao_expedidor
    , nmorgao_expedidor
  ) VALUES (
    vr_idorgao_expedidor
    , 'CRBIO'
    , 'Conselho Regional de Biologia'
  );
  
  vr_idorgao_expedidor := vr_idorgao_expedidor + 1;
  
  INSERT INTO CECRED.TBGEN_ORGAO_EXPEDIDOR (
    idorgao_expedidor
    , cdorgao_expedidor
    , nmorgao_expedidor
  ) VALUES (
    vr_idorgao_expedidor
    , 'CRBM'
    , 'Conselho Regional de Biomedicina'
  );
  
  vr_idorgao_expedidor := vr_idorgao_expedidor + 1;
  
  INSERT INTO CECRED.TBGEN_ORGAO_EXPEDIDOR (
    idorgao_expedidor
    , cdorgao_expedidor
    , nmorgao_expedidor
  ) VALUES (
    vr_idorgao_expedidor
    , 'CRED'
    , 'Conselho Regional de Economistas Domésticos'
  );
  
  vr_idorgao_expedidor := vr_idorgao_expedidor + 1;
  
  INSERT INTO CECRED.TBGEN_ORGAO_EXPEDIDOR (
    idorgao_expedidor
    , cdorgao_expedidor
    , nmorgao_expedidor
  ) VALUES (
    vr_idorgao_expedidor
    , 'CREP'
    , 'Conselho Regional de Educadores e Pedagogos'
  );
  
  vr_idorgao_expedidor := vr_idorgao_expedidor + 1;
  
  INSERT INTO CECRED.TBGEN_ORGAO_EXPEDIDOR (
    idorgao_expedidor
    , cdorgao_expedidor
    , nmorgao_expedidor
  ) VALUES (
    vr_idorgao_expedidor
    , 'CREF'
    , 'Conselho Regional de Educação Física'
  );
  
  vr_idorgao_expedidor := vr_idorgao_expedidor + 1;
  
  INSERT INTO CECRED.TBGEN_ORGAO_EXPEDIDOR (
    idorgao_expedidor
    , cdorgao_expedidor
    , nmorgao_expedidor
  ) VALUES (
    vr_idorgao_expedidor
    , 'CREFONO'
    , 'Conselho Regional de Fonoaudiologia'
  );
  
  vr_idorgao_expedidor := vr_idorgao_expedidor + 1;
  
  INSERT INTO CECRED.TBGEN_ORGAO_EXPEDIDOR (
    idorgao_expedidor
    , cdorgao_expedidor
    , nmorgao_expedidor
  ) VALUES (
    vr_idorgao_expedidor
    , 'COREM'
    , 'Conselho Regional de Museologia'
  );
  
  vr_idorgao_expedidor := vr_idorgao_expedidor + 1;
  
  INSERT INTO CECRED.TBGEN_ORGAO_EXPEDIDOR (
    idorgao_expedidor
    , cdorgao_expedidor
    , nmorgao_expedidor
  ) VALUES (
    vr_idorgao_expedidor
    , 'CRTR'
    , 'Conselho Regional de Técnicos em Radiologia'
  );
  
  vr_idorgao_expedidor := vr_idorgao_expedidor + 1;
  
  INSERT INTO CECRED.TBGEN_ORGAO_EXPEDIDOR (
    idorgao_expedidor
    , cdorgao_expedidor
    , nmorgao_expedidor
  ) VALUES (
    vr_idorgao_expedidor
    , 'CRT'
    , 'Conselho Regional dos Técnicos Industriais'
  );
  
  vr_idorgao_expedidor := vr_idorgao_expedidor + 1;
  
  INSERT INTO CECRED.TBGEN_ORGAO_EXPEDIDOR (
    idorgao_expedidor
    , cdorgao_expedidor
    , nmorgao_expedidor
  ) VALUES (
    vr_idorgao_expedidor
    , 'CRTA'
    , 'Conselho Regional dos Técnicos Agrícolas'
  );
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
