/*******************************************************************************
 cdprogra: fontes/frmenu.i
 Descri��o: Gera menu hier�rquico
 Autor: Solusoft/B&T Informatica
 
 Resumo de Altera��es:
 
    03/08/2005 - As tabelas cra-usuario, cra-progra e cra-permissao-grupo foram
                 substituidas por suas tabelas equivalentes do Ayllos
                 (Gustavo - SoluSoft).
    
    04/08/2005 - Adequa��o do programa aos padr�es de programa��o definidos pelo
                 cliente (Gustavo - SoluSoft).
    
    09/08/2005 - Altera��o do nome do programa de frmenu.i para wpgd0003.i
                 (Gustavo - SoluSoft).

    09/12/2008 - Reestrutura��o para melhoria de performance (Evandro).
        
    06/07/2009 - Altera��o CDOPERAD (Diego).

    15/08/2011 - Alterada procedure IncluiTopico para chamar o link
                 progrid.cecred.coop.br ao inves de progrid.cecrednet.coop.br
                 (Fernando).
                                 
    05/06/2012 - Adapta��o dos fontes para projeto Oracle. Alterado
                 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
					 
	12/06/2015 - Inclusao de tratamento para chamada de fontes ".php" (Jean Michel)
    
 ******************************************************************************/

	{ includes/var_progrid.i }
	
	DEF VAR v-identificacao AS CHAR NO-UNDO.
	DEF VAR v-cdprogra      AS CHAR NO-UNDO.
	DEF VAR v-permissoes    AS LOG  NO-UNDO.
	DEF VAR v-lis-topico    AS LOG  NO-UNDO.
	DEF VAR v-lis-subtopico AS LOG  NO-UNDO.
	DEF VAR aux_contador    AS INT  NO-UNDO.
    
   ASSIGN v-identificacao = get-cookie("cookie-usuario-em-uso").

   /* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
   FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
       LEAVE.
   END.

   {&out} /* "<div style='position:absolute; left: 7px; top: 8px'>*/ "<script language='JavaScript'>" skip.

   {&out} "foldersTree = gFld('<B>&nbsp;&nbsp;&nbsp;&nbsp;</B>', '')" skip.   
   
   IF   v-identificacao <> ""   AND
        AVAIL gnapses           THEN 
        DO:
            FIND crapope WHERE crapope.cdcooper = gnapses.cdcooper   AND 
                               crapope.cdoperad = gnapses.cdoperad   NO-LOCK NO-ERROR.
                                                           
            /* Verifica em quais telas do sistema o operador tem permiss�o pra poder montar o menu */
                        FOR EACH craptel WHERE craptel.cdcooper = gnapses.cdcooper   AND
                                               craptel.nmdatela BEGINS "wpgd"        AND
                                   craptel.idsistem = 2  /* Progrid */   NO-LOCK
                                   BREAK BY craptel.idevento
                                           BY craptel.nrmodulo
                                             BY craptel.tldatela:
                
                IF   FIRST-OF(craptel.idevento)   THEN 
                     ASSIGN v-lis-topico    = NO 
                            v-lis-subtopico = NO.
                ELSE 
                IF   FIRST-OF(craptel.nrmodulo)   THEN 
                     ASSIGN v-lis-subtopico = NO.

                ASSIGN v-permissoes = NO.
                                
                                DO aux_contador = 1 TO NUM-ENTRIES(craptel.cdopptel):
           
                   FIND crapace WHERE crapace.cdcooper = craptel.cdcooper                       AND
                                      crapace.nmdatela = craptel.nmdatela                       AND 
                                      crapace.nmrotina = craptel.nmrotina                       AND
                                                                          crapace.cddopcao = ENTRY(aux_contador,craptel.cdopptel)   AND
                                                                          crapace.cdoperad = crapope.cdoperad
                                                                        NO-LOCK NO-ERROR.
                                                                                 
                   /* Tendo qualquer permiss�o, j� carrega a tela no menu */
                                  IF   AVAILABLE crapace   THEN
                                        DO:
                                                    ASSIGN v-permissoes = YES.
                                                        LEAVE.
                                            END.
                            END.

                /* verifica super usu�rio */
                IF   crapope.dsdepart = "TI"   THEN
                     ASSIGN v-permissoes = YES.
               
                IF   v-permissoes   THEN 
                     DO:
                         FIND crapeve WHERE crapeve.idevento = craptel.idevento NO-LOCK NO-ERROR.
                                                 
                         FIND crapmod WHERE crapmod.nrmodulo = craptel.nrmodulo   AND
                                                                    crapmod.idsistem = craptel.idsistem   NO-LOCK NO-ERROR.
               
                                     IF   NOT AVAIL crapeve   OR
                                                      NOT AVAIL crapmod   THEN   
                                                      NEXT.
                   
                         IF   NOT v-lis-topico   THEN 
                              DO:
                                  RUN IncluiTopico(crapeve.nmevento).
                                  ASSIGN v-lis-topico = yes.
                              END. /* Fim IF NOT v-lis-topico */

                         IF   NOT v-lis-subtopico   THEN
                                                      DO:
                                  RUN IncluiSubTopico(crapmod.nmmodulo).
                                  ASSIGN v-lis-subtopico = YES.
                              END.
                                                                           
                          /* ASSIGN v-cdprogra = cra-rotina.acesso + (IF AVAIL crapprg THEN crapprg.cdprogra ELSE "").*/
                          RUN Incluicdprogra(craptel.tlrestel,craptel.nmdatela).
                                                                  
                     END. /* Fim do IF v-permissoes */
            END. /* Fim do FOR EACH craptel */
        END.

/************************************** original ****************************************
   IF   v-identificacao <> ""   THEN 
        DO:
            IF   AVAIL gnapses   THEN 
                 DO:
                     FOR EACH craptel WHERE craptel.cdcooper = gnapses.cdcooper   AND
                                            craptel.idsistem = 2                  NO-LOCK
                                            BREAK BY craptel.idevento
                                                    BY craptel.nrmodulo
                                                      BY craptel.tldatela:
                
                         IF   FIRST-OF(craptel.idevento)   THEN 
                              ASSIGN v-lis-topico    = NO 
                                     v-lis-subtopico = NO.
                         ELSE 
                         IF   FIRST-OF(craptel.nrmodulo)   THEN 
                              ASSIGN v-lis-subtopico = NO.

                         ASSIGN v-permissoes = NO.
           
                         FIND FIRST crapope WHERE crapope.cdcooper = gnapses.cdcooper   AND 
                                                  crapope.cdoperad = gnapses.cdoperad   NO-LOCK NO-ERROR.

                         IF   AVAIL crapope   THEN 
                              DO:
                                  FOR EACH crapace WHERE crapace.cdcooper = gnapses.cdcooper   AND
                                                         crapace.nmdatela = craptel.nmdatela   AND 
                                                         crapace.idevento = craptel.idevento   NO-LOCK:

                                      IF   CAN-DO(crapope.cdoperad,crapace.cdoperad)   THEN 
                                           DO:
                                               ASSIGN v-permissoes = YES.
                                               LEAVE.
                                           END. /* Fim do IF CAN-DO(crapope.cdoperad,crapace.cdoperad) */ 
                                  END.  /* Fim do FOR EACH crapace */
                              END. /* Fim do IF AVAIL crapope */

                         /* verifica super usu�rio */
                         IF   crapope.dsdepart = "TI"   THEN
                              ASSIGN v-permissoes = YES.
               
                         IF   v-permissoes   THEN 
                              DO:
                                  FIND crapeve OF craptel NO-LOCK NO-ERROR.
                                  FIND crapmod OF craptel NO-LOCK NO-ERROR.
                                  /*FIND FIRST crapprg NO-LOCK WHERE crapprg.cdprogra = craptel.nmdatela NO-ERROR.*/
               
                                              IF   NOT AVAIL crapeve   THEN   
                                                                       NEXT.
                   
                                  IF   NOT v-lis-topico   THEN 
                                       DO:
                                           RUN IncluiTopico(crapeve.nmevento).
                                           ASSIGN v-lis-topico = yes.
                                       END. /* Fim IF NOT v-lis-topico */

                                  IF   NOT v-lis-subtopico   THEN
                                                                       DO:
                                           RUN IncluiSubTopico(crapmod.nmmodulo).
                                           ASSIGN v-lis-subtopico = YES.
                                       END.
                                                                           
                                  /* ASSIGN v-cdprogra = cra-rotina.acesso + (IF AVAIL crapprg THEN crapprg.cdprogra ELSE "").*/
                                  RUN Incluicdprogra(craptel.tlrestel,craptel.nmdatela).
                                                                  
                              END. /* Fim do IF v-permissoes */
                     END. /* Fim do FOR EACH craptel */
                 END.  /* Fim do IF AVAIL gnapses */        
                END. /* Fim do IF v-identificacao <> "" */
************************************** original ****************************************/                

   {&out} 'initializeDocument()' SKIP.  
   {&out} 'clickOnFolder(0)' SKIP.
   {&out} "<" + "/" + "script></div>" SKIP.

PROCEDURE IncluiTopico:
    
    DEF INPUT PARAM p-topico AS CHAR FORM "x(20)"           NO-UNDO.
    ASSIGN p-topico = p-topico.
    {&out} "aux1 = insFld(foldersTree, gFld(setNivel('" + TRIM(p-topico) + "','http://" + aux_srvprogrid + "/cecred/images/icones/ico_lupa.gif','Clique aqui no PROGRID','linkMenuAdmin'), ''))" SKIP.

END PROCEDURE.  /* End IncluiTopico */

PROCEDURE IncluiSubTopico:
    
    DEF INPUT PARAM p-subtopico AS CHAR FORM "x(20)"        NO-UNDO.
    ASSIGN p-subtopico = p-subtopico.
    {&out} "aux2 = insFld(aux1, gFld(setNivel('" + TRIM(p-subtopico) + "','http://" + aux_srvprogrid + "/cecred/images/icones/ico_historico.gif','',''),''))" SKIP.

END PROCEDURE.  /* End IncluiSubTopico */

PROCEDURE Incluicdprogra:
    DEF INPUT PARAM p-labelcdprogra AS CHAR FORM "x(20)"    NO-UNDO.
    DEF INPUT PARAM p-cdprogra      AS CHAR FORM "x(200)"   NO-UNDO .
    
    /*IF p-cdprogra = "wpgd0019" THEN
        {&out} "insDoc(aux2, gLnk(1,'" + TRIM(p-labelcdprogra) + "','" + p-cdprogra + ".w?aux_idevento=" + string(craptel.idevento) + "'))" SKIP. 
    ELSE DO:*/
		
		IF INT(SUBSTR(p-cdprogra,(R-INDEX(p-cdprogra,"d") + 1))) >= 100 THEN
			{&out} "insDoc(aux2, gLnk(0,'" + TRIM(p-labelcdprogra) + "','" + aux_srvprogrid + "/telas/" + p-cdprogra + "/" + p-cdprogra + ".php?cdcooper=" + string(gnapses.cdcooper) + "&cdoperad=" + string(gnapses.cdoperad) + "&nmdatela=" + string(p-cdprogra) + "&idevento=" + STRING(craptel.idevento) + "&idcokses=" + string(v-identificacao) + "&tlrestel=" + craptel.tlrestel + "'))" SKIP. 
		ELSE
			{&out} "insDoc(aux2, gLnk(0,'" + TRIM(p-labelcdprogra) + "','" + p-cdprogra + ".w?aux_idevento=" + string(craptel.idevento) + "'))" SKIP. 
			
    /*END.*/

END PROCEDURE.  /* End Incluicdprogra */
