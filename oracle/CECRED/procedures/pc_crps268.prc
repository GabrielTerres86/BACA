CREATE OR REPLACE PROCEDURE CECRED.pc_crps268(pr_cdcooper IN crapcop.cdcooper%TYPE
                                             ,pr_flgresta IN PLS_INTEGER
                                             ,pr_stprogra OUT PLS_INTEGER
                                             ,pr_infimsol OUT PLS_INTEGER
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                             ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
  /* .............................................................................

   Programa: pc_crps268                      Antigo: fontes/crps268.p
   Sistema : Conta-Corrente - Cooperativa de Crédito
   Sigla   : CRED
   Autor   : Diego Simas (AMcom)
   Data    : Abril/2018.                     Ultima atualização:

   Dados referentes ao programa:

   Frequência: Diário (Batch)
   Objetivo  : Efetuar os débitos referentes a seguros de vida em grupo.

   Alterações:
               --HISTÓRICO PROGRESS--
               30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            craplcm e crapavs (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               20/01/2014 - Incluir VALIDATE craplot, craplcm, crapavs (Lucas R)

               04/02/2015 - Ajuste para debitar a primeira parcela conforme a
                            a data dtprideb SD-235552 (Odirlei-AMcom).

               04/03/2015 - Alterado validação para alterar a data de debito
                            caso a data atual de bedito seja menor ou igual a
                            data do movimento para garatir não será debitdo duas
                            vezes (Odirlei-AMcom)

               12/06/2015 - Ajuste para debitar na renovacao do seguro de vida.
                            (James/Thiago)

               --HISTÓRICO ORACLE--
               16/04/2018 - Migrado rotina/fonte progress para oracle.
                            Diego Simas (AMcom)

               30/04/2018 - P450 - Implementação da procedure de controle de débito em contas com atraso por inadimplência;
                                   Cancelamento automático de seguro para debitos não efetuados;
                                   Envio de mensagens para cooperados que tiveram seguros cancelados por inadimplência.
                            Marcel Kohls (AMcom)

               29/06/2018 - Remoção de RAISE que estava gerando interrupção indevida na diária.
                            Reginaldo (AMcom - P450) 

               09/07/2018 - Incluido NVL na validação de data do primeiro debito(DTPRIDEB)
                            pois o campo pode estar nulo na tabela(PRJ450 - Odirlei-AMcom)             

			   13/03/2019 - Remoção de Lote de Seguro - Alcemir Mouts

  ............................................................................... */

  DECLARE

      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Erro para parar a cadeia
      vr_exc_saida exception;
      -- Erro sem parar a cadeia
      vr_exc_fimprg exception;
      ---------------- Cursores genéricos ----------------

      -- Busca dados da cooperativa --
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor para buscar as informações para restart
      -- e rowid para atualização posterior
      CURSOR cr_crapres IS
        SELECT res.dsrestar
              ,res.rowid
          FROM crapres res
         WHERE res.cdcooper = pr_cdcooper
           AND res.cdprogra = vr_cdprogra;
      rw_crapres cr_crapres%ROWTYPE;

      -------------- Cursores específicos ----------------

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
              ,sld.qtddsdev
        FROM crapseg seg, crapsld sld
        WHERE seg.cdcooper  = pr_cdcooper
          AND seg.nrdconta >= pr_nrdconta
          AND seg.nrctrseg  > nvl(pr_nrctrseg, 0)
          AND seg.tpseguro  = pr_tpseguro
          AND seg.cdsitseg  = pr_cdsitseg
          AND seg.indebito  = pr_indebito
          AND sld.cdcooper  = seg.cdcooper
          AND sld.nrdconta  = seg.nrdconta;
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

      -------------- Variáveis e Tipos -------------------

      -- Variável genérica de calendário com base no cursor da btch0001
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Variáveis para controle de restart
      vr_nrctares crapseg.nrdconta%TYPE; --> Número da conta de restart
      vr_dsrestar     VARCHAR2(4000);    --> String genérica com informações para restart
      vr_nrctrseg crapseg.nrdconta%TYPE; --> Número de contrato do seguro para restart
      vr_inrestar     INTEGER;           --> Indicador de Restart

      vr_cdcritic crapcri.cdcritic%TYPE; --> Código da crítica
      vr_dscritic     VARCHAR2(2000);    --> Descrição da crítica

      vr_flgdebta     NUMBER;            --> Flag debita
      vr_cdhistor     NUMBER;            --> Código Histórico
      vr_dtdebito     DATE;              --> Data do Débito
      vr_dtdeb28      DATE;              --> Data do Débito dia 28
      vr_pmtdebit     BOOLEAN;           --> Permite debitar o histórico
      vr_rowidlcm     ROWID;             --> ROWID do lançamento inserido na CRAPLCM
      vr_nmtabela     VARCHAR2(60);      --> Nome ta tabela retornado pela "pc_gerar_lancamento_conta"
      vr_incrineg     INTEGER;           --> Indicador de crítica de negócio para uso com a "pc_gerar_lancamento_conta"
			vr_dtfimvig     DATE;              --> Data do fim de vigência do seguro, para fins de cancelamento

      vr_dsseguro     VARCHAR2(50);
      vr_rowid_log    rowid;
      vr_tab_retorno lanc0001.typ_reg_retorno;
      vr_nrseqdig craplot.nrseqdig%type; --Remoção de lotes
      -- Objetos para armazenar as variáveis da notificação
      vr_variaveis_notif  NOTI0001.typ_variaveis_notif;
    BEGIN

      -- Código do programa
      vr_cdprogra := 'CRPS268';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS268'
                                ,pr_action => null);

      -- Verifica se a cooperativa está cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de crítica
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
        -- Montar mensagem de crítica
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
      -- Se a variável de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => vr_cdcritic   --> Código da crítica
                                ,pr_des_erro  => vr_dscritic); --> Saída de erro
      -- Se encontrou erro, gerar exceção
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Se houver indicador de restart, mas não veio conta
      IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
        -- Remover o indicador
        vr_inrestar := 0;
      END IF;
      -- Se ainda houver indicação de restart
      IF vr_inrestar > 0 THEN
        -- Converter a descrição do restart que contém o contrato de seguro
        vr_nrctrseg := gene0002.fn_char_para_number(vr_dsrestar);
      END IF;

      -- Somente se a flag de restart estiver ativa
      IF pr_flgresta = 1 THEN
        -- Abre cursor CRAPRES - Restart
        OPEN cr_crapres;
        FETCH cr_crapres
         INTO rw_crapres;
        -- Se não tiver encontrado
        IF cr_crapres%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crapres;
          -- Montar mensagem de crítica
          vr_cdcritic := 151;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor para continuar
          CLOSE cr_crapres;
        END IF;
      END IF;
      -- INÍCIO DO PROCESSAMENTO PRINCIPAL --
      FOR rw_crapseg IN cr_crapseg (pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => vr_nrctares,
                                    pr_nrctrseg => vr_nrctrseg,
                                    pr_tpseguro => 3,
                                    pr_cdsitseg => 1,
                                    pr_indebito => 0) LOOP

        vr_flgdebta := 0;

        -- Condições para verificar se ocorre o débito do seguro de vida
        -- Contratação do Seguro de Vida
        IF rw_crapseg.dtprideb = rw_crapdat.dtmvtolt THEN
           vr_flgdebta := 1;
        ELSE
          -- Renovação do Seguro de Vida
          IF to_char(rw_crapseg.dtrenova, 'MM') = to_char(rw_crapdat.dtmvtolt, 'MM') THEN
            -- Mensal
            IF to_char(rw_crapdat.dtmvtolt, 'MM') <> to_char(rw_crapdat.dtmvtopr, 'MM') THEN
              -- Antecipa o débito da parcela
              IF to_char(rw_crapseg.dtrenova, 'DD') <= to_char(rw_crapdat.dtultdia, 'DD') THEN
                vr_flgdebta := 1;
              END IF;
            ELSE
              -- Diário
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
              -- Diário - Vencimento da parcela
              IF rw_crapseg.dtdebito <= rw_crapdat.dtmvtolt THEN
                vr_flgdebta := 1;
              END IF;
            END IF;
          END IF;
        END IF;

        -- Condição para verificar se debita
        IF vr_flgdebta = 1 THEN

          -- Abre cursor associados
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => rw_crapseg.nrdconta);
          FETCH cr_crapass
          INTO rw_crapass;

          IF cr_crapass%NOTFOUND THEN
            -- Fechar o cursor pois haverá raise
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
            -- Fechar o cursor pois haverá raise
            CLOSE cr_crapcsg;
            -- Montar mensagem de crítica
            -- 556 - Seguradora não cadastrada.
            vr_cdcritic := 556;
            RAISE vr_exc_saida;
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crapcsg;
          END IF;

          vr_cdhistor := rw_crapcsg.cdhstaut##2;

          -- Parcela mensal
          IF vr_cdhistor = 0 THEN
            -- Montar mensagem de crítica
            -- 581 - Histórico não cadastrado para esta seguradora.
            vr_cdcritic := 581;
            RAISE vr_exc_saida;
          END IF;
          
			-- REMOCAO LOTE 
			-- APENAS CRIAR LOTE CASO NÃO EXISTA 
						
			-- Posiciona a capa de lote
			OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
							pr_dtmvtolt => rw_crapdat.dtmvtolt,
							pr_cdagenci => 1,
							pr_cdbccxlt => 100,
							pr_nrdolote => 4154);
			FETCH cr_craplot
			INTO rw_craplot;

			IF cr_craplot%NOTFOUND THEN
					
				--Criar lote
				BEGIN
				INSERT INTO craplot
				  (craplot.cdcooper
				  ,craplot.dtmvtolt
				  ,craplot.cdagenci
				  ,craplot.cdbccxlt
				  ,craplot.nrdolote
				  ,craplot.tplotmov
				  ,craplot.cdoperad
				  ,craplot.cdhistor
				  ,craplot.dtmvtopg
				  ,craplot.nrseqdig
				  ,craplot.qtcompln
				  ,craplot.qtinfoln
				  ,craplot.vlcompcr
				  ,craplot.vlinfocr
				  ,craplot.vlcompdb
				  ,craplot.vlinfodb)
				VALUES
				  (pr_cdcooper
				  ,rw_crapdat.dtmvtolt
				  ,1
				  ,100
				  ,4154
				  ,1
				  ,'1'  -- root
				  ,vr_cdhistor
				  ,rw_crapdat.dtmvtolt
				  ,0  -- craplot.nrseqdig
				  ,0  -- craplot.qtcompln
				  ,0  -- craplot.qtinfoln
				  ,0  -- craplot.vlcompcr
				  ,0  -- craplot.vlinfocr
				  ,0  -- craplot.vlcompdb
				  ,0) -- craplot.vlinfodb
				  ;
				EXCEPTION
				WHEN Dup_Val_On_Index THEN
				  vr_cdcritic := 0;
				  vr_dscritic := 'Lote ja cadastrado.';
				  RAISE vr_exc_saida;
				WHEN OTHERS THEN
				  vr_cdcritic := 0;
					  vr_dscritic := 'Erro ao inserir na tabela de lotes. ' ||sqlerrm;
				  RAISE vr_exc_saida;
				END;
					
			END IF;

			CLOSE cr_craplot;
		  
          --debita apenas se qtde de dias devedor < 60
          IF rw_crapseg.qtddsdev < 60 THEN
		  
		      -- atribuir sequencia do lancamento
     		  vr_nrseqdig := fn_sequence('CRAPLOT'
								        ,'NRSEQDIG'
								        ,''||pr_cdcooper||';'
									       ||to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||';'
									       ||'1;'
									       ||'100;'
									       ||'4154');
										   
              -- Insere o lançamento de débito no valor do seguro
              LANC0001.pc_gerar_lancamento_conta(pr_cdagenci => 1 -- rw_craplot.cdagenci
                                                , pr_cdbccxlt => 100 -- rw_craplot.cdbccxlt
                                                 , pr_cdhistor => vr_cdhistor
												 , pr_nrseqdig => vr_nrseqdig
                                                 , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                 , pr_cdpesqbb => to_char(rw_crapseg.cdsegura)
                                                 , pr_nrdconta => rw_crapseg.nrdconta
                                                 , pr_nrdctabb => rw_crapseg.nrdconta
                                                 , pr_nrdctitg => to_char(rw_crapseg.nrdconta)
                                                 , pr_nrdocmto => rw_crapseg.nrctrseg
                                                 , pr_nrdolote => 4154 --rw_craplot.nrdolote
                                                 , pr_vllanmto => rw_crapseg.vlpreseg
                                                 , pr_cdcooper => pr_cdcooper
                                                 , pr_inprolot => 0  -- processa o lote na própria procedure
                                                 , pr_tplotmov => 1
                                                 , pr_tab_retorno => vr_tab_retorno
                                                 , pr_incrineg => vr_incrineg
                                                 , pr_cdcritic => vr_cdcritic
                                                 , pr_dscritic => vr_dscritic);
            ELSE
              vr_cdcritic := 1134; -- nao foi possivel realizar debito 
              vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
			  vr_incrineg := 1;
            END IF;

          -- se não foi possivel debitar, então cancela seguro
          IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
            IF vr_incrineg = 0 THEN -- Erro de sistema/BD
              RAISE vr_exc_saida;
            ELSE
              -- Limpa variáveis de crítica para não refletir em RAISE posterior
              vr_cdcritic := NULL;
              vr_dscritic := NULL;
							
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
                         ,pr_cdprogra => 'CRPS268'  -- Programa
                         ,pr_inpriori => 0          -- prioridade
                         ,pr_dsdmensg => 'Cooperado, seu seguro '||vr_dsseguro||' foi cancelado por falta de pagamento. Dúvidas consulte seu posto de atendimento' -- corpo da mensagem
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
                                  ,pr_dsorigem => 'AIMARO'
                                  ,pr_dstransa => 'Envio de mensagem de cancelamento de seguro por inadimplencia'
                                  ,pr_dttransa => trunc(SYSDATE)
                                  ,pr_flgtrans => 0
                                  ,pr_hrtransa => GENE0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => 'crps268'
                                  ,pr_nrdconta => rw_crapseg.nrdconta
                                  ,pr_nrdrowid => vr_rowid_log
                                  );
               
               -- cria notificação push
               vr_variaveis_notif('#descseguro') := vr_dsseguro;
               
               NOTI0001.pc_cria_notificacao( pr_cdorigem_mensagem => 8
                                            ,pr_cdmotivo_mensagem => 7
                                          --,pr_dhenvio => SYSDATE   --OPCIONAL: Só passa para agendamento, não precisa passar para SYSDATE
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_crapseg.nrdconta
                                            ,pr_idseqttl => 1        --OPCIONAL: Se não passar a notificação é gerada para todos os titulares/operadores da conta.
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
              -- Fechar o cursor pois haverá raise
              CLOSE cr_craplot;
              -- Montar mensagem de crítica
              -- 1172 - Registro de lote não encontrado.
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

          -- Não é necessário validar e mudar a data de débito se for o débito
          -- da primeira parcela ou se a data do débito já esteja menor ou igual
          -- a data de movimento para garantir que não irá debitar duas vezes
          vr_dtdebito := null;
          vr_dtdeb28 := null;

          IF nvl(rw_crapseg.dtprideb,to_date('01/01/1500','DD/MM/RRRR')) <> rw_crapdat.dtmvtolt THEN
            -- Se o débito for dias 29, 30 ou 31, debitará sempre no dia 28
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
            -- Data de Débito para o dia 28
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

          -- Efetua o cadastro do aviso de débito em conta corrente.
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
              --Levantar Exceção
              RAISE vr_exc_saida;
          END;

          -- Somente se a flag de restart estiver ativa
          IF pr_flgresta = 1 THEN
            -- Salvar informações no banco de dados a cada registro processado
            -- Atualizar a chave de restart caso aconteça algo durante o processo
            BEGIN
              UPDATE crapres
                 SET crapres.nrdconta = rw_crapseg.nrdconta              -- Número da conta
                    ,crapres.dsrestar = LPAD(rw_crapseg.nrctrseg,10,'0') -- Número do contrato de seguro
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

      -- Retornar nome do módulo original, para que tire o action gerado pelo programa chamado acima
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);

      -- Chamar rotina para eliminação do restart para evitarmos
      -- reprocessamento das aplicações indevidamente
      btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                 ,pr_cdprogra => vr_cdprogra   --> Código do programa
                                 ,pr_flgresta => pr_flgresta   --> Indicador de restart
                                 ,pr_des_erro => vr_dscritic); --> Saída de erro
      -- Testar saída de erro
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

END pc_crps268;
/