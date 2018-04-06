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
			 
************************************************************************/

// Carrega biblioteca javascript referente ao RATING
$.getScript(UrlSite + 'includes/rating/rating.js');

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
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
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
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
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
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
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
			showConfirmacao("Confirma Desbloqueio da Inclus&atilde;o de Border&ocirc;?", "Confirma&ccedil;&atilde;o - Ayllos", "desbloqueiaInclusaoBordero();", "blockBackground(parseInt($('#divRotina').css('z-index')));", "sim.gif", "nao.gif");
			return false;			
		});
				
	}else if ( nomeForm == 'divBorderos' ){
	
		$('#'+nomeForm).css('width','785px');
	
		var divRegistro = $('div.divRegistros','#'+nomeForm);		
		var tabela      = $('table', divRegistro );
						
		divRegistro.css('height','110px');
		
		var ordemInicial = new Array();
				
		var arrayLargura = new Array();
		arrayLargura[0] = '65px';
		arrayLargura[1] = '60px';
		arrayLargura[2] = '60px';
		arrayLargura[3] = '55px';
		arrayLargura[4] = '100px';
		arrayLargura[5] = '55px';
		arrayLargura[6] = '100px';
		arrayLargura[7] = '90px';
				
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'right';
		arrayAlinha[7] = 'left';
		arrayAlinha[8] = 'center';
						
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();		
			}
		});
		
		ajustarCentralizacao();
	
	}else if( nomeForm == 'frmBordero' ){
	
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
		
		$('#'+nomeForm).css('width','480px');
		
		Ldspesqui.addClass('rotulo').css('width','170px');
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
			
	}else if( nomeForm == 'divLimites' ){
				
		$('#'+nomeForm).css('width','533px');
	
		var divRegistro = $('div.divRegistros','#'+nomeForm);		
		var tabela      = $('table', divRegistro );
						
		divRegistro.css('height','135px');
		
		var ordemInicial = new Array();
				
		var arrayLargura = new Array();
		arrayLargura[0] = '60px';
		arrayLargura[1] = '60px';
		arrayLargura[2] = '60px';
		arrayLargura[3] = '80px';
		arrayLargura[4] = '30px';
		arrayLargura[5] = '25px';
		arrayLargura[6] = '65px';
				
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'center';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'left';
		arrayAlinha[7] = 'center';
						
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();		
			}
		});
	
		ajustarCentralizacao();
		
	}else if(  nomeForm == 'frmDadosLimiteDscChq' ||
			   nomeForm == 'frmDadosLimiteDscTit'){
	
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
		
		var Cnrctrlim = $('#nrctrlim','#'+nomeForm);
		var Cdtinivig = $('#dtinivig','#'+nomeForm);
		var Cqtdiavig = $('#qtdiavig','#'+nomeForm);
		var Cvllimite = $('#vllimite','#'+nomeForm);
		var Cqtrenova = $('#qtrenova','#'+nomeForm);
		var Cdsdlinha = $('#dsdlinha','#'+nomeForm);
		var Cvlutilcr = $('#vlutilcr','#'+nomeForm);
		var Cvlutilsr = $('#vlutilsr','#'+nomeForm);
		
		$('#'+nomeForm).css('width','430px');
		
		Lnrctrlim.addClass('rotulo').css('width','80px');
		Ldtinivig.css('width','60px');
		Lqtdiavig.css('width','60px');
		Lvllimite.addClass('rotulo').css('width','80px');
		Lqtrenova.css('width','158px');
		Ldsdlinha.addClass('rotulo').css('width','155px');
		Lvlutilcr.addClass('rotulo').css('width','200px');
		Lvlutilsr.addClass('rotulo').css('width','200px');
		
		
		Cnrctrlim.css({'width':'60px','text-align':'right'});
		Cdtinivig.css({'width':'65px','text-align':'center'});
		Cqtdiavig.css({'width':'60px','text-align':'right'});
		Cvllimite.css({'width':'90px','text-align':'right'});
		Cqtrenova.css({'width':'60px','text-align':'right'});
		Cdsdlinha.css({'width':'200px'});
		Cvlutilcr.css({'width':'150px','text-align':'right'});
		Cvlutilsr.css({'width':'150px','text-align':'right'});
		
		Cnrctrlim.desabilitaCampo();
		Cdtinivig.desabilitaCampo();
		Cqtdiavig.desabilitaCampo();
		Cvllimite.desabilitaCampo();
		Cqtrenova.desabilitaCampo();
		Cdsdlinha.desabilitaCampo();
		Cvlutilcr.desabilitaCampo();
		Cvlutilsr.desabilitaCampo();

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
		showError('error','Valor do CMC-7 inv&aacute;lido.','Alerta - Ayllos','hideMsgAguardo(); $(\'#dsdocmc7\', \'#'+nomeForm+'\').focus(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
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