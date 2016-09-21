/* ..........................................................................

   Programa: Fontes/crps576.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Setembro/2010                   Ultima atualizacao: 02/08/2013 

   Dados referentes ao programa:

   Frequencia: Mensal / CECRED(Roda no primeiro dia util do mes.
   Objetivo  : Atende a solicitacao 39. Ordem = 10.
               Gera informacoes para o BNDES - 7018.
               Relatorio 568.

   Alteracoes: 04/01/2010 - Ler o crapris com glb_dtultdma (Magui).             
   
               26/01/2011 - Gerar informações a partir da crapprb (Guilherme)
               
               30/10/2012 - Retirado os valores da Concredi e Credimilsul do
                            relatorio (Elton). 
                            
               28/11/2012 - Retirado os valores da Alto Vale do relatorio 
                            (David Kruger).
                            
               02/08/2013 - Retirado restrições  das informaçoes para
                            a Concredi e a Alto Vale (Daniele).            
                                         

               16/05/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Edison - AMcom)
............................................................................. */

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps576"
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

RUN STORED-PROCEDURE pc_crps576 aux_handproc = PROC-HANDLE NO-ERROR
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

CLOSE STORED-PROCEDURE pc_crps576 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps576.pr_cdcritic WHEN pc_crps576.pr_cdcritic <> ?
       glb_dscritic = pc_crps576.pr_dscritic WHEN pc_crps576.pr_dscritic <> ?
       glb_stprogra = IF pc_crps576.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps576.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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
