/*!
 * FONTE        : beinss.js
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 31/05/2011
 * OBJETIVO     : Biblioteca de funções da tela BEINSS
 * --------------
 * ALTERAÇÕES   : 18/12/2012 - Ajuste layout tela, inclusao efeito highlightObjFocus (Daniel).
 *                12/08/2013 - Alteração da sigla PAC para PA. (Carlos)
 * --------------
 */

// Definição de algumas variáveis globais 
var frmBeinss		= 'frmBeinss';
var frmPeriodo		= 'frmPeriodo';
var frmProcurador	= 'frmProcurador';

// Beinss
var nrprocur 		= 0;
var nrcpfcgc 		= 0;
var cdagenci 		= 0;
var nmrecben 		= ''; 

var n				= 0;


$(document).ready(function() {

	controlaLayout('1');	
	
	return false;
});


function controlaLayout(operacao) {

	$('#divTela').fadeTo(0,0.1);
	
	highlightObjFocus( $('#divTela') );
	highlightObjFocus( $('#frmBeinss') );
	
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('#divBotoes').css({'text-align':'center','padding-top':'5px'});
	$('#frmBeinss > fieldset:eq(0)').css({'border-left':'0','border-right':'0','margin':'3px 0px','padding':'3px 3px 5px 3px'});

	switch(operacao) {
	
		// estado inicial
		case '1':
			formataBeinss();
			controlaFoco(operacao);
		break;
		
		// busca beneficiarios
		case '2':
			formataTabBeneficiarios(1,30);
			controlaFoco(operacao);
		break;
		
		// busca periodo
		case '3':
			formataPeriodo(operacao);
			controlaFoco(operacao);
		break;
		
		// busca beneficios
		case '4':
			formataTabBeneficios();
			controlaFoco(operacao);
		break;

		// voltar
		case '5':
			if ( $('#dtdinici','#'+frmPeriodo).hasClass('campoTelaSemBorda') ) { 
				$('#divTabBeneficios').html('');
				$('#dtdinici','#'+frmPeriodo).habilitaCampo().focus();
				$('#dtdfinal','#'+frmPeriodo).habilitaCampo();
				
			} else {
				divRegistro = $('div.divRegistros','#divBeinss');
				$('table', divRegistro).zebraTabela( n );
				$('#divBeinss').css({'display':'block'});
				$('#divPeriodo').css({'display':'none'});

			}
		break;
		
	}
	
	layoutPadrao();
	controlaPesquisas();
	removeOpacidade('divTela');
	return false;
	
}

function controlaPesquisas() {

	/*---------------------*/
	/*  CONTROLE PA  	   */
	/*---------------------*/
	var linkPac = $('a:eq(0)','#'+frmBeinss);

	if ( linkPac.prev().hasClass('campoTelaSemBorda') ) {		
		linkPac.addClass('lupa').css('cursor','auto').unbind('click');
	} else {
		linkPac.css('cursor','pointer').unbind('click').bind('click', function() {			
			bo			= 'b1wgen0059.p';
			procedure	= 'busca_pac';
			titulo      = 'Agência PA';
			qtReg		= '20';
			filtrosPesq	= 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
			colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
		});
	}
						
	// controle das busca descrições
	linkPac.prev().unbind('change').bind('change',function() {		
		bo			= 'b1wgen0059.p';
		procedure	= 'busca_pac';
		titulo      = 'Agência PA';
		filtrosDesc = 'cdagepac|'+$(this).val();
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'nmresage',$(this).val(),'dsagepac',filtrosDesc,frmBeinss);
		return false;
	});	
	
	linkPac.prev().unbind('blur').bind('blur',function() {	controlaPesquisas(); return false; });

	return false;
}

function controlaFoco(operacao) {

	if (operacao == '1') {
		$('#nrprocur','#'+frmBeinss).focus();
		
	} else if (operacao == '2') {
	
	} else if (operacao == '3') {
		$('#dtdinici','#'+frmPeriodo).focus();	
	}
	
	return false;

}



// beneficiarios
function formataBeinss() {

	// limpa formulario
	$('#'+frmBeinss).limpaFormulario();
	
	// remove erros
	$('input','#'+frmBeinss).removeClass("campoErro");

	//
	$('#divBeinss').css({'display':'block'});
	$('#divTabBeneficiarios', '#divBeinss').html('');
	$('#divPeriodo').css({'display':'none'});

	// label
	rNrprocur  	= $('label[for="nrprocur"]','#'+frmBeinss);	
	rNrcpfcgc	= $('label[for="nrcpfcgc"]','#'+frmBeinss);	
	rCdagenci	= $('label[for="cdagenci"]','#'+frmBeinss);	
	rNmresage	= $('label[for="nmresage"]','#'+frmBeinss);	
	rNmrecben	= $('label[for="nmrecben"]','#'+frmBeinss);	

	rDtnasben  	= $('label[for="dtnasben"]', '#'+frmBeinss);
	rNmmaeben  	= $('label[for="nmmaeben"]', '#'+frmBeinss);
	rDsendben  	= $('label[for="dsendben"]', '#'+frmBeinss);
	rNmbairro  	= $('label[for="nmbairro"]', '#'+frmBeinss);
	rNrcepend  	= $('label[for="nrcepend"]', '#'+frmBeinss);
	rDtatuend  	= $('label[for="dtatuend"]', '#'+frmBeinss);

	rNrprocur.addClass('rotulo').css({'margin-left':'4px'});
	rNrcpfcgc.addClass('rotulo-linha');
	rCdagenci.addClass('rotulo-linha');
	rNmresage.addClass('rotulo-linha');
	rNmrecben.addClass('rotulo').css({'width':'35px','margin-left':'7px'});
	
	rDtnasben.addClass('rotulo').css({'width':'75px'});
	rNmmaeben.addClass('rotulo-linha').css({'width':'70px'});
	rDsendben.addClass('rotulo').css({'width':'75px'});
	rNmbairro.addClass('rotulo').css({'width':'75px'});
	rNrcepend.addClass('rotulo-linha').css({'width':'33px'});
	rDtatuend.addClass('rotulo-linha').css({'width':'88px'});
	
	// campos
	cTodos	  	= $('input','#'+frmBeinss);
	cNrprocur  	= $('#nrprocur','#'+frmBeinss);
	cNrcpfcgc   = $('#nrcpfcgc','#'+frmBeinss);	
	cCdagenci   = $('#cdagenci','#'+frmBeinss);	
	cNmresage   = $('#nmresage','#'+frmBeinss);	
	cNmrecben   = $('#nmrecben','#'+frmBeinss);	

	cDtnasben  	= $('#dtnasben', '#'+frmBeinss);
	cNmmaeben  	= $('#nmmaeben', '#'+frmBeinss);
	cDsendben  	= $('#dsendben', '#'+frmBeinss);
	cNmbairro  	= $('#nmbairro', '#'+frmBeinss);
	cNrcepend  	= $('#nrcepend', '#'+frmBeinss);
	cDtatuend  	= $('#dtatuend', '#'+frmBeinss);

	cTodos.desabilitaCampo();
	cNrprocur.css({'width':'105px','text-align':'right'}).attr('maxlength','11');
	cNrcpfcgc.addClass('cpf').css('width','150px');
	cCdagenci.addClass('pesquisa').css('width','30px').attr('maxlength','3');;
	cNmresage.css('width','225px');
	cNmrecben.css('width','560px').attr('maxlength','28');

	cDtnasben.addClass('data').css({'width':'80px'});
	cNmmaeben.css({'width':'400px'}).attr('maxlength','40');
	cDsendben.css({'width':'555px'}).attr('maxlength','60');
	cNmbairro.css({'width':'240px'}).attr('maxlength','17');
	cNrcepend.addClass('cep').css({'width':'80px'});
	cDtatuend.addClass('data').css({'width':'102px'});

	cNrprocur.habilitaCampo();
	cNmrecben.next().removeProp('disabled');	

	if ( $.browser.msie ) {
		rNmrecben.addClass('rotulo').css({'width':'37px'});
		cNmresage.css('width','220px');
		cNmrecben.css('width','555px');
		cNmmaeben.css({'width':'402px'});
		cDtatuend.css({'width':'108px'});
	}	

	// Se pressionar NB/NIT
	cNrprocur.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 || e.keyCode == 112) {
			if ($(this).val() == 0) {
				$(this).desabilitaCampo().val('0');
				cNrcpfcgc.habilitaCampo();
				cNrcpfcgc.focus();

			} else if ($(this).val() != 0) {
				filtroBeneficiarios();
				buscaBeneficiarios(1,30);
			}
		
			return false;
		
		}

	});		
	
	// Se pressionar CPF
	cNrcpfcgc.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13  || e.keyCode == 112) {
			if ($(this).val() == 0) {
				$(this).desabilitaCampo().val('0');
				cCdagenci.habilitaCampo();
				cNmrecben.habilitaCampo();
				cCdagenci.focus();

			} else if ($(this).val() != 0) {
				filtroBeneficiarios();
				buscaBeneficiarios(1,30);

			}

			controlaPesquisas();
			return false;

		}

	});
	
	// Se pressionar PA
	cCdagenci.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		

		if ( e.keyCode == 13  || e.keyCode == 112 ) {
			if ($(this).val() == 0) {
				$(this).val('0');
				// cNmrecben.habilitaCampo();
				cNmrecben.focus();
				
			} else if ($(this).val() != 0) {
				bo			= 'b1wgen0059.p';
				procedure	= 'busca_pac';
				titulo      = 'Agência PA';
				filtrosDesc = 'cdagepac|'+$(this).val();
				buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'nmresage',$(this).val(),'dsagepac',filtrosDesc,frmBeinss);
				
				// cNmrecben.habilitaCampo();
				cNmrecben.focus();
					
			}

			controlaPesquisas();
			return false;
		
		}
		
	});


	// Se pressionar NOME
	cNmrecben.unbind('keypress').bind('keypress', function(e) { 	
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 || e.keyCode == 112 ) {
			filtroBeneficiarios();
			buscaBeneficiarios(1,30);
			return false;
		}	
	
	});


	// Se pressionar BOTAO OK
	cNmrecben.next().unbind('click').bind('click', function() { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cNmrecben.hasClass('campoTelaSemBorda') ){ return false; }
		filtroBeneficiarios();
		buscaBeneficiarios(1,30);
		return false;

	});	
	
	
	// Periodo Inicial e Final
	
	$('#dtdinici','#frmPeriodo').unbind('keypress').bind('keypress', function(e) {
	if ( e.keyCode == 9 || e.keyCode == 13 ) {
		$('#dtdfinal','#frmPeriodo').focus();
		return false;
	}	
	});
	
	$('#dtdfinal','#frmPeriodo').unbind('keypress').bind('keypress', function(e) {
	if ( e.keyCode == 9 || e.keyCode == 13 ) {
		$('#btSalvar','#frmPeriodo').focus();
		return false;
	}	
	});

	return false;	
	
}

function formataTabBeneficiarios(){
			
	var divRegistro = $('div.divRegistros','#divBeinss');		
	var tabela      = $('table', divRegistro );
			
	divRegistro.css({'height':'150px','width':'640px'});
	
	selecionaBeinss($('table > tbody > tr:eq(0)', divRegistro));
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
			
	var arrayLargura = new Array();
	arrayLargura[0] = '250px';
	arrayLargura[1] = '75px';
	arrayLargura[2] = '65px';
	arrayLargura[3] = '118px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaLayout(\'3\')' );

	// seleciona o registro que tem focu 
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaBeinss($(this));
	
	});
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaBeinss($(this));

	});	

	hideMsgAguardo();
	return false;
}

function filtroBeneficiarios() {
	
	// desabilita todos os campos do cabecalho
	$('input','#'+frmBeinss).desabilitaCampo();
	$('#nmrecben','#'+frmBeinss).next().prop('disabled',true);
	
	// atribui os valores as variaveis globais que serao utilizadas na busca
	nrprocur = normalizaNumero($('#nrprocur','#'+frmBeinss).val());
	nrcpfcgc = normalizaNumero($('#nrcpfcgc','#'+frmBeinss).val());
	cdagenci = normalizaNumero($('#cdagenci','#'+frmBeinss).val());
	nmrecben = $('#nmrecben','#'+frmBeinss).val(); 
}

function buscaBeneficiarios( nriniseq , nrregist ){
		
	showMsgAguardo('Aguarde, buscando beneficiários...');
			
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/beinss/busca_beneficiarios.php', 
		data: {
			nrprocur: nrprocur, nrcpfcgc: nrcpfcgc,
			cdagenci: cdagenci, nmrecben: nmrecben,
			nriniseq: nriniseq, nrregist: nrregist,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();controlaLayout(\'1\');");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divTabBeneficiarios').html(response);
					controlaLayout('2');
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();controlaLayout(\'1\');');
				}
			} else {
				try {
					eval( response );
					controlaFoco();
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();controlaLayout(\'1\');');
				}
			}
		
		
			
		}				
	});
	return false;
}

function selecionaBeinss(tr){ 

	$('#nrcpfcgc','#'+frmBeinss).val( $('#nrcpfcgc', tr ).val() );
	$('#cdagenci','#'+frmBeinss).val( $('#cdagenci', tr ).val() );
	$('#nmresage','#'+frmBeinss).val( $('#nmresage', tr ).val() );
	$('#nmrecben','#'+frmBeinss).val( $('#nmrecben', tr ).val() );
	$('#dtnasben','#'+frmBeinss).val( $('#dtnasben', tr ).val() );
	$('#nmmaeben','#'+frmBeinss).val( $('#nmmaeben', tr ).val() );
	$('#dsendben','#'+frmBeinss).val( $('#dsendben', tr ).val() );
	$('#nmbairro','#'+frmBeinss).val( $('#nmbairro', tr ).val() );
	$('#nrcepend','#'+frmBeinss).val( $('#nrcepend', tr ).val() );
	$('#dtatuend','#'+frmBeinss).val( $('#dtatuend', tr ).val() );

	return false;
}


// periodo
function formataPeriodo() {

	$('#divPeriodo').css({'display':'block','width':'600px'});
	$('#frmPeriodo').limpaFormulario();
	selecionaPeriodo();
	$('#divBeinss').css({'display':'none'});
	
		
	// rotulo
	rDtdinici = $('label[for="dtdinici"]','#'+frmPeriodo);	
	rDtdfinal = $('label[for="dtdfinal"]','#'+frmPeriodo);	
	rNrcpfcgc = $('label[for="nrcpfcgc"]','#'+frmPeriodo);	
	rNmrecben = $('label[for="nmrecben"]','#'+frmPeriodo);
	rNrbenefi = $('label[for="nrbenefi"]','#'+frmPeriodo); // nb
	rNrrecben = $('label[for="nrrecben"]','#'+frmPeriodo); // nit

	rDtdinici.addClass('rotulo').css({'width':'40px'});	
	rDtdfinal.addClass('rotulo-linha').css({'width':'40px'});	
	rNrcpfcgc.addClass('rotulo').css({'width':'40px'});
	rNmrecben.addClass('rotulo-linha').css({'width':'40px'});
	rNrbenefi.addClass('rotulo').css({'width':'40px'});
	rNrrecben.addClass('rotulo-linha').css({'width':'40px'});
	
	
	// campos
	cTodos 	  = $('input','#'+frmPeriodo); 
	cDtdinici = $('#dtdinici','#'+frmPeriodo); 
	cDtdfinal = $('#dtdfinal','#'+frmPeriodo);
	cNrcpfcgc = $('#nrcpfcgc','#'+frmPeriodo);
	cNmrecben = $('#nmrecben','#'+frmPeriodo);
	cNrbenefi = $('#nrbenefi','#'+frmPeriodo); // nb
	cNrrecben = $('#nrrecben','#'+frmPeriodo); // nit

	cTodos.habilitaCampo();
	cDtdinici.addClass('data').css({'width':'100px'});
	cDtdfinal.addClass('data').css({'width':'100px'});
	cNrcpfcgc.addClass('cpf').css({'width':'100px'}).desabilitaCampo();
	cNmrecben.css({'width':'385px'}).desabilitaCampo();
	cNrbenefi.css({'width':'100px','text-align':'right'}).desabilitaCampo();
	cNrrecben.css({'width':'100px'}).desabilitaCampo();

	// Se pressionar BOTAO OK
	cDtdfinal.next().unbind('click').bind('click', function() { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cDtdfinal.hasClass('campoTelaSemBorda') ){ return false; }
		buscaBeneficios();
		return false;

	});	
	
}

function formataTabBeneficios(){
			
	var divRegistro = $('div.divRegistros','#divPeriodo');		
	var tabela      = $('table', divRegistro );

	formataProcurador();
	divRegistro.css({'height':'150px','width':'590px'});
	selecionaBeneficio($('table > tbody > tr:eq(0)', divRegistro));
    
	var divBeneficiosMais = $('#divBeneficiosMais');
	divBeneficiosMais.css({'border':'1px solid #ddd','background-color':'#eee','padding':'5px 2px 2px 2px','height':'20px','margin':'2px 0px'});	

	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
			
	var arrayLargura = new Array();
	arrayLargura[0] = '70px'; 
	arrayLargura[1] = '62px'; 
	arrayLargura[2] = '62px'; 
	arrayLargura[3] = '63px'; 
	arrayLargura[4] = '116px'; 
	arrayLargura[5] = '62px'; 
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	// seleciona o registro que tem focu 
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaBeneficio($(this));
	
	});
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaBeneficio($(this));

	});	

	hideMsgAguardo();
	return false;
}

function buscaBeneficios(){
		
	showMsgAguardo('Aguarde, buscando benefício...');
	
	var dtdinici = $('#dtdinici','#'+frmPeriodo).val();
	var dtdfinal = $('#dtdfinal','#'+frmPeriodo).val();
	var nrbenefi = $('#nrbenefi','#'+frmPeriodo).val();
	var nrrecben = $('#nrrecben','#'+frmPeriodo).val();
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/beinss/busca_beneficios.php', 
		data: {
			dtdinici: dtdinici, dtdfinal:dtdfinal,
			nrbenefi: nrbenefi, nrrecben: nrrecben,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();controlaLayout(\'3\');");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divTabBeneficios').html(response);
					controlaLayout('4');
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();controlaLayout(\'3\');');
				}
			} else {
				try {
					eval( response );
					controlaFoco();
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();controlaLayout(\'3\');');
				}
			}
		
		
			
		}				
	});
	return false;
}

function selecionaPeriodo() {

	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function(i) {
			if ( $(this).hasClass('corSelecao') ) {
				n = i;
				$('#nrbenefi','#'+frmPeriodo).val( $('#nrbenefi', $(this) ).val() );
				$('#nrcpfcgc','#'+frmPeriodo).val( $('#nrcpfcgc', $(this) ).val() );
				$('#nmrecben','#'+frmPeriodo).val( $('#nmrecben', $(this) ).val() );
				$('#nrrecben','#'+frmPeriodo).val( $('#nrrecben', $(this) ).val() );
			}
		});
	}

}

function selecionaBeneficio(tr){

	$('#flgcredi','#divBeneficiosMais').html( $('#flgcredi', tr ).val() );
	$('#dtflgcre','#divBeneficiosMais').html( $('#dtflgcre', tr ).val() );
	$('#cdagenci','#divBeneficiosMais').html( $('#cdagenci', tr ).val() );
	$('#dsespeci','#divBeneficiosMais').html( $('#dsespeci', tr ).val() );
	$('#flgcredi','#divBeneficiosMais').html( $('#flgcredi', tr ).val() );

	if ($('#flgexist', tr ).val() == 'yes') {

		$('#'+frmProcurador).css({'display':'block'});

		$('#nmprocur','#'+frmProcurador).val( $('#nmprocur', tr ).val() );
		$('#dsdocpcd','#'+frmProcurador).val( $('#dsdocpcd', tr ).val() );
		$('#cdoedpcd','#'+frmProcurador).val( $('#cdoedpcd', tr ).val() );
		$('#cdufdpcd','#'+frmProcurador).val( $('#cdufdpcd', tr ).val() );
		$('#dtvalprc','#'+frmProcurador).val( $('#dtvalprc', tr ).val() );
		
	} else {
		$('#'+frmProcurador).css({'display':'none'});
	}
	
	return false;
}


//procurador
function formataProcurador() {

	$('#'+frmProcurador).css({'display':'none'});
	
	rNmprocur = $('label[for="nmprocur"]','#'+frmProcurador);	
	rDsdocpcd = $('label[for="dsdocpcd"]','#'+frmProcurador);	
	rCdoedpcd = $('label[for="cdoedpcd"]','#'+frmProcurador);	
	rCdufdpcd = $('label[for="cdufdpcd"]','#'+frmProcurador);	
	rDtvalprc = $('label[for="dtvalprc"]','#'+frmProcurador);	

	rNmprocur.addClass('rotulo').css({'width':'40px'});	
	rDsdocpcd.addClass('rotulo').css({'width':'40px'});	
	rCdoedpcd.addClass('rotulo-linha').css({'width':'27px'});	
	rCdufdpcd.addClass('rotulo-linha').css({'width':'27px'});	
	rDtvalprc.addClass('rotulo-linha').css({'width':'59px'});	
	
	
	cTodos	  = $('input', '#'+frmProcurador);		
	cNmprocur = $('#nmprocur','#'+frmProcurador);
	cDsdocpcd = $('#dsdocpcd','#'+frmProcurador);
	cCdoedpcd = $('#cdoedpcd','#'+frmProcurador);
	cCdufdpcd = $('#cdufdpcd','#'+frmProcurador);
	cDtvalprc = $('#dtvalprc','#'+frmProcurador);

	
	cNmprocur.css({'width':'532px'});
	cDsdocpcd.css({'width':'100px'});
	cCdoedpcd.css({'width':'100px'});
	cCdufdpcd.css({'width':'100px'});
	cDtvalprc.css({'width':'101px'});
	
	cTodos.desabilitaCampo();

}