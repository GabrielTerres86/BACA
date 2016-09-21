/* ..........................................................................

   Programa: Fontes/crps483.p  
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Sidnei (Precise IT)     
   Data    : Junho/2007                      Ultima atualizacao: 09/09/2013

   Dados referentes ao programa:

   Frequencia: Mensal (Batch).
   Objetivo  : Emitir Relatorio Mensal Consolidado Arrecadacao, 
               conforme convenios lancados
               (Solicitacao 39 - Primeiro dia util do mes)
               (Emite relatorio 450)

   Alteracoes: 21/08/2007 - Alimenta tarifa diferenciada para pac 90(Guilherme)
                          - Ajustes no padrao de formatacao (Evandro).

               21/10/2008 - Incluir resumo dos convenios (Gabriel).

               13/11/2008 - Melhoria de Performance (Evandro).

               16/07/2009 - Considerar PMB(Mirtes)

               27/10/2009 - Alterado para utilizar a BO b1wgen0045.p que sera
                            agrupadora das funcoes compartilhadas com o CRPS524
                            
               18/02/2010 - Alterar nome do handle (Magui).
               
               18/03/2010 - Incluido nova coluna no relatorio crrl450.lst, com
                            as informacoes do numero de cooperados que tiveram
                            debito automatico (Elton).
               
               13/05/2010 - Incluido campo com total de cooperados que tiveram
                            algum debito automatico no mes (Elton).
                            
               21/03/2012 - Ajustes para a contabilizacao correta da coluna
                            "COOP.DEB.AUT" (Adriano).             
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
............................................................................. */
                                      
{ includes/var_batch.i  "NEW"}       
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps483"
       glb_cdempres = 11
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

RUN STORED-PROCEDURE pc_crps483 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps483 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps483.pr_cdcritic WHEN pc_crps483.pr_cdcritic <> ?
       glb_dscritic = pc_crps483.pr_dscritic WHEN pc_crps483.pr_dscritic <> ?
       glb_stprogra = IF pc_crps483.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps483.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


