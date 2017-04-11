/*!
 * FONTE        : avalis.js
 * CRIAÇÃO      : Gabriel Capoia (DB1) 
 * DATA CRIAÇÃO : 11/01/2013
 * OBJETIVO     : Biblioteca de funções da tela AVALIS
 * --------------
 * ALTERAÇÕES   : 23/07/2015 - Colocado função para quando for pressionado a tecla ESC - Jéssica (DB1).
 *                10/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * --------------
 */
 
 var nometela;

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmLocal   		= 'frmLocal';
var tabDados		= 'tabConinf';
var divTabela;

var nrdconta, nmprimtl,	nrcpfcgc, msgconta, nmdavali,
	cCddopcao, cTodosCabecalho, btnOK, rNrdconta, 
	rNmprimtl, rNrcpfcgc, rNmprimtl2, cNrdconta, cNmprimtl, cNrcpfcgc, cNmprimtl2;


$(document).ready(function() {	
	divTabela		= $('#divTabela');
	estadoInicial();			
	return false;
		
});

function carregaDados(){

	nrdconta = normalizaNumero( $('#nrdconta','#'+frmCab).val() );
	nrcpfcgc = normalizaNumero( $('#nrcpfcgc','#'+frmCab).val() );
	nmprimtl = $('#nmprimtl','#'+frmCab).val();
		
	return false;
}


// inicio
function estadoInicial() {

	$('#frmCab').fadeTo(0,0.1);
		
	$('#btSalvar','#divBotoes').show();
	$('#btVoltar','#divBotoes').hide();
	
	$('#'+frmCab).limpaFormulario();
			
	$('#divTabela').html('');
	
	formataCabecalho();
	
	removeOpacidade('frmCab');
			
	layoutPadrao();
				
	return false;
	
}

// formata
function formataCabecalho() {

	// cabecalho
	rNrdconta = $('label[for="nrdconta"]','#'+frmCab); 
	rNmprimtl = $('label[for="nmprimtl"]','#'+frmCab); 
	rNrcpfcgc = $('label[for="nrcpfcgc"]','#'+frmCab); 
		
	cNrdconta = $('#nrdconta','#'+frmCab); 
	cNmprimtl = $('#nmprimtl','#'+frmCab); 
	cNrcpfcgc = $('#nrcpfcgc','#'+frmCab); 
	
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);
	btnProsseguir		= $('#btSalvar','#divBotoes');
	
	//Label
	rNrdconta.addClass('rotulo').css({'width':'110px'});
	rNrcpfcgc.addClass('rotulo').css({'width':'110px'});
	rNmprimtl.addClass('rotulo-linha').css({'width':'85px'});
		
	//Campos
	cNrdconta.css({'width':'130px'}).addClass('conta pesquisa');
	cNrcpfcgc.css({'width':'130px','text-align':'right'}).addClass('inteiro').attr('maxlength','14');
	cNmprimtl.css({'width':'300px'});
		
	cTodosCabecalho.habilitaCampo();
	cNmprimtl.desabilitaCampo();
	highlightObjFocus( $('#frmCab') );
	
	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false;}		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
					
			$(this).removeClass('campoErro');
			cNrcpfcgc.focus();			
			return false;
		}
		
	});	

	cNrcpfcgc.unbind('keypress').bind('keypress', function(e){ 	
	
		//Aqui é verificado se existe uma mensagem de erro sendo apresentada. Se sim, 
		//deve ser abortado o evento keypress.
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
					
			$(this).removeClass('campoErro');
						
			var cpfCnpj = normalizaNumero($(this).val());
			
			if(cpfCnpj.length <= 11){	
				cNrcpfcgc.val(mascara(cpfCnpj,'###.###.###-##'));				
			}else{				
				cNrcpfcgc.val(mascara(cpfCnpj,'##.###.###/####-##'));				
			}
									
			btnProsseguir.click();
			return false;
			
		}
										
	});
	
	cNrdconta.focus();

    // Seta os valores caso tenha vindo do CRM
    if ($("#crm_inacesso","#frmCRM").val() == 1) {
        $("#nrdconta","#frmCab").val($("#crm_nrdconta","#frmCRM").val());
        $("#nrcpfcgc","#frmCab").val($("#crm_nrcpfcgc","#frmCRM").val());
    }
		
	layoutPadrao();
	controlaPesquisas();
	
	return false;	
}

// botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }		
	
	buscaContrato();
			
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;" >'+botao+'</a>&nbsp;');
	
	return false;
}

function buscaContrato() {
	
	showMsgAguardo('Aguarde, buscando Contrato...');
	
	cNrdconta.desabilitaCampo();
	cNrcpfcgc.desabilitaCampo();
					
	$('#btSalvar','#divBotoes').hide();
	$('#btVoltar','#divBotoes').show();
	
	$('input,select').removeClass('campoErro');
		
	carregaDados();
	
	msgconta = "";
			
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/'+nometela+'/busca_contrato.php', 
		data    :
				{ nrdconta	: nrdconta,
				  nmprimtl  : nmprimtl,
				  nrcpfcgc  : nrcpfcgc,
				  redirect: 'script_ajax'
				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nmprimtl\',\'#frmAvalis\').focus();');
				},
		success : function(response) {					
					hideMsgAguardo();
															
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTabela').html(response);
							verificaMsgconta();
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nmprimtl\',\'#frmAvalis\').focus();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nmprimtl\',\'#frmAvalis\').focus();');
						}
					}
					
				}
				
	});
}

function verificaMsgconta(){
	
	$('input,select').removeClass('campoErro');

	if ( msgconta == "" ){return false;}
		
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/'+nometela+'/mensagens.php', 
		data: {
			msgconta    : msgconta,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			exibeRotina($('#divRotina'));
			$('#divRotina').css({'width':'235px'});
			$('#divRotina').centralizaRotinaH();	
			$('#btVoltar','#divConteudo').focus();	
			return false;
		}				
	});	
	return false;
}

function formataTabela() {

	
	var divRegistro = $('div.divRegistros', divTabela );	

	
	var tabela      = $('table', divRegistro );

	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});
			
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '56px';
	arrayLargura[1] = '158px';
	arrayLargura[2] = '77px';
	arrayLargura[3] = '225px';
	arrayLargura[4] = '29px';
	

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'right';	
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	
	divTabela.css({'display':'block'});		
	
	cNrdconta.focus();	
	
	return false;
}


function controlaPesquisas() {

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhiscxa;	
	var nomeFormulario = 'frmCab';
	var divRotina = 'divTela';
		
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');

	// Atribui a classe lupa para os links de desabilita todos
	$('a','#'+nomeFormulario).addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	$('a','#'+nomeFormulario).each( function(i) {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
				
		$(this).unbind('click').bind('click', function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');

				if ( campoAnterior == 'nrdconta' ) {
					mostraPesquisaAssociado('nrdconta', frmCab );
					return false;
				}
				
				if ( campoAnterior == 'nrcpfcgc' ) {
					mostraAvalista();	
					return false;
				}
				
			}
		});
	});
		
	return false;
	
}

// contrato
function mostraAvalista() {
	
	showMsgAguardo('Aguarde, buscando ...');
		
	$('input,select').removeClass('campoErro');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/'+nometela+'/avalista.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			exibeRotina($('#divRotina'));
			formataAvalista();
			//buscaContrato();
			return false;
		}				
	});
	return false;
	
}

function buscaAvalista() {
		
	showMsgAguardo('Aguarde, buscando avalistas ...');
			
	$('input,select').removeClass('campoErro');
	
	var nmdavali = $('#nmdavali','#frmAvalis').val(); 
	
	cNmprimtl2.focus();
	cNmprimtl2.desabilitaCampo();
			
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/'+nometela+'/busca_avalista.php', 
		data: {
			nmdavali: nmdavali, 
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudo').html(response);					
					formataAvalista();
					return false;
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});
			
	return false;
}

function formataAvalista() {

	rNmprimtl2 = $('label[for="nmdavali"]','#frmAvalis'); 
	cNmprimtl2 = $('#nmdavali','#frmAvalis'); 
	
	//Label
	rNmprimtl2.addClass('rotulo').css({'width':'120px'});
		
	//Campos
	cNmprimtl2.css({'width':'300px'}).habilitaCampo();
			
	cNmprimtl2.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( $('#divRotina').css('visibility') == 'visible' ) { 
			// Se é a tecla ENTER, TAB
			if ( e.keyCode == 13  || e.keyCode == 9) {		
					
				$(this).removeClass('campoErro');
				cNmprimtl2.focus();
				buscaAvalista(); 
			    return false; 
			}
		}				
	});	
	
	var divRegistro = $('div.divRegistros','#divContrato');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'130px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '80px';
	arrayLargura[1] = '280px';
	
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';	
	
	var metodoTabela = 'selecionaAvalista();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

	// centraliza a divRotina
	$('#divRotina').css({'width':'525px'});
	$('#divConteudo').css({'width':'500px'});
	$('#divRotina').centralizaRotinaH();	
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	highlightObjFocus( $('#frmAvalis') );
	layoutPadrao();
	cNmprimtl2.focus();
			
	return false;
}

function selecionaAvalista() {
		
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cNrcpfcgc.val( $('#nrcpfcgc', $(this) ).val() ); 
				
			}	
		});
	}
	
	fechaRotina( $('#divRotina') );	
	buscaContrato();	

	return false;
}