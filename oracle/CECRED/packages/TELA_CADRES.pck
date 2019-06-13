CREATE OR REPLACE PACKAGE CECRED.TELA_CADRES IS
  --
	PROCEDURE pc_envia_email_alcada(pr_cdcooper            IN  tbrecip_param_workflow.cdcooper%TYPE           -- Identificador da cooperativa
                                 ,pr_idcalculo_reciproci IN  tbrecip_calculo.idcalculo_reciproci%TYPE       -- ID unico do calculo de reciprocidade atrelado a contratacao
                                 ,pr_cdcritic            OUT PLS_INTEGER                                    -- Código da crítica
                                 ,pr_dscritic            OUT VARCHAR2                                       -- Descrição da crítica
                                 );
	--
	PROCEDURE pc_busca_workflow(pr_cdcooprt IN  tbrecip_param_workflow.cdcooper%TYPE -- Identificador da cooperativa
                             ,pr_xmllog   IN  VARCHAR2                             -- XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER                          -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2                             -- Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype                    -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                             -- Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2                             -- Erros do processo
		                         );
  --
	PROCEDURE pc_insere_aprovador(pr_cdcooprt           IN  tbrecip_param_aprovador.cdcooper%TYPE           -- Identificador da cooperativa
		                           ,pr_cdalcada_aprovacao IN  tbrecip_param_aprovador.cdalcada_aprovacao%TYPE -- Código da alçada de aprovação
															 ,pr_cdaprovador        IN  tbrecip_param_aprovador.cdaprovador%TYPE        -- Código do aprovador
															 ,pr_dsemail_aprovador  IN  tbrecip_param_aprovador.dsemail_aprovador%TYPE  -- E-mail do aprovador
															 ,pr_xmllog             IN  VARCHAR2                                        -- XML com informações de LOG
															 ,pr_cdcritic           OUT PLS_INTEGER                                     -- Código da crítica
															 ,pr_dscritic           OUT VARCHAR2                                        -- Descrição da crítica
															 ,pr_retxml             IN OUT NOCOPY xmltype                               -- Arquivo de retorno do XML
															 ,pr_nmdcampo           OUT VARCHAR2                                        -- Nome do campo com erro
															 ,pr_des_erro           OUT VARCHAR2                                        -- Erros do processo
		                           );
  --
	PROCEDURE pc_exclui_aprovador(pr_cdcooprt           IN  tbrecip_param_aprovador.cdcooper%TYPE           -- Identificador da cooperativa
		                           ,pr_cdalcada_aprovacao IN  tbrecip_param_aprovador.cdalcada_aprovacao%TYPE -- Código da alçada de aprovação
															 ,pr_cdaprovador        IN  tbrecip_param_aprovador.cdaprovador%TYPE        -- Código do aprovador
															 ,pr_xmllog             IN  VARCHAR2                                        -- XML com informações de LOG
															 ,pr_cdcritic           OUT PLS_INTEGER                                     -- Código da crítica
															 ,pr_dscritic           OUT VARCHAR2                                        -- Descrição da crítica
															 ,pr_retxml             IN OUT NOCOPY xmltype                               -- Arquivo de retorno do XML
															 ,pr_nmdcampo           OUT VARCHAR2                                        -- Nome do campo com erro
															 ,pr_des_erro           OUT VARCHAR2                                        -- Erros do processo
		                           );
	--
	PROCEDURE pc_busca_aprovadores(pr_cdcooprt           IN  tbrecip_param_aprovador.cdcooper%TYPE                 -- Identificador da cooperativa
		                            ,pr_cdalcada_aprovacao IN  tbrecip_param_aprovador.cdalcada_aprovacao%TYPE       -- Código da alçada de aprovação
																,pr_cdaprovador        IN  tbrecip_param_aprovador.cdaprovador%TYPE DEFAULT NULL -- Codigo do aprovador
																,pr_xmllog             IN  VARCHAR2                                              -- XML com informações de LOG
																,pr_cdcritic           OUT PLS_INTEGER                                           -- Código da crítica
																,pr_dscritic           OUT VARCHAR2                                              -- Descrição da crítica
																,pr_retxml             IN OUT NOCOPY xmltype                                     -- Arquivo de retorno do XML
																,pr_nmdcampo           OUT VARCHAR2                                              -- Nome do campo com erro
																,pr_des_erro           OUT VARCHAR2                                              -- Erros do processo
																);
	--
	PROCEDURE pc_busca_operadores(pr_cdcooprt IN  crapope.cdcooper%TYPE -- Identificador da cooperativa
		                           ,pr_cdoperad IN  crapope.cdoperad%TYPE -- Código do operador
															 ,pr_nmoperad IN  crapope.nmoperad%TYPE -- Nome do operador
															 ,pr_nriniseq IN  NUMBER DEFAULT 1      -- Registro inicial para paginação
                               ,pr_nrregist IN  NUMBER DEFAULT 100    -- Quantidade registro inicial para paginação
															 ,pr_xmllog   IN  VARCHAR2              -- XML com informações de LOG
															 ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
															 ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
															 ,pr_retxml   IN OUT NOCOPY xmltype     -- Arquivo de retorno do XML
															 ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
															 ,pr_des_erro OUT VARCHAR2              -- Erros do processo
															 );
	--
	PROCEDURE pc_atualiza_alcada(pr_cdcooprt           IN  tbrecip_param_workflow.cdcooper%TYPE           -- Identificador da cooperativa
		                          ,pr_cdalcada_aprovacao IN  tbrecip_param_workflow.cdalcada_aprovacao%TYPE -- Código da alçada de aprovação
															,pr_flregra_aprovacao  IN  tbrecip_param_workflow.flregra_aprovacao%TYPE  -- Identificador da flag de aprovação
															,pr_xmllog             IN  VARCHAR2                                       -- XML com informações de LOG
															,pr_cdcritic           OUT PLS_INTEGER                                    -- Código da crítica
															,pr_dscritic           OUT VARCHAR2                                       -- Descrição da crítica
															,pr_retxml             IN OUT NOCOPY xmltype                              -- Arquivo de retorno do XML
															,pr_nmdcampo           OUT VARCHAR2                                       -- Nome do campo com erro
															,pr_des_erro           OUT VARCHAR2                                       -- Erros do processo
		                          );
	--
	PROCEDURE pc_busca_alcada_aprovacao(pr_cdcooprt            IN  tbrecip_param_workflow.cdcooper%TYPE               -- Identificador da cooperativa
		                                 ,pr_idcalculo_reciproci IN  tbrecip_aprovador_calculo.idcalculo_reciproci%TYPE -- Identificador do cálculo de reciprocidade
																		 ,pr_xmllog              IN  VARCHAR2                                           -- XML com informações de LOG
																		 ,pr_cdcritic            OUT PLS_INTEGER                                        -- Código da crítica
																		 ,pr_dscritic            OUT VARCHAR2                                           -- Descrição da crítica
																		 ,pr_retxml              IN OUT NOCOPY xmltype                                  -- Arquivo de retorno do XML
																		 ,pr_nmdcampo            OUT VARCHAR2                                           -- Nome do campo com erro
																		 ,pr_des_erro            OUT VARCHAR2                                           -- Erros do processo
																		 );
	--
	PROCEDURE pc_aprova_contrato(pr_cdcooprt            IN  tbrecip_param_workflow.cdcooper%TYPE               -- Identificador da cooperativa
		                          ,pr_cdalcada_aprovacao  IN  tbrecip_param_workflow.cdalcada_aprovacao%TYPE     -- Código da alçada de aprovação
															,pr_idcalculo_reciproci IN  tbrecip_aprovador_calculo.idcalculo_reciproci%TYPE -- Identificador da flag de aprovação
															,pr_idstatus            IN  tbrecip_aprovador_calculo.idstatus%TYPE            -- Status enviado pelo aprovador
															,pr_dsjustificativa     IN  tbrecip_aprovador_calculo.dsjustificativa%TYPE     -- Justificativa da aprovação/rejeição
															,pr_xmllog              IN  VARCHAR2                                           -- XML com informações de LOG
															,pr_cdcritic            OUT PLS_INTEGER                                        -- Código da crítica
															,pr_dscritic            OUT VARCHAR2                                           -- Descrição da crítica
															,pr_retxml              IN OUT NOCOPY xmltype                                  -- Arquivo de retorno do XML
															,pr_nmdcampo            OUT VARCHAR2                                           -- Nome do campo com erro
															,pr_des_erro            OUT VARCHAR2                                           -- Erros do processo
		                          );
  --
  PROCEDURE pc_valida_alcada(pr_cdcooprt            IN  tbrecip_param_workflow.cdcooper%TYPE               -- Identificador da cooperativa
                            ,pr_xmllog              IN  VARCHAR2                                           -- XML com informações de LOG
                            ,pr_cdcritic            OUT PLS_INTEGER                                        -- Código da crítica
                            ,pr_dscritic            OUT VARCHAR2                                           -- Descrição da crítica
                            ,pr_retxml              IN OUT NOCOPY xmltype                                  -- Arquivo de retorno do XML
                            ,pr_nmdcampo            OUT VARCHAR2                                           -- Nome do campo com erro
                            ,pr_des_erro            OUT VARCHAR2                                           -- Erros do processo
                            );
                            
  --
  PROCEDURE pc_busca_qtd_regional(pr_cdcooprt IN crapcop.cdcooper%type -->Codigo Cooperativa
                                 ,pr_xmllog   IN VARCHAR2 DEFAULT NULL -->XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          -->Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             -->Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    -->Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             -->Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);
	--
END TELA_CADRES;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADRES IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CADRES
  --  Sistema  : Ayllos Web
  --  Autor    : Adriao Nagasava - Supero
  --  Data     : 13/07/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela CADRES
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
	
	PROCEDURE pc_insere_param_workflow(pr_cdcooper           IN  tbrecip_param_workflow.cdcooper%TYPE
		                                ,pr_cdalcada_aprovacao IN  tbrecip_param_workflow.cdalcada_aprovacao%TYPE
																		,pr_dscritic           OUT VARCHAR2
		                                ) IS
    /* .............................................................................

    Programa: pc_insere_param_workflow
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 13/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar incluir as alcadas de aprovacao para a cooperativa informada.

    Alteracoes: 
		
    ..............................................................................*/
	BEGIN
		--
		INSERT INTO tbrecip_param_workflow(cdcooper
		                                  ,cdalcada_aprovacao
																			,flcadastra_aprovador
																			)
																VALUES(pr_cdcooper
																      ,pr_cdalcada_aprovacao
																			-- Se o nível é 1 - Coordenação Regional, indica que deverá buscar os aprovadores da CADREG
																			,decode(pr_cdalcada_aprovacao, 1, 0, 1)
																			);
																			
		--
	EXCEPTION
		WHEN OTHERS THEN
			pr_dscritic := 'Erro ao inserir na tbrecip_param_workflow: ' || SQLERRM;
	END pc_insere_param_workflow;
	--
	PROCEDURE pc_envia_email_alcada(pr_cdcooper            IN  tbrecip_param_workflow.cdcooper%TYPE           -- Identificador da cooperativa
                                 ,pr_idcalculo_reciproci IN  tbrecip_calculo.idcalculo_reciproci%TYPE       -- ID unico do calculo de reciprocidade atrelado a contratacao
                                 ,pr_cdcritic            OUT PLS_INTEGER                                    -- Código da crítica
                                 ,pr_dscritic            OUT VARCHAR2                                       -- Descrição da crítica
                                 ) IS
    /* .............................................................................

    Programa: pc_envia_email_alcada
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 01/08/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para envio de solicitação de aprovação por e-mail.

    Alteracoes: 
    
    ..............................................................................*/
    
		CURSOR cr_alcada(pr_cdcooper            tbrecip_aprovador_calculo.cdcooper%TYPE
		                ,pr_idcalculo_reciproci tbrecip_aprovador_calculo.idcalculo_reciproci%TYPE
		                ) IS
		  SELECT tpw.cdalcada_aprovacao
            ,tdc.dscodigo
            ,CASE 
               WHEN (SELECT COUNT(1)
                       FROM tbrecip_aprovador_calculo tac
                      WHERE tac.cdcooper            = tpw.cdcooper
                        AND tac.cdalcada_aprovacao  = tpw.cdalcada_aprovacao
                        AND tac.idcalculo_reciproci = pr_idcalculo_reciproci
                        AND tac.idstatus            = 'A') > 0 THEN 
                 'Aprovado'
               WHEN (SELECT COUNT(1)
                       FROM tbrecip_aprovador_calculo tac
                      WHERE tac.cdcooper            = tpw.cdcooper
                        AND tac.cdalcada_aprovacao  = tpw.cdalcada_aprovacao
                        AND tac.idcalculo_reciproci = pr_idcalculo_reciproci
                        AND tac.idstatus            = 'R') > 0 THEN
                 'Rejeitado'
               ELSE
                 'Pendente'
             END dsstatus
        FROM tbrecip_param_workflow tpw
            ,tbcobran_dominio_campo tdc
       WHERE tpw.cdalcada_aprovacao = tdc.cddominio
         AND tdc.nmdominio          = 'IDALCADA_RECIPR'
         AND tpw.flregra_aprovacao  = 1 -- Ativo
         AND tpw.cdcooper           = pr_cdcooper
		ORDER BY tpw.cdalcada_aprovacao;		
    rw_alcada cr_alcada%ROWTYPE;
		--
		CURSOR cr_conta(pr_cdcooper crapceb.cdcooper%TYPE
		               ,pr_idrecipr crapceb.idrecipr%TYPE
									 ) IS
		  SELECT crapceb.nrdconta
						,crapass.nmprimtl
						,crapass.cdagenci
				FROM crapceb
						,crapass
			 WHERE crapceb.cdcooper = crapass.cdcooper
				 AND crapceb.nrdconta = crapass.nrdconta
				 AND crapceb.cdcooper = pr_cdcooper
				 AND crapceb.idrecipr = pr_idrecipr
				 AND ROWNUM = 1
			 UNION ALL
			SELECT crapceb.nrdconta
						,crapass.nmprimtl
						,crapass.cdagenci
				FROM tbcobran_crapceb crapceb
						,crapass
			 WHERE crapceb.cdcooper = crapass.cdcooper
				 AND crapceb.nrdconta = crapass.nrdconta
				 AND crapceb.cdcooper = pr_cdcooper
				 AND crapceb.idrecipr = pr_idrecipr
				 AND ROWNUM = 1;
		
		rw_conta cr_conta%ROWTYPE;
		--
		CURSOR cr_operador(pr_cdcooper           tbrecip_param_aprovador.cdcooper%TYPE
                      ,pr_cdalcada_aprovacao tbrecip_param_aprovador.cdalcada_aprovacao%TYPE
                      ) IS
      SELECT crapope.cdoperad
            ,crapope.nmoperad
            ,tpa.dsemail_aprovador
        FROM tbrecip_param_aprovador tpa
            ,crapope
       WHERE tpa.cdcooper           = crapope.cdcooper
         AND tpa.cdaprovador        = crapope.cdoperad
				 AND tpa.flativo            = 1 -- Ativo
         AND tpa.cdcooper           = pr_cdcooper
         AND tpa.cdalcada_aprovacao = pr_cdalcada_aprovacao;
    --
    rw_operador cr_operador%ROWTYPE;
		--
		CURSOR cr_regional (pr_cdcooper crapage.cdcooper%TYPE
		                   ,pr_cdagenci crapage.cdagenci%TYPE) IS
			SELECT r.dsdemail
						,r.cdopereg
				FROM crapage c
						,crapreg r 
			 WHERE c.cdcooper = r.cdcooper 
				 AND c.cddregio = r.cddregio 
				 AND c.cdcooper = pr_cdcooper 
				 AND c.cdagenci = pr_cdagenci;
	 rw_regional cr_regional%ROWTYPE;

	 -- Variável de críticas
	 vr_cdcritic crapcri.cdcritic%TYPE;
	 vr_dscritic VARCHAR2(10000);

	 -- Tratamento de erros
	 vr_exc_erro EXCEPTION;
	    
	 -- Variáveis do e-mail
	 vr_dsjustificativa_desc_adic CLOB;
 	 vr_dsassunt                  VARCHAR2(10000);
   vr_dsmensag                  VARCHAR2(10000);
	 --
  BEGIN
		--
    BEGIN
      --
      SELECT tc.dsjustificativa_desc_adic
        INTO vr_dsjustificativa_desc_adic
        FROM tbrecip_calculo tc
       WHERE tc.idcalculo_reciproci = pr_idcalculo_reciproci;
      --
    EXCEPTION
      WHEN no_data_found THEN
        vr_dscritic := 'Não encontrado a justificativa para o calculo de reciprocidade: ' || pr_idcalculo_reciproci;
        RAISE vr_exc_erro;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao buscar a justificativa: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    --
		OPEN cr_conta(pr_cdcooper
								 ,pr_idcalculo_reciproci);
		--
		FETCH cr_conta INTO rw_conta;
		--
		IF cr_conta%ROWCOUNT = 0 THEN
			--
			vr_dscritic := 'Conta e associado não encontrados: ' || pr_idcalculo_reciproci;
      RAISE vr_exc_erro;
			--
		END IF;
		--
    vr_dsassunt := 'APROVAÇÃO DE TARIFA';
    vr_dsmensag := 'Prezado(a) operador(a),<br><br>' ||
                   'Foi solicitada a sua aprovação para alterar a tarifa do convênio de cobrança, conforme negociação abaixo: <br><br>' ||
                   'Conta: ' || SUBSTR(rw_conta.nrdconta,1, LENGTH(rw_conta.nrdconta)-1) || '-' || SUBSTR(rw_conta.nrdconta,LENGTH(rw_conta.nrdconta), LENGTH(rw_conta.nrdconta)) || '<br>' ||
                   'Nome/Razão Social: ' || rw_conta.nmprimtl || '<br><br>' ||
                   'Justificativa: <br>' || vr_dsjustificativa_desc_adic ||
                   '<br><br>Para aprovar ou rejeitar a negociação, acesse a conta na tela ATENDA > COBRANÇA BANCÁRIA, através do link abaixo: <br><br>' ||
                   '<a href="https://ayllos.cecred.coop.br/home.php">https://ayllos.cecred.coop.br/home.php</a>';
    --
		OPEN cr_alcada(pr_cdcooper
									,pr_idcalculo_reciproci);
		--
		LOOP
			--
			FETCH cr_alcada INTO rw_alcada;
			EXIT WHEN cr_alcada%NOTFOUND OR rw_alcada.dsstatus = 'Pendente';
			--
		END LOOP;
		--
		IF cr_alcada%ROWCOUNT = 0 THEN
			--
			vr_dscritic := 'Nenhuma alcada encontrada!';
      RAISE vr_exc_erro;
			--
		END IF;
		-- 
		IF rw_alcada.dsstatus = 'Pendente' THEN
			--
			IF rw_alcada.cdalcada_aprovacao = 1 THEN
				-- Envia apenas para o regional do PA do cooperado
				OPEN cr_regional(pr_cdcooper => pr_cdcooper
				                ,pr_cdagenci => rw_conta.cdagenci);
				FETCH cr_regional INTO rw_regional;
				--
				IF cr_regional%FOUND THEN
					--
					IF TRIM(rw_regional.dsdemail) IS NOT NULL THEN
						gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
																			,pr_cdprogra        => 'CADRES'
																			,pr_des_destino     => rw_regional.dsdemail
																			,pr_des_assunto     => vr_dsassunt
																			,pr_des_corpo       => vr_dsmensag
																			,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
																			,pr_flg_remove_anex => 'N' --> Remover os anexos passados
																			,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
																			,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
																			,pr_des_erro        => vr_dscritic);
					END IF;
					--
				END IF;
				--
				CLOSE cr_regional;
			ELSE
				-- Envia para todos daquela alçada
				OPEN cr_operador(pr_cdcooper
												,rw_alcada.cdalcada_aprovacao);
				--
				LOOP
				--
					FETCH cr_operador INTO rw_operador;
					EXIT WHEN cr_operador%NOTFOUND;
					--
					IF TRIM(rw_operador.dsemail_aprovador) IS NOT NULL THEN
						gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
																			,pr_cdprogra        => 'CADRES'
																			,pr_des_destino     => rw_operador.dsemail_aprovador
																			,pr_des_assunto     => vr_dsassunt
																			,pr_des_corpo       => vr_dsmensag
																			,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
																			,pr_flg_remove_anex => 'N' --> Remover os anexos passados
																			,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
																			,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
																			,pr_des_erro        => vr_dscritic);
					END IF;																		
					--
				END LOOP;
				--
				CLOSE cr_operador;
			END IF;
			--
		END IF;
		--
		CLOSE cr_alcada;
		CLOSE cr_conta;
    --
    COMMIT;
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        --
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --
      ELSE
        --
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        --
      END IF;
      --  
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;
      --
      ROLLBACK;
  END pc_envia_email_alcada;
  --
  PROCEDURE pc_ativa_contrato(pr_cdcooper IN  crapceb.cdcooper%TYPE                           -- Identificador da cooperativa
		                         ,pr_nrdconta IN  crapceb.nrdconta%TYPE                           -- Numero da conta
														 ,pr_nrconven IN  crapceb.nrconven%TYPE                           -- Numero do convenio BB
														 ,pr_nrcnvceb IN  crapceb.nrcnvceb%TYPE                           -- Numero do convenio CECRED
                             ,pr_idrecipr IN  crapceb.idrecipr%TYPE                           -- Identificador do cálculo de reciprocidade
														 ,pr_dtinicio IN  tbrecip_calculo.dtinicio_vigencia_contrato%TYPE -- Data de início de vigência do contrato
                             ,pr_cdcritic OUT PLS_INTEGER                                     -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2                                        -- Descrição da crítica
                             ) IS
    /* .............................................................................

    Programa: pc_ativa_contrato
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 02/08/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para ativar o novo contrato.

    Alteracoes: 
    
    ..............................................................................*/
    
		CURSOR cr_tbcobran_crapceb(pr_cdcooper tbcobran_crapceb.cdcooper%TYPE
															,pr_idrecipr tbcobran_crapceb.idrecipr%TYPE
														  ) IS
		  SELECT tbcobran_crapceb.nrdconta
			      ,tbcobran_crapceb.nrconven
						,tbcobran_crapceb.nrcnvceb
			  FROM tbcobran_crapceb
			 WHERE tbcobran_crapceb.idrecipr = pr_idrecipr
			   AND tbcobran_crapceb.nrcnvceb = pr_nrcnvceb
			   AND tbcobran_crapceb.nrconven = pr_nrconven
			   AND tbcobran_crapceb.nrdconta = pr_nrdconta
			   AND tbcobran_crapceb.cdcooper = pr_cdcooper;
		--
		rw_tbcobran_crapceb cr_tbcobran_crapceb%ROWTYPE;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    --
  BEGIN
    --
    BEGIN
      --
      UPDATE crapceb 
         SET crapceb.insitceb = 1 -- Ativo
       WHERE crapceb.idrecipr = pr_idrecipr
         AND crapceb.cdcooper = pr_cdcooper
         AND crapceb.insitceb = 3; -- Pendente
      --
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar a situacao na CRAPCEB ' || pr_idrecipr || ': ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    --
		BEGIN
			--
      UPDATE tbcobran_crapceb crapceb 
         SET crapceb.insitceb = 1 -- Ativo
       WHERE crapceb.idrecipr = pr_idrecipr
         AND crapceb.cdcooper = pr_cdcooper
         AND crapceb.insitceb = 3; -- Pendente
      --
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar a situacao na TBCOBRAN_CRAPCEB ' || pr_idrecipr || ': ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
		--
		BEGIN
			--
			UPDATE tbrecip_calculo tc
			   SET tc.dtinicio_vigencia_contrato = pr_dtinicio
			 WHERE tc.idcalculo_reciproci        = pr_idrecipr;
			--
		EXCEPTION
			WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar a data na tbrecip_calculo ' || pr_idrecipr || ': ' || SQLERRM;
        RAISE vr_exc_erro;
		END;
		--
		OPEN cr_tbcobran_crapceb(pr_cdcooper
														,pr_idrecipr
														);
	  --
		LOOP
			--
			FETCH cr_tbcobran_crapceb INTO rw_tbcobran_crapceb;
			EXIT WHEN cr_tbcobran_crapceb%NOTFOUND;
			--
			tela_atenda_cobran.pc_grava_principal_crapceb(pr_cdcooper => pr_cdcooper                  -- IN
																									 ,pr_nrdconta => rw_tbcobran_crapceb.nrdconta -- IN
																									 ,pr_nrconven => rw_tbcobran_crapceb.nrconven -- IN
																									 ,pr_nrcnvceb => rw_tbcobran_crapceb.nrcnvceb -- IN
																									 ,pr_insitceb => NULL                         -- IN
																									 ,pr_dscritic => vr_dscritic                  -- OUT
																									 );
			--
			IF vr_dscritic IS NOT NULL THEN
				--
				CLOSE cr_tbcobran_crapceb;
				RAISE vr_exc_erro;
				--
			END IF;
			--
		END LOOP;
		--
		CLOSE cr_tbcobran_crapceb;
		--
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        --
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --
      ELSE
        --
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        --
      END IF;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;
			ROLLBACK;
	END pc_ativa_contrato;
	--
	PROCEDURE pc_inativa_contrato(pr_cdcooper IN  crapceb.cdcooper%TYPE                        -- Identificador da cooperativa
		                           ,pr_nrdconta IN  crapceb.nrdconta%TYPE                        -- Numero da conta
															 ,pr_nrconven IN  crapceb.nrconven%TYPE                        -- Numero do convenio BB
															 ,pr_nrcnvceb IN  crapceb.nrcnvceb%TYPE                        -- Numero do convenio CECRED
															 ,pr_idrecipr IN  crapceb.idrecipr%TYPE                        -- Identificador do cálculo de reciprocidade
															 ,pr_dtfim    IN  tbrecip_calculo.dtfim_vigencia_contrato%TYPE -- Data final da vigência do contrato
															 ,pr_cdcritic OUT PLS_INTEGER                                  -- Código da crítica
															 ,pr_dscritic OUT VARCHAR2                                     -- Descrição da crítica
															 ) IS
		/* .............................................................................

    Programa: pc_inativa_contrato
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 02/08/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para inativar o novo contrato.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		--
	BEGIN
		--
		BEGIN
			--
			UPDATE crapceb 
			   SET crapceb.insitceb = 2 -- Inativo
			 WHERE crapceb.idrecipr = pr_idrecipr
			   AND crapceb.nrcnvceb = pr_nrcnvceb
			   AND crapceb.nrconven = pr_nrconven
			   AND crapceb.nrdconta = pr_nrdconta
			   AND crapceb.cdcooper = pr_cdcooper
				 AND crapceb.insitceb = 1; -- Ativo
			--
		EXCEPTION
			WHEN no_data_found THEN
				BEGIN
					--
					UPDATE tbcobran_crapceb crapceb
						 SET crapceb.insitceb = 2 -- Inativo
					 WHERE crapceb.idrecipr = pr_idrecipr
					   AND crapceb.nrcnvceb = pr_nrcnvceb
					   AND crapceb.nrconven = pr_nrconven
					   AND crapceb.nrdconta = pr_nrdconta
						 AND crapceb.cdcooper = pr_cdcooper
						 AND crapceb.insitceb = 1; -- Ativo
					--
				EXCEPTION
			WHEN OTHERS THEN
						vr_dscritic := '2.Erro ao atualizar a situacao na TBCOBRAN_CRAPCEB ' || pr_idrecipr || ': ' || SQLERRM;
						RAISE vr_exc_erro;
				END;
			WHEN OTHERS THEN
				vr_dscritic := '2.Erro ao atualizar a situacao na CRAPCEB ' || pr_idrecipr || ': ' || SQLERRM;
				RAISE vr_exc_erro;
		END;
		--
		BEGIN
			--
			UPDATE tbrecip_calculo tc
			   SET tc.dtfim_vigencia_contrato = pr_dtfim
			 WHERE tc.idcalculo_reciproci     = pr_idrecipr;
			--
		EXCEPTION
			WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar a data na tbrecip_calculo ' || pr_idrecipr || ': ' || SQLERRM;
        RAISE vr_exc_erro;
		END;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;
			ROLLBACK;
	END pc_inativa_contrato;
	--
	PROCEDURE pc_reprova_contrato(pr_cdcooper IN  crapceb.cdcooper%TYPE -- Identificador da cooperativa
															 ,pr_idrecipr IN  crapceb.idrecipr%TYPE -- Identificador do cálculo de reciprocidade
															 ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
															 ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
															 ) IS
		/* .............................................................................

    Programa: pc_reprova_contrato
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 02/08/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para reprovar o novo contrato.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		--
	BEGIN
		--
		BEGIN
			--
			UPDATE crapceb 
			   SET crapceb.insitceb = 6 -- Não aprova
			 WHERE crapceb.idrecipr = pr_idrecipr
			   AND crapceb.cdcooper = pr_cdcooper
				 AND crapceb.insitceb = 3; -- Pendente
			--
		EXCEPTION
			WHEN no_data_found THEN
				BEGIN
					--
					UPDATE tbcobran_crapceb crapceb
						 SET crapceb.insitceb = 6 -- Não aprova
					 WHERE crapceb.idrecipr = pr_idrecipr
						 AND crapceb.cdcooper = pr_cdcooper
						 AND crapceb.insitceb = 3; -- Pendente
					--
				EXCEPTION
			WHEN OTHERS THEN
						vr_dscritic := '3.Erro ao atualizar a situacao na TBCOBRAN_CRAPCEB ' || pr_idrecipr || ': ' || SQLERRM;
						RAISE vr_exc_erro;
				END;
			WHEN OTHERS THEN
				vr_dscritic := '3.Erro ao atualizar a situacao na CRAPCEB ' || pr_idrecipr || ': ' || SQLERRM;
				RAISE vr_exc_erro;
		END;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;
			ROLLBACK;
	END pc_reprova_contrato;
	--
	PROCEDURE pc_busca_workflow(pr_cdcooprt IN  tbrecip_param_workflow.cdcooper%TYPE -- Identificador da cooperativa
														 ,pr_xmllog   IN  VARCHAR2                             -- XML com informações de LOG
														 ,pr_cdcritic OUT PLS_INTEGER                          -- Código da crítica
														 ,pr_dscritic OUT VARCHAR2                             -- Descrição da crítica
														 ,pr_retxml   IN OUT NOCOPY xmltype                    -- Arquivo de retorno do XML
														 ,pr_nmdcampo OUT VARCHAR2                             -- Nome do campo com erro
														 ,pr_des_erro OUT VARCHAR2                             -- Erros do processo
		                         ) IS
    /* .............................................................................

    Programa: pc_busca_workflow
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 13/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as alcadas de aprovacao para a cooperativa informada.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Cursor para buscar o flow de aprovação
		CURSOR cr_param_workflow(pr_cdcooper tbrecip_param_workflow.cdcooper%TYPE
		                        ) IS
      SELECT tpw.cdalcada_aprovacao
						,tdc.dscodigo
						,tpw.flregra_aprovacao
						,tpw.flcadastra_aprovador
				FROM tbrecip_param_workflow tpw
						,tbcobran_dominio_campo tdc
			 WHERE tpw.cdalcada_aprovacao = tdc.cddominio
				 AND tdc.nmdominio          = 'IDALCADA_RECIPR'
				 AND tpw.cdcooper           = pr_cdcooper;
		
		rw_param_workflow cr_param_workflow%ROWTYPE;
		
		-- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		
		-- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
		--
		vr_qtregistros NUMBER;
		vr_tab_dominios gene0010.typ_tab_dominio;
		-- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                            ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE
                            ) IS
    BEGIN
      --
      gene0002.pc_escreve_xml(vr_des_xml
                             ,vr_texto_completo
                             ,pr_des_dados
                             ,pr_fecha_xml
                             );
      --
    END;
		--
	BEGIN
		-- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADRES'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
		--
		BEGIN
			--
			SELECT COUNT(1)
			  INTO vr_qtregistros
			  FROM tbrecip_param_workflow tpw
			 WHERE tpw.cdcooper = pr_cdcooprt;
			--
		EXCEPTION
			WHEN OTHERS THEN
				vr_dscritic := 'Erro ao verificar se existe workflow: ' || SQLERRM;
				RAISE vr_exc_erro;
		END;
		-- Se não encontrou o cadastro de workflow para a cooperativa informada
		IF vr_qtregistros = 0 THEN
			--
			GENE0010.pc_retorna_dominios(pr_nmmodulo     => 'COBRAN'          -- Nome do modulo(CADAST, COBRAN, etc.)
																	,pr_nmdomini     => 'IDALCADA_RECIPR' -- Nome do dominio
																	,pr_tab_dominios => vr_tab_dominios   -- Retorna os dados dos dominios
																	,pr_dscritic     => vr_dscritic       -- Retorna descricao da critica
																	);
			--
			IF vr_dscritic IS NOT NULL THEN
				--
				RAISE vr_exc_erro;
				--
			END IF;
			--
			IF vr_tab_dominios.count > 0 THEN
				--
				FOR i IN vr_tab_dominios.first..vr_tab_dominios.last LOOP
					--
					pc_insere_param_workflow(pr_cdcooper           => pr_cdcooprt                  -- IN
																	,pr_cdalcada_aprovacao => vr_tab_dominios(i).cddominio -- IN
																	,pr_dscritic           => vr_dscritic                  -- OUT
																	);
					--
					IF vr_dscritic IS NOT NULL THEN
						--
						RAISE vr_exc_erro;
						--
					END IF;
					--
				END LOOP;
				--
			END IF;
			--
		END IF;
		-- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
		--
		OPEN cr_param_workflow(pr_cdcooprt);
		--
		pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
		--
		LOOP
			--
			FETCH cr_param_workflow INTO rw_param_workflow;
			EXIT WHEN cr_param_workflow%NOTFOUND;
			--
			pc_escreve_xml('<inf>'||
												'<cdalcada_aprovacao>'   || rw_param_workflow.cdalcada_aprovacao   ||'</cdalcada_aprovacao>'   ||
												'<flregra_aprovacao>'    || rw_param_workflow.flregra_aprovacao    ||'</flregra_aprovacao>'    ||
												'<flcadastra_aprovador>' || rw_param_workflow.flcadastra_aprovador ||'</flcadastra_aprovador>' ||
												'<dsalcada_aprovacao>'   || rw_param_workflow.dscodigo             ||'</dsalcada_aprovacao>' ||
										 '</inf>');
			--
		END LOOP;
		--
		IF cr_param_workflow%ROWCOUNT > 0 THEN
			--
			pc_escreve_xml('</dados></root>',TRUE);    
			--
			pr_retxml := XMLType.createXML(vr_des_xml);
			--
		ELSE
			--
			vr_dscritic := 'Nenhuma alcada encontrada para a cooperativa informada: ' || pr_cdcooprt;
      RAISE vr_exc_erro;
			--
		END IF;
		--
		CLOSE cr_param_workflow;
		--
		COMMIT;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
	END pc_busca_workflow;
	--
	PROCEDURE pc_insere_aprovador(pr_cdcooprt           IN  tbrecip_param_aprovador.cdcooper%TYPE           -- Identificador da cooperativa
		                           ,pr_cdalcada_aprovacao IN  tbrecip_param_aprovador.cdalcada_aprovacao%TYPE -- Código da alçada de aprovação
															 ,pr_cdaprovador        IN  tbrecip_param_aprovador.cdaprovador%TYPE        -- Código do aprovador
															 ,pr_dsemail_aprovador  IN  tbrecip_param_aprovador.dsemail_aprovador%TYPE  -- E-mail do aprovador
															 ,pr_xmllog             IN  VARCHAR2                                        -- XML com informações de LOG
															 ,pr_cdcritic           OUT PLS_INTEGER                                     -- Código da crítica
															 ,pr_dscritic           OUT VARCHAR2                                        -- Descrição da crítica
															 ,pr_retxml             IN OUT NOCOPY xmltype                               -- Arquivo de retorno do XML
															 ,pr_nmdcampo           OUT VARCHAR2                                        -- Nome do campo com erro
															 ,pr_des_erro           OUT VARCHAR2                                        -- Erros do processo
		                           ) IS
		/* .............................................................................

    Programa: pc_insere_aprovador
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 16/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para inserir o aprovador na alcadas de aprovacao para a cooperativa e nível informados.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		--
		vr_qtregistro NUMBER;
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		--
	BEGIN
		-- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADRES'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
		-- Verifica se o aprovador já foi inserido
		BEGIN
			--
			SELECT COUNT(1)
			  INTO vr_qtregistro
				FROM tbrecip_param_aprovador tpa
			 WHERE tpa.cdaprovador = pr_cdaprovador;
			--
		EXCEPTION
			WHEN OTHERS THEN
				vr_dscritic := 'Erro ao buscar o aprovador ' || pr_cdaprovador || ': ' || SQLERRM;
				RAISE vr_exc_erro;
		END;
		--
		IF nvl(vr_qtregistro, 0) = 0 THEN
			--
			BEGIN
				--
				INSERT INTO tbrecip_param_aprovador(cdcooper
																					 ,cdalcada_aprovacao
																					 ,cdaprovador
																					 ,dsemail_aprovador
																					 ,flativo
																					 )
																		 VALUES(pr_cdcooprt
																					 ,pr_cdalcada_aprovacao
																					 ,pr_cdaprovador
																					 ,pr_dsemail_aprovador
																					 ,1 -- Ativo
																					 );
				--
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Erro ao inserir o aprovador ' || pr_cdaprovador || ': ' || SQLERRM;
					RAISE vr_exc_erro;
			END;
			--
		ELSE
			--
			BEGIN
				--
				UPDATE tbrecip_param_aprovador tpa
				   SET tpa.cdcooper           = pr_cdcooprt
					    ,tpa.cdalcada_aprovacao = pr_cdalcada_aprovacao
							,tpa.dsemail_aprovador  = pr_dsemail_aprovador
							,tpa.flativo            = 1 -- Ativo
				 WHERE tpa.cdaprovador = pr_cdaprovador;
				--
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Erro ao atualizar o aprovador ' || pr_cdaprovador || ': ' || SQLERRM;
					RAISE vr_exc_erro;
			END;
			--
		END IF;
		--
		COMMIT;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
	END pc_insere_aprovador;
	--
	PROCEDURE pc_exclui_aprovador(pr_cdcooprt           IN  tbrecip_param_aprovador.cdcooper%TYPE           -- Identificador da cooperativa
		                           ,pr_cdalcada_aprovacao IN  tbrecip_param_aprovador.cdalcada_aprovacao%TYPE -- Código da alçada de aprovação
															 ,pr_cdaprovador        IN  tbrecip_param_aprovador.cdaprovador%TYPE        -- Código do aprovador
															 ,pr_xmllog             IN  VARCHAR2                                        -- XML com informações de LOG
															 ,pr_cdcritic           OUT PLS_INTEGER                                     -- Código da crítica
															 ,pr_dscritic           OUT VARCHAR2                                        -- Descrição da crítica
															 ,pr_retxml             IN OUT NOCOPY xmltype                               -- Arquivo de retorno do XML
															 ,pr_nmdcampo           OUT VARCHAR2                                        -- Nome do campo com erro
															 ,pr_des_erro           OUT VARCHAR2                                        -- Erros do processo
		                           ) IS
		/* .............................................................................

    Programa: pc_exclui_aprovador
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 16/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir o aprovador na alcadas de aprovacao para a cooperativa e nível informados.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		--
	BEGIN
		-- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADRES'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
		--
		BEGIN
			--
			UPDATE tbrecip_param_aprovador tpa
			   SET tpa.flativo = 0 -- Inativo
			 WHERE tpa.cdcooper           = pr_cdcooprt
			   AND tpa.cdalcada_aprovacao = pr_cdalcada_aprovacao
				 AND tpa.cdaprovador        = pr_cdaprovador;
			--
		EXCEPTION
			WHEN OTHERS THEN
				vr_dscritic := 'Erro ao inativar o aprovador ' || pr_cdaprovador || ': ' || SQLERRM;
				RAISE vr_exc_erro;
		END;
		--
		COMMIT;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
	END pc_exclui_aprovador;
  --
  PROCEDURE pc_busca_aprovadores(pr_cdcooprt           IN  tbrecip_param_aprovador.cdcooper%TYPE                 -- Identificador da cooperativa
		                            ,pr_cdalcada_aprovacao IN  tbrecip_param_aprovador.cdalcada_aprovacao%TYPE       -- Código da alçada de aprovação
																,pr_cdaprovador        IN  tbrecip_param_aprovador.cdaprovador%TYPE DEFAULT NULL -- Codigo do aprovador
																,pr_xmllog             IN  VARCHAR2                                              -- XML com informações de LOG
																,pr_cdcritic           OUT PLS_INTEGER                                           -- Código da crítica
																,pr_dscritic           OUT VARCHAR2                                              -- Descrição da crítica
																,pr_retxml             IN OUT NOCOPY xmltype                                     -- Arquivo de retorno do XML
																,pr_nmdcampo           OUT VARCHAR2                                              -- Nome do campo com erro
																,pr_des_erro           OUT VARCHAR2                                              -- Erros do processo
																) IS
    /* .............................................................................

    Programa: pc_busca_aprovadores
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 17/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os aprovadores cadastrados para a alcada de aprovacao e cooperativa informados.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Cursor para buscar os aprovadores
		CURSOR cr_aprovadores(pr_cdcooper           tbrecip_param_aprovador.cdcooper%TYPE
		                     ,pr_cdalcada_aprovacao tbrecip_param_aprovador.cdalcada_aprovacao%TYPE
												 ,pr_cdaprovador        tbrecip_param_aprovador.cdaprovador%TYPE
		                     ) IS
      SELECT tpa.cdaprovador
			      ,crapope.nmoperad
						,tpa.dsemail_aprovador
				FROM tbrecip_param_aprovador tpa
				    ,crapope
			 WHERE tpa.cdcooper           = crapope.cdcooper
			   AND tpa.cdaprovador        = crapope.cdoperad
				 AND tpa.flativo            = 1 -- Ativo
				 AND tpa.cdaprovador        = nvl(pr_cdaprovador, tpa.cdaprovador)
				 AND tpa.cdalcada_aprovacao = pr_cdalcada_aprovacao
				 AND tpa.cdcooper           =	pr_cdcooper;
		
		rw_aprovadores cr_aprovadores%ROWTYPE;
		
    CURSOR cr_regional(pr_cdcooper crapage.cdcooper%TYPE) IS
			SELECT r.dsdemail
						,r.cdopereg
						,o.nmoperad
				FROM crapage c
						,crapreg r
						,crapope o
			 WHERE c.cdcooper = r.cdcooper 
				 AND c.cddregio = r.cddregio 
				 AND r.cdcooper = o.cdcooper
       	 AND r.cdopereg = o.cdoperad
				 AND c.cdcooper = pr_cdcooper
	  GROUP BY r.dsdemail
		        ,r.cdopereg
						,o.nmoperad;
   rw_regional cr_regional%ROWTYPE;		
		
		-- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		
		-- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
		-- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                            ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE
                            ) IS
    BEGIN
      --
      gene0002.pc_escreve_xml(vr_des_xml
                             ,vr_texto_completo
                             ,pr_des_dados
                             ,pr_fecha_xml
                             );
      --
    END;
		--
	BEGIN
		-- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADRES'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
		-- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
		--
		pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
		--
		IF pr_cdalcada_aprovacao = 1 THEN
			--
			FOR rw_regional IN cr_regional (pr_cdcooprt) LOOP
				pc_escreve_xml('<inf>'||
													'<cdaprovador>'      || rw_regional.cdopereg ||'</cdaprovador>'      ||
													'<nmaprovador>'      || rw_regional.nmoperad ||'</nmaprovador>'      ||
													'<dsemailaprovador>' || rw_regional.dsdemail ||'</dsemailaprovador>' ||
											 '</inf>');
			END LOOP;
			--
		ELSE		
			FOR rw_aprovadores IN cr_aprovadores(pr_cdcooprt
          									              ,pr_cdalcada_aprovacao
									                        ,pr_cdaprovador) LOOP
				--
				pc_escreve_xml('<inf>'||
													'<cdaprovador>'      || rw_aprovadores.cdaprovador       ||'</cdaprovador>'      ||
													'<nmaprovador>'      || rw_aprovadores.nmoperad          ||'</nmaprovador>'      ||
													'<dsemailaprovador>' || rw_aprovadores.dsemail_aprovador ||'</dsemailaprovador>' ||
											 '</inf>');
			END LOOP;
			--
		END IF;
		--
		pc_escreve_xml('</dados></root>',TRUE);    
		--
		pr_retxml := XMLType.createXML(vr_des_xml);
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
	END pc_busca_aprovadores;
	--
	PROCEDURE pc_busca_operadores(pr_cdcooprt IN  crapope.cdcooper%TYPE -- Identificador da cooperativa
		                           ,pr_cdoperad IN  crapope.cdoperad%TYPE -- Código do operador
															 ,pr_nmoperad IN  crapope.nmoperad%TYPE -- Nome do operador
															 ,pr_nriniseq IN  NUMBER DEFAULT 1      -- Registro inicial para paginação
                               ,pr_nrregist IN  NUMBER DEFAULT 100    -- Quantidade registro inicial para paginação
															 ,pr_xmllog   IN  VARCHAR2              -- XML com informações de LOG
															 ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
															 ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
															 ,pr_retxml   IN OUT NOCOPY xmltype     -- Arquivo de retorno do XML
															 ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
															 ,pr_des_erro OUT VARCHAR2              -- Erros do processo
															 ) IS
    /* .............................................................................

    Programa: pc_busca_operadores
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 17/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os operadores cadastrados para a cooperativa informada.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Busca o(s) operador(es)
		CURSOR cr_crapope(pr_cdcooper crapope.cdcooper%TYPE
		                 ,pr_cdoperad crapope.cdoperad%TYPE
										 ,pr_nmoperad crapope.nmoperad%TYPE
										 ,pr_nriniseq NUMBER
										 ,pr_nrregist NUMBER
		                 ) IS
				SELECT cdoperad
				      ,nmoperad
							,rnum
							,qtregtot
              ,(SELECT dsemail_aprovador
                  FROM tbrecip_param_aprovador tpa
                 WHERE tpa.cdcooper = res.cdcooper
                   AND tpa.cdaprovador = res.cdoperad) dsemail_operador
					FROM(SELECT crapope.cdcooper
                     ,crapope.cdoperad
										 ,crapope.nmoperad
										 ,ROW_NUMBER() OVER ( ORDER BY crapope.nmoperad) rnum
										 ,COUNT(*) over () qtregtot
								 FROM crapope
								WHERE crapope.cdsitope = 1
									AND crapope.cdcooper = pr_cdcooper
									AND ((TRIM(pr_cdoperad) IS NULL 
													OR UPPER(crapope.cdoperad) LIKE '%' || UPPER(pr_cdoperad) || '%')
									 OR  (TRIM(pr_nmoperad) IS NULL
													OR UPPER(crapope.nmoperad) LIKE '%' || UPPER(pr_nmoperad) || '%'))
									AND NOT EXISTS(SELECT 1
																	 FROM tbrecip_param_aprovador tpa
																	WHERE tpa.cdcooper    = crapope.cdcooper
																		AND tpa.cdaprovador = crapope.cdoperad
																		AND tpa.flativo     = 1 -- Ativo
																)
						ORDER BY crapope.nmoperad) res
				 WHERE (rnum >= pr_nriniseq AND 
                rnum <= (pr_nriniseq + pr_nrregist-1))
            OR pr_nrregist = 0;
    --
    rw_crapope cr_crapope%ROWTYPE;

		-- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		
		-- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
		-- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                            ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE
                            ) IS
    BEGIN
      --
      gene0002.pc_escreve_xml(vr_des_xml
                             ,vr_texto_completo
                             ,pr_des_dados
                             ,pr_fecha_xml
                             );
      --
    END;
		--
	BEGIN
		-- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADRES'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
		-- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
		--
		OPEN cr_crapope(pr_cdcooprt
									 ,pr_cdoperad
									 ,pr_nmoperad
									 ,pr_nriniseq
									 ,pr_nrregist
									 );
		--
		pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
		--
		LOOP
			--
			FETCH cr_crapope INTO rw_crapope;
			EXIT WHEN cr_crapope%NOTFOUND;
			--
			pc_escreve_xml('<inf>'||
												'<cdoperad>' || rw_crapope.cdoperad ||'</cdoperad>' ||
												'<nmoperad>' || rw_crapope.nmoperad ||'</nmoperad>' ||
												'<dsemail_operador>' || rw_crapope.dsemail_operador ||'</dsemail_operador>' ||
										 '</inf>');
			--
		END LOOP;
		--
		--IF cr_crapope%ROWCOUNT > 0 THEN
			--
			pc_escreve_xml('</dados>');
			--
			pc_escreve_xml('<dados>'||
											'<qtoperad>' || nvl(rw_crapope.qtregtot, 0) ||'</qtoperad>' ||
									 '</dados></root>', TRUE);
			--
			pr_retxml := XMLType.createXML(vr_des_xml);
			--
		/* -- Comentado para não gerar erro na tela
		ELSE
			--
			vr_dscritic := 'Nenhum operador ativo encontrado para a cooperativa informada: ' || pr_cdcooper;
      RAISE vr_exc_erro;
			--*/
		--END IF;
		--
		CLOSE cr_crapope;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
	END pc_busca_operadores;
	--
	PROCEDURE pc_atualiza_alcada(pr_cdcooprt           IN  tbrecip_param_workflow.cdcooper%TYPE           -- Identificador da cooperativa
		                          ,pr_cdalcada_aprovacao IN  tbrecip_param_workflow.cdalcada_aprovacao%TYPE -- Código da alçada de aprovação
															,pr_flregra_aprovacao  IN  tbrecip_param_workflow.flregra_aprovacao%TYPE  -- Identificador da flag de aprovação
															,pr_xmllog             IN  VARCHAR2                                       -- XML com informações de LOG
															,pr_cdcritic           OUT PLS_INTEGER                                    -- Código da crítica
															,pr_dscritic           OUT VARCHAR2                                       -- Descrição da crítica
															,pr_retxml             IN OUT NOCOPY xmltype                              -- Arquivo de retorno do XML
															,pr_nmdcampo           OUT VARCHAR2                                       -- Nome do campo com erro
															,pr_des_erro           OUT VARCHAR2                                       -- Erros do processo
		                          ) IS
		/* .............................................................................

    Programa: pc_atualiza_alcada
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 16/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para habilitar/desabilitar a alçada de aprovação.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		--
	BEGIN
		-- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADRES'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
		--
		BEGIN
			--
			UPDATE tbrecip_param_workflow tpw
			   SET tpw.flregra_aprovacao = pr_flregra_aprovacao
			 WHERE tpw.cdalcada_aprovacao = pr_cdalcada_aprovacao
			   AND tpw.cdcooper           = pr_cdcooprt;
			--
		EXCEPTION
			WHEN OTHERS THEN
				vr_dscritic := 'Erro ao atualizar a alcada ' || pr_cdalcada_aprovacao || ': ' || SQLERRM;
				RAISE vr_exc_erro;
		END;
		--
		COMMIT;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
	END pc_atualiza_alcada;
	--
	PROCEDURE pc_busca_alcada_aprovacao(pr_cdcooprt            IN  tbrecip_param_workflow.cdcooper%TYPE               -- Identificador da cooperativa
		                                 ,pr_idcalculo_reciproci IN  tbrecip_aprovador_calculo.idcalculo_reciproci%TYPE -- Identificador do cálculo de reciprocidade
																		 ,pr_xmllog              IN  VARCHAR2                                           -- XML com informações de LOG
																		 ,pr_cdcritic            OUT PLS_INTEGER                                        -- Código da crítica
																		 ,pr_dscritic            OUT VARCHAR2                                           -- Descrição da crítica
																		 ,pr_retxml              IN OUT NOCOPY xmltype                                  -- Arquivo de retorno do XML
																		 ,pr_nmdcampo            OUT VARCHAR2                                           -- Nome do campo com erro
																		 ,pr_des_erro            OUT VARCHAR2                                           -- Erros do processo
																		 ) IS
    /* .............................................................................

    Programa: pc_busca_alcada_aprovacao
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 13/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as alcadas de aprovacao com o status para o cálculo de reciprocidade informado.

    Alteracoes: 
		
    ..............................................................................*/
		
		-- Cursor para buscar as alçadas com seus respectivos status
		CURSOR cr_alcada_aprovacao(pr_cdcooper            tbrecip_param_workflow.cdcooper%TYPE
		                          ,pr_idcalculo_reciproci tbrecip_aprovador_calculo.idcalculo_reciproci%TYPE
															,pr_cdoperad            VARCHAR2
		                          ) IS
      SELECT tpw.cdalcada_aprovacao
						,tdc.dscodigo
						,CASE 
							 WHEN (SELECT COUNT(1)
											 FROM tbrecip_aprovador_calculo tac
											WHERE tac.cdcooper            = tpw.cdcooper
												AND tac.cdalcada_aprovacao  = tpw.cdalcada_aprovacao
												AND tac.idcalculo_reciproci = pr_idcalculo_reciproci
												AND tac.idstatus            = 'A') > 0 THEN 
								 'Aprovado'
							 WHEN (SELECT COUNT(1)
											 FROM tbrecip_aprovador_calculo tac
											WHERE tac.cdcooper            = tpw.cdcooper
												AND tac.cdalcada_aprovacao  = tpw.cdalcada_aprovacao
												AND tac.idcalculo_reciproci = pr_idcalculo_reciproci
												AND tac.idstatus            = 'R') > 0 THEN
								 'Rejeitado'
							 ELSE
								 'Pendente'
						 END dsstatus
						,CASE
							 WHEN (SELECT COUNT(1)
											 FROM tbrecip_param_aprovador tpa
											WHERE tpa.cdcooper           = tpw.cdcooper
												AND tpa.cdalcada_aprovacao = tpw.cdalcada_aprovacao
												AND tpa.flativo            = 1 -- Ativo
												AND LOWER(tpa.cdaprovador) = LOWER(pr_cdoperad)) > 0 THEN
								 1 -- True
							 WHEN (SELECT COUNT(1)
											 FROM crapreg reg
											WHERE reg.cdcooper = tpw.cdcooper
												AND tpw.cdalcada_aprovacao = 1 -- Regional
												AND lower(reg.cdopereg) = LOWER(pr_cdoperad)) > 0 THEN
								 1 -- True
							 ELSE
								 0 -- False
						 END idaprovador
				FROM tbrecip_param_workflow tpw
						,tbcobran_dominio_campo tdc
			 WHERE tpw.cdalcada_aprovacao = tdc.cddominio
				 AND tdc.nmdominio          = 'IDALCADA_RECIPR'
				 AND tpw.flregra_aprovacao  = 1 -- Ativo
				 AND tpw.cdcooper           = pr_cdcooper;
		
		rw_alcada_aprovacao cr_alcada_aprovacao%ROWTYPE;
		
		-- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		
		-- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
		--
		vr_qtregistros NUMBER;
		vr_tab_dominios gene0010.typ_tab_dominio;
		-- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                            ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE
                            ) IS
    BEGIN
      --
      gene0002.pc_escreve_xml(vr_des_xml
                             ,vr_texto_completo
                             ,pr_des_dados
                             ,pr_fecha_xml
                             );
      --
    END;
		--
	BEGIN
		-- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADRES'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
		--
		BEGIN
			--
			SELECT COUNT(1)
			  INTO vr_qtregistros
			  FROM tbrecip_param_workflow tpw
			 WHERE tpw.cdcooper = pr_cdcooprt;
			--
		EXCEPTION
			WHEN OTHERS THEN
				vr_dscritic := 'Erro ao verificar se existe workflow: ' || SQLERRM;
				RAISE vr_exc_erro;
		END;
		-- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
		--
		OPEN cr_alcada_aprovacao(pr_cdcooprt
		                        ,pr_idcalculo_reciproci
														,vr_cdoperad
														);
		--
		pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
		--
		LOOP
			--
			FETCH cr_alcada_aprovacao INTO rw_alcada_aprovacao;
			EXIT WHEN cr_alcada_aprovacao%NOTFOUND;
			--
			pc_escreve_xml('<inf>'||
												'<cdalcada_aprovacao>' || rw_alcada_aprovacao.cdalcada_aprovacao || '</cdalcada_aprovacao>' ||
												'<dsalcada_aprovacao>' || rw_alcada_aprovacao.dscodigo           || '</dsalcada_aprovacao>' ||
												'<dsstatus_aprovacao>' || rw_alcada_aprovacao.dsstatus           || '</dsstatus_aprovacao>' ||
												'<idaprovador>'        || rw_alcada_aprovacao.idaprovador        || '</idaprovador>'        ||
										 '</inf>');
			--
		END LOOP;
		--
		IF cr_alcada_aprovacao%ROWCOUNT > 0 THEN
			--
			pc_escreve_xml('</dados></root>',TRUE);    
			--
			pr_retxml := XMLType.createXML(vr_des_xml);
			--
		ELSE
			--
			vr_dscritic := 'Nenhuma alcada encontrada para a cooperativa informada: ' || pr_cdcooprt;
      RAISE vr_exc_erro;
			--
		END IF;
		--
		CLOSE cr_alcada_aprovacao;
		--
		COMMIT;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
	END pc_busca_alcada_aprovacao;
	--
	PROCEDURE pc_aprova_contrato(pr_cdcooprt            IN  tbrecip_param_workflow.cdcooper%TYPE               -- Identificador da cooperativa
		                          ,pr_cdalcada_aprovacao  IN  tbrecip_param_workflow.cdalcada_aprovacao%TYPE     -- Código da alçada de aprovação
															,pr_idcalculo_reciproci IN  tbrecip_aprovador_calculo.idcalculo_reciproci%TYPE -- Identificador da flag de aprovação
															,pr_idstatus            IN  tbrecip_aprovador_calculo.idstatus%TYPE            -- Status enviado pelo aprovador
															,pr_dsjustificativa     IN  tbrecip_aprovador_calculo.dsjustificativa%TYPE     -- Justificativa da aprovação/rejeição
															,pr_xmllog              IN  VARCHAR2                                           -- XML com informações de LOG
															,pr_cdcritic            OUT PLS_INTEGER                                        -- Código da crítica
															,pr_dscritic            OUT VARCHAR2                                           -- Descrição da crítica
															,pr_retxml              IN OUT NOCOPY xmltype                                  -- Arquivo de retorno do XML
															,pr_nmdcampo            OUT VARCHAR2                                           -- Nome do campo com erro
															,pr_des_erro            OUT VARCHAR2                                           -- Erros do processo
		                          ) IS
		/* .............................................................................

    Programa: pc_aprova_contrato
    Sistema : Ayllos Web
    Autor   : Adriano Nagasava - Supero
    Data    : 16/07/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para realizar a aprovação de um determinado aprovador.

    Alteracoes: 
		
    ..............................................................................*/
		
		CURSOR cr_regional (pr_cdcooper crapage.cdcooper%TYPE
											 ,pr_cdoperad crapreg.cdopereg%TYPE
											 ,pr_cdagenci crapage.cdagenci%TYPE) IS
				SELECT r.dsdemail
							,r.cdopereg
					FROM crapage c
							,crapreg r 
				 WHERE c.cdcooper = r.cdcooper 
					 AND c.cddregio = r.cddregio 
					 AND c.cdcooper = pr_cdcooper 
					 AND c.cdagenci = pr_cdagenci
					 AND lower(r.cdopereg) = lower(pr_cdoperad);
		rw_regional cr_regional%ROWTYPE;
		
		CURSOR cr_valida_aprovador(pr_cdcooper           tbrecip_param_aprovador.cdcooper%TYPE
		                          ,pr_cdalcada_aprovacao tbrecip_param_aprovador.cdalcada_aprovacao%TYPE
															,pr_cdaprovador        tbrecip_param_aprovador.cdaprovador%TYPE
		                          ) IS
      SELECT tpa.cdaprovador
			      ,tpa.cdalcada_aprovacao
				FROM tbrecip_param_aprovador tpa
			 WHERE tpa.cdcooper           = pr_cdcooper
				 AND tpa.cdalcada_aprovacao = nvl(pr_cdalcada_aprovacao, tpa.cdalcada_aprovacao)
				 AND tpa.cdaprovador        = pr_cdaprovador
				 AND tpa.flativo            = 1 -- Ativo
				 ;
		
		rw_valida_aprovador cr_valida_aprovador%ROWTYPE;
		
		CURSOR cr_contratos(pr_cdcooper crapceb.cdcooper%TYPE
		                   ,pr_idrecipr crapceb.idrecipr%TYPE
		                   ) IS
      SELECT crapceb2.cdcooper
						,crapceb2.nrdconta
						,crapceb2.nrconven
						,crapceb2.nrcnvceb
						,crapceb2.idrecipr
						,crapceb2.insitceb
				FROM crapceb crapceb2
			 WHERE (crapceb2.cdcooper, crapceb2.nrdconta) IN (SELECT crapceb.cdcooper
																															,crapceb.nrdconta
																													FROM crapceb
																												 WHERE crapceb.cdcooper = pr_cdcooper
																													 AND crapceb.idrecipr = pr_idrecipr
																										 UNION ALL
																												SELECT crapceb.cdcooper
																															,crapceb.nrdconta
																													FROM tbcobran_crapceb crapceb
																												 WHERE crapceb.cdcooper = pr_cdcooper
																													 AND crapceb.idrecipr = pr_idrecipr)
				 AND crapceb2.insitceb IN(1, 3) -- 1 = Ativo / 3 = Pendente
			 UNION ALL
			SELECT crapceb2.cdcooper
						,crapceb2.nrdconta
						,crapceb2.nrconven
						,crapceb2.nrcnvceb
						,crapceb2.idrecipr
						,crapceb2.insitceb
				FROM tbcobran_crapceb crapceb2
			 WHERE (crapceb2.cdcooper, crapceb2.nrdconta) IN (SELECT crapceb.cdcooper
																															,crapceb.nrdconta
																													FROM tbcobran_crapceb crapceb
																												 WHERE crapceb.cdcooper = pr_cdcooper
																													 AND crapceb.idrecipr = pr_idrecipr)
				 AND crapceb2.insitceb IN(1, 3); -- 1 = Ativo / 3 = Pendente
		
		rw_contratos cr_contratos%ROWTYPE;
		
		CURSOR cr_agencia(pr_cdcooper crapceb.cdcooper%TYPE
		                 ,pr_idrecipr crapceb.idrecipr%TYPE) IS
										 
      SELECT ass.cdagenci
				FROM crapceb crapceb2
				    ,crapass ass
			 WHERE (crapceb2.cdcooper, crapceb2.nrdconta) IN (SELECT crapceb.cdcooper
																															,crapceb.nrdconta
																													FROM crapceb
																												 WHERE crapceb.cdcooper = pr_cdcooper
																													 AND crapceb.idrecipr = pr_idrecipr
																										 UNION ALL
																												SELECT crapceb.cdcooper
																															,crapceb.nrdconta
																													FROM tbcobran_crapceb crapceb
																												 WHERE crapceb.cdcooper = pr_cdcooper
																													 AND crapceb.idrecipr = pr_idrecipr)
         AND ass.cdcooper = crapceb2.cdcooper
				 AND ass.nrdconta = crapceb2.nrdconta
			 UNION ALL
			SELECT ass.cdagenci
				FROM tbcobran_crapceb crapceb2
				    ,crapass ass
			 WHERE (crapceb2.cdcooper, crapceb2.nrdconta) IN (SELECT crapceb.cdcooper
																															,crapceb.nrdconta
																													FROM tbcobran_crapceb crapceb
																												 WHERE crapceb.cdcooper = pr_cdcooper
																													 AND crapceb.idrecipr = pr_idrecipr)
         AND ass.cdcooper = crapceb2.cdcooper
				 AND ass.nrdconta = crapceb2.nrdconta;
		rw_agencia cr_agencia%ROWTYPE;
		
		-- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);
		
		-- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

		-- Tratamento de erros
		vr_exc_erro EXCEPTION;
		--
		vr_qtpendentes NUMBER;
		--
	BEGIN
		-- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADRES'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se a reciprocidade foi informada
    IF TRIM(pr_idcalculo_reciproci) IS NULL OR pr_idcalculo_reciproci = 0 THEN
        vr_dscritic := 'Contrato sem código de reciprocidade.';
    END IF;

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
		
		OPEN cr_agencia(pr_cdcooper => pr_cdcooprt
		               ,pr_idrecipr => pr_idcalculo_reciproci);
		FETCH cr_agencia INTO rw_agencia;
		--
		IF cr_agencia%NOTFOUND THEN
			CLOSE cr_agencia;
			vr_dscritic := 'Contrato invalido.';
			RAISE vr_exc_erro;
		END IF;
		--
		CLOSE cr_agencia;
		--
		IF pr_idstatus = 'R' THEN -- Aprovado
			--
			OPEN cr_regional(pr_cdcooper => pr_cdcooprt
											,pr_cdoperad => vr_cdoperad
											,pr_cdagenci => rw_agencia.cdagenci);
			FETCH cr_regional INTO rw_regional;
			--
			IF cr_regional%NOTFOUND THEN
				-- Valida se o usuário possui permissão de aprovador na alçada informada
				OPEN cr_valida_aprovador(pr_cdcooprt
																,pr_cdalcada_aprovacao
																,vr_cdoperad
																);
				--
				FETCH cr_valida_aprovador INTO rw_valida_aprovador;
				--
				IF cr_valida_aprovador%NOTFOUND THEN
					CLOSE cr_valida_aprovador;
          CLOSE cr_regional;
					vr_dscritic := 'O usuário não possui permissão de aprovador ou não pertence a regional do cooperado!';
					RAISE vr_exc_erro;
				END IF;
				CLOSE cr_valida_aprovador;
			END IF;
			CLOSE cr_regional;
		ELSE

			IF pr_cdalcada_aprovacao = 1 THEN
				OPEN cr_regional(pr_cdcooper => pr_cdcooprt
												,pr_cdoperad => vr_cdoperad
												,pr_cdagenci => rw_agencia.cdagenci);
				FETCH cr_regional INTO rw_regional;
				IF cr_regional%NOTFOUND THEN
					CLOSE cr_regional;
					vr_dscritic := 'O usuário não pertence a regional do cooperado!';
					RAISE vr_exc_erro;
				END IF;
				CLOSE cr_regional;
			ELSE
				-- Valida se o usuário possui permissão de aprovador na alçada informada
				OPEN cr_valida_aprovador(pr_cdcooprt
																,pr_cdalcada_aprovacao
																,vr_cdoperad);
				--
				FETCH cr_valida_aprovador INTO rw_valida_aprovador;
				--
				IF cr_valida_aprovador%ROWCOUNT = 0 THEN
					--
					vr_dscritic := 'O usuário não possui permissão de aprovador!';
					RAISE vr_exc_erro;
					--
				END IF;
				--
				CLOSE cr_valida_aprovador;
				--
			END IF;
		END IF;

		-- Verificacao do calendario
		OPEN BTCH0001.cr_crapdat(pr_cdcooprt);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;
		--
		BEGIN
			--
			INSERT INTO tbrecip_aprovador_calculo(cdcooper
			                                     ,cdalcada_aprovacao
																					 ,idcalculo_reciproci
																					 ,cdaprovador
																					 ,idstatus
																					 ,dtalteracao_status
																					 ,dsjustificativa
																					 ,cdoperador
																					 )
																		 VALUES(pr_cdcooprt
																		       ,nvl(pr_cdalcada_aprovacao, nvl(rw_valida_aprovador.cdalcada_aprovacao, 1))
																		       ,pr_idcalculo_reciproci
																					 ,vr_cdoperad
																					 ,pr_idstatus
																					 -- Colocado sysdate, pois é importante gravar o horário no qual ocorreu a aprovação
																					 ,SYSDATE -- rw_crapdat.dtmvtolt
																					 ,pr_dsjustificativa
																					 ,vr_cdoperad
																					 );
			--
		EXCEPTION
			WHEN OTHERS THEN
				vr_dscritic := 'Erro ao inserir na tbrecip_aprovador_calculo: ' || SQLERRM;
			  RAISE vr_exc_erro;
		END;
		--
		IF pr_idstatus = 'A' THEN -- Aprovado
			-- Verifica se foi realizado todas as aprovações
			BEGIN
				--
				SELECT COUNT(1)
				  INTO vr_qtpendentes
					FROM(SELECT tpw.cdalcada_aprovacao
										 ,tdc.dscodigo
										 ,CASE 
												WHEN (SELECT COUNT(1)
																FROM tbrecip_aprovador_calculo tac
															 WHERE tac.cdcooper            = tpw.cdcooper
																 AND tac.cdalcada_aprovacao  = tpw.cdalcada_aprovacao
																 AND tac.idcalculo_reciproci = pr_idcalculo_reciproci
																 AND tac.idstatus            = 'A') > 0 THEN 
													'Aprovado'
												WHEN (SELECT COUNT(1)
																FROM tbrecip_aprovador_calculo tac
															 WHERE tac.cdcooper            = tpw.cdcooper
																 AND tac.cdalcada_aprovacao  = tpw.cdalcada_aprovacao
																 AND tac.idcalculo_reciproci = pr_idcalculo_reciproci
																 AND tac.idstatus            = 'R') > 0 THEN
													'Rejeitado'
												ELSE
													'Pendente'
											END dsstatus
								 FROM tbrecip_param_workflow tpw
										 ,tbcobran_dominio_campo tdc
								WHERE tpw.cdalcada_aprovacao = tdc.cddominio
									AND tdc.nmdominio          = 'IDALCADA_RECIPR'
									AND tpw.flregra_aprovacao  = 1 -- Ativo
									AND tpw.cdcooper           = pr_cdcooprt
						 ORDER BY tpw.cdalcada_aprovacao) pendentes
				 WHERE pendentes.dsstatus <> 'Aprovado';
				--
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Erro ao validar se existem aprovações pendentes: ' || SQLERRM;
					RAISE vr_exc_erro;
			END;
			--
			IF vr_qtpendentes = 0 THEN
				--
				OPEN cr_contratos(pr_cdcooprt
												 ,pr_idcalculo_reciproci
												 );
				--
				LOOP
					--
					FETCH cr_contratos INTO rw_contratos;
					EXIT WHEN cr_contratos%NOTFOUND;
					-- Se contrato pendente
					IF rw_contratos.insitceb = 3 THEN
						--
						pc_ativa_contrato(pr_cdcooper => rw_contratos.cdcooper   -- IN
						                 ,pr_nrdconta => rw_contratos.nrdconta   -- IN
														 ,pr_nrconven => rw_contratos.nrconven   -- IN
														 ,pr_nrcnvceb => rw_contratos.nrcnvceb   -- IN
														 ,pr_idrecipr => rw_contratos.idrecipr   -- IN
														 ,pr_dtinicio => rw_crapdat.dtmvtolt + 1 -- IN
														 ,pr_cdcritic => vr_cdcritic             -- OUT
														 ,pr_dscritic => vr_dscritic             -- OUT
														 );
					-- Se contrato ativo
					ELSIF rw_contratos.insitceb = 1 THEN
						--
						pc_inativa_contrato(pr_cdcooper => rw_contratos.cdcooper -- IN
						                   ,pr_nrdconta => rw_contratos.nrdconta -- IN
															 ,pr_nrconven => rw_contratos.nrconven -- IN
															 ,pr_nrcnvceb => rw_contratos.nrcnvceb -- IN
															 ,pr_idrecipr => rw_contratos.idrecipr -- IN
															 ,pr_dtfim    => rw_crapdat.dtmvtolt   -- IN
															 ,pr_cdcritic => vr_cdcritic           -- OUT
															 ,pr_dscritic => vr_dscritic           -- OUT
															 );
						--
						IF vr_dscritic IS NOT NULL THEN
							--
							RAISE vr_exc_erro;
							--
						END IF;
						--
					END IF;
					--
				END LOOP;
				--
				IF cr_contratos%ROWCOUNT = 0 THEN
					--
					vr_dscritic := 'O contrato não foi encontrado!';
					RAISE vr_exc_erro;
					--
				END IF;
				--
				CLOSE cr_contratos;
				--
			END IF;
			--
      COMMIT;
      -- Envia os e-mails com a solicitação de aprovação para a próxima alçada se existir
      pc_envia_email_alcada(pr_cdcooper            => pr_cdcooprt
                           ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                           ,pr_cdcritic            => vr_cdcritic
                           ,pr_dscritic            => vr_dscritic
                           );
      --
      IF vr_dscritic IS NOT NULL THEN
        --
        RAISE vr_exc_erro;
        --
      END IF;
      --
		ELSE -- Rejeitado
			--
			pc_reprova_contrato(pr_cdcooper => pr_cdcooprt            -- IN
												 ,pr_idrecipr => pr_idcalculo_reciproci -- IN
												 ,pr_cdcritic => vr_cdcritic            -- OUT
												 ,pr_dscritic => vr_dscritic            -- OUT
												 );
			-- Verifica se houve erro na reprovação do contrato
			IF vr_dscritic IS NOT NULL THEN
				--
				RAISE vr_exc_erro;
				--
			END IF;
			--
		END IF;
		--

	EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
			ROLLBACK;
	END pc_aprova_contrato;
	--
  PROCEDURE pc_valida_alcada(pr_cdcooprt            IN  tbrecip_param_workflow.cdcooper%TYPE               -- Identificador da cooperativa
                            ,pr_xmllog              IN  VARCHAR2                                           -- XML com informações de LOG
                            ,pr_cdcritic            OUT PLS_INTEGER                                        -- Código da crítica
                            ,pr_dscritic            OUT VARCHAR2                                           -- Descrição da crítica
                            ,pr_retxml              IN OUT NOCOPY xmltype                                  -- Arquivo de retorno do XML
                            ,pr_nmdcampo            OUT VARCHAR2                                           -- Nome do campo com erro
                            ,pr_des_erro            OUT VARCHAR2                                           -- Erros do processo
                            ) IS
    /* .............................................................................

    Programa: pc_valida_alcada
    Sistema : Ayllos Web
    Autor   : Andre Clemer - Supero
    Data    : 23/08/2018                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para validar se existe alcada de aprovação.

    Alteracoes: 
    
    ..............................................................................*/
    
		CURSOR cr_alcada IS
      SELECT COUNT(1)
        FROM tbrecip_param_workflow tpw
            ,tbcobran_dominio_campo tdc
       WHERE tpw.cdalcada_aprovacao = tdc.cddominio
         AND tdc.nmdominio          = 'IDALCADA_RECIPR'
         AND tpw.flregra_aprovacao  = 1 -- Ativo
         AND tpw.cdcooper           = pr_cdcooprt
		ORDER BY tpw.cdalcada_aprovacao;
		
    rw_alcada cr_alcada%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    
    -- Variáveis gerais
    vr_qtalcada INTEGER;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    --
  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADRES'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
														);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
			--
      RAISE vr_exc_erro;
			--
    END IF;
    --
		OPEN cr_alcada;
    FETCH cr_alcada INTO vr_qtalcada;
    --
    CLOSE cr_alcada;
		--
    -- Comentado para não gerar erro na tela (removido a pedido dos usuarios)
    IF vr_qtalcada = 0 THEN
			--
			vr_dscritic := 'Nenhuma alcada encontrada. Verifique o cadastro e realize novamente a operacao.';
      RAISE vr_exc_erro;
			--
		END IF;
		--
  EXCEPTION
		WHEN vr_exc_erro THEN
			IF vr_cdcritic <> 0 THEN
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				--
			ELSE
				--
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;
				--
			END IF;
      --
      IF cr_alcada%ISOPEN THEN
         CLOSE cr_alcada;
      END IF;
			
			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
		WHEN OTHERS THEN
			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela CADRES: ' || SQLERRM;
      --
      IF cr_alcada%ISOPEN THEN
         CLOSE cr_alcada;
      END IF;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic ||
																		 '</Erro></Root>');
  END pc_valida_alcada;
  
  /* Trazer o cadastro de Regionais para PACs Modo Web */
  PROCEDURE pc_busca_qtd_regional(pr_cdcooprt IN crapcop.cdcooper%type -->Codigo Cooperativa
                                 ,pr_xmllog   IN VARCHAR2 DEFAULT NULL -->XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          -->Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             -->Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    -->Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             -->Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS         -->Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_busca_crapreg      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Andre Clemer (Supero)
    Data    : 30/11/2018                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Trazer o cadastro de Regionais para PACs modo Web

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/
  
   -- Verifica operadores das regionais da cooperativa
   CURSOR cr_crapope(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
     SELECT COUNT(1)
       FROM crapope
      WHERE crapope.cdcooper = pr_cdcooper
        AND crapope.cdsitope = 1
        AND crapope.cdoperad IN (SELECT crapreg.cdopereg
                                   FROM crapreg
                                  WHERE crapreg.cdcooper = pr_cdcooper);

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
       
    --Variaveis auxiliares
    vr_qtregist INTEGER := 0;
        
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      
      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Verificacao do calendario
      OPEN BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
            
      --Consultar Regionais Cadastradas
      OPEN cr_crapope(pr_cdcooper => pr_cdcooprt);
      FETCH cr_crapope INTO vr_qtregist;
      -- Fecha cursor
      CLOSE cr_crapope;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Dados'             --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_qtregist         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                 
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
                                          
      --Retorno
      pr_des_erro:= 'OK';    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na RREG0001.pc_busca_crapreg_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_busca_qtd_regional;
END TELA_CADRES;
/
