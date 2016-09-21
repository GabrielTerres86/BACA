/* ..........................................................................

   Programa: Fontes/crps124.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/95.                       Ultima atualizacao: 12/09/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 040.
               Emitir relatorio dos debitos em conta (102).

   Alteracao : Na leitura do craplau desprezar historicos 21 e 26 (Odair)

               27/04/98 - Tratamento para milenio e troca para V8 (Magui).

               20/04/1999 - Listar por PAC (Deborah).

               17/05/1999 - Tratar somente debitos da matriz via caixa.
                            Os demais debitos serao listados no crps261.
                            (Deborah).

               21/07/99 - Nao enfileirar no MTSPOOL (Odair)

               02/02/2000 - Gerar pedido de impressao (Deborah).

               01/11/2000 - Alterar nrdolote p/6 posicoes (Magui/Planner).
               
               13/09/2001 - Calcular o saldo e mostrar no relatorio se
                            associado esta com o saldo negativo (Junior).
                            
               01/04/2002 - Alterar a classificacao do relatorio (Junior).

               15/07/2003 - Inserido o codigo para verificar, apartir do tipo de
                            registro do cadastro de tabelas, com qual numero de
                            conta que se esta trabalhando. O numero sera 
                            armazenado na variavel aux_lsconta3 (Julio).
 
               08/01/2004 - Alterado para NAO tratar os historicos 521 e 526
                            (Edson).
                            
               25/01/2005 - Estouro de Campo nrdocmto (Ze Eduardo).   
                         
               09/12/2005 - Cheque salario nao existe mais (Magui).
                         
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)
               
               20/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
               
               27/02/2009 - Gerar relatorio 102 em 132col (Gabriel).

               22/04/2009 - Gerar cabecalho do relatorio mesmo que nao haja
                            movimentos (Fernando).
               
               24/04/2009 - Gerar o relatorio 102 por PAC e tambem gerar
                            o consolidado crrl102_99 (Fernando).
                           
               14/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - paulo
                            
               19/10/2009 - Alteracao Codigo Historico (Kbase).  
               
               09/02/2011 - Incluido novo calculo e nova observação "Esse pagto 
                            gera saldo negativo" no relatório e ajuste no tamanho 
                            do campo craplau.nrdocmto no frame f_debitos (Vitor).
                            
               25/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano).             
                            
               29/04/2011 - Ajuste na ver_saldo para nao contabilizar o 
                            lancamento do debito novamente (Gabriel)
                            
               02/06/2011 - incluido no for each a condição - 
                            craplau.dsorigem <> "TAA" (Evandro).
                            
               30/09/2011 - incluido no for each a condigco -
                            craplau.dsorigem <> "CARTAOBB" (Ze).
            
               15/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)
               
               12/09/2013 - Conversao oracle, chamada da stored procedure
                            (Andre Euzebio / Supero).
              
.............................................................................*/
{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps124"
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

RUN STORED-PROCEDURE pc_crps124 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INT(STRING(glb_flgresta,"1/0")),                                          OUTPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps124 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps124.pr_cdcritic WHEN pc_crps124.pr_cdcritic <> ?
       glb_dscritic = pc_crps124.pr_dscritic WHEN pc_crps124.pr_dscritic <> ?
       glb_stprogra = IF pc_crps124.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps124.pr_infimsol = 1 THEN TRUE ELSE FALSE. 
       
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


