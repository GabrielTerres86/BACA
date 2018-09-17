/*****************************************************************************************
 Fonte: ocppep.js                                                   
 Autor: Adriano                                                   
 Data : Fevereiro/2017             					   Última Alteração:       
                                                                  
 Objetivo  : Biblioteca de funções da tela OCPPEP                 
                                                                  
 Alterações: 
						  
******************************************************************************************/

$(document).ready(function() {

	estadoInicial();
			
});

function estadoInicial() {
	
	formataCabecalho();
	
	$('#divRotina').html('');
	
	$('#cddopcao','#frmCabOcppep').habilitaCampo().focus().val('C');
	$('#frmSubrotinas').css('display','none');	
	$('#fsetSubrotina').css('display','none');
	$('#divSubrotina').css('display','none');
	$('#divBotoesSubRotinas').css('display','none');
	
	$('#frmNaturezaOcupacao').css('display','none');	
	$('#fsetNaturezaOcupacao').css('display','none');
	$('#divNaturezaOcupacao').css('display','none');
	$('#divBotoesNaturezaOcupacao').css('display','none');
	
	$('#frmDetalhesOcupacao').css('display','none');	
	$('#divDetalhesOcupacao').css('display','none');
	$('#divBotoesDetalhesOcupacao').css('display','none');
	
	$('#frmOcupacao').css('display','none');
	$('#fsetOcupacao').css('display','none');
	$('#divOcupacao').css('display','none');	
	$('#divBotoesOcupacao').css('display','none');
	
	layoutPadrao();
				
}

function formataCabecalho(){

	$('label[for="cddopcao"]','#frmCabOcppep').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCabOcppep').css('width','460px');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
	$('#frmCabOcppep').css('display','block');
		
	highlightObjFocus( $('#frmCabOcppep') );
	$('#cddopcao','#frmCabOcppep').focus();
	
    //Ao pressionar botao cddopcao
	$('#cddopcao','#frmCabOcppep').unbind('keypress').bind('keypress', function(e){
    
		$('input,select').removeClass('campoErro');
		
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$(this).desabilitaCampo();
						
			$('#btOK','#frmCabOcppep').unbind('click');
			
			carregaFormularios();
			
			return false;						
		}
						
	});
	
	//Ao clicar no botao OK
	$('#btOK','#frmCabOcppep').unbind('click').bind('click', function(){
		
		if ( $('#cddopcao','#frmCabOcppep').hasClass('campoTelaSemBorda')  ) { return false; }
		
		$('input,select').removeClass('campoErro');
		$('#cddopcao','#frmCabOcppep').desabilitaCampo();
						
		carregaFormularios();
		
		$(this).unbind('click');
								
	});
	
	//Ao pressionar botao OK
	$('#btOK','#frmCabOcppep').unbind('keypress').bind('keypress', function(e){
	
    if ( $('#cddopcao','#frmCabOcppep').hasClass('campoTelaSemBorda')  ) { return false; }	
		
		$('input,select').removeClass('campoErro');
		
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$('#cddopcao','#frmCabOcppep').desabilitaCampo();
			
			$(this).unbind('click');				
			carregaFormularios();
			
			return false;
			
		}
					
	});	
	
	return false;
	
}

function carregaFormularios(){
	
	var cddopcao = $('#cddopcao','#frmCabOcppep').val();
	
    $('input,select').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando formulários...');
		
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/ocppep/carrega_formularios.php',
		data: {
			cddopcao: cddopcao,			
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrercben','#divBeneficio').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divFormularios').html(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
					}
				}
		}				
	});
	
	return false;
	
}

function controlaLayout(tipo){
	
	switch(tipo){
	
		case '1':
		
			formataSubrotinas();
			
		break;
		
		case  '2':
		
			formataNaturezaOcupacao();
			
		break;
		
		case '4':
		
			formataOcupacao();
		
		break;
		
		case '5':
		
			formataDetalhesOcupacao();			
			
		break;
		
	}
	
	return false;
	
}

function formataSubrotinas(){

	highlightObjFocus( $('#divSubrotina') );
	
	$('#frmSubrotinas').css('display','block');
	$('#divBotoesSubRotinas').css('display','block');
	$('#divSubrotina').css('display','block');
	$('#fsetSubrotina').css('display','block');
	
	//Label do divSubrotina
	rcdsubrot = $('label[for="cdsubrot"]','#divSubrotina');
	
	rcdsubrot.css('width','55px');
	
	//Campos do divSubrotina
	ccdsubrot = $('#cdsubrot','#divSubrotina').habilitaCampo().focus();
	
	ccdsubrot.css('width','200px');
			
	ccdsubrot.unbind('keypress').bind('keypress', function (e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		//Enter ou TAB
		if(e.keyCode == 13 || e.keyCode == 9){
		
			$(this).removeClass('campoErro').desabilitaCampo();
			$('#btProsseguir','#divBotoesSubRotinas').click();
			
			return false;
			
		}
					
	});
	
	return false;
	
}

function formataNaturezaOcupacao(){
	
	$('#frmNaturezaOcupacao').css('display','block');
	$('#fsetNaturezaOcupacao').css('display','block');
	$('#divNaturezaOcupacao').css('display','block');
	$('#divBotoesNaturezaOcupacao').css('display','block');
	$('#divBotoesSubRotinas').css('display','none');
	$('#btVoltar','#divBotoesNaturezaOcupacao').css('display','inline');
	$('#btProsseguir','#divBotoesNaturezaOcupacao').css('display','inline');
	
	$('#cdsubrot','#divSubrotina').desabilitaCampo();	
	
	highlightObjFocus( $('#divNaturezaOcupacao') );
	
	todosNatureza = $('input','#divNaturezaOcupacao');
	 
	todosNatureza.val('').desabilitaCampo();
	
	//Label do divNaturezaOcupacao
	rCdnatocp = $('label[for="cdnatocp"]','#divNaturezaOcupacao');
	
	rCdnatocp.css('width','130px').addClass('rotulo');
			
	//Campos do divNaturezaOcupacao
	cCdnatocp = $('#cdnatocp','#divNaturezaOcupacao');
	cDsnatocp = $('#dsnatocp','#divNaturezaOcupacao');
	
	cCdnatocp.css({'width':'80px','text-align':'right'}).habilitaCampo().focus().addClass('inteiro').attr('maxlength','5');
	cDsnatocp.css('width','295px').addClass('alpha').attr('maxlength','40');
	
	// Se pressionar cdnatocp
	$('#cdnatocp','#divNaturezaOcupacao').unbind('keypress').bind('keypress', function (e) {
		
		if (divError.css('display') == 'block') { return false; }

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btProsseguir','#divBotoesNaturezaOcupacao').click();
				
			return false;

		}

	});
	
	//Ao clicar no botao btProsseguir
	$('#btProsseguir','#divBotoesNaturezaOcupacao').unbind('click').bind('click', function(){
		
		$('#cdnatocp','#divNaturezaOcupacao').desabilitaCampo();
		consultaNaturezaOperacao('1');
												
	});
	
	//Ao clicar no botao btProsseguir
	$('#btVoltar','#divBotoesNaturezaOcupacao').unbind('click').bind('click', function(){
		
		controlaVoltar('V2');
												
	});
	
	layoutPadrao();
		
	$('#cdnatocp','#divNaturezaOcupacao').val('99').desabilitaCampo();
	consultaNaturezaOperacao('2');
	$('#btProsseguir','#divBotoesNaturezaOcupacao').focus();
	
	return false;
	
}

function formataOcupacao(){
	
	$('#frmOcupacao').css('display','block');
	$('#divBotoesNaturezaOcupacao').css('display','none');
	$('#divBotoesOcupacao').css('display','block');
	
	highlightObjFocus( $('#frmOcupacao') );
	
	todosOcupacao = $('input','#divOcupacao');
	 
	todosOcupacao.val('').desabilitaCampo();
	
	//Label do divOcupacao
	rCdocupa = $('label[for="cdocupa"]','#divOcupacao');
	
	rCdocupa .css('width','130px').addClass('rotulo');
			
	//Campos do divOcupacao
	cCdocupa  = $('#cdocupa','#divOcupacao');
		
	cCdocupa .css('width','80px').addClass('inteiro').attr('maxlength','5');
	
	$('#fsetOcupacao').css('display','block');
	$('#divOcupacao').css('display','block');
	
	$('#cdocupa','#divOcupacao').habilitaCampo().focus();
	$("#btProsseguir","#divBotoesOcupacao").css("display","inline");
		
	// Se pressionar cdocupa
	$('#cdocupa','#divOcupacao').unbind('keypress').bind('keypress', function (e) {
		
		if (divError.css('display') == 'block') { return false; }

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btProsseguir','#divBotoesOcupacao').click();
				
			return false;

		}

	});
	
	//Ao clicar no botao btProsseguir
	$('#btProsseguir','#divBotoesOcupacao').unbind('click').bind('click', function(){
					
		consultaOcupacao();
												
	});
	
	//Ao clicar no botao btConcluir
	$('#btConcluir','#divBotoesOcupacao').unbind('click').bind('click', function(){
					
		showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterOcupacoes();','$(\'#dsdocupa\',\'#divDetalhesOcupacao\').focus();','sim.gif','nao.gif');
												
	});
		
	layoutPadrao();
	
	return false;
	
}

function formataDetalhesOcupacao(){
	
	$('#divBotoesOcupacao').css('display','none');
	$('#frmDetalhesOcupacao').css('display','block');
	$('#divBotoesDetalhesOcupacao').css('display','block');
		
	highlightObjFocus( $('#frmDetalhesOcupacao') );
	
	todosOcupacao = $('input','#divDetalhesOcupacao');
	 
	todosOcupacao.val('').desabilitaCampo();
	
	//Label do divDetalhesOcupacao
	rDsdocupa = $('label[for="dsdocupa"]','#divDetalhesOcupacao');
	rRsdocupa = $('label[for="rsdocupa"]','#divDetalhesOcupacao');
	
	rDsdocupa.css('width','130px').addClass('rotulo');
	rRsdocupa.css('width','130px').addClass('rotulo');
			
	//Campos do divDetalhesOcupacao
	cDsdocupa = $('#dsdocupa','#divDetalhesOcupacao');
	cRsdocupa = $('#rsdocupa','#divDetalhesOcupacao');
		
	cDsdocupa.css('width','395px').addClass('alpha').attr('maxlength','60');
	cRsdocupa.css('width','395px').addClass('alpha').attr('maxlength','42');
	
	$('#fsetDetalhesOcupacao').css('display','block');
	$('#divDetalhesOcupacao').css('display','block');
		
	if($('#cdsubrot','#divSubrotina').val() == 'C'){
	
		$("#btConcluir","#divBotoesDetalhesOcupacao").css("display","none");
		$("#btVoltar","#divBotoesDetalhesOcupacao").focus();
					
	}else if($('#cdsubrot','#divSubrotina').val() == 'E'){
		
		$("#btConcluir","#divBotoesDetalhesOcupacao").css("display","inline").focus();
		
	}else{
		
		$("#btConcluir","#divBotoesDetalhesOcupacao").css("display","inline");
		$('#dsdocupa','#divDetalhesOcupacao').habilitaCampo().focus();
		$('#rsdocupa','#divDetalhesOcupacao').habilitaCampo();
					
	}
	
	//Ao clicar no botao btConcluir
	$('#btConcluir','#divBotoesDetalhesOcupacao').unbind('click').bind('click', function(){
					
		showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterOcupacoes();','$(\'#btConcluir\',\'#divBotoesDetalhesOcupacao\').focus();','sim.gif','nao.gif');
												
	});
	
	// Se pressionar dsdocupa
	$('#dsdocupa','#divDetalhesOcupacao').unbind('keypress').bind('keypress', function (e) {
		
		if (divError.css('display') == 'block') { return false; }

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#rsdocupa','#divDetalhesOcupacao').focus();
				
			return false;

		}

	});
	
	// Se pressionar rsdocupa
	$('#rsdocupa','#divDetalhesOcupacao').unbind('keypress').bind('keypress', function (e) {
		
		if (divError.css('display') == 'block') { return false; }

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btConcluir','#divBotoesDetalhesOcupacao').click();
				
			return false;

		}

	});
		
	layoutPadrao();
	
	return false;
	
}

function controlaVoltar(opcao){
	
	switch(opcao){
	
		case 'V1': 
		
			estadoInicial(); 
			
		break;
		
		case 'V2':
											
			$('#frmNaturezaOcupacao').css('display','none');
			$('#fsetNaturezaOcupacao').css('display','none');
			$('#divNaturezaOcupacao').css('display','none');
			$('#divBotoesNaturezaOcupacao').css('display','none');
			
			formataSubrotinas();
			
		break;
			
		case 'V3':
			
			$('#frmOcupacao').css('display','none');
			$('#fsetOcupacao').css('display','none');
			$('#divOcupacao').css('display','none');
			$('#divBotoesOcupacao').css('display','none');
			
			formataNaturezaOcupacao();
		
		break;
		
		case 'V4':
			
			$('#frmDetalhesOcupacao').css('display','none');
			$('#fsetDetalhesOcupacao').css('display','none');
			$('#divDetalhesOcupacao').css('display','none');
			$('#divBotoesDetalhesOcupacao').css('display','none');
			
			formataOcupacao();
		
		break;
		
	}
	
	return false;

}

function controlaPesquisa(valor){

	switch(valor){
	
		case '1':
			controlaPesquisaNatOcupacao();
		break;
		
		case '2':
			controlaPesquisaOcupacao();
		break;
		
	}
	
}

function controlaPesquisaNatOcupacao() {

    // Se esta desabilitado o campo 
    if ($("#cdnatocp", "#divNaturezaOcupacao").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input', '#divNaturezaOcupacao').removeClass('campoErro');

    var cdnatocp = normalizaNumero($('#cdnatocp', '#divNaturezaOcupacao').val());
    
    //Definição dos filtros
    var filtros = "Código;cdnatocp;120px;S;;;|Descrição;dsnatocp;120px;N;;N;|Resumo;rsnatocp;120px;S;;S;";

	//Campos que serão exibidos na tela
    var colunas = 'Código;cdnatocp;15%;right|Descrição;dsnatocp;55%;left|Resumo;rsnatocp;30%;left';

	//Exibir a pesquisa
    mostraPesquisa("ZOOM0001", "CONSNATOCU", "Natureza de Ocupa&ccedil;&atilde;o", "30", filtros, colunas,'','$(\'#cdnatocp\',\'#divNaturezaOcupacao\').focus();','divNaturezaOcupacao');
    
    $("#divCabecalhoPesquisa > table").css("width", "700px");
    $("#divResultadoPesquisa > table").css("width", "700px");
    $("#divCabecalhoPesquisa").css("width", "700px");
    $("#divResultadoPesquisa").css("width", "700px");
    $('#divPesquisa').centralizaRotinaH();
   
    return false;

}


function controlaPesquisaOcupacao() {

    // Se esta desabilitado o campo 
    if ($("#cdocupa", "#divOcupacao").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input', '#divOcupacao').removeClass('campoErro');

     // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;    

    var cdocupa = normalizaNumero($('#cdocupa', '#divOcupacao').val());
    var cdnatocp = normalizaNumero($('#cdnatocp', '#divNaturezaOcupacao').val());
    
    //Definição dos filtros
    var filtros = "Código;cdocupa;120px;S;;;|Descrição;dsdocupa;120px;N;;N;|Resumo;rsdocupa;120px;S;;S;|;cdnatocp;;;"+cdnatocp+";N";

	//Campos que serão exibidos na tela
    var colunas = 'Código;cdocupa;15%;right|Descrição;dsdocupa;55%;left|Resumo;rsdocupa;30%;left';

	//Exibir a pesquisa
    mostraPesquisa("TELA_OCPPEP", "BUSCAOCUPACOES", "Ocupa&ccedil;&atilde;o", "30", filtros, colunas,'','$(\'#cdocupa\',\'#divOcupacao\').focus();','divOcupacao');
    
    $("#divCabecalhoPesquisa > table").css("width", "700px");
    $("#divResultadoPesquisa > table").css("width", "700px");
    $("#divCabecalhoPesquisa").css("width", "700px");
    $("#divResultadoPesquisa").css("width", "700px");
    $('#divPesquisa').centralizaRotinaH();
   
    return false;

}

function consultaNaturezaOperacao(operacao){

	var cddopcao = $('#cddopcao','#frmCabOcppep').val();
	var cdsubrot = $('#cdsubrot','#divSubrotina').val();
	var cdnatocp = $('#cdnatocp','#frmNaturezaOcupacao').val();
	
	$('#cdnatocp','#frmNaturezaOcupacao').desabilitaCampo();
	
	$('input,select').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, consultando natureza de ocupação...');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/ocppep/solicita_consulta_nat_ocp.php',
		data: {
			cddopcao: cddopcao,
			cdsubrot: cdsubrot,
			cdnatocp: cdnatocp,
			operacao: operacao,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cdnatocp','#divNaturezaOcupacao').focus();");							
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );						
			} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();$("#cdnatocp","#divNaturezaOcupacao").focus();');
			}
		}					
	});
		
	return false;
	
}


function consultaOcupacao(){

	var cddopcao = $('#cddopcao','#frmCabOcppep').val();
	var cdsubrot = $('#cdsubrot','#divSubrotina').val();
	var cdnatocp = $('#cdnatocp','#frmNaturezaOcupacao').val();
	var cdocupa  = $('#cdocupa','#divOcupacao').val();
	
	$('input,select').removeClass('campoErro');
	
	$('#cdocupa','#divOcupacao').desabilitaCampo();
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, consultando ocupação...');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/ocppep/solicita_consulta_ocupacao.php',
		data: {
			cddopcao: cddopcao,
			cdsubrot: cdsubrot,
			cdnatocp: cdnatocp,
			cdocupa:  cdocupa,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cdocupa','#divOcupacao').focus();");							
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );						
			} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();$("#cdocupa","#divOcupacao").focus();');
			}
		}					
	});
		
	return false;
	
}

function manterOcupacoes(){

	var cddopcao = $('#cddopcao','#frmCabOcppep').val();
	var cdsubrot = $('#cdsubrot','#divSubrotina').val();
	var cdnatocp = $('#cdnatocp','#frmNaturezaOcupacao').val();
	var cdocupa = $('#cdocupa','#divOcupacao').val();
	var dsdocupa = $('#dsdocupa','#divDetalhesOcupacao').val();
	var rsdocupa = $('#rsdocupa','#divDetalhesOcupacao').val();
	
	$('input,select').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, efetuando operação...');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/ocppep/manter_ocupacoes.php',
		data: {
			cddopcao: cddopcao,
			cdsubrot: cdsubrot,
			cdnatocp: cdnatocp,
			cdocupa:  cdocupa,
			dsdocupa: dsdocupa,
			rsdocupa: rsdocupa,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#dsdocupa','#divDetalhesOcupacao').focus();");							
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );						
			} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();$("#dsdocupa","#divDetalhesOcupacao").focus();');
			}
		}					
	});
		
	return false;
	
}
