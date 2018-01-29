/***********************************************************************
    Fonte: ocorrencias.js
    Autor: Guilherme
    Data : Fevereiro/2007                Última Alteração: 29/10/2012

    Objetivo  : Biblioteca de funções da rotina OCORRENCIAS da tela
                ATENDA

    Alterações: 13/07/2011 - Alterado para layout padrão (Rogerius - DB1). 	
	
	            16/09/2011 - Ajuste no tamanho do campo Crédito Líquido (David).
				
				29/10/2012 - Ajustes referente a inclusão da opção "Grupo Economico". 
						     Projeto GE (Adriano).
                01/08/2016 - Adicionado função controlaFoco (Evandro - RKAM).     
                
                29/09/2016 - Ajustes referente a inclusão da opção "Acordos". 
						     Projeto 302 (Jean Michel).
				
				24/01/2018 - Ajustes referentes a inclusão da opçã/abao "Riscos".
					         Reginaldo - AMcom
							 
 ***********************************************************************/

var contWin = 0;  // Vari&aacute;vel para contagem do n&uacute;mero de janelas abertas para impress&atilde;o de extratos

// Formata estilos CSS das abas
function formataEstilosAba(idAba, active = false)
{
	if (active) {
		$("#linkAba" + idAba).attr("class", "txtBrancoBold");
		$("#imgAbaEsq" + idAba).attr("src", UrlImagens + "background/mnu_sle.gif");
		$("#imgAbaDir" + idAba).attr("src", UrlImagens + "background/mnu_sld.gif");
		$("#imgAbaCen" + idAba).css("background-color", "#969FA9");

		return false;
	}

	$("#linkAba" + idAba).attr("class", "txtNormalBold");
	$("#imgAbaEsq" + idAba).attr("src", UrlImagens + "background/mnu_nle.gif");
	$("#imgAbaDir" + idAba).attr("src", UrlImagens + "background/mnu_nld.gif");
	$("#imgAbaCen" + idAba).css("background-color", "#C6C8CA");
}

// Retorna array com parâmetros das opções de abas
function getParametrosOpcoes()
{
	return [
		{
			complementoMsg: 'ocorr&ecirc;ncia',
			scriptName: 'principal.php'
		},
		{
			complementoMsg: 'contra ordens',
			scriptName: 'contra_ordens.php'
		},
		{
			complementoMsg: 'empr&eacute;stimos',
			scriptName: 'emprestimos.php'
		},
		{
			complementoMsg: 'preju&iacute;zos',
			scriptName: 'prejuizos.php'
		},
		{
			complementoMsg: 'SPC',
			scriptName: 'spc.php'
		},
		{
			complementoMsg: 'estouros',
			scriptName: 'estouros.php'
		},
		{
			complementoMsg: 'grupo econ&ocirc;mico',
			scriptName: 'grupo_economico.php'
		},
		{
			complementoMsg: 'acordos',
			scriptName: 'acordos.php'
		},
		{
			complementoMsg: 'riscos',
			scriptName: 'riscos.php'
		}
	];
}

// Fun&ccedil;&atilde;o para acessar op&ccedil;&otilde;es da rotina
function acessaOpcaoAba(nrOpcoes,id,opcao) {
	var listaParametros = getParametrosOpcoes();
	var parametrosOpcao = listaParametros[opcao];

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando " + parametrosOpcao.complementoMsg + " ...");
	
	// Atribui cor de destaque para aba da op&ccedil;&atilde;o
	for (var i = 0; i <= nrOpcoes; i++) {
		formataEstilosAba(i, i == id);
	}
	
	// Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/atenda/ocorrencias/" + parametrosOpcao.scriptName,
		data: {
			nrdconta: nrdconta,
			nrcpfcnpj: nrcpfcnpj = retiraCaracteres($("#nrcpfcgc", "#frmCabAtenda").val(), "0123456789", true),
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
		success: function(response) {
			$("#divConteudoOpcao").html(response);
			controlaFoco();
		}				
	}); 		
}

//Função para controle de navegação pelas abas
function controlaFoco() {
	$('#divRotina').each(function () {
	    $(this)
			.find("#linkAba0")
			.css({ 'border': 'none', 'outline': 'none' })
			.focus();
	});
}

// Formata o layout principal
function formataPrincipal() {
	var nomeForm = 'frmOcorrencias';

	// label
	$('label[for="campo00"]', '#'+nomeForm).addClass('rotulo').css({'width':'125px'});
	$('label[for="campo01"]', '#'+nomeForm).addClass('rotulo-linha').css({'width':'139px'});
	$('label[for="campo02"]', '#'+nomeForm).addClass('rotulo').css({'width':'125px'});
	$('label[for="campo03"]', '#'+nomeForm).addClass('rotulo-linha').css({'width':'139px'});
	$('label[for="campo04"]', '#'+nomeForm).addClass('rotulo').css({'width':'125px'});
	$('label[for="campo05"]', '#'+nomeForm).addClass('rotulo-linha').css({'width':'18px'});
	$('label[for="campo06"]', '#'+nomeForm).addClass('rotulo-linha').css({'width':'107px'});
	$('label[for="campo07"]', '#'+nomeForm).addClass('rotulo').css({'width':'125px'});
	$('label[for="campo08"]', '#'+nomeForm).addClass('rotulo-linha').css({'width':'139px'});
	$('label[for="campo09"]', '#'+nomeForm).addClass('rotulo').css({'width':'125px'});
	$('label[for="campo10"]', '#'+nomeForm).addClass('rotulo').css({'width':'370px'});
	$('label[for="campo11"]', '#'+nomeForm).addClass('rotulo').css({'width':'370px'});
	$('label[for="campo12"]', '#'+nomeForm).addClass('rotulo').css({'width':'125px'});
	$('label[for="campo13"]', '#'+nomeForm).addClass('rotulo').css({'width':'125px'});
	$('label[for="campo15"]', '#'+nomeForm).addClass('rotulo-linha').css({'width':'191px'});
	$('label[for="campo16"]', '#'+nomeForm).addClass('rotulo-linha').css({'width':'191px'});
	$('label[for="campo17"]', '#'+nomeForm).addClass('rotulo-linha').css({'width':'169px'});
	$('label[for="campo18"]', '#'+nomeForm).addClass('rotulo-linha').css({'width':'367px'});

	// campos
	$('#campo00', '#'+nomeForm).css({'width':'100px'});
	$('#campo01', '#'+nomeForm).css({'width':'70px'});
	$('#campo02', '#'+nomeForm).css({'width':'100px'});
	$('#campo03', '#'+nomeForm).css({'width':'70px'});
	$('#campo04', '#'+nomeForm).css({'width':'38px','text-align':'right'});
	$('#campo05', '#'+nomeForm).css({'width':'70px','text-align':'left'});
	$('#campo06', '#'+nomeForm).css({'width':'38px','text-align':'right'});
	$('#campo07', '#'+nomeForm).css({'width':'100px'});
	$('#campo08', '#'+nomeForm).css({'width':'70px'});
	$('#campo09', '#'+nomeForm).css({'width':'50px'});
	$('#campo10', '#'+nomeForm).css({'width':'70px'});
	$('#campo11', '#'+nomeForm).css({'width':'70px'});
	$('#campo12', '#'+nomeForm).css({'width':'48px'});
	$('#campo13', '#'+nomeForm).css({'width':'48px'});
	$('#campo15', '#'+nomeForm).css({'width':'70px'});
	$('#campo16', '#'+nomeForm).css({'width':'70px'});
	$('#campo17', '#'+nomeForm).css({'width':'90px'});
	$('#campo18', '#'+nomeForm).css({'width':'70px'});

	if ($.browser.msie) {
		rCampo06.addClass('rotulo-linha').css({ 'width': '105px' });
		rCampo10.addClass('rotulo').css({ 'width': '367px' });
		rCampo11.addClass('rotulo').css({ 'width': '367px' });
	}
	
	$('input, select', '#'+nomeForm).desabilitaCampo();

	ajustarCentralizacao();

	return false;	
}

// Função que formata a tabela contra-ordens
function formataContraOrdens() {			
	var divRegistro = $('div.divRegistros','#divTabContraOrdens');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'235px', 'width':'580px'});
	
	var ordemInicial = new Array();	
			
	var arrayLargura = ['25px', '30px', '54px', '50px', '54px', '56px', '56px'];
		
	var arrayAlinha = ['right', 'right', 'right', 'right', 'right', 'center', 
		'center', 'left'];
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );
	ajustarCentralizacao();	

	return false;
}

// Função que formata a tabela emprestimos
function formataEmprestimos() {			
	var divRegistro = $('div.divRegistros','#divTabEmprestimos');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'235px', 'width':'580px'});
	
	var ordemInicial = new Array();	
			
	var arrayLargura = ['56px', '70px', '85px', '85px', '85px'];	
		
	var arrayAlinha = ['center', 'right', 'right', 'right',  'right', 'center'];
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );

	ajustarCentralizacao();	

	return false;
}

// Função que formata a tabela riscos
function formataRiscos() {
	var divRegistro = $('div.divRegistros', '#divTabRiscos');
	var tabela = $('table', divRegistro);
	var linha = $('table > tbody > tr', divRegistro);

	divRegistro.css({ 'height': '200px', 'width': '700px' });

	var ordemInicial = new Array();

	var arrayLargura = ['140px', '70px', '60px', '40px', '40px', '40px', '40px', '40px', 
		'40px', '40px'];

	var arrayAlinha = ['center', 'right', 'right', 'center', 'center', 'center', 'center',
		'center', 'center', 'center'];

	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

	ajustarCentralizacao();

	return false;
}

// Função que formata a tabela prejuizos
function formataPrejuizos() {			
	var divRegistro = $('div.divRegistros','#divTabPrejuizos');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'235px', 'width':'530px'});
	
	var ordemInicial = new Array();	
			
	var arrayLargura = ['56px', '72px', '110px', '110px'];
		
	var arrayAlinha = ['center', 'right', 'right', 'right', 'right'];
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );

	ajustarCentralizacao();	

	return false;
}

// Função que formata a tabela SPC
function formataSPC() {
	var divRegistro = $('div.divRegistros','#divTabSPC');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'180px', 'width':'530px'});
	
	var ordemInicial = new Array();
	
	var arrayLargura = ['65px', '65px', '120px', '70px', '70px'];
		
	var arrayAlinha = ['right', 'center', 'left', 'center', 'center', 'right'];
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );

	// complemento linha 1
	var linha1  = $('ul.complemento', '#divSPCLinha1');
	
	$('li:eq(0)', linha1).addClass('txtNormalBold').css({'width':'10%'});
	$('li:eq(1)', linha1).addClass('txtNormal').css({'width':'40%'});
	$('li:eq(2)', linha1).addClass('txtNormalBold').css({'width':'15%'});
	$('li:eq(3)', linha1).addClass('txtNormal');

	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaSPC($(this));
	});	

	// seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaSPC($(this));
	});	

	ajustarCentralizacao();	

	return false;
}

// Função de complemento da formataSPC
function selecionaSPC(tr) {
	$('#contrat2').html($('#contrat1', tr).val());
	$('#dtbaixa2').html($('#dtbaixa1', tr).val());

	return false;
}

// Função que formata a tabela estouros
function formataEstouros() {
	var divRegistro = $('div.divRegistros','#divTabEstouros');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'180px', 'width':'580px'});
	
	var ordemInicial = new Array();
	
	var arrayLargura = ['33px', '55px', '35px', '80px', '92px', '70px'];
		
	var arrayAlinha = ['right', 'center', 'right', 'right', 'right', 
		'right', 'right'];
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );

	// complemento linhas
	for (var i = 1; i <= 2; i++) {
		linha = $('ul.complemento', '#divEstourosLinha' + i);

		$('li:eq(0)', linha).addClass('txtNormalBold').css({ 'width': '15%' });
		$('li:eq(1)', linha).addClass('txtNormal').css({ 'width': '36%' });
		$('li:eq(2)', linha).addClass('txtNormalBold').css({ 'width': '17%' });
		$('li:eq(3)', linha).addClass('txtNormal');
	}

	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaEstouros($(this));
	});	

	// seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaEstouros($(this));
	});	

	ajustarCentralizacao();	

	return false;
}

// Formata o layout Grupo Economico
function formataGrupoEconomico(){
	// label
	$('label[for="dsdrisco"]', '#divGrupoEconomico')
		.addClass('rotulo').css({'width':'125px'});
	$('label[for="vlendivi"]', '#divGrupoEconomico')
		.addClass('rotulo-linha').css({'width':'220px'});	

	// campos 
	$('#dsdrisco', '#divGrupoEconomico').css({'width':'30px'});
	$('#vlendivi', '#divGrupoEconomico').css({'width':'100px'});	
	
	var divRegistro = $('div.divRegistros','#divGrupoEconomico');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'180px', 'width':'530px'});
	
	var ordemInicial = new Array();
	
	var arrayLargura = ['33px', '70px', '130px', '80px'];

	var arrayAlinha = ['center', 'right', 'right', 'center', 'right'];

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );

	$('input, select', '#divGrupoEconomico').desabilitaCampo();

	return false;
}

// Formata o layout Acordos
function formataAcordos() {
    var divRegistro = $('div.divRegistros', '#divAcordos');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '180px', 'width': '530px' });

    var ordemInicial = new Array();

    var arrayLargura = ['130px', '150px'];
    
    var arrayAlinha = ['center', 'left', 'center'];
    
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
    
    return false;
}

// Função de complemento da formataEstourso
function selecionaEstouros(tr) {
	for (var i = 1; i <= 4; i++) {
		$('#complem' + i).html($('#complem1' + i, tr).val());
	}

	return false;
}

