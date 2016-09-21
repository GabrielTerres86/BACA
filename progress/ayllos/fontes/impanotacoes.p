/* .............................................................................

   Programa: Fontes/Impanotacoes.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Margarete/Edson
   Data    : Dezembro/2001                       Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para imprimir e ou visualizar as ANOTACOES.
   
   Alteracoes: 24/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
   
               03/02/2011 - Inserifo FORMAT "x(40)" para crapass.nmprimtl
                            (Diego).
                            
               24/02/2011 - Utilizacao de BO - (Gabriel Capoia, DB1)
               
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
............................................................................. */

{ includes/var_online.i }

{ includes/var_anota.i }

DEF STREAM str_1.

/* utilizados pelo includes impressao.i */

DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"        NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"        NO-UNDO.

DEF VAR par_flgrodar AS LOGI INIT TRUE                               NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                         NO-UNDO.
DEF VAR par_flgcance AS LOGI                                         NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                         NO-UNDO.

DEF VAR aux_nmendter AS CHAR                                         NO-UNDO.
DEF VAR aux_contador AS INT                                          NO-UNDO.

DEF VAR aux_flgescra AS LOGICAL                                      NO-UNDO.


DEF VAR h-b1wgen0085 AS HANDLE                                       NO-UNDO.

DEF VAR aux_nmarqpdf AS CHAR                                         NO-UNDO.

DEF TEMP-TABLE tt_erro NO-UNDO LIKE craperr.

FORM " Aguarde... "
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

EMPTY TEMP-TABLE tt_erro.

VIEW FRAME f_aguarde.

INPUT THROUGH basename `tty` NO-ECHO.

IMPORT aux_nmendter.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

RUN sistema/generico/procedures/b1wgen0085.p PERSISTENT
                    SET h-b1wgen0085.

IF  NOT VALID-HANDLE(h-b1wgen0085)  THEN
    DO:
        MESSAGE 'Handle h-b1wgen0085 inválida'.
        PAUSE 3 NO-MESSAGE.
        HIDE MESSAGE NO-PAUSE.

        HIDE FRAME f_aguarde NO-PAUSE.
    END.
ELSE
    DO: 
        
        RUN Gera_Impressao IN h-b1wgen0085
             ( INPUT glb_cdcooper,  
               INPUT 0,
               INPUT 0,
               INPUT glb_cdoperad,
               INPUT glb_nmdatela,
               INPUT 1,
               INPUT glb_dtmvtolt,
               INPUT tel_nrdconta,
               INPUT 1,
               INPUT aux_nrseqdig,
               INPUT aux_nmendter,
               INPUT YES,
               INPUT aux_tipconsu,
              OUTPUT aux_nmarqimp,
              OUTPUT aux_nmarqpdf,
              OUTPUT TABLE tt_erro ).
        
        IF  VALID-HANDLE(h-b1wgen0085) THEN
            DELETE OBJECT h-b1wgen0085.

        IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt_erro:HAS-RECORDS THEN
            DO:
               FIND FIRST tt_erro NO-ERROR.
        
               IF  AVAILABLE tt_erro THEN
                   DO:
                      MESSAGE tt_erro.dscritic.
                      RETURN "NOK".
                   END.
               HIDE FRAME f_aguarde NO-PAUSE.

            END.
    END.
    
HIDE FRAME f_aguarde NO-PAUSE.

IF   NOT aux_tipconsu   THEN
     DO:
         /*** nao necessario ao programa somente para nao dar erro 
              de compilacao na rotina de impressao ****/
         FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                                  NO-LOCK NO-ERROR.

         { includes/impressao.i }
         
         HIDE MESSAGE NO-PAUSE.
     END.

RETURN.

/* .......................................................................... */

