/*..............................................................................

   Programa: fontes/crps588.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Janeiro/2011                       Ultima atualizacao: 23/10/2012

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Gerar arquivos CUS605 - Custodia de Cheques imagem p/ ABBC
                                       Tambem consisera Desconto de Cheque

   Alteracoes: 23/02/2011 - Tratamento para cheques do BB - Grupo Setec
                            (Guilherme/Ze).
               
               03/03/2011 - Tratamento para DV e D+2 (Ze).
               
               10/03/2011 - Ajuste no trailer dos arquivos gerados (Ze).
               
               19/04/2011 - Possibilitar a geracao dos arquivos mais de uma vez
                            ao dia (Ze).
                            
               13/05/2011 - Retirar a data 24/01/11 - Data Mutirao (Ze).
               
               26/05/2011 - Selecionar somente os cheques com a data de
                            liberacao maior que a data atual (Ze).
                           
               31/05/2011 - Selecionando somente os cheques para os proximos
                            7 dias (Ze).
                            
               16/06/2011 - Acerto para incluir no arquivo C*.002 os cheques
                            com data de liberacao nos finais de semana e feriado
                            (Elton).
                            
               20/06/2011 - Alterado data de vencimento dos cheques de final 
                            de semana e feriado para o proximo dia util, no 
                            arquivo C*.002 (Elton).
                            
               29/12/2011 - Consistir para que o C*.002 nao gere inf. com 
                            cheques com lib. para o ultimo dia util do ano (Ze).

               23/10/2012 - Tratamento para tipificacao de conta - CEL604 (Ze).
               
..............................................................................*/
                  
{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps588"
       glb_flgbatch = FALSE
       glb_cdcritic = 0
       glb_dscritic = "".
       
RUN fontes/iniprg.p.
                                                                        
IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

    RETURN.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps588 aux_handproc = PROC-HANDLE
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
    RETURN.
END.

CLOSE STORED-PROCEDURE pc_crps588 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps588.pr_cdcritic WHEN pc_crps588.pr_cdcritic <> ?
       glb_dscritic = pc_crps588.pr_dscritic WHEN pc_crps588.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps588.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps588.pr_infimsol = 1 THEN
                          TRUE
                      ELSE
                          FALSE.
                          
IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

        RETURN.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                     
RUN fontes/fimprg.p.

/* .......................................................................... */
