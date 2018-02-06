/*!
 * FONTE        : cadlim.js
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 15/12/2014
 * OBJETIVO     : Biblioteca de funções da tela CADLIM
 * --------------
 * ALTERAÇÕES   : 21/09/2016 - Inclusão do filtro "Tipo de Limite" no cabecalho. Inclusão dos campos
 *                             "pcliqdez" e "qtdialiq" no formulario de regras. Projeto 300. (Lombardi)
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
	
	
	$('#tplimite','#frmCab').unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }
	
		if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118 ) {	
			$('#inpessoa','#frmCab').focus();
			return false;
		}

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

function eventTipoOpcao(){
	$('#cddopcao','#frmCab').desabilitaCampo();
	$('#tplimite','#frmCab').habilitaCampo();
	$('#inpessoa','#frmCab').habilitaCampo();
	$('#tplimite','#frmCab').focus();	
	trocaBotao('btnContinuar()','estadoInicial()');	
	return false;
}

function formataCabecalho() {

	$('input,select', '#frmCab').removeClass('campoErro');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	

	cTodosCabecalho = $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.limpaFormulario();

	// cabecalho
	rCddopcao = $('label[for="cddopcao"]','#frmCab');
	rTplimite = $('label[for="tplimite"]','#frmCab');
	rInpessoa = $('label[for="inpessoa"]','#frmCab');

	cCddopcao = $('#cddopcao','#frmCab'); 
	cTplimite = $('#tplimite','#frmCab'); 
	cInpessoa = $('#inpessoa','#frmCab'); 

	//Rótulos
	rCddopcao.css('width','44px');
	rTplimite.addClass('rotulo-linha').css('width','102px');
	rInpessoa.addClass('rotulo-linha').css('width','102px');

	//Campos	
	cCddopcao.css({'width':'496px'}).habilitaCampo().focus();
	cTplimite.addClass('inteiro').css({'width':'437px'}).desabilitaCampo();
	cInpessoa.addClass('inteiro').css({'width':'437px'}).desabilitaCampo();
	
	cCddopcao.val('C');
	cTplimite.val(0);
	cInpessoa.val(0);
	
	controlaFoco();
	layoutPadrao();

	return false;	

}

//Formata form_regra
function formataRegra(){

	cddopcao = $('#cddopcao','#frmCab').val();
	
	if ((cddopcao == 'A') || (cddopcao == 'C')){
		var rVlmaxren = $('label[for="vlmaxren"]');
		var rQtdiaren = $('label[for="qtdiaren"]');
		var rQtmaxren = $('label[for="qtmaxren"]');
		var rQtdiaatr = $('label[for="qtdiaatr"]');
		var rQtatracc = $('label[for="qtatracc"]');
		// Situacao da Conta		
		var rDssitdop = $('label[for="dssitdop"]');		
		var rDssitopt = $('label[for="sit1"], label[for="sit2"], label[for="sit3"], label[for="sit4"], label[for="sit5"], label[for="sit6"], label[for="sit8"], label[for="sit9"]');
		// Risco da Conta		
		var rDsriscop = $('label[for="dsriscop"]');
		var rDsrisopt = $('label[for="risA"], label[for="risB"], label[for="risC"], label[for="risD"], label[for="risE"], label[for="risF"], label[for="risG"], label[for="risH"]');
		var rQtmincta = $('label[for="qtmincta"]');
		var rNrrevcad = $('label[for="nrrevcad"]');
		var rPcliqdez = $('label[for="pcliqdez"]');
		var rQtdialiq = $('label[for="qtdialiq"]');
		var rQtcarpag = $('label[for="qtcarpag"]');
		var rQtaltlim = $('label[for="qtaltlim"]');

		rVlmaxren.css({width:'265px'});
		rQtdiaren.css({width:'265px'});
		rQtmaxren.css({width:'265px'});
		rQtdiaatr.css({width:'265px'});
		rQtatracc.css({width:'265px'});		
		rDssitdop.css({width:'265px'});
		rDssitopt.css({width:'19px'});		
		rDsriscop.css({width:'265px'});
		rDsrisopt.css({width:'19px'});		
		rQtmincta.css({width:'265px'});
		rNrrevcad.css({width:'265px'});
		rPcliqdez.css({width:'265px'});
		rQtdialiq.css({width:'265px'});
		rQtcarpag.css({width:'265px'});
		rQtaltlim.css({width:'265px'});

		// Campos
		var cVlmaxren = $('#vlmaxren');	
		var cQtdiaren = $('#qtdiaren');	
		var cQtmaxren = $('#qtmaxren');	
		var cQtdiaatr = $('#qtdiaatr');	
		var cQtatracc = $('#qtatracc');
		var cDssitopt = $("input[type=checkbox][name='dssitdop']",'#frmRegra');
		var cDstipopt = $("input[type=checkbox][name='dstipcta']",'#frmRegra');
		var cDsrisopt = $("input[type=checkbox][name='dsriscop']",'#frmRegra');
		var cQtmincta = $('#qtmincta');
		var cNrrevcad = $('#nrrevcad');	
		var cPcliqdez = $('#pcliqdez');	
		var cQtdialiq = $('#qtdialiq');	
		var cQtcarpag = $('#qtcarpag');	
		var cQtaltlim = $('#qtaltlim');	

		cVlmaxren.addClass('campo').setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
		cQtdiaren.addClass('campo').setMask('INTEGER','zzz9');
		cQtmaxren.addClass('campo').setMask('INTEGER','zz9');
		cQtdiaatr.addClass('campo').setMask('INTEGER','zz9');
		cQtatracc.addClass('campo').setMask('INTEGER','zz9');		
		cDssitopt.css({border:'0px'});
		cDstipopt.css({border:'0px'});
		cDsrisopt.css({border:'0px'});		
		cQtmincta.css({width:'70px'});
		cNrrevcad.css({width:'70px'});
		cPcliqdez.css({width:'40px'}).addClass('campo').setMask('INTEGER','zz9');
		cQtdialiq.css({width:'40px'}).addClass('campo').setMask('INTEGER','zzz9');
		cQtcarpag.css({width:'40px'}).addClass('campo').setMask('INTEGER','zzz9');
		cQtaltlim.css({width:'40px'}).addClass('campo').setMask('INTEGER','zzz9');

		highlightObjFocus($('#frmRegra'));
		cTodosCampos = $('input[type="text"], select, input[type="checkbox"]','#frmRegra');
		cTodosCampos.desabilitaCampo();

		$('#tplimite','#frmCab').desabilitaCampo();
		$('#inpessoa','#frmCab').desabilitaCampo();
		$('#cddopcao','#frmCab').desabilitaCampo();
		
		cPcliqdez.keyup(function(e) {
			if (cPcliqdez.val() > 100)
				cPcliqdez.val(100);
			return false;
		});
		
		cVlmaxren.unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				cQtdiaren.focus();
				return false;
			}	
		});
		
		cQtdiaren.unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				cQtmaxren.focus();
				return false;
			}	
		});
		
		cQtmaxren.unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				cQtdiaatr.focus();
				return false;
			}	
		});
		
		cQtdiaatr.unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				cQtatracc.focus();
				return false;
			}	
		});
		
		cQtatracc.unbind('keypress').bind('keypress', function(e) {

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
				$('#sit6','#frmRegra').focus();
				return false;
			}	
		});
		
		$('#sit6','#frmRegra').unbind('keypress').bind('keypress', function(e) {

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
				$('#risA','#frmRegra').focus();
				return false;
			}	
		});
		
		$('#risA','#frmRegra').unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#risB','#frmRegra').focus();
				return false;
			}	
		});
		
		$('#risB','#frmRegra').unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#risC','#frmRegra').focus();
				return false;
			}	
		});
		
		$('#risC','#frmRegra').unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#risD','#frmRegra').focus();
				return false;
			}	
		});
		
		$('#risD','#frmRegra').unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#risE','#frmRegra').focus();
				return false;
			}	
		});
		
		$('#risE','#frmRegra').unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#risF','#frmRegra').focus();
				return false;
			}	
		});
		
		$('#risF','#frmRegra').unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#risG','#frmRegra').focus();
				return false;
			}	
		});
		
		$('#risG','#frmRegra').unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#risH','#frmRegra').focus();
				return false;
			}	
		});
		
		$('#risH','#frmRegra').unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				cQtmincta.focus();
				return false;
			}	
		});
		
		cQtmincta.unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				cNrrevcad.focus();
				return false;
			}	
		});
		
		cNrrevcad.unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				if(cPcliqdez.is(':visible')){
					cPcliqdez.focus();
				}
				else{
					$('#btSalvar','#divBotoes').click();
				}
				return false;
			}	
		});
		
		cPcliqdez.unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				cQtdialiq.focus();
				return false;
			}	
		});
		
		cQtdialiq.unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				if(cQtcarpag.length>0){
					cQtcarpag.focus();
				}
				else{
					$('#btSalvar','#divBotoes').click();
				}
				return false;
			}	
		});

		cQtcarpag.unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				cQtaltlim.focus();
				return false;
			}	
		});
		cQtaltlim.unbind('keypress').bind('keypress', function(e) {

			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				$('#btSalvar','#divBotoes').click();
				return false;
			}	
		});

	}
	
    layoutPadrao();
	
	return false;
}

function controlaCampos(op, tplimite) {

    var cTodosCabecalho	= $('input[type="text"],select','#frmCab');	
	cTodosCabecalho.desabilitaCampo();

	switch(op){
	
	    case 'A':
			$('#vlmaxren','#frmRegra').habilitaCampo();
			$('#qtdiaren','#frmRegra').habilitaCampo();
			$('#qtmaxren','#frmRegra').habilitaCampo();
			$('#qtdiaatr','#frmRegra').habilitaCampo();
			$('#qtatracc','#frmRegra').habilitaCampo();			
			$("input[type=checkbox][name='dssitdop']",'#frmRegra').habilitaCampo();
			$("input[type=checkbox][name='dstipcta']",'#frmRegra').habilitaCampo();
			$("input[type=checkbox][name='dsriscop']",'#frmRegra').habilitaCampo();
			$('#qtmincta','#frmRegra').habilitaCampo();
			$('#nrrevcad','#frmRegra').habilitaCampo();
			$('#pcliqdez','#frmRegra').habilitaCampo();
			$('#qtdialiq','#frmRegra').habilitaCampo();
			$('#qtcarpag','#frmRegra').habilitaCampo();
			$('#qtaltlim','#frmRegra').habilitaCampo();
			$('#vlmaxren','#frmRegra').focus();
			trocaBotao('showConfirmacao(\'Confirma a opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'alteraRegra();\',\'btnVoltar();\',\'sim.gif\',\'nao.gif\')','btnVoltar()');
		break;
		
		default:
			trocaBotao('','btnVoltar()');
			$('#btSalvar','#divBotoes').css('display','none');			
		break;		
	}
	
	if (tplimite == 1){
		$('.cmpstlim','#frmRegra').css({'display':'none'});
	}
	
	return false;	
}

function btnVoltar(){
	$('#frmRegra').css('display','none');
	$('#tplimite','#frmCab').habilitaCampo().focus().val(0);
	$('#inpessoa','#frmCab').habilitaCampo().val(0);
	trocaBotao('btnContinuar()','estadoInicial()');
	return false;
}

function btnContinuar() {
    tplimite = $('#tplimite','#frmCab').val();
    inpessoa = $('#inpessoa','#frmCab').val();
	cddopcao = $('#cddopcao','#frmCab').val();
	
	if (tplimite == 0) {
		showError('error','Tipo de Limite deve ser Selecionado.','Alerta - Ayllos','unblockBackground()');
		return false;
	}
	
	if (inpessoa == 0) {
		showError('error','Tipo de Cadastro deve ser Selecionado.','Alerta - Ayllos','unblockBackground()');
		return false;
	}
	
	if (inpessoa > 0 ) {
		buscaRegra(cddopcao);
	}	
	return false;	
}

function trocaBotao( funcaoSalvar,funcaoVoltar ) {	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="'+funcaoVoltar+'; return false;">Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="'+funcaoSalvar+'; return false;">Prosseguir</a>');	
	return false;
}

function buscaRegra(op) {

	showMsgAguardo("Aguarde...");
	
	$('#tplimite','#frmCab').removeClass('campoErro');
	$('#inpessoa','#frmCab').removeClass('campoErro');
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadlim/busca_regra.php", 
		data: {
			tplimite: tplimite,
			inpessoa: inpessoa,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {			
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try { 
					$('#divRegra').html(response);
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
}

function alteraRegra() {

	$("input, select","#frmRegra").removeClass("campoErro");

	showMsgAguardo("Aguarde, alterando dados...");

	var cddopcao = $('#cddopcao','#frmCab').val();
    var tplimite = $('#tplimite','#frmCab').val();
    var inpessoa = $('#inpessoa','#frmCab').val();
	var vlmaxren = $('#vlmaxren','#frmRegra').val();
	var qtdiaren = $('#qtdiaren','#frmRegra').val();
	var qtmaxren = $('#qtmaxren','#frmRegra').val();
	var qtdiaatr = $('#qtdiaatr','#frmRegra').val();
	var qtatracc = $('#qtatracc','#frmRegra').val();
	var qtmincta = $('#qtmincta','#frmRegra').val();
	var nrrevcad = $('#nrrevcad','#frmRegra').val();
	var pcliqdez = $('#pcliqdez','#frmRegra').val();
	var qtdialiq = $('#qtdialiq','#frmRegra').val();
	var qtcarpag = $('#qtcarpag','#frmRegra').val();
	var qtaltlim = $('#qtaltlim','#frmRegra').val();
	
	var dssitdop = $("input[type=checkbox][name='dssitdop']:checked");
    var vlsitdop = '';
    dssitdop.each(function(){
        vlsitdop = vlsitdop + (vlsitdop == '' ? '' : ';') + $(this).val();
    });
	
	var dsriscop = $("input[type=checkbox][name='dsriscop']:checked");
    var vlriscop = '';
    dsriscop.each(function(){
        vlriscop = vlriscop + (vlriscop == '' ? '' : ';') + $(this).val();
    });

	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadlim/manter_rotina.php", 
		data: {
		    cddopcao: cddopcao,
			tplimite: tplimite,
			inpessoa: inpessoa,
			vlmaxren: vlmaxren,
			qtdiaren: qtdiaren,
			qtmaxren: qtmaxren,
			qtdiaatr: qtdiaatr,
			qtatracc: qtatracc,
			qtmincta: qtmincta,
			nrrevcad: nrrevcad,
			pcliqdez: pcliqdez,
			qtdialiq: qtdialiq,
			vlsitdop: vlsitdop,			
			vlriscop: vlriscop,
			qtcarpag: qtcarpag,
			qtaltlim: qtaltlim,
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
