/*!
 * FONTE        : lotprc.js
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 08/05/2013
 * OBJETIVO     : Biblioteca de funções da tela LOTPRC
 * --------------
 * ALTERAÇÕES   : 28/08/2013 - Ajuste para restringir maximo 5 avalistas. (Jorge)
 * 				
 * 				  29/10/2013 - Criado funcao Gera_Impressao() e ajustes de rotina. (Jorge)
 *                30/07/2018 - SCTASK0021664 Inclusão do campo vlperfin (percentual financiado) (Carlos)
 * --------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmOpcao		= 'frmOpcao';
var frmContaLote	= 'frmContaLote';
var frmCadLote		= 'frmCadLote';
	
var cddopcao = "C";
	
$(document).ready(function() {

	estadoInicial();
});

// inicio
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);

	// retira as mensagens	
	hideMsgAguardo();

	// formulario	
	formataCabecalho();
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	
	
	$("#divConteudo").hide();
	$('#'+frmOpcao).remove();
	$('#divBotoes').hide();
	
	$("#cddopcao","#frmCab").val( cddopcao );
	$("#cddopcao","#frmCab").habilitaCampo().focus();
	
	removeOpacidade('divTela');
}

// cabecalho
function formataCabecalho() {

	// Label
	rCddopcao = $('label[for="cddopcao"]', '#'+frmCab);
	rCddopcao.css({'width':'51px'}).addClass('rotulo');
	
	// Input
	cCddopcao = $('#cddopcao', '#'+frmCab);
	cCddopcao.css({'width':'400px'});
	
	cNrdolote = $('#nrdolote', '#frmOpcao');
	cNrdconta = $('#nrdconta', '#frmOpcao');
	
	// Outros	
	cTodosCabecalho  = $('input[type="text"], select', '#'+frmCab); 
	btnOK1			 = $('#btnOk1', '#'+frmCab); 
	cTodosCabecalho.desabilitaCampo();
	
	// Se clicar no botao OK
	btnOK1.unbind('click').bind('click', function() { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cCddopcao.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		cddopcao 	= cCddopcao.val();
		buscaOpcao();
		cCddopcao.desabilitaCampo();
		$('#divBotoes').show();
		
		return false;
			
	});	

	// opcao
	cCddopcao.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnOK1.click();
			return false;
		}
	});	
	
	cNrdolote.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if(cNrdconta.css('display') == "none"){
				btnContinuar();
			}else{
				cNrdconta.focus();
			}
			return false;
		}
	});

	cNrdconta.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnContinuar();
			return false;
		}
	});
	
	layoutPadrao();
	return false;	
}

//funcao que se tem acoes diretas
function opcoesDiretas(){
	
	var cddopcao = $("#cddopcao","#frmCab").val();
	
	showMsgAguardo('Aguarde, processando dados ...');
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/lotprc/principal.php', 
		data: {
			cddopcao: cddopcao,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			eval(response);
			formataCabecalho();
			cCddopcao.val(cddopcao);
			formataLayout(cddopcao);
			
			return false;
		}				
	});
}

//funcao que tem fases intermediarias
function opcoesIndiretas(){
	
	var cddopcao = $("#cddopcao","#frmCab").val();
	var nrdolote = $("#nrdolote","#frmOpcao").val();
	var nrdconta = normalizaNumero($("#nrdconta","#frmOpcao").val());
	
	showMsgAguardo('Aguarde, processando dados ...');
	
	$("#divConteudo").fadeTo(0,0.1);
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/lotprc/formulario_lotprc.php', 
		data: {
			cddopcao: cddopcao,
			nrdconta: nrdconta,
			nrdolote: nrdolote,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divConteudo').html(response);
			removeOpacidade('divConteudo');	
			cCddopcao.desabilitaCampo();				
			// limpa formulario
			cTodosOpcao	= $('input[type="text"], select', '#'+frmOpcao); 	
			cTodosOpcao.limpaFormulario().removeClass('campoErro');
		
			unblockBackground();
			hideMsgAguardo();
			formataCabecalho();
			cCddopcao.val(cddopcao);
			formataLayout(cddopcao);
			cNrdolote.focus();
			return false;
		}
	});
}

// opcao
function buscaOpcao() {
	
	var cddopcao = $("#cddopcao","#frmCab").val();
	var msgconfi = "";
	
	/* opcoes desabilitadas */
	if (cddopcao == "T"){
		showError('error','Esta opção se encontra desabilitada.','Alerta - Ayllos','estadoInicial();');
		return false;
	}
	
	if (cddopcao == "N"){
		
		showConfirmacao('Confirma abertura de novo lote?','Confirma&ccedil;&atilde;o - Ayllos','opcoesDiretas();','estadoInicial();','sim.gif','nao.gif');
		
	}else{
		opcoesIndiretas();
	}
	
}

function verificarContaLote() {

	var cddopcao = $('#cddopcao', '#'+frmCab).val();
	var nrdolote = $('#nrdolote', '#'+frmOpcao).val();
	var nrdconta = normalizaNumero( $('#nrdconta', '#'+frmOpcao).val() );
	var flgvalid = true;

	cTodosOpcao.removeClass('campoErro');

	var mensagem = 'Aguarde, verificando dados ...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/lotprc/principal.php', 
		data    : 
				{ 	
					cddopcao	: cddopcao,
					nrdolote 	: nrdolote,
					nrdconta	: nrdconta,
					flgvalid	: flgvalid,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();					
					showError('error','Não foi possível concluir a requisição #1.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) { 
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							eval(response);
							removeOpacidade("divConteudo");
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','Não foi possível concluir a requisição #2 '+error+'.','Alerta - Ayllos','estadoInicial()');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','Não foi possível concluir a requisição #3 '+error+'.','Alerta - Ayllos','estadoInicial()');
						}
					}
				}
	});

	return false;	
}

function continuarProcesso(){

	var cddopcao = $('#cddopcao', '#'+frmCab).val();
	var nrdolote = $('#nrdolote', '#'+frmOpcao).val();
	var nrdconta = normalizaNumero( $('#nrdconta', '#'+frmOpcao).val() );
	
	var vlprocap = $("#vlprocap","#"+frmContaLote).val();
    var dtvencnd = $("#dtvencnd","#"+frmContaLote).val();
    var cdmunben = $("#cdmunben","#"+frmContaLote).val();
    var cdgenben = $("#cdgenben","#"+frmContaLote).val();
    var cdporben = $("#cdporben","#"+frmContaLote).val();
    var cdsetben = $("#cdsetben","#"+frmContaLote).val();
	var dtcndfed = $("#dtcndfed","#"+frmContaLote).val();
	var dtcndfgt = $("#dtcndfgt","#"+frmContaLote).val();
	var dtcndest = $("#dtcndest","#"+frmContaLote).val();
	
    var dtcontrt = $("#dtcontrt","#"+frmCadLote).val();
	var dtpricar = $("#dtpricar","#"+frmCadLote).val();
    var dtfincar = $("#dtfincar","#"+frmCadLote).val();
    var dtpriamo = $("#dtpriamo","#"+frmCadLote).val();
    var dtultamo = $("#dtultamo","#"+frmCadLote).val();
    var cdmunbce = $("#cdmunbce","#"+frmCadLote).val();
    var cdsetpro = $("#cdsetpro","#"+frmCadLote).val();

    var vlperfin = $("#vlperfin","#"+frmCadLote).val();
	
	var lstavali = "";
	var countava = 0;
	
	if(cddopcao == "I" || cddopcao == "A"){
		$("input[type=checkbox]","#frmListAvali").each(function(){
			if(this.checked){
				lstavali = lstavali + this.value + "|"; 
				countava = countava + 1;
			}
		});
		
		if(countava > 5){
			showError('error','Selecione no máximo 5 avalistas.','Alerta - Ayllos','hideMsgAguardo();');
			return false;
		}
		if(lstavali.length > 0 ){
			lstavali = lstavali.substring(0,(lstavali.length - 1));
		}
	}
    
    // Validar percentual financiado
	if(cddopcao == "W") {
        cVlperfin = $('#vlperfin', '#'+frmCadLote);
        percent = parseFloat( cVlperfin.val().replace(',','.') );        
        
        if (validaPercentual(percent) == false) {
            return false;
        } else {
	cTodosOpcao.removeClass('campoErro');
        }
	}

	cTodosOpcao.removeClass('campoErro');

	var mensagem = 'Aguarde, verificando dados ...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/lotprc/principal.php', 
		data    : 
				{ 	
					cddopcao : cddopcao,
					nrdolote : nrdolote,
					nrdconta : nrdconta,
					vlprocap : vlprocap,
					dtvencnd : dtvencnd,
					cdmunben : cdmunben,
					cdgenben : cdgenben,
					cdporben : cdporben,
					cdsetben : cdsetben,
					dtcndfed : dtcndfed,
					dtcndfgt : dtcndfgt,
					dtcndest : dtcndest,
					dtcontrt : dtcontrt,
					dtpricar : dtpricar,
					dtfincar : dtfincar,
					dtpriamo : dtpriamo,
					dtultamo : dtultamo,
					cdmunbce : cdmunbce,
					cdsetpro : cdsetpro,
					lstavali : lstavali,
                    vlperfin : vlperfin,
					redirect : 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();					
					showError('error','Não foi possível concluir a requisição #1.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) { 
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							eval(response);
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','Não foi possível concluir a requisição #2 '+error+'.','Alerta - Ayllos','estadoInicial()');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','Não foi possível concluir a requisição #3 '+error+'.','Alerta - Ayllos','estadoInicial()');
						}
					}
				}
	});

	return false;
}


function consultarContaLote(){

	var cddopcao = $('#cddopcao', '#'+frmCab).val();
	var nrdolote = $('#nrdolote', '#'+frmOpcao).val();
	var nrdconta = normalizaNumero( $('#nrdconta', '#'+frmOpcao).val() );
	var flgvalid = false;
	
	cTodosOpcao.removeClass('campoErro');

	var mensagem = 'Aguarde, verificando dados ...';
	showMsgAguardo( mensagem );	
	
	if(cddopcao == "A" && $('#'+frmContaLote).css("display") == "none" ){
		flgvalid = true;
	}
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/lotprc/principal.php', 
		data    : 
				{ 	
					cddopcao : cddopcao,
					nrdolote : nrdolote,
					nrdconta : nrdconta,
					flgvalid : flgvalid,
					redirect : 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();					
					showError('error','Não foi possível concluir a requisição #1.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) { 
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							eval(response);
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','Não foi possível concluir a requisição #2 '+error+'.','Alerta - Ayllos','estadoInicial()');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','Não foi possível concluir a requisição #3 '+error+'.','Alerta - Ayllos','estadoInicial()');
						}
					}
				}
	});

	return false;
}


function consultarLote(){

	var cddopcao = $('#cddopcao', '#'+frmCab).val();
	var nrdolote = $('#nrdolote', '#'+frmOpcao).val();
	var flgdload = true;
	
	cTodosOpcao.removeClass('campoErro');

	var mensagem = 'Aguarde, verificando lote ...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/lotprc/principal.php', 
		data    : 
				{ 	
					cddopcao : cddopcao,
					nrdolote : nrdolote,
					flgdload : flgdload,
					redirect : 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();					
					showError('error','Não foi possível concluir a requisição #1.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) { 
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							eval(response);
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','Não foi possível concluir a requisição #2 '+error+'.','Alerta - Ayllos','estadoInicial()');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','Não foi possível concluir a requisição #3 '+error+'.','Alerta - Ayllos','estadoInicial()');
						}
					}
				}
	});

	return false;
}

function formataLayout(opcao){
	
	highlightObjFocus($('#'+frmOpcao));
	highlightObjFocus($('#'+frmContaLote));
	highlightObjFocus($('#'+frmCadLote));
	
	
	// label
	rNrdolote = $('label[for="nrdolote"]', '#'+frmOpcao);
	rNrdconta = $('label[for="nrdconta"]', '#'+frmOpcao);
	
	rVlprocap = $('label[for="vlprocap"]', '#'+frmContaLote);
	rDtvencnd = $('label[for="dtvencnd"]', '#'+frmContaLote);
	rCdmunben = $('label[for="cdmunben"]', '#'+frmContaLote);
	rCdgenben = $('label[for="cdgenben"]', '#'+frmContaLote);
	rCdporben = $('label[for="cdporben"]', '#'+frmContaLote);
	rCdsetben = $('label[for="cdsetben"]', '#'+frmContaLote);
	rDtcndfed = $('label[for="dtcndfed"]', '#'+frmContaLote);
	rDtcndfgt = $('label[for="dtcndfgt"]', '#'+frmContaLote);
	rDtcndest = $('label[for="dtcndest"]', '#'+frmContaLote);
	
	rDtcontrt = $('label[for="dtcontrt"]', '#'+frmCadLote);
	rDtpricar = $('label[for="dtpricar"]', '#'+frmCadLote);
	rDtfincar = $('label[for="dtfincar"]', '#'+frmCadLote);
	rDtpriamo = $('label[for="dtpriamo"]', '#'+frmCadLote);
	rDtultamo = $('label[for="dtultamo"]', '#'+frmCadLote);
	rCdmunbce = $('label[for="cdmunbce"]', '#'+frmCadLote);
	rCdsetpro = $('label[for="cdsetpro"]', '#'+frmCadLote);

    rVlperfin = $('label[for="vlperfin"]', '#'+frmCadLote);
	
	rNrdolote.css({'width':'35px'}).addClass('rotulo');
	rNrdconta.css({'width':'55px'}).addClass('rotulo-linha');
	
	rVlprocap.css({'width':'220px'}).addClass('rotulo');
	rDtvencnd.css({'width':'220px'}).addClass('rotulo-linha');
	rCdmunben.css({'width':'220px'}).addClass('rotulo');
	rCdgenben.css({'width':'220px'}).addClass('rotulo-linha');
	rCdporben.css({'width':'220px'}).addClass('rotulo');
	rCdsetben.css({'width':'220px'}).addClass('rotulo-linha');
	rDtcndfed.css({'width':'220px'}).addClass('rotulo');
	rDtcndfgt.css({'width':'220px'}).addClass('rotulo-linha');
	rDtcndest.css({'width':'220px'}).addClass('rotulo');
	
	rDtcontrt.css({'width':'230px'}).addClass('rotulo');
	rDtpricar.css({'width':'230px'}).addClass('rotulo');
	rDtfincar.css({'width':'260px'}).addClass('rotulo-linha');
	rDtpriamo.css({'width':'230px'}).addClass('rotulo');
	rDtultamo.css({'width':'260px'}).addClass('rotulo-linha');
	rCdmunbce.css({'width':'230px'}).addClass('rotulo');
	rCdsetpro.css({'width':'260px'}).addClass('rotulo-linha');

    rVlperfin.css({'width':'230px'}).addClass('rotulo');
	
	// input
	cNrdconta = $('#nrdconta', '#'+frmOpcao);
	cNrdolote = $('#nrdolote', '#'+frmOpcao);
	
	cVlprocap = $('#vlprocap', '#'+frmContaLote);
	cDtvencnd = $('#dtvencnd', '#'+frmContaLote);
	cCdmunben = $('#cdmunben', '#'+frmContaLote);
	cCdgenben = $('#cdgenben', '#'+frmContaLote);
	cCdporben = $('#cdporben', '#'+frmContaLote);
	cCdsetben = $('#cdsetben', '#'+frmContaLote);
	cDtcndfed = $('#dtcndfed', '#'+frmContaLote);
	cDtcndfgt = $('#dtcndfgt', '#'+frmContaLote);
	cDtcndest = $('#dtcndest', '#'+frmContaLote);
	
	cDtcontrt = $('#dtcontrt', '#'+frmCadLote);
	cDtpricar = $('#dtpricar', '#'+frmCadLote);
	cDtfincar = $('#dtfincar', '#'+frmCadLote);
	cDtpriamo = $('#dtpriamo', '#'+frmCadLote);
	cDtultamo = $('#dtultamo', '#'+frmCadLote);
	cCdmunbce = $('#cdmunbce', '#'+frmCadLote);
	cCdsetpro = $('#cdsetpro', '#'+frmCadLote);

    cVlperfin = $('#vlperfin', '#'+frmCadLote);
    
	cNrdconta.css({'width':'75px','text-align':'right'}).setMask('INTEGER','zzzz.zzz-z','.-','');
	cNrdolote.css({'width':'75px','text-align':'right'}).setMask('INTEGER','zzzzzzzz9','','');
	
	cVlprocap.css({'width':'75px','text-align':'right'}).addClass('monetario');
	cDtvencnd.css({'width':'75px','text-align':'right'}).setMask("DATE","","","");
	cCdmunben.css({'width':'75px','text-align':'right'}).setMask("INTEGER","zzzzzzz","","");
	cCdgenben.css({'width':'75px','text-align':'right'}).setMask("INTEGER","zzz","","");
	cCdporben.css({'width':'75px','text-align':'right'}).setMask("INTEGER","zz","","");
	cCdsetben.css({'width':'75px','text-align':'right'}).setMask("INTEGER","zzzzzzz","","");
	cDtcndfed.css({'width':'75px','text-align':'right'}).setMask("DATE","","","");
	cDtcndfgt.css({'width':'75px','text-align':'right'}).setMask("DATE","","","");
	cDtcndest.css({'width':'75px','text-align':'right'}).setMask("DATE","","","");
	
	cDtcontrt.css({'width':'75px','text-align':'right'}).setMask("DATE","","","");
	cDtpricar.css({'width':'75px','text-align':'right'}).setMask("DATE","","","");
	cDtfincar.css({'width':'75px','text-align':'right'}).setMask("DATE","","","");
	cDtpriamo.css({'width':'75px','text-align':'right'}).setMask("DATE","","","");
	cDtultamo.css({'width':'75px','text-align':'right'}).setMask("DATE","","","");
	cCdmunbce.css({'width':'75px','text-align':'right'}).setMask("INTEGER","zzzzzz","","");
	cCdsetpro.css({'width':'75px','text-align':'right'}).setMask("INTEGER","zzzzzzz","","");

    cVlperfin.css({'width':'75px','text-align':'right'}).addClass('monetario');    
	
	cNrdolote.focus();

	if(opcao == "F" || opcao == "W" || opcao == "L" || opcao == "G" || opcao == "Z" || opcao == "R"){
		rNrdconta.css({'display':'none'});
		cNrdconta.css({'display':'none'});
	}
	
	cVlprocap.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cDtvencnd.focus();
			return false;
		}
	});
	
	cDtvencnd.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cCdmunben.focus();
			return false;
		}
	});
	
	cCdmunben.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cCdgenben.focus();
			return false;
		}
	});
	
	cCdgenben.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cCdporben.focus();
			return false;
		}
	});
	
	cCdporben.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cCdsetben.focus();
			return false;
		}
	});
	
	cCdsetben.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cDtcndfed.focus();
			return false;
		}
	});
	
	cDtcndfed.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cDtcndfgt.focus();
			return false;
		}
	});
	
	cDtcndfgt.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cDtcndest.focus();
			return false;
		}
	});
	
	cDtcndest.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnContinuar();
			return false;
		}
	});
	
	
	//===========================================================
	
	cDtcontrt.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cDtpricar.focus();
			return false;
		}
	});
	
	cDtpricar.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cDtfincar.focus();
			return false;
		}
	});
	
	cDtfincar.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cDtpriamo.focus();
			return false;
		}
	});
	
	cDtpriamo.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cDtultamo.focus();
			return false;
		}
	});
	
	cDtultamo.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cCdmunbce.focus();
			return false;
		}
	});
	
	cCdmunbce.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cCdsetpro.focus();
			return false;
		}
	});
	
	cCdsetpro.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			//btnContinuar();
            cVlperfin.focus();
			return false;
		}
	});

	cVlperfin.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnContinuar();
			return false;
		}
	});
    
    // Valida Percentual sem Ônus
    cVlperfin.change(function () {			
        percent = parseFloat( cVlperfin.val().replace(',','.') );
        validaPercentual(percent);
    });	
    

	layoutPadrao();
	
	return false;
}

function validaPercentual(percent) {
    // Se maior do que 100, mostra mensagem de erro e retorna o foco no mesmo campo
    if ( percent < 80 || percent > 100 || isNaN(percent)) {
        showError('error','O percentual financiado deve estar entre 80% e 100%.','Alerta - Ayllos','focaCampoErro("vlperfin","frmCadLote");');
        return false;
    }    
}

// botoes
function btnVoltar() {

	var cddopcao = $("#cddopcao","#frmCab").val();
	
	if(((cddopcao == "A" || cddopcao == "I" || cddopcao == "C") && $("#"+frmContaLote).css("display") == "none") ||
	    (cddopcao == "W" && $("#"+frmCadLote).css("display") == "none") ||
		(cddopcao != "A" && cddopcao != "I" && cddopcao != "C" && cddopcao != "W")){
		estadoInicial()
	}else{
		$("#btVoltar","#divBotoes").show();
		$("#btnContinuar","#divBotoes").show();
		$("#"+frmContaLote).limpaFormulario().removeClass('campoErro').hide();
		$("#"+frmCadLote).limpaFormulario().removeClass('campoErro').hide();
		$("#divAvalista").html("").hide();
		$("#nrdconta","#frmOpcao").habilitaCampo();
		$("#nrdolote","#frmOpcao").habilitaCampo().focus();
	}
	
}

function btnContinuar(){
	
	var cddopcao = $("#cddopcao","#frmCab").val();
	var nrdolote = $("#nrdolote","#frmOpcao").val();
	var nrdconta = $("#nrdconta","#frmOpcao").val();	
	
	cTodosOpcao  = $('input[type="text"], select', '#frmOpcao');
	
	cTodosOpcao.removeClass('campoErro');
	
	if(cddopcao == "I"){
		if($("#"+frmContaLote).css("display") == "none"){
			if(!validaNumero(nrdolote,true,0,0)){
				showError('error','Número inválido!','Alerta - Ayllos','focaCampoErro("nrdolote","frmOpcao");'); 
				return false;
			}
			if (!validaNroConta(nrdconta)){
				showError('error','Conta/DV inválida!','Alerta - Ayllos','focaCampoErro("nrdconta","frmOpcao");'); 
				return false;
			}
			verificarContaLote(); // valida se conta e lote existem e verifica se a conta ja existe cadastrada no lote
		}else{
			continuarProcesso();
		}
	}else if(cddopcao == "C" || cddopcao == "A"){
		if($("#"+frmContaLote).css("display") == "none"){
			if(!validaNumero(nrdolote,true,0,0)){
				showError('error','Número inválido!','Alerta - Ayllos','focaCampoErro("nrdolote","frmOpcao");'); 
				return false;
			}
			if (!validaNroConta(nrdconta)){
				showError('error','Conta/DV inválida!','Alerta - Ayllos','focaCampoErro("nrdconta","frmOpcao");'); 
				return false;
			}
			if (cddopcao == "C"){
				$("#btnContinuar","#divBotoes").hide();
			}
			consultarContaLote();
		}else{
			continuarProcesso();
		}
	}else if(cddopcao == "E"){
		if(!validaNumero(nrdolote,true,0,0)){
			showError('error','Número inválido!','Alerta - Ayllos','focaCampoErro("nrdolote","frmOpcao");'); 
			return false;
		}
		if (!validaNroConta(nrdconta)){
			showError('error','Conta/DV inválida!','Alerta - Ayllos','focaCampoErro("nrdconta","frmOpcao");'); 
			return false;
		}
		showConfirmacao('Confirma exclusão de Conta/DV '+nrdconta+' no Lote nº '+nrdolote+' ?','Confirma&ccedil;&atilde;o - Ayllos','continuarProcesso();','','sim.gif','nao.gif');
		
	}else if(cddopcao == "W"){        
        
		if($("#"+frmCadLote).css("display") == "none"){
			if(!validaNumero(nrdolote,true,0,0)){
				showError('error','Número inválido!','Alerta - Ayllos','focaCampoErro("nrdolote","frmOpcao");'); 
				return false;
			}
			consultarLote(); // valida se lote existe e carrega a capa do lote
		}else{
			continuarProcesso();
		}
		
	}else if(cddopcao == "F"){
		if(!validaNumero(nrdolote,true,0,0)){
			showError('error','Número inválido!','Alerta - Ayllos','focaCampoErro("nrdolote","frmOpcao");'); 
			return false;
		}
		showConfirmacao('Confirma fechamento do Lote nº '+nrdolote+' ?','Confirma&ccedil;&atilde;o - Ayllos','continuarProcesso();','','sim.gif','nao.gif');
	}else if(cddopcao == "L"){
		if(!validaNumero(nrdolote,true,0,0)){
			showError('error','Número inválido!','Alerta - Ayllos','focaCampoErro("nrdolote","frmOpcao");'); 
			return false;
		}
		showConfirmacao('Confirma reabertura do Lote nº '+nrdolote+' ?','Confirma&ccedil;&atilde;o - Ayllos','continuarProcesso();','','sim.gif','nao.gif');
	}else if(cddopcao == "Z"){
		if(!validaNumero(nrdolote,true,0,0)){
			showError('error','Número inválido!','Alerta - Ayllos','focaCampoErro("nrdolote","frmOpcao");'); 
			return false;
		}
		showConfirmacao('Confirma finalização do Lote nº '+nrdolote+' ?','Confirma&ccedil;&atilde;o - Ayllos','continuarProcesso();','','sim.gif','nao.gif');
	}else if(cddopcao == "G"){
		if(!validaNumero(nrdolote,true,0,0)){
			showError('error','Número inválido!','Alerta - Ayllos','focaCampoErro("nrdolote","frmOpcao");'); 
			return false;
		}
		showConfirmacao('Confirma geração do arquivo de encaminhamento ao BRDE do Lote nº '+nrdolote+' ?','Confirma&ccedil;&atilde;o - Ayllos','continuarProcesso();','','sim.gif','nao.gif');
	}else if(cddopcao == "R"){
		if(!validaNumero(nrdolote,true,0,0)){
			showError('error','Número inválido!','Alerta - Ayllos','focaCampoErro("nrdolote","frmOpcao");'); 
			return false;
		}
		showConfirmacao('Confirma geração do Relatório do Lote nº '+nrdolote+' ?','Confirma&ccedil;&atilde;o - Ayllos','continuarProcesso();','','sim.gif','nao.gif');
	}
}

function formataTabela() {

	/*****************************
			FORMATA TABELA		
	******************************/
	
	// tabela	
	var divRegistro = $('div.divRegistros', '#frmListAvali');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'100px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
			
	var arrayLargura = new Array();
	arrayLargura[0] = '20px';
	arrayLargura[1] = '100px';
	arrayLargura[2] = '100px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );
	
	layoutPadrao();
	
	return false;
}

// imprimir
function Gera_Impressao(arquivo) {	
	
	$('#nmarquiv', '#frmImprimir').val( arquivo );
	
	var action = UrlSite + 'telas/lotprc/imprimir_dados.php';
	
	carregaImpressaoAyllos("frmImprimir",action);
	
}
