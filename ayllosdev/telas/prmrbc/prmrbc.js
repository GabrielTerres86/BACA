/*!
 * FONTE        : prmrbc.js
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Janeiro/2014
 * OBJETIVO     : Biblioteca de funções da tela PRMRBC
 * --------------
 * ALTERAÇÕES   :  23/03/2016 - Adicionado tratamento para identificar se é necessário fazer
 *                          	a chamada do ftp seguro conforme solicitado no chamado 412682. (Kelvin)
 * -----------------------------------------------------------------------
 */




// Variaveis
var rCddopcao, rLstpreme,
    cCddopcao, cLstpreme;

// Parametros Gerais
var rHrdenvio, rHrdreton, rHrdencer, rHrdencmx, rDsdirarq, rLstemail,
    cHrdenvio, cHrdreton, cHrdencer, cHrdencmx, cDsdirarq, cDesemail;

// Parametros Bureaux
var rIdtpreme, rFlgativo, rIdenvseg, rFlremseq, rDsdirenv, rDsfnburm, rDsfnchrm, rIdtpenvi, rDsfnrnen, rDssitftp, rDsusrftp, rDspwdftp, rDsdreftp, rDsdrencd, rDsdrevcd, rIdopreto, rQthorret, rDsfnburt, rDsfnchrt, rDsfnrndv, rDsdrrftp, rDsdrrecd, rDsdrrtcd, rDsdirret, rIdtpsoli, rHrinterv,
	cIdtpreme, cFlgativo, cIdenvseg, cFlremseq, cDsdirenv, cDsfnburm, cDsfnchrm, cIdtpenvi, cDsfnrnen, cDssitftp, cDsusrftp, cDspwdftp, cDsdreftp, cDsdrencd, cDsdrevcd, cIdopreto, cQthorret, cDsfnburt, cDsfnchrt, cDsfnrndv, cDsdrrftp, cDsdrrecd, cDsdrrtcd, cDsdirret, cIdtpsoli, cHrinterv;

var cTodosCabGeral, cTodosCabBureaux, btnOK, btnOK1;




// Tela
$(document).ready(function() {
	estadoInicial();
});

function estadoInicial() {

	// Efeito de inicializacao
	$('#divRotina').fadeTo(0,0.1);

	// Monta a tela Principal
	atualizaSeletor();
	formataCabecalho();

	// Desabilta
	$('#divBotoes').css({'display':'none'});
	$('#divGeral').css({'display':'none'});
	$('#frmGeral').css({'display':'none'});
	$('#divCabBur').css({'display':'none'});
	$('#frmBureaux').css({'display':'none'});
	$('#divFtpEnvio').css({'display':'none'});
	$('#divCdEnvio').css({'display':'none'});
	$('#divRetornoArq').css({'display':'none'});
	$('#divFtpRetorno').css({'display':'none'});
	$('#divCdRetorno').css({'display':'none'});

	// Habilta
	$('#frmCab').css({'display':'block'});

	// Remove Opacidade da Tela
	removeOpacidade('divTela');

	// Desativa os Botoes
	$('#btnVoltar','#divBotoes').hide();
	$('#btnGravar','#divBotoes').hide();

	// Habilita Campo
	cCddopcao.habilitaCampo();
	cLstpreme.habilitaCampo();
	btnOK.prop('disabled',false);
	btnOK1.prop('disabled',false);

	// Inicializa Campo
	cHrdenvio.val("00:00");
	cHrdreton.val("00:00");
	cHrdencer.val("00:00");
	cHrdencmx.val("00:00");

	// Foco no campo de opcao
	cCddopcao.focus();
	return false;
}

// Cabecalho
function atualizaSeletor() {

	/** Geral **/
	rCddopcao	    = $('label[for="cddopcao"]','#frmCab');
	rLstpreme	    = $('label[for="lstpreme"]','#frmCab');

	cCddopcao       = $('#cddopcao','#frmCab');
	cLstpreme       = $('#lstpreme','#frmCab');

	btnOK			    = $('#btnOK','#frmCab');
	btnOK1			    = $('#btnOK1','#frmCab');

	/** Campos DIV Geral **/
	rHrdenvio	    = $('label[for="hrdenvio"]','#frmGeral');
	rHrdreton	    = $('label[for="hrdreton"]','#frmGeral');
	rHrdencer	    = $('label[for="hrdencer"]','#frmGeral');
	rHrdencmx	    = $('label[for="hrdencmx"]','#frmGeral');
	rDsdirarq	    = $('label[for="dsdirarq"]','#frmGeral');
	rLstemail	    = $('label[for="desemail"]','#frmGeral');

	cHrdenvio       = $('#hrdenvio','#frmGeral');
	cHrdreton       = $('#hrdreton','#frmGeral');
	cHrdencer       = $('#hrdencer','#frmGeral');
	cHrdencmx       = $('#hrdencmx','#frmGeral');
	cDsdirarq       = $('#dsdirarq','#frmGeral');
	cDesemail       = $('#desemail','#frmGeral');

	cTodosCabGeral	    = $('input[type="text"],select,textArea','#frmGeral');

	/** Campos DIV Bureaux **/
	rIdtpreme       = $('label[for="idtpreme"]','#frmBureaux');
	rFlgativo       = $('label[for="flgativo"]','#frmBureaux');
	rIdenvseg		= $('label[for="idenvseg"]','#frmBureaux');
	rFlremseq       = $('label[for="flremseq"]','#frmBureaux');
    rIdtpsoli       = $('label[for="idtpsoli"]','#frmBureaux');
    rHrinterv       = $('label[for="hrinterv"]','#frmBureaux');
	rDsdirenv       = $('label[for="dsdirenv"]','#frmBureaux');
	rDsfnburm       = $('label[for="dsfnburm"]','#frmBureaux');
	rDsfnchrm       = $('label[for="dsfnchrm"]','#frmBureaux');
	rIdtpenvi       = $('label[for="idtpenvi"]','#frmBureaux');
	rDsfnrnen       = $('label[for="dsfnrnen"]','#frmBureaux');
	rDssitftp       = $('label[for="dssitftp"]','#frmBureaux');

	rDsusrftp       = $('label[for="dsusrftp"]','#frmBureaux');
	rDspwdftp       = $('label[for="dspwdftp"]','#frmBureaux');
	rDsdreftp       = $('label[for="dsdreftp"]','#frmBureaux');

	rDsdrencd       = $('label[for="dsdrencd"]','#frmBureaux');
	rDsdrevcd       = $('label[for="dsdrevcd"]','#frmBureaux');

	rIdopreto       = $('label[for="idopreto"]','#frmBureaux');
	rQthorret       = $('label[for="qthorret"]','#frmBureaux');
	rDsfnburt       = $('label[for="dsfnburt"]','#frmBureaux');
	rDsfnchrt       = $('label[for="dsfnchrt"]','#frmBureaux');
	rDsfnrndv       = $('label[for="dsfnrndv"]','#frmBureaux');

	rDsdrrftp       = $('label[for="dsdrrftp"]','#frmBureaux');
	rDsdrrecd       = $('label[for="dsdrrecd"]','#frmBureaux');
	rDsdrrtcd       = $('label[for="dsdrrtcd"]','#frmBureaux');

	rDsdirret       = $('label[for="dsdirret"]','#frmBureaux');

	cIdtpreme       = $('#idtpreme','#frmBureaux');
	cFlgativo       = $('#flgativo','#frmBureaux');
	cIdenvseg		= $('#idenvseg','#frmBureaux');
	
	cFlremseq       = $('#flremseq','#frmBureaux');
    cIdtpsoli       = $('#idtpsoli','#frmBureaux');
    cHrinterv       = $('#hrinterv','#frmBureaux');
	cDsdirenv       = $('#dsdirenv','#frmBureaux');
	cDsfnburm       = $('#dsfnburm','#frmBureaux');
	cDsfnchrm       = $('#dsfnchrm','#frmBureaux');
	cIdtpenvi       = $('#idtpenvi','#frmBureaux');
	cDsfnrnen       = $('#dsfnrnen','#frmBureaux');
	cDssitftp       = $('#dssitftp','#frmBureaux');

	cDsusrftp       = $('#dsusrftp','#frmBureaux');
	cDspwdftp       = $('#dspwdftp','#frmBureaux');
	cDsdreftp       = $('#dsdreftp','#frmBureaux');

	cDsdrencd       = $('#dsdrencd','#frmBureaux');
	cDsdrevcd       = $('#dsdrevcd','#frmBureaux');

	cIdopreto       = $('#idopreto','#frmBureaux');
	cQthorret       = $('#qthorret','#frmBureaux');
	cDsfnburt       = $('#dsfnburt','#frmBureaux');
	cDsfnchrt       = $('#dsfnchrt','#frmBureaux');
	cDsfnrndv       = $('#dsfnrndv','#frmBureaux');

	cDsdrrftp       = $('#dsdrrftp','#frmBureaux');
	cDsdrrecd       = $('#dsdrrecd','#frmBureaux');
	cDsdrrtcd       = $('#dsdrrtcd','#frmBureaux');

	cDsdirret       = $('#dsdirret','#frmBureaux');

	cTodosCabBureaux	= $('input[type="text"],','#frmBureaux');

	return false;
}

// Formatacao da Tela
function formataCabecalho() {

	/** Geral **/
	rCddopcao.css({'width':'200px'});
	rLstpreme.css({'width':'200px'});

	cCddopcao.css({'width':'400px'});
	cLstpreme.addClass('campo').css({'width':'150px'});


	/** Campos DIV Geral **/
	rHrdenvio.addClass('rotulo-linha').css({'width':'150px'});
	rHrdreton.addClass('rotulo-linha').css({'width':'105px'});
	rHrdencer.addClass('rotulo-linha').css({'width':'225px'});
	rHrdencmx.addClass('rotulo-linha').css({'width':'20px'});
	rDsdirarq.addClass('rotulo-linha').css({'width':'355px'});
	rLstemail.addClass('rotulo-linha').css({'width':'440px'});

	cHrdenvio.addClass('campo').css({'width':'100px'}).css('text-align','center').attr('maxlength','5');
	cHrdreton.addClass('campo').css({'width':'100px'}).css('text-align','center').attr('maxlength','5');
	cHrdencer.addClass('campo').css({'width':'100px'}).css('text-align','center').attr('maxlength','5');
	cHrdencmx.addClass('campo').css({'width':'100px'}).css('text-align','center').attr('maxlength','5');
	cDsdirarq.addClass('campo').css({'width':'385px'});
	cDesemail.css({'width':'300px'});


	/** Campos DIV Bureaux **/
	rIdtpreme.addClass('rotulo-linha').css({'width':'70px'});
	rFlgativo.addClass('rotulo-linha').css({'width':'50px'});
	rIdenvseg.addClass('rotulo-linha').css({'width':'95px'});
	rFlremseq.addClass('rotulo-linha').css({'width':'140px'});
    rIdtpsoli.addClass('rotulo-linha').css({'width':'120px'});
    rHrinterv.addClass('rotulo-linha').css({'width':'443px'});
	rDsdirenv.addClass('rotulo-linha').css({'width':'200px'});
	rDsfnburm.addClass('rotulo-linha').css({'width':'200px'});
	rDsfnchrm.addClass('rotulo-linha').css({'width':'200px'});
	rIdtpenvi.addClass('rotulo-linha').css({'width':'70px'});
	rDsfnrnen.addClass('rotulo-linha').css({'width':'200px'});

	rDssitftp.addClass('rotulo-linha').css({'width':'200px'});
	rDsusrftp.addClass('rotulo-linha').css({'width':'200px'});
	rDspwdftp.addClass('rotulo-linha').css({'width':'50px'});
	rDsdreftp.addClass('rotulo-linha').css({'width':'200px'});

	rDsdrencd.addClass('rotulo-linha').css({'width':'200px'});
    rDsdrevcd.addClass('rotulo-linha').css({'width':'200px'});

	rIdopreto.addClass('rotulo-linha').css({'width':'70px'});
	rQthorret.addClass('rotulo-linha').css({'width':'200px'});
	rDsfnburt.addClass('rotulo-linha').css({'width':'200px'});
	rDsfnchrt.addClass('rotulo-linha').css({'width':'200px'});
	rDsfnrndv.addClass('rotulo-linha').css({'width':'200px'});

	rDsdrrftp.addClass('rotulo-linha').css({'width':'200px'});
	rDsdrrecd.addClass('rotulo-linha').css({'width':'200px'});
    rDsdrrtcd.addClass('rotulo-linha').css({'width':'200px'});

	rDsdirret.addClass('rotulo-linha').css({'width':'200px'});

	cIdtpreme.addClass('campo').css({'width':'80px'});
	cFlgativo.addClass('campo').css({'width':'60px'});
	cIdenvseg.addClass('campo').css({'width':'60px'});
	cFlremseq.addClass('campo').css({'width':'60px'});
    cIdtpsoli.addClass('campo').css({'width':'110px'});
    cHrinterv.addClass('campo').css({'width':'100px'}).css('text-align','center').setMask('INTEGER','z9','','');
	cDsdirenv.addClass('campo').css({'width':'405px'});
	cDsfnburm.addClass('campo').css({'width':'405px'});
	cDsfnchrm.addClass('campo').css({'width':'405px'});
	cIdtpenvi.addClass('campo').css({'width':'80px'});
	cDsfnrnen.addClass('campo').css({'width':'400px'});

	cDssitftp.addClass('campo').css({'width':'400px'});
	cDsusrftp.addClass('campo').css({'width':'100px'});
	cDspwdftp.addClass('campo').css({'width':'100px'});
	cDsdreftp.addClass('campo').css({'width':'400px'});

	cDsdrencd.addClass('campo').css({'width':'400px'});
    cDsdrevcd.addClass('campo').css({'width':'400px'});

	cIdopreto.addClass('campo').css({'width':'105px'});
	cQthorret.addClass('campo').css({'width':'80px'}).css('text-align','center').setMask('INTEGER','z9','','');
	cDsfnburt.addClass('campo').css({'width':'400px'});
	cDsfnchrt.addClass('campo').css({'width':'400px'});
	cDsfnrndv.addClass('campo').css({'width':'400px'});

	cDsdrrftp.addClass('campo').css({'width':'400px'});
	cDsdrrecd.addClass('campo').css({'width':'400px'});
	cDsdrrtcd.addClass('campo').css({'width':'400px'});

	cDsdirret.addClass('campo').css({'width':'400px'});

	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmGeral') );
	highlightObjFocus( $('#frmBureaux') );

	opcaoTela();
	layoutPadrao();
	return false;
}

// Funcoes de Botoes definidas
function opcaoTela() {

	/*********************************************************/
	/********************* CAMPOS CABECALHO ******************/

	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() {

		if(cCddopcao.val() == "G"){

			btnOK.prop('disabled',true);
			btnOK1.prop('disabled',true);

			buscaDadosPrmGerais();

			$('#divGeral').css({'display':'block'});
			$('#frmGeral').css({'display':'block'});
			$('#divBotoes').css({'display':'block'});

			cCddopcao.desabilitaCampo();
			cLstpreme.desabilitaCampo();

			$('#btVoltar').show();
			$('#btGravar').show();
			cHrdenvio.focus();
		}else
		if(cCddopcao.val() == "B"){
			cCddopcao.desabilitaCampo();

			btnOK.prop('disabled',true);
			btnOK1.prop('disabled',false);

			$('#divCabBur').css({'display':'block'});
			$('#divBotoes').css({'display':'block'});

			$('#btVoltar').show();
			$('#btGravar').hide();
			cLstpreme.focus();
		}

		return false;
	});

	// Se precionar ENTER no campo de cddopcao
	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if(cCddopcao.val() == "G"){
				btnOK.prop('disabled',true);
				btnOK1.prop('disabled',true);

				cCddopcao.desabilitaCampo();
				cLstpreme.desabilitaCampo();

				buscaDadosPrmGerais();

				$('#divGeral').css({'display':'block'});
				$('#frmGeral').css({'display':'block'});
				$('#divBotoes').css({'display':'block'});

				cCddopcao.desabilitaCampo();

				$('#btVoltar').show();
				$('#btGravar').show();
				cHrdenvio.focus();
			}else
			if(cCddopcao.val() == "B"){
				cCddopcao.desabilitaCampo();

				btnOK.prop('disabled',true);
				btnOK1.prop('disabled',false);

				$('#divCabBur').css({'display':'block'});
				$('#divBotoes').css({'display':'block'});

				$('#btVoltar').show();
				$('#btGravar').hide();
				cLstpreme.focus();
			}
			return false;
		}
	});

	// Se clicar no botao OK
	btnOK1.unbind('click').bind('click', function() {
		liberaCampos();
		cLstpreme.desabilitaCampo();
		btnOK1.prop('disabled',true);
		$('#frmBureaux').css({'display':'block'});
		$('#divBureaux').css({'display':'block'});
		$('#divRetornoArq').css({'display':'block'});

		$('#btGravar').show();

		buscaDadosPrmBureaux();

		if (cLstpreme.val()=='NOVO'){
			cIdtpreme.habilitaCampo();
			cIdtpreme.val('');
			cIdtpreme.focus();
		}else{
			cIdtpreme.desabilitaCampo();
			cIdtpreme.val(cLstpreme.val());
			cFlgativo.focus();
		}
		return false;
	});

	// Se precionar ENTER no campo de cddopcao
	cLstpreme.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cLstpreme.desabilitaCampo();
			btnOK1.prop('disabled',true);
			$('#frmBureaux').css({'display':'block'});
			$('#divBureaux').css({'display':'block'});
			$('#divRetornoArq').css({'display':'block'});

			$('#btGravar').show();

			buscaDadosPrmBureaux();

			if (cLstpreme.val()=='NOVO'){
				liberaCampos();
				cIdtpreme.habilitaCampo();
				cIdtpreme.val('');
				cIdtpreme.focus();
			}else{
				cIdtpreme.desabilitaCampo();
				cIdtpreme.val(cLstpreme.val());
				cFlgativo.focus();
			}

			return false;
		}
	});

	/********************* CAMPOS CABECALHO ******************/
	/*********************************************************/



	/*********************************************************/
	/********************** CAMPOS GERAL *********************/

	cHrdenvio.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if (validaCampos(cHrdenvio.val(),"hrdenvio")){cHrdenvio.focus();return false;}
			cHrdreton.focus();
			return false;
		}
	});

	cHrdreton.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if (validaCampos(cHrdreton.val(),"hrdreton")){cHrdreton.focus();return false;}
			cHrdencer.focus();
			return false;
		}
	});

	cHrdencer.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if (validaCampos(cHrdencer.val(),"hrdencer")){cHrdencer.focus();return false;}
			cHrdencmx.focus();
			return false;
		}
	});

	cHrdencmx.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if (validaCampos(cHrdencmx.val(),"hrdencmx")){cHrdencmx.focus();return false;}
			cDsdirarq.focus();
			return false;
		}
	});

	cDsdirarq.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDesemail.focus();
			return false;
		}
	});

	/********************** CAMPOS GERAL *********************/
	/*********************************************************/


	/*********************************************************/
	/********************** CAMPOS BUREAUX *******************/

	cIdtpreme.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cFlgativo.focus();
			return false;
		}
	});

	cFlgativo.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cFlremseq.focus();
			return false;
		}
	});

	cFlremseq.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cIdtpsoli.focus();
			return false;
		}
	});

	cIdtpsoli.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsdirenv.focus();
			return false;
		}
	});

	cDsdirenv.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsfnburm.focus();
			return false;
		}
	});

	cDsfnburm.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsfnchrm.focus();
			return false;
		}
	});

	cDsfnchrm.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cIdtpenvi.focus();
			return false;
		}
	});

	// Se precionar ENTER no campo de cddopcao
	cIdtpenvi.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			liberaCampos();
			cDsfnrnen.focus();
			return false;
		}
	});

	cDsfnrnen.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if (cIdtpenvi.val()=="F"){
				cDssitftp.focus();
			}else
			if(cIdtpenvi.val()=="C"){
				cDsdrencd.focus();
			}
			return false;
		}
	});

	cDssitftp.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsusrftp.focus();
			return false;
		}
	});

	cDsusrftp.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDspwdftp.focus();
			return false;
		}
	});

	cDspwdftp.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsdreftp.focus();
			return false;
		}
	});

	cDsdreftp.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cIdopreto.focus();
			return false;
		}
	});

	cIdopreto.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cQthorret.focus();
			return false;
		}
	});

	cDsdrencd.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsdrevcd.focus();
			return false;
		}
	});

	cDsdrevcd.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cIdopreto.focus();
			return false;
		}
	});

	cQthorret.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cHrinterv.focus();
			return false;
		}
	});

	cHrinterv.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsfnburt.focus();
			return false;
		}
	});

	cDsfnburt.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsfnchrt.focus();
			return false;
		}
	});

	cDsfnchrt.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if (cIdtpenvi.val()=="F"){
				cDsdrrftp.focus();
			}else
			if(cIdtpenvi.val()=="C"){
				cDsdrrecd.focus();
			}
			return false;
		}
	});

	cDsfnrndv.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsdirret.focus();
			return false;
		}
	});

	cDsdrrftp.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsfnrndv.focus();
			return false;
		}
	});

	cDsdrrecd.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsdrrtcd.focus();
			return false;
		}
	});

	cDsdrrtcd.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsfnrndv.focus();
			return false;
		}
	});

	cDsdirret.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			gravarDadosPrmBureaux();
			return false;
		}
	});

	/********************** CAMPOS BUREAUX *********************/
	/***********************************************************/

	return false;
}




// Botoes
function btnVoltar() {

	// Inicializa Campos
	cLstpreme.val("NOVO");
	cIdtpenvi.val("F");
	cFlgativo.val("S");
	cFlremseq.val("S");
	cIdopreto.val("U");

	limpaCampos();
	estadoInicial();
	return false;
}

function btnGravar() {
	if (cCddopcao.val()=="G"){
		gravarDadosPrmGerais();
	}else
	if(cCddopcao.val()=="B"){
		gravarDadosPrmBureaux();
	}
	return false;
}




// Busca dados Parametros Gerais
function buscaDadosPrmGerais() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando os dados...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/prmrbc/busca_dados_geral.php",
		data: {
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						eval(response);
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));");
			}
		}
	});

	return false;
}


function buscaDadosPrmBureaux() {

	if (cLstpreme.val()=='NOVO'){ return false; }

	var idtpreme = cLstpreme.val();

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando os dados...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/prmrbc/busca_dados_bureaux.php",
		data: {
		    idtpreme : idtpreme,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						eval(response);
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));");
			}
		}
	});

	return false;
}


function gravarDadosPrmBureaux() {

	var lstpreme = cLstpreme.val();
	var idtpreme = cIdtpreme.val();
	var flgativo = cFlgativo.val();
	var idenvseg = cIdenvseg.val();
	var flremseq = cFlremseq.val();
	var dsfnchrm = cDsfnchrm.val();
	var idtpenvi = cIdtpenvi.val();
	var dsdirenv = cDsdirenv.val();
	var dsfnburm = cDsfnburm.val();
	var dssitftp = cDssitftp.val();
	var dsusrftp = cDsusrftp.val();
	var dspwdftp = cDspwdftp.val();
	var dsdreftp = cDsdreftp.val();
	var dsdrencd = cDsdrencd.val();
	var dsdrevcd = cDsdrevcd.val();
	var dsfnrnen = cDsfnrnen.val();
	var idopreto = cIdopreto.val();
	var qthorret = cQthorret.val();
	var dsdrrftp = cDsdrrftp.val();
	var dsdrrecd = cDsdrrecd.val();
	var dsdrrtcd = cDsdrrtcd.val();
	var dsdirret = cDsdirret.val();
	var dsfnrndv = cDsfnrndv.val();
	var dsfnburt = cDsfnburt.val();
	var dsfnchrt = cDsfnchrt.val();
	var idtpsoli = cIdtpsoli.val();
	var hrinterv = cHrinterv.val();

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, gravando os dados...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/prmrbc/grava_dados_bureaux.php",
		data: {
			lstpreme : lstpreme,
			idtpreme : idtpreme,
			flgativo : flgativo,
			idenvseg : idenvseg,
			flremseq : flremseq,
			dsfnchrm : dsfnchrm,
			idtpenvi : idtpenvi,
			dsdirenv : dsdirenv,
			dsfnburm : dsfnburm,
			dssitftp : dssitftp,
			dsusrftp : dsusrftp,
			dspwdftp : dspwdftp,
			dsdreftp : dsdreftp,
			dsdrencd : dsdrencd,
			dsdrevcd : dsdrevcd,
			dsfnrnen : dsfnrnen,
			idopreto : idopreto,
			qthorret : qthorret,
			dsdrrftp : dsdrrftp,
			dsdrrecd : dsdrrecd,
			dsdrrtcd : dsdrrtcd,
			dsdirret : dsdirret,
			dsfnrndv : dsfnrndv,
			dsfnburt : dsfnburt,
			dsfnchrt : dsfnchrt,
            idtpsoli : idtpsoli,
            hrinterv : hrinterv,
			redirect : "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						showError("inform","Grava&ccedil;&atilde;o de par&acirc;metros bureaux efetuada com Sucesso!","Alerta - Ayllos","atualizaCab()");
						eval(response);
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','btnVoltar();');
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));");
			}
		}
	});

	return false;
}


// Grava dados Parametros Gerais
function gravarDadosPrmGerais() {

	// Captura os valores de tela
	var hrdenvio = cHrdenvio.val();
	var hrdreton = cHrdreton.val();
	var hrdencer = cHrdencer.val();
	var hrdencmx = cHrdencmx.val();
	var dsdirarq = cDsdirarq.val();
	var desemail = cDesemail.val();

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, gravando os dados...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/prmrbc/grava_dados_geral.php",
		data: {
			hrdenvio : hrdenvio,
			hrdreton : hrdreton,
			hrdencer : hrdencer,
			hrdencmx : hrdencmx,
			dsdirarq : dsdirarq,
			desemail : desemail,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						showError("inform","Grava&ccedil;&atilde;o de par&acirc;metros gerais efetuada com Sucesso!","Alerta - Ayllos","btnVoltar()");
						eval(response);
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));");
			}
		}
	});

	return false;
}

function atualizaCab() {

    // Limpa as tag option
	cLstpreme.empty();

    $.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/prmrbc/busca_bureaux.php",
		data: {
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						eval(response);
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));");
			}
		}
	});
	return false;
}




// Ajusta os campos de horas
function validaCampos(valor,campo) {

	switch (campo) {
		case 'hrdenvio':
			if (valor.length==5 && valor.substr(2,1)==":" ) {
				return false;
			}
			showError('error','Hor&aacute;rio Inv&aacute;lido! Favor informar o horário no formato [HH:MM].','Aten&ccedil;&atilde;o - Ayllos','cHrdenvio.focus()');
			break;
		case 'hrdreton':
			if (valor.length==5 && valor.substr(2,1)==":" ) {
				return false;
			}
			showError('error','Hor&aacute;rio Inv&aacute;lido! Favor informar o horário no formato [HH:MM].','Aten&ccedil;&atilde;o - Ayllos','cHrdreton.focus()');
			break;
		case 'hrdencer':
			if (valor.length==5 && valor.substr(2,1)==":" ) {
				return false;
			}
			showError('error','Hor&aacute;rio Inv&aacute;lido! Favor informar o horário no formato [HH:MM].','Aten&ccedil;&atilde;o - Ayllos','cHrdencer.focus()');
			break;
		case 'hrdencmx':
			if (valor.length==5 && valor.substr(2,1)==":" ) {
				return false;
			}
			showError('error','Hor&aacute;rio Inv&aacute;lido! Favor informar o horário no formato [HH:MM].','Aten&ccedil;&atilde;o - Ayllos','cHrdencmx.focus()');
			break;
	}

	return true;
}


function liberaCampos() {
	if( cIdtpenvi.val() == "F"){
		$('#divFtpEnvio').css({'display':'block'});
		$('#divCdEnvio').css({'display':'none'});

		if(cIdopreto.val() != "S"){
			$('#divFtpRetorno').css({'display':'block'});
			$('#divCdRetorno').css({'display':'none'});
		}else{
			$('#divFtpRetorno').css({'display':'none'});
			$('#divCdRetorno').css({'display':'none'});
		}
	}else
	if(cIdtpenvi.val() == "C"){
		$('#divFtpEnvio').css({'display':'none'});
		$('#divCdEnvio').css({'display':'block'});

		if(cIdopreto.val() != "S"){
			$('#divFtpRetorno').css({'display':'none'});
			$('#divCdRetorno').css({'display':'block'});
		}else{
			$('#divFtpRetorno').css({'display':'none'});
			$('#divCdRetorno').css({'display':'none'});
		}
	}
	return false;
}

// Exibe os campos conforme a opcao de envio de arquivos
function exibeCamposEnvio() {
	if( cIdtpenvi.val() == "F"){
		cDssitftp.val('');
		cDsusrftp.val('');
		cDspwdftp.val('');
		cDsdreftp.val('');
		cDsdrencd.val('');
		cDsdrevcd.val('');
		$('#divFtpEnvio').css({'display':'block'});
		$('#divCdEnvio').css({'display':'none'});

		if(cIdopreto.val() != "S"){
			cDsdrrftp.val('');
			cDsdrrecd.val('');
			cDsdrrtcd.val('');
			$('#divFtpRetorno').css({'display':'block'});
			$('#divCdRetorno').css({'display':'none'});
		}else{
			cDsdrrftp.val('');
			cDsdrrecd.val('');
			cDsdrrtcd.val('');
			$('#divFtpRetorno').css({'display':'none'});
			$('#divCdRetorno').css({'display':'none'});
		}

	}else
	if(cIdtpenvi.val() == "C"){
		cDssitftp.val('');
		cDsusrftp.val('');
		cDspwdftp.val('');
		cDsdreftp.val('');
		cDsdrencd.val('');
		cDsdrevcd.val('');
		$('#divFtpEnvio').css({'display':'none'});
		$('#divCdEnvio').css({'display':'block'});

		if(cIdopreto.val() != "S"){
			cDsdrrftp.val('');
			cDsdrrecd.val('');
			cDsdrrtcd.val('');
			$('#divFtpRetorno').css({'display':'none'});
			$('#divCdRetorno').css({'display':'block'});
		}else{
			cDsdrrftp.val('');
			cDsdrrecd.val('');
			cDsdrrtcd.val('');
			$('#divFtpRetorno').css({'display':'none'});
			$('#divCdRetorno').css({'display':'none'});
		}

	}
	return false;
}


// Exibe os campos conforme a opcao de envio de arquivos
function exibeCamposRetorno() {
	if (cIdopreto.val() == "S"){
	    cDsdirret.val('');
		cQthorret.val('');
		cDsdrrftp.val('');
		cDsdrrecd.val('');
		cDsdrrtcd.val('');
		cDsfnburt.val('');
		cDsfnchrt.val('');
		cDsfnrndv.val('');
		$('#divRetornoArq').css({'display':'none'});
		$('#divFtpRetorno').css({'display':'none'});
		$('#divCdRetorno').css({'display':'none'});
		cIdopreto.focus();
	}else{
		if( cIdtpenvi.val() == "F"){
			$('#divRetornoArq').css({'display':'block'});
			$('#divFtpRetorno').css({'display':'block'});
			$('#divCdRetorno').css({'display':'none'});
			cQthorret.focus();
		}else
		if(cIdtpenvi.val() == "C"){
			$('#divFtpRetorno').css({'display':'none'});
			$('#divCdRetorno').css({'display':'block'});
			$('#divRetornoArq').css({'display':'block'});
			cQthorret.focus();
		}
	}

	return false;
}


// Limpa os campos
function limpaCampos() {
	cTodosCabBureaux.val('');
	cTodosCabGeral.val('');
	cCddopcao.val('G');
	return false;
}

function controlaLayout() {

	atualizaSeletor();
	formataCabecalho();

	layoutPadrao();
	return false;
}