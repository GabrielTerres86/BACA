/* ............................................................................

   Programa: Fontes/crps270.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Agosto/99                       Ultima atualizacao: 18/09/2013

   Dados referentes ao programa:

   Frequencia: Mensal (Batch).
   Objetivo  : Atende a solicitacao 83.
               Mensal do seguro de vida.
               Emite relatorio 220.

   Alteracoes: 30/12/1999 - Dar a mensagem de gravacao do arquivo somente
                            se houve registros (Deborah).

               10/03/2000 - Padronizar mensagem (Deborah).
               
               19/09/2002 - Alterado para enviar arquivo de seguro de vida
                            automaticamente (Junior).
                            
               22/11/2002 - Colocar "&" no final do comando "MT SEND" (Junior).
               
               06/02/2003 - Alterar endereco de email para envio de arquivo
                            (Junior).

               06/07/2004 - Alterado para enviar o arquivos crrl220 por 
                            email para a Janeide da ADDMakler (Edson).

               09/12/2004 - Gerar arquvios geral de seguros e envia-lo por
                            email para a Janeide da ADDMakler (Edson).


               16/02/2005 - Desmembrar o relatorio geral de seguros para
                            antes de 01/12/2004 e outro para depois de 
                            30/11/2004 (Edson).

               23/03/2005 - Incluir o campos craptsg.cdsegura na leitura da
                            tabela craptsg (Edson).

               30/06/2005 - Alimentado campo cdcooper da tabela crapres (Diego).

               01/09/2005 - Alterado para enviar os arquivos crrl220 e crrl399
                            por email para a Elisangela da ADDMakler (Edson).
                            
               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               16/02/2006 - Unificacao dos Campos - SQLWorks - Fernando. 
               
               05/07/2006 - Incluida execucao do procedimento imprim.p na
                            procedure proc_seguro_geral (David).
                            
               30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David).
               
               05/01/2007 - Incluido envio do relatorio 220 para o email
                            pedro.bnu@addmakler.com.br (David).
               
               22/05/2007 - Incluido envio do relatorio 220 para o email:
                            rene.bnu@addmakler.com.br (Guilherme).
                            
               06/08/2007 - Incluido envio do relatorio 220 para os emails:
                            susan.bnu@addmakle.com.br
                            fernandabrizola.bnu@addmakler.com.br (Guilherme).
                            
               03/10/2007 - Enviar email com o crrl399 para os mesmos
                            destinatarios do crrl220(Guilherme).
                                         
               18/03/2008 - Retirado comentario da rotina de envio de email
                            (Sidnei - Precise)

               29/11/2008 - glb_nmformul com 234dh para crrl399 (Magui).

               28/01/2009 - Enviar e-mail somente para aylloscecred@addmakler
                            .com.br em ambos relatorios (Gabriel).
                            
               14/01/2011 - Alterado campo CAPITAL no relatorio 399 para exibir
                            o valor do campo craptsg.vlmorada. (Jorge)
                            
               01/02/2011 - Alterado format do campo nrdconta e nrctrseg da
                            str_4 (Henrique).
                            
               05/07/2011 - Enviar e-mail para jeicy@cecred.coop.br (Henrique)
               
               04/03/2013 - Substituido e-mail jeicy@cecred.coop.br por 
                            cecredseguros@cecred.coop.br (Daniele).
                            
               18/09/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                            
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps270"
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

RUN STORED-PROCEDURE pc_crps270 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps270 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps270.pr_cdcritic WHEN pc_crps270.pr_cdcritic <> ?
       glb_dscritic = pc_crps270.pr_dscritic WHEN pc_crps270.pr_dscritic <> ?
       glb_stprogra = IF pc_crps270.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps270.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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