BEGIN

  UPDATE cecred.crapprg SET inlibprg = 2, nrsolici = 9516 WHERE UPPER(cdprogra) = 'CRPS516' AND cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16);
  UPDATE cecred.crapprg SET inlibprg = 2, nrsolici = 9280 WHERE UPPER(cdprogra) = 'CRPS280' AND cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16);
  UPDATE cecred.crapprg SET inlibprg = 2, nrsolici = 9634 WHERE UPPER(cdprogra) = 'CRPS634' AND cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16);
  UPDATE cecred.crapprg SET inlibprg = 2, nrsolici = 9635 WHERE UPPER(cdprogra) = 'CRPS635' AND cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16);
  UPDATE cecred.crapprg SET inlibprg = 2, nrsolici = 9627 WHERE UPPER(cdprogra) = 'CRPS627' AND cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16);
  UPDATE cecred.crapprg SET inlibprg = 2, nrsolici = 9628 WHERE UPPER(cdprogra) = 'CRPS628' AND cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16);
  UPDATE cecred.crapprg SET inlibprg = 2, nrsolici = 9299 WHERE UPPER(cdprogra) = 'CRPS299' AND cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16);
  UPDATE cecred.crapprg SET inlibprg = 2, nrsolici = 9515 WHERE UPPER(cdprogra) = 'CRPS515' AND cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16);
  UPDATE cecred.crapprg SET inlibprg = 2, nrsolici = 9310 WHERE UPPER(cdprogra) = 'CRPS310' AND cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRID', 'Cadeia diária Central de Risco 515e (634e (635e (516e)))', ' ', ' ', ' ', 1, 101, 1, 0, 0, 0, 0, 0, 1, 1, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRIM', 'Cadeia mensal Central de Risco 310e (299p, 627p (628e (516p, 280p)))', '.', '.', '.', 41, 5, 1, 0, 0, 0, 0, 0, 1, 1, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRID', 'Cadeia diária Central de Risco 515e (634e (635e (516e)))', ' ', ' ', ' ', 1, 101, 1, 0, 0, 0, 0, 0, 1, 2, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRIM', 'Cadeia mensal Central de Risco 310e (299p, 627p (628e (516p, 280p)))', '.', '.', '.', 41, 5, 1, 0, 0, 0, 0, 0, 1, 2, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRID', 'Cadeia diária Central de Risco 515e (516e)', ' ', ' ', ' ', 1, 101, 1, 0, 0, 0, 0, 0, 1, 3, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRIM', 'Cadeia mensal Central de Risco 310e (299p, 516p, 280p)', '.', '.', '.', 41, 5, 1, 0, 0, 0, 0, 0, 1, 3, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRID', 'Cadeia diária Central de Risco 515e (634e (635e (516e)))', ' ', ' ', ' ', 1, 101, 1, 0, 0, 0, 0, 0, 1, 5, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRIM', 'Cadeia mensal Central de Risco 310e (299p, 627p (628e (516p, 280p)))', '.', '.', '.', 41, 5, 1, 0, 0, 0, 0, 0, 1, 5, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRID', 'Cadeia diária Central de Risco 515e (634e (635e (516e)))', ' ', ' ', ' ', 1, 101, 1, 0, 0, 0, 0, 0, 1, 6, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRIM', 'Cadeia mensal Central de Risco 310e (299p, 627p (628e (516p, 280p)))', '.', '.', '.', 41, 5, 1, 0, 0, 0, 0, 0, 1, 6, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRID', 'Cadeia diária Central de Risco 515e (634e (635e (516e)))', ' ', ' ', ' ', 1, 101, 1, 0, 0, 0, 0, 0, 1, 7, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRIM', 'Cadeia mensal Central de Risco 310e (299p, 627p (628e (516p, 280p)))', '.', '.', '.', 41, 5, 1, 0, 0, 0, 0, 0, 1, 7, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRID', 'Cadeia diária Central de Risco 515e (634e (635e (516e)))', ' ', ' ', ' ', 1, 101, 1, 0, 0, 0, 0, 0, 1, 8, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRIM', 'Cadeia mensal Central de Risco 310e (299p, 627p (628e (516p, 280p)))', '.', '.', '.', 41, 5, 1, 0, 0, 0, 0, 0, 1, 8, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRID', 'Cadeia diária Central de Risco 515e (634e (635e (516e)))', ' ', ' ', ' ', 1, 101, 1, 0, 0, 0, 0, 0, 1, 9, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRIM', 'Cadeia mensal Central de Risco 310e (299p, 627p (628e (516p, 280p)))', '.', '.', '.', 41, 5, 1, 0, 0, 0, 0, 0, 1, 9, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRID', 'Cadeia diária Central de Risco 515e (634e (635e (516e)))', ' ', ' ', ' ', 1, 101, 1, 0, 0, 0, 0, 0, 1, 10, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRIM', 'Cadeia mensal Central de Risco 310e (299p, 627p (628e (516p, 280p)))', '.', '.', '.', 41, 5, 1, 0, 0, 0, 0, 0, 1, 10, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRID', 'Cadeia diária Central de Risco 515e (634e (635e (516e)))', ' ', ' ', ' ', 1, 101, 1, 0, 0, 0, 0, 0, 1, 11, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRIM', 'Cadeia mensal Central de Risco 310e (299p, 627p (628e (516p, 280p)))', '.', '.', '.', 41, 5, 1, 0, 0, 0, 0, 0, 1, 11, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRID', 'Cadeia diária Central de Risco 515e (634e (635e (516e)))', ' ', ' ', ' ', 1, 101, 1, 0, 0, 0, 0, 0, 1, 12, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRIM', 'Cadeia mensal Central de Risco 310e (299p, 627p (628e (516p, 280p)))', '.', '.', '.', 41, 5, 1, 0, 0, 0, 0, 0, 1, 12, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRID', 'Cadeia diária Central de Risco 515e (634e (635e (516e)))', ' ', ' ', ' ', 1, 101, 1, 0, 0, 0, 0, 0, 1, 13, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRIM', 'Cadeia mensal Central de Risco 310e (299p, 627p (628e (516p, 280p)))', '.', '.', '.', 41, 5, 1, 0, 0, 0, 0, 0, 1, 13, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRID', 'Cadeia diária Central de Risco 515e (634e (635e (516e)))', ' ', ' ', ' ', 1, 101, 1, 0, 0, 0, 0, 0, 1, 14, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRIM', 'Cadeia mensal Central de Risco 310e (299p, 627p (628e (516p, 280p)))', '.', '.', '.', 41, 5, 1, 0, 0, 0, 0, 0, 1, 14, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRID', 'Cadeia diária Central de Risco 515e (634e (635e (516e)))', ' ', ' ', ' ', 1, 101, 1, 0, 0, 0, 0, 0, 1, 16, null);

  insert into cecred.crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CRPSRIM', 'Cadeia mensal Central de Risco 310e (299p, 627p (628e (516p, 280p)))', '.', '.', '.', 41, 5, 1, 0, 0, 0, 0, 0, 1, 16, null);

  INSERT INTO CECRED.CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 1, 'CADEIA_CENTRAL_RISCO', 'Identifica última data de execução da cadeia da central de risco. Atualizada pelo programa crps516/280', '15/11/2023');
  INSERT INTO CECRED.CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 2, 'CADEIA_CENTRAL_RISCO', 'Identifica última data de execução da cadeia da central de risco. Atualizada pelo programa crps516/280', '15/11/2023');
  INSERT INTO CECRED.CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 3, 'CADEIA_CENTRAL_RISCO', 'Identifica última data de execução da cadeia da central de risco. Atualizada pelo programa crps516/280', '15/11/2023');
  INSERT INTO CECRED.CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 5, 'CADEIA_CENTRAL_RISCO', 'Identifica última data de execução da cadeia da central de risco. Atualizada pelo programa crps516/280', '15/11/2023');
  INSERT INTO CECRED.CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 6, 'CADEIA_CENTRAL_RISCO', 'Identifica última data de execução da cadeia da central de risco. Atualizada pelo programa crps516/280', '15/11/2023');
  INSERT INTO CECRED.CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 7, 'CADEIA_CENTRAL_RISCO', 'Identifica última data de execução da cadeia da central de risco. Atualizada pelo programa crps516/280', '15/11/2023');
  INSERT INTO CECRED.CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 8, 'CADEIA_CENTRAL_RISCO', 'Identifica última data de execução da cadeia da central de risco. Atualizada pelo programa crps516/280', '15/11/2023');
  INSERT INTO CECRED.CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 9, 'CADEIA_CENTRAL_RISCO', 'Identifica última data de execução da cadeia da central de risco. Atualizada pelo programa crps516/280', '15/11/2023');
  INSERT INTO CECRED.CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 10, 'CADEIA_CENTRAL_RISCO', 'Identifica última data de execução da cadeia da central de risco. Atualizada pelo programa crps516/280', '15/11/2023');
  INSERT INTO CECRED.CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 11, 'CADEIA_CENTRAL_RISCO', 'Identifica última data de execução da cadeia da central de risco. Atualizada pelo programa crps516/280', '15/11/2023');
  INSERT INTO CECRED.CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 12, 'CADEIA_CENTRAL_RISCO', 'Identifica última data de execução da cadeia da central de risco. Atualizada pelo programa crps516/280', '15/11/2023');
  INSERT INTO CECRED.CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 13, 'CADEIA_CENTRAL_RISCO', 'Identifica última data de execução da cadeia da central de risco. Atualizada pelo programa crps516/280', '15/11/2023');
  INSERT INTO CECRED.CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 14, 'CADEIA_CENTRAL_RISCO', 'Identifica última data de execução da cadeia da central de risco. Atualizada pelo programa crps516/280', '15/11/2023');
  INSERT INTO CECRED.CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 16, 'CADEIA_CENTRAL_RISCO', 'Identifica última data de execução da cadeia da central de risco. Atualizada pelo programa crps516/280', '15/11/2023');
  
  COMMIT;
END;
