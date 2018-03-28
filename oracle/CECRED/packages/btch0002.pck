CREATE OR REPLACE PACKAGE CECRED.btch0002 AS

  /*---------------------------------------------------------------------------------------------------------------
  
   Programa : BTCH0002
    Sistema : Processos Batch
    Sigla   : BTCH
    Autor   : Odirlei Busana - AMcom
    Data    : Maio/2014.                       Ultima atualizacao: 01/02/2017
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Agrupar rotinas do processamento pre-batch
  
  
   Alteracoes: 16/06/2016 - Correcao para o uso correto do indice da CRAPTAB na
                            procedure pc_gera_criticas_proces.(Carlos Rafael Tanholi).      
  
               23/06/2016 - Correcao no cursor da crapbcx utilizando o indice correto
                            sobre o campo cdopecxa.(Carlos Rafael Tanholi). 
                            
               01/02/2017 - Ajustes para consultar dados da tela PROCES de todas as cooperativas
                            (Lucas Ranghetti #491624)                
  ---------------------------------------------------------------------------------------------------------------*/

  /* Tipo para armazenamento as criticas identificadas */
  TYPE typ_rec_criticas IS
    RECORD(dscritic VARCHAR2(150)
          ,cdsitexc INTEGER
          ,cdagenci INTEGER
          ,cdcooper INTEGER);
          
  TYPE typ_tab_criticas IS
    TABLE OF typ_rec_criticas
    INDEX BY PLS_INTEGER;
    
  TYPE typ_tab_moeda is varray(5) of varchar2(30);
  vr_tab_moeda typ_tab_moeda := typ_tab_moeda('6-CDI Anual','16-CDI Mensal','18-CDI Diario','8-Poupanca','11-TR'); 
  
  /* Tipo para armazenar valores carregados da craptab*/
  TYPE typ_tab_documentos IS
    TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;   
    
  -- Gerar criticas do processo
  PROCEDURE pc_gera_criticas_proces (pr_cdcooper       IN NUMBER,                 --> Codigo da cooperativa
                                     pr_cdagenci       IN crapage.cdagenci%type,  --> Codigo da agencia
                                     pr_cdoperad       IN crapope.cdoperad%type,  --> codigo do operador
                                     pr_nmdatela       IN crapprg.cdprogra%type,  --> Nome da tela                      
                                     pr_nmarqimp       IN VARCHAR2,               --> Nome do arquivo
                                     pr_choice         IN INTEGER,                --> Tipo de escolhe efetuado na tela
                                     pr_nrsequen       OUT NUMBER,                --> Numero sequencial
                                     pr_vldaurvs       IN OUT NUMBER,             --> Variavel para armazenar o valor do urv
                                     pr_flgsol16       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol27       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol28       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol29       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol30       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol37       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol46       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol57       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol59       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol80       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_tab_criticas   OUT typ_tab_criticas,      --> Retorna as criticas encontradas
                                     pr_cdcritic OUT crapcri.cdcritic%TYPE,       --> Critica encontrada
                                     pr_dscritic OUT VARCHAR2);                   --> Texto de erro/critica encontrada             
                                     
                                     
  -- Gerar criticas do processo e gravar retorno na work table, para conseguir utilizar no progress
  PROCEDURE pc_gera_criticas_proces_wt(pr_cdcooper       IN NUMBER,                 --> Codigo da cooperativa
                                       pr_cdagenci       IN crapage.cdagenci%type,  --> Codigo da agencia
                                       pr_cdoperad       IN crapope.cdoperad%type,  --> codigo do operador
                                       pr_nmdatela       IN crapprg.cdprogra%type,  --> Nome da tela                      
                                       pr_nmarqimp       IN VARCHAR2,               --> Nome do arquivo
                                       pr_choice         IN INTEGER,                --> Tipo de escolhe efetuado na tela
                                       pr_nrsequen       OUT NUMBER,                --> Numero sequencial                                     
                                       pr_vldaurvs       IN OUT NUMBER,             --> Variavel para armazenar o valor do urv
                                       pr_flgsol16       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol27       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol28       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol29       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol30       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol37       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol46       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol57       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol59       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol80       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_cdcritic OUT crapcri.cdcritic%TYPE,       --> Critica encontrada
                                       pr_dscritic OUT VARCHAR2);                   --> Texto de erro/critica encontrada                                     
    
END btch0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.btch0002 AS

/*---------------------------------------------------------------------------------------------------------------
  
    Programa : BTCH0002
    Sistema : Processos Batch
    Sigla   : BTCH
    Autor   : Odirlei Busana - AMcom
    Data    : Maio/2014.                       Ultima atualizacao: 28/03/2018
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Agrupar rotinas do processamento pre-batch
  
   Alteracoes: 16/06/2016 - Correcao para o uso correto do indice da CRAPTAB na
                            procedure pc_gera_criticas_proces.(Carlos Rafael Tanholi).   
  
               23/06/2016 - Correcao no cursor da crapbcx utilizando o indice correto
                            sobre o campo cdopecxa.(Carlos Rafael Tanholi). 
                            
               01/02/2017 - Ajustes para consultar dados da tela PROCES de todas as cooperativas
                            (Lucas Ranghetti #491624)
  
               28/04/2017 - Adicionar chmod 666 apos a chamada do pc_clob_para_arquivo
                            para ter permissao de exclusao do arquivo ao rodar novamente 
                            a tela process ref ao chamado 491624(Lucas Ranghetti/Elton)
                            
               07/07/2017 - Adicionar Order by na consulta da tabela crapbcx, pois estava
                            ordenando pelo operador ao inves de ordear pelo PA (Lucas Ranghetti #701329)
                            
               14/09/2017 - Incluido mais uma condição para verificar se deve 
                            solicitar calculo do retorno das Sobras
                            na procedure pc_gera_criticas_proces (Tiago/Thiago M439)               
                            
               05/03/2018 - Alterado parametros de critica para não solicitar o processo
                            quando as moedas(6,16,17,18) não estiverem cadastradas (Tiago/Adriano)
                            
               28/03/2017 - Alterado rotina para deixar de criticar as moedas que não tem relevancia para
                            o processo noturno (Tiago/Adriano).
  ---------------------------------------------------------------------------------------------------------------*/
  -- Gerar criticas do processo
  PROCEDURE pc_gera_criticas_proces (pr_cdcooper       IN NUMBER,                 --> Codigo da cooperativa
                                     pr_cdagenci       IN crapage.cdagenci%type,  --> Codigo da agencia
                                     pr_cdoperad       IN crapope.cdoperad%type,  --> codigo do operador
                                     pr_nmdatela       IN crapprg.cdprogra%type,  --> Nome da tela                      
                                     pr_nmarqimp       IN VARCHAR2,               --> Nome do arquivo
                                     pr_choice         IN INTEGER,                --> Tipo de escolhe efetuado na tela
                                     pr_nrsequen       OUT NUMBER,                --> Numero sequencial
                                     pr_vldaurvs       IN OUT NUMBER,             --> Variavel para armazenar o valor do urv
                                     pr_flgsol16       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol27       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol28       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol29       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol30       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol37       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol46       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol57       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol59       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_flgsol80       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                     pr_tab_criticas   OUT typ_tab_criticas,      --> Retorna as criticas encontradas
                                     pr_cdcritic OUT crapcri.cdcritic%TYPE,       --> Critica encontrada
                                     pr_dscritic OUT VARCHAR2) IS                 --> Texto de erro/critica encontrada
  
  /* .............................................................................

   Programa: Fontes/gera_criticas_proces.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Margarete/Mirtes
   Data    : Junho/2004.                     Ultima atualizacao: 14/09/2017

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
                            útil do mes.  Se for, verifica se os valores de 
                            taxa estao cadastrados para os tipo: 
                            6-CDI Anual, 8-Poupança, 11-TR, 16-CDI Mensal 
                            (Handrei - RKAM)              
                            
               29/12/2011 - Nao cancelar a sol. do processo quando ha lotes de 
                            requisicao de cheques nao batido (Ze).
                            
               30/03/2012 - Desprezar o CDI DIARIO (no crpamfx) se o ultimo dia
                            do mes for no final de semana (Ze).
                            
               05/04/2012 - Ajuste das situaçoes que ultilizam o campo "crap.dstextab"
                            sem o registro estar AVAILABLE.
                            (David Kruger).
                            
               24/04/2012 - Incluído críticas para borderos e limites de cheques/titulos
                            sem documento digitalizado(Guilherme Maba).
               
               21/06/2012 - substituiçao do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)             
                            
               29/06/2012 - Ajuste no ver_ctace.p (Ze).
               
               11/09/2012 - Alteracao de 24/04 somente com glb_dtmvtoan 
                            (Guilherme).
                            
               15/01/2013 - Retiradas (comentadas) criticas para borderos e limites
                            de cheques/titulos nao digitalizados 
                           (Daniele).
               
               14/08/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                           
               28/01/2014 - Alterado o parametro de data para validaçao de borderos
                            (Jean Michel).     
                           
               04/02/2014 - Inclusão de tratamento p/ taxa TR e SELIC Meta (Jean Michel)
               
               12/05/2014 - Ajuste na critica TAXRDC (Ze).
               
               26/05/2014 - Conversão Progress --> Oracle (Odirlei-AMcom)    
               
               27/06/2014 - Exclusao da geracao de solicitacao 29.
                            (Tiago Castro - RKAM)    
               
               06/08/2014 - Incluido criticas para novos produtos de captacao. (Reinert)			
               
               05/01/2015 - Ajuste erro conversão, ajuste solicitação 
                            de correção monetaria solicitar até abril.(Odirlei-AMcom)				 
														
							 10/02/2015 - Alterado para ignorar a data cadastrada na leitura da
							              tabela de parâmetros 'EXEICMIRET' (Reinert)
														
               23/08/2016 - M360 - Verificação de novos percentuais de retorno de 
                            Sobras para ativação da flag sol30 (Marcos-Supero)
               														
               01/02/2017 - Ajustes para consultar dados da tela PROCES de todas as cooperativas
                            (Lucas Ranghetti #491624)
                            
               28/04/2017 - Adicionar chmod 666 apos a chamada do pc_clob_para_arquivo
                            para ter permissao de exclusao do arquivo ao rodar novamente 
                            a tela process (Lucas Ranghetti/Elton)
                            
               07/07/2017 - Adicionar Order by na consulta da tabela crapbcx, pois estava
                            ordenando pelo operador ao inves de ordear pelo PA (Lucas Ranghetti #701329)
                            
               14/09/2017 - Incluido mais uma condição para verificar se deve 
                            solicitar calculo do retorno das Sobras(Tiago/Thiago M439)
                            
               05/03/2018 - Alterado parametros de critica para não solicitar o processo
                            quando as moedas(6,16,17,18) não estiverem cadastradas (Tiago/Adriano)
  ..............................................................................*/  
    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.dsdircop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- buscar Valor moeda fixa usada pelo sistema.
    CURSOR cr_crapmfx(pr_cdcooper crapcop.cdcooper%type,
                      pr_dtmvtolt DATE,
                      pr_tpmoefix crapmfx.tpmoefix%type) IS
      SELECT vlmoefix
        FROM crapmfx
       WHERE crapmfx.cdcooper = pr_cdcooper
         AND crapmfx.dtmvtolt = pr_dtmvtolt
         AND crapmfx.tpmoefix = pr_tpmoefix;
    rw_crapmfx  cr_crapmfx%rowtype;       
    
    -- Buscar agencias
    CURSOR cr_crapage (pr_cdcooper crapcop.cdcooper%type) IS
      SELECT age.cdagenci
            ,age.nmextage
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper;
       
    -- Verificar se agencia contem lancamentos pendentes
    CURSOR cr_craplau (pr_cdcooper crapcop.cdcooper%type,
                       pr_cdagenci crapage.cdagenci%type,
                       pr_dtmvtolt DATE)IS
      SELECT 1
        FROM craplau
       WHERE craplau.cdcooper = pr_cdcooper
         AND craplau.dsorigem = 'INTERNET'
         AND craplau.cdagenci = pr_cdagenci
         AND craplau.cdbccxlt = 100
         AND craplau.nrdolote = 11900
         AND craplau.dtmvtopg = pr_dtmvtolt
         AND craplau.insitlau = 1 /* PENDENTE */
         AND rownum < 2; -- somente precisa achar 1
    rw_craplau cr_craplau%rowtype;     
    
    
    -- Verificar se agencia contem titulo recebido de outros bancos
    CURSOR cr_craptit (pr_cdcooper crapcop.cdcooper%type,
                       pr_cdagenci crapage.cdagenci%type,
                       pr_dtmvtolt DATE)IS
      SELECT 1
        FROM craptit
       WHERE craptit.cdcooper = pr_cdcooper
         AND craptit.dtdpagto = pr_dtmvtolt
         AND craptit.cdagenci = pr_cdagenci
         AND craptit.intitcop = 0 --0=outros bancos
         AND rownum < 2; -- somente precisa encontra 1
    rw_craptit cr_craptit%rowtype;     
    
    -- Verificar se agencia contem docs a serem enviados
    CURSOR cr_craptvl (pr_cdcooper crapcop.cdcooper%type,
                       pr_cdagenci crapage.cdagenci%type,
                       pr_dtmvtolt DATE)IS
      SELECT 1
        FROM craptvl
       WHERE craptvl.cdcooper = pr_cdcooper
         AND craptvl.dtmvtolt = pr_dtmvtolt
         AND craptvl.flgenvio = 0 --false
         AND craptvl.cdagenci = pr_cdagenci
         AND craptvl.tpdoctrf in (1,2) -- 1 e 2 = DOC
         AND rownum < 2; -- somente precisa encontra 1
    rw_craptvl cr_craptvl%rowtype;   
    
    -- Verificar se agencia contem teds a serem enviados
    CURSOR cr_craptvl_2 (pr_cdcooper crapcop.cdcooper%type,
                         pr_cdagenci crapage.cdagenci%type,
                         pr_dtmvtolt DATE)IS
      SELECT 1
        FROM craptvl
       WHERE craptvl.cdcooper = pr_cdcooper
         AND craptvl.dtmvtolt = pr_dtmvtolt
         AND craptvl.flgenvio = 0 --false
         AND craptvl.cdagenci = pr_cdagenci
         AND craptvl.tpdoctrf = 3 -- 3 = TED
         AND rownum < 2; -- somente precisa encontra 1
    
    -- Verificar se agencia contem lancamentos das 
    -- Guias da Previdencia Social a serem enviados
    CURSOR cr_craplgp (pr_cdcooper crapcop.cdcooper%type,
                       pr_cdagenci crapage.cdagenci%type,
                       pr_dtmvtolt DATE)IS
      SELECT 1
        FROM craplgp
       WHERE craplgp.cdcooper = pr_cdcooper
         AND craplgp.dtmvtolt = pr_dtmvtolt
         AND craplgp.cdagenci = pr_cdagenci
         AND craplgp.flgenvio = 0 --FALSE
         AND rownum < 2; -- somente precisa encontra 1
    rw_craplgp cr_craplgp%rowtype;    
    
    /* Verifica se os pagamentos do INSS-BANCOOB foram enviados */
    CURSOR cr_craplbi (pr_cdcooper crapcop.cdcooper%type,
                       pr_cdagenci crapage.cdagenci%type)IS
      SELECT 1
        FROM craplbi
       WHERE craplbi.cdcooper = pr_cdcooper
         AND craplbi.cdagenci = pr_cdagenci
         AND craplbi.dtdenvio is null
         AND craplbi.dtdpagto is not null
         AND rownum < 2; -- somente precisa encontra 1
    rw_craplbi cr_craplbi%rowtype;   
    
    -- Buscar aplicacoes RDCA por periodo
    CURSOR cr_craprda_2(pr_cdcooper crapcop.cdcooper%type,
                        pr_dtiniper DATE) IS
      SELECT dtfimper
        FROM craprda
       WHERE craprda.cdcooper = pr_cdcooper
         AND craprda.dtfimper = pr_dtiniper
         AND craprda.incalmes = 0  -- Não calcularo
         AND craprda.tpaplica = 3  -- RDCA
         AND craprda.insaqtot = 0; -- Sem saque total
    rw_craprda_2 cr_craprda_2%rowtype;   
    
    -- Buscar taxas.
    CURSOR cr_craptrd(pr_cdcooper crapcop.cdcooper%type,
                      pr_dtfimper DATE,
                      pr_tptaxrda craptrd.tptaxrda%type) IS
      SELECT 1
        FROM craptrd
       WHERE craptrd.cdcooper = pr_cdcooper
         AND craptrd.dtiniper = pr_dtfimper
         AND craptrd.tptaxrda = pr_tptaxrda
         AND craptrd.incarenc = 0 -- Sem carencia
         AND craptrd.vlfaixas = 0;
    rw_craptrd cr_craptrd%rowtype;    
    
    -- Buscar poupanca programada.
    CURSOR cr_craprpp(pr_cdcooper crapcop.cdcooper%type,
                      pr_dtmvtolt DATE,
                      pr_tipo     VARCHAR2,
                      pr_incalmes craprpp.incalmes%type default null) IS
      SELECT decode(pr_tipo, 'I',dtiniper,'F',dtfimper) dtperiodo
        FROM craprpp
       WHERE craprpp.cdcooper  = pr_cdcooper
         -- filtrar conforme o inficador se quer data inicio ou fim do periodo
         AND decode(pr_tipo, 'I',craprpp.dtiniper,'F',craprpp.dtfimper) <= pr_dtmvtolt
         AND craprpp.incalmes = nvl(pr_incalmes,craprpp.incalmes)
         GROUP BY decode(pr_tipo, 'I',dtiniper,'F',dtfimper)
         ORDER BY decode(pr_tipo, 'I',dtiniper,'F',dtfimper);
    
    -- Buscar Capas de lotes de requisicoes, que possuem diferenças
    CURSOR cr_craptrq(pr_cdcooper crapcop.cdcooper%type) IS
      SELECT nrdolote,
             cdagelot
        FROM craptrq
       WHERE craptrq.cdcooper  = pr_cdcooper
         AND NOT (craptrq.qtinforq = craptrq.qtcomprq AND
                  craptrq.qtinfotl = craptrq.qtcomptl); 
    
    -- Buscar Boletim de caixa ABERTO
    CURSOR cr_crapbcx (pr_cdcooper crapcop.cdcooper%type,
                       pr_dtmvtolt DATE) IS
      SELECT crapbcx.cdopecxa,
             crapbcx.cdagenci,
             crapbcx.nrdcaixa,
             crapope.nmoperad
        FROM crapbcx, crapope
       WHERE crapbcx.cdcooper = pr_cdcooper
         AND crapbcx.dtmvtolt = pr_dtmvtolt
         AND crapope.cdcooper = pr_cdcooper        
         AND crapope.cdcooper = crapbcx.cdcooper        
         AND upper(crapope.cdoperad) = upper(crapbcx.cdopecxa)
         AND crapbcx.cdsitbcx = 1
         /* Nao considera se o caixa da INTERNET ou TAA estiver aberto, pois ele sao
            fechados durante o processo */
         AND NOT (crapbcx.cdagenci IN (90, 91) AND /** TAA **/
                  crapbcx.nrdcaixa = 900 AND upper(crapbcx.cdopecxa) = '996')
       ORDER BY crapbcx.cdcooper, 
                crapbcx.cdagenci, 
                crapbcx.nrdcaixa;
                 
    -- Buscar lotes
    CURSOR cr_craplot (pr_cdcooper crapcop.cdcooper%type,
                       pr_dtmvtolt DATE) IS
      SELECT tplotmov,
             cdbccxlt,
             nrdcaixa,
             nrdolote,
             cdagenci,
             qtcompln,
             vlcompdb,
             vlcompcr,
             qtinfoln,
             vlinfodb,
             vlinfocr,
             qtcompcc,
             vlcompcc,
             qtinfocs,
             vlinfocs,
             qtinfoci,
             vlinfoci,
             qtinfocc,
             vlinfocc,
             qtcompcs,
             vlcompcs,
             qtcompci,
             vlcompci
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtmvtolt;
     
    -- Buscar informacoes de alteracoes de conta, 
    -- que não possuem o numero de conta na crapass
    CURSOR cr_crapact (pr_cdcooper crapcop.cdcooper%type,
                       pr_dtmvtolt DATE) IS
      SELECT nrdconta
        FROM crapact
       WHERE crapact.cdcooper = pr_cdcooper
         AND crapact.dtalttct = pr_dtmvtolt
         AND crapact.cdtctant IN ('5','6')
         AND crapact.cdtctatu NOT IN (5,6)
         -- Verificar se não existe na crapass
         AND NOT EXISTS (SELECT 1
                           FROM crapass 
                          WHERE crapass.cdcooper = pr_cdcooper     
                            AND crapass.cdcooper = crapact.cdcooper
                            AND crapass.nrdconta = crapact.nrdconta);
         
    -- Buscar cadastro do associado
    CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%type) IS
      SELECT nrdconta,
             cdagenci,
             vllimcre
        FROM crapass 
       WHERE crapass.cdcooper = pr_cdcooper          
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;
    
    -- Buscar registros ma tabela de cadastros genericos
    CURSOR cr_craptab (pr_cdcooper crapcop.cdcooper%type,
                       pr_cdacesso craptab.cdacesso%type) IS
      SELECT dstextab,
             tpregist 
        FROM craptab
       WHERE craptab.cdcooper = pr_cdcooper
         AND UPPER(craptab.nmsistem) = 'CRED'
         AND UPPER(craptab.tptabela) = 'GENERI'
         AND craptab.cdempres = 00
         AND UPPER(craptab.cdacesso) = pr_cdacesso;
    
    -- Buscar controle de movimentacao em especie
    CURSOR cr_crapcme (pr_cdcooper crapcop.cdcooper%type,
                       pr_dstextab craptab.dstextab%type) IS
      SELECT ROWID
            ,nrdconta
        FROM crapcme crapcme
       WHERE crapcme.cdcooper = pr_cdcooper
         AND crapcme.tpoperac > 0
         AND crapcme.vllanmto >= to_number(pr_dstextab)
         AND crapcme.infrepcf = 1
         AND crapcme.nrdconta <> 0
       ORDER BY CDCOOPER
               ,DTMVTOLT
               ,CDAGENCI
               ,CDBCCXLT
               ,NRDOLOTE
               ,NRDCTABB
               ,NRDOCMTO;
                               
	  -- Buscar todos os produtos de captação cadastrados
	  CURSOR cr_crapcpc IS 
		  SELECT cpc.cdprodut
			      ,cpc.cddindex
			      ,cpc.nmprodut
				FROM crapcpc cpc;
		rw_crapcpc cr_crapcpc%ROWTYPE;
		
		-- Verificar se existe alguma aplicação ativa para o produto cadastrado
		CURSOR cr_craprac (pr_cdcooper IN crapcop.cdcooper%TYPE,
		                   pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
			SELECT DISTINCT 1
			 FROM craprac rac
			WHERE rac.cdcooper = pr_cdcooper
			  AND rac.cdprodut = pr_cdprodut
				AND rac.idsaqtot = 0;
		rw_craprac cr_craprac%ROWTYPE;
		-- Busca indexadores de remuneração cadastrados
		CURSOR cr_crapind(pr_cddindex crapind.cddindex%TYPE) IS 
		  SELECT ind.cddindex
			      ,ind.nmdindex
						,ind.idperiod
				FROM crapind ind
			 WHERE ind.cddindex = pr_cddindex;
		rw_crapind cr_crapind%ROWTYPE;	 			 
		-- 	Buscar taxa de indexadores de remuneração
		CURSOR cr_craptxi(pr_cddindex craptxi.cddindex%TYPE
		                 ,pr_dtiniper craptxi.dtiniper%TYPE
										 ,pr_dtfimper craptxi.dtfimper%TYPE) IS 
		  SELECT 1
			  FROM craptxi txi
			 WHERE txi.cddindex = pr_cddindex
			   AND txi.dtiniper = pr_dtiniper
				 AND txi.dtfimper = pr_dtfimper;
		rw_craptxi cr_craptxi%ROWTYPE;
				 
                               
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

    ------------------------------- VARIAVEIS -------------------------------
    -- Nome do arquivo de limpeza
    vr_nmarqlmp VARCHAR2(500) := 'arquivos/.limpezaok';
    -- Nome do diretorio da cooperativa
    vr_nmdireto VARCHAR2(500);
    vr_nmdiretM VARCHAR2(500);
    vr_nmarqimp VARCHAR2(500);
    -- Descriçaõ de criticas encontradas
    vr_dscritic VARCHAR2(5000);
    -- identificador se existe erro
    vr_des_erro VARCHAR2(5000);
    -- Tab de erro
    vr_tab_erro   GENE0001.typ_tab_erro;
    --varaiaveis para validar os dias da limpeza
    vr_dtavisos DATE;
    vr_qtdiasut INTEGER;
    -- variavel para armazenar valor da tabela generica
    vr_dstextab craptab.dstextab%type;    
    --variaveis para varrer determinado periodo
    vr_dtfimper DATE;
    vr_dtiniper DATE;
    -- Lista das contas centralizadoras
    vr_lscontas VARCHAR2(1000);
    -- Numero da conta de retorno
    vr_nrctaret VARCHAR2(5000);
    -- Variavel de controle indicando se deve cancelar solicitação
    vr_cancsoli INTEGER := 0;
    --Lista de arquivos
    vr_listarq  VARCHAR2(20000);
    -- Temp-Table com o saldo do dia
    vr_tab_sald EXTR0001.typ_tab_saldos;   
    -- Temp-Table com o extrato da conta
    vr_tab_extr EXTR0001.typ_tab_extrato_conta;
    -- Chave da tabela Dta + Sequencia
    vr_ind_ext VARCHAR2(12); 
    -- Temp-Table de valores dos docuemntos
    vr_tab_documentos typ_tab_documentos;
    -- Total de saldo
    vr_vlsalbol NUMBER;
    -- Lista dos historicos
    vr_lshistor VARCHAR2(5000);
    -- Variáveis para armazenar as informações em XML
    vr_des_clob        clob;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  varchar2(32600);
    -- Indice da temp-table
    vr_idxcme   PLS_INTEGER;
    -- Temp-Table crapcme
    vr_tab_crapcme CTME0001.typ_tab_crapcme;
    -- Data de liberação carregada da craptab
    vr_datliber DATE;
    -- Flag de controle   
    vr_flgaprdc BOOLEAN := FALSE;
    vr_flgaprpp BOOLEAN := FALSE;
    
		-- Data do período do indexador
		vr_dtperiod DATE;
    
    vr_flexecut BOOLEAN := FALSE;
    
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB
    procedure pc_escreve_clob(pr_des_dados in varchar2,
                              pr_fecha_clob in boolean default false) is
    begin
      gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo, pr_des_dados, pr_fecha_clob);
    end;
      
    -- Procedimento para gravar a critica na temptable
    PROCEDURE pc_grava_critica (pr_cdcooper INTEGER
                               ,pr_dscritic VARCHAR2
                               ,pr_cdsitexc INTEGER default null
                               ,pr_cdagenci INTEGER default null 
                               ,pr_cancsoli INTEGER default 1) IS
      vr_nrsequen PLS_INTEGER;
      
    BEGIN
      vr_nrsequen := nvl(pr_tab_criticas.count,0) + 1;
      pr_tab_criticas(vr_nrsequen).cdcooper := pr_cdcooper;           
      pr_tab_criticas(vr_nrsequen).dscritic := substr(pr_dscritic,1,150);
      pr_tab_criticas(vr_nrsequen).cdsitexc := pr_cdsitexc;     
      pr_tab_criticas(vr_nrsequen).cdagenci := pr_cdagenci;
      
      -- indicador se critica deve cancelar processamento
      IF pr_cancsoli = 1 THEN
        -- Se gerou ao menos uma critica, que deva cancelar, 
        -- retornar a quantidade de criticas que devem abortar no parametro pr_nrsequen  
        vr_cancsoli := nvl(vr_cancsoli,0) + 1;
      END IF;  
      
    END pc_grava_critica;  
    
    -- Procedimento para gravar a critica na temptable
    PROCEDURE pc_gera_log_proces (pr_cdcooper     crapcop.cdcooper%type,       
                                  pr_ind_tipo_log NUMBER,
                                  pr_des_log      VARCHAR2) IS
    BEGIN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => pr_ind_tipo_log,
                                 pr_nmarqlog     => 'proces' ,     
                                 pr_des_log      => TO_CHAR(sysdate,'dd/mm/rrrr hh24:mi:ss') ||
                                                    ' --> ' || pr_des_log);      
    END;    
                                              
    
  BEGIN
    -- Limpar parametro
    pr_tab_criticas.delete;
    
    -- Buscar diretorio da cooperativa
    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '');
    
    -- Buscar diretorio da cooperativa
    vr_nmdiretM := gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '');
                                        
    -- Validar data da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Cooperativa sem data de movimento');
    END IF;
    CLOSE btch0001.cr_crapdat;
    
    -- Validar processo
    IF rw_crapdat.inproces = 3 THEN
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Cooperativa com Processo solicitado ou ja rodando');
    END IF;  
    
    -- Validar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN      
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Nao encontrado cadastro da Cooperativa - Tela CADCOP');
    END IF;  
    CLOSE cr_crapcop;
    
    /*  Magui - para que? Verifica se for quinto dia util antes do final do mes,
     checar se foi solicitado o processo de LIMPEZA */
    IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmdireto||'/'||vr_nmarqlmp) THEN
      -- definir ultima data do mês
      vr_dtavisos := last_day(rw_crapdat.dtmvtolt);
      vr_qtdiasut := 0;
      -- validar os 5 dias
      WHILE vr_qtdiasut < 5 LOOP
        -- Verificar se é feriado ou final de semana
        IF gene0005.fn_valida_dia_util( pr_cdcooper => pr_cdcooper, 
                                        pr_dtmvtolt => vr_dtavisos, 
                                        pr_tipo     => 'P', 
                                        pr_feriado  => TRUE) = vr_dtavisos THEN
          -- se for dia util, somar 1
          vr_qtdiasut := vr_qtdiasut + 1;
        END IF; 
        
        -- se ainda não alcançou os 5 dias, diminuir 1
        IF vr_qtdiasut < 5  THEN
          vr_dtavisos := vr_dtavisos - 1;
        END IF;                                   
      END LOOP;  
      
    END IF;  
    
    -- Buscar parametro na tabela generica CONVERREAL
    vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                               pr_nmsistem => 'CRED', 
                                               pr_tptabela => 'GENERI', 
                                               pr_cdempres => 0, 
                                               pr_cdacesso => 'CONVERREAL', 
                                               pr_tpregist => 0);
                                               
    -- Definir valor URV
    IF TRIM(vr_dstextab) is null THEN
      pr_vldaurvs := 2750;
    ELSE
      pr_vldaurvs := to_number(vr_dstextab);
    END IF;  
    
    -- Validar URV
    IF rw_crapdat.dtmvtolt > to_date('06/30/1994','MM/DD/RRRR') AND
       pr_vldaurvs <> 2750.00 THEN
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Valor da URV cadastrado errado');
    END IF;   
    
    -- Validar agencias da cooperativa
    FOR rw_crapage IN cr_crapage(pr_cdcooper => pr_cdcooper) LOOP
      /* Verifica se agendamentos (pagamentos/transferencias) foram efetivados */
      OPEN cr_craplau (pr_cdcooper => pr_cdcooper,
                       pr_cdagenci => rw_crapage.cdagenci,
                       pr_dtmvtolt => rw_crapdat.dtmvtolt);
      FETCH cr_craplau INTO rw_craplau;
      IF cr_craplau%FOUND THEN
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Pa '||TO_CHAR(rw_crapage.cdagenci,'fm000')||
                                        ' nao debitou todos os seus agendamentos - Tela DEBNET');
      END IF;
      CLOSE cr_craplau;
      
      /* Verifica se foi gerado o arquivo de titulos recebidos */
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED', 
                                                 pr_tptabela => 'GENERI', 
                                                 pr_cdempres => 00, 
                                                 pr_cdacesso => 'HRTRTITULO', 
                                                 pr_tpregist => rw_crapage.cdagenci);
                                                 
      -- verificar se existe valor
      IF TRIM(vr_dstextab) is null THEN 
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Cadastrar horario fechamento de TITULOS do Pa '||
                                        TO_CHAR(rw_crapage.cdagenci,'fm000')||' - Tela TITULO');  
                                              
      ELSIF TO_NUMBER(SUBSTR(VR_dstextab,1,1)) <> 1 AND
            rw_crapdat.dtmvtolt <> to_date('31/12/2007','DD/MM/RRRR') THEN            
        /* Verifica se existem titulos recebidos de outro banco */
        OPEN cr_craptit (pr_cdcooper => pr_cdcooper,
                         pr_cdagenci => rw_crapage.cdagenci,
                         pr_dtmvtolt => rw_crapdat.dtmvtolt);
        FETCH cr_craptit INTO rw_craptit;
        IF cr_craptit%FOUND THEN
          pc_grava_critica(pr_cdcooper => pr_cdcooper,
                           pr_dscritic => ' - Pa '||TO_CHAR(rw_crapage.cdagenci,'fm000')||
                                          ' nao enviou todos os seus TITULOS - Tela TITULO',
                           pr_cdsitexc => 2,
                           pr_cdagenci => rw_crapage.cdagenci);                           
        END IF;
        CLOSE cr_craptit;
      END IF;
      /* Fim dos titulos */
      
      /* Verificar se DOC'S e TED'S foram transmitidos */
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED', 
                                                 pr_tptabela => 'GENERI', 
                                                 pr_cdempres => 00, 
                                                 pr_cdacesso => 'HRTRDOCTOS', 
                                                 pr_tpregist => rw_crapage.cdagenci);
                                                 
      -- verificar se existe valor
      IF TRIM(vr_dstextab) is null THEN    
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Cadastrar horario fechamento DOC/TED''S do Pa '||
                                        TO_CHAR(rw_crapage.cdagenci,'fm000')||' - Tela DOCTOS');  
                                              
      ELSE
        IF TO_NUMBER(SUBSTR(vr_dstextab,1,1)) <> 1 THEN /* DOC */ 
          -- Verificar se agencia contem docs a serem enviados
          OPEN cr_craptvl (pr_cdcooper => pr_cdcooper,
                           pr_cdagenci => rw_crapage.cdagenci,
                           pr_dtmvtolt => rw_crapdat.dtmvtolt);
          FETCH cr_craptvl INTO rw_craptvl;
          -- Se encontrou, gera critica
          IF cr_craptvl%FOUND THEN
            pc_grava_critica(pr_cdcooper => pr_cdcooper,
                             pr_dscritic => ' - Nao foram enviados todos os DOC''S do Pa '||
                                            TO_CHAR(rw_crapage.cdagenci,'fm000')||' - Tela DOCTOS',
                             pr_cdsitexc => 4,
                             pr_cdagenci => rw_crapage.cdagenci);                           
          END IF;
          CLOSE cr_craptvl;
        /* Fim dos DOCS */ 
        END IF;
        
        IF TO_NUMBER(SUBSTR(vr_dstextab,13,1)) <> 1 THEN /* TED */ 
          -- Verificar se agencia contem teds a serem enviados
          OPEN cr_craptvl_2 (pr_cdcooper => pr_cdcooper,
                             pr_cdagenci => rw_crapage.cdagenci,
                             pr_dtmvtolt => rw_crapdat.dtmvtolt);
          FETCH cr_craptvl_2 INTO rw_craptvl;
          -- se econtrou, gerar critica
          IF cr_craptvl_2%FOUND THEN
            pc_grava_critica(pr_cdcooper => pr_cdcooper,
                             pr_dscritic => ' - Nao foram enviados todos os TED''S do Pa'||
                                            TO_CHAR(rw_crapage.cdagenci,'000')||' - Tela DOCTOS',
                             pr_cdsitexc => 4,
                             pr_cdagenci => rw_crapage.cdagenci);                           
          END IF;
          CLOSE cr_craptvl_2;
        /* Fim dos DOCS */   
        END IF;            
      END IF;
      /* Fim dos DOCS e TEDS */ 
      
      /* Verifica se foi gerado o arquivo de guias recebidas */
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED', 
                                                 pr_tptabela => 'GENERI', 
                                                 pr_cdempres => 00, 
                                                 pr_cdacesso => 'HRGUIASGPS', 
                                                 pr_tpregist => rw_crapage.cdagenci);
                                                 
      -- verificar se existe valor
      IF TRIM(vr_dstextab) is null THEN    
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Cadastrar horario fechamento de GUIAS GPS do Pa '||
                                        TO_CHAR(rw_crapage.cdagenci,'fm000')||' - Tela MOVGPS');  
                                              
      ELSIF TO_NUMBER(SUBSTR(vr_dstextab,1,1)) <> 1 THEN /* GPS */ 
        -- Verificar se agencia contem docs a serem enviados
        OPEN cr_craplgp (pr_cdcooper => pr_cdcooper,
                         pr_cdagenci => rw_crapage.cdagenci,
                         pr_dtmvtolt => rw_crapdat.dtmvtolt);
        FETCH cr_craplgp INTO rw_craplgp;
        -- se encontrou deve gerar critica
        IF cr_craplgp%FOUND THEN
          pc_grava_critica(pr_cdcooper => pr_cdcooper,
                           pr_dscritic => ' - Pa '||TO_CHAR(rw_crapage.cdagenci,'fm000')||
                                          ' nao enviou todas as suas GUIAS GPS - Tela MOVGPS',
                           pr_cdsitexc => 1,
                           pr_cdagenci => rw_crapage.cdagenci);                           
        END IF;
        CLOSE cr_craplgp;
          
      END IF;
      /* Fim das Guias GPS */
      
      /* Verifica se os pagamentos do INSS-BANCOOB foram enviados */
      OPEN cr_craplbi (pr_cdcooper => pr_cdcooper,
                       pr_cdagenci => rw_crapage.cdagenci);
      FETCH cr_craplbi INTO rw_craplbi;
      -- se encontrou, gerar critica
      IF cr_craplbi%FOUND THEN
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Pa '||TO_CHAR(rw_crapage.cdagenci,'fm000')||
                                        ' nao enviou todos os pagamentos do INSS - Tela PRPREV',
                         pr_cdsitexc => 5,
                         pr_cdagenci => rw_crapage.cdagenci);                           
      END IF;
      CLOSE cr_craplbi;
        
    END LOOP;  -- Fim Loop crapage
    
    /*  Verifica se a Taxa de Aplicacao (RDC) esta cadastrada  */
    OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => rw_crapdat.dtmvtolt,
                    pr_tpmoefix => 6);
    FETCH cr_crapmfx INTO rw_crapmfx;
      
    IF cr_crapmfx%NOTFOUND THEN
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Cadastrar RDC dia '||
                                      TO_CHAR(RW_CRAPDAT.dtmvtolt,'DD/MM/RRRR'),
                       pr_cdsitexc => 0);  
    END IF;  
    CLOSE cr_crapmfx;
    
    /*  Verifica se a CDI Mensal esta cadastrada  */
    OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => rw_crapdat.dtmvtolt,
                    pr_tpmoefix => 16);
    FETCH cr_crapmfx INTO rw_crapmfx;
      
    IF cr_crapmfx%NOTFOUND THEN
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Cadastrar CDI Mensal '||
                                      TO_CHAR(RW_CRAPDAT.dtmvtolt,'DD/MM/RRRR'),
                       pr_cdsitexc => 0);  
    END IF;  
    CLOSE cr_crapmfx;

    /*  Verifica se a CDI Acumulado esta cadastrada  */
    OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => rw_crapdat.dtmvtolt,
                    pr_tpmoefix => 17);
    FETCH cr_crapmfx INTO rw_crapmfx;
      
    IF cr_crapmfx%NOTFOUND THEN
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Cadastrar CDI Acumulado '||
                                      TO_CHAR(RW_CRAPDAT.dtmvtolt,'DD/MM/RRRR'),
                       pr_cdsitexc => 0);  
    END IF;  
    CLOSE cr_crapmfx;

    /*  Verifica se a CDI Diario esta cadastrada  */
    OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => rw_crapdat.dtmvtolt,
                    pr_tpmoefix => 18);
    FETCH cr_crapmfx INTO rw_crapmfx;
      
    IF cr_crapmfx%NOTFOUND THEN
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Cadastrar CDI Diario '||
                                      TO_CHAR(RW_CRAPDAT.dtmvtolt,'DD/MM/RRRR'),
                       pr_cdsitexc => 0);  
    END IF;  
    CLOSE cr_crapmfx;
      
    /* Verifica se ha aplicacoes com aniversario, exige as tabelas de
    taxas - craptrd. */
    vr_dtfimper := nvl(rw_crapdat.dtmvtolt,sysdate);
    vr_dtiniper := trunc(vr_dtfimper,'MM');
    
    LOOP
      -- Buscar aplicações RDCA
      OPEN cr_craprda_2 (pr_cdcooper => pr_cdcooper,
                         pr_dtiniper => vr_dtiniper);
      FETCH cr_craprda_2 INTO rw_craprda_2;
      -- se encontrar
      IF cr_craprda_2%FOUND THEN
        -- buscar taxas de RDCA
        OPEN cr_craptrd (pr_cdcooper => pr_cdcooper,
                         pr_dtfimper => rw_craprda_2.dtfimper,
                         pr_tptaxrda => 1);
        FETCH cr_craptrd INTO rw_craptrd;
        -- Se não encontrar
        IF cr_craptrd%NOTFOUND THEN
          pc_grava_critica(pr_cdcooper => pr_cdcooper,
                           pr_dscritic => ' - Cadastrar RDCA dia '||TO_CHAR(rw_craprda_2.dtfimper,'DD/MM/RRRR')
                                          ||' - Tela TAXCDI');  
        END IF;  
        CLOSE cr_craptrd;  
      END IF;  
      CLOSE cr_craprda_2;
      
      -- Incrementar data
      vr_dtiniper := vr_dtiniper + 1;
      -- se passou da data final, sair do loop
      IF vr_dtiniper > vr_dtfimper THEN
        EXIT;
      END IF;             
    END LOOP;  
		
		-- Verifica indexador dos produtos de captacao
		FOR rw_crapcpc IN cr_crapcpc LOOP
			
		  -- Verifica se há alguma aplicação ativa do produto
		  OPEN cr_craprac(pr_cdcooper => pr_cdcooper,
			                pr_cdprodut => rw_crapcpc.cdprodut);
      FETCH cr_craprac INTO rw_craprac;
			
			-- Se não encontrar nenhuma, pula para o próximo registro de produtos
			IF cr_craprac%NOTFOUND THEN
				CLOSE cr_craprac;
				CONTINUE;
			END IF;											
			CLOSE cr_craprac;											
		
		  -- Abre cursor do indexador cadastrado do produto
		  OPEN cr_crapind(pr_cddindex => rw_crapcpc.cddindex);
			FETCH cr_crapind INTO rw_crapind;
			
			-- Se não encontrar, gerar crítica
			IF cr_crapind%NOTFOUND THEN			
			  pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Produto de captacao ' || rw_crapcpc.nmprodut || 
                                        ' sem indexador cadastrado. Tela PCAPTA.');  							
			END IF;
			CLOSE cr_crapind;
			
			IF rw_crapind.idperiod = 1 THEN         /* Cadastro Diario */
        vr_dtperiod := rw_crapdat.dtmvtolt;
			ELSIF rw_crapind.idperiod = 2 THEN      /* Cadastro Mensal */
				vr_dtperiod := TRUNC(rw_crapdat.dtmvtolt, 'MM');
			ELSIF rw_crapind.idperiod = 3 THEN      /* Cadastro Anual  */
				vr_dtperiod := TRUNC(rw_crapdat.dtmvtolt, 'RRRR');
			END IF;

      -- Abre cursor para buscar a taxa do indexador
      OPEN cr_craptxi(pr_cddindex => rw_crapind.cddindex -- Código do indexador
			               ,pr_dtiniper => vr_dtperiod         -- Data inicial do periodo de taxa
										 ,pr_dtfimper => vr_dtperiod);       -- Data final do periodo de taxa
			FETCH cr_craptxi INTO rw_craptxi;			

			IF cr_craptxi%NOTFOUND THEN
			  pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Falta cadastrar taxa do dia ' || to_char(vr_dtperiod, 'DD/MM/RRRR') || 
                                        ' para o indexador ' || rw_crapind.nmdindex || '. Tela PCAPTA.');  	
			END IF;
		  CLOSE cr_craptxi;
    END LOOP;  
    
    /*  Verifica se foram cadastradas as taxas (emprestimo) do mes  */
    -- Verificar se é virada de mês
    IF TO_CHAR(rw_crapdat.dtmvtolt,'MM') <> TO_CHAR(rw_crapdat.dtmvtopr,'MM')   THEN
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED', 
                                                 pr_tptabela => 'GENERI', 
                                                 pr_cdempres => 00, 
                                                 pr_cdacesso => 'EXEJUROCAP', 
                                                 pr_tpregist => 001);
                                                 
      -- verificar se existe valor
      IF TRIM(vr_dstextab) is not null THEN 
        -- Verificar se existe valor para o mês
        IF gene0002.fn_busca_entrada( pr_postext     => to_char(rw_crapdat.dtmvtolt,'MM')
                                     ,pr_dstext      => SUBSTR(vr_dstextab,5,200)
                                     ,pr_delimitador => ';')  = 0 THEN
          
          pc_grava_critica(pr_cdcooper => pr_cdcooper,
                           pr_dscritic => ' - Falta cadastrar a tela SOL026 para o mes.');   
        END IF;
      ELSE
        -- se não localizou registro na craptab
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Falta cadastrar a tela SOL026 para o mes.');  
      END IF;
      
      /*  Leitura da tabela TAXASDOMES */
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED', 
                                                 pr_tptabela => 'GENERI', 
                                                 pr_cdempres => 00, 
                                                 pr_cdacesso => 'TAXASDOMES', 
                                                 pr_tpregist => 1);
                                                 
      -- verificar se existe valor
      IF TRIM(vr_dstextab) is null THEN
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Cadastrar taxas para o mes. - Tela TAXMES');
        
      ELSIF TO_CHAR(rw_crapdat.dtmvtolt,'MMRRRR') <> SUBSTR(vr_dstextab,27,6)THEN
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Cadastrar juros para o mes '
                                        ||to_char(rw_crapdat.dtmvtolt,'MM/RRRR')
                                        ||' - Tela TAXMES');
      END IF;      
      
      /*  Exige taxa para Poupanca Programada quando for mensal  */
      FOR rw_craprpp IN cr_craprpp (pr_cdcooper => pr_cdcooper,
                                    pr_tipo     => 'I', 
                                    pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
        -- buscar taxas
        OPEN cr_craptrd (pr_cdcooper => pr_cdcooper,
                         pr_dtfimper => rw_craprpp.dtperiodo,
                         pr_tptaxrda => 2);
        FETCH cr_craptrd INTO rw_craptrd;
        -- Se não encontrar
        IF cr_craptrd%NOTFOUND THEN
          pc_grava_critica(pr_cdcooper => pr_cdcooper,
                           pr_dscritic => ' - Cadastrar POUP.PROGR. dia '||
                                            TO_CHAR(rw_craprpp.dtperiodo,'DD/MM/RRRR')||' - Tela MOEDAS');    
        END IF;             
        CLOSE cr_craptrd;
        
        /*  Leitura da tabela TAXASDOMES */
        vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                   pr_nmsistem => 'CRED', 
                                                   pr_tptabela => 'USUARI', 
                                                   pr_cdempres => 11, 
                                                   pr_cdacesso => 'REMNOVPOUP', 
                                                   pr_tpregist => 1);
                                                   
        -- verificar se existe valor
        IF TRIM(vr_dstextab) is not null THEN
          -- formatar data
          vr_datliber := TO_DATE(vr_dstextab,'DD/MM/RRRR');                    
          
          -- se a data de inicio for maior que a data de liberação
          IF rw_craprpp.dtperiodo >= vr_datliber THEN            
            -- buscar taxas
            OPEN cr_craptrd (pr_cdcooper => pr_cdcooper,
                             pr_dtfimper => rw_craprpp.dtperiodo,
                             pr_tptaxrda => 4);
            FETCH cr_craptrd INTO rw_craptrd;
            -- Se não encontrar
            IF cr_craptrd%NOTFOUND THEN
              pc_grava_critica(pr_cdcooper => pr_cdcooper,
                               pr_dscritic => ' - Cadastrar NOVA POUP.PROGR. dia '||
                                              to_char(rw_craprpp.dtperiodo,'DD/MM/RRRR')||' - Tela MOEDAS');
            END IF;  
          END IF;  
        END IF;
            
      END LOOP; -- Fim loop cr_craprpp 
    END IF; -- Fim Verificar se é virada de mês
    
    /* Verifica se ha poupanca programada com aniversario,
       exige as tabela[Bs de taxas - craptrd. */
    FOR rw_craprpp IN cr_craprpp (pr_cdcooper => pr_cdcooper,
                                  pr_tipo     => 'F', 
                                  pr_dtmvtolt => rw_crapdat.dtmvtopr,
                                  pr_incalmes => 0 ) LOOP
      -- buscar taxas
      OPEN cr_craptrd (pr_cdcooper => pr_cdcooper,
                       pr_dtfimper => rw_craprpp.dtperiodo,
                       pr_tptaxrda => 2);
      FETCH cr_craptrd INTO rw_craptrd;
      -- Se não encontrar
      IF cr_craptrd%NOTFOUND THEN
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Cadastrar POUP.PROGR. dia '||
                                          TO_CHAR(rw_craprpp.dtperiodo,'DD/MM/RRRR')||' - Tela MOEDAS');    
      END IF;             
      CLOSE cr_craptrd;
    
      /*  Leitura da tabela TAXASDOMES */
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED', 
                                                 pr_tptabela => 'USUARI', 
                                                 pr_cdempres => 11, 
                                                 pr_cdacesso => 'REMNOVPOUP', 
                                                 pr_tpregist => 1);
                                                   
      -- verificar se existe valor
      IF TRIM(vr_dstextab) is not null THEN
        -- formatar data
        vr_datliber := TO_DATE(vr_dstextab,'DD/MM/RRRR');                    
          
        -- se a data de inicio for maior que a data de liberação
        IF rw_craprpp.dtperiodo >= vr_datliber THEN            
          -- buscar taxas
          OPEN cr_craptrd (pr_cdcooper => pr_cdcooper,
                           pr_dtfimper => rw_craprpp.dtperiodo,
                           pr_tptaxrda => 4);
          FETCH cr_craptrd INTO rw_craptrd;
          -- Se não encontrar
          IF cr_craptrd%NOTFOUND THEN
            pc_grava_critica(pr_cdcooper => pr_cdcooper,
                             pr_dscritic => ' - Cadastrar NOVA POUP.PROGR. dia '||
                                            to_char(rw_craprpp.dtperiodo,'DD/MM/RRRR')||' - Tela MOEDAS');
          END IF;  
        END IF;  
      END IF;
    
    END LOOP; -- Fim loop cr_craprpp 
    
    /* Verifica se houve movimentacoes que precisam ser registradas */
    vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                               pr_nmsistem => 'CRED', 
                                               pr_tptabela => 'GENERI', 
                                               pr_cdempres => 0, 
                                               pr_cdacesso => 'VMINCTRCEN', 
                                               pr_tpregist => 0);
                                                 
    -- verificar se existe valor
    IF TRIM(vr_dstextab) is null THEN
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Tabela nao cadastrada. CRED-GENERI-0-VMINCTRCEN-0');
      /* Enviar email de controle de movimentacao soh quando solicitar o processo */
    ELSIF pr_choice = 2 THEN
      -- Buscar controle de movimentacao em especie
      FOR rw_crapcme in cr_crapcme (pr_cdcooper => pr_cdcooper,
                                   pr_dstextab => to_number(vr_dstextab)) LOOP
              
        -- incluir na temp-table
        vr_idxcme := vr_tab_crapcme.count;
        vr_tab_crapcme(vr_idxcme).rowidcme := rw_crapcme.rowid;
        vr_tab_crapcme(vr_idxcme).nrdconta := rw_crapcme.nrdconta;

      END LOOP;
      -- Verificar se existe algum registro a ser processado
      IF vr_tab_crapcme.count > 0 then
        /******************************************************************************
           Gerar e enviar por email o arquivo de varios controles de movimentacao 
        ******************************************************************************/
        CTME0001.pc_gera_arquivo_controle(pr_cdcooper  => pr_cdcooper,            -- Codigo da cooperativa
                                          pr_cdagenci  => pr_cdagenci,            -- Codigo da agencia
                                          pr_nrdcaixa  => 0 /*caixa*/,            -- Numero do caixa
                                          pr_cdoperad  => pr_cdoperad,            -- codigo do operador
                                          pr_nmdatela  => pr_nmdatela,            -- Nome da tela
                                          pr_idorigem  => 1, /* AYLLOS */         -- indicador de origem
                                          pr_cddopcao  => 1, /* OPCAO */          -- Codigo da opção
                                          pr_dtmvtolt  => rw_crapdat.dtmvtolt,    -- data do movimento
                                          pr_dtarquiv  => null,                   -- Data do arquivo
                                          pr_flgerlog  => TRUE,                   -- indicador se gera log                            
                                          pr_tab_crapcme => vr_tab_crapcme,       -- temp-table com os registros a processar
                                          pr_des_erro => vr_des_erro,             -- retorno se existe erro OK/NOK
                                          pr_tab_erro => vr_tab_erro);      
      
        IF NVL(UPPER(vr_des_erro),'OK') <>  'OK' THEN
          -- gerar log da critica
          IF vr_tab_erro.count > 0 then
            pc_gera_log_proces(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, -- Erro tratato
                               pr_des_log      => 'Erro CTME0001.pc_gera_arquivo_controle: '||vr_tab_erro(vr_tab_erro.FIRST).dscritic);  
          ELSE
            pc_gera_log_proces(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, -- Erro tratato
                               pr_des_log      => 'Erro na CTME0001.pc_gera_arquivo_controle');  
          END IF;  
          
        END IF;  
        
      END IF;    
    END IF;    
    
    /* verifica se eh segunda-feira */
    IF to_char(rw_crapdat.dtmvtolt,'D') = 2 THEN
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED', 
                                                 pr_tptabela => 'GENERI', 
                                                 pr_cdempres => 00, 
                                                 pr_cdacesso => 'EXELIMPEZA', 
                                                 pr_tpregist => 001);
                                                   
      -- verificar se existe valor
      IF TRIM(vr_dstextab) is null THEN
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Falta tabela de execucao de limpeza - registro 001');
      END IF;  
    END IF;  
    
    /* Acessa a tabela com o numero das contas de convenio no BB */
    vr_lscontas := NULL;
    FOR vr_contador IN 1..3 LOOP
      -- Buscar conta centralizadora
      vr_nrctaret := GENE0005.fn_busca_conta_centralizadora(pr_cdcooper => pr_cdcooper, 
                                                            pr_tpregist => vr_contador);
      -- incrementar contas
      IF vr_nrctaret is not null THEN
        vr_lscontas := vr_lscontas||vr_nrctaret||',';
      END IF;                                                          
    END LOOP;  
    
    /*** Verifica se deve solicitar o pedido de talonarios - sol27 ***/
    vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                               pr_nmsistem => 'CRED', 
                                               pr_tptabela => 'USUARI', 
                                               pr_cdempres => 11, 
                                               pr_cdacesso => 'EXECPEDTAL', 
                                               pr_tpregist => 001);
                                                   
    -- verificar se existe valor
    IF TRIM(vr_dstextab) is null THEN
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Preencha a Tela SOL027 para PEDIDO DE TALONARIOS');
    ELSIF vr_dstextab <> '0 0'   THEN
      pr_flgsol27 := 1; --TRUE;
    END IF;  
    
    /* Verifica se deve solicitar acompanhamento dos talonarios - SOL16 */
    vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                               pr_nmsistem => 'CRED', 
                                               pr_tptabela => 'GENERI', 
                                               pr_cdempres => 00, 
                                               pr_cdacesso => 'EXEACOMPTL', 
                                               pr_tpregist => 001);
                                                   
    -- verificar se existe valor
    IF TRIM(vr_dstextab) is null THEN
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Falta tabela de execucao do acompanhamento de talonarios');
    ELSIF (to_char(rw_crapdat.dtmvtopr,'DD') > 14 AND vr_dstextab = '0') /* Apos o dia 13 */
        OR(to_char(rw_crapdat.dtmvtopr,'DD') > 27 AND vr_dstextab = '1') /* Apos o dia 26 */
        THEN
      pr_flgsol16 := 1;--TRUE;
    END IF;  
    
    /*** Ate o dia 10 o VAR precisa estar contabilizado ***/     
    IF to_char(rw_crapdat.dtmvtolt,'DD') > 10  THEN
      -- Buscar informação na craptab
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED', 
                                                 pr_tptabela => 'GENERI', 
                                                 pr_cdempres => 00, 
                                                 pr_cdacesso => 'EXESOLAPLI', 
                                                 pr_tpregist => 001);
                                                     
      -- verificar se existe valor
      IF TRIM(vr_dstextab) is null THEN 
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Falta tabela de execucao da listagem de aplicacoes a vencer');
      ELSE
        -- Se valor for zero, recebe true
        IF vr_dstextab = 0   THEN
          pr_flgsol37 := 1; --TRUE;
        --senão, se for 1 e ja passou do dia 20  
        ELSIF vr_dstextab = 1  AND 
              to_char(rw_crapdat.dtmvtolt,'DD') > 20   THEN
            pr_flgsol37 := 1; --TRUE;
        END IF;        
      END IF;
      
      -- Buscar informação na craptab
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED', 
                                                 pr_tptabela => 'GENERI', 
                                                 pr_cdempres => 00, 
                                                 pr_cdacesso => 'EXESOLADMI', 
                                                 pr_tpregist => 001);
                                                     
      -- verificar se existe valor
      IF TRIM(vr_dstextab) is null THEN 
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Falta tabela de execucao das fichas de admitidos');
      ELSIF vr_dstextab = 0   THEN
        pr_flgsol59 := 1;--TRUE;
      END IF;
                 
    END IF; -- Fim dtmvtolt > 10  
    
    /*  Verifica se e' dia primeiro dia util do mes para solicitar execucao
         da baixa de talonarios e a execucao o resumo dos historicos  */
    IF TO_CHAR(rw_crapdat.dtmvtolt,'MM') <> TO_CHAR(rw_crapdat.dtmvtoan,'MM') THEN
      -- Buscar informação na craptab
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED', 
                                                 pr_tptabela => 'GENERI', 
                                                 pr_cdempres => 00, 
                                                 pr_cdacesso => 'EXEBAIXCHQ', 
                                                 pr_tpregist => 001);
                                                     
      -- verificar se existe valor
      IF TRIM(vr_dstextab) is null THEN 
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Falta tabela de execucao de baixa de talonarios');
      ELSIF vr_dstextab = '0' THEN
        pr_flgsol28 := 1;--TRUE;
      END IF;
          
    END IF;-- Fim Mudou o mes  
    
    /*  Verifica se deve solicitar emissao dos cartoes de cheque especial e
        a relacao de contas incluidas no CCF pelo BB 
        - roda sempre no primeiro dia util apos o dia 19 */  
    IF to_char(rw_crapdat.dtmvtolt,'DD') > 19  THEN    
      -- Buscar informação na craptab
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED', 
                                                 pr_tptabela => 'GENERI', 
                                                 pr_cdempres => 00, 
                                                 pr_cdacesso => 'EXESOLCART', 
                                                 pr_tpregist => 001);
                                                     
      -- verificar se existe valor
      IF TRIM(vr_dstextab) is null THEN 
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Falta tabela de emissao dos cartoes de cheque especial');
      /* Foi pego e comparado apenas a primeira posicao */
      ELSIF SUBSTR(vr_dstextab,1,1) = '0' THEN
        pr_flgsol57 := 1; --TRUE;             
      END IF;  
    END IF; --  Fim IF dtmvtolt > 19
    
    IF   gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => add_months(TRUNC(rw_crapdat.dtmvtolt,'RRRR'),12)-1 
                                    ,pr_tipo => 'A') = rw_crapdat.dtmvtolt  THEN
         vr_flexecut := TRUE;                                
    END IF;

    
    /* Verifica se deve solicitar calculo do retorno das Sobras - roda somente ate abril */
    IF (to_char(rw_crapdat.dtmvtolt,'MM') <= to_number(gene0001.fn_param_sistema('CRED', pr_cdcooper, 'NRMES_LIM_JURO_SOBRA'))) OR
       vr_flexecut = TRUE  THEN
      -- Buscar informação na craptab
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED', 
                                                 pr_tptabela => 'GENERI', 
                                                 pr_cdempres => 00, 
                                                 pr_cdacesso => 'EXEICMIRET', 
                                                 pr_tpregist => 001);
                                                     
      -- verificar se existe valor
      IF TRIM(vr_dstextab) is null THEN 
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Falta tabela de execucao do credito de retorno');
      -- Se foi selecionado algum percentual a distribuir
      ELSIF SUBSTR(vr_dstextab,03,63) <> '0 000,00000000 0 000,00000000 000,00000000 0   0 0 000,00000000'
         OR SUBSTR(vr_dstextab,78,25) <> '000,00000000 000,00000000' THEN
        pr_flgsol30 := 1;--TRUE;
      END IF;       
    END IF; -- Fim IF Mês < 5    
    
    /* Verifica se deve solicitar relacao de emprestimos em atraso - apos
       o dia 15 do mes e no mensal */
    IF to_char(rw_crapdat.dtmvtolt,'DD') > 15  THEN
      -- Buscar informação na craptab
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED', 
                                                 pr_tptabela => 'GENERI', 
                                                 pr_cdempres => 00, 
                                                 pr_cdacesso => 'EXEEMPATRA', 
                                                 pr_tpregist => 001);
                                                     
      -- verificar se existe valor
      IF TRIM(vr_dstextab) is null THEN 
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Falta tabela de execucao dos emprestimos em atraso');      
      ELSIF vr_dstextab = '0' THEN
        pr_flgsol46 := 1;--TRUE;
      END IF;        
    END IF; -- Fim dtmvtolt > 15    
    
    /*  Verifica se deve solicitar Central de Risco */
    -- Buscar informação na craptab
    vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                               pr_nmsistem => 'CRED', 
                                               pr_tptabela => 'USUARI', 
                                               pr_cdempres => 11, 
                                               pr_cdacesso => 'RISCOBACEN', 
                                               pr_tpregist => 000);
                                                     
    -- verificar se existe valor
    IF TRIM(vr_dstextab) is null THEN 
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Tabela nao cadastrada CRED-USUARI-11-RISCOBACEN-000');
    ELSE
      IF SUBSTR(vr_dstextab,1,1) = '1' THEN
        pr_flgsol80 := 1;--TRUE;
      -- Senão, se irá passar do dia 15 e ainda estiver com zero
      ELSIF SUBSTR(vr_dstextab,1,1) = '0' AND
            to_char(rw_crapdat.dtmvtopr,'DD') > 15   AND 
            to_char(rw_crapdat.dtmvtolt,'DD') <= 15  THEN
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Cadastramento da CENTRAL DE RISCO ainda nao'||
                                        ' foi executado. CRED-USUARI-11-RISCOBACEN-000',
                         pr_cancsoli => 0); --não cancelar solicitação    
      END IF;      
    END IF;    
    
    -- Buscar capas de lotes de requisicoes que estão com diferenças
    FOR rw_craptrq IN cr_craptrq (pr_cdcooper => pr_cdcooper) LOOP
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Lote de requisicoes NAO BATIDO. Pa: '||to_char(rw_craptrq.cdagelot,'000')
                                      ||' Lote: '||to_char(rw_craptrq.nrdolote,'000000'),
                       pr_cancsoli => 0); --não cancelar solicitação
    END LOOP;
    
    /****** Verificar se ha algum boletim de caixa aberto ****/
    FOR rw_crapbcx IN cr_crapbcx (pr_cdcooper => pr_cdcooper,
                                  pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
                                  
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Boletim de caixa ABERTO ==> Pa: '||to_char(rw_crapbcx.cdagenci,'fm000')
                                      ||' Caixa: '||to_char(rw_crapbcx.nrdcaixa,'fm000')
                                      ||' Operador: '||rw_crapbcx.cdopecxa||'-'
                                      ||gene0002.fn_busca_entrada(1,rw_crapbcx.nmoperad,' '));
    END LOOP; /* Fim do FOR -- Leitura do crapbcx */
    
    /*** Validar Lotes ***/
    FOR rw_craplot IN cr_craplot (pr_cdcooper => pr_cdcooper,
                                  pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
      
      IF rw_craplot.tplotmov = 9   THEN
        vr_flgaprdc := TRUE;      
        /*** Magui destivado em 03/01/2008, RDCA cancelado
          ELSE
        IF   craplot.tplotmov = 10   THEN
             aux_flgaprda = TRUE.      
        ****************/
      ELSIF rw_craplot.tplotmov = 14 THEN
        vr_flgaprpp := TRUE;
      END IF;  
      
      -- Gerar critica sado o lote de caixa não tiver numero de caixa
      IF rw_craplot.cdbccxlt = 11 AND /* LOTE DE CAIXA */
         rw_craplot.nrdcaixa = 0  THEN
         
         pc_grava_critica(pr_cdcooper => pr_cdcooper,
                          pr_dscritic => ' - Lote de caixa NAO ASSOCIADO - Pa: '||to_char(rw_craplot.cdagenci,'000')
                                         ||' Lote: '||to_char(rw_craplot.nrdolote,'000000'));
      END IF;   
      
      -- Se valores NÃO estiverem iguais, deve gerar critica
      IF NOT (rw_craplot.qtinfoln = rw_craplot.qtcompln   AND
              rw_craplot.vlinfodb = rw_craplot.vlcompdb   AND
              rw_craplot.vlinfocr = rw_craplot.vlcompcr)   THEN
      
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Ha lotes nao batidos => Pa: '||to_char(rw_craplot.cdagenci,'000')
                                      ||' Banco/Caixa: '||to_char(rw_craplot.cdbccxlt,'000')
                                      ||' Lote: '||to_char(rw_craplot.nrdolote,'000000'));
      END IF;        
      
      -- Se valores NÃO estiverem iguais, deve gerar critica
      IF NOT(rw_craplot.qtinfocc = rw_craplot.qtcompcc AND
             rw_craplot.vlinfocc = rw_craplot.vlcompcc AND
             rw_craplot.qtcompcs = rw_craplot.qtinfocs AND
             rw_craplot.vlcompcs = rw_craplot.vlinfocs AND
             rw_craplot.qtcompci = rw_craplot.qtinfoci AND
             rw_craplot.vlcompci = rw_craplot.vlinfoci)   THEN
             
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Protoc CUSTODIA nao batido => Pa: '||to_char(rw_craplot.cdagenci,'000')
                                      ||' Bco/Cxa: '||to_char(rw_craplot.cdbccxlt,'000')
                                      ||' Lote: '||to_char(rw_craplot.nrdolote,'000000'));
      END IF;                                     
    END LOOP;/* Fim do FOR -- Leitura do craplot */
    
    -- Codigo igual ao progress
    IF pr_choice = 1   THEN
      null;  
    END IF;
    
    /*** Listar informacoes de alteracoes de conta que não possuem 
         o nrdconta cadastrado na crapass***/
    FOR rw_crapact IN cr_crapact (pr_cdcooper => pr_cdcooper,
                                  pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
      pc_grava_critica(pr_cdcooper => pr_cdcooper,
                       pr_dscritic => ' - Associado nao encontrado no crapass. ERRO DE SISTEMA');
    END LOOP;
    
    /* Chamado pelo tela proces e se o diretorio existir*/
    IF trim(pr_nmarqimp) is not null and
       gene0001.fn_exis_diretorio(pr_caminho => vr_nmdiretM||'/bancoob') THEN                 
            
      /** Verifica a existencia de cheques para serem enviados ao BANCOOB ***/
      GENE0001.pc_lista_arquivos(pr_path     => vr_nmdiretM||'/bancoob', 
                                 pr_pesq     => 'pd%BANCOOB', 
                                 pr_listarq  => vr_listarq, 
                                 pr_des_erro => vr_dscritic);
      
      
      -- Verifica se ocorreram erros no processo de listagem de arquivos
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Erro ao buscar arquivo pd%BANCOOB: '||vr_dscritic); 
      END IF;
      -- Senão retornou algum arquivo, gerar critica
      IF TRIM(vr_listarq) IS NOT NULL THEN
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Ha arquivos de cheques do BANCOOB Form.'||
                                        ' Continuo para serem enviados - PCOMPE');
      END IF;        
    END IF;
    
    /* Verificar se ha saldo na conta para emprestimos com emissao de boletos */
    -- Buscar informação na craptab
    vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                               pr_nmsistem => 'CRED', 
                                               pr_tptabela => 'GENERI', 
                                               pr_cdempres => 00, 
                                               pr_cdacesso => 'CTAEMISBOL', 
                                               pr_tpregist => 0);
                                                     
    -- verificar se existe valor
    IF NVL(TRIM(vr_dstextab),0) <> 0 THEN       
      vr_vlsalbol := 0;
      
      -- Busca associado
      OPEN  cr_crapass (pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => vr_dstextab);
      FETCH cr_crapass INTO rw_crapass;                         
       
      -- Buscar saldo do associado    
      extr0001.pc_obtem_saldo(pr_cdcooper   => pr_cdcooper,
                              pr_rw_crapdat => rw_crapdat,
                              pr_cdagenci   => 0,
                              pr_nrdcaixa   => 0,
                              pr_cdoperad   => '0',
                              pr_nrdconta   => rw_crapass.nrdconta,
                              pr_dtrefere   => rw_crapdat.dtmvtolt,
                              pr_des_reto   => vr_des_erro,
                              pr_tab_sald   => vr_tab_sald,
                              pr_tab_erro   => vr_tab_erro);
      -- VERIFICA SE HOUVE ERRO NO RETORNO
      IF vr_des_erro = 'NOK' THEN
        -- ENVIO CENTRALIZADO DE LOG DE ERRO
        IF vr_tab_erro.count > 0 THEN          
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          -- GERA LOG
          pc_gera_log_proces(pr_cdcooper     => pr_cdcooper,
                             pr_ind_tipo_log => 2, -- Erro tratato
                             pr_des_log      => vr_dscritic);
        END IF;
      END IF;
      
      -- se retornou valores, somar saldos
      IF vr_tab_sald.COUNT > 0 THEN
        vr_vlsalbol := NVL(vr_tab_sald(vr_tab_sald.FIRST).vlsddisp,0) +
                       NVL(vr_tab_sald(vr_tab_sald.FIRST).vlsdchsl,0) +
                       NVL(vr_tab_sald(vr_tab_sald.FIRST).vlsdbloq,0) +
                       NVL(vr_tab_sald(vr_tab_sald.FIRST).vlsdblpr,0) +
                       NVL(vr_tab_sald(vr_tab_sald.FIRST).vlsdblfp,0);
      END IF;  
      
      -- Buscar informação na craptab
      vr_lshistor := TABE0001.fn_busca_dstextab( pr_cdcooper =>  pr_cdcooper,
                                                 pr_nmsistem =>  'CRED',
                                                 pr_tptabela =>  'GENERI',
                                                 pr_cdempres =>  0,
                                                 pr_cdacesso =>  'HSTCHEQUES', 
                                                 pr_tpregist =>  0);
      IF TRIM(vr_lshistor) IS NULL THEN
        vr_lshistor := '999';
      END IF;  
        
      -- Efetuar chamada a rotina que monta a tabela temporária de extrato da conta
      extr0001.pc_consulta_extrato(pr_cdcooper     => pr_cdcooper
                                  ,pr_rw_crapdat   => rw_crapdat
                                  ,pr_cdagenci     => 0
                                  ,pr_nrdcaixa     => 0
                                  ,pr_cdoperad     => '0'
                                  ,pr_nrdconta     => rw_crapass.nrdconta
                                  ,pr_vllimcre     => rw_crapass.vllimcre
                                  ,pr_dtiniper     => rw_crapdat.dtmvtolt
                                  ,pr_dtfimper     => rw_crapdat.dtmvtolt
                                  ,pr_lshistor     => vr_lshistor
                                  ,pr_idorigem     => 1 --> Caixa
                                  ,pr_idseqttl     => 1
                                  ,pr_nmdatela     => 'EXTRAT'
                                  ,pr_flgerlog     => FALSE        --> Sem log
                                  ,pr_des_reto     => vr_des_erro  --> OK ou NOK
                                  ,pr_tab_extrato  => vr_tab_extr  --> Vetor para o retorno das informações
                                  ,pr_tab_erro     => vr_tab_erro);
      -- Se houve retorno não Ok
      IF vr_des_erro = 'NOK' THEN
        -- Tenta buscar o erro no vetor de erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic || ' Conta: '||rw_crapass.nrdconta;
        ELSE
          vr_des_erro := 'Retorno "NOK" na extr0001.pc_consulta_extrato e sem informação na pr_vet_erro, Conta: '||rw_crapass.nrdconta;
        END IF;
        -- gerar log
        pc_gera_log_proces(pr_cdcooper     => pr_cdcooper,
                           pr_ind_tipo_log => 2, -- Erro tratato
                           pr_des_log      => vr_des_erro);
      END IF;
      
      -- Busca a chave do primeiro registro do extrato
      vr_ind_ext := vr_tab_extr.FIRST;
      -- Varrer todos os registros do vetor atraves do .NEXT
      LOOP
        -- Sair quando não encontrou mais informações
        EXIT WHEN vr_ind_ext IS NULL;
        -- Calcular saldo conforme o codigo do historico
        IF vr_tab_extr(vr_ind_ext).inhistor >= 1   AND
           vr_tab_extr(vr_ind_ext).inhistor <= 5   THEN
          vr_vlsalbol := nvl(vr_vlsalbol,0) + nvl(vr_tab_extr(vr_ind_ext).vllanmto,0);
        ELSIF vr_tab_extr(vr_ind_ext).inhistor >= 11   AND
              vr_tab_extr(vr_ind_ext).inhistor <= 15   THEN
          vr_vlsalbol := nvl(vr_vlsalbol,0) - nvl(vr_tab_extr(vr_ind_ext).vllanmto,0);
        END IF;
        
        -- Buscar a chave do próximo registro
        vr_ind_ext := vr_tab_extr.NEXT(vr_ind_ext);
      END LOOP;
      
      /* Caso a conta tenha saldo, criticar */
      IF nvl(vr_vlsalbol,0) <> 0 THEN
        pc_grava_critica(pr_cdcooper => pr_cdcooper,
                         pr_dscritic => ' - Ha saldo na conta'||gene0002.fn_mask_conta(rw_crapass.nrdconta)
                                        ||' - Emprestimos com emissao de boletos.'
                         ,pr_cdsitexc   => 6 );
      END IF;                      
    END IF;  -- Fim CTAEMISBOL                
    
    /* Alimenta a tabela de parametros */
    FOR rw_craptab IN cr_craptab (pr_cdcooper => pr_cdcooper,
                                  pr_cdacesso => 'DIGITALIZA') LOOP
     
      vr_tab_documentos(rw_craptab.tpregist) := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(2,rw_craptab.dstextab,';'));
    END LOOP;                              
    
    -- Retornar indicador se encontrou alguma 
    -- critica que deve cancelar solicitação 
    pr_nrsequen := nvl(vr_cancsoli,0);
    
    IF trim(pr_nmarqimp) is not null THEN     /* Chamado pelo tela proces */
      -- Inicializar o CLOB
      vr_des_clob := null;

      dbms_lob.createtemporary(vr_des_clob, true);
      dbms_lob.open(vr_des_clob, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := null;
      
      IF pr_choice = 4 THEN
      -- Varrer criticas e exibir no log
        IF pr_tab_criticas.COUNT > 0 and -- se existir criticas
           pr_nrsequen > 0 THEN          -- e existir alguma critica que cancela solicitação
          -- Varrer criticas e exibir no log        
          FOR vr_idx IN pr_tab_criticas.first..pr_tab_criticas.last LOOP            
            pc_escreve_clob(UPPER(rw_crapcop.dsdircop)||' --> '||to_char(vr_idx,'fm00000')||pr_tab_criticas(vr_idx).dscritic||chr(10));            
          END LOOP;  
          
        ELSE -- SE ESTIVER VAZIO
          pc_escreve_clob(UPPER(rw_crapcop.dsdircop)||' --> NENHUMA pendencia ENCONTRADA'||chr(10));
        END IF;
      ELSE
      -- Varrer criticas e exibir no log
      IF pr_tab_criticas.COUNT > 0 and -- se existir criticas
         pr_nrsequen > 0 THEN          -- e existir alguma critica que cancela solicitação
        -- Varrer criticas e exibir no log        
        FOR vr_idx IN pr_tab_criticas.first..pr_tab_criticas.last LOOP
          pc_escreve_clob(to_char(vr_idx,'fm00000')||pr_tab_criticas(vr_idx).dscritic||chr(10)); 
        END LOOP;  
        
      ELSE -- SE ESTIVER VAZIO
          pc_escreve_clob('NENHUMA pendencia ENCONTRADA'||chr(10));
        END IF;
      END IF;
      
      -- descarregar buffer
      pc_escreve_clob('',true);
      -- Escolheu todas cooperavias
      IF pr_choice = 4 THEN
        vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => 3 -- cecred
                                              ,pr_nmsubdir => ''); 
        vr_nmarqimp := vr_nmdireto||'/'||pr_nmarqimp;        
      ELSE
      -- incluir diretorio da cooperativa no parametro recebido(diretorio rl + nmarquivo)
      vr_nmarqimp := vr_nmdireto||'/'||pr_nmarqimp;
      END IF;
      
      -- Separar diretorio do nome do arquivo
      gene0001.pc_separa_arquivo_path(pr_caminho => vr_nmarqimp, 
                                      pr_direto  => vr_nmdireto, 
                                      pr_arquivo => vr_nmarqimp);
      -- Gerar arquivo
      gene0002.pc_clob_para_arquivo( pr_clob    => vr_des_clob 
                                    ,pr_caminho => vr_nmdireto 
                                    ,pr_arquivo => vr_nmarqimp
                                    ,pr_flappend => 'S' -- Sobreescrever
                                    ,pr_des_erro=> vr_dscritic);
      
      -- gerar log da critica
      IF trim(vr_dscritic) is not null THEN
        -- gerar log
        pc_gera_log_proces(pr_cdcooper     => pr_cdcooper,
                           pr_ind_tipo_log => 2, -- Erro tratato
                           pr_des_log      => vr_dscritic);  
      END IF;  
      
      -- Setar privilégio para evitar falta de permissão a outros usuários
      gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 666 '||vr_nmdireto||
                                                    '/'||vr_nmarqimp);
          
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_clob);
      dbms_lob.freetemporary(vr_des_clob);
      
     
    ELSE
      /* Chamado pelo crps417.p - BATCH */
      -- Varrer criticas e exibir no log
      IF pr_tab_criticas.COUNT > 0 THEN
        FOR vr_idx IN pr_tab_criticas.first..pr_tab_criticas.last LOOP
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(vr_idx,'00000')||pr_tab_criticas(vr_idx).dscritic);
        END LOOP;  
      END IF;
    END IF;          
    
  EXCEPTION
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro no procedimento BTCH0002.pc_gera_criticas_proces:'|| sqlerrm;
  END pc_gera_criticas_proces;
  
  -- Gerar criticas do processo e gravar retorno na work table, para conseguir utilizar no progress
  PROCEDURE pc_gera_criticas_proces_wt(pr_cdcooper       IN NUMBER,                 --> Codigo da cooperativa
                                       pr_cdagenci       IN crapage.cdagenci%type,  --> Codigo da agencia
                                       pr_cdoperad       IN crapope.cdoperad%type,  --> codigo do operador
                                       pr_nmdatela       IN crapprg.cdprogra%type,  --> Nome da tela                      
                                       pr_nmarqimp       IN VARCHAR2,               --> Nome do arquivo
                                       pr_choice         IN INTEGER,                --> Tipo de escolhe efetuado na tela
                                       pr_nrsequen       OUT NUMBER,                --> Numero sequencial                                     
                                       pr_vldaurvs       IN OUT NUMBER,             --> Variavel para armazenar o valor do urv
                                       pr_flgsol16       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol27       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol28       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol29       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol30       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol37       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol46       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol57       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol59       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol80       IN OUT INTEGER,            --> variavel que controla se deve gerar a solicitação
                                       pr_cdcritic OUT crapcri.cdcritic%TYPE,       --> Critica encontrada
                                       pr_dscritic OUT VARCHAR2) IS                 --> Texto de erro/critica encontrada
  
  /* .............................................................................

   Programa: Fontes/gera_criticas_proces.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Odirlei Busana(AMcom)
   Data    : Junho/2004.                     Ultima atualizacao: 01/02/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gerar criticas do processo e gravar retorno na work table, para conseguir 
               utilizar no progress
  
   Alteracoes: 01/02/2017 - Ajustes para consultar dados da tela PROCES de todas as cooperativas
                            (Lucas Ranghetti #491624)
  ..................................................................................*/ 
  
    vr_tab_criticas   btch0002.typ_tab_criticas;
    vr_ind            PLS_INTEGER;
    
    -- Busca das cooperativas ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.flgativo = 1 
       ORDER BY cop.cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
  BEGIN
    -- Limpa a tabela temporaria de interface
    BEGIN
      DELETE wt_critica_proces;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao excluir wt_critica_proces: '||SQLERRM;
        RETURN;
    END;
    
    -- se está na cecred e escolheu a opção "4" de todas as coops
    IF pr_cdcooper = 3 AND 
       pr_choice = 4 THEN
      
      -- Cooperativas ativas
      FOR rw_crapcop IN cr_crapcop LOOP
    -- Gerar critica do processo
        btch0002.pc_gera_criticas_proces ( pr_cdcooper => rw_crapcop.cdcooper, --> Codigo da cooperativa
                                           pr_cdagenci => pr_cdagenci,    --> Codigo da agencia
                                           pr_cdoperad => pr_cdoperad,    --> codigo do operador
                                           pr_nmdatela => pr_nmdatela,    --> Nome da tela                      
                                           pr_nmarqimp => pr_nmarqimp,    --> Nome do arquivo
                                           pr_choice   => pr_choice,      --> Tipo de escolhe efetuado na tela
                                           pr_nrsequen => pr_nrsequen,    --> Numero sequencial
                                           pr_vldaurvs => pr_vldaurvs,    --> Variavel para armazenar o valor do urv
                                           pr_flgsol16 => pr_flgsol16,    --> variavel que controla se deve gerar a solicitação
                                           pr_flgsol27 => pr_flgsol27,    --> variavel que controla se deve gerar a solicitação
                                           pr_flgsol28 => pr_flgsol28,    --> variavel que controla se deve gerar a solicitação
                                           pr_flgsol29 => pr_flgsol29,    --> variavel que controla se deve gerar a solicitação
                                           pr_flgsol30 => pr_flgsol30,    --> variavel que controla se deve gerar a solicitação
                                           pr_flgsol37 => pr_flgsol37,    --> variavel que controla se deve gerar a solicitação
                                           pr_flgsol46 => pr_flgsol46,    --> variavel que controla se deve gerar a solicitação
                                           pr_flgsol57 => pr_flgsol57,    --> variavel que controla se deve gerar a solicitação
                                           pr_flgsol59 => pr_flgsol59,    --> variavel que controla se deve gerar a solicitação
                                           pr_flgsol80 => pr_flgsol80,    --> variavel que controla se deve gerar a solicitação
                                           pr_tab_criticas => vr_tab_criticas,--> Retorna as criticas encontradas
                                           pr_cdcritic => pr_cdcritic,    --> Critica encontrada
                                           pr_dscritic => pr_dscritic);  
      
        -- se não encontrar critica
        IF NVL(pr_cdcritic,0) = 0 AND
           TRIM(pr_dscritic) IS NULL THEN
          -- incluir os registros da tabela temporaria na work-table
          
          vr_ind := vr_tab_criticas.first; -- Vai para o primeiro registro

          -- loop sobre a tabela de retorno
          WHILE vr_ind IS NOT NULL LOOP
            -- Insere na tabela de interface
            BEGIN
              INSERT INTO wt_critica_proces
                       (cdcooper,
                        nrsequen, 
                        dscritic, 
                        cdsitexc, 
                        cdagenci)
                 VALUES(vr_tab_criticas(vr_ind).cdcooper,
                        vr_ind, -- nrsequen 
                        substr(vr_tab_criticas(vr_ind).dscritic,1,70), 
                        vr_tab_criticas(vr_ind).cdsitexc, 
                        vr_tab_criticas(vr_ind).cdagenci);    
            EXCEPTION
              WHEN OTHERS THEN
                pr_cdcritic := 0;
                pr_dscritic := 'Erro ao inserir na tabela wt_critica_proces: '||SQLERRM;
                RETURN;
            END;
            
            -- Vai para o proximo registro
            vr_ind := vr_tab_criticas.next(vr_ind);
          END LOOP; 
             
        END IF; -- Fim if critica não existe critica
        CONTINUE;
      END LOOP;
    ELSE -- faz por cooperativa
    -- Gerar critica do processo
    btch0002.pc_gera_criticas_proces ( pr_cdcooper       => pr_cdcooper,    --> Codigo da cooperativa
                                       pr_cdagenci       => pr_cdagenci,    --> Codigo da agencia
                                       pr_cdoperad       => pr_cdoperad,    --> codigo do operador
                                       pr_nmdatela       => pr_nmdatela,    --> Nome da tela                      
                                       pr_nmarqimp       => pr_nmarqimp,    --> Nome do arquivo
                                       pr_choice         => pr_choice,      --> Tipo de escolhe efetuado na tela
                                       pr_nrsequen       => pr_nrsequen,    --> Numero sequencial
                                       pr_vldaurvs       => pr_vldaurvs,    --> Variavel para armazenar o valor do urv
                                       pr_flgsol16       => pr_flgsol16,    --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol27       => pr_flgsol27,    --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol28       => pr_flgsol28,    --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol29       => pr_flgsol29,    --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol30       => pr_flgsol30,    --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol37       => pr_flgsol37,    --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol46       => pr_flgsol46,    --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol57       => pr_flgsol57,    --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol59       => pr_flgsol59,    --> variavel que controla se deve gerar a solicitação
                                       pr_flgsol80       => pr_flgsol80,    --> variavel que controla se deve gerar a solicitação
                                       pr_tab_criticas   => vr_tab_criticas,--> Retorna as criticas encontradas
                                       pr_cdcritic       => pr_cdcritic,    --> Critica encontrada
                                       pr_dscritic       => pr_dscritic);  
  
    -- se não encontrar critica
    IF NVL(pr_cdcritic,0) = 0 AND
       TRIM(pr_dscritic) IS NULL THEN
      -- incluir os registros da tabela temporaria na work-table
      
      vr_ind := vr_tab_criticas.first; -- Vai para o primeiro registro

      -- loop sobre a tabela de retorno
      WHILE vr_ind IS NOT NULL LOOP
        -- Insere na tabela de interface
        BEGIN
          INSERT INTO wt_critica_proces
                     (cdcooper,
                      nrsequen, 
                    dscritic, 
                    cdsitexc, 
                    cdagenci)
               VALUES(vr_tab_criticas(vr_ind).cdcooper,
                      vr_ind, -- nrsequen 
                      substr(vr_tab_criticas(vr_ind).dscritic,1,70), 
                    vr_tab_criticas(vr_ind).cdsitexc, 
                    vr_tab_criticas(vr_ind).cdagenci);    
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao inserir na tabela wt_critica_proces: '||SQLERRM;
            RETURN;
        END;
        
        -- Vai para o proximo registro
        vr_ind := vr_tab_criticas.next(vr_ind);
      END LOOP; 
         
    END IF; -- Fim if critica não existe critica
    END IF;
    
    
  EXCEPTION
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro no procedimento BTCH0002.pc_gera_criticas_proces_wt:'|| sqlerrm;
      rollback; -- rollback temporario até conclusão das validações
      
  END pc_gera_criticas_proces_wt;    
      
END btch0002;
/
