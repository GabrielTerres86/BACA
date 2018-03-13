/*******************************************************************************
 cdprogra: fontes/frmenu.i
 Descrição: Gera menu hierárquico
 Autor: Solusoft/B&T Informatica
 
 Resumo de Alterações:
 
    03/08/2005 - As tabelas cra-usuario, cra-progra e cra-permissao-grupo foram
                 substituidas por suas tabelas equivalentes do Ayllos
                 (Gustavo - SoluSoft).
    
    04/08/2005 - Adequação do programa aos padrões de programação definidos pelo
                 cliente (Gustavo - SoluSoft).
    
    09/08/2005 - Alteração do nome do programa de frmenu.i para wpgd0003.i
                 (Gustavo - SoluSoft).

    09/12/2008 - Reestruturação para melhoria de performance (Evandro).
        
    06/07/2009 - Alteração CDOPERAD (Diego).

    15/08/2011 - Alterada procedure IncluiTopico para chamar o link
                 progrid.cecred.coop.br ao inves de progrid.cecrednet.coop.br
                 (Fernando).
                                 
    05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
					 
	12/06/2015 - Inclusao de tratamento para chamada de fontes ".php" (Jean Michel)
    
    16/09/2015 - Inclusão da tldatela na chamada das telas do PHP (Vanessa).
    
    25/11/2015 - Reordenado a ordem de exibição das telas no menu (Jean Michel).
    
	27/04/2016 - Correcao na forma de filtro das telas validando a flag
				 flgtelbl igual a TRUE para apresentar os itens do menu
                 Lombardi, Vanessa, Carlos R.)

    20/06/2016 - Inclusao do ano agenda para passar por parametro para as
                 telas PHP (Jean Michel).

    06/12/2016 - P341-Automatização BACENJUD - Alterada a validação 
			     do departamento para que a mesma seja feita através
				 do código e não da descrição (Renato Darosci)

    02/10/2017 - Inclusao do parametro crapope.cdagenci para telas PHP (Jean Michel).				 
	
 ******************************************************************************/

	{ includes/var_progrid.i }
	
	DEF VAR v-identificacao AS CHAR NO-UNDO.
	DEF VAR v-cdprogra      AS CHAR NO-UNDO.
	DEF VAR v-permissoes    AS LOG  NO-UNDO.
	DEF VAR v-lis-topico    AS LOG  NO-UNDO.
	DEF VAR v-lis-subtopico AS LOG  NO-UNDO.
	DEF VAR aux_contador    AS INT  NO-UNDO.
  DEF VAR aux_dtanoage    AS INT  NO-UNDO.
    
   ASSIGN v-identificacao = get-cookie("cookie-usuario-em-uso").

   /* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
   FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
       LEAVE.
   END.

  {&out} "<script language='JavaScript'>" SKIP.
  {&out} "foldersTree = gFld('<B>&nbsp;&nbsp;&nbsp;&nbsp;</B>', '')" SKIP.   
   
  IF v-identificacao <> "" AND
    AVAIL gnapses THEN 
        DO:
                                                           
      FIND crapope WHERE crapope.cdcooper = gnapses.cdcooper AND 
                         crapope.cdoperad = gnapses.cdoperad NO-LOCK NO-ERROR.
                                                           
            /* Verifica em quais telas do sistema o operador tem permissão pra poder montar o menu */
                        FOR EACH craptel WHERE craptel.cdcooper = gnapses.cdcooper   AND
                             craptel.nmdatela BEGINS "WPGD"        AND
                             craptel.idsistem = 2 AND  /* Progrid */  
                             craptel.flgtelbl = TRUE NO-LOCK
                                   BREAK BY craptel.idevento
                                           BY craptel.nrmodulo
                                       BY craptel.tlrestel:
      IF FIRST-OF(craptel.idevento) THEN 
      
      
                     ASSIGN v-lis-topico    = NO 
                            v-lis-subtopico = NO.
      ELSE IF FIRST-OF(craptel.nrmodulo) THEN 
                     ASSIGN v-lis-subtopico = NO.

                ASSIGN v-permissoes = NO.
                                
                                DO aux_contador = 1 TO NUM-ENTRIES(craptel.cdopptel):
           
        FIND crapace WHERE crapace.cdcooper = craptel.cdcooper                     AND
                           crapace.nmdatela = craptel.nmdatela                     AND 
                           crapace.nmrotina = craptel.nmrotina                     AND
                           crapace.cddopcao = ENTRY(aux_contador,craptel.cdopptel) AND
                           crapace.cdoperad = crapope.cdoperad NO-LOCK NO-ERROR.
                                                                                 
                   /* Tendo qualquer permissão, já carrega a tela no menu */
        IF AVAILABLE crapace THEN
                                        DO:
                                                    ASSIGN v-permissoes = YES.
                                                        LEAVE.
                                            END.
                            END.

                /* verifica super usuário */
      IF crapope.cddepart = 20 THEN    /*  "TI"  */
                     ASSIGN v-permissoes = YES.
               
      IF v-permissoes THEN 
                     DO:
          FOR LAST gnpapgd FIELDS(dtanoage) WHERE gnpapgd.idevento = craptel.idevento
                                               AND gnpapgd.cdcooper = gnapses.cdcooper
                                               AND gnpapgd.dtanoage <> ?. END.
                                               
          IF AVAILABLE gnpapgd THEN                                     
            ASSIGN aux_dtanoage = INT(gnpapgd.dtanoage).
        
                         FIND crapeve WHERE crapeve.idevento = craptel.idevento NO-LOCK NO-ERROR.
                                                 
          FIND crapmod WHERE crapmod.nrmodulo = craptel.nrmodulo AND
                             crapmod.idsistem = craptel.idsistem NO-LOCK NO-ERROR.
               
          IF NOT AVAIL crapeve OR
             NOT AVAIL crapmod THEN   
                                                      NEXT.
                   
          IF NOT v-lis-topico   THEN 
                              DO:
                                  RUN IncluiTopico(crapeve.nmevento).
                                  ASSIGN v-lis-topico = yes.
                              END. /* Fim IF NOT v-lis-topico */

          IF NOT v-lis-subtopico THEN
                                                      DO:
                                  RUN IncluiSubTopico(crapmod.nmmodulo).
                                  ASSIGN v-lis-subtopico = YES.
                              END.
                                                                           
                          RUN Incluicdprogra(craptel.tlrestel,craptel.nmdatela).
                                                                  
                     END. /* Fim do IF v-permissoes */
            END. /* Fim do FOR EACH craptel */
        END.

   {&out} 'initializeDocument()' SKIP.  
   {&out} 'clickOnFolder(0)' SKIP.
   {&out} "<" + "/" + "script></div>" SKIP.

PROCEDURE IncluiTopico:
    
    DEF INPUT PARAM p-topico AS CHAR FORM "x(20)" NO-UNDO.
    ASSIGN p-topico = p-topico.
    {&out} "aux1 = insFld(foldersTree, gFld(setNivel('" + TRIM(p-topico) + "','http://" + aux_srvprogrid + "/cecred/images/icones/ico_lupa.gif','Clique aqui no PROGRID','linkMenuAdmin'), ''))" SKIP.

END PROCEDURE.  /* End IncluiTopico */

PROCEDURE IncluiSubTopico:
    
    DEF INPUT PARAM p-subtopico AS CHAR FORM "x(20)" NO-UNDO.
    ASSIGN p-subtopico = p-subtopico.
    {&out} "aux2 = insFld(aux1, gFld(setNivel('" + TRIM(p-subtopico) + "','http://" + aux_srvprogrid + "/cecred/images/icones/ico_historico.gif','',''),''))" SKIP.

END PROCEDURE.  /* End IncluiSubTopico */

PROCEDURE Incluicdprogra:
    DEF INPUT PARAM p-labelcdprogra AS CHAR FORM "x(20)"    NO-UNDO.
    DEF INPUT PARAM p-cdprogra      AS CHAR FORM "x(200)"   NO-UNDO .
    
		/* aux_cdcopope = é a cooperativa logada*/
		IF INT(SUBSTR(p-cdprogra,(R-INDEX(p-cdprogra,"d") + 1))) >= 100 THEN
			{&out} "insDoc(aux2, gLnk(0,'" + TRIM(p-labelcdprogra) + "','" + aux_srvprogrid + "/telas/" + p-cdprogra + "/" + p-cdprogra + ".php?cdcooper=" + string(gnapses.cdcooper) + "&cdoperad=" + string(gnapses.cdoperad) + "&cdagenci=" + string(crapope.cdagenci) + "&nmdatela=" + string(p-cdprogra) + "&idevento=" + STRING(craptel.idevento) + "&idcokses=" + string(v-identificacao) + "&tlrestel=" + craptel.tlrestel + "&tldatela=" + craptel.tldatela + "&dtanoage=" + STRING(aux_dtanoage) + "'))" SKIP. 
		ELSE /* aux_cdcopope = é a cooperativa logada*/
    	{&out} "insDoc(aux2, gLnk(0,'" + TRIM(p-labelcdprogra) + "','" + p-cdprogra + ".w?aux_idevento=" + string(craptel.idevento) + "&aux_cdcopope=" + string(gnapses.cdcooper) + "&aux_cdcooper=" + string(gnapses.cdcooper) + "&aux_cdoperad="string(gnapses.cdoperad)"'))" SKIP. 
    /*END.*/

END PROCEDURE.  /* End Incluicdprogra */