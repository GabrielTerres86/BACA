/*..............................................................................

  Programa: sistema/internet/fontes/InternetBank180.p
  Sistema : Internet - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Lucas Lunelli
  Data    : Janeiro/2017.                       Ultima atualizacao:

  Dados referentes ao programa:
  Frequencia: Sempre que for chamado (On-Line)

  Objetivo  : Obter data útil para agendamento.

  Alteracoes: 
..............................................................................*/

CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_dscritic        AS CHAR                                    NO-UNDO.
DEF VAR aux_dtcaluti        AS DATE                                    NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dstpcons AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

  /* validar dia util, senao for retorna o proximo - Rotina Oracle */
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  RUN STORED-PROCEDURE pc_valida_dia_util
    aux_handproc = PROC-HANDLE NO-ERROR
                  (INPUT par_cdcooper         /* pr_cdcooper */
                  ,INPUT-OUTPUT par_dtmvtolt  /* pr_dtmvtolt */
                  ,INPUT par_dstpcons         /* pr_tipo */
                  ,INPUT 1                    /* pr_feriado - Considerar feriados*/
                  ,INPUT 0).                  /* pr_excultdia - Nao excluir ultimo dia do ano*/

  CLOSE STORED-PROC pc_valida_dia_util
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}

  /* FIM validar dia util - Rotina Oracle */

  IF  ERROR-STATUS:ERROR  THEN DO:
      DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
          ASSIGN aux_msgerora = aux_msgerora + ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
      END.
        
      ASSIGN aux_dscritic = "pc_InternetBank180 --> "  +
                            "Erro ao executar Stored Procedure: " +
                            aux_msgerora.
              
      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                            "Erro inesperado. Nao foi possivel efetuar a consulta." + 
                            " Tente novamente ou contacte seu PA" +
                            "</dsmsgerr>".                       
      RETURN "NOK".   
  END. 

  ASSIGN xml_dsmsgerr  = ""
         aux_dtcaluti  = ?
         aux_dtcaluti  = DATE(pc_valida_dia_util.pr_dtmvtolt)
                         WHEN pc_valida_dia_util.pr_dtmvtolt <> ?.
                              
  IF  DATE(aux_dtcaluti) = ? THEN
      DO:
          ASSIGN aux_dscritic = "pc_InternetBank180 --> "  +
                                "Erro ao processar data de retorno".
              
          ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                                "Erro inesperado. Nao foi possivel efetuar a consulta." + 
                                " Tente novamente ou contacte seu PA" +
                                "</dsmsgerr>".                       
          RETURN "NOK".
      END.
  
  /* Retorna Data Calculada */
  CREATE xml_operacao.
  ASSIGN xml_operacao.dslinxml =  "<dtcaluti>" + 
                                  STRING(aux_dtcaluti, "99/99/9999") + 
                                  "</dtcaluti>".
  
  /* Retorna se data era útil */
  IF  par_dtmvtolt = aux_dtcaluti THEN
      ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
                                     "<flgdtuti>1</flgdtuti>". /* Era útil */
  ELSE
      ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml +
                                     "<flgdtuti>0</flgdtuti>". /* Nao era útil */

  RETURN "OK".