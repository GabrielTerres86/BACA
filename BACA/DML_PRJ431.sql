-- Comandos DML referente ao PRJ431
BEGIN
    -- ---------------------------------
    -- Inserts dos domínios da cobrança
    -- ---------------------------------

    -- Floating
    INSERT INTO tbcobran_dominio_campo
        (nmdominio, cddominio, dscodigo)
    VALUES
        ('TPFLOATING_RECIPR', '1', '1');
    INSERT INTO tbcobran_dominio_campo
        (nmdominio, cddominio, dscodigo)
    VALUES
        ('TPFLOATING_RECIPR', '2', '2');
    INSERT INTO tbcobran_dominio_campo
        (nmdominio, cddominio, dscodigo)
    VALUES
        ('TPFLOATING_RECIPR', '3', '3');
    INSERT INTO tbcobran_dominio_campo
        (nmdominio, cddominio, dscodigo)
    VALUES
        ('TPFLOATING_RECIPR', '4', '4');
    INSERT INTO tbcobran_dominio_campo
        (nmdominio, cddominio, dscodigo)
    VALUES
        ('TPFLOATING_RECIPR', '5', '5');

    -- Prazo de meses
    INSERT INTO tbcobran_dominio_campo (nmdominio, cddominio, dscodigo) VALUES ('TPMESES_RECIPRO', '3', '3');
    INSERT INTO tbcobran_dominio_campo (nmdominio, cddominio, dscodigo) VALUES ('TPMESES_RECIPRO', '6', '6');
    INSERT INTO tbcobran_dominio_campo (nmdominio, cddominio, dscodigo) VALUES ('TPMESES_RECIPRO', '9', '9');
    INSERT INTO tbcobran_dominio_campo
        (nmdominio, cddominio, dscodigo)
    VALUES
        ('TPMESES_RECIPRO', '12', '12');

    -- Vinculação
    INSERT INTO tbcobran_dominio_campo
        (nmdominio, cddominio, dscodigo)
    VALUES
        ('TPVINCULACAO_RECIPR', '4', 'Baixíssima');
    INSERT INTO tbcobran_dominio_campo
        (nmdominio, cddominio, dscodigo)
    VALUES
        ('TPVINCULACAO_RECIPR', '3', 'Baixa');
    INSERT INTO tbcobran_dominio_campo
        (nmdominio, cddominio, dscodigo)
    VALUES
        ('TPVINCULACAO_RECIPR', '2', 'Média');
    INSERT INTO tbcobran_dominio_campo
        (nmdominio, cddominio, dscodigo)
    VALUES
        ('TPVINCULACAO_RECIPR', '1', 'Boa');

    -- Alçadas de Aprovação
    INSERT INTO tbcobran_dominio_campo
        (nmdominio, cddominio, dscodigo)
    VALUES
        ('IDALCADA_RECIPR', '1', 'Coordenação Regional');
    INSERT INTO tbcobran_dominio_campo
        (nmdominio, cddominio, dscodigo)
    VALUES
        ('IDALCADA_RECIPR', '2', 'Sede - Área de Negócios');
    INSERT INTO tbcobran_dominio_campo
        (nmdominio, cddominio, dscodigo)
    VALUES
        ('IDALCADA_RECIPR', '3', 'Diretoria');

    -- ------------------------
    -- Inserts das novas ações
    -- ------------------------
    INSERT INTO craprdr (nmprogra, dtsolici) VALUES ('TELA_CADRES', SYSDATE);

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('BUSCA_WORKFLOW'
        ,'TELA_CADRES'
        ,'pc_busca_workflow'
        ,'pr_cdcooper'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('INSERE_APROVADOR'
        ,'TELA_CADRES'
        ,'pc_insere_aprovador'
        ,'pr_cdcooper,pr_cdalcada_aprovacao,pr_cdaprovador,pr_dsemail_aprovador'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('EXCLUIR_APROVADOR'
        ,'TELA_CADRES'
        ,'pc_exclui_aprovador'
        ,'pr_cdcooper,pr_cdalcada_aprovacao,pr_cdaprovador'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('BUSCA_APROVADORES'
        ,'TELA_CADRES'
        ,'pc_busca_aprovadores'
        ,'pr_cdcooper,pr_cdalcada_aprovacao,pr_cdaprovador'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('BUSCA_OPERADORES'
        ,'TELA_CADRES'
        ,'pc_busca_operadores'
        ,'pr_cdcooper,pr_cdoperad,pr_nmoperad,pr_nriniseq,pr_nrregist'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('ATUALIZA_ALCADA'
        ,'TELA_CADRES'
        ,'pc_atualiza_alcada'
        ,'pr_cdcooper,pr_cdalcada_aprovacao,pr_flregra_aprovacao'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('BUSCA_ALCADA_APROVACAO'
        ,'TELA_CADRES'
        ,'pc_busca_alcada_aprovacao'
        ,'pr_cdcooper,pr_idcalculo_reciproci'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('APROVA_CONTRATO'
        ,'TELA_CADRES'
        ,'pc_aprova_contrato'
        ,'pr_cdcooper,pr_cdalcada_aprovacao,pr_idcalculo_reciproci,pr_idstatus,pr_dsjustificativa'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('VALIDA_ALCADA'
        ,'TELA_CADRES'
        ,'pc_valida_alcada'
        ,'pr_cdcooper'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES'));

    UPDATE crapaca
       SET lstparam = 'pr_cdcooper,pr_idindica,pr_cdprodut,pr_inpessoa,pr_vlminimo,pr_vlmaximo,pr_perscore,pr_pertoler,pr_perpeso,pr_perdesc'
     WHERE nmpackag = 'TELA_PARIDR'
       AND nmdeacao = 'INSERE_PAR_IND';

    UPDATE crapaca
       SET lstparam = 'pr_cdcooper,pr_idindica,pr_cdprodut,pr_inpessoa,pr_vlminimo,pr_vlmaximo,pr_perscore,pr_pertoler,pr_perpeso,pr_perdesc'
     WHERE nmpackag = 'TELA_PARIDR'
       AND nmdeacao = 'ALTERA_PAR_IND';

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('BUSCA_VINCULACOES'
        ,'TELA_CADIDR'
        ,'pc_obtem_vinculacoes'
        ,NULL
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADIDR'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('BUSCA_IDVINCULACAO'
        ,'TELA_CADIDR'
        ,'pc_obtem_idvinculacao'
        ,NULL
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADIDR'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('INSERE_VINCULACAO'
        ,'TELA_CADIDR'
        ,'pc_insere_vinculacao'
        ,'pr_idvinculacao,pr_nmvinculacao,pr_flgativo'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADIDR'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('ALTERA_VINCULACAO'
        ,'TELA_CADIDR'
        ,'pc_altera_vinculacao'
        ,'pr_idvinculacao,pr_nmvinculacao,pr_flgativo'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADIDR'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('EXCLUI_VINCULACAO'
        ,'TELA_CADIDR'
        ,'pc_exclui_vinculacao'
        ,'pr_idvinculacao'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADIDR'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('OBTEM_VINCULACAO'
        ,'TELA_PARIDR'
        ,'pc_obtem_vinculacoes'
        ,'pr_cdcooper'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_PARIDR'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('PESQUISA_VINCULACOES'
        ,'TELA_PARIDR'
        ,'pc_pesquisa_vinculacoes'
        ,'pr_nmvinculacao'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_PARIDR'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('INSERE_PAR_VINCULACAO'
        ,'TELA_PARIDR'
        ,'pc_insere_param_vinculacao'
        ,'pr_cdcooper,pr_idvinculacao,pr_cdprodut,pr_inpessoa,pr_perpeso,pr_perdesc'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_PARIDR'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('ALTERA_PAR_VINCULACAO'
        ,'TELA_PARIDR'
        ,'pc_altera_param_vinculacao'
        ,'pr_cdcooper,pr_idvinculacao,pr_cdprodut,pr_inpessoa,pr_perpeso,pr_perdesc'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_PARIDR'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('EXCLUI_PAR_VINCULACAO'
        ,'TELA_PARIDR'
        ,'pc_exclui_param_vinculacao'
        ,'pr_cdcooper,pr_idvinculacao,pr_cdprodut,pr_inpessoa'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_PARIDR'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('VALIDA_VINCULACAO'
        ,'TELA_PARIDR'
        ,'pc_valida_vinculacao'
        ,'pr_idvinculacao'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_PARIDR'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('BUSCA_DOMINIO'
        ,'TELA_ATENDA_COBRAN'
        ,'pc_busca_dominio'
        ,'pr_nmdominio'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_COBRAN'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('BUSCA_CONTRATOS_ATENDA'
        ,'TELA_ATENDA_COBRAN'
        ,'pc_busca_contratos'
        ,'pr_cdcooper, pr_nrdconta'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_COBRAN'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('BUSCA_CONVENIOS_DESCONTO'
        ,'TELA_ATENDA_COBRAN'
        ,'pc_conv_recip_desc'
        ,'pr_cdcooper, pr_nrdconta'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_COBRAN'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('CARREGA_LOG_NEGO'
        ,'TELA_ATENDA_COBRAN'
        ,'pc_consulta_log_negoc_web'
        ,'pr_idrecipr'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_COBRAN'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('BUSCA_VINCULACAO'
        ,'TELA_ATENDA_COBRAN'
        ,'fn_busca_vinculacao'
        ,'pr_nrdconta'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_COBRAN'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('CANCELA_DESCONTO'
        ,'TELA_ATENDA_COBRAN'
        ,'pc_cancela_descontos'
        ,'pr_idrecipr'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_COBRAN'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('CONSULTA_DESCONTO'
        ,'TELA_ATENDA_COBRAN'
        ,'pc_consulta_descontos'
        ,'pr_idcalculo_reciproci,pr_cdcooper,pr_nrdconta'
        ,(SELECT nrseqrdr FROM craprdr r WHERE r.nmprogra = 'TELA_ATENDA_COBRAN'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('INCLUI_DESCONTO'
        ,'TELA_ATENDA_COBRAN'
        ,'pc_inclui_descontos'
        ,'pr_cdcooper,pr_nrdconta,pr_ls_convenios,pr_boletos_liquidados,pr_volume_liquidacao,pr_qtdfloat,pr_vlaplicacoes,pr_vldeposito,pr_dtfimcontrato,pr_flgdebito_reversao,pr_vldesconto_coo,pr_dtfimadicional_coo,pr_vldesconto_cee,pr_dtfimadicional_cee,pr_txtjustificativa,pr_idvinculacao,pr_perdesconto,pr_vldescontoconcedido_coo,pr_vldescontoconcedido_cee'
        ,(SELECT nrseqrdr FROM craprdr r WHERE r.nmprogra = 'TELA_ATENDA_COBRAN'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('ALTERA_DESCONTO'
        ,'TELA_ATENDA_COBRAN'
        ,'pc_altera_descontos'
        ,'pr_idcalculo_reciproci,pr_cdcooper,pr_nrdconta,pr_ls_convenios,pr_boletos_liquidados,pr_volume_liquidacao,pr_qtdfloat,pr_vlaplicacoes,pr_vldeposito,pr_dtfimcontrato,pr_flgdebito_reversao,pr_vldesconto_coo,pr_dtfimadicional_coo,pr_vldesconto_cee,pr_dtfimadicional_cee,pr_txtjustificativa,pr_idvinculacao,pr_perdesconto,pr_vldescontoconcedido_coo,pr_vldescontoconcedido_cee'
        ,(SELECT nrseqrdr FROM craprdr r WHERE r.nmprogra = 'TELA_ATENDA_COBRAN'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('BUSCA_OPERADORES_REG'
        ,'TELA_ATENDA_COBRAN'
        ,'pc_busca_operadores_reg'
        ,'pr_nmoperad,pr_nriniseq,pr_nrregist'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_COBRAN'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('VALIDA_EXCLUSAO_CONVENIO'
        ,'TELA_ATENDA_COBRAN'
        ,'pc_valida_exclusao_conven'
        ,'pr_nrdconta,pr_nrconven,pr_idrecipr'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_COBRAN'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('BUSCA_CODIGO_BARRAS'
        ,'TELA_COBRAN'
        ,'pc_consulta_cod_barras_web'
        ,'pr_dtvencto,pr_cdbandoc,pr_vltitulo,pr_nrcnvcob,pr_nrdconta,pr_nrdocmto'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBRAN'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('GERA_SMS_CSV'
        ,'COBR0005'
        ,'pc_relat_anali_envio_csv_web'
        ,'pr_nrdconta,pr_dtiniper,pr_dtfimper,pr_dsiduser,pr_instatus'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBRAN'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('IMPTERMO_RECIPROCI'
        ,'sspc0002'
        ,'pc_imprimir_termo_reciproci'
        ,'pr_nrdconta, pr_nmdtest1, pr_cpftest1, pr_nmdtest2, pr_cpftest2, pr_idcalculo_reciproci, pr_tpimpres'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'SSPC0002'));

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('CALCULA_RECIPROCIDADE'
        ,'TELA_SIMCRP'
        ,'pc_calcula_reciprocidade'
        ,'pr_cdcooper,pr_ls_nrconvenio,pr_qtboletos_liquidados,pr_vlliquidados,pr_idfloating,pr_idvinculacao,pr_vlaplicacoes,pr_vldeposito,pr_idcoo,pr_idcee'
        ,(SELECT nrseqrdr FROM craprdr WHERE craprdr.nmprogra = 'SIMCRP'));

    UPDATE crapaca
       SET lstparam = 'pr_idparame_reciproci,pr_configrp,pr_vinculacoesrp,pr_vldescontomax_coo,pr_vldescontomax_cee,pr_cdcooper'
     WHERE nmdeacao = 'CONFIRMA_CONF'
       AND nmpackag = 'TELA_CONFRP';

    UPDATE crapaca
       SET nmproced = 'pc_habilita_convenio_web'
     WHERE nmdeacao = 'HABILITA_CONVENIO'
       AND nmpackag = 'TELA_ATENDA_COBRAN';

    BEGIN
        INSERT INTO crapaca
            (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
        VALUES
            ('CARREGA_LOG_CONV'
            ,'TELA_ATENDA_COBRAN'
            ,'pc_consulta_log_conv_web'
            ,'pr_idrecipr'
            ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_COBRAN'));
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE crapaca
               SET lstparam = 'pr_idrecipr'
             WHERE nmdeacao = 'CARREGA_LOG_CONV'
               AND nmpackag = 'TELA_ATENDA_COBRAN';
    END;

    -- ------------------------------------------
    -- Inclusão dos indicadores da reciprocidade
    -- ------------------------------------------

    INSERT INTO tbrecip_indicador
        (idindicador, nmindicador, dsindicador, tpindicador, flgativo)
    VALUES
        ((SELECT MAX(tbrecip_indicador.idindicador) + 1 FROM tbrecip_indicador)
        ,'Quantidade de Floating'
        ,'É o valor com a quantidade do floating da reciprocidade.'
        ,'Q'
        ,1);

    INSERT INTO tbrecip_indicador
        (idindicador, nmindicador, dsindicador, tpindicador, flgativo)
    VALUES
        ((SELECT MAX(tbrecip_indicador.idindicador) + 1 FROM tbrecip_indicador)
        ,'Valor de Investimento'
        ,'É a quantidade de aplicação do cooperado na reciprocidade.'
        ,'Q'
        ,1);

    INSERT INTO tbrecip_indicador
        (idindicador, nmindicador, dsindicador, tpindicador, flgativo)
    VALUES
        ((SELECT MAX(tbrecip_indicador.idindicador) + 1 FROM tbrecip_indicador)
        ,'Valor de Depósito à Vista'
        ,'É a quantidade de depósito à vista do cooperado na reciprocidade.'
        ,'Q'
        ,1);

    -- ------------------------------------------
    -- Inclusão das vinculações da reciprocidade
    -- ------------------------------------------

    INSERT INTO tbrecip_vinculacao (idvinculacao, nmvinculacao, flgativo) VALUES (1, 'Boa', 1);
    INSERT INTO tbrecip_vinculacao (idvinculacao, nmvinculacao, flgativo) VALUES (2, 'Média', 1);
    INSERT INTO tbrecip_vinculacao (idvinculacao, nmvinculacao, flgativo) VALUES (3, 'Baixa', 1);
    INSERT INTO tbrecip_vinculacao (idvinculacao, nmvinculacao, flgativo) VALUES (4, 'Baixíssima', 1);

    -- ------------------
    -- Insert na CRAPPRM
    -- ------------------

    INSERT INTO crapprm
        (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES
        ('CRED', 0, 'DT_VIG_RECECIPR_V2', 'Data de vigencia do novo modelo de reciprocidade.', trunc(SYSDATE));

    INSERT INTO crapprm
        (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES
        ('CRED'
        ,16
        ,'RECIPROCIDADE_PILOTO'
        ,'Ativar/Desativar nova reciprocidade para cooperativa. (0 - desativada e 1 - ativada)'
        ,1);

    -- ------------------
    -- Usuarios liberados para acesso à CADRES
    -- ------------------

    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', '@', 'f0030636', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'I', 'f0030636', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'A', 'f0030636', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'C', 'f0030636', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'E', 'f0030636', ' ', 1, 1, 0, 2);

    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', '@', 'f0031411', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'I', 'f0031411', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'A', 'f0031411', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'C', 'f0031411', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'E', 'f0031411', ' ', 1, 1, 0, 2);

    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', '@', 'f0030497', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'I', 'f0030497', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'A', 'f0030497', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'C', 'f0030497', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'E', 'f0030497', ' ', 1, 1, 0, 2);

    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', '@', 'f0030598', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'I', 'f0030598', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'A', 'f0030598', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'C', 'f0030598', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'E', 'f0030598', ' ', 1, 1, 0, 2);

    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', '@', 'f0030215', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'I', 'f0030215', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'A', 'f0030215', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'C', 'f0030215', ' ', 1, 1, 0, 2);
    INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
    VALUES
        ('CADRES', 'E', 'f0030215', ' ', 1, 1, 0, 2);

    -- -------------------
    -- Inserts na CRAPTEL
    -- -------------------
    INSERT INTO craptel
        (nmdatela
        ,nrmodulo
        ,cdopptel
        ,tldatela
        ,tlrestel
        ,flgteldf
        ,flgtelbl
        ,nmrotina
        ,lsopptel
        ,inacesso
        ,cdcooper
        ,idsistem
        ,idevento
        ,nrordrot
        ,nrdnivel
        ,nmrotpai
        ,idambtel)
    VALUES
        ('ATENDA'
        ,'5'
        ,'@,C,H,X'
        ,'Cadastro de Cobranca'
        ,'Reciprocidade'
        ,'0'
        ,'1'
        ,'RECIPROCIDADE'
        ,'ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO'
        ,'2'
        ,'16'
        ,'1'
        ,'0'
        ,'20'
        ,'1'
        ,' '
        ,'2');

    UPDATE craptel a
       SET a.nrdnivel = 0
     WHERE a.nmdatela = 'ATENDA'
       AND a.nmrotina = 'COBRANCA'
       AND a.cdcooper = 16;

    -- ----------------
    -- Quickwins
    -- ----------------

    INSERT INTO crapaca
        (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
        ('GERA_REMESSA_CNAB240'
        ,'TELA_COBRAN'
        ,'pc_gera_arq_remes_cnab240_web'
        ,'pr_nrdconta,pr_flgregis,pr_tipo_consulta,pr_consulta,pr_inestcri,pr_ini_documento,pr_fim_documento'
        ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'COBRAN'));

    -- ----------------
    -- Demais scripts
    -- ----------------

    UPDATE crapcat SET fldesman = 1;

	COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Erro: ' || SQLERRM);
        ROLLBACK;
END;