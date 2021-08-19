-- BEGIN
  -- TBCADAST_CONFIG_FILTRO
  INSERT INTO CADASTRO.TBCADAST_CONFIG_FILTRO (DSFILTRO) VALUES ('idpessoa = :1');
  INSERT INTO CADASTRO.TBCADAST_CONFIG_FILTRO (DSFILTRO) VALUES ('idpessoa = (SELECT idpessoa_relacao  FROM tbcadast_pessoa_relacao WHERE tprelacao = 3  AND idpessoa = :1 )');
  INSERT INTO CADASTRO.TBCADAST_CONFIG_FILTRO (DSFILTRO) VALUES ('idpessoa = :1 AND nrddd = :2 AND nrtelefone = :3');
  INSERT INTO CADASTRO.TBCADAST_CONFIG_FILTRO (DSFILTRO) VALUES ('idpessoa = :1 AND dsemail = :2');
  INSERT INTO CADASTRO.TBCADAST_CONFIG_FILTRO (DSFILTRO) VALUES ('idpessoa = :1 AND tpendereco = :2');
  INSERT INTO CADASTRO.TBCADAST_CONFIG_FILTRO (DSFILTRO) VALUES ('idpessoa = (SELECT idpessoa_resp_legal FROM tbcadast_pessoa_fisica_resp WHERE idpessoa = :1 AND nrseq_resp_legal ....... ??? )');
  INSERT INTO CADASTRO.TBCADAST_CONFIG_FILTRO (DSFILTRO) VALUES ('idpessoa = (SELECT idpessoa_relacao FROM tbcadast_pessoa_relacao WHERE tprelacao = 1 AND idpessoa = :1 )');

  -- Procedimento atualizarRendimentoMdm
  INSERT INTO CADASTRO.TBCADAST_CONFIG_PROCEDIMENTO (NMPROCEDIMENTO, IDJSON_COMPLETO) VALUES ('atualizarRendimentoMdm', 0);
  
  -- Parâmetros do procedimento atualizarRendimentoMdm
  INSERT INTO CADASTRO.TBCADAST_CONFIG_PROCED_PARAM (idprocedimento, nmparametro, idtipo_parametro) VALUES (1, 'pr_idpessoa', 2);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_PROCED_PARAM (idprocedimento, nmparametro, idtipo_parametro) VALUES (1, 'pr_nmpessoa', 1);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_PROCED_PARAM (idprocedimento, nmparametro, idtipo_parametro) VALUES (1, 'pr_nrcpfcgc', 2);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_PROCED_PARAM (idprocedimento, nmparametro, idtipo_parametro) VALUES (1, 'pr_tppessoa', 2);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_PROCED_PARAM (idprocedimento, nmparametro, idtipo_parametro) VALUES (1, 'pr_inrendacomprovada', 2);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_PROCED_PARAM (idprocedimento, nmparametro, idtipo_parametro) VALUES (1, 'pr_cdcritic', 2);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_PROCED_PARAM (idprocedimento, nmparametro, idtipo_parametro) VALUES (1, 'pr_dscritic', 1);
  
  
  --  ## TBCADAST_CONFIG_ESTRUTURA
  -- pessoa
  INSERT ALL 
  INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA 
  (dsidentificador, dsinformacao, nrseq_execucao, idtipo_processo_upd, nmestrutura_upd, nmcampo_upd, idfiltro_upd, idtipo_campo, dsmask_campo )
  VALUES ('identificacao', 'situacaoCpfReceita', 10, 1, 'tbcadast_pessoa', 'cdsituacao_rfb', 1, 2, NULL)
  --
  INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA 
  (dsidentificador, dsinformacao, nrseq_execucao, idtipo_processo_upd, nmestrutura_upd, nmcampo_upd, idfiltro_upd, idtipo_campo, dsmask_campo )
  VALUES ('identificacao', 'dataConsultaCpfReceita', 10, 1, 'tbcadast_pessoa', 'dtconsulta_rfb', 1, 3, 'DD/MM/RRRR')
  --
  INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA 
  (dsidentificador, dsinformacao, nrseq_execucao, idtipo_processo_upd, nmestrutura_upd, nmcampo_upd, idfiltro_upd, idtipo_campo, dsmask_campo )
  VALUES ('identificacao', 'nomePessoa', 10, 1, 'tbcadast_pessoa', 'nmpessoa', 1, 1, NULL)
  --
  SELECT 1 FROM DUAL;
  
  -- pessoa física
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'nomeChamado', 10, 1, 'tbcadast_pessoa_fisica', 'nmsocial', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'genero', 10, 1, 'tbcadast_pessoa_fisica', 'tpsexo', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'naturalidade', 10, 1, 'tbcadast_pessoa_fisica', 'cdnaturalidade', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'dataNascimento', 10, 1, 'tbcadast_pessoa_fisica', 'dtnascimento', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'nacionalidade', 10, 1, 'tbcadast_pessoa_fisica', 'cdnacionalidade', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'tipoNacionalidade', 10, 1, 'tbcadast_pessoa_fisica', 'tpnacionalidade', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'cdTpEstadoCivil', 10, 1, 'tbcadast_pessoa_fisica', 'cdestado_civil', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'tipoDocumento', 10, 1, 'tbcadast_pessoa_fisica', 'tpdocumento', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'numeroDocumento', 10, 1, 'tbcadast_pessoa_fisica', 'nrdocumento', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'dataEmissao', 10, 1, 'tbcadast_pessoa_fisica', 'dtemissao_documento', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'cdOrgaoEmissor', 10, 1, 'tbcadast_pessoa_fisica', 'idorgao_expedidor', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'ufEmissor', 10, 1, 'tbcadast_pessoa_fisica', 'cduf_orgao_expedidor', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'cdTpPcd', 10, 1, 'tbcadast_pessoa_fisica', 'tppcd', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'cdTpNecessidadePcd', 10, 1, 'tbcadast_pessoa_fisica', 'tpnecessidadepcd', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('identificacao', 'cdCapacidadeCivil', 10, 1, 'tbcadast_pessoa_fisica', 'inhabilitacao_menor', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

  -- telefone
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('telefone', 'numeroTelefone', 10, 1, 'tbcadast_pessoa_telefone', 'nrtelefone', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('telefone', 'nrddd', 10, 1, 'tbcadast_pessoa_telefone', 'nrndd', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('telefone', 'tipoTelefone', 10, 1, 'tbcadast_pessoa_telefone', 'tptelefone', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('telefone', 'aceitaWhatsApp', 10, 1, 'tbcadast_pessoa_telefone', 'inwhatsap', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('telefone', 'nmContato', 10, 1, 'tbcadast_pessoa_telefone', 'nmpessoa_contato', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

  -- email
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('email', 'enderecoEmail', 10, 1, 'tbcadast_pessoa_email', 'dsemail', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

  -- endereço
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('endereco', 'logradouro', 10, 1, 'tbcadast_pessoa_endereco', 'nmlogradouro', 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('endereco', 'numero', 10, 1, 'tbcadast_pessoa_endereco', 'nrlogradouro', 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('endereco', 'cep', 10, 1, 'tbcadast_pessoa_endereco', 'nrcep', 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('endereco', 'tipoEndereco', 10, 1, 'tbcadast_pessoa_endereco', 'tpendereco', 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('endereco', 'tipoResidencia', 10, 1, 'tbcadast_pessoa_endereco', 'tpimovel', 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('endereco', 'complemento', 10, 1, 'tbcadast_pessoa_endereco', 'dscomplemento', 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('endereco', 'bairro', 10, 1, 'tbcadast_pessoa_endereco', 'nmbairro', 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('endereco', 'cidade', 10, 1, 'tbcadast_pessoa_endereco', 'idcidade', 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  
  -- Infomação Profissional - Renda
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('informacaoProfissional', 'rendaPrincipal', 20, 1, 'Tbcadast_Pessoa_Renda', 'vlrenda', 6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('informacaoProfissional', 'ocupacaoProfissional', 20, 1, 'Tbcadast_Pessoa_Renda', 'cdocupacao', 6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('informacaoProfissional', 'tipoContratoTrabalho', 20, 1, 'Tbcadast_Pessoa_Renda', 'tpcontrato_trabalho', 6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('informacaoProfissional', 'dataAdmissao', 20, 1, 'Tbcadast_Pessoa_Renda', 'dtadmissao', 6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('informacaoProfissional', 'turno', 20, 1, 'Tbcadast_Pessoa_Renda', 'cdturno', 6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('informacaoProfissional', 'tipoComprovacaoRenda', 20, 1, 'Tbcadast_Pessoa_Renda', 'tpcomprov_renda', 6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  
  -- Infomação Profissional - Renda -- POR PROCEDURE
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('informacaoProfissional', 'cargo (crapttl.dsproftl)', 2, 'tbcadast_pessoa_fisica', 'dsprofissao', NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('informacaoProfissional', 'naturezaOcupacao', 2, 'tbcadast_pessoa_fisica', 'cdnatureza_ocupacao', NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  
  -- fatca
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('fatca', 'nif', 10, 1, 'tbcadast_pessoa_estrangeira', 'nridentificacao', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('fatca', 'flDomicilioObrigacaoFiscal', 10, 1, 'tbcadast_pessoa_estrangeira', 'inobrigacao_exterior', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  INSERT INTO CADASTRO.TBCADAST_CONFIG_ESTRUTURA VALUES ('fatca', 'cdPaisObrigacaoFiscal', 10, 1, 'tbcadast_pessoa_estrangeira', 'cdpais', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  
  
  
  


/*  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERRO AO EXECUTAR SCRIPT: ' || SQLERRM);
    ROLLBACK;
END;*/
