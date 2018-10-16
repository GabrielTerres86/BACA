/**********************************************************************
  Fonte: portabilidade.js                                                
  Autor: Anderson-Alan													   
  Data : Setembro/2018                 Ultima Alteracao: 24/09/2018
                                                                   
  Objetivo  : Biblioteca de funcoes da rotina Portabilidade da tela Atenda                                              
                                                                   	 
 					
*************************************************************************/

var callafterCapital = ''; 

var lstLancamentos = new Array();
var lstEstorno = new Array();
var glb_opcao = "";

var vintegra = 0;


// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao) {
	glb_opcao = opcao;
	
	if (opcao == "0") {	// Opção Principal
		var msg = ", carregando dados de portabilidade";
		var UrlOperacao = UrlSite + "telas/atenda/portabilidade/envio_solicitacao.php";
	} else if (opcao == "1") { // Opção Subscrição Inicial
		var msg = ", carregando subscri&ccedil;&atilde;o inicial";
		var UrlOperacao = UrlSite + "telas/atenda/portabilidade/destinatario.php";
	}
	
	if (opcao != "")
		// Mostra mensagem de aguardo
		showMsgAguardo("Aguarde" + msg + " ...");
	
    // Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
	    if (id == i) { // Atribui estilos para foco da opção
            $("#linkAba" + id).attr("class", "txtBrancoBold");
            $("#imgAbaEsq" + id).attr("src", UrlImagens + "background/mnu_sle.gif");
            $("#imgAbaDir" + id).attr("src", UrlImagens + "background/mnu_sld.gif");
            $("#imgAbaCen" + id).css("background-color", "#969FA9");
			continue;			
		}
		
        $("#linkAba" + i).attr("class", "txtNormalBold");
        $("#imgAbaEsq" + i).attr("src", UrlImagens + "background/mnu_nle.gif");
        $("#imgAbaDir" + i).attr("src", UrlImagens + "background/mnu_nld.gif");
        $("#imgAbaCen" + i).css("background-color", "#C6C8CA");
	}

	if (opcao != "") { // Demais Opções		
	    // Carrega conteúdo da opção através de ajax
		$.ajax({		
			type: "POST", 
			dataType: "html",
			url: UrlOperacao,
			data: {
				nrdconta: nrdconta,
				sitaucaoDaContaCrm: sitaucaoDaContaCrm,
				redirect: "html_ajax"
			},
            error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
				showError("error", "Não foi possível concluir a requisição..", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
            success: function (response) {
				$("#divConteudoOpcao").html(response);
				controlaFoco(opcao); 
			}				
		}); 
	}					
}


//Função para controle de navegação
function controlaFoco(opcao) {
    var IdForm = '';
    var formid;

    if (opcao == "@") { //Envio de Solicitação
        $('.FirstInput:first ').focus();
	}

}



//
function controlaLayout(operacao) {
	
    altura = '630px';
	largura = '500px';
	
	if (in_array(operacao, ['ENVIO_SOLICITACAO'])) {
		
		nomeForm = 'frmDadosPortabilidade';		
        altura = '425px';
        largura = '555px';
		
        $('#' + nomeForm).css('margin-top', '2px');
		
		var rNrcpfcgc = $('label[for="nrcpfcgc"]', '#'+nomeForm);
		var rNmprimtl = $('label[for="nmprimtl"]', '#'+nomeForm);
		var rNrtelefo = $('label[for="nrtelefo"]', '#'+nomeForm);
		var rDsdemail = $('label[for="dsdemail"]', '#'+nomeForm);
		var rDsdbanco = $('label[for="dsdbanco"]', '#'+nomeForm);
		var rCdageban = $('label[for="cdageban"]', '#'+nomeForm);
		var rNrispbif_ban = $('label[for="nrispbif_ban"]', '#'+nomeForm);
		var rNrcnpjag = $('label[for="nrcnpjag"]', '#'+nomeForm);
		var rNrdocnpj_emp = $('label[for="nrdocnpj_emp"]', '#'+nomeForm);
		var rNmprimtl_emp = $('label[for="nmprimtl_emp"]', '#'+nomeForm);
		var rNrispbif = $('label[for="nrispbif"]', '#'+nomeForm);
		var rNrdocnpj = $('label[for="nrdocnpj"]', '#'+nomeForm);
		var rTpconta = $('label[for="tpconta"]', '#'+nomeForm);
		var rCdagectl = $('label[for="cdagectl"]', '#'+nomeForm);
		var rNrconta = $('label[for="nrconta"]', '#'+nomeForm);
		var rDscodigo = $('label[for="dscodigo"]', '#'+nomeForm);
		var rDtsolicitacao = $('label[for="dtsolicitacao"]', '#'+nomeForm);
		var rDtretorno = $('label[for="dtretorno"]', '#'+nomeForm);
		var rDsmotivo = $('label[for="dsmotivo"]', '#'+nomeForm);
		
		var cNrcpfcgc = $('#nrcpfcgc', '#'+nomeForm);
		var cNmprimtl = $('#nmprimtl', '#'+nomeForm);
		var cNrtelefo = $('#nrtelefo', '#'+nomeForm);
		var cDsdemail = $('#dsdemail', '#'+nomeForm);
		var cDsdbanco = $('#dsdbanco', '#'+nomeForm);
		var cCdageban = $('#cdageban', '#'+nomeForm);
		var cNrispbif_ban = $('#nrispbif_ban', '#'+nomeForm);
		var cNrcnpjag = $('#nrcnpjag', '#'+nomeForm);
		var cNrdocnpj_emp = $('#nrdocnpj_emp', '#'+nomeForm);
		var cNmprimtl_emp = $('#nmprimtl_emp', '#'+nomeForm);
		var cNrispbif = $('#nrispbif', '#'+nomeForm);
		var cNrdocnpj = $('#nrdocnpj', '#'+nomeForm);
		var cTpconta = $('#tpconta', '#'+nomeForm);
		var cCdagectl = $('#cdagectl', '#'+nomeForm);
		var cNrconta = $('#nrconta', '#'+nomeForm);
		var cDscodigo = $('#dscodigo', '#'+nomeForm);
		var cDtsolicitacao = $('#dtsolicitacao', '#'+nomeForm);
		var cDtretorno = $('#dtretorno', '#'+nomeForm);
		var cDsmotivo = $('#dsmotivo', '#'+nomeForm);
		
		rNrcpfcgc.addClass('rotulo').css({ 'width': '90px' });
		cNrcpfcgc.addClass('campoTelaSemBorda').css({ 'width': '110px' });
		
		rNmprimtl.css({ 'width': '50px' });
		cNmprimtl.addClass('campoTelaSemBorda').css({ 'width': '250px' });
		
		rNrtelefo.addClass('rotulo').css({ 'width': '90px' });
		cNrtelefo.addClass('campoTelaSemBorda').css({ 'width': '110px' });
		
		rDsdemail.css({ 'width': '50px' });
		cDsdemail.addClass('campoTelaSemBorda').css({ 'width': '250px' });
		
		rDsdbanco.addClass('rotulo').css({ 'width': '90px' });
		cDsdbanco.addClass('campoTelaSemBorda').css({ 'width': '413px' });
		
		rCdageban.css({ 'width': '80px' });
		cCdageban.addClass('campoTelaSemBorda').css({ 'width': '80px' });
		
		rNrispbif_ban.addClass('rotulo').css({ 'width': '90px' });
		cNrispbif_ban.addClass('campoTelaSemBorda').css({ 'width': '110px' });
		
		rNrcnpjag.css({ 'width': '100px' });
		cNrcnpjag.addClass('campoTelaSemBorda').css({ 'width': '200px' });
		
		rNrdocnpj_emp.addClass('rotulo').css({ 'width': '90px' });
		cNrdocnpj_emp.addClass('campoTelaSemBorda').css({ 'width': '110px' });
		
		rNmprimtl_emp.css({ 'width': '50px' });
		cNmprimtl_emp.addClass('campoTelaSemBorda').css({ 'width': '250px' });
		
		rNrispbif.addClass('rotulo').css({ 'width': '90px' });
		cNrispbif.addClass('campoTelaSemBorda').css({ 'width': '110px' });
		
		rNrdocnpj.css({ 'width': '50px' });
		cNrdocnpj.addClass('campoTelaSemBorda').css({ 'width': '248px' });
		
		rTpconta.addClass('rotulo').css({ 'width': '90px' });
		cTpconta.addClass('campoTelaSemBorda').css({ 'width': '110px' });
		
		rCdagectl.css({ 'width': '50px' });
		cCdagectl.addClass('campoTelaSemBorda').css({ 'width': '75px' });
		
		rNrconta.css({ 'width': '60px' });
		cNrconta.addClass('campoTelaSemBorda').css({ 'width': '110px' });
		
		rDscodigo.addClass('rotulo').css({ 'width': '90px' });
		cDscodigo.addClass('campoTelaSemBorda').css({ 'width': '110px' });
		
		rDtsolicitacao.addClass('rotulo').css({ 'width': '90px' });
		cDtsolicitacao.addClass('campoTelaSemBorda').css({ 'width': '110px' });
		
		rDtretorno.css({ 'width': '189px' });
		cDtretorno.addClass('campoTelaSemBorda').css({ 'width': '110px' });
		
		rDsmotivo.addClass('rotulo').css({ 'width': '90px' });
		cDsmotivo.addClass('campoTelaSemBorda').css({ 'width': '412px' });
		
    } else if (in_array(operacao, ['RECEBIMENTO_SOLICITACAO'])) {
		
		
    }
	
	callafterCapital = '';
	
    divRotina.css('width', largura);
    $('#divConteudoOpcao').css({ 'height': altura, 'width': largura });

	layoutPadrao();

	hideMsgAguardo();
	bloqueiaFundo(divRotina);

	removeOpacidade('divConteudoOpcao');
	divRotina.centralizaRotinaH();

	return false;
}


    
function senhaCoordenador(executaDepois) {
	pedeSenhaCoordenador(2,executaDepois,'divRotina');
}