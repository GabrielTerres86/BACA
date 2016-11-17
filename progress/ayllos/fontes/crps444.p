/* .............................................................................

   Programa: Fontes/crps444.p     
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Marco/2005.                     Ultima atualizacao: 13/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Processar as integracoes da compensacao do Banco do Brasil via
               arquivo DEB558 - CONTA INTEGRACAO.
               Emite relatorio 414.

   Alteracoes: 01/07/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craprej, craplcm, craptab e crapdpb (Diego).
               
               08/09/2005 - Lancamentos de outros debitos e 
                            novos historicos (Ze).
                            
               12/09/2005 - Tratar o historico "REMUN. de ACOES" (Ze).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               07/10/2005 - Tratar o historico de CARTAO BB (Ze).
               
               20/10/2005 - Acerto no programa (Ze).
               
               09/11/2005 - Cadastramento de Novos Historicos e DEB668 (Ze).
               
               16/11/2005 - Acerto no programa (Ze).

               17/11/2005 - Substituir crapchq,crapcht e crapchs por
                            crapfdc (Magui).
                            
               23/11/2005 - Ajuste no programa (Ze).

               10/12/2005 - Atualizar craprej.nrdctitg (Magui).
               
               14/12/2005 - Atualizar historicos com DEB668 (Ze).
               
               20/12/2005 - Acerto na critica 670 (Ze).

               22/12/2005 - Quantidade de copias - Viacredi (Ze).
               
               02/01/2006 - Tratar cheques TB (Ze).
               
               19/01/2006 - Atualizar historicos (Ze).
               
               25/01/2006 - Nao tratar o hist. 297 - Dep. Bloq. (Ze).
               
               10/02/2006 - Tratamento para datas Retroativas e 
                            Desativar o arquivo DEB668 (Ze).
                            
               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre.
               
               31/03/2006 - Incluir historicos (Ze).
               
               19/04/2006 - Ajuste na Centralizacao das Contas (Ze).
               
               23/05/2006 - Atualizacao dos historicos (Ze).
               
               08/06/2006 - Atualizacao dos historicos (Ze).
               
               14/06/2006 - Incluir verificacoes no programa (Ze).
               
               26/06/2006 - Tratamento de historicos (Ze).
               
               07/07/2006 - Tratamento do historico 144 (Ze).
               
               29/08/2006 - Atualizacao de historicos (Ze).
               
               18/10/2006 - Atualizacao de historicos (Ze).
               
               06/11/2006 - Atualizacao de historicos (Ze).
               
               15/12/2006 - Incluir historicos e o campo crapass.dtmvcitg (Ze).
               
               09/02/2007 - Vincular o historico BB 144 ao hist. 471 (Ze).

               13/02/2007 - Alterar consultas com indice crapfdc1 (David).
               
               23/02/2007 - Vincular o historico BB 732 e 168 ao hist. 661 (Ze)
              
               15/03/2007 - Acerto no historico BB 732 (Ze).
               
               11/07/2007 - Vincular hist. 0374->661,0781->169 e 0362->661 (Ze).

               25/09/2007 - Incluir o Historico 0376UNIMED->661 (Ze).
               
               04/10/2007 - Tratar historico 0144TRF SEM CPM->661 (Ze).
               
               28/01/2008 - Tratar historico 0362->661 (Ze).
               
               26/02/2008 - Acerto nos hist. Cta. Centralizador aux_dshsttrf
                            (Ze).
               08/05/2008 - Vincular o hist. 0732 ao 584 (Visanet) (Ze).
               
               20/05/2008 - Quando nao existe agencia do BB cadastrada
                            pular o programa (Magui).
                            
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               18/08/2008 - Alteracao na Aliena 43 para 49 (quando houver
                            contra-ordem) - Tarefa 18.958 (Ze).
                            
               06/01/2009 - Tratar historico 0190->661 (Tarefa 21697) (Ze).
               
               03/04/2009 - Tratar historico 0031->661 (Tarefa 23430) (Ze).
               
               16/04/2009 - Elimina arquivo de controle nao mais utilizado (Ze)
               
               05/06/2009 - Tratar historico 0204->661 (Tarefa 24884) (Ze).
               
               29/06/2009 - Tratar numero documento no Hist. Debitos (Ze).
               
               05/08/2009 - Tratar historico 0114->351 (Tarefa 25323) (Ze).
               
               17/08/2009 - Tratar historico 0612-RedeCard -> 999 (Ze).
               
               26/08/2009 - Retirada da leitura do 351 no crapdpb - 
                            Cheque nao Identificado corretamente pelo BB (Ze).
                            
               16/09/2009 - Incluir historico 0510->169 (Tarefa 27195) (Ze).
               
               14/10/2009 - Tratar historico 0707-Beneficio INSS -> 000
                            (Tarefa 27867) (Ze).
                            
               23/11/2009 - Alteracao apos identificar problema durante o 
                            processo da Textil no dia 03/11 - Acerto na inte-
                            gracao de Estornos e Debitos (Ze).      
                            
               30/11/2009 - Alteracao Codigo Historico (Kbase).
               
               12/01/2010 - Move arquivo deb558 para integra usando comando mv
                            inves do comando cat verificando se arquivo existe
                          - Incluido historico 196 para a variavel aux_dshstdeb
                            (Elton).
                            
               02/03/2010 - Ajuste para finalizar a execucao qdo nao existir
                            o arquivo (Ze Eduardo).
                            
               05/04/2010 - Quando der critica 258 enviar email para
                            Magui, Mirtes, Zé e cpd@cecred (Guilherme).
                            
               08/04/2010 - Aumentado formato da coluna documento  (Gabriel).
               
               15/04/2010 - Tratar historico BB 474 -> 668 (Trf. 31745) (Ze).
               
               12/07/2010 - Incluir Hist. BB 705 para somatorio no rel. 414 
                            (Trf. 33651) (Ze).
                            
               11/08/2010 - Incluir Hist. BB 303,373,158,156,118,808,367,378 e
                            828 (Trf. 34385/34447) e Acerto na qtdade e valor
                            processados exibido no LOG (Ze).

               21/09/2010 - Incluir Hist. BB 0143 e 0302 -> 661 (Trf. 35200)
                            (Ze).
                            
               01/12/2010 - Substituir alinea 43 por 21 e 49 por 28. (Ze).

               07/12/2010 - Condicoes Transferencia de PAC e novo relat 414_99
                            (Guilherme/Supero)
                            
               18/01/2011 - Incluido os e-mails:
                            - fabiano@viacredi.coop.br
                            - moraes@viacredi.coop.br
                            (Adriano).
                            
               31/01/2011 - Acerto no envio do email quando nao recebe o
                            arquivo deb558 (Ze).
                            
               17/02/2011 - Incluir Hist. BB 0233 -> 614 (Trf. 38270) (Ze).
                            Alterar alinea para 43 quando ja houve uma 1a vez
                            (Guilherme/Supero)

               17/03/2011 - Historicos 0900REDECARD, 0900REDE VI e 0900REDE MA
                            para nos sao o historico 444 (Magui).
                            
               14/04/2011 - Nao sera permitido a entrada de cheques que estao
                            em custodia ou em desconto de cheques (Adriano).
                            
               04/05/2011 - Tratamento da 0144TRANSF AGENDADA (Ze).
               
               03/06/2011 - Alterado destinatário do envio de email na procedure
                            gera_relatorio_203_99; 
                            De: thiago.delfes@viacredi.coop.br
                            Para: brusque@viacredi.coop.br. (Fabricio)
                            
               29/08/2011 - Tratamento da 0144TRANSFERENCIA (Ze).
                            
               21/10/2011 - Tratamento dos histor. 0159,0195,0368 e 0810 
                            - Trf. 43079 (Ze).

               25/10/2011 - Tratamento para Saldo Bloq. Indeterm. da Conta
                            Base da Concredi (Ze).
                            
               08/12/2011 - Sustação provisória (André R./Supero).             
                
               23/04/2012 - Retirado tratamento do hist. "0612RECEB FORNEC"
                            - Trf. 46233 (Ze).
                            
               08/05/2012 - Efetuar validacao do nome do arquivo(data/convenio)
                            no diretorio "compbb", e mover para o "integra" 
                            somente se estiver correto (Diego).
               
               08/06/2012 - Substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)  
                            
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).
                                        
               04/07/2012 - Retirado email fabiano@viacredi.com.br do recebimento
                            do relatório (Guilherme Maba);
                          - Somado o valor do relatorio para os demonstrativos
                            gerenciais (Evandro).
                            
               06/08/2012 - Incluir tratamento para 0729TRANSFERENCIA 
                            - Trf. 9574 (Ze)
               
               07/08/2012 - Adicionado parametro "codigo do programa" a chamada
                            da funcao geradev. (Fabricio)
                            
               14/08/2012 - Enviar email quando houver Cheque VLB no arquivo.
                            (Fabricio)

               22/10/2012 - Quando der critica 258 enviar email para
                            Diego, David, Mirtes, Zé e cpd@cecred (Ze).
                            
               28/05/2013 - Tratamento de novos historicos - Trf. 65325 (Ze).
               
               14/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel).
                                         
               13/08/2013 - Exclusao da alinea 29. (Fabricio)
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }


ASSIGN glb_cdprogra = "crps444"
       glb_flgbatch = FALSE
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

RUN STORED-PROCEDURE pc_crps444 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT INT(STRING(glb_flgresta,"1/0")),
    INPUT glb_nmtelant,
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

CLOSE STORED-PROCEDURE pc_crps444 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps444.pr_cdcritic WHEN pc_crps444.pr_cdcritic <> ?
       glb_dscritic = pc_crps444.pr_dscritic WHEN pc_crps444.pr_dscritic <> ?
       glb_stprogra = IF pc_crps444.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps444.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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
