BEGIN
  INSERT INTO crapprg
    (nmsistem,
     cdprogra,
     dsprogra##1,
     dsprogra##2,
     dsprogra##3,
     dsprogra##4,
     nrsolici,
     nrordprg,
     inctrprg,
     cdrelato##1,
     cdrelato##2,
     cdrelato##3,
     cdrelato##4,
     cdrelato##5,
     inlibprg,
     cdcooper,
     qtminmed)
  VALUES
    ('CRED',
     'JB_COMIMOB',
     'COMISS�O DO CR�DITO IMOBILI�RIO',
     'RELAT�RIO DE COMISS�O DO CR�DITO IMOBILI�RIO DO M�S ANTERIOR',
     NULL,
     NULL,
     9999,
     850,
     1,
     850,
     0,
     0,
     0,
     0,
     1,
     3,
     NULL);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(sqlerrm);
    ROLLBACK;
END;
/
