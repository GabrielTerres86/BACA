/************************************************************************
 Fonte: descontos.js                                              
 Autor: Guilherme                                                 
 Data : Novembro/2008                Última Alteração: 21/07/2017
																  
 Objetivo  : Biblioteca de funções da rotina de Descontos da tela 
			 ATENDA                                               
																	 
 Alterações: 09/06/2010 - Incluir função dscShowHideDiv (David).         
 
			 09/07/2012 - Inclusão de tratamento para novos campos do frame 'frmTitulos'
						  dentro da função 'formataLayout()' (Lucas). 
			 19/11/2012 - Ajustes:
						  - Incluído tratamento na função formataLayout para quando, 
						    pressionado	a tecla enter nos campos dos forms frmDadosLimiteDscChq,
							frmDadosLimiteDscTit (Adriano).
						 
			 30/04/2015 - Ajustes na largura da tela dos avais (Gabriel-RKAM).

             20/06/2016 - Inclusao da divRestricoes/divRestricoesTit para
                          formatacao da tabela. (Jaison/James)

             25/07/2016 - Adicionado função controlaFoco.(Evandro - RKAM).			 

			 06/09/2016 - Inclusao do botão "Renovação" para renovação do limite 
						  de desconto de cheque. Projeto 300. (Lombardi)
			
             16/12/2016 - Alterações referentes ao projeto 300. (Reinert)

             26/06/2017 - Ajuste para rotina ser chamada através da tela ATENDA > Produtos (Jonata - RKAM / P364).
			 
			 21/07/2017 - Ajuste no cadastro de emitentes. Projeto 300. (Lombardi)
			 
			 19/01/2018 - Chamado 743079 - Problema da tela ficar travada quando CMLC7 inválido (Andrei-Mouts)
			 
             07/03/2018 - Formatação do novo campo 'Data Renovação' para o formulário de titulos (Leonardo Oliveira - GFT)

             13/03/2018 - Formatação do botão Renovação para  o formulário de titulos. (Leonardo Oliveira - GFT)

             28/03/2018 - Formatação dos layouts dos formulários de Contratos e Propostas. (Andre Avila - GFT)
			 
			 02/04/2018 - Formatação da tela para listar borderôs. (Leonardo Oliveira - GFT)

			 04/04/2018 - Ajustes na formatação da tela 'divDetalheBordero'. (Leonardo Oliveira - GFT)

			 12/04/2018 - Formatação do layout 'frmTitLimiteManutencao' e inclusão do botão manutenção no layout 'frmTitulos'. (Leonardo Oliveira - GFT)
			 
             15/04/2018 - Correção de sobreescrita.

			 18/04/2018 - Alteração da coluna 'contrato' para 'prospota', inclusão da coluna 'contrato' (Leonardo Oliveira - GFT).
  
			 28/04/2018 - Inclusão de novas colunas na grid de borderô (Alex Sandro  - GFT)

			 03/08/2018 - Inclusão de dois novos campos de risco na tabela de bordero (Vitor Shimada Assanuma - GFT)

			 13/08/2018 - Novo formulário formDetalheTitulo (Vitor Shimada Assanuma - GFT)

			 22/08/2018 - Adicionado abas na tela de títulos e histórico de contrato de limite. (Vitor Shimada Assanuma - GFT)

			 25/08/2018 - Adicionado tela de prejuizo de bordero e campo na tela detalhes de titulo. (Cassia de Oliveira - GFT)
             
			 27/08/2018 - Adicionada informação mostrando borderô em prejuízo - Luis Fernando (GFT)
	        
	         04/09/2018 - Alteração do saldo do prejuizo - Vitor Shimada Assanuma (GFT)
             
	         11/09/2018 - Reformulação dos campos de prejuizo - Vitor Shimada Assanuma (GFT)

	         17/09/2018 - Inserção do campo de Acordo - Vitor S. Assanuma (GFT)

	         20/09/2018 - Inserção do campo de Acordo - Vitor S. Assanuma (GFT)

	         14/02/2019 - Adicionado na tabela divLimites e divPropostas as 3 novas colunas do crédito rating P450 (Luiz Otávio Olinger Momm - AMCOM)

	         24/05/2019 - P450 - Removido mensageiria para pesquisa de rating por proposta (Luiz Otávio Olinger Momm - AMCOM).

************************************************************************/

// Carrega biblioteca javascript referente ao RATING
$.getScript(UrlSite + 'includes/rating/rating.js');

/*Largura e alinhamento das tabelas da inclusao do bordero*/
var arrayLarguraInclusaoBordero = new Array();
arrayLarguraInclusaoBordero[0] = '70px';
arrayLarguraInclusaoBordero[1] = '70px';
arrayLarguraInclusaoBordero[2] = '370px';
arrayLarguraInclusaoBordero[3] = '80px';
arrayLarguraInclusaoBordero[4] = '100px';
arrayLarguraInclusaoBordero[5] = '70px';
arrayLarguraInclusaoBordero[6] = '70px';

var arrayAlinhaInclusaoBordero = new Array();
arrayAlinhaInclusaoBordero[0] = 'center';
arrayAlinhaInclusaoBordero[1] = 'right';
arrayAlinhaInclusaoBordero[2] = 'left';
arrayAlinhaInclusaoBordero[3] = 'right';
arrayAlinhaInclusaoBordero[4] = 'right';
arrayAlinhaInclusaoBordero[5] = 'center';
arrayAlinhaInclusaoBordero[6] = 'center';
				
var flgverbor = 0;

// Função para voltar para o div anterior conforme parâmetros
function voltaDiv(esconder,mostrar,qtdade,titulo,rotina,novotam,novalar) {	

	if (rotina != undefined && rotina != "") {
		// Executa script de alteração de nome da rotina na seção através de ajax
		$.ajax({		
			type: "POST",
			url: UrlSite + "telas/atenda/descontos/altera_secao_nmrotina.php",
			data: {
				nmrotina: rotina
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		});	
	}
	
	var tamanho = novotam == undefined ? 80 : novotam;
	var largura = novalar == undefined ? 350 : novalar;
	
	if (titulo != undefined || titulo != "") {
		$("#tdTitRotina").html(titulo);
	}
	
	$("#divConteudoOpcao").css("height",tamanho);
	$("#divConteudoOpcao").css("width",largura);
	
	if (mostrar == 0) {
		for (var i = 1; i <= qtdade;i++) {
			$("#divOpcoesDaOpcao"+i).css("display","none");
		}		
		
		$("#divConteudoOpcao").css("display","block");
	} else {
		$("#divConteudoOpcao").css("display","none");
		
		for (var i = 1; i <= qtdade;i++) {
			$("#divOpcoesDaOpcao"+i).css("display",(mostrar == i ? "block" : "none"));			
		}
	}
}

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao').each(function () {
        $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");
        $(this).find("#divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > :input[type=image]").last().addClass("LastInputModal");

        //Se estiver com foco na classe FluxoNavega
        $(".FluxoNavega").focus(function () {
            $(this).bind('keydown', function (e) {
                if (e.keyCode == 13) {
                    $(this).click();
                }
            });
        });
    });
    $(".FirstInputModal").focus();
}

// Função para mostrar div com formulário de dados para digitação ou consulta
function dscShowHideDiv(show,hide) {
	var divShow = show.split(";");
	var divHide = hide.split(";");
	
	for (var i = 0; i < divShow.length; i++) {
		$("#" + divShow[i]).css("display","block");
	}
	
	for (var i = 0; i < divHide.length; i++) {
		$("#" + divHide[i]).css("display","none");
	}	
}

// Função para bloqueio do background do divRotina
function metodoBlock(){
	blockBackground(parseInt($("#divRotina").css("z-index")));
}

// ROTINA TITULOS
// Mostrar o <div> sobre desconto de títulos
function carregaTitulos() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados de desconto de t&iacute;tulos ...");

	// Carrega biblioteca javascript da rotina
	// Ao carregar efetua chamada do conteúdo da rotina através de ajax
	$.getScript(UrlSite + "telas/atenda/descontos/titulos/titulos.js",function() {
		$.ajax({		
			type: "POST", 
			url: UrlSite + "telas/atenda/descontos/titulos/titulos_principal.php",
			dataType: "html",
			data: {
				nrdconta: nrdconta,
				cdproduto: cdproduto,
				executandoProdutos: executandoProdutos,
				redirect: "html_ajax"
			},		
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function(response) {
				$("#divOpcoesDaOpcao1").html(response);
			}				
		}); 
	});			
}

// ROTINA CHEQUES
// Mostrar o <div> sobre desconto de cheques
function carregaCheques() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados de desconto de cheques ...");
	
	// Carrega biblioteca javascript da rotina
	// Ao carregar efetua chamada do conteúdo da rotina através de ajax
	$.getScript(UrlSite + "telas/atenda/descontos/cheques/cheques.js",function() {
		$.ajax({		
			type: "POST", 
			url: UrlSite + "telas/atenda/descontos/cheques/cheques.php",
			dataType: "html",
			data: {
				nrdconta: nrdconta,
				cdproduto: cdproduto,
				executandoProdutos: executandoProdutos,
				redirect: "html_ajax"
			},		
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function(response) {
				$("#divOpcoesDaOpcao1").html(response);
			}				
		}); 
	});			
}

// Função para formata o layout
function controlaLayout() {
	
	layoutPadrao();
	
	return false;
}

function formataLayout(nomeForm){

	if(typeof nomeForm == 'undefined'){ return false;}
	
	$('#'+nomeForm).addClass('formulario');
	
	var cTodosCampos = $('select,input', '#' + nomeForm);
	
	highlightObjFocus( $('#' + nomeForm) );
	
	if( nomeForm == 'frmCheques' ){
	
		var Lnrctrlim = $('label[for="nrctrlim"]','#'+nomeForm);
		var Ldtinivig = $('label[for="dtinivig"]','#'+nomeForm);
		var Lqtdiavig = $('label[for="qtdiavig"]','#'+nomeForm);
		var Lvllimite = $('label[for="vllimite"]','#'+nomeForm);
		var Lqtrenova = $('label[for="qtrenova"]','#'+nomeForm);
		var Ldsdlinha = $('label[for="dsdlinha"]','#'+nomeForm);
		var Lvlutiliz = $('label[for="vlutiliz"]','#'+nomeForm);
		var Linsitblq = $('label[for="insitblq"]','#'+nomeForm);
		
		var Cnrctrlim = $('#nrctrlim','#'+nomeForm);
		var Cdtinivig = $('#dtinivig','#'+nomeForm);
		var Cqtdiavig = $('#qtdiavig','#'+nomeForm);
		var Cvllimite = $('#vllimite','#'+nomeForm);
		var Cqtrenova = $('#qtrenova','#'+nomeForm);
		var Cdsdlinha = $('#dsdlinha','#'+nomeForm);
		var Cvlutiliz = $('#vlutiliz','#'+nomeForm);
		var Cinsitblq = $('#insitblq','#'+nomeForm);
		var Cperrenov = $('#hd_perrenov','#'+nomeForm);
		var Chd_insitblq = $('#hd_insitblq','#'+nomeForm);
		$('#'+nomeForm).css('width','430px');
		
		Lnrctrlim.addClass('rotulo').css('width','80px');
		Ldtinivig.css('width','60px');
		Lqtdiavig.css('width','60px');
		Lvllimite.addClass('rotulo').css('width','80px');
		Lqtrenova.css('width','158px');
		Ldsdlinha.addClass('rotulo').css('width','155px');
		Lvlutiliz.addClass('rotulo').css('width','155px');
		Linsitblq.addClass('rotulo').css('width','155px');
		
		Cnrctrlim.css({'width':'60px','text-align':'right'});
		Cdtinivig.css({'width':'65px','text-align':'center'});
		Cqtdiavig.css({'width':'60px','text-align':'right'});
		Cvllimite.css({'width':'90px','text-align':'right'});
		Cqtrenova.css({'width':'60px','text-align':'right'});
		Cdsdlinha.css({'width':'200px'});
		Cinsitblq.css({'width':'80px'});
		
		Cnrctrlim.desabilitaCampo();
		Cdtinivig.desabilitaCampo();
		Cqtdiavig.desabilitaCampo();
		Cvllimite.desabilitaCampo();
		Cqtrenova.desabilitaCampo();
		Cdsdlinha.desabilitaCampo();
		Cvlutiliz.desabilitaCampo();
		Cinsitblq.desabilitaCampo();
		
		if (Cperrenov.val() != 1) {
			$('#btnrenovacao').css({'color':'gray'});
			$('#btnrenovacao').css({'cursor':'default'});
			$('#btnrenovacao').css({'pointer-events':'none'});
		}
		
		if (Chd_insitblq.val() != 1) {
			$('#btndesinbord').css({'color':'gray'});	 
			$('#btndesinbord').css({'cursor':'default'});
			$('#btndesinbord').css({'pointer-events':'none'});
		}
		
		$('#btnrenovacao').unbind('click').bind('click', function(){
			if (Cperrenov.val() != 1) {return false}
			acessaValorLimite();
			return false;			
		});
		
		$('#btndesinbord').unbind('click').bind('click', function(){
			if (Chd_insitblq.val() != 1) {return false}
			showConfirmacao("Confirma Desbloqueio da Inclus&atilde;o de Border&ocirc;?", "Confirma&ccedil;&atilde;o - Aimaro", "desbloqueiaInclusaoBordero();", "blockBackground(parseInt($('#divRotina').css('z-index')));", "sim.gif", "nao.gif");
			return false;			
		});
				
	}else if ( nomeForm == 'divBorderos' ){
	
		$('#'+nomeForm).css('width','885px');
	
		var divRegistro = $('div.divRegistros','#'+nomeForm);		
		var tabela      = $('table', divRegistro );
						
		divRegistro.css('height','110px');
		
		var ordemInicial = new Array();
				
		var arrayLargura = new Array();
		arrayLargura[0] = '60px';
		arrayLargura[1] = '60px';
		arrayLargura[2] = '60px';
		arrayLargura[3] = '60px';
		arrayLargura[4] = '80px';
		arrayLargura[5] = '60px';
		arrayLargura[6] = '80px';
		arrayLargura[7] = '80px';
		arrayLargura[8] = '120px';
		
				
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'center';
		arrayAlinha[6] = 'right';
		arrayAlinha[7] = 'center';
		arrayAlinha[8] = 'center';
		arrayAlinha[9] = 'center';
						
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();		
			}
		});
		
		ajustarCentralizacao();
	
	}else if ( nomeForm == 'divBorderosTitulos' ){
	
		var divRegistro = $('div.divRegistros','#'+nomeForm);		
		var tabela      = $('table', divRegistro );
						
		divRegistro.css('height','110px');
		
		var ordemInicial = new Array();
				
		if(flgverbor){
			$('#'+nomeForm).css('width','1005px');
			var arrayLargura = new Array();
			arrayLargura[0] = '60px';
			arrayLargura[1] = '60px';
			arrayLargura[2] = '60px';
			arrayLargura[3] = '60px';
			arrayLargura[4] = '60px';
			arrayLargura[5] = '60px';
			arrayLargura[6] = '80px';
			arrayLargura[7] = '110px';
			arrayLargura[8] = '110px';
			arrayLargura[9] = '110px';
			arrayLargura[10] = '';
			
					
			var arrayAlinha = new Array();
			arrayAlinha[0] = 'center';
			arrayAlinha[1] = 'center';
			arrayAlinha[2] = 'center';
			arrayAlinha[3] = 'center';
			arrayAlinha[4] = 'right';
			arrayAlinha[5] = 'center';
			arrayAlinha[6] = 'right';
			arrayAlinha[7] = 'center';
			arrayAlinha[8] = 'center';
			arrayAlinha[9] = 'center';
			arrayAlinha[10] = 'center';
		}
		else{
			$('#'+nomeForm).css('width','745px');
			var arrayLargura = new Array();
			arrayLargura[0] = '80px';
			arrayLargura[1] = '80px';
			arrayLargura[2] = '80px';
			arrayLargura[3] = '70px';
			arrayLargura[4] = '100px';
			arrayLargura[5] = '120px';
			arrayLargura[6] = '80px';
			arrayLargura[7] = '';
					
			var arrayAlinha = new Array();
			arrayAlinha[0] = 'center';
			arrayAlinha[1] = 'right';
			arrayAlinha[2] = 'right';
			arrayAlinha[3] = 'right';
			arrayAlinha[4] = 'right';
			arrayAlinha[5] = 'center';
			arrayAlinha[6] = 'center';
			arrayAlinha[7] = 'center';
		}
						
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();		
			}
		});
		
		ajustarCentralizacao();
	}else if( nomeForm == 'divTitulosUltAlteracoes' ){
		var divRegistro = $('div.divRegistros','#'+nomeForm);		
		var tabela      = $('table', divRegistro );
		var ordemInicial = new Array();
		var arrayLargura = new Array();

		$('#'+nomeForm).css('width','700px');
	    divRegistro.css({'height': '255px', 'padding-bottom': '2px'});

		arrayLargura[0] = '60px'; // Contrato
		arrayLargura[1] = '80px'; // Dt Ini
		arrayLargura[2] = '80px'; // Dt Fim
		arrayLargura[3] = '80px'; // Vl Limite
		arrayLargura[4] = '80px'; // Situacao
		arrayLargura[5] = '80px'; // Dt Situacao
		//arrayLargura[5] = '80px'; // Motivo
		
				
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'center';
		arrayAlinha[5] = 'center';
		arrayAlinha[6] = 'center';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();		
			}
		});
		
		ajustarCentralizacao();
	}else if ( nomeForm == 'divBorderoTitulosPagar' ){
		var divRegistro = $('div.divRegistros','#'+nomeForm);		
		var tabela      = $('table', divRegistro );
		var ordemInicial = new Array();
		var arrayLargura = new Array();

		$('#'+nomeForm).css('width','910');

		arrayLargura[0] = '70px';
		arrayLargura[1] = '50px';
		arrayLargura[2] = '90px';
		arrayLargura[3] = '90px';
		arrayLargura[4] = '60px';
		arrayLargura[5] = '60px';
		arrayLargura[6] = '80px';
		arrayLargura[7] = '70px';
		arrayLargura[8] = '70px';
		arrayLargura[9] = '70px';
		
				
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
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();		
			}
		});
		
		ajustarCentralizacao();
	}else if ( nomeForm == 'divIncluirBordero' ){
		$('#'+nomeForm).css('width','940px');
		var camposFiltros = $("input[type='text'],select",'#'+nomeForm);
		camposFiltros.desabilitaCampo();
		var divRegistrosTitulos 			= $('div.divRegistrosTitulos','#'+nomeForm);		
		var divRegistrosTitulosSelecionados = $('div.divRegistrosTitulosSelecionados','#'+nomeForm);		
		var tabelaTitulos      				= $('table', divRegistrosTitulos );
		var tabelaTitulosSelecionados   	= $('table', divRegistrosTitulosSelecionados );
						
		var rNrctrlim = $("label[for='nrctrlim']");
		var rVlutiliz = $("label[for='vlutiliz']");
		var rVldispon = $("label[for='vldispon']");
		var rNrinssac = $("label[for='nrinssac']");
	    var rNmdsacad = $("label[for='nmdsacad']");
	    var rDtvencto = $("label[for='dtvencto']");
	    var rVltitulo = $("label[for='vltitulo']");
	    var rNrnosnum = $("label[for='nrnosnum']");
	    var rQtseleci = $("label[for='qtseleci']");
	    var rVlseleci = $("label[for='vlseleci']");
	    var rVlsaldor = $("label[for='vlsaldor']");
	    var rNrborder = $("label[for='nrborder']");

		rNrctrlim.css({'width': '115px'}).addClass('rotulo');
		rVlutiliz.css({'width': '180px'}).addClass('rotulo-linha');
		rVldispon.css({'width': '150px'}).addClass('rotulo-linha');
		rNrinssac.css({'width': '115px'}).addClass('rotulo');
		rNmdsacad.css({'width': '114px'}).addClass('rotulo-linha');
		rDtvencto.css({'width': '115px'}).addClass('rotulo');
		rVltitulo.css({'width': '133px'}).addClass('rotulo-linha');
		rNrnosnum.css({'width': '110px'}).addClass('rotulo-linha');
	    rQtseleci.css({'width': '115px'}).addClass('rotulo');
	    rVlseleci.css({'width': '180px'}).addClass('rotulo-linha');
	    rVlsaldor.css({'width': '150px'}).addClass('rotulo-linha');
	    rNrborder.css({'width': '115px'}).addClass('rotulo');

		var cNrdconta = $("#nrdconta", "#"+nomeForm);
		var cNrctrlim = $("#nrctrlim", "#"+nomeForm);
		var cVlutiliz = $("#vlutiliz", "#"+nomeForm);
		var cVldispon = $("#vldispon", "#"+nomeForm);
		var cNrinssac = $("#nrinssac", "#"+nomeForm);
		var cNmdsacad = $("#nmdsacad", "#"+nomeForm);
		var cDtvencto = $("#dtvencto", "#"+nomeForm);
		var cVltitulo = $("#vltitulo", "#"+nomeForm);
		var cNrnosnum = $("#nrnosnum", "#"+nomeForm);
		var cQtseleci = $("#qtseleci", "#"+nomeForm);
		var cVlseleci = $("#vlseleci", "#"+nomeForm);
	    var cVlsaldor = $("#vlsaldor", "#"+nomeForm);
	    var cNrborder = $("#nrborder", "#"+nomeForm);


		cNrctrlim.css({'width': '115px'}).addClass('inteiro');
		cVlutiliz.css({'width': '110px'}).addClass('monetario');
		cVldispon.css({'width': '110px'}).addClass('monetario');
		cNrinssac.css({'width': '115px'}).addClass('inteiro').attr('maxlength', '14').habilitaCampo();
		cNmdsacad.css({'width': '250px'});
		cDtvencto.css({'width': '115px'}).addClass('data').habilitaCampo();
		cVltitulo.css({'width': '110px'}).addClass('monetario').habilitaCampo();
		cNrnosnum.css({'width': '70px'}).addClass('inteiro').habilitaCampo();
		cQtseleci.css({'width': '115px'}).addClass('inteiro');
		cVlseleci.css({'width': '110px'}).addClass('monetario');
		cVlsaldor.css({'width': '110px'}).addClass('monetario');
		cNrborder.css({'width': '115px'}).addClass('inteiro');


		var ordemInicial = new Array();
				
						
	    $('#' + nomeForm).css({'margin-top': '5px'});
	    divRegistrosTitulos.css({'height': '210px', 'padding-bottom': '2px'});
	    divRegistrosTitulosSelecionados.css({'height': '210px', 'padding-bottom': '2px'});

		tabelaTitulos.formataTabela( ordemInicial, arrayLarguraInclusaoBordero, arrayAlinhaInclusaoBordero, '' );
		tabelaTitulosSelecionados.formataTabela( ordemInicial, arrayLarguraInclusaoBordero, arrayAlinhaInclusaoBordero, '' );
		
		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();		
			}
		});


	    btLupaPagador = $('#btLupaPagador','#'+nomeForm);
	    btLupaPagador.css('cursor', 'pointer').unbind('click').bind('click', function () {
	        if ((cNrinssac.hasClass('campoTelaSemBorda'))) return false;
	        mostraPesquisaPagador(cNrdconta.val(),nomeForm);
	        return false;
	     });

	    cNrinssac.unbind('keypress').unbind('change').bind('change keypress', function(e) {
	        if ((e.keyCode == 9 || e.keyCode == 13 || e.type ==='change')) {
	            if(cNrinssac.val()!=''){
	                buscaPagador(cNrdconta.val(),cNrinssac.val(),nomeForm);
	            }
	            else{
	            	cNmdsacad.val('');
	            }
	            return false;
	        }
	    });

	    cDtvencto.unbind('keypress').bind('keypress', function(e) {
	        if ((e.keyCode == 9 || e.keyCode == 13)) {
	            cVltitulo.focus();
	            return false;
	        }
	    });

	    cVltitulo.unbind('keypress').bind('keypress', function(e) {
	        if ((e.keyCode == 9 || e.keyCode == 13)) {
	            cNrnosnum.focus();
	            return false;
	        }
	    });

	    cNrnosnum.unbind('keypress').bind('keypress', function(e) {
	        if ((e.keyCode == 9 || e.keyCode == 13)) {
	            buscarTitulosBordero();
	            return false;
	        }
	    });

		layoutPadrao();
		ajustarCentralizacao();
	
	}else if( nomeForm == 'frmBordero' ){
	
		var Ldsprejuz = $('label[for="dsprejuz"]','#'+nomeForm);
		var Ldspesqui = $('label[for="dspesqui"]','#'+nomeForm);
		var Lnrborder = $('label[for="nrborder"]','#'+nomeForm);
		var Lnrctrlim = $('label[for="nrctrlim"]','#'+nomeForm);
		var Ldsdlinha = $('label[for="dsdlinha"]','#'+nomeForm);
		var Lqttitulo = $('label[for="qttitulo"]','#'+nomeForm);
		var Ldsopedig = $('label[for="dsopedig"]','#'+nomeForm);
		var Lvltitulo = $('label[for="vltitulo"]','#'+nomeForm);
		var Ltxmensal = $('label[for="txmensal"]','#'+nomeForm);
		var Ldtlibbdt = $('label[for="dtlibbdt"]','#'+nomeForm);
		var Ltxdiaria = $('label[for="txdiaria"]','#'+nomeForm);
		var Ldsopelib = $('label[for="dsopelib"]','#'+nomeForm);
		var Ltxjurmor = $('label[for="txjurmor"]','#'+nomeForm);
		var Linnivris = $('label[for="innivris"]','#'+nomeForm);
		var Lqtdiaatr = $('label[for="qtdiaatr"]','#'+nomeForm);
		
		var Cdspesqui = $('#dspesqui','#'+nomeForm);
		var Cnrborder = $('#nrborder','#'+nomeForm);
		var Cnrctrlim = $('#nrctrlim','#'+nomeForm);
		var Cdsdlinha = $('#dsdlinha','#'+nomeForm);
		var Cqttitulo = $('#qttitulo','#'+nomeForm);
		var Cdsopedig = $('#dsopedig','#'+nomeForm);
		var Cvltitulo = $('#vltitulo','#'+nomeForm);
		var Ctxmensal = $('#txmensal','#'+nomeForm);
		var Cdtlibbdt = $('#dtlibbdt','#'+nomeForm);
		var Ctxdiaria = $('#txdiaria','#'+nomeForm);
		var Cdsopelib = $('#dsopelib','#'+nomeForm);
		var Ctxjurmor = $('#txjurmor','#'+nomeForm);
		var Cinnivris = $('#innivris','#'+nomeForm);
		var Cqtdiaatr = $('#qtdiaatr','#'+nomeForm);
		
		$('#'+nomeForm).css('width','480px');
		
		Ldspesqui.addClass('rotulo').css('width','170px');
		Ldsprejuz.addClass('rotulo').css({'width':'450px','text-align':'center'});
		Lnrborder.addClass('rotulo').css('width','170px');
		Lnrctrlim.css('width','72px');
		Ldsdlinha.addClass('rotulo').css('width','170px');
		
		Lqttitulo.addClass('rotulo').css('width','110px');
		Ldsopedig.css('width','110px');
		Lvltitulo.addClass('rotulo').css('width','110px');
		Ltxmensal.addClass('rotulo').css('width','110px');
		Ldtlibbdt.css('width','110px');
		Ltxdiaria.addClass('rotulo').css('width','110px');
		Ldsopelib.css('width','110px');
		Ltxjurmor.addClass('rotulo').css('width','110px');
		Linnivris.css('width','110px');
		Lqtdiaatr.css('width','110px');
		
		Cdspesqui.css({'width':'200px'});
		Cnrborder.css({'width':'60px','text-align':'right'});
		Cnrctrlim.css({'width':'65px','text-align':'right'});
		Cdsdlinha.css({'width':'200px'});
		Cqttitulo.css({'width':'100px','text-align':'right'});
		Cdsopedig.css({'width':'100px'});
		Cvltitulo.css({'width':'100px','text-align':'right'});
		Ctxmensal.css({'width':'100px','text-align':'right'});
		Cdtlibbdt.css({'width':'100px'});
		Ctxdiaria.css({'width':'100px','text-align':'right'});
		Cdsopelib.css({'width':'100px'});
		Ctxjurmor.css({'width':'100px'});
		Cinnivris.css({'width':'100px'});
		Cqtdiaatr.css({'width':'100px'});
		
		Cdspesqui.desabilitaCampo();
		Cnrborder.desabilitaCampo();
		Cnrctrlim.desabilitaCampo();
		Cdsdlinha.desabilitaCampo();
		Cqttitulo.desabilitaCampo();
		Cdsopedig.desabilitaCampo();
		Cvltitulo.desabilitaCampo();
		Ctxmensal.desabilitaCampo();
		Cdtlibbdt.desabilitaCampo();
		Ctxdiaria.desabilitaCampo();
		Cdsopelib.desabilitaCampo();
		Ctxjurmor.desabilitaCampo();
		Cinnivris.desabilitaCampo();
		Cqtdiaatr.desabilitaCampo();
			
	}else if ( nomeForm == 'divPropostas' ){

		$('#'+nomeForm).css('width','1030px');

		var divRegistro = $('div.divRegistros','#'+nomeForm);
		var tabela      = $('table', divRegistro );

		divRegistro.css('height','135px');

		var ordemInicial = new Array();

		var arrayLargura = new Array();

		arrayLargura[0]  = '75px'; // data proposta
		arrayLargura[1]  = '75px'; // contrato
		arrayLargura[2]  = '75px'; // proposta
		arrayLargura[3]  = '90px'; // valor
		arrayLargura[4]  = '40px'; // dias vigência
		arrayLargura[5]  = '40px'; // linha desconto
		arrayLargura[6]  = '100px'; // situação proposta
		arrayLargura[7]  = '130px'; // situação análise
		arrayLargura[8]  = '130px'; // decisão
		// [14/02/2019]
		arrayLargura[9]  = '60px'; // nota rating
		// arrayLargura[10] = '60px'; // origem
		// [14/02/2019]

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
        
		// [14/02/2019]
		arrayAlinha[9] = 'center';
		arrayAlinha[10] = 'center';
		// [14/02/2019]

		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();
			}
		});

		ajustarCentralizacao();

	}else if ( nomeForm == 'divContratos' ){

		$('#'+nomeForm).css('width','800px');
	
		var divRegistro = $('div.divRegistros','#'+nomeForm);		
		var tabela      = $('table', divRegistro );
						
		divRegistro.css('height','135px');
		
		var ordemInicial = new Array();
				
		var arrayLargura = new Array();


		arrayLargura[0] = '80px';
		arrayLargura[1] = '60px';
		arrayLargura[2] = '60px';
		arrayLargura[3] = '60px';
		arrayLargura[4] = '60px';
		arrayLargura[5] = '120px';
				
		var arrayAlinha = new Array();
		
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'center';
		arrayAlinha[5] = 'center';
		arrayAlinha[6] = 'center';
						
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();		
			}
		});
	
		ajustarCentralizacao();

	}else if( nomeForm == 'divLimites' ){

		$('#'+nomeForm).css('width','800px');

		var divRegistro = $('div.divRegistros','#'+nomeForm);
		var tabela      = $('table', divRegistro );

		divRegistro.css('height','135px');
		
		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '60px';
		arrayLargura[1] = '60px';
		arrayLargura[2] = '60px';
		arrayLargura[3] = '80px';
		arrayLargura[4] = '40px';
		arrayLargura[5] = '40px';
		arrayLargura[6] = '90px';
		arrayLargura[7] = '80px';
		arrayLargura[8] = '50px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'center';
		arrayAlinha[5] = 'center';
		arrayAlinha[6] = 'center';
		arrayAlinha[7] = 'center';
		arrayAlinha[8] = 'center';
		arrayAlinha[9] = 'center';

		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();
			}
		});

		ajustarCentralizacao();

	}else if ( nomeForm == 'frmDadosLimiteDscChq' || nomeForm == 'frmDadosLimiteDscTit'){

		var Lnrctrlim = $('label[for="nrctrlim"]','#'+nomeForm);
		var Lvllimite = $('label[for="vllimite"]','#'+nomeForm);
		var Lqtdiavig = $('label[for="qtdiavig"]','#'+nomeForm);
		var Lcddlinha = $('label[for="cddlinha"]','#'+nomeForm);
		
		var Cnrctrlim = $('#nrctrlim','#'+nomeForm);
		var Cvllimite = $('#vllimite','#'+nomeForm);
		var Cqtdiavig = $('#qtdiavig','#'+nomeForm);
		var Ccddlinha = $('#cddlinha','#'+nomeForm);
		var Ccddlinh2 = $('#cddlinh2','#'+nomeForm);
		
		
		var Ltxjurmor = $('label[for="txjurmor"]','#'+nomeForm);
		var Ltxdmulta = $('label[for="txdmulta"]','#'+nomeForm);
		var Ldsramati = $('label[for="dsramati"]','#'+nomeForm);
		var Lvlmedtit = $('label[for="vlmedtit"]','#'+nomeForm);
		var Lvlfatura = $('label[for="vlfatura"]','#'+nomeForm);
		var Ldtcancel = $('label[for="dtcancel"]','#'+nomeForm);
		
		var Ctxjurmor = $('#txjurmor','#'+nomeForm);
		var Ctxdmulta = $('#txdmulta','#'+nomeForm);
		var Cdsramati = $('#dsramati','#'+nomeForm);
		var Cvlmedtit = $('#vlmedtit','#'+nomeForm);
		var Cvlfatura = $('#vlfatura','#'+nomeForm);
		var Cdtcancel = $('#dtcancel','#'+nomeForm);

		
		var Llbrendas = $('label[for="lbrendas"]','#'+nomeForm);
		var Lvlsalari = $('label[for="vlsalari"]','#'+nomeForm);
		var Lvlsalcon = $('label[for="vlsalcon"]','#'+nomeForm);
		var Lvloutras = $('label[for="vloutras"]','#'+nomeForm);
		var Ldsdbens1 = $('label[for="dsdbens1"]','#'+nomeForm);
		var Ldsdbens2 = $('label[for="dsdbens2"]','#'+nomeForm);
				
		var Cvlsalari = $('#vlsalari','#'+nomeForm);
		var Cvlsalcon = $('#vlsalcon','#'+nomeForm);
		var Cvloutras = $('#vloutras','#'+nomeForm);
		var Cdsdbens1 = $('#dsdbens1','#'+nomeForm);
		var Cdsdbens2 = $('#dsdbens2','#'+nomeForm);

		
		var Ldsobserv = $('label[for="dsobserv"]','#'+nomeForm);
		var Cdsobserv = $('#dsobserv','#'+nomeForm);
		
		$('#'+nomeForm).css('width','515px');
		
		Lnrctrlim.addClass('rotulo').css('width','150px');
		Lvllimite.addClass('rotulo').css('width','150px');
		Lqtdiavig.css('width','130px');
		Lcddlinha.addClass('rotulo').css('width','150px');
		Ltxjurmor.addClass('rotulo').css('width','150px');
		Ltxdmulta.addClass('rotulo').css('width','150px');
		Ldsramati.addClass('rotulo').css('width','150px');
		Lvlmedtit.addClass('rotulo').css('width','150px');
		Lvlfatura.addClass('rotulo').css('width','150px');
		Ldtcancel.css('width','130px');
		
		Cnrctrlim.css({'width':'100px','text-align':'right'});
		Cvllimite.css({'width':'100px','text-align':'right'});
		Cqtdiavig.css({'width':'65px','text-align':'right'});
		Ccddlinha.css({'width':'40px','text-align':'right'});
		Ccddlinh2.css({'width':'255px'});
		Ctxjurmor.css({'width':'100px','text-align':'right'});
		Ctxdmulta.css({'width':'100px','text-align':'right'});
		Cdsramati.css({'width':'300px'});
		Cvlmedtit.css({'width':'100px','text-align':'right'});
		Cvlfatura.css({'width':'100px','text-align':'right'});
		Cdtcancel.css({'width':'65px'});
		
		
		Llbrendas.addClass('rotulo').css('width','80px');
		Lvlsalari.css('width','50px');
		Lvlsalcon.addClass('rotulo-linha');
		Lvloutras.addClass('rotulo').css('width','130px');
		Ldsdbens1.addClass('rotulo').css('width','80px');
		Ldsdbens2.addClass('rotulo').css('width','80px');
			
		Cvlsalari.css({'width':'100px','text-align':'right'});
		Cvlsalcon.css({'width':'100px','text-align':'right'});
		Cvloutras.css({'width':'100px','text-align':'right'});
		Cdsdbens1.css({'width':'350px','text-align':'left'});
		Cdsdbens2.css({'width':'350px','text-align':'left'});
							
		Cdsobserv.addClass('alphanum').css({'width':'485px','height':'80px','float':'left','margin':'3px 0px 3px 3px','padding-right':'1px'});
		
		
		Cnrctrlim.unbind('keypress').bind('keypress', function(e){
			/*Se foi pressionado a telca ENTER*/
			if(e.keyCode == 13){
				Cvllimite.focus();
			}
		});
		
		Cvllimite.unbind('keypress').bind('keypress', function(e){
			/*Se foi pressionado a telca ENTER*/
			if(e.keyCode == 13){
				Ccddlinha.focus();
			}
		});
		
		Cdsramati.unbind('keypress').bind('keypress', function(e){
			/*Se foi pressionado a telca ENTER*/
			if(e.keyCode == 13){
				Cvlmedtit.focus();
			}
		});
		
		Cvlmedtit.unbind('keypress').bind('keypress', function(e){
			/*Se foi pressionado a telca ENTER*/
			if(e.keyCode == 13){
				Cvlfatura.focus();
			}
		});
		
		Cvlsalari.unbind('keypress').bind('keypress', function(e){
			/*Se foi pressionado a telca ENTER*/
			if(e.keyCode == 13){
				Cvlsalcon.focus();
			}
		});
		
		Cvlsalcon.unbind('keypress').bind('keypress', function(e){
			/*Se foi pressionado a telca ENTER*/
			if(e.keyCode == 13){
				Cvloutras.focus();
			}
		});
		
		Cvloutras.unbind('keypress').bind('keypress', function(e){
			/*Se foi pressionado a telca ENTER*/
			if(e.keyCode == 13){
					Cdsdbens1.focus();
			}
		});
		
		Cdsdbens1.unbind('keypress').bind('keypress', function(e){
			/*Se foi pressionado a telca ENTER*/
			if(e.keyCode == 13){
					Cdsdbens2.focus();
			}
		});
		
	}else if( nomeForm == 'frmTitulos' ){
	
		var Lnrctrlim = $('label[for="nrctrlim"]','#'+nomeForm);
		var Ldtinivig = $('label[for="dtinivig"]','#'+nomeForm);
		var Lqtdiavig = $('label[for="qtdiavig"]','#'+nomeForm);
		var Lvllimite = $('label[for="vllimite"]','#'+nomeForm);
		var Lqtrenova = $('label[for="qtrenova"]','#'+nomeForm);
		var Ldsdlinha = $('label[for="dsdlinha"]','#'+nomeForm);
		var Lvlutilcr = $('label[for="vlutilcr"]','#'+nomeForm);
		var Lvlutilsr = $('label[for="vlutilsr"]','#'+nomeForm);
		var Ldtrenova = $('label[for="dtrenova"]','#'+nomeForm);
		var Ldtultmnt = $('label[for="dtultmnt"]','#'+nomeForm);
		
		var Cnrctrlim = $('#nrctrlim','#'+nomeForm);
		var Cdtinivig = $('#dtinivig','#'+nomeForm);
		var Cqtdiavig = $('#qtdiavig','#'+nomeForm);
		var Cvllimite = $('#vllimite','#'+nomeForm);
		var Cqtrenova = $('#qtrenova','#'+nomeForm);
		var Cdsdlinha = $('#dsdlinha','#'+nomeForm);
		var Cvlutilcr = $('#vlutilcr','#'+nomeForm);
		var Cvlutilsr = $('#vlutilsr','#'+nomeForm);
		var Cdtrenova = $('#dtrenova','#'+nomeForm);
		var Cdtultmnt = $('#dtultmnt','#'+nomeForm);
		var Cperrenov = $('#hd_perrenov','#'+nomeForm);
		
		$('#'+nomeForm).css('width','530px');
		
		Lnrctrlim.addClass('rotulo').css('width','80px');
		Ldtinivig.css('width','60px');
		Lqtdiavig.css('width','60px');
		Lvllimite.addClass('rotulo').css('width','80px');
		Lqtrenova.css('width','158px');
		Ldsdlinha.addClass('rotulo').css('width','155px');
		Lvlutilcr.addClass('rotulo').css('width','200px');
		Lvlutilsr.addClass('rotulo').css('width','200px');
		Ldtrenova.addClass('rotulo').css('width','200px');
		Ldtultmnt.addClass('rotulo').css('width','200px');
		
		
		Cnrctrlim.css({'width':'60px','text-align':'right'});
		Cdtinivig.css({'width':'65px','text-align':'center'});
		Cqtdiavig.css({'width':'60px','text-align':'right'});
		Cvllimite.css({'width':'90px','text-align':'right'});
		Cqtrenova.css({'width':'60px','text-align':'right'});
		Cdsdlinha.css({'width':'200px'});
		Cvlutilcr.css({'width':'150px','text-align':'right'});
		Cvlutilsr.css({'width':'150px','text-align':'right'});
		Cdtrenova.css({'width':'150px','text-align':'right'});
		Cdtultmnt.css({'width':'150px','text-align':'right'});
		
		Cnrctrlim.desabilitaCampo();
		Cdtinivig.desabilitaCampo();
		Cqtdiavig.desabilitaCampo();
		Cvllimite.desabilitaCampo();
		Cqtrenova.desabilitaCampo();
		Cdsdlinha.desabilitaCampo();
		Cvlutilcr.desabilitaCampo();
		Cvlutilsr.desabilitaCampo();
		Cdtrenova.desabilitaCampo();
		Cdtultmnt.desabilitaCampo();

		if (Cperrenov.val() != 1) {
			$('#btnrenovacao').css({'color':'gray'});
			$('#btnrenovacao').css({'cursor':'default'});
			$('#btnrenovacao').css({'pointer-events':'none'});
		}


		$('#btnrenovacao').unbind('click').bind('click', function(){
			if (Cperrenov.val() != 1) {return false}
			renovarLimiteTitulo();
			return false;
		});


		$('#btnManutencao').unbind('click').bind('click', function(){
			var val_flgstlcr = 0;
			if($('#flgstlcr','#'+nomeForm).val() == "yes"){
				val_flgstlcr = 1;
			}
			realizarManutencaoDeLimite(0, val_flgstlcr);
			return false;
		});

	}else if ( nomeForm == 'divRestricoes' ){
	
		$('#'+nomeForm).css('width','690px');
	
		var divRegistro = $('div.divRegistros','#'+nomeForm);		
		var tabela      = $('table', divRegistro );
						
		divRegistro.css('height','110px');
		
		var ordemInicial = new Array();
				
		var arrayLargura = new Array();
		arrayLargura[0] = '80px';
		arrayLargura[1] = '350px';
				
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'left';
						
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	}else if ( nomeForm == 'divRestricoesTit' ){
	
		$('#'+nomeForm).css('width','690px');
	
		var divRegistro = $('div.divRegistros','#'+nomeForm);		
		var tabela      = $('table', divRegistro );
						
		divRegistro.css('height','110px');
		
		var ordemInicial = new Array();
				
		var arrayLargura = new Array();
		arrayLargura[0] = '350px';
				
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'left';
						
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	}else if ( nomeForm == 'frmBorderosIA'){
		$('#'+nomeForm).css('width','900px');
		
		var rNrborder = $('label[for="nrborder"]','#'+nomeForm);
		var rNrctrlim = $('label[for="nrctrlim"]','#'+nomeForm);
		var rVllimite = $('label[for="vllimite"]','#'+nomeForm);
		var rQtcompln = $('label[for="qtcompln"]','#'+nomeForm);
		var rVlcompcr = $('label[for="vlcompcr"]','#'+nomeForm);
		
		var cNrborder = $('#nrborder','#'+nomeForm);
		var cNrctrlim = $('#nrctrlim','#'+nomeForm);
		var cVllimite = $('#vllimite','#'+nomeForm);
		var cQtcompln = $('#qtcompln','#'+nomeForm);
		var cVlcompcr = $('#vlcompcr','#'+nomeForm);	
		
		rNrborder.addClass('rotulo').css('width','94px');
		rNrctrlim.addClass('rotulo-linha').css('width','100px');
		rVllimite.addClass('rotulo-linha').css('width','150px');
		rQtcompln.addClass('rotulo').css('width','300px');
		rVlcompcr.addClass('rotulo-linha').css('width','150px');		
		
		cNrborder.css({'width':'100px','text-align':'right'});
		cNrctrlim.css({'width':'100px','text-align':'right'});
		cVllimite.css({'width':'100px','text-align':'right'});
		cQtcompln.css({'width':'100px','text-align':'right'});
		cVlcompcr.css({'width':'100px','text-align':'right'});
		
		cTodosCampos.desabilitaCampo();
		
	    // tabela
		var divRegistro = $('div.divRegistros', '#divChqsBordero');
		var tabela = $('table', divRegistro);

		// $('#' + frmOpcao).css({'margin-top': '5px'});
		divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '73px';
		arrayLargura[1] = '30px';
		arrayLargura[2] = '30px';
		arrayLargura[3] = '30px';
		arrayLargura[4] = '69px';
		arrayLargura[5] = '59px';
		arrayLargura[6] = '210px';
		arrayLargura[7] = '100px';
		arrayLargura[8] = '70px';
		arrayLargura[9] = '59px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'left';
		arrayAlinha[7] = 'right';
		arrayAlinha[8] = 'right';
		arrayAlinha[9] = 'center';
		arrayAlinha[10] = 'center';

		tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
		ajustarCentralizacao();	
		formataTabelaEmiten();
	
	}else if ( nomeForm == 'frmChequesCustodia'){
		// Ajustar tamnaho do form
		$('#'+nomeForm).css('width','900px');
		
	    // tabela
		var divRegistroChq = $('#divCheques', '#' + nomeForm);
		var divRegistroSel = $('#divChequesSel', '#' + nomeForm);
		var tabelaChq = $('table', divRegistroChq);
		var tabelaSel = $('table', divRegistroSel);

		// $('#' + frmOpcao).css({'margin-top': '5px'});
		divRegistroChq.css({'height': '207px', 'padding-bottom': '2px'});
		divRegistroSel.css({'height': '107px', 'padding-bottom': '2px'});

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '73px';
		arrayLargura[1] = '30px';
		arrayLargura[2] = '30px';
		arrayLargura[3] = '30px';
		arrayLargura[4] = '69px';
		arrayLargura[5] = '59px';
		arrayLargura[6] = '210px';
		arrayLargura[7] = '100px';
		arrayLargura[8] = '70px';
		arrayLargura[9] = '59px';
		//arrayLargura[10] = '70px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'left';
		arrayAlinha[7] = 'right';
		arrayAlinha[8] = 'right';
		arrayAlinha[9] = 'center';
		arrayAlinha[10] = 'center';
		//arrayAlinha[10] = 'center';

		tabelaChq.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
		tabelaSel.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
		ajustarCentralizacao();	
	
	}else if( nomeForm == 'frmChequesCustodiaNovo'){		
		// Ajustar tamnaho do form
		$('#'+nomeForm).css('width','820px');
		
		var rDtlibera = $('label[for="dtlibera"]','#'+nomeForm); 
		var rDtdcaptu = $('label[for="dtdcaptu"]','#'+nomeForm); 
		var rVlcheque = $('label[for="vlcheque"]','#'+nomeForm);        
		var rDsdocmc7 = $('label[for="dsdocmc7"]','#'+nomeForm);        

		rDtlibera.addClass('rotulo').css({'width':'200px'});
		rDtdcaptu.addClass('rotulo-linha').css({'width':'120px'});
		rVlcheque.addClass('rotulo-linha').css({'width':'60px'});
		rDsdocmc7.addClass('rotulo').css({'width':'200px'});

		// input
		var cDtlibera = $('#dtlibera','#'+nomeForm); 
		var cDtdcaptu = $('#dtdcaptu','#'+nomeForm); 
		var cVlcheque = $('#vlcheque','#'+nomeForm); 
		var cDsdocmc7 = $('#dsdocmc7','#'+nomeForm); 
		var btnOk	  = $('#btnOk','#'+nomeForm);
		
		cDtlibera.css({'width':'75px'}).addClass('data');	
		cDtdcaptu.css({'width':'75px'}).addClass('data');	
		cVlcheque.css({'width':'110px'}).addClass('moeda');
		cDsdocmc7.css({'width':'290px'}).attr('maxlength','34');
	
		// Outros	
		cTodosCampos.habilitaCampo();
		// Foca no primeiro campo da tela
	 	cDtlibera.focus();
		// Data boa
		cDtlibera.unbind('keydown').bind('keydown', function(e) {
			// Se é a tecla TAB ou ENTER, 
			if (e.keyCode == 9 || e.keyCode == 13 ) {
				cDtdcaptu.focus();
				return false;
			}
		});
		cDtdcaptu.unbind('keydown').bind('keydown', function(e) {
			// Se é a tecla TAB ou ENTER, 
			if (e.keyCode == 9 || e.keyCode == 13 ) {
				cVlcheque.focus();
				return false;
			}
		});
		// Valor do cheque
		cVlcheque.unbind('keydown').bind('keydown', function(e) {
			// Se é a tecla TAB ou ENTER, 
			if (e.keyCode == 9 || e.keyCode == 13 ) {
				cDsdocmc7.focus();
				return false;
			}
		});
		// CMC 7
		cDsdocmc7.unbind('keyup').bind('keyup', function(e) {
			formataCampoCmc7(false, nomeForm);
			return false;
		});
		cDsdocmc7.unbind('blur').bind('blur', function(e) {
			formataCampoCmc7(true, nomeForm);
			return false;
		});
		cDsdocmc7.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }		

			// Se é a tecla ENTER, 
			if ( e.keyCode == 13 ) {
				btnOk.click();
				return false;

			}
		});	
		
		btnOk.unbind('click').bind('click', function() {
			if ( divError.css('display') == 'block' ) { return false; }		

			validaCheque();
			return false;
		});		
			
	    // tabela
		var divRegistroChq = $('#divCheques', '#' + nomeForm);
		var tabelaChq = $('table', divRegistroChq);

		// $('#' + frmOpcao).css({'margin-top': '5px'});
		divRegistroChq.css({'height': '207px', 'padding-bottom': '2px'});

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '73px';
		arrayLargura[1] = '73px';
		arrayLargura[2] = '30px';
		arrayLargura[3] = '30px';
		arrayLargura[4] = '30px';
		arrayLargura[5] = '84px';
		arrayLargura[6] = '59px';
		arrayLargura[7] = '85px';
		arrayLargura[8] = '59px';
		arrayLargura[9] = '140px';
		//arrayLargura[10] = '70px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'right';
		arrayAlinha[7] = 'right';
		arrayAlinha[8] = 'center';
		arrayAlinha[9] = 'left';
		arrayAlinha[10] = 'center';
		//arrayAlinha[10] = 'center';

		tabelaChq.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
		ajustarCentralizacao();	
	
	}else if(nomeForm == 'frmBorderosAnalise'){
		$('#'+nomeForm).css('width','1100px');
		
		var flgcheckd = 0;
		
		var rNrborder = $('label[for="nrborder"]','#'+nomeForm);
		var rNrctrlim = $('label[for="nrctrlim"]','#'+nomeForm);
		var rVllimite = $('label[for="vllimite"]','#'+nomeForm);
		var rQtcompln = $('label[for="qtcompln"]','#'+nomeForm);
		var rVlcompcr = $('label[for="vlcompcr"]','#'+nomeForm);
		
		var cNrborder = $('#nrborder','#'+nomeForm);
		var cNrctrlim = $('#nrctrlim','#'+nomeForm);
		var cVllimite = $('#vllimite','#'+nomeForm);
		var cQtcompln = $('#qtcompln','#'+nomeForm);
		var cVlcompcr = $('#vlcompcr','#'+nomeForm);	
		var cInsitana = $('#insitana','#'+nomeForm);	
		
		rNrborder.addClass('rotulo').css('width','194px');
		rNrctrlim.addClass('rotulo-linha').css('width','100px');
		rVllimite.addClass('rotulo-linha').css('width','150px');
		rQtcompln.addClass('rotulo').css('width','400px');
		rVlcompcr.addClass('rotulo-linha').css('width','150px');		
		
		cNrborder.css({'width':'100px','text-align':'right'});
		cNrctrlim.css({'width':'100px','text-align':'right'});
		cVllimite.css({'width':'100px','text-align':'right'});
		cQtcompln.css({'width':'100px','text-align':'right'});
		cVlcompcr.css({'width':'100px','text-align':'right'});
		
		cNrborder.desabilitaCampo();
		cNrctrlim.desabilitaCampo();
		cVllimite.desabilitaCampo();
		cQtcompln.desabilitaCampo();
		cVlcompcr.desabilitaCampo();
		
		cInsitana.change(function() {
			if ($(this).is(':checked')){
				flgcheckd = 1;
			}else{
				flgcheckd = 0;
			}
			$(this).val(flgcheckd);
		});
		
	    // tabela
		var divRegistro = $('div.divRegistros', '#divChqsBordero');
		var tabela = $('table', divRegistro);

		// $('#' + frmOpcao).css({'margin-top': '5px'});
		divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '55px';
		arrayLargura[1] = '30px';
		arrayLargura[2] = '30px';
		arrayLargura[3] = '30px';
		arrayLargura[4] = '69px';
		arrayLargura[5] = '59px';
		arrayLargura[6] = '210px';
		arrayLargura[7] = '100px';
		arrayLargura[8] = '70px';
		arrayLargura[9] = '268px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'left';
		arrayAlinha[7] = 'right';
		arrayAlinha[8] = 'right';
		arrayAlinha[9] = 'left';
		arrayAlinha[10] = 'center';

		tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
		ajustarCentralizacao();			
	
	}else if(nomeForm == 'frmBorderoResgate'){
		$('#'+nomeForm).css('width','820px');
		
		var rNrborder = $('label[for="nrborder"]','#'+nomeForm);
		var rNrctrlim = $('label[for="nrctrlim"]','#'+nomeForm);
		var rVlborder = $('label[for="vlborder"]','#'+nomeForm);
		var rDsdocmc7 = $('label[for="dsdocmc7"]','#'+nomeForm);        
		var rDsmsgcmc7 = $('#dsmsgcmc7','#'+nomeForm);        
		
		var cNrborder = $('#nrborder','#'+nomeForm);
		var cNrctrlim = $('#nrctrlim','#'+nomeForm);
		var cVlborder = $('#vlborder','#'+nomeForm);
		var cDsdocmc7 = $('#dsdocmc7','#'+nomeForm);
		var btnOk	  = $('#btnOk','#'+nomeForm);
		
		rNrborder.addClass('rotulo').css('width','150px');
		rNrctrlim.addClass('rotulo-linha').css('width','60px');
		rVlborder.addClass('rotulo-linha').css('width','60px');
		rDsdocmc7.addClass('rotulo').css({'width':'150px'});
		rDsmsgcmc7.addClass('rotulo-linha').css('width','200px');
		rDsmsgcmc7.css({'text-align':'left','margin-left':'3px'});
		
		cNrborder.css({'width':'100px','text-align':'right'});
		cNrctrlim.css({'width':'100px','text-align':'right'});
		cVlborder.css({'width':'100px','text-align':'right'});
		cDsdocmc7.css({'width':'290px'}).attr('maxlength','34');
		
		cTodosCampos.desabilitaCampo();
		cDsdocmc7.habilitaCampo();
		cDsdocmc7.focus();

		// CMC 7
		cDsdocmc7.unbind('keyup').bind('keyup', function(e) {
			formataCampoCmc7(false, nomeForm);
			return false;
		});
		cDsdocmc7.unbind('blur').bind('blur', function(e) {
			formataCampoCmc7(true, nomeForm);
			return false;
		});
		cDsdocmc7.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }		

			// Se é a tecla ENTER, 
			if ( e.keyCode == 13 ) {
				btnOk.click();
				return false;

			}
		});	

		btnOk.unbind('click').bind('click', function() {
			if ( divError.css('display') == 'block' ) { return false; }		
			selecionaChequeResgate();
			return false;
		});		
		
	    // tabela
		var divRegistro = $('div.divRegistros', '#divBorderoResgate');
		var tabela = $('table', divRegistro);

		divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '30px';
		arrayLargura[1] = '73px';
		arrayLargura[2] = '30px';
		arrayLargura[3] = '30px';
		arrayLargura[4] = '30px';
		arrayLargura[5] = '69px';
		arrayLargura[6] = '59px';
		arrayLargura[7] = '210px';
		arrayLargura[8] = '100px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'right';
		arrayAlinha[7] = 'left';
		arrayAlinha[8] = 'right';
		arrayAlinha[9] = 'right';

		tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
		ajustarCentralizacao();			
	
	}else if ( nomeForm == 'divTitulosBorderos' ){

		$('#'+nomeForm).css('width','1090px');

		var divcr = $('#divcr','#'+nomeForm);		
		var tabela      = $('table', divcr );

		divcr.css('height','235px');

		var ordemInicial = new Array();
				

		var arrayLargura = new Array();
		arrayLargura[0] = '65px';//Vencto
		arrayLargura[1] = '128px';//130 Nosso Número
		arrayLargura[2] = '60px';//Valor
		arrayLargura[3] = '60px';//Valor Líquido
		arrayLargura[4] = '25px';//Prz
		arrayLargura[5] = '';//Pagador
		arrayLargura[6] = '100px';// CPF/CNPJ
		arrayLargura[7] = '100px';//130 //Situação 50 30
		arrayLargura[8] = '100px';//130 //Decisao 50 30
		arrayLargura[9] = '60px';//Saldo Devedor
		arrayLargura[10] = '60px';//Nr Ctr Cyber
				
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';// Vencto
		arrayAlinha[1] = 'center';//Nosso número
		arrayAlinha[2] = 'right';//Valor
		arrayAlinha[3] = 'right';//Valor Lóquido
		arrayAlinha[4] = 'center';//Prz
		arrayAlinha[5] = 'left';//Pagador
		arrayAlinha[6] = 'center';// CPF/CNPJ
		arrayAlinha[7] = 'center';//Situação
		arrayAlinha[8] = 'center';//Decisao
		arrayAlinha[9] = 'right';//Saldo Devedor
		arrayAlinha[10] = 'center';//Saldo Devedor
						
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();		
			}
		});
		
		ajustarCentralizacao();
	
	}else if ( nomeForm == 'formDetalheTitulo' ){
		$('#'+nomeForm).css('width','500px');
		var Lnrborder = $('label[for="nrborder"]','#'+nomeForm);
		var Lnrnosnum = $('label[for="nrnosnum"]','#'+nomeForm);
		var Lqtdprazo = $('label[for="qtdprazo"]','#'+nomeForm);
		var Lvlrmulta = $('label[for="vlrmulta"]','#'+nomeForm);
		var Lvliofatr = $('label[for="vliofatr"]','#'+nomeForm);
		var Lvlslddvd = $('label[for="vlslddvd"]','#'+nomeForm);
		var Lnrctrcyb = $('label[for="nrctrcyb"]','#'+nomeForm);
		var Lnmdpagad = $('label[for="nmdpagad"]','#'+nomeForm);
		var Lnrcpfcnp = $('label[for="nrcpfcnp"]','#'+nomeForm);
		var Ldtdvenct = $('label[for="dtdvenct"]','#'+nomeForm);
		var Lvltitulo = $('label[for="vltitulo"]','#'+nomeForm);
		var Ldiasdatr = $('label[for="diasdatr"]','#'+nomeForm);
		var Lvljrmora = $('label[for="vljrmora"]','#'+nomeForm);
		var Lvlorpago = $('label[for="vlorpago"]','#'+nomeForm);
		var Lvlsdprej = $('label[for="vlsdprej"]','#'+nomeForm);

		var Cnrborder = $('#nrborder','#'+nomeForm);
		var Cnrnosnum = $('#nrnosnum','#'+nomeForm);
		var Cqtdprazo = $('#qtdprazo','#'+nomeForm);
		var Cvlrmulta = $('#vlrmulta','#'+nomeForm);
		var Cvliofatr = $('#vliofatr','#'+nomeForm);
		var Cvlslddvd = $('#vlslddvd','#'+nomeForm);
		var Cnrctrcyb = $('#nrctrcyb','#'+nomeForm);
		var Cnmdpagad = $('#nmdpagad','#'+nomeForm);
		var Cnrcpfcnp = $('#nrcpfcnp','#'+nomeForm);
		var Cdtdvenct = $('#dtdvenct','#'+nomeForm);
		var Cvltitulo = $('#vltitulo','#'+nomeForm);
		var Cdiasdatr = $('#diasdatr','#'+nomeForm);
		var Cvljrmora = $('#vljrmora','#'+nomeForm);
		var Cvlorpago = $('#vlorpago','#'+nomeForm);
		var Cvlsdprej = $('#vlsdprej','#'+nomeForm);

		Lnrborder.addClass('rotulo').css('width','120px');
		Ldtdvenct.addClass('rotulo-linha').css('width','140px');
		Lnrnosnum.addClass('rotulo').css('width','120px');
		Lvltitulo.addClass('rotulo-linha').css('width','90px');
		Lqtdprazo.addClass('rotulo').css('width','120px');
		Ldiasdatr.addClass('rotulo-linha').css('width','140px');
		Lvlrmulta.addClass('rotulo').css('width','120px');
		Lvljrmora.addClass('rotulo-linha').css('width','140px');
		Lvliofatr.addClass('rotulo').css('width','120px');
		Lvlorpago.addClass('rotulo-linha').css('width','140px');
		Lvlsdprej.addClass('rotulo-linha').css('width','140px');
		Lvlslddvd.addClass('rotulo').css('width','120px');
		Lnrctrcyb.addClass('rotulo').css('width','120px');
		Lnmdpagad.addClass('rotulo').css('width','120px');
		Lnrcpfcnp.addClass('rotulo').css('width','120px');

		Cnrborder.css({'width':'80px','text-align':'right'});
		Cdtdvenct.css({'width':'80px','text-align':'right'});
		Cnrnosnum.css({'width':'130px','text-align':'right'});
		Cvltitulo.css({'width':'80px','text-align':'right'});
		Cqtdprazo.css({'width':'80px','text-align':'right'});
		Cdiasdatr.css({'width':'80px','text-align':'right'});
		Cvlrmulta.css({'width':'80px','text-align':'right'});
		Cvljrmora.css({'width':'80px','text-align':'right'});
		Cvliofatr.css({'width':'80px','text-align':'right'});
		Cvlorpago.css({'width':'80px','text-align':'right'});
		Cvlsdprej.css({'width':'80px','text-align':'right'});
		Cvlslddvd.css({'width':'80px','text-align':'right'});
		Cnrctrcyb.css({'width':'80px','text-align':'right'});
		Cnmdpagad.css({'width':'308px','text-align':'left'});
		Cnrcpfcnp.css({'width':'120px','text-align':'right'});
				
		Cnrborder.desabilitaCampo();
		Cnrnosnum.desabilitaCampo();
		Cqtdprazo.desabilitaCampo();
		Cvlrmulta.desabilitaCampo();
		Cvliofatr.desabilitaCampo();
		Cvlslddvd.desabilitaCampo();
		Cnrctrcyb.desabilitaCampo();
		Cnmdpagad.desabilitaCampo();
		Cnrcpfcnp.desabilitaCampo();
		Cdtdvenct.desabilitaCampo();
		Cvltitulo.desabilitaCampo();
		Cdiasdatr.desabilitaCampo();
		Cvljrmora.desabilitaCampo();
		Cvlorpago.desabilitaCampo();
		Cvlsdprej.desabilitaCampo();
	}else if ( nomeForm == 'divResumoBordero' ){
	
		$('#'+nomeForm).css('width','940px');

		var camposFiltros = $("input[type='text'],select",'#'+nomeForm);
		camposFiltros.desabilitaCampo();
		var table = $('#divTitulos table','#'+nomeForm);		

		var ordemInicial = new Array();
						
	    $('#' + nomeForm).css({'margin-top': '5px'});
    	table.formataTabela( ordemInicial, arrayLarguraInclusaoBordero, arrayAlinhaInclusaoBordero, '' );

		
		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();		
			}
		});


		layoutPadrao();
		ajustarCentralizacao();
	
	}else if ( nomeForm == 'divDetalheBordero' ){
	
		$('#'+nomeForm).css('width','940px');
		
		

		//restrições	
		var divRestricoes 					= $('div.divRestricoes','#'+nomeForm);
		var tabelaRestricoes	   			= $('table', divRestricoes );
		
		var ordemInicial = new Array();
				
		var arrayLargura = new Array();
		arrayLargura[0] = '24%';
		arrayLargura[1] = '25%';
		arrayLargura[2] = '24%';
		arrayLargura[3] = '25%';
		

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';

	    divRestricoes.css({'height': '210px', 'padding-bottom': '1px'});

		tabelaRestricoes.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );


		// campos
		var cNmdsacad = $("#nmdsacad", "#"+nomeForm);
		cNmdsacad.css({'width': '450px'});

		var camposFiltros = $("input[type='text'],select",'#'+nomeForm);
		camposFiltros.desabilitaCampo();

		//criticas
		var divRegistrosTitulos 			= $('div.divRegistrosTitulos','#'+nomeForm);		
		var divRegistrosTitulosSelecionados = $('div.divRegistrosTitulosSelecionados','#'+nomeForm);		
		var tabelaTitulos      				= $('table', divRegistrosTitulos );
		var tabelaTitulosSelecionados   	= $('table', divRegistrosTitulosSelecionados );

	

		var ordemInicial = new Array();
				
		var arrayLargura = new Array();
		arrayLargura[0] = '48%';
		arrayLargura[1] = '50%';
		

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		
						
	    $('#' + nomeForm).css({'margin-top': '5px'});
	    divRegistrosTitulos.css({'height': '210px', 'padding-bottom': '2px'});
	    divRegistrosTitulosSelecionados.css({'height': '210px', 'padding-bottom': '2px'});

		tabelaTitulos.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		tabelaTitulosSelecionados.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();		
			}
		});


		layoutPadrao();
		ajustarCentralizacao();
	
	} else if (nomeForm == 'formDetalhePrejuizo') {
	    $('#' + nomeForm).css('width', '600px');
	    var Ldtprejuz = $('label[for="dtprejuz"]', '#' + nomeForm);
	    var Ltoprejuz = $('label[for="toprejuz"]', '#' + nomeForm);
	    var Ltosdprej = $('label[for="tosdprej"]', '#' + nomeForm);
	    var Ltopgmupr = $('label[for="topgmupr"]', '#' + nomeForm);
	    var Ltottmupr = $('label[for="tottmupr"]', '#' + nomeForm);
	    var Ltopgjmpr = $('label[for="topgjmpr"]', '#' + nomeForm);
	    var Lvlsldatu = $('label[for="vlsldatu"]', '#' + nomeForm);
	    var Ldiasatrs = $('label[for="diasatrs"]', '#' + nomeForm);
	    var Lvlaboprj = $('label[for="vlaboprj"]', '#' + nomeForm);
	    var Ltojrmprj = $('label[for="tojrmprj"]', '#' + nomeForm);
	    var Ltojraprj = $('label[for="tojraprj"]', '#' + nomeForm);
	    var Lvlacrprj = $('label[for="vlacrprj"]', '#' + nomeForm);
	    var Ltottjmpr = $('label[for="tottjmpr"]', '#' + nomeForm);
	    var Ltovlpago = $('label[for="tovlpago"]', '#' + nomeForm);
	    var Ltopgjrpr = $('label[for="topgjrpr"]', '#' + nomeForm);
	    var Ltoiofprj = $('label[for="toiofprj"]', '#' + nomeForm);
	    var Ltoiofppr = $('label[for="toiofppr"]', '#' + nomeForm);

	    var Cdtprejuz = $('#dtprejuz', '#' + nomeForm);
	    var Ctoprejuz = $('#toprejuz', '#' + nomeForm);
	    var Ctosdprej = $('#tosdprej', '#' + nomeForm);
	    var Ctopgmupr = $('#topgmupr', '#' + nomeForm);
	    var Ctottmupr = $('#tottmupr', '#' + nomeForm);
	    var Ctopgjmpr = $('#topgjmpr', '#' + nomeForm);
	    var Cvlsldatu = $('#vlsldatu', '#' + nomeForm);
	    var Cdiasatrs = $('#diasatrs', '#' + nomeForm);
	    var Cvlaboprj = $('#vlaboprj', '#' + nomeForm);
	    var Ctojrmprj = $('#tojrmprj', '#' + nomeForm);
	    var Ctojraprj = $('#tojraprj', '#' + nomeForm);
	    var Cvlacrprj = $('#vlacrprj', '#' + nomeForm);
	    var Ctottjmpr = $('#tottjmpr', '#' + nomeForm);
	    var Ctovlpago = $('#tovlpago', '#' + nomeForm);
	    var Ctopgjrpr = $('#topgjrpr', '#' + nomeForm);
	    var Ctoiofprj = $('#toiofprj', '#' + nomeForm);
	    var Ctoiofppr = $('#toiofppr', '#' + nomeForm);

	    Ldtprejuz.addClass('rotulo').css('width', '190px');
	    Lvlaboprj.addClass('rotulo-linha').css('width', '150px');
	    Ltoprejuz.addClass('rotulo').css('width', '190px');
	    Ltojrmprj.addClass('rotulo-linha').css('width', '150px');
	    Ltosdprej.addClass('rotulo').css('width', '190px');
	    Lvlacrprj.addClass('rotulo').css('width', '190px');
	    Ltopgmupr.addClass('rotulo-linha').css('width', '150px');
	    Ltottmupr.addClass('rotulo').css('width', '190px');
	    Ltopgjmpr.addClass('rotulo-linha').css('width', '150px');
	    Ltottjmpr.addClass('rotulo').css('width', '190px');
	    Lvlsldatu.addClass('rotulo-linha').css('width', '150px');
	    Ldiasatrs.addClass('rotulo').css('width', '190px');
	    Ltovlpago.addClass('rotulo-linha').css('width', '150px');
	    Ltojraprj.addClass('rotulo').css('width', '190px');
	    Ltopgjrpr.addClass('rotulo-linha').css('width', '150px');
	    Ltoiofprj.addClass('rotulo').css('width', '190px');
	    Ltoiofppr.addClass('rotulo-linha').css('width', '150px');

	    Cdtprejuz.css({ 'width': '70px', 'text-align': 'right' });
	    Cvlaboprj.css({ 'width': '70px', 'text-align': 'right' });
	    Ctoprejuz.css({ 'width': '70px', 'text-align': 'right' });
	    Ctojrmprj.css({ 'width': '70px', 'text-align': 'right' });
	    Ctosdprej.css({ 'width': '70px', 'text-align': 'right' });
	    Ctojraprj.css({ 'width': '70px', 'text-align': 'right' });
	    Ctopgmupr.css({ 'width': '70px', 'text-align': 'right' });
	    Cvlacrprj.css({ 'width': '70px', 'text-align': 'right' });
	    Ctottmupr.css({ 'width': '70px', 'text-align': 'right' });
	    Ctottjmpr.css({ 'width': '70px', 'text-align': 'right' });
	    Ctopgjmpr.css({ 'width': '70px', 'text-align': 'right' });
	    Cvlsldatu.css({ 'width': '70px', 'text-align': 'right' });
	    Cdiasatrs.css({ 'width': '70px', 'text-align': 'right' });
	    Ctovlpago.css({ 'width': '70px', 'text-align': 'right' });
	    Ctopgjrpr.css({ 'width': '70px', 'text-align': 'right' });
	    Ctoiofprj.css({ 'width': '70px', 'text-align': 'right' });
	    Ctoiofppr.css({ 'width': '70px', 'text-align': 'right' });

	    Cdtprejuz.desabilitaCampo();
	    Ctoprejuz.desabilitaCampo();
	    Ctosdprej.desabilitaCampo();
	    Ctopgmupr.desabilitaCampo();
	    Ctottmupr.desabilitaCampo();
	    Ctopgjmpr.desabilitaCampo();
	    Cvlsldatu.desabilitaCampo();
	    Cdiasatrs.desabilitaCampo();
	    Cvlaboprj.desabilitaCampo();
	    Ctojrmprj.desabilitaCampo();
	    Ctojraprj.desabilitaCampo();
	    Cvlacrprj.desabilitaCampo();
	    Ctottjmpr.desabilitaCampo();
	    Ctovlpago.desabilitaCampo();
	    Ctopgjrpr.desabilitaCampo();
	    Ctoiofprj.desabilitaCampo();
	    Ctoiofppr.desabilitaCampo();

		layoutPadrao();
		ajustarCentralizacao();

	}else if ( nomeForm == 'formDetalhePrejuizoPagar' ){
		$('#'+nomeForm).css('width','300px');
		var Ltosdprej = $('label[for="tosdprej"]','#'+nomeForm);
		var Lvlsldjur = $('label[for="vlsldjur"]','#'+nomeForm);
		var Lvlsldmta = $('label[for="vlsldmta"]','#'+nomeForm);
		var Lvlpagmto = $('label[for="vlpagmto"]','#'+nomeForm);
		var Lvlaboprj = $('label[for="vlaboprj"]','#'+nomeForm);
		var Lvlsldprj = $('label[for="vlsldprj"]','#'+nomeForm);
		var Lvliofatr = $('label[for="vliofatr"]','#'+nomeForm);
		var Lvlsldaco = $('label[for="vlsldaco"]','#'+nomeForm);

		var Ctosdprej = $('#tosdprej','#'+nomeForm);
		var Cvlsldjur = $('#vlsldjur','#'+nomeForm);
		var Cvlsldmta = $('#vlsldmta','#'+nomeForm);
		var Cvlpagmto = $('#vlpagmto','#'+nomeForm);
		var Cvlaboprj = $('#vlaboprj','#'+nomeForm);
		var Cvlsldprj = $('#vlsldprj','#'+nomeForm);
		var Cvliofatr = $('#vliofatr','#'+nomeForm);
		var Cvlsldaco = $('#vlsldaco','#'+nomeForm);

		Ltosdprej.addClass('rotulo').css({'width':'160px','text-align':'left'});
		Lvlsldjur.addClass('rotulo').css({'width':'160px','text-align':'left'});
		Lvlsldmta.addClass('rotulo').css({'width':'160px','text-align':'left'});
		Lvlpagmto.addClass('rotulo').css({'width':'160px','text-align':'left'});
		Lvlaboprj.addClass('rotulo').css({'width':'160px','text-align':'left'});
		Lvlsldprj.addClass('rotulo').css({'width':'160px','text-align':'left'});
		Lvliofatr.addClass('rotulo').css({'width':'160px','text-align':'left'});
		Lvlsldaco.addClass('rotulo').css({'width':'160px','text-align':'left'});


		Ctosdprej.css({'width':'110px','text-align':'right'});
		Cvlsldjur.css({'width':'110px','text-align':'right'});
		Cvlsldmta.css({'width':'110px','text-align':'right'});
		Cvlpagmto.css({'width':'110px','text-align':'right'}).addClass('monetario').keyup(function(){calculaSaldoPrejuizo()});
		Cvlaboprj.css({'width':'110px','text-align':'right'}).addClass('monetario').keyup(function(){calculaSaldoPrejuizo()});
		Cvlsldprj.css({'width':'110px','text-align':'right'});
		Cvliofatr.css({'width':'110px','text-align':'right'});
		Cvlsldaco.css({'width':'110px','text-align':'right'});

		Ctosdprej.desabilitaCampo();
		Cvlsldjur.desabilitaCampo();
		Cvlsldmta.desabilitaCampo();
		// Cvlpagmto.desabilitaCampo();
		// Cvlaboprj.desabilitaCampo();
		Cvlsldprj.desabilitaCampo();
		Cvliofatr.desabilitaCampo();
		Cvlsldaco.desabilitaCampo();
		
		layoutPadrao();
		ajustarCentralizacao();
	}
	return false;
}

function formataCampoCmc7(exitCampo, nomeForm){
	var mask   = '<zzzzzzzz<zzzzzzzzzz>zzzzzzzzzzzz:';
	var indice = 0;
	var cDsdocmc7 = $('#dsdocmc7','#'+nomeForm); 	
	var valorAtual = cDsdocmc7.val();
	var valorNovo  = '';
	
	if ( valorAtual == '' ){
		return false;
	}
	
	if ( exitCampo && valorAtual.length < 34) {
		showError('error','Valor do CMC-7 inv&aacute;lido.','Alerta - Aimaro','hideMsgAguardo(); $(\'#dsdocmc7\', \'#'+nomeForm+'\').focus(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
	}
	
	//remover os caracteres de formatação
	valorAtual = valorAtual.replace(/[^0-9]/g, "").substr(0,30);
	
	for ( var x = 0;  x < valorAtual.length; x++ ) {
				
		//verifica se é um separador da máscara
		if (mask.charAt(indice) != 'z'){
			valorNovo = valorNovo.concat(mask.charAt(indice));
			indice++;
		}
		valorNovo = valorNovo.concat(valorAtual.charAt(x));		
		indice++;
	}
	
	// verifica se o valor digitado possui 30 caracteres sem formatação
	if ( valorAtual.length == 30 ){
		// Adiciona o ultimo caracter da máscara
		valorNovo = valorNovo.concat(':');
	}
	
	cDsdocmc7.val(valorNovo);
}

function formataTabelaEmiten(){
	// Tabela
	var divRegistro = $('div.divRegistros', '#divEmiten');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	$('#divEmiten').css({'margin-top':'5px'});
//	divRegistro.css({'height':'305px','width':'1000px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '50px';
	arrayLargura[1] = '50px';
	arrayLargura[2] = '90px';
	arrayLargura[3] = '150px';
	arrayLargura[4] = '350px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	return false;
}

function acessaOpcaoAba(id){
	var nrOpcoes = 2;
    showMsgAguardo("Aguarde, carregando dados do t&iacute;tulo ...");

    // Atribui cor de destaque para aba da opção
	nrOpcoes = nrOpcoes + 1;
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da opção
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

    if (id == 0){
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/descontos/titulos/titulos.php",
            dataType: "html",
            data: {
                nrdconta: nrdconta,
                cdproduto: cdproduto,
                executandoProdutos: executandoProdutos,
                redirect: "html_ajax"
            },      
            error: function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function(response) {
                $("#divConteudoTab").html(response);
            }               
        });
        return false;
    }else if (id == 1){
    	var nrctrlim = $("#frmTitulos #nrctrlim").val();
    	$.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/descontos/titulos/titulos_historico.php",
            dataType: "html",
            data: {
                nrdconta: nrdconta,
                nrctrlim: nrctrlim,
                redirect: "html_ajax"
            },      
            error: function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function(response) {
                $("#divConteudoTab").html(response);
            }               
        });
        return false;
	}else{
    	hideMsgAguardo();
        showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
    }
}