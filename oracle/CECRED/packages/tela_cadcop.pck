CREATE OR REPLACE PACKAGE CECRED.TELA_CADCOP is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_CADCOP
  --  Sistema  : Rotina acessada pela tela CADCOP
  --  Sigla    : TELA_CADCOP
  --  Autor    : Andrei - RKAM
  --  Data     : Agosto/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas utilizadas para a tela CADCOP
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_consulta_cooperativa(pr_cddopcao  IN VARCHAR2                --> Código da opção
                                   ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER            --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2               --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);             --> Descrição do erro


  PROCEDURE pc_consulta_municipios(pr_cddopcao  IN VARCHAR2                --> Código da opção
                                  ,pr_nrregist  IN INTEGER                 --> Número de registros
                                  ,pr_nriniseq  IN INTEGER                 --> Número sequencial
                                  ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER            --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2               --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);             --> Descrição do erro

  PROCEDURE pc_manter_municipios(pr_cddopcao  IN VARCHAR2                --> Código da opção
                                ,pr_cdcidade  IN tbgen_cid_atuacao_coop.cdcidade%TYPE  --> Código da cidade
                                ,pr_dscidade  IN crapmun.dscidade%TYPE   --> Nome da cidade
                                ,pr_cdestado  IN crapmun.cdestado%TYPE   --> Estado
                                ,pr_tpoperac  IN VARCHAR2                --> Tipo da operação
                                ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER            --> Código da crítica
                                ,pr_dscritic  OUT VARCHAR2               --> Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2);             --> Descrição do erro

  PROCEDURE pc_alterar_cooperativa(pr_cddopcao IN VARCHAR2              --> Código da opção
                                  ,pr_cddepart IN VARCHAR2              --> Departamento do operador
                                  ,pr_dtmvtolt IN VARCHAR2              --> Data de movimento
                                  ,pr_nmrescop IN crapcop.nmrescop%TYPE --> Nome resumido da cooperativa
                                  ,pr_nrdocnpj IN crapcop.nrdocnpj%TYPE --> Número do CNPJ
                                  ,pr_nmextcop IN crapcop.nmextcop%TYPE --> Nome extenso da cooperativa
                                  ,pr_dtcdcnpj IN VARCHAR2              --> Data do CNPJ
                                  ,pr_dsendcop IN crapcop.dsendcop%TYPE --> Endereço
                                  ,pr_nrendcop IN crapcop.nrendcop%TYPE --> Número do endereço
                                  ,pr_dscomple IN crapcop.dscomple%TYPE --> Complemento
                                  ,pr_nmbairro IN crapcop.nmbairro%TYPE --> Nome do bairro
                                  ,pr_nrcepend IN crapcop.nrcepend%TYPE --> CEP
                                  ,pr_nmcidade IN crapcop.nmcidade%TYPE --> Nome da cidade
                                  ,pr_cdufdcop IN crapcop.cdufdcop%TYPE --> UF
                                  ,pr_nrcxapst IN crapcop.nrcxapst%TYPE --> Caixa postal
                                  ,pr_nrtelvoz IN crapcop.nrtelvoz%TYPE --> Número do telefone
                                  ,pr_nrtelouv IN crapcop.nrtelouv%TYPE --> Ouvidoria
                                  ,pr_dsendweb IN crapcop.dsendweb%TYPE --> Endereço WEB
                                  ,pr_nrtelura IN crapcop.nrtelura%TYPE --> URA
                                  ,pr_dsdemail IN crapcop.dsdemail%TYPE --> E-mail
                                  ,pr_nrtelfax IN crapcop.nrtelfax%TYPE --> FAX
                                  ,pr_dsdempst IN crapcop.dsdempst%TYPE --> E-mail do presidente
                                  ,pr_nrtelsac IN crapcop.nrtelsac%TYPE --> SAC
                                  ,pr_nmtitcop IN crapcop.nmtitcop%TYPE --> Nome presidente
                                  ,pr_nrcpftit IN crapcop.nrcpftit%TYPE --> CPF do presidente
                                  ,pr_nmctrcop IN crapcop.nmctrcop%TYPE --> Nome do contador
                                  ,pr_nrcpfctr IN crapcop.nrcpfctr%TYPE --> CPF do contador
                                  ,pr_nrcrcctr IN crapcop.nrcrcctr%TYPE --> CRC
                                  ,pr_dsemlctr IN crapcop.dsemlctr%TYPE --> E-mail do contador
                                  ,pr_nrrjunta IN crapcop.nrrjunta%TYPE --> Número registro junta comercial
                                  ,pr_dtrjunta IN VARCHAR2              --> Data do registro junta comercial
                                  ,pr_nrinsest IN crapcop.nrinsest%TYPE --> Inscrição estadual
                                  ,pr_nrinsmun IN crapcop.nrinsmun%TYPE --> Inscrição municipal
                                  ,pr_nrlivapl IN crapcop.nrlivapl%TYPE --> Livro de aplicações
                                  ,pr_nrlivcap IN crapcop.nrlivcap%TYPE --> Livro de capital
                                  ,pr_nrlivdpv IN crapcop.nrlivdpv%TYPE --> Livro de Depóstio a vista
                                  ,pr_nrlivepr IN crapcop.nrlivepr%TYPE --> Livro de empréstimos
                                  ,pr_cdbcoctl IN crapcop.cdbcoctl%TYPE --> Código COMPE CECRED
                                  ,pr_cdagebcb IN crapcop.cdagebcb%TYPE --> Agência BANCOOB
                                  ,pr_cdagedbb IN crapcop.cdagedbb%TYPE --> Agencia BB
                                  ,pr_cdageitg IN crapcop.cdageitg%TYPE --> Agencia conta itg da coop
                                  ,pr_cdcnvitg IN crapcop.cdcnvitg%TYPE --> Número convenio conta itg
                                  ,pr_cdmasitg IN crapcop.cdmasitg%TYPE --> Código massificado da conta itg
                                  ,pr_nrctabbd IN crapcop.nrctabbd%TYPE --> Número da conta convenio BB
                                  ,pr_nrctactl IN crapcop.nrctactl%TYPE --> Numero da conta junto a CECRED
                                  ,pr_nrctaitg IN crapcop.nrctaitg%TYPE --> Conta de integracao da Cooperativa
                                  ,pr_nrctadbb IN crapcop.nrctadbb%TYPE --> Numero da conta convenio no BB
                                  ,pr_nrctacmp IN crapcop.nrctacmp%TYPE --> Conta compe CECRED
                                  ,pr_nrdconta IN crapcop.nrdconta%TYPE --> Número da conta da cooperativa
                                  ,pr_flgdsirc IN crapcop.flgdsirc%TYPE --> SIRC 0 - Capitl / 1 - Interior
                                  ,pr_flgcrmag IN crapcop.flgcrmag%TYPE --> Utiliza Cartao Magnetico
                                  ,pr_cdagectl IN crapcop.cdagectl%TYPE --> Codigo da agencia da Central
                                  ,pr_dstelscr IN crapcop.dstelscr%TYPE --> Tel. responsavel pela central de risco
                                  ,pr_cdcrdarr IN crapcop.cdcrdarr%TYPE --> Codigo de credenciamento para arrecadacoes
                                  ,pr_cdagsede IN crapcop.cdagsede%TYPE --> PA considerado sede para o INSS
                                  ,pr_nrctabol IN crapass.nrdconta%TYPE --> Conta da cooperativa para emissao de boletos
                                  ,pr_cdlcrbol IN craplcr.cdlcremp%TYPE --> Linha de credito para emissao de boletos
                                  ,pr_vltxinss IN NUMBER                --> Tarifa de recebimento de INSS
                                  ,pr_flgargps IN crapcop.flgargps%TYPE --> Arrecada GPS
                                  ,pr_vldataxa IN NUMBER                --> Tarifa de pagamento
                                  ,pr_nrversao IN NUMBER                --> Versao do software
                                  ,pr_nrconven IN NUMBER                --> Número do convenio
                                  ,pr_qttmpsgr IN VARCHAR2              --> Tempo para efetuar a sangria
                                  ,pr_hrinisac IN VARCHAR2              --> Horário inicial para atendimento
                                  ,pr_hrfimsac IN VARCHAR2              --> Horário final para atendimento
                                  ,pr_hriniouv IN VARCHAR2              --> Horário inicial para ouvidoria
                                  ,pr_hrfimouv IN VARCHAR2              --> Horário final para ouvidoria
                                  ,pr_vltfcxsb IN NUMBER                --> Tarifa de GPS sem Cod.Barras
                                  ,pr_vltfcxcb IN NUMBER                --> Tarifa de GPS com Cod.Barras
                                  ,pr_vlrtrfib IN NUMBER                --> Tarifa de GPS Internet Banking
                                  ,pr_flrecpct IN crapcop.flrecpct%TYPE --> Permite reciprocidade 0 - Nao / 1 - Sim
                                  ,pr_flsaqpre IN crapcop.flsaqpre%TYPE --> Isentar cobrança de tarifas e saques presenciais ( 0 - isentar / 1 - Nao isentar)
                                  ,pr_flgcmtlc IN crapcop.flgcmtlc%TYPE --> Comite local
                                  ,pr_qtmaxmes IN crapcop.qtmaxmes%TYPE --> Quantidade maxima de meses de desconto
                                  ,pr_permaxde IN crapcop.permaxde%TYPE --> ercentual maximo de desconto manual
                                  ,pr_cdloggrv IN crapcop.cdloggrv%TYPE --> Login do usuario no gravames
                                  ,pr_flgofatr IN crapcop.flgofatr%TYPE --> Oferta autorizacao de debito
                                  ,pr_qtdiasus IN crapcop.qtdiasus%TYPE --> Quantidade de dias de suspensao
                                  ,pr_cdcliser IN crapcop.cdcliser%TYPE --> Codigo do Cliente no SERASA
                                  ,pr_vlmiplco IN crapcop.vlmiplco%TYPE --> Valor minimo para contratacao do plano de cotas
                                  ,pr_vlmidbco IN crapcop.vlmidbco%TYPE --> Valor minimo para efetuar o debito de cotas
                                  ,pr_cdfingrv IN crapcop.cdfingrv%TYPE --> Codigo da financeira no gravames
                                  ,pr_cdsubgrv IN crapcop.cdsubgrv%TYPE --> Subcodigo do usuario no gravames
                                  ,pr_hriniatr IN VARCHAR2              --> Horario inicial para autorizacao de debito
                                  ,pr_hrfimatr IN VARCHAR2              --> Hora final para a autorizacao de debito
                                  ,pr_flgkitbv IN crapcop.flgkitbv%TYPE --> Trabalaha com kit de boas vindas
                                  ,pr_hrinigps IN VARCHAR2              --> Hora inicial para arrecadacao de guias de GPS do Sicredi
                                  ,pr_hrfimgps IN VARCHAR2              --> Hora final para arrecadacao de guias de GPS do Sicredi
                                  ,pr_hrlimsic IN VARCHAR2              --> Horario limite pagamento SICREDI
                                  ,pr_dtctrdda IN VARCHAR2              --> Contem a data do registro do contrato DDA
                                  ,pr_nrctrdda IN crapcop.nrctrdda%TYPE --> Número do contrato DDA em cartorio
                                  ,pr_idlivdda IN crapcop.idlivdda%TYPE --> numero do livro de registro do contrato DDA
                                  ,pr_nrfoldda IN crapcop.nrfoldda%TYPE --> numero da folha do livro de registro do contrato DDA
                                  ,pr_dslocdda IN crapcop.dslocdda%TYPE --> local onde ocorreu o registro do contrato DDA
                                  ,pr_dsciddda IN crapcop.dsciddda%TYPE --> cidade onde ocorreu o registro do contato DDA
                                  ,pr_dtregcob IN VARCHAR2              --> data de registro da cobranca
                                  ,pr_idregcob IN crapcop.idregcob%TYPE --> identificador de registro da cobranca
                                  ,pr_idlivcob IN crapcop.idlivcob%TYPE --> identificador do livro de registro da cobranca
                                  ,pr_nrfolcob IN crapcop.nrfolcob%TYPE --> numero da folha do registro de cobranca
                                  ,pr_dsloccob IN crapcop.dsloccob%TYPE --> local de registro da cobranca
                                  ,pr_dscidcob IN crapcop.dscidcob%TYPE --> cidade de registro da cobranca
                                  ,pr_dsnomscr IN crapcop.dsnomscr%TYPE --> nome do responsavel pelas informacoes da central de risco
                                  ,pr_dsemascr IN crapcop.dsemascr%TYPE --> e-mail do responsavel pelas informacoes da central de risco
                                  ,pr_cdagesic IN crapcop.cdagesic%TYPE --> Numero da agencia Sicredi
                                  ,pr_nrctasic IN crapcop.nrctasic%TYPE --> conta convenio no Sicredi
                                  ,pr_cdcrdins IN crapcop.cdcrdins%TYPE --> Codigo de credencimento GPS
                                  ,pr_vltarsic IN crapcop.vltarsic%TYPE --> Valor da tarifa do SICREDI
                                  ,pr_vltardrf IN crapcop.vltardrf%TYPE --> Valor da tarifa de tributo federal do Sicredi
                                  ,pr_hrproces IN VARCHAR2              --> Horario de verificacao se o processo foi solicitado
                                  ,pr_hrfinprc IN VARCHAR2              --> Horario Final Verificacao Proces
                                  ,pr_dsdircop IN crapcop.dsdircop%TYPE --> Diretorio da Cooperativa onde esta o sistema
                                  ,pr_dsnotifi IN VARCHAR2              --> Texto para notificar o responsavel pelo processamento diario
                                  ,pr_nmdireto IN crapcop.nmdireto%TYPE --> Diretorio Padrao Arquivos Textos
                                  ,pr_flgdopgd IN crapcop.flgdopgd%TYPE --> Participa do progrid ou nao
                                  ,pr_dsclactr IN VARCHAR2              --> Descricao da clausula do contrato da conta-corrente
                                  ,pr_dsclaccb IN VARCHAR2              --> Clausula do contrato de cobranca
                                  ,pr_vlmaxcen IN crapcop.vlmaxcen%TYPE --> Valor maximo legal a ser emprestado pela Cooperativa
                                  ,pr_vlmaxleg IN crapcop.vlmaxleg%TYPE --> Valor maximo legal a ser emprestado pela cooperativa ao associado
                                  ,pr_vlmaxutl IN crapcop.vlmaxutl%TYPE --> Valor maximo utilizado pelo associado nos emprestimos
                                  ,pr_vlcnsscr IN crapcop.vlcnsscr%TYPE --> Valor para Consulta SCR
                                  ,pr_vllimmes IN crapcop.vllimmes%TYPE --> Valor do limite disponivel para emprestimo no mes
                                  ,pr_qtdiaenl IN crapcop.qtdiaenl%TYPE --> Quantidade de dias para verificacao de envelopes TAA pendentes
                                  ,pr_cdsinfmg IN crapcop.cdsinfmg%TYPE --> Emissao do inform de chegada do cartao magnetico para o cooperado
                                  ,pr_taamaxer IN crapcop.taamaxer%TYPE --> Qtd. Max. de tentivas da senha no TAA
                                  ,pr_vllimapv IN crapcop.vllimapv%TYPE --> Limite necessita de aprovacao
                                  ,pr_qtmeatel IN crapcop.qtmeatel%TYPE --> Quantidade de Meses para atualizacao Telefone
                                  ,pr_flintcdc IN crapcop.flintcdc%TYPE --> Possui CDC                                  
                                  ,pr_tpcdccop IN crapcop.tpcdccop%TYPE --> Tipo CDC
                                  ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER            --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2               --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);             --> Descrição do erro

END TELA_CADCOP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADCOP IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_CADCOP
  --  Sistema  : Rotina acessada pela tela CADCOP
  --  Sigla    : TELA_CADCOP
  --  Autor    : Andrei - RKAM
  --  Data     : Agosto/2016.                   Ultima atualizacao: 15/09/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas utilizadas para a tela CADCOP
  --
  -- Alteracoes: 10/11/2016 - Ajuste para retirar o uso dos campos na tabela crapmun pois não serão
  --                          liberados em produção
  --                          (Adriano)
  --
  --             17/11/2016 - M172 - Atualização Telefone - Inclusão novo campo tela (Guilherme/SUPERO)
  --
  --             28/11/2016 - P341 - Automatização BACENJUD - Alterado o parametro PR_DSDEPART 
  --                          para PR_CDDEPART e as consultas do fonte para utilizar o código 
  --                          do departamento nas validações (Renato Darosci - Supero)
  --
  --             22/12/2016 - Ajuste para gravar o nome resumido da cooperativa em maiusculo
  --                          (Adriano - SD 582204).
  --
  --             15/09/2017 - Alteracao na mascara da Agencia do Banco do Brasil. (Jaison/Elton - M459)
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Funcao para validacao dos caracteres */
  FUNCTION fn_valida_caracteres (pr_flgnumer IN BOOLEAN,  -- Validar Numeros?
                                 pr_flgletra IN BOOLEAN,  -- Validar Letras?
                                 pr_listaesp IN VARCHAR2, -- Lista de Caracteres Validos
                                 pr_listainv IN VARCHAR2, -- Lista de Caracteres Invalidos
                                 pr_dsvalida IN VARCHAR2  -- Texto para ser validado
                                ) RETURN BOOLEAN IS       -- ERRO -> TRUE
  /* ............................................................................

    Programa: fn_valida_caracteres
    Autor   : Andrei
    Data    : Agosto/2016                   Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Processar validacoes de caracteres em campos digitaveis

    Parametros : pr_flgnumer : Validar lista de numeros ?
                 pr_flgletra : Validar lista de letras  ?
                 pr_listaesp : Lista de caracteres validados.
                 pr_listainv : Lista de caracteres invaldidos
                 pr_validar  : Campo a ser validado.

    Alteracoes:
  ............................................................................ */
    vr_dsvalida VARCHAR2(30000);

    vr_numeros  VARCHAR2(10) := '0123456789';
    vr_letras   VARCHAR2(49) := 'abcdefghijklmnopqrstuvwxyz';
    vr_validar  VARCHAR2(30000);
    vr_caracter VARCHAR2(1);

    TYPE typ_tab_char IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(1);
    vr_tab_char typ_tab_char;

    TYPE typ_tab_char_invalido IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(1);
    vr_tab_char_invalido typ_tab_char_invalido;

  BEGIN

    vr_dsvalida := REPLACE(UPPER(pr_dsvalida),' ','');

    -- Caso nao tenha campos a validar retorna OK
    IF TRIM(vr_dsvalida) IS NULL THEN
      RETURN FALSE;
    END IF;

    -- Numeros
    IF pr_flgnumer THEN
      -- Todos os caracteres devem ser numeros
      vr_validar:= vr_validar || vr_numeros;
    END IF;

    -- Letras
    IF pr_flgletra THEN
      -- Todos os caracteres devem ser numeros
      vr_validar:= vr_validar || vr_letras;
    END IF;

    -- Lista Caracteres Aceitos
    IF TRIM(pr_listaesp) IS NOT NULL THEN
      vr_validar:= vr_validar || pr_listaesp;
    END IF;

    FOR vr_pos IN 1..length(vr_validar) LOOP
      vr_caracter:= SUBSTR(vr_validar,vr_pos,1);
      vr_tab_char(vr_caracter) := vr_caracter;
    END LOOP;

    FOR vr_pos IN 1..length(pr_listainv) LOOP
      vr_caracter:= SUBSTR(pr_listainv,vr_pos,1);
      vr_tab_char_invalido(vr_caracter) := vr_caracter;
    END LOOP;

    FOR vr_pos IN 1..length(vr_dsvalida) LOOP
      vr_caracter:= SUBSTR(vr_dsvalida,vr_pos,1);
      IF NOT vr_tab_char.exists(vr_caracter)       OR
         vr_tab_char_invalido.exists(vr_caracter)  THEN
        RETURN TRUE;
      END IF;
    END LOOP;

    RETURN FALSE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END fn_valida_caracteres;

  PROCEDURE pc_gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE
                       ,pr_dsdcampo IN VARCHAR2
                       ,pr_vlrcampo IN VARCHAR2
                       ,pr_vlcampo2 IN VARCHAR2
                       ,pr_des_erro OUT VARCHAR2) IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_gera_log                            antiga:
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Agosto/2016                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Procedure para gerar log

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

   BEGIN

     IF pr_vlrcampo <> pr_vlcampo2 THEN

       -- Gera log
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => 'cadcop.log'
                                 ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                     'Alterou o campo ' ||
                                                     pr_dsdcampo || ' de ' || pr_vlrcampo ||
                                                     ' para ' || pr_vlcampo2 || '.');

     END IF;

     pr_des_erro := 'OK';

   EXCEPTION
     WHEN OTHERS THEN
       pr_des_erro := 'NOK';
   END pc_gera_log;

  -- Atualiza valor das tabelas craptab
  PROCEDURE pc_atualiza_tab (pr_cdcooper IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                            ,pr_cdacesso IN craptab.cdacesso%type  -- Código de acesso
                            ,pr_dstextab IN craptab.dstextab%type  -- Valor
                            ,pr_des_reto OUT varchar2              -- Retorno Ok ou NOK do procedimento
                            ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
                            ,pr_dscritic OUT VARCHAR2) IS          -- Descrição da crítica

    /* ..........................................................................

      Programa : pc_atualiza_tab

      Sistema  : Rotinas genericas para CADCOP
      Sigla    : TELA_CADCOP
      Autor    : Andrei - RKAM
      Data     : Agosto/2016.                   Ultima atualizacao:

      Dados referentes ao programa:

       Objetivo  : Efetua a atualização das tabelas craptab

       Alteracoes:
     .............................................................................*/

    -- Cursor para validacao da cooperativa conectada
    CURSOR cr_craptab (pr_cdcooper craptab.cdcooper%TYPE
                      ,pr_cdacesso craptab.cdacesso%TYPE) IS
     SELECT craptab.progress_recid
       FROM craptab
      WHERE craptab.cdcooper = pr_cdcooper
        AND upper(craptab.nmsistem) = 'CRED'
        AND upper(craptab.tptabela) = 'GENERI'
        AND craptab.cdempres = 0
        AND upper(craptab.cdacesso) = upper(pr_cdacesso)
        AND craptab.tpregist = 0;
    rw_craptab cr_craptab%rowtype;

    vr_des_reto    VARCHAR2(3);

    --> Tabela de retorno do operadores que estao alocando a tabela especifidada
    vr_tab_locktab GENE0001.typ_tab_locktab;

    -- Variável exceção para locke
    vr_exc_locked EXCEPTION;
    PRAGMA EXCEPTION_INIT(vr_exc_locked, -54);

    -- VARIÁVEIS
    vr_cdcritic PLS_INTEGER := 0; -- Variavel interna para erros
    vr_dscritic varchar2(4000) := ''; -- Variavel interna para erros

    vr_exc_erro EXCEPTION;

    BEGIN

      BEGIN
        -- Busca craptab
        OPEN cr_craptab(pr_cdcooper => pr_cdcooper,
                        pr_cdacesso => pr_cdacesso);

        FETCH cr_craptab INTO rw_craptab;

        -- Gerar erro caso não encontre
        IF cr_craptab%NOTFOUND THEN

           -- Fechar cursor pois teremos raise
           CLOSE cr_craptab;

           BEGIN

            INSERT INTO craptab (craptab.cdcooper
                                ,craptab.nmsistem
                                ,craptab.tptabela
                                ,craptab.cdempres
                                ,craptab.cdacesso
                                ,craptab.tpregist
                                ,craptab.dstextab)
                         VALUES(pr_cdcooper
                               ,'CRED'
                               ,'GENERI'
                               ,0
                               ,pr_cdacesso
                               ,0
                               ,pr_dstextab);
            EXCEPTION
              WHEN OTHERS THEN
                -- Montar mensagem de critica
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao gravar tabela de controle!' || SQLERRM;
                -- volta para o programa chamador
                RAISE vr_exc_erro;

          END;

        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_craptab;

          BEGIN

            UPDATE craptab
               SET craptab.dstextab = pr_dstextab
             WHERE craptab.progress_recid = rw_craptab.progress_recid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Montar mensagem de critica
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar tabela de controle!' || SQLERRM;
                -- volta para o programa chamador
                RAISE vr_exc_erro;

          END;

        END IF;

      EXCEPTION
        WHEN vr_exc_locked THEN
          gene0001.pc_ver_lock(pr_nmtabela    => 'CRAPTAB'
                              ,pr_nrdrecid    => ''
                              ,pr_des_reto    => vr_des_reto
                              ,pt_tab_locktab => vr_tab_locktab);

          IF vr_des_reto = 'OK' THEN
            FOR VR_IND IN 1..vr_tab_locktab.COUNT LOOP
              vr_dscritic := 'Registro sendo alterado em outro terminal (CRAPTAB)' ||
                             ' - ' || vr_tab_locktab(VR_IND).nmusuari;
            END LOOP;
          END IF;

          RAISE vr_exc_erro;

      END;

      -- Se não ocorreram criticas anteriores, retorna OK e volta para o programa chamador
      pr_des_reto := 'OK';

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro nao tratado na TELA_CADCOP.pc_atualiza_tab';
        pr_des_reto := 'NOK';
        RETURN;
    END pc_atualiza_tab; --  pc_atualiza_tab


  PROCEDURE pc_consulta_cooperativa(pr_cddopcao  IN VARCHAR2                --> Código da opção
                                   ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER            --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2               --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS           --> Descrição do erro

    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.dtcdcnpj
          ,crapcop.nmextcop
          ,crapcop.dscomple
          ,crapcop.nmcidade
          ,crapcop.nrtelvoz
          ,crapcop.dsdemail
          ,crapcop.nrtelsac
          ,crapcop.nmrescop
          ,crapcop.dsendcop
          ,crapcop.nmbairro
          ,crapcop.cdufdcop
          ,crapcop.nrtelfax
          ,crapcop.nrtelura
          ,crapcop.nrdocnpj
          ,crapcop.nrendcop
          ,crapcop.nrcepend
          ,crapcop.nrcxapst
          ,crapcop.dsendweb
          ,crapcop.nrtelouv
          ,crapcop.nmtitcop
          ,crapcop.nmctrcop
          ,crapcop.nrcrcctr
          ,crapcop.nrrjunta
          ,crapcop.nrinsmun
          ,crapcop.nrlivcap
          ,crapcop.nrlivepr
          ,crapcop.nrcpftit
          ,crapcop.nrcpfctr
          ,crapcop.dtrjunta
          ,crapcop.nrinsest
          ,crapcop.nrlivapl
          ,crapcop.nrlivdpv
          ,crapcop.cdagedbb
          ,crapcop.cdcnvitg
          ,crapcop.dssigaut
          ,crapcop.nrctactl
          ,crapcop.nrctadbb
          ,crapcop.nrdconta
          ,crapcop.flgcrmag
          ,crapcop.cdsinfmg
          ,decode(crapcop.cdsinfmg,0,' - Nao emite',1,' - Na chegada',2,' - Ate Retirar') dssinfmg
          ,crapcop.taamaxer
          ,crapcop.flgcmtlc
          ,crapcop.vlmaxcen
          ,crapcop.vlmaxutl
          ,crapcop.cdagsede
          ,crapcop.vllimmes
          ,crapcop.vllimapv
          ,crapcop.vlmaxleg
          ,crapcop.cdcrdarr
          ,crapcop.vlcnsscr
          ,crapcop.dsdircop
          ,crapcop.nmdireto
          ,crapcop.flgdopgd
          ,crapcop.dsnotifi##1
          ,crapcop.dsnotifi##2
          ,crapcop.dsnotifi##3
          ,crapcop.dsnotifi##4
          ,crapcop.dsnotifi##5
          ,crapcop.dsnotifi##6
          ,crapcop.dtctrdda
          ,crapcop.idlivdda
          ,crapcop.dslocdda
          ,crapcop.nrctrdda
          ,crapcop.nrfoldda
          ,crapcop.dsciddda
          ,crapcop.dtregcob
          ,crapcop.idlivcob
          ,crapcop.dsloccob
          ,crapcop.dsnomscr
          ,crapcop.dstelscr
          ,crapcop.idregcob
          ,crapcop.nrfolcob
          ,crapcop.dscidcob
          ,crapcop.dsemascr
          ,crapcop.cdagesic
          ,crapcop.nrctasic
          ,crapcop.cdcrdins
          ,crapcop.vltarsic
          ,crapcop.vltardrf
          ,crapcop.cdcliser
          ,crapcop.vlmiplco
          ,crapcop.vlmidbco
          ,crapcop.cdfingrv
          ,crapcop.cdsubgrv
          ,crapcop.cdloggrv
          ,crapcop.hrinisac
          ,crapcop.hrfimsac
          ,crapcop.hriniouv
          ,crapcop.hrfimouv
          ,crapcop.permaxde
          ,crapcop.qtmaxmes
          ,crapcop.cdagectl
          ,crapcop.cdbcoctl
          ,crapcop.flgopstr
          ,crapcop.flgoppag
          ,crapcop.iniopstr
          ,crapcop.fimopstr
          ,crapcop.inioppag
          ,crapcop.fimoppag
          ,crapcop.cdagebcb
          ,crapcop.cdageitg
          ,crapcop.cdmasitg
          ,crapcop.nrctabbd
          ,crapcop.nrctaitg
          ,crapcop.nrctacmp
          ,crapcop.flgdsirc
          ,crapcop.qtdiaenl
          ,crapcop.dsclactr##1
          ,crapcop.dsclactr##2
          ,crapcop.dsclactr##3
          ,crapcop.dsclactr##4
          ,crapcop.dsclactr##5
          ,crapcop.dsclactr##6
          ,crapcop.dsclaccb##1
          ,crapcop.dsclaccb##2
          ,crapcop.dsclaccb##3
          ,crapcop.dsclaccb##4
          ,crapcop.dsclaccb##5
          ,crapcop.dsclaccb##6
          ,crapcop.hrproces
          ,crapcop.hrfinprc
          ,crapcop.hrinigps
          ,crapcop.hrfimgps
          ,crapcop.hrlimsic
          ,crapcop.qttmpsgr
          ,crapcop.flgkitbv
          ,crapcop.qtdiasus
          ,crapcop.hriniatr
          ,crapcop.hrfimatr
          ,crapcop.flgofatr
          ,crapcop.flsaqpre
          ,crapcop.flrecpct
          ,crapcop.dsdempst
          ,crapcop.qtmeatel
          ,crapcop.flintcdc
          ,crapcop.tpcdccop
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    /* Pagamento VR-Boleto */
    CURSOR cr_craptab(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT dstextab
      FROM craptab tab
     WHERE tab.cdcooper = pr_cdcooper
       AND UPPER(tab.nmsistem) = 'CRED'
       AND UPPER(tab.tptabela) = 'GENERI'
       AND tab.cdempres = 00
       AND UPPER(tab.cdacesso) = 'HRVRBOLETO';

    --Variaveis locais
    vr_dsemlctr craptab.dstextab%TYPE := '';
    vr_dstextab craptab.dstextab%TYPE := '';
    vr_cdoperad VARCHAR2(100);
    vr_cdcooper NUMBER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_flgvrbol INTEGER;
    vr_hrvrbini VARCHAR2(5);
    vr_hrvrbfim VARCHAR2(5);
    vr_nrctabol NUMBER(25);
    vr_cdlcrbol craptab.dstextab%TYPE;
    vr_correspo VARCHAR2(100);
    vr_vltfcxsb craptab.dstextab%TYPE;
    vr_vltfcxcb craptab.dstextab%TYPE;
    vr_vlrtrfib craptab.dstextab%TYPE;
    vr_cdagectl crapcop.cdagectl%TYPE;
    vr_cddigage NUMBER(25);
    vr_flgdigok BOOLEAN;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    vr_exc_saida EXCEPTION;

    -- Array para guardar o split dos dados contidos na dstexttb
    vr_vet_dados gene0002.typ_split;

  BEGIN

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCOP'
                              ,pr_action => null);

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);

    FETCH cr_crapcop into rw_crapcop;

    IF cr_crapcop%NOTFOUND THEN

      CLOSE cr_crapcop;

      vr_cdcritic := 794;
      RAISE vr_exc_saida;

    ELSE

      CLOSE cr_crapcop;

    END IF;

    vr_dsemlctr:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'USUARI'
                                            ,pr_cdempres => 00
                                            ,pr_cdacesso => 'EMLCTBCOOP'
                                            ,pr_tpregist => 0);

    /* Pagamento VR-Boleto */
    OPEN cr_craptab(pr_cdcooper => vr_cdcooper);

    FETCH cr_craptab into vr_dstextab;

    -- Efetuar o split das informacoes contidas na dstextab separados por ;
    vr_vet_dados := gene0002.fn_quebra_string(pr_string  => vr_dstextab
                                             ,pr_delimit => ';');

    -- Pesquisar o vetor de faixas partindo do final ate o inicio
    FOR vr_pos IN REVERSE 1..vr_vet_dados.COUNT LOOP

      IF vr_pos = 1 THEN

          vr_flgvrbol := (CASE upper(vr_vet_dados(vr_pos))
                            WHEN 'YES' THEN
                              1
                            ELSE
                              0
                          END);

      ELSIF vr_pos = 2 THEN
          vr_hrvrbini := to_char(to_date(vr_vet_dados(vr_pos),'sssss'),'hh24:mi');
      ELSIF vr_pos = 3 THEN
          vr_hrvrbfim := to_char(to_date(vr_vet_dados(vr_pos),'sssss'),'hh24:mi');
      END IF;

    END LOOP;

    --Fecha o cursor
    CLOSE cr_craptab;

    vr_nrctabol:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'GENERI'
                                            ,pr_cdempres => 00
                                            ,pr_cdacesso => 'CTAEMISBOL'
                                            ,pr_tpregist => 0);

    vr_cdlcrbol:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'GENERI'
                                            ,pr_cdempres => 00
                                            ,pr_cdacesso => 'LCREMISBOL'
                                            ,pr_tpregist => 0);

    vr_correspo:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'USUARI'
                                            ,pr_cdempres => 11
                                            ,pr_cdacesso => 'CORRESPOND'
                                            ,pr_tpregist => 000);

    vr_vltfcxsb:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'GENERI'
                                            ,pr_cdempres => 00
                                            ,pr_cdacesso => 'GPSCXASCOD'
                                            ,pr_tpregist => 0);

    vr_vltfcxcb:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'GENERI'
                                            ,pr_cdempres => 00
                                            ,pr_cdacesso => 'GPSCXACCOD'
                                            ,pr_tpregist => 0);

    vr_vlrtrfib:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'GENERI'
                                            ,pr_cdempres => 00
                                            ,pr_cdacesso => 'GPSINTBANK'
                                            ,pr_tpregist => 0);

    /* Verifica Digito da Agëncia */
    vr_cdagectl:= to_number(to_char(rw_crapcop.cdagectl || '0','00000'));
    vr_flgdigok:= GENE0005.fn_calc_digito (pr_nrcalcul => vr_cdagectl);
    vr_cddigage := to_number(SUBSTR(to_char(vr_cdagectl),LENGTH(to_char(vr_cdagectl)),1));

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => null, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'crapcop', pr_tag_cont => null, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdcooper', pr_tag_cont => to_char(rw_crapcop.cdcooper,'990'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapcop.nmrescop, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrdocnpj', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapcop.nrdocnpj,pr_inpessoa => 2), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dtcdcnpj', pr_tag_cont => to_char(rw_crapcop.dtcdcnpj,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nmextcop', pr_tag_cont => rw_crapcop.nmextcop, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dsendcop', pr_tag_cont => rw_crapcop.dsendcop, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrendcop', pr_tag_cont => to_char(rw_crapcop.nrendcop,'fm9999999g990'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dscomple', pr_tag_cont => rw_crapcop.dscomple, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nmbairro', pr_tag_cont => rw_crapcop.nmbairro, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrcepend', pr_tag_cont => gene0002.fn_mask(rw_crapcop.nrcepend,'99.999.999'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nmcidade', pr_tag_cont => rw_crapcop.nmcidade, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdufdcop', pr_tag_cont => rw_crapcop.cdufdcop, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrcxapst', pr_tag_cont => to_char(rw_crapcop.nrcxapst,'fm9999999g990'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrtelvoz', pr_tag_cont => rw_crapcop.nrtelvoz, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrtelfax', pr_tag_cont => rw_crapcop.nrtelfax, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dsendweb', pr_tag_cont => rw_crapcop.dsendweb, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dsdemail', pr_tag_cont => rw_crapcop.dsdemail, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrtelura', pr_tag_cont => rw_crapcop.nrtelura, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrtelouv', pr_tag_cont => rw_crapcop.nrtelouv, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dsdempst', pr_tag_cont => rw_crapcop.dsdempst, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrtelsac', pr_tag_cont => rw_crapcop.nrtelsac, pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nmtitcop', pr_tag_cont => rw_crapcop.nmtitcop, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrcpftit', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapcop.nrcpftit,pr_inpessoa => 1), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nmctrcop', pr_tag_cont => rw_crapcop.nmctrcop, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrcpfctr', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapcop.nrcpfctr,pr_inpessoa => 1), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dsemlctr', pr_tag_cont => vr_dsemlctr, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrcrcctr', pr_tag_cont => rw_crapcop.nrcrcctr, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dtrjunta', pr_tag_cont => to_char(rw_crapcop.dtrjunta,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrrjunta', pr_tag_cont => to_char(rw_crapcop.nrrjunta,'fm999g999g99999g0'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrinsest', pr_tag_cont => to_char(rw_crapcop.nrinsest,'fm999g999g999g999g0'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrinsmun', pr_tag_cont => to_char(rw_crapcop.nrinsmun,'fm999g999g999g999g0'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrlivapl', pr_tag_cont => to_char(rw_crapcop.nrlivapl,'fm999g990'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrlivcap', pr_tag_cont => to_char(rw_crapcop.nrlivcap,'fm999g990'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrlivdpv', pr_tag_cont => to_char(rw_crapcop.nrlivdpv,'fm999g990'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrlivepr', pr_tag_cont => to_char(rw_crapcop.nrlivepr,'fm999g990'), pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdbcoctl', pr_tag_cont => to_char(rw_crapcop.cdbcoctl,'fm000'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdagectl', pr_tag_cont => to_char(rw_crapcop.cdagectl,'fm0000'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cddigage', pr_tag_cont => to_char(vr_cddigage,'fm0'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'flgopstr', pr_tag_cont => rw_crapcop.flgopstr, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'flgoppag', pr_tag_cont => rw_crapcop.flgoppag, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'iniopstr', pr_tag_cont => to_char(to_date(rw_crapcop.iniopstr,'sssss'),'hh24:mi'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'fimopstr', pr_tag_cont => to_char(to_date(rw_crapcop.fimopstr,'sssss'),'hh24:mi'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'inioppag', pr_tag_cont => to_char(to_date(rw_crapcop.inioppag,'sssss'),'hh24:mi'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'fimoppag', pr_tag_cont => to_char(to_date(rw_crapcop.fimoppag,'sssss'),'hh24:mi'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdagebcb', pr_tag_cont => to_char(rw_crapcop.cdagebcb,'fm99g990'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdagedbb', pr_tag_cont => to_char(rw_crapcop.cdagedbb,'fm999999999g0'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdageitg', pr_tag_cont => rw_crapcop.cdageitg, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdcnvitg', pr_tag_cont => rw_crapcop.cdcnvitg, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdmasitg', pr_tag_cont => rw_crapcop.cdmasitg, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dssigaut', pr_tag_cont => rw_crapcop.dssigaut, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrctabbd', pr_tag_cont => to_char(rw_crapcop.nrctabbd,'fm9999g999g0'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrctactl', pr_tag_cont => to_char(rw_crapcop.nrctactl,'fm9999g999g0'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrctaitg', pr_tag_cont => rw_crapcop.nrctaitg, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrctadbb', pr_tag_cont => to_char(rw_crapcop.nrctadbb,'fm9999g999g0'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrctacmp', pr_tag_cont => to_char(rw_crapcop.nrctacmp,'fm9999g999g0'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => to_char(rw_crapcop.nrdconta,'fm9999g999g0'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'flgdsirc', pr_tag_cont => rw_crapcop.flgdsirc, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'flgcrmag', pr_tag_cont => rw_crapcop.flgcrmag, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'qtdiaenl', pr_tag_cont => rw_crapcop.qtdiaenl, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdsinfmg', pr_tag_cont => rw_crapcop.cdsinfmg, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dssinfmg', pr_tag_cont => rw_crapcop.dssinfmg, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'taamaxer', pr_tag_cont => rw_crapcop.taamaxer, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'flintcdc', pr_tag_cont => rw_crapcop.flintcdc, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'tpcdccop', pr_tag_cont => rw_crapcop.tpcdccop, pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'hhvrbfim', pr_tag_cont => vr_hrvrbfim, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'hhvrbini', pr_tag_cont => vr_hrvrbini, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'flgvrbol', pr_tag_cont => vr_flgvrbol, pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'flgcmtlc', pr_tag_cont => rw_crapcop.flgcmtlc, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vllimapv', pr_tag_cont => to_char(rw_crapcop.vllimapv,'fm999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdcrdarr', pr_tag_cont => rw_crapcop.cdcrdarr, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vlmaxcen', pr_tag_cont => to_char(rw_crapcop.vlmaxcen,'fm999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vlmaxleg', pr_tag_cont => to_char(rw_crapcop.vlmaxleg,'fm999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vlmaxutl', pr_tag_cont => to_char(rw_crapcop.vlmaxutl,'fm999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdagsede', pr_tag_cont => to_char(rw_crapcop.cdagsede,'fm990'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vlcnsscr', pr_tag_cont => to_char(rw_crapcop.vlcnsscr,'fm999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vllimmes', pr_tag_cont => to_char(rw_crapcop.vllimmes,'fm999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrctabol', pr_tag_cont => to_char(vr_nrctabol,'fm9999g999g0'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdlcrbol', pr_tag_cont => nvl(vr_cdlcrbol,0), pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dsclactr', pr_tag_cont => rw_crapcop.dsclactr##1 || ' ' ||
                                                                                                                                    rw_crapcop.dsclactr##2 || ' ' ||
                                                                                                                                    rw_crapcop.dsclactr##3 || ' ' ||
                                                                                                                                    rw_crapcop.dsclactr##4 || ' ' ||
                                                                                                                                    rw_crapcop.dsclactr##5 || ' ' ||
                                                                                                                                    rw_crapcop.dsclactr##6, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dsclaccb', pr_tag_cont => rw_crapcop.dsclaccb##1 || ' ' ||
                                                                                                                                    rw_crapcop.dsclaccb##2 || ' ' ||
                                                                                                                                    rw_crapcop.dsclaccb##3 || ' ' ||
                                                                                                                                    rw_crapcop.dsclaccb##4 || ' ' ||
                                                                                                                                    rw_crapcop.dsclaccb##5 || ' ' ||
                                                                                                                                    rw_crapcop.dsclaccb##6, pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dsdircop', pr_tag_cont => rw_crapcop.dsdircop, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nmdireto', pr_tag_cont => rw_crapcop.nmdireto, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'flgdopgd', pr_tag_cont => rw_crapcop.flgdopgd, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'hrproces', pr_tag_cont => to_char(to_date(rw_crapcop.hrproces,'sssss'),'hh24:mi:ss'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'hrfinprc', pr_tag_cont => to_char(to_date(rw_crapcop.hrfinprc,'sssss'),'hh24:mi:ss'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dsnotifi', pr_tag_cont => rw_crapcop.dsnotifi##1 || ' ' ||
                                                                                                                                    rw_crapcop.dsnotifi##2 || ' ' ||
                                                                                                                                    rw_crapcop.dsnotifi##3 || ' ' ||
                                                                                                                                    rw_crapcop.dsnotifi##4 || ' ' ||
                                                                                                                                    rw_crapcop.dsnotifi##5 || ' ' ||
                                                                                                                                    rw_crapcop.dsnotifi##6, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrconven', pr_tag_cont => substr(vr_correspo,1,9), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrversao', pr_tag_cont => substr(vr_correspo,11,3), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vldataxa', pr_tag_cont => substr(vr_correspo,15,6), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vltxinss', pr_tag_cont => substr(vr_correspo,22,9), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dtctrdda', pr_tag_cont => to_char(rw_crapcop.dtctrdda,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrctrdda', pr_tag_cont => rw_crapcop.nrctrdda, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'idlivdda', pr_tag_cont => rw_crapcop.idlivdda, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrfoldda', pr_tag_cont => rw_crapcop.nrfoldda, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dslocdda', pr_tag_cont => rw_crapcop.dslocdda, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dsciddda', pr_tag_cont => rw_crapcop.dsciddda, pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dtregcob', pr_tag_cont => to_char(rw_crapcop.dtregcob,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'idregcob', pr_tag_cont => rw_crapcop.idregcob, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'idlivcob', pr_tag_cont => rw_crapcop.idlivcob, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrfolcob', pr_tag_cont => rw_crapcop.nrfolcob, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dsloccob', pr_tag_cont => rw_crapcop.dsloccob, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dscidcob', pr_tag_cont => rw_crapcop.dscidcob, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dsnomscr', pr_tag_cont => rw_crapcop.dsnomscr, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dsemascr', pr_tag_cont => rw_crapcop.dsemascr, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'dstelscr', pr_tag_cont => rw_crapcop.dstelscr, pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdagesic', pr_tag_cont => to_char(rw_crapcop.cdagesic,'fm999g990'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'nrctasic', pr_tag_cont => to_char(rw_crapcop.nrctasic,'fm9g999g990'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdcrdins', pr_tag_cont => rw_crapcop.cdcrdins, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vltarsic', pr_tag_cont => to_char(rw_crapcop.vltarsic,'fm0d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vltardrf', pr_tag_cont => to_char(rw_crapcop.vltardrf,'fm0d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vltfcxcb', pr_tag_cont => to_char(vr_vltfcxcb,'fm0d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vltfcxsb', pr_tag_cont => to_char(vr_vltfcxsb,'fm0d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vlrtrfib', pr_tag_cont => to_char(vr_vlrtrfib,'fm0d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'hrinigps', pr_tag_cont => to_char(to_date(rw_crapcop.hrinigps,'sssss'),'hh24:mi'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'hrfimgps', pr_tag_cont => to_char(to_date(rw_crapcop.hrfimgps,'sssss'),'hh24:mi'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'hrlimsic', pr_tag_cont => to_char(to_date(rw_crapcop.hrlimsic,'sssss'),'hh24:mi'), pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'qttmpsgr', pr_tag_cont => to_char(to_date(rw_crapcop.qttmpsgr,'sssss'),'hh24:mi'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'flgkitbv', pr_tag_cont => rw_crapcop.flgkitbv, pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'qtdiasus', pr_tag_cont => rw_crapcop.qtdiasus, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'hriniatr', pr_tag_cont => to_char(to_date(rw_crapcop.hriniatr,'sssss'),'hh24:mi'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'hrfimatr', pr_tag_cont => to_char(to_date(rw_crapcop.hrfimatr,'sssss'),'hh24:mi'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'flgofatr', pr_tag_cont => rw_crapcop.flgofatr, pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdcliser', pr_tag_cont => rw_crapcop.cdcliser, pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vlmiplco', pr_tag_cont => to_char(rw_crapcop.vlmiplco,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'vlmidbco', pr_tag_cont => to_char(rw_crapcop.vlmidbco,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdfingrv', pr_tag_cont => to_char(rw_crapcop.cdfingrv,'000000000000000'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdsubgrv', pr_tag_cont => rw_crapcop.cdsubgrv, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'cdloggrv', pr_tag_cont => rw_crapcop.cdloggrv, pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'flsaqpre', pr_tag_cont => rw_crapcop.flsaqpre, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'permaxde', pr_tag_cont => rw_crapcop.permaxde, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'qtmaxmes', pr_tag_cont => rw_crapcop.qtmaxmes, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'flrecpct', pr_tag_cont => rw_crapcop.flrecpct, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'qtmeatel', pr_tag_cont => rw_crapcop.qtmeatel, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'hrinisac', pr_tag_cont => to_char(to_date(rw_crapcop.hrinisac,'sssss'),'hh24:mi'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'hrfimsac', pr_tag_cont => to_char(to_date(rw_crapcop.hrfimsac,'sssss'),'hh24:mi'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'hriniouv', pr_tag_cont => to_char(to_date(rw_crapcop.hriniouv,'sssss'),'hh24:mi'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'crapcop', pr_posicao => 0, pr_tag_nova => 'hrfimouv', pr_tag_cont => to_char(to_date(rw_crapcop.hrfimouv,'sssss'),'hh24:mi'), pr_des_erro => vr_dscritic);


    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TELA_CADCOP.pc_consulta_cooperativa: ' || SQLERRM;
      pr_des_erro := 'NOK';

      pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_consulta_cooperativa;

  PROCEDURE pc_alterar_cooperativa(pr_cddopcao IN VARCHAR2              --> Código da opção
                                  ,pr_cddepart IN VARCHAR2              --> Departamento do operador
                                  ,pr_dtmvtolt IN VARCHAR2              --> Data de movimento
                                  ,pr_nmrescop IN crapcop.nmrescop%TYPE --> Nome resumido da cooperativa
                                  ,pr_nrdocnpj IN crapcop.nrdocnpj%TYPE --> Número do CNPJ
                                  ,pr_nmextcop IN crapcop.nmextcop%TYPE --> Nome extenso da cooperativa
                                  ,pr_dtcdcnpj IN VARCHAR2              --> Data do CNPJ
                                  ,pr_dsendcop IN crapcop.dsendcop%TYPE --> Endereço
                                  ,pr_nrendcop IN crapcop.nrendcop%TYPE --> Número do endereço
                                  ,pr_dscomple IN crapcop.dscomple%TYPE --> Complemento
                                  ,pr_nmbairro IN crapcop.nmbairro%TYPE --> Nome do bairro
                                  ,pr_nrcepend IN crapcop.nrcepend%TYPE --> CEP
                                  ,pr_nmcidade IN crapcop.nmcidade%TYPE --> Nome da cidade
                                  ,pr_cdufdcop IN crapcop.cdufdcop%TYPE --> UF
                                  ,pr_nrcxapst IN crapcop.nrcxapst%TYPE --> Caixa postal
                                  ,pr_nrtelvoz IN crapcop.nrtelvoz%TYPE --> Número do telefone
                                  ,pr_nrtelouv IN crapcop.nrtelouv%TYPE --> Ouvidoria
                                  ,pr_dsendweb IN crapcop.dsendweb%TYPE --> Endereço WEB
                                  ,pr_nrtelura IN crapcop.nrtelura%TYPE --> URA
                                  ,pr_dsdemail IN crapcop.dsdemail%TYPE --> E-mail
                                  ,pr_nrtelfax IN crapcop.nrtelfax%TYPE --> FAX
                                  ,pr_dsdempst IN crapcop.dsdempst%TYPE --> E-mail do presidente
                                  ,pr_nrtelsac IN crapcop.nrtelsac%TYPE --> SAC
                                  ,pr_nmtitcop IN crapcop.nmtitcop%TYPE --> Nome presidente
                                  ,pr_nrcpftit IN crapcop.nrcpftit%TYPE --> CPF do presidente
                                  ,pr_nmctrcop IN crapcop.nmctrcop%TYPE --> Nome do contador
                                  ,pr_nrcpfctr IN crapcop.nrcpfctr%TYPE --> CPF do contador
                                  ,pr_nrcrcctr IN crapcop.nrcrcctr%TYPE --> CRC
                                  ,pr_dsemlctr IN crapcop.dsemlctr%TYPE --> E-mail do contador
                                  ,pr_nrrjunta IN crapcop.nrrjunta%TYPE --> Número registro junta comercial
                                  ,pr_dtrjunta IN VARCHAR2              --> Data do registro junta comercial
                                  ,pr_nrinsest IN crapcop.nrinsest%TYPE --> Inscrição estadual
                                  ,pr_nrinsmun IN crapcop.nrinsmun%TYPE --> Inscrição municipal
                                  ,pr_nrlivapl IN crapcop.nrlivapl%TYPE --> Livro de aplicações
                                  ,pr_nrlivcap IN crapcop.nrlivcap%TYPE --> Livro de capital
                                  ,pr_nrlivdpv IN crapcop.nrlivdpv%TYPE --> Livro de Depóstio a vista
                                  ,pr_nrlivepr IN crapcop.nrlivepr%TYPE --> Livro de empréstimos
                                  ,pr_cdbcoctl IN crapcop.cdbcoctl%TYPE --> Código COMPE CECRED
                                  ,pr_cdagebcb IN crapcop.cdagebcb%TYPE --> Agência BANCOOB
                                  ,pr_cdagedbb IN crapcop.cdagedbb%TYPE --> Agencia BB
                                  ,pr_cdageitg IN crapcop.cdageitg%TYPE --> Agencia conta itg da coop
                                  ,pr_cdcnvitg IN crapcop.cdcnvitg%TYPE --> Número convenio conta itg
                                  ,pr_cdmasitg IN crapcop.cdmasitg%TYPE --> Código massificado da conta itg
                                  ,pr_nrctabbd IN crapcop.nrctabbd%TYPE --> Número da conta convenio BB
                                  ,pr_nrctactl IN crapcop.nrctactl%TYPE --> Numero da conta junto a CECRED
                                  ,pr_nrctaitg IN crapcop.nrctaitg%TYPE --> Conta de integracao da Cooperativa
                                  ,pr_nrctadbb IN crapcop.nrctadbb%TYPE --> Numero da conta convenio no BB
                                  ,pr_nrctacmp IN crapcop.nrctacmp%TYPE --> Conta compe CECRED
                                  ,pr_nrdconta IN crapcop.nrdconta%TYPE --> Número da conta da cooperativa
                                  ,pr_flgdsirc IN crapcop.flgdsirc%TYPE --> SIRC 0 - Capitl / 1 - Interior
                                  ,pr_flgcrmag IN crapcop.flgcrmag%TYPE --> Utiliza Cartao Magnetico
                                  ,pr_cdagectl IN crapcop.cdagectl%TYPE --> Codigo da agencia da Central
                                  ,pr_dstelscr IN crapcop.dstelscr%TYPE --> Tel. responsavel pela central de risco
                                  ,pr_cdcrdarr IN crapcop.cdcrdarr%TYPE --> Codigo de credenciamento para arrecadacoes
                                  ,pr_cdagsede IN crapcop.cdagsede%TYPE --> PA considerado sede para o INSS
                                  ,pr_nrctabol IN crapass.nrdconta%TYPE --> Conta da cooperativa para emissao de boletos
                                  ,pr_cdlcrbol IN craplcr.cdlcremp%TYPE --> Linha de credito para emissao de boletos
                                  ,pr_vltxinss IN NUMBER                --> Tarifa de recebimento de INSS
                                  ,pr_flgargps IN crapcop.flgargps%TYPE --> Arrecada GPS
                                  ,pr_vldataxa IN NUMBER                --> Tarifa de pagamento
                                  ,pr_nrversao IN NUMBER                --> Versao do software
                                  ,pr_nrconven IN NUMBER                --> Número do convenio
                                  ,pr_qttmpsgr IN VARCHAR2              --> Tempo para efetuar a sangria
                                  ,pr_hrinisac IN VARCHAR2              --> Horário inicial para atendimento
                                  ,pr_hrfimsac IN VARCHAR2              --> Horário final para atendimento
                                  ,pr_hriniouv IN VARCHAR2              --> Horário inicial para ouvidoria
                                  ,pr_hrfimouv IN VARCHAR2              --> Horário final para ouvidoria
                                  ,pr_vltfcxsb IN NUMBER                --> Tarifa de GPS sem Cod.Barras
                                  ,pr_vltfcxcb IN NUMBER                --> Tarifa de GPS com Cod.Barras
                                  ,pr_vlrtrfib IN NUMBER                --> Tarifa de GPS Internet Banking
                                  ,pr_flrecpct IN crapcop.flrecpct%TYPE --> Permite reciprocidade 0 - Nao / 1 - Sim
                                  ,pr_flsaqpre IN crapcop.flsaqpre%TYPE --> Isentar cobrança de tarifas e saques presenciais ( 0 - isentar / 1 - Nao isentar)
                                  ,pr_flgcmtlc IN crapcop.flgcmtlc%TYPE --> Comite local
                                  ,pr_qtmaxmes IN crapcop.qtmaxmes%TYPE --> Quantidade maxima de meses de desconto
                                  ,pr_permaxde IN crapcop.permaxde%TYPE --> ercentual maximo de desconto manual
                                  ,pr_cdloggrv IN crapcop.cdloggrv%TYPE --> Login do usuario no gravames
                                  ,pr_flgofatr IN crapcop.flgofatr%TYPE --> Oferta autorizacao de debito
                                  ,pr_qtdiasus IN crapcop.qtdiasus%TYPE --> Quantidade de dias de suspensao
                                  ,pr_cdcliser IN crapcop.cdcliser%TYPE --> Codigo do Cliente no SERASA
                                  ,pr_vlmiplco IN crapcop.vlmiplco%TYPE --> Valor minimo para contratacao do plano de cotas
                                  ,pr_vlmidbco IN crapcop.vlmidbco%TYPE --> Valor minimo para efetuar o debito de cotas
                                  ,pr_cdfingrv IN crapcop.cdfingrv%TYPE --> Codigo da financeira no gravames
                                  ,pr_cdsubgrv IN crapcop.cdsubgrv%TYPE --> Subcodigo do usuario no gravames
                                  ,pr_hriniatr IN VARCHAR2              --> Horario inicial para autorizacao de debito
                                  ,pr_hrfimatr IN VARCHAR2              --> Hora final para a autorizacao de debito
                                  ,pr_flgkitbv IN crapcop.flgkitbv%TYPE --> Trabalaha com kit de boas vindas
                                  ,pr_hrinigps IN VARCHAR2              --> Hora inicial para arrecadacao de guias de GPS do Sicredi
                                  ,pr_hrfimgps IN VARCHAR2              --> Hora final para arrecadacao de guias de GPS do Sicredi
                                  ,pr_hrlimsic IN VARCHAR2              --> Horario limite pagamento SICREDI
                                  ,pr_dtctrdda IN VARCHAR2              --> Contem a data do registro do contrato DDA
                                  ,pr_nrctrdda IN crapcop.nrctrdda%TYPE --> Número do contrato DDA em cartorio
                                  ,pr_idlivdda IN crapcop.idlivdda%TYPE --> numero do livro de registro do contrato DDA
                                  ,pr_nrfoldda IN crapcop.nrfoldda%TYPE --> numero da folha do livro de registro do contrato DDA
                                  ,pr_dslocdda IN crapcop.dslocdda%TYPE --> local onde ocorreu o registro do contrato DDA
                                  ,pr_dsciddda IN crapcop.dsciddda%TYPE --> cidade onde ocorreu o registro do contato DDA
                                  ,pr_dtregcob IN VARCHAR2              --> data de registro da cobranca
                                  ,pr_idregcob IN crapcop.idregcob%TYPE --> identificador de registro da cobranca
                                  ,pr_idlivcob IN crapcop.idlivcob%TYPE --> identificador do livro de registro da cobranca
                                  ,pr_nrfolcob IN crapcop.nrfolcob%TYPE --> numero da folha do registro de cobranca
                                  ,pr_dsloccob IN crapcop.dsloccob%TYPE --> local de registro da cobranca
                                  ,pr_dscidcob IN crapcop.dscidcob%TYPE --> cidade de registro da cobranca
                                  ,pr_dsnomscr IN crapcop.dsnomscr%TYPE --> nome do responsavel pelas informacoes da central de risco
                                  ,pr_dsemascr IN crapcop.dsemascr%TYPE --> e-mail do responsavel pelas informacoes da central de risco
                                  ,pr_cdagesic IN crapcop.cdagesic%TYPE --> Numero da agencia Sicredi
                                  ,pr_nrctasic IN crapcop.nrctasic%TYPE --> conta convenio no Sicredi
                                  ,pr_cdcrdins IN crapcop.cdcrdins%TYPE --> Codigo de credencimento GPS
                                  ,pr_vltarsic IN crapcop.vltarsic%TYPE --> Valor da tarifa do SICREDI
                                  ,pr_vltardrf IN crapcop.vltardrf%TYPE --> Valor da tarifa de tributo federal do Sicredi
                                  ,pr_hrproces IN VARCHAR2              --> Horario de verificacao se o processo foi solicitado
                                  ,pr_hrfinprc IN VARCHAR2              --> Horario Final Verificacao Proces
                                  ,pr_dsdircop IN crapcop.dsdircop%TYPE --> Diretorio da Cooperativa onde esta o sistema
                                  ,pr_dsnotifi IN VARCHAR2              --> Texto para notificar o responsavel pelo processamento diario
                                  ,pr_nmdireto IN crapcop.nmdireto%TYPE --> Diretorio Padrao Arquivos Textos
                                  ,pr_flgdopgd IN crapcop.flgdopgd%TYPE --> Participa do progrid ou nao
                                  ,pr_dsclactr IN VARCHAR2              --> Descricao da clausula do contrato da conta-corrente
                                  ,pr_dsclaccb IN VARCHAR2              --> Clausula do contrato de cobranca
                                  ,pr_vlmaxcen IN crapcop.vlmaxcen%TYPE --> Valor maximo legal a ser emprestado pela Cooperativa
                                  ,pr_vlmaxleg IN crapcop.vlmaxleg%TYPE --> Valor maximo legal a ser emprestado pela cooperativa ao associado
                                  ,pr_vlmaxutl IN crapcop.vlmaxutl%TYPE --> Valor maximo utilizado pelo associado nos emprestimos
                                  ,pr_vlcnsscr IN crapcop.vlcnsscr%TYPE --> Valor para Consulta SCR
                                  ,pr_vllimmes IN crapcop.vllimmes%TYPE --> Valor do limite disponivel para emprestimo no mes
                                  ,pr_qtdiaenl IN crapcop.qtdiaenl%TYPE --> Quantidade de dias para verificacao de envelopes TAA pendentes
                                  ,pr_cdsinfmg IN crapcop.cdsinfmg%TYPE --> Emissao do inform de chegada do cartao magnetico para o cooperado
                                  ,pr_taamaxer IN crapcop.taamaxer%TYPE --> Qtd. Max. de tentivas da senha no TAA
                                  ,pr_vllimapv IN crapcop.vllimapv%TYPE --> Limite necessita de aprovacao
                                  ,pr_qtmeatel IN crapcop.qtmeatel%TYPE --> Quantidade de Meses para atualizacao Telefone
                                  ,pr_flintcdc IN crapcop.flintcdc%TYPE --> Possui CDC                                  
                                  ,pr_tpcdccop IN crapcop.tpcdccop%TYPE --> Tipo CDC
                                  ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER            --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2               --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2) IS           --> Descrição do erro

    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.cdagectl
          ,crapcop.cdcrdarr
          ,crapcop.dtcdcnpj
          ,crapcop.qttmpsgr
          ,crapcop.flgcmtlc
          ,crapcop.nmrescop
          ,crapcop.nrdocnpj
          ,crapcop.nmextcop
          ,crapcop.dsendcop
          ,crapcop.dscomple
          ,crapcop.nrendcop
          ,crapcop.nmbairro
          ,crapcop.nrcepend
          ,crapcop.nmcidade
          ,crapcop.cdufdcop
          ,crapcop.nrcxapst
          ,crapcop.nrtelvoz
          ,crapcop.nrtelfax
          ,crapcop.dsendweb
          ,crapcop.dsdemail
          ,crapcop.dsdempst
          ,crapcop.nmtitcop
          ,crapcop.nrcpftit
          ,crapcop.nmctrcop
          ,crapcop.dsemlctr
          ,crapcop.nrcpfctr
          ,crapcop.nrcrcctr
          ,crapcop.nrrjunta
          ,crapcop.dtrjunta
          ,crapcop.nrinsest
          ,crapcop.nrinsmun
          ,crapcop.nrlivapl
          ,crapcop.nrlivdpv
          ,crapcop.nrlivepr
          ,crapcop.cdbcoctl
          ,crapcop.cdagebcb
          ,crapcop.cdagedbb
          ,crapcop.cdageitg
          ,crapcop.cdcnvitg
          ,crapcop.cdmasitg
          ,crapcop.nrlivcap
          ,crapcop.nrctabbd
          ,crapcop.nrctactl
          ,crapcop.nrctaitg
          ,crapcop.nrctacmp
          ,crapcop.nrdconta
          ,crapcop.flgcrmag
          ,crapcop.flgdsirc
          ,crapcop.cdsinfmg
          ,crapcop.vlmaxcen
          ,crapcop.vlmaxutl
          ,crapcop.vlcnsscr
          ,crapcop.vllimapv
          ,crapcop.dsdircop
          ,crapcop.nrctadbb
          ,crapcop.vlmaxleg
          ,crapcop.nmdireto
          ,crapcop.flgdopgd
          ,crapcop.hrproces
          ,crapcop.hrfinprc
          ,crapcop.dtctrdda
          ,crapcop.nrctrdda
          ,crapcop.nrfoldda
          ,crapcop.dslocdda
          ,crapcop.dsciddda
          ,crapcop.vlmiplco
          ,crapcop.vlmidbco
          ,crapcop.idlivdda
          ,crapcop.cdfingrv
          ,crapcop.cdsubgrv
          ,crapcop.cdagesic
          ,crapcop.nrctasic
          ,crapcop.cdcrdins
          ,crapcop.cdloggrv
          ,crapcop.cdagsins
          ,crapcop.vltardrf
          ,crapcop.hrinigps
          ,crapcop.hrfimgps
          ,crapcop.hrlimsic
          ,crapcop.flsaqpre
          ,crapcop.permaxde
          ,crapcop.qtmaxmes
          ,crapcop.flrecpct
          ,crapcop.flgargps
          ,crapcop.qtdiaenl
          ,crapcop.qtmeatel
          ,crapcop.flintcdc
          ,crapcop.tpcdccop
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    CURSOR cr_crapcop_agectl(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_cdagectl IN crapcop.cdagectl%TYPE) IS
    SELECT crapcop.cdcooper
      FROM crapcop
     WHERE crapcop.cdagectl = pr_cdagectl
       AND crapcop.cdcooper <> pr_cdcooper;
    rw_crapcop_agectl cr_crapcop_agectl%ROWTYPE;

    CURSOR cr_craptab(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nmsistem IN craptab.nmsistem%TYPE
                     ,pr_tptabela IN craptab.tptabela%TYPE
                     ,pr_cdempres IN craptab.cdempres%TYPE
                     ,pr_cdacesso IN craptab.cdacesso%TYPE) IS
    SELECT tab.progress_recid
          ,tab.dstextab
      FROM craptab tab
     WHERE tab.cdcooper = pr_cdcooper
       AND UPPER(tab.nmsistem) = UPPER(pr_nmsistem)
       AND UPPER(tab.tptabela) = UPPER(pr_tptabela)
       AND tab.cdempres = pr_cdempres
       AND UPPER(tab.cdacesso) = UPPER(pr_cdacesso);
    rw_craptab cr_craptab%ROWTYPE;

    CURSOR cr_craptab2(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nmsistem IN craptab.nmsistem%TYPE
                      ,pr_tptabela IN craptab.tptabela%TYPE
                      ,pr_cdempres IN craptab.cdempres%TYPE
                      ,pr_cdacesso IN craptab.cdacesso%TYPE
                      ,pr_tpregist IN craptab.tpregist%TYPE) IS
    SELECT tab.progress_recid
          ,tab.dstextab
      FROM craptab tab
     WHERE tab.cdcooper = pr_cdcooper
       AND UPPER(tab.nmsistem) = UPPER(pr_nmsistem)
       AND UPPER(tab.tptabela) = UPPER(pr_tptabela)
       AND tab.cdempres = pr_cdempres
       AND UPPER(tab.cdacesso) = UPPER(pr_cdacesso)
       AND tab.tpregist = pr_tpregist;
    rw_craptab2 cr_craptab2%ROWTYPE;

    CURSOR cr_craplgp(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt craplgp.dtmvtolt%TYPE)IS
    SELECT craplgp.cdcooper
      FROM craplgp
     WHERE craplgp.cdcooper = pr_cdcooper
       AND craplgp.dtmvtolt = pr_dtmvtolt
       AND craplgp.flgativo = 1;
    rw_craplgp cr_craplgp%ROWTYPE;

    CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE)IS
    SELECT crapass.inpessoa
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --Busca Linha de credito Emis. Boleto
    CURSOR cr_craplcr(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_cdlcremp craplcr.cdlcremp%TYPE)IS
    SELECT craplcr.cdcooper
          ,craplcr.cdusolcr
      FROM craplcr
     WHERE craplcr.cdcooper = pr_cdcooper
       AND craplcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;

    --Busca DIMOF
    CURSOR cr_crapmof(pr_cdcooper crapcop.cdcooper%TYPE)IS
    SELECT crapmof.cdcooper
          ,crapmof.flgenvio
          ,crapmof.dtenvarq
          ,crapmof.progress_recid
      FROM crapmof
     WHERE crapmof.cdcooper = pr_cdcooper;
    rw_crapmof cr_crapmof%ROWTYPE;

    --Variaveis locais
    vr_dstextab craptab.dstextab%TYPE := '';
    vr_cdoperad VARCHAR2(100);
    vr_cdcooper NUMBER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_nrctabol NUMBER(25);
    vr_cdlcrbol craptab.dstextab%TYPE;
    vr_des_reto VARCHAR2(3);
    vr_dtcalcu2 DATE;
    vr_ultdiame DATE;
    vr_des_erro VARCHAR2(10);
    vr_nrconven NUMBER(9) := 0;
    vr_nrversao NUMBER(3) := 0;
    vr_vldataxa NUMBER(5,2) := 0;
    vr_vltxinss NUMBER(5,2) := 0;
    vr_dsemlctr craptab.dstextab%TYPE := '';
    vr_dtregcob DATE;
    vr_dtctrdda DATE;
    vr_dtrjunta DATE;
    vr_dtcdcnpj DATE;
    vr_dtmvtolt DATE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    vr_exc_saida EXCEPTION;

  BEGIN

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCOP'
                              ,pr_action => null);

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);

    FETCH cr_crapcop into rw_crapcop;

    IF cr_crapcop%NOTFOUND THEN

      CLOSE cr_crapcop;

      vr_cdcritic := 794;
      RAISE vr_exc_saida;

    ELSE

      CLOSE cr_crapcop;

    END IF;

    /* critica para permitir somente os seguintes operadores  */
    IF pr_cddepart NOT IN  (1,4,6,7,8,9,14,18,20) THEN

      vr_cdcritic := 36;
      RAISE vr_exc_saida;

    END IF;

    /* E-mail do contador */
    OPEN cr_craptab(pr_cdcooper => vr_cdcooper
                   ,pr_nmsistem => 'CRED'
                   ,pr_tptabela => 'USUARI'
                   ,pr_cdempres => 0
                   ,pr_cdacesso => 'EMLCTBCOOP');

    FETCH cr_craptab INTO rw_craptab;

    IF cr_craptab%NOTFOUND THEN

      --Fecha o cursor
      CLOSE cr_craptab;

      BEGIN

        INSERT INTO craptab (craptab.cdcooper
                            ,craptab.nmsistem
                            ,craptab.tptabela
                            ,craptab.cdempres
                            ,craptab.cdacesso
                            ,craptab.tpregist
                            ,craptab.dstextab)
                     VALUES(vr_cdcooper
                           ,'CRED'
                           ,'USUARI'
                           ,0
                           ,'EMLCTBCOOP'
                           ,0
                           ,pr_dsemlctr);
        EXCEPTION
          WHEN OTHERS THEN
            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao gravar e-mail do contador!' || SQLERRM;
            -- volta para o programa chamador
            RAISE vr_exc_saida;

      END;

    ELSE

      --Fecha o cursor
      CLOSE cr_craptab;

      vr_dsemlctr := rw_craptab.dstextab;

      BEGIN

        UPDATE craptab
           SET craptab.dstextab = pr_dsemlctr
         WHERE craptab.progress_recid = rw_craptab.progress_recid;
        EXCEPTION
          WHEN OTHERS THEN
            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar e-mail do contador!' || SQLERRM;
            -- volta para o programa chamador
            RAISE vr_exc_saida;

      END;

    END IF;

    OPEN cr_crapcop_agectl(pr_cdcooper => vr_cdcooper
                          ,pr_cdagectl => pr_cdagectl);

    FETCH cr_crapcop_agectl INTO rw_crapcop_agectl;

    IF cr_crapcop_agectl%FOUND THEN

      --Fechar o cursor
      CLOSE cr_crapcop_agectl;

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Coop.COMPE Cecred ja utilizada por outra Cooperativa.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    ELSE

      --Fechar o cursor
      CLOSE cr_crapcop_agectl;

    END IF;

    BEGIN
      --Pega a data do registro
      vr_dtmvtolt := to_date(pr_dtmvtolt,'DD/MM/RRRR');

    EXCEPTION
      WHEN OTHERS THEN

      --Monta mensagem de critica
      vr_dscritic := 'Data invalida.';

      --Gera exceção
      RAISE vr_exc_saida;
    END;

    BEGIN
      --Pega a data do registro
      vr_dtregcob := to_date(pr_dtregcob,'DD/MM/RRRR');

    EXCEPTION
      WHEN OTHERS THEN

      --Monta mensagem de critica
      vr_dscritic := 'Data invalida.';
      pr_nmdcampo := 'dtregcob';

      --Gera exceção
      RAISE vr_exc_saida;
    END;

    BEGIN
      --Pega a data do registro
      vr_dtctrdda := to_date(pr_dtctrdda,'DD/MM/RRRR');

    EXCEPTION
      WHEN OTHERS THEN

      --Monta mensagem de critica
      vr_dscritic := 'Data invalida.';
      pr_nmdcampo := 'dtctrdda';

      --Gera exceção
      RAISE vr_exc_saida;
    END;


    BEGIN
      --Pega a data do registro
      vr_dtrjunta := to_date(pr_dtrjunta,'DD/MM/RRRR');

    EXCEPTION
      WHEN OTHERS THEN

      --Monta mensagem de critica
      vr_dscritic := 'Data invalida.';
      pr_nmdcampo := 'dtrjunta';

      --Gera exceção
      RAISE vr_exc_saida;
    END;


    BEGIN
      --Pega a data do registro
      vr_dtcdcnpj := to_date(pr_dtcdcnpj,'DD/MM/RRRR');

    EXCEPTION
      WHEN OTHERS THEN

      --Monta mensagem de critica
      vr_dscritic := 'Data invalida.';
      pr_nmdcampo := 'dtcdcnpj';

      --Gera exceção
      RAISE vr_exc_saida;
    END;

    IF length(pr_dstelscr) > 14 THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O campo telefone excedeu o numero de caracters.';
      pr_nmdcampo := 'dstelscr';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF pr_cdagectl <> rw_crapcop.cdagectl THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Favor verificar Agencia CECRED na tela CADPAC';
      pr_nmdcampo := 'cdagectl';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    vr_nrctabol:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'GENERI'
                                            ,pr_cdempres => 00
                                            ,pr_cdacesso => 'CTAEMISBOL'
                                            ,pr_tpregist => 0);

    vr_cdlcrbol:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'GENERI'
                                            ,pr_cdempres => 00
                                            ,pr_cdacesso => 'LCREMISBOL'
                                            ,pr_tpregist => 0);

    /* Se tiver sede do INSS cadastrada, eh obrigado ter
       credenciamento para GPS-BANCOOB */
    IF pr_cdagsede <> 0 AND
       pr_cdcrdarr = 0  THEN

      -- Montar mensagem de critica
      vr_cdcritic := 375;
      vr_dscritic := '';
      pr_nmdcampo := 'cdcrdarr';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    /* Se informado o campo "Creden.Arrecadacoes", o campo
       "Sede INSS" deve ser preenchido (nao pode ser = 0).
       Caso nao informado o pac sede, GERA ERRO na importaçao
       dos beneficios */
    IF pr_cdcrdarr <> 0 AND
       pr_cdagsede = 0  THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O campo Sede INSS deve ser preenchido.';
      pr_nmdcampo := 'cdagsede';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF nvl(pr_nrdocnpj,0) = 0 THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'CNPJ da Cooperativa deve ser informado.';
      pr_nmdcampo := 'nrdocnpj';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF TRIM(pr_cdufdcop) IS NULL THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Unidade de federacao deve ser informado.';
      pr_nmdcampo := 'cdufdcop';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF TRIM(pr_nrtelvoz) IS NULL THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Telefone da cooperativa deve ser informado.';
      pr_nmdcampo := 'nrtelvoz';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF nvl(pr_nrcpftit,0) = 0 THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'CPF do presidente deve ser informado.';
      pr_nmdcampo := 'nrcpftit';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF nvl(pr_nrcpfctr,0) = 0 THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'CPF do contador deve ser informado.';
      pr_nmdcampo := 'nrcpfctr';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF to_number(to_char(to_date(pr_hriniatr,'hh24:mi:ss'),'hh24')) > 22 THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O intervalo em horas deve estar entre 0 e 23.';
      pr_nmdcampo := 'hriniatr';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF to_number(to_char(to_date(pr_hrlimsic,'hh24:mi:ss'),'hh24')) > 23 THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O intervalo em horas deve estar entre 0 e 23.';
      pr_nmdcampo := 'hrlimsic';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF to_number(to_char(to_date(pr_hrinigps,'hh24:mi:ss'),'hh24')) > 22 THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O intervalo em horas deve estar entre 0 e 23.';
      pr_nmdcampo := 'hrinigps';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF NOT pr_cdsinfmg IN (0,1,2)THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Tipo invalido.';
      pr_nmdcampo := 'cdsinfmg';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF TRIM(pr_dsnomscr) IS NULL THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Informe o nome do responsavel.';
      pr_nmdcampo := 'dsnomscr';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF TRIM(pr_dsemascr) IS NULL THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Informe o e-mail do responsavel.';
      pr_nmdcampo := 'dsemascr';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF TRIM(pr_dstelscr) IS NULL THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Informe o telefone do responsavel.';
      pr_nmdcampo := 'dstelscr';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF (rw_crapcop.cdcrdarr <> 0 AND
        pr_cdcrdarr = 0)         OR
       (rw_crapcop.cdcrdarr = 0  AND
        pr_cdcrdarr <> 0)        THEN

      OPEN cr_craplgp(pr_cdcooper => vr_cdcooper
                     ,pr_dtmvtolt => vr_dtmvtolt);

      FETCH cr_craplgp INTO rw_craplgp;

      IF cr_craplgp%FOUND THEN

        --Fecha o cursor
        CLOSE cr_craplgp;

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Ja existem guias pagas hoje, impossivel alterar.';
        -- volta para o programa chamador
        RAISE vr_exc_saida;

      ELSE

        --Fecha o cursor
        CLOSE cr_craplgp;

      END IF;

    END IF;

    /* Verificar se Conta Emis. Boleto e valida */
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrctabol);

    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN

      --Fechar o cursor
      CLOSE cr_crapass;

      IF pr_nrctabol = 0 THEN

        -- Atualiza valor das tabelas craptab
        pc_atualiza_tab (pr_cdcooper => vr_cdcooper    -- Código da cooperativa
                        ,pr_cdacesso => 'CTAEMISBOL'   -- Código de acesso
                        ,pr_dstextab => to_char(pr_nrctabol) -- Valor
                        ,pr_des_reto => vr_des_reto    -- Retorno Ok ou NOK do procedimento
                        ,pr_cdcritic => vr_cdcritic    -- Código da critica
                        ,pr_dscritic => vr_dscritic);  -- Retorno da PlTable de erros

        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN

          --Se possui erro
          IF nvl(vr_cdcritic,0) = 0    AND
             trim(vr_dscritic) IS NULL THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Nao foi possivel atualziar tabelas genericas.';
          END IF;

          --Levantar Excecao
          RAISE vr_exc_saida;

        END IF;

      ELSE

        -- Montar mensagem de critica
        vr_cdcritic := 564;
        vr_dscritic := '';

        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END IF;


    ELSE
      --Fechar o cursor
      CLOSE cr_crapass;

      IF rw_crapass.inpessoa <> 3 THEN

        -- Montar mensagem de critica
        vr_cdcritic := 436;
        vr_dscritic := '';

        -- volta para o programa chamador
        RAISE vr_exc_saida;

      ELSE

        -- Atualiza valor das tabelas craptab
        pc_atualiza_tab (pr_cdcooper => vr_cdcooper    -- Código da cooperativa
                        ,pr_cdacesso => 'CTAEMISBOL'   -- Código de acesso
                        ,pr_dstextab => to_char(pr_nrctabol) -- Valor
                        ,pr_des_reto => vr_des_reto    -- Retorno Ok ou NOK do procedimento
                        ,pr_cdcritic => vr_cdcritic    -- Código da critica
                        ,pr_dscritic => vr_dscritic);  -- Retorno da PlTable de erros

        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN

          --Se possui erro
          IF nvl(vr_cdcritic,0) = 0    AND
             trim(vr_dscritic) IS NULL THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Nao foi possivel atualziar tabelas genericas.';
          END IF;

          --Levantar Excecao
          RAISE vr_exc_saida;

        END IF;

      END IF;

    END IF;

    /* Se a linha de credito para emprestimo com emissao de
       boletos foi informada, deve-se informar tambem a conta */
    IF pr_nrctabol = 0  AND
       pr_cdlcrbol <> 0 THEN

      -- Montar mensagem de critica
      vr_cdcritic := 564;
      vr_dscritic := '';
      pr_nmdcampo := 'nrctabol';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    /*Verificar se a Linha de credito Emis. Boleto e valida*/
    OPEN cr_craplcr(pr_cdcooper => vr_cdcooper
                   ,pr_cdlcremp => pr_cdlcrbol);

    FETCH cr_craplcr INTO rw_craplcr;

    IF cr_craplcr%NOTFOUND THEN

      --Fechar o cursor
      CLOSE cr_craplcr;

      IF pr_cdlcrbol = 0 THEN

        -- Atualiza valor das tabelas craptab
        pc_atualiza_tab (pr_cdcooper => vr_cdcooper    -- Código da cooperativa
                        ,pr_cdacesso => 'LCREMISBOL'   -- Código de acesso
                        ,pr_dstextab => to_char(pr_cdlcrbol) -- Valor
                        ,pr_des_reto => vr_des_reto    -- Retorno Ok ou NOK do procedimento
                        ,pr_cdcritic => vr_cdcritic    -- Código da critica
                        ,pr_dscritic => vr_dscritic);  -- Retorno da PlTable de erros

        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN

          --Se possui erro
          IF nvl(vr_cdcritic,0) = 0    AND
             trim(vr_dscritic) IS NULL THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Nao foi possivel atualziar tabelas genericas.';
          END IF;

          --Levantar Excecao
          RAISE vr_exc_saida;

        END IF;

      ELSE

        -- Montar mensagem de critica
        vr_cdcritic := 363;
        vr_dscritic := '';
        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END IF;

    ELSE

      --Fechar o cursor
      CLOSE cr_craplcr;

      IF rw_craplcr.cdusolcr = 2 THEN

        -- Atualiza valor das tabelas craptab
        pc_atualiza_tab (pr_cdcooper => vr_cdcooper    -- Código da cooperativa
                        ,pr_cdacesso => 'LCREMISBOL'   -- Código de acesso
                        ,pr_dstextab => to_char(pr_cdlcrbol) -- Valor
                        ,pr_des_reto => vr_des_reto    -- Retorno Ok ou NOK do procedimento
                        ,pr_cdcritic => vr_cdcritic    -- Código da critica
                        ,pr_dscritic => vr_dscritic);  -- Retorno da PlTable de erros

        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN

          --Se possui erro
          IF nvl(vr_cdcritic,0) = 0    AND
             trim(vr_dscritic) IS NULL THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Nao foi possivel atualziar tabelas genericas.';
          END IF;

          --Levantar Excecao
          RAISE vr_exc_saida;

        END IF;

      ELSE

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'O codigo de uso da linha deve ser 2 - EPR/BOLETOS.';
        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END IF;

    END IF;

    /* Se a conta para emprestimo com emissao de boletos foi
       informada, deve-se informar tambem a linha de credito */
    IF pr_nrctabol <> 0  AND
       pr_cdlcrbol = 0 THEN

      -- Montar mensagem de critica
      vr_cdcritic := 363;
      vr_dscritic := '';
      pr_nmdcampo := 'cdlcrbol';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF fn_valida_caracteres (pr_flgnumer => TRUE
                            ,pr_flgletra => TRUE
                            ,pr_listaesp => ''
                            ,pr_listainv => ''
                            ,pr_dsvalida => pr_nmrescop) THEN

      vr_cdcritic:= 0;
      vr_dscritic:= 'Caracteres especiais nao validos. Apenas letras e numeros.';
      pr_nmdcampo := 'nmrescop';

      --Levantar Excecao
      RAISE vr_exc_saida;

    END IF;

    IF fn_valida_caracteres (pr_flgnumer => TRUE
                            ,pr_flgletra => TRUE
                            ,pr_listaesp => ''
                            ,pr_listainv => ''
                            ,pr_dsvalida => pr_nmextcop) THEN

      vr_cdcritic:= 0;
      vr_dscritic:= 'Caracteres especiais nao validos. Apenas letras e numeros.';
      pr_nmdcampo := 'nmextcop';

      --Levantar Excecao
      RAISE vr_exc_saida;

    END IF;

    IF fn_valida_caracteres (pr_flgnumer => TRUE
                            ,pr_flgletra => TRUE
                            ,pr_listaesp => ''
                            ,pr_listainv => ''
                            ,pr_dsvalida => pr_dsendcop) THEN

      vr_cdcritic:= 0;
      vr_dscritic:= 'Caracteres especiais nao validos. Apenas letras e numeros.';
      pr_nmdcampo := 'dsendcop';

      --Levantar Excecao
      RAISE vr_exc_saida;

    END IF;

    IF fn_valida_caracteres (pr_flgnumer => TRUE
                            ,pr_flgletra => TRUE
                            ,pr_listaesp => ''
                            ,pr_listainv => ''
                            ,pr_dsvalida => pr_dscomple) THEN

      vr_cdcritic:= 0;
      vr_dscritic:= 'Caracteres especiais nao validos. Apenas letras e numeros.';
      pr_nmdcampo := 'dscomple';

      --Levantar Excecao
      RAISE vr_exc_saida;

    END IF;

    IF fn_valida_caracteres (pr_flgnumer => TRUE
                            ,pr_flgletra => TRUE
                            ,pr_listaesp => ''
                            ,pr_listainv => ''
                            ,pr_dsvalida => pr_nmcidade) THEN

      vr_cdcritic:= 0;
      vr_dscritic:= 'Caracteres especiais nao validos. Apenas letras e numeros.';
      pr_nmdcampo := 'nmcidade';

      --Levantar Excecao
      RAISE vr_exc_saida;

    END IF;

    IF fn_valida_caracteres (pr_flgnumer => TRUE
                            ,pr_flgletra => TRUE
                            ,pr_listaesp => ''
                            ,pr_listainv => ''
                            ,pr_dsvalida => pr_nmbairro) THEN

      vr_cdcritic:= 0;
      vr_dscritic:= 'Caracteres especiais nao validos. Apenas letras e numeros.';
      pr_nmdcampo := 'nmbairro';

      --Levantar Excecao
      RAISE vr_exc_saida;

    END IF;

    IF fn_valida_caracteres (pr_flgnumer => TRUE
                            ,pr_flgletra => TRUE
                            ,pr_listaesp => ''
                            ,pr_listainv => ''
                            ,pr_dsvalida => pr_nmtitcop) THEN

      vr_cdcritic:= 0;
      vr_dscritic:= 'Caracteres especiais nao validos. Apenas letras e numeros.';
      pr_nmdcampo := 'nmtitcop';

      --Levantar Excecao
      RAISE vr_exc_saida;

    END IF;

    IF fn_valida_caracteres (pr_flgnumer => TRUE
                            ,pr_flgletra => TRUE
                            ,pr_listaesp => ''
                            ,pr_listainv => ''
                            ,pr_dsvalida => pr_nmctrcop) THEN

      vr_cdcritic:= 0;
      vr_dscritic:= 'Caracteres especiais nao validos. Apenas letras e numeros.';
      pr_nmdcampo := 'nmctrcop';

      --Levantar Excecao
      RAISE vr_exc_saida;

    END IF;

    /*
      alterar/criar registro de DIMOF somente se alterado o CNPJ
      no ano corrente, caso o registro ja existe e ainda nao
      tenha sido enviado ao BC altera a data de inicio do periodo  */
    IF rw_crapcop.dtcdcnpj <> vr_dtcdcnpj                AND
       trunc(vr_dtcdcnpj,'RR') = trunc(vr_dtmvtolt,'RR') THEN

      OPEN cr_crapmof(pr_cdcooper => vr_cdcooper);

      FETCH cr_crapmof INTO rw_crapmof;

      IF cr_crapmof%NOTFOUND THEN

        --Fecha o cursor
        CLOSE cr_crapmof;

        IF to_char(vr_dtcdcnpj,'mm') > 6 THEN

           /*
          Calcula o ultimo dia util do mes
          02 do ano novo, data limite
          para envio do arquivo do segundo
          semestre do ano que se inicia   */
          vr_dtcalcu2 := to_date('01/02' || (trunc(vr_dtmvtolt,'RRRR') + 1),'DD/MM/RRRR');
          vr_ultdiame := gene0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper
                                                    ,pr_dtmvtolt => LAST_DAY(vr_dtcalcu2)
                                                    ,pr_tipo     => 'A'); -- Deve ser o último dia útil do mês

          /* Segundo semestre do ano */
          BEGIN

            INSERT INTO crapmof (crapmof.cdcooper
                                ,crapmof.dtiniper
                                ,crapmof.dtfimper
                                ,crapmof.dtenvpbc
                                ,crapmof.dtenvarq
                                ,crapmof.flgenvio)
                         VALUES(vr_cdcooper
                               ,vr_dtcdcnpj
                               ,to_date('31/12' || trunc(vr_dtmvtolt,'RRRR'),'DD/MM/RRRR')
                               ,vr_ultdiame
                               ,NULL
                               ,0);
            EXCEPTION
              WHEN OTHERS THEN
                -- Montar mensagem de critica
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao gravar controles para geracao da DIMOF!' || SQLERRM;
                -- volta para o programa chamador
                RAISE vr_exc_saida;

          END;

        ELSE

          /*
          Calcula o ultimo dia util do mes 08,
          data limite para envio do arquivo*/
          vr_dtcalcu2 := to_date('01/08' || trunc(vr_dtmvtolt,'RRRR'),'DD/MM/RRRR');
          vr_ultdiame := gene0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper
                                                    ,pr_dtmvtolt => LAST_DAY(vr_dtcalcu2)
                                                    ,pr_tipo     => 'A'); -- Deve ser o último dia útil do mês

          /* Primeiro semestre do ano */
          BEGIN

            INSERT INTO crapmof (crapmof.cdcooper
                                ,crapmof.dtiniper
                                ,crapmof.dtfimper
                                ,crapmof.dtenvpbc
                                ,crapmof.dtenvarq
                                ,crapmof.flgenvio)
                         VALUES(vr_cdcooper
                               ,vr_dtcdcnpj
                               ,to_date('30/06' || trunc(vr_dtmvtolt,'RRRR'),'DD/MM/RRRR')
                               ,vr_ultdiame
                               ,NULL
                               ,0);
            EXCEPTION
              WHEN OTHERS THEN
                -- Montar mensagem de critica
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao gravar controles para geracao da DIMOF!' || SQLERRM;
                -- volta para o programa chamador
                RAISE vr_exc_saida;

          END;

          /*
          Calcula o ultimo dia util do mes
          02 do ano novo, data limite
          para envio do arquivo do segundo
          semestre do ano que se inicia*/
          vr_dtcalcu2 := to_date('01/02' || (trunc(vr_dtmvtolt,'RRRR') + 1),'DD/MM/RRRR');
          vr_ultdiame := gene0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper
                                                    ,pr_dtmvtolt => LAST_DAY(vr_dtcalcu2)
                                                    ,pr_tipo     => 'A'); -- Deve ser o último dia útil do mês

          /* Segundo semestre do ano */
          BEGIN

            INSERT INTO crapmof (crapmof.cdcooper
                                ,crapmof.dtiniper
                                ,crapmof.dtfimper
                                ,crapmof.dtenvpbc
                                ,crapmof.dtenvarq
                                ,crapmof.flgenvio)
                         VALUES(vr_cdcooper
                               ,to_date('01/07' || trunc(vr_dtmvtolt,'RRRR'),'DD/MM/RRRR')
                               ,to_date('31/12' || trunc(vr_dtmvtolt,'RRRR'),'DD/MM/RRRR')
                               ,vr_ultdiame
                               ,NULL
                               ,0);
            EXCEPTION
              WHEN OTHERS THEN
                -- Montar mensagem de critica
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao gravar controles para geracao da DIMOF!' || SQLERRM;
                -- volta para o programa chamador
                RAISE vr_exc_saida;

          END;


        END IF;

      ELSE

        --Fecha o cursor
        CLOSE cr_crapmof;

        IF rw_crapmof.flgenvio = 0     AND
           rw_crapmof.dtenvarq IS NULL THEN

          /* Segundo semestre do ano */
          BEGIN

            UPDATE crapmof
               SET crapmof.dtiniper = vr_dtcdcnpj
             WHERE crapmof.progress_recid = rw_crapmof.progress_recid;

            EXCEPTION
              WHEN OTHERS THEN
                -- Montar mensagem de critica
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar controles para geracao da DIMOF!' || SQLERRM;
                -- volta para o programa chamador
                RAISE vr_exc_saida;

          END;

        END IF;


      END IF;

    END IF;

    /* Registro de controle de convenio*/
    OPEN cr_craptab2(pr_cdcooper => vr_cdcooper
                    ,pr_nmsistem => 'CRED'
                    ,pr_tptabela => 'USUARI'
                    ,pr_cdempres => 11
                    ,pr_cdacesso => 'CORRESPOND'
                    ,pr_tpregist => 0 );

    FETCH cr_craptab2 INTO rw_craptab2;

    IF cr_craptab2%FOUND THEN

      --Fechar o cursor
      CLOSE cr_craptab2;

      vr_nrconven := SUBSTR(rw_craptab2.dstextab,1,9);
      vr_vltxinss := SUBSTR(rw_craptab2.dstextab,22,6);
      vr_vldataxa := SUBSTR(rw_craptab2.dstextab,15,6);
      vr_nrversao := SUBSTR(rw_craptab2.dstextab,11,3);

      BEGIN

        UPDATE craptab
           SET craptab.dstextab = trim(TO_CHAR(pr_nrconven,'000000000')) || ',' ||
                                  trim(TO_CHAR(pr_nrversao,'000'))       || ',' ||
                                  trim(to_char(pr_vldataxa,'fm000d00'))  || ',' ||
                                  trim(to_char(pr_vltxinss,'fm000d00'))  ||
                                  substr(craptab.dstextab,28)
         WHERE craptab.progress_recid = rw_craptab2.progress_recid;

        EXCEPTION
          WHEN OTHERS THEN
            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar registro de controle de convenio!' || SQLERRM;
            -- volta para o programa chamador
            RAISE vr_exc_saida;

      END;

    ELSE

      --Fechar o cursor
      CLOSE cr_craptab2;

      BEGIN

        INSERT INTO craptab(craptab.cdcooper
                           ,craptab.nmsistem
                           ,craptab.tptabela
                           ,craptab.cdempres
                           ,craptab.cdacesso
                           ,craptab.tpregist
                           ,craptab.dstextab)
                     VALUES(vr_cdcooper
                           ,'CRED'
                           ,'USUARI'
                           ,'11'
                           ,'CORRESPOND'
                           ,0
                           ,trim(TO_CHAR(pr_nrconven,'000000000')) || ',' ||
                            trim(TO_CHAR(pr_nrversao,'000'))       || ',' ||
                            trim(to_char(pr_vldataxa,'fm000d00'))  || ',' ||
                            trim(to_char(pr_vltxinss,'fm000d00')));

        EXCEPTION
          WHEN OTHERS THEN
            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao criar registro de controle de convenio!' || SQLERRM;
            -- volta para o programa chamador
            RAISE vr_exc_saida;

      END;

    END IF;

    -- Se não for do Departamento 20 - TI
    IF pr_cddepart <> 20 THEN

      IF rw_crapcop.qttmpsgr <> to_number(to_char(to_date(pr_qttmpsgr,'hh24:mi:ss'),'sssss'))THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Departamento sem persmissao para alterar horario da sangria!';
        pr_nmdcampo := 'qttmpsgr';

        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END if;

    ELSE

      IF nvl(to_number(to_char(to_date(pr_qttmpsgr,'hh24:mi:ss'),'sssss')),0) = 0 THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Informe um intervalo de tempo para verificacao da sangria.!';
        pr_nmdcampo := 'qttmpsgr';

        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END IF;

    END IF;

    IF nvl(to_number(to_char(to_date(pr_hrinisac,'hh24:mi'),'sssss')),0) > nvl(to_number(to_char(to_date(pr_hrfimsac,'hh24:mi'),'sssss')),0) THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Horario inicial maior que o final.!';
      pr_nmdcampo := 'hrinisac';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    IF nvl(to_number(to_char(to_date(pr_hriniouv,'hh24:mi'),'sssss')),0) > nvl(to_number(to_char(to_date(pr_hrfimouv,'hh24:mi'),'sssss')),0) THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Horario inicial maior que o final.!';
      pr_nmdcampo := 'hriniouv';

      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    -- Atualiza valor das tabelas craptab
    pc_atualiza_tab (pr_cdcooper => vr_cdcooper    -- Código da cooperativa
                    ,pr_cdacesso => 'GPSCXASCOD'   -- Código de acesso
                    ,pr_dstextab => to_char(pr_vltfcxsb) -- Valor
                    ,pr_des_reto => vr_des_reto    -- Retorno Ok ou NOK do procedimento
                    ,pr_cdcritic => vr_cdcritic    -- Código da critica
                    ,pr_dscritic => vr_dscritic);  -- Retorno da PlTable de erros

    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN

      --Se possui erro
      IF nvl(vr_cdcritic,0) = 0    AND
         trim(vr_dscritic) IS NULL THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel atualziar tabelas genericas.';
      END IF;

      --Levantar Excecao
      RAISE vr_exc_saida;

    END IF;

    -- Atualiza valor das tabelas craptab
    pc_atualiza_tab (pr_cdcooper => vr_cdcooper    -- Código da cooperativa
                    ,pr_cdacesso => 'GPSCXACCOD'   -- Código de acesso
                    ,pr_dstextab => to_char(pr_vltfcxcb) -- Valor
                    ,pr_des_reto => vr_des_reto    -- Retorno Ok ou NOK do procedimento
                    ,pr_cdcritic => vr_cdcritic    -- Código da critica
                    ,pr_dscritic => vr_dscritic);  -- Retorno da PlTable de erros

    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN

      --Se possui erro
      IF nvl(vr_cdcritic,0) = 0    AND
         trim(vr_dscritic) IS NULL THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel atualziar tabelas genericas.';
      END IF;

      --Levantar Excecao
      RAISE vr_exc_saida;

    END IF;

    -- Atualiza valor das tabelas craptab
    pc_atualiza_tab (pr_cdcooper => vr_cdcooper    -- Código da cooperativa
                    ,pr_cdacesso => 'GPSINTBANK'   -- Código de acesso
                    ,pr_dstextab => to_char(pr_vlrtrfib) -- Valor
                    ,pr_des_reto => vr_des_reto    -- Retorno Ok ou NOK do procedimento
                    ,pr_cdcritic => vr_cdcritic    -- Código da critica
                    ,pr_dscritic => vr_dscritic);  -- Retorno da PlTable de erros

    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN

      --Se possui erro
      IF nvl(vr_cdcritic,0) = 0    AND
         trim(vr_dscritic) IS NULL THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel atualizar tabelas genericas.';
      END IF;

      --Levantar Excecao
      RAISE vr_exc_saida;

    END IF;

    BEGIN

      UPDATE crapcop
         SET crapcop.nmextcop = UPPER(pr_nmextcop)
            ,crapcop.dsendcop = UPPER(pr_dsendcop)
            ,crapcop.dscomple = UPPER(pr_dscomple)
            ,crapcop.nmbairro = UPPER(pr_nmbairro)
            ,crapcop.nmcidade = UPPER(pr_nmcidade)
            ,crapcop.nmrescop = UPPER(pr_nmrescop)
            ,crapcop.nrdocnpj = pr_nrdocnpj
            ,crapcop.dtcdcnpj = vr_dtcdcnpj
            ,crapcop.nrendcop = pr_nrendcop
            ,crapcop.nrcepend = pr_nrcepend
            ,crapcop.cdufdcop = pr_cdufdcop
            ,crapcop.nrcxapst = pr_nrcxapst
            ,crapcop.nrtelvoz = pr_nrtelvoz
            ,crapcop.nrtelouv = pr_nrtelouv
            ,crapcop.dsendweb = pr_dsendweb
            ,crapcop.nrtelura = pr_nrtelura
            ,crapcop.dsdemail = pr_dsdemail
            ,crapcop.nrtelfax = pr_nrtelfax
            ,crapcop.dsdempst = pr_dsdempst
            ,crapcop.nrtelsac = pr_nrtelsac
            ,crapcop.nmtitcop = pr_nmtitcop
            ,crapcop.nrcpftit = pr_nrcpftit
            ,crapcop.nmctrcop = pr_nmctrcop
            ,crapcop.nrcpfctr = pr_nrcpfctr
            ,crapcop.nrcrcctr = pr_nrcrcctr
            ,crapcop.nrrjunta = pr_nrrjunta
            ,crapcop.dtrjunta = vr_dtrjunta
            ,crapcop.nrinsest = pr_nrinsest
            ,crapcop.nrinsmun = pr_nrinsmun
            ,crapcop.nrlivapl = pr_nrlivapl
            ,crapcop.nrlivcap = pr_nrlivcap
            ,crapcop.nrlivdpv = pr_nrlivdpv
            ,crapcop.nrlivepr = pr_nrlivepr
            ,crapcop.cdbcoctl = pr_cdbcoctl
            ,crapcop.cdagectl = pr_cdagectl
            ,crapcop.cdagedbb = pr_cdagedbb
            ,crapcop.cdageitg = pr_cdageitg
            ,crapcop.cdcnvitg = pr_cdcnvitg
            ,crapcop.cdmasitg = pr_cdmasitg
            ,crapcop.nrctabbd = pr_nrctabbd
            ,crapcop.nrctactl = pr_nrctactl
            ,crapcop.nrctaitg = pr_nrctaitg
            ,crapcop.nrctadbb = pr_nrctadbb
            ,crapcop.nrctacmp = pr_nrctacmp
            ,crapcop.nrdconta = pr_nrdconta
            ,crapcop.flgdsirc = pr_flgdsirc
            ,crapcop.flgcrmag = CASE WHEN pr_cdagebcb <> 0 THEN pr_flgcrmag ELSE crapcop.flgcrmag END
            ,crapcop.qtdiaenl = CASE crapcop.flgcrmag WHEN 1 THEN pr_qtdiaenl ELSE crapcop.qtdiaenl END
            ,crapcop.cdsinfmg = CASE crapcop.flgcrmag WHEN 1 THEN pr_cdsinfmg ELSE crapcop.cdsinfmg END
            ,crapcop.taamaxer = CASE crapcop.flgcrmag WHEN 1 THEN pr_taamaxer ELSE crapcop.taamaxer END
            ,crapcop.vllimapv = CASE WHEN crapcop.flgcmtlc = 1 THEN 0 ELSE crapcop.vllimapv END
            ,crapcop.cdcrdarr = pr_cdcrdarr
            ,crapcop.cdagsede = pr_cdagsede
            ,crapcop.vlmaxcen = pr_vlmaxcen
            ,crapcop.vlmaxleg = pr_vlmaxleg
            ,crapcop.vlmaxutl = pr_vlmaxutl
            ,crapcop.vlcnsscr = pr_vlcnsscr
            ,crapcop.vllimmes = pr_vllimmes
            ,crapcop.dsclactr##1 = substr(pr_dsclactr,1,74)
            ,crapcop.dsclactr##2 = substr(pr_dsclactr,75,74)
            ,crapcop.dsclactr##3 = substr(pr_dsclactr,149,74)
            ,crapcop.dsclactr##4 = substr(pr_dsclactr,224,74)
            ,crapcop.dsclactr##5 = substr(pr_dsclactr,298,74)
            ,crapcop.dsclactr##6 = substr(pr_dsclactr,372,74)
            ,crapcop.dsclaccb##1 = substr(pr_dsclaccb,1,68)
            ,crapcop.dsclaccb##2 = substr(pr_dsclaccb,69,68)
            ,crapcop.dsclaccb##3 = substr(pr_dsclaccb,137,68)
            ,crapcop.dsclaccb##4 = substr(pr_dsclaccb,206,68)
            ,crapcop.dsclaccb##5 = substr(pr_dsclaccb,274,65)
            ,crapcop.dsclaccb##6 = substr(pr_dsclaccb,339,65)
            ,crapcop.nmdireto = pr_nmdireto
            ,crapcop.flgdopgd = pr_flgdopgd
            ,crapcop.dsnotifi##1 = substr(pr_dsnotifi,1,68)
            ,crapcop.dsnotifi##2 = substr(pr_dsnotifi,69,68)
            ,crapcop.dsnotifi##3 = substr(pr_dsnotifi,137,68)
            ,crapcop.dsnotifi##4 = substr(pr_dsnotifi,206,68)
            ,crapcop.dsnotifi##5 = substr(pr_dsnotifi,274,68)
            ,crapcop.dsnotifi##6 = substr(pr_dsnotifi,343,68)
            ,crapcop.dsdircop = lower(pr_dsdircop)
            ,crapcop.hrproces = to_number(to_char(to_date(pr_hrproces,'hh24:mi:ss'),'sssss'))
            ,crapcop.hrfinprc = to_number(to_char(to_date(pr_hrfinprc,'hh24:mi:ss'),'sssss'))
            ,crapcop.dtctrdda = vr_dtctrdda
            ,crapcop.nrctrdda = pr_nrctrdda
            ,crapcop.idlivdda = pr_idlivdda
            ,crapcop.nrfoldda = pr_nrfoldda
            ,crapcop.dslocdda = pr_dslocdda
            ,crapcop.dsciddda = pr_dsciddda
            ,crapcop.dtregcob = vr_dtregcob
            ,crapcop.idregcob = pr_idregcob
            ,crapcop.idlivcob = pr_idlivcob
            ,crapcop.nrfolcob = pr_nrfolcob
            ,crapcop.dsloccob = pr_dsloccob
            ,crapcop.dscidcob = pr_dscidcob
            ,crapcop.dsnomscr = pr_dsnomscr
            ,crapcop.dsemascr = pr_dsemascr
            ,crapcop.dstelscr = pr_dstelscr
            ,crapcop.cdagesic = pr_cdagesic
            ,crapcop.nrctasic = pr_nrctasic
            ,crapcop.cdcrdins = pr_cdcrdins
            ,crapcop.vltarsic = pr_vltarsic
            ,crapcop.vltardrf = pr_vltardrf
            ,crapcop.hrinigps = to_number(to_char(to_date(pr_hrinigps,'hh24:mi'),'sssss'))
            ,crapcop.hrfimgps = to_number(to_char(to_date(pr_hrfimgps,'hh24:mi'),'sssss'))
            ,crapcop.hrlimsic = to_number(to_char(to_date(pr_hrlimsic,'hh24:mi'),'sssss'))
            ,crapcop.flgkitbv = pr_flgkitbv
            ,crapcop.qttmpsgr = CASE WHEN pr_cddepart = 20 THEN to_number(to_char(to_date(pr_qttmpsgr,'hh24:mi'),'sssss')) ELSE crapcop.qttmpsgr END
            ,crapcop.hriniatr = to_number(to_char(to_date(pr_hriniatr,'hh24:mi'),'sssss'))
            ,crapcop.hrfimatr = to_number(to_char(to_date(pr_hrfimatr,'hh24:mi'),'sssss'))
            ,crapcop.flgofatr = pr_flgofatr
            ,crapcop.qtdiasus = pr_qtdiasus
            ,crapcop.cdcliser = pr_cdcliser
            ,crapcop.vlmiplco = pr_vlmiplco
            ,crapcop.vlmidbco = pr_vlmidbco
            ,crapcop.cdfingrv = pr_cdfingrv
            ,crapcop.cdsubgrv = pr_cdsubgrv
            ,crapcop.cdloggrv = pr_cdloggrv
            ,crapcop.permaxde = pr_permaxde
            ,crapcop.qtmaxmes = pr_qtmaxmes
            ,crapcop.qtmeatel = pr_qtmeatel
            ,crapcop.flsaqpre = pr_flsaqpre
            ,crapcop.flrecpct = pr_flrecpct
            ,crapcop.hrinisac = to_number(to_char(to_date(pr_hrinisac,'hh24:mi'),'sssss'))
            ,crapcop.hrfimsac = to_number(to_char(to_date(pr_hrfimsac,'hh24:mi'),'sssss'))
            ,crapcop.hriniouv = to_number(to_char(to_date(pr_hriniouv,'hh24:mi'),'sssss'))
            ,crapcop.hrfimouv = to_number(to_char(to_date(pr_hrfimouv,'hh24:mi'),'sssss'))
            ,crapcop.flgargps = pr_flgargps
            ,crapcop.flintcdc = pr_flintcdc
            ,crapcop.tpcdccop = pr_tpcdccop
       WHERE crapcop.cdcooper = vr_cdcooper;

    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar as informacoes da cooperativa!' || SQLERRM;
        -- volta para o programa chamador
        RAISE vr_exc_saida;

    END;

    IF rw_crapcop.flgcmtlc <> pr_flgcmtlc THEN

      IF pr_flgcmtlc = 1 THEN

        BEGIN

          UPDATE crapope
             SET crapope.vlapvcre = 0
           WHERE crapope.cdcooper = vr_cdcooper
             AND crapope.vlapvcre > 0;

          EXCEPTION
            WHEN OTHERS THEN
              -- Montar mensagem de critica
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar limite de aprovacao de credito!' || SQLERRM;
              -- volta para o programa chamador
              RAISE vr_exc_saida;

        END;

      ELSE

        BEGIN

          UPDATE crapage
             SET crapage.vllimapv = 0
           WHERE crapage.cdcooper = vr_cdcooper
             AND crapage.vllimapv > 0;

          EXCEPTION
            WHEN OTHERS THEN
              -- Montar mensagem de critica
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar limite de aprovacao do comite local!' || SQLERRM;
              -- volta para o programa chamador
              RAISE vr_exc_saida;

        END;

        BEGIN

          UPDATE crapope
             SET crapope.cdcomite = 0
           WHERE crapope.cdcooper = vr_cdcooper
             AND crapope.cdcomite <> 0;

          EXCEPTION
            WHEN OTHERS THEN
              -- Montar mensagem de critica
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar participacao no comite!' || SQLERRM;
              -- volta para o programa chamador
              RAISE vr_exc_saida;

        END;

      END IF;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'nome res.' --Descrição do campo
               ,pr_vlrcampo => rw_crapcop.nmrescop --Valor antigo
               ,pr_vlcampo2 => pr_nmrescop --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'cnpj.'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrdocnpj --Valor antigo
                ,pr_vlcampo2 => pr_nrdocnpj --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'nome ext.'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nmextcop --Valor antigo
                ,pr_vlcampo2 => pr_nmextcop --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'end.coop'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.dsendcop --Valor antigo
                ,pr_vlcampo2 => pr_dsendcop --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'nr.ender.'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrendcop --Valor antigo
                ,pr_vlcampo2 => pr_nrendcop --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'complemento'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.dscomple --Valor antigo
                ,pr_vlcampo2 => pr_dscomple --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'bairro'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nmbairro --Valor antigo
                ,pr_vlcampo2 => pr_nmbairro --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'cep'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrcepend --Valor antigo
                ,pr_vlcampo2 => pr_nrcepend --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'cidade'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nmcidade --Valor antigo
                ,pr_vlcampo2 => pr_nmcidade --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'uf'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.cdufdcop --Valor antigo
                ,pr_vlcampo2 => pr_cdufdcop --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'c.postal'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrcxapst --Valor antigo
                ,pr_vlcampo2 => pr_nrcxapst --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'telefone'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrtelvoz --Valor antigo
                ,pr_vlcampo2 => pr_nrtelvoz --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'fax'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrtelfax --Valor antigo
                ,pr_vlcampo2 => pr_nrtelfax --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'site'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.dsendweb --Valor antigo
                ,pr_vlcampo2 => pr_dsendweb --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'email'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.dsdemail --Valor antigo
                ,pr_vlcampo2 => pr_dsdemail --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'email presidente'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.dsdempst --Valor antigo
                ,pr_vlcampo2 => pr_dsdempst --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'titular da coop.'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nmtitcop --Valor antigo
                ,pr_vlcampo2 => pr_nmtitcop --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'cpf tit.'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrcpftit --Valor antigo
                ,pr_vlcampo2 => pr_nrcpftit --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'nome contador'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nmctrcop --Valor antigo
                ,pr_vlcampo2 => pr_nmctrcop --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'email contador'  --Descrição do campo
                ,pr_vlrcampo => vr_dsemlctr --Valor antigo
                ,pr_vlcampo2 => pr_dsemlctr --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'cpf contador'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrcpfctr --Valor antigo
                ,pr_vlcampo2 => pr_nrcpfctr --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;


    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'crc contador'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrcrcctr --Valor antigo
                ,pr_vlcampo2 => pr_nrcrcctr --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'reg.na junta'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrrjunta --Valor antigo
                ,pr_vlcampo2 => pr_nrrjunta --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'data registro'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.dtrjunta,'DD/MM/RRRR') --Valor antigo
                ,pr_vlcampo2 => to_char(vr_dtrjunta,'DD/MM/RRRR') --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'inscr.estadual'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrinsest --Valor antigo
                ,pr_vlcampo2 => pr_nrinsest --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'inscr.municipal'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrinsmun --Valor antigo
                ,pr_vlcampo2 => pr_nrinsmun --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'livro aplicacoes'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrlivapl --Valor antigo
                ,pr_vlcampo2 => pr_nrlivapl --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'livro de capital'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrlivcap --Valor antigo
                ,pr_vlcampo2 => pr_nrlivcap --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'livro dep.vista'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrlivdpv --Valor antigo
                ,pr_vlcampo2 => pr_nrlivdpv --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'livro de emprestimos'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrlivepr --Valor antigo
                ,pr_vlcampo2 => pr_nrlivepr --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Cod.COMPE Cecred'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.cdbcoctl --Valor antigo
                ,pr_vlcampo2 => pr_cdbcoctl --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Nro.Age da Central'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.cdagectl --Valor antigo
                ,pr_vlcampo2 => pr_cdagectl --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'age.bancoob'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.cdagebcb --Valor antigo
                ,pr_vlcampo2 => pr_cdagebcb --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'age.BB'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.cdagedbb --Valor antigo
                ,pr_vlcampo2 => pr_cdagedbb --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'age.ITG'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.cdageitg --Valor antigo
                ,pr_vlcampo2 => pr_cdageitg --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'cnv.ITG'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.cdcnvitg --Valor antigo
                ,pr_vlcampo2 => pr_cdcnvitg --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'massificado ITG'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.cdmasitg --Valor antigo
                ,pr_vlcampo2 => pr_cdmasitg --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'cta.conv.BB'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrctabbd --Valor antigo
                ,pr_vlcampo2 => pr_nrctabbd --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'conta na Cecred'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrctactl --Valor antigo
                ,pr_vlcampo2 => pr_nrctactl --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'conta integracao'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrctaitg --Valor antigo
                ,pr_vlcampo2 => pr_nrctaitg --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'cta.ITG'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrctadbb --Valor antigo
                ,pr_vlcampo2 => pr_nrctadbb --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'cta.Compe CECRED'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrctacmp --Valor antigo
                ,pr_vlcampo2 => pr_nrctacmp --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'conta/dv'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrdconta --Valor antigo
                ,pr_vlcampo2 => pr_nrdconta --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'SIRC'  --Descrição do campo
                ,pr_vlrcampo => (CASE WHEN rw_crapcop.flgdsirc = 0 THEN 'CAPITAL' ELSE 'INTERIOR' END)  --Valor antigo
                ,pr_vlcampo2 => (CASE WHEN pr_flgdsirc = 0 THEN 'CAPITAL' ELSE 'INTERIOR' END) --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'cartao magnetico'  --Descrição do campo
                ,pr_vlrcampo => (CASE WHEN rw_crapcop.flgcrmag = 0 THEN 'Nao' ELSE 'Sim' END)  --Valor antigo
                ,pr_vlcampo2 => (CASE WHEN pr_flgcrmag = 0 THEN 'Nao' ELSE 'Sim' END) --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Dias Env.TAA'  --Descrição do campo
               ,pr_vlrcampo => rw_crapcop.qtdiaenl --Valor antigo
               ,pr_vlcampo2 => pr_qtdiaenl --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Emite informativo chegada cartao'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.cdsinfmg --Valor antigo
                ,pr_vlcampo2 => pr_cdsinfmg --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'valor Max.Central'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.vlmaxcen,'fm999g999g999g990d00') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_vlmaxcen,'fm999g999g999g990d00') --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'valor Max.Legal'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.vlmaxleg,'fm999g999g999g990d00') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_vlmaxleg,'fm999g999g999g990d00') --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'valor Max.Utilizado'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.vlmaxutl,'fm999g999g990d00') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_vlmaxutl,'fm999g999g990d00') --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'valor Consulta SCR'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.vlcnsscr,'fm999g999g999g990d00') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_vlcnsscr,'fm999g999g999g990d00') --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Possui Comite Local'  --Descrição do campo
                ,pr_vlrcampo => (CASE WHEN rw_crapcop.flgcmtlc = 0 THEN 'Nao' ELSE 'Sim' END)  --Valor antigo
                ,pr_vlcampo2 => (CASE WHEN pr_flgcmtlc = 0 THEN 'Nao' ELSE 'Sim' END) --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Valor Limite Alcada Geral'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.vllimapv,'fm999g999g999g990d00') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_vllimapv,'fm999g999g999g990d00')  --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'diretorio onde esta sistema'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.dsdircop --Valor antigo
                ,pr_vlcampo2 => pr_dsdircop  --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'diretorio padrao arq.textos'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nmdireto --Valor antigo
                ,pr_vlcampo2 => pr_nmdireto   --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'participa progrid'  --Descrição do campo
                ,pr_vlrcampo => (CASE WHEN rw_crapcop.flgdopgd = 0 THEN 'Nao' ELSE 'Sim' END) --Valor antigo
                ,pr_vlcampo2 => (CASE WHEN pr_flgdopgd = 0 THEN 'Nao' ELSE 'Sim' END) --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'horario inicial processo'  --Descrição do campo
                ,pr_vlrcampo => to_char(to_date(rw_crapcop.hrproces,'sssss'),'hh24:mi:ss') --Valor antigo
                ,pr_vlcampo2 => pr_hrproces   --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'horario final processo'  --Descrição do campo
                ,pr_vlrcampo => to_char(to_date(rw_crapcop.hrfinprc,'sssss'),'hh24:mi:ss') --Valor antigo
                ,pr_vlcampo2 => pr_hrfinprc --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'data do cnpj'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.dtcdcnpj,'DD/MM/RRRR') --Valor antigo
                ,pr_vlcampo2 => to_char(vr_dtcdcnpj,'DD/MM/RRRR')   --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'convenio - coban'  --Descrição do campo
                ,pr_vlrcampo => vr_nrconven --Valor antigo
                ,pr_vlcampo2 => pr_nrconven   --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'versao - coban'  --Descrição do campo
                ,pr_vlrcampo => vr_nrversao --Valor antigo
                ,pr_vlcampo2 => pr_nrversao   --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'tarifa pagto. - coban'  --Descrição do campo
                ,pr_vlrcampo => to_char(vr_vldataxa,'fm990d00') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_vldataxa,'fm990d00')  --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'tarifa inss - coban'  --Descrição do campo
                ,pr_vlrcampo => to_char(vr_vltxinss,'fm990d00') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_vltxinss,'fm990d00')  --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Arrecadacao GPS - coban'  --Descrição do campo
                ,pr_vlrcampo => (CASE WHEN rw_crapcop.flgargps = 0 THEN 'Nao' ELSE 'Sim' END) --Valor antigo
                ,pr_vlcampo2 => (CASE WHEN pr_flgargps = 0 THEN 'Nao' ELSE 'Sim' END)  --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Data do Contrato - DDA'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.dtctrdda,'DD/MM/RRRR') --Valor antigo
                ,pr_vlcampo2 => to_char(vr_dtctrdda,'DD/MM/RRRR') --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'N. do Contrato - DDA'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrctrdda --Valor antigo
                ,pr_vlcampo2 => pr_nrctrdda   --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'N. do Livro - DDA'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.idlivdda --Valor antigo
                ,pr_vlcampo2 => pr_idlivdda  --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'N. da Folha - DDA'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.nrfoldda --Valor antigo
                ,pr_vlcampo2 => pr_nrfoldda   --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Local de Registro - DDA'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.dslocdda --Valor antigo
                ,pr_vlcampo2 => pr_dslocdda   --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Cidade - DDA'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.dsciddda --Valor antigo
                ,pr_vlcampo2 => pr_dsciddda  --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'conta coope Ems. Boleto'  --Descrição do campo
                ,pr_vlrcampo => to_char(vr_nrctabol,'fm9999g999g9') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_nrctabol,'fm9999g999g9')   --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'linha credito Ems. Boleto'  --Descrição do campo
                ,pr_vlrcampo => to_char(vr_cdlcrbol,'990') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_cdlcrbol,'990')   --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Intervalo de Tempo Sangria'  --Descrição do campo
                ,pr_vlrcampo => to_char(to_date(rw_crapcop.qttmpsgr,'sssss'),'hh24:mi') --Valor antigo
                ,pr_vlcampo2 => pr_qttmpsgr  --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Valor minimo contratacao plano de cotas'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.vlmiplco,'fm999g999g990d00') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_vlmiplco,'fm999g999g990d00')  --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Valor minimo debito de cotas'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.vlmidbco,'fm999g999g990d00') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_vlmidbco,'fm999g999g990d00')  --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Codigo da financeira'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.cdfingrv,'000000000000000') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_cdfingrv,'000000000000000')  --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Subcodigo do usuario'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.cdsubgrv,'990') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_cdsubgrv,'990')  --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Login do usuario'  --Descrição do campo
                ,pr_vlrcampo => rw_crapcop.cdloggrv --Valor antigo
                ,pr_vlcampo2 => pr_cdloggrv --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Agencia Sicredi'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.cdagesic,'fm9g999g990') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_cdagesic,'fm9g999g990') --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Conta Sicredi'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.nrctasic,'fm9g999g990') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_nrctasic,'fm9g999g990') --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Credencial dos arrecadadores'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.cdcrdins,'99999990') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_cdcrdins,'99999990') --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Tarifa Tributo Federal'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.vltardrf,'fm999g999g990d00') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_vltardrf,'fm999g999g990d00') --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Horario inicio pagamento GPS'  --Descrição do campo
                ,pr_vlrcampo => to_char(to_date(rw_crapcop.hrinigps,'sssss'),'hh24:mi') --Valor antigo
                ,pr_vlcampo2 => pr_hrinigps --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Horario fim pagamento GPS'  --Descrição do campo
                ,pr_vlrcampo => to_char(to_date(rw_crapcop.hrfimgps,'sssss'),'hh24:mi') --Valor antigo
                ,pr_vlcampo2 => pr_hrfimgps --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Horario limite pagamento SICREDI'  --Descrição do campo
                ,pr_vlrcampo => to_char(to_date(rw_crapcop.hrlimsic,'sssss'),'hh24:mi') --Valor antigo
                ,pr_vlcampo2 => pr_hrlimsic --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Saque presencial'  --Descrição do campo
                ,pr_vlrcampo => (CASE WHEN rw_crapcop.flsaqpre = 0 THEN 'Isentar' ELSE 'Nao Isentar' END) --Valor antigo
                ,pr_vlcampo2 => (CASE WHEN pr_flsaqpre = 0 THEN 'Isentar' ELSE 'Nao Isentar' END) --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Percentual maximo de desconto manual'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.permaxde,'fm990d00') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_permaxde,'fm990d00') --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Quantidade máxima de meses de desconto'  --Descrição do campo
                ,pr_vlrcampo => to_char(rw_crapcop.qtmaxmes,'990') --Valor antigo
                ,pr_vlcampo2 => to_char(pr_qtmaxmes,'990') --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;

    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                ,pr_cdoperad => vr_cdoperad -- Operador
                ,pr_dsdcampo => 'Permitir reciprocidade'  --Descrição do campo
                ,pr_vlrcampo => (CASE WHEN rw_crapcop.flrecpct = 0 THEN 'Nao' ELSE 'Sim' END) --Valor antigo
                ,pr_vlcampo2 => (CASE WHEN pr_flrecpct = 0 THEN 'Nao' ELSE 'Sim' END)  --Valor atual
                ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;


    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Quantidade de meses para atualização Telefone'  --Descrição do campo
               ,pr_vlrcampo => to_char(rw_crapcop.qtmeatel,'990') --Valor antigo
               ,pr_vlcampo2 => to_char(pr_qtmeatel,'990') --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;


    --Realiza commit das alterações
    COMMIT;
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';

      ROLLBACK;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TELA_CADCOP.pc_alterar_cooperativa: ' || SQLERRM;
      pr_des_erro := 'NOK';

      pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_alterar_cooperativa;

  PROCEDURE pc_consulta_municipios(pr_cddopcao  IN VARCHAR2                --> Código da opção
                                  ,pr_nrregist  IN INTEGER                 --> Número de registros
                                  ,pr_nriniseq  IN INTEGER                 --> Número sequencial
                                  ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER            --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2               --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2) IS           --> Descrição do erro

    CURSOR cr_municipios(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT m.cdcidade
          ,m.cdestado
          ,m.dscidade
          ,m.progress_recid
     FROM tbgen_cid_atuacao_coop a
         ,crapmun m
    WHERE a.cdcooper = pr_cdcooper
      AND m.cdcidade = a.cdcidade
     ORDER BY m.dscidade;
    rw_municipios cr_municipios%ROWTYPE;

    --Variáveis locais
    vr_nrregist INTEGER;
    vr_qtregist INTEGER := 0;
    vr_cdoperad VARCHAR2(100);
    vr_cdcooper NUMBER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis Arquivo Dados
    vr_auxconta PLS_INTEGER:= 0;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    vr_exc_saida EXCEPTION;

  BEGIN

    vr_nrregist := pr_nrregist;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCOP'
                              ,pr_action => null);

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'municipios', pr_tag_cont => null, pr_des_erro => vr_dscritic);

    FOR rw_municipios IN cr_municipios(pr_cdcooper => vr_cdcooper) LOOP

      --Incrementar contador
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

      -- controles da paginacao
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

        --Proximo
        CONTINUE;

      END IF;

      IF vr_nrregist > 0 THEN

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'municipios', pr_posicao => 0, pr_tag_nova => 'municipio', pr_tag_cont => null, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'municipio', pr_posicao => vr_auxconta, pr_tag_nova => 'dscidade', pr_tag_cont => rw_municipios.dscidade, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'municipio', pr_posicao => vr_auxconta, pr_tag_nova => 'cdestado', pr_tag_cont => rw_municipios.cdestado, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'municipio', pr_posicao => vr_auxconta, pr_tag_nova => 'cdcidade', pr_tag_cont => rw_municipios.cdcidade, pr_des_erro => vr_dscritic);

        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;

       END IF;

     --Diminuir registros
     vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Dados'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TELA_CADCOP.pc_consulta_municipios: ' || SQLERRM;
      pr_des_erro := 'NOK';

      pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_consulta_municipios;


  PROCEDURE pc_manter_municipios(pr_cddopcao  IN VARCHAR2                --> Código da opção
                                ,pr_cdcidade  IN tbgen_cid_atuacao_coop.cdcidade%TYPE  --> Código da cidade
                                ,pr_dscidade  IN crapmun.dscidade%TYPE   --> Nome da cidade
                                ,pr_cdestado  IN crapmun.cdestado%TYPE   --> Estado
                                ,pr_tpoperac  IN VARCHAR2                --> Tipo da operação
                                ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER            --> Código da crítica
                                ,pr_dscritic  OUT VARCHAR2               --> Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2) IS           --> Descrição do erro

    CURSOR cr_crapmun(pr_dscidade IN crapmun.dscidade%TYPE
                     ,pr_cdestado IN crapmun.cdestado%TYPE) IS
    SELECT m.cdcidade
          ,m.dscidade
          ,m.cdestado
     FROM crapmun m
    WHERE UPPER(m.dscidade) = pr_dscidade
      AND UPPER(m.cdestado) = pr_cdestado;
    rw_crapmun cr_crapmun%ROWTYPE;

    CURSOR cr_tbgen_cid_atuacao_coop(pr_cdcidade IN tbgen_cid_atuacao_coop.cdcidade%TYPE
                                    ,pr_cdcooper IN tbgen_cid_atuacao_coop.cdcooper%TYPE) IS
    SELECT t.cdcidade
          ,m.dscidade
          ,m.cdestado
     FROM tbgen_cid_atuacao_coop t
         ,crapmun m
    WHERE t.cdcooper = pr_cdcooper
      AND t.cdcidade = pr_cdcidade
      AND m.cdcidade = t.cdcidade;
    rw_tbgen_cid_atuacao_coop cr_tbgen_cid_atuacao_coop%ROWTYPE;

    --Variáveis locais
    vr_cdoperad VARCHAR2(100);
    vr_cdcooper NUMBER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    vr_exc_saida EXCEPTION;

  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCOP'
                              ,pr_action => null);

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    IF pr_tpoperac = 'I' THEN

      IF trim(pr_dscidade) IS NULL THEN

        vr_cdcritic := 0;
        vr_dscritic := 'Nome da cidade deve ser informado.';
        pr_nmdcampo := 'dscidade';

        RAISE vr_exc_saida;

      END IF;

      IF trim(pr_cdestado) IS NULL THEN

        vr_cdcritic := 0;
        vr_dscritic := 'UF da cidade deve ser informado.';
        pr_nmdcampo := 'cdestado';

        RAISE vr_exc_saida;

      END IF;

      OPEN cr_crapmun(pr_dscidade => UPPER(pr_dscidade)
                     ,pr_cdestado => UPPER(pr_cdestado));

      FETCH cr_crapmun INTO rw_crapmun;

      IF cr_crapmun%FOUND THEN

        CLOSE cr_crapmun;

        OPEN cr_tbgen_cid_atuacao_coop(pr_cdcidade => rw_crapmun.cdcidade
                                      ,pr_cdcooper => vr_cdcooper);

        FETCH cr_tbgen_cid_atuacao_coop INTO rw_tbgen_cid_atuacao_coop;

        IF cr_tbgen_cid_atuacao_coop%FOUND THEN

          CLOSE cr_tbgen_cid_atuacao_coop;

          vr_dscritic := 'Municipio ja cadastrado.';
          RAISE vr_exc_saida;

        ELSE

          CLOSE cr_tbgen_cid_atuacao_coop;

          BEGIN

            INSERT INTO tbgen_cid_atuacao_coop
                       (tbgen_cid_atuacao_coop.cdcidade
                       ,tbgen_cid_atuacao_coop.cdcooper)
                 VALUES(rw_crapmun.cdcidade
                       ,vr_cdcooper);

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Nao foi possivel criar o registro de municipio.';
              RAISE vr_exc_saida;

          END;

          -- Gera log
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => 'cadcop.log'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                        'Incluiu o municipio ' ||  trim(rw_crapmun.dscidade) ||
                                                        ' - ' || rw_crapmun.cdestado ||'.');

        END IF;

      ELSE

        CLOSE cr_crapmun;

        vr_cdcritic := 0;
        vr_dscritic := 'Municipio/UF nao cadastrado.';
        RAISE vr_exc_saida;

      END IF;

    ELSIF pr_tpoperac = 'E' THEN

      IF nvl(pr_cdcidade,0) = 0 THEN

        vr_cdcritic := 0;
        vr_dscritic := 'Codigo da cidade invalido.';
        pr_nmdcampo := 'cdcidade';

        RAISE vr_exc_saida;

      END IF;

      OPEN cr_tbgen_cid_atuacao_coop(pr_cdcidade => pr_cdcidade
                                    ,pr_cdcooper => vr_cdcooper);

      FETCH cr_tbgen_cid_atuacao_coop INTO rw_tbgen_cid_atuacao_coop;

      IF cr_tbgen_cid_atuacao_coop%FOUND THEN

        CLOSE cr_tbgen_cid_atuacao_coop;

        BEGIN

          DELETE tbgen_cid_atuacao_coop
           WHERE tbgen_cid_atuacao_coop.cdcidade = pr_cdcidade
             AND tbgen_cid_atuacao_coop.cdcooper = vr_cdcooper;

        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel excluir o registro de municipio.';
            RAISE vr_exc_saida;

        END;

        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'cadcop.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                      'Deletou o municipio ' ||  trim(rw_tbgen_cid_atuacao_coop.dscidade) ||
                                                      ' - ' || rw_tbgen_cid_atuacao_coop.cdestado ||'.');


      ELSE

        CLOSE cr_tbgen_cid_atuacao_coop;

        vr_cdcritic := 0;
        vr_dscritic := 'Municipio nao encontrado.';
        RAISE vr_exc_saida;

      END IF;

    END IF;

    --Realiza o commit das alterações
    COMMIT;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TELA_CADCOP.pc_manter_municipios: ' || SQLERRM;
      pr_des_erro := 'NOK';

      pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_manter_municipios;



END TELA_CADCOP;
/
