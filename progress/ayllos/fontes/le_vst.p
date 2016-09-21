/* ............................................................................

Programa : fontes/le_vst.p
Autor    : Julio
Objetivo : Fazer a coleta da quantidade de leituras, gravacoes e exclusoes no
           banco de dados conectado. Utiliza para isto dois arquivos
           localizado no diretorio log de cada cooperativa: log_leituras.lst e 
           leitura_banco.lst.

Alteracoes : Tratamento para o banco unificado Ayllos (Julio)
.............................................................................*/

DEFINE STREAM str_1.
DEFINE STREAM str_2.

DEFINE VARIABLE aux_qtpassag AS INT NO-UNDO.
DEFINE VARIABLE aux_qtdispla AS INT  NO-UNDO.
DEFINE VARIABLE aux_nmtabela AS CHAR NO-UNDO.
DEFINE VARIABLE aux_idtabela AS CHAR NO-UNDO.
DEFINE VARIABLE aux_qtleitur AS CHAR NO-UNDO.
DEFINE VARIABLE aux_qtupdate AS CHAR NO-UNDO.
DEFINE VARIABLE aux_qtdelete AS CHAR NO-UNDO.
DEFINE VARIABLE aux_qtcreate AS CHAR NO-UNDO.
DEFINE VARIABLE aux_nmcooper AS CHAR NO-UNDO.
DEFINE VARIABLE aux_cdprogra AS CHAR NO-UNDO.
DEFINE VARIABLE aux_idusuari AS CHAR NO-UNDO.

DEFINE TEMP-TABLE ttleituras FIELD nmtabela AS CHAR FORMAT "x(12)"
                             FIELD idtabela AS int
                             FIELD qtleitur AS dec
                             FIELD qtupdate AS dec
                             FIELD qtdelete AS dec
                             FIELD qtcreate AS dec.

ASSIGN aux_idusuari = TRIM(ENTRY(1, SESSION:PARAMETER, ","))
       aux_nmcooper = TRIM(ENTRY(2, SESSION:PARAMETER, ","))
       aux_cdprogra = TRIM(ENTRY(3, SESSION:PARAMETER, ",")).
                            
IF   aux_idusuari = ""   THEN
     aux_idusuari = "root".

IF   aux_nmcooper = "progrid"   OR   aux_nmcooper = "gener"  OR 
     aux_nmcooper = "ayllos"  THEN
     aux_nmcooper = "cecred".
ELSE     
IF   aux_nmcooper = ""   THEN
     QUIT.

IF   aux_cdprogra = ""   THEN
     aux_cdprogra = "Geral".
                                     
IF   aux_nmcooper = "cecred" OR
     SEARCH("/usr/coop/" + aux_nmcooper + "/log/leitura_banco.lst") = ?   THEN
     RUN /usr/coop/sistema/ayllos/fontes/cria_arq_leitura.p(INPUT aux_nmcooper).

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   aux_qtpassag = aux_qtpassag + 2.
   EMPTY TEMP-TABLE ttleituras.                             
   INPUT STREAM str_1 FROM 
         VALUE("/usr/coop/" + aux_nmcooper + "/log/leitura_banco.lst") NO-ECHO.
                  
   REPEAT:

     SET STREAM str_1 aux_nmtabela FORMAT "x(12)"
                      aux_idtabela 
                      aux_qtleitur FORMAT "x(12)"
                      aux_qtupdate 
                      aux_qtdelete 
                      aux_qtcreate WITH WIDTH 78.

     IF aux_nmtabela BEGINS "x" THEN
        LEAVE.

     CREATE ttleituras.
     ASSIGN ttleituras.nmtabela = aux_nmtabela
            ttleituras.idtabela = int(aux_idtabela)
            ttleituras.qtleitur = dec(aux_qtleitur)
            ttleituras.qtupdate = dec(aux_qtupdate)
            ttleituras.qtdelete = dec(aux_qtdelete)
            ttleituras.qtcreate = dec(aux_qtcreate).

   END.

   INPUT STREAM str_1 CLOSE.

   OUTPUT STREAM str_1 TO 
                 VALUE("/usr/coop/" + aux_nmcooper + "/log/leitura_banco.lst").

   HIDE ALL NO-PAUSE.
   MESSAGE STRING(aux_qtpassag, "HH:MM:SS").

   FOR EACH ttleituras:
  
       FIND banco._tablestat WHERE 
                          banco._tablestat._tablestat-id = ttleituras.idtabela
                          NO-LOCK NO-ERROR.
              
       IF   AVAILABLE banco._tablestat   THEN
            ASSIGN ttleituras.qtleitur = 
                       banco._tablestat._tablestat-read - ttleituras.qtleitur
                   ttleituras.qtupdate =
                       banco._tablestat._tablestat-update - ttleituras.qtupdate
                   ttleituras.qtdelete =   
                       banco._tablestat._tablestat-delete - ttleituras.qtdelete
                   ttleituras.qtcreate = 
                       banco._tablestat._tablestat-create - ttleituras.qtcreate.
                          
       PUT STREAM str_1 ttleituras.nmtabela 
                        ttleituras.idtabela 
                        banco._tablestat._tablestat-read 
                        banco._tablestat._tablestat-update
                        banco._tablestat._tablestat-delete
                        banco._tablestat._tablestat-create
                        SKIP.
   END.

   OUTPUT STREAM str_1 CLOSE.

   aux_qtdispla = 0.

   FOR EACH ttleituras WHERE ttleituras.qtleitur > 0
                             NO-LOCK BY ttleituras.qtleitur DESC:
       
       aux_qtdispla = aux_qtdispla + 1.
 
       IF   aux_qtdispla < 16  THEN
            DISPLAY ttleituras.nmtabela LABEL "Tabela"
                    ttleituras.qtleitur  FORMAT "zzz,zzz,zz9-" LABEL "Read"
                    ttleituras.qtupdate  FORMAT "zzz,zzz,zz9-" LABEL "Update"
                    ttleituras.qtdelete  FORMAT "zzz,zzz,zz9-" LABEL "Delete"
                    ttleituras.qtcreate  FORMAT "zzz,zzz,zz9-" LABEL "Create".

   END.

   PAUSE(2) NO-MESSAGE.

END. /* do while true */

QUIT.                                                

/*..........................................................................*/

