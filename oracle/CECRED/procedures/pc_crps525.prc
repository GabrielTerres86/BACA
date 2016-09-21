CREATE OR REPLACE PROCEDURE CECRED.pc_crps525 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /*........................................................................

    Programa: PC_CRPS525                          (Antigo Fontes/crps525.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Fernando
    Data    : Abril/2009                      Ultima Atualizacao: 23/06/2016
    Dados referente ao programa:

    Frequencia: Diario.

    Objetivo  : Gerar relatorio de limites de desconto de cheques vencidos.

    Alteracoes: 15/01/2013 - Conversão Progress >> Oracle PLSQL (Jean Michel)
    
                23/06/2016 - Correcao para o uso da function fn_busca_dstextab 
                             da TABE0001. (Carlos Rafael Tanholi).
..............................................................................*/

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS525';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      vr_clobxml CLOB; -- Variavel para relatorios e xml
      vr_dtvencdc DATE; -- Data de vencimento
      vr_dsarquiv varchar2(100);
      vr_msgsemin INTEGER := 0;
      -- Guardar registro dstextab
      vr_dstextab craptab.dstextab%TYPE;      
      
      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;


      -- Consulta contas que possuam limites
       CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE) IS

        SELECT
          ass.cdcooper,
          ass.nrdconta,
          lim.nrctrlim,
          lim.dtinivig,
          lim.vllimite,
          lim.qtdiavig
        FROM
          crapass ass,
          craplim lim
        WHERE
          ass.cdcooper = pr_cdcooper  AND
          lim.cdcooper = ass.cdcooper AND
          lim.nrdconta = ass.nrdconta AND
          lim.tpctrlim = 2            AND -- Tipo Contrato Limite
          lim.insitlim = 2                -- Situacao
        ORDER BY
          ass.nrdconta;

      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      --------------------------- SUBROTINAS INTERNAS --------------------------

      -- Subrotina para escrever texto na variável clob do xml
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(vr_clobxml, length(pr_des_dados), pr_des_dados);
      END;

    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
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

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;

      -- Se não encontrar
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

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Inicializar o clob (xml)
      dbms_lob.createtemporary(vr_clobxml, TRUE);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

      -- Inicio do arquivo xml
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');

      -- Buscar configuração na tabela
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'LIMDESCONT'
                                               ,pr_tpregist => 0);

      IF TRIM(vr_dstextab) IS NULL THEN   
        -- Montar mensagem de critica
        vr_dscritic := 'Falta tabela de limite de desconto';
        RAISE vr_exc_saida;
      END IF;

	  -- Consulta todas as contas da cooperativa
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper);

        LOOP
          FETCH cr_crapass
            INTO rw_crapass;

          -- Sai do loop quando chegar ao fim dos registros
          EXIT WHEN cr_crapass%NOTFOUND;

          -- Calcula a data de vencimento
          vr_dtvencdc := rw_crapass.dtinivig + (rw_crapass.qtdiavig * SUBSTR(vr_dstextab, 19, 2));

          -- Verifica data de vencimento
          IF vr_dtvencdc > rw_crapdat.dtmvtoan AND vr_dtvencdc <= rw_crapdat.dtmvtolt THEN

            vr_msgsemin := 1; -- Indica que existem registro p/ o relatório

            -- Escreve arquivo XML com as informações de vencimento
            pc_escreve_xml('<nrdconta id="' || gene0002.fn_mask_conta(rw_crapass.nrdconta) || '">' ||
                             '<nrctrlim>' || TO_CHAR(rw_crapass.nrctrlim,'999G999G000') || '</nrctrlim>' ||
                             '<dtinivig>' || TO_CHAR(rw_crapass.dtinivig,'dd/mm/yyyy') || '</dtinivig>' ||
                             '<dtvencdc>' || TO_CHAR(vr_dtvencdc,'dd/mm/yyyy') || '</dtvencdc>' ||
                             '<vllimite>' || TO_CHAR(rw_crapass.vllimite,'99999G990d00') || '</vllimite>' ||
                             '<qtdiavig>' || gene0002.fn_mask(rw_crapass.qtdiavig,'zzz9') || '</qtdiavig>' ||
                             '<qtrenova>' || TO_CHAR(SUBSTR(vr_dstextab, 19, 2),'9999999') || '</qtrenova>' ||
                           '</nrdconta>');

          END IF;

        END LOOP;

      CLOSE cr_crapass;

      -- Verifica se ralatório contém informações
      IF vr_msgsemin = 0 THEN
        -- Caso não tenha informação, nrconta consta como vazio
        pc_escreve_xml('<nrdconta id=""></nrdconta>');
      END IF;

      -- Fecha tag principal do arquivo xml
      pc_escreve_xml('</raiz>');

      -- Diretorio que sera gerado o arquivo final
      vr_dsarquiv := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => pr_cdcooper, pr_nmsubdir => 'rl') || '/crrl511.lst';

      -- Solicitacao do relatorio
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa
                                  pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                                  pr_dsxml     => vr_clobxml,          --> Arquivo XML de dados
                                  pr_dsxmlnode => '/raiz/nrdconta',    --> Nó do XML para iteração
                                  pr_dsjasper  => 'crrl511.jasper',    --> Arquivo de layout do iReport
                                  pr_dsparams  => '',                  --> Array de parametros diversos
                                  pr_dsarqsaid => vr_dsarquiv,         --> Path/Nome do arquivo PDF gerado
                                  pr_flg_gerar => 'N',                 --> Gerar o arquivo na hora*
                                  pr_qtcoluna  => 132,                 --> Qtd colunas do relatório (80,132,234)
                                  pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)*
                                  pr_nmformul  => '80col',             --> Nome do formulário para impressão
                                  pr_nrcopias  => 1,                   --> Qtd de cópias
                                  pr_des_erro  => vr_dscritic);        --> Saída com erro

      -- Verifica se ocorreu uma critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Libera a memoria alocada p/ variave clob
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);

      -- Processo OK, chama a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
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

      WHEN vr_exc_saida THEN
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
    END;

  END pc_crps525;
/
