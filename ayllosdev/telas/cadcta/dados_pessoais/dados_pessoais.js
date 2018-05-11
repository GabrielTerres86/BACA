/*!
 * FONTE        : dados_pessoais.js
 * CRIAÇÃO      : Gabriel (RKAM)
 * DATA CRIAÇÃO : 01/09/2015 
 * OBJETIVO     : Biblioteca de funções na rotina Dados Pessoais da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 26/10/2017 - Replicado fonte da tela CONTAS para a tela CADCTA PRJ339 - CRM (Odirlei-AMcom)
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
	for (var i = 0; i <= nrOpcoes; i++) {
		if ($('#linkAba' + id).length == false) {
			continue;
		}
				
		if (id == i) { // Atribui estilos para foco da opção	
			arr_guias_dadosp[i] =  true;		
			$('#linkAba'   + id).attr('class','txtBrancoBold');
			$('#imgAbaCen' + id).css('background-color','#969FA9');
			continue;			
		}
			
		if (arr_guias_dadosp[i] || flgcadas != 'M') { // Se ja passou por esta rotina, cor cinza senao vermelho (Quando vem da MATRIC)
			$('#linkAba'   + i).attr('class','txtNormalBold'); //txtNormalBold
			$('#imgAbaCen' + i).css('background-color','#C6C8CA');
			
		} else {
			$('#linkAba'   + i).attr('class','txtBrancoBold'); //txtNormalBold
			$('#imgAbaCen' + i).css('background-color','#EE0000');	
		}
	}
	
	// Tratamento para chamada de cada "Rotina"
	switch (id) {
		case 0: {
			nmdireto = "identificacao_fisica";
			nmrotina = "Identificacao";
			break;
		}
		case 1: {
			nmdireto  = "comercial";
			nmrotina  = "Comercial";			
			break;	
		}	
	} 
		 	
	chamaPrincipal(urlScript,nmdireto,nmrotina,nmdfonte,id,opcao);	
	
}

function chamaPrincipal (urlScript,nmdireto,nmrotina,nmdfonte,id,opcao) {
				
	$.getScript(urlScript + nmdireto + "/" + nmdireto + ".js",function() {

		// Carrega conteúdo da opção através do Ajax
		$.ajax({		
			type: 'POST', 
			dataType: 'html',
			url: UrlSite + 'telas/cadcta/' + nmdireto + '/' + nmdfonte,
			data: {
				nrdconta: nrdconta,
				idseqttl: idseqttl,
				nmdatela: "CADCTA",
				nmrotina: nmrotina,
				flgcadas: flgcadas,
				opeaction: opcao,
				redirect: 'script_ajax'
			},		
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			},
			success: function(response) {
				if ( response.indexOf('showError("error"') == -1 ) {
							
					
				    $('#divConteudoOpcao').html(response);   // Limpar tela e colocar somente novo conteudo
					
					$('#divRotina').css('width','590px');
                    $('#divConteudoOpcao').css('width','580px');
					
								
				} else {
					eval( response );
				}
				return false;
			}				 
		});
	
	});
	
}

function botoesPessoasRelacionamento () {

	var div_botoes = '<div id="divBotoes">';
	
	if (flgcadas == 'M') {
		div_botoes += '<input type="image" id="btVoltar"    src="' + UrlImagens + 'botoes/voltar.gif"  onClick="acessaOpcaoAbaDados(6,0,\'@\'); return false;" />';
	} else {
		div_botoes += '<input type="image" id="btVoltar"    src="' + UrlImagens + 'botoes/voltar.gif"  onClick="encerraRotina(); return false;" />';
	}
	
	div_botoes += '<input type="image" id="btContinuar" style="margin-left:5px;" src="' + UrlImagens + 'botoes/continuar.gif" onClick="acessaOpcaoAbaDados(6,6,\'@\'); return false" />';

	div_botoes += '</div>';
	
	$('#divConteudoOpcao').append(div_botoes);
}	