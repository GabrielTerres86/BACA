//************************************************************************//
//*** Fonte: cncart.js                                                 ***//
//*** Autor: Henrique                                                  ***//
//*** Data : Setembro/2010              Última Alteração:              ***//
//***                                                                  ***//
//*** Objetivo  : Biblioteca de funções da tela CNCART                 ***//
//***                                                                  ***//	 
//*** Alterações: 14/11/2011 - Realizado os ajustes:				   ***//
//***   					   - Criado paginação para a tabela        ***//
//***   					   - Alinhamento dos radiobox              ***//
//***   					   (Adriano).           				   ***//
//***             17/12/2012 - Ajuste para layout padrao (Daniel).     ***//
//***	                                                               ***//
//****			  10/05/2016 - Adicionado opcao para consultar pela    ***//
//****						   conta ITG conforme solicitado no		   ***//
//****					       chamado 445575. (Kelvin)				   ***//
//****																   ***//
//************************************************************************//

var detalhe      = new Array();
var strHTML      = '';
var ObjDetalhe   = new Object();

var frmCabCncart;

$(document).ready(function() {

	$('#frmCabCncart').fadeTo(0,0.1);
	
	frmCabCncart =  $('#frmCabCncart');
	
	$("#tabConteudo").css('display','block');
	$("#frmCabCncart").css('display','block');
	highlightObjFocus( $('#frmCabCncart') );

	$('input:radio','#frmCabCncart').change(function () { 
		tppesq = $("input:radio:checked",'#frmCabCncart').val();
		$('#dscartao','#frmCabCncart').val("");
		if (tppesq == 1) {
			$('#ttpesq','#frmCabCncart').css('padding-left','0px').html("N&uacute;mero do Cart&atilde;o:");
			$('#dscartao','#frmCabCncart').setMask('INTEGER','zzzz.zzzz.zzzz.zzzz','.','');
			$('#dscartao','#frmCabCncart').attr('alt','Informe o n&uacute;mero do cart&atilde;o');
		} else if (tppesq == 2) {
			$('#ttpesq','#frmCabCncart').css('padding-left','13px').html("Nome do Titular:");
			$('#dscartao','#frmCabCncart').setMask('STRING','xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx','','');
			$('#dscartao','#frmCabCncart').attr('alt','Informe o nome do titular');
		} else if (tppesq == 3) {
			$('#ttpesq','#frmCabCncart').css('padding-left','05px').html("Nome do Pl&aacute;stico:");
			$('#dscartao','#frmCabCncart').setMask('STRING','xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx','','');			
			$('#dscartao','#frmCabCncart').attr('alt','Informe o nome do pl&aacute;stico');
		} else if (tppesq == 4) {
			$('#ttpesq','#frmCabCncart').css('padding-left','05px').html("Conta ITG:");
			$('#dscartao','#frmCabCncart').setMask('INTEGER','z.zzz.zzz','.','');			
			$('#dscartao','#frmCabCncart').attr('alt','Digite o n&uacute;mero da conta ITG sem digito verificador');
		}
	});
	
	controlaLayout();	
	$('#tabConteudo').css('display','none');
	
	$('#dscartao','#frmCabCncart').focus();
	
	removeOpacidade('frmCabCncart');
	
});

function controlaLayout(){
	formataCabecalho();
	formataFormulario();
	formataMsgAjuda();
	layoutPadrao();
}

function formataCabecalho(){
	
	var cRadio  = $('input:radio','#frmCabCncart');
	var rTppesq = $('label[for="tppesq"]','#frmCabCncart');
	var btOK  	= $('#btOK', '#frmCabCncart');
	
	rTppesq.css('padding-left','29px').addClass('rotulo');
	
	cdscartao = $('#dscartao','#frmCabCncart');
	
	if($.browser.msie){
		cRadio.css('margin-top','3px');
	}else{
		cRadio.css('margin-top','4px');
	}
	
	cRadio.css('margin-left','8px');
	cRadio.css('margin-right','2px');
	cdscartao.css('width','230px');
	cdscartao.habilitaCampo();
	
	 // Se pressionar cdscartao
	cdscartao.unbind('keypress').bind('keypress', function(e) { 			
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			carrega_dados(1,30,1);
			btOK.focus();		
			return false;		
		}
	});		

	$('#nrcrcard','#frmCabCncart').prop("checked",true);
	$('#dscartao','#frmCabCncart').setMask('INTEGER','zzzz.zzzz.zzzz.zzzz','.','');
	
	
}

function formataFormulario() {
	
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0px 3px 5px 3px'});		
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});			
	
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table',divRegistro );	
	
	divRegistro.css({'height':'150px','border-bottom':'1px solid #777','padding-bottom':'2px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[1,0]];		
	
	var arrayLargura = new Array(); 
	arrayLargura[0] = '70px';
	arrayLargura[1] = '182px';
	arrayLargura[2] = '92px';		
	arrayLargura[3] = '30px';
	arrayLargura[4] = '50px';
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';	
	arrayAlinha[4] = 'center';	
	arrayAlinha[5] = 'right';	
		
	tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,'');		
	
	$('#tabConteudo').css('display','block');
	$('#divRegistrosRodape','#tabConteudo').formataRodapePesquisa();		
	
	// Formata campos
	$('#divCampos').css('padding-top','5px');
	$('#nmtitcrd','#divCampos').css('width','250px').desabilitaCampo();
	$('#cdagenci','#divCampos').css('width','30px').desabilitaCampo();
	
	$('#lnmtitcrd','#divCampos').css({'padding-left':'90px','padding-right':'2px'});
	$('#lcdagenci','#divCampos').css({'padding-left':'5px','padding-right':'2px'});
	
	layoutPadrao();		
	
	return false;
}

function carrega_dados(nriniseq, nrregist, idcampo){

	if( idcampo == 0) {
	if( $('#dscartao','#frmCabCncart').hasClass('campoTelaSemBorda') ){ return false; }
	}

	var tipopesq = $("input:radio:checked",'#frmCabCncart').val();
	var dscartao = $('#dscartao','#frmCabCncart').val();
	var flgpagin = true;
	
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
	
			
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		dataType: 'html',
		url: UrlSite + "telas/cncart/carrega_dados.php",
		data: {
			tipopesq: tipopesq,
			dscartao: dscartao,
			nriniseq: nriniseq,
			nrregist: nrregist,
			flgpagin: flgpagin,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#dscartao','#frmCabCncart').focus()");							
		},
		success: function(response) { 			
			hideMsgAguardo();			
			try {							
				eval(response);			
				
				$('a.paginacaoAnt').unbind('click').bind('click', function() {
					carrega_dados((nriniseq - nrregist),nrregist,1);
				
				});
				$('a.paginacaoProx').unbind('click').bind('click', function() {
					carrega_dados((nriniseq + nrregist),nrregist,1);
				});	
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.' + error.message + '.','Alerta - Ayllos','unblockBackground()');
			}			
		}		
	});	
}

function mostra_detalhes(id){

	$('#nmtitcrd','#divCampos').val(detalhe[id].nmtitcrd);
	$('#cdagenci','#divCampos').val(detalhe[id].cdagenci);
	$("#divBotoes").css('display','block');
	
	$('#nrcrcard','#frmCabCncart').desabilitaCampo();
	$('#nmprimtl','#frmCabCncart').desabilitaCampo();
	$('#nmtitcrd','#frmCabCncart').desabilitaCampo();
	$('#dscartao','#frmCabCncart').desabilitaCampo();
		
	
}

function formataMsgAjuda() {	

	var divMensagem = $('#divMsgAjuda');
	divMensagem.css({'border':'1px solid #ddd','background-color':'#eee','padding':'2px','height':'20px','margin':'7px 0px'});
	
	var spanMensagem = $('span','#divMsgAjuda');
	spanMensagem.css({'text-align':'left','font-size':'11px','float':'left','padding':'3px'});

	var botoesMensagem = $('input','#divMsgAjuda');
	botoesMensagem.css({'float':'right','padding-left':'2px'});		
	
	$('input,select').focus( function() {
		if ( $(this).attr('type') == 'image' ) {
			spanMensagem.html('');
		} else {
			spanMensagem.html($(this).attr('alt'));
		}
	});	
	
}

function Voltar(){
	controlaLayout();	
	$('#tabConteudo').css('display','none');
	$('#divBotoes').css('display','none');
	
	$('#ttpesq','#frmCabCncart').css('padding-left','0px').html("N&uacute;mero do Cart&atilde;o:");
	
	$('#nrcrcard','#frmCabCncart').habilitaCampo();
	$('#nmprimtl','#frmCabCncart').habilitaCampo();
	$('#nmtitcrd','#frmCabCncart').habilitaCampo();
	$('#dscartao','#frmCabCncart').habilitaCampo();
	return;
}

