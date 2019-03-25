CREATE OR REPLACE PROCEDURE CECRED.pc_crps249_1(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                               ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                               ,pr_nmestrut  IN craphis.nmestrut%TYPE --> Nome da tabela
                                               ,pr_cdhistor  IN craphis.cdhistor%TYPE --> Código do histórico
                                               ,pr_tpctbcxa  IN craphis.tpctbcxa%TYPE --> Tipo de conta
                                               ,pr_tpctbccu  IN craphis.tpctbccu%TYPE --> Tipo contábil centro de custo
                                               ,pr_vltarifa  IN crapthi.vltarifa%TYPE --> Tarifa do historico
                                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                               ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada

/* ..........................................................................

   Programa: pc_crps249_1 (antigo Fontes/crps249_1.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/98                         Ultima atualizacao: 01/09/2017

   Dados referentes ao programa:

   Frequencia: Diario. Exclusivo.
   Objetivo  : Atende a solicitacao 76.
               Gerar arquivo para contabilidade.
               Ordem do programa na solicitacao 1.

   Alteracoes: 13/06/2000 - Tratar a quantidade dos lancamentos (Odair)

               25/04/2001 - Tratar pac ate 99 (Edson).

               03/09/2001 - Nao contabilizar contratos de emprestimos
                            em PREJUIZO C/C (Edson).

               14/10/2003 - Inibicao da parte que trata o historico 270 (Julio)

               30/06/2005 - Alimentado campo cdcooper da tabela craprej (Diego).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               22/03/2006 - Contabilizar qdo linha de credito nao creditar
                            em conta corrente - historico 699(Mirtes)

               22/03/2006 - Contabilizar os historicos do Bancoob (Ze).

               04/12/2007 - Acerto para hist. do RDC para Conta Gerencial (Ze).

               09/06/2008 - Retirado historico 532(Mirtes)

               18/02/2011 - Tratamento para o historico 896 (Ze).

               01/09/2011 - Tratamento do histórico 98 e 277
                            Juros e Estorno sobre EMPREST X FINANC (Irlan)

               07/10/2011 - Tratamento no historico 99 - Trf. 42879 (Ze).

               26/10/2011 - Retirar crawepr.qtdialib para o hist. 99 -
                            Trf. 43206 (Ze).

               27/02/2013 - Conversão Progress >> Oracle PL/Sql (Daniel - Supero)

               18/02/2014 - Ajuste de PA de 2 para 3 digitos. (Gabriel)
               
               04/05/2015 - Ajustando a gravacao na CRAPREJ para separar
                            as informacoes em PF e PJ.
                            (Andre Santos - SUPERO)
                            
               22/05/2015 - Ajustar para contabilizar a cessão de cartão de crédito. (James)

               07/07/2015 - Ajustar para contabilizar a portabilidade de credito.
                            (Jaison/Diego - SD: 290027)

               07/01/2016 - Ajuste para verificar pr_cdhistor para contabilizar
                            portabilidade de credito. (Jaison/Diego - SD: 382779)

               03/04/2017 - Ajuste para segregar lançamentos em pessoa fisica e juridica
                            P307 - (Jonatas - Supero)	

               01/09/2017 - SD737681 - Ajustes nos históricos do projeto 307 - Marcos(Supero)

               20/12/2017 - Inclusão de novos históricos(2013,2014), Prj. 402 (Jean Michel)	

               25/08/2018 - Adicionado contabilização das operações de créditos dos borderôs de desconto de titulos
                            (Paulo Penteado GFT ) 
												  
               30/08/2018 - Correção bug não contabiliza histórico 2408
                             (Renato Cordeiro - AMCom)
............................................................................. */
  -- Cursor para verificar se tem empréstimo
  cursor cr_crapepr (pr_cdcooper in crapepr.cdcooper%type,
                     pr_nrdconta in crapepr.nrdconta%type,
                     pr_nrdocmto in crapepr.nrctremp%type) is
    select crapepr.cdfinemp,
           crapepr.cdlcremp,
           decode(crapepr.tpemprst,0,'TR',1,'PP',2,'POS','') tpemprst     --Tipo do emprestimo 0 - TR e 1 - PP
      from crapepr
     where crapepr.cdcooper = pr_cdcooper
       and crapepr.nrdconta = pr_nrdconta
       and crapepr.nrctremp = pr_nrdocmto;
  rw_crapepr    cr_crapepr%rowtype;
  -- Cursor para verificar o tipo de finalidade de crédito
  cursor cr_crapfin (pr_cdcooper in crapfin.cdcooper%type,
                     pr_cdfinemp in crapfin.cdfinemp%type) is
    select crapfin.tpfinali
      from crapfin
     where crapfin.cdcooper = pr_cdcooper
       and crapfin.cdfinemp = pr_cdfinemp;
  rw_crapfin    cr_crapfin%rowtype;
  -- Cursor para verificar se tem linha de crédito
  cursor cr_craplcr (pr_cdcooper in craplcr.cdcooper%type,
                     pr_cdlcremp in craplcr.cdlcremp%type) is
    select craplcr.flgcrcta,
           craplcr.dsoperac,
           craplcr.cdhistor,
           craplcr.dsorgrec,  
           craplcr.cdusolcr
      from craplcr
     where craplcr.cdcooper = pr_cdcooper
       and craplcr.cdlcremp = pr_cdlcremp;
  rw_craplcr    cr_craplcr%rowtype;
  -- Cursor para verificar se tem cadastro auxiliar de empréstimo
  cursor cr_crawepr (pr_cdcooper in crawepr.cdcooper%type,
                     pr_nrdconta in crawepr.nrdconta%type,
                     pr_nrdocmto in crawepr.nrctremp%type) is
    select 1
      from crawepr
     where crawepr.cdcooper = pr_cdcooper
       and crawepr.nrdconta = pr_nrdconta
       and crawepr.nrctremp = pr_nrdocmto;
  rw_crawepr    cr_crawepr%rowtype;
  -- Cursor para obter o maior PA
  cursor cr_crapage (pr_cdcooper in crapage.cdcooper%type) is
    select max(cdagenci)
      from crapage
     where crapage.cdcooper = pr_cdcooper;
  -- Variável para armazenar o nome do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Variáveis para criação de cursor dinâmico
  vr_num_cursor    number;
  vr_num_retor     number;
  vr_cursor        varchar2(32000);
  -- Variáveis para retorno do cursor dinâmico
  vr_cdagenci      craplct.cdagenci%type;
  vr_cdbccxlt      craplct.cdbccxlt%type;
  vr_nrdolote      craplct.nrdolote%type;
  vr_nrdconta      craplct.nrdconta%type;
  vr_nrdocmto      craplct.nrdocmto%type;
  vr_vllanmto      craplct.vllanmto%type;
  vr_ass_cdagenci  crapass.cdagenci%type;
  vr_inpessoa      crapass.inpessoa%type;
  vr_nrmaxpas      crapass.cdagenci%type;
  vr_dtrefere      craprej.dtrefere%type;
  vr_nrctremp      craplem.nrctremp%type;
  vr_cdhistor      craphis.cdhistor%TYPE;
  vr_nmcolsql      VARCHAR2(100);
  -- Variável lógica que define se credita em conta corrente
  vr_flgcrcta      boolean;
  vr_cdhistor_tdb      VARCHAR2(4000);
  vr_ind_microcred     varchar2(100);
  vr_ind_microcred_999 varchar2(100); 
  
  /* Registro para acumular os valores por agência */
  type typ_agencia is record (vr_vlccuage      craprej.vllanmto%type,
                              vr_vlcxaage      craprej.vllanmto%type,
                              vr_qtccuage      craprej.nrseqdig%type,
                              vr_qtcxaage      craprej.nrseqdig%type,                              
                              vr_vlccagpf      craprej.vllanmto%type,
                              vr_vlcxagpf      craprej.vllanmto%type,
                              vr_qtccagpf      craprej.nrseqdig%type,
                              vr_qtcxagpf      craprej.nrseqdig%type,
                              vr_vlccagpj      craprej.vllanmto%type,
                              vr_vlcxagpj      craprej.vllanmto%type,
                              vr_qtccagpj      craprej.nrseqdig%type,
                              vr_qtcxagpj      craprej.nrseqdig%type,                              
                              vr_vlccuage_499  craprej.vllanmto%type,
                              vr_vlcxaage_499  craprej.vllanmto%type,
                              vr_qtccuage_499  craprej.nrseqdig%type,
                              vr_qtcxaage_499  craprej.nrseqdig%TYPE,
                              vr_vlccagpf_499  craprej.vllanmto%type,
                              vr_vlcxagpf_499  craprej.vllanmto%type,
                              vr_qtccagpf_499  craprej.nrseqdig%type,
                              vr_qtcxagpf_499  craprej.nrseqdig%TYPE,
                              vr_vlccagpj_499  craprej.vllanmto%type,
                              vr_vlcxagpj_499  craprej.vllanmto%type,
                              vr_qtccagpj_499  craprej.nrseqdig%type,
                              vr_qtcxagpj_499  craprej.nrseqdig%TYPE);                              
  /* Tabela onde serão armazenados os registros da agência */
  /* O índice da tabela será o código da agência. O índice 99 se refere ao total das agências */
  type typ_tab_agencia is table of typ_agencia index by binary_integer;
  /* Instância da tabela */
  vr_tab_agencia   typ_tab_agencia;
  -- Índice para leitura das informações da tabela
  vr_indice_agencia  number(10);
  
  /* Registro os historicos que nao creditam em conta */
  type typ_agencia_hist_no is record (vr_vlccuage_no   craprej.vllanmto%TYPE,
                                      vr_vlcxaage_no   craprej.vllanmto%TYPE,
                                      vr_qtccuage_no   craprej.nrseqdig%TYPE,
                                      vr_qtcxaage_no   craprej.nrseqdig%TYPE,                              
                                      vr_vlccagpf_no   craprej.vllanmto%TYPE,
                                      vr_vlcxagpf_no   craprej.vllanmto%TYPE,
                                      vr_qtccagpf_no   craprej.nrseqdig%TYPE,
                                      vr_qtcxagpf_no   craprej.nrseqdig%TYPE,
                                      vr_vlccagpj_no   craprej.vllanmto%TYPE,
                                      vr_vlcxagpj_no   craprej.vllanmto%TYPE,
                                      vr_qtccagpj_no   craprej.nrseqdig%TYPE,
                                      vr_qtcxagpj_no   craprej.nrseqdig%TYPE);
                                   
  type typ_tab_agencia_hist_no is table of typ_agencia_hist_no index by VARCHAR2(10);
  /* Instância da tabela */
  vr_tab_agencia_hist_no   typ_tab_agencia_hist_no;
  
  
  type typ_agencia_microcredito is record (vr_cdagenci craprej.cdagenci%type,
                                           vr_cdhistor craprej.cdhistor%type,
                                           vr_dshistor craprej.dshistor%type,
                                           vr_vlccuage craprej.vllanmto%type,
                                           vr_qtccuage craprej.nrseqdig%type,
                                           vr_vlccagpf craprej.vllanmto%type,
                                           vr_qtccagpf craprej.nrseqdig%type,
                                           vr_vlccagpj craprej.vllanmto%type,
                                           vr_qtccagpj craprej.nrseqdig%type);                              
  /* Tabela onde serão armazenados os registros da agência */
  /* O índice da tabela será o código do histórico + código da agência + tipo do empréstimo (TR ou PP) + Origem de Recursos (DIM, PNMPO DIM, PNMPO BRDE,etc).*/
  type typ_tab_age_microcredito is table of typ_agencia_microcredito index by varchar2(100);
  /* Instância da tabela */
  vr_tab_age_microcredito   typ_tab_age_microcredito;  
  
  -- Índice para leitura das informações da tabela
  vr_indice_agencia_hist_no      VARCHAR(10);
  vr_indice_agencia_hist_no_999  VARCHAR(10);
  vr_indice_agencia_hist_no_lem  VARCHAR(10);
  vr_indice_agencia_hist_no_ass  VARCHAR(10);
  
  --
  /* Procedimento para inicialização da PL/Table de agência ao criar novo
     registro, garantindo que os campos terão valor zero, e não nulo. */
  procedure pc_cria_agencia_pltable (pr_agencia in crapage.cdagenci%type) is
  BEGIN
    -- Se o registro de memória para a agencia ainda não existe
    if not vr_tab_agencia.exists(pr_agencia) then
      vr_tab_agencia(pr_agencia).vr_vlccuage      := 0;
      vr_tab_agencia(pr_agencia).vr_vlcxaage      := 0;
      vr_tab_agencia(pr_agencia).vr_qtccuage      := 0;
      vr_tab_agencia(pr_agencia).vr_qtcxaage      := 0;      
      vr_tab_agencia(pr_agencia).vr_vlccuage_499  := 0;
      vr_tab_agencia(pr_agencia).vr_vlcxaage_499  := 0;
      vr_tab_agencia(pr_agencia).vr_qtccuage_499  := 0;
      vr_tab_agencia(pr_agencia).vr_qtcxaage_499  := 0;
      vr_tab_agencia(pr_agencia).vr_vlccagpf      := 0;
      vr_tab_agencia(pr_agencia).vr_vlcxagpf      := 0;
      vr_tab_agencia(pr_agencia).vr_qtccagpf      := 0;
      vr_tab_agencia(pr_agencia).vr_qtcxagpf      := 0;
      vr_tab_agencia(pr_agencia).vr_vlccagpf_499  := 0;
      vr_tab_agencia(pr_agencia).vr_vlcxagpf_499  := 0;
      vr_tab_agencia(pr_agencia).vr_qtccagpf_499  := 0;
      vr_tab_agencia(pr_agencia).vr_qtcxagpf_499  := 0;
      vr_tab_agencia(pr_agencia).vr_vlccagpj      := 0;
      vr_tab_agencia(pr_agencia).vr_vlcxagpj      := 0;
      vr_tab_agencia(pr_agencia).vr_qtccagpj      := 0;
      vr_tab_agencia(pr_agencia).vr_qtcxagpj      := 0;      
      vr_tab_agencia(pr_agencia).vr_vlccagpj_499  := 0;
      vr_tab_agencia(pr_agencia).vr_vlcxagpj_499  := 0;
      vr_tab_agencia(pr_agencia).vr_qtccagpj_499  := 0;
      vr_tab_agencia(pr_agencia).vr_qtcxagpj_499  := 0;      
    end if;
  end;
  
  procedure pc_cria_agencia_hist_no(pr_indice in VARCHAR2) is
  BEGIN
    -- Se o registro de memória para a agencia ainda não existe
    IF NOT vr_tab_agencia_hist_no.exists(pr_indice) THEN
      vr_tab_agencia_hist_no(pr_indice).vr_vlccuage_no := 0;
      vr_tab_agencia_hist_no(pr_indice).vr_qtccuage_no := 0;
      vr_tab_agencia_hist_no(pr_indice).vr_vlcxaage_no := 0;
      vr_tab_agencia_hist_no(pr_indice).vr_qtcxaage_no := 0;
      vr_tab_agencia_hist_no(pr_indice).vr_vlccagpf_no := 0;
      vr_tab_agencia_hist_no(pr_indice).vr_qtccagpf_no := 0;
      vr_tab_agencia_hist_no(pr_indice).vr_vlcxagpf_no := 0;
      vr_tab_agencia_hist_no(pr_indice).vr_qtcxagpf_no := 0;
      vr_tab_agencia_hist_no(pr_indice).vr_vlccagpj_no := 0;
      vr_tab_agencia_hist_no(pr_indice).vr_qtccagpj_no := 0;
      vr_tab_agencia_hist_no(pr_indice).vr_vlcxagpj_no := 0;
      vr_tab_agencia_hist_no(pr_indice).vr_qtcxagpj_no := 0;
    END IF;
  end;
  
  procedure pc_cria_age_microcredito (pr_chave in varchar2) is
  BEGIN
    -- Se o registro de memória para a agencia ainda não existe
    if not vr_tab_age_microcredito.exists(pr_chave) then
      vr_tab_age_microcredito(pr_chave).vr_vlccuage      := 0;
      vr_tab_age_microcredito(pr_chave).vr_qtccuage      := 0;
      vr_tab_age_microcredito(pr_chave).vr_vlccagpf      := 0;
      vr_tab_age_microcredito(pr_chave).vr_qtccagpf      := 0;
      vr_tab_age_microcredito(pr_chave).vr_vlccagpj      := 0;
      vr_tab_age_microcredito(pr_chave).vr_qtccagpj      := 0;
    end if;
  end;
  
  
  --
  /* Procedimento para validar as regras de negócio e criar
  os registro na tabela CRAPREJ */
  PROCEDURE pc_cria_craprej(pr_cdhistor craphis.cdhistor%TYPE,
                            pr_dtrefere craprej.dtrefere%TYPE) IS

    vr_ind_age_microcred VARCHAR2(100);
  
  BEGIN

    IF vr_tab_agencia.exists(999) AND vr_tab_agencia(999).vr_vlccuage > 0 THEN

      IF pr_tpctbcxa IN (2,3) THEN  /* Detalhamento por agencia */
        FOR vr_aux_contador IN 1..vr_nrmaxpas LOOP
          IF vr_tab_agencia.EXISTS(vr_aux_contador) THEN
            IF vr_tab_agencia(vr_aux_contador).vr_vlcxaage > 0 THEN
              -- Tipo de aplicacao 0 - Totalizador separado por agencia
              INSERT INTO craprej(cdpesqbb
                                 ,cdagenci
                                 ,cdhistor
                                 ,dtmvtolt
                                 ,vllanmto
                                 ,nrseqdig
                                 ,dtrefere
                                 ,cdcooper
                                 ,nraplica
                                 ,vlsdapli)
                           VALUES(vr_cdprogra
                                 ,vr_aux_contador
                                 ,pr_cdhistor
                                 ,pr_dtmvtolt
                                 ,vr_tab_agencia(vr_aux_contador).vr_vlcxaage
                                 ,vr_tab_agencia(vr_aux_contador).vr_qtcxaage
                                 ,pr_dtrefere
                                 ,pr_cdcooper
                                 ,0 --> Tipo de totalizador
                                 ,0.00); --> Valor para totalizador
              -- Tipo de aplicacao 1 - Totalizador de pessoa fisica separado por agencia
              INSERT INTO craprej(cdpesqbb
                                 ,cdagenci
                                 ,cdhistor
                                 ,dtmvtolt
                                 ,vllanmto
                                 ,nrseqdig
                                 ,dtrefere
                                 ,cdcooper
                                 ,nraplica
                                 ,vlsdapli)
                           VALUES(vr_cdprogra
                                 ,vr_aux_contador
                                 ,pr_cdhistor
                                 ,pr_dtmvtolt
                                 ,vr_tab_agencia(vr_aux_contador).vr_vlcxaage
                                 ,vr_tab_agencia(vr_aux_contador).vr_qtcxaage
                                 ,pr_dtrefere
                                 ,pr_cdcooper
                                 ,1 ---> Tipo de totalizador para pessoa fisica
                                 ,vr_tab_agencia(vr_aux_contador).vr_vlcxagpf);
              -- Tipo de aplicacao 2 - Totalizador de pessoa juridica separado por agencia
              INSERT INTO craprej(cdpesqbb
                                 ,cdagenci
                                 ,cdhistor
                                 ,dtmvtolt
                                 ,vllanmto
                                 ,nrseqdig
                                 ,dtrefere
                                 ,cdcooper
                                 ,nraplica
                                 ,vlsdapli)
                           VALUES(vr_cdprogra
                                 ,vr_aux_contador
                                 ,pr_cdhistor
                                 ,pr_dtmvtolt
                                 ,vr_tab_agencia(vr_aux_contador).vr_vlcxaage
                                 ,vr_tab_agencia(vr_aux_contador).vr_qtcxaage
                                 ,pr_dtrefere
                                 ,pr_cdcooper
                                 ,2 --> Tipo de totalizador para pessoa juridica
                                 ,vr_tab_agencia(vr_aux_contador).vr_vlcxagpj);
            END IF;
          END IF;
        END LOOP;
      END IF;

      /* Detalhamento por centro de custo ou por tarifas  */
      IF pr_tpctbccu = 1 OR pr_vltarifa > 0 THEN
        /* tratamento por agencia e tarifa */
        /* por tarifas para nao criar registro duplicado no tipo caixa) */
        FOR vr_aux_contador IN 1..998 LOOP
          IF vr_tab_agencia.EXISTS(vr_aux_contador) THEN
            IF vr_tab_agencia(vr_aux_contador).vr_vlccuage > 0 THEN
              -- Tipo de aplicacao 0 - Totalizador separado por agencia
              INSERT INTO craprej(cdpesqbb
                                 ,cdagenci
                                 ,cdhistor
                                 ,dtmvtolt
                                 ,vllanmto
                                 ,nrseqdig
                                 ,dtrefere
                                 ,cdcooper
                                 ,nraplica
                                 ,vlsdapli)
                           VALUES(vr_cdprogra
                                 ,vr_aux_contador
                                 ,pr_cdhistor /*{2}*/
                                 ,pr_dtmvtolt
                                 ,vr_tab_agencia(vr_aux_contador).vr_vlccuage
                                 ,vr_tab_agencia(vr_aux_contador).vr_qtccuage
                                 ,pr_dtrefere
                                 ,pr_cdcooper
                                 ,0       --> Tipo de totalizador
                                 ,0.00);  --> Valor para totalizador
              -- Tipo de aplicacao 1 - Totalizador de pessoa fisica separado por agencia
              INSERT INTO craprej(cdpesqbb
                                 ,cdagenci
                                 ,cdhistor
                                 ,dtmvtolt
                                 ,vllanmto
                                 ,nrseqdig
                                 ,dtrefere
                                 ,cdcooper
                                 ,nraplica
                                 ,vlsdapli)
                           VALUES(vr_cdprogra
                                 ,vr_aux_contador
                                 ,pr_cdhistor /*{2}*/
                                 ,pr_dtmvtolt
                                 ,vr_tab_agencia(vr_aux_contador).vr_vlccuage
                                 ,vr_tab_agencia(vr_aux_contador).vr_qtccuage
                                 ,pr_dtrefere
                                 ,pr_cdcooper
                                 ,1 --> Tipo de totalizador para pessoa fisica
                                 ,vr_tab_agencia(vr_aux_contador).vr_vlccagpf);  --> Valor para totalizador
              -- Tipo de aplicacao 2 - Totalizador de pessoa juridica separado por agencia
              INSERT INTO craprej(cdpesqbb
                                 ,cdagenci
                                 ,cdhistor
                                 ,dtmvtolt
                                 ,vllanmto
                                 ,nrseqdig
                                 ,dtrefere
                                 ,cdcooper
                                 ,nraplica
                                 ,vlsdapli)
                           VALUES(vr_cdprogra
                                 ,vr_aux_contador
                                 ,pr_cdhistor /*{2}*/
                                 ,pr_dtmvtolt
                                 ,vr_tab_agencia(vr_aux_contador).vr_vlccuage
                                 ,vr_tab_agencia(vr_aux_contador).vr_qtccuage
                                 ,pr_dtrefere
                                 ,pr_cdcooper
                                 ,2       --> Tipo de totalizador para pessoa juridica
                                 ,vr_tab_agencia(vr_aux_contador).vr_vlccagpj);  --> Valor para totalizador
            END IF;
          END IF;
        END LOOP;
      END IF;

      -- Se o tipo da conta for 2-PAC DB ou 3-PAC CR
      IF pr_tpctbcxa NOT IN (2,3) THEN
        -- Tipo de aplicacao 0 - Totalizador separado por agencia
        INSERT INTO craprej(cdpesqbb
                           ,cdagenci
                           ,cdhistor
                           ,dtmvtolt
                           ,vllanmto
                           ,nrseqdig
                           ,dtrefere
                           ,cdcooper
                           ,nraplica
                           ,vlsdapli)
                     VALUES(vr_cdprogra
                           ,0
                           ,pr_cdhistor /*{2}*/
                           ,pr_dtmvtolt
                           ,vr_tab_agencia(999).vr_vlccuage
                           ,vr_tab_agencia(999).vr_qtccuage
                           ,pr_dtrefere
                           ,pr_cdcooper
                           ,0      --> Tipo de totalizador
                           ,0.00); --> Valor para totalizador
        -- Tipo de aplicacao 1 - Totalizador de pessoa fisica separado por agencia
        INSERT INTO craprej(cdpesqbb
                           ,cdagenci
                           ,cdhistor
                           ,dtmvtolt
                           ,vllanmto
                           ,nrseqdig
                           ,dtrefere
                           ,cdcooper
                           ,nraplica
                           ,vlsdapli)
                     VALUES(vr_cdprogra
                           ,0
                           ,pr_cdhistor /*{2}*/
                           ,pr_dtmvtolt
                           ,vr_tab_agencia(999).vr_vlccuage
                           ,vr_tab_agencia(999).vr_qtccuage
                           ,pr_dtrefere
                           ,pr_cdcooper
                           ,1      --> Tipo de totalizador para pessoa fisica
                           ,vr_tab_agencia(999).vr_vlccagpf); --> Valor para totalizador
        -- Tipo de aplicacao 2 - Totalizador de pessoa juridica separado por agencia
        INSERT INTO craprej(cdpesqbb
                           ,cdagenci
                           ,cdhistor
                           ,dtmvtolt
                           ,vllanmto
                           ,nrseqdig
                           ,dtrefere
                           ,cdcooper
                           ,nraplica
                           ,vlsdapli)
                     VALUES(vr_cdprogra
                           ,0
                           ,pr_cdhistor /*{2}*/
                           ,pr_dtmvtolt
                           ,vr_tab_agencia(999).vr_vlccuage
                           ,vr_tab_agencia(999).vr_qtccuage
                           ,pr_dtrefere
                           ,pr_cdcooper
                           ,2      --> Tipo de totalizador para pessoa juridica
                           ,vr_tab_agencia(999).vr_vlccagpj); --> Valor para totalizador

        IF pr_cdhistor = 896 THEN  -- DEBITO JUROS UTIL CARD
          -- Percorrer as agencias
          FOR vr_aux_contador IN 1..vr_nrmaxpas LOOP
            IF vr_tab_agencia.EXISTS(vr_aux_contador) THEN
              IF vr_tab_agencia(vr_aux_contador).vr_vlcxaage > 0 THEN
                -- Tipo de aplicacao 0 - Totalizador separado por agencia
                INSERT INTO craprej(cdpesqbb
                                   ,cdagenci
                                   ,cdhistor
                                   ,dtmvtolt
                                   ,vllanmto
                                   ,nrseqdig
                                   ,dtrefere
                                   ,cdcooper
                                   ,nraplica
                                   ,vlsdapli)
                             VALUES(vr_cdprogra
                                   ,vr_aux_contador
                                   ,pr_cdhistor /*{2}*/
                                   ,pr_dtmvtolt
                                   ,vr_tab_agencia(vr_aux_contador).vr_vlcxaage
                                   ,vr_tab_agencia(vr_aux_contador).vr_qtcxaage
                                   ,pr_dtrefere
                                   ,pr_cdcooper
                                   ,0      --> Tipo de totalizador
                                   ,0.00); --> Valor para totalizador
                -- Tipo de aplicacao 1 - Totalizador de pessoa fisica separado por agencia
                INSERT INTO craprej(cdpesqbb
                                   ,cdagenci
                                   ,cdhistor
                                   ,dtmvtolt
                                   ,vllanmto
                                   ,nrseqdig
                                   ,dtrefere
                                   ,cdcooper
                                   ,nraplica
                                   ,vlsdapli)
                             VALUES(vr_cdprogra
                                   ,vr_aux_contador
                                   ,pr_cdhistor /*{2}*/
                                   ,pr_dtmvtolt
                                   ,vr_tab_agencia(vr_aux_contador).vr_vlcxaage
                                   ,vr_tab_agencia(vr_aux_contador).vr_qtcxaage
                                   ,pr_dtrefere
                                   ,pr_cdcooper
                                   ,1 --> Tipo de totalizador para pessoa fisica
                                   ,vr_tab_agencia(vr_aux_contador).vr_vlcxagpf); --> Valor para totalizador
                -- Tipo de aplicacao 2 - Totalizador de pessoa juridica separado por agencia
                INSERT INTO craprej(cdpesqbb
                                   ,cdagenci
                                   ,cdhistor
                                   ,dtmvtolt
                                   ,vllanmto
                                   ,nrseqdig
                                   ,dtrefere
                                   ,cdcooper
                                   ,nraplica
                                   ,vlsdapli)
                             VALUES(vr_cdprogra
                                   ,vr_aux_contador
                                   ,pr_cdhistor /*{2}*/
                                   ,pr_dtmvtolt
                                   ,vr_tab_agencia(vr_aux_contador).vr_vlcxaage
                                   ,vr_tab_agencia(vr_aux_contador).vr_qtcxaage
                                   ,pr_dtrefere
                                   ,pr_cdcooper
                                   ,2 --> Tipo de totalizador para pessoa juridico
                                   ,vr_tab_agencia(vr_aux_contador).vr_vlcxagpj); --> Valor para totalizador
              END IF;
            END IF;
          END LOOP;
        END IF;
      END IF;
    END IF;
    
    
    vr_ind_age_microcred := vr_tab_age_microcredito.first;
    -- Percorre todas as agencias\históricos
    WHILE vr_ind_age_microcred IS NOT NULL LOOP
      
      IF vr_tab_age_microcredito(vr_ind_age_microcred).vr_vlccuage > 0 THEN
        -- Tipo de aplicacao 0 - Totalizador separado por agencia
        INSERT INTO craprej(cdpesqbb
                           ,cdagenci
                           ,cdhistor
                           ,dtmvtolt
                           ,vllanmto
                           ,nrseqdig
                           ,dtrefere
                           ,cdcooper
                           ,nraplica
                           ,vlsdapli
                           ,dshistor)
                     VALUES(vr_cdprogra
                           ,vr_tab_age_microcredito(vr_ind_age_microcred).vr_cdagenci
                           ,pr_cdhistor /*{2}*/
                           ,pr_dtmvtolt
                           ,vr_tab_age_microcredito(vr_ind_age_microcred).vr_vlccuage
                           ,vr_tab_age_microcredito(vr_ind_age_microcred).vr_qtccuage
                           ,pr_dtrefere
                           ,pr_cdcooper
                           ,0       --> Tipo de totalizador
                           ,0.00    --> Valor para totalizador
                           ,LTRIM(vr_tab_age_microcredito(vr_ind_age_microcred).vr_dshistor));

          -- Tipo de aplicacao 1 - Totalizador de pessoa fisica separado por agencia
        INSERT INTO craprej(cdpesqbb
                           ,cdagenci
                           ,cdhistor
                           ,dtmvtolt
                           ,vllanmto
                           ,nrseqdig
                           ,dtrefere
                           ,cdcooper
                           ,nraplica
                           ,vlsdapli
                           ,dshistor)
                     VALUES(vr_cdprogra
                           ,vr_tab_age_microcredito(vr_ind_age_microcred).vr_cdagenci
                           ,pr_cdhistor /*{2}*/
                           ,pr_dtmvtolt
                           ,vr_tab_age_microcredito(vr_ind_age_microcred).vr_vlccuage
                           ,vr_tab_age_microcredito(vr_ind_age_microcred).vr_qtccuage
                           ,pr_dtrefere
                           ,pr_cdcooper
                           ,1 --> Tipo de totalizador para pessoa fisica
                           ,vr_tab_age_microcredito(vr_ind_age_microcred).vr_vlccagpf --> Valor para totalizador
                           ,LTRIM(vr_tab_age_microcredito(vr_ind_age_microcred).vr_dshistor));  



        -- Tipo de aplicacao 2 - Totalizador de pessoa juridica separado por agencia
        INSERT INTO craprej(cdpesqbb
                           ,cdagenci
                           ,cdhistor
                           ,dtmvtolt
                           ,vllanmto
                           ,nrseqdig
                           ,dtrefere
                           ,cdcooper
                           ,nraplica
                           ,vlsdapli
                           ,dshistor)
                     VALUES(vr_cdprogra
                           ,vr_tab_age_microcredito(vr_ind_age_microcred).vr_cdagenci
                           ,pr_cdhistor /*{2}*/
                           ,pr_dtmvtolt
                           ,vr_tab_age_microcredito(vr_ind_age_microcred).vr_vlccuage
                           ,vr_tab_age_microcredito(vr_ind_age_microcred).vr_qtccuage
                           ,pr_dtrefere
                           ,pr_cdcooper
                           ,2       --> Tipo de totalizador para pessoa juridica
                           ,vr_tab_age_microcredito(vr_ind_age_microcred).vr_vlccagpj
                           ,LTRIM(vr_tab_age_microcredito(vr_ind_age_microcred).vr_dshistor));  --> Valor para totalizador
      END IF;

        
      vr_ind_age_microcred := vr_tab_age_microcredito.next(vr_ind_age_microcred);
    
    END LOOP;
    vr_tab_age_microcredito.DELETE;
    
  END pc_cria_craprej;

  --
BEGIN
  vr_cdprogra := 'CRPS249';  /* igual ao origem */

  -- Obter o maior PA
  OPEN cr_crapage(pr_cdcooper => pr_cdcooper);
  FETCH cr_crapage INTO vr_nrmaxpas;
  CLOSE cr_crapage;
  
  IF pr_nmestrut = 'CRAPLEM' THEN
    vr_nmcolsql := ' ,x.nrctremp ';    
  END IF;  

  IF pr_nmestrut = upper('CRAPLCM') AND pr_cdhistor IN (2093,2094,2090,2091,1072,1544,1713,1070,1542,1710,1510,1719,2372,2376,2364,2368) THEN
    vr_nmcolsql := ' ,trim(replace(x.cdpesqbb,''.'','''')) ';
  END IF;

  -- Lançamentos de operação de crédito do borderô de desconto de títulos
  IF upper(pr_nmestrut) = 'TBDSCT_LANCAMENTO_BORDERO'  THEN
    -- Garantir que somente os históricos da lista gerem o arquivo "_OPECRED". Quando esses históricos estiverem aqui na procedure 249_1, não
    -- precisa desses mesmos estarem no vetor vr_tab_craphis da procedure 249.
    vr_cdhistor_tdb := DSCT0003.vr_cdhistordsct_apropjurrem   ||','|| --2667   
                       DSCT0003.vr_cdhistordsct_apropjurmra   ||','|| --2668
                       DSCT0003.vr_cdhistordsct_apropjurmta   ||','|| --2669
                       PREJ0005.vr_cdhistordsct_principal     ||','|| --2754
                       PREJ0005.vr_cdhistordsct_juros_60_rem  ||','|| --2755
                       PREJ0005.vr_cdhistordsct_juros_60_mor  ||','|| --2761
                       PREJ0005.vr_cdhistordsct_juros_60_mul  ||','|| --2879
                       DSCT0003.vr_cdhistordsct_est_apro_multa||','|| --2880
                       DSCT0003.vr_cdhistordsct_est_apro_juros;       --2881
    
    vr_cursor :=   'SELECT ass.cdagenci '||
                   '      ,100 cdbccxlt '||
                   '      ,lcb.nrdconta '||
                   '      ,9999 nrdolote '||
                   '      ,lcb.nrdocmto '||
                   '      ,lcb.vllanmto '||
                   '      ,ass.cdagenci '||
                   '      ,ass.inpessoa '||
                   ' FROM  tbdsct_lancamento_bordero lcb '||
                   '      ,crapass ass '||
                   ' WHERE lcb.cdhistor IN ('||vr_cdhistor_tdb||') '||
                   '   AND lcb.cdcooper = '||pr_cdcooper||
                   '   AND lcb.cdhistor = '||pr_cdhistor||
                   '   AND lcb.dtmvtolt = to_date('''||to_char(pr_dtmvtolt, 'ddmmyyyy')||''', ''ddmmyyyy'')'||
                   '   AND ass.cdcooper = lcb.cdcooper '||
                   '   AND ass.nrdconta = lcb.nrdconta ';
  ELSIF upper(pr_nmestrut) = 'TBCC_PREJUIZO_DETALHE'  THEN
    vr_cursor :=   ' select c.cdagenci,  '||
                   '       100 cdbccxlt, '||
                   '       pd.nrdconta,   '|| 
                   '       9999 nrdolote,   '||
                   '       1  nrdocmto,   '||
                   '       pd.vllanmto,  '|| 
                   '       c.cdagenci,   '||
                   '       c.inpessoa    '||
                   ' from  tbcc_prejuizo_detalhe pd, '||
                   '     crapass  c '||
                   ' where  pd.cdcooper  = '||pr_cdcooper||
                   '  and   pd.cdhistor  = '||pr_cdhistor||
                   '  and   pd.cdcooper  = c.cdcooper '||
                   '  and    pd.nrdconta = c.nrdconta  '|| 
                   '  and   pd.dtmvtolt  = to_date('''||to_char(pr_dtmvtolt, 'ddmmyyyy')||''', ''ddmmyyyy'')';
  ELSE
    -- Define a query do cursor dinâmico
    vr_cursor := 'select x.cdagenci,'||
                       ' x.cdbccxlt,'||
                       ' x.nrdolote,'||
                       ' x.nrdconta,'||
                       ' x.nrdocmto,'||
                       ' x.vllanmto,'||
                       ' c.cdagenci,'||
                       ' c.inpessoa' || vr_nmcolsql ||
                  ' from crapass c, '||pr_nmestrut||' x'||
                 ' where x.cdcooper = '||pr_cdcooper||
                   ' and x.dtmvtolt = to_date('''||to_char(pr_dtmvtolt, 'ddmmyyyy')||''', ''ddmmyyyy'')'||
                   ' and x.cdhistor = '||pr_cdhistor||
                   ' and c.cdcooper = x.cdcooper'||
                   ' and c.nrdconta = x.nrdconta';
  END IF;
  -- Cria cursor dinâmico
  vr_num_cursor := dbms_sql.open_cursor;

  -- Comando Parse
  dbms_sql.parse(vr_num_cursor, vr_cursor, 1);
  -- Definindo Colunas de retorno
  dbms_sql.define_column(vr_num_cursor, 1, vr_cdagenci);
  dbms_sql.define_column(vr_num_cursor, 2, vr_cdbccxlt);
  dbms_sql.define_column(vr_num_cursor, 3, vr_nrdolote);
  dbms_sql.define_column(vr_num_cursor, 4, vr_nrdconta);
  dbms_sql.define_column(vr_num_cursor, 5, vr_nrdocmto);
  dbms_sql.define_column(vr_num_cursor, 6, vr_vllanmto);
  dbms_sql.define_column(vr_num_cursor, 7, vr_ass_cdagenci);
  dbms_sql.define_column(vr_num_cursor, 8, vr_inpessoa);
  
  IF upper(pr_nmestrut) = 'CRAPLEM' OR 
     (pr_nmestrut = upper('CRAPLCM') AND pr_cdhistor IN (2093,2094,2090,2091,1072,1544,1713,1070,1542,1710,1510,1719,2372,2376,2364,2368)) THEN
    dbms_sql.define_column(vr_num_cursor, 9, vr_nrctremp);
  END IF;
      
  -- Execução do select dinamico
  vr_num_retor := dbms_sql.execute(vr_num_cursor);
  -- Abre o cursor e começa a processar os registros
  pc_cria_agencia_pltable(999);
  loop
    -- Verifica se há alguma linha de retorno do cursor
    vr_num_retor := dbms_sql.fetch_rows(vr_num_cursor);
    if vr_num_retor = 0 THEN
      -- Se o cursor dinamico está aberto
      IF dbms_sql.is_open(vr_num_cursor) THEN
        -- Fecha o mesmo
        dbms_sql.close_cursor(vr_num_cursor);
      END if;
      exit;
    else
      -- Carrega variáveis com o retorno do cursor
      dbms_sql.column_value(vr_num_cursor, 1, vr_cdagenci);
      dbms_sql.column_value(vr_num_cursor, 2, vr_cdbccxlt);
      dbms_sql.column_value(vr_num_cursor, 3, vr_nrdolote);
      dbms_sql.column_value(vr_num_cursor, 4, vr_nrdconta);
      dbms_sql.column_value(vr_num_cursor, 5, vr_nrdocmto);
      dbms_sql.column_value(vr_num_cursor, 6, vr_vllanmto);
      dbms_sql.column_value(vr_num_cursor, 7, vr_ass_cdagenci);
      dbms_sql.column_value(vr_num_cursor, 8, vr_inpessoa);
      
      IF upper(pr_nmestrut) = 'CRAPLEM' OR 
        (pr_nmestrut = upper('CRAPLCM') AND pr_cdhistor IN (2093,2094,2090,2091,1072,1544,1713,1070,1542,1710,1510,1719,2372,2376,2364,2368)) THEN
        dbms_sql.column_value(vr_num_cursor, 9, vr_nrctremp);
      END IF;
      
      -- Inicializa variável de crédito em conta corrente
      vr_flgcrcta := true;
      --
      if upper(pr_nmestrut) = 'CRAPLEM' and pr_cdhistor in (99,1036,1059,2013,2014,2326,2327) then
        -- Verifica se tem empréstimo. Se não tiver, descarta.
        open cr_crapepr (pr_cdcooper,
                         vr_nrdconta,
                         vr_nrctremp);
          fetch cr_crapepr into rw_crapepr;
          if cr_crapepr%notfound THEN
            CLOSE cr_crapepr;
            continue;
          end if;
        close cr_crapepr;
        -- Descarta se for linha de crédito 100
        if rw_crapepr.cdlcremp = 100 then
          continue;
        end if;
        -- Verifica se a linha de crédito existe. Se não existe, descarta.
        open cr_craplcr (pr_cdcooper,
                         rw_crapepr.cdlcremp);
          fetch cr_craplcr into rw_craplcr;
          if cr_craplcr%notfound THEN
            CLOSE cr_craplcr;
            continue;
          end if;
        close cr_craplcr;
        -- Verifica se existe no cadastro auxiliar de empréstimo. Se não existe, descarta.
        open cr_crawepr (pr_cdcooper,
                         vr_nrdconta,
                         vr_nrctremp);
          fetch cr_crawepr into rw_crawepr;
          if cr_crawepr%notfound THEN
            CLOSE cr_crawepr;
            continue;
          end if;
        close cr_crawepr;
        -- Verifica se a finalidade existe, se sim verifica o tipo. Se não existe, descarta.
        open cr_crapfin (pr_cdcooper,
                         rw_crapepr.cdfinemp);
          fetch cr_crapfin into rw_crapfin;
          if cr_crapfin%notfound THEN
            CLOSE cr_crapfin;
            continue;
          else
            IF rw_crapfin.tpfinali = 2 THEN -- Portabilidade
              -- Seta a variável de crédito em conta corrente como falso para portabilidade.
              vr_flgcrcta := FALSE;
            ELSE
              -- Seta a variável de crédito em conta corrente de acordo com o cadastro da linha de crédito.
              vr_flgcrcta := (rw_craplcr.flgcrcta = 1);
            END IF;
          end if;
        close cr_crapfin;
      end if;
      --
      -- Criar os registros para a agencia
      pc_cria_agencia_pltable(vr_cdagenci);
      pc_cria_agencia_pltable(vr_ass_cdagenci);
      IF NOT vr_flgcrcta THEN
        -- Caso seja Portabilidade fixa o historico
        IF rw_crapfin.tpfinali = 2 THEN -- Portabilidade
          -- Seta a variável conforme o tipo da linha de crédito.
          IF pr_cdhistor = 1036 THEN
            vr_cdhistor := 1915; -- EMPRESTIMO
          ELSE
            vr_cdhistor := 1916; -- FINANCIAMENTO
          END IF;
        ELSE
          -- Seta a variável com o historico da linha de crédito.
          vr_cdhistor := rw_craplcr.cdhistor;
        END IF;
        -- Cria os Indices
        vr_indice_agencia_hist_no_999 := LPAD(999,5,0)||LPAD(vr_cdhistor,5,0);
        vr_indice_agencia_hist_no_lem := LPAD(vr_cdagenci,5,0)||LPAD(vr_cdhistor,5,0);
        vr_indice_agencia_hist_no_ass := LPAD(vr_ass_cdagenci,5,0)||LPAD(vr_cdhistor,5,0);
        -- Cria as tabelas temporarias
        pc_cria_agencia_hist_no(vr_indice_agencia_hist_no_999);
        pc_cria_agencia_hist_no(vr_indice_agencia_hist_no_lem);
        pc_cria_agencia_hist_no(vr_indice_agencia_hist_no_ass);
        -- Carrega a tabela temporaria      
        vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_999).vr_vlccuage_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_999).vr_vlccuage_no + vr_vllanmto;
        vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_999).vr_qtccuage_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_999).vr_qtccuage_no + 1;
        vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_lem).vr_vlcxaage_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_lem).vr_vlcxaage_no + vr_vllanmto;
        vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_lem).vr_qtcxaage_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_lem).vr_qtcxaage_no + 1;
        vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_ass).vr_vlccuage_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_ass).vr_vlccuage_no + vr_vllanmto;
        vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_ass).vr_qtccuage_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_ass).vr_qtccuage_no + 1;

        -- Segregando as informacoes por tipo de pessoa
        IF vr_inpessoa = 1 THEN
           vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_999).vr_vlccagpf_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_999).vr_vlccagpf_no + vr_vllanmto;
           vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_999).vr_qtccagpf_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_999).vr_qtccagpf_no + 1;           
           vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_lem).vr_vlcxagpf_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_lem).vr_vlcxagpf_no + vr_vllanmto;
           vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_lem).vr_qtcxagpf_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_lem).vr_qtcxagpf_no + 1;
           vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_ass).vr_vlccagpf_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_ass).vr_vlccagpf_no + vr_vllanmto;
           vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_ass).vr_qtccagpf_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_ass).vr_qtccagpf_no + 1;
        ELSE
           vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_999).vr_vlccagpj_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_999).vr_vlccagpf_no + vr_vllanmto;
           vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_999).vr_qtccagpj_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_999).vr_qtccagpf_no + 1;
           vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_lem).vr_vlcxagpj_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_lem).vr_vlcxagpj_no + vr_vllanmto;
           vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_lem).vr_qtcxagpj_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_lem).vr_qtcxagpj_no + 1;
           vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_ass).vr_vlccagpj_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_ass).vr_vlccagpj_no + vr_vllanmto;
           vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_ass).vr_qtccagpj_no := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no_ass).vr_qtccagpj_no + 1;
        END IF;

      ELSE
        -- Verifica a estrutura e se o historico for
        --  98 - JUROS EMPR. ou 277 - ESTORNO JUROS 08 1038 - JUROS REMUN.
        if upper(pr_nmestrut) = 'CRAPLEM' and pr_cdhistor in (98, 277, 1038, 2343, 2345) THEN
          -- Verifica se tem empréstimo. Se não tiver, descarta.
          open cr_crapepr (pr_cdcooper,
                           vr_nrdconta,
                           vr_nrctremp);
            fetch cr_crapepr into rw_crapepr;
            if cr_crapepr%notfound THEN
              CLOSE cr_crapepr;
              continue;
            end if;
          close cr_crapepr;
          -- Verifica se a linha de crédito existe. Se não existe, descarta.
          open cr_craplcr (pr_cdcooper,
                           rw_crapepr.cdlcremp);
            fetch cr_craplcr into rw_craplcr;
            if cr_craplcr%notfound THEN
              CLOSE cr_craplcr;
              CONTINUE;
            end if;
          close cr_craplcr;
          -- Separar juros de empréstimos e juros de financiamento
          IF rw_craplcr.dsoperac = 'FINANCIAMENTO' THEN
            
            IF rw_craplcr.cdusolcr = 1 AND rw_craplcr.dsorgrec <> ' ' THEN

              ---Agrupar valores na PL Table vr_tab_age_microcredito com index sendo a seguinte chave:
              vr_ind_microcred     := pr_cdhistor ||vr_ass_cdagenci || rw_crapepr.tpemprst || REPLACE(rw_craplcr.dsorgrec,'MICROCREDITO','');
              vr_ind_microcred_999 := pr_cdhistor ||'999'       || rw_crapepr.tpemprst || REPLACE(rw_craplcr.dsorgrec,'MICROCREDITO','');
              
              IF vr_tab_age_microcredito.exists(vr_ind_microcred_999) THEN
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccuage := vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccuage + vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccuage := vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccuage + 1;
              ELSE
                pc_cria_age_microcredito(vr_ind_microcred_999);
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_cdagenci := 0;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_cdhistor := pr_cdhistor;     
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccuage := vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccuage := 1;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_dshistor := REPLACE(rw_craplcr.dsorgrec, 'MICROCREDITO','');                           
              END IF;

              IF vr_tab_age_microcredito.exists(vr_ind_microcred) THEN
                vr_tab_age_microcredito(vr_ind_microcred).vr_vlccuage := vr_tab_age_microcredito(vr_ind_microcred).vr_vlccuage + vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred).vr_qtccuage := vr_tab_age_microcredito(vr_ind_microcred).vr_qtccuage + 1; 
              ELSE
                pc_cria_age_microcredito(vr_ind_microcred);
                vr_tab_age_microcredito(vr_ind_microcred).vr_cdhistor := pr_cdhistor;
                vr_tab_age_microcredito(vr_ind_microcred).vr_dshistor := REPLACE(rw_craplcr.dsorgrec, 'MICROCREDITO','');
                vr_tab_age_microcredito(vr_ind_microcred).vr_cdagenci := vr_ass_cdagenci;
                vr_tab_age_microcredito(vr_ind_microcred).vr_vlccuage := vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred).vr_qtccuage := 1; 
              END IF;                

                          
              -- Segregando as informacoes por tipo de pessoa
              IF vr_inpessoa = 1 THEN
                IF vr_tab_age_microcredito.exists(vr_ind_microcred_999) THEN
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpf := vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpf + vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpf := vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpf + 1;
                ELSE
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpf := vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpf := 1;
                END IF;
                
                IF vr_tab_age_microcredito.exists(vr_ind_microcred) THEN                
                  vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpf:= vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpf + vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpf:= vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpf + 1;
                ELSE
                  vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpf:= vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpf:= 1;
                END IF;

              ELSE

                IF vr_tab_age_microcredito.exists(vr_ind_microcred_999) THEN
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpj := vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpj + vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpj := vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpj + 1;
                ELSE
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpj := vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpj := 1;
                END IF;
                
                IF vr_tab_age_microcredito.exists(vr_ind_microcred) THEN                
                  vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpj := vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpj + vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpj := vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpj + 1;
                ELSE
                  vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpj:= vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpj:= 1;
                END IF;
                 
              END IF;

            ELSE

              ---Agrupar valores na PL Table vr_tab_age_microcredito com index sendo a seguinte chave:
              vr_ind_microcred     := pr_cdhistor ||vr_ass_cdagenci || 'OPERACAO_NORMAL';
              vr_ind_microcred_999 := pr_cdhistor ||'999'       || 'OPERACAO_NORMAL';
              
              IF vr_tab_age_microcredito.exists(vr_ind_microcred_999) THEN
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccuage := vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccuage + vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccuage := vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccuage + 1;
              ELSE
                pc_cria_age_microcredito(vr_ind_microcred_999);
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_cdagenci := 0;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_cdhistor := pr_cdhistor;     
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccuage := vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccuage := 1;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_dshistor := 'OPERACAO_NORMAL';                           
              END IF;

              IF vr_tab_age_microcredito.exists(vr_ind_microcred) THEN
                vr_tab_age_microcredito(vr_ind_microcred).vr_vlccuage := vr_tab_age_microcredito(vr_ind_microcred).vr_vlccuage + vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred).vr_qtccuage := vr_tab_age_microcredito(vr_ind_microcred).vr_qtccuage + 1; 
              ELSE
                pc_cria_age_microcredito(vr_ind_microcred);
                vr_tab_age_microcredito(vr_ind_microcred).vr_cdhistor := pr_cdhistor;
                vr_tab_age_microcredito(vr_ind_microcred).vr_dshistor := 'OPERACAO_NORMAL';
                vr_tab_age_microcredito(vr_ind_microcred).vr_cdagenci := vr_ass_cdagenci;
                vr_tab_age_microcredito(vr_ind_microcred).vr_vlccuage := vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred).vr_qtccuage := 1; 
              END IF;                

                          
              -- Segregando as informacoes por tipo de pessoa
              IF vr_inpessoa = 1 THEN
                IF vr_tab_age_microcredito.exists(vr_ind_microcred_999) THEN
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpf := vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpf + vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpf := vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpf + 1;
                ELSE
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpf := vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpf := 1;
                END IF;
                
                IF vr_tab_age_microcredito.exists(vr_ind_microcred) THEN                
                  vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpf:= vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpf + vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpf:= vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpf + 1;
                ELSE
                  vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpf:= vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpf:= 1;
                END IF;

              ELSE

                IF vr_tab_age_microcredito.exists(vr_ind_microcred_999) THEN
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpj := vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpj + vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpj := vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpj + 1;
                ELSE
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpj := vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpj := 1;
                END IF;
                
                IF vr_tab_age_microcredito.exists(vr_ind_microcred) THEN                
                  vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpj := vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpj + vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpj := vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpj + 1;
                ELSE
                  vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpj:= vr_vllanmto;
                  vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpj:= 1;
                END IF;
                 
              END IF;

              
            END IF;            

            vr_tab_agencia(999).vr_vlccuage_499 := vr_tab_agencia(999).vr_vlccuage_499 + vr_vllanmto;
            vr_tab_agencia(999).vr_qtccuage_499 := vr_tab_agencia(999).vr_qtccuage_499 + 1;
            vr_tab_agencia(vr_cdagenci).vr_vlcxaage_499 := vr_tab_agencia(vr_cdagenci).vr_vlcxaage_499 + vr_vllanmto;
            vr_tab_agencia(vr_cdagenci).vr_qtcxaage_499 := vr_tab_agencia(vr_cdagenci).vr_qtcxaage_499 + 1;
            vr_tab_agencia(vr_ass_cdagenci).vr_vlccuage_499 := vr_tab_agencia(vr_ass_cdagenci).vr_vlccuage_499 + vr_vllanmto;
            vr_tab_agencia(vr_ass_cdagenci).vr_qtccuage_499 := vr_tab_agencia(vr_ass_cdagenci).vr_qtccuage_499 + 1;
            
            -- Segregando as informacoes por tipo de pessoa
            IF vr_inpessoa = 1 THEN
               vr_tab_agencia(999).vr_vlccagpf_499 := vr_tab_agencia(999).vr_vlccagpf_499 + vr_vllanmto;
               vr_tab_agencia(999).vr_qtccagpf_499 := vr_tab_agencia(999).vr_qtccagpf_499 + 1;
               
               vr_tab_agencia(vr_cdagenci).vr_vlcxagpf_499 := vr_tab_agencia(vr_cdagenci).vr_vlcxagpf_499 + vr_vllanmto;
               vr_tab_agencia(vr_cdagenci).vr_qtcxagpf_499 := vr_tab_agencia(vr_cdagenci).vr_qtcxagpf_499 + 1;
               vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpf_499 := vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpf_499 + vr_vllanmto;
               vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpf_499 := vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpf_499 + 1;
            ELSE
               vr_tab_agencia(999).vr_vlccagpj_499 := vr_tab_agencia(999).vr_vlccagpj_499 + vr_vllanmto;
               vr_tab_agencia(999).vr_qtccagpj_499 := vr_tab_agencia(999).vr_qtccagpj_499 + 1;
               
               vr_tab_agencia(vr_cdagenci).vr_vlcxagpj_499 := vr_tab_agencia(vr_cdagenci).vr_vlcxagpj_499 + vr_vllanmto;
               vr_tab_agencia(vr_cdagenci).vr_qtcxagpj_499 := vr_tab_agencia(vr_cdagenci).vr_qtcxagpj_499 + 1;
               vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpj_499 := vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpj_499 + vr_vllanmto;
               vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpj_499 := vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpj_499 + 1;               
            END IF;
            
          ELSE /* Emprestimo */

            vr_tab_agencia(999).vr_vlccuage := vr_tab_agencia(999).vr_vlccuage + vr_vllanmto;
            vr_tab_agencia(999).vr_qtccuage := vr_tab_agencia(999).vr_qtccuage + 1;
            vr_tab_agencia(vr_cdagenci).vr_vlcxaage := vr_tab_agencia(vr_cdagenci).vr_vlcxaage + vr_vllanmto;
            vr_tab_agencia(vr_cdagenci).vr_qtcxaage := vr_tab_agencia(vr_cdagenci).vr_qtcxaage + 1;
            vr_tab_agencia(vr_ass_cdagenci).vr_vlccuage := vr_tab_agencia(vr_ass_cdagenci).vr_vlccuage + vr_vllanmto;
            vr_tab_agencia(vr_ass_cdagenci).vr_qtccuage := vr_tab_agencia(vr_ass_cdagenci).vr_qtccuage + 1;

            -- Segregando as informacoes por tipo de pessoa
            IF vr_inpessoa = 1 THEN
               vr_tab_agencia(999).vr_vlccagpf := vr_tab_agencia(999).vr_vlccagpf + vr_vllanmto;
               vr_tab_agencia(999).vr_qtccagpf := vr_tab_agencia(999).vr_qtccagpf + 1;

               vr_tab_agencia(vr_cdagenci).vr_vlcxagpf := vr_tab_agencia(vr_cdagenci).vr_vlcxagpf + vr_vllanmto;
               vr_tab_agencia(vr_cdagenci).vr_qtcxagpf := vr_tab_agencia(vr_cdagenci).vr_qtcxagpf + 1;
               vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpf := vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpf + vr_vllanmto;
               vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpf := vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpf + 1;
            ELSE
               vr_tab_agencia(999).vr_vlccagpj := vr_tab_agencia(999).vr_vlccagpj + vr_vllanmto;
               vr_tab_agencia(999).vr_qtccagpj := vr_tab_agencia(999).vr_qtccagpj + 1;

               vr_tab_agencia(vr_cdagenci).vr_vlcxagpj := vr_tab_agencia(vr_cdagenci).vr_vlcxagpj + vr_vllanmto;
               vr_tab_agencia(vr_cdagenci).vr_qtcxagpj := vr_tab_agencia(vr_cdagenci).vr_qtcxagpj + 1;
               vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpj := vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpj + vr_vllanmto;
               vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpj := vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpj + 1;
            END IF;

          END IF;
        ELSIF pr_cdhistor in (2093,2094,2090,2091,1072,1544,1713,1070,1542,1710,1510,1719,2372,2376,2364,2368) THEN
              
          -- Verifica se tem empréstimo. Se não tiver, descarta.
          open cr_crapepr (pr_cdcooper,
                           vr_nrdconta,
                           vr_nrctremp);
            fetch cr_crapepr into rw_crapepr;
            if cr_crapepr%notfound THEN
              CLOSE cr_crapepr;
              continue;
            end if;
          close cr_crapepr;
          
          -- Verifica se a linha de crédito existe. Se não existe, descarta.
          open cr_craplcr (pr_cdcooper,
                           rw_crapepr.cdlcremp);
            fetch cr_craplcr into rw_craplcr;
            if cr_craplcr%notfound THEN
              CLOSE cr_craplcr;
              CONTINUE;
            end if;
          close cr_craplcr;
          
          -- Separar juros de empréstimos e juros de financiamento
          IF rw_craplcr.dsoperac = 'FINANCIAMENTO' AND rw_craplcr.cdusolcr = 1 AND rw_craplcr.dsorgrec <> ' ' THEN
          
            ---Agrupar valores na PL Table vr_tab_age_microcredito com index sendo a seguinte chave:
            vr_ind_microcred     := pr_cdhistor ||vr_cdagenci || rw_crapepr.tpemprst || REPLACE(rw_craplcr.dsorgrec,'MICROCREDITO','');
            vr_ind_microcred_999 := pr_cdhistor ||'999'       || rw_crapepr.tpemprst || REPLACE(rw_craplcr.dsorgrec,'MICROCREDITO','');
              
            IF vr_tab_age_microcredito.exists(vr_ind_microcred_999) THEN
              vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccuage := vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccuage + vr_vllanmto;
              vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccuage := vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccuage + 1;
            ELSE
              pc_cria_age_microcredito(vr_ind_microcred_999);
              vr_tab_age_microcredito(vr_ind_microcred_999).vr_cdagenci := 0;
              vr_tab_age_microcredito(vr_ind_microcred_999).vr_cdhistor := pr_cdhistor;     
              vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccuage := vr_vllanmto;
              vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccuage := 1;
              vr_tab_age_microcredito(vr_ind_microcred_999).vr_dshistor := REPLACE(rw_craplcr.dsorgrec, 'MICROCREDITO','');                           
            END IF;

            IF vr_tab_age_microcredito.exists(vr_ind_microcred) THEN
              vr_tab_age_microcredito(vr_ind_microcred).vr_vlccuage := vr_tab_age_microcredito(vr_ind_microcred).vr_vlccuage + vr_vllanmto;
              vr_tab_age_microcredito(vr_ind_microcred).vr_qtccuage := vr_tab_age_microcredito(vr_ind_microcred).vr_qtccuage + 1; 
            ELSE
              pc_cria_age_microcredito(vr_ind_microcred);
              vr_tab_age_microcredito(vr_ind_microcred).vr_cdhistor := pr_cdhistor;
              vr_tab_age_microcredito(vr_ind_microcred).vr_dshistor := REPLACE(rw_craplcr.dsorgrec, 'MICROCREDITO','');
              vr_tab_age_microcredito(vr_ind_microcred).vr_cdagenci := vr_ass_cdagenci;
              vr_tab_age_microcredito(vr_ind_microcred).vr_vlccuage := vr_vllanmto;
              vr_tab_age_microcredito(vr_ind_microcred).vr_qtccuage := 1; 
            END IF;                

                          
            -- Segregando as informacoes por tipo de pessoa
            IF vr_inpessoa = 1 THEN
              IF vr_tab_age_microcredito.exists(vr_ind_microcred_999) THEN
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpf := vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpf + vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpf := vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpf + 1;
              ELSE
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpf := vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpf := 1;
              END IF;
                
              IF vr_tab_age_microcredito.exists(vr_ind_microcred) THEN                
                vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpf:= vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpf + vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpf:= vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpf + 1;
              ELSE
                vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpf:= vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpf:= 1;
              END IF;

            ELSE

              IF vr_tab_age_microcredito.exists(vr_ind_microcred_999) THEN
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpj := vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpj + vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpj := vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpj + 1;
              ELSE
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpj := vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpj := 1;
              END IF;
                
              IF vr_tab_age_microcredito.exists(vr_ind_microcred) THEN                
                vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpj := vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpj + vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpj := vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpj + 1;
              ELSE
                vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpj:= vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpj:= 1;
              END IF;
                 
            END IF;

          ELSE

            ---Agrupar valores na PL Table vr_tab_age_microcredito com index sendo a seguinte chave:
            vr_ind_microcred     := pr_cdhistor ||vr_cdagenci || 'OPERACAO_NORMAL';
            vr_ind_microcred_999 := pr_cdhistor ||'999'       || 'OPERACAO_NORMAL';
              
            IF vr_tab_age_microcredito.exists(vr_ind_microcred_999) THEN
              vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccuage := vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccuage + vr_vllanmto;
              vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccuage := vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccuage + 1;
            ELSE
              pc_cria_age_microcredito(vr_ind_microcred_999);
              vr_tab_age_microcredito(vr_ind_microcred_999).vr_cdagenci := 0;
              vr_tab_age_microcredito(vr_ind_microcred_999).vr_cdhistor := pr_cdhistor;     
              vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccuage := vr_vllanmto;
              vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccuage := 1;
              vr_tab_age_microcredito(vr_ind_microcred_999).vr_dshistor := 'OPERACAO_NORMAL';                           
            END IF;

            IF vr_tab_age_microcredito.exists(vr_ind_microcred) THEN
              vr_tab_age_microcredito(vr_ind_microcred).vr_vlccuage := vr_tab_age_microcredito(vr_ind_microcred).vr_vlccuage + vr_vllanmto;
              vr_tab_age_microcredito(vr_ind_microcred).vr_qtccuage := vr_tab_age_microcredito(vr_ind_microcred).vr_qtccuage + 1; 
            ELSE
              pc_cria_age_microcredito(vr_ind_microcred);
              vr_tab_age_microcredito(vr_ind_microcred).vr_cdhistor := pr_cdhistor;
              vr_tab_age_microcredito(vr_ind_microcred).vr_dshistor := 'OPERACAO_NORMAL';
              vr_tab_age_microcredito(vr_ind_microcred).vr_cdagenci := vr_ass_cdagenci;
              vr_tab_age_microcredito(vr_ind_microcred).vr_vlccuage := vr_vllanmto;
              vr_tab_age_microcredito(vr_ind_microcred).vr_qtccuage := 1; 
            END IF;                

                          
            -- Segregando as informacoes por tipo de pessoa
            IF vr_inpessoa = 1 THEN
              IF vr_tab_age_microcredito.exists(vr_ind_microcred_999) THEN
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpf := vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpf + vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpf := vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpf + 1;
              ELSE
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpf := vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpf := 1;
              END IF;
                
              IF vr_tab_age_microcredito.exists(vr_ind_microcred) THEN                
                vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpf:= vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpf + vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpf:= vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpf + 1;
              ELSE
                vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpf:= vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpf:= 1;
              END IF;

            ELSE

              IF vr_tab_age_microcredito.exists(vr_ind_microcred_999) THEN
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpj := vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpj + vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpj := vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpj + 1;
              ELSE
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_vlccagpj := vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred_999).vr_qtccagpj := 1;
              END IF;
                
              IF vr_tab_age_microcredito.exists(vr_ind_microcred) THEN                
                vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpj := vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpj + vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpj := vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpj + 1;
              ELSE
                vr_tab_age_microcredito(vr_ind_microcred).vr_vlccagpj:= vr_vllanmto;
                vr_tab_age_microcredito(vr_ind_microcred).vr_qtccagpj:= 1;
              END IF;
                 
            END IF;

              
          END IF;            

          vr_tab_agencia(999).vr_vlccuage := vr_tab_agencia(999).vr_vlccuage + vr_vllanmto;
          vr_tab_agencia(999).vr_qtccuage := vr_tab_agencia(999).vr_qtccuage + 1;
          vr_tab_agencia(vr_cdagenci).vr_vlcxaage := vr_tab_agencia(vr_cdagenci).vr_vlcxaage + vr_vllanmto;
          vr_tab_agencia(vr_cdagenci).vr_qtcxaage := vr_tab_agencia(vr_cdagenci).vr_qtcxaage + 1;
          vr_tab_agencia(vr_ass_cdagenci).vr_vlccuage := vr_tab_agencia(vr_ass_cdagenci).vr_vlccuage + vr_vllanmto;
          vr_tab_agencia(vr_ass_cdagenci).vr_qtccuage := vr_tab_agencia(vr_ass_cdagenci).vr_qtccuage + 1;
            
          -- Segregando as informacoes por tipo de pessoa
          IF vr_inpessoa = 1 THEN
             vr_tab_agencia(999).vr_vlccagpf := vr_tab_agencia(999).vr_vlccagpf + vr_vllanmto;
             vr_tab_agencia(999).vr_qtccagpf := vr_tab_agencia(999).vr_qtccagpf + 1;

             vr_tab_agencia(vr_cdagenci).vr_vlcxagpf := vr_tab_agencia(vr_cdagenci).vr_vlcxagpf + vr_vllanmto;
             vr_tab_agencia(vr_cdagenci).vr_qtcxagpf := vr_tab_agencia(vr_cdagenci).vr_qtcxagpf + 1;
             vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpf := vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpf + vr_vllanmto;
             vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpf := vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpf + 1;
          ELSE
             vr_tab_agencia(999).vr_vlccagpj := vr_tab_agencia(999).vr_vlccagpj + vr_vllanmto;
             vr_tab_agencia(999).vr_qtccagpj := vr_tab_agencia(999).vr_qtccagpj + 1;

             vr_tab_agencia(vr_cdagenci).vr_vlcxagpj := vr_tab_agencia(vr_cdagenci).vr_vlcxagpj + vr_vllanmto;
             vr_tab_agencia(vr_cdagenci).vr_qtcxagpj := vr_tab_agencia(vr_cdagenci).vr_qtcxagpj + 1;
             vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpj := vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpj + vr_vllanmto;
             vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpj := vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpj + 1;
          END IF;

        ELSE
        
          vr_tab_agencia(999).vr_vlccuage := vr_tab_agencia(999).vr_vlccuage + vr_vllanmto;
          vr_tab_agencia(999).vr_qtccuage := vr_tab_agencia(999).vr_qtccuage + 1;
          vr_tab_agencia(vr_cdagenci).vr_vlcxaage := vr_tab_agencia(vr_cdagenci).vr_vlcxaage + vr_vllanmto;
          vr_tab_agencia(vr_cdagenci).vr_qtcxaage := vr_tab_agencia(vr_cdagenci).vr_qtcxaage + 1;
          vr_tab_agencia(vr_ass_cdagenci).vr_vlccuage := vr_tab_agencia(vr_ass_cdagenci).vr_vlccuage + vr_vllanmto;
          vr_tab_agencia(vr_ass_cdagenci).vr_qtccuage := vr_tab_agencia(vr_ass_cdagenci).vr_qtccuage + 1;
          
          -- Segregando as informacoes por tipo de pessoa
          IF vr_inpessoa = 1 THEN
             vr_tab_agencia(999).vr_vlccagpf := vr_tab_agencia(999).vr_vlccagpf + vr_vllanmto;
             vr_tab_agencia(999).vr_qtccagpf := vr_tab_agencia(999).vr_qtccagpf + 1;

             vr_tab_agencia(vr_cdagenci).vr_vlcxagpf := vr_tab_agencia(vr_cdagenci).vr_vlcxagpf + vr_vllanmto;
             vr_tab_agencia(vr_cdagenci).vr_qtcxagpf := vr_tab_agencia(vr_cdagenci).vr_qtcxagpf + 1;
             vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpf := vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpf + vr_vllanmto;
             vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpf := vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpf + 1;
          ELSE
             vr_tab_agencia(999).vr_vlccagpj := vr_tab_agencia(999).vr_vlccagpj + vr_vllanmto;
             vr_tab_agencia(999).vr_qtccagpj := vr_tab_agencia(999).vr_qtccagpj + 1;

             vr_tab_agencia(vr_cdagenci).vr_vlcxagpj := vr_tab_agencia(vr_cdagenci).vr_vlcxagpj + vr_vllanmto;
             vr_tab_agencia(vr_cdagenci).vr_qtcxagpj := vr_tab_agencia(vr_cdagenci).vr_qtcxagpj + 1;
             vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpj := vr_tab_agencia(vr_ass_cdagenci).vr_vlccagpj + vr_vllanmto;
             vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpj := vr_tab_agencia(vr_ass_cdagenci).vr_qtccagpj + 1;
          END IF;

        end if;
      end if;
    end if;
  end loop;
  -- Se o cursor dinamico está aberto
  IF dbms_sql.is_open(vr_num_cursor) THEN
    -- Fecha o mesmo
    dbms_sql.close_cursor(vr_num_cursor);
  END IF;
  --
  pc_cria_craprej(pr_cdhistor => pr_cdhistor,
                  pr_dtrefere => pr_nmestrut);
  -- Verifica a estrutura e se o historico for
  --  98 - JUROS EMPR. ou 277 - ESTORNO JUROS 08 1038 - JUROS REMUN.
  if upper(pr_nmestrut) = 'CRAPLEM' and
     pr_cdhistor in (98, 277, 1038, 2343, 2345) then
    --
    vr_indice_agencia := vr_tab_agencia.first;
    -- Percorre todas as agencias
    while vr_indice_agencia is not null loop
      vr_tab_agencia(vr_indice_agencia).vr_vlccuage := vr_tab_agencia(vr_indice_agencia).vr_vlccuage_499;
      vr_tab_agencia(vr_indice_agencia).vr_vlcxaage := vr_tab_agencia(vr_indice_agencia).vr_vlcxaage_499;
      vr_tab_agencia(vr_indice_agencia).vr_qtccuage := vr_tab_agencia(vr_indice_agencia).vr_qtccuage_499;
      vr_tab_agencia(vr_indice_agencia).vr_qtcxaage := vr_tab_agencia(vr_indice_agencia).vr_qtcxaage_499;
      -- PF
      vr_tab_agencia(vr_indice_agencia).vr_vlccagpf := vr_tab_agencia(vr_indice_agencia).vr_vlccagpf_499;
      vr_tab_agencia(vr_indice_agencia).vr_vlcxagpf := vr_tab_agencia(vr_indice_agencia).vr_vlcxagpf_499;
      vr_tab_agencia(vr_indice_agencia).vr_qtccagpf := vr_tab_agencia(vr_indice_agencia).vr_qtccagpf_499;
      vr_tab_agencia(vr_indice_agencia).vr_qtcxagpf := vr_tab_agencia(vr_indice_agencia).vr_qtcxagpf_499;
      -- PJ
      vr_tab_agencia(vr_indice_agencia).vr_vlccagpj := vr_tab_agencia(vr_indice_agencia).vr_vlccagpj_499;
      vr_tab_agencia(vr_indice_agencia).vr_vlcxagpj := vr_tab_agencia(vr_indice_agencia).vr_vlcxagpj_499;
      vr_tab_agencia(vr_indice_agencia).vr_qtccagpj := vr_tab_agencia(vr_indice_agencia).vr_qtccagpj_499;
      vr_tab_agencia(vr_indice_agencia).vr_qtcxagpj := vr_tab_agencia(vr_indice_agencia).vr_qtcxagpj_499;
      --
      vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
    end loop;
    --
    IF pr_cdhistor = '98' THEN
      vr_dtrefere := 'craplem_499';
    ELSIF pr_cdhistor = '277' THEN
      vr_dtrefere := 'craplem_estfin';
    ELSIF pr_cdhistor IN ('1038','2343','2345') THEN
      vr_dtrefere := 'craplem';
    END IF;

    pc_cria_craprej(pr_cdhistor => pr_cdhistor,
                    pr_dtrefere => vr_dtrefere);
  end if;
  --
  
  -- Percorrer todas os historicos que nao creditam em conta
  vr_indice_agencia_hist_no := vr_tab_agencia_hist_no.first;
  WHILE vr_indice_agencia_hist_no IS NOT NULL LOOP
    vr_cdagenci := substr(vr_indice_agencia_hist_no,0,5);
    vr_cdhistor := substr(vr_indice_agencia_hist_no,6,5);
    
    -- Remove os Registros
    vr_tab_agencia.DELETE;
    vr_tab_agencia(vr_cdagenci).vr_vlccuage := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no).vr_vlccuage_no;
    vr_tab_agencia(vr_cdagenci).vr_vlcxaage := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no).vr_vlcxaage_no;
    vr_tab_agencia(vr_cdagenci).vr_qtccuage := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no).vr_qtccuage_no;
    vr_tab_agencia(vr_cdagenci).vr_qtcxaage := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no).vr_qtcxaage_no;
    -- PF
    vr_tab_agencia(vr_cdagenci).vr_vlccagpf := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no).vr_vlccagpf_no;
    vr_tab_agencia(vr_cdagenci).vr_vlcxagpf := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no).vr_vlcxagpf_no;
    vr_tab_agencia(vr_cdagenci).vr_qtccagpf := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no).vr_qtccagpf_no;
    vr_tab_agencia(vr_cdagenci).vr_qtcxagpf := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no).vr_qtcxagpf_no;
    -- PJ
    vr_tab_agencia(vr_cdagenci).vr_vlccagpj := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no).vr_vlccagpj_no;
    vr_tab_agencia(vr_cdagenci).vr_vlcxagpj := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no).vr_vlcxagpj_no;
    vr_tab_agencia(vr_cdagenci).vr_qtccagpj := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no).vr_qtccagpj_no;
    vr_tab_agencia(vr_cdagenci).vr_qtcxagpj := vr_tab_agencia_hist_no(vr_indice_agencia_hist_no).vr_qtcxagpj_no;

    -- Se o histórico não for um dos listados, altera para 699 - CONTRATO DE EMPRESTIMO CDC/OUTROS
    -- 340 - CHEQUE DE TRANSFERENCIA COMPENSADO BANCOOB
    -- 313 - CHEQUE COMPENSADO BANCOOB
    -- 345 - DEPOSITO COMPENSADO ENTRE AGENCIAS BANCOOB
    -- 445 - DEPOSITO BLOQ. COMPENSADO ENTRE AGENCIAS BANCOOB
    --  97 - RESTITUICAO IMPOSTO DE RENDA - VIA BANCOOB
    -- 319 - CREDITO DOC BANCOOB
    -- 339 - DOC SEGURO SAUDE SUL AMERICA (HERCO)
    -- 351 - DEVOLUCAO DE CHEQUE ACOLHIDO EM DEPOSITO
    --  24 - CHEQUE DEVOLVIDO PRACA
    --  27 - CHEQUE DEVOLVIDO FORA PRACA
    -- 342 - CREDITO DE COBRANCA BANCOOB
    -- 463 - ESTORNO DA PROVISAO RDC PRE
    -- 475 - RENDIMENTO RDCPRE
    -- 532 - RENDIMENTO RDCPOS
    if pr_cdhistor not in (340, 313, 345, 445, 97, 319, 339, 351, 24, 27, 342, 463, 475, 532) THEN

      pc_cria_craprej(pr_cdhistor => vr_cdhistor,
                      pr_dtrefere => pr_nmestrut);
    end if;
    
    vr_indice_agencia_hist_no := vr_tab_agencia_hist_no.next(vr_indice_agencia_hist_no);
    
  END LOOP;   
 
exception
  when others then
    pr_dscritic := 'Erro PC_CRPS249_1: '||SQLERRM;
END PC_CRPS249_1;
/
