/* ..........................................................................

   Programa: Fontes/crps140.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/95                      Ultima atualizacao: 01/09/2017
                                                                          
   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 004.
               Emite relatorio 117 com os maiores aplicadores.
               Esse relatorio deve rodar sempre depois do mensal
               das aplicacoes e da poupanca programada.

   Alteracoes: 01/12/95 - Acerto no numero de vias (Deborah).

               11/04/96 - Incluir procedimentos poupanca programada (Odair).

               26/11/96 - Tratar RDCAII (Odair).

               26/12/97 - Alterado para calcular RDCA ate o dia do movimento
                          (Deborah).

               27/08/1999 - Tratar circular 2852 (Deborah).

               10/02/2000 - Gerar pedido de impressao (Deborah).

               01/04/2004 - Alteracao no FORMAT do numero sequencial (Julio)
               
               22/11/2004 - Gerar tambem relatorio com TODOS os aplicadores
                            (rl/crrl117_99.lst) (Evandro).

               06/12/2005 - Gerar relatorio dos 100 maiores aplicadores sem 
                            quebras de paginas (crrl117.txt) e com envio
                            de email (Diego).

               03/02/2006 - Modificado nome relatorio(str_4), e alterado
                            para listar TODOS APLICADORES (Diego).
                            
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               08/11/2006 - Incluido PAC do associado no relatorio (Elton).
                                 
               30/11/2006 - Melhoria de performance (Evandro).

               10/04/2007 - Gerar arquivo com totais das operacoes por CPF
                            (David).
                            
               30/05/2007 - Incluir USE-INDEX para melhorar a performace
                            (Ze/Evandro).
                            
               13/07/2007 - Retirado envio de email. Alterado nome do arquivo
                            que e salvo na pasta 'rl/' crrl117 e sua extensao
                            para .lst (Guilherme).

               23/08/2007 - Incluir valores de aplicacoes RDC (David).
               
               29/10/2007 - Acerto nos valores de aplicacoes RDC (ZE).

               26/11/2007 - Substituir chamada da include aplicacao.i pela
                            BO b1wgen0004.i. (Sidnei - Precise).
                            
               03/04/2008 - Alterado mascara do FORM do relatorio de aplicadores
                            por CPF para mostrar numeros negativos; 
                          - Lista somente aplicadores com saldo das aplicacoes
                            maiores do que zero "0" nos relatorios (Elton).
               
               28/04/2008 - Acertado para que relatorio de aplicadores por CPF
                            gere saldo das aplicacoes do ultimo dia util do mes
                            anterior (Elton).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).
                                                               
               06/01/2010 - Relatorio não irá mais listar os 100 maiores, e sim
                            os cooperados cujo valor das aplicacoes seja maior 
                            que o parametrizado na TAB007 (Fernando). 
               
               11/01/2011 - Definido o format "x(40)" nmprimtl (Kbase - Gilnei).
               
               21/01/2011 - Ajuste no layout de impressao devido a alteracao 
                            do format da variavel aux_qtregist (Henrique).

               01/06/2011 - Estanciado a b1wgen0004 ao inicio do programa e 
                            deletado ao final para ganho de performance
                            (Adriano).
                            
               09/01/2012 - Melhorar desempenho (Gabriel).
               
               28/08/2012 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            (Diego). 

               22/07/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
               
               01/09/2017 - Inclusao de log de fim de execucao do programa 
                            (Carlos)
               
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps140"
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

RUN STORED-PROCEDURE pc_crps140 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps140 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps140.pr_cdcritic WHEN pc_crps140.pr_cdcritic <> ?
       glb_dscritic = pc_crps140.pr_dscritic WHEN pc_crps140.pr_dscritic <> ?
       glb_stprogra = IF pc_crps140.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps140.pr_infimsol = 1 THEN TRUE ELSE FALSE. 
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
    INPUT "CRPS140.P",
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