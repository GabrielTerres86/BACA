/* ..........................................................................

   Programa: Fontes/crps006.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/91.                      Ultima atualizacao: 10/10/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 005.
               Listar o resumo dos lotes digitados no dia (11) e resumo dos
               pedidos de talonarios em atraso (80).

   Alteracoes: 20/06/94 - Alterado para gerar o resumo dos pedidos de talonarios
                          em atraso (Edson).

               30/11/94 - Alterado para tratar os tipos de lote 10 e 11
                          (Deborah).

               24/01/95 - Alterado o resumo do RDCA onde o total dos valores
                          aplicados passou a ser o saldo ate o ultimo movimento
                          (Deborah).

               29/05/95 - Alterado para nao listar o resumo dos lotes da Consu-
                          mo (Deborah).

               19/06/95 - Alterado para tratar os lotes tipo 12 de debito em
                          conta (Odair).

               29/03/96 - Alterado para tratar tipo de lote 14 (Odair).

               09/04/96 - Alterado para listar a quantidade e o total das
                          aplicacoes de poupanca programada (Odair).

               19/08/96 - Alterado para listar a quantidade e o total da
                          arrecadacao da TELESC (Edson).

               25/10/96 - Alterado para diminuir tamanho do codigo .r (Odair).

               03/12/96 - Alterado para tratar RDCA2 (Odair).

               20/12/96 - Alterado para tratar SEGURO (Edson).

               03/02/97 - Pegar resumos da poupanca programada da tabela
                          despesames tpregist = 2 (Odair).

               04/02/97 - Desmembrar para crps006_1.p devido ao
                          codigo do programa exceder 63K (Odair)

               09/04/97 - Alterado para gerar o pedido do resumo em 2 vias
                          (Deborah).

               16/04/97 - Alterado para tratar lotes tipo 16 e 17 (Odair)

               26/05/98 - Tratar milenio e V8 (Odair)

               12/06/98 - Listar pedidos de talonarios com 4 dias uteis de
                          atraso (Edson).

               18/09/98 - Alteracao no layout do relatorio (resumo de 
                          arrecadacao, propostas e debitos de cartao) (Deborah)
                          
               17/02/99 - Mostrar memoria contabil (Odair)           

               18/02/99 - Nao tratar os lotes tipo 89 e 90 (Edson).
               
               02/07/99 - Nao tratar pedidos roubados (Odair).

               04/01/2000 - Nao gerar pedidos de impressao (Deborah).

               11/02/2000 - Gerar pedidos de impressao (Deborah).

               30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner)

               10/05/2001 - Nao tratar os lotes tipo 23 (Edson).

               13/05/2002 - Aumentar a tabela de historicos para 999
                            ocorrencias (Deborah).

               13/06/2003 - Nao tratar os tipos de lote 26 e 27 (Edson).

               03/10/2003 - Eliminado resumos finais, nao roda mais 
                            fontes/crps006_1.p (Deborah).
               
               16/02/2004 - Desprezar tipo de lote 24(DOC) e 25(TED)(Mirtes).

               04/10/2004 - Tratar Tipo de Lote 29(CI)(Mirtes)

               22/11/2004 - Tratar Tipo de Lote 28(Corresp.Bancario)(Mirtes)

               18/04/2005 - Gerar arquivos por pac (Edson).

               14/07/2005 - Tratar Tipo de Lote 30(GPS)(Mirtes) 
                           
               03/10/2005 - Alterado para imprimir apenas uma copia do 
                            relatorio 11 para CredCrea (Diego).
               
               11/11/2005 - Tratar Historico 459(Recebto INSS) (Mirtes)
               
               30/01/2006 - Imprimir uma unica via para CREDIFIESC (Evandro).
               
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               31/03/2006 - Corrigir rotina de impressao do relatorio crrl011
                            (Junior).
                            
               08/05/2006 - Disponibilizada impressao relatorio crrl011_99.lst
                            (Diego).
                            
               26/05/2006 - Alterado para fimprimir apenas uma copia do 
                            relatorio 11 para Viacredi (Elton).
                            
               15/08/2006 - Incluido indice para leitura da tabela craplap e 
                            craplcm (Diego).
                            
               14/12/2006 - Prever lote tipo 32 (Evandro).

               21/08/2007 - Tratar lote tipo 9 (Aplicacoes RDC) (David).
               
               13/11/2007 - Tratar lote tipo 33 (Evandro).
               
               31/03/2008 - Tratar GPS-BANCOOB (Evandro).

               20/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                            
               03/10/2008 - Alterado para desconsiderar lotes : borderos de 
                            desconto de titulos e limite de desconto de 
                            titulo (Gabriel).

               15/01/2009 - Evitar estouro de campo Credito e Debito (Gabriel). 
                          - Incluir coluna Tipo no rel 080 (Gabriel).
                          
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               22/01/2010 - Alterar FORMAT do campo rel_qtdiaatr (David).
               
               28/02/2012 - Nao abortar programa quando critica 62 (Diego).
               
               03/04/2012 - Ajuste no estouro de campo no f_lotes (Ze).

               10/10/2013 - Chamada Stored Procedure do Oracle 
                            (Andre Euzebio / Supero)
............................................................................. */
{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps006"
       glb_flgbatch = FALSE
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

RUN STORED-PROCEDURE pc_crps006 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT glb_nrfolhas,
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

CLOSE STORED-PROCEDURE pc_crps006 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_stprogra = FALSE
       glb_infimsol = FALSE
       glb_cdcritic = pc_crps006.pr_cdcritic WHEN pc_crps006.pr_cdcritic <> ?
       glb_dscritic = pc_crps006.pr_dscritic WHEN pc_crps006.pr_dscritic <> ?
       glb_stprogra = IF pc_crps006.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps006.pr_infimsol = 1 THEN TRUE ELSE FALSE.
                         

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

