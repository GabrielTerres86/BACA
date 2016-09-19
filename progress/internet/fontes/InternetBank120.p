/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank120.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/SUPERO
   Data    : Setembro/2014                       Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Buscar os termos de Aceite e Confirmar Aceite ou Cancelamento
      
   Alteracoes:
..............................................................................*/



 { sistema/internet/includes/var_ibank.i    }
 { sistema/generico/includes/var_internet.i }
 { sistema/generico/includes/var_oracle.i   }

 DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
 DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
 DEF INPUT  PARAM par_nrconven LIKE crapass.nrdconta                    NO-UNDO.
 DEF INPUT  PARAM par_tpdtermo AS INT                                   NO-UNDO.
 DEF INPUT  PARAM par_confirma AS INT                                   NO-UNDO.
 DEF INPUT  PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
 DEF INPUT  PARAM par_cdoperad AS CHAR                                  NO-UNDO.

 DEF OUTPUT PARAM xml_dsmsgerr  AS CHAR                                 NO-UNDO.
 DEF OUTPUT PARAM xml_operacao  AS CHAR                                 NO-UNDO.

 DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
 DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
 DEF VAR aux_dsretorn AS CHAR                                           NO-UNDO.
 DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
 DEF VAR aux_nrdocmto AS DEC                                            NO-UNDO.
 DEF VAR ret_flconven AS INTE                                           NO-UNDO.


 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

 IF  par_confirma <> 1 THEN DO:   /** Esta apenas buscando o Termo de Servico */
     RUN STORED-PROCEDURE pc_busca_termo_servico aux_handproc = PROC-HANDLE NO-ERROR
                          (INPUT par_cdcooper,
                           INPUT par_nrdconta,
                           INPUT par_nrconven,
                           INPUT par_tpdtermo,
                           INPUT 3, /** idorigem */
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "").

     CLOSE STORED-PROC pc_busca_termo_servico aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

     ASSIGN aux_dslinxml = ""
            aux_cdcritic = 0
            aux_dscritic = ""
            aux_cdcritic = pc_busca_termo_servico.pr_cdcritic
                           WHEN pc_busca_termo_servico.pr_cdcritic <> ?
            aux_dscritic = pc_busca_termo_servico.pr_dscritic
                           WHEN pc_busca_termo_servico.pr_dscritic <> ?
            xml_operacao = pc_busca_termo_servico.pr_dsdtermo
                           WHEN pc_busca_termo_servico.pr_dsdtermo <> ?.

 END.
 ELSE DO:   /*** Se igual a 1, clicou no CONCORDO na tela do Termo do Servico **/

     RUN STORED-PROCEDURE pc_efetua_aceite_cancel aux_handproc = PROC-HANDLE NO-ERROR
                          (INPUT par_cdcooper,
                           INPUT par_nrdconta,
                           INPUT par_nrconven,
                           INPUT par_tpdtermo,
                           INPUT par_dtmvtolt,
                           INPUT par_cdoperad,
                          OUTPUT 0,
                          OUTPUT "").

     CLOSE STORED-PROC pc_efetua_aceite_cancel aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

     ASSIGN aux_dslinxml = ""
            aux_cdcritic = 0
            aux_dscritic = ""
            aux_cdcritic = pc_efetua_aceite_cancel.pr_cdcritic
                           WHEN pc_efetua_aceite_cancel.pr_cdcritic <> ?
            aux_dscritic = pc_efetua_aceite_cancel.pr_dscritic
                           WHEN pc_efetua_aceite_cancel.pr_dscritic <> ?.

 END.


 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }


 IF  aux_cdcritic <> 0   OR
     aux_dscritic <> ""  THEN DO: 

     IF  aux_dscritic = "" THEN DO:
         FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                    NO-LOCK NO-ERROR.

         IF  AVAIL crapcri THEN
             ASSIGN aux_dscritic = crapcri.dscritic.
         ELSE
             ASSIGN aux_dscritic =  "Nao foi possivel verificar " +
                                    "aceite do Pagto Lote.".
     END.

     ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                        "</dsmsgerr>".  

     RETURN "NOK".

 END.




 RETURN "OK".

 /* ............................... PROCEDURES ............................... */


