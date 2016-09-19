/* .............................................................................

   Programa: Fontes/critica_cadastro_juridica.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Agosto/2006                     Ultima atualizacao: 28/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Critica se todos os campos obrigatorios do cadastro
               de pessoa juridica/administrativa estao preenchidos

   Alteracoes: 14/12/2006 - Tirada obrigacao da inscricao municipal. Altera-
                            cao aprovada pelo Ivo (Magui)
                            
               20/05/2010 - Adaptacao para uso de BO (Jose Luis, DB1)
               
               28/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM)
............................................................................. */

{ sistema/generico/includes/b1wgen0074tt.i } 
{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/gera_log.i}
{ sistema/generico/includes/gera_erro.i }
{ includes/var_online.i }

/* Variaveis para a opcao visualizar */

DEF INPUT  PARAM par_nrdconta AS INT                                  NO-UNDO.
DEF OUTPUT PARAM par_flgserro AS LOGICAL                              NO-UNDO.

DEF STREAM str_1.

DEF VAR aux_nmendter AS CHAR                                          NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                          NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!"                               NO-UNDO.
DEF VAR aux_contador AS INTE                                          NO-UNDO.

DEF VAR tel_dsimprim AS CHAR    FORMAT "x(08)" INIT "Imprimir"        NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(08)" INIT "Cancelar"        NO-UNDO.

DEF VAR par_flgrodar AS LOGI                                          NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                          NO-UNDO.
DEF VAR par_flgcance AS LOGI                                          NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                          NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                          NO-UNDO.

DEF VAR h-bowgen0074 AS HANDLE                                        NO-UNDO.

FORM "Aguarde... Imprimindo criticas do cadastro juridico"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
     TITLE glb_tldatela FRAME f_moldura.

IF  NOT VALID-HANDLE(h-bowgen0074) THEN
    RUN sistema/generico/procedures/b1wgen0074.p PERSISTENT SET h-bowgen0074.

RUN Critica_Cadastro IN  h-bowgen0074
    ( INPUT glb_cdcooper,
      INPUT par_nrdconta,
      INPUT 0,
      INPUT 0,
      INPUT glb_dtmvtolt,
      INPUT glb_cdoperad,
     OUTPUT TABLE tt-critica-cabec,
     OUTPUT TABLE tt-critica-cadas,
     OUTPUT TABLE tt-critica-ident,
     OUTPUT TABLE tt-critica-filia,
     OUTPUT TABLE tt-critica-ender,
     OUTPUT TABLE tt-critica-comer,
     OUTPUT TABLE tt-critica-telef,
     OUTPUT TABLE tt-critica-conju,
     OUTPUT TABLE tt-critica-ctato,
     OUTPUT TABLE tt-critica-respo,
     OUTPUT TABLE tt-critica-ctcor,
     OUTPUT TABLE tt-critica-regis,
     OUTPUT TABLE tt-critica-procu,
     OUTPUT TABLE tt-erro ) NO-ERROR .

DELETE PROCEDURE h-bowgen0074.

IF  ERROR-STATUS:ERROR  THEN
    DO:
       MESSAGE ERROR-STATUS:GET-MESSAGE(1).
       RETURN "NOK".
    END.

IF  RETURN-VALUE <> "OK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-erro THEN
            MESSAGE tt-erro.dscritic.
            
        RETURN "NOK".
    END.

RUN imprime_relacao (INPUT TRUE).

FIND FIRST tt-critica-cadas NO-LOCK NO-ERROR.

IF   NOT AVAILABLE tt-critica-cadas THEN
     par_flgserro = FALSE.
ELSE
     DO:
         ASSIGN par_flgserro = TRUE.

         VIEW FRAME f_moldura.

         PAUSE 0.

         RUN fontes/visrel.p (INPUT aux_nmarqimp).

         HIDE FRAME f_moldura.

         ASSIGN aux_confirma = "N".

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            MESSAGE "Imprimir a Relacao de Criticas ? (S)im/(N)ao:"
                    UPDATE aux_confirma.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

         IF   aux_confirma = "S"  THEN     /* Imprimir ficha cadastral */
              RUN imprime_relacao (INPUT FALSE).
     END.

PROCEDURE imprime_relacao:

  DEF INPUT PARAM par_impntela AS LOGICAL                             NO-UNDO.
  
  FORM tt-critica-cabec.nmextcop  AT 02 NO-LABEL FORMAT "x(50)" 
       SKIP(1)
       tt-critica-cabec.nrdconta  AT 02 LABEL "CONTA/DV" FORMAT "x(10)"
       " - "
       tt-critica-cabec.nmprimtl  AT 27 NO-LABEL FORMAT "x(40)"
       SKIP(1)
       "CRITICAS DE CADASTRAMENTO DE PESSOA JURIDICA" AT 21 
       SKIP(1)
       WITH COLUMN 02 NO-BOX SIDE-LABELS WIDTH 76 FRAME f_identi.
   
  FORM "------------------------------------------------------------------------------"
       SKIP
       "ITEM:"                            AT 30
       tt-critica-cadas.nmdatela  FORMAT "x(30)"
       SKIP
       "-----------------------------------------------------------------------~-------"
       SKIP
       "Falta preencher as seguintes informacoes:"
       SKIP(1)
       WITH COLUMN 02 NO-LABELS NO-BOX FRAME f_cabec.

  FORM "-"               AT 20
       tt-critica-cadas.nmdcampo  FORMAT "x(50)" 
       SKIP(1)
       WITH COLUMN 02 NO-LABELS NO-BOX FRAME f_campo.

  FORM SKIP(1)
       "Impresso em"
       tt-critica-cabec.dtmvtolt      NO-LABEL  FORMAT "99/99/9999"
       " pelo Operador:"
       tt-critica-cabec.nmoperad      NO-LABEL FORMAT "x(27)"
       SKIP(1)
       WITH COLUMN 02 NO-LABELS NO-BOX FRAME f_rodape.
  
  INPUT THROUGH basename `tty` NO-ECHO.
  
  SET aux_nmendter WITH FRAME f_terminal.
  
  INPUT CLOSE.
  
  aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                        aux_nmendter.
     
  UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
     
  ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".
     
  IF   NOT par_impntela THEN
       DO:
           HIDE MESSAGE NO-PAUSE.
                  
           VIEW FRAME f_aguarde.
           PAUSE 3 NO-MESSAGE.
           HIDE FRAME f_aguarde NO-PAUSE.
                        
           OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 80 PAGED.

           VIEW STREAM str_1 FRAME f_paginacao.
         
           /*  Configura a impressora para 1/8"  */
           PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
                           
           PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
       END.
  ELSE
       OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp).
       /* visualiza nao pode ter caracteres de controle */

  FIND FIRST tt-critica-cabec NO-ERROR.

  IF  NOT AVAILABLE tt-critica-cabec THEN
      RETURN "NOK".
  
  DISPLAY STREAM str_1  
      tt-critica-cabec.nmextcop  
      tt-critica-cabec.nrdconta
      tt-critica-cabec.nmprimtl  WITH FRAME f_identi.
   
  FOR EACH tt-critica-cadas NO-LOCK BREAK BY tt-critica-cadas.nmdatela:
  
      IF   FIRST-OF(tt-critica-cadas.nmdatela) THEN
           DISPLAY STREAM str_1 tt-critica-cadas.nmdatela WITH FRAME f_cabec.
      
      DISPLAY STREAM str_1 tt-critica-cadas.nmdcampo WITH FRAME f_campo.
      
      DOWN STREAM str_1 WITH FRAME f_campo.
      
  END.

  DISPLAY STREAM str_1 
      tt-critica-cabec.dtmvtolt 
      tt-critica-cabec.nmoperad WITH FRAME f_rodape.
  
  OUTPUT STREAM str_1 CLOSE.
  
  IF   NOT par_impntela THEN
       DO:
            ASSIGN glb_nmarqimp = aux_nmarqimp
                   glb_nrdevias = 1
                   par_flgrodar = TRUE.

            FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                               crapass.nrdconta = par_nrdconta
                               NO-LOCK NO-ERROR.

            { includes/impressao.i }

            HIDE MESSAGE NO-PAUSE.
       END.

END PROCEDURE.                    
                    
/* .......................................................................... */
