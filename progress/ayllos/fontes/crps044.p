/* .............................................................................

   Programa: Fontes/crps044.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/92.                    Ultima atualizacao: 06/09/2013

   Dados referentes ao programa:

   Frequencia: Anual (Batch)
   Objetivo  : Calculo anual dos juros sobre capital.
               Atende a solicitacao 026. Emite relatorio 39.

   Alteracoes: 27/03/95 - Alterado para alimentar o campo craplct.qtlanmfx com
                          o campo tot_vljurmfx (Edson).

               28/06/95 - Alterado para calculo no mes de junho/95 (Edson).

               26/09/95 - Alterado para calculo no mes de setembro/95 (Edson).

               18/12/95 - Alterado para calculo no mes de dezembro/95 (Edson).

               28/03/96 - Alterado para calculo no mes de marco/96 (Edson).

               24/06/96 - Alterado para calculo no mes de junho/96 (Edson).

               12/07/96 - Alterado para nao calcular juros para contas trans-
                          feridas (Odair).

               01/08/97 - Alterado para utilizar 6 casas decimal na taxa de
                          calculo dos juros (Edson).

               09/11/98 - Tratar situacao em prejuizo (Deborah).
               
               14/03/2000 - Tratar taxas diferenciadas para cada mes (Edson).
               
               30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               26/12/2000 - Identificar se semestral ou anual e acrescentar
                            campos de controle na tabela (Deborah). 
                            
               05/01/2001 - Alterar o nome dos formularios de impressao para
                            132dm. (Eduardo).

               27/07/2001 - Ignorar os campos de controle na tabela (Edson).

               16/12/2002 - Alterado para efetuar o calculo anual dos juros
                            sobre o capital e armazena-lo na tabela crapjsc
                            (Edson).

               28/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplct e crapjsc (Diego).
               
               16/01/2006 - Criar o registro no crapjsc com data do ULTIMO dia
                            do ano - 31/12/...  (Edson).

               14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               30/01/2008 - Alteracao LABEL de JUROS para ATUALIZACAO
                            (Guilherme).

               14/05/2010 - Quando crapcot.vlcapmes negativo assumir zeros
                            no calculo e dar mensagem no log (Magui).
                            
              30/11/2010 - 001 / Alterado Format "x(40)" para Format "x(50)" (Danielle/Kbase)

              21/12/2010 - Incluido campo Saldo Medio Capital. 
                         - Incluidos totais de saldo medio, cooperados com 
                           movimentacao e demitidos (Henrique).
                           
              19/01/2011 - Alteracao do layout do relatorio. Agrupar por PAC
                           e dividir os cooperados em 3 grupos. (Henrique)
                           
              28/02/2011 - Alteracao nos totais e na exibicao dos cooperados
                           (Henrique).
                           
              03/04/2012 - Ajuste nas 2 ultimas alteracoes (David).
              
              06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                           
............................................................................. */

{ includes/var_batch.i {1} }  
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps044"
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

RUN STORED-PROCEDURE pc_crps044 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps044 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps044.pr_cdcritic WHEN pc_crps044.pr_cdcritic <> ?
       glb_dscritic = pc_crps044.pr_dscritic WHEN pc_crps044.pr_dscritic <> ?
       glb_stprogra = IF pc_crps044.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps044.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


