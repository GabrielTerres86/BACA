CREATE OR REPLACE PROCEDURE CECRED.pc_crps591(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                             ,pr_flgresta IN PLS_INTEGER             --> Flag 0/1 para utilizar restart na chamada
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                             ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* ............................................................................

       Programa: pc_crps591    (Fontes/crps591.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Vitor
       Data    : Marco/2011                         Ultima atualizacao: 31/03/2015

       Dados referentes ao programa:

       Frequencia: Mensal (Batch).
       Objetivo  : Atende a solicitacao 4. Ordem 40.
                   Resumo Mensal Procapcred.

       Alteracoes: 24/10/2012 - Reformulado relatorio 592 (Tiago)

                   30/08/2013 - Conversão Progress >> Oracle PLSQL (Edison-AMcom)

                   22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                                ser acionada em caso de saída para continuação da cadeia,
                                e não em caso de problemas na execução (Marcos-Supero)
                                
                   31/03/2015 - Projeto de separação contábeis de PF e PJ.
                                (Andre Santos - SUPERO)
    ............................................................................ */
    DECLARE
      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrtelura
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.dsdircop
              ,cop.nrdocnpj
              ,cop.cdufdcop
              ,cop.nmextcop
              ,cop.nrcpftit
              ,cop.nrtelvoz
              ,cop.nrcpfctr
              ,cop.nmctrcop
              ,cop.dsendcop
              ,cop.nrendcop
              ,cop.dscomple
              ,cop.nmbairro
              ,cop.nrcepend
              ,cop.nmcidade
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      -- registro da coopertiva
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Código do programa
      vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS591';

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_exc_fimprg    EXCEPTION;
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(4000);

      -- Variáveis de trabalho
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;

      -- Variável de Controle de XML
      vr_des_xml      CLOB;
      vr_path_arquivo VARCHAR2(1000);

      -- definindo a tabela temporária de lançamentos de cotas
      vr_tab_craplct           PCAP0001.typ_tab_craplct;
      vr_typ_tab_ativos        PCAP0001.typ_tab_ativos;
      vr_typ_tab_desb_nsacado  PCAP0001.typ_tab_desb_nsacado;
      vr_typ_tab_capsac        PCAP0001.typ_tab_capsac;
      vr_typ_tab_integralizado PCAP0001.typ_tab_integralizado;

      -- demais variáveis
      vr_ind					VARCHAR2(100);
      vr_inpessoa     PLS_INTEGER;
      vr_qtprocap     NUMBER;
      vr_totinteg     NUMBER;
      vr_vlativos     NUMBER;
      vr_totativo     NUMBER;
      vr_vldbnsac     NUMBER;
      vr_todbnsac     NUMBER;
      vr_vlcapsac     NUMBER;
      vr_tocapsac     NUMBER;
      vr_vltotint     NUMBER;
      vr_toqtdpro     NUMBER;
      vr_vlslproc     NUMBER;
      vr_vlprosac     NUMBER;
      -- Variavel totalizadora por tipo de pessoa
      vr_vltotfis     NUMBER;
      vr_vlslpfis     NUMBER;
      vr_vltotjur     NUMBER;
      vr_vlslpjur     NUMBER;
      vr_toqtdjur     NUMBER;
      vr_vlprosac_fis NUMBER;
      vr_toqtdpro_fis NUMBER;
      vr_vlprosac_jur NUMBER;
      vr_toqtdpro_jur NUMBER;
      

	    --Procedure que escreve linha no arquivo CLOB
	    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS591'
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic:= 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
	    -- Verificação do calendário
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                ,pr_flgbatch => 1
                                ,pr_infimsol => pr_infimsol
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_cdcritic => vr_cdcritic);

      --Se retornou critica aborta programa
      IF vr_cdcritic <> 0 THEN
        --Descricao do erro recebe mensagam da critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --Envio do log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -------------------------------------------
      -- Iniciando a geração do XML
      -------------------------------------------
      pc_escreve_xml('<?xml version="1.0" encoding="WINDOWS-1252"?><crrl592><tipos>');
      ------------------------------------------
      -- Ativos - Inicio
      ------------------------------------------
      pc_escreve_xml('<tipo dstipo="ATIVOS"><ativos>');

      -- Busca informações das cotas de capital ativas
      PCAP0001.pc_busca_procap_ativos( pr_cdcooper => pr_cdcooper
                                      ,pr_totativo => vr_totativo
                                      ,pr_vlativos => vr_vlativos
                                      ,pr_tab_craplct => vr_tab_craplct
                                      ,pr_typ_tab_ativos => vr_typ_tab_ativos
                                      ,pr_dscritic =>  vr_dscritic);

      -- Se ocorrer algum erro aborta a geração
      IF vr_dscritic IS NOT NULL THEN
        --Envio do log de erro
        RAISE vr_exc_saida;
      END IF;

      -- se possuir informações gera registro no xml
      IF vr_tab_craplct.count > 0 THEN

        -- Posiciona no primeiro registro da tabela
        vr_ind := vr_tab_craplct.FIRST;
        LOOP
          -- Sair quando a chave atual for null (chegou no final)
          EXIT WHEN vr_ind IS NULL;
          -- Gera o registro no xml
          pc_escreve_xml('<ativo id="'||vr_tab_craplct(vr_ind).nrchave||'">'||
                            '<cdagenci>'||vr_tab_craplct(vr_ind).cdagenci||'</cdagenci>'||
                            '<nrdconta>'||rtrim(ltrim(gene0002.fn_mask_conta(vr_tab_craplct(vr_ind).nrdconta)))||'</nrdconta>'||
                            '<dspessoa>'||TRIM(vr_tab_craplct(vr_ind).dspessoa)||'</dspessoa>'||
                            '<nmprimtl>'||vr_tab_craplct(vr_ind).nmprimtl||'</nmprimtl>'||
                            '<dtmvtolt>'||to_char(vr_tab_craplct(vr_ind).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                            '<vllanmto>'||to_char(vr_tab_craplct(vr_ind).vllanmto, 'fm99999G999G990D00')||'</vllanmto>'||
														'<totativo>'||nvl(vr_totativo,0)||'</totativo>'||
                       			'<vlativos>'||to_char(vr_vlativos,'fm99999G999G990D00')||'</vlativos>'||
 														'<qtatvfis>'||nvl(vr_typ_tab_ativos(1).totativo,0)||'</qtatvfis>'||
                            '<vlatvfis>'||to_char(nvl(vr_typ_tab_ativos(1).vlativos,0),'fm99999G999G990D00')||'</vlatvfis>'||
                            '<qtatvjur>'||nvl(vr_typ_tab_ativos(2).totativo,0)||'</qtatvjur>'||
                            '<vlatvjur>'||to_char(nvl(vr_typ_tab_ativos(2).vlativos,0),'fm99999G999G990D00')||'</vlatvjur>'||                             
                          '</ativo>');
          -- Buscar o próximo registro da tabela
          vr_ind := vr_tab_craplct.next(vr_ind);
        END LOOP;

      ELSE
        -- Gera o registro no xml
        pc_escreve_xml('<ativo id="">'||
                          '<cdagenci></cdagenci>'||
                          '<nrdconta></nrdconta>'||
                          '<nmprimtl></nmprimtl>'||
                          '<dspessoa></dspessoa>'||
                          '<dtmvtolt></dtmvtolt>'||
                          '<vllanmto></vllanmto>'||
                          '<totativo>0</totativo>'||
                          '<vlativos>0,00</vlativos>'||
                          '<qtatvfis>0</qtatvfis>'||
                          '<vlatvfis>0,00</vlatvfis>'||
                          '<qtatvjur>0</qtatvjur>'||
                          '<vlatvjur>0,00</vlatvjur>'|| 
                        '</ativo>');
      END IF;
      -- finalizando a chave do tipo ativos
      pc_escreve_xml('</ativos></tipo>');
      ------------------------------------------
      -- Ativos - Fim
      ------------------------------------------

      ------------------------------------------
      -- Desbloqueados e Não sacados - Inicio
      ------------------------------------------
      pc_escreve_xml('<tipo dstipo="DESBLOQUEADOS_NAO_SACADOS"><desbloqueados>');

      -- Busca informações das cotas de capital desbloqueadas e não sacadas
      PCAP0001.pc_busca_procap_desbl_naosac(pr_cdcooper => pr_cdcooper
                                      ,pr_todbnsac => vr_todbnsac
                                      ,pr_vldbnsac => vr_vldbnsac
                                      ,pr_tab_craplct => vr_tab_craplct
                                      ,pr_typ_tab_desb_nsacado => vr_typ_tab_desb_nsacado
                                      ,pr_dscritic =>  vr_dscritic);

      -- Se ocorrer algum erro aborta a geração
      IF vr_dscritic IS NOT NULL THEN
        --Envio do log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Se retornar regoisros, gera as informações
      IF vr_tab_craplct.count > 0 THEN
        -- Posiciona no primeiro registro da tabela
        vr_ind := vr_tab_craplct.FIRST;
        LOOP
          -- Sair quando a chave atual for null (chegou no final)
          EXIT WHEN vr_ind IS NULL;
          -- Gerando o registro
          pc_escreve_xml('<desbloqueado id="'||vr_tab_craplct(vr_ind).nrchave||'">'||
                            '<cdagenci>'||vr_tab_craplct(vr_ind).cdagenci||'</cdagenci>'||
                            '<nrdconta>'||ltrim(rtrim(gene0002.fn_mask_conta(vr_tab_craplct(vr_ind).nrdconta)))||'</nrdconta>'||
                            '<nmprimtl>'||vr_tab_craplct(vr_ind).nmprimtl||'</nmprimtl>'||
                            '<dspessoa>'||TRIM(vr_tab_craplct(vr_ind).dspessoa)||'</dspessoa>'||
                            '<dtmvtolt>'||to_char(vr_tab_craplct(vr_ind).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                            '<vllanmto>'||to_char(vr_tab_craplct(vr_ind).vllanmto, 'fm99999G999G990D00')||'</vllanmto>'||
                            '<dtlibera>'||to_char(vr_tab_craplct(vr_ind).dtlibera,'dd/mm/yyyy')||'</dtlibera>'||
                            '<todbnsac>'||vr_todbnsac||'</todbnsac>'||
                            '<vldbnsac>'||to_char(vr_vldbnsac,'fm99999G999G990D00')||'</vldbnsac>'||
                            '<qtnscfis>'||nvl(vr_typ_tab_desb_nsacado(1).todbnsac,0)||'</qtnscfis>'||
                            '<vlnscfis>'||to_char(nvl(vr_typ_tab_desb_nsacado(1).vldbnsac,0),'fm99999G999G990D00')||'</vlnscfis>'||
                            '<qtnscjur>'||nvl(vr_typ_tab_desb_nsacado(2).todbnsac,0)||'</qtnscjur>'||
                            '<vlnscjur>'||to_char(nvl(vr_typ_tab_desb_nsacado(2).vldbnsac,0),'fm99999G999G990D00')||'</vlnscjur>'||
                          '</desbloqueado>');
          -- Buscar o próximo registro da tabela
          vr_ind := vr_tab_craplct.next(vr_ind);
        END LOOP;
      ELSE
        -- Gerando o registro em branco
        pc_escreve_xml('<desbloqueado id="">'||
                          '<cdagenci></cdagenci>'||
                          '<nrdconta></nrdconta>'||
                          '<nmprimtl></nmprimtl>'||
                          '<dspessoa></dspessoa>'||
                          '<dtmvtolt></dtmvtolt>'||
                          '<vllanmto></vllanmto>'||
                          '<dtlibera></dtlibera>'||
                          '<todbnsac>0</todbnsac>'||
                          '<vldbnsac>0,00</vldbnsac>'||
                          '<qtnscfis>0</qtnscfis>'||
                          '<vlnscfis>0,00</vlnscfis>'||
                          '<qtnscjur>0</qtnscjur>'||
                          '<vlnscjur>0,00</vlnscjur>'||
                        '</desbloqueado>'
                        );

      END IF;
      ------------------------------------------
      -- Desbloqueados e Não sacados - Fim
      ------------------------------------------
      pc_escreve_xml('</desbloqueados></tipo>');

      ------------------------------------------
      -- Capital Sacado - Inicio
      ------------------------------------------
      pc_escreve_xml('<tipo dstipo="CAPITAL_SACADO">');
      pc_escreve_xml('<capitais>');

      -- carregando as informações na tabela auxiliar
      PCAP0001.pc_busca_procap_capital_sacado(pr_cdcooper => pr_cdcooper
                                      ,pr_tocapsac => vr_tocapsac
                                      ,pr_vlcapsac => vr_vlcapsac
                                      ,pr_tab_craplct => vr_tab_craplct
                                      ,pr_typ_tab_capsac => vr_typ_tab_capsac
                                      ,pr_dscritic =>  vr_dscritic);

      -- Se ocorrer algum erro, aborta a operação
      IF vr_dscritic IS NOT NULL THEN
        --Envio do log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Se a tabela possuir registros, gera o relatório
      IF vr_tab_craplct.count > 0 THEN

        -- Posiciona no primeiro registro da tabela
        vr_ind   := vr_tab_craplct.FIRST;
        LOOP
          -- Sair quando a chave atual for null (chegou no final)
          EXIT WHEN vr_ind IS NULL;

          -- Sempre que quebrar a agência/conta (FIRST-OF), busca o total integralizado para a conta
          IF vr_tab_craplct(vr_ind).nrseqreg = 1 THEN
            -- Recuperando o valor total integralizado
            PCAP0001.pc_total_integralizado(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => vr_tab_craplct(vr_ind).nrdconta
                                           ,pr_inpessoa => vr_inpessoa
                                           ,pr_qtprocap => vr_qtprocap
                                           ,pr_totinteg => vr_totinteg
                                           ,pr_typ_tab_integralizado => vr_typ_tab_integralizado
                                           ,pr_dscritic => vr_dscritic);

            -- Se ocorrer algum erro, aborta a operação
            IF vr_dscritic IS NOT NULL THEN
              --Envio do log de erro
              RAISE vr_exc_saida;
            END IF;

            -- Acumulando o total integralizado
            vr_vlprosac := nvl(vr_vlprosac,0) + nvl(vr_totinteg,0);
            vr_toqtdpro := nvl(vr_toqtdpro,0) + nvl(vr_qtprocap,0);
            
            IF vr_inpessoa = 1 THEN
               vr_vlprosac_fis := nvl(vr_vlprosac_fis,0) + nvl(vr_typ_tab_integralizado(1).totinteg,0);
               vr_toqtdpro_fis := nvl(vr_toqtdpro_fis,0) + nvl(vr_typ_tab_integralizado(1).qtprocap,0);
            ELSE      
               vr_vlprosac_jur := nvl(vr_vlprosac_jur,0) + nvl(vr_typ_tab_integralizado(2).totinteg,0);
               vr_toqtdpro_jur := nvl(vr_toqtdpro_jur,0) + nvl(vr_typ_tab_integralizado(2).qtprocap,0);
            END IF;

          END IF;
          -- Gera o agrupamento do associado
          pc_escreve_xml('<capital id="'||vr_tab_craplct(vr_ind).nrchave||'">'||
                           '<cdagenci>'||vr_tab_craplct(vr_ind).cdagenci||'</cdagenci>'||
                           '<nrdconta>'||rtrim(ltrim(gene0002.fn_mask_conta(vr_tab_craplct(vr_ind).nrdconta)))||'</nrdconta>'||
                           '<nmprimtl>'||vr_tab_craplct(vr_ind).nmprimtl||'</nmprimtl>'||
                           '<dspessoa>'||TRIM(vr_tab_craplct(vr_ind).dspessoa)||'</dspessoa>'||
                           '<totinteg>'||to_char(vr_totinteg, 'fm99999G999G990D00')||'</totinteg>'||
                           '<vllanmto>'||to_char(vr_tab_craplct(vr_ind).vllanmto, 'fm99999G999G990D00')||'</vllanmto>'||
                           '<dtmvtolt>'||to_char(vr_tab_craplct(vr_ind).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                           '<tocapsac>'||vr_tocapsac||'</tocapsac>'||
                           '<vlcapsac>'||to_char(vr_vlcapsac,'fm99999G999G990D00')||'</vlcapsac>'||
                           '<vlprosac>'||to_char(vr_vlprosac,'fm99999G999G990D00')||'</vlprosac>'||
                           '<qtpscfis>'||nvl(vr_typ_tab_capsac(1).tocapsac,0)||'</qtpscfis>'||
                           '<vlpscfis>'||to_char(nvl(vr_typ_tab_capsac(1).vlcapsac,0),'fm99999G999G990D00')||'</vlpscfis>'||
                           '<vlprofis>'||to_char(nvl(vr_vlprosac_fis,0),'fm99999G999G990D00')||'</vlprofis>'||
                           '<qtpscjur>'||nvl(vr_typ_tab_capsac(2).tocapsac,0)||'</qtpscjur>'||
                           '<vlpscjur>'||to_char(nvl(vr_typ_tab_capsac(2).vlcapsac,0),'fm99999G999G990D00')||'</vlpscjur>'||
                           '<vlprojur>'||to_char(nvl(vr_vlprosac_jur,0),'fm99999G999G990D00')||'</vlprojur>'||
                         '</capital>');

          -- Buscar o próximo registro da tabela
          vr_ind := vr_tab_craplct.next(vr_ind);
        END LOOP;

      ELSE
        -- gerando um registro em branco
        pc_escreve_xml('<capital id="">'||
                         '<cdagenci></cdagenci>'||
                         '<nrdconta></nrdconta>'||
                         '<nmprimtl></nmprimtl>'||
                         '<dspessoa></dspessoa>'||
                         '<totinteg></totinteg>'||
                         '<vllanmto></vllanmto>'||
                         '<dtmvtolt></dtmvtolt>'||
                         '<tocapsac>0</tocapsac>'||
                         '<vlcapsac>0,00</vlcapsac>'||
                         '<vlprosac>0,00</vlprosac>'||
                         '<qtpscfis>0</qtpscfis>'||
                         '<vlpscfis>0,00</vlpscfis>'||
                         '<qtpscjur>0</qtpscjur>'||
                         '<vlpscjur>0,00</vlpscjur>'||
                         '<vlprofis>0,00</vlprofis>'||
                         '<vlprojur>0,00</vlprojur>'||
                       '</capital>');
      END IF;
      ------------------------------------------
      -- Capital Sacado - Fim
      ------------------------------------------
      pc_escreve_xml('</capitais></tipo>');

      -- Totalizando os resumos
			vr_vltotint := nvl(vr_vlativos,0) + nvl(vr_vldbnsac,0) + nvl(vr_vlprosac,0);
      vr_vlslproc := nvl(vr_vltotint,0) - nvl(vr_vlcapsac,0);
      vr_toqtdpro := nvl(vr_toqtdpro,0) + nvl(vr_todbnsac,0) + nvl(vr_totativo,0);
      
      /* Totalizando os resumos por pessoa fisica */
      
      -- Valor Total de Ativos + Valor Total Nao Sacado + Valor Total Procap Capital Sacado
      vr_vltotfis := nvl(vr_typ_tab_ativos(1).vlativos,0) + nvl(vr_typ_tab_desb_nsacado(1).vldbnsac,0) + nvl(vr_vlprosac_fis,0);
      -- Subtrai Valor Total Procap Capital Sacado da variavel VR_VLTOTFIS
      vr_vlslpfis := nvl(vr_vltotfis,0) - nvl(vr_typ_tab_capsac(1).vlcapsac,0);
      -- Quantidade Total Integralizado + Quantidade Nao Sacado + Quantidade de Ativos
      vr_toqtdpro_fis := nvl(vr_toqtdpro_fis,0) + nvl(vr_typ_tab_desb_nsacado(1).todbnsac,0) + nvl(vr_typ_tab_ativos(1).totativo,0);
      
      /* Totalizando os resumos por pessoa juridica */
      
      -- Valor Total de Ativos + Valor Total Nao Sacado + Valor Total Procap Capital Sacado
      vr_vltotjur := nvl(vr_typ_tab_ativos(2).vlativos,0) + nvl(vr_typ_tab_desb_nsacado(2).vldbnsac,0) + nvl(vr_vlprosac_jur,0);
      -- Subtrai Valor Total Procap Capital Sacado da variavel VR_VLTOTFIS
      vr_vlslpjur := nvl(vr_vltotjur,0) - nvl(vr_typ_tab_capsac(2).vlcapsac,0);
      -- Quantidade Total Integralizado + Quantidade Nao Sacado + Quantidade de Ativos
      vr_toqtdpro_jur := nvl(vr_toqtdpro_jur,0) + nvl(vr_typ_tab_desb_nsacado(2).todbnsac,0) + nvl(vr_typ_tab_ativos(2).totativo,0);

      ------------------------------------------
      -- Resumo - Inicio
      ------------------------------------------
      pc_escreve_xml('<tipo dstipo="RESUMO"><resumos>');
      pc_escreve_xml('<resumo id="01">'||-- Ativos
                       '<dsresumo>Ativos</dsresumo>'||
                       '<vlrfis>'||to_char(nvl(vr_typ_tab_ativos(1).vlativos,0),'fm99999G999G990D00')||'</vlrfis>'||
                       '<vlrjur>'||to_char(nvl(vr_typ_tab_ativos(2).vlativos,0),'fm99999G999G990D00')||'</vlrjur>'||
                       '<valor>'||to_char(vr_vlativos, 'fm99999G999G990D00')||'</valor>'||
                       '<qtdefis>'||nvl(vr_typ_tab_ativos(1).totativo,0)||'</qtdefis>'||
                       '<qtdejur>'||nvl(vr_typ_tab_ativos(2).totativo,0)||'</qtdejur>'||                       
                       '<qtde>'||vr_totativo||'</qtde>'||
                     '</resumo>'||

                     '<resumo id="02">'||
                       '<dsresumo>Desbloqueados e nao sacados</dsresumo>'||
                       '<vlrfis>'||to_char(nvl(vr_typ_tab_desb_nsacado(1).vldbnsac,0), 'fm99999G999G990D00')||'</vlrfis>'||
                       '<vlrjur>'||to_char(nvl(vr_typ_tab_desb_nsacado(2).vldbnsac,0), 'fm99999G999G990D00')||'</vlrjur>'||
                       '<valor>'||to_char(vr_vldbnsac, 'fm99999G999G990D00')||'</valor>'||
                       '<qtdefis>'||nvl(vr_typ_tab_desb_nsacado(1).todbnsac,0)||'</qtdefis>'||                       
                       '<qtdejur>'||nvl(vr_typ_tab_desb_nsacado(2).todbnsac,0)||'</qtdejur>'||
                       '<qtde>'||vr_todbnsac||'</qtde>'||
                     '</resumo>'||

                     '<resumo id="03">'||
                       '<dsresumo>Capital sacado</dsresumo>'||
                       '<vlrfis>'||to_char(nvl(vr_typ_tab_capsac(1).vlcapsac,0), 'fm99999G999G990D00')||'</vlrfis>'||
                       '<vlrjur>'||to_char(nvl(vr_typ_tab_capsac(2).vlcapsac,0), 'fm99999G999G990D00')||'</vlrjur>'||
                       '<valor>'||to_char(vr_vlcapsac, 'fm99999G999G990D00')||'</valor>'||
                       '<qtdefis>'||nvl(vr_typ_tab_capsac(1).tocapsac,0)||'</qtdefis>'||                       
                       '<qtdejur>'||nvl(vr_typ_tab_capsac(2).tocapsac,0)||'</qtdejur>'||
                       '<qtde>'||vr_tocapsac||'</qtde>'||                       
                     '</resumo>'||

                     '<resumo id="04">'||
                       '<dsresumo>Total integralizado</dsresumo>'||
                       '<vlrfis>'||to_char(vr_vltotfis, 'fm99999G999G990D00')||'</vlrfis>'||
                       '<vlrjur>'||to_char(vr_vltotjur, 'fm99999G999G990D00')||'</vlrjur>'||
                       '<valor>'||to_char(vr_vltotint, 'fm99999G999G990D00')||'</valor>'|| 
                       '<qtdefis>'||vr_toqtdpro_fis||'</qtdefis>'||
                       '<qtdejur>'||vr_toqtdpro_jur||'</qtdejur>'||
                       '<qtde>'||vr_toqtdpro||'</qtde>'||
                     '</resumo>'||

                     '<resumo id="05">'||
                       '<dsresumo>Saldo Procap</dsresumo>'||
                       '<vlrfis>'||to_char(vr_vlslpfis, 'fm99999G999G990D00')||'</vlrfis>'||
                       '<vlrjur>'||to_char(vr_vlslpjur, 'fm99999G999G990D00')||'</vlrjur>'||
                       '<valor>'||to_char(vr_vlslproc, 'fm99999G999G990D00')||'</valor>'||
                       '<qtdefis></qtdefis>'||
                       '<qtdejur></qtdejur>'||
                       '<qtde></qtde>'||
                     '</resumo></resumos></tipo>');
      ------------------------------------------
      -- Resumo - Fim
      ------------------------------------------

      ------------------------------------------
      -- Finalizando as tags do arquivo XML
      ------------------------------------------
      pc_escreve_xml('</tipos></crrl592>');

      -- Busca do diretório base da cooperativa e a subpasta de relatórios
      vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/rl'); --> Gerado no diretorio /rl
                                             
      -- Gerando o relatório
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_des_xml
                                 ,pr_dsxmlnode => '/crrl592'
                                 ,pr_dsjasper  => 'crrl592.jasper'
                                 ,pr_dsparams  => ''
                                 ,pr_dsarqsaid => vr_path_arquivo || '/crrl592.lst'
                                 ,pr_flg_gerar => 'S'
                                 ,pr_qtcoluna  => 132
                                 ,pr_sqcabrel  => 1
                                 ,pr_cdrelato  => NULL
                                 ,pr_flg_impri => 'S'
                                 ,pr_nmformul  => '132col'
                                 ,pr_nrcopias  => 1
                                 ,pr_dspathcop => NULL
                                 ,pr_dsmailcop => NULL
                                 ,pr_dsassmail => NULL
                                 ,pr_dscormail => NULL
                                 ,pr_des_erro  => vr_dscritic);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Comitando
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
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps591;
/

