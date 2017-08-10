CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS435(pr_cdcooper  IN craptab.cdcooper%TYPE --> Cooperativa solicitada
                                      ,pr_flgresta  IN PLS_INTEGER            --> Flag 0/1 para utilizar restart na chamada
                                      ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Crítica encontrada
                                      ,pr_dscritic OUT VARCHAR2)  IS         --> Texto de erro/critica encontrada

/* .............................................................................

   Programa: PC_CRPS435                          Antigo: Fontes/crps435.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Fevereiro/2005                  Ultima atualizacao: 24/04/2017

   Dados referentes ao programa:

   Frequencia: Por solicitacao - SOL030.
   Objetivo  : Emite aviso do credito das sobras do exercicio anterior.
               Solicitacao: 30
               Ordem: 2
               Relatorio: 410
               Tipo Documento: 8
               Formulario: Credito-Sobras.

   Alteracoes: 10/03/2005 - Alterado para NAO emitir aviso de credito para os
                            demitidos e para os valores abaixo de R$ 1,00
                            (Edson).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               19/06/2006 - Modificados campos referente endereco da estrutura
                            crapass para crapenc (Diego).

               06/02/2007 - Alterado de FormXpress para FormPrint (Julio).

               18/04/2007 - Modificado nome do arquivo aux_nmarqdat (Diego).

               30/05/2007 - Chamada do programa 'fontes/gera_formprint.p'
                            para executar a geracao e impressao dos
                            formularios em background (Julio)

               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               22/01/2009 - Envio de informativos para Postmix (Elton).

               25/03/2010 - Quando Viacredi, imprimir informativos so para
                            sobras >= 5,00 (Magui).

               14/03/2011 - Alteracao no layout do aviso (Henrique).

               28/03/2011 - Alterado para somente listar o cooperado que tiver o
                            total do retorno maior do que o especificado (Elton).

               19/08/2011 - Incluido separador das cartas e envio para Engecopy
                            quando for cooperativas 1, 2 ou 4 (Elton).

               03/04/2012 - Incluir descricao "JUROS AO CAPITAL" (Diego).

               14/05/2012 - Incluido FORMAT no campo aux_dsintern[5] ref.
                            valor liquido a ser creditado (Diego).

               16/05/2012 - Setado quantidade maxima de registros por arquivo;
                            aux_qtmaxarq = 3000. Tratado tambem para o envio
                            de email. (Fabricio)

                10/06/2013 - Alteraçao funçao enviar_email_completo para
                             nova versao (Jean Michel).

                27/02/2014 - Conversão Progress >>> Oracle  ( Renato - Supero )

                20/03/2014 - Tratamento migracao Acredi->Viacredi (Gabriel).

                20/03/2014 - Alterado para nao emitir carta para contas migradas
                             em 2014. (Gabriel)

                25/04/2014 - Corrigir alteração realizada pelo Gabriel, pois
                             não estava como implementado no progress.

				24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).

............................................................................. */

  -- CURSORES
  -- Buscar informações da cooperativa
  CURSOR cr_crapcop IS
    SELECT crapcop.dsdircop
         , crapcop.nmrescop
         , LPAD(crapcop.cdbcoctl,3,0) cdbcoctl
         , crapcop.cdagectl
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;

  -- Realizar um find dos lançamentos para verificar se há registros a serem processados
  CURSOR cr_craplct_find(pr_dtmvtolt DATE) IS
    SELECT 1
      FROM craplct
     WHERE craplct.cdcooper = pr_cdcooper
       AND craplct.dtmvtolt = pr_dtmvtolt
       AND craplct.cdagenci = 1
       AND craplct.cdbccxlt = 100
       AND craplct.nrdolote = 8005
       AND craplct.cdhistor = 64;

  -- Buscar os registros dos associados
  CURSOR cr_crapass IS
    SELECT crapass.nrdconta
         , crapass.inpessoa
         , crapass.cdsecext
         , crapass.cdagenci
         , crapass.nrcpfcgc
         , crapass.cdcooper
         , crapass.nmprimtl
         , crapass.nrctainv
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
      ORDER BY crapass.cdagenci
             , crapass.cdsecext
             , crapass.nrdconta
             , crapass.progress_recid;

  -- Buscar registros de lançamentos a serem processados
  CURSOR cr_craplct(pr_cdcooper craplct.cdcooper%TYPE
                   ,pr_dtmvtolt craplct.dtmvtolt%TYPE
                   ,pr_nrdconta craplct.nrdconta%TYPE
                   ,pr_dtlctjur craplct.dtmvtolt%TYPE
                   ,pr_cddopcao NUMBER) IS

       SELECT craplct.cdhistor
         , craplct.vllanmto
      FROM craplct
     WHERE craplct.cdcooper = pr_cdcooper
       AND craplct.cdagenci = 1
       AND craplct.cdbccxlt = 100
       AND craplct.nrdolote = 8005
       AND craplct.nrdconta = pr_nrdconta
       AND ( ( craplct.cdhistor = 64 AND craplct.dtmvtolt = pr_dtmvtolt AND pr_cddopcao = 1)
       OR  ( craplct.cdhistor IN (922,926) AND craplct.dtmvtolt = pr_dtlctjur AND pr_cddopcao = 2) )
     ORDER BY craplct.progress_recid;

  -- Buscar informação de titulares de conta
  CURSOR cr_crapttl(pr_nrdconta   crapttl.nrdconta%TYPE) IS
    SELECT crapttl.cdempres
      FROM crapttl
     WHERE crapttl.cdcooper = pr_cdcooper
       AND crapttl.nrdconta = pr_nrdconta
       AND crapttl.idseqttl = 1; -- Titular 1

  -- Buscar dados pessoa juridica
  CURSOR cr_crapjur(pr_nrdconta   crapttl.nrdconta%TYPE) IS
    SELECT crapjur.cdempres
      FROM crapjur
     WHERE crapjur.cdcooper = pr_cdcooper
       AND crapjur.nrdconta = pr_nrdconta;

  -- Buscar dados da empresa
  CURSOR cr_crapemp(pr_cdempres crapemp.cdempres%TYPE ) IS
    SELECT crapemp.nmresemp
      FROM crapemp
     WHERE crapemp.cdcooper = pr_cdcooper
       AND crapemp.cdempres = pr_cdempres;

  -- Buscar os dados do PA
  CURSOR cr_crapage(pr_cdagenci crapage.cdagenci%TYPE ) IS
    SELECT crapage.nmresage
      FROM crapage
     WHERE crapage.cdcooper = pr_cdcooper
       AND crapage.cdagenci = pr_cdagenci;

  -- Buscar o cadastro do destino do extrato
  CURSOR cr_crapdes(pr_cdsecext  crapdes.cdsecext%TYPE
                   ,pr_cdagenci  crapdes.cdagenci%TYPE) IS
    SELECT crapdes.nmsecext
      FROM crapdes
     WHERE crapdes.cdcooper = pr_cdcooper
       AND crapdes.cdsecext = pr_cdsecext
       AND crapdes.cdagenci = pr_cdagenci;

  -- Contas migradas ACREDI->VIACREDI
  CURSOR cr_craptco (pr_cdcooper craptco.cdcooper%TYPE
                    ,pr_nrdconta craptco.nrdconta%TYPE) IS
    SELECT 1
      FROM craptco
     WHERE craptco.cdcooper = pr_cdcooper
       AND craptco.nrdconta = pr_nrdconta
       AND craptco.cdcopant = 2
       AND craptco.cdageant IN (2,4,6,7,11)
       AND craptco.tpctatrf = 1
       AND craptco.flgativo = 1;

  CURSOR cr_craptco2 (pr_cdcopant craptco.cdcopant%TYPE
                     ,pr_nrctaant craptco.nrctaant%TYPE) IS
    SELECT craptco.cdcooper
          ,craptco.nrdconta
      FROM craptco
     WHERE craptco.cdcopant = pr_cdcopant
       AND craptco.nrctaant = pr_nrctaant
       AND craptco.cdageant IN (2,4,6,7,11)
       AND craptco.tpctatrf = 1
       AND craptco.flgativo = 1;

  -- Busca data juros creditados
  CURSOR cr_craplct_dt_jur(pr_dtmvtolt DATE) IS
    SELECT craplct.dtmvtolt
      FROM craplct
     WHERE craplct.cdcooper = pr_cdcooper
       AND craplct.dtmvtolt >= trunc(pr_dtmvtolt, 'yyyy')
       AND craplct.cdagenci = 1
       AND craplct.cdbccxlt = 100
       AND craplct.nrdolote = 8005
       AND craplct.cdhistor IN (922,926)
       AND rownum = 1;


  -- REGISTROS
  rw_crapcop          cr_crapcop%ROWTYPE;
  rw_craptco          cr_craptco%ROWTYPE;
  rw_craptco2         cr_craptco2%ROWTYPE;

  -- VARIÁVEIS
  -- Código do programa
  vr_cdprogra      CONSTANT VARCHAR2(10) := 'CRPS435';
  -- Datas de movimento e controle
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;
  -- Instancias e chave para manter os formulário
  vr_tab_cratext   FORM0001.typ_tab_cratext;
  vr_chv_cratext   VARCHAR2(40); -- Chave com Cooperativa(10) + Agencia(5) + Sessão(5) + Conta(10) + Ordem(10)
  -- Variáveis relativas aos arquivos
  vr_qtmaxarq      CONSTANT NUMBER :=  3000;
  vr_vlimprim      NUMBER;
  vr_nmarqdat      VARCHAR2(100);
  vr_imlogoin      VARCHAR2(200);
  vr_imlogoex      VARCHAR2(200);
  vr_nrarquiv      NUMBER := 1;
  vr_flgprint      BOOLEAN;
  -- Corpo da mensagem enviada por e-mail
  vr_dsmensag      VARCHAR2(1000);
  -- Código da empresa do associado
  vr_cdempres      crapttl.cdempres%TYPE;
  --Variaveis auxiliares, de controle e contadores
  vr_nrdummy       NUMBER;  -- Auxiliar para uso genérico
  vr_vlretsob      NUMBER := 0;
  vr_vljurcap      NUMBER := 0;
  vr_vljurirr      NUMBER := 0;
  vr_nrsequen      NUMBER;
  vr_cdacesso      CONSTANT craptab.cdacesso%TYPE := 'MSGDSOBRAS';
  vr_cdcooper      NUMBER := 0;
  vr_nrdconta      NUMBER := 0;
  -- Codigo da secao para onde deve ser enviado o extrato
  vr_cdsecext      crapass.cdsecext%TYPE;
  -- Nome resumido da agencia
  vr_nmresage      crapage.nmresage%TYPE;
  -- Nome resumido da empresa
  vr_nmresemp      crapemp.nmresemp%TYPE;
  -- Descrição destino extrato
  vr_nmsecext      crapdes.nmsecext%TYPE;
  -- Diretório das cooperativas
  vr_dsdireto      VARCHAR2(200);
  -- Tipo de saída do comando Host
  vr_typ_said      VARCHAR2(100);
  -- Variável de críticas
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(4000);
  -- Tratamento de erros
  vr_exc_saida     EXCEPTION;
  vr_exc_fimprg    EXCEPTION;
  -- Data pagamento Juros
  vr_dtlctjur      craplct.dtmvtolt%TYPE;

  -- Tipo opcao de elitura
  vr_cddopcao      NUMBER := 0;

BEGIN

  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra,
                             pr_action => vr_cdprogra);

  -- Verifica se a cooperativa esta cadastrada
  OPEN  cr_crapcop;
  FETCH cr_crapcop INTO rw_crapcop;

  -- Se não encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois haverá raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    vr_cdcritic := 651;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;

  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1 -- Fixo
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);

  -- Se retornou algum erro
  IF vr_cdcritic <> 0 THEN
    -- Log de critica
    RAISE vr_exc_saida;
  END IF;

  -- Buscar as datas do movimento
  OPEN  btch0001.cr_crapdat(pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;

  -- Se não encontrar o registro de movimento
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- 001 - Sistema sem data de movimento.
    vr_cdcritic := 1;

    CLOSE btch0001.cr_crapdat;
    -- Log de crítica
    RAISE vr_exc_saida;
  ELSE
    -- Atualizar as variáveis referente a datas
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
  END IF;

  CLOSE btch0001.cr_crapdat;
  -- Buscar diretório base da cooperativa
  vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Coop
                                      ,pr_cdcooper => pr_cdcooper);

  -- Definir os dados dos arquivos
  vr_nrsequen := 0;
  vr_nmarqdat := to_char(pr_cdcooper,'FM00')||'crrl410_'||TO_CHAR(vr_dtmvtolt,'DDMM')||'_';
  vr_imlogoin := /*vr_dsdireto||*/'laser/imagens/logo_'||TRIM(LOWER(rw_crapcop.nmrescop))||'_interno.pcx';
  vr_imlogoex := /*vr_dsdireto||*/'laser/imagens/logo_'||TRIM(LOWER(rw_crapcop.nmrescop))||'_externo.pcx';

  -- Se for viacredi
  IF pr_cdcooper = 1 THEN
    vr_vlimprim := 5;
  ELSE
    vr_vlimprim := 1;
  END IF;

  -- Buscar lançamentos a serem listados
  OPEN  cr_craplct_find(vr_dtmvtolt);
  FETCH cr_craplct_find INTO vr_nrdummy;
  -- Se não retornou nenhum registro
  IF cr_craplct_find%NOTFOUND THEN

    -- Seta o parametro de retorno
    pr_infimsol := 1;

    -- Fecha cursor
    CLOSE cr_craplct_find;

    -- Executar o fimprg e encerrar o programa
    RAISE vr_exc_fimprg;

  END IF;

  -- Fecha cursor
  CLOSE cr_craplct_find;


  -- Buscar data pagamento juros
  OPEN  cr_craplct_dt_jur(vr_dtmvtolt);
  FETCH cr_craplct_dt_jur INTO vr_dtlctjur;
  -- Se não retornou nenhum registro
  IF cr_craplct_dt_jur%NOTFOUND THEN
    -- Se não existir lançamento de juros, a data deve ser nula
    vr_dtlctjur := NULL;
  END IF;

  -- Fecha cursor
  CLOSE cr_craplct_dt_jur;

  -- Seta a flag
  vr_flgprint := FALSE;

  -- Buscar os associados e percorrer os mesmos
  FOR rw_crapass IN cr_crapass LOOP

    -- Inicializa
    vr_vlretsob := 0;
    vr_vljurirr := 0;
    vr_vljurcap := 0;
    vr_cdcooper := rw_crapass.cdcooper;
    vr_nrdconta := rw_crapass.nrdconta;


    -- Tratamento contas migradas ACREDI->VIACREDI
    IF  to_number(to_char(vr_dtmvtolt,'yyyy')) - 1 = 2013  AND
      rw_crapass.cdcooper = 1  THEN

      OPEN cr_craptco (pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta);

      FETCH cr_craptco INTO rw_craptco;

      -- Desprezar, pois nao emitira carta na nova coop.(VIACREDI)
      -- para esta conta ref. 2013, o retorno das sobras de 2013
      -- eh ref. a movimentacao da antiga conta na ACREDI
      IF  cr_craptco%FOUND  THEN
        CLOSE cr_craptco;
        CONTINUE;
      END IF;

      CLOSE cr_craptco;

    END IF;

    IF  rw_crapass.cdcooper = 2  THEN

      -- A carta de retorno das sobras ref. 2013 sera enviada pela
      -- coop. antiga (ACREDI)
      OPEN cr_craptco2 (pr_cdcopant => vr_cdcooper
                       ,pr_nrctaant => vr_nrdconta);

      FETCH cr_craptco2 INTO rw_craptco2;

      -- Devera buscar lançamento de retorno efetuado na NOVA cooperativa
      IF  cr_craptco2%FOUND  THEN
        vr_cdcooper := rw_craptco2.cdcooper;
        vr_nrdconta := rw_craptco2.nrdconta;
      END IF;

      CLOSE cr_craptco2;

    END IF;

    vr_cddopcao := 1; -- Retorno de sobras

    -- Percorre todos os registros de lançamento
    FOR rw_craplct IN cr_craplct(vr_cdcooper, vr_dtmvtolt, vr_nrdconta, vr_dtlctjur, vr_cddopcao) LOOP
      -- Verificar o histórico
      IF    rw_craplct.cdhistor = 64  THEN -- Se for retorno de sobras
        vr_vlretsob := rw_craplct.vllanmto;
      END IF;

    END LOOP;  -- cr_craplct

    IF vr_vlretsob = 0 THEN
      CONTINUE;
    END IF;

	IF  vr_dtlctjur IS NOT NULL  THEN
      vr_cddopcao := 2; -- Juros

      -- Percorre todos os registros de lançamento
      FOR rw_craplct IN cr_craplct(vr_cdcooper, vr_dtmvtolt, vr_nrdconta, vr_dtlctjur, vr_cddopcao) LOOP
        -- Verificar o histórico
        IF    rw_craplct.cdhistor = 922 THEN -- Se for IR sobre Juros
          vr_vljurirr := rw_craplct.vllanmto;
        ELSIF rw_craplct.cdhistor = 926 THEN -- Se Juros sobre Capital
          vr_vljurcap := rw_craplct.vllanmto;
        END IF;

      END LOOP;  -- cr_craplct
    END IF;

    -- Totaliza valor do retorno e despreza se for menor do que especificado
    IF (vr_vlretsob + vr_vljurcap - vr_vljurirr) < vr_vlimprim THEN
      -- Próximo registro
      CONTINUE;
    END IF;

    vr_cdempres := NULL;

    -- Se for pessoa fisica
    IF rw_crapass.inpessoa = 1   THEN
      -- Buscar dados de titulares da conta
      OPEN  cr_crapttl(rw_crapass.nrdconta);
      FETCH cr_crapttl INTO vr_cdempres;
      CLOSE cr_crapttl;
    ELSE
      -- Buscar dados de pessoa jurídica
      OPEN  cr_crapjur(rw_crapass.nrdconta);
      FETCH cr_crapjur INTO vr_cdempres;
      CLOSE cr_crapjur;
    END IF;

    -- Verifica a sessão de envio do extrato
    IF rw_crapass.cdsecext = 0 THEN
      vr_cdsecext := 999;
    ELSE
      vr_cdsecext := rw_crapass.cdsecext;
    END IF;

    -- Buscar informações do cadastro de empresas
    OPEN  cr_crapemp(vr_cdempres);
    FETCH cr_crapemp INTO vr_nmresemp;
    -- Se não encontrar registros
    IF cr_crapemp%NOTFOUND THEN
      vr_cdcritic := 40; -- 040 - Empresa nao cadastrada
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) );
      -- Limpar critica
      vr_cdcritic := 0;
      -- Fecha o cursor
      CLOSE cr_crapemp;
      -- Encerrar a execução do programa sem a chamada da fimprg
      RETURN;
    END IF;
    -- Fecha o cursor
    CLOSE cr_crapemp;

    -- Buscar informações do cadastro de agencias
    OPEN  cr_crapage(rw_crapass.cdagenci);
    FETCH cr_crapage INTO vr_nmresage;
    -- Se não encontrar registros
    IF cr_crapage%NOTFOUND THEN
      vr_cdcritic := 15; -- 015 - Agencia nao cadastrada
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) );
      -- Limpar critica
      vr_cdcritic := 0;
      -- Fecha o cursor
      CLOSE cr_crapage;
      -- Encerrar a execução do programa sem a chamada da fimprg
      RETURN;
    END IF;
    -- Fecha o cursor
    CLOSE cr_crapage;

    -- Buscar informações do cadastro de destinos de extratos
    OPEN  cr_crapdes(vr_cdsecext, rw_crapass.cdagenci);
    FETCH cr_crapdes INTO vr_nmsecext;
    -- Se não encontrar registros
    IF cr_crapdes%NOTFOUND THEN
      vr_cdcritic := 19; -- 019 - Secao para extrato nao cadastrada
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) );
      -- Limpar critica
      vr_cdcritic := 0;
      -- Fecha o cursor
      CLOSE cr_crapdes;
      -- Encerrar a execução do programa sem a chamada da fimprg
      RETURN;
    END IF;
    -- Fecha o cursor
    CLOSE cr_crapdes;

    -- Incrementa a sequencia
    vr_nrsequen := NVL(vr_nrsequen,0) + 1;

    -- Formar a chave para inserir o registro
    vr_chv_cratext := lpad(rw_crapass.cdagenci,5,'0')||lpad(rw_crapass.nrdconta,10,'0');

    -- Insere os dados no registro de memória
    vr_tab_cratext(vr_chv_cratext).nmagenci := vr_nmresage;
    vr_tab_cratext(vr_chv_cratext).nmsecext := vr_nmsecext;
    vr_tab_cratext(vr_chv_cratext).nrdconta := rw_crapass.nrdconta;
    vr_tab_cratext(vr_chv_cratext).cdagenci := rw_crapass.cdagenci;
    vr_tab_cratext(vr_chv_cratext).nmprimtl := SUBSTR(rw_crapass.nmprimtl,0,47); -- Limitar em 47 caracteres
    vr_tab_cratext(vr_chv_cratext).nmempres := vr_nmresemp;
    vr_tab_cratext(vr_chv_cratext).nrseqint := vr_nrsequen;
    vr_tab_cratext(vr_chv_cratext).indespac := 2;
    vr_tab_cratext(vr_chv_cratext).dtemissa := vr_dtmvtolt;
    vr_tab_cratext(vr_chv_cratext).nrdordem := 1;
    vr_tab_cratext(vr_chv_cratext).tpdocmto := 8;

    -- Nome e conta do associado
    vr_tab_cratext(vr_chv_cratext).dsintern(1) := RPAD(rw_crapass.nmprimtl, 43, ' ')||GENE0002.fn_mask_conta(rw_crapass.nrdconta);

    -- Limpa os campos e cria o registro
    vr_tab_cratext(vr_chv_cratext).dsintern(2) := '';
    vr_tab_cratext(vr_chv_cratext).dsintern(3) := '';
    vr_tab_cratext(vr_chv_cratext).dsintern(4) := '';

    -- Retorno de sobras
    IF vr_vlretsob > 0 THEN
      vr_tab_cratext(vr_chv_cratext).dsintern(2) := 'RETORNO DAS SOBRAS               C  '||to_char(vr_vlretsob,'FM99G999G990D00');
    END IF;
    -- Juros ao capital
    IF vr_vljurcap > 0 THEN
      vr_tab_cratext(vr_chv_cratext).dsintern(3) := 'JUROS AO CAPITAL                 C  '||to_char(vr_vljurcap,'FM99G999G990D00');
    END IF;
    -- IR sobre juros ao capital
    IF vr_vljurirr > 0  THEN
      vr_tab_cratext(vr_chv_cratext).dsintern(4) := 'IR SOBRE JUROS AO CAPITAL(15%)   D  '||to_char(vr_vljurirr,'FM99G999G990D00');
    END IF;

    -- Total
    vr_tab_cratext(vr_chv_cratext).dsintern(5) := to_char(vr_vlretsob + vr_vljurcap - vr_vljurirr, 'FM99G999G990D00');

    -- Ano anterior
    vr_tab_cratext(vr_chv_cratext).dsintern(6) := to_char(ADD_MONTHS(vr_dtmvtolt,-12), 'YYYY');
    vr_tab_cratext(vr_chv_cratext).dsintern(7) := '#';


    -- Setar a variável de controle de impressão
    vr_flgprint := TRUE;

  END LOOP; -- cr_crapass

  -- Chamar a rotina de geração do arquivo
  FORM0001.pc_gera_dados_inform(pr_cdcooper    => pr_cdcooper
                               ,pr_dtmvtolt    => vr_dtmvtolt
                               ,pr_cdacesso    => vr_cdacesso
                               ,pr_qtmaxarq    => vr_qtmaxarq
                               ,pr_nrarquiv    => vr_nrarquiv
                               ,pr_dsdireto    => vr_dsdireto||'/arq'
                               ,pr_nmarqdat    => vr_nmarqdat
                               ,pr_tab_cratext => vr_tab_cratext
                               ,pr_imlogoex    => vr_imlogoex
                               ,pr_imlogoin    => vr_imlogoin
                               ,pr_des_erro    => vr_dscritic);

  -- Testar saida com erro
  IF vr_dscritic IS NOT NULL THEN
    -- Gerar exceção
    vr_cdcritic := 0;
    RAISE vr_exc_saida;
  END IF;

  -- Se a flag de impressão está marcada como true
  IF vr_flgprint THEN

    -- Iteração para arquivos
    LOOP
      -- Sai quando encerrarem os arquivos
      EXIT WHEN vr_nrarquiv <= 0;

      -- Move os arquivos para o direório salvar
      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dsdireto||'/arq/'||vr_nmarqdat||to_char(vr_nrarquiv,'FM00')||'.dat '||vr_dsdireto||'/salvar/ '
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_dscritic);

      -- Testar erro
      IF vr_typ_said = 'ERR' THEN
        -- Adicionar o erro na variavel de erros
        vr_dscritic := 'Erro ao excluir arquivos dat --> '||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;

      -- Se for uma cooperativa que trabalha com a ENGECOPY
      IF pr_cdcooper IN (1,2,4)  THEN

        -- Definir o corpo da mensagem
        vr_dsmensag := 'Em anexo o arquivo('||vr_nmarqdat||to_char(vr_nrarquiv,'FM00')||'.zip'
                     ||') contendo as cartas da '||rw_crapcop.nmrescop||'.';

        -- Enviar os dados para a Blucopy
        FORM0001.pc_envia_dados_blucopy(pr_cdcooper => pr_cdcooper
                                       ,pr_cdprogra => vr_cdprogra
                                       ,pr_dslstarq => vr_dsdireto||'/salvar/'||vr_nmarqdat||to_char(vr_nrarquiv,'FM00')||'.dat'
                                       ,pr_dsasseml => 'Cartas '||rw_crapcop.nmrescop
                                       ,pr_dscoreml => vr_dsmensag
                                       ,pr_des_erro => vr_dscritic);

        -- Testar saida com erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          vr_cdcritic := 0;
          RAISE vr_exc_saida;
        END IF;

      ELSE

        -- Chamar rotina de upload dos arquivos para Postmix
        FORM0001.pc_envia_dados_postmix(pr_cdcooper => pr_cdcooper
                                       ,pr_dtmvtolt => vr_dtmvtolt
                                       ,pr_nmarqdat => vr_nmarqdat||to_char(vr_nrarquiv,'FM00')||'.dat'
                                       ,pr_nmarqenv => 'salvar/'||vr_nmarqdat||to_char(vr_nrarquiv,'FM00')||'.dat'
                                       ,pr_inaguard => 'N'
                                       ,pr_des_erro => vr_dscritic );

        -- Testar saida com erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          vr_cdcritic := 0;
          RAISE vr_exc_saida;
        END IF;

      END IF;

      -- Diminui o número de arquivos
      vr_nrarquiv := vr_nrarquiv - 1;

    END LOOP;
  END IF;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informações atualizada
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
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
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
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS435;
/

