declare

pr_stprogra BINARY_INTEGER;
pr_infimsol BINARY_INTEGER;
pr_cdcritic NUMBER(10);
pr_dscritic VARCHAR2(2000);


PROCEDURE pc_crps388_RRC(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                             ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
/* 
  Programa: PC_CRPS388                          Antigo: Fontes/crps388.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autora  : Mirtes
  Data    : Abril/2004                          Ultima atualizacao: 20/09/2019

  Dados referentes ao programa:

  Frequencia: Diario (Batch).
  Objetivo  : Atender a solicitacao 092
              Gerar arquivo de arrecadacao de faturas(Debito Automatico)
              Emite relatorio 350.

  Alteracoes: 29/06/2004 - Tratamento de erros nos relatorios (Ze Eduardo).
  
              30/06/2004 - Nomear arquivo de dados dentro do FOR EACH crapndb
                           caso este ainda nao tenha sido nomeado (Julio).
  
              06/10/2004 - Sequenciar pelo numero do convenio(Mirtes). 

              03/11/2004 - Inclusao dos convenios 5 e 15 (Julio) 

              26/11/2004 - Inclusao do convenio 16 (Julio) 

              30/11/2004 - Cooperativa 1, nunca vai com "9001" na frente do
                           numero da conta (Julio)

              07/01/2005 - Referencia de cliente  VIVO deve ter 11 digitos
                           (Julio)

              28/01/2005 - Tratamento SAMAE GASPAR (CECRED) -> Hist. 635
                           convenio 19 
                           SAMAE TIMBO -> Hist. 628 convenio 16 (Julio)
                           
              02/02/2005 - Tratamento SAMAE BLUMENAU CECRED -> 643 (Julio)
                
              25/04/2005 - Tratamento para UNIMED -> 509 (Julio)  

              31/05/2005 - Tratamento para AGUAS ITAPEMA -> 24 Hist. 455
                           (Julio)

              12/07/2005 - Alteracoes no tratamento de SAMAE GASPAR -> 19
                           (Julio)

              23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                           crabcop.cdcooper = glb_cdcooper (Diego).

              03/10/2005 - Quando for UNIMED (22), sempre colocar o codigo da
                           cooperativa no numero da conta, mesmo quendo for
                           VIACREDI. (Julio)

              12/01/2006 - Tratamento para email's em branco (Julio)

              16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
              
              13/10/2006 - Tratamento para CELESC Distribuicao (Julio)

              27/11/2006 - Acerto no envio de email pela BO b1wgen0011 (David).
              
              29/11/2006 - Inclusao do convenio 28 - Unimed (Elton).
              
              02/02/2007 - Tratamento para DAE Navegantes -> 31 (Elton).
              
              29/05/2007 - Inclusao de registros "J" no caso do convenio
                           solicitar arquivos de confirmacao (Elton).
                           
              30/05/2007 - Inclusao do convenio 32 - Uniodonto (Elton).
              
              01/06/2007 - Incluido possibilidade de envio de arquivo para
                           Accestage (Elton).
              
              27/07/2007 - Acertado total de registros no trailer "Z" quando
                           houver registros do tipo "J" (Elton).
                           
              19/11/2007 - Tratamento para Aguas de Joinville -> 33 (Elton).
              
              28/11/2007 - Tratamento para SEMASA Itajai -> 34 (Elton).

              04/06/2008 - Campo dsorigem nas leituras da craplau (David)
              
              15/08/2008 - Tratamento para o convenio SAMAE Jaragua -> 9
                           (Diego).
                           
              04/11/2008 - Retirado constante da UF "SC" e colocado campo de
                           arquivo (Martin).
                           
              14/07/2009 - incluido no for each a condição - 
                           craplau.dsorigem <> "PG555" - Precise - Paulo
                           
              16/10/2009 - Tratamento para convenio 38 -> Unimed Planalto Norte
                           e convenio 43 -> Servmed (Elton). 
                           
              15/04/2010 - Tratamento para convenio 46 -> Uniodonto Federacao
                           (Elton).
                           
              18/05/2010 - Tratamento para convenio 48 -> TIM Celular, conforme
                           convenio 3 (Elton).
              
              09/06/2010 - Tratamento para convenio 47 -> Unimed Credcrea 
                           (Elton).
              
              01/10/2010 - Tratamento para convenio 49 -> Samae Rio Negrinho e
                           convenio 50 -> HDI (Elton). 
                           
              08/11/2010 - Acerto no retorno de lancamentos nao debitados para
                           VIVO (Elton).             
                           
              11/05/2011 - Tratamento para convenio 53 -> Foz do Brasil e 
                           convenio 54 -> Aguas de Massaranduba (Elton).
                           
              27/05/2011 - Tratamento para convenio 55 -> Liberty
                           Tratamento para convenio 57 -> Jornal de SC (Elton).
              
              02/06/2011 - Incluido no for each a condição -
                           craplau.dsorigem <> "TAA" (Evandro).
                           
              03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                           craplau. (Fabricio)
                           
              03/11/2011 - Tratamento para convenio 58 -> Porto Seguro (Elton).

              23/01/2012 - Tratamento para unificacao arqs. Convenios
                           (Guilherme/Supero)
                           
              22/06/2012 - Substituido gncoper por crabcop (Tiago).       
              
              03/07/2012 - Alterado nomeclatura do relatório gerado incluindo 
                           código do convênio (Guilherme Maba).                
                           
              29/11/2102 - Tratamento migracao Alto Vale (Elton).
              
              03/06/2013 - Incluindo no FIND FIRST craplau a condicao -
                           craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)
                           
              04/07/2013 - Tratamento para Azul Seguros (Elton).
              
              08/08/2013 - Nao cria registro de controle na gncontr se for 
                           Cecred e o convenio for unificado (Elton).
                           
              20/09/2013 - Retirada condicao para atribuicao da variavel 
                           aux_nragenci;
                         - Retirado tratamento para GLOBAL TELECOM;
                         - Agrupados convenios: SAMAE Jaragua, SAMAE Gaspar,
                           SAMAE Blumenau Viacredi, SAMAE Blumenau Creditextil,
                           SAMAE Blumenau CECRED, SAMAE Timbo CECRED,
                           SAMAE Rio Negrinho em uma mesma condicao para a 
                           atribuicao da variavel aux_dslinreg;
                         - Adicionada condicao para os convenios: 1,25,26,33,
                           39,41,43,62;
                         - Adionado ultimo else no for each do craplcm. 
                           (Reinert)
              
              07/11/2013 - Tratamento migracao Acredi (Elton).
              
              22/11/2013 - Ajustes de format na exportacao convenios (Lucas R)
              
              22/01/2014 - Incluir VALIDATE gncontr, gncvuni (Lucas R.)
              
              01/04/2014 - incluido nas consultas da craplau
                           craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
                           
              26/05/2014 - Retirado mensagens do log: "Sem movtos Convenio"; 
                           "Executando Convenio"; conforme chamado: 146206
                           data: 07/04/2014 - chamado:146223 data: 07/04/2014
                           chamado: 146226 data: 07/04/2014. Jéssica (DB1)
                           
              29/05/2014 - Retirado Criticas: 657; 748; 696 e 905 conforme 
                           chamado: 146231 data: 07/04/2014 - chamado:146236 
                           data: 07/04/2014. Jéssica (DB1)
                           
              25/09/2014 - Inclusao do convenio PREVISUL (cdconven = 66)
                           para montagem do arquivo de retorno com campo
                           de identificacao do cliente com 20 posicoes.
                           Removido das verificacoes alguns convenios 
                           que estao inativos. (Chamado 101648) - (Fabricio)
                           
              23/10/2014 - Tratamento para o campo Usa Agencia 
                           (gnconve.flgagenc); convenios a partir de 2014.
                           (Fabricio)
                           
              14/11/2014 - Ajuste para montar os registros da crapndb no
                           arquivo da mesma forma que quando montado atraves
                           da leitura da craplcm. (Chamado 173646) - (Fabricio)
                           
              28/11/2014 - Implementacao Van E-Sales (utilizacao inicial pela
                           Oi). (Chamado 192004) - (Fabricio)
                           
              07/04/2015 - Logs migrados para proc_message.log que nao eram
                           referentes ao processo (SD273550 - Tiago).
                           
              03/06/2015 - Retirado validacoes para o convenio 53 Foz do brasil
                           (Lucas Ranghetti #292200)
                           
              19/06/2015 - Alterado ordem do calculo da data aux_dtmvtopr
                           (Lucas Ranghetti #296615)
                           
              13/08/2015 - Adicioanar tratamento para o convenio MAPFRE VERA CRUZ SEG, 
                           referencia e conta (Lucas Ranghetti #292988 )
              
              28/09/2015 - incluido nas consultas da craplau
                           craplau.dsorigem <> "CAIXA" (Lombardi).
                           
              27/11/2015 - Alterar proc_batch pelo proc_message e tambem
                           retirado os logs do proc_message que eram gerados
                           com linhas em branco (Lucas Ranghetti #366033)

              04/04/2016 - Incluido a regra Caso a data de inicio da
                           autorização seja maior que 01/09/2013 ira gravar a 
                           agencia com formato novo. 

              15/06/2016 - Adicioar ux2dos para a Van E-sales (Lucas Ranghetti #469980)

              23/06/2016 - P333.1 - Devolução de arquivos com tipo de envio 
                           6 - WebService (Marcos)
              
              15/08/2016 - Alterado ordem da leitura da crapatr (Lucas Ranghetti #499449)

              05/10/2016 - Incluir tratamento para a CASAN enviar a angecia 1294 para autorizacoes
                           mais antigas (Lucas Ranghetti ##534110)
             
              28/12/2016 - Ajustes para incorporaçao da Transulcred (SD585459 Tiago/Elton) 

              17/01/2016 - Ajustes para incorporação da Transulcred (SD593672 Tiago/Elton)
              
              19/01/2017 - Validar se referencia existe atraves do campo nrcrcard da craplau com a
                           tabela crapatr (Lucas Ranghetti #533520)

              29/03/2017 - Conversão Progress para PLSQL (Jonata-MOUTs)

			        11/04/2017 - Ajuste para integracao de arquivos com layout na versao 5
				                   (Jonata - RKAM M311).

              18/05/2017 - Ajustes após validação Fabrício (Andrei-MOUTs)

              15/05/2017 - Adicionar tratamento para o convenio CERSAD 9 posicoes
                           (Lucas Ranghetti #622377)
                           
              26/05/2017 - Incluido tratamento para cdrefere da linha F para
                           AGUAS DE GUARAMIRIM (Tiago/Fabricio #640336)
              									 
              26/06/2017 - Incluido tratamento para cdrefere da linha F para
                           SANEPAR (Tiago/Fabricio #640336)                           

              04/07/2017 - Incluir nvl para a varial vr_vrlanmto pois se o valor estivesse
                           vazio ia dar pau no programa (Lucas Ranghetti #706349)
             
              16/08/2017 - Aumentar o format da referencia para 23 posições (Lucas Ranghetti #681634)
              
              28/09/2017 - Aumentar o format da referencia para 23 posições somente 
                           para a CHUBB mantendo os convenios do else com 22 (Lucas Ranghetti #766211)
                           
              04/10/2017 - Alterar o craplau.nrdocmto pelo crapatr.cdrefere na exibição da
                           referencia no arquivo para a MAPFRE pois estava calculando a 
                           quantidade a completar com espaços baseado no nrdocmto e deveria
                           se basear no cdrefere  (Lucas Ranghetti #769738)
                           
              16/10/2017 - Adicionar chamada da procedure pc_retorna_referencia_conv para formatar 
                           a referencia do convenio de acordo com o cadastrado na tabela crapprm 
                           (Lucas Ranghetti #712492)
                           
              07/11/2017 - Alterar para gravar a versao do layout dinamicamente no header do arquivo 
                           (Lucas Ranghetti #789879)
                           
              03/01/2019 - Ajuste para que nos arquivos de retorno dos convênios 127,128 seja
                           enviada a data de pagamento do agendamento (craplau.dtmvtopg) 
                           conforme já é enviado para o convênio 085
                           (Adriano - INC0027597).

              25/01/2019 - Projeto de homologacao de convenios (sustentacao). Nao causara 
                           impacto em prod, usado somente em dev. Gabriel Marcos (Mouts).

              08/02/2019 - Ajuste na declaracao da variavel vr_cdconven - Gabriel Marcos (Mouts).

              10/03/2019 - Inclusão do indicador de validação do CPF/CNPJ Layout 5.
                           Gabriel Marcos (Mouts) - SCTASK0038352.
						   
              23/05/2019 - Implementado para antes de processar este processo, cancelar os 
                           agendamento pendentes DEBNET.
                           (PRB0041528 - Andre B - MoutS)			  

              12/06/2019 - Ajuste realizado para corrigir problema de merge da liberação anterior. (Kelvin)

			        20/09/2019 - Tratamento de campo tamanho de optante e flgenv_dt_repasse tela CONVeN 
                          (Luis Amcom pj565.2)

			        06/11/2019 - Considerar dias de repasse da tela CONVEN (campo tprepass arqamazena qtd.dias)
                          (Renato Cordeiro pj565.2)
  ..............................................................................*/

  ----------------------------- ESTRUTURAS de MEMORIA -----------------------------
  TYPE typ_reg_craptco IS RECORD(cdcopant craptco.cdcopant%type 
                                ,nrctaant craptco.nrctaant%type
                                ,cdagectl crapcop.cdagectl%type);
  TYPE typ_tab_craptco IS TABLE OF typ_reg_craptco
                          INDEX BY PLS_INTEGER;
  
  ------------------------------- VARIAVEIS GLOBAIS -------------------------------

  -- Tratamento de erros
  vr_excsaida  EXCEPTION;
  vr_excfimpr EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS388';
  -- Calendário
  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT dat.dtmvtolt-1 dtmvtolt
          ,dat.dtmvtopr-1 dtmvtopr
          ,dat.dtmvtoan-1 dtmvtoan
          ,dat.inproces
          ,dat.qtdiaute
          ,dat.cdprgant
          ,dat.dtmvtocd-1 dtmvtocd
          ,trunc(dat.dtmvtolt,'mm')               dtinimes -- Pri. Dia Mes Corr.
          ,trunc(Add_Months(dat.dtmvtolt,1),'mm') dtpridms -- Pri. Dia mes Seguinte
          ,last_day(add_months(dat.dtmvtolt,-1))  dtultdma -- Ult. Dia Mes Ant.
          ,last_day(dat.dtmvtolt)                 dtultdia -- Utl. Dia Mes Corr.
          ,rowid
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;
  
  -- Cursor COP
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmcidade
          ,cop.cdufdcop
          ,cop.nmrescop
          ,cop.cdagectl
          ,cop.nmextcop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  ------------------------------- VARIAVEIS ESPECIFICAS -------------------------------
  
  -- Variáveis específicas para os relatórios / arquivos 
  vr_camicop      VARCHAR2(1000);
  vr_clobarqu     CLOB;
  vr_txtoarqu     varchar2(32767);
  vr_clobrela     CLOB;
  vr_txtorela     varchar2(32767);
  vr_nmarqdat     varchar2(40);
  vr_nmarqped     varchar2(40);
  vr_nmciddat     varchar2(70);
  vr_nmcidade     varchar2(70);
  vr_dtmvtolt     varchar2(8);
  vr_flgfirst     boolean;
  vr_dtmvtopr     DATE;
  vr_flgrelat     BOOLEAN;
  
  vr_qtdig        INTEGER;
  vr_cdidenti     varchar2(27);
  
  -- Informações dos lançamentos
  vr_nrseqdig     PLS_INTEGER;
  vr_tot_vlfatura NUMBER;
  vr_tot_vltarifa NUMBER;
  vr_tot_vlapagar NUMBER;
  vr_nrseqndb     PLS_INTEGER;
  vr_vlfatndb     NUMBER;
  vr_nrseqret     PLS_INTEGER;
  vr_vldocto2     NUMBER;
  vr_dsobserv     VARCHAR(15);
  vr_ctamigra     BOOLEAN;
  vr_vlapagar     NUMBER;
  vr_nrseqarq     PLS_INTEGER;
  vr_cdrefere     VARCHAR2(25);
  vr_cdcooper     VARCHAR2(4); 
  vr_nrdconta     VARCHAR2(14);
  vr_nrsequni     NUMBER;
  vr_vllanmto     NUMBER;
  vr_vlfatura     NUMBER;
  vr_vltarifa     NUMBER;
  vr_nragenci     VARCHAR2(4);
  vr_dslinreg     VARCHAR2(255);
  vr_nrseqtot     NUMBER;
  vr_vltotarq     NUMBER;
  vr_nrrefere     VARCHAR2(25);
  vr_qtdigito     INTEGER;
  vr_cdconven     gnconve.cdconven%type := 0;
  vr_cdcriticcanc PLS_INTEGER;
  vr_dscriticcanc VARCHAR2(4000);

  ---------------------------------- CURSORES  ----------------------------------
  
  -- Verificar se é conta migrada
  cursor cr_craptco IS
    select tco.nrdconta
          ,tco.cdcopant 
          ,tco.nrctaant
          ,cop.cdagectl
      from craptco tco
          ,crapcop cop
     where tco.cdcopant = cop.cdcooper
       and tco.cdcooper = pr_cdcooper          
       and tco.tpctatrf = 1                     
       and tco.flgativo = 1; 
  vr_tab_tco typ_tab_craptco;
  
  -- Busca os convênios ativos de Debito Automático da Cooperativa
  CURSOR cr_gnconve (pr_cdconven in gnconve.cdconven%type) IS   
    SELECT gnconve.cdconven
          ,gnconve.tprepass
          ,gnconve.nmempres
          ,gnconve.cdhisdeb
          ,gnconve.flgagenc
          ,gnconve.flgcvuni
          ,gnconve.flggeraj
          ,gnconve.nrseqatu
          ,gnconve.nmarqdeb
          ,gnconve.nrcnvfbr
          ,crapcop.cdcooper
          ,crapcop.nmrescop
          ,gnconve.tpdenvio
          ,gnconve.vltrfdeb
          ,gnconve.cddbanco
          ,replace(gnconve.dsenddeb,',,','') dsenddeb /*Remover aqueles sem email*/
          ,gnconve.rowid nrrowid
          ,gnconve.nrlayout
          ,gnconve.nrlayout_arrecad
          ,gnconve.qttamanho_optante
          ,gnconve.flgenv_dt_repasse
     from  gnconve,
           tbconv_liberacao tbconv,
           crapcop
     where tbconv.tparrecadacao = 3
       and tbconv.cdcooper = pr_cdcooper
       and tbconv.cdconven = decode(pr_cdconven,0,tbconv.cdconven,pr_cdconven)
       and gnconve.cdconven = tbconv.cdconven
       and crapcop.cdcooper = gnconve.cdcooper
--       and gnconve.cdconven > 50 --faba
       and gnconve.cdconven > 26 --rrc
       and tbconv.flgautdb = 1;
	  
  
  -- Busca dos lançamentos efetivados no dia
  CURSOR cr_craplcm(pr_cdhisdeb gnconve.cdhisdeb%TYPE) IS
    SELECT nrdconta
          ,cdhistor 
          ,cdpesqbb
          ,dtmvtolt
          ,nrdocmto
          ,vllanmto
      FROM craplcm 
     WHERE cdcooper = pr_cdcooper      
       AND dtmvtolt = rw_crapdat.dtmvtolt      
       AND cdhistor = pr_cdhisdeb;
  
  -- Checar se existe o lançamento automático 
  CURSOR cr_craplau(pr_cdcooper number
                   ,pr_nrdconta number 
                   ,pr_cdhistor number
                   ,pr_dtmvtolt date 
                   ,pr_cdpesqbb craplcm.cdpesqbb%type) IS
    SELECT cdcooper
          ,nrdconta
          ,cdhistor
          ,nrcrcard
          ,nrdocmto
          ,dtmvtopg
          ,cdcritic
          ,dscodbar
          ,cdseqtel
          ,tbconv.tppessoa_dest
          ,tbconv.nrcpfcgc_dest
      FROM craplau
          ,tbconv_det_agendamento tbconv
     WHERE craplau.cdcooper  = pr_cdcooper
       AND craplau.nrdconta  = pr_nrdconta 
       AND craplau.cdhistor  = pr_cdhistor  
       AND craplau.dtdebito  = pr_dtmvtolt  
       AND craplau.dsorigem NOT IN('CAIXA','INTERNET','TAA','PG555','CARTAOBB','BLOQJUD','DAUT BANCOOB')
       AND craplau.nrdocmto  = gene0002.fn_busca_entrada(6,SUBSTR(pr_cdpesqbb,6,100),'-')
       AND tbconv.idlancto = craplau.idlancto;
  rw_craplau cr_craplau%ROWTYPE;
  
  -- Verificar se existe autorização de débito especifica para CASAN
  CURSOR cr_crapatr_casan(pr_nrdconta craplcm.nrdconta%type
                         ,pr_cdhistor craplcm.cdhistor%type
                         ,pr_cdpesqbb craplcm.cdpesqbb%type) IS 
    SELECT 1
      FROM crapatr 
     WHERE cdcooper = pr_cdcooper  
       AND nrdconta = pr_nrdconta 
       AND cdhistor = pr_cdhistor 
       AND cdrefere = gene0002.fn_busca_entrada(6,SUBSTR(pr_cdpesqbb,6,100),'-')
       AND dtiniatr < to_date('05/10/2016','dd/mm/rrrr');
  vr_atrcasan NUMBER(1);
  
  -- Verificar se existe autorização de débito (antigo e novo)
  CURSOR cr_crapatr(pr_nrdconta craplcm.nrdconta%type
                   ,pr_cdhistor craplcm.cdhistor%type
                   ,pr_nrcrcard craplau.nrcrcard%type
                   ,pr_nrdocmto craplau.nrdocmto%type) IS 
    SELECT cdrefere
          ,dtiniatr
          ,cdseqtel
      FROM crapatr 
     WHERE cdcooper = pr_cdcooper  
       AND nrdconta = pr_nrdconta 
       AND cdhistor = pr_cdhistor 
       AND cdrefere in(pr_nrcrcard,pr_nrdocmto);
  rw_crapatr cr_crapatr%ROWTYPE;
  
  -- Buscar lançamentos não efetuados do convênio 
  CURSOR cr_crapndb(pr_cdhisdeb gnconve.cdhisdeb%TYPE) IS
    SELECT dstexarq,
           length(trim(substr(substr(dstexarq,1,25),2,instr(dstexarq,' ',-1)))) qtdarq
      FROM crapndb 
     WHERE cdcooper = pr_cdcooper
       AND dtmvtolt = rw_crapdat.dtmvtolt 
       AND cdhistor = pr_cdhisdeb;
        
  -- Buscar informações para geração do registro J
  CURSOR cr_gnarqrx(pr_cdconven gnconve.cdconven%TYPE) IS 
    SELECT dtgerarq
          ,dtmvtolt
          ,nrsequen
          ,qtregarq
          ,vltotarq
          ,rowid nrrowid
      FROM gnarqrx
     WHERE cdconven = pr_cdconven 
       AND flgretor = 0; --FALSE
  
  -- Utilizado apenas em homologacao de convenios
  CURSOR cr_hconven (pr_cdcooper in crapass.cdcooper%TYPE) IS
  SELECT prm.dsvlrprm
    FROM crapprm prm
   WHERE prm.cdcooper = pr_cdcooper
     AND prm.nmsistem = 'CRED'
     AND prm.cdacesso = 'PRM_HCONVE_CRPS388_IN';
  rw_hconven cr_hconven%ROWTYPE;

  ------------------------- PROCEDIMENTOS INTERNOS -----------------------------
  
  -- Procedimento para obtenção da sequencia atual dos arquivos 
  PROCEDURE pc_obtem_atualiza_sequencia(pr_rw_gnconve IN OUT cr_gnconve%ROWTYPE
                                       ,pr_nrseqarq OUT NUMBER 
                                       ,pr_cdcritic OUT NUMBER
                                       ,pr_dscritic OUT VARCHAR2) IS
    -- Buscar a sequencia atual com for-update para garantir o lock na tabela
    CURSOR cr_gnconve IS
      SELECT nrseqatu
        FROM gnconve
       WHERE rowid =  pr_rw_gnconve.nrrowid
         FOR UPDATE;   
    rw_gnconve cr_gnconve%ROWTYPE;      
  BEGIN 
    -- Buscar a sequencia atual com for-update para garantir o lock na tabela
    OPEN cr_gnconve;
    FETCH cr_gnconve
     INTO rw_gnconve; 
    -- Se não encontrou nenhuma linhas
    IF cr_gnconve%NOTFOUND THEN
        -- Geraremos critica 151 e sairemos do processo 
        pr_cdcritic := 151;
      CLOSE cr_gnconve;
        RETURN;
      END IF;
    
    -- Utilizar a sequencia atual 
    pr_nrseqarq := rw_gnconve.nrseqatu;
    
    -- Se não for convênio unificado 
--    IF pr_rw_gnconve.flgcvuni = 0 THEN 
-- RRC ATUALIZA SEQUENCIA PARA CONVENIOS UNIFICADOS E NAO UNIFICADOS
      -- Atualizar a sequencia na tabela 
      UPDATE gnconve
         SET nrseqatu = nrseqatu + 1
       WHERE CURRENT OF cr_gnconve;
       -- Atualizar no retorno
       pr_rw_gnconve.nrseqatu := rw_gnconve.nrseqatu + 1;
--    END IF;
    -- Nao cria registro de controle se convenio for unificado e a 
    -- execucao for na Cecred, pois quando roda programa que faz a 
    -- unificacao nao atualiza a sequencia do convenio 
    IF pr_cdcooper <> 3 OR pr_rw_gnconve.flgcvuni = 0 THEN
      -- Criaremos registro de controle 
      INSERT INTO gncontr (cdcooper
                          ,tpdcontr
                          ,cdconven
                          ,dtmvtolt
                          ,nrsequen)
                   VALUES (pr_cdcooper
                          ,4
                          ,pr_rw_gnconve.cdconven
                          ,rw_crapdat.dtmvtolt
                          ,pr_nrseqarq);
    END IF;
    
    -- Fechar o cusror para liberar a tabela
    CLOSE cr_gnconve;
    
  EXCEPTION 
    WHEN OTHERS THEN 
      -- Se cursor aberto, liberar a tabela
      IF cr_gnconve%ISOPEN THEN 
        CLOSE cr_gnconve;        
      END IF;
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado - Rotina pc_obtem_atualiza_sequencia - '||sqlerrm;
  
  END pc_obtem_atualiza_sequencia;
  
  -- Procedimento para nomeação dos arquivos 
  PROCEDURE pc_nomeia_arquivos(pr_rw_gnconve IN OUT cr_gnconve%ROWTYPE
                              ,pr_nrseqarq OUT NUMBER 
                              ,pr_nragenci IN OUT VARCHAR2
                              ,pr_nmarqdat OUT VARCHAR2
                              ,pr_nmarqped OUT VARCHAR2 
                              ,pr_cdcritic OUT NUMBER
                              ,pr_dscritic OUT VARCHAR2) IS
    -- Busca da sequencia atual para a COOP 
    CURSOR cr_gncontr IS  
      SELECT nrsequen
        FROM gncontr  
       WHERE cdcooper = pr_cdcooper     
         AND tpdcontr = 4 -- Debito Automatico                  
         AND cdconven = pr_rw_gnconve.cdconven     
         AND dtmvtolt = rw_crapdat.dtmvtolt;
    -- Numero sequencia
    vr_nrsequen VARCHAR2(6);    
  BEGIN 
    -- Busca da sequencia atual para a COOP 
    OPEN cr_gncontr;
    FETCH cr_gncontr
     INTO pr_nrseqarq;
    -- Se não encontrar
    IF cr_gncontr%NOTFOUND THEN 
      -- Fechar o cursor
      CLOSE cr_gncontr;
      -- Gravar a próxima sequencia 
      pc_obtem_atualiza_sequencia(pr_rw_gnconve => pr_rw_gnconve
                                 ,pr_nrseqarq => pr_nrseqarq 
                                 ,pr_cdcritic => pr_cdcritic 
                                 ,pr_dscritic => pr_dscritic);
      -- Se retornou erro 
      IF pr_cdcritic <> 0 OR pr_dscritic IS NOT NULL THEN 
        -- Retornar pois houve erro 
        RETURN;
      END IF;
    ELSE 
      -- Apenas fechar o cursor e continuar 
      CLOSE cr_gncontr;
    END IF;    
    
    -- Montagem das variaveis do arquivo / linhas 
    vr_nrsequen := to_char(pr_nrseqarq,'fm000000');
    
    -- Tratamento especifico da CASAN 
    IF pr_rw_gnconve.cdconven = 4 THEN
      pr_nragenci := '1294';
    END IF;
    
    -- Nomenclatura padrão 
    pr_nmarqdat := TRIM(SUBSTR(pr_rw_gnconve.nmarqdeb,1,4)) 
                || to_char(rw_crapdat.dtmvtolt,'mmdd') 
                || '.' || SUBSTR(vr_nrsequen,4,3);
    
    -- Alterar o nome conforme a configuração do nome do arquivo 
    IF SUBSTR(pr_rw_gnconve.nmarqdeb,5,2)  = 'MM' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,7,2)  = 'DD' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,10,3) = 'TXT' THEN 
      -- 
      pr_nmarqdat := TRIM(SUBSTR(pr_rw_gnconve.nmarqdeb,1,4)) 
                  || to_char(rw_crapdat.dtmvtolt,'mmdd') 
                  || '.txt';
                   
    ELSIF SUBSTR(pr_rw_gnconve.nmarqdeb,5,2)  = 'DD' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,7,2)  = 'MM' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,10,3) = 'RET' THEN 
      --
      pr_nmarqdat := TRIM(SUBSTR(pr_rw_gnconve.nmarqdeb,1,4)) 
                  || to_char(rw_crapdat.dtmvtolt,'ddmm') 
                  || '.ret';
    ELSIF SUBSTR(pr_rw_gnconve.nmarqdeb,5,2)  = 'CP' /* Cooperativa */
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,7,2)  = 'MM' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,9,2)  = 'DD' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,12,3) = 'SEQ' THEN 
      --
      pr_nmarqdat := TRIM(SUBSTR(pr_rw_gnconve.nmarqdeb,1,4)) 
                  || TO_CHAR(pr_rw_gnconve.cdcooper,'FM00')      
                  || to_char(rw_crapdat.dtmvtolt,'mmdd') 
                  || '.' || SUBSTR(vr_nrsequen,4,3);
    
    ELSIF SUBSTR(pr_rw_gnconve.nmarqdeb,4,1)  = 'C' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,5,4)  = 'SEQU' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,10,3) = 'RET' THEN 
      --
      pr_nmarqdat := TRIM(SUBSTR(pr_rw_gnconve.nmarqdeb,1,3)) 
                  || TO_CHAR(pr_rw_gnconve.cdcooper,'fm0')       
                  || SUBSTR(vr_nrsequen,3,4) || '.ret';
    END IF;
    
    -- Montar o nome com a pasta de gravação 
    pr_nmarqped := 'salvar/' || pr_nmarqdat;
    
  EXCEPTION 
    WHEN OTHERS THEN 
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado - Rotina pc_nomeia_arquivos - '||sqlerrm;
  
  END pc_nomeia_arquivos;
   
  -- Chamar a atualização do Controle e Devolução as Empresas 
  PROCEDURE pc_atualiza_controle(pr_rw_gnconve IN cr_gnconve%ROWTYPE
                                ,pr_nrseqarq   IN NUMBER 
                                ,pr_camicoop   IN VARCHAR2
                                ,pr_nmarqped   IN VARCHAR2
                                ,pr_nmarqdat   IN VARCHAR2
                                ,pr_dtmvtopr   IN DATE 
                                ,pr_nrseqdig      IN NUMBER
                                ,pr_cdconven      IN NUMBER
                                ,pr_tot_vlfatura  IN NUMBER
                                ,pr_tot_vltarifa  IN NUMBER
                                ,pr_tot_vlapagar  IN NUMBER
                                ,pr_cdcritic OUT number
                                ,pr_dscritic OUT VARCHAR2) IS  
    -- Tratamento de comandos no Sistema Operacional
    vr_typsaida VARCHAR2(3);    
  BEGIN 
    -- Caso não seja convênio unificado 
/*    IF pr_rw_gnconve.flgcvuni = 0 THEN 

	  -- Caso seja maior que zero
	  -- esta em processo de homol de convenios

      IF pr_cdconven > 0 THEN
        -- Registra parametros para uso interno da rotina
        begin         
          insert 
            into crapprm (nmsistem
                         ,cdcooper
                         ,cdacesso
                         ,dstexprm
                         ,dsvlrprm)
          values         ('CRED'
                         ,pr_cdcooper
                         ,'PRM_HCONVE_CRPS388_OUT'
                         ,'Parametro de entrada do Crps388, auxilia na homologacao dos convenios.'
                         ,vr_camicop||'/'||vr_nmarqped);
        exception
          when dup_val_on_index then
            update crapprm prm
               set prm.dsvlrprm = vr_camicop||'/'||vr_nmarqped
             where prm.cdcooper = pr_cdcooper
               and prm.cdacesso = 'PRM_HCONVE_CRPS388_OUT';
          when others then          
            -- gerando a critica
            pr_dscritic := 'Erro ao inserir dados na tabela crapprm: '||sqlerrm;        
        end;
      END IF;
*/
      -- Para Internet e E-Sales 

/*
      IF pr_rw_gnconve.tpdenvio IN(1,2) THEN
        -- Vamos converter para DOS 
        gene0001.pc_OScommand_Shell(pr_des_comando => 'ux2dos '||pr_camicoop||'/'||pr_nmarqped ||' >> '||pr_camicoop||'/converte/'||pr_nmarqdat
                                   ,pr_typ_saida   => vr_typsaida
                                   ,pr_des_saida   => vr_dscritic);
        IF NVL(vr_typsaida,' ') != 'ERR' THEN          
        -- Para e-Sales
        IF pr_rw_gnconve.tpdenvio = 2 THEN 
          -- Copiar para o diretório e-Sales
          gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||pr_camicoop||'/converte/'||pr_nmarqdat ||' '||gene0001.fn_param_sistema('CRED', pr_cdcooper, 'DIR_ENVIO_ESALES')
                                     ,pr_typ_saida   => vr_typsaida
                                       ,pr_des_saida   => vr_dscritic);
        ELSE 
          -- Enviaremos email 
          gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => vr_cdprogra
                                    ,pr_des_destino     => pr_rw_gnconve.dsenddeb
                                    ,pr_des_assunto     => 'ARQUIVO DEBITO AUTOMATICO DA '||rw_crapcop.nmrescop
                                    ,pr_des_corpo       => ' '
                                    ,pr_des_anexo       => pr_camicoop||'/converte/'||pr_nmarqdat
                                    ,pr_flg_remove_anex => 'N'
                                    ,pr_flg_enviar      => 'N'
                                    ,pr_des_erro        => vr_dscritic);        
          END IF;
        END IF;
      -- Para Nexxera 
      ELSIF pr_rw_gnconve.tpdenvio = 3 THEN
        -- Copiar para o diretório específico 
        gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||pr_camicoop||'/'||pr_nmarqped ||' '||gene0001.fn_param_sistema('CRED', pr_cdcooper, 'DIR_NEXXERA')
                                   ,pr_typ_saida   => vr_typsaida
                                   ,pr_des_saida   => vr_dscritic);
      -- Para AccessStage 
      ELSIF pr_rw_gnconve.tpdenvio = 5 THEN
        -- Copiar para o diretório arq 
        gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||pr_camicoop||'/'||pr_nmarqped ||' '||pr_camicoop||'/arq'
                                   ,pr_typ_saida   => vr_typsaida
                                   ,pr_des_saida   => vr_dscritic);
      -- Para WebService
      ELSIF pr_rw_gnconve.tpdenvio = 6 THEN  
        -- Chamar gravação do arquivo para retorno posterior via WebService
        conv0002.pc_armazena_arquivo_conven(pr_rw_gnconve.cdconven
                                           ,rw_crapdat.dtmvtolt
                                           ,'F' 
                                           ,0   
                                           ,pr_camicoop||'/salvar'
                                           ,pr_nmarqdat
                                           ,vr_cdcritic
                                           ,vr_dscritic);
        -- Critica 202 é Sucesso no recebimento do arquivo
        IF vr_cdcritic = 202 THEN
          -- Limpar criticas
          vr_cdcritic := 0;
          vr_dscritic := NULL;
        END IF;
      END IF;     
    END IF;  
*/  
  
    -- Nao cria registro de controle se convenio for unificado e a 
    -- execucao for na Cecred, pois quando roda programa que faz a 
    -- unificacao nao atualiza a sequencia do convenio 
    IF pr_cdcooper <> 3 OR pr_rw_gnconve.flgcvuni = 0 THEN
      -- Criaremos registro de controle 
      UPDATE gncontr        
         SET dtcredit = pr_dtmvtopr
            ,nmarquiv = pr_nmarqdat
            ,qtdoctos = pr_nrseqdig
            ,vldoctos = pr_tot_vlfatura
            ,vltarifa = pr_tot_vltarifa
            ,vlapagar = pr_tot_vlapagar
       WHERE cdcooper = pr_cdcooper 
         AND tpdcontr = 4 
         AND cdconven = pr_rw_gnconve.cdconven
         AND dtmvtolt = rw_crapdat.dtmvtolt
         AND nrsequen = pr_nrseqarq;
    END IF;
    
    -- Gerar LOG se houve encontro de critica
    IF nvl(vr_cdcritic,0) <> 0 OR nvl(vr_typsaida,' ') = 'ERR' THEN 
      -- Gerar log no proc_message e continuar 
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> Erro no retorno do arquivo para a empresa --> ' || vr_dscritic 
                                                 || ' Convenio --> '|| pr_rw_gnconve.cdconven);
      -- Limpar erros                                    
      vr_cdcritic := 0;
      vr_dscritic := null;    
    END IF;
    
  EXCEPTION 
    WHEN OTHERS THEN 
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado - Rotina pc_atualiza_controle - '||sqlerrm;
  END pc_atualiza_controle; 
  
  -- Codigo principal da rotina  
  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 057;
      RAISE vr_excsaida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calendário da cooperativa
    OPEN cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_excsaida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapdat;
    END IF;

    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF nvl(vr_cdcritic,0) <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_excsaida;
    END IF;
    
    -- Cancelar agendamentos DEBNET caso tenha ficado algum pendente
    PAGA0001.pc_PAGA0001_cancela_debitos(pr_cdcooper => pr_cdcooper
                                        ,pr_dtmvtopg => rw_crapdat.dtmvtolt
                                        ,pr_cdcritic => vr_cdcriticcanc
                                        ,pr_dscritic => vr_dscriticcanc);
    
    -- Carregar tabela de contas migradas
    FOR rw_tco IN cr_craptco LOOP 
      -- Carregar a tabela 
      vr_tab_tco(rw_tco.nrdconta).cdcopant := rw_tco.cdcopant;
      vr_tab_tco(rw_tco.nrdconta).nrctaant := rw_tco.nrctaant;
      vr_tab_tco(rw_tco.nrdconta).cdagectl := rw_tco.cdagectl;
    END LOOP;
    
    -- Busca do caminho da Cooperativa
    vr_camicop := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                       ,pr_cdcooper => pr_cdcooper);
    
    -- Montagem das informações para os comunidados as empresas
    vr_nmciddat := trim(rw_crapcop.nmcidade) ||', ' 
                                             || to_char(rw_crapdat.dtmvtolt,'dd "de" FMMONTH "de" YYYY','nls_date_language = ''BRAZILIAN PORTUGUESE''');
    vr_nmcidade := trim(rw_crapcop.nmcidade) ||' - '||trim(rw_crapcop.cdufdcop);
    
    -- Montagem de auxiliares para os arquivos 
    vr_dtmvtolt := to_char(rw_crapdat.dtmvtolt,'rrrrmmdd');
    vr_flgfirst := true;
    
    -- Analisa se esta sendo homologado 
    -- algum convenio (busca parametros)
    open cr_hconven (pr_cdcooper);
    fetch cr_hconven into rw_hconven;
    
    -- Se encontrou limita loop de convenios
    if cr_hconven%found then
      vr_cdconven := rw_hconven.dsvlrprm;
    end if;
    
    close cr_hconven;

    -- Busca de todos os convênios de debito automático vinculados a Cooperativa
    FOR rw_gnconve IN cr_gnconve (vr_cdconven) LOOP 
      
      IF nvl(rw_gnconve.flgenv_dt_repasse,0) = 1 THEN  --PJ 565.2
        
         --P565-2 Dias de Repasse (D+X)
         conv0001.pc_soma_dia_util(pr_cdcooper => pr_cdcooper, 
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                                   pr_nrdias => rw_gnconve.tprepass, 
                                   pr_dtcalculada => vr_dtmvtopr);
         --
      ELSE
        vr_dtmvtopr := null;
   
      END IF;
      
      --pj 565.2
        vr_qtdig := rw_gnconve.qttamanho_optante;
        
      
      -- Reiniciar totais e controladores por convênio
      vr_flgfirst := TRUE;
      vr_nrseqdig := 0;
      vr_vlfatura := 0;
      vr_vltarifa := 0;
      vr_vlapagar := 0;
      vr_nrseqndb := 0;
      vr_vlfatndb := 0;
      vr_flgrelat := FALSE;
      vr_nrseqret := 0;
      vr_vldocto2 := 0; 
      vr_tot_vlfatura := 0;
      vr_tot_vlapagar := 0;
      vr_tot_vltarifa := 0;
      
      -- Busca dos lançamentos efetivados no dia
      FOR rw_craplcm IN cr_craplcm(rw_gnconve.cdhisdeb) LOOP 
        -- Reiniciar controladores por lançamentos 
        vr_dsobserv := NULL;
        vr_ctamigra := FALSE; 

        -- Armazenar agencia da Cooperativa
        vr_nragenci := to_char(rw_crapcop.cdagectl, 'fm0000');
        
        -- Verificar se existe autorização de débito especifica para CASAN
        IF rw_gnconve.cdconven = 4 THEN 
          
          OPEN cr_crapatr_casan(pr_nrdconta => rw_craplcm.nrdconta
                               ,pr_cdhistor => rw_craplcm.cdhistor
                               ,pr_cdpesqbb => rw_craplcm.cdpesqbb);
          FETCH cr_crapatr_casan 
           INTO vr_atrcasan;
          -- Se encontrar
          IF cr_crapatr_casan%FOUND THEN 
            -- Usar código fixo
            vr_nragenci := '1294';
          END IF;
          CLOSE cr_crapatr_casan; 
          
        END IF;  
        
        
        -- Para o primeiro registro do arquivo 
        IF vr_flgfirst THEN 
          -- Nomeação dos arquivos 
          pc_nomeia_arquivos(pr_rw_gnconve => rw_gnconve
                            ,pr_nrseqarq => vr_nrseqarq
                            ,pr_nragenci => vr_nragenci
                            ,pr_nmarqdat => vr_nmarqdat
                            ,pr_nmarqped => vr_nmarqped
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
          -- Se houve erro 
          IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
            -- Sair 
            RAISE vr_excsaida;
          END IF;
          
          -- Abrir os CLOBs para Arquivo e Relatórios
          vr_clobarqu := NULL;
          dbms_lob.createtemporary(vr_clobarqu, TRUE);
          dbms_lob.open(vr_clobarqu, dbms_lob.lob_readwrite);
          vr_clobrela := NULL;
          dbms_lob.createtemporary(vr_clobrela, TRUE);
          dbms_lob.open(vr_clobrela, dbms_lob.lob_readwrite);
          
          -- Enviar Header do Arquivo 
          gene0002.pc_escreve_xml(vr_clobarqu
                                 ,vr_txtoarqu
                                 ,'A2'
                                ||RPAD(rw_gnconve.nrcnvfbr,20,' ')
                                ||RPAD(substr(rw_gnconve.nmempres,1,20),20,' ')
                                ||to_char(rw_gnconve.cddbanco,'fm000')
                                ||RPAD(substr(rw_gnconve.nmrescop,1,20),20,' ')
                                ||vr_dtmvtolt
                                ||to_char(vr_nrseqarq,'fm000000')
                                ||LPAD(rw_gnconve.nrlayout,2,'0')
                                ||'DEBITO AUTOMATICO'
                                ||RPAD(' ',52,' ')
                                ||CHR(10));          
          
          -- Inicilizar as informações do Relatório
          gene0002.pc_escreve_xml(vr_clobrela
                                 ,vr_txtorela
                                 ,'<?xml version="1.0" encoding="utf-8"?><crrl350 nmarqdat="'||vr_nmarqdat||'" dtmvtopr="'||to_char(vr_dtmvtopr,'dd/mm/rrrr')||'" nmempcov="'||rw_gnconve.nmempres||'"><lcts>');          
          
          -- Atualizar as Flags
          vr_flgfirst := FALSE;
          vr_flgrelat := TRUE;
        END IF;
        
        -- Checar se a conta é migrada 
        IF vr_tab_tco.exists(rw_craplcm.nrdconta) THEN 
          vr_ctamigra := true;
        ELSE 
          vr_ctamigra := false;
        END IF;        
        
        -- Verificar se existe o lançamento migrada 
        OPEN cr_craplau(pr_cdcooper
                       ,rw_craplcm.nrdconta
                       ,rw_craplcm.cdhistor
                       ,rw_craplcm.dtmvtolt
                       ,rw_craplcm.cdpesqbb);
                       
        FETCH cr_craplau INTO rw_craplau;
        
        -- Se não encontrar 
        IF cr_craplau%NOTFOUND THEN 

          CLOSE cr_craplau;

          /** Verifica se eh conta migrada e se foi enviado 
              para agendamento na coop. anterior ***/
          IF vr_ctamigra THEN      
                   
            -- Buscar na Cooperativa anterior
            OPEN cr_craplau(vr_tab_tco(rw_craplcm.nrdconta).cdcopant
                           ,vr_tab_tco(rw_craplcm.nrdconta).nrctaant
                           ,rw_craplcm.cdhistor
                           ,rw_craplcm.dtmvtolt
                           ,rw_craplcm.cdpesqbb);
                           
            FETCH cr_craplau INTO rw_craplau;

            -- Se não encontrar 
            IF cr_craplau%NOTFOUND THEN 
              CLOSE cr_craplau;
              -- Gerar critica 501 no proc_message
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> ' || gene0001.fn_busca_critica(501) 
                                                         || ' Conta = '|| gene0002.fn_mask_conta(rw_craplcm.nrdconta)
                                                         || ' Documento = ' || rw_craplcm.nrdocmto);
              -- Ir ao próximo registro (Ignorar LCM)
              CONTINUE;   

            ELSE
              CLOSE cr_craplau;
            END IF;

          ELSE

            -- Gerar critica 501 no proc_message
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> ' || gene0001.fn_busca_critica(501) 
                                                       || ' Conta = '|| gene0002.fn_mask_conta(rw_craplcm.nrdconta)
                                                       || ' Documento = ' || rw_craplcm.nrdocmto);
            -- Ir ao próximo registro (Ignorar LCM)
            CONTINUE;   

          END IF;
        ELSE 
          CLOSE cr_craplau;
        END IF;        
        
        -- Verificar se existe autorização de débito (antigo e novo)
        OPEN cr_crapatr(rw_craplcm.nrdconta
                       ,rw_craplau.cdhistor
                       ,rw_craplau.nrcrcard
                       ,rw_craplau.nrdocmto);
        FETCH cr_crapatr
         INTO rw_crapatr;
        -- Se não encontrar 
        IF cr_crapatr%NOTFOUND THEN 
          CLOSE cr_crapatr;
          -- Gerar critica 453
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> ' || gene0001.fn_busca_critica(453) 
                                                     || ' Conta = '|| gene0002.fn_mask_conta(rw_craplcm.nrdconta)
                                                     || ' Documento = ' || rw_craplcm.nrdocmto);
          -- Ir ao próximo registro (Ignorar LCM)
          CONTINUE;   
        ELSE 
          CLOSE cr_crapatr;
        END IF;       
        
        -- Convenio 1 não pode ter referencia com mais de 11 posições
        IF rw_gnconve.cdconven = 1 AND  LENGTH(to_char(rw_crapatr.cdrefere,'fm999999999999990')) > 11 THEN
          -- Gerar critica 654
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> ' || gene0001.fn_busca_critica(654)
                                                     || ' Conta = '|| gene0002.fn_mask_conta(rw_craplcm.nrdconta)
                                                     || ' Documento = ' || rw_craplcm.nrdocmto);
          -- Ir ao próximo registro (Ignorar LCM)
          CONTINUE;  
        END IF;
         
        -- Referencia diferenciada para o convênio 1
        IF rw_gnconve.cdconven = 1 THEN 
          vr_cdrefere := gene0002.fn_mask(rw_crapatr.cdrefere,'999.999.999.9');
        ELSIF rw_gnconve.cdconven IN(9,16,24,31,33,34,53,54) THEN 
          /* 31 DAE Navegantes */
          /* 33 Aguas de Joinville */
          /* 34 SEMASA Itajai */
          /* 53 Foz do Brasil */
          /* 54 Aguas de Massaranduba */
          vr_cdrefere := gene0002.fn_mask(rw_crapatr.cdrefere,'9999.999.9');        
        ELSE 
          vr_cdrefere := trim(rw_crapatr.cdrefere);
        END IF;
        
        -- Acumular valores 
        vr_nrseqdig := vr_nrseqdig + 1;
        vr_tot_vlfatura := vr_tot_vlfatura + rw_craplcm.vllanmto;
        
        -- MOntagem prefixo da Cooperativa 
        IF (   rw_gnconve.cdcooper = pr_cdcooper 
            OR pr_cdcooper = 1                 
            OR rw_gnconve.flgagenc = 1 /*TRUE*/
            OR rw_crapatr.dtiniatr  > to_date('01/09/2013','dd/mm/rrrr')) 
            /*32 UNIODONTO*/ 
            /*38 UNIM.PLAN.NORTE*/
            /*43 SERVMED*/
            /*46 UNIODONTO FEDER.*/
            /*47 UNIMED CREDCREA*/
            /*55 LIBERTY*/
            /*57 RBS*/
            /*58 PORTO SEGURO*/
            AND (rw_gnconve.cdconven NOT IN(22,32,38,43,46,47,55,57,58)) THEN 
          vr_cdcooper := ' ';
        ELSE
          vr_cdcooper := '9' || TO_CHAR(pr_cdcooper,'fm000');
        END IF;

        -- Montagem do prefixo Cooperativa em caso de Migração
        IF vr_ctamigra THEN 
          -- Se a cooperativa anterior igual ao do agendamento 
          IF (   rw_craplau.cdcooper = vr_tab_tco(rw_craplau.nrdconta).cdcopant 
              OR rw_craplau.cdcritic = 951                
              OR UPPER(rw_craplau.dscodbar) = 'MIGRADO') THEN
            -- Tratamento conforme os convênios 
              /*32 UNIODONTO*/ 
              /*38 UNIM.PLAN.NORTE*/
              /*43 SERVMED*/
              /*46 UNIODONTO FEDER.*/
              /*47 UNIMED CREDCREA*/
              /*55 LIBERTY*/
              /*57 RBS*/
              /*58 PORTO SEGURO*/
            IF vr_tab_tco(rw_craplau.nrdconta).cdcopant = 1 AND (rw_gnconve.cdconven NOT IN(22,32,38,43,46,47,55,57,58)) THEN 
              vr_cdcooper := ' ';
            ELSE
              IF rw_gnconve.flgagenc = 1 /*true*/ THEN
                vr_cdcooper := ' '; 
              ELSE   
                vr_cdcooper := '9' || TO_CHAR(vr_tab_tco(rw_craplau.nrdconta).cdcopant,'fm000');
              END IF;  
            END IF;
            -- Montar observação 
            vr_dsobserv := 'Debito migrado.';
            -- Usar agencia da Cooperativa Anterior
            vr_nragenci := to_char(vr_tab_tco(rw_craplau.nrdconta).cdagectl,'fm9999');
          END IF;
        END IF;  
        
        -- Se não conseguirmos montar a Cooperativa ainda
        IF vr_cdcooper = ' ' THEN 
          -- Para convenios 9, 74 e 75 
          IF rw_gnconve.cdconven IN(9,74,75) THEN 
            -- Para conta migrada 
            IF vr_ctamigra AND vr_dsobserv IS NOT NULL THEN 
              vr_nrdconta := to_char(vr_tab_tco(rw_craplcm.nrdconta).nrctaant,'fm00000000000000');
            ELSE 
              vr_nrdconta := to_char(rw_craplcm.nrdconta,'fm00000000000000');
            END IF;
          ELSE 
            -- Para conta migrada 
            IF vr_ctamigra AND vr_dsobserv IS NOT NULL THEN 
              vr_nrdconta := to_char(vr_tab_tco(rw_craplcm.nrdconta).nrctaant,'fm00000000');
            ELSE 
              vr_nrdconta := to_char(rw_craplcm.nrdconta,'fm00000000');
            END IF;
          END IF;
        ELSE           
          -- Para o convênio 9
          IF rw_gnconve.cdconven = 9 THEN 
            -- Incluir dois espaços na frente
            vr_nrdconta := '  ';
          ELSE
            vr_nrdconta := NULL;
          END IF;
          -- Incluir a Cooperativa
          vr_nrdconta := vr_nrdconta||to_char(vr_cdcooper,'fm0000');          
          -- Para conta migrada 
          IF vr_ctamigra AND vr_dsobserv IS NOT NULL THEN 
            vr_nrdconta := vr_nrdconta||to_char(vr_tab_tco(rw_craplcm.nrdconta).nrctaant,'fm00000000');
          ELSE 
            vr_nrdconta := vr_nrdconta||to_char(rw_craplcm.nrdconta,'fm00000000');
          END IF;          
        END IF;
        
        -- Remover espaços
        vr_cdrefere := TRIM(vr_cdrefere);
        
        -- Enviar registro para o relatório 
        gene0002.pc_escreve_xml(vr_clobrela
                               ,vr_txtorela
                               , '<lcto>'
                               || ' <nrdconta>'||gene0002.fn_mask_conta(rw_craplcm.nrdconta)||'</nrdconta>'
                               || ' <cdrefere>'||vr_cdrefere||'</cdrefere>'
                               || ' <vllanmto>'||to_char(rw_craplcm.vllanmto,'fm999G999G999G999G990d00')||'</vllanmto>'
                               || ' <dtmvtolt>'||to_char(rw_craplcm.dtmvtolt,'dd/mm/rrrr')||'</dtmvtolt>'
                               || ' <dsobserv>'||vr_dsobserv||'</dsobserv>'
                               ||'</lcto>');
        
        -- Buscar referencia formatada
        conv0001.pc_retorna_referencia_conv(pr_cdconven => rw_gnconve.cdconven
                                           ,pr_cdhistor => 0
                                           ,pr_cdrefere => rw_crapatr.cdrefere
                                           ,pr_nrrefere => vr_nrrefere
                                           ,pr_qtdigito => vr_qtdigito
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        
        --pj 565.2
        vr_qtdig := rw_gnconve.qttamanho_optante;
        
        --faba
        if vr_qtdig <> 0 then
          vr_cdrefere := rw_crapatr.cdrefere;
        else
          vr_cdrefere := trim(nvl(rw_crapatr.cdseqtel,rw_crapatr.cdrefere));
        end if;
        -- fim faba
        
        IF vr_qtdig <> 0 THEN  
          vr_cdrefere := rw_crapatr.cdrefere; 
          vr_cdidenti := RPAD(LPAD(vr_cdrefere,vr_qtdig ,'0'),25,' ');  
        ELSE
          vr_cdidenti := RPAD(vr_cdrefere,25,' ');
        END IF; 
                                       
        IF rw_gnconve.nrlayout = 5 THEN
    	
          -- CERSAD e SANEPAR
          IF vr_qtdig <> 0 THEN
            vr_dslinreg := 'F' 
                    || vr_cdidenti
                    --||vr_nrrefere 
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')                       
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00'                                   
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || nvl(to_char(rw_craplau.tppessoa_dest,'fm0'),' ')
                    || nvl(to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000'),'               ')
                    || RPAD(' ',4,' ') || '0';

          /* Celesc Distribuicao */  
          /* Aguas Pres.Getulio  */
          ELSIF rw_gnconve.cdconven IN (30,45) THEN       						
            vr_dslinreg := 'F' 
                    || vr_cdidenti 
                   -- || to_char(rw_crapatr.cdrefere,'fm000000000')
                   -- || RPAD(' ',16,' ')
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')                       
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00'                                   
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || nvl(to_char(rw_craplau.tppessoa_dest,'fm0'),' ')
                    || nvl(to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000'),'               ')
                    || RPAD(' ',4,' ') || '0';
                    
          /* CASAN */           
          /* AGUAS ITAPEMA */           
          /* DAE NAVEGANTES */           
          /* AGUAS JOINVILLE */           
          /* SEMASA ITAJAI */           
          /* Foz do Brasil */           
          /* AGUAS DE MASSARANDUBA */ 
		  /* 108 - AGUAS DE GUARAMIRIM */
          ELSIF rw_gnconve.cdconven IN (4,24,31,33,34,53,54,108) THEN  

            vr_dslinreg := 'F' 
                    || vr_cdidenti 
                   -- || to_char(rw_crapatr.cdrefere,'fm00000000')
                   -- || RPAD(' ',17,' ')
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || vr_dtmvtolt                          
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00'                                   
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || nvl(to_char(rw_craplau.tppessoa_dest,'fm0'),' ')
                    || nvl(to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000'),'               ')
                    || RPAD(' ',4,' ') || '0';
                    
          /* TIM Celular */          
          /* HDI */          
          /* LIBERTY */          
          /* PORTO SEGURO */          
          /* PREVISUL */          
          ELSIF rw_gnconve.cdconven IN (48,50,55,58,66) THEN  
    										 
            vr_dslinreg := 'F' 
                    || vr_cdidenti 
                  --  || to_char(rw_crapatr.cdrefere,'fm00000000000000000000')
                  --  || RPAD(' ',5,' ')
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || vr_dtmvtolt
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00'                                   
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || nvl(to_char(rw_craplau.tppessoa_dest,'fm0'),' ')
                    || nvl(to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000'),'               ')
                    || RPAD(' ',4,' ') || '0';
                    
          /* UNIMED CREDCREA */          
          /* RBS */
          ELSIF rw_gnconve.cdconven IN (47,57) THEN  

            vr_dslinreg := 'F' 
                    || vr_cdidenti 
                  --  || to_char(rw_crapatr.cdrefere,'fm00000000000000000')
                  --  || RPAD(' ',8,' ')
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || vr_dtmvtolt
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00'                                   
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || nvl(to_char(rw_craplau.tppessoa_dest,'fm0'),' ')
                    || nvl(to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000'),'               ')
                    || RPAD(' ',4,' ') || '0';
                    
          /* UNIMED */          
          /* UNIODONTO */          
          /* UNIM.PLAN.NORTE */           
          /* UNIODONTO FEDERACAO */          
          /* AZUL SEGUROS */   
          ELSIF rw_gnconve.cdconven IN (22,32,38,46,64) THEN   
                
            vr_dslinreg := 'F' 
                    || vr_cdidenti 
                 --   || to_char(rw_crapatr.cdrefere,'fm0000000000000000000000000')
                 --   || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || vr_dtmvtolt
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00'                                   
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || nvl(to_char(rw_craplau.tppessoa_dest,'fm0'),' ')
                    || nvl(to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000'),'               ')
                    || RPAD(' ',4,' ') || '0';
             
          /* VIVO */       
          ELSIF rw_gnconve.cdconven IN (15)   THEN 

            vr_dslinreg := 'F' 
                    || vr_cdidenti 
                --    || to_char(rw_crapatr.cdrefere,'fm00000000000')
                --    || LPAD(' ',14,' ')
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00'                                   
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || nvl(to_char(rw_craplau.tppessoa_dest,'fm0'),' ')
                    || nvl(to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000'),'               ')
                    || RPAD(' ',4,' ') || '0';
                    
          /*SAMAE Jaragua*/           
          /*SAMAE Gaspar */           
          /*SAMAE Blumenau CECRED*/           
          /*SAMAE Timbo CECRED*/           
          /*SAMAE Rio Negrinho*/           
          ELSIF rw_gnconve.cdconven IN (9,19,20,16,49) THEN  
                
            vr_dslinreg := 'F' 
                    || vr_cdidenti 
               --     || to_char(rw_crapatr.cdrefere,'fm000000')
               --     || LPAD(' ',19,' ')
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    ||'00'
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || nvl(to_char(rw_craplau.tppessoa_dest,'fm0'),' ')
                    || nvl(to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000'),'               ')
                    || RPAD(' ',4,' ') || '0';
          
          /* BRASIL TELECOM/SC */
          /* SAMAE BRUSQUE */
          /* SAMAE POMERODE */
          /* AGUAS DE JOINVILLE */
          /* SEGURO AUTO */
          /* SAMAE SAO BENTO */
          /* SERVMED */
          /* AGUAS DE ITAPOCOROY */           
          ELSIF rw_gnconve.cdconven IN (1,25,26,33,39,41,43,62) THEN
                
            vr_dslinreg := 'F' 
                    || vr_cdidenti 
                --    || to_char(rw_crapatr.cdrefere,'fm0000000000')
                --    || LPAD(' ',15,' ') 
                    || to_char(vr_nragenci,'fm0000') 
                    || RPAD(vr_nrdconta,14,' ') 
                    || vr_dtmvtolt 
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00' 
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || nvl(to_char(rw_craplau.tppessoa_dest,'fm0'),' ')
                    || nvl(to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000'),'               ')
                    || RPAD(' ',4,' ') || '0';
            
          /* MAPFRE VERA CRUZ SEG */        
          ELSIF rw_gnconve.cdconven IN (74,75) THEN
                
            vr_dslinreg := 'F' 
                    || vr_cdidenti 
                 --   || rw_crapatr.cdrefere 
                 --   || LPAD(' ',25 - length(rw_crapatr.cdrefere),' ') 
                    || to_char(vr_nragenci,'fm0000') 
                    || RPAD(vr_nrdconta,14,' ') 
                    || vr_dtmvtolt 
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00' 
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || nvl(to_char(rw_craplau.tppessoa_dest,'fm0'),' ')
                    || nvl(to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000'),'               ')
                    || RPAD(' ',4,' ') || '0';
                    
          ELSIF rw_gnconve.cdconven = 112 THEN -- chubb seguros
              vr_dslinreg := 'F'
                    || vr_cdidenti 
                 --   || to_char(rw_crapatr.cdrefere,'fm00000000000000000000000')
                 --   || RPAD(' ',2,' ') 
                    || to_char(vr_nragenci,'fm0000') 
                    || RPAD(vr_nrdconta,14,' ') 
                    || vr_dtmvtolt 
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00' 
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || nvl(to_char(rw_craplau.tppessoa_dest,'fm0'),' ')
                    || nvl(to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000'),'               ')
                    || RPAD(' ',4,' ') || '0';
          ELSE
              vr_dslinreg := 'F'
                    || vr_cdidenti 
                  --  || to_char(rw_crapatr.cdrefere,'fm0000000000000000000000')
                  --  || RPAD(' ',3,' ') 
                    || to_char(vr_nragenci,'fm0000') 
                    || RPAD(vr_nrdconta,14,' ') 
                    || vr_dtmvtolt 
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00' 
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || nvl(to_char(rw_craplau.tppessoa_dest,'fm0'),' ')
                    || nvl(to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000'),'               ')
                    || RPAD(' ',4,' ') || '0';
          END IF;
       
       ELSE
		
          -- Enviar informações para o arquivo conforme especificidades do convênio

          IF vr_qtdig <> 0 THEN
            
            IF rw_gnconve.cdconven IN(127,128) THEN 
            
              -- Todos outros casos 
            -- Enviar linha ao arquivo 
              vr_dslinreg := 'F'
                          || vr_cdidenti 
                    
                          ||to_char(vr_nragenci,'fm0000')
                          ||RPAD(vr_nrdconta,14,' ')
                          ||vr_dtmvtolt
                          ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                          ||'00'
                          ||rpad(rw_craplau.cdseqtel,60,' ')
                          ||lpad(nvl(TO_CHAR(vr_dtmvtopr,'rrrrmmdd'),' '),8,' ')
                          ||RPAD(' ',12,' ')||'0';      
                
            ELSE
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        ||vr_cdidenti
                     
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||lpad(nvl(TO_CHAR(vr_dtmvtopr,'rrrrmmdd'),' '),8,' ')
                        ||RPAD(' ',12,' ')||'0';      
          
            END IF;
          
          /* 30 - Celesc Distribuicao */
          /* 45 - Aguas Pres.Getulio  */
          ELSIF rw_gnconve.cdconven IN(30,45) THEN    
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        ||vr_cdidenti 
             
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||lpad(nvl(TO_CHAR(vr_dtmvtopr,'rrrrmmdd'),' '),8,' ')
                        ||RPAD(' ',12,' ')||'0';      
          /* 4  - CASAN */
          /* 24 - AGUAS ITAPEMA */
          /* 31 - DAE NAVEGANTES */
          /* 33 - AGUAS JOINVILLE */
          /* 34 - SEMASA ITAJAI */
          /* 53 - Foz do Brasil */
          /* 54 - AGUAS DE MASSARANDUBA */  
		  /* 108 - AGUAS DE GUARAMIRIM */
          ELSIF rw_gnconve.cdconven IN(4,24,31,33,34,53,54,108) THEN
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        || vr_cdidenti 

                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||vr_dtmvtolt
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||lpad(nvl(TO_CHAR(vr_dtmvtopr,'rrrrmmdd'),' '),8,' ')
                        ||RPAD(' ',12,' ')||'0';      
          /* 48 - TIM Celular */
          /* 50 - HDI */
          /* 55 - LIBERTY */
          /* 58 - PORTO SEGURO */
          /* 66 - PREVISUL */        
          ELSIF rw_gnconve.cdconven IN(48,50,55,58,66) THEN  
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        || vr_cdidenti 

                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||vr_dtmvtolt
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||lpad(nvl(TO_CHAR(vr_dtmvtopr,'rrrrmmdd'),' '),8,' ')
                        ||RPAD(' ',12,' ')||'0';
          /* 47 - UNIMED CREDCREA */
          /* 57 - RBS */
          ELSIF rw_gnconve.cdconven IN(47,57) THEN     
            -- Enviar linha ao arquivo 
            vr_dslinreg :='F'
                        || vr_cdidenti 

                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||vr_dtmvtolt
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||lpad(nvl(TO_CHAR(vr_dtmvtopr,'rrrrmmdd'),' '),8,' ')
                        ||RPAD(' ',12,' ')||'0';
          /* 22 - UNIMED */
          /* 32 - UNIODONTO */
          /* 38 - UNIM.PLAN.NORTE */ 
          /* 46 - UNIODONTO FEDERACAO */
          /* 64 - AZUL SEGUROS */   
          ELSIF rw_gnconve.cdconven IN(22,32,38,46,64) THEN   
            -- Enviar linha ao arquivo 
            vr_dslinreg :='F'
                        || vr_cdidenti 
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||vr_dtmvtolt
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||lpad(nvl(TO_CHAR(vr_dtmvtopr,'rrrrmmdd'),' '),8,' ')
                        ||RPAD(' ',12,' ')||'0';
          /* 15 - VIVO */
          ELSIF rw_gnconve.cdconven = 15 THEN 
            -- Enviar linha ao arquivo 
            vr_dslinreg :='F'
                        || vr_cdidenti 
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||lpad(nvl(TO_CHAR(vr_dtmvtopr,'rrrrmmdd'),' '),8,' ')
                        ||RPAD(' ',12,' ')||'0';      
          /* 9 - SAMAE Jaragua*/
          /*19 - SAMAE Gaspar */
          /*20 - SAMAE Blumenau CECRED*/
          /*16 - SAMAE Timbo CECRED*/
          /*49 - SAMAE Rio Negrinho*/
          ELSIF rw_gnconve.cdconven IN(9,19,20,16,49) THEN  
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        || vr_cdidenti 
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||lpad(nvl(TO_CHAR(vr_dtmvtopr,'rrrrmmdd'),' '),8,' ')
                        ||RPAD(' ',12,' ')||'0';      
          /*  1 - BRASIL TELECOM/SC */
          /* 25 - SAMAE BRUSQUE */
          /* 26 - SAMAE POMERODE */
          /* 33 - AGUAS DE JOINVILLE */
          /* 39 - SEGURO AUTO */
          /* 41 - SAMAE SAO BENTO */
          /* 43 - SERVMED */
          /* 62 - AGUAS DE ITAPOCOROY */ 
          ELSIF rw_gnconve.cdconven IN(1,25,26,33,39,41,43,62) THEN 
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        || vr_cdidenti 
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||vr_dtmvtolt
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||lpad(nvl(TO_CHAR(vr_dtmvtopr,'rrrrmmdd'),' '),8,' ')
                        ||RPAD(' ',12,' ')||'0';        
          /* 74 e 75 - MAPFRE VERA CRUZ SEG */ 
          ELSIF rw_gnconve.cdconven IN(74,75) THEN
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        || vr_cdidenti 
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||vr_dtmvtolt
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||lpad(nvl(TO_CHAR(vr_dtmvtopr,'rrrrmmdd'),' '),8,' ')
                        ||RPAD(' ',12,' ')||'0';      
        ELSIF rw_gnconve.cdconven = 112 THEN -- chubb seguros
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        || vr_cdidenti 
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||vr_dtmvtolt
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||lpad(nvl(TO_CHAR(vr_dtmvtopr,'rrrrmmdd'),' '),8,' ')
                        ||RPAD(' ',12,' ')||'0';              
        ELSE
          -- Todos outros casos 
          -- Enviar linha ao arquivo 
          vr_dslinreg := 'F'
                      || vr_cdidenti 
                      ||to_char(vr_nragenci,'fm0000')
                      ||RPAD(vr_nrdconta,14,' ')
                      ||vr_dtmvtolt
                      ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                      ||'00'
                      ||rpad(rw_craplau.cdseqtel,60,' ')
                      ||lpad(nvl(TO_CHAR(vr_dtmvtopr,'rrrrmmdd'),' '),8,' ')
                      ||RPAD(' ',12,' ')||'0';              
          END IF;
        END IF;
        
        
        -- Enviar para o arquivo 
        gene0002.pc_escreve_xml(vr_clobarqu
                                 ,vr_txtoarqu
                                 ,vr_dslinreg||CHR(10));    
        
        -- Criar registro unificado 
        IF rw_gnconve.flgcvuni = 1 THEN 
          BEGIN 
            INSERT INTO gncvuni(cdcooper
                               ,cdconven
                               ,dtmvtolt
                               ,flgproce
                               ,nrseqreg
                               ,dsmovtos
                               ,tpdcontr)
                         VALUES(pr_cdcooper
                               ,rw_gnconve.cdconven
                               ,rw_crapdat.dtmvtolt
                               ,1 -- RRC
                               ,vr_nrseqdig
                               ,vr_dslinreg
                               ,2); /* DEB. AUTOMATICO */
                               
          
          EXCEPTION 
            WHEN OTHERS THEN 
              vr_dscritic := 'Erro na gravacao da gncvuni --> '||sqlerrm;
              RAISE vr_excsaida;
          END;
        END IF;
      
      END LOOP; -- Loop lançamentos do dia 
      
      -- Sequencia unificada 
      vr_nrsequni := vr_nrseqdig;
      
      -- Buscar lançamentos não efetuados do convênio 
      FOR rw_crapndb IN cr_crapndb(rw_gnconve.cdhisdeb) LOOP
        
      
        -- Para o primeiro registro do arquivo 
        IF vr_flgfirst THEN 
          -- Nomeação dos arquivos 
          pc_nomeia_arquivos(pr_rw_gnconve => rw_gnconve
                            ,pr_nrseqarq => vr_nrseqarq
                            ,pr_nragenci => vr_nragenci
                            ,pr_nmarqdat => vr_nmarqdat
                            ,pr_nmarqped => vr_nmarqped
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
          -- Se houve erro 
          IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
            -- Sair 
            RAISE vr_excsaida;
          END IF;
          
          -- Abrir os CLOBs para Arquivo 
          vr_clobarqu := NULL;
          dbms_lob.createtemporary(vr_clobarqu, TRUE);
          dbms_lob.open(vr_clobarqu, dbms_lob.lob_readwrite);
          
          -- Enviar Header do Arquivo 
          gene0002.pc_escreve_xml(vr_clobarqu
                                 ,vr_txtoarqu
                                 ,'A2'
                                ||RPAD(rw_gnconve.nrcnvfbr,20,' ')
                                ||RPAD(substr(rw_gnconve.nmempres,1,20),20,' ')
                                ||to_char(RW_gnconve.cddbanco,'fm000')
                                ||RPAD(substr(rw_gnconve.nmrescop,1,20),20,' ')
                                ||vr_dtmvtolt
                                ||to_char(vr_nrseqarq,'fm000000')
                                ||LPAD(rw_gnconve.nrlayout,2,'0')
                                ||'DEBITO AUTOMATICO'
                                ||RPAD(' ',52,' ')
                                ||CHR(10));          
          
          -- Atualizar as Flags
          vr_flgfirst := FALSE;
        END IF;
        
        --Se convênvio utiliza versão 5 do layout fefraban
        IF rw_gnconve.nrlayout = 5 THEN
           IF vr_qtdig <> 0 THEN
              IF rw_gnconve.cdconven = 19 THEN

                vr_dslinreg := 'F'||RPAD(LPAD(trim(substr(substr(rw_crapndb.dstexarq,1,25),2,instr(rw_crapndb.dstexarq,' ',-1))),vr_qtdig,'0'),25,' ')
                         || RPAD(SUBSTR(rw_crapndb.dstexarq,27,127),102,' ')
                         || RPAD(' ',1,' ')
                         || SUBSTR(rw_crapndb.dstexarq,130,1) 
                         || SUBSTR(rw_crapndb.dstexarq,131,15)
                         || RPAD(' ',4,' ') || '0';

              ELSE
                  IF rw_gnconve.cdconven IN (4,15,16,45,50,9,74,75) THEN
                -- Enviar linha ao arquivo 
                      vr_dslinreg := 'F'||RPAD(LPAD(trim(substr(substr(rw_crapndb.dstexarq,1,25),2,instr(rw_crapndb.dstexarq,' ',-1))),vr_qtdig,'0'),25,' ')
                               || RPAD(SUBSTR(rw_crapndb.dstexarq,27,150),150,' ');
                
                  ELSE
                /* Gravar o gncvuni */
                    vr_dslinreg :='F'||RPAD(LPAD(trim(substr(substr(rw_crapndb.dstexarq,1,26),2,instr(rw_crapndb.dstexarq,' ',-1))),vr_qtdig,'0'),25,' ')
                             || RPAD(SUBSTR(rw_crapndb.dstexarq,27,104),104,' ') 
                        -- || SUBSTR(rw_crapndb.dstexarq,130,1) 
                         || SUBSTR(rw_crapndb.dstexarq,131,15)
                         || RPAD(' ',4,' ') || '0';
                   END IF; 
                         
              END IF;
          ELSE
             IF rw_gnconve.cdconven = 19 THEN

                vr_dslinreg := 'F'||RPAD(trim(substr(substr(rw_crapndb.dstexarq,1,25),2,instr(rw_crapndb.dstexarq,' ',-1))),25,' ')
                         || RPAD(SUBSTR(rw_crapndb.dstexarq,27,127),102,' ')
                         || RPAD(' ',1,' ')
                         || SUBSTR(rw_crapndb.dstexarq,130,1) 
                         || SUBSTR(rw_crapndb.dstexarq,131,15)
                         || RPAD(' ',4,' ') || '0';

              ELSE
                  IF rw_gnconve.cdconven IN (4,15,16,45,50,9,74,75) THEN
    						
                -- Enviar linha ao arquivo 
                      vr_dslinreg := 'F'||RPAD(trim(substr(substr(rw_crapndb.dstexarq,1,25),2,instr(rw_crapndb.dstexarq,' ',-1))),25,' ')
                               || RPAD(SUBSTR(rw_crapndb.dstexarq,27,150),150,' ');
                
                  ELSE
                
                     /* Gravar o gncvuni */
                    vr_dslinreg :='F'||RPAD(trim(substr(substr(rw_crapndb.dstexarq,1,26),2,instr(rw_crapndb.dstexarq,' ',-1))),25,' ')
                             || RPAD(SUBSTR(rw_crapndb.dstexarq,27,104),104,' ') 
                         --|| SUBSTR(rw_crapndb.dstexarq,130,1) 
                         || SUBSTR(rw_crapndb.dstexarq,131,15)
                         || RPAD(' ',4,' ') || '0';
                   END IF; 
              END IF;
           END IF;
			  ELSE
			         
          /* Convenio 19 */ 
          IF rw_gnconve.cdconven = 19 THEN
            IF vr_qtdig <> 0 THEN
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'||RPAD(LPAD(trim(substr(substr(rw_crapndb.dstexarq,1,25),2,instr(rw_crapndb.dstexarq,' ',-1))),vr_qtdig,'0'),25,' ')
                     || RPAD(SUBSTR(rw_crapndb.dstexarq,27,102),102+21,' ') ||'0';
             ELSE
               vr_dslinreg := 'F'||RPAD(trim(substr(substr(rw_crapndb.dstexarq,1,25),2,instr(rw_crapndb.dstexarq,' ',-1))),25,' ')
                     || RPAD(SUBSTR(rw_crapndb.dstexarq,27,102),102+21,' ') ||'0';
             END IF;        
                     
            -- caso campo envia data repasse = sim
          ELSIF rw_gnconve.flgenv_dt_repasse = 1 THEN
             IF vr_qtdig <> 0 THEN
            vr_dslinreg := 'F'||RPAD(LPAD(trim(substr(substr(rw_crapndb.dstexarq,1,25),2,instr(rw_crapndb.dstexarq,' ',-1))),vr_qtdig,'0'),25,' ')
                   || RPAD(SUBSTR(rw_crapndb.dstexarq,27,103),103,' ')
                        ||to_char(vr_dtmvtopr,'rrrrmmdd')
                        ||RPAD(' ',12,' ')||'0';              
          ELSE 
                  vr_dslinreg := 'F'||RPAD(trim(substr(substr(rw_crapndb.dstexarq,1,26),2,instr(rw_crapndb.dstexarq,' ',-1))),25,' ')
                         || RPAD(SUBSTR(rw_crapndb.dstexarq,27,103),103,' ')
                              ||to_char(vr_dtmvtopr,'rrrrmmdd')
                              ||RPAD(' ',12,' ')||'0';  
              END IF;        
          ELSE 
            IF vr_qtdig <> 0 THEN
               -- outros casos
                vr_dslinreg :=  'F'||RPAD(LPAD(trim(substr(substr(rw_crapndb.dstexarq,1,25),2,instr(rw_crapndb.dstexarq,' ',-1))),vr_qtdig,'0'),25,' ')
                         ||RPAD(substr(rw_crapndb.dstexarq,27,127),124,' ');
             ELSE            
          
                vr_dslinreg :=  'F'||RPAD(trim(substr(substr(rw_crapndb.dstexarq,1,26),2,instr(rw_crapndb.dstexarq,' ',-1))),25,' ')
                         ||RPAD(substr(rw_crapndb.dstexarq,27,127),124,' ');   
             END IF;      
          END IF;
        END IF;
        
        -- Enviar para o arquivo 
        gene0002.pc_escreve_xml(vr_clobarqu
                               ,vr_txtoarqu
                               ,vr_dslinreg||CHR(10));   
        
        -- Criar registro unificado 
        IF rw_gnconve.flgcvuni = 1 THEN 
          -- INcrementar o contador 
          vr_nrsequni := vr_nrsequni + 1;          
          BEGIN 
            INSERT INTO gncvuni(cdcooper
                               ,cdconven
                               ,dtmvtolt
                               ,flgproce
                               ,nrseqreg
                               ,dsmovtos
                               ,tpdcontr)
                         VALUES(pr_cdcooper
                               ,rw_gnconve.cdconven
                               ,rw_crapdat.dtmvtolt
                               ,0 /*FALSE*/
                               ,vr_nrsequni
                               ,vr_dslinreg
                               ,2); /* DEB. AUTOMATICO */
                               
          
          EXCEPTION 
            WHEN OTHERS THEN 
              vr_dscritic := 'Erro na gravacao da gncvuni --> '||sqlerrm;
              RAISE vr_excsaida;
          END;
        END IF;
        
        -- Acumular totalizadores
        vr_nrseqndb := vr_nrseqndb + 1;
        vr_vllanmto := nvl(to_number(TRIM(SUBSTR(rw_crapndb.dstexarq,53,15))),0);
        vr_vllanmto := vr_vllanmto / 100;
        vr_vlfatndb := vr_vlfatndb + vr_vllanmto;        
      
      END LOOP;
      
      -- Se convênio gera registro "J"
      IF rw_gnconve.flggeraj = 1 THEN 
        -- Buscar os registro pendentes de envio 
        FOR rw_gnarqrx IN cr_gnarqrx(rw_gnconve.cdconven) LOOP 
          -- Para o primeiro registro do arquivo 
          IF vr_flgfirst THEN 
            -- Nomeação dos arquivos 
            pc_nomeia_arquivos(pr_rw_gnconve => rw_gnconve
                              ,pr_nrseqarq => vr_nrseqarq
                              ,pr_nragenci => vr_nragenci
                              ,pr_nmarqdat => vr_nmarqdat
                              ,pr_nmarqped => vr_nmarqped
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
            -- Se houve erro 
            IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
              -- Sair 
              RAISE vr_excsaida;
            END IF;
            
            -- Abrir os CLOBs para Arquivo 
            vr_clobarqu := NULL;
            dbms_lob.createtemporary(vr_clobarqu, TRUE);
            dbms_lob.open(vr_clobarqu, dbms_lob.lob_readwrite);
            
            -- Enviar Header do Arquivo 
            gene0002.pc_escreve_xml(vr_clobarqu
                                   ,vr_txtoarqu
                                   ,'A2'
                                  ||RPAD(rw_gnconve.nrcnvfbr,20,' ')
                                  ||RPAD(substr(rw_gnconve.nmempres,1,20),20,' ')
                                  ||to_char(rw_gnconve.cddbanco,'fm000')
                                  ||RPAD(substr(rw_gnconve.nmrescop,1,20),20,' ')
                                  ||vr_dtmvtolt
                                  ||to_char(vr_nrseqarq,'fm000000')
                                  ||LPAD(rw_gnconve.nrlayout,2,'0')
                                  ||'DEBITO AUTOMATICO'
                                  ||RPAD(' ',52,' ')
                                  ||CHR(10));          
            
            -- Atualizar as Flags
            vr_flgfirst := FALSE;
          END IF;
          
          -- Enviar registro para o Arquivo 
          gene0002.pc_escreve_xml(vr_clobarqu
                                 ,vr_txtoarqu
                                 ,'J'
                                ||to_char(rw_gnarqrx.nrsequen,'fm000000')
                                ||to_char(rw_gnarqrx.dtgerarq,'rrrr')
                                ||to_char(rw_gnarqrx.dtgerarq,'mm') 
                                ||to_char(rw_gnarqrx.dtgerarq,'dd')
                                ||to_char(rw_gnarqrx.qtregarq,'fm000000')
                                ||to_char((rw_gnarqrx.vltotarq  * 100),'fm00000000000000000')
                                ||to_char(rw_gnarqrx.dtmvtolt,'rrrr')
                                ||to_char(rw_gnarqrx.dtmvtolt,'mm') 
                                ||to_char(rw_gnarqrx.dtmvtolt,'dd')
                                ||RPAD(' ',104,' ')
                                ||CHR(10));              
          -- Atualizar o registro como retornado 
          BEGIN 
            UPDATE gnarqrx
               SET flgretor = 1 -- TRUE 
             WHERE rowid = rw_gnarqrx.nrrowid;
          EXCEPTION
            WHEN OTHERS THEN 
              vr_dscritic := 'Erro na atualizacao da tabela gnarqrx --> '||sqlerrm;
              RAISE vr_excsaida;
          END;
          
          -- Incrementar o contador 
          vr_nrseqret := vr_nrseqret + 1;
        END LOOP;
      END IF;
      
      -- Ao final, se foi gerada alguma informação 
      IF NOT vr_flgfirst THEN 
        
        -- Acumular totais para envio ao arquivo 
        vr_tot_vltarifa := vr_nrseqdig * rw_gnconve.vltrfdeb;
        vr_tot_vlapagar := vr_tot_vlfatura - vr_tot_vltarifa;
        vr_nrseqtot := vr_nrseqdig + vr_nrseqndb + vr_nrseqret;
        vr_vltotarq := vr_tot_vlfatura + vr_vlfatndb;
        
        -- Enviar trailler para o arquivo 
        gene0002.pc_escreve_xml(vr_clobarqu
                               ,vr_txtoarqu
                               ,'Z'
                              ||to_char(vr_nrseqtot+2,'fm000000')
                              ||to_char((vr_vltotarq*100),'fm00000000000000000')
                              ||RPAD(' ',126,' ')
                              ||CHR(10)
                              ,true);        
        
        -- Chamar geração do arquivo 
        GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper          --> Cooperativa conectada
                                           ,pr_cdprogra  => vr_cdprogra          --> Programa chamador
                                           ,pr_dtmvtolt  => rw_crapdat.dtmvtolt  --> Data do movimento atual
                                           ,pr_dsxml     => vr_clobarqu          --> Arquivo XML de dados
                                           ,pr_dsarqsaid => vr_camicop||'/'||vr_nmarqped --> Path/Nome do arquivo PDF gerado
                                           ,pr_flg_impri => 'N'                  --> Chamar a impressão (Imprim.p)
                                           ,pr_flg_gerar => 'S'                  --> Gerar o arquivo na hora
                                           ,pr_nmformul  => '234dh'              --> Nome do formulário para impressão
                                           ,pr_des_erro  => vr_dscritic);        --> Retorno de Erro
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clobarqu);
        dbms_lob.freetemporary(vr_clobarqu);

        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_excsaida;
        END IF;
        
        -- Somente se houver informações no CLOB de relatório
        IF vr_flgrelat THEN
          
          -- Envio das informações para a ultima página
          gene0002.pc_escreve_xml(vr_clobrela
                                 ,vr_txtorela
                                 , '</lcts>'
                                 ||'<totais>'
                                 || ' <nrseqdig>'||to_char(vr_nrseqdig,'fm999G999G999G999G990')||'</nrseqdig>'
                                 || ' <tot_vlfatura>'||to_char(vr_tot_vlfatura,'fm999G999G999G999G990d00')||'</tot_vlfatura>'
                                 || ' <tot_vltarifa>'||to_char(vr_tot_vltarifa,'fm999G999G999G999G990d00')||'</tot_vltarifa>'
                                 || ' <tot_vlapagar>'||to_char(vr_tot_vlapagar,'fm999G999G999G999G990d00')||'</tot_vlapagar>'
                                 || ' <nmciddat>'||vr_nmciddat||'</nmciddat>'
                                 || ' <nmcidade>'||vr_nmcidade||'</nmcidade>'
                                 || ' <nmextcop>'||rw_crapcop.nmextcop||'</nmextcop>'
                                 ||'</totais>');
          -- Encerrar a tag raiz
          gene0002.pc_escreve_xml(vr_clobrela
                                 ,vr_txtorela
                                 , '</crrl350>'
                                 ,true);        
          
          -- Solicitar o relatório 
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_clobrela         --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl350/lcts/lcto'          --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl350.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                --> Sem parametros
                                     ,pr_dsarqsaid => vr_camicop||'/rl/crrl350_c' || to_char(rw_gnconve.cdconven,'fm0000')||'.lst' --> Arquivo final
                                     ,pr_qtcoluna  => 80                  --> 132 colunas
                                     ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                     ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => '80d'            --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                   --> Número de cópias
                                     ,pr_flg_gerar => 'N'                 --> gerar na hora 
                                     ,pr_des_erro  => vr_dscritic);       --> Saída com erro

          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_clobrela);
          dbms_lob.freetemporary(vr_clobrela);

          -- TEstar saida do relatorio
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar excecao
            raise vr_excsaida;
          END IF;
        END IF;  
      
        -- Chamar a atualização do Controle e Devolução as Empresas 
        pc_atualiza_controle(rw_gnconve
                            ,vr_nrseqarq
                            ,vr_camicop
                            ,vr_nmarqped
                            ,vr_nmarqdat
                            ,vr_dtmvtopr
                            ,vr_nrseqdig
                            ,vr_cdconven
                            ,vr_tot_vlfatura
                            ,vr_tot_vltarifa
                            ,vr_tot_vlapagar
                            ,vr_cdcritic
                            ,vr_dscritic);
        -- Testar retorno de problema
        IF vr_cdcritic <> 0 AND vr_dscritic IS NOT NULL THEN 
          RAISE vr_excsaida;
        END IF;
      END IF;
      -- Commit a cada convênio 
      commit;      
    END LOOP; -- Loop convênios 
    
    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informações atualizadas
    COMMIT;

  EXCEPTION
    WHEN vr_excfimpr THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
     
    WHEN vr_excsaida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
End pc_crps388_RRC;

begin

  dbms_output.put_line('Inicio...');

--  for creg in (select * from crapcop a where a.cdcooper in (1)) loop
    dbms_output.put_line('Processando coop=1');
     pc_crps388_RRC(pr_cdcooper => 1, 
                       pr_flgresta => 0, 
                       pr_stprogra => pr_stprogra, 
                       pr_infimsol => pr_infimsol, 
                       pr_cdcritic => pr_cdcritic, 
                       pr_dscritic => pr_dscritic);
     if pr_cdcritic <> 0 or pr_dscritic is not null then
       dbms_output.put_line('Cooper=1'||' com erro: '||pr_cdcritic||'/'||pr_dscritic);
     end if;

  commit;
  
  dbms_output.put_line('Fim...');

end;
/
