begin
  
FOR rw_crapcop IN (SELECT cdcooper FROM crapcop) LOOP 

  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER)
      values ('CRED', 'SEGEMP', 'Parâmetros Segmento Empréstimo', ' ', ' ', ' ', 50, (SELECT MAX(g.nrordprg)+1 FROM crapprg g WHERE g.cdcooper = rw_crapcop.cdcooper AND g.nrsolici = 50), 1, 0, 0, 0, 0, 0, 1, rw_crapcop.cdcooper); 

END LOOP;

  COMMIT;
end;