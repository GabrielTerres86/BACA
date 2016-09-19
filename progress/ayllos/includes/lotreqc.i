/* .............................................................................

   Programa: Includes/lotreqc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/92.                     Ultima atualizacao: 30/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela lotreq.

   Alteracoes: 02/04/98 - Tratamento para milenio e troca para V8 (Magui).

               12/11/2004 - Exibir o nome do operador (Evandro).

               08/12/2005 - Incluir tratamento para conta ITG (Magui).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 
               
               11/07/2016 - Apresentar apenas opcao C, e incluir quantidades
                          de entrega de taloes.
                          PRJ290 – Caixa OnLine (Odirlei-AMcom)
............................................................................. */

{ sistema/generico/includes/var_oracle.i }

FIND craptrq WHERE craptrq.cdcooper = glb_cdcooper       AND   
                   craptrq.cdagelot = INPUT tel_cdagelot AND
                   craptrq.tprequis = 0                  AND
                   craptrq.nrdolote = INPUT tel_nrdolote NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptrq   THEN
     DO:
         glb_cdcritic = 60.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_lotreq NO-PAUSE.

         ASSIGN tel_cdagelot = aux_cdagelot
                tel_nrdolote = aux_nrdolote.

         DISPLAY tel_cdagelot tel_nrdolote WITH FRAME f_lotreq.
         NEXT.
     END.

ASSIGN tel_qtdiferq = craptrq.qtcomprq - craptrq.qtinforq
       tel_qtdifetl = craptrq.qtcomptl - craptrq.qtinfotl
       tel_qtdifeen = craptrq.qtcompen - craptrq.qtinfoen.
       
FIND crapope WHERE  crapope.cdcooper = glb_cdcooper     AND
                    crapope.cdoperad = craptrq.cdoperad NO-LOCK NO-ERROR.

IF   AVAILABLE crapope   THEN
     tel_nmoperad = crapope.nmoperad.

 ASSIGN aux_qtentdif_r = 0
        aux_qtentdif_c = 0.
        
{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

/* Buscar quantidades de taloes entregues*/ 
RUN STORED-PROCEDURE pc_busca_qtd_entrega_talao aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,  /* pr_cdcooper */
    INPUT INPUT tel_cdagelot,  /* pr_cdagenci - necessario termo input para pegar campo informado */
    INPUT INPUT tel_nrdolote,  /* pr_nrdcaixa - necessario termo input para pegar campo informado */
    INPUT glb_dtmvtolt,  /* pr_dtmvtolt */
    OUTPUT 0,            /* pr_qtentreq */ 
    OUTPUT 0,            /* pr_qtentcar */
    OUTPUT 0,            /* pr_cdcritic */
    OUTPUT "").          /* pr_dscritic */
    
IF  ERROR-STATUS:ERROR  THEN DO:
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + 
                              ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
    BELL.    
    MESSAGE "Erro ao executar Stored Procedure: '" + 
            aux_msgerora VIEW-AS ALERT-BOX.
    
END.

CLOSE STORED-PROCEDURE pc_busca_qtd_entrega_talao 
             WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }             
  
ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       aux_qtentreq = 0
       aux_qtentcar = 0
       glb_cdcritic = pc_busca_qtd_entrega_talao.pr_cdcritic 
                      WHEN pc_busca_qtd_entrega_talao.pr_cdcritic <> ?
       glb_dscritic = pc_busca_qtd_entrega_talao.pr_dscritic 
                      WHEN pc_busca_qtd_entrega_talao.pr_dscritic <> ?
       aux_qtentreq = pc_busca_qtd_entrega_talao.pr_qtentreq 
                      WHEN pc_busca_qtd_entrega_talao.pr_qtentreq <> ?
       aux_qtentcar = pc_busca_qtd_entrega_talao.pr_qtentcar 
                      WHEN pc_busca_qtd_entrega_talao.pr_qtentcar <> ?.

IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        
        IF glb_cdcritic > 0 AND glb_dscritic = "" THEN
        DO:
          RUN fontes/critic.p.
        END.  
        BELL.
        MESSAGE glb_dscritic VIEW-AS ALERT-BOX.
    END.         

ASSIGN aux_qtentreq_in = aux_qtentreq              
       aux_qtentcar_in = aux_qtentcar.    

DISPLAY craptrq.qtinfotl craptrq.qtcomptl tel_qtdifetl
        craptrq.qtinfoen craptrq.qtcompen tel_qtdifeen
        aux_qtentreq_in aux_qtentreq aux_qtentdif_r 
        aux_qtentcar_in aux_qtentcar aux_qtentdif_c 
        tel_nmoperad     WITH FRAME f_lotreq.

/* .......................................................................... */
