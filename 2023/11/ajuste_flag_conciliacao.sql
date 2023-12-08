BEGIN
  UPDATE crapprm prm
     SET prm.dsvlrprm = 0
   WHERE prm.CDACESSO = 'SAQPAG_NOVO_CORE';

  COMMIT;
END;
