DECLARE
  v_nrseqrdr NUMBER(10);
BEGIN
  INSERT INTO CRAPRDR (NMPROGRA,
                       DTSOLICI) 
               VALUES ('TELA_PREJ',
                       SYSDATE)
              RETURNING NRSEQRDR INTO v_nrseqrdr;
              
  INSERT INTO CRAPACA (NMDEACAO, 
                       NMPACKAG, 
                       NMPROCED, 
                       LSTPARAM, 
                       NRSEQRDR)
              VALUES ('CARREGA_PARAM_EXIBE_PREJU', 
                      NULL, 
                      'CREDITO.obtemParametroPrejuzTopaz', 
                      NULL, 
                      v_nrseqrdr);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
