/*..........................................................................

   Programa: Fontes/crps279.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah      
   Data    : Janeiro/2000                      Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 004.
               Emite: Controle de seguros prestamistas (226).

   Alteracoes: 05/05/2000 - Classificar por inmatric descending para que na
                            leitura as contas originais fiquem sempre depois
                            das contas duplicadas (Deborah).

               21/09/2000 - Campos da tabela:
                            valor minimo para emissao de proposta
                            valor maximo de cobertura
                            valor minimo de cobertura 
                            data de inicio da cobertura
                            Ajustes para esses campos (Deborah).

               06/02/2001 - Alterado para enviar o arquivo por e-mail (Edson).

               02/05/2001 - Alterado para tirar os parenteses da mensagem
                            (Deborah).

               03/12/2001 - Incluir valor total (Margarete).
               
               04/02/2002 - Padronizar o indice gravado na tabela (Ze Eduardo).
               
               07/05/2002 - Calcular e mostrar o percentual de pagto para a 
                            seguradora (Edson).

               19/09/2002 - Alterado para enviar arquivo de seguro de vida
                            automaticamente          (Junior).
                            
               22/11/2002 - Colocar "&" no final do comando MTSEND (Junior).

               04/04/2003 - Imprimir o relatorio somente para as cooperativas
                            que possuir seguros (Ze Eduardo).

               31/03/2004 - Enviar email para ADD-MAKLER somente quando a 
                            cooperativa for VIACREDI ou CREDITEXTIL (Edson).

               31/03/2004 - Corrigir valor PAGTO SEGURADORA se estiver zerado
                            (Julio)

               04/10/2004 - Alterado destino do email para 
                            janeide.bnu@addmakler.com.br (Edson).
                            
               03/11/2004 - Enviar, tambem, email para a VIACREDI (Edson).

               23/03/2005 - Incluir o campo craptsg.cdsegura na leitura da
                            tabela craptsg (Edson).

               01/09/2005 - Alterado destino do email para 
                            elisangela.bnu@addmakler.com.br (Edson).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               23/01/2006 - Efetuado acerto - Data seguro(Mirtes)
                
               26/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David).
               
               12/04/2007 - Retirar rotina de email em comentario (David).
               
               01/06/2007 - Aumentado de 6 para 7 digitos o 'nrctremp'
                            (Guilherme).

               13/08/2007 - Incluido envio do relatorio 226 para os emails:
                            fernandabrizola.bnu@addmakler.com.br
                            rene.bnu@addmakler.com.br
                            susan.bnu@addmakler.com.br 
                          - Incluido "Vct ctrato" crrl226  (Guilherme).
                          
               12/09/2007 - Incluido envio e-mail para graziele@viacredi.coop.br
                            (Guilherme).
              
               05/11/2007 - Layout do arquivo modificado para que as 145     
                            colunas sejam impressas (Gabriel).
                                 
               07/12/2007 - Cooperativa Creditextil, enviar  o e-mail para
                            ivanildo@sorellaseguros.com.br (Gabriel)
                            
               18/09/2008 - Enviar e-mail para patrimonio@viacredi.coop.br
                            (Gabriel).

               4/11/2008  - Enviar rel226 para ariana@viacredi.coop.br(Gabriel).
               
               14/11/2008 - Listar seguros prestamistas a partir da data
                            de contratacao deste servico pela cooperativa
                           (Diego).
               
               28/01/2009 - Enviar email somente para aylloscecred@addmakler
                            .com.br (Gabriel)
                            
               10/06/2009 - Incluido resumo por PAC do saldo devedor e
                            encaminhado e_mail para as cooperativas(Fernando).
                            
               01/12/2010 - Alteracao de Format (Kbase/Willian).
                            001 - Alterado para 50 posições, valor anterior 40.

               04/01/2011 - Alterado o envio de e-mail do rel226 de 
                            ivanildo@sorellaseguros.com.br para 
                            aylloscecred@addmakler.com.br (Adriano).
                            
               05/07/2011 - Enviar e-mail para jeicy@cecred.coop.br (Henrique)
               
               13/02/2012 - Substituído o email ariana@viacredi.coop.br
                            por fernanda.devitz@viacredi.coop.br (Lucas)
                            
               07/01/2013 - Desprezada as linhas de credito 800 e 900 da 
                            leitura da tabela de emprestimos (crapepr). 
                            (Daniele)

               01/02/2013 - Incluir parametros de programa pararelo (David).  
               
               05/03/2013 - Alterado posicao de  NOME, NASCIMENTO e PAC para 
                            aparecer ao lado da conta no frame f_emprestimos
                            Tarefa - 47606 (Lucas R).
                            
               08/03/2013 - Substituido e-mail jeicy@cecred.coop.br por 
                            cecredseguros@cecred.coop.br (Diego).
                                         
               23/08/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739) 

..............................................................................*/

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps279"
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

RUN STORED-PROCEDURE pc_crps279 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps279 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps279.pr_cdcritic WHEN pc_crps279.pr_cdcritic <> ?
       glb_dscritic = pc_crps279.pr_dscritic WHEN pc_crps279.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps279.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps279.pr_infimsol = 1 THEN
                         TRUE
                      ELSE
                         FALSE.

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

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS279.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 912,
    input "912 - FINALIZADO LEGAL",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS279.P",
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
