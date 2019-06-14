/*!
 * FONTE        : cadpre.js                         Última alteração: 03/08/2016
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : 04/09/2014
 * OBJETIVO     : Biblioteca de funções da tela CADPPRE
 * --------------
 * ALTERAÇÕES   : 11/07/2016 - Adicionados novos campos para a fase 3 do projeto de Pre aprovado. (Lombardi)
 *
 *                03/08/2016 - Auste para utilizar a rotina convertida para encontrar as finalidades de empréstimos
 *                             (Andrei - RKAM).	  
 *
 *                27/04/2018 - Alteração  da situação de "1,2,3,4,5,6,8,9" para "1,2,3,4,5,7,8,9". 
 *                             Projeto 366. (Lombardi)
 *				  
 *				  
 * --------------
 */
 
 var glbIdcarga;

$(document).ready(function() {

	estadoInicial();

	highlightObjFocus( $('#frmCab') );

	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	return false;

});

function estadoInicial() {

	$('#frmCab').css({'display':'block'});
	$('#frmRegra').css({'display':'none'});
	$('#frmGerar').css({'display':'none'});

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
	
	
	$('#inpessoa','#frmCab').unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }
	
		if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118 ) {	
			btnContinuar();
			return false;
		}

	});
				
	return false;
	
}

function eventTipoOpcao (){
	$('#cddopcao','#frmCab').desabilitaCampo();
	
	if ($('#cddopcao','#frmCab').val() == 'G') {
		$('#trTipoCadastro').hide();
		// Abre a tela de Gerar
		abreTelaGerar();
        trocaBotao('abreTelaGerar()','estadoInicial()');
	} else {
		$('#trTipoCadastro').show();
		$('#inpessoa','#frmCab').habilitaCampo();
		$('#inpessoa','#frmCab').focus();	
		trocaBotao('btnContinuar()','estadoInicial()');
	}	
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
	rInpessoa			= $('label[for="inpessoa"]','#frmCab');  

	cCddopcao			= $('#cddopcao','#frmCab'); 
	cInpessoa			= $('#inpessoa','#frmCab'); 

	//Rótulos
	rCddopcao.css('width','44px');
	rInpessoa.addClass('rotulo-linha');

	//Campos	
	cCddopcao.css({'width':'496px'}).habilitaCampo().focus();
	cInpessoa.addClass('inteiro').css({'width':'437px'}).desabilitaCampo();
	
	// Esconde o campo tipo de cadastro
	$('#trTipoCadastro').hide();

	controlaFoco();
	layoutPadrao();

	return false;	

}

//Formata form_regra
function formataRegra() {

	if ((cddopcao == 'A') || (cddopcao == 'C')) {

		// Rotulo
		var rCdfinemp = $('label[for="cdfinemp"]');
		var rCdlcremp = $('label[for="cdlcremp"]');
		var rNrmcotas = $('label[for="nrmcotas"]');
		var rDssitdop = $('label[for="dssitdop"]');
		var rDssitopt = $('label[for="sit1"], label[for="sit2"], label[for="sit3"], label[for="sit4"], label[for="sit5"], label[for="sit7"], label[for="sit8"], label[for="sit9"]');
        var rQtmescta = $('label[for="qtmescta"]');
        var rQtmesadm = $('label[for="qtmesadm"]');
        var rQtmesemp = $('label[for="qtmesemp"]');
		var rNrrevcad = $('label[for="nrrevcad"]');
		var rVllimmin = $('label[for="vllimmin"]');
		var rVllimctr = $('label[for="vllimctr"]');
		var rVlmulpli = $('label[for="vlmulpli"]');
		var rVlpercom = $('label[for="vlpercom"]');
		var rQtdiaver = $('label[for="qtdiaver"]');
		var rVlmaxleg = $('label[for="vlmaxleg"]');
		var rQtmesblq = $('label[for="qtmesblq"]');

		var rQtdevolu = $('label[for="qtdevolu"]');
		var rQtdiadev = $('label[for="qtdiadev"]');

		var rQtctaatr = $('label[for="qtctaatr"]');
		var rQtepratr = $('label[for="qtepratr"]');
        var rQtestour = $('label[for="qtestour"]');
		var rQtdiaest = $('label[for="qtdiaest"]');
		var rQtavlatr = $('label[for="qtavlatr"]');
		var rVlavlatr = $('label[for="vlavlatr"]');
		var rQtavlope = $('label[for="qtavlope"]');
		var rQtcjgatr = $('label[for="qtcjgatr"]');
		var rVlcjgatr = $('label[for="vlcjgatr"]');
		var rQtcjgope = $('label[for="qtcjgope"]');

		rCdfinemp.css({width:'200px'});
		rCdlcremp.css({width:'200px'});
		rNrmcotas.css({width:'200px'});
		rDssitdop.css({width:'200px'});
		rDssitopt.css({width:'20px'});
        rQtmescta.css({width:'200px'});
        rQtmesadm.css({width:'200px'});
        rQtmesemp.css({width:'200px'});
		rNrrevcad.css({width:'200px'});
		rVllimmin.css({width:'200px'});
		rVllimctr.css({width:'200px'});
		rVlmulpli.css({width:'200px'});
		rVlpercom.css({width:'200px'});
		rQtdiaver.css({width:'330px'});
		rVlmaxleg.css({width:'200px'});
		rQtmesblq.css({width:'330px'});

		rQtdevolu.css({width:'200px'});
		rQtdiadev.css({width:'200px'});

		rQtctaatr.css({width:'200px'});
		rQtepratr.css({width:'200px'});
		rQtestour.css({width:'200px'});
		rQtdiaest.css({width:'200px'});
		rQtavlatr.css({width:'200px'});
		rVlavlatr.css({width:'200px'});
		rQtavlope.css({width:'200px'});
		rQtcjgatr.css({width:'200px'});
		rVlcjgatr.css({width:'200px'});
		rQtcjgope.css({width:'200px'});

		// Campos
		var cCdfinemp = $('#cdfinemp');
		var cDsfinemp = $('#dsfinemp');
		var cCdlcremp = $('#cdlcremp');
		var cDslcremp = $('#dslcremp');
		var cNrmcotas = $('#nrmcotas');
		var cDssitopt = $('#sit1, #sit2, #sit3, #sit4, #sit5, #sit7, #sit8');
        var cQtmescta = $('#qtmescta');
        var cQtmesadm = $('#qtmesadm');
        var cQtmesemp = $('#qtmesemp');
		var cNrrevcad = $('#nrrevcad');
		var cVllimmin = $('#vllimmin');
		var cVllimctr = $('#vllimctr');
		var cVlmulpli = $('#vlmulpli');
		var cVlpercom = $('#vlpercom');
		var cQtdiaver = $('#qtdiaver');
		var cVlmaxleg = $('#vlmaxleg');
		var cQtmesblq = $('#qtmesblq');

		var cQtdevolu = $('#qtdevolu');
		var cQtdiadev = $('#qtdiadev');

		var cQtctaatr = $('#qtctaatr');
		var cQtepratr = $('#qtepratr');
		var cQtestour = $('#qtestour');
		var cQtdiaest = $('#qtdiaest');
		var cQtavlatr = $('#qtavlatr');
		var cVlavlatr = $('#vlavlatr');
		var cQtavlope = $('#qtavlope');
		var cQtcjgatr = $('#qtcjgatr');
		var cVlcjgatr = $('#vlcjgatr');
		var cQtcjgope = $('#qtcjgope');

		cCdfinemp.css({width:'70px'}).addClass('campo pesquisa').setMask('INTEGER','zzzzzzzzz9');
		cDsfinemp.css({width:'250px'}).addClass('campo');
		cCdlcremp.css({width:'70px'}).addClass('campo pesquisa').setMask('INTEGER','zzzzzzzzz9');
		cDslcremp.css({width:'250px'}).addClass('campo');
		cNrmcotas.css({width:'70px'}).addClass('campo').setMask('INTEGER','z9');
		cDssitopt.css({border:'0px'});
		cQtmescta.css({width:'70px'}).addClass('campo').setMask('INTEGER','z9');
        cQtmesadm.css({width:'70px'}).addClass('campo').setMask('INTEGER','z9');
        cQtmesemp.css({width:'70px'}).addClass('campo').setMask('INTEGER','z9');
        cNrrevcad.css({width:'70px'}).addClass('campo').setMask('INTEGER','z9');
		cVllimmin.addClass('campo').setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
		cVllimctr.addClass('campo').setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
		cVlmulpli.addClass('campo').setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
		cVlpercom.css({width:'70px'}).addClass('campo').setMask('INTEGER','z9');
		cQtdiaver.css({width:'25px'}).addClass('campo').setMask('INTEGER','z9');
		cVlmaxleg.css({width:'70px'}).addClass('campo').setMask('INTEGER','zz9');
		cQtmesblq.css({width:'25px'}).addClass('campo').setMask('INTEGER','zz9');
		
		controlaLayoutTabelaRisco();
		
		cQtdevolu.css({width:'70px'}).addClass('campo').setMask('INTEGER','zz9');
        cQtdiadev.css({width:'70px'}).addClass('campo').setMask('INTEGER','zz9');

		cQtctaatr.css({width:'70px'}).addClass('campo').setMask('INTEGER','zz9');
        cQtepratr.css({width:'70px'}).addClass('campo').setMask('INTEGER','zz9');
        cQtestour.css({width:'70px'}).addClass('campo').setMask('INTEGER','zz9');
        cQtdiaest.css({width:'70px'}).addClass('campo').setMask('INTEGER','zz9');
        cQtavlatr.css({width:'70px'}).addClass('campo').setMask('INTEGER','zz9');
        cVlavlatr.css({width:'70px'}).addClass('campo').setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
        cQtavlope.css({width:'70px'}).addClass('campo').setMask('INTEGER','zz9');
        cQtcjgatr.css({width:'70px'}).addClass('campo').setMask('INTEGER','zz9');
        cVlcjgatr.css({width:'70px'}).addClass('campo').setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
        cQtcjgope.css({width:'70px'}).addClass('campo').setMask('INTEGER','zz9');
		
		// DIV com o Valor Maximo Legal e Sugestao de Cotas
		$('#divLimiteCoop').css({'clear':'left','margin-left':'205px','font-size':'11px'});

		highlightObjFocus($('#frmRegra'));

		cTodosCampos = $('input[type="text"], select, input[type="checkbox"]','#frmRegra');
		cTodosCampos.desabilitaCampo();

		$('#inpessoa','#frmCab').desabilitaCampo();
		$('#cddopcao','#frmCab').desabilitaCampo();

		$('#cdfinemp','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#nrmcotas','#frmRegra').focus();
				return false;
			}
		});

		$('#nrmcotas','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#sit1','#frmRegra').focus();
				return false;
			}
		});

		$('#sit1','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#sit2','#frmRegra').focus();
				return false;
			}
		});

		$('#sit2','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#sit3','#frmRegra').focus();
				return false;
			}
		});

		$('#sit3','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#sit4','#frmRegra').focus();
				return false;
			}
		});

		$('#sit4','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#sit5','#frmRegra').focus();
				return false;
			}
		});

		$('#sit5','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#sit7','#frmRegra').focus();
				return false;
			}
		});

		$('#sit7','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#sit8','#frmRegra').focus();
				return false;
			}
		});

		$('#sit8','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#sit9','#frmRegra').focus();
				return false;
			}
		});

		$('#sit9','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#qtmescta','#frmRegra').focus();
				return false;
			}
		});

		$('#qtmescta','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                if (inpessoa == 1) {
                    $('#qtmesadm','#frmRegra').focus();
                } else {
                    $('#qtmesemp','#frmRegra').focus();
                }
				return false;
			}
		});

		$('#qtmesadm','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#nrrevcad','#frmRegra').focus();
				return false;
			}
		});

		$('#qtmesemp','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#nrrevcad','#frmRegra').focus();
				return false;
			}
		});

		$('#nrrevcad','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#vllimmin','#frmRegra').focus();
				return false;
			}
		});

		$('#vllimmin','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#vllimctr','#frmRegra').focus();
				return false;
			}
		});

		$('#vllimctr','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#vlmulpli','#frmRegra').focus();
				return false;
			}
		});

		$('#vlmulpli','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#vlpercom','#frmRegra').focus();
				return false;
			}
		});

		$('#vlpercom','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#qtdiaver','#frmRegra').focus();
				return false;
			}
		});
		
		$('#qtdiaver','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#vlmaxleg','#frmRegra').focus();
				return false;
			}
		});

		$('#vlmaxleg','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#qtmesblq','#frmRegra').focus();
				return false;
			}
		});
		
		$('#qtmesblq','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                acessaOpcaoAba(1);
				$('#vllimite_A','#frmRegra').focus();
				return false;
			}
		});
		
		$('#vllimite_A','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#cdlcremp_A','#frmRegra').focus();
				return false;
			}
		});
		
		$('#cdlcremp_A','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#vllimite_B','#frmRegra').focus();
				return false;
			}
		});
		
		$('#vllimite_B','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#cdlcremp_B','#frmRegra').focus();
				return false;
			}
		});
		
		$('#cdlcremp_B','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#vllimite_C','#frmRegra').focus();
				return false;
			}
		});
		
		$('#vllimite_C','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#cdlcremp_C','#frmRegra').focus();
				return false;
			}
		});
		
		$('#cdlcremp_C','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#vllimite_D','#frmRegra').focus();
				return false;
			}
		});
		
		$('#vllimite_D','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#cdlcremp_D','#frmRegra').focus();
				return false;
			}
		});
		
		$('#cdlcremp_D','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#vllimite_E','#frmRegra').focus();
				return false;
			}
		});
		
		$('#vllimite_E','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#cdlcremp_E','#frmRegra').focus();
				return false;
			}
		});
		
		$('#cdlcremp_E','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#vllimite_F','#frmRegra').focus();
				return false;
			}
		});
		
		$('#vllimite_F','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#cdlcremp_F','#frmRegra').focus();
				return false;
			}
		});
		
		$('#cdlcremp_F','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#vllimite_G','#frmRegra').focus();
				return false;
			}
		});
		
		$('#vllimite_G','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#cdlcremp_G','#frmRegra').focus();
				return false;
			}
		});
		
		$('#cdlcremp_G','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#vllimite_H','#frmRegra').focus();
				return false;
			}
		});
		
		$('#vllimite_H','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#cdlcremp_H','#frmRegra').focus();
				return false;
			}
		});
		
		$('#cdlcremp_H','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                acessaOpcaoAba(2);
				$('#' + $("input[type=checkbox][name=dslstali]").attr('id'),'#frmRegra').focus();
				return false;
			}
		});
		
		$('#' + $("input[type=checkbox][name=dslstali]").attr('id'),'#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                $('#qtdevolu','#frmRegra').focus();
				return false;
			}
		});

		$('#qtdevolu','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#qtdiadev','#frmRegra').focus();
				return false;
			}
		});

		$('#qtdiadev','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
                acessaOpcaoAba(3);
				$('#qtctaatr','#frmRegra').focus();
				return false;
			}
		});

		$('#qtctaatr','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#qtepratr','#frmRegra').focus();
				return false;
			}
		});

		$('#qtepratr','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#qtestour','#frmRegra').focus();
				return false;
			}
		});

		$('#qtestour','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#qtdiaest','#frmRegra').focus();
				return false;
			}
		});

		$('#qtdiaest','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#qtavlatr','#frmRegra').focus();
				return false;
			}
		});

		$('#qtavlatr','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#vlavlatr','#frmRegra').focus();
				return false;
			}
		});

		$('#vlavlatr','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#qtavlope','#frmRegra').focus();
				return false;
			}
		});

		$('#qtavlope','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#qtcjgatr','#frmRegra').focus();
				return false;
			}
		});

		$('#qtcjgatr','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#vlcjgatr','#frmRegra').focus();
				return false;
			}
		});

		$('#vlcjgatr','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				$('#qtcjgope','#frmRegra').focus();
				return false;
			}
		});

		$('#qtcjgope','#frmRegra').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				confirmaAlteracao();
				return false;
			}
		});

	} else if (cddopcao == 'G') {

		// Rotulo
		var rInsitcar = $('label[for="insitcar"]');
		var rDtcalcul = $('label[for="dtcalcul"]');
		
		rDtcalcul.css({width:'120px'});
		rInsitcar.css({width:'120px'});

		// Campos
		var cInsitcar = $('#insitcar','#frmGerar');
		var cDtcalcul = $('#dtcalcul','#frmGerar');
		
		cDtcalcul.css({width:'99px'}).addClass('campo');
		cDtcalcul.desabilitaCampo();
		
		cInsitcar.css({width:'100px'}).addClass('campo');
		cInsitcar.desabilitaCampo();
	}
	
    layoutPadrao();
	
	return false;	

}

function controlaLayoutTabelaRisco() {
  
  var divRegistro = $('div.divRegistros');
  var tabela      = $('table', divRegistro );
 
  divRegistro.css('height','210px');
  $('#divRiscos').css('width','600px');
  
  var ordemInicial = new Array();
  ordemInicial = [[1,0]];

  var arrayLargura = new Array();
  arrayLargura[0] = '50px';
  arrayLargura[1] = '170px';
  arrayLargura[2] = '260px';
 
  var arrayAlinha = new Array();
  arrayAlinha[0] = 'center';
  arrayAlinha[1] = 'center';
  arrayAlinha[2] = 'center';
  arrayAlinha[3] = 'center';
  
  tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
  $("th", tabela).removeClass();
  $("th", tabela).unbind('click');
  $('.headerSort','#frmRegra').removeClass();
  $('.ordemInicial','#frmRegra').removeClass(); 
  
  $('.vllimite').css({'text-align':'right'}).addClass('campo').setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
  $('.cdlcremp').addClass('campo pesquisa').css({width:'50px'}).setMask('INTEGER','zzzzzzzzz9');
  $('.dslcremp').css({width:'170px'}).addClass('campo');
  
}

function controlaCampos(op) {

    var cTodosCabecalho	= $('input[type="text"],select','#frmCab'); 
	
	cTodosCabecalho.desabilitaCampo();

	switch(op){
	
		case 'A':
			$('#cdfinemp','#frmRegra').habilitaCampo().addClass('pesquisa');
			$('#cdlcremp','#frmRegra').habilitaCampo().addClass('pesquisa');
			$('#nrmcotas','#frmRegra').habilitaCampo();
			$('#sit1, #sit2, #sit3, #sit4, #sit5, #sit7, #sit8, #sit9','#frmRegra').habilitaCampo();
            $('#qtmescta','#frmRegra').habilitaCampo();
            $('#qtmesadm','#frmRegra').habilitaCampo();
            $('#qtmesemp','#frmRegra').habilitaCampo();
			$('#nrrevcad','#frmRegra').habilitaCampo();
			$('#vllimmin','#frmRegra').habilitaCampo();
			$('#vllimctr','#frmRegra').habilitaCampo();
			$('#vlmulpli','#frmRegra').habilitaCampo();
			$('#vlpercom','#frmRegra').habilitaCampo();
			$('#qtdiaver','#frmRegra').habilitaCampo();
			$('#vlmaxleg','#frmRegra').habilitaCampo();
			$('#qtmesblq','#frmRegra').habilitaCampo();

            $('.clsAlinea','#frmRegra').habilitaCampo();
            $('#qtdevolu','#frmRegra').habilitaCampo();
			$('#qtdiadev','#frmRegra').habilitaCampo();

            $('#qtctaatr','#frmRegra').habilitaCampo();
			$('#qtepratr','#frmRegra').habilitaCampo();
            $('#qtestour','#frmRegra').habilitaCampo();
			$('#qtdiaest','#frmRegra').habilitaCampo();
			$('#qtavlatr','#frmRegra').habilitaCampo();
			$('#vlavlatr','#frmRegra').habilitaCampo();
			$('#qtavlope','#frmRegra').habilitaCampo();
			$('#qtcjgatr','#frmRegra').habilitaCampo();
			$('#vlcjgatr','#frmRegra').habilitaCampo();
			$('#qtcjgope','#frmRegra').habilitaCampo();

			
			$('.cdlcremp').habilitaCampo().addClass('pesquisa');
			$('.vllimite').habilitaCampo();
			
            controlaPesquisas();
            
            $('#cdfinemp','#frmRegra').focus();

			trocaBotao('btnContinuar()','btnVoltar()');
						
		break;
		
		default:
			trocaBotao('','btnVoltar()');
			$('#btSalvar','#divBotoes').css('display','none');
			
		break;
		
	}
	
	return false;
	
}

function btnVoltar(){

	$('#frmRegra').css('display','none');
	$('#inpessoa','#frmCab').habilitaCampo().focus().val(0);
	trocaBotao('btnContinuar()','estadoInicial()');
	return false;

}

function btnContinuar() {

    inpessoa = $('#inpessoa','#frmCab').val();
	cddopcao = $('#cddopcao','#frmCab').val();
		
	if (inpessoa > 0 ) {
        abreTelaRegra();
	} else {
        showError("error","Selecione o Tipo de Cadastro.","Alerta - Ayllos","unblockBackground();$('#inpessoa','#frmCab').focus();");
    }
	return false;	
}

function trocaBotao( funcaoSalvar,funcaoVoltar ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="'+funcaoVoltar+'; return false;">Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="'+funcaoSalvar+'; return false;">Prosseguir</a>');
	
	return false;
}

function buscaRegra() {
    
    showMsgAguardo("Aguarde, buscando regra...");
	
	// Executa script de bloqueio atraves de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpre/busca_regra.php", 
		data: {
			inpessoa: inpessoa,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success: function(response) {
            hideMsgAguardo();
            bloqueiaFundo($('#divRotina'));
            $('#divRotina').append(response);
        }
	});
    return false;
}

function abreTelaGerar() {

	showMsgAguardo('Aguarde, carregando...');
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
        dataType: 'html',
		url: UrlSite + "telas/cadpre/form_gerar.php", 
		data: {			
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
            bloqueiaFundo($('#divRotina'));
            exibeRotina($('#divRotina'));
            $('#divRotina').html(response);
		}		
	});
    return false;
}

function confirmaAlteracao() {
    showConfirmacao('Confirma a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'alteraRegra();', 'fechaRotina($("#divRotina")); btnVoltar();', 'sim.gif', 'nao.gif');
}

function alteraRegra() {

	$("input, select","#frmRegra").removeClass("campoErro");

	showMsgAguardo("Aguarde, alterando dados...");

	var cddopcao = $('#cddopcao','#frmCab').val();
    var inpessoa = $('#inpessoa','#frmCab').val();

	var cdfinemp = $('#cdfinemp','#frmRegra').val();
	var cdlcremp = $('#cdlcremp','#frmRegra').val();
	var nrmcotas = $('#nrmcotas','#frmRegra').val();

    var dssitdop = $("input[type=checkbox][name='dssitdop']:checked");
    var vlsitdop = '';
    dssitdop.each(function(){
        vlsitdop = vlsitdop + 
                  (vlsitdop == '' ? '' : ';') + 
                   $(this).val();
    });

	var qtmescta = $('#qtmescta','#frmRegra').val();
	var qtmesadm = normalizaNumero($('#qtmesadm','#frmRegra').val());
	var qtmesemp = normalizaNumero($('#qtmesemp','#frmRegra').val());
	var nrrevcad = $('#nrrevcad','#frmRegra').val();
	var vllimmin = $('#vllimmin','#frmRegra').val();
	var vllimctr = $('#vllimctr','#frmRegra').val();
	var vlmulpli = $('#vlmulpli','#frmRegra').val();
	var vlpercom = $('#vlpercom','#frmRegra').val();
	var qtdiaver = $('#qtdiaver','#frmRegra').val();
	var vlmaxleg = $('#vlmaxleg','#frmRegra').val();
	var qtmesblq = $('#qtmesblq','#frmRegra').val();

    var dslstali = $("input[type=checkbox][name='dslstali']:checked");
    var vllstali = '';
    dslstali.each(function(){
        vllstali = vllstali + 
                  (vllstali == '' ? '' : ';') + 
                   $(this).val();
    });

	var qtdevolu = $('#qtdevolu','#frmRegra').val();
	var qtdiadev = $('#qtdiadev','#frmRegra').val();
	
	var vllimite_A = $('#vllimite_A','#frmRegra').val();
	var vllimite_B = $('#vllimite_B','#frmRegra').val();
	var vllimite_C = $('#vllimite_C','#frmRegra').val();
	var vllimite_D = $('#vllimite_D','#frmRegra').val();
	var vllimite_E = $('#vllimite_E','#frmRegra').val();
	var vllimite_F = $('#vllimite_F','#frmRegra').val();
	var vllimite_G = $('#vllimite_G','#frmRegra').val();
	var vllimite_H = $('#vllimite_H','#frmRegra').val();
	
	var cdlcremp_A = $('#cdlcremp_A','#frmRegra').val();
	var cdlcremp_B = $('#cdlcremp_B','#frmRegra').val();
	var cdlcremp_C = $('#cdlcremp_C','#frmRegra').val();
	var cdlcremp_D = $('#cdlcremp_D','#frmRegra').val();
	var cdlcremp_E = $('#cdlcremp_E','#frmRegra').val();
	var cdlcremp_F = $('#cdlcremp_F','#frmRegra').val();
	var cdlcremp_G = $('#cdlcremp_G','#frmRegra').val();
	var cdlcremp_H = $('#cdlcremp_H','#frmRegra').val();
	
	var qtctaatr = $('#qtctaatr','#frmRegra').val();
	var qtepratr = $('#qtepratr','#frmRegra').val();
	var qtestour = $('#qtestour','#frmRegra').val();
	var qtdiaest = $('#qtdiaest','#frmRegra').val();
	var qtavlatr = $('#qtavlatr','#frmRegra').val();
	var vlavlatr = $('#vlavlatr','#frmRegra').val();
	var qtavlope = $('#qtavlope','#frmRegra').val();
	var qtcjgatr = $('#qtcjgatr','#frmRegra').val();
	var vlcjgatr = $('#vlcjgatr','#frmRegra').val();
	var qtcjgope = $('#qtcjgope','#frmRegra').val();
	
	if ((((vllimite_A != '' && vllimite_A != '0,00') && (cdlcremp_A == '' || cdlcremp_A == '0'))     ||
	    ((cdlcremp_A  != '' && cdlcremp_A != '0')    && (vllimite_A == '' || vllimite_A == '0,00'))) ||
		(((vllimite_B != '' && vllimite_B != '0,00') && (cdlcremp_B == '' || cdlcremp_B == '0'))     ||
	    ((cdlcremp_B  != '' && cdlcremp_B != '0')    && (vllimite_B == '' || vllimite_B == '0,00'))) ||
		(((vllimite_C != '' && vllimite_C != '0,00') && (cdlcremp_C == '' || cdlcremp_C == '0'))     ||
	    ((cdlcremp_C  != '' && cdlcremp_C != '0')    && (vllimite_C == '' || vllimite_C == '0,00'))) ||
		(((vllimite_D != '' && vllimite_D != '0,00') && (cdlcremp_D == '' || cdlcremp_D == '0'))     ||
	    ((cdlcremp_D  != '' && cdlcremp_D != '0')    && (vllimite_D == '' || vllimite_D == '0,00'))) ||
		(((vllimite_E != '' && vllimite_E != '0,00') && (cdlcremp_E == '' || cdlcremp_E == '0'))     ||
	    ((cdlcremp_E  != '' && cdlcremp_E != '0')    && (vllimite_E == '' || vllimite_E == '0,00'))) ||
		(((vllimite_F != '' && vllimite_F != '0,00') && (cdlcremp_F == '' || cdlcremp_F == '0'))     ||
	    ((cdlcremp_F  != '' && cdlcremp_F != '0')    && (vllimite_F == '' || vllimite_F == '0,00'))) ||
		(((vllimite_G != '' && vllimite_G != '0,00') && (cdlcremp_G == '' || cdlcremp_G == '0'))     ||
	    ((cdlcremp_G  != '' && cdlcremp_G != '0')    && (vllimite_G == '' || vllimite_G == '0,00'))) ||
		(((vllimite_H != '' && vllimite_H != '0,00') && (cdlcremp_H == '' || cdlcremp_H == '0'))     ||
	    ((cdlcremp_H  != '' && cdlcremp_H != '0')    && (vllimite_H == '' || vllimite_H == '0,00')))){
		hideMsgAguardo();
		showError('error','Valor limite e Linha de Cr&eacute;dito devem ser preenchidos!',"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpre/manter_rotina.php", 
		data: {
		    cddopcao: cddopcao,
			inpessoa: inpessoa,
			cdfinemp: cdfinemp,
			cdlcremp: cdlcremp,
			nrmcotas: nrmcotas,
            dssitdop: vlsitdop,
            qtmescta: qtmescta,
            qtmesadm: qtmesadm,
            qtmesemp: qtmesemp,
			nrrevcad: nrrevcad,
			vllimmin: vllimmin,
			vllimctr: vllimctr,
			vlmulpli: vlmulpli,
			vlpercom: vlpercom,
			qtdiaver: qtdiaver,
			vlmaxleg: vlmaxleg,
			qtmesblq: qtmesblq,
			vllimite_A: vllimite_A,
			vllimite_B: vllimite_B,
			vllimite_C: vllimite_C,
			vllimite_D: vllimite_D,
			vllimite_E: vllimite_E,
			vllimite_F: vllimite_F,
			vllimite_G: vllimite_G,
			vllimite_H: vllimite_H,
			cdlcremp_A: cdlcremp_A,
			cdlcremp_B: cdlcremp_B,
			cdlcremp_C: cdlcremp_C,
			cdlcremp_D: cdlcremp_D,
			cdlcremp_E: cdlcremp_E,
			cdlcremp_F: cdlcremp_F,
			cdlcremp_G: cdlcremp_G,
			cdlcremp_H: cdlcremp_H,
			dslstali: vllstali,
            qtdevolu: qtdevolu,
            qtdiadev: qtdiadev,
            qtctaatr: qtctaatr,
            qtepratr: qtepratr,
            qtestour: qtestour,
            qtdiaest: qtdiaest,
            qtavlatr: qtavlatr,
            vlavlatr: vlavlatr,
            qtavlope: qtavlope,
            qtcjgatr: qtcjgatr,
            vlcjgatr: vlcjgatr,
            qtcjgope: qtcjgope,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.',"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			}		
	});				
}

function controlaPesquisas(){

	// Variável local para guardar o elemento anterior
	var campoAnterior = '', campo = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, varAux, cdlcremp, dslcremp;
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmRegra';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');

	// Atribui a classe lupa para os links de desabilita todos
	$('a','#'+nomeFormulario).addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	$('a','#'+nomeFormulario).each( function(i) {
		
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');

		$(this).click( function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior  = $(this).prev().attr('name');
				campoPosteiror = $(this).next().attr('name');
				campoTaxa	   = $(this).next().next().attr('name');
				
				// Finalidade
                if ( campoAnterior == 'cdfinemp' ) {
					
					filtros 	= 'Finalidade do Empr.;cdfinemp;30px;S;0|Descri&ccedil&atildeo;dsfinemp;200px;S;|;flgstfin;;;1;N';
					colunas 	= 'C&oacutedigo;cdfinemp;20%;right|Finalidade;dsfinemp;80%;left';

                    //Exibir a pesquisa
					mostraPesquisa("zoom0001", "BUSCAFINEMPR", "Finalidade do Empr&eacutestimo", "30", filtros, colunas, divRotina, '$(\'#cdfinemp\',\'#frmConsulta\').focus();', nomeFormulario);

                    return false;
                } else { //campoAnterior == 'cdlcremp_'
					bo			= 'b1wgen0059.p';
					procedure	= 'busca_linhas_credito';
					titulo      = 'Linhas de Cr&eacutedito';
					qtReg		= '20';
					varAux      = $('#cdfinemp','#'+nomeFormulario).val();
					filtros 	= 'C&oacuted. Linha Cr&eacutedito;'+campoAnterior+';30px;S;0|Descri&ccedil&atildeo;'+campoPosteiror+';200px;S|;'+campoTaxa+';;N;;N|;'+null+';;N;;N|;'+null+';;N;;N|;cdfinemp;;;'+varAux+';N|;flgstlcr;;;yes;N';
					colunas 	= 'C&oacutedigo;cdlcremp;15%;right|Linha de Cr&eacutedito;dslcremp;40%;left|Taxa;txmensal;10%;right|Prest. Max.;nrfimpre;10%;right|Garantia;dsgarant;25%;left';

					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina,'populaTaxas("'+campoTaxa+'");');

					return false;
				}

			}
	});
	});
	
	return false;
}

function populaTaxas(campoTaxa){
	$('#'+campoTaxa).text(document.getElementsByName(campoTaxa)[0].value);
}

function abreTelaRegra() {

	showMsgAguardo('Aguarde, carregando...');

    // Executa script atraves de ajax
    $.ajax({		
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cadpre/form_regras.php',
        data: {
                  cddopcao: cddopcao,
                  inpessoa: inpessoa,
                  redirect: 'html_ajax'			
              }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            bloqueiaFundo($('#divRotina'));
            exibeRotina($('#divRotina'));
            $('#divRotina').html(response);
            $('#divRotina').css({ 'left': '400px' });

            // Busca os dados
            buscaRegra();
            // Formata os campos
            formataRegra();
            // Carrega aba inicial
            acessaOpcaoAba(0);
            // Se for consulta esconde o botao
            if (cddopcao == 'C') {
                $('#btConcluir').hide();
            }
        }				
    });
    return false;

}

// Funcao para acessar opcoes da rotina
function acessaOpcaoAba(id) {
    
    // Esconde as abas
    $('.clsAbas','#frmRegra').hide();
    
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

function formataGridCarga() {

    var divRegistro = $('#divCarga');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '50px' });

    var ordemInicial = new Array();
    ordemInicial = [[3, 1]];

    var arrayLargura = new Array();
    arrayLargura[0] = '80px';
    arrayLargura[1] = '90px';
    arrayLargura[2] = '70px';
    arrayLargura[3] = '70px';
    arrayLargura[4] = '70px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

	// seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click( function() {
        glbIdcarga = $(this).find('#hdn_idcarga').val();
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();

    return false;
}

function confirmarAcaoCarga(acao) {

	glbIdcarga = normalizaNumero(glbIdcarga);

	if (glbIdcarga == 0 && acao != "G") {
        showError("error","Favor selecionar uma carga!","Alerta - Ayllos","bloqueiaFundo($('#divRotina'));");
    } else {
        var cddopcao = $('#cddopcao','#frmCab').val();
        var dsmensag = (acao == 'G' ? 'Aten&ccedil;&atilde;o, todas as cargas com situa&ccedil;&atilde;o bloqueada ser&atilde;o apagadas.<br />Deseja realmente gerar uma nova carga?' : 'Confirma a opera&ccedil;&atilde;o?');
        showConfirmacao(dsmensag, 'Confirma&ccedil;&atilde;o - Ayllos', "executarAcaoCarga('" + cddopcao + "','" + acao + "','" + glbIdcarga + "');", 'bloqueiaFundo($(\'#divRotina\'));', 'sim.gif', 'nao.gif');
    }
    return false;
}

function executarAcaoCarga(cddopcao,acao,idcarga) {

    showMsgAguardo("Aguarde, carregando...");
    
    // Executa script de bloqueio através de ajax
    $.ajax({		
        type: "POST",
        url: UrlSite + "telas/cadpre/manter_rotina.php", 
        data: {
            cddopcao: cddopcao,
            acao    : acao,
            idcarga : idcarga,
            redirect: "script_ajax"
        }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
        },
        success: function(response) {
            try {
                eval(response);
                return false;
            } catch(error) {
                hideMsgAguardo();
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
            }
        }
    });

}
