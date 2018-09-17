/*!
 * FONTE        : LISEPR.js
 * CRIAÇÃO      : André Santos / SUPERO        Última alteração: 25/02/2015
 * DATA CRIAÇÃO : 19/07/2013
 * OBJETIVO     : Biblioteca de funções - Tela LISEPR
 * --------------
 * ALTERAÇÕES   : 25/02/2015 - Validação e correção da coversão realizada pela SUPERO
							  (Adriano).
 * --------------
 */

//Formulários
var frmCab   	= 'frmCab';
var tabDados	= 'tabLisepr';

// Inicio
$(document).ready(function() {
	estadoInicial();
	return false;
});

// inicio
function estadoInicial() {	
	
	$('#frmOpcoes').css('display','none');
	$('input,select').removeClass('campoErro');
		
	formataCabecalho();
	
	$('#divBotoes','#divTela').css({'display':'none'});
	$('input[type="text"],select','#frmOpcoes').limpaFormulario();

	layoutPadrao();
	$('#cddopcao','#frmCab').habilitaCampo().focus();
		
	return false;
	
}

// formata
function formataCabecalho() {

	var cTodosCabecalho = $('input[type="text"],select','#frmCab');

	var btnOK			= $('#btnOK','#frmCab');

	var rCddopcao		= $('label[for="cddopcao"]','#frmCab');	

	var cCddopcao			= $('#cddopcao','#frmCab');

	cTodosCabecalho.habilitaCampo();

	rCddopcao.css({'width':'60px'});
	cCddopcao.css({'width':'500px'});
		
	$('#divTela').css({'display':'block'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
	
	$('#frmCab').css('display','block');

	btnOK.unbind('click').bind('click', function() {

		if ( divError.css('display') == 'block' ) { return false; }		

		controlaLayout(1);
		return false;

	});
	
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
	
		//Enter ou tab
		if ( e.keyCode == 13 || e.keyCode == 9 ) {	
			
			controlaLayout(1);						
			return false;
		}	
	});

	highlightObjFocus( $('#frmCab') );	
	highlightObjFocus( $('#frmOpcoes') );	
	highlightObjFocus( $('#divBotoes') );
		
	layoutPadrao();
	
	cCddopcao.focus();
		
	return false;	
	
}

function formataOpcoes() {

	// Labels
	var rCdagenci			= $('label[for="cdagenci"]','#frmOpcoes');
    var rCdlcremp			= $('label[for="cdlcremp"]','#frmOpcoes');
    var rCddotipo			= $('label[for="cddotipo"]','#frmOpcoes');
	var rDtinicio			= $('label[for="dtinicio"]','#frmOpcoes');
    var rDttermin			= $('label[for="dttermin"]','#frmOpcoes');
    var rTipsaida			= $('label[for="tipsaida"]','#frmOpcoes');

    // Campos
	var cCdagenci			= $('#cdagenci','#frmOpcoes');
    var cCdlcremp			= $('#cdlcremp','#frmOpcoes');
    var cCddotipo			= $('#cddotipo','#frmOpcoes');
    var cDtinicio			= $('#dtinicio','#frmOpcoes');
    var cDttermin			= $('#dttermin','#frmOpcoes');
    var cTipsaida			= $('#tipsaida','#frmOpcoes');
	var cTodosOpcoes		= $('input[type="text"],select','#frmOpcoes');
	
	//Rótulos
	rCdagenci.addClass('rotulo-linha').css({'width':'105px'});
    rCdlcremp.addClass('rotulo-linha').css({'width':'110px'});
    rCddotipo.addClass('rotulo-linha').css({'width':'33px'});
	rDtinicio.addClass('rotulo-linha').css({'width':'105px'});
    rDttermin.addClass('rotulo-linha').css({'width':'10px'});
    rTipsaida.addClass('rotulo-linha').css({'width':'84px'});

    // Campos
	cCdagenci.css({'width':'50px'});
    cCdagenci.addClass('inteiro').css({'width':'50px'}).attr('maxlength','4');
	cCdlcremp.css({'width':'150px'});
    cCdlcremp.addClass('inteiro').css({'width':'50px'}).attr('maxlength','4');
    cCddotipo.css({'width':'100px'});
    cDtinicio.addClass('rotulo-linha').css({'width':'85px'});
    cDtinicio.addClass('data').css({'width':'85px'});
	cDttermin.addClass('rotulo-linha').css({'width':'85px'});
    cDttermin.addClass('data').css({'width':'85px'});
    cTipsaida.css({'width':'100px'});

	cTodosOpcoes.habilitaCampo();
	
	if($('#cddopcao','#frmCab').val() == "T"){
		cTipsaida.desabilitaCampo();
	}
	
	cCdagenci.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13  || e.keyCode == 9 || e.keyCode == 18) {
								
			var bo, procedure, titulo, qtReg, filtrosPesq, colunas; 	
			
			bo			= 'b1wgen0059.p';
			procedure	= 'busca_pac';
			titulo      = 'Agência PA';
			qtReg		= '20';					
			filtrosPesq	= 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
			colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
			
			$(this).removeClass('campoErro');
			buscaDescricao(bo,procedure,titulo,'cdagenci','nmresage',$('#cdagenci','#frmOpcoes').val(),'dsagepac','cdagenci','frmOpcoes');
					
			cCdlcremp.focus();	
						
			return false;
							
		}
				
	});	
	
	cCdlcremp.unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13  || e.keyCode == 9 || e.keyCode == 18) {
		
			$(this).removeClass('campoErro');
		    cCddotipo.focus();
            return false;
		}
		
	});

    cCddotipo.unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13  || e.keyCode == 9 || e.keyCode == 18) {
			$(this).removeClass('campoErro');
            cDtinicio.focus();
            return false;
		}
		
	});

    cDtinicio.unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13  || e.keyCode == 9 || e.keyCode == 18) {
			$(this).removeClass('campoErro');
            cDttermin.focus();
            return false;
		}
		
	});
	
	cDtinicio.unbind('blur').bind('blur', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }		
			
		$(this).removeClass('campoErro');
		
		var dtHoje  = new Date();
		dtIniPer 	=  dataString("01/" + (dtHoje.getMonth() + 1)  + "/" + dtHoje.getFullYear());
		
		if($(this).val() == ''){
			$(this).val(dtIniPer);
		}
				
	});	

    cDttermin.unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13  || e.keyCode == 9 || e.keyCode == 18) {
			$(this).removeClass('campoErro');
			
			if ( $('#cddopcao','#frmCab').val() == "T" ){
				$('#btSalvar','#divBotoes').click();
			}else{
				cTipsaida.focus();
			}
			
            return false;
		}
		
	});	
	
	cDttermin.unbind('blur').bind('blur', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }		
			
		$(this).removeClass('campoErro');
		
		var dtHoje  = new Date();
		dtFimPer 	=  dataString(buscaUltimoDia(dtHoje.getMonth()) + "/" + (dtHoje.getMonth() + 1) + "/" + dtHoje.getFullYear());

		if($(this).val() == ''){
			$(this).val(dtFimPer);
		}
				
	});	
	
	cTipsaida.unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13  || e.keyCode == 9 || e.keyCode == 18) {
		
			$(this).removeClass('campoErro');
			$('#btSalvar','#divBotoes').click();		
			
            return false;
		}
		
	});

	$('#frmOpcoes').css('display','block');
	
	cCdagenci.focus();
		
	layoutPadrao();
	return false;
	
}

function controlaLayout(tipo){

	if (tipo == 1){
	
		trocaBotao(true,$('#cddopcao','#frmCab').val());
		formataOpcoes();
		$('#divBotoes').css('display','block');
		$('#btSalvar','#divBotoes').css('display','inline');		

		$('#cddopcao','#frmCab').desabilitaCampo();
			
	}else{
		
		formataOpcoes();		
		
		$('input[type="text"],select','#frmOpcoes').limpaFormulario();
		$('#divResultado').html('').css('display','none');
		$('#btSalvar','#divBotoes').css('display','inline');
		
		$('#btVoltar','#divBotoes').unbind('click').bind('click', function(){
			btnVoltar(1);
			return false;
		});
		
		$('#cdagenci','#frmOpcoes').focus();
		
	}
	
	return false;
	
}

function setaDatasTela() {

    var dtHoje  = new Date();
    dtIniPer 	=  dataString("01/" + (dtHoje.getMonth() + 1)  + "/" + dtHoje.getFullYear());
    dtFimPer 	=  dataString(buscaUltimoDia(dtHoje.getMonth()) + "/" + (dtHoje.getMonth() + 1) + "/" + dtHoje.getFullYear());

	if($('#dtinicio','#frmOpcoes').val() == ''){
		$('#dtinicio','#frmOpcoes').val(dtIniPer);
	}
	
	if($('#dttermin','#frmOpcoes').val() == ''){
		$('#dttermin','#frmOpcoes').val(dtFimPer);
	}
	
	return false;
}

// Controle de Botoes
function trocaBotao(tipo,cddopcao ) {

	if(tipo){
		
		$('#btVoltar','#divBotoes').unbind('click').bind('click', function(){
		
			btnVoltar(1);
			
			return false;						
			
		});
		
		$('#btSalvar','#divBotoes').unbind('click').bind('click', function(){
		
			btnContinuar(cddopcao);
			
			return false;						
			
		});
				
	}else{
		
		$('#btVoltar','#divBotoes').unbind('click').bind('click', function(){
		
			btnVoltar(2);
			
			return false;						
			
		});
			
	}
	
	return false;
}

// Botoes
function btnVoltar(tipo) {

	if(tipo == 1){
		
		estadoInicial();
		
	}else{
		
		controlaLayout(2);
		
	}
	
	return false;
	
}

function btnContinuar(cddopcao) {

    if(cddopcao == "T"){
		showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','buscaEmprestimo(1,50);','$(\'#cdagenci\',\'#frmOpcoes\').focus();','sim.gif','nao.gif');
	}else{
	
		if($('#tipsaida','#frmOpcoes').val() == 1){
			showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','buscaLocal();','','sim.gif','nao.gif');
		}else{
			showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','imprimirEmprestimos(1,50);','','sim.gif','nao.gif');
		}
	}
	
    return false;
	
}

function buscaEmprestimo( nriniseq, nrregist ) {

	$('input,select','#frmOpcoes').removeClass('campoErro');
	
    var cdagenci = $('#cdagenci','#frmOpcoes').val();
	var cddopcao = $('#cddopcao','#frmCab').val();
	var cdlcremp = $('#cdlcremp','#frmOpcoes').val();
	var dtinicio = $('#dtinicio','#frmOpcoes').val();
	var dttermin = $('#dttermin','#frmOpcoes').val();
    var cddotipo = $('#cddotipo','#frmOpcoes').val();
	var tipsaida = (cddopcao == "I" ? $('#tipsaida','#frmOpcoes').val() : 0);
	var nmarquiv = $('#nmarquiv','#frmLocal').val();
	
    showMsgAguardo("Aguarde, buscando informações...");
    
	$('input,select','#frmOpcoes').desabilitaCampo();
			
	$.ajax({
		type	: 'POST',
		url		: UrlSite + 'telas/lisepr/manter_rotina.php',
		dataType: 'html',
		data    :
				{
					cdagenci : cdagenci,
					cddopcao : cddopcao,
					cdlcremp : cdlcremp,
					cddotipo : cddotipo,
					dtinicio : dtinicio,
					dttermin : dttermin,
					nriniseq : nriniseq,
					nrregist : nrregist,
					tipsaida : tipsaida,
					nmarquiv : nmarquiv,
					redirect : 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
			hideMsgAguardo();
			try {				
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divResultado').html(response);						
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
				} else {
					try {
						eval(response);
						return false;
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
				hideMsgAguardo();
				
			} catch(error) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});
		
    return false;
	
}

function imprimirEmprestimos( nriniseq, nrregist ) {

	$('input,select','#frmOpcoes').removeClass('campoErro');
	
    var cdagenci = $('#cdagenci','#frmOpcoes').val();
	var cddopcao = $('#cddopcao','#frmCab').val();
	var cdlcremp = $('#cdlcremp','#frmOpcoes').val();
	var dtinicio = $('#dtinicio','#frmOpcoes').val();
	var dttermin = $('#dttermin','#frmOpcoes').val();
    var cddotipo = $('#cddotipo','#frmOpcoes').val();
	var tipsaida = $('#tipsaida','#frmOpcoes').val();
	var nmarquiv = $('#nmarquiv','#frmLocal').val();
	
    showMsgAguardo("Aguarde, buscando informações...");
    
	$('input,select','#frmOpcoes').desabilitaCampo();
			
	$.ajax({
		type	: 'POST',
		url		: UrlSite + 'telas/lisepr/manter_rotina.php',
		dataType: 'html',
		data    :
				{
					cdagenci : cdagenci,
					cddopcao : cddopcao,
					cdlcremp : cdlcremp,
					cddotipo : cddotipo,
					dtinicio : dtinicio,
					dttermin : dttermin,
					nriniseq : nriniseq,
					nrregist : nrregist,
					tipsaida : tipsaida,
					nmarquiv : nmarquiv,
					redirect : 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				},
		success : function(response) {
					hideMsgAguardo();				
					try {
						eval( response );												
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
					}

				}
	});
		
    return false;
	
}

function Gera_Impressao(nmarqpdf) {

	var action = UrlSite + 'telas/lisepr/imprimir_pdf.php';
	
	$('#nmarqpdf','#frmImprimir').remove();
	$('#sidlogin','#frmImprimir').remove();
	$('#frmImprimir').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');	
	$('#frmImprimir').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
			
	carregaImpressaoAyllos("frmImprimir",action,'estadoInicial()');

}

function formataTabela() {

    $('#divResultado').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#'+tabDados);
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    $('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'180px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '50px';
	arrayLargura[1] = '73px';
	arrayLargura[2] = '70px';
	arrayLargura[3] = '70px';
	arrayLargura[4] = '83px';
    arrayLargura[5] = '80px';
    arrayLargura[6] = '50px';

	var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'center';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	/********************
	 FORMATA COMPLEMENTO
	*********************/

	// complemento linha 1
	var linha1  = $('ul.complemento', '#linha1').css({'margin-left':'1px','width':'99.5%'});

        $('li:eq(0)', linha1).addClass('txtNormalBold').css({'width':'12%','text-align':'right'});
        $('li:eq(1)', linha1).addClass('txtNormal').css({'width':'59%'});

	// complemento linha 2
	var linha2  = $('ul.complemento', '#linha2').css({'clear':'both','border-top':'0','width':'99.5%'});

        $('li:eq(0)', linha2).addClass('txtNormalBold').css({'width':'12%','text-align':'right'});
        $('li:eq(1)', linha2).addClass('txtNormal').css({'width':'43%'});

        $('li:eq(2)', linha2).addClass('txtNormalBold').css({'width':'14%','text-align':'right'});
        $('li:eq(3)', linha2).addClass('txtNormal').css({'width':'10%'});
        $('#qtdregis','.complemento').html( $('#qtdregis').val() );

    // complemento linha 3
	var linha3  = $('ul.complemento', '#linha3').css({'clear':'both','border-top':'0','width':'99.5%'});

        $('li:eq(0)', linha3).addClass('txtNormalBold').css({'width':'12%','text-align':'right'});
        $('li:eq(1)', linha3).addClass('txtNormal').css({'width':'39%'});
        $('li:eq(2)', linha3).addClass('txtNormalBold').css({'width':'18%','text-align':'right'});
        $('li:eq(3)', linha3).addClass('txtNormal').css({'width':'10%'});
        $('#totvlrep','.complemento').html( $('#totvlrep').val() );

    /********************
	  EVENTO COMPLEMENTO
	*********************/

    // seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaTabela($(this));
	});

    // seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaTabela($(this));
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();	
    return false;
}

function selecionaTabela(tr) {

	$('#nmprimtl','.complemento').html( $('#nmprimtl', tr).val() );
	$('#dtmvtprp','.complemento').html( $('#dtmvtprp', tr).val() );
	$('#diaprmed','.complemento').html( $('#diaprmed', tr).val() );
	
	return false;
}

function controlaPesquisa(){

	// Se esta desabilitado o campo 
	if ($("#cdagenci","#frmOpcoes" ).prop("disabled") == true)  {
		return;
	}
	
	/* Remove foco de erro */
	$('input','#frmOpcoes').removeClass('campoErro'); 
	
	var bo, procedure, titulo, qtReg, filtrosPesq, colunas;	
	
	bo			= 'b1wgen0059.p';
	procedure	= 'busca_pac';
	titulo      = 'Agência PA';
	qtReg		= '20';					
	filtrosPesq	= 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
	colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
		
	return false;	

}

function dataString(vData) {

    var dtArray = vData.split('/');

    switch (dtArray[1]) {
    case "1":
    case "2":
    case "3":
    case "4":
    case "5":
    case "6":
    case "7":
    case "8":
    case "9":
        vMes = "0" + (dtArray[1]);
        break;
    default:
        vMes = dtArray[1];
    }

    return dtArray[0] + "/" + vMes + "/" + dtArray[2];
}

function buscaUltimoDia(vMes){

    var today = new Date();
    var lastDayOfMonth = new Date(today.getFullYear(), vMes + 1 , 0);
    var vUltimoDia = lastDayOfMonth.getDate();

    return vUltimoDia;
}


function buscaLocal() {

	hideMsgAguardo();

	showMsgAguardo('Aguarde, abrindo ...');

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/lisepr/arquivo.php',
		data: {			
			   redirect: 'script_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {

			hideMsgAguardo();
			
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divRotina').html(response);					
					exibeRotina($('#divRotina'));
					formataArquivo();
					return false;
				} catch(error) {					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}
	});
	return false;
}

function validaArquivo(){

	var nmarquiv = $('#nmarquiv','#frmLocal').val();
	
	if ( nmarquiv == '' ){
		showError('error','Arquivo n&atilde;o informado.','Alerta - Ayllos','bloqueiaFundo($(\'#divRotina\'));$(\'#nmarquiv\',\'#frmLocal\').focus();'); return false;
	}

	buscaEmprestimo(1,50);
			
	return false;

}

function formataArquivo(){

	var cNmarquiv = $('#nmarquiv','#frmLocal');
    var rNmarquiv  = $('label[for="nmarquiv"]','#frmLocal');
	
	rNmarquiv.addClass('rotulo').css({'width':'180px'});
	
	cNmarquiv.css({'width':'180px'});
	cNmarquiv.habilitaCampo();
	cNmarquiv.focus();
	
	cNmarquiv.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {

			showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','validaArquivo();','$(\'#nmarquiv\',\'#frmLocal\').focus();bloqueiaFundo($(\'#divRotina\'));','sim.gif','nao.gif');			
			return false;
		}

	});

	return false;
}