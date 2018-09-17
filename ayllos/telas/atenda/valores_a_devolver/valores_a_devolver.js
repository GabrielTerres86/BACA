/**********************************************************************
  Fonte: valores_a_devolver.js                                                
  Autor: Jonata - RKAM													   
  Data : Dezembro/2017                 Ultima Alteracao:  
                                                                   
  Objetivo  : Biblioteca de funcoes da rotina Valores a Devolver da tela      
              ATENDA                                               
                                                                   	 
  Alteracoes:
 					
*************************************************************************/

var callafterCapital = '';

var lstLancamentos = new Array();
var lstEstorno = new Array();
var glb_opcao = "";

var vintegra = 0;

// Fun&ccedil;&atilde;o para acessar op&ccedil;&otilde;es da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao) {
		
	 glb_opcao = opcao;
	
	if (opcao == "@") {	// Op&ccedil;&atilde;o Principal
		var msg = ", carregando dados de valores a devolver";
		var UrlOperacao = UrlSite + "telas/atenda/valores_a_devolver/principal.php";
	} 
	
	if (opcao != "")
		// Mostra mensagem de aguardo
		showMsgAguardo("Aguarde" + msg + " ...");
	
	// Atribui cor de destaque para aba da op&ccedil;&atilde;o
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da op&ccedil;&atilde;o
            $("#linkAba" + id).attr("class", "txtBrancoBold");
            $("#imgAbaEsq" + id).attr("src", UrlImagens + "background/mnu_sle.gif");
            $("#imgAbaDir" + id).attr("src", UrlImagens + "background/mnu_sld.gif");
            $("#imgAbaCen" + id).css("background-color", "#969FA9");
			
			if (id == 5) {
				$('#divIntegralizacao').css({'display': 'block', 'height': '142px'});
				$('#divEstorno').css({'display': 'none'});
			} else
			if (id == 6) {
				lstLancamentos = "";
				lstEstorno = "";
                    $('#divIntegralizacao').css({ 'display': 'none' });
                    $('#divEstorno').css({ 'display': 'block' });
			}
			
			continue;			
		}
		
        $("#linkAba" + i).attr("class", "txtNormalBold");
        $("#imgAbaEsq" + i).attr("src", UrlImagens + "background/mnu_nle.gif");
        $("#imgAbaDir" + i).attr("src", UrlImagens + "background/mnu_nld.gif");
        $("#imgAbaCen" + i).css("background-color", "#C6C8CA");
	}

		
	// Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlOperacao,
		data: {
			nrdconta: nrdconta,
			redirect: "html_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			$("#divConteudoOpcao").html(response);
			controlaFoco(opcao); 
		}				
	}); 
			
}


//Função para controle de navegação
function controlaFoco(opcao) {
    var IdForm = '';
    var formid;

    if (opcao == "@") { //Principal
        $('.FirstInput:first ').focus();
	}
    
}

//
function controlaLayout( ) {	
		
    var altura = '170px';
	var largura = '425px';
		
	altura = '133px';
	largura = '425px';

	$('#frmValoresDevolver').css('margin-top', '2px')
	
	//Label do frmValoresDevolver
	rVlcapital = $('label[for="vlcapital"]','#frmValoresDevolver');
	rDscapital = $('label[for="dscapital"]','#frmValoresDevolver');
	rVldeposito = $('label[for="vldeposito"]','#frmValoresDevolver');
	rDsdeposito = $('label[for="dscdeposito"]','#frmValoresDevolver');
	
	rVlcapital.css('width','125px').addClass('rotulo');
	rDscapital.addClass('rotulo').css({ 'width': '350px', 'text-align': 'left','margin-left':'10px'});
	rVldeposito.css('width','125px').addClass('rotulo');
	rDsdeposito.addClass('rotulo').css({ 'width': '350px', 'text-align': 'left','margin-left':'10px' });
	
	//Campos do frmValoresDevolver
	cVlcapital  = $('#vlcapital','#frmValoresDevolver');
	cVldeposito = $('#vldeposito','#frmValoresDevolver');
	
	cVlcapital.css('width','100px').addClass('moeda_15').desabilitaCampo();
	cVldeposito.css('width','100px').addClass('moeda_15').desabilitaCampo();
	
	divRotina.css('width', largura);
    $('#divConteudoOpcao').css({ 'height': altura, 'width': largura });

	layoutPadrao();

	hideMsgAguardo();
	bloqueiaFundo(divRotina);

	removeOpacidade('divConteudoOpcao');
	divRotina.centralizaRotinaH();

	return false;
}
