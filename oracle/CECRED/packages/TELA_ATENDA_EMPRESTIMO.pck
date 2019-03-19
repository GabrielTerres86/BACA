CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_EMPRESTIMO IS

  /* Tipo que compreende o registro da tab. temporaria  */
  TYPE typ_reg_dados_crapcri IS RECORD (
      cdcritic crapcri.Cdcritic%TYPE
     ,dscritic crapcri.Dscritic%TYPE
     ,tpcritic crapcri.Cdcritic%TYPE);
     
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_dados_crapcri IS TABLE OF typ_reg_dados_crapcri INDEX BY BINARY_INTEGER;


  PROCEDURE pc_calc_data_carencia(pr_dtcarenc   IN VARCHAR2 --> Data da Carencia
                                 ,pr_idcarenc   IN INTEGER --> Codigo da Carencia
                                 ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_prmpos(pr_vlminimo_emprestado OUT tbepr_posfix_param.vlminimo_emprestado%TYPE -- Valor Minimo Emprestado
                           ,pr_vlmaximo_emprestado OUT tbepr_posfix_param.vlmaximo_emprestado%TYPE -- Valor Maximo Emprestado
                           ,pr_qtdminima_parcela   OUT tbepr_posfix_param.qtdminima_parcela%TYPE -- Quantidade Minima Parcela
                           ,pr_qtdmaxima_parcela   OUT tbepr_posfix_param.qtdmaxima_parcela%TYPE -- Quantidade Maxima Parcela
                           ,pr_cdcritic            OUT INTEGER -- Codigo de critica
                           ,pr_dscritic            OUT VARCHAR2); -- Descricao da critica
                           
  PROCEDURE pc_valida_inf_cadastrais_web(pr_nrdconta           IN crapass.nrdconta%type --> Conta
                                        ,pr_cdlcremp           IN craplcr.cdlcremp%type --> linha de crédito
                                          -- campos padrões  
                                         ,pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                         ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                         ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                         ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                         ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                         );
  
  PROCEDURE pc_valida_inf_cad_car( pr_nrdconta       IN crapass.nrdconta%type --> Conta
                                  , pr_cdlcremp       IN craplcr.cdlcremp%type --> linha de crédito
                                  --
                                  , pr_cdcooper       IN crapcop.cdcooper%TYPE --> Cooperativa
                                  , pr_nmdatela       IN VARCHAR2              --> Tela
                                  , pr_cdagenci       IN crapass.cdagenci%TYPE --> Agencia
                                  , pr_nrdcaixa       IN craperr.nrdcaixa%TYPE --> Caixa
                                  , pr_idorigem       IN INTEGER               --> Origem
                                  , pr_cdoperad       IN craplgm.cdoperad%TYPE --> Operador
                                  -- campos padrões OUT 
                                  , pr_des_erro       OUT VARCHAR2              --> Saida OK/NOK
                                  , pr_clob_ret       OUT CLOB                  --> Tabela Extrato da Conta
                                  , pr_cdcritic       OUT PLS_INTEGER           --> Codigo da critica
                                  , pr_dscritic       OUT VARCHAR2              --> Descricao da critica
                                  ) ;                                                                               
END TELA_ATENDA_EMPRESTIMO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_EMPRESTIMO IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_EMPRESTIMO
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Marco - 2017                 Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela Emprestimos dentro da ATENDA
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_calc_data_carencia(pr_dtcarenc   IN VARCHAR2 --> Data da Carencia
                                 ,pr_idcarenc   IN INTEGER --> Codigo da Carencia
                                 ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_calc_data_carencia
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para calcular a data conforme a carencia informada.

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Busca os dias
      CURSOR cr_param(pr_idcarenc IN tbepr_posfix_param_carencia.idcarencia%TYPE) IS
        SELECT NVL(qtddias,0)
          FROM tbepr_posfix_param_carencia
         WHERE idparametro = 1
           AND idcarencia  = pr_idcarenc;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_dtcarenc DATE := '';
      vr_dd       VARCHAR2(2);
      vr_mmaaaa   VARCHAR2(8);
      vr_qtddias  tbepr_posfix_param_carencia.qtddias%TYPE;

    BEGIN
      -- Busca os dias
      OPEN cr_param(pr_idcarenc => pr_idcarenc);
      FETCH cr_param INTO vr_qtddias;
      CLOSE cr_param;

      -- Se possui dias para adicionar
      IF vr_qtddias > 0 THEN
        vr_dd := SUBSTR(pr_dtcarenc,1,2);
        BEGIN
          IF TO_NUMBER(vr_dd) >= 28 THEN
            vr_dscritic := 'Data de Pagamento não pode ser maior ou igual ao dia 28.';
            RAISE vr_exc_saida;
          END IF;
          vr_dtcarenc := TO_DATE(pr_dtcarenc, 'DD/MM/RRRR');
          vr_dtcarenc := vr_dtcarenc + vr_qtddias;
          vr_mmaaaa   := TO_CHAR(vr_dtcarenc,'MM/RRRR');
          vr_dtcarenc := TO_DATE(vr_dd || '/' || vr_mmaaaa, 'DD/MM/RRRR');
        EXCEPTION
          WHEN vr_exc_saida THEN
            RAISE vr_exc_saida;
          WHEN OTHERS THEN
            vr_dscritic := 'Data da carência é inválida.';
            RAISE vr_exc_saida;
        END;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dtcarenc'
                            ,pr_tag_cont => TO_CHAR(vr_dtcarenc,'DD/MM/RRRR')
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_EMPRESTIMO: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

    END;

  END pc_calc_data_carencia;

  PROCEDURE pc_busca_prmpos(pr_vlminimo_emprestado OUT tbepr_posfix_param.vlminimo_emprestado%TYPE -- Valor Minimo Emprestado
                           ,pr_vlmaximo_emprestado OUT tbepr_posfix_param.vlmaximo_emprestado%TYPE -- Valor Maximo Emprestado
                           ,pr_qtdminima_parcela   OUT tbepr_posfix_param.qtdminima_parcela%TYPE -- Quantidade Minima Parcela
                           ,pr_qtdmaxima_parcela   OUT tbepr_posfix_param.qtdmaxima_parcela%TYPE -- Quantidade Maxima Parcela
                           ,pr_cdcritic            OUT INTEGER -- Codigo de critica
                           ,pr_dscritic            OUT VARCHAR2) IS -- Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_busca_prmpos
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Abril/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os parametros do Pos-Fixado.

    Alteracoes: 
    ..............................................................................*/

    DECLARE
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Vetor para armazenar os dados da tabela
      vr_tab_param TELA_PRMPOS.typ_tab_param;

    BEGIN
      -- Carrega os dados
      TELA_PRMPOS.pc_carrega_dados(pr_tab_param => vr_tab_param
                                  ,pr_cdcritic  => vr_cdcritic
                                  ,pr_dscritic  => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Se encontrou
      IF vr_tab_param.COUNT > 0 THEN
        pr_vlminimo_emprestado := vr_tab_param(0).vlminimo_emprestado;
        pr_vlmaximo_emprestado := vr_tab_param(0).vlmaximo_emprestado;
        pr_qtdminima_parcela   := vr_tab_param(0).qtdminima_parcela;
        pr_qtdmaxima_parcela   := vr_tab_param(0).qtdmaxima_parcela;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_EMPRESTIMO: ' || SQLERRM;
    END;

  END pc_busca_prmpos;

  PROCEDURE pc_valida_inf_proposta(pr_cdcooper  IN crapemp.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%type  --> Conta
                                  ,pr_cdlcremp  IN craplcr.cdlcremp%type  --> linha de crédito
                                   --> OUT <--
                                   ,pr_qtregist               OUT integer                   --> Quantidade de registros encontrados
                                   ,pr_tab_dados_crapcri      OUT typ_tab_dados_crapcri     --> Tabela de retorno
                                   ,pr_cdcritic               OUT PLS_INTEGER               --> Código da crítica
                                   ,pr_dscritic               OUT VARCHAR2                  --> Descrição da crítica
                                   ) IS          --> Saida OK/NOK  --

  /* .............................................................................

    Programa: pc_valida_inf_proposta
    Sistema : AIMARO
    Autor   : AMcom Sistemas de Informação - Projeto 437 - Consignado
    Data    : 11/03/2019                       Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Validações da inclusão da proposta do consignado

    Alteracoes: 
    ..............................................................................*/ 
         
  --Variaveis Locais   
  vr_tpmodcon_emp  tbcadast_empresa_consig.tpmodconvenio%TYPE;
  vr_tpmodcon_lcr  craplcr.tpmodcon%TYPE; 
  vr_dtvencimento  date;
  --vr_dtliberacao   date;
  vr_clob          CLOB;   
  vr_xml_temp      VARCHAR2(32726) := '';      
  vr_qtregist      INTEGER := 0; 

  --Controle de erro
  vr_exc_erro EXCEPTION;
  vr_saida    EXCEPTION;
  
  vr_idtab number;
  --
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;        
  rw_crapdat btch0001.cr_crapdat%ROWTYPE; 
  
  -- tipo da pessoa
  CURSOR cr_crapass (pr_cdcooper IN NUMBER)IS
    SELECT a.inpessoa
     FROM crapass a
    WHERE a.cdcooper = pr_cdcooper
      AND a.nrdconta = pr_nrdconta;
      
   -- modalidade do consignado da linha de crédito 
  CURSOR cr_craplcr (pr_cdcooper IN NUMBER) IS
    SELECT l.tpmodcon,
           l.cdmodali,
           l.cdsubmod
      FROM craplcr l
     WHERE l.cdcooper = pr_cdcooper
       AND l.cdlcremp = pr_cdlcremp;
  
  -- modalidade do convenio da empresa do cooperado
  CURSOR cr_tpmodcon (pr_cdcooper IN NUMBER)IS
    SELECT tpmodconvenio
     FROM tbcadast_empresa_consig c
    WHERE c.cdcooper = pr_cdcooper
      AND c.indconsignado = 1
      AND c.cdempres IN (SELECT t.cdempres
                           FROM crapttl t
                          WHERE t.cdcooper = pr_cdcooper
                            AND t.nrdconta = pr_nrdconta
                            AND t.idseqttl = 1); 
  
  -- Busca o vencimento da 1ª parcela
  CURSOR cr_vecto (pr_cdcooper IN NUMBER,
                   pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT MIN(b.dtvencimento) dtvencimento
      FROM tbcadast_empresa_consig a,
           tbcadast_emp_consig_param b
     WHERE a.idemprconsig = b.idemprconsig
       AND a.cdcooper = pr_cdcooper
       AND a.indconsignado = 1
       AND TO_DATE(TO_CHAR(pr_dtmvtolt,'dd/mm'),'dd/mm') BETWEEN TO_DATE(TO_CHAR(b.dtinclpropostade, 'dd/mm'),'dd/mm')
                                                             AND TO_DATE(TO_CHAR(b.dtinclpropostaate,'dd/mm'),'dd/mm')
       AND a.cdempres IN (SELECT t.cdempres
                            FROM crapttl t
                           WHERE t.cdcooper = pr_cdcooper
                             AND t.nrdconta = pr_nrdconta
                             AND t.idseqttl = 1);
                             
  
  BEGIN
    
    -- verifica a modalidade do consignado da linha de crédito 
    FOR rg_craplcr IN cr_craplcr(pr_cdcooper => pr_cdcooper)
    LOOP
      -- Verifica se modalidade = 02-emprestimo,
      -- submodalidade = 02 -Crédito pessoal consignado em folha
      /*if rg_craplcr.cdmodali <> '02' OR
         rg_craplcr.cdsubmod <> '02'THEN
         vr_cdcritic:= 0;
         vr_cdcritic:= null;
         RAISE vr_saida;
      end if;*/
      
      vr_tpmodcon_lcr:= rg_craplcr.tpmodcon;
    END LOOP; 
   
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
    ELSE
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    FOR rg_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper)
    LOOP
      -- se o tipo de pessoa for diferente de pessoa fisica, não deixa cadastrar
      IF rg_crapass.inpessoa <> 1 THEN
        vr_idtab := pr_tab_dados_crapcri.count + 1;         
        pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
        pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Operacao nao permitida para este Tipo de Pessoa.';
        pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1; 
        pr_qtregist := nvl(pr_qtregist,0) + 1;
      END IF;
    END LOOP;
    
    -- verifica a modalidade do consignado cadastrado para a empresa do cooperado
    FOR rg_tpmodcon IN cr_tpmodcon (pr_cdcooper => pr_cdcooper)
    LOOP
       vr_tpmodcon_emp := rg_tpmodcon.tpmodconvenio;
    END LOOP;
    
    -- Caso as modalidades sejam diferentes, o sistema não permite a continuação da simulação 
    -- e apresentar mensagem ao operador
    IF vr_tpmodcon_lcr <> vr_tpmodcon_emp THEN
      vr_idtab := pr_tab_dados_crapcri.count + 1;         
      pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
      pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Modalidade de Consignado da Linha de Credito diferente da modalidade disponivel para este cooperado.';
      pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1; 
      pr_qtregist := nvl(pr_qtregist,0) + 1;   
    END IF;
    
    -- busca o 1º vencimento da parcela
    FOR rg_vecto in cr_vecto (pr_cdcooper => pr_cdcooper,
                              pr_dtmvtolt => rw_crapdat.dtmvtolt)
    LOOP
      vr_dtvencimento:= rg_vecto.dtvencimento;
    END LOOP;
    
    IF vr_dtvencimento is null THEN
      vr_idtab := pr_tab_dados_crapcri.count + 1;         
      pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
      pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Vencimento da 1ª parcela nao encontrado.';
      pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1; 
      pr_qtregist := nvl(pr_qtregist,0) + 1;
    END IF;
        
   
 EXCEPTION
    WHEN vr_exc_erro THEN
      /* busca valores de critica predefinidos */
      IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        /* busca a descriçao da crítica baseado no código */
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado na tela_atenda_emprestimo.pc_valida_inf_proposta '||sqlerrm;
      pr_cdcritic := 0;
  END pc_valida_inf_proposta;  
 
  
  PROCEDURE pc_valida_inf_cadastrais( pr_cdcooper               IN crapemp.cdcooper%TYPE      --> Código da Cooperativa
                                     ,pr_nrdconta               IN NUMBER
                                      --> OUT <--
                                     ,pr_qtregist               OUT integer                   --> Quantidade de registros encontrados
                                     ,pr_tab_dados_crapcri      OUT typ_tab_dados_crapcri     --> Tabela de retorno
                                     ,pr_cdcritic               OUT PLS_INTEGER               --> Código da crítica
                                     ,pr_dscritic               OUT VARCHAR2                  --> Descrição da crítica
                                     ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_validar_inf_cadastrais
      Sistema  : Aimaro
      Sigla    : CONSIG
      Autor    : AMcom Sistemas de Informação  - Projeto 437 - Consignado
      Data     : 08/03/2019

      Objetivo  : Buscar as Críticas de Validação para Inclusão da Proposta.

      Alteração : 

    ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      CURSOR cr_inf_cadastrais IS
        SELECT cdestcvl estado_civil
              ,dtnasttl data_nascimento 
              ,cdnacion nacional
              ,dsnatura naturalidade
              ,cdsexotl sexo
              ,nrdocttl documento
              ,cdnatopc natureza_operacao
         FROM cecred.crapttl  --Cadastro de titulares da conta
        where nrdconta = pr_nrdconta
          and cdcooper = pr_cdcooper
          and idseqttl = 1 ;

      rw_inf_cadastrais cr_inf_cadastrais%ROWTYPE;
      
      CURSOR cr_inf_cadast_crapenc IS
        SELECT nrcepend  --CEP
              ,dsendere  --Rua
              ,nrendere  --Número
              ,nmbairro  --Bairro
              ,nmcidade  --Cidade
              ,cdufende  --UF             
          FROM cecred.crapenc  
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND idseqttl = 1
           AND tpendass = 10; --residencial
           
      rw_inf_cadast_crapenc cr_inf_cadast_crapenc%ROWTYPE;           

      /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descrição e código da critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      vr_idtab number;
    BEGIN
      --Validar Cadastro de titulares da conta
      OPEN cr_inf_cadastrais;
      LOOP
        FETCH cr_inf_cadastrais INTO rw_inf_cadastrais;
        EXIT WHEN cr_inf_cadastrais%NOTFOUND;

        --Validar Estado Civil
        if rw_inf_cadastrais.estado_civil is null then
          vr_idtab := pr_tab_dados_crapcri.count + 1;         
          pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
          pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Necessario informar o Estado Civil na tela Contas.';
          pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1; --Identifica o tipo de critica (1-Erro de Negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Informacao)                 
          pr_qtregist := nvl(pr_qtregist,0) + 1;  
        end if;
        --Data Nascimento
        if rw_inf_cadastrais.data_nascimento is null then 
          vr_idtab := pr_tab_dados_crapcri.count + 1;         
          pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
          pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Necessario informar a Data de Nascimento na tela Contas.';
          pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1; 
          pr_qtregist := nvl(pr_qtregist,0) + 1;   
        end if;
        --Nacionalidade
        if rw_inf_cadastrais.nacional is null then
          vr_idtab := pr_tab_dados_crapcri.count + 1;         
          pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
          pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Necessario informar a Nacionalidade na tela Contas.';
          pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1; 
          pr_qtregist := nvl(pr_qtregist,0) + 1;     
        end if;
        --Naturalidade
        if rw_inf_cadastrais.nacional is null then
          vr_idtab := pr_tab_dados_crapcri.count + 1;         
          pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
          pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Necessario informar a Naturalidade na tela Contas.';
          pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1;
          pr_qtregist := nvl(pr_qtregist,0) + 1;     
        end if;
        --Sexo
        if rw_inf_cadastrais.naturalidade is null then
          vr_idtab := pr_tab_dados_crapcri.count + 1;         
          pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
          pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Necessario informar o Sexo na tela Contas.';
          pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1; 
          pr_qtregist := nvl(pr_qtregist,0) + 1;     
        end if;
        --Documento (Número e Tipo)
        if rw_inf_cadastrais.sexo is null then
          vr_idtab := pr_tab_dados_crapcri.count + 1;         
          pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
          pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Necessario informar o Documento na tela Contas.';
          pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1; 
          pr_qtregist := nvl(pr_qtregist,0) + 1;     
        end if;
        --Natureza da Ocupação
        if rw_inf_cadastrais.documento is null then
          vr_idtab := pr_tab_dados_crapcri.count + 1;         
          pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
          pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Necessario informar a Natureza da Ocupacao na tela Contas.';
          pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1; 
          pr_qtregist := nvl(pr_qtregist,0) + 1;     
        end if;
               
      END LOOP;
      CLOSE cr_inf_cadastrais;
      
      --Validar Informações ref. enderecos do cooperado.
      OPEN cr_inf_cadast_crapenc;
      LOOP
        FETCH cr_inf_cadast_crapenc INTO rw_inf_cadast_crapenc;
        EXIT WHEN cr_inf_cadast_crapenc%NOTFOUND;

        --Validar CEP
        if rw_inf_cadast_crapenc.nrcepend is null then
          vr_idtab := pr_tab_dados_crapcri.count + 1;         
          pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
          pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Necessario informar o CEP na tela Contas.';
          pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1; --Identifica o tipo de critica (1-Erro de Negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Informacao)                 
          pr_qtregist := nvl(pr_qtregist,0) + 1;  
        end if;
        --Validar Rua
        if rw_inf_cadast_crapenc.dsendere is null then
          vr_idtab := pr_tab_dados_crapcri.count + 1;         
          pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
          pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Necessario informar a Rua na tela Contas.';
          pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1; 
          pr_qtregist := nvl(pr_qtregist,0) + 1;  
        end if;
        --Validar Número
        /*if rw_inf_cadast_crapenc.nrendere is null then
          vr_idtab := pr_tab_dados_crapcri.count + 1;         
          pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
          pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Numero nao informado.';
          pr_tab_dados_crapcri(vr_idtab).tpcritic  := 3; --Identifica o tipo de critica (1-Erro de Negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Informacao)                 
          pr_qtregist := nvl(pr_qtregist,0) + 1;  
        end if;*/
        --Validar Bairro
        if rw_inf_cadast_crapenc.nmbairro is null then
          vr_idtab := pr_tab_dados_crapcri.count + 1;         
          pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
          pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Necessario informar a Bairro na tela Contas.';
          pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1; 
          pr_qtregist := nvl(pr_qtregist,0) + 1;  
        end if;
        --Validar Cidade
        if rw_inf_cadast_crapenc.nmcidade is null then
          vr_idtab := pr_tab_dados_crapcri.count + 1;         
          pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
          pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Necessario informar a Cidade na tela Contas.';
          pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1; 
          pr_qtregist := nvl(pr_qtregist,0) + 1;  
        end if;
        --Validar UF
        if rw_inf_cadast_crapenc.cdufende is null then
          vr_idtab := pr_tab_dados_crapcri.count + 1;         
          pr_tab_dados_crapcri(vr_idtab).cdcritic  := 0;
          pr_tab_dados_crapcri(vr_idtab).dscritic  := 'Necessario informar a UF na tela Contas.';
          pr_tab_dados_crapcri(vr_idtab).tpcritic  := 1; 
          pr_qtregist := nvl(pr_qtregist,0) + 1;  
        end if;
               
      END LOOP;
      CLOSE cr_inf_cadast_crapenc;
                 
    EXCEPTION
      WHEN vr_exc_erro THEN
        /* busca valores de critica predefinidos */
        IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
          /* busca a descriçao da crítica baseado no código */
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro nao tratado na tela_atenda_emprestimo.pc_valida_inf_cadastrais '||sqlerrm;
        pr_cdcritic := 0;
    END;
  END pc_valida_inf_cadastrais;
  
  PROCEDURE pc_valida_inf_cadastrais_web(pr_nrdconta           IN crapass.nrdconta%type --> Conta
                                        ,pr_cdlcremp           IN craplcr.cdlcremp%type --> linha de crédito
                                         -- campos padrões  
                                        ,pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                        ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_validar_inf_cadastrais_web
      Sistema  : AIMARO
      Sigla    : CONSIG
      Autor    : AMcom Sistemas de Informação  - Projeto 437 - Consignado
      Data     : 08/03/2019

      Objetivo : Verificar se os dados de cadastro obrigatórios estão preenchidos no cadastro do cooperado 
                 para permitir a inclusão da proposta de Empréstimo Consignado 

      Alteração : 

    ----------------------------------------------------------------------------------------------------------*/
    BEGIN
    DECLARE
      /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descrição e código da critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- variaveis de retorno
      vr_tab_dados_crapcri typ_tab_dados_crapcri;
      vr_qtregist          number;

      -- variaveis de entrada vindas no xml
      vr_cdcooper integer;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);

      -- variáveis para armazenar as informaçoes em xml
      vr_des_xml        clob;
      vr_texto_completo varchar2(32600);
      vr_index          varchar2(100);
      
      vr_consignado     NUMBER := 0; -- 1 - Consignado 0 - Não Consignado

      procedure pc_escreve_xml( pr_des_dados in varchar2
                              , pr_fecha_xml in boolean default false
                              ) is
      begin
          gene0002.pc_escreve_xml( vr_des_xml
                                 , vr_texto_completo
                                 , pr_des_dados
                                 , pr_fecha_xml );
      end;

    BEGIN
      pr_nmdcampo := NULL;
      pr_des_erro := 'OK';
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);
      
      
      --Verificar se é uma linha de crédito do Consignado
      BEGIN
        SELECT 1
          INTO vr_consignado
          FROM cecred.craplcr
         WHERE nvl(tpmodcon,0) > 0 --Tipo da modalidade do consignado  
           AND cdlcremp = pr_cdlcremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problema na verificacao da linha de credito. Erro: '||sqlerrm;
          raise vr_exc_erro;
      END;
        
      IF vr_consignado = 1 THEN 
       
       --Valida Informações Poposta
       tela_atenda_emprestimo.pc_valida_inf_proposta( pr_cdcooper          => vr_cdcooper
                                                          ,pr_nrdconta          => pr_nrdconta
                                                          ,pr_cdlcremp          => pr_cdlcremp
                                                           --> OUT <--
                                                          ,pr_qtregist          => vr_qtregist
                                                          ,pr_tab_dados_crapcri => vr_tab_dados_crapcri
                                                          ,pr_cdcritic          => vr_cdcritic
                                                          ,pr_dscritic          => vr_dscritic);                                 
       
       IF (nvl(vr_cdcritic,0) <> 0 OR  vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
       END IF; 
        
       --Valida Informações Cadastrais
       tela_atenda_emprestimo.pc_valida_inf_cadastrais( pr_cdcooper          => vr_cdcooper
                                                            ,pr_nrdconta          => pr_nrdconta
                                                             --> OUT <--
                                                            ,pr_qtregist          => vr_qtregist
                                                            ,pr_tab_dados_crapcri => vr_tab_dados_crapcri
                                                            ,pr_cdcritic          => vr_cdcritic
                                                            ,pr_dscritic          => vr_dscritic);                                 
        
       IF (nvl(vr_cdcritic,0) <> 0 OR  vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
       END IF;      
     
     END IF;
       
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados qtregist="' || vr_qtregist ||'" >');

      -- ler os registros do consignado e incluir no xml
      vr_index := vr_tab_dados_crapcri.first;
      while vr_index is not null loop
        
            pc_escreve_xml('<inf>'||
                             '<cdcritic>'|| vr_tab_dados_crapcri(vr_index).cdcritic ||'</cdcritic>'||
                             '<dscritic>'|| vr_tab_dados_crapcri(vr_index).dscritic ||'</dscritic>'||
                             '<tpcritic>'|| vr_tab_dados_crapcri(vr_index).tpcritic ||'</tpcritic>'||
                           '</inf>');
          /* buscar proximo */
          vr_index := vr_tab_dados_crapcri.next(vr_index);
      end loop;
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_erro THEN
           /*  se foi retornado apenas código */
           IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           /* variavel de erro recebe erro ocorrido */
           pr_des_erro := 'NOK';
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
             pr_des_erro := 'NOK';
           /* montar descriçao de erro nao tratado */
             pr_dscritic := 'erro nao tratado na tela_atenda_emprestimo.pc_valida_inf_cadastrais_web ' ||SQLERRM;
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_valida_inf_cadastrais_web;
  
  PROCEDURE pc_valida_inf_cad_car( pr_nrdconta       IN crapass.nrdconta%type --> Conta
                                  , pr_cdlcremp       IN craplcr.cdlcremp%type --> linha de crédito
                                  , pr_cdcooper       IN crapcop.cdcooper%TYPE --> Cooperativa
                                  , pr_nmdatela       IN VARCHAR2              --> Tela
                                  , pr_cdagenci       IN crapass.cdagenci%TYPE --> Agencia
                                  , pr_nrdcaixa       IN craperr.nrdcaixa%TYPE --> Caixa
                                  , pr_idorigem       IN INTEGER               --> Origem
                                  , pr_cdoperad       IN craplgm.cdoperad%TYPE --> Operador
                                  -- campos padrões OUT 
                                  , pr_des_erro       OUT VARCHAR2              --> Saida OK/NOK
                                  , pr_clob_ret       OUT CLOB                  --> Tabela Extrato da Conta
                                  , pr_cdcritic       OUT PLS_INTEGER           --> Codigo da critica
                                  , pr_dscritic       OUT VARCHAR2              --> Descricao da critica
                                  ) IS
    /* .............................................................................................

    Programa: pc_valida_inf_cad_car (Rotina chamada do progess b1wgen0002.p)
    Sistema : AIMARO
    Autor   : Fernanda Kelli de Oliveira - AMcom Sistemas de Informação  - Projeto 437 - Consignado
    Data    : 12/03/2019                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo : Verificar se os dados de cadastro obrigatórios estão preenchidos no cadastro
               do cooperado para permitir a inclusão da proposta de Empréstimo Consignado 


    Alteracoes: 
    ...............................................................................................*/
    BEGIN
    DECLARE
      /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descrição e código da critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- variaveis de retorno
      vr_tab_dados_crapcri typ_tab_dados_crapcri;
      vr_qtregist          number;

      --Variaveis Arquivo Dados
      vr_dstexto VARCHAR2(32767);
      vr_string  VARCHAR2(32767);
    
      -- variáveis para armazenar as informaçoes em xml
      vr_des_xml        clob;
      vr_texto_completo varchar2(32600);
      vr_index          varchar2(100);
      
      vr_consignado     NUMBER := 0; -- 1 - Consignado 0 - Não Consignado

    BEGIN
      pr_des_erro := 'OK';
      
      --Verificar se é uma linha de crédito do Consignado
      BEGIN
        SELECT 1
          INTO vr_consignado
          FROM cecred.craplcr
         WHERE nvl(tpmodcon,0) > 0 --Tipo da modalidade do consignado  
           AND cdlcremp = pr_cdlcremp;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          vr_consignado := 0;
        WHEN OTHERS THEN
          vr_dscritic := 'Problema na verificacao da linha de credito. Erro: '||sqlerrm;
          raise vr_exc_erro;
      END;
        
      IF vr_consignado = 1 THEN 
       
       --Valida Informações Poposta
       tela_atenda_emprestimo.pc_valida_inf_proposta( pr_cdcooper          => pr_cdcooper
                                                          ,pr_nrdconta          => pr_nrdconta
                                                          ,pr_cdlcremp          => pr_cdlcremp
                                                           --> OUT <--
                                                          ,pr_qtregist          => vr_qtregist
                                                          ,pr_tab_dados_crapcri => vr_tab_dados_crapcri
                                                          ,pr_cdcritic          => vr_cdcritic
                                                          ,pr_dscritic          => vr_dscritic);                                 
       
       IF (nvl(vr_cdcritic,0) <> 0 OR  vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
       END IF; 
        
       --Valida Informações Cadastrais
       tela_atenda_emprestimo.pc_valida_inf_cadastrais( pr_cdcooper          => pr_cdcooper
                                                            ,pr_nrdconta          => pr_nrdconta
                                                             --> OUT <--
                                                            ,pr_qtregist          => vr_qtregist
                                                            ,pr_tab_dados_crapcri => vr_tab_dados_crapcri
                                                            ,pr_cdcritic          => vr_cdcritic
                                                            ,pr_dscritic          => vr_dscritic);                                 
        
       IF (nvl(vr_cdcritic,0) <> 0 OR  vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
       END IF;      
     
     END IF;
     
     --Montar CLOB
      IF vr_tab_dados_crapcri.COUNT > 0 THEN
        
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clob_ret, TRUE); 
        dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);
        
        -- Insere o cabeçalho do XML 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
         
        --Buscar a Primeira Crítica de Validação
        vr_index:= vr_tab_dados_crapcri.FIRST;
        
        --Percorrer todos as Crítica de Validação
        WHILE vr_index IS NOT NULL LOOP
          
          pr_des_erro := 'NOK';
          vr_string:= '<inf>'||
                         '<cdcritic>'|| vr_tab_dados_crapcri(vr_index).cdcritic ||'</cdcritic>'||
                         '<dscritic>'|| vr_tab_dados_crapcri(vr_index).dscritic ||'</dscritic>'||                        
                      '</inf>';

          -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                                 ,pr_texto_completo => vr_dstexto 
                                 ,pr_texto_novo     => vr_string
                                 ,pr_fecha_xml      => FALSE);   
                                                    
          --Próximo Registro
          vr_index:= vr_tab_dados_crapcri.NEXT(vr_index);
          
        END LOOP;  
        
        -- Encerrar a tag raiz 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '</root>' 
                               ,pr_fecha_xml      => TRUE);                               
      END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
           /*  se foi retornado apenas código */
           IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           /* variavel de erro recebe erro ocorrido */
           pr_des_erro := 'NOK';
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        /* montar descriçao de erro nao tratado */
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := 'Erro nao tratado na tela_atenda_emprestimo.pc_valida_inf_cad_car ' ||SQLERRM;
             
    END;
  END pc_valida_inf_cad_car;

END TELA_ATENDA_EMPRESTIMO;
/
