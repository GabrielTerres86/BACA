/* .............................................................................

   Programa: Fontes/acha_lock.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/2005.                         Ultima atualizacao:   /  /    

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Identificar quem esta prendendo um registro.

   Alteracoes: 

............................................................................. */

DEF INPUT  PARAM par_recid    AS INT                                   NO-UNDO.
DEF INPUT  PARAM par_nmtabela AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM par_dscritic AS CHAR                                  NO-UNDO.

DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR aux_nmusuari AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdmicro AS CHAR                                           NO-UNDO.

FIND FIRST _file WHERE _file-name = par_nmtabela NO-LOCK NO-ERROR.

IF   NOT AVAILABLE _file   THEN
     RETURN.
     
FIND FIRST _lock WHERE _lock-table = _file._file-number   AND
                       _lock-recid = par_recid NO-LOCK NO-ERROR.
                       
IF   NOT AVAILABLE _lock   THEN
     RETURN.
display _lock-usr.
FIND _connect WHERE _connect._connect-usr = _lock-usr NO-LOCK NO-ERROR.
     
IF   NOT AVAILABLE _connect   THEN
     RETURN.
             
INPUT THROUGH VALUE("script/acha_usuario.sh " +
                    TRIM(_lock-name) + " " + 
                    TRIM(SUBSTRING(_connect-device,6,20))) NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET aux_nmusuari FORMAT "x(40)" 
       aux_nmdmicro FORMAT "x(20)"
       WITH NO-BOX NO-LABELS FRAME f_ls.
   
   LEAVE.
   
END.  /*  Fim do DO WHILE TRUE  */

par_dscritic = TRIM(aux_nmusuari) + " em " +
               TRIM(aux_nmdmicro) + "(" + TRIM(_connect-device) + ")".

/* .......................................................................... */

