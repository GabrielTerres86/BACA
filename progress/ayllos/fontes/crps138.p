/*** DEFINICAO DE COMO E COMPOSTO O CAMPOS CONTAS
O campo "Contas" e a somatoria de todas as contas ativas, sem data de demissao abertas ate a data de referencia do relatorio e que nao sejam contas do tipo 5(cheque salario), 6(aplicacao simples),7(aplicacao conjunta), 17(aplicacao simples itg) e 18(aplicacao conjunta itg). Somando tambem as contas com sem talao com movimentacao superior a R$20,00 em janeiro de 2008. 
***************************************************************/
/* ..........................................................................

   Programa: Fontes/crps138.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/95.                        Ultima atualizacao: 11/11/2013

   Dados referentes ao programa:

   Frequencia: Mensal (Batch).
   Objetivo  : Atende a solicitacao 039.
               Gerar o relatorio de informacoes gerenciais.
               Emite relatorio 115.
               Roda no primeiro dia util.

   Alteracoes: 23/02/96 - Tratar os campos cdempres nas leituras do crapger e do
                          crapacc (Odair).

               01/04/96 - Listar tambem vlctrrpp, qtaplrpp, vlaplrpp (Odair)

               14/08/96 - Alterado para listar o campo qtassapl (Odair).

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               15/01/99 - Tratar historico 320 = 58 (Odair)

               17/03/99 - Listar resumo de todas as agencias do mes corrente
                          no inicio (Odair).

               07/01/2000 - Alterado o diretorio /micros (Deborah).
               
               30/05/2001 - Alterado para ser impresso na impressora laser
                            com formulario de 234 columas por 62 linhas
                            (Edson).

               30/10/2003 - Substituido comando RETURN pelo QUIT(Mirtes)       
                                    
               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapacc (Diego).
                            
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
              
               04/04/2006 - Acerto em estouro de campo LANCTOS (Ze).

               03/05/2006 - Alterado format "SALDO DEVEDOR" (Diego).
               
               25/07/2006 - Alterado numero de copias do relatorio 115 para
                            Viacredi(Elton).

               07/04/2009 - Aumentado formato do valor capital e
                            saldo medio (Gabriel).
                           
               22/08/2011 - Alterado format do campo aux_vldjuros (Adriano).
               
               08/03/2013 - Alteracao no format aux_vldjuros (Daniele).
               
               11/11/2013 - Alterado totalizador de PAs de 99 para 999.
                           (Reinert)
                            
..............................................................................*/

DEF STREAM str_1.  /*  Para relatorio de informacoes gerenciais */

{ includes/var_batch.i "new" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps138"
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

RUN STORED-PROCEDURE pc_crps138 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps138 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps138.pr_cdcritic WHEN pc_crps138.pr_cdcritic <> ?
       glb_dscritic = pc_crps138.pr_dscritic WHEN pc_crps138.pr_dscritic <> ?
       glb_stprogra = IF pc_crps138.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps138.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


