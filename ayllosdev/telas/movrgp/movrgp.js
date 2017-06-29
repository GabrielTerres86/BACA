/*****************************************************************************************
 Fonte: movrgp.js                                                   
 Autor: Jonata - RKAM                                                 
 Data : Maio/2017           					   Última Alteração: 22/06/2017      
                                                                  
 Objetivo  : Biblioteca de funções da tela MOVRGP                 
                                                                  
 Alterações: 19/06/2017 - Ajuste para realizar a exportação de todas as cooperativas (Jonata - RKAM). 

             22/06/2017 - Ajuste posicionamento de colunas da tabela de movimentos (Jonata - RKAM).
						  
******************************************************************************************/

$(document).ready(function() {

	estadoInicial();
			
});


function estadoInicial() {
	
	formataCabecalho();	
	
	$('#divDetalhes').html('');
	$('#divFiltroCoop').html('');
	$('#divFiltroProduto').html('');
	$('#divProdutos').html('');
	$('#cddopcao','#frmCabMovrgp').habilitaCampo().focus().val('C');	
		
	layoutPadrao();
				
}

function formataCabecalho(){

	$('label[for="cddopcao"]','#frmCabMovrgp').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCabMovrgp').css('width','710px');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
	$('#frmCabMovrgp').css('display','block');
		
	cTodosCabecalho = $('input[type="text"],select', '#frmCabMovrgp');
    
	highlightObjFocus( $('#frmCabMovrgp') );
	
	cTodosCabecalho.habilitaCampo();
	
    //Ao pressionar botao cddopcao
	$('#cddopcao','#frmCabMovrgp').unbind('keypress').bind('keypress', function(e){
    
		$('input,select').removeClass('campoErro');
			
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$('#btOK','#frmCabMovrgp').click();
			$(this).desabilitaCampo();			
			
			return false;						
			
		}
						
	});
	
	//Ao clicar no botao OK
	$('#btOK','#frmCabMovrgp').unbind('click').bind('click', function(){
		
		if ( $('#cddopcao','#frmCabMovrgp').hasClass('campoTelaSemBorda')  ) { return false; }
		
		$('#cddopcao','#frmCabMovrgp').desabilitaCampo();		
		$(this).unbind('click');
		
		carregaInformacoesCabecalho();
								
	});
		
	$('#cddopcao', '#frmCabMovrgp').focus();
	
	return false;
	
}

function carregaInformacoesCabecalho() {

	var cddopcao = $('#cddopcao','#frmCabMovrgp').val(); 
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde ...');
	
	$('input,select').removeClass('campoErro');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/movrgp/carrega_informacoes_cabecalho.php',
		data: {
			cddopcao: cddopcao,			
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","estadoInicial();");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divFiltroCoop').html(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
					}
				}
		}				
	});
		
	return false;
	
}


function carregaMovimentos(nriniseq,nrregist) {

	var cddopcao = $('#cddopcao','#frmCabMovrgp').val(); 
	var cdcopsel = $('#cdcopsel','#frmFiltroCoop').val(); 
	var dtrefere = $('#dtrefere','#frmFiltroCoop').val(); 
	var cdproduto = $('#cdproduto','#frmFiltroProduto').val(); 
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, buscando produtos ...');
	
	$('input,select').removeClass('campoErro');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/movrgp/carrega_movimentos.php',
		data: {
			cddopcao: cddopcao,			
			cdcopsel: cdcopsel,			
			dtrefere: dtrefere,			
			cdproduto: cdproduto,	
		    nriniseq: nriniseq,			
			nrregist: nrregist,				
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","estadoInicial();");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divProdutos').html(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
					}
				}
		}				
	});
		
	return false;
	
}


function formataFiltroCoop(){

	highlightObjFocus( $('#fsetFiltroCoop') );
	$('#fsetFiltroCoop').css({'border-bottom':'1px solid #777'});	
	
	todosCampos = $('input,select','#fsetFiltroCoop');
	 
	todosCampos.val('').desabilitaCampo();
	
	//Label do fsetFiltroCoop
	rCdcopsel = $('label[for="cdcopsel"]','#fsetFiltroCoop');
	rDtrefere = $('label[for="dtrefere"]','#fsetFiltroCoop');
	
	//Label do fsetFiltroCoop
	rCdcopsel.addClass("rotulo").css('width','100px');
	rDtrefere.addClass("rotulo-linha").css('width','60px');
		  		
	//Campos do fsetFiltroCoop
	cCdcopsel = $('#cdcopsel','#fsetFiltroCoop');
	cDtrefere = $('#dtrefere','#fsetFiltroCoop');
	
	cCdcopsel.css('width','180px').habilitaCampo();
	cDtrefere.addClass('data').css({'width':'120px'}).habilitaCampo();
	
	// Percorrendo todos os links
    $('input, select', '#frmFiltroCoop').each(function () {
		
		//Define ação para o campo
		$(this).unbind('keypress').bind('keypress', function (e) {

			$('input,select').removeClass('campoErro');
			
			if (divError.css('display') == 'block') { return false; }

			// Se é a tecla ENTER, TAB
			if (e.keyCode == 13 || e.keyCode == 9) {

				$(this).nextAll('.campo:first').focus();

				return false;
			}
			
		});
		
	});
	
	layoutPadrao();
	
	$('#frmFiltroCoop').css('display','block');
	$('#divBotoesFiltroCoop').css('display','block');

	if($('#cddopcao','#frmCabMovrgp').val() == 'L'){
		
		cCdcopsel.desabilitaCampo();
		cDtrefere.focus();
		
	}else{
		
		cCdcopsel.focus();
		
	}
	
	
	return false;
	
}


function carregaBotaoProdutos() {

	var cddopcao = $('#cddopcao','#frmCabMovrgp').val(); 
	var cdcopsel = $('#cdcopsel','#frmFiltroCoop').val(); 
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde ...');
	
	$('input,select').removeClass('campoErro');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/movrgp/carrega_botao_produto.php',
		data: {
			cddopcao: cddopcao,			
			cdcopsel: cdcopsel,			
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","controlaVoltar('2');");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divFiltroProduto').html(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();controlaVoltar("2");');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();controlaVoltar("2");');
					}
				}
		}				
	});
		
	return false;
	
}



function formataFiltroProduto(){

	highlightObjFocus( $('#fsetFiltroProduto') );
	$('#fsetFiltroProduto').css({'border-bottom':'1px solid #777'});	
	
	todosCampos = $('input,select','#fsetFiltroProduto');
	 
	todosCampos.val('').desabilitaCampo();
	
	//Label do fsetFiltroProduto
	rCdproduto = $('label[for="cdproduto"]','#fsetFiltroProduto');
	
	//Label do fsetFiltroProduto
	rCdproduto.addClass("rotulo").css('width','100px');
		  		
	//Campos do fsetFiltroProduto
	cCdproduto = $('#cdproduto','#fsetFiltroProduto');
	
	cCdproduto.css('width','180px').habilitaCampo();
	
	// Percorrendo todos os links
    $('input, select', '#frmFiltroCoop').each(function () {
		
		//Define ação para o campo
		$(this).unbind('keypress').bind('keypress', function (e) {

			$('input,select').removeClass('campoErro');
			
			if (divError.css('display') == 'block') { return false; }

			// Se é a tecla ENTER, TAB
			if (e.keyCode == 13 || e.keyCode == 9) {

				$(this).nextAll('.campo:first').focus();

				return false;
			}
			
		});
		
	});
	
	layoutPadrao();
	
	$('input,select','#frmFiltroCoop').desabilitaCampo();
	$('#divBotoesFiltroCoop').css('display','none');
	$('#frmFiltroProduto').css('display','block');
	$('#divBotoesFiltroProduto').css('display','block');

	cCdproduto.focus();
	
	return false;
	
}


function formataFormProdutos(){

	highlightObjFocus( $('#fsetProdutosTotais') );
	$('#fsetProdutosTotais').css({'border-bottom':'1px solid #777'});	
	
	todosCampos = $('input,select','#fsetProdutosTotais');
	 
	todosCampos.val('').desabilitaCampo();
	
	//Label do fsetProdutosTotais
	rQtregist = $('label[for="qtregist"]','#fsetProdutosTotais');
	rVloperacao = $('label[for="tot_vloperacao"]','#fsetProdutosTotais');
	rVlsaldo = $('label[for="tot_vlsaldo"]','#fsetProdutosTotais');
	rVlsaldoPF = $('label[for="vlsaldo_pendente_pf"]','#fsetProdutosTotais');
	rVlsaldoPJ= $('label[for="vlsaldo_pendente_pj"]','#fsetProdutosTotais');
	
	//Label do fsetProdutosTotais
	rQtregist.addClass("rotulo").css('width','170px');
	rVloperacao.addClass("rotulo").css('width','170px');
	rVlsaldo.addClass("rotulo").css('width','170px');
	rVlsaldoPF.addClass("rotulo").css('width','170px');
	rVlsaldoPJ.addClass("rotulo").css('width','170px');
		  		
	//Campos do fsetProdutosTotais
	cQtregist = $('#qtregist','#fsetProdutosTotais');
	cVloperacao = $('#tot_vloperacao','#fsetProdutosTotais');
	cVlsaldo = $('#tot_vlsaldo','#fsetProdutosTotais');
	cVlsaldoPF = $('#vlsaldo_pendente_pf','#fsetProdutosTotais');
	cVlsaldoPJ = $('#vlsaldo_pendente_pj','#fsetProdutosTotais');
	
	cQtregist.css('width','130px').addClass('inteiro');
	cVloperacao.css('width','130px').addClass('inteiro');
	cVlsaldo.css('width','130px').addClass('inteiro');
	cVlsaldo.css('width','130px').addClass('inteiro');
	cVlsaldoPF.css('width','130px').addClass('inteiro');
	cVlsaldoPJ.css('width','130px').addClass('inteiro');
	
	layoutPadrao();
	
	return false;
	
}


function exportarArquivo() {

    var cddopcao = $("#cddopcao", "#frmCabMovrgp").val();
	var dtrefere = $('#dtrefere','#frmFiltroCoop').val();
	
	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde, exportando arquivo ...");

	$('input,select').removeClass('campoErro');
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/movrgp/exportar_arquivo.php",
        data: {
            cddopcao   : cddopcao,
            dtrefere   : dtrefere, 
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'blockBackground(parseInt($("#divRotina").css("z-index")));$("#cdproduto","#frmFiltroProduto").focus();');
            }
        }

    });

    return false;

}


function importarArquivo(tpoperacao) {

    var cddopcao = $("#cddopcao", "#frmCabMovrgp").val();
	var cdcopsel = $('#cdcopsel','#frmFiltroCoop').val();
	var dtrefere = $('#dtrefere','#frmFiltroCoop').val();
	var cdproduto = $('#cdproduto','#frmFiltroProduto').val();
	
	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde ...");

	$('input,select').removeClass('campoErro');
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/movrgp/importar_arquivo.php",
        data: {
            cddopcao   : cddopcao,
            cdcopsel   : cdcopsel, 
			dtrefere   : dtrefere, 
			cdproduto  : cdproduto, 
			tpoperacao : tpoperacao, 
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
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$("#cdproduto","#frmFiltroProduto").focus();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$("#cdproduto","#frmFiltroProduto").focus();');
				}
			}
			
        }

    });

    return false;

}


function excluirMovimento(idmovto_risco) {

    var cddopcao = $("#cddopcao", "#frmCabMovrgp").val();
	
	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde, excluindo movimento ...");

	$('input,select').removeClass('campoErro');
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/movrgp/excluir_movimento.php",
        data: {
            cddopcao      : cddopcao,
            idmovto_risco : idmovto_risco, 			
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'blockBackground(parseInt($("#divRotina").css("z-index")));$("#cdproduto","#frmFiltroProduto").focus();');
            }
        }

    });

    return false;

}


function alterarMovimento() {

    var cddopcao = $("#cddopcao", "#frmCabMovrgp").val();
	var cdcopsel = $('#cdcopsel','#frmFiltroCoop').val();
	var dtrefere = $('#dtrefere','#frmFiltroCoop').val();
	var idproduto = $('#idproduto','#fsetDetalhes').val();
	var idmovto_risco = $('#idmovto_risco','#fsetDetalhes').val();
	var nrcpfcgc = normalizaNumero($('#nrcpfcgc','#fsetDetalhes').val());
	var nrdconta = normalizaNumero($('#nrdconta','#fsetDetalhes').val());
	var nrctremp = normalizaNumero($('#nrctremp','#fsetDetalhes').val());
	var idgarantia = $('#iddominio_idgarantia','#fsetDetalhes').val();
	var idorigem_recurso = $('#iddominio_idorigem_recurso','#fsetDetalhes').val();
	var idindexador = $('#iddominio_idindexador','#fsetDetalhes').val();
	var perindexador = isNaN(parseFloat($('#perindexador', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#perindexador', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."));
	var vltaxa_juros = isNaN(parseFloat($('#vltaxa_juros', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vltaxa_juros', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."));
	var dtlib_operacao = $('#dtlib_operacao','#fsetDetalhes').val();
	var vloperacao = isNaN(parseFloat($('#vloperacao', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vloperacao', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."));
	var idnat_operacao = $('#iddominio_idnat_operacao','#fsetDetalhes').val();
	var dtvenc_operacao = $('#dtvenc_operacao','#fsetDetalhes').val();
	var cdclassifica_operacao = $('#cdclassifica_operacao', '#fsetDetalhes').val();
	var qtdparcelas = $('#qtdparcelas', '#fsetDetalhes').val();
	var vlparcela = isNaN(parseFloat($('#vlparcela', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlparcela', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."));
	var dtproxima_parcela = $('#dtproxima_parcela', '#fsetDetalhes').val();
	var vlsaldo_pendente = isNaN(parseFloat($('#vlsaldo_pendente', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlsaldo_pendente', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."));
	var flsaida_operacao = $('#flsaida_operacao','#fsetDetalhes').prop('checked');
	
	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde, alterando movimento ...");

	$('input,select').removeClass('campoErro');
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/movrgp/alterar_movimento.php",
        data: {
            cddopcao                 : cddopcao,                
            cdcopsel                 : cdcopsel,                
            dtrefere                 : dtrefere,                
			idmovto_risco            : idmovto_risco,               
			idproduto                : idproduto,               
			nrcpfcgc                 : nrcpfcgc,                
			nrdconta                 : nrdconta,                
			nrctremp                 : nrctremp,                
			idgarantia               : idgarantia,              
			idorigem_recurso         : idorigem_recurso,       
			idindexador              : idindexador,             
			perindexador             : perindexador,            
			vltaxa_juros             : vltaxa_juros,            
			dtlib_operacao           : dtlib_operacao,          
			vloperacao               : vloperacao,              
			idnat_operacao           : idnat_operacao,          
			dtvenc_operacao          : dtvenc_operacao,         
			cdclassifica_operacao    : cdclassifica_operacao,   
			qtdparcelas              : qtdparcelas,             
			vlparcela                : vlparcela,               
			dtproxima_parcela        : dtproxima_parcela,       
			vlsaldo_pendente         : vlsaldo_pendente,        
			flsaida_operacao         : (flsaida_operacao ) ? '1' : '0',				
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'blockBackground(parseInt($("#divRotina").css("z-index")));$("#cdproduto","#frmFiltroProduto").focus();');
            }
        }

    });

    return false;

}


function incluirMovimento() {

    var cddopcao = $("#cddopcao", "#frmCabMovrgp").val();
	var cdcopsel = $('#cdcopsel','#frmFiltroCoop').val();
	var dtrefere = $('#dtrefere','#frmFiltroCoop').val();
	var idproduto = $('#idproduto','#fsetDetalhes').val();
	var nrcpfcgc = normalizaNumero($('#nrcpfcgc','#fsetDetalhes').val());
	var nrdconta = normalizaNumero($('#nrdconta','#fsetDetalhes').val());
	var nrctremp = normalizaNumero($('#nrctremp','#fsetDetalhes').val());
	var idgarantia = $('#iddominio_idgarantia','#fsetDetalhes').val();
	var idorigem_recurso = $('#iddominio_idorigem_recurso','#fsetDetalhes').val();
	var idindexador = $('#iddominio_idindexador','#fsetDetalhes').val();
	var perindexador = isNaN(parseFloat($('#perindexador', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#perindexador', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."));
	var vltaxa_juros = isNaN(parseFloat($('#vltaxa_juros', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vltaxa_juros', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."));
	var dtlib_operacao = $('#dtlib_operacao','#fsetDetalhes').val();
	var vloperacao = isNaN(parseFloat($('#vloperacao', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vloperacao', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."));
	var idnat_operacao = $('#iddominio_idnat_operacao','#fsetDetalhes').val();
	var dtvenc_operacao = $('#dtvenc_operacao','#fsetDetalhes').val();
	var cdclassifica_operacao = $('#cdclassifica_operacao', '#fsetDetalhes').val();
	var qtdparcelas = $('#qtdparcelas', '#fsetDetalhes').val();
	var vlparcela = isNaN(parseFloat($('#vlparcela', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlparcela', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."));
	var dtproxima_parcela = $('#dtproxima_parcela', '#fsetDetalhes').val();
	var vlsaldo_pendente = isNaN(parseFloat($('#vlsaldo_pendente', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlsaldo_pendente', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."));
	var flsaida_operacao = $('#flsaida_operacao','#fsetDetalhes').prop('checked');
	
	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde, incluindo movimento ...");

	$('input,select').removeClass('campoErro');
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/movrgp/incluir_movimento.php",
        data: {
            cddopcao                 : cddopcao,                
            cdcopsel                 : cdcopsel,                
            dtrefere                 : dtrefere,                
			idproduto                : idproduto,               
			nrcpfcgc                 : nrcpfcgc,                
			nrdconta                 : nrdconta,                
			nrctremp                 : nrctremp,                
			idgarantia               : idgarantia,              
			idorigem_recurso         : idorigem_recurso,       
			idindexador              : idindexador,             
			perindexador             : perindexador,            
			vltaxa_juros             : vltaxa_juros,            
			dtlib_operacao           : dtlib_operacao,          
			vloperacao               : vloperacao,              
			idnat_operacao           : idnat_operacao,          
			dtvenc_operacao          : dtvenc_operacao,         
			cdclassifica_operacao    : cdclassifica_operacao,   
			qtdparcelas              : qtdparcelas,             
			vlparcela                : vlparcela,               
			dtproxima_parcela        : dtproxima_parcela,       
			vlsaldo_pendente         : vlsaldo_pendente,        
			flsaida_operacao         : (flsaida_operacao ) ? '1' : '0',				
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'blockBackground(parseInt($("#divRotina").css("z-index")));$("#cdproduto","#frmFiltroProduto").focus();');
            }
        }

    });

    return false;

}


function efetuarFechamentoDigitacao() {

    var cddopcao = $("#cddopcao", "#frmCabMovrgp").val();
    var cdcopsel = $('#cdcopsel','#frmFiltroCoop').val();
	var dtrefere = $('#dtrefere','#frmFiltroCoop').val();
	
	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde, efetuando fechamento ...");

	$('input,select').removeClass('campoErro');
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/movrgp/fechar_digitacao.php",
        data: {
            cddopcao : cddopcao,
            cdcopsel : cdcopsel, 			
            dtrefere : dtrefere, 			
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#cdproduto","#frmFiltroProduto").focus();');
            }
        }

    });

    return false;

}


function efetuarReaberturaDigitacao() {

    var cddopcao = $("#cddopcao", "#frmCabMovrgp").val();
	var cdcopsel = $('#cdcopsel','#frmFiltroCoop').val();
	var dtrefere = $('#dtrefere','#frmFiltroCoop').val();
	
	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde, efetuando reabertura ...");

	$('input,select').removeClass('campoErro');
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/movrgp/reabrir_digitacao.php",
        data: {
            cddopcao : cddopcao,
            cdcopsel : cdcopsel, 			
            dtrefere : dtrefere,  			
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#cdproduto","#frmFiltroProduto").focus();');
            }
        }

    });

    return false;

}

//Funcao para formatar a tabela com as ocorrências encontradas na consulta
function formataTabelaProdutos(){

	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
		
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table',divRegistro );	
	var linha		= $('table > tbody > tr', divRegistro );
									
	divRegistro.css({ 'height': '150px', 'width' : '100%'});
			
	var ordemInicial = new Array();
					
	var arrayLargura = new Array(); 
	    arrayLargura[0] = '25%';
	    arrayLargura[1] = '10%';
	    arrayLargura[2] = '15%';
	    arrayLargura[3] = '15%';
	    arrayLargura[4] = '15%';
							
	var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
				
		
	if ($('#cddopcao','#frmCabMovrgp').val() == 'E'){		
		
		var metodoTabela = "$('#btConcluir','#divBotoesProdutos').click();";
		tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,metodoTabela);
		
		$('table > tbody > tr', divRegistro).focus(function () {
			
			var linha = $(this);
			
			//Ao clicar no botao btConcluir
			$('#btConcluir','#divBotoesProdutos').unbind('click').bind('click', function(){
				
				showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','excluirMovimento('+ $('#aux_idmovto_risco', linha ).val()+');','$(\'#cdproduto\',\'#frmFiltroProduto\').focus();','sim.gif','nao.gif');
																		
			});			

		});
		
		//Seleciona o registro que é clicado
		$('table > tbody > tr', divRegistro).click( function() {
			
			var linha = $(this);
			
			//Ao clicar no botao btConcluir
			$('#btConcluir','#divBotoesProdutos').unbind('click').bind('click', function(){
				
				showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','excluirMovimento('+ $('#aux_idmovto_risco', linha ).val()+');','$(\'#cdproduto\',\'#frmFiltroProduto\').focus();','sim.gif','nao.gif');
												
			});		
			
		});			
		
		//Deixa o primeiro registro ja selecionado
		$('table > tbody > tr', divRegistro).each(function (i) {

			if ($(this).hasClass('corSelecao')) {

				var linha = $(this);
			
				//Ao clicar no botao btConcluir
				$('#btConcluir','#divBotoesProdutos').unbind('click').bind('click', function(){
					
					showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','excluirMovimento('+ $('#aux_idmovto_risco', linha ).val()+');','$(\'#cdproduto\',\'#frmFiltroProduto\').focus();','sim.gif','nao.gif');
											
				});

			}

		});
		
	}else if ($('#cddopcao','#frmCabMovrgp').val() == 'A' || $('#cddopcao','#frmCabMovrgp').val() == 'C'){	
		
		var metodoTabela = "$('#btProsseguir','#divBotoesProdutos').click();";
		tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,metodoTabela);
		
		$('table > tbody > tr', divRegistro).focus(function () {
			
			var linha = $(this);
			
			//Ao clicar no botao btProsseguir
			$('#btProsseguir','#divBotoesProdutos').unbind('click').bind('click', function(){
				
				buscarDetalhesMovto(linha);
													
			});			

		});
		
		//Seleciona o registro que é clicado
		$('table > tbody > tr', divRegistro).click( function() {
			
			var linha = $(this);
			
			//Ao clicar no botao btProsseguir
			$('#btProsseguir','#divBotoesProdutos').unbind('click').bind('click', function(){
				
				buscarDetalhesMovto(linha);
							
			});		
			
		});			
		
		//Deixa o primeiro registro ja selecionado
		$('table > tbody > tr', divRegistro).each(function (i) {

			if ($(this).hasClass('corSelecao')) {

				var linha = $(this);
			
				//Ao clicar no botao btProsseguir
				$('#btProsseguir','#divBotoesProdutos').unbind('click').bind('click', function(){
					
					buscarDetalhesMovto(linha);				
														
				});

			}

		});
		
	}
	
	$('#divRegistros').css('display','block');
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();		
	
	if ($('#cddopcao','#frmCabMovrgp').val() == 'I'){	
	
		$('#frmProdutos').css('display','none');
		$('#btProsseguir','#divBotoesProdutos').click();
	
	}
	
	return false;
	
}


function buscarDetalhesMovto(linha) {

    var cddopcao = $("#cddopcao", "#frmCabMovrgp").val();
	var idmovto_risco = $('#aux_idmovto_risco', linha).val();
	var idproduto = $('#cdproduto', '#frmFiltroProduto').val();
	
	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde, buscando informações ...");

	$('input,select').removeClass('campoErro');
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/movrgp/buscar_detalhes_movto.php",
        data: {
            cddopcao      : cddopcao,
            idmovto_risco : idmovto_risco,
            idproduto     : idproduto,
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
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$("#cdproduto","#frmFiltroProduto").focus();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$("#cdproduto","#frmFiltroProduto").focus();');
				}
			}
			
        }

    });

    return false;

}

function formataDetalhes(){

	highlightObjFocus( $('#fsetDetalhes') );
	$('#fsetDetalhes').css({'border-bottom':'1px solid #777'});	
	
	todosCampos = $('input,select','#fsetDetalhes');
	 
	//Label do fsetDetalhes
	rCdcopsel = $('label[for="cdcopsel"]','#fsetDetalhes');
	rDtrefere = $('label[for="dtrefere"]','#fsetDetalhes');
	rDsproduto = $('label[for="dsproduto"]','#fsetDetalhes');
	rNrdconta = $('label[for="nrdconta"]','#fsetDetalhes');
	rNrcpfcgc = $('label[for="nrcpfcgc"]','#fsetDetalhes');
	rNrctremp = $('label[for="nrctremp"]','#fsetDetalhes');
	rIdgarantia = $('label[for="idgarantia"]','#fsetDetalhes');
	rIdorigem_recurso = $('label[for="idorigem_recurso"]','#fsetDetalhes');
	rIdindexador = $('label[for="idindexador"]','#fsetDetalhes');
	rPerindexador = $('label[for="perindexador"]','#fsetDetalhes');
	rVltaxa_juros = $('label[for="vltaxa_juros"]','#fsetDetalhes');
	rDtlib_operacao = $('label[for="dtlib_operacao"]','#fsetDetalhes');
	rVloperacao = $('label[for="vloperacao"]','#fsetDetalhes');
	rIdnat_operacao = $('label[for="idnat_operacao"]','#fsetDetalhes');
	rDtvenc_operacao = $('label[for="dtvenc_operacao"]','#fsetDetalhes');
	rCdclassifica_operacao = $('label[for="cdclassifica_operacao"]','#fsetDetalhes');
	rQtdparcelas = $('label[for="qtdparcelas"]','#fsetDetalhes');
	rVlparcela = $('label[for="vlparcela"]','#fsetDetalhes');
	rDtproxima_parcela = $('label[for="dtproxima_parcela"]','#fsetDetalhes');
	rVlsaldo_pendente = $('label[for="vlsaldo_pendente"]','#fsetDetalhes');
	rFlsaida_operacao = $('label[for="flsaida_operacao"]','#fsetDetalhes');
	
	//Label do fsetDetalhes
	rCdcopsel.addClass("rotulo").css('width','160px');
	rDtrefere.addClass("rotulo").css('width','160px');
	rDsproduto.addClass("rotulo").css('width','160px');
	rNrdconta.addClass("rotulo").css('width','160px');
	rNrcpfcgc.addClass("rotulo").css('width','160px');
	rNrctremp.addClass("rotulo").css('width','160px');
	rIdgarantia.addClass("rotulo").css('width','160px');
	rIdorigem_recurso.addClass("rotulo").css('width','160px');
	rIdindexador.addClass("rotulo").css('width','160px');
	rPerindexador.addClass("rotulo").css('width','160px');
	rVltaxa_juros.addClass("rotulo").css('width','160px');
	rDtlib_operacao.addClass("rotulo").css('width','160px');
	rVloperacao.addClass("rotulo").css('width','160px');
	rIdnat_operacao.addClass("rotulo").css('width','160px');
	rDtvenc_operacao.addClass("rotulo").css('width','160px');
	rCdclassifica_operacao.addClass("rotulo").css('width','160px');
	rQtdparcelas.addClass("rotulo").css('width','160px');
	rVlparcela.addClass("rotulo").css('width','160px');
	rDtproxima_parcela.addClass("rotulo").css('width','160px');
	rVlsaldo_pendente.addClass("rotulo").css('width','160px');
	rFlsaida_operacao.addClass("rotulo").css('width','160px');
	  		
	//Campos do fsetDetalhes
	cCdcopsel = $('#cdcopsel','#fsetDetalhes');
	cDtrefere = $('#dtrefere','#fsetDetalhes');
	cDsproduto = $('#dsproduto','#fsetDetalhes');
	cNrdconta = $('#nrdconta','#fsetDetalhes');
	cNmprimtl = $('#nmprimtl','#fsetDetalhes');
	cNrcpfcgc = $('#nrcpfcgc','#fsetDetalhes');
	cNrctremp = $('#nrctremp','#fsetDetalhes');
	cIdgarantia = $('#idgarantia','#fsetDetalhes');
	cDsgarantia = $('#dsgarantia','#fsetDetalhes');
	cIdorigem_recurso = $('#idorigem_recurso','#fsetDetalhes');
	cDsorigem_recurso = $('#dsorigem_recurso','#fsetDetalhes');
	cIdindexador = $('#idindexador','#fsetDetalhes');
	cDsindexador = $('#dsindexador','#fsetDetalhes');
	cPerindexador = $('#perindexador','#fsetDetalhes');
	cVltaxa_juros = $('#vltaxa_juros','#fsetDetalhes');
	cDtlib_operacao = $('#dtlib_operacao','#fsetDetalhes');
	cVloperacao = $('#vloperacao','#fsetDetalhes');
	cIdnat_operacao = $('#idnat_operacao','#fsetDetalhes');
	cDsnat_operacao = $('#dsnat_operacao','#fsetDetalhes');
	cDtvenc_operacao = $('#dtvenc_operacao','#fsetDetalhes');
	cCdclassifica_operacao = $('#cdclassifica_operacao','#fsetDetalhes');
	cQtdparcelas = $('#qtdparcelas','#fsetDetalhes');
	cVlparcela = $('#vlparcela','#fsetDetalhes');
	cDtproxima_parcela = $('#dtproxima_parcela','#fsetDetalhes');
	cVlsaldo_pendente = $('#vlsaldo_pendente','#fsetDetalhes');
	cFlsaida_operacao = $('#flsaida_operacao','#fsetDetalhes');
	
	cCdcopsel.css('width','100px').addClass('alphanum').attr('maxlength','10').desabilitaCampo();
	cDtrefere.css('width','100px').addClass('data').desabilitaCampo();
	cDsproduto.css('width','340px').addClass('alphanum').attr('maxlength','150').desabilitaCampo();
	cNrdconta.addClass('conta pesquisa').css({'width':'100px'}).habilitaCampo();
	cNmprimtl.css('width','480px').addClass('alphanum').attr('maxlength','150').desabilitaCampo();
	cNrcpfcgc.css({ 'width': '150px'}).addClass('inteiro').attr('maxlength','18').desabilitaCampo();
	cNrctremp.css({ 'width': '100px', 'text-align': 'left' }).addClass('inteiro').attr('maxlength','10').habilitaCampo();
	cIdgarantia.css('width','100px').addClass('inteiro').attr('maxlength','4').habilitaCampo();
	cDsgarantia.css('width','480px').addClass('alphanum').attr('maxlength','200').desabilitaCampo();
	cIdorigem_recurso.css('width','100px').addClass('inteiro').attr('maxlength','4').habilitaCampo();
	cDsorigem_recurso.css('width','480px').addClass('alphanum').attr('maxlength','200').desabilitaCampo();
	cIdindexador.css('width','100px').addClass('inteiro').attr('maxlength','4').habilitaCampo();
	cDsindexador.css('width','480px').addClass('alphanum').attr('maxlength','200').desabilitaCampo();
    cPerindexador.css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_7').attr('maxlength', '10').habilitaCampo();
    cVltaxa_juros.css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_7').attr('maxlength', '10').habilitaCampo();
    cDtlib_operacao.css('width','100px').addClass('data').habilitaCampo();
    cVloperacao.css('width','100px').addClass('moeda_15').habilitaCampo();
    cIdnat_operacao.css('width','100px').addClass('inteiro').attr('maxlength','2').habilitaCampo();
	cDsnat_operacao.css('width','480px').addClass('alphanum').attr('maxlength','200').desabilitaCampo();
	cDtvenc_operacao.css('width','100px').addClass('data').habilitaCampo();
	cCdclassifica_operacao.css({ 'width': '100px', 'text-align': 'left' }).habilitaCampo();
	cQtdparcelas.css('width','100px').addClass('inteiro').attr('maxlength','8').habilitaCampo();
	cVlparcela.css('width','100px').addClass('moeda_15').habilitaCampo();
	cDtproxima_parcela.css('width','100px').addClass('data').habilitaCampo();
	cVlsaldo_pendente.css('width','100px').addClass('moeda_15').habilitaCampo();
	cFlsaida_operacao.habilitaCampo();
	
	controlaPesquisas();
	
	// Percorrendo todos os links
    $('input, select', '#frmDetalhes').each(function () {
		
		//Define ação para o campo
		$(this).unbind('keypress').bind('keypress', function (e) {

			$('input,select').removeClass('campoErro');
			
			if (divError.css('display') == 'block') { return false; }

			// Se é a tecla ENTER, TAB
			if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {
				
				if ($(this).attr('name') == 'vlsaldo_pendente'){
					
					($(this).val() > 0 ) ? $('#flsaida_operacao','#fsetDetalhes').prop("checked",false) : $('#flsaida_operacao','#fsetDetalhes').prop("checked",true); 
					
				}else if ($(this).attr('name') == 'nrcpfcgc'){
					
					var cpfCnpj = normalizaNumero($('#nrcpfcgc','#fsetDetalhes').val());
					
					if(cpfCnpj.length <= 11){	
						cNrcpfcgc.val(mascara(cpfCnpj,'###.###.###-##'));
					}else{
						cNrcpfcgc.val(mascara(cpfCnpj,'##.###.###/####-##'));
					}
					
				}

				$(this).nextAll('.campo:first').focus();

				return false;
			}
			
		});
		
	});
	
	cVlsaldo_pendente.unbind('change').bind('change', function() {
		
		var vlsaldoPendente = parseFloat($(this).val().replace(/\./g, "").replace(/\,/g, "."));
		
		if($('#flpermite_saida_operacao','#frmDetalhes').val() == '1'){
			
			(vlsaldoPendente > 0 ) ? $('#flsaida_operacao','#fsetDetalhes').prop("checked",false) : $('#flsaida_operacao','#fsetDetalhes').prop("checked",true); 
			
		}
		
		return false;
										
	});	
	
	cVlsaldo_pendente.unbind('focusout').bind('focusout',function() {

		var vlsaldoPendente = parseFloat($(this).val().replace(/\./g, "").replace(/\,/g, "."));
		
		if($('#flpermite_saida_operacao','#frmDetalhes').val() == '1'){
		
			(vlsaldoPendente > 0 ) ? $('#flsaida_operacao','#fsetDetalhes').prop("checked",false) : $('#flsaida_operacao','#fsetDetalhes').prop("checked",true); 
		
		}
		
		return false;		
		
	});	
	
	cFlsaida_operacao.unbind('focusout').bind('focusout',function() {

		if($('#flpermite_saida_operacao','#frmDetalhes').val() == '1'){
		
			if($(this).prop("checked")){
			
				cVlsaldo_pendente.val('');
			
			}else{
				cVlsaldo_pendente.val('0,01');
			}
		
		}
		
		return false;		
		
	});	
	
	cNrcpfcgc.unbind('change').bind('change', function() {

		var cpfCnpj = normalizaNumero($(this).val());
		
		if(cpfCnpj.length <= 11){	
			cNrcpfcgc.val(mascara(cpfCnpj,'###.###.###-##'));
		}else{
			cNrcpfcgc.val(mascara(cpfCnpj,'##.###.###/####-##'));
		}
										
	});
	
	layoutPadrao();
	
	$('#frmDetalhes').css('display','block');
	$('#divBotoesDetalhes').css('display','block');	
	
    if($('#cddopcao','#frmCabMovrgp').val() == 'C'){
		
		todosCampos.desabilitaCampo();
		$('#btVoltar','#divBotoesDetalhes').focus();
		
	}else if($('#cddopcao','#frmCabMovrgp').val() == 'E'){
		
		todosCampos.desabilitaCampo();
	    $('#btConcluir','#divBotoesDetalhes').focus();
				
	}else{
		
		if($('#flpermite_fluxo_financeiro','#frmDetalhes').val() != '1'){
			
			cQtdparcelas.desabilitaCampo();
			cVlparcela.desabilitaCampo();
			cDtproxima_parcela.desabilitaCampo();			
			
		}
				
		if($('#flpermite_saida_operacao','#frmDetalhes').val() != '1'){
			
			cFlsaida_operacao.desabilitaCampo();			
			
		}
		
		if ($('#cdclassificacao_produto', '#fsetDetalhes').val() == 'AA') {
			
		    $('#cdclassifica_operacao', '#fsetDetalhes').prop('selected', true).val($('#cdclassificacao_produto', '#fsetDetalhes').val());
            
		}
			   
        if($('#cddopcao','#frmCabMovrgp').val() == 'I'){
			
		  cVlsaldo_pendente.change();
			
		}		
	
        cIdgarantia.desabilitaCampo();
        cIdorigem_recurso.desabilitaCampo();
        cIdindexador.desabilitaCampo();
        cPerindexador.desabilitaCampo();
        cIdnat_operacao.desabilitaCampo();
       
		cNrdconta.focus();
		
	}
	
	return false;
	
}


function controlaPesquisas() {

	// Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas, campoDescricao;
    var nomeForm = 'fsetDetalhes';
	
    /*-------------------------------------*/
    /*       CONTROLE DAS PESQUISAS        */
    /*-------------------------------------*/

    // Atribui a classe lupa para os links e desabilita todos
    $('a', '#' + nomeForm).addClass('lupa').css('cursor', 'auto');

    // Percorrendo todos os links
    $('a', '#' + nomeForm).each(function () {

        if (!$(this).prev().hasClass('campoTelaSemBorda')) { $(this).css('cursor', 'pointer'); }

        $(this).unbind("click").bind("click", (function () {
            if ($(this).prev().hasClass('campoTelaSemBorda')) {
                return false;
            } else {
                campoAnterior = $(this).prev().attr('name');
				
				// Garantia
                if (campoAnterior == 'nrdconta') {
					
                    mostraPesquisaAssociado('nrdconta|nmprimtl|cdclassifica_operacao|nrcpfcgc', 'frmDetalhes',$('#divRotina'),'',$('#cdcopsel','#frmFiltroCoop').val());
					return false;
					
				// Garantia
                }else if (campoAnterior == 'idgarantia') {
                    filtrosPesq = "Cód. do Domínio;idtipo_dominio;30px;N;8;N|Descrição do Domínio;dstipo_dominio;200px;N;;N";
					colunas 	= 'Valor;dsdvalor;10%;left|Domínio;cddominio;20%;center|Descrição;dsdominio;80%;left#Valor;dsdvalor;10%;left|Domínio;cddominio;10%;center|Descrição;dsdominio;30%;left|Subdomínio;cdsubdominio;20%;left|Descrição;dssubdominio;80%;left';
					camposRetorno = 'iddominio|iddominio_idgarantia;dsdvalor|idgarantia;dstipo_dominio|dsgarantia';
					mostraPesquisaDominios("ZOOM0001", "BUSCADOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", "30", filtrosPesq, camposRetorno, colunas, $('#divRotina'),'','frmDetalhes');                        
					return false;
					
				// Origem recurso
                } else if (campoAnterior == 'idorigem_recurso') {
                    filtrosPesq = "Cód. do Domínio;idtipo_dominio;30px;N;3;N|Descrição do Domínio;dstipo_dominio;200px;N;;N";
                    colunas 	= 'Valor;dsdvalor;10%;left|Domínio;cddominio;20%;center|Descrição;dsdominio;80%;left#Valor;dsdvalor;10%;left|Domínio;cddominio;10%;center|Descrição;dsdominio;30%;left|Subdomínio;cdsubdominio;20%;left|Descrição;dssubdominio;80%;left';
					camposRetorno = 'iddominio|iddominio_idorigem_recurso;dsdvalor|idorigem_recurso;dstipo_dominio|dsorigem_recurso';
					mostraPesquisaDominios("ZOOM0001", "BUSCADOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", "30", filtrosPesq, camposRetorno, colunas,$('#divRotina'),'','frmDetalhes');
                    return false;

					//Indexador
                }else if (campoAnterior == 'idindexador') {
                    filtrosPesq = "Cód. do Domínio;idtipo_dominio;30px;N;4;N|Descrição do Domínio;dstipo_dominio;200px;N;;N";
                    colunas 	= 'Valor;dsdvalor;10%;left|Domínio;cddominio;20%;center|Descrição;dsdominio;80%;left#Valor;dsdvalor;10%;left|Domínio;cddominio;10%;center|Descrição;dsdominio;30%;left|Subdomínio;cdsubdominio;20%;left|Descrição;dssubdominio;80%;left';
					camposRetorno = 'iddominio|iddominio_idindexador;dsdvalor|idindexador;dstipo_dominio|dsindexador';
					mostraPesquisaDominios("ZOOM0001", "BUSCADOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", "30", filtrosPesq, camposRetorno, colunas,$('#divRotina'),'','frmDetalhes');
                    return false;

				//Natureza operação
                }else if (campoAnterior == 'idnat_operacao') {
                    filtrosPesq = "Cód. do Domínio;idtipo_dominio;30px;N;6;N|Descrição do Domínio;dstipo_dominio;200px;N;;N";
                    colunas 	= 'Valor;dsdvalor;10%;left|Domínio;cddominio;20%;center|Descrição;dsdominio;80%;left#Valor;dsdvalor;10%;left|Domínio;cddominio;10%;center|Descrição;dsdominio;30%;left|Subdomínio;cdsubdominio;20%;left|Descrição;dssubdominio;80%;left';
					camposRetorno = 'iddominio|iddominio_idnat_operacao;dsdvalor|idnat_operacao;dstipo_dominio|dsnat_operacao';
					mostraPesquisaDominios("ZOOM0001", "BUSCADOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", "30", filtrosPesq, camposRetorno, colunas,$('#divRotina'),'','frmDetalhes');
                    return false;

                }

            }
            return false;
        }));
    });

	
    /*-------------------------------------*/
    /*   CONTROLE DA BUSCA DESCRIÇÕES      */
    /*-------------------------------------*/

	//Conta
    $('#nrdconta', '#' + nomeForm).unbind('blur').bind('blur', function () {
		
		if( $('#divRotina').css('visibility') == 'visible'){
			
		filtrosDesc = 'cdcooper|' + $('#cdcopsel', '#frmFiltroCoop').val();
		buscaDescricao("ZOOM0001", "BUSCADESCASSOCIADO", "Pesquisa Associados", $(this).attr('name'), 'nmprimtl',normalizaNumero($(this).val()), 'nmprimtl', filtrosDesc, 'frmDetalhes');
		}
        
		return false;
    });
	
    //Garantia
    $('#idgarantia', '#' + nomeForm).unbind('blur').bind('blur', function () {
		
		if( $('#divRotina').css('visibility') == 'visible'){
			
		//Deve limpar o campo auxiliar, pois é sempre o valor dele que será utilizado nas operações
		$('#iddominio_idgarantia','#frmDetalhes').val('');
		filtrosDesc = 'idtipo_dominio|8';
        buscaDescricao("ZOOM0001", "BUSCADESCDOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", $(this).attr('name'), 'dsgarantia', $(this).val(), 'descricao', filtrosDesc, 'frmDetalhes');
        
		}
		
		return false;
    });
	
	// Origem recurso
    $('#idorigem_recurso', '#' + nomeForm).unbind('blur').bind('blur', function () {
		
		if( $('#divRotina').css('visibility') == 'visible'){
		
		//Deve limpar o campo auxiliar, pois é sempre o valor dele que será utilizado nas operações
		$('#iddominio_idorigem_recurso','#frmDetalhes').val('');
		filtrosDesc = 'idtipo_dominio|3';
        buscaDescricao("ZOOM0001", "BUSCADESCDOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", $(this).attr('name'), 'dsorigem_recurso', $(this).val(), 'descricao', filtrosDesc, 'frmDetalhes');
        
		}
		
		return false;
		
    });
	
	// Indexador
    $('#idindexador', '#' + nomeForm).unbind('blur').bind('blur', function () {
		
		if( $('#divRotina').css('visibility') == 'visible'){
			
		//Deve limpar o campo auxiliar, pois é sempre o valor dele que será utilizado nas operações
		$('#iddominio_idindexador','#frmDetalhes').val('');
		filtrosDesc = 'idtipo_dominio|4';
        buscaDescricao("ZOOM0001", "BUSCADESCDOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", $(this).attr('name'), 'dsindexador', $(this).val(), 'descricao', filtrosDesc, 'frmDetalhes');
        
		}
		
		return false;
		
    });
	
	// Natureza Operação
    $('#idnat_operacao', '#' + nomeForm).unbind('blur').bind('blur', function () {
		
		if( $('#divRotina').css('visibility') == 'visible'){
			
		//Deve limpar o campo auxiliar, pois é sempre o valor dele que será utilizado nas operações
		$('#iddominio_idnat_operacao','#frmDetalhes').val('');
		filtrosDesc = 'idtipo_dominio|6';
        buscaDescricao("ZOOM0001", "BUSCADESCDOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", $(this).attr('name'), 'dsnat_operacao', $(this).val(), 'descricao', filtrosDesc, 'frmDetalhes');
        
		}
		
		return false;
		
    });
	
}

function controlaVoltar(ope){
		
	switch (ope) {
		
		case '1': 
		
			estadoInicial();
			
		break;
		
		case '2': 			
			
			$('#divFiltroProduto').html('');
			carregaInformacoesCabecalho();
			
		break;
		
		case '3': 			
			
			$('#divProdutos').html('');
			carregaBotaoProdutos();
			
		break;
				
	}
	
	return false;
	
}

function controleOperacao(){
	
	var cddopcao = $('#cddopcao','#frmCabMovrgp').val();
	
	switch(cddopcao){
		
		case 'A':

			carregaMovimentos('1','30');
			
		break;
		
		case 'C':
		
			carregaMovimentos('1','30');
		
		break;
		
		case 'E':
		
			carregaMovimentos('1','30');
		
		break;
		
		case 'I':
		
			carregaMovimentos('1','30');
		
		break;
		
		
		case 'J':
		
			importarArquivo('VI');
		
		break;
		
		
		case 'L':
		
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','exportarArquivo();','$(\'#cdproduto\',\'#frmFiltroProduto\').focus();','sim.gif','nao.gif');
		
		break;
		
		
	}
	
	return false;
	
}



function Gera_Impressao(nmarquivo, callback) {

     hideMsgAguardo();

    var action = UrlSite + 'telas/movrgp/download_arquivo.php';

    $('#nmarquivo', '#frmFiltroCoop').remove();
    $('#sidlogin', '#frmFiltroCoop').remove();
    $('#opcao', '#frmFiltroCoop').remove();

    $('#frmFiltroCoop').append('<input type="hidden" id="nmarquivo" name="nmarquivo" value="' + nmarquivo + '" />');
    $('#frmFiltroCoop').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');
    $('#frmFiltroCoop').append('<input type="hidden" id="opcao" name="opcao" value="' + $('#cddopcao', '#frmCabMovrgp').val() + '" />');

    carregaImpressaoAyllos("frmFiltroCoop", action, callback);
	
	return false;

}