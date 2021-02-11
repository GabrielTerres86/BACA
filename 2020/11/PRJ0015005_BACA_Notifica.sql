begin

  update TBGEN_NOTIF_MSG_CADASTRO a
	set a.CDMENU_ACAO_MOBILE = 400
	where a.cdorigem_mensagem = 13
	and a.CDMENU_ACAO_MOBILE in (401,402); 

  commit;

end;