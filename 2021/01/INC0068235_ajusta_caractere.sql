/*
  Realizar implementacao da RDM0037938
  [INC0068235] Caractere especial no nome do remetente de transfer�ncia DOC
*/
UPDATE gncpdoc
   SET nmpesemi = 'ADEGA TANINO E EMPORIO COMERCIO B. LTDA'
 WHERE progress_recid = 3198453;

COMMIT;
