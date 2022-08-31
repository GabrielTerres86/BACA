 Begin

 UPDATE cecred.crapprm
    SET dsvlrprm = 'A'
  WHERE cdacesso = 'FLG_PAG_FGTS_CXON'
    AND cdcooper = 16;

commit;

end;