/*!
 * FONTE        : grupo_economico.js
 * CRIAÇÃO      : Mauro (MOUTS)
 * DATA CRIAÇÃO : Agosto/2017
 * OBJETIVO     : Biblioteca de funções da rotina Grupo Economico da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
// Função para acessar opções da rotina
function buscaDadosGrupoEconomico() {  
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando os dados...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/contas/grupo_economico/principal.php",
		async: true,
		data: {
			nrdconta: nrdconta,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',bloqueiaFundo(divRotina));
		},
		success: function(response) {		
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
				carregaTelaConsultarIntegrantes();
			} else {
				eval( response );				
			}
			return false;
		}				
	});
}

function carregaTelaConsultarIntegrantes(){
	
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, buscando os integrantes...");
	
	var idgrupo     = $('#idgrupo', '#frmGrupoEconomico').val();
	var listarTodos = $('#listarTodos', '#frmGrupoEconomico').prop('checked');
	var nrdconta    = normalizaNumero($('#nrdconta', '#frmGrupoEconomico').val());
	
	// Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/contas/grupo_economico/carrega_integrantes_grupo_economico.php',
		async: true,
        data:{
			idgrupo:  idgrupo,
			listarTodos: listarTodos,
			nrdconta: nrdconta,
			redirect: "html_ajax"
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response){
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divIntegrantesGrupoEconomico').html(response);
				hideMsgAguardo();
				bloqueiaFundo(divRotina);
			} else {
				eval( response );				
			}
			return false;
        }
    });
    return false;
}

function abreTelaInclusaoIntegrante(){
	
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando a tela...");
    
	// Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/contas/grupo_economico/carrega_tela_incluir_integrantes.php',
		async: true,
        data:{
			idgrupo: $('#idgrupo','#frmGrupoEconomico').val()
		   ,redirect: "html_ajax"
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response){
			if ( response.indexOf('showError("error"') == -1 ) {
				exibeRotina($('#divUsoGenerico'));
				$('#divUsoGenerico').html(response);
				//layoutPadrao();
				hideMsgAguardo();
				bloqueiaFundo($('#divUsoGenerico'));
			} else {
				eval( response );				
			}
			return false;
        }
    });
    return false;
}

function abreTelaInclusaoGrupoEconomico(){
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando a tela...");
    
	// Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/contas/grupo_economico/carrega_tela_incluir_grupo_economico.php',
		async: true,
        data:{
			redirect: "html_ajax"
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response){
			if ( response.indexOf('showError("error"') == -1 ) {
				exibeRotina($('#divUsoGenerico'));
				$('#divUsoGenerico').html(response);
				//layoutPadrao();
				hideMsgAguardo();
				bloqueiaFundo($('#divUsoGenerico'));
			} else {
				eval( response );				
			}
			return false;
        }
    });
    return false;
}

function manterRotina(operacao,nomeFormulario) {

	hideMsgAguardo();
	showMsgAguardo('Aguarde...');
	
	var nmgrupo      = $('#nmgrupo', '#'+nomeFormulario).val();
	var dsobservacao = $('#dsobservacao', '#'+nomeFormulario).val();
	
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/grupo_economico/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, 
			nmgrupo:  nmgrupo,
			dsobservacao: dsobservacao,
			operacao: operacao, 
			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function (response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
				return;
			}
			hideMsgAguardo();
			bloqueiaFundo(divRotina);
		}				
	});
}

function solicitaExclusaoIntegrante(){
	showConfirmacao('Confirma a exclus&atilde;o do integrante?','Confirma&ccedil;&atilde;o - Ayllos','excluirIntegranteGrupoEconomico();','bloqueiaFundo(divRotina)','sim.gif','nao.gif');	
}

function excluirIntegranteGrupoEconomico(){
	
	var qtexclu      = 0;
	var idintegrante = 0;
    $("input[class='clsCheckbox']:checked").each(function () {
        idintegrante = $(this).attr('recid');
		qtexclu = qtexclu + 1;
	}); 
	
    if (qtexclu != 1) {
        showError("error","Selecione apenas um registro.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
    }
	
	hideMsgAguardo();
	showMsgAguardo('Aguarde, excluindo integrante...');
	
	$.ajax({
		type: 'POST',
		url: UrlSite + 'telas/contas/grupo_economico/manter_rotina.php', 		
		data: {
			idintegrante: idintegrante
		   ,idgrupo: $('#idgrupo','#frmGrupoEconomico').val()
		   ,operacao: 'ExcluirIntegrante'
		   ,redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function (response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
				return;
			}
			hideMsgAguardo();
			bloqueiaFundo(divRotina);
		}
	});		
}

function incluirIntegranteGrupoEconomico(){
	
	hideMsgAguardo();
	showMsgAguardo('Aguarde, incluindo integrante...');
	
	$.ajax({
		type: 'POST',
		url: UrlSite + 'telas/contas/grupo_economico/manter_rotina.php', 		
		data: {
			idgrupo: $('#idgrupo','#frmGrupoEconomico').val()
		   ,tppessoa: $('#tppessoa','#frmGrupoEconomicoIntegrantes').val()
		   ,nrcpfcgc: normalizaNumero($('#nrcpfcgc','#frmGrupoEconomicoIntegrantes').val())
		   ,nrdconta: normalizaNumero($('#nrdconta','#frmGrupoEconomicoIntegrantes').val())
		   ,nmprimtl: $('#nmprimtl','#frmGrupoEconomicoIntegrantes').val()
		   ,tpvinculo: $('#tpvinculo','#frmGrupoEconomicoIntegrantes').val()
		   ,peparticipacao: $('#peparticipacao','#frmGrupoEconomicoIntegrantes').val()
		   ,operacao: 'IncluirIntegrante'
		   ,redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function (response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
				return;
			}
			hideMsgAguardo();
			bloqueiaFundo(divRotina);
		}
	});	
}

function controlaLayoutInclusaoIntegrante(){
	
	var rTppessoa 	    	 = $('label[for="tppessoa"]', '#frmGrupoEconomicoIntegrantes');
	var rNrcpfcgc 	         = $('label[for="nrcpfcgc"]', '#frmGrupoEconomicoIntegrantes');
	var rNrdconta			 = $('label[for="nrdconta"]', '#frmGrupoEconomicoIntegrantes');
	var rNmintegrante   	 = $('label[for="nmprimtl"]', '#frmGrupoEconomicoIntegrantes');
	var rTpvinculo 	    	 = $('label[for="tpvinculo"]', '#frmGrupoEconomicoIntegrantes');
	var rPeparticipacao 	 = $('label[for="peparticipacao"]', '#frmGrupoEconomicoIntegrantes');
	
	rTppessoa.addClass('rotulo-linha').css({'width':'77px'});	
	rNrcpfcgc.addClass('rotulo').css({'width':'80px'});	
	rNrdconta.addClass('rotulo-linha').css({'width':'122px'});	
	rNmintegrante.addClass('rotulo').css({'width':'80px'});	
	rTpvinculo.addClass('rotulo').css({'width':'80px'});	
	rPeparticipacao.addClass('rotulo-linha').css({'width':'100px'});
	
	var cTppessoa       	 = $('#tppessoa', '#frmGrupoEconomicoIntegrantes');
	var cNrcpfcgc       	 = $('#nrcpfcgc', '#frmGrupoEconomicoIntegrantes');
	var cNrdconta 		     = $('#nrdconta', '#frmGrupoEconomicoIntegrantes');
	var cNmintegrante   	 = $('#nmprimtl', '#frmGrupoEconomicoIntegrantes');
	var cPeparticipacao 	 = $('#peparticipacao', '#frmGrupoEconomicoIntegrantes');
	
	cTppessoa.css('width','110px');
	cNrcpfcgc.css('width','110px');
	cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
	cNmintegrante.css('width','318px');
	cPeparticipacao.css('width','80px').attr('maxlength', '6');
		
	// Se pressionar cConsucpf
	cTppessoa.unbind('change').bind('change', function(e){
		cNrcpfcgc.val('');
		cNrdconta.val('');
		
		if (cTppessoa.val() == 1){
			cNrcpfcgc.setMask('INTEGER', '999.999.999-99', '.-', '');			
		}else{
			cNrcpfcgc.setMask('INTEGER', 'z.zzz.zzz/zzzz-zz', '/.-', '');			
		}
		return false;
	});
	
	cNrcpfcgc.unbind('blur').bind('blur', function(e){
		//cNrdconta.val('');
		cNmintegrante.val('');
		buscaDadosAssociado();
		return false;
	});
	
	cNrdconta.unbind('blur').bind('blur', function(e){
		//cNrcpfcgc.val('');
		cNmintegrante.val('');
		buscaDadosAssociado();
		return false;
	});
	
	cTppessoa.trigger('change');
	controlaPesquisas('frmGrupoEconomicoIntegrantes');
	layoutPadrao();
	return false;
}

function controlaLayout() {	
	var rDataInclusao  = $('label[for="dtinclusao"]', '#frmGrupoEconomico');
	var rIdGrupo       = $('label[for="idgrupo"]', '#frmGrupoEconomico');
	var rNmgrupo       = $('label[for="nmgrupo"]', '#frmGrupoEconomico');
	var rListarTodos   = $('label[for="listarTodos"]', '#frmGrupoEconomico');
	var rDsobservacao  = $('label[for="dsobservacao"]', '#frmGrupoEconomico');
	var rNrdconta      = $('label[for="nrdconta"]', '#frmGrupoEconomico');
	
	rIdGrupo.addClass('rotulo-linha').css({'width':'150px'});	
	rNmgrupo.addClass('rotulo-linha').css({'width':'80px'});	
	rDataInclusao.addClass('rotulo-linha').css({'width':'110px'});
	rListarTodos.addClass('rotulo').css({'width':'114px'});
	rDsobservacao.addClass('rotulo').css({'width':'auto','padding-left':'3px'});
	rNrdconta.addClass('rotulo-linha').css({'width':'80px'});
	
	var cIdGrupo      = $('#idgrupo', '#frmGrupoEconomico');
	var cNmGrupo      = $('#nmgrupo', '#frmGrupoEconomico');
	var cDataInclusao = $('#dtinclusao', '#frmGrupoEconomico');
	var cListarTodos  = $('#listarTodos', '#frmGrupoEconomico');
	var cDsobservacao = $('#dsobservacao', '#frmGrupoEconomico');
	var cNrdconta     = $('#nrdconta', '#frmGrupoEconomico');
	
	cIdGrupo.css({'width':'80px'});
	cIdGrupo.desabilitaCampo();
	
	cNmGrupo.css({'width':'300px'});
	
	cDataInclusao.css({'width':'80px'});
	cDataInclusao.desabilitaCampo();
	
	cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
	cDsobservacao.addClass('alphanum').css({'width':'951px','height':'80px','float':'left','margin':'-5px 0px 3px 3px','padding-right':'1px'});
    cListarTodos.css({'margin':'5px 3px 0px 3px','*margin':'7px 0px 0px 0px','height':'16px'});
	
	// Evento onKeyDown no campo "nrdconta"
    cNrdconta.bind("keydown", function (e) {
        // Captura código da tecla pressionada
        var keyValue = getKeyValue(e);

        // Se o botão enter foi pressionado, carrega dados da conta
        if (keyValue == 13) {
            carregaTelaConsultarIntegrantes();
            return false;
        }

        // Seta máscara ao campo
        return $(this).setMaskOnKeyDown("INTEGER", "zzzz.zzz-z", "", e);
    });
	
	cListarTodos.bind("click", function (e) {
		carregaTelaConsultarIntegrantes();
	});
	
	divRotina.css('width','1000px');
	layoutPadrao();
	//hideMsgAguardo();
	//bloqueiaFundo(divRotina);	
	//$(this).fadeIn(1000);
	divRotina.centralizaRotinaH();
	controlaPesquisas('frmGrupoEconomico');	
	return false;
}

function controlaLayoutInclusaoGrupoEconomico(){
	var rNmgrupo       = $('label[for="nmgrupo"]', '#frmInclusaoGrupoEconomico');
	rNmgrupo.addClass('rotulo-linha').css({'width':'80px'});	

	var cNmGrupo      = $('#nmgrupo', '#frmInclusaoGrupoEconomico');
	cNmGrupo.css({'width':'300px'});

	layoutPadrao();
	return false;
}

function formataTabIntegrantes() {

	var divRegistro = $('#divIntegrantes');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

	// FORMATA O GRID DOS LANCAMENTOS DE PAGAMENTO
    divRegistro.css({'height':'120px'});

    var ordemInicial = new Array();
    ordemInicial = [[9,0],[2,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '18px'; //Checkbox
    arrayLargura[1] = '50px'; //Tipo Pessoa
    arrayLargura[2] = '70px'; //Conta
    arrayLargura[3] = '100px'; //Documento
    arrayLargura[4] = '110px'; //Nome
    arrayLargura[5] = '60px'; //Tipo Vinculo
    arrayLargura[6] = '70px'; //%Participacao
    arrayLargura[7] = '70px'; //Data Inclusao
    arrayLargura[8] = '95px'; //Operador Inclusao
	arrayLargura[9] = '70px'; //Data Exclusao

	var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'left';
    arrayAlinha[5] = 'left';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'left';
    arrayAlinha[8] = 'left';
    arrayAlinha[9] = 'left';
    arrayAlinha[10] = 'left';
	
    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
    return false;
}

function buscaDadosAssociado(){
	
	hideMsgAguardo();
	showMsgAguardo('Aguarde, buscando os dados...');
	
	$.ajax({
		type: 'POST',
		url: UrlSite + 'telas/contas/grupo_economico/busca_associado.php',		
		data: {
			nrdconta: normalizaNumero($('#nrdconta', '#frmGrupoEconomicoIntegrantes').val())
		   ,nrcpfcgc: normalizaNumero($('#nrcpfcgc', '#frmGrupoEconomicoIntegrantes').val())
		   ,redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"bloqueiaFundo($('#divUsoGenerico'));");
		},
		success: function (response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"bloqueiaFundo($('#divUsoGenerico'));");
				return;
			}		
		}
	});		
}

function controlaPesquisas(nmformul) {

	// Atribui a classe lupa para os links e desabilita todos
	$('a','#' + nmformul).addClass('lupa').css('cursor','auto');	
	
	// Percorrendo todos os links
	$('a','#' + nmformul).each( function() {
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
	});
	
	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#' + nmformul);

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {
			if (nmformul == 'frmGrupoEconomico'){
			  mostraPesquisaAssociado('nrdconta',nmformul);
			}else if (nmformul == 'frmGrupoEconomicoIntegrantes'){
				var bo = 'b1wgen0059.p';
				var procedure = 'busca_associado';
				var titulo = 'Associados';
				var qtReg = '20';
				var inpessoa = $('#tppessoa', '#frmGrupoEconomicoIntegrantes').val();
				var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#frmGrupoEconomicoIntegrantes').val());
				var filtros = 'Conta;nrdconta;80px;S;0|Nome;nmprimtl;200px;S|;inpessoa;;;' + inpessoa + ';N|;nrcpfcgc;;;' + nrcpfcgc + ';N';
				var colunas = 'C&oacutedigo;nrdconta;20%;right|Nome;nmprimtl;50%;left|CPF/CNPJ;nrcpfcgc;30%;left';
				mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, $('#divUsoGenerico'),true,nmformul);
				return false;
			}
		});
	}
	return false;
}

function imprimirRelatorio(){
	var action    = UrlSite + 'telas/contas/grupo_economico/imprime_grupo_economico.php';	
	var callafter = "hideMsgAguardo();bloqueiaFundo(divRotina);";	
	$('#sidlogin','#frmGrupoEconomico').remove();
	$('#idgrupo_rel','#frmGrupoEconomico').remove();
	
	$('#frmGrupoEconomico').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');
	$('#frmGrupoEconomico').append('<input type="hidden" id="idgrupo_rel" name="idgrupo_rel" value="' + $('#idgrupo','#frmGrupoEconomico').val() + '" />');
	$('#frmGrupoEconomico').append('<input type="hidden" id="nrdconta_rel" name="nrdconta_rel" value="' + normalizaNumero($('#nrdconta','#frmGrupoEconomico').val()) + '" />');
	carregaImpressaoAyllos("frmGrupoEconomico",action,callafter);
	return false;
}
