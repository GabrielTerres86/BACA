PL/SQL Developer Test script 3.0
15
/*
INC0027091 - Inclus�o de c�digo de motivo para SMS n�o contratado (Douglas Pagel / AMcom)
*/
begin
  
FOR rw IN (SELECT cdcooper FROM crapcop) LOOP 

  insert into crapmot (CDCOOPER, CDDBANCO, CDOCORRE, TPOCORRE, CDMOTIVO, DSMOTIVO, DSABREVI, CDOPERAD, DTALTERA, HRTRANSA)

  values (rw.cdcooper, 85, 26, 2, 'XW', 'Servi�o de SMS n�o contratado', ' ', '1', TRUNC(SYSDATE), 0);

END LOOP;

  COMMIT;
end;
0
0
