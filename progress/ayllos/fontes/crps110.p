/* ..........................................................................

   Programa: Fontes/crps110.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Janeiro/95                      Ultima Alteracao: 18/01/2018

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 058.
               Emite o resumo dos saldos das aplicacoes RDCA por dia de aniver-
               sario e por agencia.

   Alteracoes: 06/12/95 - Alterado para modificar a logica do programa,ele dei-
                          xou de trabalhar com workfile e trabalha com arquivo
                          convencional classificado pelo sort (Odair).

               25/11/96 - Tratar RDCAII (Odair).

               29/12/1999 - Nao gerar relatorio se nao ha aplicacoes
                            (Deborah).

               12/01/2000 - Nao gerar pedido de impressao (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah). 

               20/01/2003 - Quebra de pagina por Pac e 2 vias (Deborah).
               
               06/09/2004 - Criar um relatorio por Agencia (Ze Eduardo).
               
               13/10/2004 - NAO marcar a solicitacao como atendida (Evandro).
               
               18/01/2005 - Incluida coluna "ORDEM" no relatorio (Evandro).
               
               01/08/2005 - Colocar numero da agencia no resumo
                            geral (Margarete).                      
                            
               06/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                            "fontes/iniprg.p" por causa da "glb_cdcooper"
                            (Evandro).
                            
               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               22/05/2006 - Alterado numero de vias do relatorio para 
                            Viacredi (Diego).
               
               22/06/2007 - Somente lista aplicacoes RDCA30 e RDCA60 (Elton).

               30/07/2007 - Tratamento para aplicacoes RDC (David).
               
               14/08/2007 - Acerto na dtiniper e dtfimper (Magui).

               26/11/2007 - Substituir chamada da include aplicacao.i pela
                            BO b1wgen0004.i e rdca2s pela b1wgen0004a.i
                            (Sidnei - Precise).

               06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)

			   18/01/2018 - Inclusao de parametros para tratamento de paralelismo.
			                Projeto Ligeirinho. (Fabrício)
                            
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps110"
       glb_flgbatch = FALSE
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

RUN STORED-PROCEDURE pc_crps110 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT INT(STRING(glb_flgresta,"1/0")),
	INPUT 0,
	INPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps110 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps110.pr_cdcritic WHEN pc_crps110.pr_cdcritic <> ?
       glb_dscritic = pc_crps110.pr_dscritic WHEN pc_crps110.pr_dscritic <> ?
       glb_stprogra = IF pc_crps110.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps110.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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
