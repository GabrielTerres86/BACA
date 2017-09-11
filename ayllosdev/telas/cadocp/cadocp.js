/*****************************************************************************************
 Fonte: cadocp.js                                                   
 Autor: Kelvin Souza Ott - CECRED                                                   
 Data : Agosto/2017             					   Última Alteracao:         
                                                                  
 Objetivo  : Biblioteca de funcoes da tela CADOCP
                                                                  
 Alteracoes:  
						  
******************************************************************************************/

$(document).ready(function() {

	estadoInicial();
			
});

function estadoInicial() {
	
	formataCabecalho();
	$('#frmFiltro').css('display','none');
	$('#divTabela').html('');
	$('#divBotoesFiltro').css('display','none');
	$('#cddopcao','#frmCabCadocp').habilitaCampo().focus().val('C');
	
	layoutPadrao();
				
}

function formataCabecalho(){

	$('label[for="cddopcao"]','#frmCabCadocp').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCabCadocp').css('width','610px');
	$('#divTela').css({'display':'block'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
	$('#frmCabCadocp').css('display','block');
		
	highlightObjFocus( $('#frmCabCadocp') );
	
	//Ao pressionar botao cddopcao
	$('#cddopcao','#frmCabCadocp').unbind('keypress').bind('keypress', function(e){
    
		$('input,select').removeClass('campoErro');
			
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$('#btOK','#frmCabCadocp').click();
			$(this).desabilitaCampo();			
			
			return false;						
			
		}
						
	});
	
	//Ao clicar no botao OK
	$('#btOK','#frmCabCadocp').unbind('click').bind('click', function(){
		
		if ( $('#cddopcao','#frmCabCadocp').hasClass('campoTelaSemBorda')  ) { return false; }
		
		$('#cddopcao','#frmCabCadocp').desabilitaCampo();		
		$(this).unbind('click');
		
		formataFiltro();
								
	});
	
	$('#cddopcao','#frmCabCadocp').focus();	
    
	return false;
	
}

function formataFiltro(){

	highlightObjFocus( $('#frmFiltro') );
	$('#fsetFiltro').css({'border-bottom':'1px solid #777'});	
	
	$('input','#frmFiltro').val('');
	
	//Label do frmFiltro
	var rCdnatocp = $('label[for="cdnatocp"]','#frmFiltro');
	
	rCdnatocp.addClass("rotulo").css('width','150px');
	  
	//Campos do frmFiltro
	var cCdnatocp = $('#cdnatocp','#frmFiltro');
	var cDsnatocp = $('#dsnatocp','#frmFiltro');
  
    cCdnatocp.css({'width':'130px'}).addClass('alphanum').attr('maxlength','12').habilitaCampo();
    cDsnatocp.css({'width':'350px'}).addClass('alphanum').attr('maxlength','60').desabilitaCampo();
		
	// Percorrendo todos os links
    $('input, select', '#frmFiltro').each(function () {
		
		//Define acao para o campo
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
	
	$('#frmFiltro').css('display','block');
	$('#divBotoesFiltro').css('display','block');
	
	controlaPesquisas();
	
	layoutPadrao();
	
	if($('#cddopcao','#frmCabCadocp').val() == 'I'){
	
		$('#cdnatocp','#frmFiltro').habilitaCampo().focus();
		$('#dsnatocp','#frmFiltro').habilitaCampo();
	
	}else{
		
		$('#cdnatocp','#frmFiltro').focus();
		
	}
	
	return false;
	
}

function controlaPesquisas() {

	// Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var nomeForm = 'frmFiltro';
	
    /*-------------------------------------*/
    /*       CONTROLE DAS PESQUISAS        */
    /*-------------------------------------*/

    // Atribui a classe lupa para os links e desabilita todos
    $('a', '#' + nomeForm).addClass('lupa').css('cursor', 'auto');

    // Percorrendo todos os links
    $('a', '#' + nomeForm).each(function () {
	
		if (!$(this).prev().hasClass('campoTelaSemBorda')) { $(this).css('cursor', 'pointer'); }
		
        $(this).unbind("click").bind("click", (function () {
			
			campoAnterior = $(this).prev().attr('name');
			
			// Codigo da natureza da ocupacao
			if (campoAnterior == 'cdnatocp') {
				
				var filtrosPesq = "Código;atocp;100px;S;|Descrição;dsnatocp;200px;S;";
				var colunas = 'Código;cdnatocp;25%;left|Descrição;rsnatocp;75%;left';
				
				mostraPesquisa("TELA_CADOCP", "BUSCANATOCUCADOCP", "Natureza da ocupa&ccedil&atilde;o", "30", filtrosPesq, colunas, '','','frmFiltro');
				
				return false;
			}
			
        }));
    });

    /*-------------------------------------*/
    /*   CONTROLE DA BUSCA DESCRICOES      */
    /*-------------------------------------*/

	//Nacionalidade
    $('#cdnatocp','#frmFiltro').unbind('blur').bind('blur', function(e) {
		
		buscaDescricao("TELA_CADOCP", "BUSCANATOCUCADOCP", "Natureza da ocupa&ccedil&atilde;o", $(this).attr('name'), 'dsnatocp', $(this).val(), 'rsnatocp', '', 'frmFiltro');
		
		return false;
	});
	
}

function buscarOcupacao(nriniseq,nrregist){	

	var cddopcao = $('#cddopcao','#frmCabCadocp').val();
	var cdnatocp = $('#cdnatocp','#frmFiltro').val();
		
	showMsgAguardo( "Aguarde, buscando ocupações..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadocp/buscar_ocupacao.php", 
        data: {
			cddopcao :cddopcao,
			cdnatocp :cdnatocp,
			nrregist :nrregist,
			nriniseq :nriniseq,
			redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCabCadocp').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divTabela').html(response);
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

function excluirOcupacao(){
	var cddopcao = $('#cddopcao','#frmCabCadocp').val();
	var cdocupa = $('#cdocupa','.corSelecao').val();
	var cdnatocp = $('#cdnatocp','#frmFiltro').val();	
	
	showMsgAguardo( "Aguarde, excluindo ocupacao..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadocp/excluir_ocupacao.php", 
        data: {
			cddopcao: cddopcao,
			cdocupa : cdocupa,
			cdnatocp: cdnatocp,						
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cdnatocp','#frmFiltro').focus();");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdnatocp','#frmFiltro').focus();");
			}
		}
    });
	
    return false;
}

function incluirOcupacao(){
	var cddopcao = $('#cddopcao','#frmCabCadocp').val();
	var cdnatocp = $('#cdnatocp','#frmFiltro').val();	
	var dsdocupa = $('#dsdocupa','#frmDetalhes').val();
	var rsdocupa = $('#rsdocupa','#frmDetalhes').val();
	
	showMsgAguardo( "Aguarde, alterando ocupacao..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadocp/incluir_ocupacao.php", 
        data: {
			cddopcao: cddopcao,
			cdnatocp: cdnatocp,			
			dsdocupa: dsdocupa,
			rsdocupa: rsdocupa,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cdnatocp','#frmFiltro').focus();");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdnatocp','#frmFiltro').focus();");
			}
		}
    });
	
    return false;
}

function alterarOcupacao(){
	var cddopcao = $('#cddopcao','#frmCabCadocp').val();
	var cdnatocp = $('#cdnatocp','#frmFiltro').val();
	var cdocupa  = $('#cdocupa','#frmDetalhes').val();
	var dsdocupa = $('#dsdocupa','#frmDetalhes').val();
	var rsdocupa = $('#rsdocupa','#frmDetalhes').val();
	
	showMsgAguardo( "Aguarde, alterando ocupacao..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadocp/alterar_ocupacao.php", 
        data: {
			cddopcao: cddopcao,
			cdnatocp: cdnatocp,
			cdocupa : cdocupa,
			dsdocupa: dsdocupa,
			rsdocupa: rsdocupa,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cdocupa','#frmFiltro').focus();");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdocupa','#frmFiltro').focus();");
			}
		}
    });
	
    return false;
	
}

function controlaOperacao(){
	
	var cddopcao = $('#cddopcao','#frmCabCadocp').val();
	
	switch(cddopcao){
		
		case 'C':
		
			buscarOcupacao(1,30);
							
		break;
		
		case 'A':
		
			buscarOcupacao(1,30);
		
		break;		
		
		case 'E':
		
			buscarOcupacao(1,30);			
		
		break;
		
		case 'I':
		
			buscarOcupacao(1,30);
		
		break;
		
		
	};
	
	return false;
	
}

function formataDetalhes(){

	highlightObjFocus( $('#frmDetalhes') );
	$('#fsetDetalhes').css({'border-bottom':'1px solid #777'});	
	
	$('input','#frmDetalhes').val('');
	
	//Label do frmDetalhes
	var rCdocupa = $('label[for="cdocupa"]','#frmDetalhes');
	var rDsdocupa = $('label[for="dsdocupa"]','#frmDetalhes');
	var rRsdocupa = $('label[for="rsdocupa"]','#frmDetalhes');
	
	rCdocupa.addClass("rotulo").css('width','150px');
	rDsdocupa.addClass("rotulo").css('width','150px');
	rRsdocupa.addClass("rotulo").css('width','150px');
  
	//Campos do frmDetalhes
	var cCdocupa = $('#cdocupa','#frmDetalhes');
	var cDsdocupa = $('#dsdocupa','#frmDetalhes');
	var cRsdocupa = $('#rsdocupa','#frmDetalhes');
  
    cCdocupa.css({'width':'400px'}).addClass('alphanum').attr('maxlength','12').habilitaCampo();
    cDsdocupa.css({'width':'400px'}).addClass('alphanum').attr('maxlength','60').habilitaCampo();
	cRsdocupa.css({'width':'400px'}).addClass('alphanum').attr('maxlength','42').habilitaCampo();
		
	// Percorrendo todos os links
    $('input, select', '#frmDetalhes').each(function () {
		
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
	
	$('#divBotoesFiltro').css('display','none');
	$('#frmDetalhes').css('display','block');
	$('#divBotoesDetalhes').css('display','block');
	$('input','#frmFiltro').desabilitaCampo();
	
	layoutPadrao();
	
	formataTabelaOcupacao();	
	
	$('#cdocupa','#frmDetalhes').focus();
	
	return false;
	
}

function formataTabelaOcupacao(){
	
	var divRegistro = $('div.divRegistros', '#divTabela');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({ 'height': '150px', 'width' : '100%'});
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '20%';
	arrayLargura[2] = '40%';
    
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	
	var metodoTabela = '';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	$('table > tbody > tr', divRegistro).each( function(i) {
		
		if ( $(this).hasClass( 'corSelecao' ) ) {
		
			selecionaOcupacao($(this));
			
		}	
		
	});	
	
	//seleciona o lancamento que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		
		selecionaOcupacao($(this));
		
	});
	
	$('#divTabela').css('display','block');
	$('#frmOcupacao').css('display','block');
	
	return false;
	
}

function selecionaOcupacao(tr){

	$('#dsdocupa','#frmDetalhes').val($('#dsdocupa', tr ).val());
	$('#cdocupa','#frmDetalhes').val($('#cdocupa', tr ).val());	
	$('#rsdocupa','#frmDetalhes').val($('#rsdocupa', tr ).val());
	return false;
	
}

function controlaVoltar(op){
		
	switch(op){
		
		case '1':
		
			estadoInicial();
			
		break;
		
		case '2':
		
			$('#divTabela').css('display','none');
			formataFiltro();
		
		break;
				
	};
	
	return false;
	
}