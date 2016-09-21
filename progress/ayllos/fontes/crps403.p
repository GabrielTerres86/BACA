
/* ..........................................................................

   Programa: fontes/crps403.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Outubro/2004                       Ultima atualizacao: 26/05/2013

   Dados referentes ao programa:

   Frequencia: Semanal.
   Objetivo  : Atende a solicitacao 82 Ordem 47.
               Gerar relatorio (364) com a relacao de baixas do CCF
               Gerar lancamento de tarifa de regularizacao do CCF.
               Este programa passou de uma cadeia paralela para exclusiva.
               
   Alteracoes: 30/11/2004 - Incluido "CPF/CNPJ" (Evandro).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               10/04/2007 - Lista situacao dos cheques como "ENVIADO/NAO
                            ENVIADO" e separa o relatorio por bancos (Elton).  
                             
               23/05/2007 - Eliminada atribuicao TRUE de glb_infimsol pois
                            nao e o ultimo programa da cadeia (Guilherme).
                            
               13/07/2007 - Corrigidas as descricoes das situacoes dos cheques
                            (Evandro).
                            
               20/11/2007 - Tarifar regularizacao de CCF, alterado de paralelo 
                            para exclusivo solicitacao 82, ordem 47 (Guilherme).

               11/05/2009 - Alteracao CDOPERAD (Kbase).
               
               16/11/2009 - Não cobrar tarifa no período de pré inclusão do 
                            cheque no CCF (Fernando).
                            
               18/03/2010 - Adaptacao CCF Projeto IF CECRED (Guilherme).
               
               21/02/2011 - Atender a Trf. 38210 para o valor da tarifa dos 
                            cooperados ser da TAB027 e nao da tela TRFCMP (Ze).
                            
               14/01/2013 - Tratamento para contas migradas 
                            Viacredi -> AltoVale. (Fabricio)
                            
               15/03/2013 - Incluir ajustes do Projeto de Tarifas Fase 2
                            Grupo de cheque (Lucas R.).
                            
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               26/05/2013 - Ajustado para chamar o fonte oracle convertido(Odirlei-AMcom)       
               
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps403"
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

RUN STORED-PROCEDURE pc_crps403 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps403 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps403.pr_cdcritic WHEN pc_crps403.pr_cdcritic <> ?
       glb_dscritic = pc_crps403.pr_dscritic WHEN pc_crps403.pr_dscritic <> ?
       glb_stprogra = IF pc_crps403.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps403.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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
 
/*............................................................................*/

