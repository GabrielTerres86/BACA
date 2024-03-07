BEGIN
  DELETE FROM craptel WHERE nmdatela = 'VERIGE';
  DELETE FROM crapace WHERE nmdatela = 'VERIGE';
  DELETE FROM crapprg WHERE cdprogra = 'VERIGE';
  COMMIT;
END;
