/*****************************************************************************************
 Fonte: mincap.js                                                   
 Autor: Jonata - RKAM                                                   
 Data : Junho/2017             					   Última Alteração:         
                                                                  
 Objetivo  : Biblioteca de funções da tela MINCAP                 
                                                                  
 Alterações:  
						  
******************************************************************************************/


$(document).ready(function() {

	estadoInicial();
			
});


function estadoInicial() {
	
	formataCabecalho();
	$('#frmFiltro').css('display','none');
	$('#divValor').html('');
	$('#divTiposConta').html('');
	$('#divBotoesFiltro').css('display','none');
	$('#cddopcao','#frmCabMincap').habilitaCampo().focus().val('C');
	
	layoutPadrao();
				
}

function formataCabecalho(){

	$('label[for="cddopcao"]','#frmCabMincap').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCabMincap').css('width','610px');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
	$('#frmCabMincap').css('display','block');
		
	highlightObjFocus( $('#frmCabMincap') );
	
	//Ao pressionar botao cddopcao
	$('#cddopcao','#frmCabMincap').unbind('keypress').bind('keypress', function(e){
    
		$('input,select').removeClass('campoErro');
			
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$('#btOK','#frmCabMincap').click();
			$(this).desabilitaCampo();			
			
			return false;						
			
		}
						
	});
	
	//Ao clicar no botao OK
	$('#btOK','#frmCabMincap').unbind('click').bind('click', function(){
		
		if ( $('#cddopcao','#frmCabMincap').hasClass('campoTelaSemBorda')  ) { return false; }
		
		$('#cddopcao','#frmCabMincap').desabilitaCampo();		
		$(this).unbind('click');
		
		$('#frmFiltro').css('display','block');
		$('#divBotoesFiltro').css('display','block');
		
		formataFiltro();
								
	});
	
	$('#cddopcao','#frmCabMincap').focus();	
    
	return false;
	
}

function formataFiltro(){

	highlightObjFocus( $('#frmFiltro') );
		
	$('input','#frmFiltro').val('');
	
	//Label do frmFiltro
	var rCdcopsel = $('label[for="cdcopsel"]','#frmFiltro');
	var rTppessoa = $('label[for="tppessoa"]','#frmFiltro');
	var rTppessoaFis = $('label[for="tppessoaFis"]','#frmFiltro');
	var rTppessoaJur = $('label[for="tppessoaJur"]','#frmFiltro');
	var rCdtipcta = $('label[for="cdtipcta"]','#frmFiltro');
	
	rCdcopsel.addClass("rotulo").css('width','100px');
	rTppessoa.addClass("rotulo-linha").css('width','60px');
	rTppessoaFis.addClass("rotulo-linha").css('width','60px');
	rTppessoaJur.addClass("rotulo-linha").css('width','60px');
	rCdtipcta.addClass("rotulo").css('width','100px');
  
	//Campos do frmFiltro
	var cCdcopsel = $('#cdcopsel','#frmFiltro');
	var cRadio  = $('input:radio','#frmFiltro'); 
	var cCdtipcta = $('#cdtipcta','#frmFiltro');
  
    cCdcopsel.css({'width':'400px'}).addClass('alphanum').habilitaCampo();
	cCdtipcta.css({'width':'400px'}).addClass('alphanum').habilitaCampo();
	cRadio.habilitaCampo();
	
	if($.browser.msie){
		cRadio.css('margin-top','3px');
	}else{
		cRadio.css('margin-top','4px');
	}
	
	cRadio.css('margin-left','8px');
	cRadio.css('margin-right','2px');		
		
	// Percorrendo todos os links
    $('input, select', '#frmFiltro').each(function () {
		
		//Define ação para o campo
		$(this).unbind('keypress').bind('keypress', function (e) {

			$('input,select').removeClass('campoErro');
			
			if (divError.css('display') == 'block') { return false; }

			// Se é a tecla ENTER, TAB
			if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {
				
				$(this).nextAll('.campo:first').focus();

				return false;
			}
			
		});
		
	});
	
	$('#divBotoesFiltro').css('display','block');
	
	layoutPadrao();
	
	$('#cdcopsel','#frmFiltro').focus();
	
	return false;
	
}

function formataFormularioValorMinimo(){
	
	highlightObjFocus( $('#frmValorMinimo') );
		
	//Label do frmValorMinimo
	var rVlminimo = $('label[for="vlminimo"]','#frmValorMinimo');
	
	rVlminimo.addClass("rotulo").css('width','150px'); 
  
	//Campos do frmValorMinimo
	var cVlminimo = $('#vlminimo','#frmValorMinimo'); 
  
    cVlminimo.css({ 'width': '200px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
	layoutPadrao();
	
	$('#frmValorMinimo').css('display','block');
	$('#divBotoesValorMinimo').css('display','block');
	
	if($('#cddopcao','#frmCabMincap').val() == 'A'){
		
		cVlminimo.habilitaCampo().focus().select();
		
	}
	
	return false;
	
}

function formataTabelaTiposContas() {

	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table',divRegistro );	
	var linha		= $('table > tbody > tr', divRegistro );
									
	divRegistro.css({'height':'150px'});
			
	var ordemInicial = new Array();
					
	var arrayLargura = new Array(); 
		arrayLargura[0] = '80px';
		arrayLargura[1] = '400px';
							
	var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
				
	var metodoTabela = '';
				
	tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,metodoTabela);			
							
	//Seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		
		var linha = $(this);
			
		//Ao clicar no botao btProsseguir
		$('#btProsseguir','#divBotoesTiposConta').unbind('click').bind('click', function(){
			
			apresentaFormValorMinimo(linha);
												
		});			

		apresentaFormValorMinimo($(this));
		
	});			
	
	$('table > tbody > tr', divRegistro).focus(function () {
		
		var linha = $(this);
			
		//Ao clicar no botao btProsseguir
		$('#btProsseguir','#divBotoesTiposConta').unbind('click').bind('click', function(){
			
			apresentaFormValorMinimo(linha);
												
		});		

	});

	//Deixa o primeiro registro ja selecionado
	$('table > tbody > tr', divRegistro).each(function (i) {

		if ($(this).hasClass('corSelecao')) {

			var linha = $(this);
			
			//Ao clicar no botao btProsseguir
			$('#btProsseguir','#divBotoesTiposConta').unbind('click').bind('click', function(){
				
				apresentaFormValorMinimo(linha);
													
			});	

		}

	});
	
	$('#frmTiposConta').css('display','block');
	$('#divBotoesTiposConta').css('display','block');
	$('#divRegistros').css('display','block');
	$('#divRegistrosRodape','#frmTiposConta').formataRodapePesquisa();		
	
	return false;
	
}

function buscaTiposConta(nriniseq,nrregist) {
		
	var cddopcao = $('#cddopcao','#frmCabMincap').val(); 
	var cdcopsel = $('#cdcopsel','#frmFiltro').val(); 
	var tppessoa = $('#tppessoa','#frmTiposConta').val(); 	
	
	if($('#tppessoaFis','#frmFiltro').is(":checked")){
		
		var tppessoa = 1;
		
	}else if($('#tppessoaJur','#frmFiltro').is(":checked")){
		
		var tppessoa = 2;
		
	} 
	
	showMsgAguardo('Aguarde...');		
		
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/mincap/busca_tipos_conta.php', 
		data: {			 
			cddopcao: cddopcao,
			cdcopsel: cdcopsel,
			tppessoa: tppessoa,
			nriniseq: nriniseq,
			nrregist: nrregist,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"estadoInicial();");
		},
		success: function(response) {
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divTiposConta').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial()');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
		}				
	});
	
	return false;
	
}


function apresentaFormValorMinimo(linha) {

    var cddopcao = $("#cddopcao", "#frmCabMincap").val();	
	var vlminimo = $('#valorMinimo',linha).val();
	var cdtipcta = $('#tipoConta',linha).val();
	
	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde...");

	$('input,select').removeClass('campoErro');
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/mincap/apresenta_form_valor_minimo.php",
        data: {
            cddopcao : cddopcao,
            vlminimo : vlminimo,
            cdtipcta : cdtipcta,
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divRotina').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$("#btVoltar","#divBotoesTiposConta").focus();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$("#btVoltar","#divBotoesTiposConta").focus();');
				}
			}
			
        }

    });

    return false;

}


function manterRotina() {
		
	var cddopcao = $('#cddopcao','#frmCabMincap').val(); 
	var cdcopsel = $('#cdcopsel','#frmFiltro').val(); 
	var cdtipcta = $('#cdtipcta','#frmValorMinimo').val(); 	
	var vlminimo = isNaN(parseFloat($('#vlminimo', '#frmValorMinimo').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlminimo', '#frmValorMinimo').val().replace(/\./g, "").replace(/\,/g, "."));
	
	if($('#tppessoaFis','#frmFiltro').is(":checked")){
		
		var tppessoa = 1;
		
	}else if($('#tppessoaJur','#frmFiltro').is(":checked")){
		
		var tppessoa = 2;
		
	} 
	
	showMsgAguardo('Aguarde...');		
		
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/mincap/manter_rotina.php', 
		data: {			 
			cddopcao: cddopcao,
			cdcopsel: cdcopsel,
			tppessoa: tppessoa,
			cdtipcta: cdtipcta,
			vlminimo: vlminimo,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"estadoInicial();");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );						
			} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
			}
		}				
	});
	
	return false;
	
}

function controlaVoltar(op){
	
	
	switch(op){
		
		case '1':
		
			estadoInicial();
			
		break;
		
		case '2':
		
			$('#divTiposConta').html('');
			formataFiltro();
		
		break;
		
		
		case '3':
		
			$('#divValor').html('');
			formataFiltroTiposConta();
		
		break;
		
		
	};
	
	return false;
	
}

