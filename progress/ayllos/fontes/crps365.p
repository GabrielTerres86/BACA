/* .............................................................................

   Programa: Fontes/crps365.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/2003.                      Ultima atualizacao: 11/03/2009

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 87.
               Emite listagens de saldos de cheques descontados para conferen-
               cia fisica (311) e relatorio aberto de cheques descontados para
               auditoria (312).
   
   Alteracoes: 09/03/2004 - Desprezar devolucoes(Mirtes).
   
               26/10/2004 - Incluir apropriacao (Ze Eduardo).

               03/12/2004 - Incluido campo valor Liq.(Mirtes)

               05/08/2005 - Ajuste na selecao dos registros do crapljd
                            (Edson).

               12/08/2005 - Alterado para exibir tambem no relatorio 311
                            os campos Limite e Disponivel (Diego).
                            
               01/08/2005 - Alterado p/ mostrar total geral associados que
                            descontaram cheques; qtd borderos emitidos p/
                            desconto cheques; e geral socios c/limite p/
                            desconto de cheque - crrl311 (Diego).

               16/09/2005 - Acrescentados totais e concertado layout (Diego).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               11/10/2005 - Efetuado acerto cabecalho,colunas impressao(Mirtes)
               
               18/10/2005 - Acrescentado no relatorio 311, listagem da qtd de 
                            limites que estao e nao esta sendo utilizados
                            por PAC (Diego).

               08/12/2005 - Alterados relatorios (311 e 312) para listar
                            ordenados por PAC (Diego).

               15/02/2005 - Acrescentada listagem por Pac, separando contas
                            Fisicas e Juridicas (311) (Diego).
                            
               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder             

               25/01/2007 - Modificado formato das variaveis do tipo DATE de
                            "99/99/99" para "99/99/9999" (Elton).

               02/07/2007 - Efetuado acerto mascara valor disponivel(negativo)
                            (Mirtes)

               11/03/2009 - Aumentado formato do campo rel_nrdconta(Gabriel).  
............................................................................. */

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps365"
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

RUN STORED-PROCEDURE pc_crps365 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps365 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps365.pr_cdcritic WHEN pc_crps365.pr_cdcritic <> ?
       glb_dscritic = pc_crps365.pr_dscritic WHEN pc_crps365.pr_dscritic <> ?
       glb_stprogra = IF pc_crps365.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps365.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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

