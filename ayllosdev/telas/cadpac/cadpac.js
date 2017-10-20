/*!
 * FONTE        : cadpac.js
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 05/07/2016
 * OBJETIVO     : Biblioteca de funções da tela CADPAC
 * --------------
 * ALTERAÇÕES   : 08/08/2017 - Adicionado novo campo Habilitar Acesso CRM. (Reinert - Projeto 339)
 *                08/08/2017 - Implementacao da melhoria 438. Heitor (Mouts).
 * --------------
 */
$(document).ready(function() {

	estadoInicial();

	highlightObjFocus( $('#frmCab') );

	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	return false;

});

function estadoInicial() {
	$('#frmCab').css({'display':'block'});
	$('#frmCadpac').css({'display':'none'});	
	$('#divBotoes', '#divTela').html('').css({'display':'block'});
	formataCabecalho();
	return false;
}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {

		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }

		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			eventTipoOpcao();			
			return false;
		}	
	});

	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {

		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }

		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			eventTipoOpcao();
			return false;
		}	
	});

	$('#btnOK','#frmCab').unbind('click').bind('click', function(){
	
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }		
		eventTipoOpcao();
		return false;			
	});

	return false;
}

function eventTipoOpcao(){
	carregaTelaCadpac();
	return false;
}

function formataCabecalho() {

	$('input,select', '#frmCab').removeClass('campoErro');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	

	cTodosCabecalho = $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.limpaFormulario();

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#frmCab'); 	
	cCddopcao			= $('#cddopcao','#frmCab'); 	

	//Rótulos
	rCddopcao.css('width','44px');	

	//Campos	
	cCddopcao.css({'width':'496px'}).habilitaCampo().focus();	

	controlaFoco();
	layoutPadrao();

	return false;
}

function trocaBotao(sNomeBotaoSalvar,sFuncaoSalvar,sFuncaoVoltar) {
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="'+sFuncaoVoltar+'; return false;">Voltar</a>&nbsp;');

	if (sFuncaoSalvar != ''){
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="'+sFuncaoSalvar+'; return false;">'+sNomeBotaoSalvar+'</a>');	
	}
	return false;
}

/**
	Funcao responsavel para formatar os campos em tela
*/
function formataCamposTela(cddopcao){

    highlightObjFocus($('#frmCadpac'));

    var rCdagenci = $('label[for="cdagenci"]', '#frmCadpac');
    var rNmresage = $('label[for="nmresage"]', '#frmCadpac');
    
    var cCdagenci = $('#cdagenci', '#frmCadpac');
    var cNmresage = $('#nmresage', '#frmCadpac');

    rCdagenci.addClass('rotulo').css({'width': '40px'});
    cCdagenci.addClass('campo pesquisa').css({'width':'40px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
    cCdagenci.habilitaCampo().focus();

    rNmresage.addClass('rotulo-linha').css({'width': '110px'});
    cNmresage.addClass('campo').css({'width':'340px'}).attr('maxlength','15');
    cNmresage.desabilitaCampo();

    cCdagenci.unbind('keypress').bind('keypress', function(e) {
        if ( divError.css('display') == 'block' ) { return false; }
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            buscaDados(cddopcao);
            return false;
        }
    });

    // Oculta
    $('#divTabCampos, #fieldOpcaoB, #fieldOpcaoX, #fieldOpcaoS', '#frmCadpac').hide();

    if (cddopcao == 'C' || cddopcao == 'I' || cddopcao == 'A') {

        var rNmextage = $('label[for="nmextage"]', '#frmCadpac');
        var rInsitage = $('label[for="insitage"]', '#frmCadpac');
        var rCdcxaage = $('label[for="cdcxaage"]', '#frmCadpac');
        var rTpagenci = $('label[for="tpagenci"]', '#frmCadpac');
        var rCdccuage = $('label[for="cdccuage"]', '#frmCadpac');
        var rCdorgpag = $('label[for="cdorgpag"]', '#frmCadpac');
        var rCdagecbn = $('label[for="cdagecbn"]', '#frmCadpac');
        var rCdcomchq = $('label[for="cdcomchq"]', '#frmCadpac');
        var rVercoban = $('label[for="vercoban"]', '#frmCadpac');
        var rCdbantit = $('label[for="cdbantit"]', '#frmCadpac');
        var rCdagetit = $('label[for="cdagetit"]', '#frmCadpac');
        var rCdbanchq = $('label[for="cdbanchq"]', '#frmCadpac');
        var rCdagechq = $('label[for="cdagechq"]', '#frmCadpac');
        var rCdbandoc = $('label[for="cdbandoc"]', '#frmCadpac');
        var rCdagedoc = $('label[for="cdagedoc"]', '#frmCadpac');
        var rFlgdsede = $('label[for="flgdsede"]', '#frmCadpac');
        var rCdagepac = $('label[for="cdagepac"]', '#frmCadpac');
		var rFlmajora = $('label[for="flmajora"]', '#frmCadpac');
        var rFlgutcrm = $('label[for="flgutcrm"]', '#frmCadpac');

        var rDsendcop = $('label[for="dsendcop"]', '#frmCadpac');
        var rNrendere = $('label[for="nrendere"]', '#frmCadpac');
        var rNmbairro = $('label[for="nmbairro"]', '#frmCadpac');
        var rDscomple = $('label[for="dscomple"]', '#frmCadpac');
        var rNrcepend = $('label[for="nrcepend"]', '#frmCadpac');
        var rIdcidade = $('label[for="idcidade"]', '#frmCadpac');
        var rCdestado = $('label[for="cdestado"]', '#frmCadpac');
        var rDsdemail = $('label[for="dsdemail"]', '#frmCadpac');
        var rDsmailbd = $('label[for="dsmailbd"]', '#frmCadpac');
        var rDsinform1 = $('label[for="dsinform1"]', '#frmCadpac');
        var rDsinform2 = $('label[for="dsinform2"]', '#frmCadpac');
        var rDsinform3 = $('label[for="dsinform3"]', '#frmCadpac');

        var rRotulo_h = $('label[for="rotulo_h"]', '#frmCadpac');
        var rHhsicini = $('label[for="hhsicini"]', '#frmCadpac');
        var rHhsicfim = $('label[for="hhsicfim"]', '#frmCadpac');
        var rHhtitini = $('label[for="hhtitini"]', '#frmCadpac');
        var rHhtitfim = $('label[for="hhtitfim"]', '#frmCadpac');
        var rHhcompel = $('label[for="hhcompel"]', '#frmCadpac');
        var rHhcapini = $('label[for="hhcapini"]', '#frmCadpac');
        var rHhcapfim = $('label[for="hhcapfim"]', '#frmCadpac');
        var rHhdoctos = $('label[for="hhdoctos"]', '#frmCadpac');
        var rHhtrfini = $('label[for="hhtrfini"]', '#frmCadpac');
        var rHhtrffim = $('label[for="hhtrffim"]', '#frmCadpac');
        var rHhguigps = $('label[for="hhguigps"]', '#frmCadpac');
        var rHhbolini = $('label[for="hhbolini"]', '#frmCadpac');
        var rHhbolfim = $('label[for="hhbolfim"]', '#frmCadpac');
        var rHhenvelo = $('label[for="hhenvelo"]', '#frmCadpac');
        var rHhcpaini = $('label[for="hhcpaini"]', '#frmCadpac');
        var rHhcpafim = $('label[for="hhcpafim"]', '#frmCadpac');
        var rHhlimcan = $('label[for="hhlimcan"]', '#frmCadpac');
        var rHhsiccan = $('label[for="hhsiccan"]', '#frmCadpac');
        var rNrtelvoz = $('label[for="nrtelvoz"]', '#frmCadpac');
        var rNrtelfax = $('label[for="nrtelfax"]', '#frmCadpac');
        var rRotulopr = $('label[for="rotulopr"]', '#frmCadpac');
        var rQtddaglf = $('label[for="qtddaglf"]', '#frmCadpac');
        var rQtmesage = $('label[for="qtmesage"]', '#frmCadpac');
        var rQtddlslf = $('label[for="qtddlslf"]', '#frmCadpac');
        var rFlsgproc = $('label[for="flsgproc"]', '#frmCadpac');

        var rVllimapv = $('label[for="vllimapv"]', '#frmCadpac');
        var rQtchqprv = $('label[for="qtchqprv"]', '#frmCadpac');
        var rFlgdopgd = $('label[for="flgdopgd"]', '#frmCadpac');
        var rCdageagr = $('label[for="cdageagr"]', '#frmCadpac');
        var rCddregio = $('label[for="cddregio"]', '#frmCadpac');
        var rTpageins = $('label[for="tpageins"]', '#frmCadpac');
        var rCdorgins = $('label[for="cdorgins"]', '#frmCadpac');
        var rVlminsgr = $('label[for="vlminsgr"]', '#frmCadpac');
        var rVlmaxsgr = $('label[for="vlmaxsgr"]', '#frmCadpac');

        var cNmextage = $('#nmextage', '#frmCadpac');
        var cInsitage = $('#insitage', '#frmCadpac');
        var cCdcxaage = $('#cdcxaage', '#frmCadpac');
        var cTpagenci = $('#tpagenci', '#frmCadpac');
        var cCdccuage = $('#cdccuage', '#frmCadpac');
        var cCdorgpag = $('#cdorgpag', '#frmCadpac');
        var cCdagecbn = $('#cdagecbn', '#frmCadpac');
        var cCdcomchq = $('#cdcomchq', '#frmCadpac');
        var cVercoban = $('#vercoban', '#frmCadpac');
        var cCdbantit = $('#cdbantit', '#frmCadpac');
        var cCdagetit = $('#cdagetit', '#frmCadpac');
        var cCdbanchq = $('#cdbanchq', '#frmCadpac');
        var cCdagechq = $('#cdagechq', '#frmCadpac');
        var cCdbandoc = $('#cdbandoc', '#frmCadpac');
        var cCdagedoc = $('#cdagedoc', '#frmCadpac');
        var cFlgdsede = $('#flgdsede', '#frmCadpac');
        var cCdagepac = $('#cdagepac', '#frmCadpac');
		var cFlmajora = $('#flmajora', '#frmCadpac');
        var cFlgutcrm = $('#flgutcrm', '#frmCadpac');

        var cDsendcop = $('#dsendcop', '#frmCadpac');
        var cNrendere = $('#nrendere', '#frmCadpac');
        var cNmbairro = $('#nmbairro', '#frmCadpac');
        var cDscomple = $('#dscomple', '#frmCadpac');
        var cNrcepend = $('#nrcepend', '#frmCadpac');
        var cIdcidade = $('#idcidade', '#frmCadpac');
        var cDscidade = $('#dscidade', '#frmCadpac');
        var cCdestado = $('#cdestado', '#frmCadpac');
        var cDsdemail = $('#dsdemail', '#frmCadpac');
        var cDsmailbd = $('#dsmailbd', '#frmCadpac');
        var cDsinform1 = $('#dsinform1', '#frmCadpac');
        var cDsinform2 = $('#dsinform2', '#frmCadpac');
        var cDsinform3 = $('#dsinform3', '#frmCadpac');

        var cHhsicini = $('#hhsicini', '#frmCadpac');
        var cHhsicfim = $('#hhsicfim', '#frmCadpac');
        var cHhtitini = $('#hhtitini', '#frmCadpac');
        var cHhtitfim = $('#hhtitfim', '#frmCadpac');
        var cHhcompel = $('#hhcompel', '#frmCadpac');
        var cHhcapini = $('#hhcapini', '#frmCadpac');
        var cHhcapfim = $('#hhcapfim', '#frmCadpac');
        var cHhdoctos = $('#hhdoctos', '#frmCadpac');
        var cHhtrfini = $('#hhtrfini', '#frmCadpac');
        var cHhtrffim = $('#hhtrffim', '#frmCadpac');
        var cHhguigps = $('#hhguigps', '#frmCadpac');
        var cHhbolini = $('#hhbolini', '#frmCadpac');
        var cHhbolfim = $('#hhbolfim', '#frmCadpac');
        var cHhenvelo = $('#hhenvelo', '#frmCadpac');
        var cHhcpaini = $('#hhcpaini', '#frmCadpac');
        var cHhcpafim = $('#hhcpafim', '#frmCadpac');
        var cHhlimcan = $('#hhlimcan', '#frmCadpac');
        var cHhsiccan = $('#hhsiccan', '#frmCadpac');
        var cNrtelvoz = $('#nrtelvoz', '#frmCadpac');
        var cNrtelfax = $('#nrtelfax', '#frmCadpac');
        var cRotulopr = $('#rotulopr', '#frmCadpac');
        var cQtddaglf = $('#qtddaglf', '#frmCadpac');
        var cQtmesage = $('#qtmesage', '#frmCadpac');
        var cQtddlslf = $('#qtddlslf', '#frmCadpac');
        var cFlsgproc = $('#flsgproc', '#frmCadpac');

        var cVllimapv = $('#vllimapv', '#frmCadpac');
        var cQtchqprv = $('#qtchqprv', '#frmCadpac');
        var cFlgdopgd = $('#flgdopgd', '#frmCadpac');
        var cCdageagr = $('#cdageagr', '#frmCadpac');
        var cCddregio = $('#cddregio', '#frmCadpac');
        var cDsdregio = $('#dsdregio', '#frmCadpac');
        var cTpageins = $('#tpageins', '#frmCadpac');
        var cCdorgins = $('#cdorgins', '#frmCadpac');
        var cVlminsgr = $('#vlminsgr', '#frmCadpac');
        var cVlmaxsgr = $('#vlmaxsgr', '#frmCadpac');

        rNmextage.addClass('rotulo').css({'width': '130px'});
        rInsitage.addClass('rotulo').css({'width': '130px'});
        rCdcxaage.addClass('rotulo-linha').css({'width': '105px'});
        rTpagenci.addClass('rotulo').css({'width': '130px'});
        rCdccuage.addClass('rotulo-linha').css({'width': '223px'});
        rCdorgpag.addClass('rotulo').css({'width': '130px'});
        rCdagecbn.addClass('rotulo-linha').css({'width': '285px'});
        rCdcomchq.addClass('rotulo').css({'width': '130px'});
        rVercoban.addClass('rotulo-linha').css({'width': '285px'});
        rCdbantit.addClass('rotulo').css({'width': '130px'});
        rCdagetit.addClass('rotulo-linha').css({'width': '285px'});
        rCdbanchq.addClass('rotulo').css({'width': '130px'});
        rCdagechq.addClass('rotulo-linha').css({'width': '285px'});
        rCdbandoc.addClass('rotulo').css({'width': '130px'});
        rCdagedoc.addClass('rotulo-linha').css({'width': '285px'});
        rFlgdsede.addClass('rotulo').css({'width': '130px'});
        rCdagepac.addClass('rotulo-linha').css({'width': '285px'});
		rFlmajora.addClass('rotulo').css({'width': '130px'});
        rFlgutcrm.addClass('rotulo-linha').css({'width': '285px'});

        rDsendcop.addClass('rotulo').css({'width': '130px'});
        rNrendere.addClass('rotulo').css({'width': '130px'});
        rNmbairro.addClass('rotulo-linha').css({'width': '55px'});
        rDscomple.addClass('rotulo').css({'width': '130px'});
        rNrcepend.addClass('rotulo').css({'width': '130px'});
        rIdcidade.addClass('rotulo').css({'width': '130px'});
        rCdestado.addClass('rotulo-linha').css({'width': '55px'});
        rDsdemail.addClass('rotulo').css({'width': '130px'});
        rDsmailbd.addClass('rotulo').css({'width': '130px'});
        rDsinform1.addClass('rotulo').css({'width': '230px'});
        rDsinform2.addClass('rotulo').css({'width': '230px'});
        rDsinform3.addClass('rotulo').css({'width': '230px'});

        rRotulo_h.addClass('rotulo-linha').css({'width': '10px','text-align':'center'});
        rHhsicini.addClass('rotulo').css({'width': '230px'});
        rHhsicfim.addClass('rotulo-linha').css({'width': '25px','text-align':'center'});
        rHhtitini.addClass('rotulo').css({'width': '230px'});
        rHhtitfim.addClass('rotulo-linha').css({'width': '25px','text-align':'center'});
        rHhcompel.addClass('rotulo-linha').css({'width': '120px'});
        rHhcapini.addClass('rotulo').css({'width': '230px'});
        rHhcapfim.addClass('rotulo-linha').css({'width': '25px','text-align':'center'});
        rHhdoctos.addClass('rotulo-linha').css({'width': '120px'});
        rHhtrfini.addClass('rotulo').css({'width': '230px'});
        rHhtrffim.addClass('rotulo-linha').css({'width': '25px','text-align':'center'});
        rHhguigps.addClass('rotulo-linha').css({'width': '120px'});
        rHhbolini.addClass('rotulo').css({'width': '230px'});
        rHhbolfim.addClass('rotulo-linha').css({'width': '25px','text-align':'center'});
        rHhenvelo.addClass('rotulo-linha').css({'width': '120px'});
        rHhcpaini.addClass('rotulo').css({'width': '230px'});
        rHhcpafim.addClass('rotulo-linha').css({'width': '25px','text-align':'center'});
        rHhlimcan.addClass('rotulo').css({'width': '230px'});
        rHhsiccan.addClass('rotulo').css({'width': '230px'});
        rNrtelvoz.addClass('rotulo-linha').css({'width': '101px'});
        rNrtelfax.addClass('rotulo-linha').css({'width': '101px'});
        rRotulopr.addClass('rotulo').css({'width': '230px'});
        rQtddaglf.addClass('rotulo-linha').css({'width': '257px'});
        rQtmesage.addClass('rotulo').css({'width': '490px'});
        rQtddlslf.addClass('rotulo').css({'width': '490px'});
        rFlsgproc.addClass('rotulo').css({'width': '490px'});

        rVllimapv.addClass('rotulo').css({'width': '260px'});
        rQtchqprv.addClass('rotulo').css({'width': '260px'});
        rFlgdopgd.addClass('rotulo').css({'width': '260px'});
        rCdageagr.addClass('rotulo-linha').css({'width': '120px'});
        rCddregio.addClass('rotulo').css({'width': '180px'});
        rTpageins.addClass('rotulo').css({'width': '260px'});
        rCdorgins.addClass('rotulo').css({'width': '260px'});
        rVlminsgr.addClass('rotulo').css({'width': '260px'});
        rVlmaxsgr.addClass('rotulo').css({'width': '260px'});

        cNmextage.addClass('campo').css({'width':'411px'}).attr('maxlength','35');
        cInsitage.addClass('campo').css({'width':'240px'});
        cCdcxaage.addClass('campo').css({'width':'60px'}).attr('maxlength','4').setMask('INTEGER','zzzz','','');
        cTpagenci.addClass('campo').css({'width':'122px'});
        cCdccuage.addClass('campo').css({'width':'60px'}).attr('maxlength','4').setMask('INTEGER','zzzz','','');
        cCdorgpag.addClass('campo').css({'width':'60px'}).attr('maxlength','6').setMask('INTEGER','zzzzzz','','');
        cCdagecbn.addClass('campo').css({'width':'60px'}).attr('maxlength','4').setMask('INTEGER','zzzz','','');
        cCdcomchq.addClass('campo').css({'width':'60px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
        cVercoban.addClass('campo').css({'width':'60px'});
        cCdbantit.addClass('campo').css({'width':'60px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
        cCdagetit.addClass('campo').css({'width':'60px'}).attr('maxlength','6').setMask('INTEGER','zzzz.z','','');
        cCdbanchq.addClass('campo').css({'width':'60px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
        cCdagechq.addClass('campo').css({'width':'60px'}).attr('maxlength','6').setMask('INTEGER','zzzz.z','','');
        cCdbandoc.addClass('campo').css({'width':'60px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
        cCdagedoc.addClass('campo').css({'width':'60px'}).attr('maxlength','6').setMask('INTEGER','zzzz.z','','');
        cFlgdsede.addClass('campo').css({'width':'60px'});        
        cCdagepac.addClass('campo').css({'width':'60px'}).attr('maxlength','6').setMask('INTEGER','zz.zzz','','');
		cFlmajora.addClass('campo').css({'width':'60px'});
		
		cFlgutcrm.addClass('campo').css({'width':'60px'});

        cDsendcop.addClass('campo').css({'width':'411px'}).attr('maxlength','40');
        cNrendere.addClass('campo').css({'width':'80px'}).attr('maxlength','10').setMask('INTEGER','zzzzzzzzzz','','');
        cNmbairro.addClass('campo').css({'width':'270px'}).attr('maxlength','15');
        cDscomple.addClass('campo').css({'width':'411px'}).attr('maxlength','50');
        cNrcepend.addClass('campo').css({'width':'80px'}).attr('maxlength','10').setMask('INTEGER','zz.zzz-zzz','','');
        cIdcidade.addClass('campo pesquisa').css({'width':'80px'}).attr('maxlength','8').setMask('INTEGER','zzzzzzzz','','');
        cDscidade.addClass('campo').css({'width':'311px'}).desabilitaCampo();
        cCdestado.addClass('campo').css({'width':'50px'});
        cDsdemail.addClass('campo').css({'width':'411px'}).attr('maxlength','60');
        cDsmailbd.addClass('campo').css({'width':'411px'}).attr('maxlength','60');
        cDsinform1.addClass('campo').css({'width':'311px'}).attr('maxlength','40');
        cDsinform2.addClass('campo').css({'width':'311px'}).attr('maxlength','40');
        cDsinform3.addClass('campo').css({'width':'311px'}).attr('maxlength','40');

        cHhsicini.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhsicfim.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhtitini.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhtitfim.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhcompel.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhcapini.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhcapfim.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhdoctos.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhtrfini.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhtrffim.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhguigps.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhbolini.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhbolfim.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhenvelo.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhcpaini.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhcpafim.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhlimcan.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cHhsiccan.addClass('campo').css({'width':'50px','text-align':'center'}).attr('maxlength','5').setMask('STRING','99:99',':','');
        cNrtelvoz.addClass('campo').css({'width':'150px'}).attr('maxlength','15');
        cNrtelfax.addClass('campo').css({'width':'150px'}).attr('maxlength','15');
        cQtddaglf.addClass('campo').css({'width':'60px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
        cQtmesage.addClass('campo').css({'width':'60px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
        cQtddlslf.addClass('campo').css({'width':'60px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
        cFlsgproc.addClass('campo').css({'width':'60px'});

        cHhsicini.mask('00:00');
        cHhsicfim.mask('00:00');
        cHhtitini.mask('00:00');
        cHhtitfim.mask('00:00');
        cHhcompel.mask('00:00');
        cHhcapini.mask('00:00');
        cHhcapfim.mask('00:00');
        cHhdoctos.mask('00:00');
        cHhtrfini.mask('00:00');
        cHhtrffim.mask('00:00');
        cHhguigps.mask('00:00');
        cHhbolini.mask('00:00');
        cHhbolfim.mask('00:00');
        cHhenvelo.mask('00:00');
        cHhcpaini.mask('00:00');
        cHhcpafim.mask('00:00');
        cHhlimcan.mask('00:00');
        cHhsiccan.mask('00:00');

        cVllimapv.addClass('campo').css({'width':'120px','text-align':'right'}).setMask("DECIMAL","zzz.zzz.zz9,99","","");
        cQtchqprv.addClass('campo').css({'width':'60px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
        cFlgdopgd.addClass('campo').css({'width':'60px'});
        cCdageagr.addClass('campo').css({'width':'60px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
        cCddregio.addClass('campo pesquisa').css({'width':'60px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
        cDsdregio.addClass('campo').css({'width':'290px'}).desabilitaCampo();
        cTpageins.addClass('campo').css({'width':'60px'}).attr('maxlength','2').setMask('INTEGER','zz','','');
        cCdorgins.addClass('campo').css({'width':'60px'}).attr('maxlength','6').setMask('INTEGER','zzzzzz','','');
        cVlminsgr.addClass('campo').css({'width':'120px','text-align':'right'}).setMask("DECIMAL","zzz.zzz.zz9,99","","");
        cVlmaxsgr.addClass('campo').css({'width':'120px','text-align':'right'}).setMask("DECIMAL","zzz.zzz.zz9,99","","");
        
        if (cddopcao == 'I' || cddopcao == 'A') {

            cNmresage.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cNmextage.focus();
                    return false;
                }
            });

            cNmextage.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cInsitage.focus();
                    return false;
                }
            });

            cInsitage.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCdcxaage.focus();
                    return false;
                }
            });

            cCdcxaage.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cTpagenci.focus();
                    return false;
                }
            });

            cTpagenci.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCdccuage.focus();
                    return false;
                }
            });

            cCdccuage.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCdorgpag.focus();
                    return false;
                }
            });

            cCdorgpag.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCdagecbn.focus();
                    return false;
                }
            });

            cCdagecbn.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCdcomchq.focus();
                    return false;
                }
            });

            cCdcomchq.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cVercoban.focus();
                    return false;
                }
            });

            cVercoban.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCdbantit.focus();
                    return false;
                }
            });

            cCdbantit.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCdagetit.focus();
                    return false;
                }
            });

            cCdagetit.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCdbanchq.focus();
                    return false;
                }
            });

            cCdbanchq.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCdagechq.focus();
                    return false;
                }
            });

            cCdagechq.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCdbandoc.focus();
                    return false;
                }
            });

            cCdbandoc.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCdagedoc.focus();
                    return false;
                }
            });

            cCdagedoc.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cFlgdsede.focus();
                    return false;
                }
            });

            cFlgdsede.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
					if (cddopcao == 'A'){
						cFlmajora.focus();
					}else{
						cCdagepac.focus();
					}
                    return false;
                }
            });

            cCdagepac.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cFlmajora.focus();
                    return false;
                }
            });
			
			cFlmajora.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cFlgutcrm.focus();
                    return false;
                }
			});

			cFlgutcrm.unbind('keypress').bind('keypress', function(e) {
			    if ( divError.css('display') == 'block' ) { return false; }
			    if ( e.keyCode == 9 || e.keyCode == 13 ) {
			        acessaOpcaoAba(1);
			        cDsendcop.focus();
			        return false;
			    }
			});
			
            cDsendcop.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cDscomple.focus();
                    return false;
                }
            });

            cDscomple.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cNrendere.focus();
                    return false;
                }
            });

            cNrendere.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cNmbairro.focus();
                    return false;
                }
            });

            cNmbairro.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cNrcepend.focus();
                    return false;
                }
            });

            cNrcepend.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCdestado.focus();
                    return false;
                }
            });

            cCdestado.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cIdcidade.focus();
                    return false;
                }
            });
            cCdestado.unbind('change').bind('change', function(e) {
                controlaPesquisas();
            });

            cIdcidade.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cDsdemail.focus();
                    return false;
                }
            });
            cIdcidade.unbind('focus').bind('focus', function(e) {
                controlaPesquisas();
            });

            cDsdemail.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cDsmailbd.focus();
                    return false;
                }
            });

            cDsmailbd.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cDsinform1.focus();
                    return false;
                }
            });

            cDsinform1.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cDsinform2.focus();
                    return false;
                }
            });

            cDsinform2.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cDsinform3.focus();
                    return false;
                }
            });

            cDsinform3.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    acessaOpcaoAba(2);
                    cHhsicini.focus();
                    return false;
                }
            });

            cHhsicini.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhsicfim.focus();
                    return false;
                }
            });

            cHhsicfim.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhtitini.focus();
                    return false;
                }
            });

            cHhtitini.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhtitfim.focus();
                    return false;
                }
            });

            cHhtitfim.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhcompel.focus();
                    return false;
                }
            });

            cHhcompel.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhcapini.focus();
                    return false;
                }
            });

            cHhcapini.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhcapfim.focus();
                    return false;
                }
            });

            cHhcapfim.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhdoctos.focus();
                    return false;
                }
            });

            cHhdoctos.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhtrfini.focus();
                    return false;
                }
            });

            cHhtrfini.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhtrffim.focus();
                    return false;
                }
            });

            cHhtrffim.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhguigps.focus();
                    return false;
                }
            });

            cHhguigps.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhbolini.focus();
                    return false;
                }
            });

            cHhbolini.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhbolfim.focus();
                    return false;
                }
            });

            cHhbolfim.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhenvelo.focus();
                    return false;
                }
            });

            cHhenvelo.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhcpaini.focus();
                    return false;
                }
            });

            cHhcpaini.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhcpafim.focus();
                    return false;
                }
            });

            cHhcpafim.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhlimcan.focus();
                    return false;
                }
            });

            cHhlimcan.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cNrtelvoz.focus();
                    return false;
                }
            });

            cNrtelvoz.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cHhsiccan.focus();
                    return false;
                }
            });

            cHhsiccan.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cNrtelfax.focus();
                    return false;
                }
            });

            cNrtelfax.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cQtddaglf.focus();
                    return false;
                }
            });

            cQtddaglf.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cQtmesage.focus();
                    return false;
                }
            });

            cQtmesage.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cQtddlslf.focus();
                    return false;
                }
            });

            cQtddlslf.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cFlsgproc.focus();
                    return false;
                }
            });

            cFlsgproc.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    acessaOpcaoAba(3);
                    cVllimapv.focus();
                    return false;
                }
            });

            cVllimapv.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cQtchqprv.focus();
                    return false;
                }
            });

            cQtchqprv.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cFlgdopgd.focus();
                    return false;
                }
            });

            cFlgdopgd.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCdageagr.focus();
                    return false;
                }
            });

            cCdageagr.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCddregio.focus();
                    return false;
                }
            });

            cCddregio.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cTpageins.focus();
                    return false;
                }
            });

            cTpageins.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cCdorgins.focus();
                    return false;
                }
            });

            cCdorgins.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cVlminsgr.focus();
                    return false;
                }
            });

            cVlminsgr.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    cVlmaxsgr.focus();
                    return false;
                }
            });

            cVlmaxsgr.unbind('keypress').bind('keypress', function(e) {
                if ( divError.css('display') == 'block' ) { return false; }
                if ( e.keyCode == 9 || e.keyCode == 13 ) {
                    confirmaAcao();
                    return false;
                }
            });

        }

    } else if (cddopcao == 'B') {

        var rNrdcaixa = $('label[for="nrdcaixa"]', '#frmCadpac');
        var rCdopercx = $('label[for="cdopercx"]', '#frmCadpac');
        var rDtdcaixa = $('label[for="dtdcaixa"]', '#frmCadpac');

        var cNrdcaixa = $('#nrdcaixa', '#frmCadpac');
        var cCdopercx = $('#cdopercx', '#frmCadpac');
        var cDtdcaixa = $('#dtdcaixa', '#frmCadpac');

        rNrdcaixa.addClass('rotulo').css({'width': '213px'});
        rCdopercx.addClass('rotulo').css({'width': '213px'});
        rDtdcaixa.addClass('rotulo').css({'width': '213px'});

        cNrdcaixa.addClass('campo').css({'width':'60px'}).attr('maxlength','4').setMask('INTEGER','zzz','','');
        cCdopercx.addClass('campo').css({'width':'120px'}).desabilitaCampo().attr('maxlength','10');
        cDtdcaixa.addClass('campo').css({'width':'120px'}).desabilitaCampo().setMask('DATE','99/99/9999');

        cNrdcaixa.unbind('keypress').bind('keypress', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                validarCaixa();
                return false;
            }
        });

        cCdopercx.unbind('keypress').bind('keypress', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                cDtdcaixa.focus();
                return false;
            }
        });

        cDtdcaixa.unbind('keypress').bind('keypress', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                confirmaAcao();
                return false;
            }
        });

    } else if (cddopcao == 'X') {

        var rVllimapv = $('label[for="vllimapv_x"]', '#frmCadpac');
        var cVllimapv = $('#vllimapv_x', '#frmCadpac');

        rVllimapv.addClass('rotulo').css({'width': '260px'});
        cVllimapv.addClass('campo').css({'width':'120px','text-align':'right'}).setMask("DECIMAL","zzz.zzz.zz9,99","","");

        cVllimapv.unbind('keypress').bind('keypress', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                confirmaAcao();
                return false;
            }
        });

    } else if (cddopcao == 'S') {

        var rNmpasite = $('label[for="nmpasite"]', '#frmCadpac');
        var rDstelsit = $('label[for="dstelsit"]', '#frmCadpac');
        var rDsemasit = $('label[for="dsemasit"]', '#frmCadpac');
        var rDshorsit = $('label[for="dshorsit"]', '#frmCadpac');
        var rNrlatitu = $('label[for="nrlatitu"]', '#frmCadpac');
        var rNrlongit = $('label[for="nrlongit"]', '#frmCadpac');

        var cNmpasite = $('#nmpasite', '#frmCadpac');
        var cDstelsit = $('#dstelsit', '#frmCadpac');
        var cDsemasit = $('#dsemasit', '#frmCadpac');
        var cDshorsit = $('#dshorsit', '#frmCadpac');
        var cNrlatitu = $('#nrlatitu', '#frmCadpac');
        var cNrlongit = $('#nrlongit', '#frmCadpac');

        rNmpasite.addClass('rotulo').css({'width': '165px'});
        rDstelsit.addClass('rotulo').css({'width': '165px'});
        rDsemasit.addClass('rotulo').css({'width': '165px'});
        rDshorsit.addClass('rotulo').css({'width': '165px'});
        rNrlatitu.addClass('rotulo').css({'width': '165px'});
        rNrlongit.addClass('rotulo').css({'width': '165px'});

        cNmpasite.addClass('campo').css({'width':'340px'}).attr('maxlength','200');
        cDstelsit.addClass('campo').css({'width':'340px'}).attr('maxlength','50');
        cDsemasit.addClass('campo').css({'width':'340px'}).attr('maxlength','60');
        cDshorsit.addClass('campo').css({'width':'340px','height':'70px','float':'left','margin':'3px 0px 3px 3px'}).attr('maxlength','200');
        cNrlatitu.addClass('campo').css({'width':'340px'});
        cNrlongit.addClass('campo').css({'width':'340px'});

        cNmpasite.unbind('keypress').bind('keypress', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                cDstelsit.focus();
                return false;
            }
        });

        cDstelsit.unbind('keypress').bind('keypress', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                cDsemasit.focus();
                return false;
            }
        });

        cDsemasit.unbind('keypress').bind('keypress', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                cDshorsit.focus();
                return false;
            }
        });

        cDshorsit.unbind('keypress').bind('keypress', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }
            if ( e.keyCode == 9 || (e.keyCode == 13 && !e.shiftKey) ) {
                cNrlatitu.focus();
                return false;
            }
        });
        cDshorsit.bind('input propertychange', function() {
            var maxLength = $(this).attr('maxlength');
            if ($(this).val().length > maxLength) {
                $(this).val($(this).val().substring(0, maxLength));
            }
        });
		
        cNrlatitu.unbind('keypress').bind('keypress', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }
            if ( e.keyCode == 9 || e.keyCode == 13 ) {
                cNrlongit.focus();
                return false;
            }
        });
        cNrlatitu.keyup(function () { 
            this.value = this.value.replace(/[^0-9.-]/g,''); // Deixa digitar somente hífen, ponto e número
            
            if ((this.value.match(/^\-$/g) || []).length == 0) //Remove a última ocorrência do hífen
                this.value = this.value.replace(/\-$/g,'');
            
            if ((this.value.match(/\./g) || []).length > 1) //Remove as ocorrências de ponto (.), deixando apenas a primeira
                this.value = this.value.replace(/\.$/g,'');
            
        });

        cNrlongit.unbind('keypress').bind('keypress', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }
            if ( e.keyCode == 9 || (e.keyCode == 13 && !e.shiftKey) ) {
                confirmaAcao();
                return false;
            }
        });
        cNrlongit.keyup(function () { 
            this.value = this.value.replace(/[^0-9.-]/g,''); // Deixa digitar somente hífen, ponto e número
            
            if ((this.value.match(/^\-$/g) || []).length == 0) //Remove a última ocorrência do hífen
                this.value = this.value.replace(/\-$/g,'');
            
            if ((this.value.match(/\./g) || []).length > 1) //Remove as ocorrências de ponto (.), deixando apenas a primeira
                this.value = this.value.replace(/\.$/g,'');
        });

    }

	layoutPadrao();
	controlaPesquisas();	
    return false;
}	

function controlaPesquisas() {

    var nmformul = 'frmCadpac';
    var cdcooper = $('#cdcooper', '#' + nmformul).val();
    var cdestado = $('#cdestado', '#' + nmformul).val();
    var campoAnterior = '';
    var lupas = $('a', '#' + nmformul);

    // Atribui a classe lupa para os links
    lupas.addClass('lupa').css('cursor', 'pointer');

    // Percorrendo todos os links
    lupas.each(function() {
        $(this).unbind('click').bind('click', function() {

            if ($(this).prev().hasClass('campoTelaSemBorda')) {
                return false;
            } else {
                // Obtenho o nome do campo anterior
                campoAnterior = $(this).prev().attr('name');

                // PA
                if (campoAnterior == 'cdagenci') {
                    bo			= 'b1wgen0059.p';
                    procedure	= 'busca_pac';
                    titulo      = 'Agência PA';
                    qtReg		= '20';					
                    filtrosPesq	= 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
                    colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
                    mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
                    return false;
                // Regional
                } else if (campoAnterior == 'cddregio') {
                    bo          = 'CONLDB'
                    procedure   = 'LISTA_REGIONAL';
                    titulo      = 'Regionais';
                    qtReg       = '20';
                    filtrosPesq = 'Codigo;cddregio;200px;S;;S;descricao|Descricao;dsdregio;200px;S;;N;descricao|Conta;cdcooper;100px;S;' + cdcooper + ';N';
                    colunas     = 'Codigo;cddregio;30%;center|Descricao;dsdregio;70%;left';
                    mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
                    return false;
                // Cidade
                } else if (campoAnterior == 'idcidade') {
                    bo          = 'CADA0003'
                    procedure   = 'LISTA_CIDADES';
                    titulo      = 'Cidades';
                    qtReg       = '20';
                    filtrosPesq = 'Codigo;idcidade;70px;S;;S;codigo|Cidade;dscidade;200px;S;;S;descricao|UF;cdestado;40px;S;' + cdestado + ';S;descricao|;infiltro;;N;1;N;codigo|;intipnom;;N;1;N;codigo|;cdcidade;;N;0;N;codigo';
                    colunas     = 'Codigo;idcidade;30%;center|Cidade;dscidade;60%;left|UF;cdestado;10%;center';
                    mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
                    return false;
                }
            }
        });
    });
}

/**
	Funcao responsavel para carregar a tela
*/
function carregaTelaCadpac(){

	showMsgAguardo("Aguarde...");
	
	var cCddopcao = $('#cddopcao','#frmCab');
	cCddopcao.desabilitaCampo();

	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpac/principal.php", 
		data: {			
			cddopcao: cCddopcao.val(),
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
			try {
				$('#divCadastro').html(response);

                var nmBotao = 'Continuar';
                var nmFuncao = 'buscaDados(\'' + cCddopcao.val() + '\');';

                // Exibe os botoes
                trocaBotao(nmBotao,nmFuncao,'estadoInicial()');

				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

/**
	Funcao responsavel por buscar os dados
*/
function buscaDados(cddopcao) {

	showMsgAguardo("Aguarde...");

    var cdagenci = $('#cdagenci','#frmCadpac').val();

    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpac/busca_dados.php", 
		data: {			
			cddopcao: cddopcao,
            cdagenci: normalizaNumero(cdagenci),
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
			try { 
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

// Funcao para acessar opcoes da rotina
function acessaOpcaoAba(id) {
    
    // Esconde as abas
    $('.clsAbas','#frmCadpac').hide();
    
	// Atribui cor de destaque para aba da opcao
	for (var i = 0; i < 4; i++) {
		if (id == i) { // Atribui estilos para foco da opcao
			$("#linkAba" + id).attr("class","txtBrancoBold");
			$("#imgAbaEsq" + id).attr("src",UrlImagens + "background/mnu_sle.gif");				
			$("#imgAbaDir" + id).attr("src",UrlImagens + "background/mnu_sld.gif");
			$("#imgAbaCen" + id).css("background-color","#969FA9");
            $("#divAba" + id).show();
			continue;			
		}
		$("#linkAba" + i).attr("class","txtNormalBold");
		$("#imgAbaEsq" + i).attr("src",UrlImagens + "background/mnu_nle.gif");			
		$("#imgAbaDir" + i).attr("src",UrlImagens + "background/mnu_nld.gif");
		$("#imgAbaCen" + i).css("background-color","#C6C8CA");
	}
}

/**
	Funcao responsavel para confirmar acao
*/
function confirmaAcao() {

    var cddopcao = $('#cddopcao','#frmCab').val();
    var nmfuncao = 'gravarPAC()';

    if (cddopcao == 'B') {
        nmfuncao = 'gravarCaixa()';
    } else if (cddopcao == 'X') {
        nmfuncao = 'gravarValorAprovComite()';
    } else if (cddopcao == 'S') {
        nmfuncao = 'gravarDadosSite()';
    }

    showConfirmacao('Confirma a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', nmfuncao, '', 'sim.gif', 'nao.gif');
}

/**
	Funcao responsavel por gravar os dados
*/
function gravarDadosSite() {

    var cddopcao = $('#cddopcao','#frmCab').val();
    var cdagenci = $('#cdagenci','#frmCadpac').val();
    var nmpasite = $('#nmpasite','#frmCadpac').val();
    var dstelsit = $('#dstelsit','#frmCadpac').val();
    var dsemasit = $('#dsemasit','#frmCadpac').val();
    var dshorsit = $('#dshorsit','#frmCadpac').val();
    var nrlatitu = $('#nrlatitu','#frmCadpac').val();
    var nrlongit = $('#nrlongit','#frmCadpac').val();

    showMsgAguardo("Aguarde, processando...");
		
    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpac/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
            cdagenci: normalizaNumero(cdagenci),
            nmpasite: nmpasite,
            dstelsit: dstelsit,
            dsemasit: dsemasit,
            dshorsit: dshorsit,
            nrlatitu: nrlatitu,
            nrlongit: nrlongit,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			try { 
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

/**
	Funcao responsavel por gravar os dados
*/
function gravarCaixa() {

    var cddopcao = $('#cddopcao','#frmCab').val();
    var cdagenci = $('#cdagenci','#frmCadpac').val();
    var nrdcaixa = $('#nrdcaixa','#frmCadpac').val();
    var cdopercx = $('#cdopercx','#frmCadpac').val();
    var dtdcaixa = $('#dtdcaixa','#frmCadpac').val();
    var rowidcxa = $('#rowidcxa','#frmCadpac').val();

    showMsgAguardo("Aguarde, processando...");

    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpac/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
            cdagenci: normalizaNumero(cdagenci),
			nrdcaixa: normalizaNumero(nrdcaixa),
            cdopercx: cdopercx,
            dtdcaixa: dtdcaixa,
            rowidcxa: rowidcxa,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			try { 
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

/**
	Funcao responsavel por validar os dados
*/
function validarCaixa() {

    var cddopcao = $('#cddopcao','#frmCab').val();
    var cdagenci = $('#cdagenci','#frmCadpac').val();
    var nrdcaixa = $('#nrdcaixa','#frmCadpac').val();

    showMsgAguardo("Aguarde, processando...");

    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpac/validar.php", 
		data: {
			cddopcao: cddopcao,
            cdagenci: normalizaNumero(cdagenci),
			nrdcaixa: normalizaNumero(nrdcaixa),
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			try { 
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

/**
	Funcao responsavel por gravar os dados
*/
function gravarValorAprovComite() {

    var cddopcao = $('#cddopcao','#frmCab').val();
    var cdagenci = $('#cdagenci','#frmCadpac').val();
    var vllimapv = $('#vllimapv_x','#frmCadpac').val();

    showMsgAguardo("Aguarde, processando...");

    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpac/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
            cdagenci: normalizaNumero(cdagenci),
			vllimapv: vllimapv,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			try { 
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}

/**
	Funcao responsavel por gravar os dados
*/
function gravarPAC() {

    var cddopcao = $('#cddopcao','#frmCab').val();
    var cdagenci = $('#cdagenci','#frmCadpac').val();
    var nmextage = $('#nmextage','#frmCadpac').val();
    var nmresage = $('#nmresage','#frmCadpac').val();
    var insitage = $('#insitage','#frmCadpac').val();
    var cdcxaage = $('#cdcxaage','#frmCadpac').val();
    var tpagenci = $('#tpagenci','#frmCadpac').val();
    var cdccuage = $('#cdccuage','#frmCadpac').val();
    var cdorgpag = $('#cdorgpag','#frmCadpac').val();
    var cdagecbn = $('#cdagecbn','#frmCadpac').val();
    var cdcomchq = $('#cdcomchq','#frmCadpac').val();
    var vercoban = $('#vercoban','#frmCadpac').val();
    var cdbantit = $('#cdbantit','#frmCadpac').val();
    var cdagetit = $('#cdagetit','#frmCadpac').val();
    var cdbanchq = $('#cdbanchq','#frmCadpac').val();
    var cdagechq = $('#cdagechq','#frmCadpac').val();
    var cdbandoc = $('#cdbandoc','#frmCadpac').val();
    var cdagedoc = $('#cdagedoc','#frmCadpac').val();
    var flgdsede = $('#flgdsede','#frmCadpac').val();
    var cdagepac = $('#cdagepac','#frmCadpac').val();
    var flgutcrm = $('#flgutcrm','#frmCadpac').val();
    var dsendcop = $('#dsendcop','#frmCadpac').val();
    var nrendere = $('#nrendere','#frmCadpac').val();
    var nmbairro = $('#nmbairro','#frmCadpac').val();
    var dscomple = $('#dscomple','#frmCadpac').val();
    var nrcepend = $('#nrcepend','#frmCadpac').val();
    var idcidade = $('#idcidade','#frmCadpac').val();
    var dscidade = $('#dscidade','#frmCadpac').val();
    var cdestado = $('#cdestado','#frmCadpac').val();
    var dsdemail = $('#dsdemail','#frmCadpac').val();
    var dsmailbd = $('#dsmailbd','#frmCadpac').val();
    var dsinform1 = $('#dsinform1','#frmCadpac').val();
    var dsinform2 = $('#dsinform2','#frmCadpac').val();
    var dsinform3 = $('#dsinform3','#frmCadpac').val();
    var hhsicini = $('#hhsicini','#frmCadpac').val();
    var hhsicfim = $('#hhsicfim','#frmCadpac').val();
    var hhtitini = $('#hhtitini','#frmCadpac').val();
    var hhtitfim = $('#hhtitfim','#frmCadpac').val();
    var hhcompel = $('#hhcompel','#frmCadpac').val();
    var hhcapini = $('#hhcapini','#frmCadpac').val();
    var hhcapfim = $('#hhcapfim','#frmCadpac').val();
    var hhdoctos = $('#hhdoctos','#frmCadpac').val();
    var hhtrfini = $('#hhtrfini','#frmCadpac').val();
    var hhtrffim = $('#hhtrffim','#frmCadpac').val();
    var hhguigps = $('#hhguigps','#frmCadpac').val();
    var hhbolini = $('#hhbolini','#frmCadpac').val();
    var hhbolfim = $('#hhbolfim','#frmCadpac').val();
    var hhenvelo = $('#hhenvelo','#frmCadpac').val();
    var hhcpaini = $('#hhcpaini','#frmCadpac').val();
    var hhcpafim = $('#hhcpafim','#frmCadpac').val();
    var hhlimcan = $('#hhlimcan','#frmCadpac').val();
    var hhsiccan = $('#hhsiccan','#frmCadpac').val();
    var nrtelvoz = $('#nrtelvoz','#frmCadpac').val();
    var nrtelfax = $('#nrtelfax','#frmCadpac').val();
    var qtddaglf = $('#qtddaglf','#frmCadpac').val();
    var qtmesage = $('#qtmesage','#frmCadpac').val();
    var qtddlslf = $('#qtddlslf','#frmCadpac').val();
    var flsgproc = $('#flsgproc','#frmCadpac').val();
    var vllimapv = $('#vllimapv','#frmCadpac').val();
    var qtchqprv = $('#qtchqprv','#frmCadpac').val();
    var flgdopgd = $('#flgdopgd','#frmCadpac').val();
    var cdageagr = $('#cdageagr','#frmCadpac').val();
    var cddregio = $('#cddregio','#frmCadpac').val();
    var tpageins = $('#tpageins','#frmCadpac').val();
    var cdorgins = $('#cdorgins','#frmCadpac').val();
    var vlminsgr = $('#vlminsgr','#frmCadpac').val();
    var vlmaxsgr = $('#vlmaxsgr','#frmCadpac').val();
	var flmajora = $('#flmajora','#frmCadpac').val();

    showMsgAguardo("Aguarde, processando...");

    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpac/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
            cdagenci: normalizaNumero(cdagenci),
			nmextage: nmextage,
            nmresage: nmresage,
            insitage: normalizaNumero(insitage),
            cdcxaage: normalizaNumero(cdcxaage),
            tpagenci: normalizaNumero(tpagenci),
            cdccuage: normalizaNumero(cdccuage),
            cdorgpag: normalizaNumero(cdorgpag),
            cdagecbn: normalizaNumero(cdagecbn),
            cdcomchq: normalizaNumero(cdcomchq),
            vercoban: normalizaNumero(vercoban),
            cdbantit: normalizaNumero(cdbantit),
            cdagetit: normalizaNumero(cdagetit),
            cdbanchq: normalizaNumero(cdbanchq),
            cdagechq: normalizaNumero(cdagechq),
            cdbandoc: normalizaNumero(cdbandoc),
            cdagedoc: normalizaNumero(cdagedoc),
            flgdsede: normalizaNumero(flgdsede),
            cdagepac: normalizaNumero(cdagepac),
            flgutcrm: normalizaNumero(flgutcrm),
            dsendcop: dsendcop,
            nrendere: normalizaNumero(nrendere),
            nmbairro: nmbairro,
            dscomple: dscomple,
            nrcepend: normalizaNumero(nrcepend),
            idcidade: normalizaNumero(idcidade),
            nmcidade: dscidade,
            cdufdcop: cdestado,
            dsdemail: dsdemail,
            dsmailbd: dsmailbd,
            dsinform1: dsinform1,
            dsinform2: dsinform2,
            dsinform3: dsinform3,
            hhsicini: hhsicini,
            hhsicfim: hhsicfim,
            hhtitini: hhtitini,
            hhtitfim: hhtitfim,
            hhcompel: hhcompel,
            hhcapini: hhcapini,
            hhcapfim: hhcapfim,
            hhdoctos: hhdoctos,
            hhtrfini: hhtrfini,
            hhtrffim: hhtrffim,
            hhguigps: hhguigps,
            hhbolini: hhbolini,
            hhbolfim: hhbolfim,
            hhenvelo: hhenvelo,
            hhcpaini: hhcpaini,
            hhcpafim: hhcpafim,
            hhlimcan: hhlimcan,
            hhsiccan: hhsiccan,
            nrtelvoz: nrtelvoz,
            nrtelfax: nrtelfax,
            qtddaglf: normalizaNumero(qtddaglf),
            qtmesage: normalizaNumero(qtmesage),
            qtddlslf: normalizaNumero(qtddlslf),
            flsgproc: flsgproc,
            vllimapv: vllimapv,
            qtchqprv: normalizaNumero(qtchqprv),
            flgdopgd: flgdopgd,
            cdageagr: normalizaNumero(cdageagr),
            cddregio: normalizaNumero(cddregio),
            tpageins: normalizaNumero(tpageins),
            cdorgins: normalizaNumero(cdorgins),
            vlminsgr: vlminsgr,
            vlmaxsgr: vlmaxsgr,
			flmajora: flmajora,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			try { 
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}
	});
}
