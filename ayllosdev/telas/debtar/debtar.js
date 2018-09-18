/*!
 * FONTE        : debtar.js
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : 26/01/2015
 * OBJETIVO     : Biblioteca de funções da tela DEBTAR
 * --------------
 * ALTERAÇÕES   : 
 * -----------------------------------------------------------------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmDebtar       = 'frmDebtar';

//Labels/Campos do cabeçalho
var rInpessoa, rCddopcao, rCdhistor, rCdmotest, rCdcooper, rCdagenci, rNrdconta, rDtinicio, rDtafinal, rCdhisest, 
	cInpessoa, cCddopcao, cCdhistor, cCdmotest, cCdcooper, cCdagenci, cNrdconta, cDtinicio, cDtafinal, cCdhisest,
	cDshistor, cDshisest, cDsmotest, cNmrescop, cNmresage, cNmprimtl, cGlbcoope, cCddgrupo, cCdsubgru, cDsdgrupo,
	cDssubgru, rCddgrupo, rCdsubgru, glbTabRowid, glbDtmvtolt, glbCdcooper;

$(document).ready(function() {
	estadoInicial();
	inicializaVar();
});

var dates = {
    convert:function(d) {
        // Converts the date in d to a date-object. The input can be:
        //   a date object: returned without modification
        //  an array      : Interpreted as [year,month,day]. NOTE: month is 0-11.
        //   a number     : Interpreted as number of milliseconds
        //                  since 1 Jan 1970 (a timestamp) 
        //   a string     : Any format supported by the javascript engine, like
        //                  "YYYY/MM/DD", "MM/DD/YYYY", "Jan 31 2009" etc.
        //  an object     : Interpreted as an object with year, month and date
        //                  attributes.  **NOTE** month is 0-11.
        return (
            d.constructor === Date ? d :
            d.constructor === Array ? new Date(d[0],d[1],d[2]) :
            d.constructor === Number ? new Date(d) :
            d.constructor === String ? new Date(d) :
            typeof d === "object" ? new Date(d.year,d.month,d.date) :
            NaN
        );
    },
    compare:function(a,b) {
        // Compare two dates (could be of any type supported by the convert
        // function above) and returns:
        //  -1 : if a < b
        //   0 : if a = b
        //   1 : if a > b
        // NaN : if a or b is an illegal date
        // NOTE: The code inside isFinite does an assignment (=).
        return (
            isFinite(a=this.convert(a).valueOf()) &&
            isFinite(b=this.convert(b).valueOf()) ?
            (a>b)-(a<b) :
            NaN
        );
    },
    inRange:function(d,start,end) {
        // Checks if date in d is between dates in start and end.
        // Returns a boolean or NaN:
        //    true  : if d is between start and end (inclusive)
        //    false : if d is before start or after end
        //    NaN   : if one or more of the dates is illegal.
        // NOTE: The code inside isFinite does an assignment (=).
       return (
            isFinite(d=this.convert(d).valueOf()) &&
            isFinite(start=this.convert(start).valueOf()) &&
            isFinite(end=this.convert(end).valueOf()) ?
            start <= d && d <= end :
            NaN
        );
    }
}

function getDateUS(datapt){
	var adata = datapt.split("/");
	var arrData = [0,0,0];
	arrData[0] = adata[2];
	arrData[1] = adata[1];
	arrData[2] = adata[0];	
	
	return arrData;
}

function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	
	hideMsgAguardo();		
	formataCabecalho();
	formatafrmDebtar();
	controlaNavegacao();
	$("#divTarifaPendente").html('');
	
	trocaBotao('Carregar');
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmDebtar') );
	
	$('#frmCab').css({'display':'block'});
	$('#frmDebtar').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	
	cCdcooper.habilitaCampo();
	cInpessoa.habilitaCampo();
	cCddopcao.habilitaCampo();
	cCdagenci.habilitaCampo();
	cNrdconta.habilitaCampo();
	cCdhistor.habilitaCampo();
	cCdhisest.habilitaCampo();
	cCddgrupo.habilitaCampo();
	cCdsubgru.habilitaCampo();
	cDtinicio.habilitaCampo().datepicker('enable');
	/*.datepicker({
	  showOn: "button",
	  buttonImage: "../../imagens/geral/btn_calendario.gif",
	  buttonImageOnly: true    });  */
  
	cDtafinal.habilitaCampo().datepicker('enable');
	cCddopcao.val('E');
	cCddopcao.focus();	
	removeOpacidade('divTela');
	
}

function layoutTabela(){
		var divRegistro = $('#divTarifaPendente > div.divRegistros');
		var tabela      = $('table', divRegistro );

		divRegistro.css('height','150px');

		var ordemInicial = new Array();
		ordemInicial = [[0,0]];

		var arrayLargura = new Array();
		arrayLargura[0] = '100px';
		arrayLargura[1] = '20px';
		arrayLargura[2] = '55px';
		arrayLargura[3] = '130px';
		arrayLargura[4] = '60px';
		arrayLargura[5] = '150px';
		arrayLargura[6] = '40px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'left';
		arrayAlinha[3] = 'left';
		arrayAlinha[4] = 'left';
		arrayAlinha[5] = 'left';
		arrayAlinha[6] = 'right';		

		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		glbTabRowid = '';
		
		// seleciona o registro que é clicado
		//$('table > tbody > tr', divRegistro).click( function() {
		//	glbTabRowid = $(this).find('#rowid > span').text() ;
		//	alert(glbTabRowid);
		//});
		
		//$('table > tbody > tr:eq(0)', divRegistro).click();
		
		return false;		
}

function formataCabecalho() {

	// Cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);	

	rCddopcao.addClass('rotulo').css({'width':'100px'});
	
	cCddopcao			= $('#cddopcao','#'+frmCab);
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	
	cCddopcao.addClass('campo').css({'width':'533px'});

	layoutPadrao();

	return false;
}


function formatafrmDebtar() {

	// Cabecalho
	rInpessoa			= $('label[for="inpessoa"]','#'+frmDebtar);
	
	rCddgrupo			= $('label[for="cddgrupo"]','#'+frmDebtar);
	rCdsubgru			= $('label[for="cdsubgru"]','#'+frmDebtar);
	
	rCdhistor			= $('label[for="cdhistor"]','#'+frmDebtar);
	rCdhisest			= $('label[for="cdhisest"]','#'+frmDebtar);
	rCdmotest			= $('label[for="cdmotest"]','#'+frmDebtar);	
	rCdcooper			= $('label[for="cdcopaux"]','#'+frmDebtar);
	rCdagenci			= $('label[for="cdagenci"]','#'+frmDebtar);
	rNrdconta			= $('label[for="nrdconta"]','#'+frmDebtar);
	rDtinicio			= $('label[for="dtinicio"]','#'+frmDebtar); 
	rDtafinal			= $('label[for="dtafinal"]','#'+frmDebtar);	
	
	rInpessoa.addClass('rotulo').css({'width':'100px'});
	rCddgrupo.addClass('rotulo').css({'width':'100px'});
	rCdsubgru.addClass('rotulo').css({'width':'100px'});
	rCdhistor.addClass('rotulo').css({'width':'100px'});
	rCdhisest.addClass('rotulo').css({'width':'100px'});
	rCdmotest.addClass('rotulo').css({'width':'100px'});	
	rCdcooper.addClass('rotulo').css({'width':'100px'});
	rCdagenci.addClass('rotulo').css({'width':'100px'});
	rNrdconta.addClass('rotulo').css({'width':'100px'});
	rDtinicio.addClass('rotulo').css({'width':'100px'});
	rDtafinal.addClass('rotulo').css({'width':'100px'});
	
	cInpessoa			= $('#inpessoa','#'+frmDebtar); 
	cCddgrupo			= $('#cddgrupo','#'+frmDebtar); 
	cDsdgrupo			= $('#dsdgrupo','#'+frmDebtar); 
	cCdsubgru			= $('#cdsubgru','#'+frmDebtar); 
	cDssubgru			= $('#dssubgru','#'+frmDebtar); 
	cCdhistor			= $('#cdhistor','#'+frmDebtar);
	cDshistor			= $('#dshistor','#'+frmDebtar);
	cCdhisest			= $('#cdhisest','#'+frmDebtar);
	cDshisest			= $('#dshisest','#'+frmDebtar);
	cCdmotest			= $('#cdmotest','#'+frmDebtar);
	cDsmotest			= $('#dsmotest','#'+frmDebtar);
	cCdcooper			= $('#cdcopaux','#'+frmDebtar);
	cNmrescop			= $('#nmrescop','#'+frmDebtar);
	cCdagenci			= $('#cdagenci','#'+frmDebtar);
	cNmresage			= $('#nmresage','#'+frmDebtar);
	cNrdconta			= $('#nrdconta','#'+frmDebtar); 
	cDtinicio			= $('#dtinicio','#'+frmDebtar);
	cDtafinal			= $('#dtafinal','#'+frmDebtar); 
	cNmprimtl			= $('#nmprimtl','#'+frmDebtar);
	cGlbcoope			= $('#glbcoope','#frmCab');
	
	cInpessoa.addClass('campo').css({'width':'553px'});
	cCdhistor.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	cCddgrupo.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	cDsdgrupo.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cCdsubgru.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	cDssubgru.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cDshistor.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cCdhisest.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	cDshisest.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cCdmotest.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	cDsmotest.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cCdcooper.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','10').setMask('INTEGER','zzzzzzzzzz','','');
	cNmrescop.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cCdagenci.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	cNmresage.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cNrdconta.addClass('conta pesquisa campo').css({'width':'80px'});
	cNmprimtl.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cDtinicio.addClass('data campo').css({'width':'80px'});
	cDtafinal.addClass('data campo').css({'width':'80px'});
	
	layoutPadrao();

	return false;
}

// Controle
function buscaAssociado() {

	hideMsgAguardo();

	var nrdconta = normalizaNumero( cNrdconta.val() );
	var cdcooper = normalizaNumero( cCdcooper.val() );
	var cdagenci = normalizaNumero( cCdagenci.val() );
	
	var mensagem = 'Aguarde, buscando associado ...';
	showMsgAguardo( mensagem );	
	
	//Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		url		: UrlSite + 'telas/debtar/busca_associado.php', 
		data    : 
				{ 
					nrdconta	: nrdconta,
					cdcooper	: cdcooper,
					cdagenci	: cdagenci,
					redirect	: 'script_ajax' 
				}, 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
				},
				success: function(response) {
					try {
						hideMsgAguardo();
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
					}
				}						
	});			

}

function controlaPesquisas(valor) {
	
	switch( valor )
	{
		case 1:
			controlaPesquisaHistorico()	
			break;
		case 2:
			controlaPesquisaHistoricoEstorno()
			break;
		case 3:
		  controlaPesquisaMotivos();
		  break;		
		case 4:
			controlaPesquisaCoop();
			break;
		case 5:
			controlaPesquisaPac();
			break;
		case 6:
			// Se esta desabilitado o campo 
			if ($("#nrdconta","#frmDebtar").prop("disabled") == true)  {
				return;
			}	
			mostraPesquisaAssociado('nrdconta', frmCab );
			break;
		case 7:
			controlaPesquisaGrupo();
			break; //grupo
		case 8:
			controlaPesquisaSubGrupo();
			break; //subgrupo
	}
}

// Formata
function controlaNavegacao() {

	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			liberaCampos();
			return false;
		}
	});	

	//tiago tratar os campos  cddgrupo e cdsubgru
	cCddgrupo.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCddgrupo.val() == '') {
				cCdsubgru.focus();
				return false;
			} else {
				buscaGrupo();
			}
		}
	});	

	cCdsubgru.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCdsubgru.val() == '') {
				if($('#divEstorno').is(":visible")){
					cCdhisest.focus();
				}else{
					cCdhistor.focus();
				}	
				return false;
			} else {
				buscaSubGrupo();
			}
		}
	});	
	
	cCdhistor.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCdhistor.val() == '') {
				if ( cGlbcoope.val() == 3 ) {
					cCdcooper.focus();
					return false;
				} else {
					cCdagenci.focus();
					return false;
				}
			} else {			    
				buscaHistorico();
			}
		}
	});	
	
	cCdhisest.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCdhisest.val() == '') {
				cCdmotest.focus();
				return false;
			} else {			    
				buscaHistoricoEstorno();
			}
		}
	});	
	
	cCdmotest.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCdmotest.val() == '') {
				if ( cGlbcoope.val() == 3 ) {
					cCdcooper.focus();
				} else {
					cCdagenci.focus();
				}
			} else {
				buscaDadosMotivo();
			}
			return false;
		}
	});
	
	cCdcooper.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCdcooper.val() == '') {
				$('#nmrescop','#frmDebtar').val('');
				cInpessoa.focus();
				return false;
			} else {
				buscaCooperativa();
			}
		}
		
	});
	
	cCdagenci.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCdagenci.val() == '') {
				cInpessoa.focus();
				return false;
			} else {
				buscaDadosAgencia();
			}
		}
	});
	
	cInpessoa.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cNrdconta.focus();
			return false;
		}
	});
	
	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cNrdconta.val() == '') {
				cDtinicio.focus();
			} else {
				buscaAssociado();
				return false;
			}
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});
	
	cDtinicio.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cDtafinal.focus();
			return false;
		}
	});
	
	cDtafinal.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnContinuar();
			return false;
		}
	});

	
	return false;	
	
}

function controlaLayout() {
}

// Botoes
function btnVoltar() {
	estadoInicial();	
	return false;
}

function btnContinuar() {

	//Remove a classe de Erro do form
	$('input,select', '#frmDebtar').removeClass('campoErro');

	var dtinicio = cDtinicio.val();
	var dtafinal = cDtafinal.val();
	
	if ( glbCdcooper == '3'){
		if ( $('#nrdconta','#'+frmDebtar).val() == '' && $('#cdhistor','#'+frmDebtar).val() == ''){
			hideMsgAguardo();
			showError("error","Historico ou Conta deve ser informado.","Alerta - Aimaro","focaCampoErro(\'cdhistor\', \'frmDebtar\');",false);
			return false;			
		}
	} else{
		if ( $('#nrdconta','#'+frmDebtar).val() == '' ){
			hideMsgAguardo();
			showError("error","Numero da conta deve ser informado.","Alerta - Aimaro","focaCampoErro(\'nrdconta\', \'frmDebtar\');",false);
			return false;					
		}
	} 
	

	if ( dtinicio == '' ){
		hideMsgAguardo();
		showError("error","Periodo Inicial deve ser informado.","Alerta - Aimaro","focaCampoErro(\'dtinicio\', \'frmDebtar\');",false);
		return false;
	
	}
	
	if ( dtafinal == '' ){
		hideMsgAguardo();
		showError("error","Periodo Final deve ser informado.","Alerta - Aimaro","focaCampoErro(\'dtafinal\', \'frmDebtar\');",false);
		return false;	
	}
	
	if(dates.compare(getDateUS(dtinicio),getDateUS(glbDtmvtolt)) > 0){
		hideMsgAguardo();
		showError("error","Periodo inicial nao deve ser maior que a data atual.","Alerta - Aimaro","focaCampoErro(\'dtinicio\', \'frmDebtar\');",false);
		return false;
	}
	
	if(dates.compare(getDateUS(dtafinal),getDateUS(glbDtmvtolt)) > 0){
		hideMsgAguardo();
		showError("error","Periodo Final nao deve ser maior que a data atual.","Alerta - Aimaro","focaCampoErro(\'dtafinal\', \'frmDebtar\');",false);
		return false;
	}	
		
	var aux_inicio = parseInt(dtinicio.split("/")[2].toString() + dtinicio.split("/")[1].toString() + dtinicio.split("/")[0].toString()); 
	var aux_final  = parseInt(dtafinal.split("/")[2].toString() + dtafinal.split("/")[1].toString() + dtafinal.split("/")[0].toString()); 
	
	if ( aux_inicio > aux_final ) {
		hideMsgAguardo();
		showError("error","Periodo Inicial deve ser menor que Periodo Final.","Alerta - Aimaro","focaCampoErro(\'dtinicio\', \'frmDebtar\');",false);
		return false;
	}

	buscaTarifaPendenteGrid();

}

function carregaTarifas(){

   return false;
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	
	if (botao != '') {
	
		if(botao == 'Carregar'){
			$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >' + botao + '</a>');
		}
		
		if(botao == 'Debitar'){
			cCdcooper.desabilitaCampo();
			cInpessoa.desabilitaCampo();
			cCddopcao.desabilitaCampo();
			cCdagenci.desabilitaCampo();
			cNrdconta.desabilitaCampo();
			cCdhistor.desabilitaCampo();
			cCdhisest.desabilitaCampo();
			cCddgrupo.desabilitaCampo();
			cCdsubgru.desabilitaCampo();
			cDtinicio.desabilitaCampo().datepicker("disable");
			cDtafinal.desabilitaCampo().datepicker("disable");
			
			
			$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="efetivaDebitos(); return false;" >' + botao + '</a>');
		}
		
	}

	
	return false;
}

function botaoPDF(nmarqpdf){

	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btLog" onclick="Gera_Impressao(' + "'" + nmarqpdf + "'" + ');" >Log</a>');
	
	return false;
}

function buscaHistorico(){

	showMsgAguardo("Aguarde, consultando Historico...");

	var cddopcao = $('#cddopcao','#frmCab').val();
	var cdhistor = $('#cdhistor','#frmDebtar').val();
	cdhistor = normalizaNumero(cdhistor);		
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/debtar/busca_historico.php", 
		data: {
			cdhistor: cdhistor,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {				
				hideMsgAguardo();					
				eval(response);				
				buscaSubgrupoHistorico();
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
	
}

function buscaSubgrupoHistorico(){

	showMsgAguardo("Aguarde, consultando Historico...");

	var cddopcao = $('#cddopcao','#frmCab').val();
	var cdhistor = $('#cdhistor','#frmDebtar').val();
	cdhistor = normalizaNumero(cdhistor);	
	var cdhisest = $('#cdhisest','#frmDebtar').val();
	cdhisest = normalizaNumero(cdhisest);	
	var cdhistmp = 0;
	var flgestor = 0;
	
	if(   ($('#cdhistor','#frmDebtar').hasClass('campoTelaSemBorda') && (cdhistor > 0)) || 
	      ($('#cdhisest','#frmDebtar').hasClass('campoTelaSemBorda') && (cdhisest > 0)) ){
				
		if(cdhistor > 0){
			cdhistmp = cdhistor;			
			flgestor = 0;
		}else{
			cdhistmp = cdhisest;
			flgestor = 1;				
		}
	
		// Executa script através de ajax
		$.ajax({		
			type: "POST",
			url: UrlSite + "telas/debtar/busca_subgrupo_historico.php", 
			data: {
				cdhistor: cdhistmp,
				flgestor: flgestor,
				redirect: "script_ajax"
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function(response) {
				try {			
					hideMsgAguardo();
					eval(response);
					
					if( ! $('#cdsubgru','#frmDebtar').hasClass('campoTelaSemBorda') ){
						buscaSubGrupo();
					}	
				} catch(error) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}				
			}				
		});		
		
		

	}else{
		hideMsgAguardo();
	}
}

function buscaGrupo(){

	showMsgAguardo("Aguarde, consultando Grupo...");

	var cddgrupo = $('#cddgrupo','#frmDebtar').val();
	cddgrupo = normalizaNumero(cddgrupo);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/debtar/busca_grupo.php", 
		data: {
			cddgrupo: cddgrupo,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();	
				eval(response);
				
				if( $("#divEstorno").is(":visible") ){
				
					if( $('#cdhisest','#frmDebtar').hasClass('campoTelaSemBorda') ){
						$('#cdmotest','#frmDebtar').focus();												
					}else{
						if( $('#cdsubgru','#frmDebtar').hasClass('campoTelaSemBorda') ){
							$('#cdhisest','#frmDebtar').focus();
						}					
					}
					
				}else{
					if( $('#cdhistor','#frmDebtar').hasClass('campoTelaSemBorda') ){ 
						$('#cdcopaux','#frmDebtar').focus();
					}else{
						if( $('#cdsubgru','#frmDebtar').hasClass('campoTelaSemBorda') ){ 
							$('#cdhistor','#frmDebtar').focus();
						}	
					}	
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
	
}

function buscaSubGrupo(){

	showMsgAguardo("Aguarde, consultando SubGrupo...");

	var cdsubgru = $('#cdsubgru','#frmDebtar').val();
	cdsubgru = normalizaNumero(cdsubgru);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/debtar/busca_subgrupo.php", 
		data: {
			cdsubgru: cdsubgru,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();	
				eval(response);				
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});		
	
}

function buscaHistoricoEstorno(){

	var cddopcao = $('#cddopcao','#frmCab').val();
	
	showMsgAguardo("Aguarde, consultando Historico...");

	var cdhisest = $('#cdhisest','#frmDebtar').val();
	cdhisest = normalizaNumero(cdhisest);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/debtar/busca_historico_estorno.php", 
		data: {
			cdhisest: cdhisest,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
				buscaSubgrupoHistorico();				
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
	
}

function controlaPesquisaHistoricoEstorno() {

	// Se esta desabilitado o campo 
	if ($("#cdhisest","#frmDebtar").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhisest, titulo_coluna, cdgrupos, dshisest;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDebtar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdhisest = $('#cdhisest','#'+nomeFormulario).val();	
	cdhisest = normalizaNumero(cdhisest);		
	dshisest = ' ';
	
	titulo_coluna = "Historicos";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-historicos-estorno-tarifa';
	titulo      = 'Historicos';
	qtReg		= '10';
	filtros 	= 'Codigo;cdhisest;130px;S;' + cdhisest + ';S|Descricao;dshisest;100px;S;' + dshisest + ';S';
	colunas 	= 'Codigo;cdhistor;20%;right|' + titulo_coluna + ';dshistor;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdhisest\',\'#frmDetalhaTarifa\').val()');
	
	return false;
}

function controlaPesquisaHistorico() {

	// Se esta desabilitado o campo 
	if ($("#cdhistor","#frmDebtar").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhistor, titulo_coluna, cdgrupos, dshistor;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDebtar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdhistor = $('#cdhistor','#'+nomeFormulario).val();
	cdhistor = cdhistor;	
	dshistor = '';
	
	titulo_coluna = "Historicos";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-historicos-tarifa';
	titulo      = 'Historicos';
	qtReg		= '10';
	filtros 	= 'Codigo;cdhistor;130px;S;' + cdhistor + ';S|Descricao;dshistor;330px;S;' + dshistor + ';S';
	colunas 	= 'Codigo;cdhistor;20%;right|' + titulo_coluna + ';dshistor;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdhistor\',\'#frmDetalhaTarifa\').val()');
	
	return false;
}

//tiago pesquisa grupo
function controlaPesquisaGrupo() {

	// Se esta desabilitado o campo 
	if ($("#cddgrupo","#frmDebtar").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cddgrupo, titulo_coluna, cdgrupos, dsdgrupo;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDebtar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cddgrupo = $('#cddgrupo','#'+nomeFormulario).val();
	cddgrupo = cddgrupo;	
	dsdgrupo = '';
	
	titulo_coluna = "Grupos";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-grupos';
	titulo      = 'Grupos';
	qtReg		= '10';
	filtros 	= 'Codigo;cddgrupo;130px;S;' + cddgrupo + ';S|Descricao;dsdgrupo;330px;S;' + dsdgrupo + ';S';
	colunas 	= 'Codigo;cddgrupo;20%;right|' + titulo_coluna + ';dsdgrupo;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cddgrupo\',\'#frmDetalhaTarifa\').val()');
	
	return false;
}

//tiago pesquisa subgrupo
function controlaPesquisaSubGrupo() {

	// Se esta desabilitado o campo 
	if ($("#cdsubgru","#frmDebtar").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdsubgru, titulo_coluna, cdgrupos, dssubgru;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDebtar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdsubgru = $('#cdsubgru','#'+nomeFormulario).val();
	cdsubgru = cdsubgru;	
	dssubgru = '';
	
	titulo_coluna = "SubGrupos";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-subgrupos';
	titulo      = 'SubGrupos';
	qtReg		= '10';
	filtros 	= 'Codigo;cdsubgru;130px;S;' + cdsubgru + ';S|Descricao;dssubgru;330px;S;' + dssubgru + ';S';
	colunas 	= 'Codigo;cdsubgru;20%;right|' + titulo_coluna + ';dssubgru;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdsubgru\',\'#frmDetalhaTarifa\').val()');
	
	return false;
}

function liberaCampos() {

	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; } ;	
	
	

	$('#cddopcao','#'+frmCab).desabilitaCampo();
	$('#frmDebtar').css({'display':'block'});
	$('#divBotoes').css({'display':'block'});
	formatafrmDebtar();
	
	$('#divEstorno').css({'display':'none'});
	$('#divHistorico').css({'display':'block'});
	
	//cCdhistor.focus();
	cCddgrupo.focus();
	
	$('input, select', '#'+frmDebtar).limpaFormulario().removeClass('campoErro');	
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	$('#cddopcao1','#frmDebtar').val(cddopcao);
	
	var dtafinal = $('#glbdtmvt','#frmCab').val();
	var dtinicio = "01/" + dtafinal.split("/")[1].toString() + "/" + dtafinal.split("/")[2].toString()
	
	$('#dtinicio','#frmDebtar').val(dtinicio);
	$('#dtafinal','#frmDebtar').val(dtafinal);
	
	if ( $('#glbcoope','#frmCab').val() == 3 ) {
		$('#cdagenci','#frmDebtar').desabilitaCampo();
		$('#nrdconta','#frmDebtar').desabilitaCampo();
	}else{	
		bloqueiaCampos(glbCdcooper);
	}	
	
	return false;

}


function buscaDadosMotivo() {

	showMsgAguardo("Aguarde, consultando Motivos...");

	var cdmotest = $('#cdmotest','#frmDebtar').val();
		cdmotest = normalizaNumero(cdmotest);
		
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/debtar/busca_motivo.php", 
		data: {
			cdmotest: cdmotest,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	

}

function buscaDadosAgencia() {

	showMsgAguardo("Aguarde, consultando Pa...");

	var cdagenci = $('#cdagenci','#frmDebtar').val();
		cdagenci = normalizaNumero(cdagenci);
		
	var cdcooper = $('#cdcopaux','#frmDebtar').val();
		cdcooper = normalizaNumero(cdcooper);
		
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/debtar/busca_agencia.php", 
		data: {
			cdagenci: cdagenci,
			cdcooper: cdcooper,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	

}


// imprimir
function Gera_Impressao(nmarqpdf) {	

	//showMsgAguardo("Aguarde, gerando relatorio...");

	var cddopcao = $('#cddopcao1','#frmDebtar').val(); 
	var cdhistor = $('#cdhistor','#frmDebtar').val();	
	var cddgrupo = $('#cddgrupo','#frmDebtar').val();
	var cdsubgru = $('#cdsubgru','#frmDebtar').val();	
	var cdhisest = $('#cdhisest','#frmDebtar').val();
	var cdmotest = $('#cdmotest','#frmDebtar').val();
	var cdcooper = $('#cdcopaux','#frmDebtar').val();
	var cdagenci = $('#cdagenci','#frmDebtar').val();
	var inpessoa = $('#inpessoa','#frmDebtar').val();
	var nrdconta = $('#nrdconta','#frmDebtar').val();
	var dtinicio = $('#dtinicio','#frmDebtar').val();
	var dtafinal = $('#dtafinal','#frmDebtar').val();

	cdhistor = normalizaNumero(cdhistor);
	cddgrupo = normalizaNumero(cddgrupo);
	cdsubgru = normalizaNumero(cdsubgru);
	cdhisest = normalizaNumero(cdhisest);
	cdmotest = normalizaNumero(cdmotest);
	cdcooper = normalizaNumero(cdcooper);
	cdagenci = normalizaNumero(cdagenci);
	inpessoa = normalizaNumero(inpessoa);
	nrdconta = normalizaNumero(nrdconta);
	
	$('#cdhistor1','#frmDebtar').val(cdhistor);
	$('#cdhisest1','#frmDebtar').val(cdhisest);	
	$('#cddgrupo1','#frmDebtar').val(cddgrupo);
	$('#cdsubgru1','#frmDebtar').val(cdsubgru);	
	$('#cdmotest1','#frmDebtar').val(cdmotest);
	$('#cdcooper1','#frmDebtar').val(cdcooper);
	$('#cdagenci1','#frmDebtar').val(cdagenci);
	$('#inpessoa1','#frmDebtar').val(inpessoa);
	$('#nrdconta1','#frmDebtar').val(nrdconta);	
	$('#nmarqpdf1','#frmDebtar').val(nmarqpdf);	
	
	
	//var action = UrlSite + 'telas/debtar/manter_rotina.php';
	var action = UrlSite + 'telas/debtar/manter_rotina.php';
	
	$('#sidlogin','#frmDebtar').remove();
	
	$('#frmDebtar').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');

	carregaImpressaoAyllos("frmDebtar",action,"estadoInicial();");
	
	return false;
		
}


function controlaPesquisaMotivos() {

	// Se esta desabilitado o campo 
	if ($("#cdmotest","#frmDebtar").prop("disabled") == true)  {
		return;
	}
	
 	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdmotest, titulo_coluna, cdmotests, dsmotest, tpaplica;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDebtar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdmotest = $('#cdmotest','#'+nomeFormulario).val();
	cdmotests = cdmotest;	
	dsmotest = ' ';
	tpaplica = 1;
	
	titulo_coluna = "Descricao";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-met';
	titulo      = 'Motivos de Estorno Baixa de Tarifas';
	qtReg		= '10';
	filtros 	= 'Codigo;cdmotest;130px;S;' + cdmotest + ';S|Descricao;dsmotest;100px;S;' + dsmotest + ';N|Aplicacao;tpaplica;100px;N;' + tpaplica + ';N';
	colunas 	= 'Codigo;cdmotest;20%;right|' + titulo_coluna + ';dsmotest;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdmotest\',\'#frmCab\').val()');
	
	return false; 
}


function controlaPesquisaPac() {

	// Se esta desabilitado o campo 
	if ($("#cdagenci","#frmDebtar").prop("disabled") == true)  {
		return;
	}
	
 	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcooper, nmrescop, cdagenci, titulo_coluna, cdagencis, nmresage;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDebtar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdagenci = $('#cdagenci','#'+nomeFormulario).val();
	
	var cdcooper = $('#cdcopaux','#frmDebtar').val();
	
	if ( cdcooper == '' ) {
		var cdcooper = $('#glbcoope','#frmCab').val();	
	}
	
	cdagencis = cdagenci;	
	nmresage = ' ';
	nmrescop = ' ';
	
	titulo_coluna = "Descricao";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-pacs';
	titulo      = 'Agência PA';
	qtReg		= '20';
	
	if ( $('#glbcoope','#frmCab').val() == 3 ) {
		filtros 	= 'Coop;cdcooper;30px;S;' + cdcooper + ';S|Nome Coop;nmrescop;30px;N;' + nmrescop + ';N|Cód. PA;cdagenci;30px;S;' + cdagenci + ';S|Agência PA;nmresage;200px;S;' + nmresage + ';N';
		colunas 	= 'Cód. Coop;cdcooper;20%;right|Cooperativa;nmrescop;27%;right|Cód. PA;cdagenci;15%;right|' + titulo_coluna + ';nmresage;50%;left';
	} else {
		filtros 	= 'Cód. PA;cdagenci;30px;S;' + cdagenci + ';S|Agência PA;nmresage;200px;S;' + nmresage + ';N';
		colunas 	= 'Codigo;cdagenci;20%;right|' + titulo_coluna + ';nmresage;50%;left';
	}
	
	
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdagenci\',\'#frmDebtar\').val()');
	
	return false; 
}

function controlaPesquisaCoop(){

	// Se esta desabilitado o campo 
	if ($("#cdcopaux","#frmDebtar").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcooper, titulo_coluna, cdcoopers, cdcopaux, nmrescop;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDebtar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdcopaux = $('#cdcopaux','#'+nomeFormulario).val();
	cdcoopers = cdcopaux;	
	nmrescop = '';
	
	var cdcopaux = '' ;	
	
	titulo_coluna = "Cooperativas";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-cooperativas';
	titulo      = 'Cooperativas';
	qtReg		= '10';
	filtros 	= 'Codigo;cdcopaux;130px;S;' + cdcopaux + ';S|Descricao;nmrescop;200px;S;' + nmrescop + ';S';
	colunas 	= 'Codigo;cdcooper;20%;right|' + titulo_coluna + ';nmrescop;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdcopaux\',\'#frmDebtar\').val()');
	
	return false;
}


function buscaCooperativa(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando cooperativa...");

	var cdcooper = $('#cdcopaux','#frmDebtar').val();
	cdcooper = normalizaNumero(cdcooper);

	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/debtar/busca_dados_cooperativa.php", 
		data: {
			cdcooper: cdcooper,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
	
	return false;

}

function buscaTarifaPendenteGrid(){

	showMsgAguardo("Aguarde, consultando tarifas pendentes...");

	var cdcooper = $('#cdcopaux','#frmDebtar').val();
	cdcooper = normalizaNumero(cdcooper);	
	var cdagenci = $('#cdagenci','#frmDebtar').val();
	cdagenci = normalizaNumero(cdagenci);	
	var inpessoa = $('#inpessoa','#frmDebtar').val();
	inpessoa = normalizaNumero(inpessoa);	
	var nrdconta = $('#nrdconta','#frmDebtar').val();
	nrdconta = normalizaNumero(nrdconta);	
	var cdhistor = $('#cdhistor','#frmDebtar').val();
	cdhistor = normalizaNumero(cdhistor);		
	var cddgrupo = $('#cddgrupo','#frmDebtar').val();
	cddgrupo = normalizaNumero(cddgrupo);	
	var cdsubrgu = $('#cdsubgru','#frmDebtar').val();
	cdsubrgu = normalizaNumero(cdsubrgu);		
	var dtinicio = $('#dtinicio','#frmDebtar').val();
	var dtafinal = $('#dtafinal','#frmDebtar').val();
	var aux_inicio = dtinicio.split("/")[1].toString() + '/' + dtinicio.split("/")[0].toString() + '/' + dtinicio.split("/")[2].toString(); 
	var aux_final  = dtafinal.split("/")[1].toString() + '/' + dtafinal.split("/")[0].toString() + '/' + dtafinal.split("/")[2].toString(); 
	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/debtar/carrega_grid.php", 
		data: {
		    cdcooper: cdcooper,
			cdagenci: cdagenci,
			inpessoa: inpessoa,
			nrdconta: nrdconta,
			cdhistor: cdhistor,
			cddgrupo: cddgrupo,
			cdsubrgu: cdsubrgu,			
			dtinicio: dtinicio,
			dtafinal: dtafinal,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();	
				$("#divTarifaPendente").html('');
				eval(response);				
				layoutTabela();								
				glbTabRowid = '';
				var divRegistro = $('#divTarifaPendente > div.divRegistros');
				$('table > tbody > tr', divRegistro).each(function() {
					if(trim($(this).find('#rowid > span').text()) != ''){
					  glbTabRowid = glbTabRowid + $(this).find('#rowid > span').text() + ';';
					}
		        });				

				glbTabRowid = glbTabRowid.substr(0,glbTabRowid.lastIndexOf(";"));

			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});		
}

function efetivaDebitos(){

	showMsgAguardo("Aguarde, efetivando debitos das tarifas pendentes...");

	var cdcooper = $('#cdcooper','#frmDebtar').val();
	cdcooper = normalizaNumero(cdcooper);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/debtar/efetiva_debitos.php", 
		data: {
		    cdcooper: cdcooper,
			listalat: glbTabRowid,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();	
				eval(response);				
				glbTabRowid = '';
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});		
}


function criaTabelaReg(tabela){
	$("#divTarifaPendente").html(tabela);
	return false;
}

function insereRegTabela(registro){
	$("#divTarifaPendente .divRegistros table").append(registro);
	return false;
}

function insereResumo(qtregtar, vltottar){
	$("#divTarifaPendente").append('<br/><div style="width:100%;border-top: 1px solid #777777;"></div><div style="width:100%;height:20px;display:block;"><table style="float:right;font-weight:bold;padding-bottom:10px;" cellspacing="0" cellpadding="0"><tr><td style="width:140px;">Tarifas selecionadas: </td><td>' + qtregtar + '</td><td style="width:150px;"></td><td style="width:120px;">TOTAL: </td><td>' + vltottar + '</td></tr></table></div><div style="width:100%;height:10px;border-top: 1px solid #777777;"></div>');
	return false;
}

function inicializaVar() {

	hideMsgAguardo();
	
	var mensagem = 'Aguarde, procedimentos iniciais ...';
	showMsgAguardo( mensagem );	
	
	//Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		url		: UrlSite + 'telas/debtar/inicializa_var.php', 
		data    : 
				{ 
					redirect	: 'script_ajax' 
				}, 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
				},
				success: function(response) {
					try {
						hideMsgAguardo();
						eval(response);						
					} catch(error) {
						hideMsgAguardo();
						showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
					}
				}						
	});			

}

function bloqueiaCampos(cdcooper){
	$('#cdcopaux','#'+frmDebtar).val(cdcooper);
	buscaCooperativa();    
}