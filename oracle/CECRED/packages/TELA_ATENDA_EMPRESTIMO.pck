CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_EMPRESTIMO IS

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

    Alteracoes: PJ298.3 Simulação do Pós, foi incluido a variável vr_qtdmes
                08/08/2019 - Giba (Supero)
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
      vr_qtdmes   number(2);
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
          --PJ298_5
          vr_qtdmes := vr_qtddias / 30;
          vr_dtcarenc := TO_DATE(pr_dtcarenc, 'DD/MM/RRRR');
          vr_dtcarenc := ADD_MONTHS(TO_DATE(vr_dtcarenc,'DD/MM/RRRR'),vr_qtdmes);
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

END TELA_ATENDA_EMPRESTIMO;
/
