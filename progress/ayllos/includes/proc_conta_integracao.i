/* .............................................................................

   Programa: includes/proc_conta_integracao.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2004                   Ultima atualizacao: 08/03/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Procedures para descobrir se existe conta integracao.

   Alteracoes: 10/11/2005 - Criada procedure Conta digito zero (Magui). 
                
               12/01/2006 - Aceita conta inativa (Magui). 
               
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               08/03/2018 - Substituido cdtipcta < 12 por flag de conta integracao = 0. PRJ366 (Lombardi).
............................................................................. */

PROCEDURE existe_conta_integracao:
   
   { sistema/generico/includes/var_oracle.i }

   DEF VAR aux_idctaitg         AS INT                             NO-UNDO.
   DEF VAR aux_des_erro         AS CHAR                            NO-UNDO.
   DEF VAR aux_dscritic         AS CHAR                            NO-UNDO.

   IF  LENGTH(STRING(aux_ctpsqitg)) <= 8 THEN
       DO:
   
          ASSIGN aux_nrctaass = 0
                 aux_nrdctitg = SUBSTR(STRING(aux_ctpsqitg,"99999999"),1,7) +
                                SUBSTR(STRING(aux_ctpsqitg,"99999999"),8,1).
 
          FIND crabass5 WHERE crabass5.cdcooper = glb_cdcooper  AND
                              crabass5.nrdctitg = aux_nrdctitg  
                              NO-LOCK NO-ERROR.

          IF  NOT AVAIL crabass5   THEN
              DO:
                 ASSIGN aux_nrdctitg = 
                        SUBSTR(STRING(aux_ctpsqitg,"99999999"),1,7) + "X".
            
                 FIND crabass5 WHERE crabass5.cdcooper = glb_cdcooper   AND
                                     crabass5.nrdctitg = aux_nrdctitg 
                                     NO-LOCK NO-ERROR.
                                     
                 IF  NOT AVAIL crabass5   THEN
                     ASSIGN aux_nrdctitg = "".
                 ELSE
                     ASSIGN aux_nrctaass = crabass5.nrdconta.
              END. 
               
          ELSE
              ASSIGN aux_nrctaass = crabass5.nrdconta.
         
       END.
   ELSE 
       DO:
          ASSIGN aux_nrctaass = 0
                 aux_nrdctitg = SUBSTR(STRING(aux_ctpsqitg,"9999999999"),1,9) +
                                SUBSTR(STRING(aux_ctpsqitg,"9999999999"),10,1). 

          FIND crabass5 WHERE crabass5.cdcooper = glb_cdcooper  AND
                              crabass5.nrdctitg = aux_nrdctitg  
                              NO-LOCK NO-ERROR.

          IF   NOT AVAIL crabass5   THEN
               DO:
                  ASSIGN aux_nrdctitg = 
                   SUBSTR(STRING(aux_ctpsqitg,"9999999999"),1,9) + "X".
            
                  FIND crabass5 WHERE crabass5.cdcooper = glb_cdcooper AND
                                      crabass5.nrdctitg = aux_nrdctitg 
                                      NO-LOCK NO-ERROR.
                                      
                  IF  NOT AVAIL crabass5   THEN
                      ASSIGN aux_nrdctitg = "".
                  ELSE
                      ASSIGN aux_nrctaass = crabass5.nrdconta.
               END.
          ELSE
               ASSIGN aux_nrctaass = crabass5.nrdconta.
         
       END.
   
   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
   
   RUN STORED-PROCEDURE pc_busca_tipo_conta_itg
   aux_handproc = PROC-HANDLE NO-ERROR (INPUT crabass5.inpessoa, /* Tipo de pessoa */
                                        INPUT crabass5.cdtipcta, /* Tipo de conta */
                                       OUTPUT 0,                /* Modalidade */
                                       OUTPUT "",               /* Flag Erro */
                                       OUTPUT "").              /* Descrição da crítica */

   CLOSE STORED-PROC pc_busca_tipo_conta_itg
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
   
   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
   
   ASSIGN aux_idctaitg = 0
          aux_des_erro = ""
          aux_dscritic = ""
          aux_idctaitg = pc_busca_tipo_conta_itg.pr_indconta_itg 
                         WHEN pc_busca_tipo_conta_itg.pr_indconta_itg <> ?
          aux_des_erro = pc_busca_tipo_conta_itg.pr_des_erro 
                         WHEN pc_busca_tipo_conta_itg.pr_des_erro <> ?
          aux_dscritic = pc_busca_tipo_conta_itg.pr_dscritic
                         WHEN pc_busca_tipo_conta_itg.pr_dscritic <> ?.
   
   IF aux_des_erro = "NOK"  THEN
          ASSIGN aux_nrdctitg = "".
   
   IF   aux_nrdctitg      <> ""   AND
        aux_idctaitg       = 0    AND 
        crabass5.flgctitg <> 2   THEN
        DO:
            IF  crabass5.flgctitg <> 3   THEN 
                ASSIGN aux_nrdctitg = "".
        END.
        
END PROCEDURE.        

PROCEDURE conta_itg_digito_zero:
   
   ASSIGN aux_nrdigitg = SUBSTR(STRING(aux_nrdctitg,"9999999x"),8,1).
   
   IF   aux_nrdigitg = "x"   THEN 
        ASSIGN aux_nrdigitg = "0".

   ASSIGN aux_ctpsqitg = INTE(SUBSTR(STRING(aux_nrdctitg,"9999999"),1,7) +
                              aux_nrdigitg).

END PROCEDURE.
             
