/***********************************************************************
      Fonte: pacote_tarifas.js
      Autor: Lucas Lombardi
      Data : Marco/2016                &Uacute;ltima Altera&ccedil;&atilde;o: 00/00/0000

      Objetivo  : Biblioteca de fun&ccedil;&otilde;es da rotina Pacote Tarifas da tela
                  ATENDA

      Altera&ccedil;&otilde;es:
	  25/07/2016 - Adicionado função controlaFoco.(Evandro - RKAM).	 

      30/10/2018 - Merge Changeset 26538 referente ao P435 - Tarifas Avulsas (Peter - Supero) 

 ***********************************************************************/
// Variaveis para consulta do pacote de tarifas
var glb_cdpacote = 0, glb_dspacote, glb_dtinicio_vigencia, glb_dtcancelamento, glb_dtdiadebito, glb_perdesconto_manual, glb_qtdmeses_desconto, glb_cdreciprocidade, glb_dtass_eletronica, glb_dtadesao, glb_flgsituacao;
 
// Fun&ccedil;&atilde;o para acessar op&ccedil;&otilde;es da rotina
function acessaOpcaoAba(nrOpcoes,id,opcao) {
	glb_cdpacote = 0;
	if (opcao == "0") {	// Op&ccedil;&atilde;o Principal
		var msg = "servi&ccedil;os cooperativos";
	}
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando " + msg + " ...");
	
	// Atribui cor de destaque para aba da op&ccedil;&atilde;o
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da op&ccedil;&atilde;o
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
		url: UrlSite + "telas/atenda/pacote_tarifas/principal.php",
		data: {
			nrdconta: nrdconta,
			nrregist: 20,
			nrinireg: 0,
			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
					hideMsgAguardo();
					$('#divConteudoOpcao').html(response);
					formataTelaPrincipal();
                    controlaFoco();					
				} else {
					eval(response);
				}
			return false;
		}				
	}); 		
}

//Função para controle de navegação
 function controlaFoco() { 
	$('#divConteudoOpcao').each(function () {
		$(this).find("#divBotoes > a").addClass("FluxoNavega");
		$(this).find("#divBotoes > a").first().addClass("FirstInputModal").focus();
		$(this).find("#divBotoes > a").last().addClass("LastInputModal");
	}); 		
	
	//Se estiver com foco na classe FluxoNavega
    $(".FluxoNavega").focus(function(){		 
		$(this).bind('keydown', function(e) {
		  if(e.keyCode == 13) {
			$(this).click();
}
		});
	});
	
	//Se estiver com foco na classe LastInputModal
    $(".LastInputModal").focus(function(){
		var pressedShift = false; 

		$(this).bind('keyup', function(e) {
			if(e.keyCode == 16) {
			   pressedShift=false;//Quando tecla shift for solta passa valor false 
			} 
		})
		 
		$(this).bind('keydown', function(e) { 
		  e.stopPropagation();
		  e.preventDefault();
		  
		  if(e.keyCode == 13) {
			$(".LastInputModal").click();
		  }
		  if(e.keyCode == 16) {
				pressedShift = true;//Quando tecla shift for pressionada passa valor true 
		  } 
		  if((e.keyCode == 9) && pressedShift == true) {
				return setFocusCampo($(target), e, false, 0);
		  } 
		  else if(e.keyCode == 9){
			  $(".FirstInputModal").focus();	
		  } 
		});
	});
	
	$(".FirstInputModal").focus();
}

function formataTelaPrincipal(){
	$('#divConteudoOpcao').css('display','block');	
		
	divRotina.css('width','645px');	
	$('#divConteudoOpcao').css({'height':'245px','width':'645px'});	
		
	// tabela	
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'180px','padding-bottom':'2px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,1]];
			
	var arrayLargura = new Array();
	arrayLargura[0] = '78px';
	arrayLargura[1] = '340px';
	arrayLargura[2] = '106px';
	arrayLargura[3] = '94px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '');
	
	$('table > tbody > tr:eq(0)', divRegistro).click();
	
	layoutPadrao();	
	
	$('input','#divRegistros').trigger('blur');	
	
    // seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		glb_cdpacote           = $(this).find('#hd_cdpacote').val();
		glb_dspacote           = $(this).find('#hd_dspacote').val();
		glb_dtinicio_vigencia  = $(this).find('#hd_dtinicio_vigencia').val();
		glb_dtcancelamento     = $(this).find('#hd_dtcancelamento').val();
		glb_dtadesao           = $(this).find('#hd_dtadesao').val();
		glb_dtdiadebito        = $(this).find('#hd_dtdiadebito').val();
		glb_perdesconto_manual = $(this).find('#hd_perdesconto_manual').val();
		glb_qtdmeses_desconto  = $(this).find('#hd_qtdmeses_desconto').val();
		glb_cdreciprocidade    = $(this).find('#hd_cdreciprocidade').val();
		glb_dtass_eletronica   = $(this).find('#hd_dtass_eletronica').val();
		glb_flgsituacao        = $(this).find('#hd_flgsituacao').val();
	});
	  
	$('table > tbody > tr:eq(0)', divRegistro).click();
		
	hideMsgAguardo();
	removeOpacidade('divRegistros');
	divRotina.centralizaRotinaH();
	bloqueiaFundo(divRotina);
}

function formataTelaAlteraDebito() {
	altura = '100px';
	
	largura = '200px';
	
	$('#divConteudoOpcao').css('display','none');
	
	divRotina = $('#divRotina');
	
	$('input, select','#frmAlteraDebito').removeClass('campoErro');
	
	cDtdiadebito = $('#dtdiadebito','#frmAlteraDebito');
	
	rDtdiadebito = $('label[for="dtdiadebito"]','#frmAlteraDebito');
	
	cDtdiadebito.addClass('campo').css('width','45px');
	
	rDtdiadebito.addClass('rotulo').css('width','100px');
	
	cDtdiadebito.val(glb_dtdiadebito);
	
	$('input','#frmAlteraDebito').trigger('blur');
		
	divRotina.css('width',largura);	
	$('#divConteudoOpcao').css({'height':altura,'width':largura});

	layoutPadrao();
	hideMsgAguardo();
	removeOpacidade('divConteudoOpcao');
	divRotina.setCenterPosition();
	bloqueiaFundo(divRotina);
	
	$('#dtdiadebito','#frmAlteraDebito').focus();
	
	$('#dtdiadebito','#frmAlteraDebito').unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9 ) {
			$('#btConfirmar','#divBotoes').focus();
			return false;
}
	});

}

function formataTelaImprimir() {
	altura = '30px';
	
	var nrlargura = 700;
	
	if (glb_cdreciprocidade == 0)
		nrlargura -= 300;
	
	if (glb_flgsituacao.toUpperCase() == 'ATIVO')
		nrlargura -= 150;
	
	largura = nrlargura + 'px';
 	
	//largura = '100px';
	
	$('#divConteudoOpcao').css('display','none');
	
	
	divRotina.css('width',largura);	
	divRotina = $('#divRotina');
	$('#divConteudoOpcao').css({'height':altura,'width':largura});

	hideMsgAguardo();
	removeOpacidade('divConteudoOpcao');
	divRotina.setCenterPosition();
	bloqueiaFundo(divRotina);
	layoutPadrao();
}

function formataTelaPacote(opcao) {
	
	if (opcao.toUpperCase() == 'C')
		altura = '200px';
	else
		altura = '150px';
	
	largura = '530px';
	
	//$('input', '#frmConsultaPacote').limpaFormulario();
	$('#divConteudoOpcao').css('display','none');
	
	divRotina = $('#divRotina');
	
	$('input, select','#frmConsultaPacote').removeClass('campoErro');
	
	cCdpacote = $('#cdpacote','#frmConsultaPacote');
	cDspacote = $('#dspacote','#frmConsultaPacote');
	cDtinicio_vigencia = $('#dtinicio_vigencia','#frmConsultaPacote');
	cDtcancelamento = $('#dtcancelamento','#frmConsultaPacote');
	cDtdiadebito = $('#dtdiadebito','#frmConsultaPacote');
	cPerdesconto_manual = $('#perdesconto_manual','#frmConsultaPacote');
	cQtdmeses_desconto = $('#qtdmeses_desconto','#frmConsultaPacote');
	cTipoAutorizacao = $('input[type=radio][name=tipo_autorizacao]','#frmConsultaPacote');
	cCdreciprocidade = $('#cdreciprocidade','#frmConsultaPacote');
	
	rCdpacote = $('label[for="cdpacote"]','#frmConsultaPacote');
	rDspacote = $('label[for="dspacote"]','#frmConsultaPacote');
	rDtinicio_vigencia = $('label[for="dtinicio_vigencia"]','#frmConsultaPacote');
	rDtcancelamento = $('label[for="dtcancelamento"]','#frmConsultaPacote');
	rDtdiadebito = $('label[for="dtdiadebito"]','#frmConsultaPacote');
	rPerdesconto_manual = $('label[for="perdesconto_manual"]','#frmConsultaPacote');
	rQtdmeses_desconto = $('label[for="qtdmeses_desconto"]','#frmConsultaPacote');
	rCdreciprocidade = $('label[for="cdreciprocidade"]','#frmConsultaPacote');
	
	cCdpacote.addClass('campo').css('width','45px');
	cDspacote.addClass('campo').css({'width':'320px', 'text-align':'left'}).desabilitaCampo();
	cDtinicio_vigencia.addClass('campo').css('width','65px').desabilitaCampo();
	cDtcancelamento.addClass('campo').css('width','65px');
	cDtdiadebito.addClass('campo').css('width','45px');
	cPerdesconto_manual.addClass('campo').css('width','44px');
	cQtdmeses_desconto.addClass('campo').css('width','31px').desabilitaCampo();
	cCdreciprocidade.addClass('campo').css('width','45px');
	
	rCdpacote.addClass('rotulo').css('width','118px');
	rDspacote.addClass('rotulo').css('width','118px');
	if (opcao == 'C' || opcao == 'c'){
		rDtinicio_vigencia.addClass('rotulo').css('width','118px');
		rDtcancelamento.addClass('rotulo-linha').css('width','137px');
		rQtdmeses_desconto.addClass('rotulo-linha').css('width','145px');
	}
	else{
		rDtinicio_vigencia.addClass('rotulo-linha').css('width','158px');
		rDtcancelamento.addClass('rotulo-linha').css('width','161px');
		rQtdmeses_desconto.addClass('rotulo-linha').css('width','178px');
	}
	rDtdiadebito.addClass('rotulo').css('width','118px');
	rPerdesconto_manual.addClass('rotulo').css('width','118px');
	rCdreciprocidade.addClass('rotulo').css('width','118px');
	
	if (opcao == 'C' || opcao == 'c') {
		cCdpacote.val(glb_cdpacote);
		cDspacote.val(glb_dspacote);
		cDtinicio_vigencia.val(glb_dtinicio_vigencia);
		cDtcancelamento.val(glb_dtcancelamento );
		cDtdiadebito.val(glb_dtdiadebito);
		cPerdesconto_manual.val(glb_perdesconto_manual);
		cQtdmeses_desconto.val(glb_qtdmeses_desconto);
		
		if (glb_dtass_eletronica) {
			cTipoAutorizacao.closest('[value=S]').prop('checked', true);
		} else {
			cTipoAutorizacao.closest('[value=A]').prop('checked', true);
		}
		
		cCdreciprocidade.val((glb_cdreciprocidade > 0) ? "Sim" : "Não");
		
		cCdpacote.desabilitaCampo();
		cDspacote.desabilitaCampo();
		cDtinicio_vigencia.desabilitaCampo();
		cDtcancelamento.desabilitaCampo();
		cDtdiadebito.desabilitaCampo();
		cPerdesconto_manual.desabilitaCampo();
		cQtdmeses_desconto.desabilitaCampo();
		cTipoAutorizacao.desabilitaCampo();
		cCdreciprocidade.desabilitaCampo();
	}
	$('input','#frmConsultaPacote').trigger('blur');
		
	divRotina.css('width',largura);	
	$('#divConteudoOpcao').css({'height':altura,'width':largura});

	$('#cdpacote','#frmConsultaPacote').unbind('keydown').bind('keydown', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#dtdiadebito','#frmConsultaPacote').focus();
				return false;
			}
		});

	$('#dtdiadebito','#frmConsultaPacote').unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( e.keyCode == 13 || e.keyCode == 9 ) {
			$('#perdesconto_manual','#frmConsultaPacote').focus();
			return false;
		}
	});
	
	$('#perdesconto_manual','#frmConsultaPacote').unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( e.keyCode == 13 || e.keyCode == 9 ) {
			if ($('#perdesconto_manual').val() != "" && converteNumero($('#perdesconto_manual').val()) > 0)
				$('#qtdmeses_desconto','#frmConsultaPacote').focus();
			else
				$('#btProsseguir','#divBotoes').focus();
			return false;
		}
	});
	
	$('#qtdmeses_desconto','#frmConsultaPacote').unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( e.keyCode == 13 || e.keyCode == 9 ) {
			$('#btProsseguir','#divBotoes').focus();
			return false;
		}
	});
	
	layoutPadrao();
	hideMsgAguardo();
	removeOpacidade('divConteudoOpcao');
	divRotina.setCenterPosition();
	bloqueiaFundo(divRotina);	
	
	$('#cdpacote','#frmConsultaPacote').focus();
	
}

function formataTelaPeriodo() {
	$("#dtanoperiodo","#frmPeriodo").unbind('keypress').bind('keypress', function(e){ 	
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
			imprimirER();
			return false;
		}								
	});
}

function valida_inclusao(reciprocidade,nrdconta,idparame_reciproci,inpessoa){

	if ($("#cdpacote").val() == "") {
		showError('error','Informe um c&oacute;digo de servi&ccedil;o v&aacute;lido.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
		return false;
	}
	
	if ($('#perdesconto_manual').val() != "" && converteNumero($('#perdesconto_manual').val()) > 0 
	&& ($("#qtdmeses_desconto").val() == "" || converteNumero($("#qtdmeses_desconto").val()) <= 0)) {
		showError('error','Informe a qtd. de meses de desconto.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
		return false;
	}
	
	var tipoAutorizacao = cTipoAutorizacao.closest(':checked').val();
	if (!tipoAutorizacao) {
		showError('error','Informe o tipo de autoriza&ccedil;&atilde;o', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
		return false;
	}
	
	// Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/pacote_tarifas/valida_inclusao.php',
        data: {
            cdpacote           : $('#cdpacote').val(),
            dtdiadebito        : $('#dtdiadebito').val(),
            perdesconto_manual : $('#perdesconto_manual').val().replace(',00',''),
            qtdmeses_desconto  : $('#qtdmeses_desconto').val(),
            nrdconta           : nrdconta,
            redirect           : 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
			var perdesconto_manual = $('#perdesconto_manual').val().replace(',00','');
			if (perdesconto_manual == "") 
				perdesconto_manual = 0;
			
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				if (reciprocidade == "S") {
					chamaCONFRP(idparame_reciproci,inpessoa,'incluiPacote(' + nrdconta + ', "'+ tipoAutorizacao +'");',(perdesconto_manual > 0) ? 'S' : 'N');
				}
				else {
					if (perdesconto_manual > 0) {
						 pedeSenhaCoordenador(2,'incluiPacote(' + nrdconta + ', "'+ tipoAutorizacao +'");','divRotina');
					} else {
						incluiPacote(nrdconta, tipoAutorizacao);
					}
				}
			} else {
				eval( response );						
			}
        }
    });
	
	return false;
}

function chamaCONFRP(idparame_reciproci,inpessoa,executafuncao,senha_coordenador) {
	
    showMsgAguardo('Aguarde, carregando ...');

    exibeRotina($('#divUsoGenerico'));
	
	// Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/confrp/confrp.php',
        data: {
            idparame_reciproci    : 0, //idparame_reciproci,
            inpessoa              : inpessoa,
            cdproduto             : 26,
            consulta              : 'N',
            cp_idparame_reciproci : 'glb_idparame_reciproci',
            cp_desmensagem        : 'glb_desmensagem',
			executafuncao         : executafuncao,
            divanterior           : 'divRotina',
			tela_anterior         : 'pacote_tarifas',
            senha_coordenador     : senha_coordenador,
			redirect              : 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            $('#divUsoGenerico').html(response);
            $('#divUsoGenerico').css({'left':'340px','top':'91px'});
            layoutPadrao();
            hideMsgAguardo();            
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });
}

function incluiPacote(nrdconta, tipoAutorizacao) {
	// tipo autorização com senha
	if (tipoAutorizacao == 'S') {
		solicitaSenhaMagnetico('incluiPacoteAux('+ nrdconta +')', nrdconta);
	} else {
		incluiPacoteAux(nrdconta);
	}
}

function incluiPacoteAux(nrdconta) {
	// Executa script de atraves de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',   
		url: UrlSite + 'telas/atenda/pacote_tarifas/inclui_pacote.php', 
		data: {
			cdpacote           : $('#cdpacote').val(),
            dtdiadebito        : $('#dtdiadebito').val(),
            perdesconto_manual : $('#perdesconto_manual').val().replace(',00',''),
            qtdmeses_desconto  : $('#qtdmeses_desconto').val(),
            nrdconta           : nrdconta,
			idparame_reciproci : $('#glb_idparame_reciproci').val(),
			idtipo_autorizacao : $('input[type=radio][name=tipo_autorizacao]:checked','#frmConsultaPacote').val(),
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			eval( response );
			return false;
		}			
	});
}

function chamaTelaPacote(opcao, nrdconta) {
	if (opcao.toUpperCase() == 'C' && glb_cdpacote == 0){
		return false;
	}
	// Executa script de atraves de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',   
		url: UrlSite + 'telas/atenda/pacote_tarifas/form_consulta_pacote.php', 
		data: {
			   opcao: opcao,
    cd_reciprocidade: 1,
			nrdconta: nrdconta,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
					hideMsgAguardo();
					$('#tabelaPai').css({'width':'500px'});
					$('#divConteudoOpcao').html(response);
					formataTelaPacote(opcao);
				} else {
				eval( response );
			}
			return false;
		}			
	});
}

function verificaPctCancelado(nrdconta, rotina, dtadesao) {
	if (glb_cdpacote == "" || glb_cdpacote < 1) {
		return false;
	}
	// Executa script de atraves de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',   
		url: UrlSite + 'telas/atenda/pacote_tarifas/verifica_pct_cancelado.php', 
		data: {
			cdpacote: glb_cdpacote,
            nrdconta: nrdconta,
            dtadesao: glb_dtadesao,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if(response == "N") {
				if (rotina == 'C'){
					showConfirmacao('Deseja cancelar o Servi&ccedil;o Cooperativo atual?',
									'Confirma&ccedil;&atilde;o - Aimaro', 
									'blockBackground(parseInt($("#divRotina").css("z-index")));imprimirCancelaPct(' + nrdconta + ', 1);', 
									'blockBackground(parseInt($("#divRotina").css("z-index")));', 
									'sim.gif',
									'nao.gif');
				} else if (rotina == 'AD') {
					chamaTelaAlteraDebito(nrdconta);
				}
			}
			return false;
		}			
	});
}

function cancelarPacote(nrdconta) {
	
	// Executa script de atraves de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',   
		url: UrlSite + 'telas/atenda/pacote_tarifas/cancela_pacote.php', 
		data: {
			cdpacote: glb_cdpacote,
            nrdconta: nrdconta,
            dtadesao: glb_dtadesao,
			dtinivig: glb_dtinicio_vigencia,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {			
			eval(response);
			return false;
		}			
	});
}

function chamaTelaAlteraDebito(nrdconta){
	// Executa script de atraves de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',   
		url: UrlSite + 'telas/atenda/pacote_tarifas/form_altera_debito.php', 
		data: {
			nrdconta: nrdconta,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
					hideMsgAguardo();
					$('#divConteudoOpcao').html(response);
					$('#tabelaPai').css({'width':'210px'});
					formataTelaAlteraDebito();
				} else {
				eval( response );
			}
			return false;
		}			
	});
}

function alteraDebito(nrdconta) {
	// Executa script de atraves de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',   
		url: UrlSite + 'telas/atenda/pacote_tarifas/altera_debito.php', 
		data: {
			cdpacote: glb_cdpacote,
            nrdconta: nrdconta,
            dtadesao: glb_dtadesao,
         dtdiadebito: $('#dtdiadebito','#frmAlteraDebito').val(),
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			eval(response);
			return false;
		}			
	});
}

function chamaTelaImprimir(nrdconta){
	if (glb_cdpacote == 0){
		return false;
	}
	// Executa script de atraves de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',   
		url: UrlSite + 'telas/atenda/pacote_tarifas/form_imprimir.php', 
		data: {
			nrdconta: nrdconta,
		 flgsituacao: glb_flgsituacao,
     cdreciprocidade: glb_cdreciprocidade,
			dtadesao: glb_dtadesao,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
					hideMsgAguardo();
					$('#tabelaPai').css({'width':'470px'});
					$('#divConteudoOpcao').html(response);
					formataTelaImprimir();
					layoutPadrao();
				} else {
				eval( response );
			}
			return false;
		}			
	});
}

function buscaPacote(cdpacote, indpessoa){
	
	if (cdpacote == '' || cdpacote == 0)
		return false;
	
	// Executa script de atraves de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',   
		url: UrlSite + 'telas/atenda/pacote_tarifas/busca_pacote.php', 
		data: {
		    cdpacote: cdpacote,
            inpessoa: indpessoa,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
			$("#dspacote").val("");
		},
		success: function(response) {			
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#dspacote').val(response);
			} else {
				$('#cdpacote').val('');
				$('#dspacote').val('');
				eval( response );
			}
			return false;
		}
	});
}

function imprimirIR(nrdconta, dtadesao) {

	showMsgAguardo('Aguarde, carregando impress&atilde;o ...');
	
	var mesrefere = $("#dtmesperiodo","#frmPeriodo").val() + "/" + $("#dtanoperiodo","#frmPeriodo").val();
	
	fechaRotina($('#divUsoGenerico'),$('#divRotina'));
	
	// Executa script de atraves de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',   
		url: UrlSite + 'telas/atenda/pacote_tarifas/gera_indicadores_reciprocidade.php', 
		data: {
             nrdconta: nrdconta,
			 dtadesao: dtadesao,
            redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			hideMsgAguardo();
			if(response.substr(0,4) == "hide"){
				eval(response);
			}else{
				geraImpressao(response);
			}
			return false;
		}			
	});
}

function imprimirER() {
	
	showMsgAguardo('Aguarde, carregando impress&atilde;o ...');
	
	var mesrefere = $("#dtmesperiodo","#frmPeriodo").val() + "/" + $("#dtanoperiodo","#frmPeriodo").val();
	
	var nrdconta = $("#nrdconta","#frmPeriodo").val();
	var dtadesao = $("#dtadesao","#frmPeriodo").val();
	
	fechaRotina($('#divUsoGenerico'),$('#divRotina'));
	
	// Executa script de atraves de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',   
		url: UrlSite + 'telas/atenda/pacote_tarifas/gera_extrato_reciprocidade.php', 
		data: {
            nrdconta: nrdconta,
			dtadesao: dtadesao,
			mesrefere: mesrefere,
            redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			hideMsgAguardo();
			if(response.substr(0,4) == "hide"){
				eval(response);
			}else{
				geraImpressao(response);
			}
			return false;
		}			
	});
	
	return false;
}

function geraImpressao(arquivo) {
	
    $('#nmarquiv', '#frmImprimir').val(arquivo);
	
    var action = UrlSite + 'telas/atenda/pacote_tarifas/imprimir_pdf.php';
	
    carregaImpressaoAyllos("frmImprimir", action, "bloqueiaFundo(divRotina);");

}

function chamaTelaPeriodo(nrdconta, dtadesao) {
	
	showMsgAguardo('Aguarde, carregando ...');

    exibeRotina($('#divUsoGenerico'));
	
	// Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/pacote_tarifas/form_periodo.php',
        data: {
            nrdconta: nrdconta,
			dtadesao: dtadesao,
			redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            $('#divUsoGenerico').html(response);
            $('#divUsoGenerico').css({'top':'200px','width':'400px'});
            layoutPadrao();
			formataTelaPeriodo();
			$('#divUsoGenerico')
            hideMsgAguardo();            
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });
}

function pesquisaPacote(indpessoa) {
    procedure = 'PESQ_PACOTES';
    titulo = 'Servi&ccedil;os Cooperativos';
    qtReg = '20';
    filtrosPesq = 'Código;cdpacote;40px;S;0;;codigo|Descrição;dspacote;200px;S;;;descricao|Conta;inpessoa;100px;S;' + indpessoa + ';N';
    colunas = 'Codigo;cdpacote;10%;center|Descrição;dspacote;40%;left';
    mostraPesquisa('ADEPAC', procedure, titulo, qtReg, filtrosPesq, colunas, $('#divRotina'));
    return false;
}

function habilidaQtdMeses() {
	if ($('#perdesconto_manual').val() != "" && converteNumero($('#perdesconto_manual').val()) > 0)
		$('#qtdmeses_desconto').habilitaCampo();
	else {
		$('#qtdmeses_desconto').desabilitaCampo();
		$('#qtdmeses_desconto').val("");
	}
}

function converteNumero (numero){
	return numero.replace('.','').replace(',','.');
}

function imprimirAdesaoPct (nrdconta, dtadesao){
	
	showMsgAguardo('Aguarde, carregando impress&atilde;o ...');
	
	// Executa script de atraves de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',   
		url: UrlSite + 'telas/atenda/pacote_tarifas/gera_termo_adesao_pct.php', 
		data: {
			nrdconta: nrdconta,
			dtadesao: dtadesao,
	        redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},		
		success: function(response) {
			hideMsgAguardo();
			if(response.substr(0,4) == "hide"){
				eval(response);
			}else{
				geraImpressao(response);
			}
			return false;
		}			
	});
	
	return false;
}

function imprimirCancelaPct (nrdconta, cancelar){
	
	showMsgAguardo('Aguarde, carregando impress&atilde;o ...');
	// Executa script de atraves de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/pacote_tarifas/gera_termo_cancela_pct.php', 
		data: {
			nrdconta: nrdconta,
			dtadesao: glb_dtadesao,
	        redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			hideMsgAguardo();
			if(response.substr(0,4) == "hide"){
				eval(response);
			}else{
				if (cancelar == 1)
					cancelarPacote(nrdconta);
				geraImpressao(response);
			}
			return false;
		}			
	});
	
	return false;
}
