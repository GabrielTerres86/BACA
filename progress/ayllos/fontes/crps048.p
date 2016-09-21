/* .............................................................................

   Programa: Fontes/crps048.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/93.                         Ultima atualizacao: 29/04/2008

   Dados referentes ao programa:

   Frequencia: Anual (Batch)
   Objetivo  : Calculo e credito do retorno de sobras e juros sobre o capital.
               Atende a solicitacao 030. Emite relatorio 43.

   /* ATENCAO: ESSE PROGRAMA SOMENTE CREDITA RETORNO SOBRE JUROS AO CAPITAL E
      ======== SOBRE RENDIMENTOS DE APLICACOES SE FOI PEDIDO CREDITO DE RETORNO
               SOBRE JUROS PAGOS */

[B   Alteracoes: 05/07/94 - Retirado o literal "em cruzeiros".

               09/09/94 - Alterado valor da moeda para 8 casas decimais
                          (Deborah).

               20/02/95 - Alterado para tratar inpessoa 3 (Deborah).

               14/03/95 - Alterado para ignorar a incorporacao da correcao
                          monetaria a incorporar (Edson).

               06/01/97 - Alterado para creditar o retorno sobre o capital
                          que esta guardado no campo crapcot.qtrsjmfx (Edson).

               23/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               30/10/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               06/03/2001 - Incluido tratamento para creditar retorno nos juros
                            ao capital. Acrescentado % na tabela (Deborah).

               10/04/2001 - Nao calcular para contas com dtelimin (Deborah).

               04/02/2003 - Alterado para acessar o crapjsc (juros sobre o
                            capital) - Edson
                            
               28/01/2004 - Alterado para calcular juros para PESSOA FISICA e
                            JURIDICA (Edson).
                            
               25/02/2005 - Tratar novos parametros (Edson).

               28/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            e craplct (Diego).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               23/02/2006 - Prever sinal no indice de retorno
                            sobre juros ao capital(Mirtes)
                            
               30/01/2008 - Alteracao do LABEL JUROS para ATUALIZACAO
                            (Guilherme).

               22/02/2008 - Tratamento para contas demitidas (David).
               
               13/03/2008 - Corrigida a limpeza da craptab (Evandro).
               
               29/04/2008 - criacao da include crps048.i com a logica deste 
                            programa para possibilitar chamada on-line
                            atraves do programa crps510.p (Sidnei - Precise)
                            
............................................................................. */


DEF STREAM str_1.  /*  Para relatorio dos juros calculados  */
DEF STREAM str_3.  /*  Para entrada/saida de incorporacao/retorno  */
DEF STREAM str_4.  /*  Para demonstrativo detalhado  */

/* O STREAM STR_2 EH UTILIZADO NO SUB-PROGRAMA CRPS048_2.P  */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdcritic = 0
       glb_dscritic = "".
 
glb_cdprogra = "crps048".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0   THEN
    RETURN.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_emite_retorno_sobras aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT glb_cdprogra,
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

CLOSE STORED-PROCEDURE pc_emite_retorno_sobras WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_emite_retorno_sobras.pr_cdcritic WHEN pc_emite_retorno_sobras.pr_cdcritic <> ?
       glb_dscritic = pc_emite_retorno_sobras.pr_dscritic WHEN pc_emite_retorno_sobras.pr_dscritic <> ?.


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




