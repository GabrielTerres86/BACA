/*!
 * FONTE        : fatca_crs_pf.js
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : Abril/2018 
 * OBJETIVO     : Biblioteca de funções da rotina FATCA/CRS da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Definindo variáveis globais
var nomeForm = "frmDadosFatcaCrs";
var flgContinuar = false;
var nrcpfcgc = normalizaNumero(cpfprocu);

// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes,id,opcao) {  
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando...");
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da opção
			$("#linkAba" + id).attr("class","txtBrancoBold");
			$("#imgAbaEsq" + id).attr("src",UrlImagens + "background/mnu_sle.gif");				
			$("#imgAbaDir" + id).attr("src",UrlImagens + "background/mnu_sld.gif");
			$("#imgAbaCen" + id).css("background-color","#969FA9");
			continue;			
		}
		
		$("#linkAba" + i).attr("class","txtNormalBold");
		$("#imgAbaEsq" + i).attr("src",UrlImagens + "background/mnu_nle.gif");			
		$("#imgAbaDir" + i).attr("src",UrlImagens + "background/mnu_nld.gif");
		$("#imgAbaCen" + i).css("background-color","#C6C8CA");
	}

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/contas/fatca_crs_pf/principal.php",
		data: {
			nrcpfcgc: nrcpfcgc,
			flgcadas: flgcadas,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',bloqueiaFundo(divRotina));
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
			} else {
				eval( response );				
			}
			return false;
		}				
	});
		
}

function controlaOperacao(operacao) {

	if( !verificaSemaforo() && operacao != 'CA' ) { return false; }

	// Verifica permissões de acesso
	if ( (operacao == 'CA') && (flgAlterar != '1') ) { 
		showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Aimaro','semaforo--;bloqueiaFundo(divRotina);');
		return false;
	} 
		
	// Mostra mensagem de aguardo
	var msgOperacao = '';
	switch (operacao) {			
		// Consulta para Alteração
		case 'CA': 
			msgOperacao = 'abrindo altera&ccedil;&atilde;o';
			break;
		// Alteração para Consulta - Cancelando Operação
		case 'AC': 
			showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','semaforo--;controlaOperacao()','semaforo--;bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;	
		// Alteração para Validação - Validando Alteração
		case 'AV': 
			manterRotina(operacao);
			return false;
			break;	
		// Validação para Alteração - Salvando Alteração
		case 'VA': 
			manterRotina(operacao);
			return false;
			break;				
		// Qualquer outro Valor: Abrindo tela em modo Consulta
		default: 
			msgOperacao = 'abrindo tela';
			break;			
	}
	
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/fatca_crs_pf/principal.php', 
		data: {
			nrcpfcgc: nrcpfcgc,
			flgcadas: flgcadas,
			operacao: operacao,
			redirect: "html_ajax"
		},  
		error: function(objAjax,responseError,objExcept) {
			semaforo--;
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			semaforo--;
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
			} else {
				eval( response );
				controlaFoco( operacao );
			}
			return false;	
		}				
	});			
}

function manterRotina(operacao) {
	semaforo--;
	hideMsgAguardo();	
	
	var msgOperacao = '';
	switch (operacao) {	
		case 'VA': msgOperacao = 'salvando altera&ccedil;&atilde;o'; break;
		case 'AV': msgOperacao = 'validando altera&ccedil;&atilde;o'; break;										
		default: return false; break;
	}
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	var inobrigacao_exterior = $('#inobrigacao_exterior','#' + nomeForm ).val();
	var cdpais 				 = $('#cdpais','#' + nomeForm ).val();
	var nridentificacao      = $('#nridentificacao','#' + nomeForm ).val();		
	var cdpais_exterior      = $('#cdpais_exterior','#' + nomeForm ).val();	
	var dscodigo_postal      = $('#dscodigo_postal','#' + nomeForm ).val();
	var nmlogradouro 		 = $('#nmlogradouro','#' + nomeForm ).val();
	var nrlogradouro 		 = $('#nrlogradouro','#' + nomeForm ).val();
	var dscomplemento 		 = $('#dscomplemento','#' + nomeForm ).val();
	var dscidade 	         = $('#dscidade','#' + nomeForm ).val();
	var dsestado 	         = $('#dsestado','#' + nomeForm ).val();
	var insocio 			 = 'N';
	var inacordo 			 = $('#inacordo', '#'+nomeForm).val();
			
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/fatca_crs_pf/manter_rotina.php', 		
		data: {
			nrcpfcgc: 			  nrcpfcgc,
			inobrigacao_exterior: inobrigacao_exterior,
			cdpais:     		  cdpais,
			nridentificacao:      nridentificacao,
			cdpais_exterior:      cdpais_exterior,
			dscodigo_postal:      dscodigo_postal,
            nmlogradouro: 		  nmlogradouro,
            nrlogradouro: 		  nrlogradouro,
            dscomplemento: 		  dscomplemento,
            dscidade: 	          dscidade,
            dsestado: 	          dsestado,
            operacao: 			  operacao,
            insocio: 			  insocio,
            inacordo:             inacordo,
            nrdconta: 			  nrdconta,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				
				eval(response);
				
				if  (operacao == 'VA' && (flgcadas == 'M' || flgContinuar)) {
					proximaRotina();
				}
				
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

function controlaLayout() {	
	
	var rInobrigacao_exterior = $('label[for="inobrigacao_exterior"]', '#'+nomeForm);	
	var rCdpais     		  = $('label[for="cdpais"]', '#'+nomeForm);
	var rNridentificacao      = $('label[for="nridentificacao"]', '#'+nomeForm);	
	var rCdpais_exterior      = $('label[for="cdpais_exterior"]', '#'+nomeForm);
	var rDscodigo_postal      = $('label[for="dscodigo_postal"]', '#'+nomeForm);
	var rNmlogradouro   	  = $('label[for="nmlogradouro"]', '#'+nomeForm);
	var rNrlogradouro   	  = $('label[for="nrlogradouro"]', '#'+nomeForm);
	var rDscomplemento   	  = $('label[for="dscomplemento"]', '#'+nomeForm);
	var rDscidade             = $('label[for="dscidade"]', '#'+nomeForm);
	var rDsestado	          = $('label[for="dsestado"]', '#'+nomeForm);

	var cInobrigacao_exterior = $('#inobrigacao_exterior,', '#'+nomeForm);
	var cCdpais   		      = $('#cdpais,', '#'+nomeForm);
	var cDspais 		      = $('#dspais,', '#'+nomeForm);
	var cNridentificacao      = $('#nridentificacao,', '#'+nomeForm);
	var cCdpais_exterior      = $('#cdpais_exterior,', '#'+nomeForm);
	var cDspais_exterior      = $('#dspais_exterior,', '#'+nomeForm);
	var cDscodigo_postal      = $('#dscodigo_postal,', '#'+nomeForm);
	var cNmlogradouro         = $('#nmlogradouro,', '#'+nomeForm);
	var cNrlogradouro   	  = $('#nrlogradouro,', '#'+nomeForm);
	var cDscomplemento   	  = $('#dscomplemento,', '#'+nomeForm);
	var cDscidade             = $('#dscidade,', '#'+nomeForm);
	var cDsestado             = $('#dsestado,', '#'+nomeForm);

	var cTodos    = $('input, select', '#'+nomeForm);
	var cEndereco = $('input, select', '#fsetEndereco');
	var inacordo  = $('#inacordo', '#'+nomeForm).val();

	$('#divConteudoOpcao').hide(0, function() {

		// Controla a altura da tela		
		$('#divConteudoOpcao').css('width','570px');
		$('#divRotina').css('width','570px');		
		$('#frmDadosFatcaCrs').css({'padding-top':'5px'});
		
		// Formatação dos rotulos
		rInobrigacao_exterior.addClass('rotulo').css('width','500px');
		rCdpais.addClass('rotulo').css('width','350px');
		rNridentificacao.addClass('rotulo').css('width','350px');
		rCdpais_exterior.addClass('rotulo').css('width','337px');
		rDscodigo_postal.addClass('rotulo').css('width','60px');
		rNmlogradouro.addClass('rotulo-linha').css('width','30px');
		rNrlogradouro.addClass('rotulo-linha').css('width','20px');
		rDscomplemento.addClass('rotulo').css('width','60px');
		rDscidade.addClass('rotulo').css('width','60px');
		rDsestado.addClass('rotulo-linha').css('width','50px');
		
		// Formatação dos campos
		cInobrigacao_exterior.css('width','50px');
		cCdpais.addClass('alphanum').css('width','35px');
		cDspais.css('width','142px');
		cNridentificacao.css('width','200px').attr('maxlength','30');
		cCdpais_exterior.addClass('alphanum').css('width','35px');
		cDspais_exterior.css('width','142px');
		cDscodigo_postal.css('width','80px');
		cNmlogradouro.addClass('alphanum').css('width','290px');
		cNrlogradouro.addClass('numerocasa').css('width','45px');
		cDscomplemento.addClass('alphanum').css('width','477px');
		cDscidade.addClass('alphanum').css('width','230px');
		cDsestado.addClass('alphanum').css('width','191px');

		// No inicio desabilita todos os campos
		cTodos.desabilitaCampo();

		if (operacao == 'CA') {
			cInobrigacao_exterior.habilitaCampo();
		}

		if (operacao == 'CA' && cInobrigacao_exterior.val() == 'S') {
			cCdpais.habilitaCampo();
		}

		if (operacao == 'CA' && cInobrigacao_exterior.val() == 'S') {
			cNridentificacao.habilitaCampo().removeAttr('tabindex');
			cCdpais_exterior.habilitaCampo().removeAttr('tabindex');
			cDscodigo_postal.habilitaCampo().removeAttr('tabindex');
			cNmlogradouro.habilitaCampo().removeAttr('tabindex');
			cNrlogradouro.habilitaCampo().removeAttr('tabindex');
			cDscomplemento.habilitaCampo().removeAttr('tabindex');
			cDscidade.habilitaCampo().removeAttr('tabindex');
			cDsestado.habilitaCampo().removeAttr('tabindex');
		} else {
			cNridentificacao.desabilitaCampo();
			cCdpais_exterior.desabilitaCampo();
		}

		/*if (operacao == 'CA' && (inacordo != 'FATCA' && inacordo != 'CRS')) {
			cNridentificacao.val('');
			cCdpais_exterior.val('');
			cDspais_exterior.val('');
			cEndereco.val('');
		}*/

		cInobrigacao_exterior.unbind('change').bind('change', function(){
			if ( $(this).val() == 'N' ) {
				// desabilitar e limpar todos os campos, exceto inobrigacao_exterior
				cTodos.not('#inobrigacao_exterior', '#frmDadosFatcaCrs')
					  .desabilitaCampo()
					  .val('')
					  .removeAttr('selected');
			} else if ( $(this).val() == 'S') {
				cCdpais.habilitaCampo().removeAttr('tabindex');
			}
			return false;
		});
		
		controlaPesquisas();
		layoutPadrao();
		controlaFocoEnter("frmDadosFatcaCrs");
		hideMsgAguardo();
		bloqueiaFundo(divRotina);	
		$(this).fadeIn(1000);
		divRotina.centralizaRotinaH(); 
	});	
	
	return false;	
}

function controlaPesquisas() {

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var filtrosPesq, filtrosDesc, colunas;
	
	/*-------------------------------------*/
	/*       CONTROLE DAS PESQUISAS        */
	/*-------------------------------------*/
	
	// Atribui a classe lupa para os links e desabilita todos
	$('a','#'+nomeForm).addClass('lupa').css('cursor','auto');	
	
	// Percorrendo todos os links
	$('a','#'+nomeForm).each( function() {
		
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
		
		$(this).click( function() {
		
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');
				
				//Remove a classe de Erro do form
				$('input,select', '#'+nomeForm).removeClass('campoErro');
				
				// Nr. Conta do Cônjuge
				if ( campoAnterior == 'cdpais' ) {
					
					filtrosPesq	= 'Cód. País;cdpais;30px;S;|País;dspais;200px;S;|Países FATCA/CRS;inacordo;30px;S;S';
					colunas 	= 'Código;cdpais;20%;right|País;nmpais;80%;left';
					mostraPesquisa("TELA_FATCA_CRS", "BUSCA_PAISES", "Pais", "30", filtrosPesq, colunas, divRotina);
					return false;
				} else if ( campoAnterior == 'cdpais_exterior' ) {
					
					filtrosPesq	= 'Cód. País;cdpais_exterior;30px;S;|País;dspais_exterior;200px;S;|Países FATCA/CRS;inacordo;30px;S;';
					colunas 	= 'Código;cdpais;20%;right|País;nmpais;80%;left';
					mostraPesquisa("TELA_FATCA_CRS", "BUSCA_PAISES", "Pais", "30", filtrosPesq, colunas, divRotina);
					return false;
				}					
			}
			return false;		
		});
	});
	
	/*-------------------------------------*/
	/*   CONTROLE DAS BUSCA DESCRIÇÕES     */
	/*-------------------------------------*/
	
	// Pais
	$('#cdpais','#'+nomeForm).unbind('change').bind('change',function() {
		
		filtrosDesc = '';
        buscaDescricao("TELA_FATCA_CRS", "VALIDA_PAIS", "País", $(this).attr('name'), 'dspais', $(this).val(), 'nmpais', filtrosDesc, nomeForm);
        if ($(this).val() != '') {
        	validaPais('cdpais');
        }
		return false;

	});

	$('#cdpais_exterior','#'+nomeForm).unbind('change').bind('change',function() {
		
		filtrosDesc = '';
        buscaDescricao("TELA_FATCA_CRS", "VALIDA_PAIS", "País", 'cdpais', 'dspais_exterior', $(this).val(), 'nmpais', filtrosDesc, nomeForm);
        if ($(this).val() != '') {
        	validaPais('cdpais_exterior');
        }
		return false;

	});
}

function controlaContinuar () {
	
	flgContinuar = true;
		
	if ($("#btAlterar","#divBotoes").length > 0) {
		proximaRotina();
	} else {
		controlaOperacao('AV');
	}
	
}

function voltarRotina() {
    fechaRotina(divRotina);
	
	acessaRotina('COMERCIAL', 'COMERCIAL', 'comercial_pf');
}

function proximaRotina () {
		
	hideMsgAguardo();
	encerraRotina(false);

	acessaRotina('CONTA CORRENTE','Conta Corrente','conta_corrente_pf');		
}

function validaPais(campo){

	var cdpais = $('#cdpais','#' + nomeForm ).val();
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/fatca_crs_pf/valida_pais.php', 
		data: {
			cdpais: cdpais,
			redirect: "html_ajax"
		},  
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
                hideMsgAguardo();
                eval(response);
                
                controlaLayout();

                if(campo == 'cdpais'){
                	$('#nridentificacao').focus();        			
                } else if (campo == 'cdpais_exterior') {
                	$('#dscodigo_postal').focus();
                }

            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#tpdrend2','#frmManipulaRendimentos').focus()");
            }	
		}				
	});	
}
