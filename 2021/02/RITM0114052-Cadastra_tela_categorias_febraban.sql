DECLARE

  vr_msg    VARCHAR2(500);
  vr_exc    EXCEPTION;

BEGIN
  --
  BEGIN 
    UPDATE craptel
      SET cdopptel  = cdopptel || ',K'
        , lsopptel = lsopptel || ',CAD. CATEGORIA FEBRABAN'
    WHERE nmdatela = 'HISTOR'
      AND CDCOOPER = 3;
    --
    dbms_output.put_line(SQL%ROWCOUNT || ' registros atualizados.');
    --
  EXCEPTION
    WHEN OTHERS THEN
      --
      vr_msg := 'Erro ao atualizar a CRAPTEL: ' || SQLERRM;
      RAISE vr_exc;
      --
  END;
  --
  BEGIN 
    INSERT INTO cecred.crapace (
      nmdatela
      , cddopcao
      , cdoperad
      , nmrotina
      , cdcooper
      , nrmodulo
      , idevento
      , idambace
    )
    SELECT ace.nmdatela
      , 'K'
      , ace.cdoperad
      , ace.nmrotina
      , ace.cdcooper
      , ace.nrmodulo
      , ace.idevento
      , ace.idambace
    FROM cecred.crapace ace
    WHERE UPPER(ace.nmdatela) = 'HISTOR'
      AND UPPER(ace.cddopcao) = 'I';
    --
    dbms_output.put_line(SQL%ROWCOUNT || ' registros inseridos.');
    --
  EXCEPTION
    WHEN OTHERS THEN
      --
      vr_msg := 'Erro ao inserir dados na CRAPACE: ' || SQLERRM;
      RAISE vr_exc;
      --
  END;
  --
  COMMIT;
  --
EXCEPTION
  WHEN vr_exc THEN
    RAISE_APPLICATION_ERROR(-20000, vr_msg);
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
