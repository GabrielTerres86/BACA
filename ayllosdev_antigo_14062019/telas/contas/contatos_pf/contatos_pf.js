/*!
 * FONTE        : contatos_pf.js
 * CRIAÇÃO      : Gabriel (RKAM)
 * DATA CRIAÇÃO : 08/09/2015 
 * OBJETIVO     : Biblioteca de funções na rotina Contatos PF da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ 

function acessaOpcaoAbaDados(nrOpcoes,id,opcao) {

	var urlScript = UrlSite + "telas/contas/";
	var nmdireto  = "";
	var nmrotina  = "";
	var nmdfonte  = "principal.php"; 

	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando...');
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if ($('#linkAba' + id).length == false) {
			continue;
		}
		
		if (id == i) { // Atribui estilos para foco da opção			
			$('#linkAba'   + id).attr('class','txtBrancoBold');
			$('#imgAbaEsq' + id).attr('src',UrlImagens + 'background/mnu_sle.gif');				
			$('#imgAbaDir' + id).attr('src',UrlImagens + 'background/mnu_sld.gif');
			$('#imgAbaCen' + id).css('background-color','#969FA9');
			continue;			
		}
		
		$('#linkAba'   + i).attr('class','txtNormalBold');
		$('#imgAbaEsq' + i).attr('src',UrlImagens + 'background/mnu_nle.gif');			
		$('#imgAbaDir' + i).attr('src',UrlImagens + 'background/mnu_nld.gif');
		$('#imgAbaCen' + i).css('background-color','#C6C8CA');
	}
	
	// Tratamento para chamada de cada "Rotina"
	switch (id) {
		case 0: {
			nmdireto = "endereco";
			nmrotina = "Endereco";
			break;
		}
		case 1: {
			nmdireto  = "telefones";
			nmrotina  = "Telefones";
			break;
		}
		case 2: {
			nmdireto = "emails";
			nmrotina = "E_mails";
			break;
		}	
	} 
		 	
	chamaPrincipal(urlScript,nmdireto,nmrotina,nmdfonte,id);	
	
}

function chamaPrincipal (urlScript,nmdireto,nmrotina,nmdfonte,id) {
		
	$.getScript(urlScript + nmdireto + "/" + nmdireto + ".js",function() {

		// Carrega conteúdo da opção através do Ajax
		$.ajax({		
			type: 'POST', 
			dataType: 'html',
			url: UrlSite + 'telas/contas/' + nmdireto + '/' + nmdfonte,
			data: {
				nrdconta: nrdconta,
				idseqttl: idseqttl,
				nmdatela: "CONTAS",
				nmrotina: nmrotina,
				flgcadas: flgcadas,
				redirect: 'script_ajax'
			},		
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
			},
			success: function(response) {
				if ( response.indexOf('showError("error"') == -1 ) {
							
					$('#divConteudoOpcao').html(response);   // Limpar tela e colocar somente novo conteudo
					
					if (id == 0) {
						$('#divConteudoOpcao').css('height','auto');
					}
													
				} else {
					eval( response );
				}
				return false;
			}				 
		});
	
	});
	
}
