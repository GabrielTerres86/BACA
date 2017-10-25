/*!
 * FONTE        : cadmat.js
 * CRIA��O      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 22/09/2017
 * OBJETIVO     : Biblioteca de funções da tela CADMAT
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao, hrinicad, inpessoa = 0, nrdconta, nrdconta_org, nrcpfcgc, lscontas;

// Campos do cabeçalho
var cTodosCabecalho, cCddopcao, cNrdconta, cInpessoa;
// Campos do formulário
var cTodosFrmCadmat, cNmprimtl, cNrcpfcgc, cCdagenci, cNmresage, cNrMatric, 
	cNrdConta, cDtAdmiss, cDtDemiss, cDsTipsai, cDsInctva, cCdMotdem, cDsMotdem;

//Variaveis que armazenam informações do parcelamento
var dtdebito = '';
var qtparcel = '';
var vlparcel = '';
var msgRetor = '';
var idseqttl = 1;

var arrayBensMatric = new Array(); 		// Variável global para armazenar os bens dos procuradores
var arrayFilhosAvtMatric = new Array(); // Variável global para armazenar os procuradores
var arrayBackupAvt = new Array(); 		// Array que armazena o arrayFilhosAvtMatric antes de qualquer operação.
var arrayBackupBens = new Array(); 		// Array que armazena o arrayFilhosBensMatric antes de qualquer operação.
var arrayFilhos = new Array(); 			// Variável global para armazenar os responsaveis legais
var arrayBackupFilhos = new Array();    // Array que armazena o arrayFilhos antes de qualquer operação.

	
$(document).ready(function() {

	estadoInicial();
	
	highlightObjFocus( $('#frmCab') );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	// Obter o horario de inicio do cadastro.
	var data = new Date();
	hrinicad = ((data.getHours() * 3600) + (data.getMinutes() * 60) + data.getSeconds());
	
	// Se origem foi do CRM
	if (crm_inacesso == 1){
		nrdconta = crm_nrdconta;
		nrcpfcgc = crm_nrcpfcgc;
		
		if (normalizaNumero(nrdconta) > 0){
			cCddopcao.val('C');
			cddopcao = 'C';
			prosseguirInicio();
			cNrdconta.val(nrdconta);
			buscaDados();
		}else{
			cCddopcao.val('I');
			cddopcao = 'I';
			prosseguirInicio();
			consultaPreInclusao();
		}
	}
	
	return false;
	
});

//Fun��o criado para resolver problema de mensagens no IE.
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').limpaFormulario();
	$('#frmCab').css({'display':'block'});
	$('#frmCadmat').css({'display':'none'});
	$('#frmCadmat').limpaFormulario();
	$('#divBotoes').css({'display':'none'});
	$('input,select', '#frmCab').removeClass('campoErro');	
	
	formataCabecalho();

	cCddopcao.val('C');
	cCddopcao.habilitaCampo().focus();
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	controlaFocoCab();
	
}

function formataCabecalho() {

	highlightObjFocus($('#frmCab'));

    var rCddopcao = $('label[for="cddopcao"]', '#frmCab');
    var rNrdconta = $('label[for="nrdconta"]', '#frmCab');
    var rInpessoa = $('label[for="inpessoa"]', '#frmCab');

    cTodosCabecalho = $('input[type="text"],input[type="radio"],select', '#frmCab');
    cCddopcao = $('#cddopcao', '#frmCab');
    cNrdconta = $('#nrdconta', '#frmCab');
    cInpessoa = $("#input[name='inpessoa']", '#frmCab');

    rCddopcao.addClass('rotulo').css({ 'width': '42px' });
    rNrdconta.addClass('rotulo').css({ 'width': '42px' });
    rInpessoa.addClass('rotulo-linha').css({ 'width': '2px' });

    cCddopcao.css('width', '589px');
    cNrdconta.addClass('conta pesquisa').css('width', '85px');
	
	cTodosCabecalho.desabilitaCampo();
	
	if (crm_inacesso == 1){
		cNrdconta.val(nrdconta);
	}
	
	layoutPadrao();
	return false;
}

function controlaFocoCab() {
		
	/* -------------- Cabeçalho - INICIO -------------- */
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if (!($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda'))){
				cddopcao = 	cCddopcao.val();
				btnContinuar();
			}
			return false;
		}	
	});

	$('#btnOK','#frmCab').unbind('click').bind('click', function(e) {
		if (!(cCddopcao.hasClass('campoTelaSemBorda'))){
			cddopcao = 	cCddopcao.val();
			btnContinuar();
		}
		return false;
	});
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {			
			$('#btnOK','#frmCab').click();				
			return false;
		}	
	});
	
	// Se pressionar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida a��o
	cNrdconta.unbind('keypress').bind('keypress', function (e) {

		if (divError.css('display') == 'block') { return false; }

		// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Armazena o número da conta na variável global
			nrdconta = normalizaNumero($(this).val());

			// Verifica se o número da conta é vazio
			if (nrdconta == '') { return false; }

			// Verifica se a conta é válida
			if (!validaNroConta(nrdconta)) {
				showError('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Cadmat', 'focaCampoErro(\'nrdconta\',\'frmCab\');');
				return false;
			}

			btnContinuar();
			return false;
		}

	});
	
	// Se mudar a opção, muda a variável global operacao
	$("input[name='inpessoa']").unbind('keypress').bind('keypress', function (e) {

		if (divError.css('display') == 'block') { return false; }
		if (e.keyCode == 13) {		
			btnContinuar();
			return false;
		}

	});

	/* -------------- Cabeçalho - FIM -------------- */

}

function controlaFocoForm(){
	/* ------------ Formulário - INICIO ------------ */
	
	cCdagenci.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cCdempres.focus();
			return false;
		}	
	});
	
	cCdempres.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			btnContinuar();
			return false;
		}	
	});
	
	/* ------------ Formulário - FIM ------------- */
}

function formataTitular() {

	$('#frmCadmat').css({'display':'block'});
	highlightObjFocus($('#frmCadmat'));

	/* ----------------------- */
	/*    FIELDSET TITULAR     */
	/* ----------------------- */
    var rNrcpfcgc    = $('label[for="nrcpfcgc"]', '#frmCadmat');
    var rNomeTitular = $('label[for="nmprimtl"]', '#frmCadmat');
    var rCdagenci    = $('label[for="cdagenci"]', '#frmCadmat');
    var rCdempres    = $('label[for="cdempres"]', '#frmCadmat');
    var rNrMatric    = $('label[for="nrmatric"]', '#frmCadmat');
    var rNrdConta    = $('label[for="nrdconta"]', '#frmCadmat');
    var rDtAdmiss    = $('label[for="dtadmiss"]', '#frmCadmat');
    var rDtDemiss    = $('label[for="dtdemiss"]', '#frmCadmat');
    var rDsTipsai    = $('label[for="dstipsai"]', '#frmCadmat');
    var rDsInctva    = $('label[for="dsinctva"]', '#frmCadmat');
    var rCdMotdem    = $('label[for="cdmotdem"]', '#frmCadmat');
    

    rNrcpfcgc.addClass('rotulo').css('width', '80px');
    rNomeTitular.addClass('rotulo-linha').css('width', '72px');
    rCdagenci.addClass('rotulo').css('width', '80px');
    rCdempres.addClass('rotulo-linha').css('width', '72px');
    rNrMatric.addClass('rotulo').css('width', '80px');
    rNrdConta.addClass('rotulo-linha').css('width', '129px');
    rDtAdmiss.addClass('rotulo-linha').css('width', '130px');
    rDtDemiss.addClass('rotulo').css('width', '80px');
    rDsTipsai.addClass('rotulo-linha').css('width', '144px');
    rDsInctva.addClass('rotulo').css('width', '80px');
    rCdMotdem.addClass('rotulo-linha').css('width', '64px');

    cTodosFrmCadmat = $('input,select', '#frmCadmat');
    cNmprimtl = $('#nmprimtl', '#frmCadmat');
    cNrcpfcgc = $('#nrcpfcgc', '#frmCadmat');
    cCdagenci = $('#cdagenci', '#frmCadmat');
    cNmresage = $('#nmresage', '#frmCadmat');
    cCdempres = $('#cdempres', '#frmCadmat');
    cNmresemp = $('#nmresemp', '#frmCadmat');
    cNrMatric = $('#nrmatric', '#frmCadmat');
    cNrdConta = $('#nrdconta', '#frmCadmat');
    cDtAdmiss = $('#dtadmiss', '#frmCadmat');
    cDtDemiss = $('#dtdemiss', '#frmCadmat');
    cDsTipsai = $('#dstipsai', '#frmCadmat');
    cDsInctva = $('#dsinctva', '#frmCadmat');
    cCdMotdem = $('#cdmotdem', '#frmCadmat');
    cDsMotdem = $('#dsmotdem', '#frmCadmat');

    cTodosFrmCadmat.desabilitaCampo();
    cNmprimtl.addClass('alphanum').css('width', '358px').attr('maxlength', '50');
    cCdagenci.addClass('inteiro').css('width', '40px');
    cNmresage.addClass('alphanum').css('width', '193px');
	cCdempres.addClass('inteiro').css('width', '40px');
    cNmresemp.addClass('alphanum').css('width', '180px');
    cNrMatric.addClass('inteiro').css('width', '100px');
    cNrdConta.addClass('conta').css('width', '100px');
    cDtAdmiss.addClass('data').css('width', '100px');
    cDtDemiss.addClass('data').css('width', '100px');
    cDsTipsai.addClass('alphanum').css('width', '321px');
    cDsInctva.addClass('alphanum').css('width', '180px');
    cCdMotdem.addClass('inteiro').css('width', '30px');
    cDsMotdem.addClass('alphanum').css('width', '288px');

	if ($("input[name='inpessoa']:checked").val() == 1){
		cNrcpfcgc.removeClass('cnpj').addClass('cpf').css('width', '135px');
		rCdempres.show();
		cCdempres.show();
		cNmresemp.show();
		$('a:eq(1)', '#frmCadmat').show();
	}else{
		cNrcpfcgc.removeClass('cpf').addClass('cnpj').css('width', '135px');
		rCdempres.hide();
		cCdempres.hide();
		cNmresemp.hide();
		$('a:eq(1)', '#frmCadmat').hide();
	}
	
	layoutPadrao();
	
	return false;
}

function controlaPesquisas() {

	// Definindo as vari�veis
    var bo = 'b1wgen0059.p';
    var procedure = '';
    var titulo = '';
    var qtReg = '';
    var filtrosPesq = '';
    var filtrosDesc = '';
    var colunas = '';

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
    $('a:eq(1)', '#frmCab').css('cursor', 'pointer').unbind('click').bind('click', function () {
		if (cNrdconta.hasClass('campoTelaSemBorda')) return false;
		mostraPesquisaAssociado('nrdconta','frmCab');
		return false;
     });	

	/*----------------*/
	/*  CONTROLE PA   */
	/*----------------*/
    var linkPAC = $('a:eq(0)', '#frmCadmat');
    if (linkPAC.prev().hasClass('campoTelaSemBorda')) {
        linkPAC.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkPAC.css('cursor', 'pointer').unbind('click').bind('click', function () {
            procedure = 'busca_pac';
            titulo = 'Ag&ecircncia PA';
            qtReg = '20';
            filtrosPesq = 'C&oacuted. PA;cdagenci;30px;S;0;;codigo;|Ag&ecircncia PA;nmresage;200px;S;;;descricao;';
            colunas = 'C&oacutedigo;cdagepac;20%;right|Descri&ccedil&atildeo;dsagepac;80%;left';
            mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas);
			return false;
		});

        linkPAC.prev().unbind('blur').bind('blur', function () {
            procedure = 'busca_pac';
            titulo = 'Agência PA';
			filtrosDesc = '';
            buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'nmresage', $(this).val(), 'dsagepac', filtrosDesc, 'frmCadmat');
			return false;
		});

        linkPAC.prev().unbind('keypress').bind('keypress', function (e) {
			if (e.keyCode == 13) {
                $("#nrmatric", "#frmCadmat").focus();
			}
		});

	}
	
	/*-------------------------------*/
	/*        CONTROLE EMPRESA       */
	/*-------------------------------*/	
    var linkEmp = $('a:eq(1)', '#frmCadmat');
    if (linkEmp.prev().hasClass('campoTelaSemBorda')) {
        linkEmp.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkEmp.css('cursor', 'pointer').unbind('click').bind('click', function () {
            procedure = 'busca_empresa';
            titulo = 'Empresa';
            qtReg = '30';
            filtrosPesq = 'Cód. Empresa;cdempres;30px;S;0;;codigo|Empresa;nmresemp;200px;S;;;descricao';
            colunas = 'Código;cdempres;20%;right|Empresa;nmresemp;80%;left';
            mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas);
			return false;	
		});
        linkEmp.prev().unbind('change').bind('change', function () {
            procedure = 'busca_empresa';
            titulo = 'Empresa';
			filtrosDesc = '';
            buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'nmresemp', $(this).val(), 'nmresemp', filtrosDesc, 'frmCadmat');
			return false;
		});
        linkEmp.prev().unbind('blur').bind('blur', function () {
            $(this).unbind('change').bind('change', function () {
                procedure = 'busca_empresa';
                titulo = 'Empresa';
				filtrosDesc = '';
                buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'nmresemp', $(this).val(), 'nmresemp', filtrosDesc, 'frmCadmat');
				return false;
			});
		});
	}
	
}

function imprime() {

    $('#sidlogin', '#frmCab').remove();

    $('#frmCab').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');

    $('#nrdconta', '#frmCab').val(nrdconta);

	nrdconta = normalizaNumero($('#nrdconta', '#frmCab').val());
	
    var action = UrlSite + 'telas/cadmat/imp_relatorio.php?nrdconta=' + nrdconta;
    var callback = (cddopcao == 'I') ? 'efetuarConsultas();' : '';

    carregaImpressaoAyllos("frmCab", action, callback);

}

function limpaCharEsp(texto) {
    var chars = ["=", "%", "&", "#", "+", "?", "'", ",", ".", "/", ";", "[", "]", "!", "@", "$", "(", ")", "*", "|", ":", "<", ">", "~", "{", "~", "}", "~", "  "];
    for (var x = 0; x < chars.length; x++) {
        while (texto.indexOf(chars[x]) > 0) {
			texto = texto.replace(chars[x], ' ');
		}
	}
	return texto;
}


// Somente para nao dar erro quando fechada alguma rotina
function btnVoltar() {
	// Exibir mensagem de confirmação
	if (cddopcao == 'I' || cddopcao == 'D' && $('#frmCadmat').css('display') != 'none'){
		showConfirmacao('Deseja cancelar a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Cadmat', 'estadoInicial()', '', 'sim.gif', 'nao.gif');
	}else{
		estadoInicial();	
	}
	return false;
}

function trocaBotoes(){
	
	$('#btProsseguir', '#divBotoes').unbind("click").bind("click", function () {
		btnContinuar();							
	});
	
	// Mostrar botões
	if ($('#divBotoes', '#divTela').css('display') == 'none'){
		$('#divBotoes', '#divTela').css({'display':'block'});
		$('#btVoltar','#divBotoes').show();
		$('#btDemiss','#divBotoes').hide();
		$('#btTermDemiss','#divBotoes').hide();
		$('#btGerarTed','#divBotoes').hide();
		$('#btSaqParcial','#divBotoes').hide();
		$('#btProsseguir','#divBotoes').show();
	}else{
		$('#btVoltar','#divBotoes').show();
		if (cddopcao == 'C'){
			$('#btProsseguir','#divBotoes').hide();
			$('#btDemiss','#divBotoes').show();
			$('#btTermDemiss','#divBotoes').show();
			$('#btGerarTed','#divBotoes').show();
			$('#btSaqParcial','#divBotoes').show();
		}else{
			$('#btProsseguir','#divBotoes').show();
		}

	}
}

function prosseguirInicio(){
	cCddopcao.desabilitaCampo();		
	controlaPesquisas();
	trocaBotoes();
	return false;
}

function btnContinuar(){

	if (!cCddopcao.hasClass('campoTelaSemBorda')){
		prosseguirInicio();
		if (cddopcao == 'I'){
			consultaPreInclusao();
		}else{
			$("input[name='inpessoa']").desabilitaCampo();
			// Se vier do CRM não permite alterar número da conta
			if (crm_inacesso != 1){
				cNrdconta.habilitaCampo();
				cNrdconta.focus();
			}else{
				btnContinuar();
			}
		}
	}else if (cddopcao == 'C'){
		buscaDados();
	}else if (cddopcao == 'I' ){
		validaInclusao();
	}else if (cddopcao == 'R' ){
		verificaRelatorio()
	}else if (cddopcao == 'D' ){
		if ($('#frmCadmat').css('display') == 'none'){
			buscaDados();
		}else{
			validaDesvincula();
		}
	}
}

function buscaDados(){

	showMsgAguardo('Aguarde, buscando dados do cooperado ...');
		
	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadmat/busca_dados_conta.php', 
		data: {
			cddopcao: cddopcao,
			nrdconta: normalizaNumero(nrdconta),	
			redirect: 'script_ajax'           
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();           
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		}
	});
	
}

function consultaPreInclusao(){
	
	showMsgAguardo('Aguarde, consultando dados ...');
	
	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadmat/consulta_pre_inclusao.php', 
		data: {
			nrcpfcgc: nrcpfcgc,	
			redirect: 'script_ajax'           
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();           
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
			habilitaInclusao();
		}
	});
	
}

function habilitaInclusao(){
	
	// Capturar natureza da pessoa a ser incluida
	inpessoa = $("input[name='inpessoa']:checked").val();
	$("input[name='inpessoa']").desabilitaCampo();
	
	// Formata formulário
	formataTitular();
	// Troca botões do form
	trocaBotoes();
	// Controla foco do formulário
	controlaFocoForm()
	
	// Controla campos habilitados
	cTodosFrmCadmat.desabilitaCampo();
	cCdagenci.habilitaCampo();
	if (inpessoa == 1){
		cCdempres.habilitaCampo();
	}
	cCdagenci.focus();
}

function mostraFormSenha(operacao){

	showMsgAguardo('Aguarde ...');

	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadmat/senha.php', 
		data: {
			operacao: operacao,	
			redirect: 'html_ajax'           
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();           
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divRotina').html(response);
					exibeRotina($('#divRotina'));
					hideMsgAguardo();
					formataSenha();
					return false;
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			} else {
				try {
                    eval(response);
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}			
		}
	});
	
}

function formataSenha() {

	highlightObjFocus($('#frmSenha'));

    rOperador = $('label[for="operauto"]', '#frmSenha');
    rSenha = $('label[for="codsenha"]', '#frmSenha');
	
    rOperador.addClass('rotulo').css({ 'width': '165px' });
    rSenha.addClass('rotulo').css({ 'width': '165px' });

    cOperador = $('#operauto', '#frmSenha');
    cSenha = $('#codsenha', '#frmSenha');
	
    cOperador.addClass('campo').css({ 'width': '100px' }).attr('maxlength', '10');
    cSenha.addClass('campo').css({ 'width': '100px' }).attr('maxlength', '30');
	
    $('#divConteudoSenha').css({ 'width': '400px', 'height': '120px' });

	// centraliza a divRotina
    $('#divRotina').css({ 'width': '425px' });
    $('#divConteudo').css({ 'width': '400px' });
	$('#divRotina').centralizaRotinaH();
	
    bloqueiaFundo($('#divRotina'));
	cOperador.focus();

	cOperador.unbind('keydown').bind('keydown', function (e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER, 
		if (e.keyCode == 9 || e.keyCode == 13) {
			cSenha.focus();
			return false;			
		} 
	});
	
	cSenha.unbind('keydown').bind('keydown', function (e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER, 
		if (e.keyCode == 9 || e.keyCode == 13) {
			$('#btOk', '#divBotoes2').click();
			return false;			
		} 
	});
	
	return false;
}

function validarSenha(operacao) {
	
	// Pega valores informados
    var operauto = $('#operauto', '#frmSenha').val();
    var codsenha = $('#codsenha', '#frmSenha').val();
	
    showMsgAguardo('Aguarde, validando dados ...');

	$.ajax({		
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/cadmat/valida_senha.php',
			data: {
            operauto: operauto,
            codsenha: codsenha,
            cddopcao: cddopcao,
            redirect: 'script_ajax'
			}, 
        error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
			},
        success: function (response) {
				try {
					eval(response);
					// se não ocorreu erro, vamos gravar as alterações
					if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
						if (operacao == 'DCC') {
							hideMsgAguardo();
							selecionaConta(nrdconta_org);
						} else if (operacao == 'LCC') {
							buscaContas();
						}
					}
				return false;
            } catch (error) {
					hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
				}
			}
		});	
		
	return false;
}

function selecionaConta(nrdconta){
	
    showMsgAguardo('Aguarde, gerando a C/C ...');
	
	// Atribui conta selecionada a conta de origem
	nrdconta_org = normalizaNumero(nrdconta);	
	
	$.ajax({		
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/cadmat/gera_conta_corrente.php',
			data: {
            redirect: 'script_ajax'
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
		},
        success: function (response) {
			try {
				eval(response);
				return false;
            } catch (error) {
				hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
				}
			}
		});	
		
	return false;	
	
}

function duplicaContaCorrente(nrctanov){
	
	showMsgAguardo('Aguarde, duplicando a C/C ...');

	// Remove formato das contas de origem e destino
	nrdconta_org = normalizaNumero(nrdconta_org);
	var nrdconta_dst = normalizaNumero(nrctanov);
	
	// Atualiza nr. da conta global
	nrdconta = nrdconta_dst;
	
	$.ajax({		
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/cadmat/duplica_conta_corrente.php',
			data: {
			nrdconta_org: nrdconta_org,
			nrdconta_dst: nrdconta_dst,
            redirect: 'script_ajax'
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
		},
        success: function (response) {
			try {
				eval(response);
				return false;
            } catch (error) {
				hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
				}
			}
		});	
		
	return false;	
	
}

function verificaRelatorio() {
	
    showMsgAguardo('Aguarde, verificando relat&oacute;rio ...');
	nrdconta = normalizaNumero(nrdconta);
	
	$.ajax({		
        type: 'POST',
		dataType: 'html',
        url: UrlSite + 'telas/cadmat/verifica_relatorio.php',
        data:
		{ 
			nrdconta: nrdconta,	
			cddopcao: cddopcao,
			redirect: 'script_ajax' 
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Matric', '$(\'#nrdconta\',\'#frmCabMatric\').focus()');
		},
        success: function (response) {
			hideMsgAguardo();
							
            if (response.indexOf('showError("error"') == -1) {
						
				// Se esta incluindo, efetuar consultas
                var metodo = (cddopcao == 'I') ? 'efetuarConsultas();' : '';

                showConfirmacao("Deseja visualizar a impress&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "imprime();", metodo, "sim.gif", "nao.gif");
			} else {
				try {
					eval(response);
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}
		}
	}); 

	return false;
}

function efetuarConsultas(){
	
	showMsgAguardo('Aguarde, efetuando consultas ...');
				
	$.ajax({
        type: 'POST',
        url: UrlSite + 'includes/consultas_automatizadas/efetuar_consultas.php',
        data: {
            nrdconta: nrdconta,
            nrdocmto: 0,
            inprodut: 6, // Inclusao de conta
            insolici: 1,
			nmdatela: 'CADMAT',
            redirect: 'script_ajax'
		  },
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
		},
        success: function (response) {
			hideMsgAguardo();
			eval(response);
			return false;
		}
	});
	return false;
	
}

function buscaContas() {

	hideMsgAguardo();		
	showMsgAguardo('Aguarde, listando as C/C ...');

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadmat/lista_contas.php', 
		data: {
			lscontas: lscontas,
			redirect: 'script_ajax'	
			}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
		},
        success: function (response) {
		
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divRotina').html(response);
					exibeRotina($('#divRotina'));
					formataContas();
					return false;
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			} else {
				try {
                    eval(response);
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}
		}				
	});
	
	return false;
}

function formataContas() {
	
	var divRegistro = $('div.divRegistros');		
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);
	
    $('#divContas').css({ 'width': '300px', 'height': '190px' });
	
    divRegistro.css({ 'height': '110px', 'padding-bottom': '2px' });
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '100px';
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
		
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

	hideMsgAguardo();	
	
    bloqueiaFundo($('#divRotina'));
	
}

function validaDesvincula(){
	
    showMsgAguardo('Aguarde, validando desvincula&ccedil;&atilde;o ...');
	
	nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#frmCadmat').val());
	inpessoa = $("input[name='inpessoa']:checked").val();
	var nmprimtl = normalizaTexto($('#nmprimtl', '#frmCadmat').val());
	var rowidass = $('#rowidass', '#frmCadmat').val();

	$.ajax({		
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/cadmat/valida_desvincula_conta.php',
			data: {
			nrdconta: nrdconta,
			inpessoa: inpessoa,
			rowidass: rowidass,
			nmprimtl: nmprimtl,
			nrcpfcgc: nrcpfcgc,
            redirect: 'script_ajax'
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
		},
        success: function (response) {
			try {
				hideMsgAguardo();
				eval(response);
				return false;
            } catch (error) {
				hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
				}
			}
		});	
		
	return false;	
	
}

function desvinculaConta(){
	
    showMsgAguardo('Aguarde, desvinculando ...');
	
	nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#frmCadmat').val());
	inpessoa = $("input[name='inpessoa']:checked").val();
	var nmprimtl = normalizaTexto($('#nmprimtl', '#frmCadmat').val());
	var rowidass = $('#rowidass', '#frmCadmat').val();

	$.ajax({		
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/cadmat/desvincula_conta.php',
			data: {
			nrdconta: nrdconta,
			inpessoa: inpessoa,
			rowidass: rowidass,
			nmprimtl: nmprimtl,
			nrcpfcgc: nrcpfcgc,
            redirect: 'script_ajax'
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
		},
        success: function (response) {
			try {
				eval(response);
				return false;
            } catch (error) {
				hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
				}
			}
		});	
		
	return false;	
}

function validaInclusao(){
	
	showMsgAguardo('Aguarde, validando inclus&atilde;o ...');
	
	// Captura valores dos campos
	nrcpfcgc     = $('#nrcpfcgc', '#frmCadmat').val();	
	nrdconta     = $('#nrdconta', '#frmCadmat').val();	
	inpessoa     = $("input[name='inpessoa']:checked").val();
	var nmprimtl = $('#nmprimtl', '#frmCadmat').val();
	var cdagenci = $('#cdagenci', '#frmCadmat').val();
	var cdempres = $('#cdempres', '#frmCadmat').val();
	var tpdocptl = $('#tpdocptl', '#frmCadmat').val();
	var nrdocptl = $('#nrdocptl', '#frmCadmat').val();
	var cdsitcpf = $('#cdsitcpf', '#frmCadmat').val();
	var dtcnscpf = $('#dtcnscpf', '#frmCadmat').val();
	var inhabmen = $('#inhabmen', '#frmCadmat').val();
	var dthabmen = $('#dthabmen', '#frmCadmat').val();
	var cdestcvl = $('#cdestcvl', '#frmCadmat').val();
	var tpnacion = $('#tpnacion', '#frmCadmat').val();
	var cdnacion = $('#cdnacion', '#frmCadmat').val();
	var dsnacion = $('#dsnacion', '#frmCadmat').val();
	var cdoedptl = $('#cdoedptl', '#frmCadmat').val();
	var cdufdptl = $('#cdufdptl', '#frmCadmat').val();
	var dtemdptl = $('#dtemdptl', '#frmCadmat').val();
	var dtnasctl = $('#dtnasctl', '#frmCadmat').val();
	var nmconjug = $('#nmconjug', '#frmCadmat').val();
	var nmmaettl = $('#nmmaettl', '#frmCadmat').val();
	var nmpaittl = $('#nmpaittl', '#frmCadmat').val();
	var dsnatura = $('#dsnatura', '#frmCadmat').val();
	var cdufnatu = $('#cdufnatu', '#frmCadmat').val();
	var nrcepend = $('#nrcepend', '#frmCadmat').val();
	var dsendere = $('#dsendere', '#frmCadmat').val();
	var nrendere = $('#nrendere', '#frmCadmat').val();
	var complend = $('#complend', '#frmCadmat').val();
	var nmbairro = $('#nmbairro', '#frmCadmat').val();
	var cdufende = $('#cdufende', '#frmCadmat').val();
	var nmcidade = $('#nmcidade', '#frmCadmat').val();
	var cdocpttl = $('#cdocpttl', '#frmCadmat').val();
	var nrcadast = $('#nrcadast', '#frmCadmat').val();
	var cdsexotl = $('#cdsexotl', '#frmCadmat').val();
	var nmfansia = $('#nmfansia', '#frmCadmat').val();
	var nrdddtfc = $('#nrdddtfc', '#frmCadmat').val();
	var nrtelefo = $('#nrtelefo', '#frmCadmat').val();
	var nrinsest = $('#nrinsest', '#frmCadmat').val();
	var natjurid = $('#natjurid', '#frmCadmat').val();
	var cdseteco = $('#cdseteco', '#frmCadmat').val();
	var cdrmativ = $('#cdrmativ', '#frmCadmat').val();
	var dtiniatv = $('#dtiniatv', '#frmCadmat').val();
	var verrespo = false;	// Variável que indica se deve ou não validar o resp. legal
	var permalte = true;	//
	
	$.ajax({		
			type: 'POST',
			url: UrlSite + 'telas/cadmat/valida_inclusao.php', 		
			data: {
				nrcpfcgc : normalizaNumero(nrcpfcgc),
				nrdconta : normalizaNumero(nrdconta),
				inpessoa : normalizaNumero(inpessoa),
				nmprimtl : normalizaTexto(nmprimtl),
				cdagepac : normalizaNumero(cdagenci),
				cdempres : normalizaNumero(cdempres),
				tpdocptl : tpdocptl,
				nrdocptl : normalizaTexto(nrdocptl),
				cdsitcpf : cdsitcpf,
				dtcnscpf : dtcnscpf,
				inhabmen : normalizaNumero(inhabmen),
				dthabmen : dthabmen,
				cdestcvl : normalizaNumero(cdestcvl),
				tpnacion : tpnacion,
				cdnacion : normalizaNumero(cdnacion),
				cdoedptl : normalizaTexto(cdoedptl),
				cdufdptl : cdufdptl,
				dtemdptl : dtemdptl,
				dtnasctl : dtnasctl,
				nmconjug : normalizaTexto(nmconjug),
				nmmaettl : normalizaTexto(nmmaettl),
				nmpaittl : normalizaTexto(nmpaittl),
				dsnatura : dsnatura,
				cdufnatu : cdufnatu,
				nrcepend : normalizaNumero(nrcepend),
				dsendere : dsendere,
				nrendere : normalizaNumero(nrendere),
				complend : complend,
				nmbairro : normalizaTexto(nmbairro),
				cdufende : cdufende,
				nmcidade : normalizaTexto(nmcidade),
				cdocpttl : cdocpttl,
				nrcadast : normalizaNumero(nrcadast),
				cdsexotl : cdsexotl,
				nmfansia : normalizaTexto(nmfansia),
				nrdddtfc : nrdddtfc,
				nrtelefo : normalizaNumero(nrtelefo),
				nrinsest : normalizaNumero(nrinsest),
				natjurid : natjurid,
				cdseteco : cdseteco,
				cdrmativ : cdrmativ,
				dtiniatv : dtiniatv,
				verrespo : verrespo,
				permalte : permalte,
				redirect: 'script_ajax'
			}, 
            error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				
			},
            success: function (response) {
				try {
					eval(response);
					return false;
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}				
		});	
}

function incluirConta(){
	
	hideMsgAguardo();
	showMsgAguardo('Aguarde, efetuando inclus&atilde;o ...');

	// Captura valores dos campos
	nrcpfcgc     = $('#nrcpfcgc', '#frmCadmat').val();
	nrdconta     = $('#nrdconta', '#frmCadmat').val();
	inpessoa     = $("input[name='inpessoa']:checked").val();
	var nmprimtl = $('#nmprimtl', '#frmCadmat').val();
	var cdagenci = $('#cdagenci', '#frmCadmat').val();
	var cdempres = $('#cdempres', '#frmCadmat').val();
	var inmatric = $('#inmatric', '#frmCadmat').val();
	var tpdocptl = $('#tpdocptl', '#frmCadmat').val();
	var nrdocptl = $('#nrdocptl', '#frmCadmat').val();
	var nmttlrfb = $('#nmttlrfb', '#frmCadmat').val();
	var cdsitcpf = $('#cdsitcpf', '#frmCadmat').val();
	var dtcnscpf = $('#dtcnscpf', '#frmCadmat').val();
	var dsdemail = $('#dsdemail', '#frmCadmat').val();
	var dsnacion = $('#dsnacion', '#frmCadmat').val();
	var inhabmen = $('#inhabmen', '#frmCadmat').val();
	var dthabmen = $('#dthabmen', '#frmCadmat').val();
	var cdestcvl = $('#cdestcvl', '#frmCadmat').val();
	var tpnacion = $('#tpnacion', '#frmCadmat').val();
	var cdnacion = $('#cdnacion', '#frmCadmat').val();
	var cdoedptl = $('#cdoedptl', '#frmCadmat').val();
	var cdufdptl = $('#cdufdptl', '#frmCadmat').val();
	var dtemdptl = $('#dtemdptl', '#frmCadmat').val();
	var dtnasctl = $('#dtnasctl', '#frmCadmat').val();
	var nmconjug = $('#nmconjug', '#frmCadmat').val();
	var nmmaettl = $('#nmmaettl', '#frmCadmat').val();
	var nmpaittl = $('#nmpaittl', '#frmCadmat').val();
	var dsnatura = $('#dsnatura', '#frmCadmat').val();
	var cdufnatu = $('#cdufnatu', '#frmCadmat').val();
	var nrdddres = $('#nrdddres', '#frmCadmat').val();
	var nrtelres = $('#nrtelres', '#frmCadmat').val();
	var cdopetfn = $('#cdopetfn', '#frmCadmat').val();
	var nrdddcel = $('#nrdddcel', '#frmCadmat').val();
	var nrtelcel = $('#nrtelcel', '#frmCadmat').val();
	var nrcepend = $('#nrcepend', '#frmCadmat').val();
	var dsendere = $('#dsendere', '#frmCadmat').val();
	var nrendere = $('#nrendere', '#frmCadmat').val();
	var complend = $('#complend', '#frmCadmat').val();
	var nmbairro = $('#nmbairro', '#frmCadmat').val();
	var cdufende = $('#cdufende', '#frmCadmat').val();
	var nmcidade = $('#nmcidade', '#frmCadmat').val();
	var idorigee = $('#idorigee', '#frmCadmat').val();
	var cdocpttl = $('#cdocpttl', '#frmCadmat').val();
	var nrcadast = $('#nrcadast', '#frmCadmat').val();
	var cdsexotl = $('#cdsexotl', '#frmCadmat').val();
	var idorgexp = $('#idorgexp', '#frmCadmat').val();
	var nmfansia = $('#nmfansia', '#frmCadmat').val();
	var nrdddtfc = $('#nrdddtfc', '#frmCadmat').val();
	var nrtelefo = $('#nrtelefo', '#frmCadmat').val();
	var nrinsest = $('#nrinsest', '#frmCadmat').val();
	var nrlicamb = $('#nrlicamb', '#frmCadmat').val();
	var natjurid = $('#natjurid', '#frmCadmat').val();
	var cdseteco = $('#cdseteco', '#frmCadmat').val();
	var cdrmativ = $('#cdrmativ', '#frmCadmat').val();
	var cdcnae   = $('#cdcnae  ', '#frmCadmat').val();
	var dtiniatv = $('#dtiniatv', '#frmCadmat').val();

	//Normalilza os campos de valor
	vlparcel = number_format(parseFloat(vlparcel.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
	
	$.ajax({		
			type: 'POST',
			url: UrlSite + 'telas/cadmat/incluir_conta.php', 		
			data: {
				nrcpfcgc : normalizaNumero(nrcpfcgc),    
				nrdconta : normalizaNumero(nrdconta),    
				inpessoa : inpessoa,    
				nmprimtl : normalizaTexto(nmprimtl),
				cdagepac : cdagenci,
				cdempres : cdempres,
				inmatric : inmatric,
				tpdocptl : tpdocptl,
				nrdocptl : normalizaTexto(nrdocptl),
				nmttlrfb : normalizaTexto(nmttlrfb),
				cdsitcpf : cdsitcpf,
				dtcnscpf : dtcnscpf,
				dsdemail : dsdemail,
				dsnacion : dsnacion,
				inhabmen : inhabmen,
				dthabmen : dthabmen,
				cdestcvl : cdestcvl,
				tpnacion : tpnacion,
				cdnacion : cdnacion,
				cdoedptl : normalizaTexto(cdoedptl),
				cdufdptl : cdufdptl,
				dtemdptl : dtemdptl,
				dtnasctl : dtnasctl,
				nmconjug : normalizaTexto(nmconjug),
				nmmaettl : normalizaTexto(nmmaettl),
				nmpaittl : normalizaTexto(nmpaittl),
				dsnatura : dsnatura,
				cdufnatu : cdufnatu,
				nrdddres : nrdddres,
				nrtelres : nrtelres,
				cdopetfn : cdopetfn,
				nrdddcel : nrdddcel,
				nrtelcel : nrtelcel,
				nrcepend : normalizaNumero(nrcepend),
				dsendere : dsendere,
				nrendere : normalizaNumero(nrendere),
				complend : complend,
				nmbairro : normalizaTexto(nmbairro),
				cdufende : cdufende,
				nmcidade : normalizaTexto(nmcidade),
				idorigee : idorigee,
				cdocpttl : cdocpttl,
				nrcadast : normalizaNumero(nrcadast),
				cdsexotl : cdsexotl,
				idorgexp : idorgexp,
				nmfansia : nmfansia,
				nrdddtfc : nrdddtfc,
				nrtelefo : nrtelefo,
				nrinsest : nrinsest,
				nrlicamb : nrlicamb,
				natjurid : natjurid,
				cdseteco : cdseteco,
				cdrmativ : cdrmativ,
				cdcnae   : cdcnae,
				dtiniatv : dtiniatv,
				dtdebito : dtdebito,
				qtparcel : qtparcel,
				vlparcel : vlparcel,
				hrinicad : hrinicad,
				redirect: 'script_ajax'
			}, 
            error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				
			},
            success: function (response) {
				try {
					eval(response);
					return false;
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}				
		});	
}

function exibirMsgInclusao(strAlerta, msgRetorno, qtparcel, vlparcel) {
	
    if (strAlerta != '') {
		// Definindo as variáveis
				
        var arrayMensagens = new Array();
        var novoArray = new Array();
        var elementoAtual = '';
		// Setando os valores
        arrayMensagens = strAlerta.split('|');
		
        elementoAtual = arrayMensagens.splice(0, 1);
        arrayMensagens = implode('|', arrayMensagens);
		// Exibindo mensagem de erro
        showError('inform', elementoAtual, 'Alerta - Ayllos', "exibirMsgInclusao('" + arrayMensagens + "','" + msgRetorno + "','" + qtparcel + "','" + vlparcel + "')");
	} else {
        qtparcel = (typeof qtparcel == 'undefined') ? 0 : qtparcel;
        if (qtparcel > 0) {
            exibeParcelamento(qtparcel, vlparcel, msgRetorno);
        } else if (msgRetorno != '') {
            var op = operacao.substr(0, 1);
            showConfirmacao(msgRetorno, 'Confirma&ccedil;&atilde;o - CADMAT', 'controlaOperacao(\'V' + op + '\');', 'unblockBackground();', 'sim.gif', 'nao.gif');
		}
	}
	return false;
}

//---------------------------------------------------------
//  FUNÇÕES PARA O PARCELAMENTO
//---------------------------------------------------------

function exibeParcelamento(qtparcel, vlparcel, msgRetor) {
	
    showMsgAguardo('Aguarde, abrindo parcelamento ...');
	
    $.getScript(UrlSite + 'telas/cadmat/parcelamento/parcelamento.js', function () {
		$.ajax({		
            type: 'POST',
			dataType: 'html',
            url: UrlSite + 'telas/cadmat/parcelamento/parcelamento.php',
            data: {
				qtparcel: qtparcel,
				vlparcel: vlparcel,
				msgRetor: msgRetor,
				redirect: 'html_ajax'
			},		
            error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
                showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
			},
            success: function (response) {
                if (response.indexOf('showError("error"') == -1) {
					$('#divUsoGenerico').html(response);
					hideMsgAguardo();
                    bloqueiaFundo($('#divUsoGenerico'));
				} else {
					try {
						hideMsgAguardo();
                        eval(response);
						controlaFoco();
                    } catch (error) {
						hideMsgAguardo();
                        showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
							}
						}
						return false;
					}				 
		});	
	});
}

function abrirProcuradores() {
		
    $('#btProsseguir', '#divBotoes').unbind("click").bind("click", function () {
		verificaRelatorio();							
	});
	
    abrirRotina('PROCURADORES', 'Representante/Procurador', 'procuradores', 'procuradores', 'CI');
}

// Função para acessar rotina 
function abrirRotina(nomeValidar, nomeTitulo, nomeScript, nomeURL, ope) {
						
	operacao = ope;
    inpessoa = $('input[name="inpessoa"]:checked', '#frmCab').val();
    nomeForm = 'frmCadmat';
	permalte = true;
    dtnasctl = $('#dtnasctl', '#frmCadmat').val();
    cdhabmen = $('#inhabmen', '#frmCadmat').val();
	nmrotina = 'MATRIC';		
    nrcpfcgc = $('#nrcpfcgc', '#' + nomeForm).val();
    nrdconta = normalizaNumero($("#nrdconta", "#frmCab").val());
	
	
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde, carregando  " + nomeTitulo + " ...");
	
	if (ope == 'RFB' || ope == 'TED_CAPITAL') {
		var url = UrlSite + "includes/" + nomeScript + "/" + nomeURL;
	} else {
		var url = UrlSite + "telas/contas/" + nomeScript + "/" + nomeURL;
	}
	
	var urlScript = UrlSite + "includes/" + nomeURL + "/" + nomeURL;
	
	// Carrega biblioteca javascript da rotina
	// Ao carregar efetua chamada do conteúdo da rotina através de ajax
    $.getScript(urlScript + ".js?keyrand="+Math.floor((Math.random() * 1000) + 1), function () {
																		
		operacao_rsp = operacao;
	
        //console.log(url);

		$.ajax({
			type: "POST",
			dataType: "html",
            url: url + ".php?keyrand="+Math.floor((Math.random() * 1000) + 1),
			data: {
				nrdconta: nrdconta,
				idseqttl: 1,
				nmdatela: "MATRIC",
				inpessoa: inpessoa,
				dtnasctl: dtnasctl,
				nrcpfcgc: nrcpfcgc,
				nmrotina: nomeValidar,
				redirect: "html_ajax" // Tipo de retorno do ajax
			},
            error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "");
			},
            success: function (response) {
				
				$("#divRotina").html(response);
                $('.fecharRotina').click(function () {
					fechaRotina(divRotina);
					return false;
				});
				
			}				 
		}); 
	});
}

/* Apenas para satisfazer rotina de procuradores */
function impressao_inclusao(){
	verificaRelatorio();
}

function consultaPosDesvinculacao(){
	cCddopcao.val('C');
	cddopcao = 'C';
	prosseguirInicio();
	cNrdconta.val(nrdconta);
	buscaDados();
}

function gerarTedCapital(){
	
	abrirRotina('TED_CAPITAL', 'Conta Destino Para Envio De TED Capital', 'contas_ted_capital', 'contas_ted_capital', 'TED_CAPITAL'); 
	return false;
	
}

function verificarDesligamento(){
	
	showConfirmacao('Atrav&eacute;s da tela CONTAS, na op&ccedil;&atilde;o Impedimentos de Desligamento, todos os produtos e servi&ccedil;os foram cancelados?','Confirma&ccedil;&atilde;o - Ayllos','apresentarDesligamento();','fechaRotina($(\'#divRotina\'));','sim.gif','nao.gif');
	
	return false;	
}

// Função para acessar rotina de Saque Parcial 
function apresentarDesligamento() {			
	
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde, carregando ...");
	
    // Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadmat/apresentar_desligamento.php', 
		data: {			
			nrdconta: normalizaNumero(nrdconta),
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			exibeRotina($('#divRotina'));
			hideMsgAguardo();
			bloqueiaFundo($('#divRotina'));
			formataDesligamento();
		}				
	});
	
  return false;
 	
}

function formataDesligamento(){

	//Campos do frmDesligamento
	cVldcotas = $('#vldcotas','#frmDesligamento');
	cNrdconta = $('#nrdconta','#frmDesligamento');
	cQtdparce = $('#qtdparce','#frmDesligamento');
	cDatadevo = $('#datadevo','#frmDesligamento');	

	cVldcotas.css('width','130px').addClass('moeda').desabilitaCampo();
	cNrdconta.css('width','130px').addClass('conta campoTelaSemBorda').desabilitaCampo();
	cQtdparce.css('width','130px').css('display','none').addClass('campo');
	cDatadevo.css('width','130px').addClass('data campo');

	layoutPadrao();

}

function confirmarDesligamento(cdmotdem, dsmotdem){
	showConfirmacao('A conta está na situa&ccedil;&atilde;o '+ cdmotdem +' - '+ dsmotdem +'. Deseja Prosseguir?','Confirma&ccedil;&atilde;o - Ayllos','efetuarDevolucaoCotas();','fechaRotina($(\'#divRotina\'));','sim.gif','nao.gif');return false;
}

function efetuarDevolucaoCotas() {
	
	var vldcotas = isNaN(parseFloat($('#vldcotas', '#frmDesligamento').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vldcotas', '#frmDesligamento').val().replace(/\./g, "").replace(/\,/g, "."));
	var formadev = $('input[name="formadev"]:checked', '#frmDesligamento').val();
	var qtdparce = $('#qtdparce','#frmDesligamento').val() ? $('#qtdparce','#frmDesligamento').val() : 0;
	var datadevo = $('#datadevo','#frmDesligamento').val();
	var mtdemiss = $('#cdmotdem','#frmCadmat').val();
	var dtdemiss = $('#dtdemiss','#frmCadmat').val();

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, efetuando devolução ...");
			
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadmat/efetuar_devolucao_cotas.php",
		data: {
			nrdconta: normalizaNumero(nrdconta),
			vldcotas: vldcotas,
			formadev: formadev,
			qtdparce: qtdparce,
			datadevo: datadevo,
			mtdemiss: mtdemiss,
			dtdemiss: dtdemiss,			
			redirect: "script_ajax"
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));$('#btVoltar','#divBotoesSaqueParcial').focus();");							
		},
        success: function (response) {
			hideMsgAguardo();				
			try {
				eval( response );						
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));$("#btVoltar","#divBotoesSaqueParcial").focus();');
			}
		}				
	});	
}
