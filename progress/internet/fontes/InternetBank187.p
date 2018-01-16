/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank187.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jean Michel
   Data    : Julho/2016.                       Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Obter horarios limites de pagamento DARF/DAS.
   
   Alteracoes: 
..............................................................................*/
 
	CREATE WIDGET-POOL.
 
	{ sistema/internet/includes/var_ibank.i }
	{ sistema/generico/includes/var_internet.i }
	{ sistema/generico/includes/var_oracle.i }

	DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.

	DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
	DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
    DEF VAR aux_dsretorn AS CHAR                                           NO-UNDO.
    DEF VAR aux_xml_operacao187 AS LONGCHAR                                NO-UNDO.
	DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
    DEF VAR aux_iteracoes AS INT                                           NO-UNDO.
    DEF VAR aux_posini AS INT                                              NO-UNDO.
    DEF VAR aux_contador AS INT                                            NO-UNDO.
    DEF VAR aux_flmobile AS INT                                            NO-UNDO.

	DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
	DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
	DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
	DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
	DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
	DEF  INPUT PARAM par_tpdaguia LIKE crapttl.idseqttl                    NO-UNDO.
	DEF  INPUT PARAM par_flmobile AS LOGI                                  NO-UNDO.

	DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

	DEF OUTPUT PARAM TABLE FOR xml_operacao.

	DEF VAR aux_dsconsul  AS CHAR NO-UNDO.

	IF par_tpdaguia = 1 THEN
		ASSIGN aux_dstransa = "Consulta de dados para pagamento de DARF".
	ELSE IF par_tpdaguia = 2 THEN
		ASSIGN aux_dstransa = "Consulta de dados para pagamento de DAS".

    FUNCTION roundUp RETURNS INTEGER ( x as decimal ):
	  IF x = TRUNCATE( x, 0 ) THEN
	    RETURN INTEGER( x ).
	  ELSE
	    RETURN INTEGER(TRUNCATE( x, 0 ) + 1 ).
    END.

    IF par_flmobile THEN
        ASSIGN aux_flmobile = 1.
    ELSE
        ASSIGN aux_flmobile = 0.
    
    /* Procedimento do internetbank operaçao 187 */
	{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_InternetBank187
		aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper /* Codigo Cooperativa */
                                    	   ,INPUT 90		   /* Agencia do Associado */
                                    	   ,INPUT 900		   /* Numero caixa */
                                    	   ,INPUT par_nrdconta /* Numero da conta */
                                    	   ,INPUT par_idseqttl /* Identificador Sequencial titulo */
                                    	   ,INPUT par_dtmvtolt /* Data Movimento */
                                    	   ,INPUT 0			   /* Indicador agenda */
                                    	   ,INPUT ?			   /* Data Pagamento */
                                    	   ,INPUT 0			   /* Valor Lancamento */
                                    	   ,INPUT 0			   /* Codigo banco */
                                    	   ,INPUT 0			   /* Codigo Agencia */
                                    	   ,INPUT 0			   /* Numero Conta Transferencia */
                                    	   ,INPUT 10  
                                    	   ,INPUT "996"		   /* Codigo Operador */
                                    	   ,INPUT par_tpdaguia 
                                    	   ,INPUT 0			   /* (0- False, 1-True)Indicador validacoes */
                                    	   ,INPUT "INTERNET"   /* Descricao Origem */
                                    	   ,INPUT par_nrcpfope /* CPF operador */
                                    	   ,INPUT 1            /* (0- False, 1-True)controla validacoes na efetivacao de agendamentos */
                                    	   ,INPUT ""		   /* Nome da Tela */
                                    	   ,INPUT ""		   /* IP da transacao no IBank/mobile */
                                    	   ,INPUT aux_flmobile /* Indicador se origem é do Mobile */
                                    	  ,OUTPUT ""		   /* Retorno XML de critica */
                                    	  ,OUTPUT ""		   /* Retorno XML da operaçao 187 */
                                    	  ,OUTPUT "").         /* Retorno de critica (OK ou NOK) */
                                                                           

	IF  ERROR-STATUS:ERROR  THEN DO:
		DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
			ASSIGN aux_msgerora = aux_msgerora + ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
		END.
          
		ASSIGN aux_dscritic = "pc_InternetBank187 --> "  +
							"Erro ao executar Stored Procedure: " +
							aux_msgerora.
      
		ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
									"Erro inesperado. Nao foi possivel efetuar a consulta." + 
									" Tente novamente ou contacte seu PA" +
							"</dsmsgerr>".
                        
		RUN proc_geracao_log(INPUT FALSE).
      
		RETURN "NOK".
      
	END. 

	CLOSE STORED-PROC pc_InternetBank187
		aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

	{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}

	ASSIGN aux_dsretorn       = ""
		   xml_dsmsgerr       = ""
		   aux_xml_operacao187 = ""
		   aux_dsretorn = pc_InternetBank187.pr_dsretorn 
		      			  WHEN pc_InternetBank187.pr_dsretorn <> ?
		   xml_dsmsgerr = pc_InternetBank187.pr_xml_dsmsgerr 
						  WHEN pc_InternetBank187.pr_xml_dsmsgerr <> ?
		   aux_xml_operacao187 = pc_InternetBank187.pr_xml_operacao187 
								WHEN pc_InternetBank187.pr_xml_operacao187 <> ?               .

	/* Verificar se retornou critica */
	IF aux_dsretorn <> "OK" THEN
	    RETURN "NOK".
   
	/* Atribuir xml de retorno a temptable*/ 
	IF aux_xml_operacao187 <> "" THEN
		DO:
			ASSIGN aux_iteracoes = roundUp(LENGTH(aux_xml_operacao187) / 31000)
				   aux_posini    = 1.    

			DO aux_contador = 1 TO aux_iteracoes:
						CREATE xml_operacao.
				ASSIGN xml_operacao.dslinxml = SUBSTRING(aux_xml_operacao187, aux_posini, 31000)
						aux_posini            = aux_posini + 31000.
			END.

		END.

	RETURN "OK".
    
/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:
    
    DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT "996",
                                          INPUT aux_dscritic,
                                          INPUT "INTERNET",
                                          INPUT aux_dstransa,
                                          INPUT aux_datdodia,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT "INTERNETBANK",
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).
                                          
             RUN gera_log_item IN h-b1wgen0014
                          (INPUT aux_nrdrowid,
                           INPUT "Origem",
                           INPUT "",
                           INPUT STRING(par_flmobile,"MOBILE/INTERNETBANK")).
                 
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE.