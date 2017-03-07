/*.............................................................................

   Programa: fontes/zoom_natureza_ocupacao.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2004                   Ultima alteracao: 06/03/2010 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela tt-gncdnto - natureza da ocupacao.

   Alteracoes: 06/03/2010 - Busca dados da BO generica p/ ZOOM (Jose Luis, DB1)
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM &BD-GEN=SIM }
{ sistema/generico/includes/var_oracle.i }

DEF SHARED VAR shr_cdnatocp LIKE crapttl.cdnatopc                NO-UNDO.
DEF SHARED VAR shr_rsnatocp AS CHAR FORMAT "x(15)"               NO-UNDO.

DEF QUERY  b-gncdntoa-q FOR tt-gncdnto. 
DEF BROWSE b-gncdntoa-b QUERY b-gncdntoa-q
      DISP cdnatocp                            COLUMN-LABEL "Cod"
           rsnatocp        FORMAT "x(15)"      COLUMN-LABEL "Descricao"
           WITH 10 DOWN OVERLAY TITLE "NATUREZA OCUPACAO".    
          
FORM b-gncdntoa-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

/* Variaveis para o XML */ 
DEF VAR xDoc          AS HANDLE                                      NO-UNDO.   
DEF VAR xRoot         AS HANDLE                                      NO-UNDO.  
DEF VAR xRoot2        AS HANDLE                                      NO-UNDO.  
DEF VAR xField        AS HANDLE                                      NO-UNDO. 
DEF VAR xText         AS HANDLE                                      NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER                                     NO-UNDO. 
DEF VAR aux_cont      AS INTEGER                                     NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR                                      NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR                                    NO-UNDO.

/***************************************************/
   IF  NOT aux_fezbusca THEN
       DO:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
 
			/* Efetuar a chamada da rotina Oracle */ 
			RUN STORED-PROCEDURE pc_busca_gncdnto_car
				aux_handproc = PROC-HANDLE NO-ERROR(INPUT 0, /*codigo da natureza*/                          
													INPUT "", /*descricao da natureza*/                                                                                            
													INPUT 999999, /*nrregist*/
													INPUT 1, /*nriniseq*/
												   OUTPUT "", /*Nome do Campo*/                
												   OUTPUT "", /*Saida OK/NOK*/                          
												   OUTPUT ?, /*Tabela Regionais*/                       
												   OUTPUT 0, /*Codigo da critica*/                      
												   OUTPUT ""). /*Descricao da critica*/ 
    
			/* Fechar o procedimento para buscarmos o resultado */ 
			CLOSE STORED-PROC pc_busca_gncdnto_car
				   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
         
			/* Efetuar a chamada da rotina Oracle */ 
			{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

			/*Leitura do XML de retorno da proc e criacao dos registros na tt-gncdnto
			  para visualizacao dos registros na tela */
    
			/* Buscar o XML na tabela de retorno da procedure Progress */ 
			ASSIGN xml_req = pc_busca_gncdnto_car.pr_clob_ret.
    
			/* Efetuar a leitura do XML*/ 
			SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
			PUT-STRING(ponteiro_xml,1) = xml_req. 
    
			/* Inicializando objetos para leitura do XML */ 
			CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
			CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
			CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
			CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
			CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */
     
			IF ponteiro_xml <> ? THEN
			   DO:   
				  xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
				  xDoc:GET-DOCUMENT-ELEMENT(xRoot).
             
				  DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
             
					 xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
     
					 IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
						NEXT. 
           
					 IF xRoot2:NUM-CHILDREN > 0 THEN
						DO:
                
							CREATE tt-gncdnto.
    
						END.
     
					 DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
               
						xRoot2:GET-CHILD(xField,aux_cont).
                  
						IF xField:SUBTYPE <> "ELEMENT" THEN 
						   NEXT. 
              
						xField:GET-CHILD(xText,1).
                  
						ASSIGN tt-gncdnto.cdnatocp = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdnatocp"
							   tt-gncdnto.rsnatocp = xText:NODE-VALUE WHEN xField:NAME = "rsnatocp"
							   tt-gncdnto.dsnatocp = xText:NODE-VALUE WHEN xField:NAME = "dsnatocp".							   
                
					 END. 
            
				  END.
     
				  SET-SIZE(ponteiro_xml) = 0. 
    
			   END.
     
			DELETE OBJECT xDoc. 
			DELETE OBJECT xRoot. 
			DELETE OBJECT xRoot2. 
			DELETE OBJECT xField. 
			DELETE OBJECT xText.
			
			ASSIGN aux_fezbusca = YES.

       END.

   ON RETURN OF b-gncdntoa-b 
      DO:
          ASSIGN shr_cdnatocp = tt-gncdnto.cdnatocp
                 shr_rsnatocp = tt-gncdnto.rsnatocp.
          
          CLOSE QUERY b-gncdntoa-q.               
          APPLY "END-ERROR" TO b-gncdntoa-b.
                 
      END.

   OPEN QUERY b-gncdntoa-q FOR EACH tt-gncdnto NO-LOCK BY tt-gncdnto.rsnatocp.
   
   SET b-gncdntoa-b WITH FRAME f_alterar.
           
/****************************************************************************/
