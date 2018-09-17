/*!
 * FONTE        : gt0002.js
 * CRIAÇÃO      : Jéssica (DB1) 
 * DATA CRIAÇÃO : 19/09/2013
 * OBJETIVO     : Biblioteca de funções da tela GT0002
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */
 
 var nometela;

//Formulários e Tabela
var frmCab   	= 'frmCab';
var frmConsulta = 'frmConsulta';
var divTabela;


var cddopcao, cdcooper, nmrescop, cdconven, nmempres, nriniseq, nrregist, 
    cTodosCabecalho, btnOK, cTodosConsulta;

var rCddopcao, rCdcooper, rNmrescop, rCdconven, rNmempres,
	cCddopcao, cCdcooper, cNmrescop, cCdconven, cNmempres;
	
$(document).ready(function() {
	divTabela		= $('#divTabela');
		
	$('#divBotoes','#divTela').css({'display':'none'});
	$('#divBotoesConsulta','#divTela').css({'display':'none'});
	
	estadoInicial();
	nrregist = 50;
		
	return false;
		
});

function carregaDados(){

	cddopcao = $('#cddopcao','#'+frmCab).val();
	cdcooper = $('#cdcooper','#'+frmConsulta).val();
	cdconven = $('#cdconven','#'+frmConsulta).val();
			
	return false;
} //carregaDados

// inicio
function estadoInicial() {

	$('#frmCab').fadeTo(0,0.1);
		
	$('#divTabela').html('');
		
	formataCabecalho();
	formataConsulta();
	
	removeOpacidade('frmCab');

	return false;
	
}

// formata
function formataCabecalho() {
		
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
		
	btnOK				= $('#btnOK','#'+frmCab);
	
	//Cabecalho

	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);	
	cCddopcao			= $('#cddopcao','#'+frmCab);

	cTodosCabecalho.habilitaCampo();

	rCddopcao.addClass('rotulo').css({'width':'50px'});
	cCddopcao.css({'width':'515px'});

	cCddopcao.focus();

	btnOK.unbind('click').bind('click', function() {

		if ( divError.css('display') == 'block' ) { return false; }		

		cTodosCabecalho.removeClass('campoErro');	
		cCddopcao.desabilitaCampo();		

		controlaLayout();
        
		$('#divBotoesConsulta').css('display', 'block');
		
		//$('#divBotoesConsulta','#divTela').css({'display':'none'});
	});

	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
		if ( e.keyCode == 13) {
			btnOK.click();
			return false;
		}
	});

	$('#frmConsulta').css('display','none');

	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmConsulta') );

	layoutPadrao();

	cCddopcao.focus();

	return false;
}

function controlaLayout() {

	$('#frmConsulta').css('display','block');
	
	cCdcooper.focus();
	cNmrescop.desabilitaCampo();
	cNmempres.desabilitaCampo();
			
	return false;
}

function btnVoltar(op) {
	
	cTodosConsulta.removeClass('campoErro');

    switch (op) {

        case 1: // volta para opcao		
			$('#frmConsulta').limpaFormulario();
			$('#divBotoes','#divTela').css({'display':'none'});	
			$('#divBotoesConsulta','#divTela').css({'display':'none'});	
            estadoInicial();
        break;

        case 2: // volta para filtro
            $('#divTabela').css('display','none');

			$('#divBotoesConsulta','#divTela').css({'display':'block'});			

			cCdcooper.habilitaCampo();
			cCdconven.habilitaCampo();
			cCdcooper.focus();
        break;
    }
}

function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }

	btnOK.unbind('click').bind('click', function() {
		return false;
	});

	cCdcooper.desabilitaCampo();
	cCdconven.desabilitaCampo();	

	buscaGt0002(1);

	if (cddopcao == 'C') {
		$('#divBotoesConsulta','#divTela').css({'display':'none'});	
	}	
	
	$('#btVoltar','#divBotoes').focus();	
	
	return false;
}

function buscaGt0002(nriniseq) {
	
	showMsgAguardo('Aguarde, buscando Convenios...');

	carregaDados();

	cTodosConsulta.removeClass('campoErro');	
    
	
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/'+nometela+'/busca_gt0002.php', 
		data    :
				{ 
				  cddopcao  : cddopcao,	
				  cdcooper  : cdcooper,
				  cdconven  : cdconven,
				  nrregist  : nrregist,
				  nriniseq  : nriniseq,
				  redirect: 'script_ajax'				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');					
				},
		success : function(response) { 
					hideMsgAguardo();
					
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTabela').html(response);
							$('#btVoltar','#divBotoes').focus();
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					} else {
						try {
							eval( response );
							
							cCdcooper.habilitaCampo();
							cCdconven.habilitaCampo();
							$('#divBotoesConsulta','#divTela').css({'display':'block'});
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					}
					
				}
	}); 
}

function manterRotina() {
	
	showMsgAguardo('Aguarde efetuando operacao...');

	carregaDados();

    $('#cdcooper', '#frmConsulta').removeClass('campoErro');
	$('#cdconven', '#frmConsulta').removeClass('campoErro');
	
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/'+nometela+'/manter_rotina.php', 
		data    :
				{ 
				  cddopcao  : cddopcao,	
				  cdcooper  : cdcooper,
				  cdconven  : cdconven,
				  redirect  : 'script_ajax'					  
				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success : function(response) { 
					hideMsgAguardo();
					
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTabela').html(response);	
							
							$('#divBotoesConsulta','#divTela').css({'display':'none'});	
							
							if (cddopcao !== 'C') {
								$('#frmConsulta').limpaFormulario();
							}
							
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					}
					
				}
	});

}

function formataTabela() {

	var divRegistro = $('div.divRegistros', divTabela );	
	
	var tabela      = $('table', divRegistro );
	
	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});	
	divTabela.css({'padding-top':'10px'});	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '60px';
	arrayLargura[1] = '100px';
	arrayLargura[2] = '65px';
	arrayLargura[3] = '200px';
			
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'left';	
	arrayAlinha[4] = 'right';
	
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
			
	divTabela.css({'display':'block'});	
	
	
	return false;
}

function formataConsulta(){

	cTodosConsulta = $('input[type="text"],select','#divConsulta');
	
	rCdcooper = $('label[for="cdcooper"]','#divConsulta');
	rNmrescop = $('label[for="nmrescop"]','#divConsulta');
	rCdconven = $('label[for="cdconven"]','#divConsulta');
	rNmempres = $('label[for="nmempres"]','#divConsulta');
	
		
	cCdcooper = $('#cdcooper','#divConsulta');	
	cNmrescop = $('#nmrescop','#divConsulta');	
	cCdconven = $('#cdconven','#divConsulta');	
	cNmempres = $('#nmempres','#divConsulta');
	
	
	rCdcooper.css({'width':'125px'});
	rNmrescop.css({'width':'115px'});
	rCdconven.css({'width':'125px'});
	rNmempres.css({'width':'115px'});
	
	cCdcooper.css({'width':'40px'});
	cNmrescop.css({'width':'290px'});
	cCdconven.css({'width':'40px'});
	cNmempres.css({'width':'290px'});
				
	cTodosConsulta.habilitaCampo();
	cNmrescop.desabilitaCampo();		
	cNmempres.desabilitaCampo();
	
	cCdcooper.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
		if ( e.keyCode == 13) {
			cCdconven.select();
			return false;
		}
	});

	cCdconven.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
		if ( e.keyCode == 13) {
			btnContinuar();
			return false;
		}
	});
	
	layoutPadrao();

	return false;
}