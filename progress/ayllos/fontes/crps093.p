/* .............................................................................

   Programa: Fontes/crps093.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/94.                          Ultima atualizacao: 28/03/2013

   Dados referentes ao programa:

   Frequencia: Mensal (Batch)
   Objetivo  : Geracao dos lancamentos de baixa de capital e saldo dos demi-
               tidos. Atende a solicitacao 052.

   Alteracoes: 08/12/94 - Alterado para nao permitir a baixa se o associado ti-
                          ver algum registro em craprda (aplicacoes finaceiras
                          RDCA) (Deborah).

               14/03/95 - Alterado para executar somente nos finais de tri-
                          mestre (Edson).

               05/07/95 - Alterado para analisar os avisos e os debitos em
                          conta (Odair).

               24/11/95 - Acerto na atualizacao dos saldos medios (Deborah).

               21/03/96 - Alterado para analisar poupanca programada (Odair).

               21/08/96 - Alterado nao baixar se o associado tiver cartao
                          Credicard (Edson).

               17/04/97 - Alterado para analisar cartao de credito (Odair).

               09/07/97 - Atualizar crapsld.vlsdanes (Odair)

               25/09/97 - Alterado para nao executar ate segunda ordem (Edson).

               02/01/98 - Alterado para executar apenas nos meses de JUNHO e
                          DEZEMBRO (Edson).

               29/07/98 - Como o vlipmfap podera ser < 0, alterado para tratar 
                          por diferente de 0. (Deborah)
                          
               09/11/98 - Nao eliminar se a situacao estiver com prejuizo
                          (Deborah).

               19/11/98 - Nao eliminar se houver valores em crapcot.qtrsjmfx
                          (Deborah).

             11/12/2000 - Alterar o programa para incluir alguns criterios
                          de selecao. (Eduardo)

             18/12/2000 - Liberado para rodar (Deborah).

             10/04/2001 - Acerto para baixar o retorno creditado para 
                          contas que ja estavam com dtelimin (Deborah). 
                          
             28/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                          craplcm e craplct (Diego).

             14/07/2005 - Ajuste no saldo medio e saldo diario (Edson).
             
             14/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
             
             19/10/2005 - Solicitado para comentar o campo vldoipmf (SQLWorks).
             
             10/11/2005 - Incluido o tpcheque no uso da crapfdc (Evandro).
             
             14/12/2005 - Alimentar o crapfdc.dtliqchq no cancelamento do
                          cheque (Edson).

             15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
             
             12/08/2010 - Alteração na verificação de operacoes pendentes 
                          do crapass (Vitor).
                          
             20/01/2011 - Alteração no consulta de lancamentos automaticos
                          e consulta de cartoes de credito (Irlan)
                          
             02/03/2011 - Inclusão da opcão crawcrd.insitcrd = 6 para não
                          considerar os registros encerrados
                          (Isara - RKAM)
                          
             02/08/2011 - Nao sera permitido eliminar um associado quando este,
                          tiver algum tipo de limite ativo (Adriano).        
                          
             19/10/2011 - Tratamento melhorias seguro (Diego).                  
                          
             27/09/2012 - Removido tratamento para o campo vllimcrd 
                          do for each crapass (Lucas R).
                          
             28/03/2013 - Ajustes referentes ao Projeto Tarifas Fase 2
                          Grupo de cheque (Lucas R.).
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps093"
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

RUN STORED-PROCEDURE pc_crps093 aux_handproc = PROC-HANDLE
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
    RETURN.
END.

CLOSE STORED-PROCEDURE pc_crps093 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps093.pr_cdcritic WHEN pc_crps093.pr_cdcritic <> ?
       glb_dscritic = pc_crps093.pr_dscritic WHEN pc_crps093.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps093.pr_stprogra = 1 THEN 
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps093.pr_infimsol = 1 THEN 
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

