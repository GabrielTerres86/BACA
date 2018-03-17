/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank215.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Dionathan Henchel
   Data    : Março/2018                       Ultima atualizacao:   /  /    
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Carregar os banner para exibição no carrossel do sistema mobile
   
   Alteracoes: 
..............................................................................*/
    
{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF  INPUT PARAM par_cdcooper LIKE crapttl.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_cdcanal AS INTE                                   NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR xml_ret AS CHAR 									           NO-UNDO.

 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
 
 RUN STORED-PROCEDURE pc_consulta_banner aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
						  INPUT par_cdcanal,
                          OUTPUT "").

    CLOSE STORED-PROC pc_consulta_banner aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.
		  
	ASSIGN xml_ret = pc_consulta_banner.pr_xml_ret.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = xml_ret.

RETURN "OK".