/* ..........................................................................

   Programa: Fontes/crps191.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Abril/97.                         Ultima atualizacao: 03/06/2013
   
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 005.
               Gerar avisos de debito em conta e gerar etiquetas de endereca-
               mento Credicard.

   Alteracoes: 28/05/97 - Alterado para nao imprimir etiquetas para a Credito
                          (Deborah).

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               04/12/97 - Tirar IF para imprimir etiquetas para Credito (Odair)
               
               09/09/98 - Tratar novas administradoras (Odair)

               18/09/98 - Gerar etiquetas somente para lancamentos de fatura
                          (Deborah).

               09/08/1999 - Colocar mensagem de impressao no log (Deborah).

               05/01/2000 - Padronizar as mensagens (Deborah).

               22/12/2000 - Imprimir etiquetas nas impressoras a laser 
                            (Eduardo).
                            
               05/08/2002 - Incluir agencia na secao de extrato (Ze Eduardo)
               
               09/02/2004 - Alterada forma de impressao, todas as etiquetas
                            deverao ir para a fila da cecred, inclusao
                            do nome da cooperativa na etiqueta (Julio).

               27/04/2004 - Tratamento para cooperativa 3, nao procurar 
                            crapcrd (Julio).
                            
               18/05/2004 - Inclusao da impressao no log impressao.log (Julio)
               
               28/07/2004 - Referencia da STREAM no comando DOWN (Julio)

               07/04/2005 - Pular uma linha na primeira pagina do crrl149.lst
                            (Evandro).

               29/06/2005 - Alimentado campo cdcooper das tabelas craprej e 
                            crapavs (Diego).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               02/03/2006 - Nao imprimir as etiquetas Cecred Visa (Ze).

               18/04/2006 - Imprimir somente se ha etiquetas geradas (Edson).
               
               26/04/2006 - Desprezar administradoras 83/84/85/86/87/88(BB) 
                            (Mirtes)

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)
               
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               14/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - paulo
                            
               02/06/2011 - incluido no for each a condição - 
                            craplau.dsorigem <> "TAA" (Evandro).
                            
               03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                            craplau. (Fabricio)
                            
               25/07/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               03/06/2013 - incluido no FOR EACH craplau a condicao -
                            craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)
                                                             
............................................................................ */

{ includes/var_batch.i {1} } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps191"
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

RUN STORED-PROCEDURE pc_crps191 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps191 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps191.pr_cdcritic WHEN pc_crps191.pr_cdcritic <> ?
       glb_dscritic = pc_crps191.pr_dscritic WHEN pc_crps191.pr_dscritic <> ?
       glb_stprogra = IF pc_crps191.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps191.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


