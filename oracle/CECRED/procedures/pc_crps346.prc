CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS346(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                             ,pr_nmtelant  IN VARCHAR2               --> Tela chamadora
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
  /* ..........................................................................

   Programa: PC_CRPS346                               Antigo : Fontes/crps346.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/2003.                         Ultima atualizacao: 24/07/2017

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
             
              14/10/2016 - Conversao Progress >> Oracle PLSQL (Jonata-MOUTs)

			  19/01/2017 - Ajuste na gravacao das datas nas tabelas lot e rej.
			               Quando executava pela COMPEFORA, os registros de lancamento
						   nao eram encontrados, imprimindo em branco.
						   Jonata (Mouts) - Chamado 588174

              01/02/2017 - Tratar incorporacao da Transulcred. (Fabricio)	   
  
              21/06/2017 - Inclusão na tabela de erros Oracle
                         - Padronização de logs
                         - Inclusão validação e log 191 para integrações com críticas
                         - Chamado 696499 (Ana Volles - Envolti)	 

              21/06/2017 - Removidas condições que validam o valor de cheque VLB e enviam
                           email para o SPB. PRJ367 - Compe Sessao Unica (Lombardi) 

              21/09/2017 - Ajustado para não gravar nmarqlog, pois so gera a tbgen_prglog
                           (Ana - Envolti - Chamado 746134)
   ............................................................................. */

  -- Constantes do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS346';
  vr_cdagenci CONSTANT PLS_INTEGER := 1;
  vr_cdbccxlt CONSTANT PLS_INTEGER := 1;
  
  -- Tratamento de erros
  vr_exc_fimprg EXCEPTION;
  vr_exc_saida  EXCEPTION;

  vr_dscritic   varchar2(4000);
  vr_cdcritic   crapcri.cdcritic%TYPE := 0;

  /* Busca dos dados da cooperativa */
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.cdageitg
          ,cop.cdagebcb
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  /* Cursor generico de calendario */
  RW_CRAPDAT BTCH0001.CR_CRAPDAT%ROWTYPE;
  
  -- Variaveis auxiliares para o tratamento do arquivo
  vr_conteudo varchar2(2000);
  vr_nmdircop varchar2(200);
  vr_dtleiarq DATE;
  vr_flgarqui BOOLEAN;
  vr_dstextab craptab.dstextab%TYPE;
  vr_nomedarq varchar2(200);
  vr_dslisarq VARCHAR2(1000);
  vr_splisarq gene0002.typ_split;
  vr_typsaida varchar2(3);
  vr_dessaida varchar2(2000);
  vr_flgchqbb BOOLEAN;
  vr_vlchqvlb NUMBER;
  
  -- Valor dos maiores cheques do BB - 3000,00 - nao usa da tabela 
  -- pois a tabela eh usada em outros programas
  vr_vlmaichq NUMBER(18,2) := 3000; 

  -- Estrutura para separar numericos de campo texto separado por ","
  TYPE typ_tab_valores_n IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
  TYPE typ_tab_valores_t IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);  

  -- Operacoes a processar
  vr_tab_hstchq typ_tab_valores_t;
  vr_tab_hstblq typ_tab_valores_t;
  vr_tab_hstdep typ_tab_valores_t;
  vr_tab_hstcob typ_tab_valores_t;
  vr_dshstblq varchar2(1000);
  
  /*  codigo de agencia com digito calculado: ex. 3164-01 = 3164012  */
  vr_tab_lsagenci typ_tab_valores_n;
  
  -- Lista de contas dos convênios
  vr_tab_contas typ_tab_valores_n;
  vr_tab_conta2 typ_tab_valores_n; 
  vr_tab_conta3 typ_tab_valores_n;
  
  -- Controladores a cada loop de Cooperativa
  vr_nrdolote pls_integer;
  vr_nrdlinha pls_integer;
  vr_flgarqvz boolean;
  vr_flgfirst boolean;
  vr_flgentra boolean;
  vr_flgclote boolean;
  
  -- Arquivo e informações em leitura 
  vr_arqhandle utl_file.file_type;
  vr_dslinharq varchar2(4000);
  vr_nrdctabb number(8);
  vr_nrseqint PLS_INTEGER;
  vr_dshistor VARCHAR2(30);
  vr_nrdocmto PLS_INTEGER;
  vr_nrdocmt2 PLS_INTEGER;
  vr_nrcalcul PLS_INTEGER;
  vr_stsnrcal BOOLEAN;
  vr_stsnrcal_int PLS_INTEGER;
  vr_dsdctitg VARCHAR2(30);
  vr_vllanmto NUMBER(16,2);
  vr_dtmvtolt DATE;
  vr_indebcre CHAR(1);
  vr_cdpesqbb VARCHAR2(13);
  vr_dsageori VARCHAR2(7);
  vr_dtrefere DATE;
  vr_nrdconta PLS_INTEGER;
  vr_indevchq PLS_INTEGER;
  vr_cdalinea PLS_INTEGER := 0;
  vr_flgcontr BOOLEAN;
  vr_flgdepos BOOLEAN;
  vr_flgchequ BOOLEAN;
  vr_cobranca BOOLEAN;
  vr_dtliblan DATE;
  vr_cdhistor PLS_INTEGER;
  vr_nrdiautl PLS_INTEGER := 0;
  vr_dsintegr VARCHAR2(30);
  
  -- Totais para o relatório 
  vr_tot_qtintdeb PLS_INTEGER := 0;
  vr_tot_vlintdeb NUMBER      := 0;
  vr_tot_qtintcre PLS_INTEGER := 0;
  vr_tot_vlintcre NUMBER      := 0;
  
  --Chamado 696499
  --Variaveis de inclusão de log 
  vr_idprglog     tbgen_prglog.idprglog%TYPE := 0;      
   
  -- Tipos para gravação dos totais integrados 
  TYPE typ_reg_totais IS RECORD(vlcompdb NUMBER 
                               ,qtcompdb PLS_INTEGER
                               ,vlcompcr NUMBER
                               ,qtcompcr PLS_INTEGER);
  TYPE typ_tab_totais IS TABLE OF typ_reg_totais INDEX BY PLS_INTEGER;
  vr_tab_totais typ_tab_totais;
  
  -- Totais dos saldos
  vr_ger_vlbloque NUMBER;
  
  -- Variaveis de controle xml
  vr_xmlrel CLOB;
  vr_txtrel VARCHAR2(32767);
  
  -- Estrutura para as leitura de várias cooperativas (Incorporação)
  TYPE typ_reg_crapcop IS RECORD (cdcooper PLS_INTEGER
                                 ,cdconven PLS_INTEGER
                                 ,nmarquiv VARCHAR2(1000)
                                 ,nmarqimp VARCHAR2(1000));                                   
  TYPE typ_tab_crapcop IS TABLE OF typ_reg_crapcop INDEX BY PLS_INTEGER;
  vr_tab_crapcop typ_tab_crapcop;  
  
  -- Estrutura para alimentar os saldos das contas
  TYPE typ_reg_crawdpb IS RECORD (vldispon NUMBER
                                 ,vlblq001 NUMBER
                                 ,vlblq002 NUMBER
                                 ,vlblq003 NUMBER
                                 ,vlblq004 NUMBER
                                 ,vlblq999 NUMBER); 
  TYPE typ_tab_crawdpb IS TABLE OF typ_reg_crawdpb INDEX BY PLS_INTEGER;
  vr_tab_crawdpb typ_tab_crawdpb;
  
  -- Tipo para armazenar valores do lote
  TYPE typ_reg_craplot IS RECORD(nrrowid  rowid
                                ,dtmvtolt craplot.dtmvtolt%type
                                ,cdagenci craplot.cdagenci%type
                                ,cdbccxlt craplot.cdbccxlt%type
                                ,nrdolote craplot.nrdolote%type
                                ,tplotmov craplot.tplotmov%type
                                ,qtinfoln craplot.qtinfoln%type
                                ,qtcompln craplot.qtcompln%type
                                ,vlinfodb craplot.vlinfodb%type
                                ,vlcompdb craplot.vlcompdb%type
                                ,vlinfocr craplot.vlinfocr%type
                                ,vlcompcr craplot.vlcompcr%type
                                ,nrseqdig craplot.nrseqdig%type);
  rw_craplot typ_reg_craplot;
  
  -- Buscar Folhas de Cheque 
  CURSOR cr_crapfdc(pr_cdageitg NUMBER 
                   ,pr_nrctachq NUMBER 
                   ,pr_nrcheque NUMBER) IS
    SELECT nrdconta
          ,incheque
          ,vlcheque
          ,dtemschq
          ,dtretchq  
          ,tpcheque
          ,cdbanchq
          ,cdagechq
          ,nrctachq
          ,rowid 
      FROM crapfdc 
     WHERE cdcooper = pr_cdcooper 
       AND cdbanchq = 1
       AND cdagechq = pr_cdageitg 
       AND nrctachq = pr_nrctachq 
       AND nrcheque = pr_nrcheque;
  rw_crapfdc cr_crapfdc%Rowtype;
  
  -- Busca do cadastro de associados
  CURSOR cr_crapass(pr_nrdconta NUMBER) IS
    SELECT cdsitdtl
          ,dtelimin
          ,cdagenci
      FROM crapass
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%rowtype;
  
  -- Busca lançamento para o cheque no dia
  CURSOR cr_craplcm_cheque(pr_nrdolote craplcm.nrdolote%type
                          ,pr_nrdctabb craplcm.nrdctabb%type
                          ,pr_nrdocmto craplcm.nrdocmto%type) IS
    SELECT 1
      FROM craplcm 
     WHERE craplcm.cdcooper = pr_cdcooper
       AND craplcm.dtmvtolt = rw_crapdat.dtmvtolt
       AND craplcm.cdagenci = vr_cdagenci
       AND craplcm.cdbccxlt = vr_cdbccxlt
       AND craplcm.nrdolote = pr_nrdolote
       AND craplcm.nrdctabb = pr_nrdctabb
       AND craplcm.nrdocmto = pr_nrdocmto;             
  vr_flgexis NUMBER;
       
  CURSOR cr_craplcm_cheque_cor(pr_nrdconta craplcm.nrdconta%type
                              ,pr_nrdocmto craplcm.nrdocmto%type) IS
    SELECT dtmvtolt 
      FROM craplcm 
     WHERE craplcm.cdcooper = pr_cdcooper
       AND craplcm.nrdconta = pr_nrdconta
       AND craplcm.nrdocmto = pr_nrdocmto
       AND craplcm.cdhistor in(21,50)
     ORDER BY dtmvtolt DESC; 
  rw_craplcm_cor cr_craplcm_cheque_cor%ROWTYPE;
  
  -- Buscar contra ordem no cheque
  CURSOR cr_crapcor(pr_cdageitg NUMBER 
                   ,pr_nrdctabb NUMBER 
                   ,pr_nrdocmto NUMBER ) IS
    SELECT dtvalcor
          ,dtemscor
          ,cdhistor
      FROM crapcor 
     WHERE cdcooper = pr_cdcooper
       AND cdbanchq = 1                
       AND cdagechq = pr_cdageitg 
       AND nrctachq = pr_nrdctabb     
       AND nrcheque = pr_nrdocmto     
       AND flgativo = 1;
  rw_crapcor cr_crapcor%ROWTYPE;   
     
  -- Buscar negativação vinculada ao cheque 
  CURSOR cr_crapneg(pr_nrdconta craplcm.nrdconta%type
                   ,pr_nrdocmto craplcm.nrdocmto%type) IS
    SELECT 1
      FROM crapneg 
     WHERE cdcooper = pr_cdcooper 
       AND nrdconta = pr_nrdconta 
       AND nrdocmto = pr_nrdocmto 
       AND cdhisest = 1
       AND cdobserv in(12,13)
       AND dtfimest is null;
  
  -- Busca do indicador de D/C do Histórico
  CURSOR cr_craphis(pr_cdcooper NUMBER 
                   ,pr_cdhistor NUMBER) IS
    SELECT indebcre 
      FROM craphis 
     WHERE cdcooper = pr_cdcooper 
       AND cdhistor = pr_cdhistor;                        
  
  -- Busca dos registros rejeitos
  CURSOR cr_craprej(pr_cdcooper NUMBER 
                   ,pr_nrdolote NUMBER) IS 
    SELECT cdcritic
          ,nrseqdig
          ,dshistor
          ,nrdctabb
          ,dtrefere
          ,nrdocmto
          ,cdpesqbb
          ,vllanmto
          ,indebcre
          ,nrdconta
      FROM craprej 
     WHERE cdcooper = pr_cdcooper 
       AND dtmvtolt = rw_crapdat.dtmvtolt 
       AND cdagenci = vr_cdagenci
       AND cdbccxlt = vr_cdbccxlt
       AND nrdolote = pr_nrdolote
       AND tpintegr = 1
     ORDER BY dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,tpintegr
             ,nrdctabb
             ,dtdaviso
             ,nrdocmto
             ,nrseqdig;
  
  -- Leitura dos lancamentos integrados  --  Maiores cheques
  CURSOR cr_craplcm_integra(pr_nrdolote NUMBER) IS
    SELECT nrdctabb
          ,nrdocmto
          ,nrdconta
          ,cdhistor
          ,vllanmto
          ,cdpesqbb
          ,nrseqdig
      FROM craplcm 
     WHERE cdcooper  = pr_cdcooper   
       AND dtmvtolt  = rw_crapdat.dtmvtolt
       AND cdagenci  = vr_cdagenci
       AND cdbccxlt  = vr_cdbccxlt
       AND nrdolote  = pr_nrdolote
       AND cdhistor IN(50,59)         
       AND vllanmto >= vr_vlmaichq;
  
  -- Função genérica para converter valores num texto separado por "," para pltable numérica
  FUNCTION fn_converte_texto_vetor_n(pr_dstexto in varchar2) RETURN typ_tab_valores_n IS
    -- Tipos para transformação de lista texto em vetor
    vr_tab_split   gene0002.typ_split;
    vr_tab_valores typ_tab_valores_n;
  BEGIN
    -- Joga as contas em uma temp-table
    vr_tab_split := gene0002.fn_quebra_string(pr_dstexto,',');
    -- Varre a tabela criando registros na tabela de retorno 
    IF vr_tab_split.count() > 0 THEN
      -- Itera sobre o array para pesquisar seus objetos
      FOR idx IN 1..vr_tab_split.count() LOOP
        -- Criar o registro na tabela (tratar em bloco pra evitar erro no formato)
        vr_tab_valores(vr_tab_split(idx)) := vr_tab_split(idx);
      END LOOP;
    END IF;
    -- Retornar tabela convertida 
    RETURN vr_tab_valores;
  END;
  
  -- Função genérica para converter valores num texto separado por "," para pltable alfanumérica
  FUNCTION fn_converte_texto_vetor_t(pr_dstexto in varchar2) RETURN typ_tab_valores_t IS
    -- Tipos para transformação de lista texto em vetor
    vr_tab_split   gene0002.typ_split;
    vr_tab_valores typ_tab_valores_t;
  BEGIN
    -- Joga as contas em uma temp-table
    vr_tab_split := gene0002.fn_quebra_string(pr_dstexto,',');
    -- Varre a tabela criando registros na tabela de retorno 
    IF vr_tab_split.count() > 0 THEN
      -- Itera sobre o array para pesquisar seus objetos
      FOR idx IN 1..vr_tab_split.count() LOOP
        -- Criar o registro na tabela (tratar em bloco pra evitar erro no formato)
        vr_tab_valores(vr_tab_split(idx)) := vr_tab_split(idx);
      END LOOP;
    END IF;
    -- Retornar tabela convertida 
    RETURN vr_tab_valores;
  END;
  
  
  -- Subrotina para processamento dos saldos e gravacao em temp-table
  PROCEDURE pc_leitura_saldos(pr_dslinhar  IN VARCHAR2
                             ,pr_nrdctabb  IN pls_integer
                             ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    --Inclusão nome do módulo logado - Chamado 696499
    gene0001.pc_set_modulo(pr_module => 'PC_CRPS346'
                          ,pr_action => 'pc_leitura_saldos');

    -- Somente se houver Registro de Saldo
    IF substr(pr_dslinhar,42,1) = '0' OR substr(pr_dslinhar,42,1) = '2' THEN 
      -- Verifica se existe registro na temp-table
      IF NOT vr_tab_crawdpb.exists(pr_nrdctabb) THEN 
        -- Criarmos o registro zerado para evitar no-data-found 
        vr_tab_crawdpb(pr_nrdctabb).vldispon := 0;
        vr_tab_crawdpb(pr_nrdctabb).vlblq001 := 0;
        vr_tab_crawdpb(pr_nrdctabb).vlblq002 := 0;
        vr_tab_crawdpb(pr_nrdctabb).vlblq003 := 0;
        vr_tab_crawdpb(pr_nrdctabb).vlblq004 := 0;
        vr_tab_crawdpb(pr_nrdctabb).vlblq999 := 0;
      END IF;
      -- Para registro do tipo 2
      IF substr(pr_dslinhar,42,1) = '2' THEN
        -- Incrementer saldo disponível
        vr_tab_crawdpb(pr_nrdctabb).vldispon := vr_tab_crawdpb(pr_nrdctabb).vldispon +
                                                (to_number(nvl(trim(substr(pr_dslinhar,087,18)),0)) / 100);
      ELSE 
        -- Incrementar valores bloqueados
        vr_tab_crawdpb(pr_nrdctabb).vlblq001 := vr_tab_crawdpb(pr_nrdctabb).vlblq001 +
                                                (to_number(nvl(trim(substr(pr_dslinhar,157,17)),0)) / 100);
        vr_tab_crawdpb(pr_nrdctabb).vlblq002 := vr_tab_crawdpb(pr_nrdctabb).vlblq002 +
                                                (to_number(nvl(trim(substr(pr_dslinhar,140,17)),0)) / 100);
        vr_tab_crawdpb(pr_nrdctabb).vlblq003 := vr_tab_crawdpb(pr_nrdctabb).vlblq003 +
                                                (to_number(nvl(trim(substr(pr_dslinhar,123,17)),0)) / 100);
        vr_tab_crawdpb(pr_nrdctabb).vlblq004 := vr_tab_crawdpb(pr_nrdctabb).vlblq004 +
                                                (to_number(nvl(trim(substr(pr_dslinhar,106,17)),0)) / 100);
        vr_tab_crawdpb(pr_nrdctabb).vlblq999 := vr_tab_crawdpb(pr_nrdctabb).vlblq999 +
                                                (to_number(nvl(trim(substr(pr_dslinhar,043,17)),0)) / 100);
      END IF;                                          
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      --Inclusão na tabela de erros Oracle - Chamado 696499
      CECRED.pc_internal_exception( pr_cdcooper => NULL
                                   ,pr_compleme => pr_dscritic );

      pr_dscritic := 'Erro nao tratado na leitura do saldo --> '||sqlerrm;
  END;
  
BEGIN
  -- Incluir nome do modulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => null);
                            
  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
  FETCH cr_crapcop
   INTO rw_crapcop;
  -- Se nao encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois havera raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    vr_cdcritic := 651;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;

  -- Leitura do calendario da cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat
   INTO rw_crapdat;
  -- Se nao encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE btch0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE btch0001.cr_crapdat;
  END IF;

  -- Validacoes iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);
  -- Se a variavel de erro e <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;
  
  -- Busca do diretório Integracao
  vr_nmdircop := gene0001.fn_diretorio('C',pr_cdcooper);
  
  -- Caso execução pela COMPEFORA
  IF pr_nmtelant = 'COMPEFORA' THEN
    vr_dtleiarq := rw_crapdat.dtmvtoan;    
  ELSE
    vr_dtleiarq := rw_crapdat.dtmvtolt;
  END IF;   
   
  -- Criar registros na Temp-Table de Cooperativas a processar
  vr_tab_crapcop(1).cdcooper := pr_cdcooper;
  
  -- Tratar incorporações
  IF pr_cdcooper = 1 THEN
    vr_tab_crapcop(2).cdcooper := 4;  /* Incorporacao Concredi */
  ELSIF pr_cdcooper = 13 THEN
    vr_tab_crapcop(2).cdcooper := 15; /* Incorporacao Credimilsul */
  ELSIF pr_cdcooper = 9 THEN
    vr_tab_crapcop(2).cdcooper := 17; /* Incorporacao Transulcred */
  END IF;
    
  -- inicializar variavel de controle se existe algum arquivo a ser processado
  vr_flgarqui := FALSE;
  
  -- Buscar todos os arquivos da pasta COMPBB conforme convenio da CRAPTAB
  FOR vr_idx IN 1..vr_tab_crapcop.COUNT LOOP
    -- Armazenar o nome do arquivo que deverá estar na Integra para o processo continuar
    vr_tab_crapcop(vr_idx).nmarquiv := 'deb558_346_' 
                                    || to_char(vr_dtleiarq,'rrrrmmdd')
                                    || '_' || to_char(vr_tab_crapcop(vr_idx).cdcooper,'fm00')||'.bb';

    -- Buscar o convênio conforme CRAPTAB
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => vr_tab_crapcop(vr_idx).cdcooper 
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'COMPEARQBB'
                                             ,pr_tpregist => 346);

    -- Se não encontrar
    IF trim(vr_dstextab) IS NULL THEN
      -- Gerar critica 55
      vr_cdcritic := 55;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' (COMPEARQBB)';
      RAISE vr_exc_saida;
    ELSE
      -- Guardar numero do convênio
      vr_tab_crapcop(vr_idx).cdconven := SUBSTR(vr_dstextab,1,9);

      -- Busca o arquivo DEB558 em um unico arquivo 
      vr_nomedarq := 'deb558%'||to_char(vr_dtleiarq,'DDMMRR')||'%'||to_char(vr_tab_crapcop(vr_idx).cdconven,'fm000000000') || '%';
      
      -- Busca os arquivos da pasta compbb
      gene0001.pc_lista_arquivos(vr_nmdircop||'/compbb', vr_nomedarq, vr_dslisarq, vr_dscritic);

      -- Se houver erro
      IF vr_dscritic IS NOT NULL THEN 
        RAISE vr_exc_saida;
      END IF;
      -- Separa a lista de arquivos em uma tabela com todos os encontrados
      vr_splisarq := gene0002.fn_quebra_string(vr_dslisarq, ',');
      -- Verifica se a quebra resultou em um array válido
      IF vr_splisarq.count() > 0 THEN
        -- Iterar sob cada arquivo encontrado
        FOR idx IN 1..vr_splisarq.count() LOOP
          -- Para cada arquivo, movê-lo para a integra renomeando-o
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'mv ' || vr_nmdircop||'/compbb/'||vr_splisarq(idx) || ' ' 
                                                              || vr_nmdircop||'/integra/'||vr_tab_crapcop(vr_idx).nmarquiv
                                     ,pr_typ_saida => vr_typsaida
                                     ,pr_des_saida => vr_dessaida);
          -- Havendo erro, finalizar
          IF vr_typsaida = 'ERR' THEN
            vr_dscritic := vr_dessaida;
            RAISE vr_exc_saida;
          END IF;        
        END LOOP;  
      END IF;
    END IF;  
  END LOOP;

  -- Se a tabela abaixo existir, deve processar os arquivos de deposito
  vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                           ,pr_nmsistem => 'CRED'
                                           ,pr_tptabela => 'GENERI'
                                           ,pr_cdempres => 0
                                           ,pr_cdacesso => 'COMPECHQBB'
                                           ,pr_tpregist => 0);

  IF trim(vr_dstextab) IS NULL THEN
    vr_flgchqbb := FALSE;
  ELSE
    vr_flgchqbb := TRUE;
  END IF;  
    
  -- Buscar valores VLB
  vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                           ,pr_nmsistem => 'CRED'
                                           ,pr_tptabela => 'GENERI'
                                           ,pr_cdempres => 0
                                           ,pr_cdacesso => 'VALORESVLB'
                                           ,pr_tpregist => 0);

  IF trim(vr_dstextab) IS NOT NULL THEN
    vr_vlchqvlb := to_number(gene0002.fn_busca_entrada(2,vr_dstextab,';'));
  ELSE
    vr_vlchqvlb := 0;
  END IF;  
    
  -- Carregar lista de agencias 
  vr_tab_lsagenci := fn_converte_texto_vetor_n('14077,16179,305057,3164012,405019,407020,410020,486019,562017,714020,828017'); 
    
  -- Montagem dos históricos para processamento
  vr_tab_hstchq := fn_converte_texto_vetor_t('0002,0102,0102,0103,0113,0300,0452,0033,0455,0456,0457,0458,0500');
    
  vr_dshstblq := '0511BL.1D UTIL,0512BL.2D UTIL,0513BL.3D UTIL,'
              || '0514BL.4D UTIL,0515BL.5D UTIL,0516BL.6D UTIL,'
              || '0517BL.7D UTIL,0518BL.8D UTIL,0519BL.9D UTIL,'
              || '0520DEP.BL.IND,'
              || '0911DEP.BL.1D,0912DEP.BL.2D,0913DEP.BL.3D,'
              || '0914DEP.BL.4D,0915DEP.BL.5D,0916DEP.BL.6D,'
              || '0917DEP.BL.7D,0918DEP.BL.8D,0919DEP.BL.9D,'
              || '0920DEP.BL.IND';
 
  vr_tab_hstblq := fn_converte_texto_vetor_t(vr_dshstblq);
                                           
  -- ATENCAO: O historico 623-DEP. COMPE nao sera tratado 
  vr_tab_hstdep := fn_converte_texto_vetor_t('0502DEPOSITO,0505DEP.CHEQUE,0830DEP.ONLINE,0870TRF.ONLINE,' || vr_dshstblq);

  -- Especifica da Cobrança
  vr_tab_hstcob := fn_converte_texto_vetor_t('0624COBRANCA');
     
  -- Iterar sobre todas as Coops da executação
  FOR vr_idx IN vr_tab_crapcop.first..vr_tab_crapcop.last LOOP
    -- Se não existir arquivo gravado no registro
    IF vr_tab_crapcop(vr_idx).nmarquiv IS NULL THEN
      -- Ir ao proximo registro
      CONTINUE;
    END IF;
      
    --  Le tabela com as contas convenio do Banco do Brasil - Geral .............
    vr_tab_contas := fn_converte_texto_vetor_n(gene0005.fn_busca_conta_centralizadora(vr_tab_crapcop(vr_idx).cdcooper,0));
    -- Le tabela com as contas convenio do Banco do Brasil - talao transf ......
    vr_tab_conta2 := fn_converte_texto_vetor_n(gene0005.fn_busca_conta_centralizadora(vr_tab_crapcop(vr_idx).cdcooper,2));
    -- Le tabela com as contas convenio do Banco do Brasil - chq.salario ....... 
    vr_tab_conta3 := fn_converte_texto_vetor_n(gene0005.fn_busca_conta_centralizadora(vr_tab_crapcop(vr_idx).cdcooper,3));
      
    -- Reiniciar variaveis para cada Coop
    vr_tab_crapcop(vr_idx).nmarqimp := 'crrl291_' || to_char(vr_tab_crapcop(vr_idx).cdcooper,'fm00') || '.lst';
    vr_cdcritic := 0;
    vr_nrdolote := 0;
    vr_flgarqvz := TRUE;
    vr_flgfirst := TRUE;
    vr_flgentra := TRUE;
    vr_nrdlinha := 0;
    vr_ger_vlbloque := 0;      
      
    -- Se por algum motivo o arquivo não mais existir, ele já deve ter sido processado
    IF NOT gene0001.fn_exis_arquivo(vr_nmdircop||'/integra/'||vr_tab_crapcop(vr_idx).nmarquiv) THEN
      -- Continuar para a próxima COOP
      CONTINUE;
    ELSE 
      -- Indicar que encontrou um arquivo para processamento
      vr_flgarqui := TRUE;
    END IF;
      
    -- Limpar tabela de saldos
    vr_tab_crawdpb.delete;
      
    --Geração de log de erro - Chamado 696499
    --Enviar critica 219 ao LOG
    vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                           ' --> ' || 'ALERTA: ' ||gene0001.fn_busca_critica(219) ||
                           ': '||vr_tab_crapcop(vr_idx).nmarquiv;
      
    cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                           pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                           pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                           pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia  => 4,            -- tbgen_prglog_ocorrencia - 4 - Mensagem
                           pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                           pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                           pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                           pr_nmarqlog      => NULL, 
                           pr_idprglog      => vr_idprglog);
      
    -- Efetuar abertura do arquivo 
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdircop||'/integra/'
                            ,pr_nmarquiv => vr_tab_crapcop(vr_idx).nmarquiv
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_arqhandle
                            ,pr_des_erro => vr_dscritic);
    -- Em caso de problema na abertura do arquivo 
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Erro na abertura do arquivo --> ' || vr_tab_crapcop(vr_idx).nmarquiv|| ' --> ' ||vr_dscritic;
      RAISE vr_exc_saida;
    END IF;
      
    -- Efetuar laço para processamento das linhas do arquivo 
    BEGIN 
      LOOP 
        -- Leitura linha a linha           
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqhandle
                                    ,pr_des_text => vr_dslinharq);
        -- Incrementar contador 
        vr_nrdlinha := vr_nrdlinha + 1;
        -- Ignorar Header e Trailler, ou seja, registros que não comecem com 1
        IF substr(vr_dslinharq,1,1) <> '1' THEN
          CONTINUE;
        END IF;
        -- Ignorar conta Cecred cancelada e que ainda vem no arquivo
        IF pr_cdcooper = 3 AND substr(vr_dslinharq,37,5) = '5027X' THEN
          CONTINUE;
        END IF;
        
        -- Inicializar variaveis
        vr_nrdconta := 0;
          
        -- Separar numero da conta (substituindo digito X por 0)
        BEGIN 
          IF SUBSTR(vr_dslinharq,41,01) = 'X' THEN
            vr_nrdctabb := SUBSTR(vr_dslinharq,33,08) || '0';
          ELSE     
            vr_nrdctabb := SUBSTR(vr_dslinharq,33,09);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := ' na leitura da conta ['||SUBSTR(vr_dslinharq,33,09)||']';
            raise vr_exc_saida;
        END;
        pc_leitura_saldos(vr_dslinharq,vr_nrdctabb,vr_dscritic);
        -- Ao encontrar erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Se a conta não estiver na listagem parametrizada
        IF NOT vr_tab_contas.exists(vr_nrdctabb) THEN 
          -- Pular 
          CONTINUE;
        END IF;
        -- Setar flag de encontro
        vr_flgarqvz := FALSE;
        -- Ignorar registro com 1 na posição 42
        IF substr(vr_dslinharq,42,1) <> '1' THEN
          CONTINUE;
        END IF;
          
        -- Leitura de informações para o processamento
        BEGIN 
          vr_nrseqint := substr(vr_dslinharq,195,6);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := ' na leitura da seqint ['||SUBSTR(vr_dslinharq,195,6)||']';
            raise vr_exc_saida;
        END;
        vr_dshistor := TRIM(substr(vr_dslinharq,46,29));
        BEGIN 
          vr_nrdocmto := TO_NUMBER(substr(vr_dslinharq,75,6)) * 10;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := ' na leitura do nrdocmto ['||SUBSTR(vr_dslinharq,75,6)||']';
            raise vr_exc_saida;
        END;  
        BEGIN   
          vr_vllanmto := TO_NUMBER(substr(vr_dslinharq,87,18)) / 100;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := ' na leitura do valor lancamento ['||SUBSTR(vr_dslinharq,87,18)||']';
            raise vr_exc_saida;
        END;              
        BEGIN 
          vr_dtmvtolt := to_date(substr(vr_dslinharq,182,2)||substr(vr_dslinharq,184,2)||substr(vr_dslinharq,186,4),'ddmmrrrr');
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := ' na leitura da data ['||substr(vr_dslinharq,182,2)||substr(vr_dslinharq,184,2)||substr(vr_dslinharq,186,4)||']';
            raise vr_exc_saida;
        END;              
        BEGIN 
          IF to_number(substr(vr_dslinharq,43,3)) > 100 AND to_number(substr(vr_dslinharq,43,3)) < 200 THEN 
            vr_indebcre := 'D';
          ELSE
            vr_indebcre := 'C';
          END IF;  
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := ' na leitura do tipo(D/C) ';
            raise vr_exc_saida;
        END;              
        vr_cdpesqbb := substr(vr_dslinharq,111,5) || '-000-' || substr(vr_dslinharq,120,3);                                
        vr_dsageori := substr(vr_dslinharq,116,4) || '.00';
        BEGIN 
          IF to_number(substr(vr_dslinharq,174,8)) > 0 THEN 
            vr_dtrefere := to_date(substr(vr_dslinharq,174,2)||substr(vr_dslinharq,176,2)||substr(vr_dslinharq,178,4),'ddmmrrrr');
          ELSE
            vr_dtrefere := NULL;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := ' na leitura da Data Referencia.';
            raise vr_exc_saida;
        END;
        -- Calculo novamente o digito verificador do numero do documento 
        vr_stsnrcal := GENE0005.fn_calc_digito (pr_nrcalcul => vr_nrdocmto);
        -- Validar datas do processamento
        IF pr_nmtelant = 'COMPEFORA' THEN
          IF vr_dtmvtolt <> rw_crapdat.dtmvtoan THEN
            CONTINUE;
          END IF;  
        ELSIF vr_dtmvtolt <> rw_crapdat.dtmvtolt THEN
          CONTINUE;
        END IF;  
          
        -- Na primeira execução da Coop
        IF vr_flgfirst THEN
          -- Le numero de lote a ser usado na integracao
          vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 0
                                                   ,pr_cdacesso => 'NUMLOTECBB'
                                                   ,pr_tpregist => 1);
          IF trim(vr_dstextab) IS NULL THEN
            -- Gerar critica 259
            vr_cdcritic := 259;
            raise vr_exc_saida;
          ELSE
            -- Gravar numero do lote e atualizar controle
            vr_nrdolote := to_number(vr_dstextab) + 1;
            vr_flgclote := true;
            vr_flgfirst := false;
          END IF;  
        END IF;
          
        -- Buscar os tipos de movimento da linha
        IF vr_tab_hstdep.exists(vr_dshistor) THEN 
          /* Depósitos */
          vr_flgdepos := TRUE;
          vr_flgchequ := FALSE;
        ELSIF vr_tab_hstchq.exists(SUBSTR(vr_dshistor,1,4)) THEN    
          /*  Cheque  */
          vr_flgdepos := FALSE;
          vr_flgchequ := TRUE;
        ELSE
          /* Outros */
          vr_cdcritic := 245;                              
          vr_flgdepos := FALSE;
          vr_flgchequ := TRUE;
        END IF;
          
        -- Verifica se movto cobranca 0624
        vr_cobranca := FALSE; 
        IF vr_cdcritic = 245 THEN 
          -- 245 - Historico nao processado.            
          IF vr_tab_hstcob.exists(vr_dshistor) THEN 
            /* 0624COBRANCA */
            vr_cobranca := TRUE;
          END IF;  
        END IF;
          
        -- Checar criticas 
        IF vr_cdcritic = 0  THEN
          -- Se não há numero de documento
          IF vr_nrdocmto = 0  THEN
            -- 022 - Numero do documento errado.
            vr_cdcritic := 22;
          ELSE
            -- Calcular digito verificador
            vr_nrcalcul := vr_nrdocmto;
            vr_stsnrcal := GENE0005.fn_calc_digito (pr_nrcalcul => vr_nrcalcul);
            -- Se deposito 
            IF vr_flgdepos THEN
              -- Se o digito calculo não faz parte da lista de agencias
              IF vr_tab_lsagenci.exists(vr_nrcalcul) THEN
                -- 577 - Verifique o numero da conta.
                vr_cdcritic := 577;
              ELSE
                -- Usar a conta calculada
                vr_nrdconta := vr_nrcalcul;
              END IF;  
            ELSE 
              IF NOT vr_stsnrcal THEN
                -- 008 - Digito errado.
                vr_cdcritic := 8;
              END IF;  
              -- Deve haver valor de lançamento
              IF vr_vllanmto = 0 THEN
                -- 091 - Valor do lancamento errado.
                vr_cdcritic := 91;
              END IF;  
            END IF;
          END IF;  
        END IF;
          
        -- Se não houve encontro de criticas E processamento de cheques
        IF vr_cdcritic = 0 AND vr_flgchequ THEN
          -- Calcular conta ITG
          gene0005.pc_conta_itg_digito_x (pr_nrcalcul => vr_nrdctabb
                                         ,pr_dscalcul => vr_dsdctitg
                                         ,pr_stsnrcal => vr_stsnrcal_int
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
          -- Sair em caso de erro
          IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          ELSE
            vr_cdcritic := 0;
          END IF;
            
          -- Montar novo numero de documento
          vr_nrdocmt2 := SUBSTR(to_char(vr_nrdocmto,'fm0000000'),1,6);
            
          -- Buscar Folhas de Cheque 
          OPEN cr_crapfdc(pr_cdageitg => rw_crapcop.cdageitg
                         ,pr_nrctachq => vr_nrdctabb
                         ,pr_nrcheque => vr_nrdocmt2);
          FETCH cr_crapfdc 
           INTO rw_crapfdc;
          -- Se não encontar
          IF cr_crapfdc%notfound THEN
            -- Fechar cursor
            CLOSE cr_crapfdc;
            -- Montar critica conforme situação
            IF vr_tab_conta3.exists(vr_nrdctabb) THEN
              -- 286 - Cheque salario nao existe.
              vr_cdcritic := 286;
            ELSE
              -- 108 - Talonario nao emitido.
              vr_cdcritic := 108;
            END IF;
          ELSE
            -- Continuar
            CLOSE cr_crapfdc;
          END IF;
          -- Somente se não encontrou critica
          IF vr_cdcritic = 0 THEN 
            vr_nrdconta := rw_crapfdc.nrdconta;
            -- Criticas padrão
            IF rw_crapfdc.incheque in(5,6,7) THEN
              -- 097 - Cheque ja entrou.
              vr_cdcritic := 97;
            ELSIF rw_crapfdc.incheque = 8   THEN
              -- 320 - Cheque cancelado.
              vr_cdcritic := 320;
            END IF;  
            -- Caso CHQ SAL
            IF vr_tab_conta3.exists(vr_nrdctabb) THEN
              IF rw_crapfdc.nrdconta = 0 THEN
                -- 286 - Cheque salario nao existe.
                vr_cdcritic := 286;
              ELSIF rw_crapfdc.incheque = 1 THEN
                -- 096 - Cheque com contra-ordem.
                vr_flgcontr := TRUE;
              ELSIF rw_crapfdc.vlcheque <> vr_vllanmto THEN
                -- 269 - Valor errado.
                vr_cdcritic := 269;
              END IF;     
            ELSE 
              -- Outros casos 
              IF rw_crapfdc.dtemschq IS NULL THEN
                -- 108 - Talonario nao emitido.
                vr_cdcritic := 108;
              ELSIF rw_crapfdc.dtretchq IS NULL THEN
                vr_cdcritic := 109;
              END IF;     
            END IF;              
          END IF;
        END IF;
        -- Se não encontrou critica
        IF vr_cdcritic = 0 THEN
          -- Busca associado 
          OPEN cr_crapass(vr_nrdconta);
          FETCH cr_crapass 
           INTO rw_crapass;
          -- Se não encontrar 
          IF cr_crapass%NOTFOUND THEN
            -- Fechar cursor e gerar critica 009
            CLOSE cr_crapass;
            vr_cdcritic := 9;
          ELSE
            -- Fechar cursor e testar outras situações
            CLOSE cr_crapass;
            IF rw_crapass.cdsitdtl IN (5,6,7,8) THEN
              -- 695 - ATENCAO! Houve prejuizo nessa conta
              vr_cdcritic := 695;
            ELSIF rw_crapass.cdsitdtl IN(2,4,6,8) THEN
              -- 095 - Titular da conta bloqueado.
              vr_cdcritic := 95;
            ELSIF rw_crapass.dtelimin IS NOT NULL THEN
              -- 410 - Associado excluido.
              vr_cdcritic := 410;
            END IF;
          END IF;            
        END IF;
          
        -- Se foi solicitada criação de lote
        IF vr_flgclote THEN
          -- Tentaremos criar o registro do lote
          BEGIN
            INSERT INTO craplot (cdcooper
                                ,dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov)
                          VALUES(pr_cdcooper  -- cdcooper
                                ,rw_crapdat.dtmvtolt  -- dtmvtolt
                                ,vr_cdagenci  -- cdagenci
                                ,vr_cdbccxlt  -- cdbccxlt
                                ,vr_nrdolote  -- nrdolote
                                ,1)           -- tplotmov
                       RETURNING rowid
                                ,dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov
                                ,qtinfoln 
                                ,qtcompln 
                                ,vlinfodb 
                                ,vlcompdb 
                                ,vlinfocr
                                ,vlcompcr
                            INTO rw_craplot.nrrowid 
                                ,rw_craplot.dtmvtolt
                                ,rw_craplot.cdagenci
                                ,rw_craplot.cdbccxlt
                                ,rw_craplot.nrdolote
                                ,rw_craplot.tplotmov
                                ,rw_craplot.qtinfoln 
                                ,rw_craplot.qtcompln 
                                ,rw_craplot.vlinfodb 
                                ,rw_craplot.vlcompdb 
                                ,rw_craplot.vlinfocr
                                ,rw_craplot.vlcompcr;
          EXCEPTION
            WHEN dup_val_on_index THEN
              -- Lote já existe, critica 59
              vr_cdcritic := 59;
              vr_dscritic := gene0001.fn_busca_critica(59) || ' COMPBB - LOTE = ' || to_char(vr_nrdolote,'fm000g000');
              RAISE vr_exc_saida;
            WHEN others THEN 
              -- Erro não tratado 
              vr_dscritic := ' na insercao do lote '||vr_nrdolote|| ' --> ' || sqlerrm;
              RAISE vr_exc_saida;
          END;  
          -- Atualizar CRAPTAB 
          BEGIN
            UPDATE craptab 
               SET dstextab = vr_nrdolote 
             WHERE cdcooper = pr_cdcooper
               AND UPPER(nmsistem) = 'CRED'
               AND UPPER(tptabela) = 'GENERI'
               AND cdempres = 0
               AND UPPER(cdacesso) = 'NUMLOTECBB'
               AND tpregist = 1;               
          EXCEPTION
            WHEN others THEN
              vr_dscritic := ' na atualizada da TAB de lote --> '||sqlerrm;
              RAISE vr_exc_saida;
          END;            
          -- Atualizar o controle indicando que houve criação do lote
          vr_flgclote := false;
        END IF;
        -- Não havendo critica e com flag de cheque
        IF vr_cdcritic = 0 AND vr_flgchequ THEN
          -- Busca se já existe lançamento para aquele cheque
          OPEN cr_craplcm_cheque(vr_nrdolote,vr_nrdctabb,vr_nrdocmto);
          FETCH cr_craplcm_cheque
           INTO vr_flgexis;
          -- Se encontrou
          IF cr_craplcm_cheque%FOUND THEN
            -- Fechar cursor e criticar 92
            CLOSE cr_craplcm_cheque;
            -- 092 - Lancamento ja existe
            vr_cdcritic := 92;
          ELSE 
            -- Fechar cursor e continuar as validações 
            CLOSE cr_craplcm_cheque;
            -- Para contas da lista 3
            IF vr_tab_conta3.exists(vr_nrdctabb) THEN
              IF rw_crapfdc.incheque = 2 THEN 
                -- Gerar critica 287
                -- 287 - Cheque salario com alerta!!!                  
                vr_cdcritic := 287;
              END IF;  
            -- Para contas da lista 2
            ELSIF vr_tab_conta2.exists(vr_nrdctabb) THEN
              IF rw_crapfdc.incheque = 2 THEN
                -- Gerar critica 257
                -- 257 - Cheque com alerta.
                vr_cdcritic := 257;
              ELSIF rw_crapfdc.incheque = 1 THEN
                -- Gerar critica 96
                -- 096 - Cheque com contra-ordem.                  
                vr_cdcritic := 096;
                vr_indevchq := 3;
              END IF;
            ELSE
              -- Testar cheque com alerta
              IF rw_crapfdc.incheque = 2 THEN
                -- Gerar critica 257
                -- 257 - Cheque com alerta.
                vr_cdcritic := 257;
              ELSIF rw_crapfdc.incheque = 1 THEN 
                -- Buscar lançamento nos históricos:
                -- 21 - CHEQUE
                -- 50	- CHEQUE COMP.
                OPEN cr_craplcm_cheque_cor(vr_nrdconta,vr_nrdocmto);
                FETCH cr_craplcm_cheque_cor
                 INTO rw_craplcm_cor;
                -- Se não encontrar
                IF cr_craplcm_cheque_cor%NOTFOUND THEN                   
                  -- Fechar cursor e gerar critica 96
                  CLOSE cr_craplcm_cheque_cor;
                  -- 096 - Cheque com contra-ordem.
                  vr_cdcritic := 96;
                  vr_indevchq := 1;
                  vr_cdalinea := 0;
                ELSE
                  -- Fechar cursor e continuar procurando
                  CLOSE cr_craplcm_cheque_cor;
                  -- Buscar contra-ordem no cheque 
                  OPEN cr_crapcor(rw_crapcop.cdageitg
                                 ,vr_nrdctabb
                                 ,vr_nrdocmto);
                  -- Se não encontrar contra ordem
                  IF cr_crapcor%NOTFOUND THEN                     
                    -- Fechar o cursor e gerar critica 439
                    CLOSE cr_crapcor;
                    -- 439 - Ch. C.Ordem - Apr. Indevida.
                    vr_cdcritic := 439;
                    vr_indevchq := 1;
                    vr_cdalinea := 49;                      
                  ELSE 
                    -- Fechar o cursor e continuar
                    CLOSE cr_crapcor;
                    -- Se a Contra Ordem está no futuro ainda 
                    IF rw_crapcor.dtvalcor >= rw_crapdat.dtmvtolt THEN
                      -- Gerar critica 96 
                      -- 096 - Cheque com contra-ordem.
                      vr_cdcritic := 96;
                      IF rw_crapfdc.tpcheque = 1 THEN 
                        vr_indevchq := 1;
                      ELSE 
                        vr_indevchq := 3;
                      END IF;                        
                      vr_cdalinea := 70;
                    -- Se a data do envio é superior ao ultimo lançamento 
                    ELSIF rw_crapcor.dtemscor > rw_craplcm_cor.dtmvtolt   THEN
                      -- Gerar critica 96
                      -- 096 - Cheque com contra-ordem.
                      vr_cdcritic := 96;
                      vr_indevchq := 1;
                      vr_cdalinea := 0;
                    -- Se não se enquadrar em nenhum caso                      
                    ELSE
                      -- gerar critica 439
                      -- 439 - Ch. C.Ordem - Apr. Indevida.
                      vr_cdcritic := 439;
                      vr_indevchq := 1;
                      vr_cdalinea := 43;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
        -- Monta a data de liberacao para depositos bloqueados 
        IF vr_cdcritic = 0 AND vr_flgdepos THEN 
          -- Testar bloqueio 
          IF vr_tab_hstblq.exists(vr_dshistor) THEN 
            -- Contagem dos dias uteis
            vr_nrdiautl := 0;
            -- Buscar caractere a caractere do histórico
            FOR vr_contador IN 1..LENGTH(vr_dshistor) LOOP
              -- Buscar a quantidade de dias do bloqueio
              vr_nrdiautl := INSTR(vr_dshistor,vr_contador||'D');
              -- Se encontrou 
              IF vr_nrdiautl > 0 THEN
                -- Guardar o contador 
                vr_nrdiautl := vr_contador;
                EXIT;
              END IF;
            END LOOP;
            -- Se não achou a quantidade de dias
            IF vr_nrdiautl = 0 THEN 
              -- Gerar critica 245;
              -- 245 - Historico nao processado.
              vr_cdcritic := 245;
            ELSE 
              -- Gerar histórico 170
              vr_cdhistor := 170;
              vr_dtliblan := rw_crapdat.dtmvtopr;
              -- Para casos de mais de 1 dia
              IF vr_nrdiautl > 1 THEN       
                -- Buscar a data da liberação conforme a quantidade de dias
                LOOP 
                  -- Sair quando finalizar a quantidade de dias de bloqueio
                  EXIT WHEN vr_nrdiautl = 1;
                  -- Adicionar um dia 
                  vr_dtliblan := vr_dtliblan + 1;
                  -- Chamar rotina que valida o dia em util, buscado seu próximo caso não seja
                  vr_dtliblan := gene0005.fn_valida_dia_util(pr_cdcooper,vr_dtliblan);
                  -- Decrementar pois encontramos mais um dia util 
                  vr_nrdiautl := vr_nrdiautl - 1;
                END LOOP;
              END IF;
            END IF; 
          ELSE 
            -- Gerar histórico 169 
            vr_cdhistor := 169;
            vr_dtliblan := null;
          END IF;
          -- Se chegou neste ponto sem critica
          IF vr_cdcritic = 0 THEN 
            -- Gerar critica 762 
            -- 762 - Deposito NAO processado.
            vr_cdcritic := 762;
          END IF;
        END IF;
          
        -- Se houve encontro de critica 
        IF vr_cdcritic > 0 OR  vr_flgcontr THEN
          -- Para contraordem
          IF vr_flgcontr THEN
            -- 096 - Cheque com contra-ordem.
            vr_cdcritic := 96;
          END IF;
          -- Para cobrança
          IF vr_cobranca THEN
            -- 784 - Processado via Cobranca
            vr_cdcritic := 784;
          END IF;
          -- Efetuar criação da CRAPREJ
          BEGIN 
            INSERT INTO CRAPREJ (cdcooper
                                ,dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov
                                ,nrdconta
                                ,nrdctabb
                                ,nrdctitg
                                ,dshistor
                                ,cdpesqbb
                                ,nrseqdig
                                ,nrdocmto
                                ,vllanmto
                                ,indebcre
                                ,dtrefere
                                ,cdcritic
                                ,dtdaviso
                                ,tpintegr)
                         VALUES (pr_cdcooper                              -- cdcooper
                                ,rw_craplot.dtmvtolt                      -- dtmvtolt
                                ,rw_craplot.cdagenci                      -- cdagenci
                                ,rw_craplot.cdbccxlt                      -- cdbccxlt
                                ,rw_craplot.nrdolote                      -- nrdolote
                                ,rw_craplot.tplotmov                      -- tplotmov
                                ,vr_nrdconta                              -- nrdconta
                                ,vr_nrdctabb                              -- nrdctabb
                                ,vr_dsdctitg                              -- nrdctitg
                                ,rpad(vr_dshistor,15,' ') || vr_dsageori  -- dshistor
                                ,vr_cdpesqbb                              -- cdpesqbb
                                ,vr_nrseqint                              -- nrseqdig
                                ,CASE vr_cdcritic
                                  WHEN 762 THEN vr_nrseqint
                                  WHEN 608 THEN vr_nrseqint
                                  ELSE vr_nrdocmto END                    -- nrdocmto
                                ,vr_vllanmto                              -- vllanmto
                                ,vr_indebcre                              -- indebcre
                                ,vr_dtrefere                              -- dtrefere
                                ,vr_cdcritic                              -- cdcritic
                                ,nvl(vr_dtrefere,rw_crapdat.dtmvtolt)     -- dtdaviso
                                ,1                      );                -- tpintegr
          EXCEPTION 
            WHEN OTHERS THEN 
              vr_dscritic := ' ao inserir registro de Rejeição --> ' ||sqlerrm;
              RAISE vr_exc_saida;
          END;
          -- Tratar criticas ignoráveis
          IF vr_cdcritic IN(96,137,172,257,287,439,608) THEN 
            -- Para critica 96 - Cheque com Contra Ordem 
            IF vr_cdcritic = 96 AND vr_tab_conta3.exists(vr_nrdctabb) THEN
              -- Critica pode ser limpa e não haverá entrada 
              vr_cdcritic := 0;
              vr_flgentra := FALSE;
            ELSE
              -- Limpar a critica e haverá entrada 
              vr_cdcritic := 0;
              vr_flgentra := TRUE;
            END IF;
          ELSE 
            -- Todas as outras podem ser limpas e não haverá entrada 
            vr_cdcritic := 0;
            vr_flgentra := FALSE;
          END IF;
        END IF;
          
        -- Verifica se há negativação no cheque 
        IF vr_flgchequ THEN 
          OPEN cr_crapneg(vr_nrdconta
                         ,vr_nrdocmto);
          FETCH cr_crapneg 
           INTO vr_flgexis;
          -- Se encontrar 
          IF cr_crapneg%FOUND THEN 
            IF rw_crapfdc.tpcheque = 1 THEN 
              vr_indevchq := 1;
            ELSE 
              vr_indevchq := 3;
            END IF;
            vr_cdalinea := 49;
            vr_flgentra := TRUE;
          END IF;
          -- Fechar cursor
          CLOSE cr_crapneg;
        END IF;
        -- Para entrada de cheques
        IF vr_flgentra AND vr_flgchequ THEN 
          -- Atualizar LOTE 
          rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
          rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
          rw_craplot.vlinfodb := rw_craplot.vlinfodb + nvl(vr_vllanmto,0);
          rw_craplot.vlcompdb := rw_craplot.vlcompdb + nvl(vr_vllanmto,0);
          rw_craplot.nrseqdig := vr_nrseqint;
          -- Criar lançamento na CC do Cooperado 
          BEGIN
            -- Tratando histórico 
            IF vr_tab_conta3.exists(vr_nrdctabb) THEN 
              vr_cdhistor := 56;
            ELSIF vr_tab_conta2.exists(vr_nrdctabb) THEN 
              vr_cdhistor := 59;
            ELSE   
              vr_cdhistor := 50;
            END IF;
            -- Criando lançamento 
            INSERT INTO craplcm (dtmvtolt
                                ,dtrefere
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,nrdconta
                                ,nrdctabb
                                ,nrdctitg
                                ,nrdocmto
                                ,cdcooper 
                                ,cdhistor
                                ,vllanmto
                                ,nrseqdig
                                ,cdpesqbb
                                ,cdbanchq
                                ,cdagechq
                                ,nrctachq)
                         VALUES(rw_craplot.dtmvtolt
                               ,vr_dtleiarq
                               ,rw_craplot.cdagenci
                               ,rw_craplot.cdbccxlt
                               ,rw_craplot.nrdolote
                               ,vr_nrdconta
                               ,vr_nrdctabb
                               ,vr_dsdctitg
                               ,vr_nrdocmto
                               ,pr_cdcooper
                               ,vr_cdhistor
                               ,vr_vllanmto
                               ,vr_nrseqint
                               ,vr_cdpesqbb
                               ,rw_crapfdc.cdbanchq
                               ,rw_crapfdc.cdagechq
                               ,rw_crapfdc.nrctachq);
          EXCEPTION 
            WHEN OTHERS THEN 
              vr_dscritic := ' na inserção do lançamento em CC --> '||sqlerrm;
              RAISE vr_exc_saida;
          END;
          -- Atualizar folha de cheque 
          BEGIN 
            UPDATE crapfdc 
               SET incheque = rw_crapfdc.incheque + 5
                  ,vlcheque = vr_vllanmto
                  ,dtliqchq = rw_crapdat.dtmvtolt 
                  ,cdagedep = substr(vr_dsageori,1,4)
             WHERE rowid = rw_crapfdc.rowid;
          EXCEPTION 
            WHEN OTHERS THEN 
              vr_dscritic := ' ao atualizar Folha de Cheque --> '||sqlerrm;
              RAISE vr_exc_saida; 
          END;
          -- Se for devolucao de cheque verifica o indicador de
          -- historico da contra-ordem. Se for 2, alimenta aux_cdalinea
          -- com 28 para nao gerar taxa de devolucao
          IF (vr_indevchq = 1 OR vr_indevchq = 3) AND vr_cdalinea = 0 THEN
            -- Buscar contra-ordem no cheque 
            OPEN cr_crapcor(rw_crapcop.cdageitg
                           ,vr_nrdctabb
                           ,vr_nrdocmto);
            -- Se não encontrar contra ordem
            IF cr_crapcor%NOTFOUND THEN                     
              -- Fechar o cursor e gerar critica 179 retornando 
              CLOSE cr_crapcor;
              vr_cdcritic := 179;
              vr_dscritic := gene0001.fn_busca_critica(179) || ' ' || gene0002.fn_mask_conta(vr_nrdconta)
                          || ' Docmto = '|| gene0002.fn_mask(vr_nrdocmto,'zzz.zzz.9')
                          || ' Cta Base = ' || gene0002.fn_mask_conta(vr_nrdctabb);
              RAISE vr_exc_saida;                
            ELSE 
              -- Fechar o cursor e continuar
              CLOSE cr_crapcor;
              -- Contra Ordem Provisoria
              IF rw_crapcor.dtvalcor >= rw_crapdat.dtmvtolt THEN
                vr_cdalinea := 70;
              ELSIF rw_crapcor.cdhistor = 835 THEN
                vr_cdalinea := 28;
              ELSIF rw_crapcor.cdhistor = 815 THEN
                vr_cdalinea := 21;
              ELSIF rw_crapcor.cdhistor = 818 THEN
                vr_cdalinea := 20;
              ELSE
                vr_cdalinea := 21;
              END IF;
            END IF;  
          END IF;
          -- Se há devolução
          IF vr_indevchq > 0 THEN 
            -- Gerar devolução 
            cheq0001.pc_gera_devolucao_cheque(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdbccxlt => 1 -- Fixo BB
                                             ,pr_cdbcoctl => 1 -- Fixo BB
                                             ,pr_inchqdev => vr_indevchq
                                             ,pr_nrdconta => vr_nrdconta 
                                             ,pr_nrdocmto => vr_nrdocmto 
                                             ,pr_nrdctitg => vr_dsdctitg 
                                             ,pr_vllanmto => vr_vllanmto 
                                             ,pr_cdalinea => vr_cdalinea 
                                             ,pr_cdhistor => (CASE vr_indevchq
                                                               WHEN 1 THEN 191
                                                               ELSE 78
                                                              END)
                                             ,pr_cdoperad => '1'
                                             ,pr_cdagechq => rw_crapcop.cdagebcb
                                             ,pr_nrctachq => vr_nrdctabb
                                             ,pr_cdprogra => vr_cdprogra
                                             ,pr_nrdrecid => 0
                                             ,pr_vlchqvlb => vr_vlchqvlb
                                             ,pr_cdcritic => vr_cdcritic 
                                             ,pr_des_erro => vr_dscritic);
            -- Testar erro na chamada
            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN 
              -- Concatenar detalhes e sair 
              IF vr_dscritic IS NULL THEN 
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              END IF;
              vr_dscritic := vr_dscritic || ' ' || gene0002.fn_mask_conta(vr_nrdconta)
                          || ' Docmto = '|| gene0002.fn_mask(vr_nrdocmto,'zzz.zzz.9')
                          || ' Cta Base = ' || gene0002.fn_mask_conta(vr_nrdctabb);
              RAISE vr_exc_saida;
            ELSE
              vr_cdcritic := 0;
            END IF;              
          END IF;
          -- Buscar indicador de D/C do Histórico gravado
          OPEN cr_craphis(pr_cdcooper,vr_cdhistor);
          FETCH cr_craphis 
           INTO vr_indebcre;
          -- Se não encontrar
          IF cr_craphis%NOTFOUND THEN 
            CLOSE cr_craphis;
            -- Gerar critica 80 e retornar 
            vr_cdcritic := 80;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            vr_dscritic := vr_dscritic || ' HST = ' || vr_cdhistor;
            RAISE vr_exc_saida;
          ELSE
            CLOSE cr_craphis;
          END IF;            
            
          -- Se foi lançamento de Debito
          IF vr_indebcre = 'D' THEN               
            -- Acumular totalizadores da COMPBB
            IF NOT vr_tab_totais.EXISTS(vr_nrdctabb) THEN 
              vr_tab_totais(vr_nrdctabb).qtcompdb := 0;
              vr_tab_totais(vr_nrdctabb).vlcompdb := 0;
              vr_tab_totais(vr_nrdctabb).qtcompcr := 0;
              vr_tab_totais(vr_nrdctabb).vlcompcr := 0;
            END IF;               
            vr_tab_totais(vr_nrdctabb).vlcompdb := vr_tab_totais(vr_nrdctabb).vlcompdb + vr_vllanmto; 
            vr_tab_totais(vr_nrdctabb).qtcompdb := vr_tab_totais(vr_nrdctabb).qtcompdb + 1;
          END IF;
        -- Entrada de Depósitos  
        ELSIF vr_flgentra AND vr_flgdepos THEN          
          -- Buscar indicador de D/C do Histórico gravado
          OPEN cr_craphis(pr_cdcooper,vr_cdhistor);
          FETCH cr_craphis 
           INTO vr_indebcre;
          -- Se não encontrar
          IF cr_craphis%NOTFOUND THEN 
            CLOSE cr_craphis;
            -- Gerar critica 80 e retornar 
            vr_cdcritic := 80;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            vr_dscritic := vr_dscritic || ' HST = ' || vr_cdhistor;
            RAISE vr_exc_saida;
          ELSE
            CLOSE cr_craphis;
          END IF;             
          -- Para histórico 170
          -- DEPOS.BB BLOQ
          IF vr_cdhistor = 170 THEN
            -- Criar registros na tabela de Depositos Bloqueados
            BEGIN 
              INSERT INTO crapdpb (cdcooper 
                                  ,dtmvtolt
                                  ,cdagenci
                                  ,cdbccxlt
                                  ,nrdolote
                                  ,nrdconta
                                  ,dtliblan
                                  ,cdhistor
                                  ,nrdocmto
                                  ,vllanmto
                                  ,inlibera)
                            VALUES(pr_cdcooper            -- cdcooper 
                                  ,rw_craplot.dtmvtolt    -- dtmvtolt
                                  ,rw_craplot.cdagenci    -- cdagenci
                                  ,rw_craplot.cdbccxlt    -- cdbccxlt
                                  ,rw_craplot.nrdolote    -- nrdolote
                                  ,vr_nrdconta            -- nrdconta
                                  ,vr_dtliblan            -- dtliblan
                                  ,vr_cdhistor            -- cdhistor
                                  ,vr_nrseqint            -- nrdocmto
                                  ,vr_vllanmto            -- vllanmto
                                  ,1                  );  -- inlibera
            EXCEPTION
              WHEN OTHERS THEN 
                vr_dscritic := ' ao criar registro de Depósito Bloqueado --> '||sqlerrm;
                RAISE vr_exc_saida;
            END;
          END IF;
          -- Atualizar LOTE 
          rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
          rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
          rw_craplot.vlinfocr := rw_craplot.vlinfocr + nvl(vr_vllanmto,0);
          rw_craplot.vlcompcr := rw_craplot.vlcompcr + nvl(vr_vllanmto,0);
          rw_craplot.nrseqdig := vr_nrseqint;
          -- Criar lançamento na CC do Cooperado 
          BEGIN
            INSERT INTO craplcm (dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,nrdconta
                                ,nrdctabb
                                ,nrdctitg
                                ,nrdocmto
                                ,cdcooper 
                                ,cdhistor
                                ,vllanmto
                                ,nrseqdig
                                ,cdpesqbb)
                         VALUES(rw_craplot.dtmvtolt
                               ,rw_craplot.cdagenci
                               ,rw_craplot.cdbccxlt
                               ,rw_craplot.nrdolote
                               ,vr_nrdconta
                               ,vr_nrdctabb
                               ,vr_dsdctitg
                               ,vr_nrseqint
                               ,pr_cdcooper
                               ,vr_cdhistor
                               ,vr_vllanmto
                               ,vr_nrseqint
                               ,vr_cdpesqbb);
          EXCEPTION 
            WHEN OTHERS THEN 
              vr_dscritic := ' na inserção do lançamento em CC --> '||sqlerrm;
              RAISE vr_exc_saida;
          END;
          -- Se foi lançamento de Credito
          IF vr_indebcre = 'C' THEN        
            -- Acumular totalizadores da COMPBB
            IF NOT vr_tab_totais.EXISTS(vr_nrdctabb) THEN 
              vr_tab_totais(vr_nrdctabb).qtcompdb := 0;
              vr_tab_totais(vr_nrdctabb).vlcompdb := 0;
              vr_tab_totais(vr_nrdctabb).qtcompcr := 0;
              vr_tab_totais(vr_nrdctabb).vlcompcr := 0;
            END IF;               
            vr_tab_totais(vr_nrdctabb).vlcompcr := vr_tab_totais(vr_nrdctabb).vlcompcr + vr_vllanmto; 
            vr_tab_totais(vr_nrdctabb).qtcompcr := vr_tab_totais(vr_nrdctabb).qtcompcr + 1;
          END IF;
        ELSE 
          -- Outras casos
          -- Acumular totalizadores da COMPBB
          IF NOT vr_tab_totais.EXISTS(99999999) THEN 
            vr_tab_totais(99999999).qtcompdb := 0;
            vr_tab_totais(99999999).vlcompdb := 0;
            vr_tab_totais(99999999).qtcompcr := 0;
            vr_tab_totais(99999999).vlcompcr := 0;
          END IF; 
          -- Alimentar totalizadores conforme tipo do lançamento (D/C)
          IF vr_indebcre = 'D' THEN 
            vr_tab_totais(99999999).vlcompdb := vr_tab_totais(99999999).vlcompdb + vr_vllanmto; 
            vr_tab_totais(99999999).qtcompdb := vr_tab_totais(99999999).qtcompdb + 1;
          ELSE 
            vr_tab_totais(99999999).vlcompcr := vr_tab_totais(99999999).vlcompcr + vr_vllanmto; 
            vr_tab_totais(99999999).qtcompcr := vr_tab_totais(99999999).qtcompcr + 1;
          END IF;
          -- Atualizar variavel de entrada
          vr_flgentra := true;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Fechar handle do arquivo pendente 
        gene0001.pc_fecha_arquivo(vr_arqhandle);
        -- Adicionar o numero da linha ao erro 
        vr_dscritic := 'Erro tratado na linha '||vr_nrdlinha||' --> '|| vr_dscritic;
        -- Direcionar para saída
        RAISE vr_exc_saida; 
      WHEN no_data_found THEN
        NULL; --> Fim da leitura 
      WHEN OTHERS THEN
        -- Fechar handle do arquivo pendente 
        gene0001.pc_fecha_arquivo(vr_arqhandle);
        -- Adicionar o numero da linha ao erro 
        vr_dscritic := 'Erro nao tratado na linha '||vr_nrdlinha||' --> '|| sqlerrm;
        -- Direcionar para saída
        RAISE vr_exc_saida; 
    END;
      
    -- Fechar handle do arquivo pendente 
    gene0001.pc_fecha_arquivo(vr_arqhandle);
      
      
    -- Atualizar a CRAPLOT após o processamento, pois os valores estão apenas em memória
    BEGIN 
      UPDATE craplot 
         SET qtinfoln = rw_craplot.qtinfoln
            ,qtcompln = rw_craplot.qtcompln
            ,vlinfodb = rw_craplot.vlinfodb
            ,vlcompdb = rw_craplot.vlcompdb
            ,vlinfocr = rw_craplot.vlinfocr
            ,vlcompcr = rw_craplot.vlcompcr
            ,nrseqdig = rw_craplot.nrseqdig
       WHERE rowid = rw_craplot.nrrowid;
    EXCEPTION
      WHEN OTHERS THEN 
        vr_dscritic := 'Erro ao atualizar o lote após processamento --> '||sqlerrm;
        RAISE vr_exc_saida;
    END;
    -- Em caso de arquivo vazio
    IF vr_flgarqvz THEN 
      -- Se houve ativação da flag de cheque BB
      IF vr_flgchqbb THEN 
        -- Enviar critica 263 ao log
        -- 263 - ARQUIVO VAZIO;
        vr_cdcritic := 263;

        --Geração de log de erro - Chamado 696499
        vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                               ' --> ' || 'ERRO: ' ||gene0001.fn_busca_critica(263) ||
                               ' Cdcooper='||vr_tab_crapcop(vr_idx).cdcooper;

        cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                               pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                               pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                               pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               pr_tpocorrencia  => 2,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                               pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                               pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                               pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                               pr_nmarqlog      => NULL, 
                               pr_idprglog      => vr_idprglog);
      END IF;
    ELSE 
      -- Arquivo não está vazio, iniciaremos a montagem do relatório 
      dbms_lob.createtemporary(vr_xmlrel, TRUE);
      dbms_lob.open(vr_xmlrel, dbms_lob.lob_readwrite);

      -- Inicializa o xml jah enviando os dados de resumo geral 
      gene0002.pc_escreve_xml(vr_xmlrel,
                              vr_txtrel,
                             '<?xml version="1.0" encoding="utf-8"?>'||
                             '<root><totais>');
        
      -- Iterar sobre os registros acumulados de totalizadores
      vr_nrdctabb := vr_tab_totais.first;
      LOOP 
        EXIT WHEN vr_nrdctabb IS NULL;
        -- Montagem do texto padrão 
        IF vr_nrdctabb != 99999999 THEN 
          vr_dsintegr := 'INTEGRADOS NA CONTA '||GENE0002.FN_MASK_CONTA(vr_nrdctabb);
        ELSE
          vr_dsintegr := 'NAO INTEGRADOS';
        END IF;
        -- Enviar os dados desta conta 
        gene0002.pc_escreve_xml(vr_xmlrel
                               ,vr_txtrel
                               ,'<total dsdsintegr="'||vr_dsintegr||'" '||
                                      ' qtintdeb="'||TO_CHAR(vr_tab_totais(vr_nrdctabb).qtcompdb,'fm999g999g999g990')||'" '||
                                      ' vlintdeb="'||TO_CHAR(vr_tab_totais(vr_nrdctabb).vlcompdb,'fm999g999g999g990d00')||'"'||
                                      ' qtintcre="'||TO_CHAR(vr_tab_totais(vr_nrdctabb).qtcompcr,'fm999g999g999g990')||'" '||
                                      ' vlintcre="'||TO_CHAR(vr_tab_totais(vr_nrdctabb).vlcompcr,'fm999g999g999g990d00')||'"/>');    
        -- Acumular os totais 
        vr_tot_qtintdeb := vr_tot_qtintdeb + vr_tab_totais(vr_nrdctabb).qtcompdb;
        vr_tot_vlintdeb := vr_tot_vlintdeb + vr_tab_totais(vr_nrdctabb).vlcompdb;
        vr_tot_qtintcre := vr_tot_qtintcre + vr_tab_totais(vr_nrdctabb).qtcompcr;
        vr_tot_vlintcre := vr_tot_vlintcre + vr_tab_totais(vr_nrdctabb).vlcompcr;
        -- Buscar a próxima conta
        vr_nrdctabb := vr_tab_totais.next(vr_nrdctabb);
      END LOOP;
      -- Enviar o total geral Integrados + Não Integrados 
      gene0002.pc_escreve_xml(vr_xmlrel
                             ,vr_txtrel
                             ,'<total dsdsintegr="TOTAL DA COMPE" '||
                                    ' qtintdeb="'||TO_CHAR(vr_tot_qtintdeb,'fm999g999g999g990')||'" '||
                                    ' vlintdeb="'||TO_CHAR(vr_tot_vlintdeb,'fm999g999g999g990d00')||'"'||
                                    ' qtintcre="'||TO_CHAR(vr_tot_qtintcre,'fm999g999g999g990')||'" '||
                                    ' vlintcre="'||TO_CHAR(vr_tot_vlintcre,'fm999g999g999g990d00')||'"/>');    
      -- Encerrar tag totais e iniciar tag saldos 
      gene0002.pc_escreve_xml(vr_xmlrel,
                              vr_txtrel,
                             '</totais><saldos>');
      -- Saldos bloqueados nas contas --
      vr_nrdctabb := vr_tab_crawdpb.first;
      LOOP 
        EXIT WHEN vr_nrdctabb IS NULL;
        -- Acumular total bloqueado 
        vr_ger_vlbloque := vr_ger_vlbloque 
                         + vr_tab_crawdpb(vr_nrdctabb).vlblq001 + vr_tab_crawdpb(vr_nrdctabb).vlblq002
                         + vr_tab_crawdpb(vr_nrdctabb).vlblq003 + vr_tab_crawdpb(vr_nrdctabb).vlblq004
                         + vr_tab_crawdpb(vr_nrdctabb).vlblq999 + vr_tab_crawdpb(vr_nrdctabb).vldispon;
        -- Enviar para o XML 
        gene0002.pc_escreve_xml(vr_xmlrel
                               ,vr_txtrel
                               ,'<saldo nrdconta="'||gene0002.fn_mask_conta(vr_nrdctabb)||'"'||
                                      ' vldispon="'||TO_CHAR(vr_tab_crawdpb(vr_nrdctabb).vldispon,'fm999g999g999g990d00')||'" '||
                                      ' vlblq001="'||TO_CHAR(vr_tab_crawdpb(vr_nrdctabb).vlblq001,'fm999g999g999g990d00')||'" '||
                                      ' vlblq002="'||TO_CHAR(vr_tab_crawdpb(vr_nrdctabb).vlblq002,'fm999g999g999g990d00')||'" '||
                                      ' vlblq003="'||TO_CHAR(vr_tab_crawdpb(vr_nrdctabb).vlblq003,'fm999g999g999g990d00')||'" '||
                                      ' vlblq004="'||TO_CHAR(vr_tab_crawdpb(vr_nrdctabb).vlblq004,'fm999g999g999g990d00')||'" '||
                                      ' vlblq999="'||TO_CHAR(vr_tab_crawdpb(vr_nrdctabb).vlblq999,'fm999g999g999g990d00')||'"/>');
        -- Buscar a próxima conta
        vr_nrdctabb := vr_tab_crawdpb.next(vr_nrdctabb);
      END LOOP;
      /* Consulta ajustada para gravar os dados com base no processo 
         que será executado. DTMVTOLT - Processo Normal
                             DTMVTAON - Processo COMPEFORA.
                     
         Obs: O processo COMPEFORA eh executado quando os arquivos deb558*
         nao chegam a tempo de ser executado no processo NOTURNO. Falar
         com o Devid G. Kistner sobre mais detalhes desse processo.
             
         Esse ajuste foi discutido com o solicitante Fernando - Controles 
         Internos junto ao analista responsavel para gravar os dados 
         totalizadores no dia anterior para que os dados sejam mantidos visiveis
         no demostrativo na intranet. Antes essa variavel era gravada no
         mesmo dia que o processo noturno seria executado, com isso o registro
         era sobrescrito e a informacao era perdida. Para a area de controle
         esse valor nao eh critico, se trata de um demonstrativo do dia que
         eh mostrado no painel gerencial da intranet. */
      BEGIN 
        -- Tentaremos atualizar 
        UPDATE gntotpl
           SET vlslddbb = vr_ger_vlbloque
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt =  vr_dtleiarq;
        -- Se não afetou nenhum registro
        IF SQL%ROWCOUNT = 0 THEN 
          INSERT INTO gntotpl(cdcooper
                             ,dtmvtolt
                             ,vlslddbb)
                       VALUES(pr_cdcooper
                             ,vr_dtleiarq
                             ,vr_ger_vlbloque);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN 
          vr_dscritic := 'Erro ao gravar totais de Saldos --> '||sqlerrm;
          RAISE vr_exc_saida;
      END;        
      -- Encerrar tag Saldos e iniciar a Rejeitados 
      gene0002.pc_escreve_xml(vr_xmlrel
                             ,vr_txtrel
                             ,'</saldos><rejeitados>');
      -- Efetuar varredura nos registros da CRAPREJ para envio ao relatório 
      vr_cdcritic := 0;
      FOR rw_craprej IN cr_craprej(pr_cdcooper,vr_nrdolote) LOOP
        -- Buscar critica se diferente da anterior
        IF vr_cdcritic <> rw_craprej.cdcritic THEN 
          vr_cdcritic := rw_craprej.cdcritic;
          vr_dscritic := substr(gene0001.fn_busca_critica(rw_craprej.cdcritic),7,50);
          -- Adicionar asterisco em criticas específicas
          IF vr_cdcritic IN(96,137,172,257,287,439,508,608) THEN 
            vr_dscritic := '* '||vr_dscritic;
          END IF;
        END IF;
        -- Enviar o registro para o XML 
        gene0002.pc_escreve_xml(vr_xmlrel
                               ,vr_txtrel
                               ,'<rejeito nrseqdig="'||rw_craprej.nrseqdig||'"'||
                                        ' dshistor="'||substr(rw_craprej.dshistor,1,15)||'" '||
                                        ' nrdctabb="'||gene0002.fn_mask_conta(rw_craprej.nrdctabb)||'" '||
                                        ' dtrefere="'||rw_craprej.dtrefere||'" '||
                                        ' nrdocmto="'||gene0002.fn_mask_conta(rw_craprej.nrdocmto)||'" '||
                                        ' cdpesqbb="'||substr(rw_craprej.cdpesqbb,1,13)||'" '||
                                        ' vllanmto="'||TO_CHAR(rw_craprej.vllanmto,'fm999g999g999g990d00')||'" '||
                                        ' indebcre="'||rw_craprej.indebcre||'" '||
                                        ' nrdconta="'||gene0002.fn_mask_conta(rw_craprej.nrdconta)||'" '||
                                        ' dscritic="'||substr(vr_dscritic,1,29)||'" ');
        -- Para as criticas abaixo, incrementar quantidade de erros
        IF rw_craprej.cdcritic IN(96,137,172,257,287,439,508,608,762) THEN 
          gene0002.pc_escreve_xml(vr_xmlrel
                                 ,vr_txtrel
                                 ,' qtderros="1"/>');
        ELSE 
          gene0002.pc_escreve_xml(vr_xmlrel
                                 ,vr_txtrel
                                 ,' qtderros="0"/>');
        END IF;
      END LOOP;
      -- Encerrar a tag Rejeitados e iniciar a integrados 
      gene0002.pc_escreve_xml(vr_xmlrel
                             ,vr_txtrel
                             ,'</rejeitados>');
      -- Iniciar a tag Integrados 
      gene0002.pc_escreve_xml(vr_xmlrel,
                              vr_txtrel,
                             '<integrados '||
                                  ' vlmaichq="'||TO_CHAR(vr_vlmaichq,'fm999g999g999g990')||'" '||
                                  ' dtmvtolt="'||TO_CHAR(rw_craplot.dtmvtolt,'dd/mm/rrrr')||'"'||
                                  ' cdagenci="'||rw_craplot.cdagenci||'" '||
                                  ' cdbccxlt="'||rw_craplot.cdbccxlt||'" '||
                                  ' nrdolote="'||TO_CHAR(rw_craplot.nrdolote,'fm999g990')||'" '||
                                  ' qtcompln="'||TO_CHAR(rw_craplot.qtcompln,'fm999g999g999g990')||'" '||
                                  ' vlcompdb="'||TO_CHAR(rw_craplot.vlcompdb,'fm999g999g999g990d00')||'">');
        
      -- Leitura dos lancamentos integrados  --  Maiores cheques
      FOR rw_lcm IN cr_craplcm_integra(vr_nrdolote) LOOP
        -- Envia registro 
        gene0002.pc_escreve_xml(vr_xmlrel
                               ,vr_txtrel
                               ,'<integrado nrdctabb="'||gene0002.fn_mask_conta(rw_lcm.nrdctabb)||'"'||
                                          ' nrdocmto="'||trim(gene0002.fn_mask(rw_lcm.nrdocmto,'zzzz.zzz.zzz.9'))||'" '||
                                          ' nrdconta="'||gene0002.fn_mask_conta(rw_lcm.nrdconta)||'" '||
                                          ' cdhistor="'||TO_CHAR(rw_lcm.cdhistor,'fm9990')||'" '||
                                          ' vllanmto="'||TO_CHAR(rw_lcm.vllanmto,'fm999g999g999g990')||'" '||
                                          ' cdpesqbb="'||substr(rw_lcm.cdpesqbb,1,15)||'" '||
                                          ' nrseqdig="'||TO_CHAR(rw_lcm.nrseqdig,'fm999g990')||'" />');
      END LOOP;        
                               
      -- Solicitaremos o fechamento da tag integrados e root e do XML
      gene0002.pc_escreve_xml(vr_xmlrel
                             ,vr_txtrel
                             ,'</integrados></root>'
                             ,true);
                               
        -- Por fim, iremos solicitar a emissão do relatório 
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,         --> Data do movimento atual
                                  pr_dsxml     => vr_xmlrel,          --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/root',    --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl291.jasper',    --> Arquivo de layout do iReport
                                  pr_dsparams  => NULL,                --> nao enviar parametros
                                  pr_dsarqsaid =>  vr_nmdircop||'/rl/'||vr_tab_crapcop(vr_idx).nmarqimp, --> Arquivo final
                                  pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                  pr_qtcoluna  => 132,                  --> Quantidade de colunas
                                  pr_sqcabrel  => 1,                   --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                                  pr_nmformul  => '132dm',             --> Nome do formulário para impressão
                                  pr_nrcopias  => 1,                   --> Número de cópias para impressão
                                  pr_dspathcop => NULL,                --> Diretorio para copia dos arquivos
                                  pr_des_erro  => vr_dscritic);        --> Saida com erro

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memoria alocada para os CLOBs
      dbms_lob.close(vr_xmlrel);
      dbms_lob.freetemporary(vr_xmlrel);
        
    END IF;
      
    --Geração de log de erro - Chamado 696499
    --Inclusão validação e log 191 para integrações com críticas
    IF vr_dscritic IS NULL THEN
      --Enviar critica 190 ao LOG
      vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                             ' --> ' || 'ALERTA: ' ||gene0001.fn_busca_critica(190) ||
                             ': '||vr_tab_crapcop(vr_idx).nmarquiv;
    ELSE
      --Enviar critica 191 ao LOG
      vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                             ' --> ' || 'ALERTA: ' ||gene0001.fn_busca_critica(191) ||
                             ': '||vr_tab_crapcop(vr_idx).nmarquiv;
    END IF;
      
    cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                           pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                           pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                           pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia  => 4,            -- tbgen_prglog_ocorrencia - 4 - Mensagem
                           pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                           pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                           pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                           pr_nmarqlog      => NULL, 
                           pr_idprglog      => vr_idprglog);
      
    -- Move arquivo integrado para o diretorio salvar
    gene0001.pc_OSCommand_Shell(pr_des_comando => 'mv ' || vr_nmdircop||'/integra/'||vr_tab_crapcop(vr_idx).nmarquiv|| ' ' || vr_nmdircop||'/salvar'
                               ,pr_typ_saida => vr_typsaida
                               ,pr_des_saida => vr_dessaida);
    -- Havendo erro, finalizar
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic := 'Erro ao mover arquivo apos processar, alteracoes desfeitas --> ' || vr_dessaida;
      RAISE vr_exc_saida;
    ELSE 
      -- Commitar pois o arquivo foi processado e movido com sucesso 
      COMMIT;
    END IF;
  END LOOP;   
  
  -- Se nao encontrou nenhum arquivo para processar deve continuar o processo apenas alertando ao pessoal
  IF NOT vr_flgarqui THEN
    -- Enviar email para sistemas afim de avisar que o processo rodou sem COMPBB
    vr_conteudo := 'ATENCAO!!<br><br> Voce esta recebendo este e-mail pois o programa ' 
                || vr_cdprogra || ' acusou critica ' || vr_dscritic 
                || '<br><br>COOPERATIVA: ' || pr_cdcooper || ' - ' 
                || rw_crapcop.nmrescop || '.<br>Data: ' || to_char(rw_crapdat.dtmvtolt,'dd/mm/rrrr') 
                || '<br>Hora: ' || to_char(sysdate,'HH:MI:SS');
    -- Solicitar envio do email 
    gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                              ,pr_cdprogra        => 'PC_'||vr_cdprogra
                              ,pr_des_destino     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRPS346_EMAIL_COMPBB')
                              ,pr_des_assunto     => 'Processo da Cooperativa ' ||pr_cdcooper || ' sem COMPE BB'
                              ,pr_des_corpo       => vr_conteudo
                              ,pr_des_anexo       => null
                              ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                              ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                              ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                              ,pr_des_erro        => vr_dscritic);
    -- Encerrar o CRPS e continuar o processo 
    vr_cdcritic := 258;
    raise vr_exc_fimprg;     
  END IF; 
  
  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  COMMIT;
  
EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      --Geração de log de erro - Chamado 696499
      --Enviar critica 258 ao LOG
      vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                             ' --> ' || 'ERRO: ' ||vr_dscritic;

      cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                             pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                             pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                             pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             pr_tpocorrencia  => 2,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                             pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                             pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                             pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                             pr_nmarqlog      => NULL, 
                             pr_idprglog      => vr_idprglog);
    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;

    --Geração de log de erro - Chamado 696499
    vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                           ' --> ' || 'ERRO: ' ||vr_dscritic;

    cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                           pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                           pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                           pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia  => 2,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                           pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                           pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                           pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                           pr_nmarqlog      => NULL, 
                           pr_idprglog      => vr_idprglog);
 
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;

    --Geração de log de erro - Chamado 696499
    vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                           ' --> ' || 'ERRO: ' ||pr_dscritic;

    --Geração de log de erro - Chamado 696499
    cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                           pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                           pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                           pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia  => 2,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                           pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                           pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                           pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                           pr_nmarqlog      => NULL, 
                           pr_idprglog      => vr_idprglog);

    --Inclusão na tabela de erros Oracle - Chamado 696499
    CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                 ,pr_compleme => pr_dscritic );

    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS346;
/
