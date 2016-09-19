/* .............................................................................

   Programa: Fontes/crps435.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Fevereiro/2005                  Ultima atualizacao: 10/06/2013

   Dados referentes ao programa:

   Frequencia: Por solicitacao - SOL030.
   Objetivo  : Emite aviso do credito das sobras do exercicio anterior.
               Solicitacao: 30
               Ordem: 2
               Relatorio: 410
               Tipo Documento: 8
               Formulario: Credito-Sobras.

   Alteracoes: 10/03/2005 - Alterado para NAO emitir aviso de credito para os
                            demitidos e para os valores abaixo de R$ 1,00
                            (Edson).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               19/06/2006 - Modificados campos referente endereco da estrutura
                            crapass para crapenc (Diego).

               06/02/2007 - Alterado de FormXpress para FormPrint (Julio).
               
               18/04/2007 - Modificado nome do arquivo aux_nmarqdat (Diego).

               30/05/2007 - Chamada do programa 'fontes/gera_formprint.p'
                            para executar a geracao e impressao dos
                            formularios em background (Julio)
                            
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               22/01/2009 - Envio de informativos para Postmix (Elton).

               25/03/2010 - Quando Viacredi, imprimir informativos so para
                            sobras >= 5,00 (Magui).
                            
               14/03/2011 - Alteracao no layout do aviso (Henrique).
               
               28/03/2011 - Alterado para somente listar o cooperado que tiver o
                            total do retorno maior do que o especificado (Elton).
                            
               19/08/2011 - Incluido separador das cartas e envio para Engecopy 
                            quando for cooperativas 1, 2 ou 4 (Elton).
                            
               03/04/2012 - Incluir descricao "JUROS AO CAPITAL" (Diego).
               
               14/05/2012 - Incluido FORMAT no campo aux_dsintern[5] ref.
                            valor liquido a ser creditado (Diego).
                            
               16/05/2012 - Setado quantidade maxima de registros por arquivo;
                            aux_qtmaxarq = 3000. Tratado tambem para o envio 
                            de email. (Fabricio)
                            
                10/06/2013 - Alteração função enviar_email_completo para
                             nova versão (Jean Michel).
                            
............................................................................. */

{ includes/var_batch.i }  
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps435"
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

RUN STORED-PROCEDURE pc_crps435 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps435 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps435.pr_cdcritic WHEN pc_crps435.pr_cdcritic <> ?
       glb_dscritic = pc_crps435.pr_dscritic WHEN pc_crps435.pr_dscritic <> ?
       glb_stprogra = IF pc_crps435.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps435.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


