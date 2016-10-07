/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank175.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Kelvin Souza Ott
   Data    : Setembro/2016                        Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Gravar configuracoes da cobranca
      
   Alteracoes:
..............................................................................*/
{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM pr_cdcooper  AS INTE                    			   NO-UNDO.
DEF INPUT  PARAM pr_nrdconta  AS INTE                   			   NO-UNDO.
DEF INPUT  PARAM pr_idrazfan  AS INTE                   			   NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.						   

DEF VAR aux_dsxmlout  AS CHAR                                          NO-UNDO.
DEF VAR aux_des_erro  AS CHAR                                          NO-UNDO.
DEF VAR aux_dscritic  AS CHAR                                          NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_grava_config_nome_blt
  aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT deci(pr_cdcooper),
                      INPUT deci(pr_nrdconta),
					  INPUT pr_idrazfan,
                      OUTPUT "",
                      OUTPUT "").
                      
                     
CLOSE STORED-PROC pc_grava_config_nome_blt aux_statproc = PROC-STATUS
      WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_des_erro = ""
       aux_dscritic = ""
       aux_des_erro = pc_grava_config_nome_blt.pr_des_erro
                      WHEN pc_grava_config_nome_blt.pr_des_erro <> ?
       aux_dscritic = pc_grava_config_nome_blt.pr_dscritic
                      WHEN pc_grava_config_nome_blt.pr_dscritic <> ?.
        
{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_des_erro <> "OK" OR
    aux_dscritic <> ""   THEN DO: 

    IF  aux_dscritic = "" THEN DO:   
        ASSIGN aux_dscritic =  "Nao foi possivel concluir a busca da configuracao".
    END.

    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                       "</dsmsgerr>".  
    
    RETURN "NOK".
    
END.

RETURN "OK".