/*!
 * FONTE        : conta_corrente_pf.js
 * CRIAÇÃO      : Gabriel (RKAM)
 * DATA CRIAÇÃO : 08/09/2015 
 * OBJETIVO     : Biblioteca de funções na rotina CONTA CORRENTE PF da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ 

function acessaOpcaoAbaDados(nrOpcoes,id,opcao) {

	var urlScript = UrlSite + "telas/cadcta/";
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
			arr_guias_contacorrente[i] =  true;		
			$('#linkAba'   + id).attr('class','txtBrancoBold');
			$('#imgAbaCen' + id).css('background-color','#969FA9');
			continue;			
		}
			
		if (arr_guias_contacorrente[i] ) {
			$('#linkAba'   + i).attr('class','txtNormalBold'); //txtNormalBold
			$('#imgAbaCen' + i).css('background-color','#C6C8CA');
			
		}
	}
	
	// Tratamento para chamada de cada "Rotina"
	switch (id) {
		case 0: {
			nmdireto = "conta_corrente";
			nmrotina = "Conta Corrente";
			break;
		}
		case 1: {
			nmdireto  = "cliente_financeiro";
			nmrotina  = "Cliente Financeiro";
			nmdfonte = "cliente_financeiro.php";
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
			url: UrlSite + 'telas/cadcta/' + nmdireto + '/' + nmdfonte,
			data: {
				nrdconta: nrdconta,
				idseqttl: idseqttl,
				inpessoa: inpessoa,
				nmdatela: "CADCTA",
				nmrotina: nmrotina,
				flgcadas: flgcadas,
				redirect: 'script_ajax'
			},		
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			},
			success: function(response) {
				if ( response.indexOf('showError("error"') == -1 ) {
					
					if (id == 0) {						
						$('#divConteudoOpcao').css('width','600px'); 	
					} else if (id == 1) {
						$('#divConteudoOpcao').css('height','330px'); 	
					}
					
					$('#divConteudoOpcao').html(response);   		
				} else {
					eval( response );
				}
				return false;
			}				 
		});
	
	});
	
}