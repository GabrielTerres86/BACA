/* ............................................................................

   Programa: fontes/crps413.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Outubro/2004                   Ultima atualizacao: 16/08/2013

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 86.
               Gerar relatorio com as AUTENTICACOES POR MES em cada PAC.

   Alteracoes: 23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego)

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
               06/07/2006 - Incluida execucao do procedimento imprim.p (David).
               
               16/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).                            
............................................................................. */
{ includes/var_batch.i "NEW"} 

DEF  STREAM str_1. /* para o relatorio */

DEF  VAR i-occ          AS INT                                        NO-UNDO.
DEF  VAR aux_totpac     AS INT                                        NO-UNDO.
DEF  VAR aux_totger     AS INT                                        NO-UNDO.
DEF  VAR aux_nmarqimp   AS CHAR                                       NO-UNDO.
DEF  VAR aux_uldiames   AS DATE                                       NO-UNDO.

/* variaveis para o cabecalho */
DEF  VAR rel_nmresemp   AS CHAR                                       NO-UNDO.
DEF  VAR rel_nmrelato   AS CHAR   EXTENT 5                            NO-UNDO.
DEF  VAR rel_nrmodulo   AS INT                                        NO-UNDO.


FORM HEADER 
     " PA               CAIXA   QTDE AUT" SKIP(1)
     WITH NO-BOX NO-LABEL PAGE-TOP COLUMN 15 FRAME f_pac.
    
FORM crapbcx.cdagenci
     crapage.nmresage
     crapbcx.nrdcaixa
     i-occ
     WITH NO-BOX NO-LABELS COLUMN 15 FRAME f_caixa.
     
glb_cdprogra = "crps413".
           
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     QUIT.

ASSIGN aux_nmarqimp = "rl/crrl373.lst" 
                      
                      /*calcula o ultimo dia util do mes*/
       aux_uldiames = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4) -
                      DAY(DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4)).


{ includes/cabrel080_1.i }

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 80.

VIEW STREAM str_1 FRAME f_cabrel080_1.
VIEW STREAM str_1 FRAME f_pac.

FOR EACH crapbcx WHERE crapbcx.cdcooper  =  glb_cdcooper                   AND
                       crapbcx.dtmvtolt >=  DATE(MONTH(glb_dtmvtolt),01,
                                                      YEAR(glb_dtmvtolt))  AND
                       crapbcx.dtmvtolt <= aux_uldiames NO-LOCK
                       BREAK BY crapbcx.cdagenci
                             BY crapbcx.nrdcaixa:

    IF   FIRST-OF(crapbcx.cdagenci)   THEN
         DO:
             ASSIGN aux_totpac = 0.
             FIND crapage WHERE crapage.cdcooper = glb_cdcooper    AND 
                                crapage.cdagenci = crapbcx.cdagenci
                                NO-LOCK NO-ERROR.

             DISPLAY STREAM str_1 
                     crapbcx.cdagenci  crapage.nmresage WITH FRAME f_caixa.
         END.

    IF   FIRST-OF(crapbcx.nrdcaixa)   THEN
         ASSIGN i-occ = 0.
   
    ASSIGN i-occ = i-occ + crapbcx.qtautent
           aux_totpac = aux_totpac + crapbcx.qtautent
           aux_totger = aux_totger + crapbcx.qtautent.
                        
    IF   LAST-OF(crapbcx.nrdcaixa)   THEN
         DO:
             DISPLAY STREAM str_1 
                     crapbcx.nrdcaixa  i-occ WITH FRAME f_caixa.

             DOWN STREAM str_1 WITH FRAME f_caixa.
         END.
    
    IF   LAST-OF(crapbcx.cdagenci)    THEN
         PUT STREAM str_1 SPACE(18) "TOTAL DA AGENCIA ==>" aux_totpac SKIP(1).

END.

PUT STREAM str_1 SKIP SPACE(14) "TOTAL DA COOPERATIVA ==>" aux_totger SKIP.

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrcopias = 1
       glb_nmformul = ""
       glb_nmarqimp = aux_nmarqimp.
  
       RUN fontes/imprim.p.

RUN fontes/fimprg.p.

/*...........................................................................*/
