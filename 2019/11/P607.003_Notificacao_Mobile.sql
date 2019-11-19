DECLARE
    CURSOR cr_crapcop IS
        SELECT (nvl(MAX(cdmensagem), 0) + 1) cdmensagem FROM tbgen_notif_msg_cadastro;
    vr_cdmensagem tbgen_notif_msg_cadastro.cdmensagem%TYPE;

BEGIN

    OPEN cr_crapcop;
    FETCH cr_crapcop
        INTO vr_cdmensagem;

    IF cr_crapcop%NOTFOUND THEN
        dbms_output.put_line('Erro ao obter indice.');
        CLOSE cr_crapcop;
        RETURN;
    END IF;
    CLOSE cr_crapcop;

    INSERT INTO tbgen_notif_msg_cadastro
        (cdmensagem
        ,cdorigem_mensagem
        ,dstitulo_mensagem
        ,dstexto_mensagem
        ,dshtml_mensagem
        ,cdicone
        ,inexibir_banner
        ,nmimagem_banner
        ,inexibe_botao_acao_mobile
        ,dstexto_botao_acao_mobile
        ,cdmenu_acao_mobile
        ,dslink_acao_mobile
        ,dsmensagem_acao_mobile
        ,dsparam_acao_mobile
        ,inenviar_push)
    VALUES
        (vr_cdmensagem
        ,8
        ,'AilosPag - Pagamento recebido'
        ,'Você recebeu um pagamento. Clique e saiba mais.'
        ,'<p>#nomepagador pagou&nbsp;#valor para voc&ecirc;.</p>'
        ,14
        ,0
        ,NULL
        ,0
        ,NULL
        ,0
        ,NULL
        ,NULL
        ,NULL
        ,0);
		
		INSERT INTO tbgen_notif_automatica_prm
        (cdorigem_mensagem
        ,cdmotivo_mensagem
        ,dsmotivo_mensagem
        ,cdmensagem
        ,dsvariaveis_mensagem
        ,inmensagem_ativa
        ,intipo_repeticao
        ,nrdias_semana
        ,nrsemanas_repeticao
        ,nrdias_mes
        ,nrmeses_repeticao
        ,hrenvio_mensagem
        ,nmfuncao_contas
        ,dhultima_execucao)
    VALUES
        (8
        ,11
        ,'AilosPag - Pagamento recebido'
        ,vr_cdmensagem
        ,'<br/>#nomepagador - Nome completo do pagador (Ex.: JOÃO DA SILVA) <br/>#valor - Valor do pagamento (Ex.: 45,00)'
        ,1
        ,0
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL);		
		
		
	COMMIT;
END;
