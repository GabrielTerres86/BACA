DECLARE

  -- Busca cooperados demitidos
  cursor cr_tab_resumo is
  select tbevento_grupos.*
    from (select pes.cdcooper
               , pes.cdagenci
               , pes.nrdgrupo
               , count(1) agrupado
               , (select grp.qtd_membros
                    from tbevento_grupos grp
                   where grp.cdcooper = pes.cdcooper
                     and grp.cdagenci = pes.cdagenci
                     and grp.nrdgrupo = pes.nrdgrupo) resumido
            from tbevento_pessoa_grupos pes
           group
              by pes.cdcooper
               , pes.cdagenci
               , pes.nrdgrupo
           order
              by pes.cdcooper
               , pes.cdagenci
               , pes.nrdgrupo) tbevento_grupos
 where tbevento_grupos.agrupado <> tbevento_grupos.resumido;
       
BEGIN
  -- aca para a opcao consultar opcao N
  BEGIN
    INSERT INTO crapaca 
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr
    )VALUES(
    'CONSULTA_OPCAO_N'
    ,'TELA_CADGRP'
    ,'pc_cursor_opcao_n'
    ,''
    ,1565);  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20001,'Erro ao inserir crapaca CONSULTA_OPCAO_N '||SQLERRM);    
  END;
  -- aca para o botao analisar 
  BEGIN
    INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr
    )VALUES(
    'ANALISAR_PENDENCIAS'
    ,'TELA_CADGRP'
    ,'pc_analisar_notificacao_web'
    ,'pr_nmdgrupo'
    ,1565);  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20001,'Erro ao inserir crapaca ANALISAR_PENDENCIAS '||SQLERRM);    
  END;  
  -- Aca para inserir a criacao de banner
  BEGIN
    INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr
    )VALUES(
    'CRIAR_BANNER_CADGRP'
    ,'TELA_CADGRP'
    ,'pc_criar_banner'
    ,'pr_cdcooper, pr_cdagenci, pr_nrdgrupo, pr_nmimagem_banner'
    ,1565);   
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20001,'Erro ao inserir crapaca CRIAR_BANNER_CADGRP '||SQLERRM);    
  END; 
  --
  BEGIN
    INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr
    )VALUES(
    'LIMPAR_PENDENCIAS'
    ,'TELA_CADGRP'
    ,'pc_limpar_opcao_n'
    ,'pr_nmdgrupo'
    ,1565);   
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20001,'Erro ao inserir crapaca LIMPAR_PENDENCIAS '||SQLERRM);    
  END; 
  --
  BEGIN
    INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr
    )VALUES(
    'LIMPAR_BANNERS'
    ,'TELA_CADGRP'
    ,'pc_limpar_banner_n'
    ,'pr_nmdgrupo'
    ,1565);   
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20001,'Erro ao inserir crapaca LIMPAR_PENDENCIAS '||SQLERRM);    
  END; 
  --
  BEGIN
    INSERT INTO tbgen_notif_msg_cadastro
    (CDMENSAGEM
    ,CDORIGEM_MENSAGEM
    ,DSTITULO_MENSAGEM
    ,DSTEXTO_MENSAGEM
    ,DSHTML_MENSAGEM
    ,CDICONE
    ,INEXIBIR_BANNER
    ,NMIMAGEM_BANNER
    ,INEXIBE_BOTAO_ACAO_MOBILE
    ,DSTEXTO_BOTAO_ACAO_MOBILE
    ,CDMENU_ACAO_MOBILE
    ,DSLINK_ACAO_MOBILE
    ,DSMENSAGEM_ACAO_MOBILE
    ,DSPARAM_ACAO_MOBILE
    ,INENVIAR_PUSH
    )VALUES(
    (SELECT (MAX(CDMENSAGEM)+1) FROM tbgen_notif_msg_cadastro)
	,11
	,'Assembleias 2020'
	,'Dia #data às #horario , #local , #endereco , #cidade'
    ,'<p>Ficou mais f&aacute;cil votar nas nossas Assembleias: o evento realizado na sua regi&atilde;o agora tem poder de decis&atilde;o. Venha, conhe&ccedil;a os resultados de 2019 e decida os pr&oacute;ximos passos da sua Cooperativa. Juntos vamos sempre mais longe.</p>
<p><strong>Dia:</strong> #data<br />
<strong>Hora:</strong> #horario<br />
<strong>Local:</strong> #local<br />
<strong>Endere&ccedil;o:</strong> #endereco - #cidade</p>
<p>Essa &eacute; a data exclusiva para voce votar nas decis&otilde;es da Cooperativa.</p>
<p><strong>Obs: </strong><strong>Se voc&ecirc; tiver alguma d&uacute;vida entre em contato conosco pelo SAC 0800 647 2200.</strong></p>
<p>Aguardamos voc&ecirc; ;)</p>'
    ,11
    ,1
    ,'assembleias_2019_viacredi.jpg'
    ,1
    ,'Saiba mais'
    ,NULL
    ,'http://www.aquivoceparticipa.coop.br/'
    ,'Você será redirecionado para fora do app.'
    ,NULL
    ,1);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20001,'Erro ao inserir tbgen_notif_msg_cadastro '||SQLERRM);    
  END; 
  --
  BEGIN
    INSERT INTO tbgen_notif_automatica_prm 
    (CDORIGEM_MENSAGEM
    ,CDMOTIVO_MENSAGEM
    ,DSMOTIVO_MENSAGEM
    ,CDMENSAGEM
    ,DSVARIAVEIS_MENSAGEM
    ,INMENSAGEM_ATIVA
    ,INTIPO_REPETICAO
    ,NRDIAS_SEMANA
    ,NRSEMANAS_REPETICAO
    ,NRDIAS_MES
    ,NRMESES_REPETICAO
    ,HRENVIO_MENSAGEM
    ,NMFUNCAO_CONTAS
    ,DHULTIMA_EXECUCAO
    )VALUES(
	11
	,3
	,'Agendamento para envio automático'
	,(SELECT MAX(CDMENSAGEM) FROM tbgen_notif_msg_cadastro)
	,'<br/>#data  - Data do evento (Ex: 20/02) <br/>#horario - Horário do evento (Ex: 19:00)<br/>#local - Local do evento (Ex: Vila Germânica)<br/>#endereco - Endereço do Evento (Ex: Rua XV de Novembro, 500)<br/>#cidade - Cidade do evento (Ex: Blumenau)'
	,1
	,1
	,'1,2,3,4,5,6,7'
	,'1,2,3,4,5,6'
	,NULL
	,NULL
	,30000
	,'AGRP0001.fn_busca_grupos_notifica'
	,NULL);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20001,'Erro ao inserir tbgen_notif_automatica_prm '||SQLERRM);    
  END;
  --
  BEGIN
    UPDATE tbevento_grupos c
       SET c.flgnotificacao = 0
         , c.cdbanner = 0;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20001,'Erro ao inserir tbevento_grupos '||SQLERRM);    
  END;
  -- Busca cooperados sem grupo
  FOR rw_tab_resumo IN cr_tab_resumo LOOP
    BEGIN
      --
      UPDATE tbevento_grupos c
         SET c.qtd_membros = rw_tab_resumo.agrupado
       WHERE c.cdcooper = rw_tab_resumo.cdcooper
         AND c.cdagenci = rw_tab_resumo.cdagenci
         AND c.nrdgrupo = rw_tab_resumo.nrdgrupo;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20001,'Erro ao atualizar tbevento_grupos '||SQLERRM);    
    END;
  END LOOP;
  --
  BEGIN
    INSERT INTO crapprm 
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
    VALUES 
    ('CRED'
    ,0
    ,'CDORIGEM_MENSAGEM_484'
    ,'Código de origem para envio de notificacoes e pushes.'
    ,11);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20001,'Erro ao inserir crapaca CDORIGEM_MENSAGEM_484 '||SQLERRM);    
  END; 
  --
  BEGIN
    UPDATE craptel c
       SET c.cdopptel = 'B,C,E,G,P,N,I'
         , c.lsopptel = 'BUSCAR GRUPO,CONSULTAR COOPERADO,EDITAL ASSEMBLEIA,MANUTENCAO GRUPOS,PARAMETRIZACAO FRACAO,OPERACOES NOT E BANNERS,INSERIR BANNERS'
     WHERE c.nmdatela = 'CADGRP';
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20001,'Erro ao inserir crapaca craptel '||SQLERRM);    
  END; 
  --
  COMMIT;
  --
END;
 

