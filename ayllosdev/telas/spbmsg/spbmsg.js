/*****************************************************************************************
 Fonte: spbmsg.js                                                   
 Autor: Mateus Zimmermann - Mouts                                                   
 Data : Agosto/2018            					            
                                                                  
 Objetivo  : Biblioteca de funções da tela SPBMSG
                                                                  
 Alterações:  
						  
******************************************************************************************/

$(document).ready(function() {

	estadoInicial();
			
});

function estadoInicial() {
	
	formataCabecalho();
	$('#frmFiltro').css('display','none');
	$('#frmIncluir').css('display','none');
	$('#divTabela').html('');
	$('#divBotoesFiltro').css('display','none');
	$('#cddopcao','#frmCabSpbmsg').habilitaCampo().focus().val('R');
	
	layoutPadrao();
				
}

function formataCabecalho(){

	$('label[for="cddopcao"]','#frmCabSpbmsg').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCabSpbmsg').css('width','610px');
	$('#divTela').css({'display':'block'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
	$('#frmCabSpbmsg').css('display','block');
		
	highlightObjFocus( $('#frmCabSpbmsg') );
	
	//Ao pressionar botao cddopcao
	$('#cddopcao','#frmCabSpbmsg').unbind('keypress').bind('keypress', function(e){
    
		$('input,select').removeClass('campoErro');
			
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$('#btOK','#frmCabSpbmsg').click();
			$(this).desabilitaCampo();			
			
			return false;						
			
		}
						
	});
	
	//Ao clicar no botao OK
	$('#btOK','#frmCabSpbmsg').unbind('click').bind('click', function(){
		
		if ( $('#cddopcao','#frmCabSpbmsg').hasClass('campoTelaSemBorda')  ) { return false; }
		
		$('#cddopcao','#frmCabSpbmsg').desabilitaCampo();		
		$(this).unbind('click');
		
		if($('#cddopcao','#frmCabSpbmsg').val() == 'C'){
			showError("error","Op&ccedil;&atilde;o n&atilde;o dispon&iacute;vel","Alerta - Aimaro","unblockBackground();estadoInicial();");
		} else {
			formataFiltro();
		}
								
	});
	
	$('#cddopcao','#frmCabSpbmsg').focus();	
    
	return false;
	
}

function formataFiltro(){

	highlightObjFocus( $('#frmFiltro') );
	$('#fsetFiltro').css({'border-bottom':'1px solid #777'});	
	
	$('input','#frmFiltro').val('').habilitaCampo();
	
	//Label do frmFiltro
	var rCdfase   = $('label[for="cdfase"]','#frmFiltro');
	var rCdcooper = $('label[for="cdcooper"]','#frmFiltro');
	var rMensagem = $('label[for="mensagem"]','#frmFiltro');
	var rValorini = $('label[for="valorini"]','#frmFiltro');
	var rValorfim = $('label[for="valorfim"]','#frmFiltro');
	var rHorarioini  = $('label[for="horarioini"]','#frmFiltro');
	var rHorariofim  = $('label[for="horariofim"]','#frmFiltro');
	
	rCdfase.addClass("rotulo").css('width','80px');
	rCdcooper.addClass("rotulo-linha").css('width','75px');
	rMensagem.addClass("rotulo").css('width','80px');
	rValorini.addClass("rotulo-linha").css('width','75px');
	rValorfim.addClass("rotulo-linha").css('width','25px');
	rHorarioini.addClass("rotulo-linha").css('width','75px');
	rHorariofim.addClass("rotulo-linha").css('width','25px');
	  
	//Campos do frmFiltro
	var cCdfase   = $('#cdfase','#frmFiltro');
	var cCdcooper = $('#cdcooper','#frmFiltro');
	var cMensagem = $('#mensagem','#frmFiltro');
	var cValorini = $('#valorini','#frmFiltro');
	var cValorfim = $('#valorfim','#frmFiltro');
	var cHorarioini  = $('#horarioini','#frmFiltro');
	var cHorariofim  = $('#horariofim','#frmFiltro');
  
    cCdfase.css({'width':'270px'});
    cCdcooper.css({'width':'191px'});
    cMensagem.css({'width':'270px'}).addClass('alphanum').attr('maxlength', '20');
    cValorini.css({'width':'80px'}).addClass('moeda');
    cValorfim.css({'width':'80px'}).addClass('moeda');
    cHorarioini.css({'width':'45px'}).setMask("STRING", "99:99", ":", "");
    cHorariofim.css({'width':'45px'}).setMask("STRING", "99:99", ":", "");
		
	// Percorrendo todos os links
    $('input, select', '#frmFiltro').each(function () {
		
		//Define ação para o campo
		$(this).unbind('keypress').bind('keypress', function (e) {

			$('input,select').removeClass('campoErro');
			
			if (divError.css('display') == 'block') { return false; }

			// Se é a tecla ENTER, TAB
			if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {
				
				$(this).nextAll('.campo:first').focus();

				return false;
			}
			
		});
		
	});

	buscarFiltros();
	
	$('#frmFiltro').css('display','block');
	$('#divBotoesFiltro').css('display','block');
	
	layoutPadrao();
	
	return false;
	
}

function buscarMensagens(){	

	var cddopcao = $('#cddopcao','#frmCabSpbmsg').val();
	var cdfase   = $('#cdfase','#frmFiltro').val();
	var cdcooper = $('#cdcooper','#frmFiltro').val();
	var mensagem = $('#mensagem','#frmFiltro').val();
	var valorini = $('#valorini','#frmFiltro').val();
	var valorfim = $('#valorfim','#frmFiltro').val();
	var horarioini  = $('#horarioini','#frmFiltro').val();
	var horariofim  = $('#horariofim','#frmFiltro').val();
		
	showMsgAguardo( "Aguarde, buscando mensagens..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/spbmsg/buscar_mensagens.php", 
        data: {
			cddopcao : cddopcao,
			cdfase   : cdfase,
			cdcooper : cdcooper,
			mensagem : mensagem,
			valorini : valorini,
			valorfim : valorfim,
			horarioini  : horarioini,
			horariofim  : horariofim,
			redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","$('#cddopcao','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divTabela').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();estadoInicial();');
				}
			}
		}
    });
    return false;
	
}

function formataTabelaMensagens(){
	
	var divRegistro = $('div.divRegistros', '#divTabela');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({ 'height': '300px', 'width' : '100%'});
		
	var ordemInicial = new Array();

	// Está setado largura no arquivo busca_mensagens.php para as colunas Fase e IF Destino, pois estavam dando problema de alinhamento,
	// já que o código abaixo seta a lagura apenas do primeiro registro da tabela

	var arrayLargura = new Array();
    arrayLargura[0] = '20px';
    arrayLargura[1] = '81px';
    arrayLargura[2] = '135px';
    arrayLargura[3] = '50px';
    arrayLargura[4] = '120px';
    arrayLargura[5] = '105px';
    arrayLargura[6] = '60px';
    arrayLargura[7] = '76px';
    arrayLargura[8] = '125px';	
    arrayLargura[9] = '145px';
	
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';
	arrayAlinha[7] = 'right';
	arrayAlinha[8] = 'left';
	arrayAlinha[9] = 'center';
	arrayAlinha[10] = 'center';
	
	var metodoTabela = '';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

	$('#marcarDesmarcar').css({'margin-left': '8px','margin-top': '6px'});
	$('#lblMarcarDesmarcar').addClass('rotulo-linha');
	
	$('#divBotoesMensagens').css('display','block');
	$('#frmMensagens').css('display','block');
	
	return false;
	
}

function controlaOperacao(){
	
	var cddopcao = $('#cddopcao','#frmCabSpbmsg').val();
	
	switch(cddopcao){
		
		case 'C':
		
			showError("error","Op&ccedil;&atilde;o n&atilde;o dispon&iacute;vel","Alerta - Aimaro","$('#cddopcao','#frmCabSpbmsg').focus();");
							
		break;
		
		case 'R':
		
			buscarMensagens();
		
		break;		
		
	};
	
	return false;
	
}

function controlaVoltar(op){
	
	
	switch(op){
		
		case '1':
		
			estadoInicial();
			
		break;
		
		case '2':
		
			$('#divTabela').css('display','none');
			formataFiltro();
		
		break;
		
		
	};
	
	return false;
	
}

function buscarFiltros() {

    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/spbmsg/buscar_filtros.php",
        data: {
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
                hideMsgAguardo();
            } catch (error) {
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "");
            }
        }
    });

}

function reprocessarMensagens(){

	showMsgAguardo( "Aguarde, reprocessando mensagens..." );

	var contador = 0;

	var nrseq_mensagem_xml = '';
	var cdcooper = '';
	var nrdconta = '';

	// percorrer todas os registros da tabela e verificar quais estao com o checkbox marcados para reprocessar
	$('table > tbody > tr', '#frmMensagens').each(function(){
		if ($("#reprocessar", this).is(':checked')){
			
			if(nrseq_mensagem_xml != ''){
				nrseq_mensagem_xml += ';';
			}

			if(cdcooper != ''){
				cdcooper += ';';
			}

			if(nrdconta != ''){
				nrdconta += ';';
			}

			nrseq_mensagem_xml += $("#nrseq_mensagem_xml", this).val();
			cdcooper += $("#cdcooper", this).val();
			nrdconta += $("#nrdconta", this).val();

			contador++;
		}
	});

	if(contador == 0){
		showError("error","Selecione pelo menos uma mensagem para reprocessar.","Alerta - Aimaro","hideMsgAguardo();");
	}

	//Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/spbmsg/reprocessa_mensagem.php", 
        data: {
			nrseq_mensagem_xml : nrseq_mensagem_xml,
			cdcooper : cdcooper,
			nrdconta : nrdconta,  
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","");
        },
        success: function(response) {
        	eval(response);
		}
    });
    
    return false;

}

function marcarDesmarcarTodas(cbMarcarDesmarcar){
	
	if($("#marcarDesmarcar", "#frmMensagens").is(':checked')){
		$('input:checkbox').not(cbMarcarDesmarcar).prop('checked', true);
	}else{
		$('input:checkbox').not(cbMarcarDesmarcar).prop('checked', false);
	}
}

function mostrarXMLCompleto(btnXML){

	// Pegar o elemento ao lado do botao XML clicado, nesse caso, a tag span que contem o XML completo
	var dsxml_completo = $(btnXML).prev().html();

	$.ajax({
        type: "POST",
        url: UrlSite + "telas/spbmsg/mostrar_xml_completo.php",
        data: {
        	dsxml_completo : dsxml_completo,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                $("#divRotina").html(response);
                $("#divRotina").centralizaRotinaH();
                exibeRotina($('#divRotina'));
            } catch (error) {
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "");
            }
        }
    });
}

function mostrarLOGReprocessa(log){

	$.ajax({
        type: "POST",
        url: UrlSite + "telas/spbmsg/mostrar_log_reprocessa.php",
        data: {
        	log : log,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                $("#divRotina").html(response);
                exibeRotina($('#divRotina'));
            } catch (error) {
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "");
            }
        }
    });
}
