CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS315 (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                       ,pr_flgresta  IN PLS_INTEGER           --> Flag 0/1 para utilizar restart na chamada
                                       ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                       ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada AS
BEGIN
/* ............................................................................

   Programa: PC_CRPS315 (AntigoFontes/crps315.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior.
   Data    : Julho/2001                         Ultima atualizacao: 23/03/2016

   Dados referentes ao programa:

   Frequencia : Diario.
   Objetivo   : Atende a solicitacao 002.
                Listar as contas que tiveram abertura de conta corrente ou
                recadastramento no dia.
                Emite relatorio 267.

   Alteracaoes: 20/02/2002 - Incluir novo relatorio por PAC q sera impresso
                             na IMPREL. (Ze Eduardo).

                08/04/2002 - Fazer relatorios em paginas separadas para as
                             pessoas juridicas (Junior).

                22/05/2002 - Mostrar o operador da transacao no relatorio
                             (Junior).

                18/06/2002 - Corrigir a alteracao acima (Edson).

                23/07/2002 - Pular linha entre as contas (Deborah).

                05/08/2003 - So ira mandar para o relatorio os associados que
                             nao estiverem como revisao cadastral. (Julio)

                28/02/2005 - Tratar o termo ADMISSAO DE SOCIO (Edson).

                04/10/2005 - Inclusao contas que tiveram impresso TERMO CI
                             (Mirtes)

                05/10/2005 - Impressao contas que tiverem impresso TERMO CI
                             independente de recadastramento(Mirtes)

                14/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                28/06/2006 - Inclusao "SFN"(Mirtes)

                17/10/2006 - Inclusao do PAC do Operador nos relatorios (Elton)

                26/10/2006 - Ajustar leitura do crapneg para ser mais perfor-
                             matica (Edson).

                21/02/2007 - Listar contas que tiverem impressao Termo BANCOOB
                             (Diego).

                30/04/2008 - Incluida na rotina de verificacao de documentos
                             para arquivar a "Impressao do Contrato Poupanca
                             Programada (Gabriel).

                18/05/2009 - Mostrar relatorios crrl272_* na intranet
                             (Fernando).

                22/05/2009 - Alteracao CDOPERAD (Kbase).

                11/11/2009 - Ajuste para o novo Termo de Adesao - retirar o
                             antigo Termo CI e Termo BANCCOB (Fernando).

                27/04/2010 - Desconsisderar a tabela temporaria das poupancas
                             (Gabriel).

                15/07/2010 - Implementacao de listagem de contas que fizeram
                             impressao de carta na tela MANCCF (GATI - Eder)

                02/08/2010 - Implementacoes na Listagem de contas que efetuaram
                             impressao de cartas - Emissao Cartas de CCF:
                             * Exibicao do Nome e PAC do Operador que efetuou
                               a impressao de cartas (cdopeimp);
                             * Separacao por Tipo de Pessoa.
                           - Alteracao da listagem "Abertura/Recadastramento
                             de Conta Corrente" para imprimir por Tipo de
                             Pessoa
                           - Exclusao do nome e PAC do operador da listagem
                             de Emissao de Cartas CCF - mantido apenas dados
                             do operador que efetuou impressao
                           - Nao apresentar totais quando estiverem com valor 0

                10/08/2012 - Inclusão do campo nrdocmto - Numero cheque para o
                             relatorio 267 Emissao Cartas de CCF. (Lucas R.)

                26/08/2013 - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)

                26/07/2014 - Retirado "NOT LIKE" do IF ((rw_crapalt.tpaltera = 1
                             AND vr_dsaltera_lob (not) like '%REVISAO CADASTRAL%')
                             (Daniele).

                05/12/2014 - Ajustado a variavel vr_des_chave_ag (agencia)
                             para 3 digitos pois os relatorios 272 de agencias
                             com 3 digitos (Ex: Agencia 194) eram gerados juntos
                             com outros PA's. SD - 222067.
                             (Andre Santos - SUPERO)

                23/12/2015 - Removido do relatório contas com REVISAO CADASTRAL
                             conforme solicitado na melhoria 114. SD 372880 (Kelvin)

                03/03/2016 - Removido todas as informacoes que eram obtidas atraves
                             da busca do controle dos saldos negativos e devolucoes 
                             de cheques. As alteracoes cadastrais foram restringidas
                             apenas a abertura da conta, com isso o cursor foi alterado
                             para ler a crapass. A Emissao Cartas de CCF nao foi alterada.
                             (Douglas - Chamado 411494)
                             
                23/03/2016 - Ajuste para buscar o nome do operador que fez a abertura da
                             conta (Douglas - Ajuste Chamado 411494)
............................................................................. */
  declare
    -- Codigo do programa
    vr_cdprogra crapprg.cdprogra%TYPE;
    -- Tratamento de erros
    vr_exc_saida exception;
    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%rowtype;

    /* Cursor generico de calendario */
    rw_crapdat btch0001.cr_crapdat%rowtype;

    /* Leitura das contas que fizeram impressao de cartas */
    CURSOR cr_crapneg2 (pr_cdcooper IN crapneg.cdcooper%TYPE,
                        pr_dtmvtolt IN crapneg.dtiniest%TYPE ) IS
      SELECT  nrdconta
             ,nrdocmto
             ,cdoperad
             ,cdopeimp
             ,Count(1) OVER (PARTITION BY crapneg.cdcooper,crapneg.nrdconta) qtdreg
             ,Row_Number() OVER (PARTITION BY crapneg.cdcooper,crapneg.nrdconta
                                   ORDER BY crapneg.nrdconta) nrseqreg
        FROM crapneg
       WHERE crapneg.cdcooper = pr_cdcooper AND
             crapneg.dtimpreg = pr_dtmvtolt;

    -- Buscar associados
    CURSOR cr_crapass (pr_cdcooper in crapass.cdcooper%type,
                       pr_nrdconta in crapass.nrdconta%type) is
      SELECT nmprimtl,
             cdagenci,
             nrdconta,
             inpessoa
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;

    rw_crapass cr_crapass%rowtype;

    -- Buscar associados Abertura de Conta
    CURSOR cr_crapass_abertura (pr_cdcooper in crapass.cdcooper%type,
                                pr_dtmvtolt in crapass.dtmvtolt%type) is
      SELECT ass.nmprimtl,
             ass.cdagenci,
             ass.nrdconta,
             ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.dtmvtolt = pr_dtmvtolt;

    -- Buscar controle dos saldos negativos e devolucoes de cheques.
    CURSOR cr_crapneg (pr_cdcooper IN crapneg.cdcooper%TYPE,
                       pr_nrdconta IN crapneg.nrdconta%TYPE,
                       pr_dtmvtolt IN crapneg.dtiniest%TYPE ) IS
      SELECT neg.cdoperad
        FROM crapneg neg
       WHERE neg.cdcooper = pr_cdcooper 
         AND neg.nrdconta = pr_nrdconta
         AND neg.dtiniest = pr_dtmvtolt 
         AND neg.nrseqdig = 1;
    rw_crapneg cr_crapneg%ROWTYPE;
         
    -- Buscar Cadastro de poupanca programada.
    CURSOR cr_craprpp (pr_cdcooper in craprpp.cdcooper%type,
                       pr_dtmvtolt IN craprpp.dtimpcrt%TYPE) is
      SELECT 1
        FROM craprpp
       WHERE craprpp.cdcooper = pr_cdcooper   AND
             craprpp.dtimpcrt = pr_dtmvtolt;

    -- Buscar operadores
    CURSOR cr_crapope (pr_cdcooper in crapope.cdcooper%type,
                       pr_cdoperad in crapope.cdoperad%type) is
      SELECT nmoperad,
             cdagenci
        FROM crapope
       WHERE crapope.cdcooper = pr_cdcooper
         AND crapope.cdoperad = pr_cdoperad;
    rw_crapope cr_crapope%rowtype;

    --Type para armazenar as informacoes dos associados que efetuaram alteracao no cadastro
    type typ_reg_cratass is record ( cdagenci     crapass.cdagenci%type,
                                     nrdconta     crapass.nrdconta%type,
                                     nmprimtl     crapass.nmprimtl%type,
                                     inpessoa     number(1),
                                     cdoperad     crapope.cdoperad%type,
                                     nmoperad     crapope.nmoperad%type,
                                     agoperad     crapope.cdagenci%type);

    type typ_tab_reg_cratass is table of typ_reg_cratass
                           index by varchar2(24); --id(1) + Ag(5) + Cta(8)

    --Type para armazenar as informacoes dos associados que efetuaram emissao de cartas
    type typ_reg_cratneg is record ( cdagenci     crapass.cdagenci%type,
                                     nrdconta     crapass.nrdconta%type,
                                     nmprimtl     crapass.nmprimtl%type,
                                     inpessoa     number(1),
                                     cdoperad     crapope.cdoperad%type,
                                     nmoperad     crapope.nmoperad%type,
                                     agoperad     crapope.cdagenci%type,
                                     nmopeimp     crapope.nmoperad%type,
                                     agopeimp     crapope.cdagenci%type,
                                     nrdocmto     crapneg.nrdocmto%type);

    type typ_tab_reg_cratneg is table of typ_reg_cratneg
                           index by varchar2(24); --id(1) +Ag(5) + Cta(8) + nrdoc(10)

    type typ_reg_rel   is record ( vr_tab_cratass typ_tab_reg_cratass,
                                   vr_tab_cratneg typ_tab_reg_cratneg);

    type typ_tab_reg_rel is table of typ_reg_rel
                           index by varchar2(5); --Ag(5)
    vr_tab_rel typ_tab_reg_rel;

    -- Type para armazenar informacoes de todas as filiais para montar um arquivo geral
    type typ_reg_rel_tot is record (idtprel      varchar2(1),
                                    inpessoa     number(1),
                                    dsc_xml     clob);

    type typ_tab_rel_tot is table of typ_reg_rel_tot
                           index by varchar2(10); --Id tipo(1)+ Cta(8)
    vr_tab_rel_tot typ_tab_rel_tot;

    -- Variavel para chaveamento (hash) da tabela de aplicacões
    vr_des_chave     varchar2(24);
    vr_des_chave_ag  varchar2(3);
    vr_des_chave_tot varchar2(10);

    -- variavel para validacao dos historicos de alteracao, devido a restricao do oracle no campo long
    vr_dsaltera_lob clob;

    -- Variavel para armazenar as informacos em XML
    vr_des_xml_tmp   clob;
    vr_des_xml       clob;

    -- Variavel utilizada para criacao do relatorio
    vr_nom_direto    varchar2(100);
    vr_nom_arquivo   varchar2(100);

    -- Controlar quebras
    vr_inpessoa_ant number := 0;
    vr_nrdconta_ant number := 0;
    vr_idtprel_ant  varchar2(1) := 'x';

    -- Variaveis para controlar se exibe subreport.
    vr_exibe_ct     varchar2(1) := 'S';
    vr_exibe_ab     varchar2(1) := 'S';

    -- Variáveis de crítica
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(2000);

    --Escrever no arquivo CLOB
    PROCEDURE pc_escreve_xml(pr_des_dados IN CLOB,
                             pr_idtprel in varchar2 default null,
                             pr_ipessoa in number default null) IS
    BEGIN
      --Escrever no arquivo XML
      vr_des_xml := vr_des_xml||pr_des_dados;

      -- Armazenar informacoes de todas as agencias para montar arquivo total
      if pr_idtprel is not null then

        vr_des_chave_tot := pr_idtprel||pr_ipessoa;
        vr_tab_rel_tot(vr_des_chave_tot).idtprel  := pr_idtprel;
        vr_tab_rel_tot(vr_des_chave_tot).inpessoa := pr_ipessoa;

        if vr_tab_rel_tot.exists(vr_des_chave_tot) then
             vr_tab_rel_tot(vr_des_chave_tot).dsc_xml := vr_tab_rel_tot(vr_des_chave_tot).dsc_xml||pr_des_dados;
        else
           vr_tab_rel_tot(vr_des_chave_tot).dsc_xml := pr_des_dados;
        end if;
      end if;
    END;

    -- Buscar dados do operador
    PROCEDURE pc_buscar_operad (pr_cdoperad IN crapope.cdoperad%type,
                                pr_nmoperad out crapope.nmoperad%type,
                                pr_cdagenci out crapope.cdagenci%type
                                ) IS
    BEGIN
      IF trim(pr_cdoperad) is not null THEN
        -- Verifica operadores
        open cr_crapope(pr_cdcooper => pr_cdcooper,
                        pr_cdoperad => pr_cdoperad );
        fetch cr_crapope
          into rw_crapope;
        -- Se não encontrar
        if cr_crapope%notfound then
          pr_nmoperad := '';
          pr_cdagenci := 0;
          -- Fechar o cursor
          close cr_crapope;
        else
          pr_nmoperad := rw_crapope.nmoperad;
          pr_cdagenci := rw_crapope.cdagenci;
          close cr_crapope;
        end if;
      ELSE
        pr_nmoperad := '';
      END IF;
    END pc_buscar_operad;

  BEGIN
    -- Codigo do programa
    vr_cdprogra := 'CRPS315';
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS315'
                              ,pr_action => null);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
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
    BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                              ,pr_flgbatch => 1 -- Fixo
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_cdcritic => vr_cdcritic);

    -- Se a variavel de erro e <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      raise vr_exc_saida;
    END IF;

    -- Buscar as contas que foram abertas no dia em questao
    FOR rw_crapass_abertura IN cr_crapass_abertura (pr_cdcooper => pr_cdcooper,
                                                    pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

      vr_des_chave   := lpad(rw_crapass_abertura.cdagenci,3,0)||nvl(rw_crapass_abertura.inpessoa,3)||lpad(rw_crapass_abertura.nrdconta,8,0);
      vr_des_chave_ag:= lpad(rw_crapass_abertura.cdagenci,3,0);

      --armazenar informacoes dos associados
      vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).cdagenci := rw_crapass_abertura.cdagenci;
      vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).nrdconta := rw_crapass_abertura.nrdconta;
      vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).nmprimtl := rw_crapass_abertura.nmprimtl;
      vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).inpessoa := rw_crapass_abertura.inpessoa;
      
      -- Buscar operador que fez a abertura da conta
      -- Quando eh realizado a abertura da conta, sempre eh gerado a crapneg
      OPEN cr_crapneg (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => rw_crapass_abertura.nrdconta
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
      FETCH cr_crapneg INTO rw_crapneg;
      IF cr_crapneg%FOUND THEN
        vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).cdoperad := rw_crapneg.cdoperad;
      END IF;
      CLOSE cr_crapneg;
      
    END LOOP; -- Fim loop Busca dos associados admitidos no dia

    /* Leitura das contas que fizeram impressao de cartas */
    FOR rw_crapneg2 IN cr_crapneg2(pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt)  LOOP
      IF rw_crapneg2.nrseqreg = 1 THEN --(first-of)
        -- Busca associado
        open cr_crapass(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => rw_crapneg2.nrdconta);
        fetch cr_crapass
          into rw_crapass;
        close cr_crapass;

        vr_des_chave := lpad(rw_crapass.cdagenci,3,0)||
                        nvl(rw_crapass.inpessoa,3)||
                        lpad(rw_crapass.nrdconta,8,0)||
                        lpad(rw_crapneg2.nrdocmto,10,0);

        vr_des_chave_ag:= lpad(rw_crapass.cdagenci,3,0);

        -- Armazenar informacoes das contas que fizeram emissao das cartas
        vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).cdagenci := rw_crapass.cdagenci;
        vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).nrdconta := rw_crapass.nrdconta;
        vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).nmprimtl := rw_crapass.nmprimtl;
        vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).nrdocmto := rw_crapneg2.nrdocmto;
        vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).inpessoa := rw_crapass.inpessoa;

        -- Buscar dados do operador caso exista
        IF trim(rw_crapneg2.cdoperad) is not null THEN
          pc_buscar_operad (pr_cdoperad => rw_crapneg2.cdoperad,
                            pr_nmoperad => vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).nmoperad,
                            pr_cdagenci => vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).agoperad
                           );
        END IF;

        --Buscar dados do operador que imprimiu
        IF trim(rw_crapneg2.cdopeimp) is not null THEN
          pc_buscar_operad (pr_cdoperad => rw_crapneg2.cdopeimp,
                            pr_nmoperad => vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).nmopeimp,
                            pr_cdagenci => vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).agopeimp
                           );
        END IF;

      END IF;-- Fim First-of
    END LOOP;

    -- Busca do diretorio base da cooperativa
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
    --Ler agencias
    IF vr_tab_rel.count > 0 THEN
      vr_des_chave_ag := vr_tab_rel.FIRST;
      LOOP
        -- Sair quando a chave atual for null (chegou no final)
        exit when vr_des_chave_ag is null;
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        --Determinar o nome do arquivo que sera gerado
        vr_nom_arquivo := 'crrl272_'||vr_des_chave_ag;

        --Ler associados que tiveram alteracao
        if vr_tab_rel(vr_des_chave_ag).vr_tab_cratass.count > 0 then

          pc_escreve_xml('<abertura>');

          -- Iniciar variavei de controle
          vr_inpessoa_ant := 0;
          vr_nrdconta_ant := 0;
          vr_exibe_ct     := 'S';
          vr_exibe_ab     := 'S';

          vr_des_chave := vr_tab_rel(vr_des_chave_ag).vr_tab_cratass.FIRST;
          LOOP
            -- Sair quando a chave atual for null (chegou no final)
            exit when vr_des_chave is null;

            -- Buscar informacoes do operador
            pc_buscar_operad (pr_cdoperad => vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).cdoperad,
                              pr_nmoperad => vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).nmoperad,
                              pr_cdagenci => vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).agoperad
                              );

            -- Quando mudar de inpessoa, finalizar tag e reiniciar novo grupo
            IF vr_inpessoa_ant <> vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).inpessoa THEN
              -- se nao for a primeira tag
              IF vr_inpessoa_ant <> 0 THEN
                pc_escreve_xml('</tpessoa>');
              END IF;

              pc_escreve_xml('<tpessoa inpessoa="'||vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).inpessoa||'" ');
              -- salvar no xml a descricao do tipo de pessoa
              if vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).inpessoa = 1 then
                pc_escreve_xml('dspessoa="FISICA" >');
              elsif vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).inpessoa = 2 then
                pc_escreve_xml('dspessoa="JURIDICA">');
              else
                pc_escreve_xml('dspessoa="CHEQUE ADM.">');
              end if;

              vr_inpessoa_ant := vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).inpessoa;
            END IF;

            -- quando mudar de conta incluir informacoes no xml
            IF vr_nrdconta_ant <> vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).nrdconta THEN
              vr_des_xml_tmp := ('<conta>'||
                                '<nrdconta>'||gene0002.fn_mask_conta(vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).nrdconta)||'</nrdconta>
                                 <cdagenci>'||vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).cdagenci||'</cdagenci>
                                 <nmprimtl>'||substr(vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).nmprimtl,1,30)||'</nmprimtl>
                                 <cdoperad>'||vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).cdoperad||'</cdoperad>
                                 <nmoperad>'||substr(vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).nmoperad,1,13)||'</nmoperad>
                                 <agoperad>'||vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).agoperad||'</agoperad>
                               </conta>');

              pc_escreve_xml (vr_des_xml_tmp
                             ,'A' -- Armazenar informacoes tambem no totalizador
                             ,vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).inpessoa);
              vr_nrdconta_ant := vr_tab_rel(vr_des_chave_ag).vr_tab_cratass(vr_des_chave).nrdconta;
            END IF;

            -- Buscar o proximo registro da tabela
            vr_des_chave := vr_tab_rel(vr_des_chave_ag).vr_tab_cratass.next(vr_des_chave);
          END LOOP;

          --pc_escreve_xml(vr_des_xml_tmp);
          pc_escreve_xml('</tpessoa>
                      </abertura>');
        ELSE
          --caso nao exista dados de associados a ser impresso,
          -- deve enviar no xml indicador para não exibir cabecalho
          vr_exibe_ab := 'N';
        END IF;

        --- Montar xml das cartas
        if vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg.count > 0 then

          pc_escreve_xml('<carta>');

          vr_inpessoa_ant := 0;
          vr_nrdconta_ant := 0;

          vr_des_chave := vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg.FIRST;
          LOOP
            -- Sair quando a chave atual for null (chegou no final)
            exit when vr_des_chave is null;

            -- Quando mudar de inpessoa, finalizar tag e reiniciar novo grupo
            IF vr_inpessoa_ant <> vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).inpessoa THEN
              -- se nao for a primeira tag
              IF vr_inpessoa_ant <> 0 THEN
                pc_escreve_xml('</tpessoa>');
              END IF;

              pc_escreve_xml('<tpessoa inpessoa="'||vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).inpessoa||'" ');

              -- salvar no xml a descricao do tipo de pessoa
              IF vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).inpessoa = 1 THEN
                pc_escreve_xml('dspessoa="FISICA" >');
              ELSIF vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).inpessoa = 2 THEN
                pc_escreve_xml('dspessoa="JURIDICA">');
              ELSE
                pc_escreve_xml('dspessoa="CHEQUE ADM.">');
              END IF;

              vr_inpessoa_ant := vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).inpessoa;

            END IF;

            -- quando mudar de conta incluir informacoes no xml
            IF vr_nrdconta_ant <> vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).nrdconta THEN
              vr_des_xml_tmp :=('<conta>'||
                                '<nrdconta>'||gene0002.fn_mask_conta(vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).nrdconta)||'</nrdconta>
                                 <cdagenci>'||vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).cdagenci||'</cdagenci>
                                 <nmprimtl>'||substr(vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).nmprimtl,1,30)||'</nmprimtl>
                                 <agopeimp>'||vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).agopeimp||'</agopeimp>
                                 <nmopeimp>'||substr(vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).nmopeimp,1,13)||'</nmopeimp>
                                 <nrdocmto>'||gene0002.fn_mask(vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).nrdocmto,'zzzz.zzz.9')||'</nrdocmto>
                                </conta>');

              pc_escreve_xml(pr_des_dados => vr_des_xml_tmp,
                             pr_idtprel   => 'C', -- Armazenar informacoes tambem no totalizador
                             pr_ipessoa   => vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).inpessoa
                            );

              vr_nrdconta_ant := vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg(vr_des_chave).nrdconta;
            END IF;

            -- Buscar o proximo registro da tabela
            vr_des_chave := vr_tab_rel(vr_des_chave_ag).vr_tab_cratneg.next(vr_des_chave);
          END LOOP;

          --  pc_escreve_xml(vr_des_xml_tmp);
          pc_escreve_xml('</tpessoa>
                      </carta>');
        ELSE
          --caso nao exista dados de associados a ser impresso,
          -- deve enviar no xml indicador para nao exibir cabecalho
          vr_exibe_ct := 'N';
        END IF;

        --incluir tags de inicializacoo e finalizacao
        vr_des_xml_tmp := '<?xml version="1.0" encoding="utf-8"?><crrl272 exibeab="'||vr_exibe_ab||'"  exibect="'||vr_exibe_ct||'">'||vr_des_xml||'</crrl272>';

        -- Solicitar impressao Arquivo por agencia
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml_tmp      --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl272'          --> No base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl272.jasper'    --> Arquivo de layout do iReport
                                   ,pr_cdrelato  => '272'
                                   ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                                   ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com codigo da agencia
                                   ,pr_qtcoluna  => 80                  --> 132 colunas
                                   ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => '80dh'              --> Nome do formulario para impressão
                                   ,pr_nrcopias  => 1                   --> Numero de copias
                                   ,pr_des_erro  => vr_dscritic);       --> Saida com erro

        IF vr_dscritic IS NOT NULL THEN
          -- Gerar excecao
          raise vr_exc_saida;
        end if;

        -- Buscar o proximo registro da tabela
        vr_des_chave_ag := vr_tab_rel.next(vr_des_chave_ag);
      END LOOP;
    END IF; --vr_tab_rel.COUNT

    --Buscar todos  os registros para emissao do relatorio total
    if vr_tab_rel_tot.count > 0 then
      -- Buscar primeiro
      vr_des_chave_tot := vr_tab_rel_tot.FIRST;

      -- Inicializar variaveis de controle
      vr_inpessoa_ant  := 0;
      vr_idtprel_ant   := 'x';
      vr_des_xml_tmp   := '';
      vr_exibe_ct      := 'N';
      vr_exibe_ab      := 'N';

      LOOP
        -- sair quando nao existir mais chaves
        exit when vr_des_chave_tot is null;

        -- Verificar se muda o tipo de relatorio para montar as tags principais e fechar as anteriores
        IF vr_idtprel_ant       <> vr_tab_rel_tot(vr_des_chave_tot).idtprel THEN
          -- Se nao for o primeiro
          IF vr_idtprel_ant     <> 'x' THEN
            -- Fechar tag conforme o tipo de informacao
            IF vr_idtprel_ant    = 'A' THEN
              vr_des_xml_tmp    := vr_des_xml_tmp||'</tpessoa></abertura>';
            ELSIF vr_idtprel_ant = 'C' THEN
              vr_des_xml_tmp    := vr_des_xml_tmp||'</tpessoa></carta>';
            END IF;
          END IF;
          -- Gerar tag conforme o tipo de informacao
          IF vr_tab_rel_tot(vr_des_chave_tot).idtprel    = 'A' THEN
            vr_des_xml_tmp  := vr_des_xml_tmp||'<abertura>';
            vr_exibe_ab := 'S';
          ELSIF vr_tab_rel_tot(vr_des_chave_tot).idtprel = 'C' THEN
            vr_des_xml_tmp  := vr_des_xml_tmp||'<carta>';
            vr_exibe_ct := 'S';
          END IF;
          vr_idtprel_ant  := vr_tab_rel_tot(vr_des_chave_tot).idtprel;
          vr_inpessoa_ant := 0;
        END IF;

        -- Quando mudar o tipo de pessoa gerar tag do grupo
        IF vr_inpessoa_ant <> vr_tab_rel_tot(vr_des_chave_tot).inpessoa THEN
          -- Senao for o primeiro
          IF vr_inpessoa_ant <> 0 THEN
            vr_des_xml_tmp := vr_des_xml_tmp||('</tpessoa>');
          END IF;

          vr_des_xml_tmp := vr_des_xml_tmp||('<tpessoa inpessoa="'||vr_tab_rel_tot(vr_des_chave_tot).inpessoa||'" ');

          -- Gerar tag com a descricao do tipo de pessoa
          IF vr_tab_rel_tot(vr_des_chave_tot).inpessoa    = 1 THEN
            vr_des_xml_tmp := vr_des_xml_tmp||('dspessoa="FISICA" >');
          ELSIF vr_tab_rel_tot(vr_des_chave_tot).inpessoa = 2 THEN
            vr_des_xml_tmp := vr_des_xml_tmp||('dspessoa="JURIDICA">');
          ELSE
            vr_des_xml_tmp := vr_des_xml_tmp||('dspessoa="CHEQUE ADM.">');
          END IF;

          vr_inpessoa_ant := vr_tab_rel_tot(vr_des_chave_tot).inpessoa;
        END IF;

        vr_des_xml_tmp := vr_des_xml_tmp||vr_tab_rel_tot(vr_des_chave_tot).dsc_xml;
        vr_des_chave_tot := vr_tab_rel_tot.NEXT(vr_des_chave_tot);

      END LOOP;

    END IF; -- Sair quando a chave atual for null (chegou no final)

    -- Montar tags finais
    IF vr_idtprel_ant <> 'x' THEN
      IF vr_idtprel_ant = 'A' THEN
         vr_des_xml_tmp := vr_des_xml_tmp||'</tpessoa></abertura>';
      ELSIF vr_idtprel_ant = 'C' THEN
        vr_des_xml_tmp := vr_des_xml_tmp||'</tpessoa></carta>';
      END IF;
    END IF;

    --incluir tags de inicializacoo e finalizacao
    vr_des_xml_tmp := '<?xml version="1.0" encoding="utf-8"?><crrl272 exibeab="'||vr_exibe_ab||'"  exibect="'||vr_exibe_ct||'">'||vr_des_xml_tmp||'</crrl272>';

    -- Solicitar impressao Arquivo Total
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                               ,pr_dsxml     => vr_des_xml_tmp      --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/crrl272'          --> No base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl272.jasper'    --> Arquivo de layout do iReport
                               ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                               ,pr_cdrelato  => '267'
                               ,pr_dsarqsaid => vr_nom_direto||'/'||'crrl267.lst' --> Arquivo final com codigo da agencia
                               ,pr_qtcoluna  => 80                  --> 132 colunas
                               ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => '80dh'              --> Nome do formulario para impressão
                               ,pr_nrcopias  => 1                   --> Numero de copias
                               ,pr_des_erro  => vr_dscritic);       --> Saida com erro
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar excecao
      RAISE vr_exc_saida;
    END IF;

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    COMMIT;    
  EXCEPTION
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
  END;

END PC_CRPS315;
/
