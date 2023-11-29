BEGIN
  UPDATE crapprm prm
     SET prm.dsvlrprm = 1
   WHERE prm.CDACESSO = 'SAQPAG_NOVO_CORE';

  COMMIT;
END;
