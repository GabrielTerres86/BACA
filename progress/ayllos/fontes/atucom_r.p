/* ..........................................................................

   Programa: Fontes/atucom_r.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Fevereiro/2004                  Ultima atualizacao: 24/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio atualizacao Movtos COMPEL. 

   Alteracoes: 20/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               24/12/2013 - Trocar Agencia por PA (Gielow)

............................................................................. */

DEFINE TEMP-TABLE w-arquivo-rel                                      NO-UNDO
       FIELD  nmarquivo AS CHAR format "x(40)".

DEF STREAM str_1.

DEF INPUT PARAM par_dtmvtolt  AS DATE                                NO-UNDO.
DEF INPUT PARAM par_nmarquivo AS CHAR                                NO-UNDO.
DEF INPUT PARAM par_vlrlista  AS DEC                                 NO-UNDO.
DEF INPUT PARAM TABLE FOR  w-arquivo-rel.
DEF INPUT PARAM par_cdagenci  AS INT                                 NO-UNDO.

DEF VAR par_flgrodar AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                      NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                      NO-UNDO.

{ includes/var_online.i }
             
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.


DEF   VAR lot_nmoperad AS CHAR                                       NO-UNDO.

DEF   VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF   VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.

DEF   VAR tel_dsdlinha AS CHAR                                       NO-UNDO.
DEF   VAR tel_dscodbar AS CHAR    FORMAT "x(44)"                     NO-UNDO.

DEF   VAR aux_contador AS INT                                        NO-UNDO.

DEF   VAR aux_nmendter AS CHAR    FORMAT "x(20)"                     NO-UNDO.
DEF   VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF   VAR aux_dscomand AS CHAR                                       NO-UNDO.

DEF   VAR aux_confirma AS CHAR                                       NO-UNDO.
DEF   VAR tot_qtregrej AS INTE                                       NO-UNDO.
DEF   VAR tot_qtregace AS INTE                                       NO-UNDO.
DEF   VAR tot_vlregrej AS DEC  FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF   VAR tot_vlregace AS DEC  FORMAT "zzz,zzz,zz9.99"               NO-UNDO.

FORM SKIP(1)
     "PA:"              AT 01
     par_cdagenci       AT 10 FORMAT "zz9"    NO-LABEL
     SKIP(1)
     par_dtmvtolt       AT 01 FORMAT "99/99/9999" LABEL "DATA"
     SKIP(1)
     " "                AT 01
     WITH NO-BOX SIDE-LABELS DOWN WIDTH 132 FRAME f_cab.

FORM SKIP(1)
     w-arquivo-rel.nmarquivo  AT 10 FORMAT "x(40)" LABEL "ARQUIVO"
     " "                      AT 10
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_arquivo.

FORM craprej.nrdconta                              LABEL "CONTA/DV"
     craprej.nrdocmto      FORMAT "zzz,zzz,zzz"    LABEL "DOCTO"
     craprej.vllanmto      FORMAT "zzz,zzz,zz9.99" LABEL "VALOR"
     craprej.cdbccxlt      FORMAT "zz9"            LABEL "BANCO"
     craprej.cdagenci      FORMAT "zzz9"           LABEL "PA"
     craprej.nrdolote      FORMAT "z,zzz,zz9"      LABEL "LOTE"
     /*
     craprej.dshistor      FORMAT "x(36)"          LABEL "CMC7"
     */
     glb_dscritic          FORMAT "x(35)"          LABEL "CRITICA"
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_movtos.

FORM tot_qtregrej          FORMAT "zzzz9"          LABEL "Qtd.Rejeitados"
     tot_vlregrej          FORMAT "zzz,zzz,zz9.99" LABEL "Valor Rejeitados"
     tot_qtregace          FORMAT "zzzz9"          LABEL "Qtd.Atualizados"
     tot_vlregace          FORMAT "zzz,zzz,zz9.99" LABEL "Valor Atualizados"
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_total. 

FORM SKIP(1)
     WITH NO-BOX FRAME f_linha.

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.
 
ASSIGN glb_cdcritic    = 0
       glb_nrdevias    = 1
       glb_cdempres    = 11
       glb_cdrelato[1] = 336.


{ includes/cabrel080_1.i }

aux_nmarqimp = "rl/O336_" + STRING(TIME,"99999") + ".lst".
       
HIDE MESSAGE NO-PAUSE.

/*  Gerenciamento da impressao  */

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

MESSAGE "AGUARDE... Imprimindo relatorio!".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

VIEW STREAM str_1 FRAME f_cabrel080_1.
 
DO aux_contador = 1 TO 1:

   DISPLAY STREAM str_1 par_dtmvtolt
                        par_cdagenci WITH FRAME f_cab.
   
   FOR EACH w-arquivo-rel NO-LOCK:
       DISPLAY STREAM str_1 w-arquivo-rel.nmarquivo WITH FRAME f_arquivo.
       DOWN STREAM str_1 WITH FRAME f_arquivo.
   END.
   
   FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper   AND
                          craprej.dtrefere = par_nmarquivo  NO-LOCK
                          BREAK BY craprej.cdcritic DESC:

       IF  craprej.cdcritic > 0     OR
          (craprej.vllanmto >= par_vlrlista) THEN  /* Listar Valores acima de */
           
           DO:
              ASSIGN glb_dscritic = " ".
              
              IF  craprej.cdcritic > 0 THEN
                  DO:
                     ASSIGN  glb_cdcritic = craprej.cdcritic.
               
                    RUN fontes/critic.p.
                  END.
              /*--
              DISPLAY STREAM str_1  
                       craprej.nrdconta   
                       craprej.nrdocmto 
                       craprej.vllanmto  
                       craprej.cdbccxlt
                       craprej.cdagenci 
                       craprej.nrdolote
                       /*
                       craprej.dshistor
                       */
                       glb_dscritic WITH FRAME f_movtos.
                         
              DOWN STREAM str_1 WITH FRAME f_movtos.         
              --*/           
              IF  craprej.cdcritic > 0 THEN
                  ASSIGN tot_qtregrej = tot_qtregrej + 1        
                         tot_vlregrej = tot_vlregrej + craprej.vllanmto.
              ELSE
                  ASSIGN tot_qtregace = tot_qtregace + 1
                         tot_vlregace = tot_vlregace + craprej.vllanmto.
            END.
        ELSE
            DO:
               ASSIGN tot_qtregace = tot_qtregace + 1
                      tot_vlregace = tot_vlregace + craprej.vllanmto.
       
            END.
   
   END.  /* FOR EACH craprej */
   
   DISPLAY STREAM str_1 
                  tot_qtregrej  
                  tot_vlregrej
                  tot_qtregace      
                  tot_vlregace
                  WITH FRAME f_total.
               
   DOWN STREAM str_1 WITH FRAME f_movtos.         
  
   ASSIGN tot_qtregrej = 0
          tot_vlregrej = 0
          tot_qtregace = 0
          tot_vlregace = 0.
   PAGE STREAM str_1.

END.  /* Fim do DO .. TO  */

PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

OUTPUT  STREAM str_1 CLOSE.

ASSIGN glb_nmformul = ""
       glb_nrcopias = 2
       glb_nmarqimp = aux_nmarqimp.

FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

{ includes/impressao.i }

HIDE MESSAGE NO-PAUSE.

IF   NOT par_flgcance   THEN
     MESSAGE "Retire o relatorio da impressora!".
ELSE
     MESSAGE "Impressao cancelada!".
/* .......................................................................... */
