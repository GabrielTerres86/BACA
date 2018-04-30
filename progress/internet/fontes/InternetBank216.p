/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank216.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lombardi
   Data    : Abril/2018                     Ultima atualizacao: 00/00/0000
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Validar adesao do produto por tipo de conta. (Lombardi).
   
   Alteracoes: 
 
..............................................................................*/
    
{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF  INPUT PARAM par_cdcooper LIKE crapass.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_cdprodut   AS INTEGER                             NO-UNDO.
DEF  INPUT PARAM par_vlcontra   AS DECI                                NO-UNDO.
DEF  INPUT PARAM par_operacao   AS INTEGER                             NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR xml_ret AS CHAR 									           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                         NO-UNDO.
DEF VAR aux_dscritic AS CHAR                         NO-UNDO.
DEF VAR aux_solcoord AS INTE                         NO-UNDO.

IF par_operacao = 1 THEN
  DO:
      /* Verificar se o tipo de conta permite a contrataçao do produto. */
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
      
      RUN STORED-PROCEDURE pc_valida_adesao_produto
          aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT par_cdcooper,
                                   INPUT par_nrdconta,
                                   INPUT par_cdprodut, /* Codigo Produto */
                                   OUTPUT 0,   /* pr_cdcritic */
                                   OUTPUT ""). /* pr_dscritic */
      
      CLOSE STORED-PROC pc_valida_adesao_produto
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
      
      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
      ASSIGN aux_cdcritic = 0
             aux_dscritic = ""
             aux_cdcritic = pc_valida_adesao_produto.pr_cdcritic                          
                                WHEN pc_valida_adesao_produto.pr_cdcritic <> ?
             aux_dscritic = pc_valida_adesao_produto.pr_dscritic
                                WHEN pc_valida_adesao_produto.pr_dscritic <> ?.
      
      IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
          DO:
              IF aux_dscritic = "" THEN
                 DO:
                    FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                       NO-LOCK NO-ERROR.
                    
                    IF AVAIL crapcri THEN
                       ASSIGN aux_dscritic = crapcri.dscritic.
                    ELSE
                       ASSIGN aux_dscritic =  "Nao foi possivel validar a adesao do produto.".
                 
                 END.
              
              ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
              
              RETURN "NOK".
          END.
          
      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = xml_ret.
  END.
ELSE IF par_operacao = 2 THEN
  DO:
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

      RUN STORED-PROCEDURE pc_valida_valor_adesao
      aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Cooperativa */
                                           INPUT par_nrdconta, /* Numero da conta */
                                           INPUT par_cdprodut, /* Codigo Produto */
                                           INPUT par_vlcontra, /* Valor contratado */
                                           INPUT 3,            /* Codigo do produto */
                                          OUTPUT 0,            /* Solicita senha coordenador */
                                          OUTPUT 0,            /* Codigo da crítica */
                                          OUTPUT "").          /* Descriçao da crítica */

      CLOSE STORED-PROC pc_valida_valor_adesao
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

      ASSIGN aux_solcoord = 0
             aux_cdcritic = 0
             aux_dscritic = ""
             aux_solcoord = pc_valida_valor_adesao.pr_solcoord 
                            WHEN pc_valida_valor_adesao.pr_solcoord <> ?
             aux_cdcritic = pc_valida_valor_adesao.pr_cdcritic 
                            WHEN pc_valida_valor_adesao.pr_cdcritic <> ?
             aux_dscritic = pc_valida_valor_adesao.pr_dscritic
                            WHEN pc_valida_valor_adesao.pr_dscritic <> ?.

      IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
           DO:
               IF aux_dscritic = "" THEN
                   DO:
                      FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                         NO-LOCK NO-ERROR.
                      
                      IF AVAIL crapcri THEN
                         ASSIGN aux_dscritic = crapcri.dscritic.
                      ELSE
                         ASSIGN aux_dscritic =  "Nao foi possivel validar o valor de adesao.".
                   END.
          
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                      "</dsmsgerr>".  
                
                RETURN "NOK".
           END.
  END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = xml_ret.

RETURN "OK".