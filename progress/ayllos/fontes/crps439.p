/* ..........................................................................

   Programa: fontes/crps439.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio          
   Data    : Marco/2005                       Ultima atualizacao: 19/09/2013
                                                                            
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001 
               Ordem na solicitacao = 50.
               Processar as solicitacoes de geracao dos debitos de seguro.
               Emite relatorio 416

   Alteracoes: 08/04/2005 - Alteracao na formatacao do relatorio de 132 para 80
                            colunas (Julio)

               03/05/2005 - Alterado para listar as alteracoes conforme a data
                            de digitacao e efetuar o debito um dia util apos
                            a data de debito caso a data de debito seja um 
                            domingo ou feriado. (Julio)

               01/07/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e crapavs (Diego).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               20/10/2005 - Alterado o e-mail do Jean para a Mary (Julio)
               
               24/10/2005 - Alterada a extensao do relatorio de .lst para
                            .doc, pois .lst estava sendo barrado pelo filtro
                            do servidor da Addmakler (Julio)

               24/11/2005 - Tratamento para planos de seguro com parcelas
                            variaveis ou unica. (Julio)
                            
               06/12/2005 - Alteracao de e-mail da Mary para o Jean (Julio)    
                        
               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).

               14/12/2005 - Ajustes no controle indebito (Julio)
               
               17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               03/04/2006 - Alteracao na critica 200 para o LOG (Julio)

               21/06/2006 - Preparar relatorio para seguradora CHUBB (Julio)
               
               06/07/2006 - Nao deixar lancar valores negativos (Julio).
               
               13/07/2006 - Ajustes para debitos de seguros cancelados (Julio)
               
               19/07/2006 - Atualizacao do FIND crapavs. Antes estava prvisto
                            para seguros vinculados a folha. Isto nao esta mais
                            sendo utilizado. (Julio)
                            
               28/08/2006 - Somente listar no log, seguros com valores
                            negativos (Julio)

               08/01/2007 - Enviado arquivo .doc para ADDmakler e arquivo .lst
                            para diretorio "rl" (Elton).

               22/05/2007 - Incluido envio do relatorio 416 para os emails
                            rene.bnu@addmakler.com.br e
                            pedro.bnu@addmakler.com.br (Guilherme).

               25/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                            
               08/08/2008 - Gerar/Enviar novo arquivo(str_2) (Diego).
                          - Enviar e-mail a josianes.bnu@addmakler.com.br
                            (Gabriel).
               
               20/10/2008 - Gerar arquivo(str_2) somente se Parametro Seguro
                            Chubb estiver cadastrado na TAB049 (Diego).
                            
               14/11/2008 - Alterado para buscar numero do lote(str_2) atraves
                            da craptab, e incrementar sequencia (Diego).

               29/01/2009 - Enviar e-mail somente p/ aylloscecred@addmakler.
                            com.br (Gabriel).
                            
               10/03/2009 - Enviar arquivo crrl416.doc para demais emails:
                            egoncalves@chubb.com galmeida@chubb.com (Diego).
                            
               03/12/2009 - Inclusao do PAC do Seguro no relatorio apresentado 
                            (GATI - Eder)
                            
               16/05/2011 - Desconsiderar do relatório, seguros contratados e 
                            cancelados no mesmo dia (Diego).
                            
               05/07/2011 - Enviar e-mail para jeicy@cecred.coop.br (Henrique)                            
               
               16/09/2011 - Incluidos campos de tipos de movimento, motivo de
                            cancelamento, RG, crapseg.flgclabe e
                            crapseg.nmbenvid[1] nos Detalhes. Retirados
                            tratamentos referente a endosso.
                            Incluido no relatorio crrl416 listagem de
                            seguros renovados. (Gati - Oliver)
                            
               04/10/2011 - Incluido tratamento para endereco de 
                            correspondencia (Diego).            
               
               21/12/2011 - Corrigido warnings (Tiago). 
               
               04/03/2013 - Substituido e-mail jeicy@cecred.coop.br por 
                            cecredseguros@cecred.coop.br (Daniele).
                            
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero). 
                            
               19/09/2013 - Incluir o campo complemento no relatorio que e
                            enviado para a Chubb (James).
............................................................................. */

{ includes/var_batch.i {1} } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps439"
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

RUN STORED-PROCEDURE pc_crps439 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps439 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps439.pr_cdcritic WHEN pc_crps439.pr_cdcritic <> ?
       glb_dscritic = pc_crps439.pr_dscritic WHEN pc_crps439.pr_dscritic <> ?
       glb_stprogra = IF pc_crps439.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps439.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


