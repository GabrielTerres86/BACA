/*!
 * FONTE        : logdda.js
 * CRIAÇÃO      : David (CECRED)
 * DATA CRIAÇÃO : Março/2011
 * OBJETIVO     : Biblioteca de funções da tela LOGDDA
 * --------------
 * ALTERAÇÕES   : 
 * 001: [02/03/2011] David (CECRED) : Desenvolver a tela LOGDDA
 * 002: [30/11/2012] Daniel(CECRED) : Alterado layout da tela, inclusão efeito fade e 
 *                                    focus, incluso função Voltar (Daniel).
 * --------------
 */

var nrseqlog     = 0; 
var detalhe      = new Array();
var strHTML      = '';
var ObjDetalhe   = new Object();
var flgConsultar = '';

$(document).ready(function() {
	$('#frmCabLogdda', '#divTela').css({'display':'block'});
	controlaFoco('');
});
 
function formataCabecalho() {	
	var nomeForm = 'frmCabLogdda';
	
	$('label[for="cddopcao"]','#'+nomeForm).addClass('rotulo').css('width','46px');
	$('label[for="dtmvtlog"]','#'+nomeForm).addClass('rotulo-linha').css('width','125px');
	
	$('#cddopcao','#'+nomeForm).addClass('data').css('width','325px').desabilitaCampo();
	$('#dtmvtlog','#'+nomeForm).addClass('data').css('width','75px').habilitaCampo();	
			
	return false;	
}

function controlaLayout(operacao,cfgtable) {
	$('#divTela').fadeTo(0,0.1);	
	$('#divLogdda').fadeTo(0,0.1);
	
	$('#divTela').css('visibility') == 'visible';
	
	if (operacao == '') {
		$('#tabConteudo').css('display','none');
		$('#tabDetalheErroDDA').css('display','none');		
		$('#dtmvtlog','#frmCabLogdda').habilitaCampo();
	} else {
		$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0px 3px 5px 3px'});		
		$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});						
		
		if (operacao == 'C') {
			if (cfgtable) {
				var divRegistro = $('div.divRegistros');		
				var tabela      = $('table',divRegistro );	
				
				divRegistro.css({'height':'150px','border-bottom':'1px solid #777','padding-bottom':'2px'});
				
				var ordemInicial = new Array();
				ordemInicial = [[0,0]];		
				
				var arrayLargura = new Array(); 
				arrayLargura[0] = '50px';
				arrayLargura[1] = '75px';
				arrayLargura[2] = '225px';		
					
				var arrayAlinha = new Array();
				arrayAlinha[0] = 'left';
				arrayAlinha[1] = 'right';
				arrayAlinha[2] = 'left';
				arrayAlinha[3] = 'left';	
				
				var metodoTabela = '';
				
				tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,'mostraDetalhamento()');
			}
			
			$('#divBotoes').css({'text-align':'center','padding-top':'5px'});
			
			$('#tabConteudo').css('display','block');
			$('#tabDetalheErroDDA').css('display','none');
		} else if (operacao == 'D') {
			var objForm = $('#frmDadosDetalheErroDDA');
			
			$('label',objForm).css({'width':'115px'}).addClass('rotulo');
			
			$('#dttransa',objForm).css({'width':'80px'});			
			$('#hrtransa',objForm).css({'width':'80px'});
			$('#nrdconta',objForm).css({'width':'80px'});
			$('#nmprimtl',objForm).css({'width':'405px'});
			$('#dscpfcgc',objForm).css({'width':'150px'});
			$('#nmmetodo',objForm).css({'width':'150px'});
			$('#cdderror',objForm).css({'width':'150px'});			
			$('#dsderror',objForm).css({'width':'405px','height':'35px','float':'left','margin':'3px 0px 3px 3px','padding-right':'1px','overflow':'hidden'});
			
			$('#dttransa,#hrtransa,#nrdconta,#nmprimtl,#dscpfcgc,#nmmetodo,#cdderror,#dsderror',objForm).desabilitaCampo();			
			
			$('#divBotoesDetalhe').css({'text-align':'center','margin-top':'5px','padding-top':'5px'});			
			
			$('#tabConteudo').css('display','none');
			$('#tabDetalheErroDDA').css('display','block');
		}
	}	
	
	layoutPadrao();		
	removeOpacidade('divTela');
	removeOpacidade('divLogdda');
	controlaFoco(operacao);
	
	highlightObjFocus( $("#frmCabLogdda") );
	
	$('#dtmvtlog','#frmCabLogdda').unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			
			consultaLog();
			return false;
		}
	});	

	return false;	
}

function controlaFoco(operacao) {
	switch(operacao) {
		case 'C': $('#btConsultar','#divBotoes').focus(); break;
		case 'D': $('#btVoltar','#divBotoesDetalhe').focus(); break;
		default: $('#dtmvtlog','#frmCabLogdda').focus(); break;
	}
}

function consultaLog() {
	if (flgConsultar != '1') { 
		showError('error','Seu usuário não possui permissão de consulta.','Alerta - Ayllos','$(\'#dtmvtlog\',\'#frmCabLogdda\').focus()'); 
		return false; 
	}
	
	
	
	if( ! $('#dtmvtlog','#frmCabLogdda').hasClass('campoTelaSemBorda') ){
	
		$('#dtmvtlog','#frmCabLogdda').desabilitaCampo();
	
		showMsgAguardo('Aguarde, consultando log ...');	
				
		var dtmvtlog = $('#dtmvtlog','#frmCabLogdda').val();
		
		// Carrega dados da conta através de ajax
		$.ajax({		
			type: 'POST',		
			url: UrlSite + 'telas/logdda/logdda_consulta.php', 
			data: { 
				dtmvtlog: dtmvtlog,				
				redirect: 'script_ajax' 
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#dtmvtlog\',\'#frmCabLogdda\').focus()');
			},
			success: function(response) { 			
				hideMsgAguardo();
				
				try {							
					eval(response);								
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}			
			}
		}); 
	}
}

function mostraDetalhamento() {
	nrseqlog = 0;
	
	$('table > tbody > tr','.divRegistros').each( function() {
		if ( $(this).hasClass('corSelecao') ) {
			nrseqlog = $('input',$(this) ).val();
		}
	});

	if (nrseqlog == 0) { return false; }	
	
	var objForm = $('#frmDadosDetalheErroDDA');
	
	$('#dttransa',objForm).val(detalhe[nrseqlog].dttransa);
	$('#hrtransa',objForm).val(detalhe[nrseqlog].hrtransa);
	$('#nrdconta',objForm).val(detalhe[nrseqlog].nrdconta);
	$('#nmprimtl',objForm).val(detalhe[nrseqlog].nmprimtl);
	$('#dscpfcgc',objForm).val(detalhe[nrseqlog].dscpfcgc);
	$('#nmmetodo',objForm).val(detalhe[nrseqlog].nmmetodo);
	$('#cdderror',objForm).val(detalhe[nrseqlog].cdderror);
	$('#dsderror',objForm).html(detalhe[nrseqlog].dsderror);
	
	controlaLayout('D');
	
	return false;
}

function Voltar() {

	$('#tabConteudo').css('display','none');
	$('#tabDetalheErroDDA').css('display','none'); 	
	$('#dtmvtlog','#frmCabLogdda').habilitaCampo();
	$('#dtmvtlog','#frmCabLogdda').focus();

}