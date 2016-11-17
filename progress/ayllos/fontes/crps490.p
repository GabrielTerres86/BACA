/*..............................................................................

   Programa: fontes/crps490.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Julho/2007                      Ultima atualizacao: 12/11/2013

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Solicitacao: 002.
               Listar todas as aplicacoes RDCPRE e RDCPOS com vencimento
               para daqui a 5 dias uteis
               Ordem da solicitacao: 44 
               Relatorio 458

   Alteracoes: 02/08/2007 - Separar relatorio 458 por PAC (David).

               05/11/2007 - Classificacao agencia da aplicacao com erro (Magui)
               
               11/03/2008 - Melhorar leitura do craplap para taxas (Magui).
               
               06/05/2008 - Incluida data que foi feita a aplicacao (Evandro).
               
               26/11/2010 - Retirar da sol 2 ordem 44 e colocar na sol 82
                            ordem 81.E na CECRED sol 82 e ordem 84 (Magui). 
                            
               07/12/2010 - Alterado p/ listar as aplicações com base no PAC 
                            do cooperado (Vitor).
                            
               01/06/2011 - Estanciado a b1wgen0004 para o inicio do programa
                            e deletado ao final para ganho de performance
                            (Adriano).
                            
               16/09/2013 - Tratamento para Imunidade Tributaria (Ze).
               
               27/09/2013 - Alterada atribuicao da variavel aux_nrramfon
                            para receber somente o telefone da tabela craptfc 
                            e alteradas strings de PAC para PA. (Reinert)
                            
               12/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)
                                                        
               31/01/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                                         
..............................................................................*/

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps490"
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

RUN STORED-PROCEDURE pc_crps490 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps490 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps490.pr_cdcritic WHEN pc_crps490.pr_cdcritic <> ?
       glb_dscritic = pc_crps490.pr_dscritic WHEN pc_crps490.pr_dscritic <> ?
       glb_stprogra = IF pc_crps490.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps490.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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
