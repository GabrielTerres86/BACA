-- APAGAR O ACESSO A OPCAO "A" DA DEVOLU
-- DE TODOS OS OPERADORES QUE NÃO SEJAM 
-- DO DEPARTAMENTO "4 - COMPE"
DELETE crapace t
 WHERE t.nmdatela = 'DEVOLU'
   AND t.cddopcao = 'A'
   AND NOT EXISTS(SELECT 1
                    FROM crapope o
                   WHERE o.cdcooper = t.cdcooper
                     AND o.cdoperad = t.cdoperad
                     AND o.cddepart = 4);

COMMIT;
