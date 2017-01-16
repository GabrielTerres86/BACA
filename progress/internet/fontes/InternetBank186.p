/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank186.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Kelvin Souza Ott
   Data    : Setembro/2016                        Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Retornar o valor do titulo vencido
      
   Alteracoes:
..............................................................................*/
{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM pr_cdcooper        AS INTE         NO-UNDO.
DEF INPUT  PARAM pr_nrdconta        AS INTE         NO-UNDO.
DEF INPUT  PARAM pr_idseqttl        AS INTE         NO-UNDO.
DEF INPUT  PARAM pr_cdagenci        AS INTE         NO-UNDO.
DEF INPUT  PARAM pr_nrdcaixa        AS INTE         NO-UNDO.
        
DEF INPUT  PARAM pr_titulo1         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_titulo2         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_titulo3         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_titulo4         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_titulo5         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_codigo_barras   AS CHAR         NO-UNDO.
      
DEF VAR aux_vlfatura                AS DECI         NO-UNDO.
DEF VAR aux_vlrjuros                AS DECI         NO-UNDO.
DEF VAR aux_vlrmulta                AS DECI         NO-UNDO.
DEF VAR aux_fltitven                AS INTE         NO-UNDO.
                                                   
DEF VAR aux_des_erro                AS CHAR         NO-UNDO.
DEF VAR aux_dscritic                AS CHAR         NO-UNDO.
   
DEF OUTPUT PARAM xml_dsmsgerr       AS CHAR         NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.      

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_retorna_vlr_tit_vencto
  aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT pr_cdcooper,
                      INPUT pr_nrdconta,
                      INPUT pr_idseqttl,
                      INPUT pr_cdagenci,
                      INPUT pr_nrdcaixa,
                      INPUT pr_titulo1,
                      INPUT pr_titulo2,
                      INPUT pr_titulo3,
                      INPUT pr_titulo4,
                      INPUT pr_titulo5,
                      INPUT pr_codigo_barras,
                      OUTPUT 0,
                      OUTPUT 0,
                      OUTPUT 0,
                      OUTPUT 0,
                      OUTPUT "",
                      OUTPUT "").
                      
                     
CLOSE STORED-PROC pc_retorna_vlr_tit_vencto aux_statproc = PROC-STATUS
      WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_des_erro = ""
           aux_dscritic = ""
           aux_vlfatura = 0
           aux_vlrjuros = 0
           aux_vlrmulta = 0
           aux_fltitven = 0
           aux_vlfatura = pc_retorna_vlr_tit_vencto.pr_vlfatura
                          WHEN pc_retorna_vlr_tit_vencto.pr_vlfatura <> ?        
           aux_vlrjuros = pc_retorna_vlr_tit_vencto.pr_vlrjuros
                          WHEN pc_retorna_vlr_tit_vencto.pr_vlrjuros <> ?
           aux_vlrmulta = pc_retorna_vlr_tit_vencto.pr_vlrmulta
                          WHEN pc_retorna_vlr_tit_vencto.pr_vlrmulta <> ?
           aux_fltitven = pc_retorna_vlr_tit_vencto.pr_fltitven
                          WHEN pc_retorna_vlr_tit_vencto.pr_fltitven <> ?
           aux_des_erro = pc_retorna_vlr_tit_vencto.pr_des_erro
                          WHEN pc_retorna_vlr_tit_vencto.pr_des_erro <> ?
           aux_dscritic = pc_retorna_vlr_tit_vencto.pr_dscritic
                          WHEN pc_retorna_vlr_tit_vencto.pr_dscritic <> ?.
           
{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_des_erro <> "OK" OR
    aux_dscritic <> ""   THEN DO: 

    IF  aux_dscritic = "" THEN DO:   
        ASSIGN aux_dscritic =  "Nao foi possivel concluir a busca do valor do titulo".
    END.

    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                       "</dsmsgerr>".  
    
    RETURN "NOK".
    
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<cabecalho> 
                                  <vlfatura>" + TRIM(STRING(aux_vlfatura,'zzz,zzz,zz9.99')) + "</vlfatura>
                                  <vlrjuros>" + STRING(aux_vlrjuros) + "</vlrjuros>
                                  <vlrmulta>" + STRING(aux_vlrmulta) + "</vlrmulta>
                                  <fltitven>" + STRING(aux_fltitven) + "</fltitven>
                                </cabecalho>".

RETURN "OK".