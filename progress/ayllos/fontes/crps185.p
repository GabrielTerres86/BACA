/* .............................................................................

   Programa: Fontes/crps185.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/97.                           Ultima atualizacao: 12/09/2013

   Dados referentes ao programa:

   Frequencia: Mensal ou por solicitacao.
   Objetivo  : Emitir relatorio com as pendencias nas alienacoes fiduciarias.
               Atende a solicitacao 101. Emite relatorio 145.

   Alteracoes: 24/06/1999 - Alterado para tratar a data de vencimento do 
                            seguro do bem alienado (Edson).

               10/02/2000 - Gerar pedido de impressao (Deborah).

               26/02/2002 - Trocado para a solicitacao 70 - semanal (Deborah).

               16/08/2002 - Desprezar se o bem nao exige seguro (Margarete).

               15/06/2004 - Nao listar se seguro nao obrigatorio(Mirtes)
               
               30/06/2005 - Trocada solicitacao de 070 para 101 e gerar
                            relatorio por PAC - para a IMPREL (Evandro).
                            
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder 
                           
               10/07/2006 - Concertado para gerar arquivo pdf(INTRANET) (Diego).
               
               28/07/2006 - Alterado numero de copias do relatorio 145 para
                            Viacredi (Elton).
              
               23/05/2007 - Eliminada a atribuicao TRUE de glb_infimsol pois
                            nao e o ultimo programa da cadeia (Guilherme).  
                            
               18/02/2010 - Incluido Renavan na descricao do bem (Fernando).
               
               06/05/2010 - Inclusao do campo "Chassi" (Sandro-GATI).
               
               20/09/2010 - Migraçao dos campos dos bens da crawepr para
                            a crapbpr (Gabriel).
                            
               20/12/2010 - Arrumar duplicacao de registros no relatorio
                            (Gabriel)             
               
               01/02/2011 - Alterado para nao desprezar emprestimos onde o 
                            operador nao e´ encontrado (Henrique).
                            
               16/01/2012 - Ajuste na quantidade de bens alienados (David).
               
               12/09/2013 - Conversao oracle, chamada da stored procedure
                            (Andre Euzebio / Supero).
.............................................................................*/

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps185"
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

RUN STORED-PROCEDURE pc_crps185 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper, 
    INPUT INT(STRING(glb_flgresta,"1/0")),                                         OUTPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps185 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps185.pr_cdcritic WHEN pc_crps185.pr_cdcritic <> ?
       glb_dscritic = pc_crps185.pr_dscritic WHEN pc_crps185.pr_dscritic <> ?
       glb_stprogra = IF pc_crps185.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps185.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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



