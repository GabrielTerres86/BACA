/*!
 * FONTE        : imppre.js
 * CRIAÇÃO      : Lucas Lombardi
 * DATA CRIAÇÃO : 19/07/2016
 * OBJETIVO     : Biblioteca de funções da tela IMPPRE
 * --------------
 * ALTERAÇÕES   : 
 *
 * 000: [11/07/2017] Alteração no controla de apresentação do cargas bloqueadas na opção "A", Melhoria M441. ( Mateus Zimmermann/MoutS )			  
 *				  
 * --------------
 */
var glbIdcarga = 0;
var glbDscarga, glbDtfinal_vigencia, glbDsmensagem_aviso, glbNmarquivo;
 
$(document).ready(function() {

	estadoInicial();

	highlightObjFocus( $('#frmCab') );

	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	return false;

});

function estadoInicial() {

	$('#frmCab').css({'display':'block'});
	$('#divDetalhes').css({'display':'none'});

	$('#divBotoes', '#divTela').html('').css({'display':'block'});

	formataCabecalho();

	return false;

}

function controlaFoco() {
		
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
	
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			acessa_rotina();			
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			acessa_rotina();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('click').bind('click', function(){
	
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }		
		acessa_rotina();
		return false;			
	});
				
	return false;
	
}

function manter_rotina() {
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	var descricao      = $('#descricao','#frmImportaCarga').val();
	var final_vigencia = $('#final_vigencia','#frmImportaCarga').val();
	var indeterminada  = $('#indeterminada','#frmImportaCarga').is(':checked') ? 1 : 0;
	var mensagem       = $('#mensagem','#frmImportaCarga').val();
	var nome_arquivo   = $('#nome_arquivo','#frmImportaCarga').val();
	
	if (cddopcao == 'A')
		glbIdcarga = $('#hdIdcarga','#frmImportaCarga').val();
	else if (cddopcao == 'I')
		glbIdcarga = 0;
	
	showMsgAguardo('Aguarde, carregando...');
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/imppre/manter_rotina.php',
		data: {
			cddopcao: cddopcao,
		   descricao: descricao,
	  final_vigencia: final_vigencia,
	   indeterminada: indeterminada,
			mensagem: mensagem,
		nome_arquivo: nome_arquivo,
			iddcarga: glbIdcarga,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {			
			hideMsgAguardo();
			eval(response);
		}				
	});
    return false;
}

function acessa_rotina() {
	$('#cddopcao','#frmCab').desabilitaCampo();
	
	switch ($('#cddopcao','#frmCab').val()) {
		case 'I':
			acessaImportaCarga();
			break;
		case 'B':
		case 'L':
		case 'E':
		case 'A':
			acessaManterCarga(1,15);
			break;
	}
	return false;
}

function acessaImportaCarga(iddcarga, flgbloqu) {
	
    showMsgAguardo('Aguarde, carregando...');

	var cddopcao = $('#cddopcao','#frmCab').val();
    // Executa script atraves de ajax
    $.ajax({		
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/imppre/form_importa_carga.php',
        data: {
				cddopcao: cddopcao,
				iddcarga: iddcarga,
				redirect: 'html_ajax'			
              }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            $('#divDetalhes').html(response);
            formataImportaCarga(flgbloqu);
        }				
    });
    return false;
}

function acessaManterCarga(nriniseq, nrregist) {
	
    showMsgAguardo('Aguarde, carregando...');

	var cddopcao = $('#cddopcao','#frmCab').val();
	
    // Executa script atraves de ajax
    $.ajax({		
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/imppre/form_manter_carga.php',
        data: {
				cddopcao: cddopcao,
				nriniseq: nriniseq,
				nrregist: nrregist,
				redirect: 'html_ajax'			
              }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            $('#divDetalhes').html(response);
			formataManterCarga();
        }				
    });
    return false;
}

function formataCabecalho() {

	$('input,select', '#frmCab').removeClass('campoErro');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	

	cTodosCabecalho = $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.limpaFormulario();

	// cabecalho
	rCddopcao = $('label[for="cddopcao"]','#frmCab');

	cCddopcao = $('#cddopcao','#frmCab');

	//Rótulos
	rCddopcao.css('width','44px');

	//Campos	
	cCddopcao.css({'width':'496px'}).habilitaCampo().focus();
	
	// Esconde o campo tipo de cadastro
	$('#trTipoCadastro').hide();

	controlaFoco();
	layoutPadrao();

	return false;	

}

function formataImportaCarga(flgbloqu) {
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	// labels
	rDescricao          = $('label[for="descricao"]','#frmImportaCarga');
	rFinal_vigencia     = $('label[for="final_vigencia"]','#frmImportaCarga');
	rIndeterminada      = $('label[for="indeterminada"]','#frmImportaCarga');
	rMensagem           = $('label[for="mensagem"]','#frmImportaCarga');
	rNome_arquivo       = $('label[for="nome_arquivo"]','#frmImportaCarga');
	
	// campos
	cDescricao          = $('#descricao','#frmImportaCarga');
	cFinal_vigencia     = $('#final_vigencia','#frmImportaCarga');
	cIndeterminada      = $('#indeterminada','#frmImportaCarga');
	cMensagem           = $('#mensagem','#frmImportaCarga');
	cNome_arquivo       = $('#nome_arquivo','#frmImportaCarga');
	                 
	rDescricao.css('width','110px').addClass('rotulo');
    rFinal_vigencia.css('width','110px').addClass('rotulo');
    rIndeterminada.css('width','80px').addClass('rotulo-linha');
    rMensagem.css('width','113px').addClass('rotulo');
    rNome_arquivo.css('width','110px').addClass('rotulo');
	
	cDescricao.addClass('campo').css('width','400px').focus();
	cFinal_vigencia.css({'width':'72px','text-align':'right'}).addClass('campo inteiro').attr('maxlength','14').setMask("DATE","","","");
	cIndeterminada.css({'width':'20px','margin-top':'5px'});
	cMensagem.addClass('campo').css({'width':'400px','height':'70px','margin-left':'-72px','margin-top':'3px'});
	cNome_arquivo.addClass('campo').css('margin-top','4px');

	highlightObjFocus( $('#frmImportaCarga') );
	layoutPadrao();
	
	if (cddopcao == 'A') {
		cDescricao.val(glbDscarga);
		cFinal_vigencia.val(glbDtfinal_vigencia);
		
		if (glbDtfinal_vigencia == '')
			cIndeterminada.prop("checked", true);
		
		cMensagem.val(glbDsmensagem_aviso);
		cNome_arquivo.val(glbNmarquivo).desabilitaCampo();
		
		if (flgbloqu == 2) {

		    cFinal_vigencia.desabilitaCampo();
		    cIndeterminada.desabilitaCampo();
		} else {

		    habilita_vigencia();
		}
	}
	
	cIndeterminada.change(function() {
		habilita_vigencia();
	});
	
	$('#descricao','#frmImportaCarga').unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( e.keyCode == 13 || e.keyCode == 9 ) {
			if (cIndeterminada.is(':checked'))
				$('#indeterminada','#frmImportaCarga').focus();
			else
				$('#final_vigencia','#frmImportaCarga').focus();
			return false;
		}
	});
	
	$('#final_vigencia','#frmImportaCarga').unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( e.keyCode == 13 || e.keyCode == 9 ) {
			$('#indeterminada','#frmImportaCarga').focus();
			return false;
		}
	});
	
	$('#indeterminada','#frmImportaCarga').unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( e.keyCode == 13 || e.keyCode == 9 ) {
			$('#mensagem','#frmImportaCarga').focus();
			return false;
		}
	});
	
	$('#mensagem','#frmImportaCarga').unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( e.keyCode == 9 || (e.keyCode == 13 && !e.shiftKey)) {
			if (cddopcao == 'A') 
				$('#btConcluir','#frmImportaCarga').focus();
			else
				$('#nome_arquivo','#frmImportaCarga').focus();
			return false;
		}
	});
	
	$('#nome_arquivo','#frmImportaCarga').unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( e.keyCode == 13 || e.keyCode == 9 ) {
			$('#btConcluir','#frmImportaCarga').focus();
			return false;
		}
	});
	
	$('#btConcluir','#frmImportaCarga').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			validaImportacao();
			return false;
		}	
	});
	
	$('#btConcluir','#frmImportaCarga').unbind('click').bind('click', function(){
		validaImportacao();
		return false;			
	});

	$('#btVoltar','#frmImportaCarga').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if (cddopcao == 'A')
				acessa_rotina();
			else
				estadoInicial();
			return false;
		}	
	});
	
	$('#btVoltar','#frmImportaCarga').unbind('click').bind('click', function(){
		if (cddopcao == 'A')
			acessa_rotina();
		else
			estadoInicial();
		return false;			
	});
	
	$('#divDetalhes').css({'display':'block'});

	$('#descricao','#frmImportaCarga').focus();

	return false;	
}

function formataManterCarga() {
	
    var divRegistro = $('#divCarga');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '240px', 'width': '740px' });

    var ordemInicial = new Array();
    ordemInicial = [[0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '50px';
    arrayLargura[1] = '300px';
    arrayLargura[2] = '70px';
    arrayLargura[3] = '60px';
    arrayLargura[4] = '90px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
	$('#divPesquisaRodape','#divDetalhes').formataRodapePesquisa();
	glbIdcarga = 0;
	// seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click( function() {
       return false;
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();
	
	$('#btConcluir','#frmImportaCarga').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			confirmar_manter_rotina();
			return false;
		}	
	});
	
	$('#btConcluir','#frmImportaCarga').unbind('click').bind('click', function(){
		confirmar_manter_rotina();
	});

	$('#btVoltar','#frmImportaCarga').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			estadoInicial();
			return false;
		}	
	});
	
	$('#btVoltar','#frmImportaCarga').unbind('click').bind('click', function(){
		estadoInicial();
		return false;
	});
	
	$('#divDetalhes').css({'display':'block'});

	layoutPadrao();

	return false;	
}

function confirmar_manter_rotina () {
	
    glbIdcarga = $("#divCarga table tr.corSelecao").find("input[id='hdn_idcarga']").val();

    var flgBloqueio = $("#divCarga table tr.corSelecao").find("input[id='hdn_bloqueio']").val() == 'Sim' ? 1 : 2;
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	var msgConfirm, msgErro;
	switch(cddopcao){
		case 'B':
			msgConfirm = 'Deseja bloquear a carga ';
			msgErro = "Selecione uma carga para bloquear.";
			break;
		case 'L':
			msgConfirm = 'Deseja liberar a carga ';
			msgErro = "Selecione uma carga para liberar.";
			break;
		case 'E':
			msgConfirm = 'Deseja excluir a carga ';
			msgErro = "Selecione uma carga para excluir.";
			break;
		case 'A':
		    acessaImportaCarga(glbIdcarga, flgBloqueio);
			return false;
	}
	
	if(typeof glbIdcarga == "undefined") {
		showError('error',msgErro,'Alerta - Ayllos',"unblockBackground()");
		return false;
	}
	
	showConfirmacao(msgConfirm + glbIdcarga + '?','Confirma&ccedil;&atilde;o - Ayllos','manter_rotina();','','sim.gif','nao.gif');
	return false;
}

function habilita_vigencia() {
	if ($('#indeterminada','#frmImportaCarga').is(':checked')) {
		$('#final_vigencia','#frmImportaCarga').desabilitaCampo();
		$('#final_vigencia','#frmImportaCarga').val('');
	}
	else {
		$('#final_vigencia','#frmImportaCarga').habilitaCampo();
	}
}

function validaImportacao() {
	
	if ($('#final_vigencia','#frmImportaCarga').val() != ''){
		var data = $('#final_vigencia','#frmImportaCarga').val();
		var data_final = new Date(data);
		var data_hoje  = new Date();

	}
	
	if ($('#descricao','#frmImportaCarga').val() == '') {
		showError("error","Campo \"Descri&ccedil;&atilde;o\" &eacute; obrigat&oacute;rio.","Alerta - Ayllos","$('#nrdconta','#frmTrocaOpContaCorrente').focus();");
		return false;
	}
	
	if ($('#final_vigencia','#frmImportaCarga').val() == '' && !$('#indeterminada','#frmImportaCarga').is(':checked')) {
		showError("error","Campo \"Final de Vig&ecirc;ncia\" &eacute; obrigat&oacute;rio.","Alerta - Ayllos","$('#nrdconta','#frmTrocaOpContaCorrente').focus();");
		return false;
	}
	
	if ($('#mensagem','#frmImportaCarga').val() == '') {
		showError("error","Campo \"Mensagem\" &eacute; obrigat&oacute;rio.","Alerta - Ayllos","$('#nrdconta','#frmTrocaOpContaCorrente').focus();");
		return false;
	}
	
	if ($('#nome_arquivo','#frmImportaCarga').val() == '') {
		showError("error","Campo \"Nome do Arquivo\" &eacute; obrigat&oacute;rio.","Alerta - Ayllos","$('#nrdconta','#frmTrocaOpContaCorrente').focus();");
		return false;
	}
	
	manter_rotina();
	return false;
}
