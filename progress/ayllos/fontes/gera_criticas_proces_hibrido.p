/* ...................................................................................

   Programa: Fontes/gera_criticas_proces.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Margarete/Mirtes
   Data    : Junho/2004.                     Ultima atualizacao: 11/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criticas que impedem a solicitacao do PROCESSO.

   Alteracoes: 23/11/2004 - Independente  de determinadas criticas,           
                             solicitar processo(Noturno)(Mirtes).

               11/04/2005 - Conferir se a taxa oficial esta cadastrada (Edson).
               
               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               04/10/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapact (Diego).

               03/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               14/12/2006 - Verificar se os TEDs das contas salario foram
                            enviados (Evandro).
                            
               05/02/2007 - Nao alertar mais para cadastramento do 
               dolar(Julio)
               
               30/03/2007 - Melhorar calculo das datas para ver se as taxas
                            estao cadastradas (Magui).
                            
               03/04/2007 - Verificar o envio de DOCS (HRTRDOCTOS) (Evandro).

               17/04/2007 - Melhorar criticas apresentadas (Magui).
               
               20/07/2007 - Nao considerar se o caixa da INTERNET estiver
                            aberto (Evandro).
                            
               06/08/2007 - Exigir TAXRDC quando mensal (Magui).

               10/10/2007 - Definir TEMP-TABLE w_criticas como parametro de
                            saida (David).
               
               19/11/2007 - Exigir TAXRDC do dia quando tiver RDCPOS (Magui). 
               
               20/11/2007 - Colocar aspas simples "'" quando colocar criticas no
                            proc_batch.log (David).

               23/11/2007 - Incluir verificacao de envio de arquivos pela tela
                            MOVGPS (David).

               20/12/2007 - Nao efetuar critica de arquivo nao enviado no dia
                            31/12/2007 (David).
               
               03/01/2008 - Retirar criticas do RDCA (Magui).
               
               12/02/2008 - Verificar se ha algum pagamento do INSS-BANCOOB nao
                            enviado (Evandro).

               22/02/2008 - Incluir parametro na craptab "EXEICMIRET" (David).
               
               17/04/2008 - Incluido tratamento TED (Diego).
               
               07/05/2008 - Incluido critica para envio de cheques para o
                            BANCOOB (Elton).
                          - Verificar agendamentos pendentes (David).
                          
               14/10/2008 - Incluir parametro na craptab EXEICMIRET (David).
               
               06/04/2009 - Retirada critica dos lotes da poupanca 
                            programada (Fernando).
               
               28/04/2009 - Atualizar os campos cdsitexc e cdagenci da
                            TEMP-TABLE w_criticas (Fernando).

               01/07/2009 - Eliminar critica de taxa cadastrada para poupanca
                            programa com faixa maior que 10000. Se a zero
                            estiver cadastrada, todas as faixas estao (Magui).
                            
               06/07/2009 - Incluir critica para a conta dos emprestimos com
                            emissao de boletos, a mesma devera estar zerada 
                            quando houver a solicitacao do processo (Fernando).
               
               26/05/2010 - Retirada na leitura da tabela craptit o campo 
                            craptit.insittit (Elton).

               14/06/2010 - Melhorar critica movtos em especie (Magui).
                          - Tratamento para PAC 91 conforme PAC 90 (Elton).
                          
               07/05/2010 - Consistir o envio do Arq. Chq. p/ o Bancoob somente
                            qdo for chamado pela PRocES (Ze).
                            
               06/08/2010 - Realizado mudanca para que a critica "Falta CECRED
                            cadastrar TAXRDC para RDCPOS do dia". Quando chamado
                            pelo crps417, seja apenas criticado se hora for maior
                            que 20:30 (Adriano).              
                            
               11/11/2010 - Alteracoes atendendo o projeto de Truncagem (Ze).
               
               31/01/2011 - Nao verificar situacao da previa antes de 25/03/11
                            (Ze).
                            
               18/02/2011 - Incluso novo parametro de Saldo Medio na EXEICMIRET
                            para calculo das sobras(Guilherme).
                            
               22/03/2011 - Aumento das casas decimais para 8 dig 
                            na EXEICMIRET(Guilherme).              
                            
               18/04/2011 - Nao criticas as remessas dos cheques digitalizados
                            (Ze).
                            
               03/06/2011 - Alteracao na leitura do crapcme devido o projeto
                            de combate a lavagem de dinheiro (Henrique). 
                            
               07/07/2011 - Logar chamada da procedure de controle de 
                            movimentacao. E só chamar ela quando solicitado
                            o processo (Gabriel).             
                 
               12/08/2011 - Enviar e_mail de todos os controles de movimentacao
                            que ainda nao forame enviados ao COAF independente
                            da data (Magui).
                            
               16/11/2011 - Verifica se a data corrente é igual ao último dia
                            útil do mês.  Se for, verifica se os valores de 
                            taxa estão cadastrados para os tipo: 
                            6-CDI Anual, 8-Poupança, 11-TR, 16-CDI Mensal 
                            (Handrei - RKAM)              
                            
               29/12/2011 - Nao cancelar a sol. do processo quando ha lotes de 
                            requisicao de cheques nao batido (Ze).
                            
               30/03/2012 - Desprezar o CDI DIARIO (no crpamfx) se o ultimo dia
                            do mes for no final de semana (Ze).
                            
               05/04/2012 - Ajuste das situações que ultilizam o campo "crap.dstextab"
                            sem o registro estar AVAILABLE.
                            (David Kruger).
                            
               24/04/2012 - Incluído críticas para borderos e limites de cheques/titulos
                            sem documento digitalizado(Guilherme Maba).
               
               21/06/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)             
                            
               29/06/2012 - Ajuste no ver_ctace.p (Ze).
               
               11/09/2012 - Alteracao de 24/04 somente com glb_dtmvtoan 
                            (Guilherme).
                            
               15/01/2013 - Retiradas (comentadas) criticas para borderos e limites
                            de cheques/titulos nao digitalizados 
                           (Daniele).
               
               14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                           
               28/01/2014 - Alterado o parametro de data para validação de borderos
                            (Jean Michel).  
                                                        
               04/02/2014 - Inclusão de tratamento p/ taxa TR e SELIC Meta (Jean Michel)
               
               12/05/2014 - Ajuste na critica TAXRDC (Ze).
               
               11/06/2014 - Conversao Progress -> Oracle, Alterado procedimento 
                            para chamar a store-procedure do oracle (Odirlei - AMcom)
........................................................................................*/

{ includes/var_online.i }
{ includes/var_proces.i }
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen9998tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF INPUT  PARAM par_nmarqimp AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM par_nrsequen AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM TABLE for w_criticas.


ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_gera_criticas_proces_wt aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper, /* pr_cdcooper   --> Codigo da cooperativa*/
    INPUT glb_cdagenci, /* pr_cdagenci   --> Codigo da agencia*/
    INPUT glb_cdoperad, /* pr_cdoperad   --> codigo do operador*/
    INPUT glb_nmdatela, /* pr_nmdatela   --> Nome da tela */
    INPUT par_nmarqimp, /* pr_nmarqimp   --> Nome do arquivo*/
    /* pr_choice      --> Tipo de escolhe efetuado na tela*/
    INPUT choice,       
    /* pr_nrsequen    --> Numero sequencial */ 
    OUTPUT aux_nrsequen, 
    /* pr_vldaurvs    --> Variavel para armazenar o valor do urv*/
    OUTPUT aux_vldaurvs, 
    /* pr_flgsol    --> variavel que controla se deve gerar a solicitaçao*/
    OUTPUT INT(STRING(aux_flgsol16,"1/0")), 
    OUTPUT INT(STRING(aux_flgsol27,"1/0")), 
    OUTPUT INT(STRING(aux_flgsol28,"1/0")), 
    OUTPUT INT(STRING(aux_flgsol29,"1/0")), 
    OUTPUT INT(STRING(aux_flgsol30,"1/0")), 
    OUTPUT INT(STRING(aux_flgsol37,"1/0")), 
    OUTPUT INT(STRING(aux_flgsol46,"1/0")), 
    OUTPUT INT(STRING(aux_flgsol57,"1/0")), 
    OUTPUT INT(STRING(aux_flgsol59,"1/0")), 
    OUTPUT INT(STRING(aux_flgsol80,"1/0")), 
    OUTPUT 0,           /*aux_cdcritic    --> Critica encontrada*/
    OUTPUT ""          /*aux_dscritic OUT VARCHAR2*/
    ).
      
IF  ERROR-STATUS:ERROR  THEN DO:
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + 
                              ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
        
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - pc_gera_criticas_proces_wt' --> '"  +
                      "Erro ao executar Stored Procedure: '" +
                      aux_msgerora + "' >> log/proc_batch.log").
    RETURN.
END.

CLOSE STORED-PROCEDURE pc_gera_criticas_proces_wt WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_gera_criticas_proces_wt.pr_cdcritic WHEN pc_gera_criticas_proces_wt.pr_cdcritic <> ?
       glb_dscritic = pc_gera_criticas_proces_wt.pr_dscritic WHEN pc_gera_criticas_proces_wt.pr_dscritic <> ?
       aux_nrsequen = pc_gera_criticas_proces_wt.pr_nrsequen WHEN pc_gera_criticas_proces_wt.pr_nrsequen <> ?
       aux_vldaurvs = pc_gera_criticas_proces_wt.pr_vldaurvs WHEN pc_gera_criticas_proces_wt.pr_vldaurvs <> ?       
       aux_flgsol16 = IF pc_gera_criticas_proces_wt.pr_flgsol16 = 1 THEN TRUE ELSE FALSE
       aux_flgsol27 = IF pc_gera_criticas_proces_wt.pr_flgsol27 = 1 THEN TRUE ELSE FALSE
       aux_flgsol28 = IF pc_gera_criticas_proces_wt.pr_flgsol28 = 1 THEN TRUE ELSE FALSE
       aux_flgsol29 = IF pc_gera_criticas_proces_wt.pr_flgsol29 = 1 THEN TRUE ELSE FALSE
       aux_flgsol30 = IF pc_gera_criticas_proces_wt.pr_flgsol30 = 1 THEN TRUE ELSE FALSE
       aux_flgsol37 = IF pc_gera_criticas_proces_wt.pr_flgsol37 = 1 THEN TRUE ELSE FALSE
       aux_flgsol46 = IF pc_gera_criticas_proces_wt.pr_flgsol46 = 1 THEN TRUE ELSE FALSE       
       aux_flgsol57 = IF pc_gera_criticas_proces_wt.pr_flgsol57 = 1 THEN TRUE ELSE FALSE
       aux_flgsol59 = IF pc_gera_criticas_proces_wt.pr_flgsol59 = 1 THEN TRUE ELSE FALSE
       aux_flgsol80 = IF pc_gera_criticas_proces_wt.pr_flgsol80 = 1 THEN TRUE ELSE FALSE.

ASSIGN par_nrsequen = aux_nrsequen.

/** descarregar work table na temp table **/
FOR EACH wt_critica_proces 
      BY nrsequen:

   CREATE w_criticas.
   ASSIGN w_criticas.nrsequen = wt_critica_proces.nrsequen
          w_criticas.cdsitexc = wt_critica_proces.cdsitexc
          w_criticas.dscritic = wt_critica_proces.dscritic
          w_criticas.cdagenci = wt_critica_proces.cdagenci.
END. 

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").

/* .......................................................................... */

