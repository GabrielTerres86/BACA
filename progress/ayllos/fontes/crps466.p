/* ..........................................................................

   Programa: Fontes/crps466.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Julho/2006                      Ultima atualizacao: 22/05/2014

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 086.
               Estatistica lancamentos Conta Integracao (relatorio 441) e 
               Relacao Contas Integracao sem Movimentacoes (relatorio 442).
               
   Alteracoes: 10/08/2006 - Alterado o periodo de contas sem movimentacao e 
                            incluidos historicos 21,521,516 (Diego).

               11/09/2006 - Retirada atribuicao para glb_dtmvtolt e efetuado
                            acerto nas datas utilizadas para periodo de 6 meses
                            (Diego). 
                            
               02/01/2008 - Incluidas informacoes no relatorio 442 (Diego).
                             
               15/02/2008 - Incluida linha com total de contas ITG sem
                            movimentacao (Gabriel).
                            
               28/04/2008 - Nao listar contas que possuem cartoes BB(Guilherme).

               30/05/2008 - Incluido qtdade contas c/cartao BB(Mirtes)
                           (Nao comparar qtd.com tela CCARBB, pois este rel.                            
                            lista contas ativas com cartao BB e a tela CCARBB
                            apenas a  quantidade de cartoes.
                            Uma conta pode ter mais de um cartao).
                            
               15/12/2008 - Substituir a tab "ContaConve" pela gnctace (Ze).
               
               29/03/2010 - Incluir historico 444 e 584 para ITG s/ movimento 
                            (Guilherme).
                            
               16/05/2011 - Alterado para que o programa passe a rodar no dia
                            25 de cada mes (Henrique).
                            
               26/05/2011 - Melhorar performance (Magui).             
                            
               21/06/2011 - Ajuste de performance (Gabriel)             
               
               19/09/2011 - Listar contas ITG sem movimentacao nos ultimos 
                            6 meses somente se, a data de abertura da conta
                            ITG for <= 6 meses (Adriano).
                            
               21/03/2012 - Ajuste para listar todas as contas abertas com 
                            data menor a data atual no crrl441(Adriano).
                            
               27/12/2012 - Alteracao para nao imprimir em uma str_2 
                            fechado (Ze).
                            
               13/02/2013 - Verificado se houve reativacao de conta na crapalt
                            para nao desprezar contas erroneamente (Tiago).
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               12/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)                            
                            
               23/12/2013 - Ajuste para a impressao de todos os PAs para o
                            relatorio 441. (Reinert)
                            
               22/05/2014 - Ajuste para inserir o NEW e flgbatch (Ze).
..............................................................................*/

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps466"
       glb_flgbatch = FALSE   
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

RUN STORED-PROCEDURE pc_crps466 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps466 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps466.pr_cdcritic WHEN pc_crps466.pr_cdcritic <> ?
       glb_dscritic = pc_crps466.pr_dscritic WHEN pc_crps466.pr_dscritic <> ?
       glb_stprogra = IF pc_crps466.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps466.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


