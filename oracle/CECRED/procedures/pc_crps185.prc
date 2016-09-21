CREATE OR REPLACE PROCEDURE CECRED.pc_crps185(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                      ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
BEGIN
  /*

   Programa: PC_CRPS185 (Antigo Fontes/crps185.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/97.                           Ultima atualizacao: 13/02/2015

   Dados referentes ao programa:

   Frequencia: Mensal ou por solicitacao.
   Objetivo  : Emitir relatorio com as pendencias nas alienacoes fiduciarias.
               Atende a solicitacao 101. Emite relatorio 145.

   Alteracoes: 24/06/1999 - Alterado para tratar a data de vencimento do
                            seguro do bem alienado (Edson).

               10/02/2000 - Gerar pedido de impressao (Deborah).

               26/02/2002 - Trocado para a solicitacao 70 - semanal (Deborah).

               16/08/2002 - Desprezar se o bem nao exige seguro (Margarete).

               15/06/2004 - Nao listar se seguro nao obrigatorio(Mirtes)

               30/06/2005 - Trocada solicitacao de 070 para 101 e gerar
                            relatorio por PAC - para a IMPREL (Evandro).

               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               10/07/2006 - Concertado para gerar arquivo pdf(INTRANET) (Diego).

               28/07/2006 - Alterado numero de copias do relatorio 145 para
                            Viacredi (Elton).

               23/05/2007 - Eliminada a atribuicao TRUE de glb_infimsol pois
                            nao e o ultimo programa da cadeia (Guilherme).

               18/02/2010 - Incluido Renavan na descricao do bem (Fernando).

               06/05/2010 - Inclusao do campo "Chassi" (Sandro-GATI).

               20/09/2010 - Migraçao dos campos dos bens da crawepr para
                            a crapbpr (Gabriel).

               20/12/2010 - Arrumar duplicacao de registros no relatorio
                            (Gabriel)

               01/02/2011 - Alterado para nao desprezar emprestimos onde o
                            operador nao e´ encontrado (Henrique).

               16/01/2012 - Ajuste na quantidade de bens alienados (David).

               20/08/2013 - Conversão Progress >> Oracle PLSQL (Odirlei-AMcom)

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)

               20/09/2013 - Alteracao de PAC/P.A.C para PA. (James)

               29/10/2013 - Alterado totalizador de 99 para 999. (Reinert)

               16/01/2014 - Ajustes para compatibilizar alterações de janeiro no Progress (Petter-Supero)

               14/05/2014 - Incluido Upper na busca da crapope. (Odirlei-AMcom)

               30/05/2014 - Retirando crítica do log, "067 - Operador não cadastrado",
                            conforme chamado: 139657 data: 17/03/2014 - Jéssica (DB1).

               26/01/2015 - Alterado o formato do campo nrctremp para 8
                            caracters (Kelvin - 233714)

               13/02/2015 - #241529 Correção de tamanho dos campos que envolvem o número do contrato de empréstimo (aumentado
                            para 8, conforme chamado #233714) em seus conteúdos, pois não estavam suportando o tamanho (Carlos)
*/
    DECLARE
      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS185';
      -- Tratamento de erros
      vr_exc_erro exception;
      vr_exc_fimprg exception;
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);

      /* Busca dos dados da cooperativa */
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nrtelura
              ,cop.dsdircop
              ,cop.cdbcoctl
              ,cop.cdagectl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      /* Cursor genérico de calendário */
      RW_CRAPDAT BTCH0001.CR_CRAPDAT%ROWTYPE;

      /*Busca dados da lista de categorias dispensadas do seguro*/
      CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE)  is
        SELECT dstextab
          FROM craptab
         WHERE craptab.cdcooper = pr_cdcooper
           AND CRAPTAB.NMSISTEM   = 'CRED'
           AND craptab.tptabela   = 'USUARI'
           AND craptab.cdempres   = 11
           AND craptab.cdacesso   = 'DISPSEGURO'
           AND CRAPTAB.TPREGIST   = 001;
       rw_craptab cr_craptab%ROWTYPE;

       --Type para armazenar as descrições das agencias
       type typ_reg_crapage is RECORD(ds_agencia varchar(40) );
       type typ_tab_reg_crapage is table of typ_reg_crapage
                                index by binary_integer;
       vr_tab_dsagencia typ_tab_reg_crapage;

       --Buscar agencias
       cursor cr_crapage (pr_cdcooper in craptab.cdcooper%type) is
         select cdagenci,
                nmresage
           from crapage
           where cdcooper         = pr_cdcooper;

       -- Buscar cadastro auxiliar de emprestimos
       cursor cr_crawepr(pr_cdcooper in crawepr.cdcooper%type) is
         select nrctremp,
                nrdconta,
                cdoperad,
                cdcooper
           from crawepr r
          where r.cdcooper = pr_cdcooper
            --and r.nrctremp = 272279
            and exists(select  1
                         from craplcr c
                        where c.cdlcremp = r.cdlcremp
                          and c.cdcooper = r.cdcooper
                          and c.tpctrato in (2,3));

       -- Buscar emprestimos
       cursor cr_crapepr(pr_cdcooper in crawepr.cdcooper%type,
                         pr_nrdconta in crawepr.nrdconta%type,
                         pr_nrctremp in crawepr.nrctremp%type) is
         select inliquid,
                dtmvtolt
           from crapepr
          where crapepr.cdcooper = pr_cdcooper
            and crapepr.nrdconta = pr_nrdconta
            and crapepr.nrctremp = pr_nrctremp;

       rw_crapepr cr_crapepr%ROWTYPE;

       -- Buscar associados
       cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type,
                          pr_nrdconta in crapass.nrdconta%type) is
         select nmprimtl,
                cdagenci,
                nrdconta
           from crapass
          where crapass.cdcooper = pr_cdcooper
            and crapass.nrdconta = pr_nrdconta;
       rw_crapass cr_crapass%rowtype;

       -- Buscar operadores
       cursor cr_crapope (pr_cdcooper in crapope.cdcooper%type,
                          pr_cdoperad in crapope.cdoperad%type) is
         select nmoperad
           from crapope
          where crapope.cdcooper = pr_cdcooper
            and UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
       rw_crapope cr_crapope%rowtype;

       --Buscar informacoes dos bens da proposta de emprestimo do cooperado
       cursor cr_crapbpr(pr_cdcooper in crawepr.cdcooper%type,
                         pr_nrdconta in crawepr.nrdconta%type,
                         pr_nrctremp in crawepr.nrctremp%type) is
         select dsbemfin
               ,dtvigseg
               ,flgsegur
               ,flgalfid
               ,flglbseg
               ,dscatbem
               ,dscorbem
               ,nrdplaca
               ,nrrenava
               ,dschassi
           from crapbpr
          where crapbpr.cdcooper = pr_cdcooper
            and crapbpr.nrdconta = pr_nrdconta
            and crapbpr.nrctrpro = pr_nrctremp
            and crapbpr.tpctrpro = 90
            and crapbpr.flgalien = 1;--True

       --Type para armazenar as informações de detalhes
       type typ_reg_det is record (rel_nmprimtl varchar2(300),
                                    rel_nmprimt2 varchar2(200),
                                    rel_dschassi varchar2(100));

       type typ_tab_reg_det  is table of typ_reg_det
                             index by pls_integer;

       --Type para armazenar as informações que serão geradas no relatorio
       type typ_reg_str2 is record (cdagenci     crapass.cdagenci%type,
                                    dsagenci     varchar2(100),
                                    nrdconta     crapass.nrdconta%type,
                                    nrctremp     crawepr.nrctremp%type,
                                    dsoperad     crapope.nmoperad%type,
                                    dtmvtolt     crapepr.dtmvtolt%type,
                                    nmprimtl     rw_crapass.nmprimtl%type,
                                    vr_tab_det   typ_tab_reg_det);

       type typ_tab_reg_str2 is table of typ_reg_str2
                             index by varchar2(19); --Ag(3) + Cta(8) + Ctr(8)
       vr_tab_str2 typ_tab_reg_str2;
       -- Indice com array vr_tab_str2
       vr_nrregid       varchar2(50);
       -- Variável para chaveamento (hash) da tabela de aplicações
       vr_des_chave     varchar2(19);

       vr_lssemseg      varchar2(1300);
       vr_nmoperad      crapope.nmoperad%type;

       --Variaveis utilizadas para concatenar informações que serão exibidas no relatorio
       vr_rel_nmprimtl  varchar2(300);
       vr_rel_nmprimt2  varchar2(200);
       vr_rel_dschassi  varchar2(50);

       -- Variaveis utilizadas para gerar totalizadores
       vr_contador      number(5) := 0;
       vr_agencia_atual crapass.cdagenci%type;
       vr_agencia_prox  crapass.cdagenci%type;
       vr_nrdconta_ant  crapass.nrdconta%type;
       vr_nrctremp_ant  crapepr.nrctremp%type;
       vr_tot_conta     number(5);
       vr_tot_ctremp    number(5);
       vr_tot_bem       number(5);

       -- Variavel para armazenar as informacos em XML
       vr_des_xml_tmp   clob;
       vr_des_xml       clob;
       vr_resumo        varchar2(32000);
       vr_nom_direto    varchar2(100);
       vr_nom_arquivo   varchar2(100);
       vr_regexist      BOOLEAN;

       --Escrever no arquivo CLOB
	     PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
       BEGIN
         --Escrever no arquivo XML
         dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
       END;

       --Escrever no arquivo CLOB
	     PROCEDURE pc_escreve_xml(pr_des_dados IN CLOB) IS
       BEGIN
         --Escrever no arquivo XML
         vr_des_xml := vr_des_xml||pr_des_dados;
       END;

    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
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
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1 --true
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);

      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Buscar descrição da crítica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;

      -- Leitura da lista de categorias dispensadas do seguro
      OPEN cr_craptab(pr_cdcooper => pr_cdcooper);
      FETCH cr_craptab
       INTO rw_craptab;
      -- Se não encontrar
      IF CR_CRAPTAB%NOTFOUND THEN
        vr_lssemseg := '';
        -- Fechar o cursor pois efetuaremos raise
        CLOSE cr_craptab;
      ELSE
        vr_lssemseg := rw_craptab.dstextab;
        -- Apenas fechar o cursor
        CLOSE cr_craptab;
      END IF;

      -- Leitura dos postos de atendimento
      for rw_crapage in cr_crapage(pr_cdcooper => pr_cdcooper) loop
        --Armazernar descrições no array
        vr_tab_dsagencia(rw_crapage.cdagenci).ds_agencia := lpad(rw_crapage.cdagenci,3,'0') || ' - ' ||
                                                                 rw_crapage.nmresage;
      end loop;

      --Iniciar variavel de controle
      vr_regexist := FALSE;

      for rw_crawepr in cr_crawepr(pr_cdcooper => pr_cdcooper) loop
        -- Verifica emprestimo
        open cr_crapepr(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => rw_crawepr.nrdconta,
                        pr_nrctremp => rw_crawepr.nrctremp );
        fetch cr_crapepr
          into rw_crapepr;
        -- Se não encontrar
        if cr_crapepr%notfound then
          -- Fechar o cursor
          close cr_crapepr;
          -- ir para o proximo registro
          continue;
        elsif rw_crapepr.inliquid > 0 then
          -- fechar o cursor
          close cr_crapepr;
          -- ir para o proximo registro
          continue;
        else
          -- Apenas fechar o cursor
          close cr_crapepr;
        end if;

        -- Verifica associado
        open cr_crapass(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => rw_crawepr.nrdconta );
        fetch cr_crapass
          into rw_crapass;
        -- Se não encontrar
        if cr_crapass%notfound then
          -- Fechar o cursor
          close cr_crapass;
          -- Montar mensagem de critica
          vr_cdcritic := 251;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 251);

          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic||' CONTA = '||to_char(rw_crawepr.nrdconta));
          --Limpara variavel, pois já atualizou o log
          vr_dscritic := null;
          vr_cdcritic := null;
          -- ir para o proximo registro
          continue;
        end if;
        close cr_crapass;

        -- Verifica operadores
        open cr_crapope(pr_cdcooper => pr_cdcooper,
                        pr_cdoperad => rw_crawepr.cdoperad );
        fetch cr_crapope
          into rw_crapope;
        -- Se não encontrar
        if cr_crapope%notfound then
          -- Fechar o cursor
          close cr_crapope;

          vr_nmoperad := to_char(rw_crawepr.cdoperad)|| ' - Nao Cadastrado';
        else
          vr_nmoperad := rw_crapope.nmoperad;
          close cr_crapope;
        end if;


        vr_contador := 0;
        --Buscar informacoes dos bens da proposta de emprestimo do cooperado
        for rw_crapbpr in cr_crapbpr(pr_cdcooper => rw_crawepr.cdcooper,
                                     pr_nrdconta => rw_crawepr.nrdconta,
                                     pr_nrctremp => rw_crawepr.nrctremp ) loop

          vr_contador := vr_contador + 1;

          -- Senão existir descrição do Bem, vai para o proximo
          if trim(rw_crapbpr.dsbemfin) is null   then
            continue;
          end if;
          -- Se a data da vigencia for maior que a data do movimento e e
          --tiver comprovação de alienação e seguro ou seguro já esta liberado
          -- Deve pular o registro
          if ( rw_crapbpr.dtvigseg > rw_crapdat.dtmvtolt   and
               rw_crapbpr.flgsegur = 1 and --true comprovação de seguro do bem
               rw_crapbpr.flgalfid = 1)    --true comprovação de alienação fiduciária
               or
               rw_crapbpr.flglbseg = 1 then --true liberado do seguro
            continue;
          end if;

          -- Se encontrar a descrição no parametro
          if instr(vr_lssemseg,rw_crapbpr.dscatbem||',') > 0 and
             rw_crapbpr.flgalfid  = 1            then
            continue;
          end if;

          begin
            --Inicializar variaveis que armazenam as mensagens
            vr_rel_nmprimt2 := null;
            vr_rel_dschassi	:= null;

            vr_rel_nmprimtl := lpad(vr_contador,3,'0') || ') (' ;

            if rw_crapbpr.flgalfid = 0 then
              vr_rel_nmprimtl := vr_rel_nmprimtl||'ALIENACAO';
            end if;

            -- senão encontrar a descrição no parametro
            if instr(vr_lssemseg,rw_crapbpr.dscatbem||',') = 0 then
              if rw_crapbpr.flgalfid  = 0 and
                 (rw_crapbpr.flgsegur = 0 or
                  rw_crapbpr.dtvigseg is null or
                  rw_crapbpr.dtvigseg <= rw_crapdat.dtmvtolt)then
                vr_rel_nmprimtl := vr_rel_nmprimtl||'/';
              end if;
              if (rw_crapbpr.flgsegur = 0 or
                    rw_crapbpr.dtvigseg is null OR
                    rw_crapbpr.dtvigseg <= rw_crapdat.dtmvtolt)then
                vr_rel_nmprimtl := vr_rel_nmprimtl||'SEGURO';
              else
                vr_rel_nmprimtl := vr_rel_nmprimtl||'';
              end if;
            end if;

            if trim(vr_rel_nmprimtl) is not null   then
              vr_rel_nmprimtl := vr_rel_nmprimtl || ') ';
            end if;

            vr_rel_nmprimtl := vr_rel_nmprimtl || trim(rw_crapbpr.dscatbem) || ' ' || trim(rw_crapbpr.dsbemfin);

            if trim(rw_crapbpr.dscorbem) is not null then
              vr_rel_nmprimtl := vr_rel_nmprimtl ||', de cor ' || trim(rw_crapbpr.dscorbem);
            end if;

            if trim(rw_crapbpr.nrdplaca) is not null then
              vr_rel_nmprimtl := vr_rel_nmprimtl || ', placa ' || gene0002.fn_mask(rpad(rw_crapbpr.nrdplaca,7,' '),'zzz-zzzz');
            else
              vr_rel_nmprimtl := vr_rel_nmprimtl || ' .';
            end if;

            if rw_crapbpr.nrrenava <> 0 then
              vr_rel_nmprimt2 := '    RENAVAN - ' || gene0002.fn_mask(rw_crapbpr.nrrenava,'zzz.zzz.zzz.zz9') || ' .';
            end if;

            if trim(rw_crapbpr.dschassi) is not null then
              vr_rel_dschassi := '    Chassi - ' || rw_crapbpr.dschassi || ' .';
            end if;

            vr_nrregid := lpad(rw_crapass.cdagenci,3,0)||lpad(rw_crapass.nrdconta,8,0)||lpad(rw_crawepr.nrctremp,8,0);

            vr_tab_str2(vr_nrregid).cdagenci := rw_crapass.cdagenci;
            vr_tab_str2(vr_nrregid).dsagenci := vr_tab_dsagencia(rw_crapass.cdagenci).ds_agencia;
            vr_tab_str2(vr_nrregid).nrdconta := rw_crapass.nrdconta;
            vr_tab_str2(vr_nrregid).nrctremp := rw_crawepr.nrctremp;
            vr_tab_str2(vr_nrregid).dsoperad := vr_nmoperad;
            vr_tab_str2(vr_nrregid).dtmvtolt := rw_crapepr.dtmvtolt;
            vr_tab_str2(vr_nrregid).nmprimtl := rw_crapass.nmprimtl;
            vr_tab_str2(vr_nrregid).vr_tab_det(vr_contador).rel_nmprimtl := vr_rel_nmprimtl;
            vr_tab_str2(vr_nrregid).vr_tab_det(vr_contador).rel_nmprimt2 := vr_rel_nmprimt2;
            vr_tab_str2(vr_nrregid).vr_tab_det(vr_contador).rel_dschassi := vr_rel_dschassi;
          exception
            when others then
              vr_dscritic := 'Não foi possivel armazenar dados no array o (contrato'||rw_crawepr.nrctremp||') :'||SQLErrm;
              RAISE vr_exc_erro;
          end;

          -- marcar como encontrou algum registro para gerar o relatorio
          vr_regexist := TRUE;

        end loop;-- Fim for cr_crapbpr
      end loop;-- Fim for rw_crawepr

      --gerar XML que será enviado ao IReport
      begin

        -- Busca do diretorio base da cooperativa
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

        --Determinar o nome do arquivo que sera gerado
        vr_nom_arquivo := 'crrl145_';

        --Caso não exista nenhum registro, deve gerar relatorio apenas com a mensagem de "NAO HA PENDENCIAS A RELATAR!"
        IF NOT vr_regexist THEN
          -- Inicializar o CLOB
          dbms_lob.createtemporary(vr_des_xml, true);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

          -- Inicilizar as informacoes do XML
          pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl145></crrl145>');

          -- Solicitar impressao de todas as agencias
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl145'          --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl145.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => 'PR_SEMPENDE##S@@PR_FLGSMCTR##S'   --> Enviar como parâmetro apenas a agência
                                     ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo || rw_crapass.cdagenci || '.lst' --> Arquivo final com código da agência
                                     ,pr_qtcoluna  => 132                 --> 132 colunas
                                     ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => '132dh'             --> Nome do formulário para impressão
                                     ,pr_nrcopias  => (case pr_cdcooper
                                                       when 1 then 1
                                                       else 2 end)        --> Número de cópias
                                     ,pr_des_erro  => vr_dscritic);       --> Saída com erro

          -- Liberando a memoria alocada pro CLOB
          dbms_lob.freetemporary(vr_des_xml);
          -- Sair com fimprg
          raise vr_exc_fimprg;

        END IF;

        vr_tot_conta    := 0;
        vr_tot_ctremp   := 0;
        vr_nrdconta_ant := 0;
        vr_nrctremp_ant := 0;
        vr_resumo       := null;

        if vr_tab_str2.count > 0 then

          -- Inicializar o CLOB
          dbms_lob.createtemporary(vr_des_xml, true);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

          -- Inicilizar as informacoes do XML
          pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl145>');

          vr_des_chave := vr_tab_str2.FIRST;
          LOOP
            -- Sair quando a chave atual for null (chegou no final)
            exit when vr_des_chave is null;

            if nvl(vr_agencia_atual,0) <> vr_tab_str2(vr_des_chave).cdagenci then
              vr_agencia_atual := vr_tab_str2(vr_des_chave).cdagenci;
              --Iniciar contadores
              vr_tot_bem      := 0;
              vr_tot_conta    := 0;
              vr_tot_ctremp   := 0;
              vr_nrdconta_ant := 0;
              vr_nrctremp_ant := 0;
              vr_des_xml_tmp  := null;
            end if;

            --Montar tag dos comprovantes
            vr_des_xml_tmp := vr_des_xml_tmp||
                  '<contrato>
                     <nrdconta>'||gene0002.fn_mask_conta(vr_tab_str2(vr_des_chave).nrdconta)   ||'</nrdconta>
                     <nrctremp>'||gene0002.fn_mask_contrato(vr_tab_str2(vr_des_chave).nrctremp)||'</nrctremp>
                     <dsoperad>'||substr(vr_tab_str2(vr_des_chave).dsoperad,1,40)              ||'</dsoperad>
                     <dtmvtolt>'||to_char(vr_tab_str2(vr_des_chave).dtmvtolt,'DD/MM/RR')       ||'</dtmvtolt>
                     <nmprimtl>'||substr(vr_tab_str2(vr_des_chave).nmprimtl,1,100)             ||'</nmprimtl>';

            --Verificar se a conta vai mudar, se não mudar não deve exibir linha separando os registros
            if vr_tab_str2.next(vr_des_chave) is not null then
              if vr_tab_str2(vr_des_chave).nrdconta = vr_tab_str2(vr_tab_str2.next(vr_des_chave)).nrdconta then
                vr_des_xml_tmp := vr_des_xml_tmp|| '<flgmstesp>N</flgmstesp>';
              else
                vr_des_xml_tmp := vr_des_xml_tmp|| '<flgmstesp>S</flgmstesp>';
              end if;
            else
              vr_des_xml_tmp := vr_des_xml_tmp|| '<flgmstesp>S</flgmstesp>';
            end if;

            vr_des_xml_tmp := vr_des_xml_tmp||'<detalhe>';

            --Buscar os detalhes
            for vr_ind in vr_tab_str2(vr_des_chave).vr_tab_det.first..vr_tab_str2(vr_des_chave).vr_tab_det.last loop
              -- Verifica se o registro existe
              IF vr_tab_str2(vr_des_chave).vr_tab_det.EXISTS(vr_ind) THEN
                vr_des_xml_tmp := vr_des_xml_tmp||
                '<info_detalhe>
                       <rel_nmprimtl>'||substr(vr_tab_str2(vr_des_chave).vr_tab_det(vr_ind).rel_nmprimtl,1,97)     ||'</rel_nmprimtl>
                       <rel_nmprimt2>'||substr(vr_tab_str2(vr_des_chave).vr_tab_det(vr_ind).rel_nmprimt2,1,30)      ||'</rel_nmprimt2>
                       <rel_dschassi>'||substr(vr_tab_str2(vr_des_chave).vr_tab_det(vr_ind).rel_dschassi,1,20)      ||'</rel_dschassi>';

                -- se não existir valor enviar tag para não exibir linha no IReport
                if  vr_tab_str2(vr_des_chave).vr_tab_det(vr_ind).rel_nmprimt2 is null and
                    vr_tab_str2(vr_des_chave).vr_tab_det(vr_ind).rel_dschassi is null then
                  vr_des_xml_tmp := vr_des_xml_tmp||'<flgexbinfo>N</flgexbinfo>
                                                     </info_detalhe>  ';
                else
                  vr_des_xml_tmp := vr_des_xml_tmp||'<flgexbinfo>S</flgexbinfo>
                                                      </info_detalhe>  ';
                end if;

                --contar quantidade de bens para a agencia
                vr_tot_bem := vr_tot_bem + 1;
              END IF;
            end loop;
            vr_des_xml_tmp := vr_des_xml_tmp||
                  '  </detalhe>
                   </contrato>';

            -- Contar contas diferentes para a agencia
            if vr_nrdconta_ant <> vr_tab_str2(vr_des_chave).nrdconta then
              vr_tot_conta    := vr_tot_conta + 1;
              vr_nrdconta_ant :=  vr_tab_str2(vr_des_chave).nrdconta;
            end if;

            -- Contar contatos diferentes para a agencia
            if vr_nrctremp_ant <> vr_tab_str2(vr_des_chave).nrctremp then
              vr_tot_ctremp   := vr_tot_ctremp + 1;
              vr_nrctremp_ant := vr_tab_str2(vr_des_chave).nrctremp;
            end if;

            -- verificar se é a ultimo registro
            if vr_tab_str2.next(vr_des_chave) is not null then
              vr_agencia_prox := vr_tab_str2(vr_tab_str2.next(vr_des_chave)).cdagenci;
            else
              vr_agencia_prox := 0;
            end if;

            if vr_agencia_atual <> vr_agencia_prox then
              --Montar tag da agencia para arquivo XML com os totais
              pc_escreve_xml
                 ('<agencia cdagenci="'||vr_tab_str2(vr_des_chave).cdagenci||'"'||
                          ' dsagencia="'||vr_tab_str2(vr_des_chave).dsagenci||'"'||
                          ' qttotass="'||vr_tot_conta||'"'||
                          ' qttotctr="'||vr_tot_ctremp||'"'||
                          ' qttotbem="'||vr_tot_bem||'"'||
                          '>');
              -- Adicionar no xml as informações dos contratos armazenados na variavel tmp
              pc_escreve_xml(vr_des_xml_tmp);

              pc_escreve_xml
                 ( '</agencia>');

              -- Armazenar totais para o resumo
              if vr_resumo is null then
                vr_resumo :=
                  '<resumo cdagenci="999">
                    <detresumo>
                     <cdagenci>' ||vr_tab_str2(vr_des_chave).cdagenci||'</cdagenci>
                     <dsagencia>'||vr_tab_str2(vr_des_chave).dsagenci||'</dsagencia>
                     <qttotass>'||vr_tot_conta      ||'</qttotass>
                     <qttotctr>'||vr_tot_ctremp     ||'</qttotctr>
                     <qttotbem>'||vr_tot_bem        ||'</qttotbem>
                    </detresumo>' ;
              else
                vr_resumo := vr_resumo||
                  '<detresumo>
                     <cdagenci>' ||vr_tab_str2(vr_des_chave).cdagenci||'</cdagenci>
                     <dsagencia>'||vr_tab_str2(vr_des_chave).dsagenci||'</dsagencia>
                     <qttotass>'||vr_tot_conta      ||'</qttotass>
                     <qttotctr>'||vr_tot_ctremp     ||'</qttotctr>
                     <qttotbem>'||vr_tot_bem ||'</qttotbem>
                  </detresumo>' ;
              end if;
            end if;
            -- Buscar o próximo registro da tabela
            vr_des_chave := vr_tab_str2.next(vr_des_chave);
          end loop;

          -- fechar tag resumo
          if vr_resumo is not null then
            vr_resumo := vr_resumo||'</resumo>';
            pc_escreve_xml(vr_resumo);
          end if;

          --Montar tag para finalizar conta
          pc_escreve_xml('</crrl145>');

          -- Gerar solicitação do relatorio por agencia
          vr_agencia_atual := 0;
          vr_des_chave     := vr_tab_str2.first;
          loop
            -- Sair quando a chave atual for null (chegou no final)
            exit when vr_des_chave is null;

            if nvl(vr_agencia_atual,0) <> vr_tab_str2(vr_des_chave).cdagenci then
              vr_agencia_atual := vr_tab_str2(vr_des_chave).cdagenci;
              -- Solicitar impressao
              gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                         ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                         ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                         ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                         ,pr_dsxmlnode => '/crrl145/agencia[@cdagenci='||vr_agencia_atual||']' --> Nó base do XML para leitura dos dados
                                         ,pr_dsjasper  => 'crrl145.jasper'    --> Arquivo de layout do iReport
                                         ,pr_dsparams  => 'PR_CDAGENCI##'||vr_agencia_atual||'@@PR_FLGSMCTR##N@@PR_SEMPENDE##N'   --> Enviar como parâmetro apenas a agência
                                         ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||lpad(vr_agencia_atual,3,0)||'.lst' --> Arquivo final com código da agência
                                         ,pr_qtcoluna  => 132                 --> 132 colunas
                                         ,pr_flg_impri => 'N'                --> Chamar a impressão (Imprim.p)
                                         ,pr_nmformul  => '132dh'            --> Nome do formulário para impressão
                                         ,pr_nrcopias  => 1                  --> Número de cópias
                                         ,pr_des_erro  => vr_dscritic);       --> Saída com erro
              IF vr_dscritic IS NOT NULL THEN
                -- Gerar exceção
                raise vr_exc_erro;
              end if;
            end if;

            -- Buscar o próximo registro da tabela
            vr_des_chave := vr_tab_str2.next(vr_des_chave);

          end loop;

          -- Solicitar geracao somente do resumo(PR_FLGSMCTR = S  sem exibir os contratos)
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl145'          --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl145.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => 'PR_CDAGENCI##999@@PR_FLGSMCTR##S@@PR_SEMPENDE##N'  --> Enviar como parâmetro apenas a agência
                                     ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||
                                                      gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')||'.lst' --> Arquivo final com código da agência
                                     ,pr_qtcoluna  => 132                 --> 132 colunas
                                     ,pr_flg_impri => 'N'                 --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => '132dh'             --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                   --> Número de cópias
                                     ,pr_des_erro  => vr_dscritic);       --> Saída com erro

          IF vr_dscritic IS NOT NULL THEN
            -- Gerar exceção
            raise vr_exc_erro;
          end if;

          -- Solicitar impressao de todas as agencias
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl145' --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl145.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => 'PR_CDAGENCI##999@@PR_FLGSMCTR##N@@PR_SEMPENDE##N'   --> Enviar como parâmetro apenas a agência
                                     ,pr_dsarqsaid => vr_nom_direto||'/crrl145'||
                                                      gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')||'.lst' --> Arquivo final com código da agência
                                     ,pr_qtcoluna  => 132                 --> 132 colunas
                                     ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => '132dh'             --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                   --> Número de cópias
                                     ,pr_des_erro  => vr_dscritic);       --> Saída com erro

          -- Liberando a memoria alocada pro CLOB
          dbms_lob.freetemporary(vr_des_xml);
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar exceção
            raise vr_exc_erro;
          end if;
        end if; -- Fim vr_tab_str2.count > 0 then

        -- Processo OK, devemos chamar a fimprg
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        COMMIT;
      END;
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
      WHEN vr_exc_erro THEN
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
        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        -- Efetuar rollback
        ROLLBACK;
    END;
END PC_CRPS185;
/

