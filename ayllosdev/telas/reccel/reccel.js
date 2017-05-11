/*!
 * FONTE        : opecel.js
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 21/02/2013
 * OBJETIVO     : Biblioteca de funções da tela OPECEL
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';

//Labels/Campos do cabeçalho
var cCddopcao, cNrdconta, cNmprimtl, cDtinirec, cDtfimrec, btnCab, btLupaConta,
	cNrdddtel, cNrtelefo, cNrdddtel2, cNrtelefo2, cNmopetel, cVlrecarg, btLupaTelefo,
	nomeForm, cdoperadora;

var valores = [];

$(document).ready(function() {

	estadoInicial();
	
	highlightObjFocus( $('#frmCab') );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
	
	
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
	$('#frmOpcaoC').css({'display':'none'});
	$('#frmOpcaoR').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	$('input,select', '#frmCab').removeClass('campoErro');	
	
	formataCabecalho();

	cCddopcao.val( cddopcao );

	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	controlaFoco();
}

function controlaFoco() {
	
	var bo        = '';
	var procedure = '';
	var titulo    = '';
	var qtReg	  = '';
	var filtros   = '';
    var colunas   = '';
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cddopcao = 	$(this).val();
			validaPermissao();		
			return false;
		}	
	});
	
	btnCab.unbind('keypress').bind('keypress', function(e) {
		if (cCddopcao.hasClass('campoTelaSemBorda')) return false;
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cddopcao = 	cCddopcao.val();
			validaPermissao();
			return false;
		}	
	});

	btnCab.unbind('click').bind('click', function(e) {
		if (cCddopcao.hasClass('campoTelaSemBorda')) return false;
		cddopcao = 	cCddopcao.val();
		validaPermissao();
		return false;
	});
	 
}

function formataCabecalho(){
	
	cTodosCabecalho = $('input[type="text"],select','#frmCab');
	cTodosCabecalho.limpaFormulario();
	cTodosCabecalho.habilitaCampo();
	
	// cabecalho
	rCddopcao = $('label[for="cddopcao"]','#frmCab'); 
	rCddopcao.css('width','70px');
	
	cCddopcao	 = $('#cddopcao','#frmCab').css({'width':'445px'}); 
	btnCab		 = $('#btnOK','#frmCab');
	
	cCddopcao.focus();	
	
}

// botoes
function btnVoltar() {

	if (cddopcao == 'C' && !cDtinirec.hasClass('campoTelaSemBorda')){
		cNrdconta.habilitaCampo();
		cDtinirec.val('');
		cDtfimrec.val('');
		cDtinirec.desabilitaCampo();
		cDtfimrec.desabilitaCampo();
		cNrdconta.select();
		return false;
	}else if (cddopcao == 'C' && $('#divRecargas').css('display') == 'block'){
		$('#divRecargas').css('display', 'none');		
		cDtinirec.habilitaCampo();
		cDtfimrec.habilitaCampo();
		cDtinirec.select();
		trocaBotoes();
		return false;
	}else if (cddopcao == 'R' && $('#divEfetuaRecarga').css('display') == 'block'){
		$('#divEfetuaRecarga').css('display', 'none');		
		cNrdconta.habilitaCampo();		
		cNrdconta.val('');
		cNmprimtl.val('');
		cNrdddtel.val('');
		cNrtelefo.val('');
		cNrdddtel2.val('');
		cNrtelefo2.val('');
		cNmopetel.val('0;0');		
		cNrdconta.focus();
		$('#vlrecarga option').remove();
		return false;
	}else if (cddopcao == 'R'){
		$('#nmoperadora option').remove();
		$('#nmoperadora', '#frmOpcaoR').append($('<option>', {
			value: '0;0',
			text: 'Selecione a operadora'
		}).select());
	}
	estadoInicial();
	return false;
}

function buscaConta() {
	showMsgAguardo('Aguarde, buscando dados da Conta...');	
	
	nrdconta = normalizaNumero(cNrdconta.val());
			
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/reccel/busca_conta.php', 
		data    :
				{ nrdconta: nrdconta,	
				  nomeForm: nomeForm,
				  redirect: 'script_ajax'

				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nrdconta\',\'#frmCab\').focus();');
				},
		success : function(response) { 
					hideMsgAguardo();
					eval(response);
				}
	}); 
}

function formataOpcaoC(){
	$('#'+nomeForm, '#divTela').css({'display':'block'});
	highlightObjFocus( $('#'+nomeForm) );

	rNrdconta = $('label[for="nrdconta"]','#'+nomeForm); 
	rDtinirec = $('label[for="dtinirec"]','#'+nomeForm); 
	rDtfimrec = $('label[for="dtfimrec"]','#'+nomeForm); 
	rNmprimtl = $('label[for="nmprimtl"]','#'+nomeForm); 
	rNrdconta.css({'width':'70px'}).addClass('rotulo');	
	rDtinirec.css({'width':'75px'}).addClass('rotulo-linha');	
	rDtfimrec.css({'width':'75px'}).addClass('rotulo-linha');	
	rNmprimtl.css({'width':'70px'}).addClass('rotulo');	
	
	cNrdconta    = $('#nrdconta','#'+nomeForm).addClass('conta pesquisa').css('width','100px');
	cDtinirec    = $('#dtinirec','#'+nomeForm).addClass('data').css('width','75px');
	cDtfimrec    = $('#dtfimrec','#'+nomeForm).addClass('data').css('width','75px');
	cNmprimtl    = $('#nmprimtl','#'+nomeForm).css('width','467px');
	btLupaConta  = $('#btLupaConta','#'+nomeForm);
	
	cNrdconta.habilitaCampo();
	cDtinirec.desabilitaCampo();
	cDtfimrec.desabilitaCampo();
	cNmprimtl.desabilitaCampo();	

	cNrdconta.val("");
	cNmprimtl.val("");
	cDtinirec.val("");
	cDtfimrec.val("");
			
	cNrdconta.focus();

	cNrdconta.unbind('keypress').bind('keypress', function(e){
		if (e.keyCode == 13 ) {
			buscaConta();
		}
	});

	cDtinirec.unbind('keypress').bind('keypress', function(e){
		if (e.keyCode == 13) {
			cDtfimrec.focus();
		}
	});

	cDtfimrec.unbind('keypress').bind('keypress', function(e){
		if (e.keyCode == 13) {
			btnContinuar();
		}
	});

	btLupaConta.css('cursor', 'pointer').unbind('click').bind('click', function () {
		if (cNrdconta.hasClass('campoTelaSemBorda')) return false;
		mostraPesquisaAssociado('nrdconta',nomeForm);
		return false;
     });	

	$('#btnOKC','#'+nomeForm).unbind('keypress').bind('keypress', function(e) {
		if (cNrdconta.hasClass('campoTelaSemBorda')) return false;
		if (e.keyCode == 13 ) {
			buscaConta();
			return false;
		}		
	});

	$('#btnOKC','#'+nomeForm).unbind('click').bind('click', function(e) {
		if (cNrdconta.hasClass('campoTelaSemBorda')) return false;
		buscaConta();
		return false;
	});

	layoutPadrao();
	cDtinirec.attr('tabindex', 1);
	cDtfimrec.attr('tabindex', 2);
	$('#btProsseguir','#divBotoes').attr('tabindex', 3);
	
}

function formataOpcaoR(){

	$('#'+nomeForm, '#divTela').css({'display':'block'});
	highlightObjFocus( $('#'+nomeForm) );

	var rNrdconta = $('label[for="nrdconta"]','#'+nomeForm); 
	var rNmprintl = $('label[for="nmprimtl"]','#'+nomeForm); 
	var rNrdddtel = $('label[for="nrdddtel"]','#'+nomeForm); 
	var rNrtelefo = $('label[for="nrtelefo"]','#'+nomeForm); 
	var rNrdddtel2 = $('label[for="nrdddtel2"]','#'+nomeForm); 
	var rNrtelefo2 = $('label[for="nrtelefo2"]','#'+nomeForm); 
	var rNmopetel = $('label[for="nmoperadora"]','#'+nomeForm); 
	var rVlrecarg = $('label[for="vlrecarga"]','#'+nomeForm); 

	rNrdconta.css({'width':'70px'}).addClass('rotulo');	
	rNmprintl.css({'width':'45px'}).addClass('rotulo-linha');	
	rNrdddtel.css({'width':'250px'}).addClass('rotulo');	
	rNrtelefo.css({'width':'3px'}).addClass('rotulo-linha');	
	rNrdddtel2.css({'width':'250px'}).addClass('rotulo');	
	rNrtelefo2.css({'width':'3px'}).addClass('rotulo-linha');	
	rNmopetel.css({'width':'250px'}).addClass('rotulo');	
	rVlrecarg.css({'width':'250px'}).addClass('rotulo');	
	
	cNrdconta    = $('#nrdconta','#'+nomeForm).addClass('conta pesquisa').css('width','100px');
	cNmprimtl    = $('#nmprimtl','#'+nomeForm).css('width','347px');
	cNrdddtel    = $('#nrdddtel','#'+nomeForm).addClass('campo inteiro').css('width', '30px').attr('maxlength', '2');
	cNrtelefo    = $('#nrtelefo','#'+nomeForm).addClass('campo').css('width', '90px');
	cNrtelefo.setMask("INTEGER","zzzzz-zzzz",".-","");
	cNrdddtel2   = $('#nrdddtel2','#'+nomeForm).addClass('campo inteiro').css('width', '30px').attr('maxlength', '2');
	cNrtelefo2   = $('#nrtelefo2','#'+nomeForm).addClass('campo').css('width', '90px');
	cNrtelefo2.setMask("INTEGER","zzzzz-zzzz",".-","");
	cNmopetel    = $('#nmoperadora','#'+nomeForm).addClass('campo').css('width', '200px');
	cVlrecarg    = $('#vlrecarga','#'+nomeForm).addClass('campo').css('width', '125px').addClass('moeda');
	btLupaConta  = $('#btLupaConta','#'+nomeForm);
	btLupaTelefo = $('#btLupaTelefo','#'+nomeForm);
	
	cNrdconta.habilitaCampo();
	cNmprimtl.desabilitaCampo();
		
	cNrdconta.focus();

	cNrdconta.unbind('keypress').bind('keypress', function(e){
		if (e.keyCode == 13 ) {
			buscaConta();
		}
	});

	btLupaConta.css('cursor', 'pointer').unbind('click').bind('click', function () {
		if (cNrdconta.hasClass('campoTelaSemBorda')) return false;
		mostraPesquisaAssociado('nrdconta',nomeForm);
		return false;
     });	

	$('#btnOKR','#'+nomeForm).unbind('keypress').bind('keypress', function(e) {
		if (cNrdconta.hasClass('campoTelaSemBorda')) return false;
		if (e.keyCode == 13 ) {
			buscaConta();
			return false;
		}		
	});

	$('#btnOKR','#'+nomeForm).unbind('click').bind('click', function(e) {
		if (cNrdconta.hasClass('campoTelaSemBorda')) return false;
		buscaConta();
		return false;
	});

	btLupaTelefo.css('cursor', 'pointer').unbind('click').bind('click', function () {
		mostraPesquisaTelefone();
		return false;
    });	

	cNmopetel.unbind('change').bind('change', function() {
		$('#vlrecarga option', '#frmOpcaoR').remove();		
		cdoperadora = $(this).val().split(";");
		if (cdoperadora[1] != 0){
			var valor = valores[cdoperadora[1]].valor;
			for(var i in valor) {
				$('#vlrecarga', '#frmOpcaoR').append($('<option>', {
					value: valor[i].replace(',','.'),
					text: valor[i]
				}));
			}
		}
		return false;
	});

	cNrdddtel.unbind('keypress').bind('keypress', function(e){
		if (e.keyCode == 13 ) {
			cNrtelefo.focus();
		}		
	});

	cNrdddtel.unbind('keyup').bind('keyup', function(e){
		if ($(this).val().length == 2){
			cNrtelefo.focus();
		}
	});
	
	cNrtelefo.unbind('keypress').bind('keypress', function(e){
		if (e.keyCode == 13 ) {
			cNrdddtel2.focus();
		}
	});

	cNrtelefo.unbind('keyup').bind('keyup', function(e){
		if ($(this).val().length == 10){
			cNrdddtel2.focus();
		}
	});
	
	cNrdddtel2.unbind('keypress').bind('keypress', function(e){
		if (e.keyCode == 13 ) {
			cNrtelefo2.focus();
		}
	});

	cNrdddtel2.unbind('keyup').bind('keyup', function(e){
		if ($(this).val().length == 2){
			cNrtelefo2.focus();
		}
	});

	cNrtelefo2.unbind('keypress').bind('keypress', function(e){
		if (e.keyCode == 13 ) {
			cNmopetel.focus();
		}
	});

	cNrtelefo2.unbind('keyup').bind('keyup', function(e){
		if ($(this).val().length == 10){
			cNmopetel.focus();
		}
	});	
	
	cNmopetel.unbind('keydown').bind('keydown', function(e){
		if (e.keyCode == 13 ) {
			cVlrecarg.focus();
		}
	});

	cVlrecarg.unbind('keydown').bind('keydown', function(e){
		if (e.keyCode == 13 ) {
			btnContinuar();
		}
	});

	layoutPadrao();

	cNrdddtel.attr('tabindex',1);
	cNrtelefo.attr('tabindex',2); 
	cNrdddtel2.attr('tabindex',3);
	cNrtelefo2.attr('tabindex',4);
	cNmopetel.attr('tabindex',5);
	cVlrecarg.attr('tabindex',6);
	$('#btProsseguir','#divBotoes').attr('tabindex',7);
}

function validaPermissao(){
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/reccel/validaPermissao.php", 
		data: {
			cddopcao: cddopcao,
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
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
}

function liberaCampos(){

	if (cddopcao == 'C'){
		cNrdconta.desabilitaCampo();
		cDtinirec.habilitaCampo();
		cDtfimrec.habilitaCampo();
		cDtinirec.focus();
	}else{
		$('#divEfetuaRecarga').css({'display': 'block'});
		cNrdconta.desabilitaCampo();
		cNrdddtel.focus();
	}
	return false;
}

function btnContinuar(){

	if (!cCddopcao.hasClass('campoTelaSemBorda')){
		cCddopcao.desabilitaCampo();		
		if (cddopcao == 'R'){
			nomeForm = 'frmOpcaoR';
			buscaInformacoesOperadoras();
			formataOpcaoR();
		}else{
			nomeForm = 'frmOpcaoC';
			formataOpcaoC();
		}
		trocaBotoes();
	}else if (cddopcao == 'C'){
		if (cNrdconta.hasClass('campoTelaSemBorda')){
			buscaRecarga(1, 50);
		}else{
			buscaConta();
		}
	}else if (cddopcao == 'R' ){
		if (cNrdconta.hasClass('campoTelaSemBorda')){
			efetuaRecarga();
		}else{
			buscaConta();
		}
	}
}

function buscaRecarga(nriniseq, nrregist){

	showMsgAguardo('Aguarde, buscando recargas de celular ...');
	
	var dtinirec, dtfimrec;
	
	nrdconta = normalizaNumero(cNrdconta.val());
	dtinirec = cDtinirec.val();
	dtfimrec = cDtfimrec.val();
	
	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/reccel/busca_recargas.php', 
		data: {
			nrdconta: nrdconta,
			dtinirec: dtinirec,
			dtfimrec: dtfimrec,
			nrregist: nrregist,
			nriniseq: nriniseq,
			redirect: 'html_ajax'           
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();           
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try{
					$('#divRecargas').html(response);
					$('#divRecargas').css({'display': 'block'});
					formataTabelaRecargas();
					$('#divPesquisaRodape', '#divRecargas').formataRodapePesquisa();					
					cDtinirec.desabilitaCampo();
					cDtfimrec.desabilitaCampo();
					trocaBotoes();
				} catch(error){
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			}else{
				try {
					eval( response );					
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			}
		}
	});
	
}

function trocaBotoes(){
	// Mostrar botões
	if ($('#divBotoes', '#divTela').css('display') == 'none'){
		$('#divBotoes', '#divTela').css({'display':'block'});
		$('#btVoltar','#divBotoes').show();
		$('#btProsseguir','#divBotoes').show();
	}else if (cddopcao == 'C'){
		if (cDtinirec.hasClass('campoTelaSemBorda')){
			$('#btImprimir', '#divBotoes').show();
			$('#btProsseguir', '#divBotoes').hide();
		}else{
			$('#btImprimir', '#divBotoes').hide();
			$('#btProsseguir', '#divBotoes').show();
		}
	}
}

function formataTabelaRecargas(){
	
    // tabela
    var divRegistro = $('div.divRegistros', '#divRecargas');
    var tabela = $('table', divRegistro);
		
    $('#' + nomeForm).css({'margin-top': '5px'});
    divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '70px';
    arrayLargura[1] = '70px';
    arrayLargura[2] = '90px';
    arrayLargura[3] = '100px';
    arrayLargura[4] = '90px';
	
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'left';

	glbTabIdoperacao = undefined;

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

	if ($('#qtregist' ,'#divRecargas').val() == 0){
		$("#tbRecargas > tbody")
			.append($('<tr>') // Linha
			.attr('class','corImpar')
			.append($('<td>')
			.attr('rowspan','6')			
			.attr('style', 'text-align: center')
			.text("N\u00e3o foram encontrados registros com os par\u00e2metros informados.")));
			
/*		$('table.tituloRegistros > tbody > tr', '#divRecargas')
			.append($('<tr>') // Linha
			.attr('class','corImpar')
			.attr('style', 'text-align: center')
			.text("N\u00e3o foram encontrados registros com os par\u00e2metros informados."));*/
	}else{	
		// Ordenação da tabela
		$('table.tituloRegistros > thead > tr', '#divRecargas').click( function() {
			glbTabIdoperacao = undefined;
			// Devemos atribuir o evento de click novamente, pois o mesmo é removido ao ordenar a tabela
			$('table.tituloRegistros > tbody > tr', '#divRecargas').click( function() {
				glbTabIdoperacao = $('#idoperacao' ,$(this)).val();
			});

		});
		// seleciona o registro que é clicado
		$('table.tituloRegistros > tbody > tr', '#divRecargas').click( function() {
			glbTabIdoperacao = $('#idoperacao' ,$(this)).val();
		});


		$('table > tbody > tr:eq(0)', divRegistro).click();
	}
}

function imprimeRecarga(){

    if (glbTabIdoperacao == undefined) {
		showError('error','Nenhuma recarga selecionada.','Alerta - Ayllos',"unblockBackground()");
		return false;
	}

	$('#formImpres').html('');

	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#formImpres').append('<input type="hidden" id="cddopcao" name="cddopcao" />');
	$('#formImpres').append('<input type="hidden" id="nrdconta" name="nrdconta" />');
	$('#formImpres').append('<input type="hidden" id="idoperacao" name="idoperacao" />');
	$('#formImpres').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	
	// Agora insiro os devidos valores nos inputs criados
	$('#cddopcao','#formImpres').val( 'C' );
	$('#nrdconta','#formImpres').val( cNrdconta.val() );
	$('#idoperacao','#formImpres').val( glbTabIdoperacao );
	$('#sidlogin','#formImpres').val( $('#sidlogin','#frmMenu').val() );
    
	var action = UrlSite + 'telas/reccel/imprimir_recarga.php';
	
	carregaImpressaoAyllos("formImpres",action,"bloqueiaFundo(divRotina);hideMsgAguardo();");
}

function mostraPesquisaTelefone(){

	procedure = 'PESQUISA_TELEFONES';
	titulo = 'Favoritos';
	qtReg = '30';
	filtros = ';cdseq_favorito;;N;;N;;|;dstelefo;;N;;N;;|;nrdddtel;;N;;N;;|;nrtelefo;;N;;N;;|;nrdconta;;N;' + normalizaNumero(cNrdconta.val()) + ';N;;';
	colunas = 'C&oacutedigo;cdseq_favorito;20%;right|Telefone;dstelefo;80%;left|;nrdddtel;;;;N;|;nrtelefo;;;;N;';
	mostraPesquisa('TELA_RECCEL', procedure, titulo, qtReg, filtros, colunas, 'frmOpcaoR', '$(\'#nmoperadora\', \'#frmOpcaoR\').focus();');
	$('#formPesquisa').css('display', 'none');
	return false;

}

function buscaInformacoesOperadoras(){

	showMsgAguardo('Aguarde, buscando operadoras de celular ...');
		
	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/reccel/busca_operadoras.php', 
		data: {
			redirect: 'html_ajax'           
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();           
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try{
					var obj = jQuery.parseJSON(response);
					var qtdopera = obj.Dados.qtdopera;
					operadora = obj.Dados.operadora;
					mostraOperadoras(operadora, qtdopera);
				} catch(error){
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			}else{
				try {
					eval(response);
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			}
		}
	});
}

function mostraOperadoras(operadora, qtdopera){
	if (qtdopera == '1'){
		$('#nmoperadora').append($('<option>', {
			value: operadora.cdproduto + ';' + operadora.cdoperadora,
			text: operadora.nmproduto
		}));
		// Utilizamos o código da operadora como indice dos valores
		valores[operadora.cdoperadora] = operadora.valores;
	}else{
		for(var i in operadora) {
			$('#nmoperadora').append($('<option>', {
				value: operadora[i].cdproduto + ';' + operadora[i].cdoperadora,
				text: operadora[i].nmproduto
			}));
			// Utilizamos o código da operadora como indice dos valores
			valores[operadora[i].cdoperadora] = operadora[i].valores;
		}
	}
}

function efetuaRecarga(){

	showMsgAguardo('Aguarde, efetuando recarga ...');

	var nrdddtel, nrtelefo, nrdddtel2, nrtelefo2, cdoperadora, cdproduto, vlrecarga, aux_operadora,
		nrdconta;

	nrdddtel = cNrdddtel.val();
	nrdddtel2 = cNrdddtel2.val();
	nrtelefo = normalizaNumero(cNrtelefo.val());
	nrtelefo2 = normalizaNumero(cNrtelefo2.val());
	aux_operadora = cNmopetel.val().split(";");
	cdproduto = aux_operadora[0];
	cdoperadora = aux_operadora[1];
	vlrecarga = cVlrecarg.val();
	nrdconta = normalizaNumero(cNrdconta.val());

	if (nrdddtel.length <= 0){
		showError('error','Informe DDD/Telefone.','Alerta - Ayllos',"unblockBackground();$('#nrdddtel', '#frmOpcaoR').focus();hideMsgAguardo();");
		return false;
	}
	if (nrtelefo == 0){
		showError('error','Informe DDD/Telefone.','Alerta - Ayllos',"unblockBackground();$('#nrtelefo', '#frmOpcaoR').focus();hideMsgAguardo();");
		return false;
	}
	if (nrdddtel.length < 2){
		showError('error','DDD inv&aacute;lido.','Alerta - Ayllos',"unblockBackground();$('#nrdddtel', '#frmOpcaoR').focus();hideMsgAguardo();");
		return false;
	}
	if (nrtelefo.length < 9){
		showError('error','Telefone inv&aacute;lido.','Alerta - Ayllos',"unblockBackground();$('#nrtelefo', '#frmOpcaoR').focus();hideMsgAguardo();");
		return false;
	}
	if (nrdddtel2.length <= 0){
		showError('error','Confirme DDD/Telefone.','Alerta - Ayllos',"unblockBackground();$('#nrdddtel2', '#frmOpcaoR').focus();hideMsgAguardo();");
		return false;
	}
	if (nrtelefo2 == 0){
		showError('error','Confirme DDD/Telefone.','Alerta - Ayllos',"unblockBackground();$('#nrtelefo2', '#frmOpcaoR').focus();hideMsgAguardo();");
		return false;
	}
	if (nrdddtel != nrdddtel2 || nrtelefo != nrtelefo2){
		showError('error','Telefones n&atilde;o conferem.','Alerta - Ayllos',"unblockBackground();$('#nrdddtel', '#frmOpcaoR').focus();hideMsgAguardo();");
		return false;
	}
	if (cdoperadora == 0){
		showError('error','Informe a operadora de celular.','Alerta - Ayllos',"unblockBackground();$('#nmoperadora', '#frmOpcaoR').focus();hideMsgAguardo();");
		return false;
	}
	if (vlrecarga == null){
		showError('error','Informe o valor da recarga.','Alerta - Ayllos',"unblockBackground();$('#vlrecarga', '#frmOpcaoR').focus();hideMsgAguardo();");
		return false;
	}
	
		
	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/reccel/efetua_recarga.php', 
		data: {
			nrdconta: nrdconta,
			nrdddtel: nrdddtel,
			nrtelefo: nrtelefo,
			cdoperadora: cdoperadora,
			cdproduto: cdproduto,
			vlrecarga: vlrecarga,
			redirect: 'html_ajax'           
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();           
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try{
					eval(response);
				} catch(error){
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			}else{
				try {				
					eval(response);	
					$('#btnError').prop('src',UrlImagens + "botoes/fechar.gif");					
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			}
		}
	});
}