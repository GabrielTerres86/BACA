/* ............................................................................

Programa : cria_arq_leitura.p
Autor    : Julio
Objetivo : Atualizar arquivo de leituras e gravacoes do banco conectado.

.............................................................................*/

DEFIN INPUT PARAMETER par_nmcooper AS CHAR.

DEFINE STREAM str_1.

OUTPUT STREAM str_1 TO         
       VALUE("/usr/coop/" + par_nmcooper + "/log/leitura_banco.lst").

FOR EACH _file WHERE NOT _file._frozen NO-LOCK:

    FIND _tablestat WHERE _tablestat._tablestat-id = _file._file-num 
         NO-LOCK NO-ERROR.
    
    IF   AVAILABLE _tablestat   THEN
         DO:
             PUT STREAM str_1 _file._file-name
                              _tablestat._tablestat-id
                              _tablestat._tablestat-read 
                              _tablestat._tablestat-update 
                              _tablestat._tablestat-delete
                              _tablestat._tablestat-create SKIP.
         END.

END.

OUTPUT STREAM str_1 CLOSE.
                                                                        
/*...........................................................................*/
                                                                        
                                                                        
