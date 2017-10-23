/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank209.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Dionathan
   Data    : Agosto/2017                     Ultima atualizacao: 00/00/0000
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Atualiza as configuraçoes de recebimento de push do cooperado.
   
   Alteracoes: 
 
..............................................................................*/
    
{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF  INPUT PARAM par_cdcooper LIKE crapttl.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dispositivomobileid AS CHAR                       NO-UNDO.
DEF  INPUT PARAM par_recbpush AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_chavedsp AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_lstconfg AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_cdcanal AS INTE                                   NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR xml_ret AS CHAR 									           NO-UNDO.

 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
 
 RUN STORED-PROCEDURE pc_altera_config_receb_push aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT DECIMAL(par_dispositivomobileid),
                          INPUT par_recbpush,
                          INPUT par_chavedsp,
                          INPUT par_lstconfg,
						  INPUT par_cdcanal,
                          OUTPUT "").

    CLOSE STORED-PROC pc_altera_config_receb_push aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.
		  
	ASSIGN xml_ret = pc_altera_config_receb_push.pr_xml_ret.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = xml_ret.

RETURN "OK".