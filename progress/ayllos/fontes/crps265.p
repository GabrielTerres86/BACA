/* ..........................................................................

   Programa: Fontes/crps265.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Maio/99.                            Ultima atualizacao: 01/09/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Emitir boletim de caixa (cash dispenser) (214).
               Atende solicitacao 2. 

   Alteracoes: 19/07/99 - Alterado para chamar a rotina de impressao (Edson).

               25/01/2000 - Alterado p/chamar a rotina de impressao (Deborah).

               10/04/2001 - Alterado para listar os saldos dos caixas (Edson).

               03/06/2002 - Incluir numeros de lacres (Margarete).

               10/07/2002 - Acerto na leitura do crapbcx (Deborah).

               26/09/2002 - Alterado para nao imprimir boletim com situacao de
                            cash igual a 5 - INATIVO (Edson).
               
               06/11/2002 - Alterado para nao listar os caixas com saldo zerado
                            ha mais de 10 dias (Edson).

               04/06/2004 - Incluir subtotal por caixas no PAC (Margarete).
               
               29/09/2004 - Gravacao de dados na tabela gnsldcx do banco
                            generico, para relatorios gerenciais (Junior).
                            
               14/12/2004 - Acerto no indice da tabela gnsldcx, para gravacao
                            dos dados dos caixas eletronicos (Junior).
                            
               01/03/2005 - Imprimir tambem o relatorio 411 (Evandro).

               09/03/2005 - Ajustes no laytou do relatorio 411 (Edson).
               
               24/05/2005 - Gerar relatorio 386 (Evandro).
               
               03/06/2005 - Imprimir resumo geral no relatorio 386 (Evandro).
               
               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               03/10/2005 - Alterado para imprimir apenas 1 copia do relatorio
                            411 para  CredCrea (Diego).
                            
               30/01/2006 - Imprimir uma unica via para CREDIFIESC (Evandro).
               
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               03/04/2006 - Corrigir rotina de impressao de relatorios por 
                            agencia (Junior).

               17/05/2006 - Alterado numero de vias do relatorio crrl411
                            para Viacredi (Diego).

               17/07/2006 - Inicializar variaveis rel_qttot7.. e rel_vltot7..
                            para crrl386 (David).
                            
               18/12/2006 - Somente listar PAC's ativos (Elton).
               
               06/02/2007 - Colocar sinal no campo de saldo final (Edson).
               
               19/10/2007 - Incluido campo Situacao do Cash (Gabriel).
               
               22/04/2008 - Alterar para novo sistema de CASH - FOTON (Ze).
               
               09/06/2008 - Incluído o mecanismo de pesquisa no "find" na 
                            tabela CRAPHIS para buscar primeiro pela chave de
                            acesso (craphis.cdcooper = glb_cdcooper) e após 
                            pelo código do histórico "craphis.cdhistor". 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
              
               01/07/2008 - Ajustados os "finds" que utilizam as tabelas
                            genericas "GN" para que efetue a busca pela
                            variavel "glb_cdcooper".
                            - Kbase IT Solutions - Paulo Ricardo Maciel.

               07/11/2008 - Troca do Histor. 359 p/ 767 (Estorno Debito) (Ze).
               
               11/05/2009 - Alteracao CDOPERAD (Kbase).

               09/09/2009 - Verificar se operador registrado no log esta 
                            cadastrado na crapope - NOT AVAIL - (David).
                            
               02/10/2009 - Aumento do campo nrterfin (Diego).
               
               11/06/2010 - Tratamento para o sistema TAA e para nao
                            mostrar PAC 90 e 91 (Evandro).
                            
               24/08/2010 - Ajuste na verificacao do saldo, nao tratar valor
                            rejeitado separadamente do recolhimento (Evandro).
                            
               28/10/2010 - Inclusão dos históricos 918(Saque) e 920(Estorno)
                            devido ao TAA compartilhado (Henrique). 
                            
               16/12/2010 - Zerar as variaveis de saque e estorno do TAA
                            compartilhado (Evandro).
                            
               28/12/2010 - Na verificacao dos saques e estornos, utilizar a
                            cooperativa do terminal (cdcoptfn) (Evandro).
                            
               28/02/2011 - Tratamento para contabilizar o saldo de TAAs que
                            nao tem movimentacao no dia, para fechar com o
                            saldo contabil (Evandro).
                            
               13/06/2012 - Eliminar EXTENT vldmovto (Evandro).
                
               25/07/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                            
               01/09/2017 - Inclusao de log de fim de execucao do programa 
                            (Carlos)

............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps265"
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

RUN STORED-PROCEDURE pc_crps265 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INT(STRING(glb_flgresta,"1/0")),                                           OUTPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps265 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps265.pr_cdcritic WHEN pc_crps265.pr_cdcritic <> ?
       glb_dscritic = pc_crps265.pr_dscritic WHEN pc_crps265.pr_dscritic <> ?
       glb_stprogra = IF pc_crps265.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps265.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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
    INPUT "CRPS265.P",
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

/*............................................................................*/