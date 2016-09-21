/* ..........................................................................

   Programa: Fontes/crps034.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/92.                          Ultima atualizacao: 18/09/2013

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 004.
               Emite relatorio dos associados demitidos no mes (rel 033).

   Alteracoes: 03/04/95 - Alterado para incluir contador de contas excluidas
                          (Edson).

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               20/01/99 - Mudar relatorio para laser (Odair).

               29/12/1999 - Nao gerar mais pedido de impressao (Edson).

               11/02/2000 - Gerar pedido de impressao (Deborah).

               08/07/2005 - Incluidos novos campos no relatorio e geracao
                            de um arquivo para cada PAC (Evandro).
                            
               13/09/2005 - Incluido o operador de demissao (Evandro).
               
               14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               22/01/2007 - Substituicao do formato das variaveis do tipo DATE
                            para "99/99/9999" (Elton).

               13/02/2007 - Concertado para disponibilizar relatorio na 
                            Intranet (Diego).
                            
               19/02/2007 - Alterado Termo Qtd.Associados Excluidos para       
                            Demitidos (Mirtes)

               30/06/2008 - Incluida a chave de acesso (craphis.cdcooper =
                            glb_cdcooper) no "find".
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               14/07/2009 - Alteracao CDOPERAD (Diego).

               18/09/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
               
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps034"
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

RUN STORED-PROCEDURE pc_crps034 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INT(STRING(glb_flgresta,"1/0")),                                         OUTPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps034 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps034.pr_cdcritic WHEN pc_crps034.pr_cdcritic <> ?
       glb_dscritic = pc_crps034.pr_dscritic WHEN pc_crps034.pr_dscritic <> ?          glb_stprogra = IF pc_crps034.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps034.pr_infimsol = 1 THEN TRUE ELSE FALSE. 
       
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

/* .......................................................................... */