/*..........................................................................

   Programa: Fontes/crps109.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Janeiro/95.                     Ultima atualizacao: 24/07/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 1, ordem 91.
               Emite listagem das aplicacoes RDCA por agencia.

   Observacao: Para que haja o pedido de impressao do relatorio para a agencia
               devera existir a seguinte tabela CRED-GENERI-0-IMPREL089-agencia
               onde o texto da tabela informa os dias que deve ser impresso o
               relatorio.

   Alteracoes: 15/02/95 - Alterado para acumular o saldo e a quantidade das
                          aplicacoes na tabela CRED-GENERI-00-DESPESAMES-001
                          e atender a solicitacao 2 (Edson).

               29/05/95 - Alterado para  nao atualizar a solicitacao como pro-
                          cessada (Odair).

               17/07/95 - Incluido os totais para as aplicacoes com saldo nega-
                          tivo no total geral (Edson).

               04/12/95 - Alterado para imprimir 1 copia nos dias normais e
                          2 copias no mensal (Odair).

               19/03/96 - Alterado para imprimir por agencia selecionada
                          (Edson).

               09/07/96 - Alterado para imprimir tambem agencia 3 (Deborah).

               17/09/96 - Alterado para criar tabela para impressao dos
                          relatorios por agencia (Odair).

               22/11/96 - Tratar RDCAII (Odair).

               22/08/97 - Tirar linha entre as aplicacoes (Odair)

               18/02/98 - Apresentar totais por faixa RDCA60 (Odair)

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/12/1999 - Alterado para nao imprimir se nao houver aplica-
                            coes (Deborah). 

               26/01/2000 - Gerar pedido de impressao (Deborah).

               03/10/2003 - Eliminada tabela de DESPESA (Deborah).

               17/10/2003 - Tratamento para calculo do VAR (Margarete).

               22/06/2004 - Incluidos os campos: RESGATES DO MES e TOTAL DE
                            RESGATES (Evandro).

               22/09/2004 - Incluidos historicos 492/494(CI)(Mirtes)

               03/02/2005 - Incluido log para listar aplicacoes com saldo
                            negativo(Mirtes)

               29/06/2005 - Alimentado campo cdcooper das tabelas crapvar e
                            craptab (Diego).
                            
               06/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                            "fontes/iniprg.p" por causa da "glb_cdcooper"
                            (Evandro).
                            
               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               31/03/2006 - Corrigir rotina de impressao do relatorio 89
                            (Junior).
               
               30/11/2006 - Melhoria de performance (Evandro).

               09/10/2007 - Mudar solicitacao de 86 para 1. Ordem de 9 para 91
                            Retira o new e o flgbatch (Magui).

               03/12/2007 - Substituir chamada da include aplicacao.i pela
                            BO b1wgen0004.i. (Sidnei - Precise).
       
               26/11/2010 - Retirar da sol 1 ordem 91 e colocar na sol 82                                   ordem 80.E na CECRED sol 82 ordem 83 (Magui).
                            
               24/07/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                            
............................................................................. */
/*  Decisoes sobre o VAR **************************************************
**
Rdca30 = carencia depois diario (usar taxa provisoria senao houver oficial)
         quando dtdpagto = glb_dtmvtopr nao ha juros ja esta imbutido no saldo
Rdca60 = carencia depois mensal (usar taxa provisoria senao houver oficial)
*****************************************************************************/

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps109"
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

RUN STORED-PROCEDURE pc_crps109 aux_handproc = PROC-HANDLE
   (INPUT  glb_cdcooper,
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

CLOSE STORED-PROCEDURE pc_crps109 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps109.pr_cdcritic WHEN pc_crps109.pr_cdcritic <> ?
       glb_dscritic = pc_crps109.pr_dscritic WHEN pc_crps109.pr_dscritic <> ?
       glb_stprogra = IF pc_crps109.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps109.pr_infimsol = 1 THEN TRUE ELSE FALSE. 
       
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
