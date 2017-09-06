/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps005.p                | pc_crps005                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/





/*** Campo saldo ci listado no relatorio crrl006_99.lst nao confere com o
     relatorio crrl400.lst rodado pelo programa crps429.p que lista o saldo
     da conta investimento. Motivo = crrl006 trabalha em cima do saldo em conta      
     corrente do cooperado, entao se o mesmo nao possuir saldos nos campos
     crapsld e nenhum emprestimo aberto tipo micro credito o programa crps005
     despreza o cooperado e passa para o proximo. Ja o crps429 lista todos os
     saldos parados la, independente se o cooperado tem saldo em conta corrente
     ou nao. ***/
/* ...........................................................................

   Programa: Fontes/crps005.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/91.                    Ultima atualizacao: 01/09/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 002
               Listar os relatorios de saldos.

   Alteracoes: 04/01/2000 - Nao gerar pedido de impressao (Deborah).
                            Alterado diretorio /micros.

               24/01/2000 - Tratar pedidos de impressao para a laser (Deborah).

               28/01/2000 - Gerar pedido do relatorio 225 para laser (Deborah).
               
               17/07/2000 - Alterar historicos contabeis (Odair)

               11/10/2000 - Alterar para 20 posicoes fone (Margarete/Planner).
               
               27/03/2001 - Desconsiderar o saldo bloqueado na listagem de 
                            negativos dos funcionarios/conselheiros (Deborah).
                            
               24/04/2001 - Alterado o centro de custos para apenas 2 casas 
                            (Edson).
 
               06/06/2001 - Modificacao dos lancamentos de adiantamentos 
                            a depositantes (Deborah).
                            
               13/06/2002 - Modificar o tamanho do PAGE-SIZE de 84 p/ 80
                            (Ze Eduardo).

               07/03/2003 - Alterado relatorio 225 para 1 via (Deborah).

               22/07/2003 - Alterado para nao somar o limite de credito no 
                            total do utilizado se estiver em CL (Deborah).  
                            
               12/08/2003 - Mudanca no calculo do utilizado (Deborah).
               
               12/09/2003 - No relatorio 030, foi adicionado o total por PAC
                            (Fernando).

               15/12/2003 - Alterado para nao gerar mais lancamentos   
                            contabeis de Conta Corrente (Mirtes).

               06/01/2004 - Alterado resumo(rel.) composicao saldos(Mirtes)  
 
               01/03/2004 - Alterado p/nao gerar lancamento Adiant.Depos(Mirtes)

               02/03/2004 - Alterado para qdo Saldos Cheques Admnistrativos 
                            /Cheque Esp. zerados, nao gerar movto(Mirtes)
                            
               22/04/2004 - Acrescentar mais uma via no rel. 225 (Eduardo)
               
               16/08/2004 - REFORMULACAO DE TODO O PROGRAMA (Ze Eduardo).

               09/09/2004 - Inclusao do campo "DD" no relatorio "crrl030"
                            (Julio)
                            
               24/09/2004 - Inclusao do saldo da conta investimento (Evandro).
                          
               29/09/2004 - Gravacao de dados na tabela gntotpl e gninfpl 
                            do banco generico, para relatorios gerenciais
                            (Junior).

               01/10/2004 - Implementeado rel.372(Saldos Conta Investimento)
                            (Mirtes)
 
               16/11/2004 - Implementado o saldo do MICRO-CREDITO (Edson).

               02/12/2004 - Efetuar contabilizacao diferenciada para a CECRED
                            (Edson).
                            
               06/12/2004 - Alteracao do arquivo para Contabilidade (Ze).
               
               17/02/2005 - Incluidos tipos de conta Integracao(12/13/14/15)
                                                           (Mirtes).

               21/02/2005 - Incluido PAC e totais por PAC no relatorio 55
                            (Edson).
               
               29/03/2005 - Rel. Ger.: Adicionar campo para armazenar valor de
                            cheque administrativo (Junior).
                            
               11/04/2005 - Rel. Ger.: Gravacao de dados por PAC, substituindo
                            gravacao de dados por Cooperativa (Junior).
                            
               22/04/2005 - Acerto na gravacao do campo gninfpl.vltotsdb, para
                            Relatorios Gerenciais (Junior).
                
               20/05/2005 - Mudado o crrl055 para gerar por PAC(Evandro).

               20/07/2005 - Script CriaPDF.sh nao respeitar o crapvia (Julio)
               
               11/08/2005 - Alterado para mostrar separadamnete no relatorio
                            225 os Estouros de contas com tipo de vinculo      
                            diferente de Cooperado (Diego).

               16/08/2005 - Alterado para exibir no final do relatorio 225  
                            o numero do PAC ao lado do nome (Diego). 
                      
                                  
               01/09/2005 - Somente calcular saldo emprestimo quando nao for
                            processo mensal(Mirtes)

               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               03/10/2005 - Alterado para imprimir apenas 1 copia do relatorio
                            225 para CredCrea (Diego).

               14/10/2005 - Alterado relatorio 225 para informar quando nao
                            houver registros na RELACAO DE ESTOUROS
                            (FUNCION./ESTAGIAR./CONSELH.)(Diego).
               19/10/2005 - Qdo relacao estouros funcionarios/estag/conselh.
                            assumir valor de referencia 0.01(Mirtes)

               24/11/2005 - Enviar para a CECRED relatorio crrl225.lst quando
                            houver estouro de conta dos funcionarios da CECRED
                            (Edson).

               09/12/2005 - Acrescentado listagem de saldos conta poupanca > 4
                            no relatorio crrl007 (Diego).
                            
               28/03/2006 - Retirar a verificacao no crapvia, para copia dos
                            relatorios para o servidor Web (Junior).

               12/04/2006 - Alterado valor(parametro) dos SALDOS CONTA
                            POUPANCA da Viacredi, para buscar >= 15 (Diego).
                            
               16/05/2006 - Alterado numero de vias dos relatorios crrl030 e
                            crrl225 para Viacredi (Diego).
                            
               30/05/2006 - Alterado numero de vias do relatorio crrl225 para
                            Viacredi (Elton).
               
               31/05/2006 - Desenvolver o Gerencial a Credito e a Debito (Ze).
               
               06/06/2006 - Alimentar o campo cdcooper das tabelas:
                            craptab, crapage, crapass, crapsld, craplcm,
                            crapsli, crapepr (David).

               23/06/2006 - Incluido campo de observacao no relatorio crrl007.
                            
               30/06/2006 - Ajustes para melhorar a performance na leitura do
                            crapsli (Edson).

               21/07/2006 - Incluido condicao glb_cdcooper <> 1 nas linhas 938
                            e 940 (David). 

               16/04/2007 - Leitura da tabela craptfc para impressao de
                            telefones (David).
 
               28/08/2007 - Tratar historicos de micro creditos pelo novo campo
                            cdusolcr (Guilherme). 

               04/09/2007 - Ler crapepr no inicio para nao desprezar contas
                            com micro credito (Magui).
                            
               11/10/2007 - Mostrar total fisica e juridica por linha
                            e emprestimos atrasados a mais de um ano(Guilherme)
                            
               06/12/2007 - Mostrar saldo atualizado na listagem dos           
                            emprestimos atrasados a mais de um ano (Magui).

               28/12/2007 - Somente gerar relatorio geral crrl055_99 quando
                            existirem os relatorios por pac (David).

               02/01/2008 - Tratamento na geracao do relatorio geral 
                            crrl055_99 (David).
       
               21/02/2008 - Mostrar turno da crapttl.cdturnos (Gabriel)
                          - Separar linhas de credito PNMPO (Evandro).

               18/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                            
               17/06/2008 - Detalhamento das linhas PNMPO crrl006(Guilherme);
                          - Incluidas informacoes COMP DIA BB e COMP DIA
                            BANCOOB no relatorio crrl007 (Evandro).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               12/11/2008 - Melhoria de performance na craplcm (Evandro).

               02/09/2009 - Aumentar formato de vlcompbb e vlcmpbcb da tabela
                            crat007 para nao estourar (Gabriel).
                            
               20/11/2009 - Considera linhas de micro-credito que contenham na
                            descricao "BNDES", como sendo PNMPO (Elton).   
                            
               03/03/2010 - Aumentar formato do geral do saldo total do
                            crrl007 (Gabriel)
                            Alterar a leitura da craplcm para os cheques
                            compensados do dia .    
                            
               16/03/2010 - Alterado para ordenar os saldos por origem do
                            recurso. (gati - Daniel)   
                            
               29/04/2010 - Alterado para incluir totais por origem do 
                            recurso. (gati - Sandro)

[B               23/08/2010 - Inclusao cheques CECRED no campo OBS referente
                            ao saldo devedor (Ze).
                            
               06/09/2010 - Gerar crapbnd com informacoes contidas no                                      
                            relatorio crrl006. Tarefa 34668 (Henrique).
               
               04/01/2011 - Acertar atualizacao do crapbnd (Magui).
               
               20/01/2011 - Criado novo form f_titulo_saldisp (Adriano)
               
               28/01/2011 - Criar crapbnd quebrando por nrdconta (Guilherme).
               
               02/02/2011 - Alteracao do format dos campos de limite (Henrique)
               
               06/05/2011 - Nao criar quebra de conta do BNDES na CECRED pois 
                            esta sendo criado nas singulares (Guilherme).
                            
               06/05/2011 - Mudanca no layout do crrl007. Retirar os 
                            comentarios desnecessarios (Gabriel)  
                            
               26/05/2011 - Ajuste na listagem do crrl007 (Gabriel)   
               
               08/06/2011 - Ajuste na leitura da crapcst (Gabriel).
               
               19/07/2011 - Alterado para emissao 1 via relatorio 225(Mirtes)
               
               27/07/2011 - Desprezar lanc. do hist. 21 ou 26 e lote 4500 - 
                            relatorio crrl007 - Tarefa 41352 (Ze).
                            
               11/11/2011 - Alterações para gerar arquivo .txt com cópia do
                            relatório crrl007 em micros/viacredi/Tiago
                            (Oscar/Lucas).
               
               05/01/2012 - Renomeado arquivo "crrl005" para "slddev" (Tiago).
               
               13/01/2012 - Melhoria de desempenho (Gabriel).
               
               14/05/2012 - Incluido tratamento de LOCK na atualizacao do 
                            registro da tabela crapbnd. (Fabricio)
                            
               21/06/2012 - Substituido gncoper por crapcop (Tiago).             
               
               23/11/2012 - Alterado para tratar o novo emprestimo no include
                            crps398.i incluido rotina para calculo de dias em
                            atraso. (Oscar) 
                            
               15/03/2013 - Removido email do Tavares e incluído emails do
                            Jose Carlos e Ricardo para recebimento do 
                            relatorio 225. (Irlan)       
                            
               05/04/2013 - No relatorio crrl006_99 incluido form para listar
                            contratos que estao em atraso ate 59 dias.
                          - Incluir novo stream que gera arquivo em txt com
                            informacoes dos contratos (Lucas R.).
                           
               06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                           
               01/09/2017 - Inclusao de log de fim de execucao do programa 
                            (Carlos)
                           
..............................................................................*/

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }


ASSIGN glb_cdprogra = "crps005"
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

RUN STORED-PROCEDURE pc_crps005 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps005 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps005.pr_cdcritic WHEN pc_crps005.pr_cdcritic <> ?
       glb_dscritic = pc_crps005.pr_dscritic WHEN pc_crps005.pr_dscritic <> ?
       glb_stprogra = IF pc_crps005.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps005.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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
                  
{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS005.P",
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


