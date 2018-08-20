/*!
 * FONTE        : cadcyb.js
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Agosto/2013
 * OBJETIVO     : Biblioteca de funções da tela CADCYB
 * --------------
 * ALTERAÇÕES   : 30/03/2015 - Melhorias na tela CADCYB (Jonata-RKAM).
 *                31/08/2015 - Adicionar validações para os campos de Assessoria e Motivo CIN (Douglas - Melhoria 12)
 *                25/11/2015 - Ajustar o tamanho do label do campo Data Envio Contrato Assessoria Cobrança (Douglas - Melhoria 12)
 *                10/12/2015 - Ajustes na rotina para nao apresentar borda a mais nos campos checkbox,
 *                             isso ocorria devido a funcao habilita e desabilita que adicionava a classe campo
 *                             devido a isso foi criaca as funcoes desabilitaCheckbox e habilitaCheckbox e ajustado o tamanho dos campos
 *                             SD347594 (Odirlei-AMcom)
 *                19/01/2017 - PRJ 432 - Melhorias Envio CYber - incluída validação para verificar se assessoria estiver preenchida,
                               os campos flgjudic e flextjud não podem er nulos (Jean/Mout´S).
 *                15/02/2017 - Alteracao para habilitar btnOk quando chamado funcao estadoInicial. (Jaison/James)
 *				  04/06/2018 - Projeto 403 - Inclusão de tratativas para a inclusão de títulos vencidos na Cyber (Lucas - GFT)	
 *				  21/06/2018 - Inserção de bordero e titulo [Vitor Shimada Assanuma (GFT)]
 * -----------------------------------------------------------------------
 */

var arrAssociado, arrPesqAssociado, glbTabCdorigem, glbTabNrdconta, glbTabNrctremp, glbTabNrdconta, glbTabNrtitulo;
var flgjudic, flextjud, flgehvip, flgmsger, dtenvcbr;	 
 
var arrayConsulta = new Array();
 
$(document).ready(function() {
	estadoInicial();
    
});

$.fn.extend({ 
    
    desabilitaCheckbox: function() {
        return this.each(function() {	          
            $(this).prop('readonly',true).prop('disabled',true).removeClass('checkboxFocusIn');                    
        });		
    },
    
    habilitaCheckbox: function() {
        return this.each(function() {	          
            $(this).prop('readonly',false).prop('disabled',false).removeClass('checkboxFocusIn');
        });		
    }
});

function estadoInicial() {

	$("#divTela").css({"width":"720px","padding-bottom":"2px"});
	$('#divTela').fadeTo(0,0.1);
	
	arrAssociado = new Array();
	formataCabecalho();
	formataTabela();
	validaOpcaoOrigem();
	
	$('#divTabela').css({'display':'none'});
	$('#divConsulta').css({'display':'none'});
	$('#divRegistros').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	$('#divOpcoes').css({'display':'none'});
	$('#divOpcoes2').css({'display':'none'});
	$('#divPesquisaRodape').css({'display':'none'});
	$('#frmCab').css({'display':'block'});


	removeOpacidade('divTela');
	$('#btGravar' ,'#divBotoes').hide();
	$('#btExcluirSelecionado','#divBotoes').hide();
	$('#btExclusao','#divBotoes').hide();
	$('#btImportar','#divBotoes').hide();
	$("#cddopcao","#frmCab").focus();

    $("#btnOk","#frmCab").prop('disabled',false);

}	

// Formata
function formataCabecalho() {
	// Rótulos
	$('label[for="cddopcao"]','#frmCab').addClass('rotulo').css({'width':'80px'});
	
	$('label[for="cdorigem"]','#frmCab').addClass('rotulo').css({'width':'80px'});
	$('label[for="nrdconta"]','#frmCab').addClass('rotulo-linha').css({'width':'55px'});
	$('label[for="nrctremp"]','#frmCab').addClass('rotulo-linha').css({'width':'68px'});
	
	$('label[for="nrborder"]','#frmCab').addClass('rotulo').css({'width':'80px'});
	$('label[for="nrtitulo"]','#frmCab').addClass('rotulo-linha').css({'width':'55px'});
	
	$('label[for="flgjudic"]','#frmCab').addClass('rotulo').css({'width':'80px'});
    $('label[for="flextjud"]','#frmCab').addClass('rotulo-linha').css({'width':'100px'});
	$('label[for="flgehvip"]','#frmCab').addClass('rotulo-linha').css({'width':'68px'});
	
	$('label[for="cdmotivocin"]','#frmCab').addClass('rotulo').css({'width':'80px'});
	$('label[for="cdassessoria"]','#frmCab').addClass('rotulo').css({'width':'80px'});

	$('label[for="dtenvcbr"]','#frmCab').addClass('rotulo').css({'width':'255px'});

	$('label[for="nmdarqui"]','#frmCab').addClass('rotulo').css({'width':'80px'});
	
	// Campos
	$('#cddopcao','#frmCab').css({'width':'400px'}).habilitaCampo();

	$('#cdorigem','#frmCab').css({'width':'165px'}).habilitaCampo(); 
	$('#nrdconta','#frmCab').css({'width':'80px'}).habilitaCampo().setMask('INTEGER','zzzz.zzz-z','.-','');
	$('#nrctremp','#frmCab').css({'width':'80px'}).habilitaCampo(); 


	$('#nrborder','#frmCab').css({'width':'165px'}).habilitaCampo(); 
	$('#nrtitulo','#frmCab').css({'width':'80px'}).habilitaCampo(); 
	

	$('#flgjudic','#frmCab').css({'height':'14px','width':'16px','margin':'3px 0px 3px 3px'}).habilitaCheckbox().attr("checked", false);  
	$('#flextjud','#frmCab').css({'height':'14px','width':'16px','margin':'3px 0px 3px 3px'}).habilitaCheckbox().attr("checked", false); 	
    $('#flgehvip','#frmCab').css({'height':'14px','width':'16px','margin':'3px 0px 3px 3px'}).habilitaCheckbox().attr("checked", false); 
	
	$('#cdmotivocin','#frmCab').css({'width':'50px'}).desabilitaCampo();
	$('#dsmotivocin','#frmCab').css({'width':'300px'}).desabilitaCampo();

	$('#cdassessoria','#frmCab').css({'width':'50px'}).habilitaCampo();
	$('#nmassessoria','#frmCab').css({'width':'300px'}).desabilitaCampo();

	$('#dtenvcbr','#frmCab').css({'width':'80px'}).addClass('data').habilitaCampo();

	$('#nmdarqui','#frmCab').css({'width':'415px'}).desabilitaCampo();

	limparCamposCabecalho();
	
	highlightObjFocus( $('#frmCab') );

	// Se clicar no botao OK
	$('#btnOK','#frmCab').unbind('click').bind('click', function() {
		habilibitaCamposCddopcao();
		return false;
	});	

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			habilibitaCamposCddopcao();
			return false;
		}	
	});	
	
	$('#cdorigem','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			validaOpcaoOrigem();
			return false;
		}
	});
	
	$('#cdorigem','#frmCab').unbind('blur').bind('blur', function() {
		validaOpcaoOrigem();
		return false;
	});
	
	$('#nrborder','#frmCab').unbind('blur').bind('blur', function() {
		$('#nrtitulo','#frmCab').habilitaCampo().focus();
		return false;
	});

	$('#nrdconta','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13) {
			var cddopcao = $("#cddopcao","#frmCab").val();
			var cdorigem = $('#cdorigem','#frmCab').val();
			
			if (cdorigem == '1') {
				if (cddopcao == 'C') { 
					$('#nrctremp','#frmCab').desabilitaCampo();
				}else{
					$('#nrctremp','#frmCab').desabilitaCampo();
					if (cddopcao == 'A') {
						$('#flgjudic','#frmCab').habilitaCheckbox().focus();
					}
				}
			}else if (cdorigem == '4'){
				$('#nrctremp','#frmCab').desabilitaCampo();			
				$('#nrborder','#frmCab').habilitaCampo().focus();			
			} else {
				$('#nrctremp','#frmCab').habilitaCampo().focus();			
			}
			
			if ( (cddopcao == 'A' && cdorigem == '1') || (cddopcao == 'E' && cdorigem == '1') ) {
				$('#nrctremp','#frmCab').desabilitaCampo();
				btnContinuar();
			} 
			return false;			
		}	
	});

	$('#nrctremp','#frmCab').unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			var cddopcao = $("#cddopcao","#frmCab").val();
			var cdorigem = $('#cdorigem','#frmCab').val();
			
			if (cddopcao == 'A' && cdorigem == '3'){
				btnContinuar();
			}
			if (cddopcao == 'C' && cdorigem == '3'){ 
				$('#flgjudic','#frmCab').desabilitaCheckbox();
			}
			if (cddopcao == 'E' && cdorigem == '3'){
				btnContinuar();
			}
			return false;			
		}
	});
	
	$('#flgjudic','#frmCab').unbind('keypress').bind('keypress', function(e) {
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#flextjud','#frmCab').focus();
			return false;
		}
	});		
	
	$('#flextjud','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if( $(this).prop("checked") == true ){
				$('#cdmotivocin','#frmCab').habilitaCampo().val('').focus();
				$('#dsmotivocin','#frmCab').val('');
			} else {
				$('#cdmotivocin','#frmCab').desabilitaCampo().val('');
				$('#dsmotivocin','#frmCab').val('');
			}
			return false;			
		}
	});
	
	$('#flextjud','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#flgehvip','#frmCab').focus();
			return false;			
		}
	});
	
	$('#flgjudic','#frmCab').unbind('click').bind('click', function(e) {
		if( $(this).prop("checked") == true ){
			$('#flextjud','#frmCab').prop("checked",false);			
		}		
	});	

	$('#flextjud','#frmCab').unbind('click').bind('click', function(e) {
		if( $(this).prop("checked") == true ){
			$('#flgjudic','#frmCab').prop("checked",false);			
		}		
	});	

	$('#flgehvip','#frmCab').unbind('click').bind('click', function(e) {
		if( $(this).prop("checked") == true ){
			$('#cdmotivocin','#frmCab').habilitaCampo().val('').focus();
			$('#dsmotivocin','#frmCab').val('');
		} else {
			$('#cdmotivocin','#frmCab').desabilitaCampo().val('');
			$('#dsmotivocin','#frmCab').val('');
		}
	});	
	
	$('#cdmotivocin','#frmCab').unbind('blur').bind('blur', function(e) {
		var valor		= $('#cdmotivocin', '#frmCab').val();
		var filtrosDesc = 'cdmotivo|'+valor;
		buscaDescricao("PARCYB", "PARCYB_CONSULTAR_MOTIVOS_CIN","Motivos CIN",'cdmotivocin','dsmotivocin',valor,'dsmotivo',filtrosDesc,'frmCab');
		return false;
	});
	
	$('#cdassessoria','#frmCab').unbind('blur').bind('blur', function(e) {
		var valor		= $('#cdassessoria', '#frmCab').val();
		var filtrosDesc = 'cdassess|'+valor;
		buscaDescricao("PARCYB", "PARCYB_CONSULTAR_ASSESSORIAS","Assessorias",'cdassessoria','nmassessoria',valor,'nmassessoria',filtrosDesc,'frmCab');
		return false;
	});
	
	layoutPadrao();
	return false;	
}	

function habilibitaCamposCddopcao(){
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	if (cddopcao == 'F') { 
		$('#divOpcoes2').css({'display':'block'});
		$('#btImportar','#divBotoes').show();
		$('#btSalvar' ,'#divBotoes').hide();
	} else {
		$('#divOpcoes').css({'display':'block'});
		$('#btImportar','#divBotoes').hide();
		$('#btSalvar' ,'#divBotoes').show();
	}

	$('#divBotoes').css({'display':'block'});

	$('#btVoltar' ,'#divBotoes').show();	
	$('#btGravar' ,'#divBotoes').hide();
	$('#btExcluirSelecionado','#divBotoes').hide();
	$('#btExclusao','#divBotoes').hide();

	$('#divTabela').css({'display':'none'});

	$('#cddopcao','#frmCab').desabilitaCampo();
	$('#cdorigem','#frmCab').habilitaCampo().val('1').focus();
		
	if (cddopcao == 'C') {
		$("#flgjudic","#frmCab").desabilitaCheckbox();
		$("#flextjud","#frmCab").desabilitaCheckbox();		
        $("#flgehvip","#frmCab").desabilitaCheckbox();

		$("#dtenvcbr","#frmCab").desabilitaCampo();
		$("#cdmotivocin","#frmCab").habilitaCampo();
		$("#cdassessoria","#frmCab").habilitaCampo();
	}else if ( cddopcao == 'E' || cddopcao == 'A') {
		$("#flgjudic","#frmCab").desabilitaCheckbox();	
		$("#flextjud","#frmCab").desabilitaCheckbox();		
        $("#flgehvip","#frmCab").desabilitaCheckbox();
		$("#dtenvcbr","#frmCab").desabilitaCampo();
		$("#cdmotivocin","#frmCab").desabilitaCampo();
		$("#cdassessoria","#frmCab").desabilitaCampo();
	}else {
		$("#flgjudic","#frmCab").habilitaCheckbox();
		$("#flextjud","#frmCab").habilitaCheckbox();		
        $("#flgehvip","#frmCab").habilitaCheckbox();
		$("#dtenvcbr","#frmCab").habilitaCampo();
		$("#cdmotivocin","#frmCab").desabilitaCampo();
		$("#cdassessoria","#frmCab").habilitaCampo();
	}
}

function validaOpcaoOrigem(){
	$('#nrdconta','#frmCab').val('').habilitaCampo().focus();
	if ( $('#cdorigem','#frmCab').val() == '1') {
		$('#nrctremp','#frmCab').val('').desabilitaCampo();
		$('#nrborder','#frmCab').val('').desabilitaCampo();
		$('#nrtitulo','#frmCab').val('').desabilitaCampo();
		$('#nrdocmto','#frmCab').val('').desabilitaCampo();


	} else if($('#cdorigem','#frmCab').val() == '4'){
		$('#nrctremp','#frmCab').val('').desabilitaCampo();
		$('#nrborder','#frmCab').val('').habilitaCampo();
		$('#nrtitulo','#frmCab').val('').habilitaCampo();
		//$('#nrdocmto','#frmCab').val('').habilitaCampo();
		$('#nrdocmto','#frmCab').val('').desabilitaCampo();
		
	} else {
		$('#nrctremp','#frmCab').val('').habilitaCampo();
		$('#nrborder','#frmCab').val('').desabilitaCampo();
		$('#nrtitulo','#frmCab').val('').desabilitaCampo();
		$('#nrdocmto','#frmCab').val('').desabilitaCampo();
		
	}	
}

function btnGravar() {
	
	if ( divError.css('display') == 'block' ) { return false; }		
	
	if ($("#cddopcao","#frmCab").val() == 'A'){
		showConfirmacao('Confirma alteração dos registros?','Confirma&ccedil;&atilde;o - Ayllos','alteraCadcyb();','','sim.gif','nao.gif');				
	}else if($("#cddopcao","#frmCab").val() == 'I') {
	   	  showConfirmacao('Confirma inclusão dos registros?','Confirma&ccedil;&atilde;o - Ayllos','gravarOperacao();','','sim.gif','nao.gif');		
	}
}


function gravarOperacao() {
	
	//Remove a classe de Erro do form
	$('input,select', '#frmCab').removeClass('campoErro');

	showMsgAguardo("Aguarde, realizando operação...");
	
	var strNrdconta = '';
	var strNrctremp = '';
	var strNrborder = '';
	var strNrtitulo = '';
	var	strCdorigem = '';
	var strFlgjudic = '';
	var strFlextjud = '';
	var strFlgehvip = '';
	var strDtcnvcbr = '';
	var strCdassess = '';
	var strCdmotcin = '';
	
	// Verifica se existe contas a serem processadas.
	if (arrAssociado.length <= 0) {
		hideMsgAguardo();
		showError("error","N&atilde;o possui contas a serem processados.","Alerta - Ayllos","unblockBackground");
		return false;
	}
	
	// Monta lista com contas a serem processadas.
	for(var i=0,len=arrAssociado.length; i<len; i++){
		strNrdconta = strNrdconta + arrAssociado[i].nrdconta + ';';
		strNrctremp = strNrctremp + arrAssociado[i].nrctremp + ';';
		strNrborder = strNrborder + arrAssociado[i].nrborder + ';';
		strNrtitulo = strNrtitulo + arrAssociado[i].nrtitulo + ';';
		strCdorigem = strCdorigem + arrAssociado[i].cdorigem + ';';
		strFlgjudic = strFlgjudic + arrAssociado[i].flgjudic + ';';
		strFlextjud = strFlextjud + arrAssociado[i].flextjud + ';';
		strFlgehvip = strFlgehvip + arrAssociado[i].flgehvip + ';'; 
		strDtcnvcbr = strDtcnvcbr + arrAssociado[i].dtenvcbr + ';'; 
		strCdassess = strCdassess + arrAssociado[i].cdassess + ';'; 
		strCdmotcin = strCdmotcin + arrAssociado[i].cdmotcin + ';'; 
	}

	$.trim(strNrdconta);
	strNrdconta = strNrdconta.substr(0,strNrdconta.length - 1);	
	
	$.trim(strNrctremp);
	strNrctremp = strNrctremp.substr(0,strNrctremp.length - 1);
	
	$.trim(strNrborder);
	strNrborder = strNrborder.substr(0,strNrborder.length - 1);
	
	$.trim(strNrtitulo);
	strNrtitulo = strNrtitulo.substr(0,strNrtitulo.length - 1);
	
	$.trim(strCdorigem);
	strCdorigem = strCdorigem.substr(0,strCdorigem.length - 1);
	
	$.trim(strFlgjudic);
	strFlgjudic = strFlgjudic.substr(0,strFlgjudic.length - 1);
	
	$.trim(strFlextjud);
	strFlextjud = strFlextjud.substr(0,strFlextjud.length - 1);
	
	$.trim(strFlgehvip);
	strFlgehvip = strFlgehvip.substr(0,strFlgehvip.length - 1);
	
	$.trim(strDtcnvcbr);
	strDtcnvcbr = strDtcnvcbr.substr(0,strDtcnvcbr.length - 1);
	
	$.trim(strCdassess);
	strCdassess = strCdassess.substr(0,strCdassess.length - 1);
	
	$.trim(strCdmotcin);
	strCdmotcin = strCdmotcin.substr(0,strCdmotcin.length - 1);
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadcyb/manter_rotina.php", 
		data: {
			strNrdconta: strNrdconta,
			strNrctremp: strNrctremp,
			strNrborder: strNrborder,
			strNrtitulo: strNrtitulo,
			strCdorigem: strCdorigem,
			strFlgjudic: strFlgjudic,
			strFlextjud: strFlextjud,
			strFlgehvip: strFlgehvip,
			strDtcnvcbr: strDtcnvcbr,
			strCdassess: strCdassess,
			strCdmotcin: strCdmotcin,
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
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});		
}

function btnExclusao() {

	if ( divError.css('display') == 'block' ) { return false; }		
	
	showConfirmacao('Confirma exclusão do registro?','Confirma&ccedil;&atilde;o - Ayllos','excluirCrapcyc();','','sim.gif','nao.gif');				
}

function excluirCrapcyc(flgmsger) {

	hideMsgAguardo();

	var nrctremp;
	var nrdconta = normalizaNumero( $("#nrdconta","#frmCab").val() );
	var cdorigem = $("#cdorigem","#frmCab").val();
	var nrborder = $("#nrborder","#frmCab").val();
	var nrtitulo = $("#nrtitulo","#frmCab").val();

	if (cdorigem == "1") {
		nrctremp = nrdconta;
	}else{
		nrctremp = $("#nrctremp","#frmCab").val();
	}	

	showMsgAguardo( 'Aguarde, excluindo registro...' );	

	// Carrega dados da conta através de ajax
	$.ajax({		
		type: 'POST',
		url	: UrlSite + 'telas/cadcyb/excluir_dados.php', 
		data: { 
				nrdconta: nrdconta,
				nrctremp: nrctremp,
				cdorigem: cdorigem,
				nrborder: nrborder,
				nrtitulo: nrtitulo,
				redirect: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
			try {
				hideMsgAguardo();		
				eval(response);				
			    return false;
			} catch(error) {				
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			}
		}
	});				
}

// Botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function controlaBotao() {
	if ($("#cddopcao","#frmCab").val() == 'C') {
		buscaConsulta(1,30);		
	}else {
		btnContinuar();
	}
}

function btnContinuar() {

	// Armazena o número da conta na variável global
	var nrdconta = normalizaNumero( $("#nrdconta","#frmCab").val() );
	var nrctremp = $("#nrctremp","#frmCab").val();
	var nrborder = $("#nrborder","#frmCab").val();
	var nrtitulo = $("#nrtitulo","#frmCab").val();
	var nrdocmto = $("#nrdocmto","#frmCab").val();
	var operacao = $("#cddopcao","#frmCab").val();
	var cdorigem = $("#cdorigem","#frmCab").val();
	var dtenvcbr = $("#dtenvcbr","#frmCab").val();
	var cdassess = $("#cdassessoria","#frmCab").val();
	var cdmotcin = $("#cdmotivocin","#frmCab").val();
	var nrborder = $("#nrborder","#frmCab").val();
	
	
	if (cdorigem == "1") {
		nrctremp = nrdconta;
	}else if (cdorigem == "4") {
		nrctremp = $("#nrborder","#frmCab").val();
	}else{
		nrctremp = $("#nrctremp","#frmCab").val();
	}	
	

	// Verifica se o número da conta é vazio
	if ( nrdconta == '' ) { 
		showError('error','Conta/dv Inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\'frmCab\');'); 
		return false; 
	}	

	// Verifica se a conta é válida
	if ( !validaNroConta(nrdconta) ) { 
		showError('error','Conta/dv Inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\'frmCab\');'); 
		return false; 
	}
	
	if( $("#flgjudic","#frmCab").prop("checked") ){
		flgjudic = 'true'; 
	} else {
		flgjudic = 'false'; 
	}
	
	if( $("#flextjud","#frmCab").prop("checked") ){
		flextjud = 'true'; 
	} else {
		flextjud = 'false'; 
	}
	
	if( $("#flgehvip","#frmCab").prop("checked") ){
		flgehvip = 'true'; 
		if ( cdmotcin == 0 ) {
			showError('error','Motivo CIN Inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'cdmotivocin\',\'frmCab\');'); 
			return false; 
		}
	} else {
		flgehvip = 'false'; 
	}
	
	if ( (flgjudic == 'true') && (flextjud == 'true') ) {
		showError('error','O cooperado não pode ser Judicial e Extra Judicial ao mesmo tempo.','Alerta - Ayllos','focaCampoErro(\'flgjudic\',\'frmCab\');');
		return false;	
	}

    // 17/01/2017 - Prj 432 - verificar se assessoria está preenchida, ao menos um dos flags (flgjudic ou flextjud) devem estar setados. (Jean/Mout´S)
	if ((cdassess != '') && (flgjudic == 'false') && (flextjud == 'false')) {
        showError('error','Se a assessoria estiver preenchida, deve ser definido os flags Judicial ou Extra Judicial.','Alerta - Ayllos','focaCampoErro(\'cdassess\',\'frmCab\');');
        return false;
    }

	var mensagem = 'Aguarde, buscando dados da conta ...';
	showMsgAguardo( mensagem );	

	// Carrega dados da conta através de ajax

	$.ajax({		
		type: 'POST',
		url	: UrlSite + 'telas/cadcyb/principal.php', 
		data: { 
				operacao: operacao,
				nrdconta: nrdconta,
				nrctremp: nrctremp,
				nrborder: nrborder,
				nrtitulo: nrtitulo,
				nrdocmto: nrdocmto,
				cdorigem: cdorigem,
				flgjudic: flgjudic,
				flextjud: flextjud,
				flgehvip: flgehvip,
				dtenvcbr: dtenvcbr,
				cdassess: cdassess,
				cdmotcin: cdmotcin,
				redirect: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					try { 
						hideMsgAguardo();
						eval(response);
						formataTabela();
						if (operacao == 'I') {
							if (cdorigem == '4'){
								$("#thnrctremp").css({'display':'none'});

								$("#tbCadcyb #nrctremp").css({'display':'none'});
							}else{
								$("#thnrborder").css({'display':'none'});
								$("#thnrtitulo").css({'display':'none'});
						
								$("#tbCadcyb #nrborder").css({'display':'none'});
								$("#tbCadcyb #nrtitulo").css({'display':'none'});
							}
						}
						else if (operacao == 'A') {
							// Tratar os botões para alteração
							$('#btVoltar' ,'#divBotoes').show();
							$('#btSalvar' ,'#divBotoes').hide();
							$('#btGravar' ,'#divBotoes').show();
							$('#btExcluir','#divBotoes').hide();
							$('#btExclusao','#divBotoes').hide();
							// Habilitar os campos para edição
							$("#flgjudic","#frmCab").habilitaCheckbox().focus();
							$("#flextjud","#frmCab").habilitaCheckbox();							
                            $("#flgehvip","#frmCab").habilitaCheckbox();
							$("#dtenvcbr","#frmCab").habilitaCampo();
							$("#cdassessoria","#frmCab").habilitaCampo();
							if( $("#flgehvip","#frmCab").prop("checked") ){
								$("#cdmotivocin","#frmCab").habilitaCampo();
							} else {
								$("#cdmotivocin","#frmCab").desabilitaCampo();
							}
						} else if (operacao == 'E'){
							// Tratar os botões para exclusão
							$('#btVoltar' ,'#divBotoes').show();
							$('#btSalvar' ,'#divBotoes').hide();
							$('#btGravar' ,'#divBotoes').hide();
							$('#btExcluir','#divBotoes').hide();
							$('#btExclusao','#divBotoes').show();
						}
						
						return false;
					} catch(error) {				
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
	});	
	return false;
}

function alteraCadcyb() {
	
	hideMsgAguardo();

	// Armazena o número da conta na variável global
	var nrctremp;
	var nrdconta = normalizaNumero( $("#nrdconta","#frmCab").val() );
	var operacao = $("#cddopcao","#frmCab").val();
	var cdorigem = $("#cdorigem","#frmCab").val();
	var dtenvcbr = $("#dtenvcbr","#frmCab").val();
	var cdassess = $("#cdassessoria","#frmCab").val();
	var cdmotcin = $("#cdmotivocin","#frmCab").val();
	
	if (cdorigem == "1") {
		nrctremp = nrdconta;
	}else{
		nrctremp = $("#nrctremp","#frmCab").val();
	}	
	
	// Verifica se o número da conta é vazio
	if ( nrdconta == '' ) { 
		showError('error','Conta/dv Inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\'frmCab\');'); 
		return false; 
	}	

	// Verifica se a conta é válida
	if ( !validaNroConta(nrdconta) ) { 
		showError('error','Conta/dv Inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\'frmCab\');'); 
		return false; 
	}
	
	if( $("#flgjudic","#frmCab").prop("checked") ){
		flgjudic = 'true'; 
	} else {
		flgjudic = 'false'; 
	}
	
	if( $("#flextjud","#frmCab").prop("checked") ){
		flextjud = 'true'; 
	} else {
		flextjud = 'false'; 
	}
	
	if( $("#flgehvip","#frmCab").prop("checked") ){
		flgehvip = 'true'; 
		if ( cdmotcin == 0 ) {
			showError('error','Motivo CIN Inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'cdmotivocin\',\'frmCab\');'); 
			return false; 
		}
	} else {
		flgehvip = 'false'; 
	}
	
	if ( (flgjudic == 'true') && (flextjud == 'true') ) {
		showError('error','O cooperado não pode ser Judicial e Extra Judicial ao mesmo tempo.','Alerta - Ayllos','focaCampoErro(\'flgjudic\',\'frmCab\');');
		return false;	
	}

    // 17/01/2017 - Prj 432 - verificar se assessoria está preenchida, ao menos um dos flags (flgjudic ou flextjud) devem estar setados. (Jean/Mout´S)
	if ((cdassess != '') && (flgjudic == 'false') && (flextjud == 'false')) {
        showError('error','Se a assessoria estiver preenchida, deve ser definido os flags Judicial ou Extra Judicial.','Alerta - Ayllos','focaCampoErro(\'cdassess\',\'frmCab\');');
	    return false;
    }

	var mensagem = 'Aguarde, alterando dados...';
	showMsgAguardo( mensagem );	

	// Carrega dados da conta através de ajax
	$.ajax({		
		type: 'POST',
		url	: UrlSite + 'telas/cadcyb/altera_cadcyb.php', 
		data: { 
				nrdconta: nrdconta,
				nrctremp: nrctremp,
				cdorigem: cdorigem,
				flgjudic: flgjudic,
				flextjud: flextjud,
				flgehvip: flgehvip,
				dtenvcbr: dtenvcbr,
				cdassess: cdassess,
				cdmotcin: cdmotcin,
				redirect: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
			try {
				hideMsgAguardo();		
				eval(response);				
			    return false;
			} catch(error) {				
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			}
		}
	});				
}

function carregaTabela(){

	$("table.divRegistros", "#divTabela" ).remove();

	$('#divTabela').css({'display':'block'});
	
	$('#regAssociado').html('');
	
	for(var i=0,len=arrAssociado.length; i<len; i++){
		$('#regAssociado').append( 
					'<tr>' +    
						'<td id="cdorigem"><span>'+arrAssociado[i].cdorigem+'</span>'
							      +arrAssociado[i].cdorigem+
						'</td>'+
						'<td id="nrdconta"><span>'+arrAssociado[i].nrdconta+'</span>'
							      +mascara(arrAssociado[i].nrdconta,'####.###.#')+
						'</td>'+
						'<td id="nrctremp"><span>'+arrAssociado[i].nrctremp+'</span>'
							      +arrAssociado[i].nrctremp+
						'</td>'+
						'<td id="nrborder"><span>'+arrAssociado[i].nrborder+'</span>'
							      +arrAssociado[i].nrborder+
						'</td>'+
						'<td id="nrtitulo"><span>'+arrAssociado[i].nrdocmto+'</span>'
							      +arrAssociado[i].nrdocmto+
						'</td>'+
						'<td><span>'+arrAssociado[i].flgjudic+'</span>'
							      +arrAssociado[i].flgjudic+
						'</td>'+
						'<td><span>'+arrAssociado[i].flextjud+'</span>'
							      +arrAssociado[i].flextjud+
						'</td>'+
						'<td><span>'+arrAssociado[i].flgehvip+'</span>'
							      +arrAssociado[i].flgehvip+
						'</td>'+						
					'</tr>'
		);
	}
		
	$('#btVoltar' ,'#divBotoes').show();
    $('#btSalvar' ,'#divBotoes').show();
    $('#btGravar' ,'#divBotoes').show();
	$('#btExcluirSelecionado','#divBotoes').show();
}

function formataTabela() {
	
	$("table.tituloRegistros", "#divTabela"  ).remove();
	
	// Tabela
    var divRegistro = $('div.divRegistros', '#divTabela');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	$('#divTabela').css({'margin-top':'4px'});
	divRegistro.css({'height':'190px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '';
	arrayLargura[1] = '70px';
	arrayLargura[2] = '70px';
	arrayLargura[3] = '61px';
	arrayLargura[4] = '61px';
	arrayLargura[5] = '70px';
	arrayLargura[6] = '90px';
	arrayLargura[7] = '50px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'center';
	arrayAlinha[6] = 'center';
	arrayAlinha[7] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	glbTabCdorigem = '';
	glbTabNrdconta = '';
	glbTabNrctremp = '';
	glbTabNrborder = '';
	glbTabNrtitulo = '';
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		glbTabCdorigem = $(this).find('#cdorigem > span').text() ;
	});

	$('table > tbody > tr', divRegistro).click( function() {
		glbTabNrdconta = $(this).find('#nrdconta > span').text() ;
	});
	
	$('table > tbody > tr', divRegistro).click( function() {
		glbTabNrctremp = $(this).find('#nrctremp > span').text() ;
	});

	$('table > tbody > tr', divRegistro).click( function() {
		glbTabNrborder = $(this).find('#nrborder > span').text() ;
	});

	$('table > tbody > tr', divRegistro).click( function() {
		glbTabNrtitulo = $(this).find('#nrtitulo > span').text() ;
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();
	
	return false;
}

function criaObjetoAssociado(cdorigem, nrdconta, nrctremp, nrborder, nrtitulo, nrdocmto, flgjudic, flextjud, flgehvip, dtenvcbr, cdassess, cdmotcin ) {

	var judicial, extjudic, coopvip, dsorigem; 
	if (flgjudic == 'false') {
		judicial = 'Nao';
	} else { 
		judicial = 'Sim'; 
	} 
	
	if (flextjud == 'false') {
		extjudic = 'Nao';
	} else {
		extjudic = 'Sim'; 
	}
	
	if (flgehvip == 'false') {
		coopvip = 'Nao';
	} else { 
		coopvip = 'Sim'; 
	}
	
	if (cdorigem == "1") {
		dsorigem = 'Conta';
	} else if (cdorigem == "4") { 
		dsorigem = 'Desconto de Titulo'; 
	} else { 
		dsorigem = 'Emprestimo'; 
	}
	
	var flgCria = true;
	
	for(var i=0,len=arrAssociado.length; i<len; i++){ 
		// Verifica se conta já foi incluida, evitando assim duplicidade de registros.
		if  ( ((dsorigem == "Conta") 	  	      && (arrAssociado[i].nrdconta == nrdconta)) || 
			  ((dsorigem == "Emprestimo") 		  && (arrAssociado[i].nrdconta == nrdconta) && (arrAssociado[i].nrctremp == nrctremp)) || 
			  ((dsorigem == "Desconto de Titulo") && (arrAssociado[i].nrdconta == nrdconta) && (arrAssociado[i].nrborder == nrborder) && (arrAssociado[i].nrtitulo == nrtitulo)) ) {
			flgCria = false;			
			break;			
		}
	}
	
	if ( flgCria == true ) { 
		var objAssociado = new associado(dsorigem, nrdconta, nrctremp, nrborder, nrtitulo, nrdocmto, judicial, extjudic, coopvip, dtenvcbr, cdassess, cdmotcin);
		arrAssociado.push( objAssociado );
	} else {
		//showError("error",$msgErro,"Alerta - Ayllos","limparCamposCabecalho();",NaN);
		showError("error","Registro já inserido na tabela!","Alerta - Ayllos","limparCamposCabecalho();",NaN);
	}
}

function associado(cdorigem, nrdconta, nrctremp, nrborder, nrtitulo, nrdocmto, flgjudic, flextjud, flgehvip, dtenvcbr, cdassess, cdmotcin ) {
	this.cdorigem=cdorigem;
	this.nrdconta=nrdconta;
	this.nrctremp=nrctremp;
	this.nrborder=nrborder;
	this.nrtitulo=nrtitulo;
	this.nrdocmto=nrdocmto;
	this.flgjudic=flgjudic;
	this.flextjud=flextjud;
	this.flgehvip=flgehvip;
	this.dtenvcbr=dtenvcbr;
	this.cdassess=cdassess;
	this.cdmotcin=cdmotcin;
}

function btnExcluir() {
	if ( glbTabNrdconta == '' ) {
		showError('error','Não há registro selecionado','Alerta - Ayllos',"unblockBackground()");
		return false
	} else {
		showConfirmacao('Deseja realmente excluir o registro selecionado?','Confirma&ccedil;&atilde;o - Ayllos','excluirRegistro()','','sim.gif','nao.gif');	
	}	
}

function excluirRegistro() {
	var operacao = $("#cddopcao","#frmCab").val();
	var cdorigem = $("#cdorigem","#frmCab").val();
	
	for(x=0;x<arrAssociado.length;x++) {
		if  ( (arrAssociado[x].cdorigem == glbTabCdorigem) && 
			  (arrAssociado[x].nrdconta == glbTabNrdconta) && 
			  (arrAssociado[x].nrctremp == glbTabNrctremp) && 
			  (arrAssociado[x].nrborder == glbTabNrborder) && 
			  (arrAssociado[x].nrdocmto == glbTabNrtitulo) ) {
			arrAssociado.splice(x,1);
		}		
	}

	carregaTabela();
	formataTabela();
	limparCamposCabecalho();
	if (operacao == 'I'){
		if (cdorigem == '4'){
			$("#thnrctremp").css({'display':'none'});
		}
	}
	
	return false;
}

function buscaConsulta(nriniseq, nrregist)  {
	
	hideMsgAguardo();

	var nrdconta = normalizaNumero( $("#nrdconta","#frmCab").val() );
	var nrctremp = $("#nrctremp","#frmCab").val();
	var nrborder = $("#nrborder","#frmCab").val();
	var nrtitulo = $("#nrtitulo","#frmCab").val();
	var cdorigem = $("#cdorigem","#frmCab").val();
	var cdassess = $("#cdassessoria","#frmCab").val();
	var cdmotcin = $("#cdmotivocin","#frmCab").val();
	
	
	/*
	if (cdorigem == "1") {
		nrctremp = nrdconta;
	}else{
		nrctremp = $("#nrctremp","#frmCab").val();
	}	
	*/
	
	var mensagem = 'Aguarde, buscando dados da conta ...';
	showMsgAguardo( mensagem );	

	// Carrega dados da conta através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url	: UrlSite + 'telas/cadcyb/consulta_dados.php', 
		data: { 
				nrdconta: nrdconta,
				nrctremp: nrctremp,
				nrborder: nrborder,
				nrtitulo: nrtitulo,
				cdorigem: cdorigem,
				nriniseq: nriniseq,
				nrregist: nrregist,
				cdassess: cdassess,
				cdmotcin: cdmotcin,
				redirect: 'html_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
			$('#divConsulta').html(response);		
			formataTabelaConsulta();
			$('#divPesquisaRodape','#divConsulta').formataRodapePesquisa();
			hideMsgAguardo();			
		}
	});					
}
function formataTabelaConsulta() {

	var divRegistro = $('div.divRegistros','#divConsulta');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	var mostraColunasDscto = $('#aux_cdorigem').val();
	
	$('#divConsulta').css({'margin-top':'4px'});
	divRegistro.css({'height':'190px','padding-bottom':'2px'});
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '140px';
	arrayLargura[1] = '80px';
	arrayLargura[2] = '80px';
	arrayLargura[3] = '80px';
	arrayLargura[4] = '91px';
	arrayLargura[5] = '85px';
	//arrayLargura[6] = '54px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'center';
	arrayAlinha[6] = 'center';
	
	var metodoTabela = '';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

	$("#nrdconta","#frmCab").desabilitaCampo();
	$("#cdorigem","#frmCab").desabilitaCampo();
	$("#nrctremp","#frmCab").desabilitaCampo();
	$("#nrborder","#frmCab").desabilitaCampo();
	$("#nrtitulo","#frmCab").desabilitaCampo();
	$("#flextjud","#frmCab").desabilitaCheckbox();
	$("#flgjudic","#frmCab").desabilitaCheckbox();	
    $("#flgehvip","#frmCab").desabilitaCheckbox();
	$("#cdmotivocin","#frmCab").desabilitaCampo();	
	$("#cdassessoria","#frmCab").desabilitaCampo();	

	$("#btnOk","#frmCab").prop('disabled',true);		
	$('#btSalvar' ,'#divBotoes').hide();	
	$('#divConsulta').css({'display':'block'});	
	$('#divTabela').css({'display':'none'});	

	hideMsgAguardo();
	return false;
}

function btnImportar() {
	
	if ( divError.css('display') == 'block' ) { return false; }		
	
	showConfirmacao('Confirma importa&ccedil;&atilde;o dos registros?','Confirma&ccedil;&atilde;o - Ayllos','importarCadcyb();','','sim.gif','nao.gif');				
}

function importarCadcyb() {
	
	hideMsgAguardo();
	
	var nmdarqui;
	var nmdarqui = $("#nmdarqui","#frmCab").val();
	
	var mensagem = 'Aguarde, importando registros...';
	showMsgAguardo( mensagem );	
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: 'POST',
		url	: UrlSite + 'telas/cadcyb/importa_cadcyb.php', 
		data: { 
				nmdarqui: nmdarqui,
				redirect: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
			try {
				hideMsgAguardo();		
				eval(response);				
			    return false;
			} catch(error) {				
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			}
		}
	});				
}

function mostraDetalhes (dsorigem, nrdconta, nrctremp, flgjudic, flextjud, flgehvip, dtenvcbr, dtinclus, cdopeinc, dtaltera, cdoperad, assessor, motivocin, nrborder, nrtitulo, nrdocmto) {

	var mensagem = 'Aguarde, consultando dados ...';
	showMsgAguardo( mensagem );	

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadcyb/rotina.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			mostraRotina(dsorigem, nrdconta, nrctremp, flgjudic, flextjud, flgehvip, dtenvcbr, dtinclus, cdopeinc, dtaltera, cdoperad, assessor, motivocin, nrborder, nrtitulo, nrdocmto) ;
		}				
	});
	return false;

}

function mostraRotina (dsorigem, nrdconta, nrctremp, flgjudic, flextjud, flgehvip, dtenvcbr, dtinclus, cdopeinc, dtaltera, cdoperad, assessor, motivocin, nrborder, nrtitulo, nrdocmto) {	
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadcyb/form_detalhes.php', 
		data: {
			dsorigem : dsorigem,
			nrdconta : nrdconta,
			nrctremp : nrctremp,
			flgjudic : flgjudic,
			flextjud : flextjud,
			flgehvip : flgehvip,
			dtenvcbr : dtenvcbr,
			dtinclus : dtinclus,
			cdopeinc : cdopeinc,
			dtaltera : dtaltera,
			cdoperad : cdoperad,
			assessor : assessor,
			motivocin: motivocin,
			nrborder : nrborder,
			nrtitulo : nrtitulo,
			nrdocmto : nrdocmto,
			redirect : 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"fechaOpcao();");
		},
		success: function(response) {
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudo').html(response);
					exibeRotina( $('#divRotina') );
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','fechaOpcao();');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','fechaOpcao();');
				}
			}
		}
	});
	return false;
}

function formataDetalhes () {

	$('label', '#frmDetalhes').addClass('rotulo').css({'width':'170px','text-align':'right','margin-left':'10px'});
	
	$('input[type="text"],select','#frmDetalhes').css({'width':'250px','margin-right':'40px'}).desabilitaCampo();
	
	layoutPadrao();
	return false;
}

function fechaOpcao() {

	fechaRotina( $('#divRotina') );
	$('#divRotina').html('');
	
}

// Função para abrir a pesquisa de asessorias
function mostrarPesquisaAssessoria(){
	if( $('#cdassessoria','#frmCab').prop("disabled") ) {
		return false;
	}
	//Definição dos filtros
	var filtros	= "Código Assessoria;cdassessoria;50px;N;;N;|Nome Assessoria;nmassessoria;200px;S;;S;descricao";
	//Campos que serão exibidos na tela
	var colunas = 'Código;cdassessoria;20%;right|Nome Assessoria;nmassessoria;80%;left';			
	//Exibir a pesquisa
	mostraPesquisa("PARCYB", "PARCYB_BUSCAR_ASSESSORIAS", "Assessorias","100",filtros,colunas);
}

// Função para abrir a pesquisa de motivos CIN
function mostrarPesquisaMotivoCin(){
	if( $('#cdmotivocin','#frmCab').prop("disabled") ) {
		return false;
	}
	//Definição dos filtros
	var filtros	= "Código;cdmotivocin;50px;N;;N;|Motivo CIN;dsmotivocin;200px;S;;S;descricao";
	//Campos que serão exibidos na tela
	var colunas = 'Código;cdmotivo;20%;right|Motivo CIN;dsmotivo;80%;left';			
	//Exibir a pesquisa
	mostraPesquisa("PARCYB", "PARCYB_BUSCAR_MOTIVOS_CIN", "Motivos CIN","100",filtros,colunas);
}


// Função para abrir a pesquisa de borderos, usando número do título
function mostrarPesquisaBorderoPorTitulo(){
	$('#frmCab #nrdocmto').val('');
	var normNrconta = normalizaNumero($('#frmCab #nrdconta').val()) > 0 ? normalizaNumero($('#frmCab #nrdconta').val()) : '';
	var nrBorder    = normalizaNumero($('#frmCab #nrborder').val()) > 0 ? $('#frmCab #nrborder').val() : '';

	if( $('#nrtitulo','#frmCab').prop("disabled") ) {
		return false;
	}
	//Definição dos filtros
	// |;nrborder;;N;;N;nrborder|;nrtitulo;;N;;N;nrtitulo
	var filtros	= "Conta;nrdconta;200px;S;"+normNrconta+";S;nrdconta|Nr. Bordero;nrborder;;S;"+nrBorder+";S;nrborder|Titulo;nrtitulo;;N;;N;nrtitulo|Nr. Documento;nrdocmto;;S;;S;nrdocmto|Valor do Titulo;vltitulo;;N;;N;vltitulo|Dt Venc;dtvencto;;N;;N;dtvencto";
	//Campos que serão exibidos na tela
	var colunas = 'Numero da Conta;nrdconta;0%;center;;N|Bordero;nrborder;20%;center|Titulo;nrtitulo;0%;center;;N|Numero Documento;nrdocmto;20%;center|Valor;vltitulo;20%;center|Vencto;dtvencto;20%;center';			
	//Exibir a pesquisa
	mostraPesquisa("PARCYB", "PARCYB_BUSCAR_TITULOS_BORDERO", "Titulos e Bordero","100",filtros,colunas);
}



function limparCamposCabecalho(){
	// Limpar os campos do formulário
	var file = $('#nmdarqui','#frmCab').val();
	$('input[type="text"],select','#frmCab').limpaFormulario().removeClass('campoErro');
	$('#nmdarqui','#frmCab').val(file);
}
