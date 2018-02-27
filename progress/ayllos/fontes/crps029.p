
/* ............................................................................
   
   Programa: Fontes/crps029.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/93.                       Ultima atualizacao: 23/02/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Emitir extratos especiais diariamente, relatorio 40,44,73 e 88.
               Atende solicitacao 002.

   Alteracoes: 22/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                          quidacao do emprestimo (Edson).

               05/07/94 - Alterado para nao compor o saldo dos emprestimos nao
                          liquididados com data de contratacao inferior ao dia
                          01/07/94 (Conversao CR$ para R$) - (Edson).

               30/09/94 - Alterado para mostrar a alinea na descricao do histo-
                          rico 47 (Deborah).

               25/10/94 - Alterado para mostrar a alinea na descricao do histo-
                          rico 78 (Odair).

               03/11/94 - Alterado para incluir a comparacao do codigo de his-
                          torico 46 atraves de uma variavel (Odair).

               14/12/94 - Alterado para incluir o relatorio de extrato das
                          aplicacoes RDCA - 88 (Edson).

               02/02/95 - Alterado para reconverter o juros ao capital em
                          moeda fixa (Deborah).

               02/03/95 - Alterado para modificar o layout do extrato de empres-
                          timo, acrescentando o campo txjurepr (Odair).

               29/03/95 - Alterado para na leitura do craplap, desprezar os
                          historicos de provisao (Odair).

               03/08/95 - Alterar o layout do extrato para imposto de renda.
                          (Odair).

               14/08/95 - Alteracao total. A partir de hoje passara parametros
                          para os programas que gerarao os devidos extratos
                          especiais (Edson).

               28/03/96 - Alterado para tratar inisenta e insitext (Edson).

               23/02/99 - Incluir tipo 5 Poupanca Programada (Odair)

               19/07/99 - Alterado para chamar a rotina de impressao (Edson).

               25/01/2000 - Chamar a rotina de impressao (Deborah).

               16/03/2000 - Tratar tpextrat = 6 - IR juridicas mensal
                            (Deborah).

               24/04/2002 - Tratar impressao dos cheques depositados (Edson).

               04/11/2003 - Substituido comando RETURN pelo QUIT(Mirtes).

               07/10/2004 - Efetuar impressao CI - Relatorio 370 (Mirtes).
               
               31/08/2005 - Passado parametro crapext.dtreffim para tipo
                            de extrato 1 (Diego).

               14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               24/07/2008 - Incluido os parametros "crapext.dtrefere" e
                            "crapext.dtreffim" na chamada do programa
                            fontes/impextppr.p (Elton).
        
               16/01/2009 - Chamar programa de tarifas (Gabriel).  
               
               01/10/2009 - Tratamento para listar depositos identificados
                            no extrato de conta corrente (David).
                            
               09/02/2012 - Utilizar BO b1wgen0112.p (David).
               
               28/06/2013 - Retirar o USE-INDEX da crapext (Evandro).
                                       
               17/09/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                             procedure (Alisson - AMcom)
                             
               01/09/2017 - Inclusao de log de fim de execucao do programa 
                            (Carlos)
             
               01/09/2017 - Projeto ligeirinho, paralelismo.
                            (Fernando Miranda - Amcom)             
             
............................................................................ */

{ includes/var_batch.i "NEW"} 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps029"
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

RUN STORED-PROCEDURE pc_crps029 aux_handproc = PROC-HANDLE NO-ERROR
   (INPUT glb_cdcooper,
    INPUT  0,
    INPUT  0,
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

CLOSE STORED-PROCEDURE pc_crps029 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps029.pr_cdcritic WHEN pc_crps029.pr_cdcritic <> ?
       glb_dscritic = pc_crps029.pr_dscritic WHEN pc_crps029.pr_dscritic <> ?
       glb_stprogra = IF pc_crps029.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps029.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS029.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 0,
    input "",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

RUN fontes/fimprg.p.

/* .......................................................................... */
