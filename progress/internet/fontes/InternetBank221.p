/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank221.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas Pagel (AMcom)
   Data    : Fevereiro/2019.                       Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Gravar os dados do emprestimo contratado.
      
   Alteracoes: 
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nripuser AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_iddispos AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcpfope AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_cdorigem AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_cdcoptfn AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_cdagetfn AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_nrterfin AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_nrctremp AS INT                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_des_reto AS CHAR                                           NO-UNDO.
DEF VAR aux_idastcjt AS INT                                            NO-UNDO.
DEF VAR aux_qtminast AS INT                                            NO-UNDO.
          
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

  RUN STORED-PROCEDURE pc_solicita_contratacao_ib
      aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nripuser,
                      INPUT par_iddispos,
                      INPUT par_nmdatela,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_dtmvtolt,
                      INPUT STRING(par_nrcpfope),
                      INPUT par_cdorigem,
                      INPUT par_cdcoptfn,
                      INPUT par_cdagetfn,
                      INPUT par_nrterfin,
                      INPUT par_nrctremp,
                      OUTPUT "",
                      OUTPUT "",
                      OUTPUT 0,
                      OUTPUT 0).

  CLOSE STORED-PROC pc_solicita_contratacao_ib 
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

  ASSIGN aux_dscritic = ""
         aux_des_reto = pc_solicita_contratacao_ib.pr_des_reto
                            WHEN pc_solicita_contratacao_ib.pr_des_reto <> ?
         aux_dscritic = pc_solicita_contratacao_ib.pr_dscritic
                            WHEN pc_solicita_contratacao_ib.pr_dscritic <> ? 
         aux_idastcjt = pc_solicita_contratacao_ib.pr_idastcjt
                            WHEN pc_solicita_contratacao_ib.pr_idastcjt <> ?
         aux_qtminast = pc_solicita_contratacao_ib.pr_qtminast
                            WHEN pc_solicita_contratacao_ib.pr_qtminast <> ?.

  IF aux_des_reto <> "OK"  THEN
    DO:
      IF aux_dscritic = "" THEN
         DO:
               ASSIGN aux_dscritic =  "Nao foi possivel efetuar a contratacao da proposta " + STRING(par_nrctremp) + ". ".
         END.

      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                            "</dsmsgerr>".  

      RETURN "NOK".
    END.
            
  CREATE xml_operacao.
  
  ASSIGN xml_operacao.dslinxml = 
       "<Numero_Contrato>" + STRING(par_nrctremp) + "</Numero_Contrato>"  +
       "<Conta>" + STRING(par_nrdconta) + "</Conta>"  +
       "<Cooperativa>" + STRING(par_cdcooper) + "</Cooperativa>".
      
  IF aux_idastcjt = 1 THEN
    DO:
    ASSIGN xml_operacao.dslinxml = xml_operacao.dslinxml + "<qtminast>" + STRING(aux_qtminast) + "</qtminast>" +
                                                           "<dsmsgsuc>" + STRING(aux_dscritic) + "</dsmsgsuc>".
  END.
  
  
      
  RETURN "OK".


/*............................................................................*/
