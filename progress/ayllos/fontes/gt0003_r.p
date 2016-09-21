/* ..........................................................................

   Programa: Fontes/gt0003_r.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes
   Data    : Abril/2004                        Ultima atualizacao: 22/06/2012 

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio Controle de Execucao

   Alteracoes: 28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               22/06/2012 - Substituido gncoper por crapcop (Tiago).   
............................................................................. */

DEF STREAM str_1.

DEF   INPUT PARAM par_tiporel  AS LOG                                NO-UNDO.  
DEF   INPUT PARAM par_cdcooper AS INT                                NO-UNDO.
DEF   INPUT PARAM par_dtinici  AS DATE                               NO-UNDO.
DEF   INPUT PARAM par_dtfinal  AS DATE                               NO-UNDO.

DEF   VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                     NO-UNDO.
DEF   VAR aux_ttqtdoctos  LIKE gncontr.qtdoctos                      NO-UNDO.
DEF   VAR aux_ttvldoctos  LIKE gncontr.vldoctos                      NO-UNDO.
DEF   VAR aux_ttvltarifa  LIKE gncontr.vltarifa                      NO-UNDO.
DEF   VAR aux_ttvlapagar  LIKE gncontr.vlapagar                      NO-UNDO.
DEF   VAR aux_ggqtdoctos  LIKE gncontr.qtdoctos                      NO-UNDO.
DEF   VAR aux_ggvldoctos  LIKE gncontr.vldoctos                      NO-UNDO.
DEF   VAR aux_ggvltarifa  LIKE gncontr.vltarifa                      NO-UNDO.
DEF   VAR aux_ggvlapagar  LIKE gncontr.vlapagar                      NO-UNDO.
DEF   VAR aux_nmrescop      AS  CHAR FORMAT "x(20)"                  NO-UNDO.
DEF   VAR aux_contador AS INTE                                       NO-UNDO.
DEF   VAR par_flgrodar AS LOGICAL INIT TRUE                          NO-UNDO.
DEF   VAR par_flgfirst AS LOGICAL INIT TRUE                          NO-UNDO.
DEF   VAR par_flgcance AS LOGICAL                                    NO-UNDO.

DEF BUFFER crabcop FOR crapcop.

{ includes/var_online.i }

DEF   VAR rel_nmempres     AS CHAR    FORMAT "x(15)"                 NO-UNDO.
DEF   VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5        NO-UNDO.

DEF   VAR rel_nrmodulo AS INT     FORMAT "9"                         NO-UNDO.
DEF   VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 9
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "CADASTROS",
                                     "PROCESSOS",
                                     "PARAMETRIZACAO",
                                     "SOLICITACOES",
                                     "GENERICO       "]              NO-UNDO.

DEF   VAR rel_nmmesano AS CHAR    FORMAT "x(09)"                     NO-UNDO.

DEF   VAR res_nrctremp AS INT                                        NO-UNDO.
DEF   VAR res_dslinhas AS CHAR                                       NO-UNDO.
DEF   VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF   VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF   VAR aux_flgescra AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_dscomand AS CHAR                                       NO-UNDO.
DEF   VAR aux_nmendter AS CHAR    FORMAT "x(20)"                     NO-UNDO.
DEF   VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
      
DEF   VAR aux_tiporel  AS CHAR    FORMAT "x(11)"                     NO-UNDO.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM "SELECAO "     AT  1
     par_cdcooper   AT 15    LABEL "Cooperativa  "
     par_dtinici    AT 40    LABEL "Data Inicial " FORMAT "99/99/9999"
     par_dtfinal    AT 70    LABEL "Data Final "   FORMAT "99/99/9999"
     SKIP(1)
     aux_tiporel    NO-LABEL
     "         Qtd.Doctos       Vl.Doctos          Tarifa     Vl. a Pagar"
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab.

FORM  aux_nmrescop   
      gncontr.qtdoctos  
      gncontr.vldoctos  
      gncontr.vltarifa  
      gncontr.vlapagar  
      WITH NO-BOX  NO-LABELS DOWN FRAME f_movtos WIDTH 132.

FORM  gnconve.nmempres 
      gncontr.qtdoctos  
      gncontr.vldoctos  
      gncontr.vltarifa  
      gncontr.vlapagar  
      WITH NO-BOX  NO-LABELS DOWN FRAME f_movtos_conven WIDTH 132.

IF  par_tiporel = YES THEN
    ASSIGN aux_tiporel = "Convenio   ".
ELSE
    ASSIGN aux_tiporel = "Cooperativa".
    
/* Busca dados da cooperativa */

FIND crabcop WHERE crabcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crabcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.
 
ASSIGN glb_cdcritic    = 0
       glb_nrdevias    = 1
       glb_cdempres    = 11
       glb_cdrelato[1] = 347.

{ includes/cabrel132_1.i }

aux_nmarqimp = "rl/O347_" + STRING(TIME,"99999") + ".lst".
       
HIDE MESSAGE NO-PAUSE.

/*  Gerenciamento da impressao  */

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

MESSAGE "AGUARDE... Imprimindo relatorio!".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0\033\017" NULL.

VIEW STREAM str_1 FRAME f_cabrel132_1.

DISPLAY STREAM str_1 aux_tiporel
                     par_cdcooper
                     par_dtinici
                     par_dtfinal WITH FRAME f_cab.    

IF   par_tiporel = NO THEN      /* Por Cooperativa */
     RUN lista_por_cooperativa.
ELSE      
     RUN lista_por_convenio.

PAGE STREAM str_1.

PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

OUTPUT  STREAM str_1 CLOSE.

ASSIGN glb_nmformul = ""
       glb_nrcopias = 1
       glb_nmarqimp = aux_nmarqimp.

FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

{ includes/impressao.i }

HIDE MESSAGE NO-PAUSE.

MESSAGE "Retire o relatorio da impressora!".

     

PROCEDURE lista_por_cooperativa.
     
    ASSIGN aux_ttqtdoctos = 0
           aux_ttvldoctos = 0
           aux_ttvltarifa = 0
           aux_ttvlapagar = 0.
    ASSIGN aux_ttqtdoctos = 0
           aux_ttvldoctos = 0
           aux_ttvltarifa = 0
           aux_ttvlapagar = 0.
    
    FOR EACH  gncontr WHERE
             (gncontr.cdcooper = par_cdcooper      OR                    
              par_cdcooper     = 0)                AND
              gncontr.dtmvtolt >= par_dtinici      AND
              gncontr.dtmvtolt <= par_dtfinal      AND
              gncontr.tpdcontr = 1                 NO-LOCK,
         EACH crapcop WHERE
              crapcop.cdcooper = gncontr.cdcooper  NO-LOCK
              BREAK BY crapcop.nmrescop
                       BY gncontr.cdconven:

        ASSIGN aux_ttqtdoctos = aux_ttqtdoctos + gncontr.qtdoctos
               aux_ttvldoctos = aux_ttvldoctos + gncontr.vldoctos
               aux_ttvltarifa = aux_ttvltarifa + gncontr.vltarifa
               aux_ttvlapagar = aux_ttvlapagar + gncontr.vlapagar.
        ASSIGN aux_ggqtdoctos = aux_ggqtdoctos + gncontr.qtdoctos
               aux_ggvldoctos = aux_ggvldoctos + gncontr.vldoctos
               aux_ggvltarifa = aux_ggvltarifa + gncontr.vltarifa
               aux_ggvlapagar = aux_ggvlapagar + gncontr.vlapagar.
            
        IF   LAST-OF(crapcop.nmrescop) THEN
             DO:
                
                ASSIGN aux_nmrescop = crapcop.nmrescop.
                DISPLAY STREAM str_1
                       aux_nmrescop
                       aux_ttqtdoctos @ gncontr.qtdoctos
                       aux_ttvldoctos @ gncontr.vldoctos
                       aux_ttvltarifa @ gncontr.vltarifa
                       aux_ttvlapagar @ gncontr.vlapagar
                       WITH FRAME f_movtos.
                DOWN   WITH FRAME f_movtos.
                ASSIGN aux_ttqtdoctos = 0
                       aux_ttvldoctos = 0
                       aux_ttvltarifa = 0
                       aux_ttvlapagar = 0.
             END.
               
        IF   LINE-COUNTER(str_1) > 80  THEN
             DO:
                PAGE STREAM str_1.
                       
                DISPLAY STREAM str_1 
                        aux_tiporel
                        par_cdcooper
                        par_dtinici
                        par_dtfinal WITH FRAME f_cab.
            END.
    END.
    DISPLAY STREAM str_1
                   "TOTAL " @ aux_nmrescop
                   aux_ggqtdoctos @ gncontr.qtdoctos
                   aux_ggvldoctos @ gncontr.vldoctos
                   aux_ggvltarifa @ gncontr.vltarifa
                   aux_ggvlapagar @ gncontr.vlapagar
                   WITH FRAME f_movtos.
    DOWN   WITH FRAME f_movtos.


END PROCEDURE.



PROCEDURE lista_por_convenio.

    ASSIGN aux_ttqtdoctos = 0
           aux_ttvldoctos = 0
           aux_ttvltarifa = 0
           aux_ttvlapagar = 0.
    ASSIGN aux_ttqtdoctos = 0
           aux_ttvldoctos = 0
           aux_ttvltarifa = 0
           aux_ttvlapagar = 0.

    FOR EACH  gncontr WHERE
             (gncontr.cdcooper = par_cdcooper      OR                    
              par_cdcooper     = 0)                AND
              gncontr.dtmvtolt >= par_dtinici      AND
              gncontr.dtmvtolt <= par_dtfinal      AND
              gncontr.tpdcontr = 1                 NO-LOCK,
         EACH gnconve WHERE
              gnconve.cdconven = gncontr.cdconven  NO-LOCK
         BREAK BY gnconve.nmempres
               BY gncontr.cdcooper:

        ASSIGN aux_ttqtdoctos = aux_ttqtdoctos + gncontr.qtdoctos
               aux_ttvldoctos = aux_ttvldoctos + gncontr.vldoctos
               aux_ttvltarifa = aux_ttvltarifa + gncontr.vltarifa
               aux_ttvlapagar = aux_ttvlapagar + gncontr.vlapagar.
           
        ASSIGN aux_ggqtdoctos = aux_ggqtdoctos + gncontr.qtdoctos
               aux_ggvldoctos = aux_ggvldoctos + gncontr.vldoctos
               aux_ggvltarifa = aux_ggvltarifa + gncontr.vltarifa
               aux_ggvlapagar = aux_ggvlapagar + gncontr.vlapagar.
 
        IF   LAST-OF(gnconve.nmempres) THEN
             DO:
                DISPLAY STREAM str_1
                       gnconve.nmempres
                       aux_ttqtdoctos @ gncontr.qtdoctos
                       aux_ttvldoctos @ gncontr.vldoctos
                       aux_ttvltarifa @ gncontr.vltarifa
                       aux_ttvlapagar @ gncontr.vlapagar
                       WITH FRAME f_movtos_conven.
                DOWN   WITH FRAME f_movtos_conven.
                ASSIGN aux_ttqtdoctos = 0
                       aux_ttvldoctos = 0
                       aux_ttvltarifa = 0
                       aux_ttvlapagar = 0.
             END.
               
        IF   LINE-COUNTER(str_1) > 80  THEN
             DO:
                PAGE STREAM str_1.
                       
                DISPLAY STREAM str_1 
                        aux_tiporel
                        par_cdcooper
                        par_dtinici
                        par_dtfinal WITH FRAME f_cab.
            END.
    END.
   
    DISPLAY STREAM str_1
                   "TOTAL " @ gnconve.nmempres
                   aux_ggqtdoctos @ gncontr.qtdoctos
                   aux_ggvldoctos @ gncontr.vldoctos
                   aux_ggvltarifa @ gncontr.vltarifa
                   aux_ggvlapagar @ gncontr.vlapagar
                   WITH FRAME f_movtos_conven.
    DOWN   WITH FRAME f_movtos_conven.

    
END PROCEDURE.






/* .......................................................................... */

