/*****************************************************************************************
 Fonte: cadcna.js                                                   
 Autor: Adriano - CECRED                                                   
 Data : Julho/2017             					   Última Alteração: 04/08/2017        
                                                                  
 Objetivo  : Biblioteca de funções da tela CADCNA
                                                                  
 Alterações: 04/08/2017 - Ajuste para enviar o parametro flserasa ao buscar o cnae 
                         (Adriano).
						  
******************************************************************************************/


$(document).ready(function() {

	estadoInicial();
			
});

function estadoInicial() {
	
	formataCabecalho();
	$('#frmFiltro').css('display','none');
	$('#divTabela').html('');
	$('#divBotoesFiltro').css('display','none');
	$('#cddopcao','#frmCabCadcna').habilitaCampo().focus().val('C');
	
	layoutPadrao();
				
}

function formataCabecalho(){

	$('label[for="cddopcao"]','#frmCabCadcna').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCabCadcna').css('width','610px');
	$('#divTela').css({'display':'block'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
	$('#frmCabCadcna').css('display','block');
		
	highlightObjFocus( $('#frmCabCadcna') );
	
	//Ao pressionar botao cddopcao
	$('#cddopcao','#frmCabCadcna').unbind('keypress').bind('keypress', function(e){
    
		$('input,select').removeClass('campoErro');
			
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$('#btOK','#frmCabCadcna').click();
			$(this).desabilitaCampo();			
			
			return false;						
			
		}
						
	});
	
	//Ao clicar no botao OK
	$('#btOK','#frmCabCadcna').unbind('click').bind('click', function(){
		
		if ( $('#cddopcao','#frmCabCadcna').hasClass('campoTelaSemBorda')  ) { return false; }
		
		$('#cddopcao','#frmCabCadcna').desabilitaCampo();		
		$(this).unbind('click');
		
		formataFiltro();
								
	});
	
	$('#cddopcao','#frmCabCadcna').focus();	
    
	return false;
	
}

function formataFiltro(){

	highlightObjFocus( $('#frmFiltro') );
	$('#fsetFiltro').css({'border-bottom':'1px solid #777'});	
	
	$('input','#frmFiltro').val('');
	
	//Label do frmFiltro
	var rCdcnae = $('label[for="cdcnae"]','#frmFiltro');
	
	rCdcnae.addClass("rotulo").css('width','100px');
	  
	//Campos do frmFiltro
	var cCdcnae = $('#cdcnae','#frmFiltro');
	var cDscnae = $('#dscnae','#frmFiltro');
  
    cCdcnae.css({'width':'80px'}).addClass('inteiro').attr('maxlength','10').habilitaCampo();
    cDscnae.css({'width':'400px'}).addClass('alphanum').attr('maxlength','200').desabilitaCampo();
		
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
	
	if($('#cddopcao','#frmCabCadcna').val() == 'I'){
	
		$('#cdcnae','#frmFiltro').desabilitaCampo();
		$('#dscnae','#frmFiltro').habilitaCampo().focus();
	
	}else{
	
		$('#cdcnae','#frmFiltro').focus();
		
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
				
				// Código CNAE
                if (campoAnterior == 'cdcnae') {
					
                    var filtrosPesq = "Código;cdcnae;100px;S;0|CNAE;dscnae;200px;S;;;descricao|;flserasa;;N;2;N;;descricao";
                    var colunas = 'Código;cdcnae;20%;right|CNAE;dscnae;80%;left';
                    mostraPesquisa("ZOOM0001", "BUSCA_CNAE", "CNAE", "30", filtrosPesq, colunas, '','','frmFiltro');
                    
					return false;
                }

            }
            
        }));
    });

    /*-------------------------------------*/
    /*   CONTROLE DA BUSCA DESCRIÇÕES      */
    /*-------------------------------------*/

	//CNAE
    $('#cdcnae','#frmFiltro').unbind('blur').bind('blur', function(e) {
        filtrosDesc = 'flserasa|2'; // 2 - Todos
        buscaDescricao("ZOOM0001", "BUSCA_CNAE", "CNAE", $(this).attr('name'), 'dscnae', $(this).val(), 'dscnae', filtrosDesc, 'frmFiltro');
		return false;
	});
	
}


function formataDetalhes(){

	highlightObjFocus( $('#frmDetalhes') );
	$('#fsetDetalhes').css({'border-bottom':'1px solid #777'});	
	
	$('input','#frmDetalhes').val('');
	
	//Label do frmDetalhes
	var rDscnae = $('label[for="dscnae"]','#frmDetalhes');
	
	rDscnae.addClass("rotulo").css('width','100px');
  
	//Campos do frmDetalhes
	var cDscnae = $('#dscnae','#frmDetalhes');
  
    cDscnae.css({'width':'400px'}).addClass('alphanum').attr('maxlength','25').habilitaCampo();
		
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
	
	formataTabelaCnae();
	
	$('#dscnae','#frmDetalhes').focus();
	
	return false;
	
}


function buscarCnae(nriniseq,nrregist){	

	var cddopcao = $('#cddopcao','#frmCabCadcna').val();
	var cdcnae = $('#cdcnae','#frmFiltro').val();
		
	showMsgAguardo( "Aguarde, buscando CNAE..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcna/buscar_cnae.php", 
        data: {
			cddopcao :cddopcao,
			cdcnae   :cdcnae,
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


function incluirCnae(){
	
	var cddopcao = $('#cddopcao','#frmCabCadcna').val();
	var dscnae = $('#dscnae','#frmFiltro').val();
	
	showMsgAguardo( "Aguarde, incluindo CNAE..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcna/incluir_cnae.php", 
        data: {
			cddopcao: cddopcao,
			dscnae  : dscnae,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#dscnae','#frmDetalhes').focus();");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#dscnae','#frmDetalhes').focus();");
			}
		}
    });
    return false;
	
	
}


function excluirCnae(){
	
	var cddopcao = $('#cddopcao','#frmCabCadcna').val();
	var cdcnae   = $('#cdcnae','#frmFiltro').val();
	
	showMsgAguardo( "Aguarde, excluíndo CNAE..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcna/excluir_cnae.php", 
        data: {
			cddopcao: cddopcao,
			cdcnae  : cdcnae,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cdcnae','#frmFiltro').focus();");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdcnae','#frmFiltro').focus();");
			}
		}
    });
    return false;
	
	
}


function alterarCnae(){
	
	var cddopcao = $('#cddopcao','#frmCabCadcna').val();
	var cdcnae = $('#cdcnae','#frmDetalhes').val();
	var dscnae = $('#dscnae','#frmDetalhes').val();
	
	showMsgAguardo( "Aguarde, alterando CNAE..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcna/alterar_cnae.php", 
        data: {
			cddopcao: cddopcao,
			cdcnae: cdcnae,
			dscnae: dscnae,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#dscnae','#frmFiltro').focus();");
        },
        success: function(response) {
			try {
				eval(response);				
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#dscnae','#frmFiltro').focus();");
			}
		}
    });
	
    return false;
		
}

function formataTabelaCnae(){
	
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
		
			selecionaCnae($(this));
			
		}	
		
	});	
	
	//seleciona o lancamento que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		
		selecionaCnae($(this));
		
	});
	
	$('#divTabela').css('display','block');
	$('#frmCnae').css('display','block');
	
	return false;
	
}


function selecionaCnae(tr){

	$('#cdcnae','#frmDetalhes').val($('#cdcnae', tr ).val());
	$('#dscnae','#frmDetalhes').val($('#dscnae', tr ).val());
	return false;
	
}

function controlaOperacao(){
	
	var cddopcao = $('#cddopcao','#frmCabCadcna').val();
	
	switch(cddopcao){
		
		case 'C':
		
			buscarCnae(1,30);
							
		break;
		
		case 'A':
		
			buscarCnae(1,30);
		
		break;
		
		
		case 'E':
		
			excluirCnae();
		
		break;
		
		case 'I':
		
			showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','incluirCnae();','$(\'#dscnae\',\'#frmFiltro\').focus();','sim.gif','nao.gif');
		
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

