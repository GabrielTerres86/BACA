/*******************************************************************************

Programa: includes/wpgd0009.i
Descricao: Verificar permissões de acesso de usuarios
Author: BT - Solusoft 

Alterações: 09/12/2008 - Reestruturação para melhoria de performance (Evandro).

            06/07/2009 - Alteração CDOPERAD (Diego).
			
			05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
						 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

			06/12/2016 - P341-Automatização BACENJUD - Alterada a validação 
			             do departamento para que a mesma seja feita através
						 do código e não da descrição (Renato Darosci).
*******************************************************************************/

/* Parâmetros  */
DEF INPUT  PARAM v-programa      AS CHAR NO-UNDO.
DEF OUTPUT PARAM v-identificacao AS CHAR NO-UNDO.
DEF OUTPUT PARAM v-permissoes    AS CHAR NO-UNDO INIT "".

/* Variaveis locais */
DEF VAR v-inclusao   AS LOG NO-UNDO INIT NO.
DEF VAR v-consulta   AS LOG NO-UNDO INIT NO.
DEF VAR v-alteracao  AS LOG NO-UNDO INIT NO.
DEF VAR v-exclusao   AS LOG NO-UNDO INIT NO.
DEF VAR v-pesquisa   AS LOG NO-UNDO INIT NO.
DEF VAR v-lista      AS LOG NO-UNDO INIT NO.
DEF VAR v-auxiliar   AS LOG NO-UNDO INIT NO.
DEF VAR aux_contador AS INT NO-UNDO.

ASSIGN v-identificacao = get-cookie("cookie-usuario-em-uso").

IF   v-identificacao = ""   THEN
     ASSIGN v-permissoes = "1".  /* falha de identificacao de acesso */
ELSE
     DO:
           /* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
           FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
               LEAVE.
           END.
		 
		 IF   NOT AVAIL gnapses   THEN
		      ASSIGN v-permissoes = "2".  /* falha em gnapses */
	     ELSE
		      DO: /* verificará permissões de acesso */
			      /* Usuário */
				  FIND crapope WHERE crapope.cdcooper = gnapses.cdcooper   AND
                                     crapope.cdoperad = gnapses.cdoperad   NO-LOCK NO-ERROR.
										   
			      IF   NOT AVAIL crapope   THEN
   			           v-permissoes = "3".
			      ELSE
				       DO:
					       /* Limpa as permissões */
					       ASSIGN v-consulta   = NO
  						 	      v-inclusao   = NO
								  v-alteracao  = NO
								  v-exclusao   = NO
								  v-pesquisa   = NO
								  v-lista      = NO
								  v-auxiliar   = NO.					   
					   
					       /* Operador 1-Super Usuario */
						   IF   crapope.cddepart = 20   THEN    /*  TI  */
						        ASSIGN v-consulta   = YES
  									   v-inclusao   = YES
									   v-alteracao  = YES
									   v-exclusao   = YES
									   v-pesquisa   = YES
									   v-lista      = YES
									   v-auxiliar   = YES.
						   ELSE
						        DO:
									FOR EACH craptel WHERE craptel.cdcooper = gnapses.cdcooper   AND
									                       craptel.nmdatela = v-programa         NO-LOCK:
														   
										DO aux_contador = 1 TO NUM-ENTRIES(craptel.cdopptel):
										
										   FIND crapace WHERE crapace.cdcooper = craptel.cdcooper                       AND
                                                              crapace.nmdatela = craptel.nmdatela                       AND 
                                                              crapace.nmrotina = craptel.nmrotina                       AND
									                          crapace.cddopcao = ENTRY(aux_contador,craptel.cdopptel)   AND
									                          crapace.cdoperad = crapope.cdoperad
  								                              NO-LOCK NO-ERROR.
															  
										   IF   AVAILABLE crapace   THEN
										        IF   crapace.cddopcao = "C"   THEN
												     ASSIGN v-consulta = YES
															v-pesquisa = YES
															v-lista    = YES.
												ELSE
												IF   crapace.cddopcao = "I"   THEN
													 ASSIGN v-inclusao = YES.
												ELSE
												IF   crapace.cddopcao = "A"   THEN
												     ASSIGN v-alteracao = YES.
											    ELSE
												IF   crapace.cddopcao = "E"   THEN 
													 ASSIGN v-exclusao = YES.
												ELSE
												IF   crapace.cddopcao = "U"   THEN
													 ASSIGN v-auxiliar = YES.
													 
										END. /* Fim DO..TO.. */									 
                                    END.  /* Fim do FOR EACH */
								END.
						   
						   IF   NOT v-consulta   THEN
						        ASSIGN v-permissoes = "3".
                           ELSE
							    ASSIGN v-permissoes = IF v-inclusao THEN "I" ELSE "X"
                                       v-permissoes = v-permissoes + (IF v-alteracao THEN "A" ELSE "X")
                                       v-permissoes = v-permissoes + (IF v-exclusao  THEN "E" ELSE "X")
                                       v-permissoes = v-permissoes + (IF v-pesquisa  THEN "P" ELSE "X")
                                       v-permissoes = v-permissoes + (IF v-lista     THEN "L" ELSE "X")
                                       v-permissoes = v-permissoes + (IF v-auxiliar  THEN "U" ELSE "X").
   
                       END. /* Fim do ELSE DO */
              END. /* fim de verificao de permissoes de acesso */                                                 
     END.  /* else do */
