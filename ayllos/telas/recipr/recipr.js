/*!
 * FONTE        : recipr.js
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : Marco/2016
 * OBJETIVO     : Funcoes da tela Reciprocidade
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	

var glbIdapuracao_reciproci;
var glbNrdconta;

function acessaOpcaoAbaReciprocidade() {
    // Se nao veio a conta
    if (glb_nrdconta == 0) {
        if (glb_nmrotina == 'cobranca') {
            showError("error","Problema ao acessar a tela! Conta para consulta n&atilde;o recebida!","Alerta - Ayllos",'bloqueiaFundo(divRotina);fechaRotina($(\'#divUsoGenerico\'),$(\'#divRotina\'));');
            return false;
        }
    }

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados ...");	

	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/recipr/principal.php",
		data: {
			nrdconta: glb_nrdconta, // GLB vem da recipr.php
			nrconven: glb_nrconven, // GLB vem da recipr.php
            nmrotina: glb_nmrotina, // GLB vem da recipr.php
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos",bloqueiaFundo(divRotina));
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoReciprocidade').html(response);
			} else {
				eval( response );				
			}
			return false;
		}
	});
}

function controlaLayoutTabelaReciprocidade() {
	var divRegistro = $('div.divRegistros','#divReciprocidadePrincipal');		
	var tabela      = $('table', divRegistro );
	var ordemInicial = new Array();

	divRegistro.css('height','70px');

	var arrayLargura = new Array();
	arrayLargura[0] = '70px';
    arrayLargura[1] = '70px';
    arrayLargura[2] = '40px';
    arrayLargura[3] = '50px';
    arrayLargura[4] = '50px';
    arrayLargura[5] = '70px';
    arrayLargura[6] = '70px';
    arrayLargura[7] = '90px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'left';
	arrayAlinha[6] = 'left';
	arrayAlinha[7] = 'center';
	arrayAlinha[8] = 'center';
	arrayAlinha[9] = 'center';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	$('tbody > tr',tabela).each( function() {
		if ( $(this).hasClass('corSelecao') ) {
			$(this).focus();		
		}
	});
  
    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click( function() {
        glbNrdconta = $(this).find('#hd_nrdconta').val();
        glbIdapuracao_reciproci = $(this).find('#hd_idapuracao_reciproci').val();
        exibeDetalheApuracaoReciprocidade();
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();
}

function exibeDetalheApuracaoReciprocidade() {
    // Andamento dos Indicadores
    $.ajax({		
		type: "POST", 
		url: UrlSite + "telas/recipr/detalhes.php",
		data: {
            nrdconta: glbNrdconta,
			idapuracao_reciproci: glbIdapuracao_reciproci,
            tipo_tabela: 'andamento_indicadores',
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos",bloqueiaFundo(divRotina));
		},
		success: function(response) {
			$('#divReciprIndicadores').html(response);

            var divRegistro  = $('div.divRegistros','#divReciprIndicadores');		
            var tabela       = $('table', divRegistro );
            var ordemInicial = new Array();

            divRegistro.css('height','70px');

            arrayLargura = new Array();
            arrayLargura[0] = '300px';
            arrayLargura[1] = '75px';
            arrayLargura[2] = '75px';
            arrayLargura[3] = '70px';
            arrayLargura[4] = '80px';

            arrayAlinha = new Array();
            arrayAlinha[0] = 'left';
            arrayAlinha[1] = 'right';
            arrayAlinha[2] = 'right';
            arrayAlinha[3] = 'right';
            arrayAlinha[4] = 'right';
            arrayAlinha[5] = 'center';

            tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		}
	});

    // Acompanhamento das Tarifas
    $.ajax({		
		type: "POST", 
		url: UrlSite + "telas/recipr/detalhes.php",
		data: {
			idapuracao_reciproci: glbIdapuracao_reciproci,
            tipo_tabela: 'acompanhamento_tarifas',
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos",bloqueiaFundo(divRotina));
		},
		success: function(response) {
			$('#divReciprTarifas').html(response);

            var divRegistro  = $('div.divRegistros','#divReciprTarifas');		
            var tabela       = $('table', divRegistro );
            var ordemInicial = new Array();

            divRegistro.css('height','70px');

            arrayLargura = new Array();
            arrayLargura[0] = '300px';
            arrayLargura[1] = '80px';
            arrayLargura[2] = '90px';
            arrayLargura[3] = '80px';

            arrayAlinha = new Array();
            arrayAlinha[0] = 'left';
            arrayAlinha[1] = 'right';
            arrayAlinha[2] = 'right';
            arrayAlinha[3] = 'center';
            arrayAlinha[4] = 'right';

            tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		}
	});
}