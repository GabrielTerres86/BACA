/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps346.p                | pc_crps346                        |
  +---------------------------------+-----------------------------------+
  
   TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 04/MAR/2015 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - IRLAN CHEQUER MAIA  (CECRED)
   - MARCOS MARTINI      (SUPERO)

******************************************************************************/

/* ............................................................................

   Programa: Fontes/crps346.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/2003.                         Ultima atualizacao: 28/10/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Processar as integracoes da compensacao do Banco do Brasil via
               arquivo DEB558.
               Emite relatorio 291.

   Alteracoes: 21/08/2003 - Enviar por email o relatorio da integracao para o
                            Financeiro da CECRED (Edson).

               04/09/2003 - Nao tratar mais o estorno de depositos (Edson).

               01/10/2003 - Corrigir erro no restart (Edson).

               02/10/2003 - Acertar para rodar tambem com o script
                            COMPEFORA (Margarete).

               15/10/2003 - Tirado o = (igual) na verificacao da conta-ordem
                            (Edson)
                            
               29/01/2004 - Nao enviar por email o relatorio de integracao.
                            (Ze Eduardo).

               30/01/2004 - Espec. cobranca eletronica(0624COBRANCA)(Mirtes)
               
               18/06/2004 - Listar o disponivel de todas as conta (Margarete).
               
               25/06/2004 - Eliminar a listagem de depositos (Ze Eduardo).
               
               13/08/2004 - Modificar formulario para duplex (Ze Eduardo).
               
               25/08/2004 - Nao esta mostrando o disponivel correto (Margarete)
               
               04/10/2004 - Gravacao de dados na tabela gntotpl do banco
                            generico, para relatorios gerenciais (Junior).
               
               06/10/2004 - Modificar o SUBSTR da conta base (Ze Eduardo).
               
               29/04/2005 - Modificacao para Conta-Integracao (Ze Eduardo).
               
               23/05/2005 - Incluir coop: 4,5,6 e 7 CTITG (Ze Eduardo).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craprej, craptab, crapdpb e craplcm (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               03/10/2005 - Alterado e_mail(Mirtes).
               
               17/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               20/10/2005 - Alteracao de Locks e blocos transacionais(SQLWorks).

               01/11/2005 - Uso da procedure digbbx.p para conversao de campo
                            inteiro para caracter (SQLWorks - Andre).

               10/11/2005 - Tratar campo cdcooper na leitura da tabela
                            crapcor (Edson).
                            
               08/12/2005 - Revisao do crapfdc (Ze).
               
               14/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               22/03/2006 - Acerto no Programa (Ze).
               
               23/05/2006 - Atualizacao dos historicos (Ze).
               
               09/06/2006 - Atualizacao dos historicos (Ze).

               13/02/2007 - Alterar consultas com indice crapfdc1 (David).
               
               04/06/2007 - Alteracao email administrativo para compe(Mirtes)
               
               11/11/2008 - Inlcuir tratamento para contas com digito X (Ze).
               
               11/12/2008 - Chamar BO de email. Alterar o email do rel291 para
                            ariana@viacredi.coop.br (Gabriel).
                            
               06/02/2009 - Acerto no envio do relatorio por email (Ze).
               
               19/03/2009 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
                            
               16/04/2009 - Elimina arquivo de controle nao mais utilizado (Ze) 
 
               27/08/2009 - E_mail juliana.vieira@viacredi.coop.br(Mirtes)
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               11/01/2010 - Substituido comando "cat" por "mv" no momento da 
                            integracao do arquivo no sistema (Elton).
                            
               05/02/2010 - Alterado e-mail de juliana.vieira@viacredi.coop.br
                            para graziela.farias@viacredi.coop.br (Fernando).

               02/03/2010 - Ajuste para finalizar a execucao qdo nao existir
                            o arquivo (Ze Eduardo).
                            
               05/04/2010 - Quando der critica 258 enviar email para
                            Magui, Mirtes, Zé e cpd@cecred (Guilherme).   
                            
               12/04/2011 - Incluido o e-mail marilia.spies@viacredi.coop.br
                            para receber o relatorio 291 (Adriano).
                            
               16/05/2011 - Alterado para enviar o rel291 somente para o e-mail
                            marcela@cecred.coop.br (Adriano).
                            
               07/12/2011 - Sustação provisória (André R./Supero).             
                                         
               12/12/2011 - Retirar o email da Marcela - Trf. 43942 (ZE).
               
               15/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)
                            
               07/08/2012 - Adicionado parametro "codigo do programa" a chamada
                            da funcao geradev. (Fabricio)
                            
               13/08/2012 - Enviar email quando houver Cheque VLB no arquivo.
                            (Fabricio)
                            
               04/09/2012 - Tratamento crapcop.nmrescop "x(20)" (Diego).             
               
               22/10/2012 - Quando der critica 258 enviar email para
                            Diego, David, Mirtes, Zé e cpd@cecred (Ze).
               
               10/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel).
                            
               13/08/2013 - Exclusao da alinea 29. (Fabricio)
               
               08/11/2013 - Adicionado o PA do cooperado ao conteudo do email
                            de notificacao de cheque VLB. (Fabricio)
                            
               21/01/2014 - Incluir VALIDATE craplot, craplcm, craptab, 
                            craprej, gntotpl, crapdpb (Lucas R.)
                            
               26/11/2014 - Ajustado para integrar arquivos da incorporacao.
                            (Reinert)
                            
               01/12/2014 - Ajustando a procedure lista_saldos para gravar os
			                registro na tabela gntotpl para exibir o valor do
							movimento do dia quando for rodado tanto o processo
							normal quanto o processo COMPEFORA. SD - 218189
							(Andre Santos - SUPERO).
                            
               09/04/2015 - Ajuste para não abortar programa pela critica 258
                            sem antes verificar se existe os arquivos para as 
                            coops incorporadas SD 274788 (Odirlei-AMcom)              

               09/11/2015 - Ajustar para sempre exibir a mensagem de arquivo 
                            processado com sucesso. A mensagem eh apenas para
                            saber que o processamento do arquivo foi finalizado.
                            (Douglas - Chamado 306964)

               23/12/2015 - Ajustar parametros da procedure geradev.p 
                          - Ajustar as alineas de acordo com a revisao de alineas
                            (Douglas - Melhoria 100)  

               02/02/2016 - Incluso novos e-mail na rotina de envio e-mail. (Daniel) 
             
               28/10/2016 - Conversao Progress > PLSQL (Jonata-Mouts)
                                
............................................................................ */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps346"
       glb_flgbatch = FALSE. 

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " +
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
    RETURN.
END.
ERROR-STATUS:ERROR = FALSE.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps346 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps346 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps346.pr_cdcritic WHEN pc_crps346.pr_cdcritic <> ?
       glb_dscritic = pc_crps346.pr_dscritic WHEN pc_crps346.pr_dscritic <> ?
       glb_stprogra = IF pc_crps346.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps346.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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
                  