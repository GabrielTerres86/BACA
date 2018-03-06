/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank215.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ederson Luiz Camargo
   Data    : Março/2018                       Ultima atualizacao:   /  /    
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Carregar os banner para exibição no carrossel do sistema mobile
   
   Alteracoes: 
..............................................................................*/
 
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_oracle.i   }

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdcanal AS INTE                                   NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR xml_req      AS LONGCHAR                     NO-UNDO.
DEF VAR aux_dsxmlout AS CHAR                         NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
     
    RUN STORED-PROCEDURE pc_consulta_banner aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper    /* pr_cdcooper */
                         ,INPUT par_nrdconta    /* pr_nrdconta */
						 ,INPUT par_idseqttl    /* pr_idseqttl */
						 ,INPUT par_cdcanal		/* pr_cdcanal  */
						 //,OUTPUT ?				/* pr_dscritic */
                         ,OUTPUT ? ).			/* pr_xml_ret  */

    CLOSE STORED-PROC pc_consulta_banner aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dsxmlout = ""
           aux_dsxmlout = pc_consulta_banner.pr_xml_ret WHEN pc_consulta_banner.pr_xml_ret  <> ?.
		   //aux_dscritic = ""
           //aux_dscritic = pc_consulta_banner.pr_dscritic WHEN pc_consulta_banner.pr_dscritic <> ?
           
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    xml_req = aux_dsxmlout.

    //IF  aux_dscritic <> "" THEN DO:
    //    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    //    RETURN "NOK".
    //END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.
	
	RETURN "OK".

/*...........................................................................*/