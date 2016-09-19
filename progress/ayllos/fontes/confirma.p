/* ............................................................................

   Programa: Fontes/confirma.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Agosto/2009                        Ultima atualizacao:

   Dados referente ao programa:

   Frequencia: Diario (Sempre que chamado por outros programas).

   Objetivo  : Apresentar mensagem de confirmacao de operacao.

   Alteracoes:

.............................................................................*/

{ includes/var_online.i }

/* Parametro para perguna especifica, sem usar a critica 78 de confirmacao */
DEF INPUT  PARAM par_dspergun AS CHAR                               NO-UNDO.

DEF OUTPUT PARAM par_confirma AS CHAR FORMAT "!"                    NO-UNDO.


/* Confirma */
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
   ASSIGN par_confirma = "N".
   
   IF   par_dspergun = ""   THEN
        DO:
            glb_cdcritic = 78.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL. 
            MESSAGE COLOR NORMAL glb_dscritic UPDATE par_confirma.
        
        END.
   ELSE
        DO:
            BELL.
            MESSAGE COLOR NORMAL par_dspergun UPDATE par_confirma.
        END.
        
   LEAVE.
                   
END.

     /* Cancelado */
IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
     par_confirma <> "S" THEN
     DO:
         glb_cdcritic = 79.
         RUN fontes/critic.p.
         glb_cdcritic = 0.
         MESSAGE glb_dscritic.
     END. 
     

/*............................................................................*/
