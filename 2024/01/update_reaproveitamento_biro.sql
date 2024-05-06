begin

  UPDATE crapprm
  SET DSVLRPRM = 'S'
  WHERE CDACESSO = 'FL_SALVAR_ARQ_RET_BIRO';
    
  COMMIT;

end;
