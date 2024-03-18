BEGIN
  UPDATE craptel SET flgtelbl = 0 WHERE nmdatela = 'VERIGE';
  UPDATE crapprg SET inlibprg = 0 WHERE cdprogra = 'VERIGE';
  COMMIT;
END;
