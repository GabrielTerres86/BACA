/*********************************************************************************************
 FONTE        : admcrd.js
 CRIAÇÃO      : Cristian Filipe (GATI)         
 DATA CRIAÇÃO : Setembro/2013
 OBJETIVO     : Biblioteca de funções da tela ADMCRD
 --------------
 ALTERAÇÕES   : 26/02/2014 - Revisão e Correção (Lucas).
				24/03/2014 - Implementados novos campos Projeto cartão Bancoob (Jean Michel).
				24/10/2014 - Alteração do campo nmresadm para maxlength de 30 (Vanessa).
 -------------- 
                                                                                           
***********************************************************************************************/

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, rcddgrupo, cCddopcao, cTodosCabecalho, btnCab, cTodosAdministradoras;

//Labels Formulario
var rCdadmcrd, rNmadmcrd, rNmresadm, rInsitadc, rNmbandei, rQtcarnom, rTpctahab, rInanuida,
    rNrctamae, rCdclasse, rNrctacor, rNrdigcta, rNrrazcta, rNmagecta, rCdagecta, rCddigage,
	rDsendere, rNmbairro, rNmcidade, rCdufende, rRrcepend, rNmpescto, rFlgcchip; 
	
//Campos Formulario
var cCdadmcrd, cNmadmcrd, cNmresadm, cInsitadc, cNmbandei, cQtcarnom, cTpctahab, cInanuida,
    cNrctamae, cCdclasse, cNrctacor, cNrdigcta, cNrrazcta, cNmagecta, cCdagecta, cCddigage,
	cDsendere, cNmbairro, cNmcidade, cCdufende, cNrcepend, cNmpescto, cFlgcchip;
	
$(document).ready(function() {
	
	estadoInicial();
	
	highlightObjFocus( $('#'+frmCab) );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
	$('#frmAdministradoras').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	
	formataLayout();
	
	cTodosCabecalho.limpaFormulario();
	cTodosCabecalho.habilitaCampo();
	
	cCddopcao.val( cddopcao );
	
	cInsitadc.prop('selected',true).val("YES");
	cInanuida.prop('selected',true).val(0);
	cFlgcchip.prop('checked',false);
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	trocaBotao( '' , '' );
	$("#btVoltar","#divBotoes").hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	$('input,select', '#frmAdministradoras').removeClass('campoErro');
	
	cTpctahab.desabilitaCampo();
	cCddopcao.habilitaCampo();
	cCddopcao.focus();

}

function formataLayout() {

	// Cabecalho	
	cTodosCabecalho			  = $('input[type="text"],select','#'+frmCab);
	cTodosFormAdministradoras = $('input[type="text"],select','#frmAdministradoras'); 
	btnCab					  = $('#btOK','#'+frmCab);
	
	cCddopcao				  = $('#cddopcao','#'+frmCab); 
	rCddopcao				  = $('label[for="cddopcao"]','#'+frmCab); 
	
	cCddopcao.css({'width':'460px'});
	rCddopcao.css('width','44px');

	// Form Adms
	rCdadmcrd = $('label[for="cdadmcrd"]','#frmAdministradoras'); 
    rNmadmcrd = $('label[for="nmadmcrd"]','#frmAdministradoras'); 
    rNmresadm = $('label[for="nmresadm"]','#frmAdministradoras'); 
    rInsitadc = $('label[for="insitadc"]','#frmAdministradoras'); 
    rNmbandei = $('label[for="nmbandei"]','#frmAdministradoras'); 
    rQtcarnom = $('label[for="qtcarnom"]','#frmAdministradoras'); 
    rTpctahab = $('label[for="tpctahab"]','#frmAdministradoras'); 
    rInanuida = $('label[for="inanuida"]','#frmAdministradoras'); 	
	rNrctamae = $('label[for="nrctamae"]','#frmAdministradoras'); 
	rCdclasse = $('label[for="cdclasse"]','#frmAdministradoras'); 
	rFlgcchip = $('label[for="flgcchip"]','#frmAdministradoras');     
	rNrctacor = $('label[for="nrctacor"]','#frmAdministradoras'); 
    rNrdigcta = $('label[for="nrdigcta"]','#frmAdministradoras'); 
    rNrrazcta = $('label[for="nrrazcta"]','#frmAdministradoras'); 
    rNmagecta = $('label[for="nmagecta"]','#frmAdministradoras'); 
    rCdagecta = $('label[for="cdagecta"]','#frmAdministradoras'); 
    rCddigage = $('label[for="cddigage"]','#frmAdministradoras'); 
    rDsendere = $('label[for="dsendere"]','#frmAdministradoras'); 
    rNmbairro = $('label[for="nmbairro"]','#frmAdministradoras'); 
    rNmcidade = $('label[for="nmcidade"]','#frmAdministradoras'); 
    rCdufende = $('label[for="cdufende"]','#frmAdministradoras'); 
    rRrcepend = $('label[for="nrcepend"]','#frmAdministradoras'); 
    rNmpescto = $('label[for="nmpescto"]','#frmAdministradoras'); 
	
	rCdadmcrd.css({width:'110px'});
	
	rNmresadm.css({width:'120px'});
	
	
	rNmbandei.css({width:'110px'});
	
	rTpctahab.css({width:'110px'});
	rNrctacor.css({width:'110px'});
	rNrdigcta.css({width:'50px'});
	
	rNmagecta.css({width:'110px'});
	rCdagecta.css({width:'95px'});
	
	rDsendere.css({width:'110px'});
	rNmbairro.css({width:'110px'});
	rNmcidade.css({width:'132px'});
	
	rRrcepend.css({width:'110px'});
	rNmpescto.css({width:'110px'});
	
	rNrctamae.css({width:'110px'});
	rCdufende.css({width:'95px'});
			
	if ( $.browser.msie ) {
		rNmadmcrd.css({width:'50px'});
		rInsitadc.css({width:'123px'});
		rQtcarnom.css({width:'223px'});
		rInanuida.css({width:'170px'});
		rCdclasse.css({width:'190px'});
		rNrrazcta.css({width:'175px'});
		rCddigage.css({width:'35px'});
		rFlgcchip.css({width:'66px'});
	}else{
		rNmadmcrd.css({width:'54px'});
		rInsitadc.css({width:'125px'});
		rQtcarnom.css({width:'225px'});
		rInanuida.css({width:'173px'});
		rCdclasse.css({width:'200px'});
		rNrrazcta.css({width:'178px'});
		rCddigage.css({width:'37px'});		
		rFlgcchip.css({width:'70px'});
	}
	// Label E-mail
    rDsdemail1 = $('label[for="dsdemail1"]','#frmAdministradoras'); 
    rDsdemail2 = $('label[for="dsdemail2"]','#frmAdministradoras'); 
    rDsdemail3 = $('label[for="dsdemail3"]','#frmAdministradoras'); 
    rDsdemail4 = $('label[for="dsdemail4"]','#frmAdministradoras'); 
    rDsdemail5 = $('label[for="dsdemail5"]','#frmAdministradoras'); 

	rDsdemail1.css({width:'110px'});
	rDsdemail2.css({width:'110px'}).addClass('rotulo');
	rDsdemail3.css({width:'110px'}).addClass('rotulo');
	rDsdemail4.css({width:'110px'}).addClass('rotulo');
	rDsdemail5.css({width:'110px'}).addClass('rotulo');
	
	// Campos
    cCdadmcrd = $('#cdadmcrd','#frmAdministradoras');  
    cNmadmcrd = $('#nmadmcrd','#frmAdministradoras');
    cNmresadm = $('#nmresadm','#frmAdministradoras');
    cInsitadc = $('#insitadc','#frmAdministradoras');
    cNmbandei = $('#nmbandei','#frmAdministradoras'); 
    cQtcarnom = $('#qtcarnom','#frmAdministradoras'); 
    cTpctahab = $('#tpctahab','#frmAdministradoras'); 
    cInanuida = $('#inanuida','#frmAdministradoras'); 
    cNrctacor = $('#nrctacor','#frmAdministradoras');
    cNrdigcta = $('#nrdigcta','#frmAdministradoras'); 
    cNrrazcta = $('#nrrazcta','#frmAdministradoras');
    cNmagecta = $('#nmagecta','#frmAdministradoras'); 
    cCdagecta = $('#cdagecta','#frmAdministradoras'); 
    cCddigage = $('#cddigage','#frmAdministradoras'); 
    cDsendere = $('#dsendere','#frmAdministradoras');
    cNmbairro = $('#nmbairro','#frmAdministradoras'); 
    cNmcidade = $('#nmcidade','#frmAdministradoras');
    cCdufende = $('#cdufende','#frmAdministradoras'); 
    cNrcepend = $('#nrcepend','#frmAdministradoras'); 
    cNmpescto = $('#nmpescto','#frmAdministradoras'); 
	cNrctamae = $('#nrctamae','#frmAdministradoras'); 
	cCdclasse = $('#cdclasse','#frmAdministradoras'); 
	cFlgcchip = $('#flgcchip','#frmAdministradoras'); 
	
	cCdadmcrd.css({width:'30px'}).attr( 'maxlength','02').setMask('INTEGER','zz','','');
	cNmadmcrd.css({width:'360px'}).attr('maxlength','50');
    cNmresadm.css({width:'240px'}).attr('maxlength','30');
    cInsitadc.css({width:'90px'});
    cNmbandei.css({width:'210px'}).attr('maxlength','20');
    cQtcarnom.css({width:'30px'}).attr( 'maxlength','02').setMask('INTEGER','zz','','');
	cInanuida.css({width:'180px'});
	cNrctacor.css({width:'100px'}).attr('maxlength','10').setMask('INTEGER','zzzzzzzzzz','','');
	cNrdigcta.css({width:'30px'}).attr('maxlength','02').setMask('INTEGER','zz','','');
	cNrrazcta.css({width:'105px'}).attr('maxlength','09').setMask('INTEGER','zzzzzzzzz','','');
	cNmagecta.css({width:'220px'}).attr('maxlength','25')
	cCdagecta.css({width:'80px' }).attr('maxlength','06').setMask('INTEGER','zzzzzz','','');
	cCddigage.css({width:'30px'}).attr('maxlength','3').setMask('INTEGER','zz','',''); 
	cDsendere.css({width:'465px'}).attr('maxlength','60');
	cNmbairro.css({width:'100px'}).attr('maxlength','15');
	cNmcidade.css({width:'100px'}).attr('maxlength','15');
	cCdufende.css({width:'30px'}).attr('maxlength','2');
	cNrcepend.css({width:'100px'}).addClass('cep');
	cNmpescto.css({width:'459px'}).attr('maxlength','40');	
	cNrctamae.css({width:'80px'}).attr('maxlength','06').setMask('INTEGER','zzzzzz','','');
    cCdclasse.css({width:'30px'}).attr('maxlength','02').setMask('INTEGER','zz','','');
	cCdclasse.css({width:'100'});
    // E-mail
    cDsdemail1 = $('#dsdemail1','#frmAdministradoras');
    cDsdemail2 = $('#dsdemail2','#frmAdministradoras');
    cDsdemail3 = $('#dsdemail3','#frmAdministradoras');
    cDsdemail4 = $('#dsdemail4','#frmAdministradoras');
    cDsdemail5 = $('#dsdemail5','#frmAdministradoras');
	
	cDsdemail1.css({width:'459px'}).addClass('email').attr('maxlength','30');
	cDsdemail2.css({width:'459px'}).addClass('email').attr('maxlength','30');
	cDsdemail3.css({width:'459px'}).addClass('email').attr('maxlength','30');
	cDsdemail4.css({width:'459px'}).addClass('email').attr('maxlength','30');
	cDsdemail5.css({width:'459px'}).addClass('email').attr('maxlength','30');  
	
	controlaFoco();	

	layoutPadrao();
	return false;	
}

function controlaFoco() {

	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			liberaCampos();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			liberaCampos();
			return false;
		}
	});
	
	cCdadmcrd.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			realizaOperacao(cCddopcao.val());
			return false;
		}
	}).unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 118 ) {	
			controlaPesquisa();
			return false;
		}
	});

	cNmadmcrd.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNmresadm.focus();
			return false;
		}	
	});

	cNmresadm.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cInsitadc.focus();
			return false;
		}	
	});
	
	cInsitadc.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNmbandei.focus();
			return false;
		}	
	}); 

	cNmbandei.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cQtcarnom.focus();
			return false;
		}	
	});
	
	cQtcarnom.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cTpctahab.focus();
			return false;
		}	
	});
	
	cTpctahab.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cInanuida.focus();
			return false;
		}	
	});
	
	cInanuida.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrctamae.focus();
			return false;
		}	
	});
 
 
	cNrctamae.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdclasse.focus();
			return false;
		}	
	});
 	
	cCdclasse.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cFlgcchip.focus();
			return false;
		}	
	});
	
	cFlgcchip.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrctacor.focus();
			return false;
		}	
	});
	
	cNrctacor.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrdigcta.focus();
			return false;
		}	
	});
	
	cNrdigcta.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrrazcta.focus();
			return false;
		}	
	});
	
	cNrrazcta.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNmagecta.focus();
			return false;
		}	
	});
	
	cNmagecta.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdagecta.focus();
			return false;
		}	
	});
	
	cCdagecta.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCddigage.focus();
			return false;
		}	
	});
	
	cCddigage.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDsendere.focus();
			return false;
		}	
	});
	
	cDsendere.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNmbairro.focus();
			return false;
		}	
	});
	
	cNmbairro.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNmcidade.focus();
			return false;
		}	
	});
	
	cNmcidade.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdufende.focus();
			return false;
		}	
	});
	
	cCdufende.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrcepend.focus();
			return false;
		}	
	});
	
	cNrcepend.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cNmpescto.focus();
			return false;
		}	
	});
	
	cNmpescto.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDsdemail1.focus();
			return false;
		}	
	});
	
	cDsdemail1.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDsdemail2.focus();
			return false;
		}	
	});
	
	cDsdemail2.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDsdemail3.focus();
			return false;
		}	
	});
	
	cDsdemail3.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDsdemail4.focus();
			return false;
		}	
	});
	
	cDsdemail4.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDsdemail5.focus();
			return false;
		}	
	});
	
	cDsdemail5.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if (cCddopcao.val() == "A"){
				confirma('A1');
			} else
			if (cCddopcao.val() == "I"){
				confirma('I1');
			}
			return false;
		}	
	});
}

function trocaBotao(botao , cddopcao) {

	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');	
	
	if ( botao != '' ) {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" id="btSalvar" onClick="confirma(\'' + cddopcao + '\'); return false;" >'+botao+'</a>');		
	}
	
	return false;
}

function liberaCampos() {

	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }	

	cTodosFormAdministradoras.desabilitaCampo();
	cTodosFormAdministradoras.limpaFormulario();
	
	// Mostra form frmAdministradoras
	$('#frmAdministradoras').css({'display':'block'});
	
	cCdadmcrd.habilitaCampo();
	cCddopcao.desabilitaCampo();
		
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
	
	cCdadmcrd.focus();
    
	return false;
}
	
function btnVoltar() {
	
	estadoInicial();
	return false;
}


function confirma(cddopcao) {

	var menssagem;
	
	// Mostra mensagem de aguardo
	if (cddopcao == "A1"){ menssagem = 'Deseja alterar Administradoras de Cartoes?';  }
	else if (cddopcao == "I1"){ menssagem = 'Deseja incluir Administradoras de Cartoes?';  }
	else if (cddopcao == "E1"){ menssagem = 'Deseja excluir Administradoras de Cartoes?';  }	
	
	showConfirmacao(menssagem,'Confirma&ccedil;&atilde;o - Ayllos','realizaOperacao(\'' + cddopcao + '\');','return false;','sim.gif','nao.gif');	
	
}

function realizaOperacao(cddopcao) {
	
	var flgcchip;
	
	if (this.cddopcao == "lupa") {
		cddopcao = "";
	}
		
	flgcchip = $('input[name="flgcchip"]:checked','#frmAdministradoras').val();
	if (flgcchip == 'on'){ flgcchip = 1; }else{ flgcchip = 0; };
	
	// Mostra mensagem de aguardo
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando administradora..."); } 
	else if (cddopcao == "A"){ showMsgAguardo("Aguarde, consultando administradora...");  }
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, consultando administradora...");  }
	else if (cddopcao == "I"){ showMsgAguardo("Aguarde, carregando formulario da administradora...");  }
	else if (cddopcao == "A1"){ showMsgAguardo("Aguarde, alterando administradora...");  }	
	else if (cddopcao == "E1"){ showMsgAguardo("Aguarde, excluindo administradora...");  }
	else if (cddopcao == "I1"){ showMsgAguardo("Aguarde, incluindo administradora...");  }
	else { showMsgAguardo("Aguarde, consultando administradora..."); }
		
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/admcrd/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			cdadmcrd: normalizaNumero(cCdadmcrd.val()),
			nmadmcrd: cNmadmcrd.val(),
			nmresadm: cNmresadm.val(),
			insitadc: cInsitadc.val(),
			nmbandei: cNmbandei.val(),
			qtcarnom: cQtcarnom.val(),
			tpctahab: cTpctahab.val(),
			inanuida: cInanuida.val(),
			nrctamae: cNrctamae.val(),
			cdclasse: cCdclasse.val(),
			flgcchip: flgcchip,
			nrctacor: cNrctacor.val(),
			nrdigcta: cNrdigcta.val(),
			nrrazcta: cNrrazcta.val(),
			nmagecta: cNmagecta.val(),
			cdagecta: cCdagecta.val(),
			cddigage: cCddigage.val(),
			dsendere: cDsendere.val(),
			nmbairro: cNmbairro.val(),
			nmcidade: cNmcidade.val(),
			cdufende: cCdufende.val(),
			nrcepend: normalizaNumero(cNrcepend.val()),
			nmpescto: cNmpescto.val(),
			dsdemail1: cDsdemail1.val(),
			dsdemail2: cDsdemail2.val(),
			dsdemail3: cDsdemail3.val(),
			dsdemail4: cDsdemail4.val(),
			dsdemail5: cDsdemail5.val(),
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
				cNmadmcrd.focus();
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}

function carregaEmail(dsdemail) {

	var email = dsdemail.split(",");    
	$('#dsdemail1','#frmAdministradoras').val(email[0]);
	$('#dsdemail2','#frmAdministradoras').val(email[1]);
	$('#dsdemail3','#frmAdministradoras').val(email[2]);
	$('#dsdemail4','#frmAdministradoras').val(email[3]);
	$('#dsdemail5','#frmAdministradoras').val(email[4]);
	return false;
					
}

function controlaOperacao(cddopcao) {


	
	if ( cddopcao == "I" ) {
	
		cInanuida.prop('selected',true).val(3);	
		$('#flgcchip','#frmAdministradoras').attr('disabled',false);
		cTodosFormAdministradoras.habilitaCampo();
		cCdadmcrd.desabilitaCampo();
		cTpctahab.habilitaCampo();
		cNmadmcrd.focus();	
		$('#btVoltar', '#divBotoes').focus();
		trocaBotao('Incluir', 'I1');
		
	} else
	if ( cddopcao == "C" ) {
		cCdadmcrd.desabilitaCampo();
		$('#flgcchip','#frmAdministradoras').attr('disabled',true);
		$('#btVoltar', '#divBotoes').focus();
		
	} else
	if ( cddopcao == "E" ) {
		$('#flgcchip','#frmAdministradoras').attr('disabled',false);
		cCdadmcrd.desabilitaCampo();
		trocaBotao('Excluir', 'E1');
		$('#btSalvar','#divBotoes').focus();
		
	} else
	if ( cddopcao == "A" ) {
		
		$('#flgcchip','#frmAdministradoras').attr('disabled',false);
		cTodosFormAdministradoras.habilitaCampo();
		cCdadmcrd.desabilitaCampo();
		
		cTpctahab.habilitaCampo();
		cNmadmcrd.focus();						
		trocaBotao('Alterar', 'A1');
	}
	
	return false;
					
}

function controlaPesquisa() {

	// Se Cod.Adm. estiver desabilitado ou Opção I
	if ($("#cdadmcrd","#frmAdministradoras").prop("disabled") == true){
		return false;
	}
	
	if ($('#cddopcao','#frmCab').val() == "I"){
		return false;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdadmcrd, titulo_coluna, nmadmcrd;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmAdministradoras';
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	cdadmcrd = $('#cdadmcrd','#'+nomeFormulario).val();
	nmadmcrd = '';	
	titulo_coluna = "Administradoras";
	
	bo			= 'b1wgen0182.p'; 
	procedure	= 'consulta-administradora';
	titulo      = 'Administradoras Cartao';
	qtReg		= '20';
	filtros 	= 'Codigo;cdadmcrd;100px;S;' + cdadmcrd + ';S|Nome;nmadmcrd;150px;S;' + nmadmcrd + ';S';
	colunas 	= 'Codigo;cdadmcrd;20%;right|' + titulo_coluna + ';nmadmcrd;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','cCdadmcrd.focus();');
	
	return false;

}