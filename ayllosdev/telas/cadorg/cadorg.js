/*****************************************************************************************
 Fonte: cadorg.js                                                   
 Autor: Adriano - CECRED                                                   
 Data : Junho/2017             					   Última Alteração:         
                                                                  
 Objetivo  : Biblioteca de funções da tela CADORG
                                                                  
 Alterações:  
						  
******************************************************************************************/


$(document).ready(function() {

	estadoInicial();
			
});

function estadoInicial() {
	
	formataCabecalho();
	$('#frmFiltro').css('display','none');
	$('#divTabela').html('');
	$('#divBotoesFiltro').css('display','none');
	$('#cddopcao','#frmCabCadorg').habilitaCampo().focus().val('C');
	
	layoutPadrao();
				
}

function formataCabecalho(){

	$('label[for="cddopcao"]','#frmCabCadorg').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCabCadorg').css('width','610px');
	$('#divTela').css({'display':'block'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
	$('#frmCabCadorg').css('display','block');
		
	highlightObjFocus( $('#frmCabCadorg') );
	
	//Ao pressionar botao cddopcao
	$('#cddopcao','#frmCabCadorg').unbind('keypress').bind('keypress', function(e){
    
		$('input,select').removeClass('campoErro');
			
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$('#btOK','#frmCabCadorg').click();
			$(this).desabilitaCampo();			
			
			return false;						
			
		}
						
	});
	
	//Ao clicar no botao OK
	$('#btOK','#frmCabCadorg').unbind('click').bind('click', function(){
		
		if ( $('#cddopcao','#frmCabCadorg').hasClass('campoTelaSemBorda')  ) { return false; }
		
		$('#cddopcao','#frmCabCadorg').desabilitaCampo();		
		$(this).unbind('click');
		
		formataFiltro();
								
	});
	
	$('#cddopcao','#frmCabCadorg').focus();	
    
	return false;
	
}

function formataFiltro(){

	highlightObjFocus( $('#frmFiltro') );
	$('#fsetFiltro').css({'border-bottom':'1px solid #777'});	
	
	$('input','#frmFiltro').val('');
	
	//Label do frmFiltro
	var rCdorgao_expedidor = $('label[for="cdorgao_expedidor"]','#frmFiltro');
	
	rCdorgao_expedidor.addClass("rotulo").css('width','120px');
	  
	//Campos do frmFiltro
	var cCdorgao_expedidor = $('#cdorgao_expedidor','#frmFiltro');
	var cNmorgao_expedidor = $('#nmorgao_expedidor','#frmFiltro');
  
    cCdorgao_expedidor.css({'width':'130px'}).addClass('alphanum').attr('maxlength','12').habilitaCampo();
    cNmorgao_expedidor.css({'width':'400px'}).addClass('alphanum').attr('maxlength','60').desabilitaCampo();
		
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
	
	$('#frmFiltro').css('display','block');
	$('#divBotoesFiltro').css('display','block');
	
	controlaPesquisas();
	
	layoutPadrao();
	
	if($('#cddopcao','#frmCabCadorg').val() == 'I'){
	
		$('#cdorgao_expedidor','#frmFiltro').habilitaCampo().focus();
		$('#nmorgao_expedidor','#frmFiltro').habilitaCampo();
	
	}else{
		
		$('#cdorgao_expedidor','#frmFiltro').focus();
		
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
			
            if ($(this).prev().hasClass('campoTelaSemBorda') || $('#cddopcao','#frmCabCadorg').val() == 'I') {
				
                return false;
				
            } else {
				
                campoAnterior = $(this).prev().attr('name');
				
				// Código do orgão expedidor
                if (campoAnterior == 'cdorgao_expedidor') {
					
					var filtrosPesq = "Código;cdorgao_expedidor;100px;S;|Descrição;nmorgao_expedidor;200px;S;";
                    var colunas = 'Código;cdorgao_expedidor;25%;left|Descrição;nmorgao_expedidor;75%;left';
                    mostraPesquisa("ZOOM0001", "BUSCA_ORGAO_EXPEDIDOR", "Org&atilde;o expedidor", "30", filtrosPesq, colunas, '','','frmFiltro');
                    
					return false;
                }

            }
            
        }));
    });

    /*-------------------------------------*/
    /*   CONTROLE DA BUSCA DESCRIÇÕES      */
    /*-------------------------------------*/

	//Nacionalidade
    $('#cdorgao_expedidor','#frmFiltro').unbind('blur').bind('blur', function(e) {
		
		if ($('#cddopcao','#frmCabCadorg').val() != 'I') {
			
			buscaDescricao("ZOOM0001", "BUSCA_ORGAO_EXPEDIDOR", "Org&atilde;o expedidor", $(this).attr('name'), 'nmorgao_expedidor', $(this).val(), 'nmorgao_expedidor', '', 'frmFiltro');
			
		}
		
		return false;
	});
	
}


function formataDetalhes(){

	highlightObjFocus( $('#frmDetalhes') );
	$('#fsetDetalhes').css({'border-bottom':'1px solid #777'});	
	
	$('input','#frmDetalhes').val('');
	
	//Label do frmDetalhes
	var rCdorgao_expedidor = $('label[for="cdorgao_expedidor"]','#frmDetalhes');
	var rNmorgao_expedidor = $('label[for="nmorgao_expedidor"]','#frmDetalhes');
	
	rCdorgao_expedidor.addClass("rotulo").css('width','100px');
	rNmorgao_expedidor.addClass("rotulo").css('width','100px');
  
	//Campos do frmDetalhes
	var cCdorgao_expedidor = $('#cdorgao_expedidor','#frmDetalhes');
	var cNmorgao_expedidor = $('#nmorgao_expedidor','#frmDetalhes');
  
    cCdorgao_expedidor.css({'width':'400px'}).addClass('alphanum').attr('maxlength','12').habilitaCampo();
    cNmorgao_expedidor.css({'width':'400px'}).addClass('alphanum').attr('maxlength','60').habilitaCampo();
		
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
	
	formataTabelaOrgaoExpedidor();	
	
	$('#cdorgao_expedidor','#frmDetalhes').focus();
	
	return false;
	
}


function buscarOrgaoExpedidor(nriniseq,nrregist){	

	var cddopcao = $('#cddopcao','#frmCabCadorg').val();
	var cdorgao_expedidor = $('#cdorgao_expedidor','#frmFiltro').val();
		
	showMsgAguardo( "Aguarde, buscando orgão expedidor..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadorg/buscar_orgao_expedidor.php", 
        data: {
			cddopcao :cddopcao,
			cdorgao_expedidor :cdorgao_expedidor,
			nrregist :nrregist,
			nriniseq :nriniseq,
			redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCab').focus();");
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


function incluirOrgaoExpedidor(){
	
	var cddopcao = $('#cddopcao','#frmCabCadorg').val();
	var cdorgao_expedidor = $('#cdorgao_expedidor','#frmFiltro').val();
	var nmorgao_expedidor = $('#nmorgao_expedidor','#frmFiltro').val();
	
	showMsgAguardo( "Aguarde, incluindo orgão expedidor..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadorg/incluir_orgao_expedidor.php", 
        data: {
			cddopcao: cddopcao,
			cdorgao_expedidor: cdorgao_expedidor,
			nmorgao_expedidor: nmorgao_expedidor,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#nmorgao_expedidor','#frmDetalhes').focus();");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nmorgao_expedidor','#frmDetalhes').focus();");
			}
		}
    });
    return false;
	
	
}


function excluirOrgaoExpedidor(){
	
	var cddopcao = $('#cddopcao','#frmCabCadorg').val();
	var cdorgao_expedidor = $('#cdorgao_expedidor','#frmFiltro').val();
	
	showMsgAguardo( "Aguarde, excluíndo orgão expedidor..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadorg/excluir_orgao_expedidor.php", 
        data: {
			cddopcao: cddopcao,
			cdorgao_expedidor: cdorgao_expedidor,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cdorgao_expedidor','#frmFiltro').focus();");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdorgao_expedidor','#frmFiltro').focus();");
			}
		}
    });
    return false;
	
	
}

function alterarOrgaoExpedidor(){
	
	var cddopcao = $('#cddopcao','#frmCabCadorg').val();
	var idorgao_expedidor = $('#idorgao_expedidor','#frmDetalhes').val();
	var cdorgao_expedidor = $('#cdorgao_expedidor','#frmDetalhes').val();
	var nmorgao_expedidor = $('#nmorgao_expedidor','#frmDetalhes').val();
	
	showMsgAguardo( "Aguarde, alterando orgão expedidor..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadorg/alterar_orgao_expedidor.php", 
        data: {
			cddopcao: cddopcao,
			idorgao_expedidor: idorgao_expedidor,
			cdorgao_expedidor: cdorgao_expedidor,
			nmorgao_expedidor: nmorgao_expedidor,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cdorgao_expedidor','#frmFiltro').focus();");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdorgao_expedidor','#frmFiltro').focus();");
			}
		}
    });
	
    return false;
	
	
}


function formataTabelaOrgaoExpedidor(){
	
	var divRegistro = $('div.divRegistros', '#divTabela');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({ 'height': '150px', 'width' : '100%'});
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '20%';
    
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
	
	var metodoTabela = '';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	$('table > tbody > tr', divRegistro).each( function(i) {
		
		if ( $(this).hasClass( 'corSelecao' ) ) {
		
			selecionaOrgaoExpedidor($(this));
			
		}	
		
	});	
	
	//seleciona o lancamento que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		
		selecionaOrgaoExpedidor($(this));
		
	});
	
	$('#divTabela').css('display','block');
	$('#frmOrgaoExpedidor').css('display','block');
	
	return false;
	
}


function selecionaOrgaoExpedidor(tr){

	$('#nmorgao_expedidor','#frmDetalhes').val($('#nmorgao_expedidor', tr ).val());
	$('#cdorgao_expedidor','#frmDetalhes').val($('#cdorgao_expedidor', tr ).val());
	$('#idorgao_expedidor','#frmDetalhes').val($('#idorgao_expedidor', tr ).val());
	return false;
	
}

function controlaOperacao(){
	
	var cddopcao = $('#cddopcao','#frmCabCadorg').val();
	
	switch(cddopcao){
		
		case 'C':
		
			buscarOrgaoExpedidor(1,30);
							
		break;
		
		case 'A':
		
			buscarOrgaoExpedidor(1,30);
		
		break;
		
		
		case 'E':
		
			excluirOrgaoExpedidor();
		
		break;
		
		case 'I':
		
			showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','incluirOrgaoExpedidor();','$(\'#dsnacion\',\'#frmFiltro\').focus();','sim.gif','nao.gif');
		
		break;
		
		
	};
	
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

