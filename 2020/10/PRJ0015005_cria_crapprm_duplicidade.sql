insert into crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values
  ('CRED',
   0,
   'TEMPODUPLICIDADEPIX',
   'Tempo limite para validação de PIX em duplicidade',
   '10;1');
 /* 
    SELECT prm.dsvlrprm
            FROM crapprm prm
           WHERE prm.nmsistem = 'CRED'
             AND prm.cdcooper = 0 
             AND prm.cdacesso = 'TEMPODUPLICIDADEPIX'
           ORDER BY prm.cdcooper DESC ; -->
 */  
           
 
commit;
