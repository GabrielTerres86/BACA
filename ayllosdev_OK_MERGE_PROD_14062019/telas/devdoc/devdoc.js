/*
 * FONTE        : devdoc.js
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 01/03/2014
 * OBJETIVO     : Biblioteca de funções da tela DEVDOC
 * --------------
 * ALTERAÇÕES   : 22/09/2014 - Inclusão da coluna Ag Fav (Marcos-Supero)
 * --------------
 */

//Formulários e Tabela
var formDados 		= 'frmDetalheDoc';

//Labels/Campos do formulário de dados
var rCdmotdev, rNrdocmto, rDtmvtolt, rVldocmto,
    cCdmotdev, cNrdocmto, cDtmvtolt, cVldocmto,
	
	rCdagenci, rNrdconta, rNmfavore, rNrcpffav,
    cCdagenci ,cNrdconta, cNmfavore, cNrcpffav,	
	
	rNrctadoc, rNmemiten, rNrcpfemi, rCdbandoc, rCdagedoc, rBlank,
	cNrctadoc, cNmemiten, cNrcpfemi, cCdbandoc, cCdagedoc;
	
var vg_formRetorno  = '';
var vg_campoRetorno = '';
var glb_nriniseq    = 1;
var glb_nrregist    = 50;
	
	
$(document).ready(function() {

	estadoInicial();
});

// inicio
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	
	$('input', '#'+ formDados ).limpaFormulario();
	$('input, select','#'+ formDados ).removeClass('campoErro');

	atualizaSeletor();
	controlaLayout();
	
	// retira as mensagens	
	hideMsgAguardo();
	BuscaDevDoc(1,50);
	removeOpacidade('divTela');

}

// controle de seletores
function atualizaSeletor(){
	
	rCdmotdev = $('label[for="cdmotdev"]','#'+formDados);
	rNrdocmto = $('label[for="nrdocmto"]','#'+formDados);
	rDtmvtolt = $('label[for="dtmvtolt"]','#'+formDados);
	rVldocmto = $('label[for="vldocmto"]','#'+formDados);
	
	rCdagenci = $('label[for="cdagenci"]','#'+formDados);
	rNrdconta = $('label[for="nrdconta"]','#'+formDados);
	rNmfavore = $('label[for="nmfavore"]','#'+formDados);
	rNrcpffav = $('label[for="nrcpffav"]','#'+formDados);
	
	rNrctadoc = $('label[for="nrctadoc"]','#'+formDados);
	rNmemiten = $('label[for="nmemiten"]','#'+formDados);
	rNrcpfemi = $('label[for="nrcpfemi"]','#'+formDados);
	rCdbandoc = $('label[for="cdbandoc"]','#'+formDados);
	rCdagedoc = $('label[for="cdagedoc"]','#'+formDados);
	rBlank    = $('label[for="blank"]','#'+formDados);
	
	cTodos    = $('input[type="text"],select','#'+formDados);

	cCdmotdev = $('#cdmotdev','#'+formDados);
	cNrdocmto = $('#nrdocmto','#'+formDados);
	cDtmvtolt = $('#dtmvtolt','#'+formDados);
	cVldocmto = $('#vldocmto','#'+formDados);
	
	cCdagenci = $('#cdagenci','#'+formDados);
	cNrdconta = $('#nrdconta','#'+formDados);
	cNmfavore = $('#nmfavore','#'+formDados);
	cNrcpffav = $('#nrcpffav','#'+formDados);
	
	cNrctadoc = $('#nrctadoc','#'+formDados);
	cNmemiten = $('#nmemiten','#'+formDados);
	cNrcpfemi = $('#nrcpfemi','#'+formDados);
	cCdbandoc = $('#cdbandoc','#'+formDados);
	cCdagedoc = $('#cdagedoc','#'+formDados);
	
	return false;
}

function controlaLayout() {

	$('fieldset').css({'clear':'both','border':'1px solid lightgray','margin':'5px 0px','padding':'10px 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'gray','margin-left':'5px','padding':'0px 2px'});
	$('#divBotoes').css({'text-align':'center','padding-top':'5px'});
	// Dados documento
	rCdmotdev.addClass('rotulo').css({'width':'58px','display':'inline-block','text-align':'right'});
	rNrdocmto.addClass('rotulo-linha').css({'width':'80px','display':'inline-block','text-align':'right'});
	rDtmvtolt.addClass('rotulo-linha').css({'width':'50px','display':'inline-block','text-align':'right'});
	rVldocmto.addClass('rotulo-linha').css({'width':'50px','display':'inline-block','text-align':'right'});
	// Favorecido
	rCdagenci.addClass('rotulo').css({'width':'60px','display':'inline-block','text-align':'right'});
	rNrdconta.addClass('rotulo-linha').css({'width':'60px','display':'inline-block','text-align':'right'});
	rNmfavore.addClass('rotulo-linha').css({'width':'70px','display':'inline-block','text-align':'right'});
	rNrcpffav.addClass('rotulo-linha').css({'width':'70px','display':'inline-block','text-align':'right'});
	// Emitente
	rNrctadoc.addClass('rotulo').css({'width':'60px','display':'inline-block','text-align':'right'});
	rNmemiten.addClass('rotulo-linha').css({'width':'70px','display':'inline-block','text-align':'right'}); 
	rNrcpfemi.addClass('rotulo-linha').css({'width':'70px','display':'inline-block','text-align':'right'});
	rCdbandoc.addClass('rotulo').css({'width':'40px','display':'inline-block','text-align':'right','margin-top':'10px'});
	rCdagedoc.addClass('rotulo-linha').css({'width':'100px','display':'inline-block','text-align':'right'});
	rBlank.addClass('rotulo-linha').css({'width':'262px','display':'inline-block'});
	
	cCdmotdev.css('width','40px').setMask('INTEGER','zz9','','');
	cNrdocmto.css('width','55px').setMask('INTEGER','zz.zz9','','');
	cDtmvtolt.css('width','80px').addClass('data');
	cVldocmto.css('width','100px').addClass('monetario');
	
	cCdagenci.css('width','80px').setMask('INTEGER','zz9','','');
	cNrdconta.css('width','80px').setMask('INTEGER','zzzz.zzz-9','','');
	cNmfavore.css('width','150px').attr('maxlength','40').addClass('alphanum');
	cNrcpffav.css('width','110px').setMask('INTEGER','zzzzzzzzzzzzz9','','');
	
	cNrctadoc.css('width','80px').setMask('INTEGER','zzzz.zzz-9','','');
	cNmemiten.css('width','150px').attr('maxlength','40').addClass('alphanum');
	cNrcpfemi.css('width','110px').setMask('INTEGER','zzzzzzzzzzzzz9','','');
	cCdbandoc.css('width','50px').setMask('INTEGER','z.zz9','','');
	cCdagedoc.css('width','50px').setMask('INTEGER','z.zz9','','');;
	
	cTodos.desabilitaCampo();
	cCdmotdev.habilitaCampo();
	
	highlightObjFocus( $('#'+formDados) );
	
	controlaFoco();
	layoutPadrao();
	controlaPesquisas();

	return false;
	
}

// Controle dos Campos
function controlaFoco() {
	
	cCdmotdev.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cNrdocmto.focus();
			return false;
		}
	});
	
	cNrdocmto.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDtmvtolt.focus();
			return false;
		}
	});
	
	cDtmvtolt.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cVldocmto.focus();
			return false;
		}
	});
	
	cVldocmto.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cCdagenci.focus();
			return false;
		}
	});
	
	cCdagenci.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cNrdconta.focus();
			return false;
		}
	});	
	
	cNrdconta.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cNmfavore.focus();
			return false;
		}
	});
	
	cNmfavore.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cNrcpffav.focus();
			return false;
		}
	});
	
	cNrcpffav.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cNrctadoc.focus();
			return false;
		}
	});
	
	cNrctadoc.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cNmemiten.focus();
			return false;
		}
	});
	
	cNmemiten.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cNrcpfemi.focus();
			return false;
		}
	});
	
	cNrcpfemi.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cCdbandoc.focus();
			return false;
		}
	});
	
	cCdbandoc.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cCdagedoc.focus();
			return false;
		}
	});
	
	cCdagedoc.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			$('#btSalvar','#divBotoes').focus();
			return false;
		}
	});

}

function controlaPesquisas() {

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#'+ formDados );

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {

		linkConta.prev().unbind('blur').bind('blur', function() { 
			controlaPesquisas();
			return false;
		});	
	
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaMotivo('cdmotdev', formDados, $('#divRotina') );
		});
	}

	return false;
}

function mostraPesquisaMotivo(campoRetorno, formRetorno, divBloqueia, fncFechar) {

	// Mostra mensagem de aguardo	
	showMsgAguardo('Aguarde, carregando Motivos de Devolu&ccedil;&atilde;o ...');	
	
	// Guardo o campoRetorno e o formRetorno em variáveis globais para serem utilizados na seleção do motivo
	vg_campoRetorno = campoRetorno;
	vg_formRetorno  = formRetorno;	
	
	$('.fecharPesquisa').click( function() {
		// 015 - Retirado tratamento do tipo do divBloqueia e acrescentado a fncFechar
		fechaRotina($('#divPesquisa'),divBloqueia,fncFechar);
	});	
	
	hideMsgAguardo();	
	exibeRotina($('#divPesquisa'));
	zebradoLinhaTabela($('#divPesquisaMotivoDevdoc > table > tbody > tr'));	
	$("#divResultadoPesquisaMotivo").css("height","160px");
	return false;
}

function selecionaMotivo(codmot) {	
	// Chama o evento click do botão fechar
	$('.fecharPesquisa').click();
	
	// Atribui codigo motivo consultada para campo e formulários contidos nas respectivas variáveis globais 
	$('#'+vg_campoRetorno,'#'+vg_formRetorno).val(codmot).formataDado('INTEGER','zz9','',false);
	
	$('#'+vg_campoRetorno,'#'+vg_formRetorno).trigger('change');
	
	// Da foco no campo
	$('#'+vg_campoRetorno,'#'+vg_formRetorno).focus();	
	
	return false;
	
}

function fechaDetalhe(){
	// Esconde div da rotina
	$("#divDetalheDoc").css("display","none");

	unblockBackground();
}

function btnSalvar(){
	
	atualizaSeletor();
	
	var operacao = "A";
	
	var nrdocmto = cNrdocmto.val();
	var dtmvtolt = cDtmvtolt.val();
	var vldocmto = cVldocmto.val();
	var cdbandoc = cCdbandoc.val();
	var cdagedoc = cCdagedoc.val();
	var nrctadoc = cNrctadoc.val();
	var cdmotdev = cCdmotdev.val();
	
	// codigos motivos possiveis
	if((cdmotdev != 51) && (cdmotdev != 52) && (cdmotdev != 53) && (cdmotdev != 56) && (cdmotdev != 57) &&
	   (cdmotdev != 58) && (cdmotdev != 59) && (cdmotdev != 62) && (cdmotdev != 66) && (cdmotdev != 67)){
		showError('error','C&oacute;digo do motivo inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'cdmotdev\',\'frmDetalheDoc\');bloqueiaFundo(divRotina);');
		return false;
	}
	
	showMsgAguardo('Aguarde, salvando ...');

	// Executa script de através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/devdoc/principal.php',
		data: {
			operacao : operacao,
			nrdocmto : nrdocmto,
			dtmvtolt : dtmvtolt,
			vldocmto : vldocmto,
			cdbandoc : cdbandoc,
			cdagedoc : cdagedoc,
			nrctadoc : nrctadoc,
			cdmotdev : cdmotdev,
			redirect : 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {

			if ( response.indexOf('showError("error"') == -1 ) {
                hideMsgAguardo();
				
				$('#divRotina').html(response);
				atualizaSeletor();
				controlaLayout();
				exibeRotina($('#divRotina'));
				return false;
			}	
		}
	});
}

// salvar os documentos marcados e nao marcados como devolucao
function btnContinuar(){
	
	var documtos = ""; 
	var devol    = "1";
	
	// pega os documentos nao checados
	$('input[type=checkbox]','#frmcheckdocs').each(function(){
		devol = "1";
		if($(this).is(":disabled")){
			return;
		}
		if($(this).is(":not(:checked)")){
			devol = "0";
		}
		if(documtos != ""){
			documtos = documtos + "*";
		}
		documtos = documtos + $(this).attr("name").replace("chkdevol","") + "|" + devol;
	});
	
	if(documtos != ""){
		showConfirmacao('Documentos desmarcados nao ser&atilde;o devolvidos.<br>Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','salvaDocs(\''+documtos+'\');','','sim.gif','nao.gif');
	}
	
	return false;
	
}

function salvaDocs(documtos){
	
	var operacao = "S";
	
	showMsgAguardo('Aguarde, salvando documentos ...');

	// Executa script de através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/devdoc/principal.php',
		data: {
			operacao : operacao,
			documtos : documtos,
			redirect : 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {

			if ( response.indexOf('showError("error"') == -1 ) {
                hideMsgAguardo();
				
				$('#divRotina').html(response);
				atualizaSeletor();
				controlaLayout();
				exibeRotina($('#divRotina'));
				return false;
			}	
		}
	});
}

function verDetalhe(trObj){

	var operacao  = "C";
	var variaveis = new Array();
	var nrdocmto  = 0;
	var dtmvtolt  = "";
	var vldocmto  = 0;
	var cdbandoc  = 0;
	var cdagedoc  = 0;
	var nrctadoc  = 0;
	var cdmotdev  = 0;
	var cTodosOpcao = "";
	
	cTodosOpcao  = $('input[type="text"], select', '#frmOpcao');
	variaveis = trObj.getAttribute("id").split("|");
	
	if (variaveis.length != 7){
		hideMsgAguardo();
		showError('error','Quantidade de Par&acirc;metros incorretos.','Alerta - Ayllos','hideMsgAguardo();');
		return false;
	}
	
	nrdocmto = variaveis[0];
	dtmvtolt = variaveis[1];
	vldocmto = variaveis[2];
	cdbandoc = variaveis[3];
	cdagedoc = variaveis[4];
	nrctadoc = variaveis[5];
	cdmotdev = variaveis[6];
	
	cTodosOpcao  = $('input[type="text"], select', '#frmOpcao');
	
	cTodosOpcao.removeClass('campoErro');

	showMsgAguardo('Aguarde, carregando DOC ...');

	// Executa script de através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/devdoc/principal.php',
		data: {
			operacao : operacao,
			nrdocmto : nrdocmto,
			dtmvtolt : dtmvtolt,
			vldocmto : vldocmto,
			cdbandoc : cdbandoc,
			cdagedoc : cdagedoc,
			nrctadoc : nrctadoc,
			cdmotdev : cdmotdev,
			redirect : 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {

			if ( response.indexOf('showError("error"') == -1 ) {
                hideMsgAguardo();
				
				$('#divRotina').html(response);
				return false;
			}	
		}
	});
}


// Busca devolucoes de documento
function BuscaDevDoc(nriniseq,nrregist) {
	
	var operacao = "D";
	glb_nriniseq = nriniseq;
	glb_nrregist = nrregist;
	
    showMsgAguardo("Aguarde, buscando DOC compensa&ccedil;&atilde;o...");

    $.ajax({
        type	: 'POST',
        url		: UrlSite + 'telas/devdoc/principal.php',
        dataType: 'html',
        data    :
                {
					operacao : operacao,
					nriniseq : glb_nriniseq,
					nrregist : glb_nrregist,
                    redirect : 'script_ajax'
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                },
        success : function(response) {
            try {
                if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                    try {
						$('#divConteudo').html(response);
						hideMsgAguardo();
						formataTabelaDevdoc();
                        
					} catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                    }
                } else {
                    try {
                        eval(response);
						$('#nrdconta','#'+frmCab).habilitaCampo();
                        return false;
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                    }
                }
            } catch(error) {
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
                hideMsgAguardo();
            }
        }
    });

    return false;
}

// Função para acessar opções da rotina
function acessaOpcaoAba(nriniseq, nrregist) {
	
	operacao = "";
	glb_nriniseq = nriniseq;
	glb_nrregist = nrregist;
	
	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando ...');

	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (!$('#linkAba' + id)) {
			continue;
		}

		if (id == i) { // Atribui estilos para foco da opção
			$('#linkAba' + id).attr('class','txtBrancoBold');
			$('#imgAbaEsq' + id).attr('src',UrlImagens + 'background/mnu_sle.gif');
			$('#imgAbaDir' + id).attr('src',UrlImagens + 'background/mnu_sld.gif');
			$('#imgAbaCen' + id).css('background-color','#969FA9');
			continue;
		}

		$('#linkAba' + i).attr('class','txtNormalBold');
		$('#imgAbaEsq' + i).attr('src',UrlImagens + 'background/mnu_nle.gif');
		$('#imgAbaDir' + i).attr('src',UrlImagens + 'background/mnu_nld.gif');
		$('#imgAbaCen' + i).css('background-color','#C6C8CA');
	}
	
	// Carrega conteúdo da opção através do Ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/principal.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nriniseq: glb_nriniseq,
			nrregist: glb_nrregist,
			operacao: operacao,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','1 N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
				bloqueiaFundo($('#divRotina'));
			} else {
				eval( response );
				controlaFoco( operacao );
			}
			return false;
		}
	});
}


// Formata Browse da Tela
function formataTabelaDevdoc() {

	// Tabela
	$('#tabDevdoc').css({'display':'block'});
    $('#divConteudo').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabDevdoc');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    $('#tabDevdoc').css({'margin-top':'5px'});
	divRegistro.css({'height':'200px','width':'800px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '23px';
	arrayLargura[1] = '26px';
	arrayLargura[2] = '42px';
	arrayLargura[3] = '65px';
	arrayLargura[4] = '70px';	
	arrayLargura[5] = '70px';
	arrayLargura[6] = '';
	arrayLargura[7] = '70px';
	arrayLargura[8] = '120px';

    var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'left';
	arrayAlinha[7] = 'center';
	arrayAlinha[8] = 'center';

	var metodoTabela = 'verDetalhe(this)';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	hideMsgAguardo();

	return false;
}