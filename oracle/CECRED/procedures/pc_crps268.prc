CREATE OR REPLACE PROCEDURE CECRED.pc_crps268(pr_cdcooper IN crapcop.cdcooper%TYPE
                                             ,pr_flgresta IN PLS_INTEGER
                                             ,pr_stprogra OUT PLS_INTEGER
                                             ,pr_infimsol OUT PLS_INTEGER
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                             ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
  /* .............................................................................

   Programa: pc_crps268                      Antigo: fontes/crps268.p
   Sistema : Conta-Corrente - Cooperativa de Cr�dito
   Sigla   : CRED
   Autor   : Diego Simas (AMcom)
   Data    : Abril/2018.                     Ultima atualiza��o:

   Dados referentes ao programa:

   Frequ�ncia: Di�rio (Batch)
   Objetivo  : Efetuar os d�bitos referentes a seguros de vida em grupo.

   Altera��es:
               --HIST�RICO PROGRESS--
               30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            craplcm e crapavs (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               20/01/2014 - Incluir VALIDATE craplot, craplcm, crapavs (Lucas R)

               04/02/2015 - Ajuste para debitar a primeira parcela conforme a
                            a data dtprideb SD-235552 (Odirlei-AMcom).

               04/03/2015 - Alterado valida��o para alterar a data de debito
                            caso a data atual de bedito seja menor ou igual a
                            data do movimento para garatir n�o ser� debitdo duas
                            vezes (Odirlei-AMcom)

               12/06/2015 - Ajuste para debitar na renovacao do seguro de vida.
                            (James/Thiago)

               --HIST�RICO ORACLE--
               16/04/2018 - Migrado rotina/fonte progress para oracle.
                            Diego Simas (AMcom)

               30/04/2018 - P450 - Implementa��o da procedure de controle de d�bito em contas com atraso por inadimpl�ncia;
                                   Cancelamento autom�tico de seguro para debitos n�o efetuados;
                                   Envio de mensagens para cooperados que tiveram seguros cancelados por inadimpl�ncia.
                            Marcel Kohls (AMcom)

  ............................................................................... */

  DECLARE

      -- C�digo do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Erro para parar a cadeia
      vr_exc_saida exception;
      -- Erro sem parar a cadeia
      vr_exc_fimprg exception;
      ---------------- Cursores gen�ricos ----------------

      -- Busca dados da cooperativa --
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor para buscar as informa��es para restart
      -- e rowid para atualiza��o posterior
      CURSOR cr_crapres IS
        SELECT res.dsrestar
              ,res.rowid
          FROM crapres res
         WHERE res.cdcooper = pr_cdcooper
           AND res.cdprogra = vr_cdprogra;
      rw_crapres cr_crapres%ROWTYPE;

      -------------- Cursores espec�ficos ----------------

      -- Busca dados do cadastro de seguros --
      CURSOR cr_crapseg(pr_cdcooper IN crapseg.cdcooper%TYPE,
                        pr_nrdconta IN crapseg.nrdconta%TYPE,
                        pr_nrctrseg IN crapseg.nrctrseg%TYPE,
                        pr_tpseguro IN crapseg.tpseguro%TYPE,
                        pr_cdsitseg IN crapseg.cdsitseg%TYPE,
                        pr_indebito IN crapseg.indebito%TYPE) IS
        SELECT /*+index_asc (seg CRAPSEG##CRAPSEG2)*/
               seg.rowid
              ,seg.dtprideb
              ,seg.dtrenova
              ,seg.dtdebito
              ,seg.nrdconta
              ,seg.cdsegura
              ,seg.vlpreseg
              ,seg.nrctrseg
              ,seg.vlprepag
              ,seg.qtprevig
              ,seg.qtprepag
              ,seg.tpseguro
							,seg.dtfimvig
        FROM crapseg seg
        WHERE seg.cdcooper  = pr_cdcooper
          AND seg.nrdconta >= pr_nrdconta
          AND seg.nrctrseg  > nvl(pr_nrctrseg, 0)
          AND seg.tpseguro  = pr_tpseguro
          AND seg.cdsitseg  = pr_cdsitseg
          AND seg.indebito  = pr_indebito;
      rw_crapseg cr_crapseg%ROWTYPE;

      -- Busca dados do associado --
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.cdsecext
              ,ass.cdagenci
        FROM crapass ass
        WHERE ass.cdcooper = pr_cdcooper
          AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Busca dados da seguradora
      CURSOR cr_crapcsg(pr_cdcooper IN crapcsg.cdcooper%TYPE,
                        pr_cdsegura IN crapcsg.cdsegura%TYPE) IS
        SELECT csg.nrcgcseg
              ,csg.cdhstaut##2
        FROM crapcsg csg
        WHERE csg.cdcooper = pr_cdcooper
          AND csg.cdsegura = pr_cdsegura;
      rw_crapcsg cr_crapcsg%ROWTYPE;

      -- Busca dados da capa de lote
      CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE,
                        pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                        pr_cdagenci IN craplot.cdagenci%TYPE,
                        pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                        pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT lot.rowid
              ,lot.nrseqdig
              ,lot.nrdolote
              ,lot.cdbccxlt
              ,lot.cdagenci
              ,lot.vlcompdb
              ,lot.qtcompln
        FROM craplot lot
        WHERE lot.cdcooper = pr_cdcooper
          AND lot.dtmvtolt = pr_dtmvtolt
          AND lot.cdagenci = pr_cdagenci
          AND lot.cdbccxlt = pr_cdbccxlt
          AND lot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

      -------------- Vari�veis e Tipos -------------------

      -- Vari�vel gen�rica de calend�rio com base no cursor da btch0001
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Vari�veis para controle de restart
      vr_nrctares crapseg.nrdconta%TYPE; --> N�mero da conta de restart
      vr_dsrestar     VARCHAR2(4000);    --> String gen�rica com informa��es para restart
      vr_nrctrseg crapseg.nrdconta%TYPE; --> N�mero de contrato do seguro para restart
      vr_inrestar     INTEGER;           --> Indicador de Restart

      vr_cdcritic crapcri.cdcritic%TYPE; --> C�digo da cr�tica
      vr_dscritic     VARCHAR2(2000);    --> Descri��o da cr�tica

      vr_flgdebta     NUMBER;            --> Flag debita
      vr_cdhistor     NUMBER;            --> C�digo Hist�rico
      vr_dtdebito     DATE;              --> Data do D�bito
      vr_dtdeb28      DATE;              --> Data do D�bito dia 28
      vr_pmtdebit     BOOLEAN;           --> Permite debitar o hist�rico
      vr_rowidlcm     ROWID;             --> ROWID do lan�amento inserido na CRAPLCM
      vr_nmtabela     VARCHAR2(60);      --> Nome ta tabela retornado pela "pc_gerar_lancamento_conta"
      vr_incrineg     INTEGER;           --> Indicador de cr�tica de neg�cio para uso com a "pc_gerar_lancamento_conta"
			vr_dtfimvig     DATE;              --> Data do fim de vig�ncia do seguro, para fins de cancelamento

      vr_dsseguro     VARCHAR2(50);
      vr_rowid_log    rowid;
      vr_tab_retorno lanc0001.typ_reg_retorno;
      
      -- Objetos para armazenar as vari�veis da notifica��o
      vr_variaveis_notif  NOTI0001.typ_variaveis_notif;
    BEGIN

      -- C�digo do programa
      vr_cdprogra := 'CRPS268';
      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS268'
                                ,pr_action => null);

      -- Verifica se a cooperativa est� cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapcop;
        -- Montar mensagem de cr�tica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calend�rio da cooperativa
       OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de cr�tica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a vari�vel de erro � <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> C�digo do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> N�mero da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String gen�rica com informa��es para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => vr_cdcritic   --> C�digo da cr�tica
                                ,pr_des_erro  => vr_dscritic); --> Sa�da de erro
      -- Se encontrou erro, gerar exce��o
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Se houver indicador de restart, mas n�o veio conta
      IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
        -- Remover o indicador
        vr_inrestar := 0;
      END IF;
      -- Se ainda houver indica��o de restart
      IF vr_inrestar > 0 THEN
        -- Converter a descri��o do restart que cont�m o contrato de seguro
        vr_nrctrseg := gene0002.fn_char_para_number(vr_dsrestar);
      END IF;

      -- Somente se a flag de restart estiver ativa
      IF pr_flgresta = 1 THEN
        -- Abre cursor CRAPRES - Restart
        OPEN cr_crapres;
        FETCH cr_crapres
         INTO rw_crapres;
        -- Se n�o tiver encontrado
        IF cr_crapres%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crapres;
          -- Montar mensagem de cr�tica
          vr_cdcritic := 151;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor para continuar
          CLOSE cr_crapres;
        END IF;
      END IF;
      -- IN�CIO DO PROCESSAMENTO PRINCIPAL --
      FOR rw_crapseg IN cr_crapseg (pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => vr_nrctares,
                                    pr_nrctrseg => vr_nrctrseg,
                                    pr_tpseguro => 3,
                                    pr_cdsitseg => 1,
                                    pr_indebito => 0) LOOP

        vr_flgdebta := 0;

        -- Condi��es para verificar se ocorre o d�bito do seguro de vida
        -- Contrata��o do Seguro de Vida
        IF rw_crapseg.dtprideb = rw_crapdat.dtmvtolt THEN
           vr_flgdebta := 1;
        ELSE
          -- Renova��o do Seguro de Vida
          IF to_char(rw_crapseg.dtrenova, 'MM') = to_char(rw_crapdat.dtmvtolt, 'MM') THEN
            -- Mensal
            IF to_char(rw_crapdat.dtmvtolt, 'MM') <> to_char(rw_crapdat.dtmvtopr, 'MM') THEN
              -- Antecipa o d�bito da parcela
              IF to_char(rw_crapseg.dtrenova, 'DD') <= to_char(rw_crapdat.dtultdia, 'DD') THEN
                vr_flgdebta := 1;
              END IF;
            ELSE
              -- Di�rio
              IF to_char(rw_crapseg.dtrenova, 'DD') <= to_char(rw_crapdat.dtmvtolt, 'DD') THEN
                vr_flgdebta := 1;
              END IF;
            END IF;
          ELSE
            -- Mensal
            IF to_char(rw_crapdat.dtmvtolt, 'MM') <> to_char(rw_crapdat.dtmvtopr, 'MM') THEN
              IF rw_crapseg.dtdebito <= rw_crapdat.dtultdia THEN
                vr_flgdebta := 1;
              END IF;
            ELSE
              -- Di�rio - Vencimento da parcela
              IF rw_crapseg.dtdebito <= rw_crapdat.dtmvtolt THEN
                vr_flgdebta := 1;
              END IF;
            END IF;
          END IF;
        END IF;

        -- Condi��o para verificar se debita
        IF vr_flgdebta = 1 THEN

          -- Abre cursor associados
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => rw_crapseg.nrdconta);
          FETCH cr_crapass
          INTO rw_crapass;

          IF cr_crapass%NOTFOUND THEN
            -- Fechar o cursor pois haver� raise
            CLOSE cr_crapass;
            -- Montar mensagem de critica
            -- 251 - Associado nao encontrado no crapass. ERRO DE SISTEMA.
            vr_cdcritic := 251;
            RAISE vr_exc_saida;
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crapass;
          END IF;

          -- Abre cursor seguradoras
          OPEN cr_crapcsg(pr_cdcooper => pr_cdcooper,
                          pr_cdsegura => rw_crapseg.cdsegura);
          FETCH cr_crapcsg
          INTO rw_crapcsg;

          IF cr_crapcsg%NOTFOUND THEN
            -- Fechar o cursor pois haver� raise
            CLOSE cr_crapcsg;
            -- Montar mensagem de cr�tica
            -- 556 - Seguradora n�o cadastrada.
            vr_cdcritic := 556;
            RAISE vr_exc_saida;
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crapcsg;
          END IF;

          vr_cdhistor := rw_crapcsg.cdhstaut##2;

          -- Parcela mensal
          IF vr_cdhistor = 0 THEN
            -- Montar mensagem de cr�tica
            -- 581 - Hist�rico n�o cadastrado para esta seguradora.
            vr_cdcritic := 581;
            RAISE vr_exc_saida;
          END IF;
          
          -- Insere o lan�amento de d�bito no valor do seguro
          LANC0001.pc_gerar_lancamento_conta(pr_cdagenci => 1 -- rw_craplot.cdagenci
                                            , pr_cdbccxlt => 100 -- rw_craplot.cdbccxlt
                                             , pr_cdhistor => vr_cdhistor
                                             , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             , pr_cdpesqbb => to_char(rw_crapseg.cdsegura)
                                             , pr_nrdconta => rw_crapseg.nrdconta
                                             , pr_nrdctabb => rw_crapseg.nrdconta
                                             , pr_nrdctitg => to_char(rw_crapseg.nrdconta)
                                             , pr_nrdocmto => rw_crapseg.nrctrseg
                                             , pr_nrdolote => 4154 --rw_craplot.nrdolote
                                             , pr_vllanmto => rw_crapseg.vlpreseg
                                             , pr_cdcooper => pr_cdcooper
                                             , pr_inprolot => 1  -- processa o lote na pr�pria procedure
                                             , pr_tplotmov => 1
                                             , pr_tab_retorno => vr_tab_retorno
                                             , pr_incrineg => vr_incrineg
                                             , pr_cdcritic => vr_cdcritic
                                             , pr_dscritic => vr_dscritic);

          -- se n�o foi possivel debitar, ent�o cancela seguro
          IF nvl(pr_cdcritic, 0) > 0 OR pr_dscritic IS NOT NULL THEN
            IF vr_incrineg = 0 THEN -- Erro de sistema/BD
              RAISE vr_exc_saida;
            ELSE
              IF (rw_crapseg.tpseguro = 3) THEN
                 vr_dtfimvig := rw_crapdat.dtmvtolt;
               ELSE
                 vr_dtfimvig := rw_crapseg.dtfimvig;
               END IF;

               -- atuliza seguro para cancelado
               update crapseg
               set crapseg.dtfimvig = vr_dtfimvig, -- Data de fim de vigencia do seguro
                   crapseg.dtcancel = rw_crapdat.dtmvtolt, -- Data de cancelamento
                   crapseg.cdsitseg = 2, -- Situacao do seguro: 1 - Ativo 2 - Cancelado
                   crapseg.cdmotcan = 12, -- cancelamento por inadimplencia (SEGU0001)
                   crapseg.cdopeexc = 1,
                   crapseg.cdageexc = 1,
                   crapseg.dtinsexc = rw_crapdat.dtmvtolt,
                   crapseg.cdopecnl = 1
               where crapseg.rowid = rw_crapseg.rowid;


               CASE rw_crapseg.tpseguro
                  WHEN 1 THEN vr_dsseguro := 'Residencial';
                  WHEN 11 THEN vr_dsseguro:= 'Residencial';
                  WHEN 2 THEN vr_dsseguro := 'Auto';
                  WHEN 3 THEN vr_dsseguro := 'de Vida';
                  WHEN 4 THEN vr_dsseguro := 'Prestamista';
                  ELSE vr_dsseguro := '';
                END CASE;

             -- gera mensagem de aviso para o cooperado
              GENE0003.pc_gerar_mensagem
                         (pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => rw_crapseg.nrdconta
                         ,pr_idseqttl => 1          -- Primeiro titular da conta
                         ,pr_cdprogra => 'CRPS439'  -- Programa
                         ,pr_inpriori => 0          -- prioridade
                         ,pr_dsdmensg => 'Cooperado, seu seguro '||vr_dsseguro||' foi cancelado por falta de pagamento. D�vidas consulte seu posto de atendimento' -- corpo da mensagem
                         ,pr_dsdassun => 'Aviso sobre seu seguro'         -- Assunto
                         ,pr_dsdremet => rw_crapcop.nmrescop --nome cooperativa remetente
                         ,pr_dsdplchv => 'emprestimo'
                         ,pr_cdoperad => 1
                         ,pr_cdcadmsg => 0
                         ,pr_dscritic => vr_dscritic);

              -- gera log do envio da mensagem
              GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => '1'
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_dsorigem => 'AYLLOS'
                                  ,pr_dstransa => 'Envio de mensagem de cancelamento de seguro por inadimplencia'
                                  ,pr_dttransa => trunc(SYSDATE)
                                  ,pr_flgtrans => 0
                                  ,pr_hrtransa => GENE0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => 'crps268'
                                  ,pr_nrdconta => rw_crapseg.nrdconta
                                  ,pr_nrdrowid => vr_rowid_log
                                  );
               
               -- cria notifica��o push
               vr_variaveis_notif('#descseguro') := vr_dsseguro;
               
               NOTI0001.pc_cria_notificacao( pr_cdorigem_mensagem => 8
                                            ,pr_cdmotivo_mensagem => 7
                                          --,pr_dhenvio => SYSDATE   --OPCIONAL: S� passa para agendamento, n�o precisa passar para SYSDATE
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_crapseg.nrdconta
                                            ,pr_idseqttl => 1        --OPCIONAL: Se n�o passar a notifica��o � gerada para todos os titulares/operadores da conta.
                                            ,pr_variaveis => vr_variaveis_notif);
               
               -- proximo registro
               continue;
            END IF;
          END IF;

          IF rw_craplot.rowid IS NULL THEN
            -- Posiciona a capa de lote
            OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                            pr_dtmvtolt => rw_crapdat.dtmvtolt,
                            pr_cdagenci => 1,
                            pr_cdbccxlt => 100,
                            pr_nrdolote => 4154);
            FETCH cr_craplot
            INTO rw_craplot;

            IF cr_craplot%NOTFOUND THEN
              -- Fechar o cursor pois haver� raise
              CLOSE cr_craplot;
              -- Montar mensagem de cr�tica
              -- 1172 - Registro de lote n�o encontrado.
              vr_cdcritic := 1172;
              RAISE vr_exc_saida;
            END IF;

            CLOSE cr_craplot;            
          END IF;

          -- Altera o registro de seguros
          BEGIN
            UPDATE crapseg SET
                   crapseg.dtultpag = rw_crapdat.dtmvtolt,
                   crapseg.qtprepag = rw_crapseg.qtprepag + 1,
                   crapseg.qtprevig = rw_crapseg.qtprevig + 1,
                   crapseg.vlprepag = rw_crapseg.vlprepag + rw_crapseg.vlpreseg,
                   crapseg.indebito = 1
             WHERE crapseg.rowid = rw_crapseg.rowid;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic:= 'Erro ao atualizar crapseg. '||SQLERRM;
              --Sair
              RAISE vr_exc_saida;
          END;

          -- Altera o registro de capa de lotes
          BEGIN
            UPDATE craplot SET
                   craplot.nrseqdig = rw_craplot.nrseqdig + 1,
                   craplot.qtcompln = rw_craplot.qtcompln + 1,
                   craplot.qtinfoln = rw_craplot.qtcompln,
                   craplot.vlcompdb = rw_craplot.vlcompdb + rw_crapseg.vlpreseg,
                   craplot.vlinfodb = rw_craplot.vlcompdb
             WHERE craplot.rowid = rw_craplot.rowid;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic:= 'Erro ao atualizar craplot. '||SQLERRM;
              --Sair
              RAISE vr_exc_saida;
          END;

          -- N�o � necess�rio validar e mudar a data de d�bito se for o d�bito
          -- da primeira parcela ou se a data do d�bito j� esteja menor ou igual
          -- a data de movimento para garantir que n�o ir� debitar duas vezes
          vr_dtdebito := null;
          vr_dtdeb28 := null;

          IF rw_crapseg.dtprideb <> rw_crapdat.dtmvtolt THEN
            -- Se o d�bito for dias 29, 30 ou 31, debitar� sempre no dia 28
            IF to_char(rw_crapseg.dtdebito,'DD') > 28 THEN
              vr_dtdeb28 := '28'||to_char(rw_crapseg.dtdebito, '/MM/YYYY');
            END IF;


            IF vr_dtdeb28 IS NOT NULL THEN
              -- CALCULA DATA COM DIA 28 FIXADO
              vr_dtdebito := GENE0005.fn_calc_data(pr_dtmvtolt => vr_dtdeb28
                                                  ,pr_qtmesano => 1
                                                  ,pr_tpmesano => 'M'
                                                  ,pr_des_erro => vr_dscritic);
            ELSE
              -- CALCULA DATA GERAL
              vr_dtdebito := GENE0005.fn_calc_data(pr_dtmvtolt => rw_crapseg.dtdebito
                                                  ,pr_qtmesano => 1
                                                  ,pr_tpmesano => 'M'
                                                  ,pr_des_erro => vr_dscritic);

            END IF;

            -- Altera o registro de seguro
            -- Data de D�bito para o dia 28
            BEGIN
              UPDATE crapseg SET
                     crapseg.dtdebito = vr_dtdebito
               WHERE crapseg.rowid = rw_crapseg.rowid;

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic:= 'Erro ao atualizar crapseg. DataDeb.'||SQLERRM;
                --Sair
                RAISE vr_exc_saida;

            END;
          END IF;

          -- Efetua o cadastro do aviso de d�bito em conta corrente.
          BEGIN
            INSERT INTO crapavs(crapavs.cdagenci,
                                crapavs.cdempres,
                                crapavs.cdhistor,
                                crapavs.cdsecext,
                                crapavs.dtdebito,
                                crapavs.dtmvtolt,
                                crapavs.dtrefere,
                                crapavs.insitavs,
                                crapavs.nrdconta,
                                crapavs.nrdocmto,
                                crapavs.nrseqdig,
                                crapavs.tpdaviso,
                                crapavs.vldebito,
                                crapavs.vlestdif,
                                crapavs.vllanmto,
                                crapavs.flgproce,
                                crapavs.cdcooper)
                 VALUES(rw_crapass.cdagenci,
                        0, -- cdempres
                        vr_cdhistor,
                        rw_crapass.cdsecext,
                        rw_crapdat.dtmvtolt, -- dtdebito
                        rw_crapdat.dtmvtolt, -- dtmvtolt
                        rw_crapdat.dtmvtolt, -- dtrefere
                        0, -- insitavs
                        rw_crapseg.nrdconta,
                        rw_crapseg.nrctrseg,
                        rw_craplot.nrseqdig + 1,
                        2, -- tpdaviso
                        0, -- vldebito
                        0, -- vlestdif
                        rw_crapseg.vlpreseg,
                        0, -- flgproce
                        pr_cdcooper);

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao  inserir  na tabela  CRAPAVS. ' || SQLERRM;
              --Levantar Exce��o
              RAISE vr_exc_saida;
          END;

          -- Somente se a flag de restart estiver ativa
          IF pr_flgresta = 1 THEN
            -- Salvar informa��es no banco de dados a cada registro processado
            -- Atualizar a chave de restart caso aconte�a algo durante o processo
            BEGIN
              UPDATE crapres
                 SET crapres.nrdconta = rw_crapseg.nrdconta              -- N�mero da conta
                    ,crapres.dsrestar = LPAD(rw_crapseg.nrctrseg,10,'0') -- N�mero do contrato de seguro
               WHERE crapres.rowid = rw_crapres.rowid;

            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar a tabela de Restart (CRAPRES) - Conta: '||rw_crapseg.nrdconta||
                               ' CtrSeg:'||rw_crapseg.nrctrseg||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_saida;

            END;
          END IF;

        END IF;
      END LOOP;
      -- FIM DO PROCESSAMENTO PRINCIPAL --

      -- Retornar nome do m�dulo original, para que tire o action gerado pelo programa chamado acima
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);
      -- Testar sa�da de erro
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Chamar rotina para elimina��o do restart para evitarmos
      -- reprocessamento das aplica��es indevidamente
      btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                 ,pr_cdprogra => vr_cdprogra   --> C�digo do programa
                                 ,pr_flgresta => pr_flgresta   --> Indicador de restart
                                 ,pr_des_erro => vr_dscritic); --> Sa�da de erro
      -- Testar sa�da de erro
      IF vr_dscritic IS NOT NULL THEN
        -- Sair do processo
        RAISE vr_exc_saida;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit final
     COMMIT;
   EXCEPTION

    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas c�digo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descri��o
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
      -- Efetuar commit pois gravaremos o que foi processo at� ent�o
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas c�digo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descri��o
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos c�digo e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro n�o tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
   END;

END pc_crps268;
/
