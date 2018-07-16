/* ..........................................................................
   Programa: Fontes/crps147.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Abril/96.                       Ultima atualizacao: 06/06/2013

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Solicitacao: 003.
               Calcular a provisao mensal e emitir resumo da poupanca programda.
               Relatorio 123.

   Alteracoes: 27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               07/01/2000 - Nao gerar pedido de relatorio (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).
               
               26/07/2001 - Gerar arquivo para conferencia (Junior).

               29/01/2004 - Mostrar o IR recolhido na fonte (Margarete).
               
               19/04/2004 - Atualizar novos campos craprpp (Margarete).
               
               24/05/2004 - Incluir total abono cpmf a recuperar (Margarete).
                              
               22/09/2004 - Incluido historico 496(CI)(Mirtes)

               29/06/2005 - Alimentado campo cdcooper da tabela craprej (Diego)
               
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               26/07/2006 - Campo vlslfmes passa a ser vlsdextr. E o
                            vlslfmes passa a ser o valor exato da poupanca
                            na contabilidade no ultimo dia do mes (Magui).
                            
               04/05/2008 - Alterado para nao considerar cdsitrpp = 5 (poupanca
                            baixada pelo vencimento)  no for each na craprpp.
                            (Rosangela)
                                         
               02/09/2010 - Incluir no relatorio o quadro de periodos.
                            Tarefa 34624 (Henrique).
                            
               13/09/2010 - Adicionar novos prazos no quadro de periodos.
                            (Henrique)
                            
               26/01/2011 - Alimentar crapprb por nrdconta do cooperado
                           (Guilherme)   
                           
               21/11/2011 - Correção para considerar o prazo a partir da
                            data atual (glb_dtmvtolt) ao invés da data 
                            de criação do plano de poupança programada
                           (Irlan/Lucas)                            
                           
               06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                           
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps147"
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

RUN STORED-PROCEDURE pc_crps147 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps147 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps147.pr_cdcritic WHEN pc_crps147.pr_cdcritic <> ?
       glb_dscritic = pc_crps147.pr_dscritic WHEN pc_crps147.pr_dscritic <> ?
       glb_stprogra = IF pc_crps147.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps147.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

IF glb_cdcritic <> 0   OR
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

/* ....................................................................... */

