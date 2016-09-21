/*!
 * FONTE        : pagfol.js
 * CRIAÇÃO      : Renato Darosci - SUPERO
 * DATA CRIAÇÃO : Junho/2015
 * OBJETIVO     : Biblioteca de funções da tela PAGFOL
 * --------------
 * ALTERAÇÕES   :
 * -----------------------------------------------------------------------
 */

// Variaveis
var cTodosCabecalho;

var prCdcooper, prCdempres, prNrseqpag;

var rCdcooper,cCdcooper,
	rCdempres,cCdempres,
	          cNmextemp,
              cDtmvtolt;
	
var cNmresemp,
    cNmcooper,
    cDsdregio,
    cNmconspj;
	
var rNrcpfcgc,rNmprimtl,rNrdconta,rNrctremp,
    cNrcpfcgc,cNmprimtl,cNrdconta,cNrctremp;

var cTodosCabecalho, btnOK, btnOK2,btnOK3;

$.fn.extend({ 
	
	/*!
	 * Formatar a tabela desta tela, sem setar Ordernação
	 */
	formataTabelaPAGFOL: function(ordemInicial, larguras, alinhamento, metodoDuploClick ) {

		var tabela = $(this);		
		
		// Forma personalizada de extra??o dos dados para ordena??o, pois para n?meros e datas os dados devem ser extra?dos para serem ordenados
		// n?o da forma que s?o apresentados na tela. Portanto adotou-se o padr?o de no in?cio da tag TD, inserir uma tag SPAN com o formato do 
		// dado aceito para ordena??o
		var textExtraction = function(node) {  
			if ( $('span', node).length == 1 ) {
				return $('span', node).html();
			} else {
				return node.innerHTML;
			}		
		}

		// O thead no IE n?o funciona corretamento, portanto ele ? ocultado no arquivo "estilo.css", mas seu conte?do
		// ? copiado para uma tabela fora da tabela original
		var divRegistro = tabela.parent();
		divRegistro.before('<table class="tituloRegistros"><thead>'+$('thead', tabela ).html()+'</thead></table>');		
		
		var tabelaTitulo = $( 'table.tituloRegistros',divRegistro.parent() );	
		
		// $('thead', tabelaTitulo ).append( $('thead', tabela ).html() );
		$('thead > tr', tabelaTitulo ).append('<th class="ordemInicial"></th>');
		
		
		// Formatando - Largura 
		if (typeof larguras != 'undefined') {
			for( var i in larguras ) {
				$('td:eq('+i+')', tabela ).css('width', larguras[i] );
				$('th:eq('+i+')', tabelaTitulo ).css('width', larguras[i] );
			}		
		}	
		
		// Calcula o n?mero de colunas Total da tabela
		var nrColTotal = $('thead > tr > th', tabela ).length;
		
		//$('td:last-child', tabela ).prop('colspan','2');
		
		// Formatando - Alinhamento
		if (typeof alinhamento != 'undefined') {
			for( var i in alinhamento ) {
				var nrColAtual = i;
				nrColAtual++;
				$('td:nth-child('+nrColTotal+'n+'+nrColAtual+')', tabela ).css('text-align', alinhamento[i] );		
			}		
		}			

		$('table > tbody > tr', divRegistro).each( function(i) {
			$(this).bind('click', function() {
				$('table', divRegistro).zebraTabela( i );
			});
		});		

		if ( typeof metodoDuploClick != 'undefined' ) {	
			$('table > tbody > tr', divRegistro).dblclick( function() {
				eval( metodoDuploClick );
			});	

			$('table > tbody > tr', divRegistro).keypress( function(e) {
				if ( e.keyCode == 13 ) {
					eval( metodoDuploClick );
				}
			});	

		}	
		
		$('td:nth-child('+nrColTotal+'n)', tabela ).css('border','0px');
		
		// Iniciar com a primeira linha selecionado e retornar o valor da chave deste primerio registro, que se encontra no input do tipo hidden
		tabela.zebraTabela(0);	
		return true;
	}
});

// Funcao de Data JavaScript
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

function setaDataTela() {

    var dtHoje  = new Date();
    var dtmvtolt 	=  dataString(dtHoje.getDate() + "/" + (dtHoje.getMonth()+1)  + "/" + dtHoje.getFullYear());

    $('#dtmvtolt','#frmCab').val(dtmvtolt);
    return false;
}


// Tela
$(document).ready(function() {

    /** Campos da divConsulta **/
	rCdcooper       = $('label[for="cdcooper"]','#frmCab');
	cCdcooper       = $('#cdcooper','#frmCab');
	
	rCdempres       = $('label[for="cdempres"]','#frmCab');
	cCdempres       = $('#cdempres','#frmCab');
	cNmextemp		= $('#nmextemp','#frmCab');
    cDtmvtolt       = $('#dtmvtolt','#frmCab');
	
	cNmresemp		= $('#nmresemp','#frmCons');
	cNmcooper		= $('#nmcooper','#frmCons');
	cDsdregio		= $('#dsdregio','#frmCons');
	cNmconspj		= $('#nmconspj','#frmCons');

	estadoInicial();
});


function estadoInicial() {

	$('#divRotina').fadeTo(0,0.1);

	atualizaSeletor();
	formataCabecalho();

	$('#divConsulta').css({'display':'none'});
	$('#divRegistros').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	$('#divIncluir').css({'display':'none'});
	$('#frmCab').css({'display':'block'});
	
	// Habilitar campos do frame de pesquisa
	cCdcooper.habilitaCampo();
	cCdempres.habilitaCampo();
    cDtmvtolt.habilitaCampo();
	
	$("#divConteudo").html('');

	removeOpacidade('divTela');

	$('#btnVoltar','#divBotoes').hide();
	
	//btnOK.prop('disabled',false);
	$('#divConsulta').css({'display':'block'});
	$('#divBotoes').css({'display':'block'});
	$('#btVoltar' ,'#divBotoes').show();
	$('#btProsseguir' ,'#divBotoes').show();
	
	cCdcooper.focus();
}


// Cabecalho
function atualizaSeletor() {

	
	// Adicionar os itens do campo select das cooperativas
	lista_coop();
	
	cTodosCabecalho	= $('input[type="text"],select','#frmCab');
	btnOK			= $('#btnOK','#frmCab');
	btnOK2			= $('#btnOK2','#frmCab');
	btnOK3			= $('#btnOK3','#frmCab');
	
	/** Campos da divIncluir **/
	rNrcpfcgc	    = $('label[for="nrcpfcgc"]','#frmCab');
	rNmprimtl       = $('label[for="nmprimtl"]','#frmCab');
	rNrdconta       = $('label[for="nrdconta"]','#frmCab');
	rNrctremp       = $('label[for="nrctremp"]','#frmCab');

	cNrcpfcgc		= $('#nrcpfcgc','#frmCab');
	cNmprimtl       = $('#nmprimtl','#frmCab');
	cNrdconta       = $('#nrdconta','#frmCab');
	cNrctremp       = $('#nrctremp','#frmCab');

	return false;
}


// Formatacao da Tela
function formataCabecalho() {

	/** Campos da divConsulta **/
	rCdcooper.addClass('rotulo').css({'width':'80px'});
	cCdcooper.addClass('campo').css({'width':'130px'});
	
	rCdempres.addClass('rotulo').css({'width':'60px'});
	cCdempres.addClass('rotulo').css({'width':'50px'});
	
	cNmextemp.addClass('rotulo').css({'width':'430px'});
	cNmextemp.desabilitaCampo();
    
    cDtmvtolt.addClass('campo').addClass('data').css({'width':'85px'});
	
	/** Campos da divIncluir **/
	rNrcpfcgc.addClass('rotulo').css({'width':'80px'});
	rNmprimtl.addClass('rotulo-linha').css({'width':'90px'});
	rNrdconta.addClass('rotulo-linha').css({'width':'90px'});
	rNrctremp.addClass('rotulo-linha').css({'width':'90px'});

	cNrcpfcgc.addClass('rotulo-linha').css({'width':'100px'});
	cNmprimtl.addClass('rotulo-linha').css({'width':'280px'});
	cNrdconta.addClass('rotulo-linha').css({'width':'100px'});
	cNrctremp.addClass('rotulo-linha').css({'width':'100px'});

	highlightObjFocus( $('#frmCab') );
	
	opcaoTela();
	layoutPadrao();
	return false;
}

function opcaoTela() {
	
	cCdcooper.unbind('change').bind('change', function() {
		cCdempres.val('');
		cNmextemp.val('');
	});
	
	cDtmvtolt.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cCdempres.focus();
			return false;
		}
	});
	
	cCdempres.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                buscaEmpresas();
                return false;
            }
        });
	
	cCdcooper.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cCdempres.focus();
			return false;
		}
	});

	return false;
}

function lista_coop() {

	mensagem = 'Aguarde, processando ...';
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/pagfol/busca_cooperativa.php", 
		data: {
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
		    hideMsgAguardo();
			try {
				eval(response);
				hideMsgAguardo();
			} catch(error) {
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","");				
			}
		}				
	}); 	
	
}

function btnVoltar() {

	cCdempres.val('');
	cNmextemp.val('');
	
	$('input,select','#frmCab').removeClass('campoErro');
	$('#divDetalhes').css({'display':'none'});
	$('#divDados').css({'display':'none'});

	estadoInicial();
	return false;
}

function btnProsseguir() {
		
	// Verificar se a empresa foi informada
	if (cCdempres.val().length == 0 ) {
		showError("error","Favor informar empresa.","Alerta - Ayllos","focaCampoErro('cdempres','frmCab')");
		return false; 
	}
	
	// Bloquear os campos de pesquisa
	cCdcooper.desabilitaCampo();
	cCdempres.desabilitaCampo();
    cDtmvtolt.desabilitaCampo();
	
	mensagem = 'Aguarde, processando ...';	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/pagfol/busca_dados_pagamentos.php", 
		data: {
			cdcooper: cCdcooper.val(),
			cdempres: cCdempres.val(),
            dtmvtolt: cDtmvtolt.val(),
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
		    hideMsgAguardo();
			try {
				
				$('input,select','#frmCab').removeClass('campoErro');
				$('#frmCons').css({'display':'block'}); 
				$("#divDados").html(response);
				$('#btProsseguir' ,'#divBotoes').hide();
				formataTabela('M');
				
				hideMsgAguardo();
			} catch(error) {
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","");				
			}
		}				
	}); 
	
	return false;
}

function buscaDetalhes() {
	
	mensagem = 'Aguarde, processando ...';
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/pagfol/busca_dados_detalhes.php", 
		data: {
			cdcooper: prCdcooper,
			cdempres: prCdempres,
			nrseqpag: prNrseqpag,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
		    hideMsgAguardo();
			try {
				$('input,select','#frmCab').removeClass('campoErro');
				$('#frmDetail').css({'display':'block'}); 
				$("#divDetalhes").html(response);
				
				formataTabela('D');
				 
				hideMsgAguardo();
			} catch(error) {
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","");				
			}
		}				
	}); 
	
	return false;
}

/* Retorna o registro para atualizar */
function retornaRegistro(rowid) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando dados...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/reafor/retorna_dados_reafor.php",
		data: {
			rowid    : rowid,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
		    try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#nrdconta','#frmCab').empty();
						$('#nrctremp','#frmCab').empty();
						$('input,select','#frmCab').removeClass('campoErro');
						$('#divConsulta').css({'display':'none'});
						$('#divRegistros').css({'display':'none'});
						$('#divConteudo').css({'display':'none'});
						$('#divIncluir').css({'display':'block'});

						cNrdconta.habilitaCampo();

						$('#btnVoltar','#divBotoes').hide();
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')));");
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')));estadoInicial();");
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});
	return false;
}


// Formata Tabela
function formataTabela(inTabela) {

    $('#divDados').css({'display':'block'});
	$('#divDetalhes').css({'display':'block'});	
	$('#tabFolhaPagto').css({'margin-top':'1px'});
	$('#tabFolhaDetalhe').css({'margin-top':'1px'});

	var divRegistro;
	
	// Verifica a tabela a ser formatada
	if (inTabela == 'M') {   //Master
		divRegistro = $('div.divRegistros', '#frmCons');
		divRegistro.css({'height':'85px','padding-bottom':'1px'}); // 370px
	} else { // Detail
		divRegistro = $('div.divRegistros' , '#frmDetail');
		divRegistro.css({'height':'155px','padding-bottom':'1px'}); 
	}

	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	var arrayAlinha = new Array();
	// Verifica a tabela a ser formatada
	if (inTabela == 'M') {   //Master
		arrayLargura[0] = '30px';
		arrayLargura[1] = '110px';
		arrayLargura[2] = '110px';
		arrayLargura[3] = '60px';
		arrayLargura[4] = '110px';
		arrayLargura[5] = '60px';
		arrayLargura[6] = '70px';
		arrayLargura[7] = '70px';
		arrayLargura[8] = '140px';
		arrayLargura[9] = '';      // Necessário para que os pixels se enquadrem corretamente
		arrayLargura[10] = '14px'; // Fixo para definir o tamanho da coluna do campo da ordenação inicial que fica sobre a barra de rolagem
	
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'center';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'center';
        arrayAlinha[5] = 'center';
        arrayAlinha[6] = 'center';
		arrayAlinha[7] = 'center';
		arrayAlinha[8] = 'right';
		arrayAlinha[9] = 'right';
	} else {
		arrayLargura[0] = '120px';
		arrayLargura[1] = '100px';
		arrayLargura[2] = '380px';
		arrayLargura[3] = '100px';
		arrayLargura[4] = '100px';      
		arrayLargura[5] = '';     // Necessário para que os pixels se enquadrem corretamente
		arrayLargura[6] = '14px'; // Fixo para definir o tamanho da coluna do campo da ordenação inicial que fica sobre a barra de rolagem
				
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'right';
        arrayAlinha[2] = 'left';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'right';
        arrayAlinha[5] = 'left';
	}
	if (inTabela == 'M') {   //Master
		//tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		tabela.formataTabelaPAGFOL( ordemInicial, arrayLargura, arrayAlinha, '' );
	} else {
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	}
		
	

	hideMsgAguardo();

	/* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
	para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
	excluir o registro selecionado */

	// Verifica a tabela a ser formatada
	if (inTabela == 'M') {   //Master
		//$('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
		//	$('table > tbody > tr > td', divRegistro).focus();
		//});
        
        // Esconde os detalhes
        $('#frmDetail').hide();

		// seleciona o registro que é clicado
		$('table > tbody > tr', divRegistro).click( function() {
			selecionaTabela($(this));
			buscaDetalhes();
		});

		/*// seleciona o registro que é focado
		$('table > tbody > tr', divRegistro).focus( function() {
			selecionaTabela($(this));
		});
	
		$('table > tbody > tr:eq(0)', divRegistro).click();
		
		$('table > thead > tr > th', divRegistro).removeClass('headerSort headerSortUp headerSortDown');
		$('table > thead > tr > th', divRegistro).addClass('tituloRegistros');
		$('table > thead > tr > th', divRegistro).tablesorter();
		/*
		$('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
			return false;
		});*/
	} else {
        var num;
		$('table > tbody > tr', divRegistro).click( function() {
            num = $(this).attr('id').replace('linObsClick_','');
            mostraObservacao(num);
		});
    }
	
	return false;
}


function mostraObservacao(ind) {
    $('.linObs').hide();
    $('#divObservacao').show();
    $('#linObs_' + ind).show();
}


function selecionaTabela(tr) {

	// Guardar os valores selecionados na linha
	prCdcooper = $('#cdcooper', tr).val();
	prCdempres = $('#cdempres', tr).val();
	prNrseqpag = $('#nrseqpag', tr).val();
				
	return false;
}

/*!
 * ALTERAÇÃO  : Criação da função "mostraPesquisaEmpresa"
 * OBJETIVO   : Função para mostrar a rotina de Pesquisa de Empresas Genérica. 
 * PARÂMETROS : campoRetorno -> (String) O campo retorno é o nome do campo que representa o Nome da Empresa, para que na seleção
 *                              da empresa o sistema saiba para onde deve enviar o valor da empresa escolhida 
 *              formRetorno  -> (String) Nome do formulário que irá receber as informações da empresa selecionada
 *              divBloqueia  -> (Opcional) Seletor jQuery da div que será ao qual queremos bloquear o fundo, logo em seguida de fecharmos a janela de pesquisa
 *              fncFechar    -> (Opcional) String que será executada como script ao fechar o formulário de Pesquisa Empresa. Na maioria 
 *                               das vezes será uma instrução de foco para algum campo.
 */
function mostraPesquisaEmpresa(campoRetorno, formRetorno, divBloqueia, fncFechar) {

    // Mostra mensagem de aguardo	
    showMsgAguardo('Aguarde, carregando Pesquisa de Empresas ...');

    // Guardo o campoRetorno e o formRetorno em variáveis globais para serem utilizados na seleção do associado
    vg_campoRetorno = campoRetorno;
    vg_formRetorno = formRetorno;

    $('#tpdapesq', '#frmPesquisaEmpresa').empty();

    // Limpar campos de pesquisa
    $('#nmdbusca', '#frmPesquisaEmpresa').val('');
    $('#tpdapesq', '#frmPesquisaEmpresa').val('0');

    // Formatação Inicial
    $('#nmdbusca, #tpdapesq', '#frmPesquisaEmpresa').removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled');
    $('#tpdapesq', '#frmPesquisaEmpresa').removeProp('disabled');

    $('.fecharPesquisa', '#divPesquisaEmpresa').click(function() {
        $('#nmdbusca', '#frmPesquisaEmpresa').val('');
        // 015 - Retirado tratamento do tipo do divBloqueia e acrescentado a fncFechar
        fechaRotina($('#divPesquisaEmpresa'), divBloqueia, fncFechar);
        fechaRotina($('#divTabEmpresas'));
    });

    // Limpa Tabela de pesquisa
    $('#divConteudoPesquisaEmpresa').empty();
    $('#divTabPesquisaEmpresas').empty();

    exibeRotina($('#divPesquisaEmpresa'));
    $('#divPesquisaEmpresa').css({'left': '475px'});
    $('#nmdbusca', '#frmPesquisaEmpresa').focus();
    hideMsgAguardo();
}

/* Tabela de Empresas*/
// Busca as informações da empresa 
function buscaEmpresas() {

    var nmdbusca = $('#nmdbusca', '#frmPesquisaEmpresa').val();
    var cdpesqui = $('input[type="radio"]:checked', '#frmPesquisaEmpresa').val();
    var cdempres = $('#cdempres', '#frmCab').val();
	var cddopcao = 'R';
	
    //Limpa variável código da empresa para buscar por nome ou razão social
    if (nmdbusca != '') {
        cdempres = '';
    }

    // Define a URL a ser chamada
    $urlFonte = "telas/pagfol/busca_empresas.php";

    // Mostra mensagem de aguardo.
	showMsgAguardo("Aguarde, buscando empresas...");
	
    // Executa script de bloqueio através de ajax
    $.ajax({
        type: "POST",
		dataType: "html",
        url: UrlSite + $urlFonte,
        data: {
            cddopcao: cddopcao,
            cdcooper: cCdcooper.val(),
			cdpesqui: cdpesqui,
            nmdbusca: nmdbusca,
            cdempres: cdempres,
            redirect: "html_ajax"
        },
        error: function(objAjax, responseError, objExcept) {
            alert(responseError);
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
        },
        success: function(response) {
            try {
                if (cddopcao == "I")
                {
                    eval(response);
                    $('#frmCab').css({'display': 'block'});
                    controlaFocoFormulariosEmpresa();
                    hideMsgAguardo();
                }
                else
                {
                    if (cdempres == '') {
                        if (response.substring(3, 6) == 'div') {
                            $('#divConteudo').html(response);
                            fechaRotina($('#divCabecalhoPesquisaEmpresa'));
                            exibeRotina($('#divPesquisaEmpresa'));
                            exibeRotina($('#divTabEmpresas'));
                            formataTabEmpresas();
                            hideMsgAguardo();
                        } else {
                            hideMsgAguardo();
                            eval(response);
                            return false;
                        }
                    } else {
                        if (response.substring(3, 6) == 'div') {
                            $('#divConteudo').html(response);
                            exibeRotina($('#divPesquisaEmpresa'));
                            exibeRotina($('#divTabEmpresas'));
                            formataTabEmpresas();
                            selecionaEmpresa();
                            hideMsgAguardo();
                        } else {
                            hideMsgAguardo();
                            eval(response);
                            return false;
                        }
                    }
                }
				
				// Foco no botão prosseguir
				$('#btProsseguir' ,'#divBotoes').focus();
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
            }
        }
    });
}

// formata a tabela de empresas
function formataTabEmpresas() {

    var divRegistro = $('div.divRegistros', '#divPesquisaEmpresa', '#divTabEmpresas');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({'height': '155px', 'width': '555px'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '55px';
    arrayLargura[1] = '250px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'left';

    var metodoTabela = 'selecionaEmpresa();';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    hideMsgAguardo();
    bloqueiaFundo($('#divUsoGenerico'));

    return false;
}

function selecionaEmpresa() {

    if ($('table > tbody > tr', 'div#divTabEmpresas div.divRegistros').hasClass('corSelecao')) {

        $('table > tbody > tr', 'div#divTabEmpresas div.divRegistros').each(function() {
            if ($(this).hasClass('corSelecao')) {
			
                // Popula campos Formulario empresa
                cCdempres.val($('#hcdempres', $(this)).val());
				cNmextemp.val($('#hnmresemp', $(this)).val() + " - " + $('#hnmextemp', $(this)).val()); 
                //função para executar a procedure Busca_tabela e encontrar as informações restantes.

                
            }
        });
    }
    
	// Limpar o campo de busca
	$('#nmdbusca','#frmPesquisaEmpresa').val('');
	
	fechaRotina($('#divUsoGenerico'));
    fechaRotina($('#divPesquisaEmpresa'));
    fechaRotina($('#divTabEmpresas'));
	
	// Foco no botão
	$('#btProsseguir' ,'#divBotoes').focus();
	
    return false;
}


function controlaLayout() {

	atualizaSeletor();
	formataCabecalho();

	cDtmvtolt.val('');
	layoutPadrao();
	return false;
}

