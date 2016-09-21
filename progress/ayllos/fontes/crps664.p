/* ............................................................................

   Programa: fontes/crps664.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Carlos Henrique
   Data    : Janeiro/2014                       Ultima atualizacao: 07/05/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Gerar relatorios 
               crrl671 - Arrecadação Diaria
               crrl672 - Arrecadação Mensal.
               
               Sol. 2  / Ordem 52 / Exclusividade = paralelo
               
   Alteracoes: 07/05/2014 - Assing na variável rel_nrmodulo, para corrigir o
                            problema do erro ** Subscritor de array 0 está fora 
                            de faixa. (26) - Jéssica (DB1) 

               08/04/2015 - Alterar para exibir no relatorio mensal (CRRL672) 
                            os dados de PF, PJ e nao associados de forma segregada. 
                            Incluir a geracao do arquivo de convenios 
                            AAMMDD_CONVEN.txt. Esse processo passara a chamar o
                            processo PC_CRPS649. Projeto 186 ( Renato - Supero )
                            
.............................................................................*/

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps664"
       glb_cdcritic = 0
       glb_dscritic = "".
       
RUN fontes/iniprg.p.
                                                                        
IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

    QUIT.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps649 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT INT(STRING(glb_flgresta,"1/0")),
    OUTPUT 0,
    OUTPUT 0,
    OUTPUT 0, 
    OUTPUT "").

IF  ERROR-STATUS:ERROR  THEN DO:
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + 
                              ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
        
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao executar Stored Procedure: '" +
                      aux_msgerora + "' >> log/proc_batch.log").
    QUIT.
END.

CLOSE STORED-PROCEDURE pc_crps649 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps649.pr_cdcritic WHEN pc_crps649.pr_cdcritic <> ?
       glb_dscritic = pc_crps649.pr_dscritic WHEN pc_crps649.pr_dscritic <> ?
       glb_stprogra = IF pc_crps649.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps649.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
        QUIT.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
RUN fontes/fimprg.p.



