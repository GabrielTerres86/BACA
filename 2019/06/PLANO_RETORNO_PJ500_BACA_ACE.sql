UPDATE CRAPTEL 
   SET CDOPPTEL = '@,C,T,R,L',
        lsopptel = 'Acesso,Consulta,Remessa,Relatorio,Log'
WHERE NMDATELA LIKE 'UPPGTO';

DELETE CRAPACE
 WHERE NMDATELA = 'UPPGTO'
   AND CDDOPCAO = 'E'
   AND CDOPERAD IN ('F0030497',
                    'F0030598',
                    'F0030636',
                    'F0031411',
                    'F0030868',
                    'F0030215');

Commit;                    
