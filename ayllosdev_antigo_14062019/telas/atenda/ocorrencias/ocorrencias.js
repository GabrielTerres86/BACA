/***********************************************************************
    Fonte: ocorrencias.js
    Autor: Guilherme
    Data : Fevereiro/2007                Última Alteração: 10/09/2018

    Objetivo  : Biblioteca de funções da rotina OCORRENCIAS da tela
                ATENDA

    Alterações: 13/07/2011 - Alterado para layout padrão (Rogerius - DB1). 	
	
	            16/09/2011 - Ajuste no tamanho do campo Crédito Líquido (David).
				
				29/10/2012 - Ajustes referente a inclusão da opção "Grupo Economico". 
						     Projeto GE (Adriano).
                01/08/2016 - Adicionado função controlaFoco (Evandro - RKAM).     
                
                29/09/2016 - Ajustes referente a inclusão da opção "Acordos". 
						     Projeto 302 (Jean Michel).

				24/01/2018 - Ajustes referentes a inclusão da opção "Riscos".
					         Reginaldo - AMcom

			    25/03/2018 - Adicionada coluna de Risco Refinanciamento e carregamento de dados brutos
										Marcel Kohls - AMCom
							 
                19/06/2018 - Atualizado os detalhes da aba Prejuízo para considerar o prejuízo da Conta Corrente
                             Diego Simas - AMcom - PRJ450

				24/08/2018 - Inclusão da coluna quantidade de dias de atraso
							 PJ 450 - Diego Simas - AMcom

			    10/09/2018 - Ajuste no layout da tela de risco
					         PJ 450 - Diego Simas - AMcom
							 
 ***********************************************************************/

var contWin = 0;  // Vari&aacute;vel para contagem do n&uacute;mero de janelas abertas para impress&atilde;o de extratos

// Fun&ccedil;&atilde;o para acessar op&ccedil;&otilde;es da rotina
function acessaOpcaoAba(nrOpcoes,id,opcao) {
	if (opcao == "0") {	// Op&ccedil;&atilde;o Principal
		var msg = "ocorr&ecirc;ncias";
		var UrlOperacao = UrlSite + "telas/atenda/ocorrencias/principal.php";
	} else if (opcao == "1") {	// Op&ccedil;&atilde;o Contra Ordens
		var msg = "contra ordens";
		var UrlOperacao = UrlSite + "telas/atenda/ocorrencias/contra_ordens.php";
    } else if (opcao == "2") {	// Op&ccedil;&atilde;o Emprestimos
		var msg = "empr&eacute;stimos";
		var UrlOperacao = UrlSite + "telas/atenda/ocorrencias/emprestimos.php";
    } else if (opcao == "3") {	// Op&ccedil;&atilde;o Prejuizos
		var msg = "preju&iacute;zos";
		var UrlOperacao = UrlSite + "telas/atenda/ocorrencias/prejuizos.php";
    } else if (opcao == "4") {	// Op&ccedil;&atilde;o SPC
		var msg = "SPC";
		var UrlOperacao = UrlSite + "telas/atenda/ocorrencias/spc.php";
    } else if (opcao == "5") {	// Op&ccedil;&atilde;o Estouros
		var msg = "estouros";
		var UrlOperacao = UrlSite + "telas/atenda/ocorrencias/estouros.php";
    } else if (opcao == '6') { // Operação Grupo Economico
		var msg  = "grupo economico";
		var UrlOperacao = UrlSite + "telas/atenda/ocorrencias/grupo_economico.php";
    } else if (opcao == '7') { // Operação Acordos
        var msg = "acordos";
        var UrlOperacao = UrlSite + "telas/atenda/ocorrencias/acordos.php";
	} else if (opcao == '8') { // Operação Riscos
		var msg = "riscos";
		var UrlOperacao = UrlSite + "telas/atenda/ocorrencias/riscos.php";
    }
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando " + msg + " ...");
	
	// Atribui cor de destaque para aba da op&ccedil;&atilde;o
	for (var i = 0; i <= nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da op&ccedil;&atilde;o
			$("#linkAba" + id).attr("class","txtBrancoBold");
			$("#imgAbaEsq" + id).attr("src",UrlImagens + "background/mnu_sle.gif");				
			$("#imgAbaDir" + id).attr("src",UrlImagens + "background/mnu_sld.gif");
			$("#imgAbaCen" + id).css("background-color","#969FA9");
			continue;			
}

		$("#linkAba" + i).attr("class","txtNormalBold");
		$("#imgAbaEsq" + i).attr("src",UrlImagens + "background/mnu_nle.gif");			
		$("#imgAbaDir" + i).attr("src",UrlImagens + "background/mnu_nld.gif");
		$("#imgAbaCen" + i).css("background-color","#C6C8CA");
	}
	
	
	// Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlOperacao,
		data: {
			nrdconta: nrdconta,
			nrcpfcnpj: nrcpfcnpj = retiraCaracteres($("#nrcpfcgc", "#frmCabAtenda").val(), "0123456789", true),
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
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
	    $(this).find("#linkAba0").focus();
	    $("#linkAba0:focus").css({ 'border': 'none', 'outline': 'none' });
	});
}
// Formata o layout principal
function formataPrincipal() {

	var nomeForm = 'frmOcorrencias';

	// label
	rCampo00 = $('label[for="campo00"]', '#'+nomeForm);
	rCampo01 = $('label[for="campo01"]', '#'+nomeForm);
	rCampo02 = $('label[for="campo02"]', '#'+nomeForm);
	rCampo03 = $('label[for="campo03"]', '#'+nomeForm);
	rCampo04 = $('label[for="campo04"]', '#'+nomeForm);
	rCampo05 = $('label[for="campo05"]', '#'+nomeForm);
	rCampo06 = $('label[for="campo06"]', '#'+nomeForm);
	rCampo07 = $('label[for="campo07"]', '#'+nomeForm);
	rCampo08 = $('label[for="campo08"]', '#'+nomeForm);
	rCampo09 = $('label[for="campo09"]', '#'+nomeForm);
	rCampo10 = $('label[for="campo10"]', '#'+nomeForm);
	rCampo11 = $('label[for="campo11"]', '#'+nomeForm);
	rCampo12 = $('label[for="campo12"]', '#'+nomeForm);
	rCampo13 = $('label[for="campo13"]', '#'+nomeForm);
	rCampo15 = $('label[for="campo15"]', '#'+nomeForm);
	rCampo16 = $('label[for="campo16"]', '#'+nomeForm);
	rCampo17 = $('label[for="campo17"]', '#'+nomeForm);
	rCampo18 = $('label[for="campo18"]', '#'+nomeForm);

	rCampo00.addClass('rotulo').css({'width':'125px'});
	rCampo01.addClass('rotulo-linha').css({'width':'139px'});
	rCampo02.addClass('rotulo').css({'width':'125px'});
	rCampo03.addClass('rotulo-linha').css({'width':'139px'});
	rCampo04.addClass('rotulo').css({'width':'125px'});
	rCampo05.addClass('rotulo-linha').css({'width':'18px'});
	rCampo06.addClass('rotulo-linha').css({'width':'107px'});
	rCampo07.addClass('rotulo').css({'width':'125px'});
	rCampo08.addClass('rotulo-linha').css({'width':'139px'});
	rCampo09.addClass('rotulo').css({'width':'125px'});
	rCampo10.addClass('rotulo').css({'width':'370px'});
	rCampo11.addClass('rotulo').css({'width':'370px'});
	rCampo12.addClass('rotulo').css({'width':'125px'});
	rCampo13.addClass('rotulo').css({'width':'125px'});
	rCampo15.addClass('rotulo-linha').css({'width':'191px'});
	rCampo16.addClass('rotulo-linha').css({'width':'191px'});
	rCampo17.addClass('rotulo-linha').css({'width':'169px'});
	rCampo18.addClass('rotulo-linha').css({'width':'367px'});

	// campos
	cCampo00 = $('#campo00', '#'+nomeForm);	
	cCampo01 = $('#campo01', '#'+nomeForm);	
	cCampo02 = $('#campo02', '#'+nomeForm);	
	cCampo03 = $('#campo03', '#'+nomeForm);	
	cCampo04 = $('#campo04', '#'+nomeForm);	
	cCampo05 = $('#campo05', '#'+nomeForm);	
	cCampo06 = $('#campo06', '#'+nomeForm);	
	cCampo07 = $('#campo07', '#'+nomeForm);	
	cCampo08 = $('#campo08', '#'+nomeForm);	
	cCampo09 = $('#campo09', '#'+nomeForm);	
	cCampo10 = $('#campo10', '#'+nomeForm);	
	cCampo11 = $('#campo11', '#'+nomeForm);	
	cCampo12 = $('#campo12', '#'+nomeForm);	
	cCampo13 = $('#campo13', '#'+nomeForm);	
	cCampo15 = $('#campo15', '#'+nomeForm);	
	cCampo16 = $('#campo16', '#'+nomeForm);	
	cCampo17 = $('#campo17', '#'+nomeForm);	
	cCampo18 = $('#campo18', '#'+nomeForm);

	cCampo00.css({'width':'100px'});
	cCampo01.css({'width':'70px'});
	cCampo02.css({'width':'100px'});
	cCampo03.css({'width':'70px'});
	cCampo04.css({'width':'38px','text-align':'right'});
	cCampo05.css({'width':'70px','text-align':'left'});
	cCampo06.css({'width':'38px','text-align':'right'});
	cCampo07.css({'width':'100px'});
	cCampo08.css({'width':'70px'});
	cCampo09.css({'width':'50px'});
	cCampo10.css({'width':'70px'});
	cCampo11.css({'width':'70px'});
	cCampo12.css({'width':'48px'});
	cCampo13.css({'width':'48px'});
	cCampo15.css({'width':'70px'});
	cCampo16.css({'width':'70px'});
	cCampo17.css({'width':'90px'});
	cCampo18.css({'width':'70px'});
	
	$('input, select', '#'+nomeForm).desabilitaCampo();
	
	if ( $.browser.msie ) {	
		rCampo06.addClass('rotulo-linha').css({'width':'105px'});
		rCampo10.addClass('rotulo').css({'width':'367px'});
		rCampo11.addClass('rotulo').css({'width':'367px'});
}

	return false;
}

// Função que formata a tabela contra-ordens
function formataContraOrdens() {
			
	var divRegistro = $('div.divRegistros','#divTabContraOrdens');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'235px', 'width':'580px'});
	
	var ordemInicial = new Array();
	
			
	var arrayLargura = new Array();
	arrayLargura[0] = '25px';
	arrayLargura[1] = '30px';
	arrayLargura[2] = '54px';
	arrayLargura[3] = '50px';
	arrayLargura[4] = '54px';
	arrayLargura[5] = '56px';
	arrayLargura[6] = '56px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'center';
	arrayAlinha[6] = 'center';
	arrayAlinha[7] = 'left';
	
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
	
			
	var arrayLargura = new Array();
	arrayLargura[0] = '56px';
	arrayLargura[1] = '70px';
	arrayLargura[2] = '85px';
	arrayLargura[3] = '85px';
	arrayLargura[4] = '85px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );
	ajustarCentralizacao();	

	return false;
}

// Função que formata a tabela riscos
function formataRiscos() {
	var divRegistro = $('div.divRegistros', '#divTabRiscos');
	var tabela = $('table', divRegistro);
	var linha = $('table > tbody > tr', divRegistro);

	divRegistro.css({ 'height': '175px', 'width': '950px' });

	var ordemInicial = new Array();

	var arrayLargura = ['99px', '67px', 
		                '55px', '40px', 
						'40px', '40px', 
						'40px', '40px', 
						'40px', '40px',
 		                '40px', '40px', 
						'40px', '40px', 
						'40px', '40px'];

	var arrayAlinha = ['center', 'center', 
					   'center', 'center', 
					   'center', 'center', 
					   'center', 'center', 
					   'center', 'center', 
					   'center', 'center', 
					   'center', 'center', 
					   'center', 'center'];

	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

	ajustarCentralizacao();

	return false;
}

// Função que formata a tabela prejuizos
function formataPrejuizos() {
			
	var divRegistro = $('div.divRegistros','#divTabPrejuizos');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'235px', 'width':'910px'});
	
	var ordemInicial = new Array();
	
			
	var arrayLargura = new Array();
	arrayLargura[0] = '65px';
	arrayLargura[1] = '60px';
	arrayLargura[2] = '65px';
	arrayLargura[3] = '65px';
	arrayLargura[4] = '50px';
	arrayLargura[5] = '50px';
	arrayLargura[6] = '55px';
	arrayLargura[7] = '70px';
	arrayLargura[8] = '68px';
	arrayLargura[9] = '65px';
	arrayLargura[10] = '65px';
	arrayLargura[11] = '65px';
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'center';
	arrayAlinha[6] = 'center';
	arrayAlinha[7] = 'center';
	arrayAlinha[8] = 'center';
	arrayAlinha[9] = 'center';
	arrayAlinha[10] = 'center';
	arrayAlinha[11] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );
	ajustarCentralizacao();	
	return false;
}

// Função que formata a tabela SPC
function formataSPC() {

	var divRegistro = $('div.divRegistros','#divTabSPC');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'180px', 'width':'580px'});
	
	var ordemInicial = new Array();
	
	var arrayLargura = new Array();
	arrayLargura[0] = '65px';
	arrayLargura[1] = '65px';
	arrayLargura[2] = '120px';
	arrayLargura[3] = '70px';
	arrayLargura[4] = '70px';
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'right';
	
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

	$('#contrat2').html($('#contrat1', tr ).val());
	$('#dtbaixa2').html($('#dtbaixa1', tr ).val());

	return false;
}

// Função que formata a tabela estouros
function formataEstouros() {

	var divRegistro = $('div.divRegistros','#divTabEstouros');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'180px', 'width':'580px'});
	
	var ordemInicial = new Array();
	
	var arrayLargura = new Array();
	arrayLargura[0] = '33px';
	arrayLargura[1] = '55px';
	arrayLargura[2] = '35px';
	arrayLargura[3] = '80px';
	arrayLargura[4] = '92px';
	arrayLargura[5] = '70px'; //conta base
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );

	// complemento linha 1
	var linha1  = $('ul.complemento', '#divEstourosLinha1');
	
	$('li:eq(0)', linha1).addClass('txtNormalBold').css({'width':'15%'});
	$('li:eq(1)', linha1).addClass('txtNormal').css({'width':'36%'});
	$('li:eq(2)', linha1).addClass('txtNormalBold').css({'width':'17%'});
	$('li:eq(3)', linha1).addClass('txtNormal');

	// complemento linha 2
	var linha2  = $('ul.complemento', '#divEstourosLinha2');

	$('li:eq(0)', linha2).addClass('txtNormalBold').css({'width':'15%'});
	$('li:eq(1)', linha2).addClass('txtNormal').css({'width':'36%'});
	$('li:eq(2)', linha2).addClass('txtNormalBold').css({'width':'17%'});
	$('li:eq(3)', linha2).addClass('txtNormal');


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
	rDsdrisco = $('label[for="dsdrisco"]', '#divGrupoEconomico');
	rVlendivi = $('label[for="vlendivi"]', '#divGrupoEconomico');
		
	rDsdrisco.addClass('rotulo').css({'width':'125px'});
	rVlendivi.addClass('rotulo-linha').css({'width':'220px'});
	

	// campos 
	cDsdrisco = $('#dsdrisco', '#divGrupoEconomico');	
	cVlendivi = $('#vlendivi', '#divGrupoEconomico');	
	
	cDsdrisco.css({'width':'30px'});
	cVlendivi.css({'width':'100px'});
	
	
	var divRegistro = $('div.divRegistros','#divGrupoEconomico');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'180px', 'width':'580px'});
	
	var ordemInicial = new Array();
	
	var arrayLargura = new Array();
	arrayLargura[0] = '33px';
	arrayLargura[1] = '70px';
	arrayLargura[2] = '130px';
	arrayLargura[3] = '80px';


	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'right';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );

	$('input, select', '#divGrupoEconomico').desabilitaCampo();

	return false;

}

// Formata o layout Acordos
function formataAcordos() {

    var divRegistro = $('div.divRegistros', '#divAcordos');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '180px', 'width': '580px' });

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '130px';
    arrayLargura[1] = '150px';
    
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
    
    return false;

}

// Função de complemento da formataEstourso
function selecionaEstouros(tr) {

	$('#complem1').html($('#complem11', tr ).val());
	$('#complem2').html($('#complem21', tr ).val());
	$('#complem3').html($('#complem31', tr ).val());
	$('#complem4').html($('#complem41', tr ).val());

	return false;
}
