/* ..........................................................................

   Programa: Fontes/crps309.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson 
   Data    : Maio/2001.                         Ultima atualizacao: 31/10/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 005.
               Criar base da comp. eletronica dos cheques em custodia.

   Alteracoes: 07/06/2001 - Alterado para tratar tabela de custodia
                            (CRED-CUSTOD-00-nnnnnnnnnn-000) - Edson.
                            
               11/07/2001 - Alterado para adaptar o nome de campo (Edson).
               
               14/08/2001 - Alterar mensagem da transmissao no log do processo
                            (Junior).
                            
               21/01/2002 - Incluir a data no nome do arquivo de cheques para
                            o banco Safra (Junior).

               25/04/2002 - Criar crapchd para os cheques CREDIHERING (Edson).

               13/05/2002 - Mover o arquivo para o salvar ao inves de copia-lo
                            (Deborah).

               25/09/2002 - Alterado para enviar arquivos de custodia da Cooper
                            automaticamente (Junior).
                            
               22/11/2002 - Colocar "&" no final do comando "MT  SEND" (Junior).

               30/06/2005 - Alimentado campo cdcooper da tabela crapchd (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder      
                      
               30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David).
               
               12/04/2007 - Retirar rotina de email em comentario (David).
               
               18/03/2008 - Retirado comentario da rotina de envio de email
                            (Sidnei - Precise)
                            
               20/01/2014 - Incluir VALIDATE crapchd (Lucas R.)
               
               22/05/2014 - Atualiza a situacao previa da tabela crapchd
                            com a mesma da crapcst.insitprv 
                            (Tiago/Rodrigo SD158725).
                            
               31/10/2016 - Conversão para PL/SQL (Daniel)                             
                            
                            
............................................................................. */


{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps309"
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

RUN STORED-PROCEDURE pc_crps309 NO-ERROR
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

CLOSE STORED-PROCEDURE pc_crps002.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps309.pr_cdcritic WHEN pc_crps309.pr_cdcritic <> ?
       glb_dscritic = pc_crps309.pr_dscritic WHEN pc_crps309.pr_dscritic <> ?
       glb_stprogra = IF pc_crps309.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps309.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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

/* .......................................................................... */

