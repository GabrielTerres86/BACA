/*****************************************************************************************
 Fonte: cadnac.js                                                   
 Autor: Adriano - CECRED                                                   
 Data : Junho/2017             					   Última Alteração:         
                                                                  
 Objetivo  : Biblioteca de funções da tela CADNAC
                                                                  
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
	$('#cddopcao','#frmCabCadnac').habilitaCampo().focus().val('C');
	
	layoutPadrao();
				
}

function formataCabecalho(){

	$('label[for="cddopcao"]','#frmCabCadnac').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCabCadnac').css('width','610px');
	$('#divTela').css({'display':'block'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
	$('#frmCabCadnac').css('display','block');
		
	highlightObjFocus( $('#frmCabCadnac') );
	
	//Ao pressionar botao cddopcao
	$('#cddopcao','#frmCabCadnac').unbind('keypress').bind('keypress', function(e){
    
		$('input,select').removeClass('campoErro');
			
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$('#btOK','#frmCabCadnac').click();
			$(this).desabilitaCampo();			
			
			return false;						
			
		}
						
	});
	
	//Ao clicar no botao OK
	$('#btOK','#frmCabCadnac').unbind('click').bind('click', function(){
		
		if ( $('#cddopcao','#frmCabCadnac').hasClass('campoTelaSemBorda')  ) { return false; }
		
		$('#cddopcao','#frmCabCadnac').desabilitaCampo();		
		$(this).unbind('click');
		
		formataFiltro();
								
	});
	
	$('#cddopcao','#frmCabCadnac').focus();	
    
	return false;
	
}

function formataFiltro(){

	highlightObjFocus( $('#frmFiltro') );
	$('#fsetFiltro').css({'border-bottom':'1px solid #777'});	
	
	$('input','#frmFiltro').val('');
	
	//Label do frmFiltro
	var rCdnacion = $('label[for="cdnacion"]','#frmFiltro');
	
	rCdnacion.addClass("rotulo").css('width','100px');
	  
	//Campos do frmFiltro
	var cCdnacion = $('#cdnacion','#frmFiltro');
	var cDsnacion = $('#dsnacion','#frmFiltro');
  
    cCdnacion.css({'width':'80px'}).addClass('inteiro').attr('maxlength','5').habilitaCampo();
    cDsnacion.css({'width':'400px'}).addClass('alphanum').attr('maxlength','15').desabilitaCampo();
		
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
	
	if($('#cddopcao','#frmCabCadnac').val() == 'I'){
	
		$('#cdnacion','#frmFiltro').desabilitaCampo();
		$('#dsnacion','#frmFiltro').habilitaCampo().focus();
	
	}else{
	
		$('#cdnacion','#frmFiltro').focus();
		
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
			
            if ($(this).prev().hasClass('campoTelaSemBorda')) {
				
                return false;
				
            } else {
				
                campoAnterior = $(this).prev().attr('name');
				
				// Código da nacionalidade
                if (campoAnterior == 'cdnacion') {
					
					var filtrosPesq = "Código;cdnacion;100px;S;0|Descrição;dsnacion;200px;S;";
                    var colunas = 'Código;cdnacion;25%;right|Descrição;dsnacion;75%;left';
                    mostraPesquisa("ZOOM0001", "BUSCANACIONALIDADES", "Nacionalidades", "30", filtrosPesq, colunas, '','','frmFiltro');
                    
					return false;
                }

            }
            
        }));
    });

    /*-------------------------------------*/
    /*   CONTROLE DA BUSCA DESCRIÇÕES      */
    /*-------------------------------------*/

	//Nacionalidade
    $('#cdnacion','#frmFiltro').unbind('blur').bind('blur', function(e) {
		buscaDescricao("ZOOM0001", "BUSCANACIONALIDADES", "Nacionalidades", $(this).attr('name'), 'dsnacion', $(this).val(), 'dsnacion', '', 'frmFiltro');
		return false;
	});
	
}


function formataDetalhes(){

	highlightObjFocus( $('#frmDetalhes') );
	$('#fsetDetalhes').css({'border-bottom':'1px solid #777'});	
	
	$('input','#frmDetalhes').val('');
	
	//Label do frmDetalhes
	var rDsnacion = $('label[for="dsnacion"]','#frmDetalhes');
	
	rDsnacion.addClass("rotulo").css('width','100px');
  
	//Campos do frmDetalhes
	var cDsnacion = $('#dsnacion','#frmDetalhes');
  
    cDsnacion.css({'width':'400px'}).addClass('alphanum').attr('maxlength','25').habilitaCampo();
		
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
	
	formataTabelaNacionalidade();	
	
	$('#dsnacion','#frmDetalhes').focus();
	
	return false;
	
}


function buscarNacionalidades(nriniseq,nrregist){	

	var cddopcao = $('#cddopcao','#frmCabCadnac').val();
	var cdnacion = $('#cdnacion','#frmFiltro').val();
		
	showMsgAguardo( "Aguarde, buscando nacionalidades..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadnac/buscar_nacionalidade.php", 
        data: {
			cddopcao :cddopcao,
			cdnacion :cdnacion,
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


function incluirNacionalidade(){
	
	var cddopcao = $('#cddopcao','#frmCabCadnac').val();
	var dsnacion = $('#dsnacion','#frmFiltro').val();
	
	showMsgAguardo( "Aguarde, incluindo nacionalidade..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadnac/incluir_nacionalidades.php", 
        data: {
			cddopcao: cddopcao,
			dsnacion: dsnacion,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#dsnacion','#frmDetalhes').focus();");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#dsnacion','#frmDetalhes').focus();");
			}
		}
    });
    return false;
	
	
}


function excluirNacionalidade(){
	
	var cddopcao = $('#cddopcao','#frmCabCadnac').val();
	var cdnacion = $('#cdnacion','#frmFiltro').val();
	
	showMsgAguardo( "Aguarde, excluíndo nacionalidade..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadnac/excluir_nacionalidades.php", 
        data: {
			cddopcao: cddopcao,
			cdnacion: cdnacion,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cdnacion','#frmFiltro').focus();");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdnacion','#frmFiltro').focus();");
			}
		}
    });
    return false;
	
	
}


function alterarNacionalidade(){
	
	var cddopcao = $('#cddopcao','#frmCabCadnac').val();
	var cdnacion = $('#cdnacion','#frmDetalhes').val();
	var dsnacion = $('#dsnacion','#frmDetalhes').val();
	
	showMsgAguardo( "Aguarde, alterando nacionalidade..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadnac/alterar_nacionalidades.php", 
        data: {
			cddopcao: cddopcao,
			cdnacion: cdnacion,
			dsnacion: dsnacion,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#dsnacion','#frmFiltro').focus();");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#dsnacion','#frmFiltro').focus();");
			}
		}
    });
	
    return false;
	
	
}


function formataTabelaNacionalidade(){
	
	var divRegistro = $('div.divRegistros', '#divTabela');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({ 'height': '150px', 'width' : '100%'});
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '60px';
	
	
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	
	var metodoTabela = '';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	$('table > tbody > tr', divRegistro).each( function(i) {
		
		if ( $(this).hasClass( 'corSelecao' ) ) {
		
			selecionaNacionalidade($(this));
			
		}	
		
	});	
	
	//seleciona o lancamento que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		
		selecionaNacionalidade($(this));
		
	});
	
	$('#divTabela').css('display','block');
	$('#frmNacionalidades').css('display','block');
	
	return false;
	
}


function selecionaNacionalidade(tr){

	$('#dsnacion','#frmDetalhes').val($('#dsnacion', tr ).val());
	$('#cdnacion','#frmDetalhes').val($('#cdnacion', tr ).val());
	return false;
	
}

function controlaOperacao(){
	
	var cddopcao = $('#cddopcao','#frmCabCadnac').val();
	
	switch(cddopcao){
		
		case 'C':
		
			buscarNacionalidades(1,30);
							
		break;
		
		case 'A':
		
			buscarNacionalidades(1,30);
		
		break;
		
		
		case 'E':
		
			excluirNacionalidade();
		
		break;
		
		case 'I':
		
			showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','incluirNacionalidade();','$(\'#dsnacion\',\'#frmFiltro\').focus();','sim.gif','nao.gif');
		
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

