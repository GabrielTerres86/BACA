/***********************************************************************
 Fonte: conlog.js                                                  
 Autor: Thaise - Envolti
 Data : Setembro/2018
                                                                   
 Objetivo  : Cadastro de servicos ofertados na tela CONLOG
***********************************************************************/

$(document).ready(function(){
	formataFiltro();
});

function formataFiltro(){
	$('#frmFiltro').css({ 'display': 'block' });

	$('#nmarqlog[type=text]').unbind('keyup').bind('keyup', function(e){
		if($(this).val().length == 0 && e.keyCode == 8){
			$(this).css({ 'display': 'none' });
			$('select[name=nmarqlog]').css({ 'display': 'block' });
			$('select[name=nmarqlog]').focus();
			$('select[name=nmarqlog] option:eq(0)').attr('selected', 'selected');
		}
	});

	$('#nmarqlog[type=text]').css({ 'display': 'none' });
	
	$('#dtde', '#divFiltro').css({ 'width': '130px' }).habilitaCampo().setMask('INTEGER','/z9/zzz9', '/', '');
	$('#dtate', '#divFiltro').css({ 'width': '130px' }).habilitaCampo().setMask('INTEGER','/z9/zzz9', '/', '');
	$('#cdcooper', '#divFiltro').css({ 'width': '175px' }).habilitaCampo();
	$('#cdprogra', '#divFiltro').css({ 'width': '130px', 'text-transform': 'uppercase' }).habilitaCampo();
	$('#tpocorre', '#divFiltro').css({ 'width': '130px' }).habilitaCampo();
	$('#nmarqlog', '#divFiltro').css({ 'width': '175px' }).habilitaCampo();
	$('#dsmensag', '#divFiltro').css({ 'width': '421px', 'text-transform': 'uppercase' }).habilitaCampo();
	$('#clausula', '#divFiltro').css({ 'width': '175px' }).habilitaCampo();
	$('#cdmensag', '#divFiltro').css({ 'width': '130px' }).habilitaCampo();
	$('#orderby', '#divFiltro').css({ 'width': '130px' }).habilitaCampo();
	$('#ordenaca', '#divFiltro').css({ 'width': '130px' }).habilitaCampo();
	$('#cdcriti', '#divFiltro').css({ 'width': '175px' }).habilitaCampo();
	$('#tpexecuc', '#divFiltro').css({ 'width': '175px' }).habilitaCampo();
	$('#chamaber', '#divFiltro').css({ 'width': '130px' }).habilitaCampo();
	$('#nrchamad', '#divFiltro').css({ 'width': '130px' }).habilitaCampo();

	$('#dtate', '#divFiltro').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			$('#cdcooper', '#divFiltro').focus();
			return false;
		}
	});

	$('#nmarqlog').unbind('keypress').bind('keypress', function(e){
		if($(this).is('select')){
			$(this).css({ 'display': 'none' });
			$(this).val('');
			$('#nmarqlog[type=text]').css({ 'display': 'block' });
			$('#nmarqlog[type=text]').focus();
			$('#nmarqlog[type=text]').val();
		}

		if(e.keyCode == 8){

		} else{

		}
	});
	
	$('#btConsultar').unbind('click').bind('click', function(){
		$('#divTabela').html('');
		$('#divTabelaDetalhes').html('');
		$('#divTabelaErro').html('');
		buscarDadosLog();
	});
}

function buscarDadosLog(){
	showMsgAguardo('Aguarde, buscando logs...');
	var dtde = $('#dtde', '#divFiltro').val();
	var dtate = $('#dtate', '#divFiltro').val();
	var cdcooper = $('#cdcooper', '#divFiltro').val();
	var cdprogra = $('#cdprogra', '#divFiltro').val();
	var tpocorre = $('#tpocorre', '#divFiltro').val();
	var nmarqlog;
	if($('#nmarqlog[type=text]').is(':visible')){
		nmarqlog = $('#nmarqlog[type=text]', '#divFiltro').val();
	} else{
		nmarqlog = $('select[name=nmarqlog]', '#divFiltro').val();
	}
	var clausula = $('#clausula', '#divFiltro').val();
	var cdmensag = $('#cdmensag', '#divFiltro').val();
	var dsmensag = $('#dsmensag', '#divFiltro').val();
	var cdcriti = $('#cdcriti', '#divFiltro').val();
	var tpexecuc = $('#tpexecuc', '#divFiltro').val();
	var chamaber = $('#chamaber', '#divFiltro').val();
	var nrchamad = $('#nrchamad', '#divFiltro').val();
	
	//Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/conlog/busca_dados_log.php",
        data: {
			cdcooper: cdcooper,
			cdprogra: cdprogra,
            dtde: dtde,
			dtate: dtate,
			nmarqlog: nmarqlog,
			cdmensag: cdmensag,
			dsmensag: dsmensag,
			tpocorre: tpocorre,
			cdcriti: cdcriti,
			clausula: clausula,
			tpexecuc: tpexecuc,
			chamaber: chamaber,
			nrchamad: nrchamad,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "formataFiltro();");
        },
        success: function (response) {

            hideMsgAguardo();
            try 
            {
            	if(response.indexOf('showError') > -1){
            		eval(response);
            	} else {
                	$('#divTabela').html(response);
					formatarTabelaLogs();
					buscarDadosErro();
				}
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "formataFiltro();");
            }
        }

    });
}

function buscarDetalhesLog(){
	showMsgAguardo('Aguarde, buscando detalhes...');
	var dtde = $('#dtde', '#divFiltro').val();
	var dtate = $('#dtate', '#divFiltro').val();
	var cdcooper = $('#cdcooper', '#divFiltro').val();
	var cdprogra = $('#cdprogra', '#divFiltro').val();
	var tpocorre = $('#tpocorre', '#divFiltro').val();
	var nmarqlog;
	if($('#nmarqlog[type=text]').is(':visible')){
		nmarqlog = $('#nmarqlog[type=text]', '#divFiltro').val();
	} else{
		nmarqlog = $('select[name=nmarqlog]', '#divFiltro').val();
	}
	var clausula = $('#clausula', '#divFiltro').val();
	var cdmensag = $('#cdmensag', '#divFiltro').val();
	var dsmensag = $('#dsmensag', '#divFiltro').val();
	var cdcriti = $('#cdcriti', '#divFiltro').val();
	var tpexecuc = $('#tpexecuc', '#divFiltro').val();
	var chamaber = $('#chamaber', '#divFiltro').val();
	var nrchamad = $('#nrchamad', '#divFiltro').val();
	var idprglog = $('#divTabela .corSelecao').find('td#idprglog').find('span').html();
	
	
	
	//Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/conlog/busca_dados_detalhe.php",
        data: {
			cdcooper: cdcooper,
			cdprogra: cdprogra,
            dtde: dtde,
			dtate: dtate,
			nmarqlog: nmarqlog,
			cdmensag: cdmensag,
			dsmensag: dsmensag,
			tpocorre: tpocorre,
			cdcriti: cdcriti,
			idprglog: idprglog,
			clausula: clausula,
			tpexecuc: tpexecuc,
			chamaber: chamaber,
			nrchamad: nrchamad,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "formataFiltro();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {

                $('#divTabelaDetalhes').html(response);
				formataTabelaDetalhes();
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "formataFiltro();");
            }
        }

    });
}

function buscarDadosErro(){	
	showMsgAguardo('Aguarde, buscando erros...');
	var dtde = $('#dtde', '#divFiltro').val();
	var dtate = $('#dtate', '#divFiltro').val();
	var cdcooper = $('#cdcooper', '#divFiltro').val();
	var clausula = $('#clausula', '#divFiltro').val();
	var dsmensag = $('#dsmensag', '#divFiltro').val();
	
	//Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/conlog/busca_dados_erros.php",
        data: {
			cdcooper: cdcooper,
            dtde: dtde,
			dtate: dtate,
			dsmensag: dsmensag,
			clausula: clausula,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "formataFiltro();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {

                $('#divTabelaErro').html(response);
				formataTabelaErros();
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "formataFiltro();");
            }
        }

    });
}

function formatarTabelaLogs(){
	var divRegistro = $('#divTabela div.divRegistros');
	divRegistro.css({'padding-bottom':'1px'}); 
	
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	var arrayAlinha = new Array();

	if(linha.hasClass('semRegistros')){
		arrayAlinha[0]= 'center';
	} else {
		arrayLargura[0] = '21px';   //Contador
		arrayLargura[1] = '55px';  	//Cooper
		arrayLargura[2] = '65px';	//Idprglog
		arrayLargura[3] = '240px';	//Programa
		arrayLargura[4] = '210px';	//Arquivo Log
		arrayLargura[5] = '120px';	//Dh Início
		arrayLargura[6] = '120px';	//Dh Fim
		arrayLargura[7] = '65px';	//Tipo Execução
		arrayLargura[8] = '15px'; // Fixo para definir o tamanho da coluna do campo da ordenação inicial que fica sobre a barra de rolagem
	
		arrayAlinha[0]= 'right';
    	arrayAlinha[1] = 'rigth';
   		arrayAlinha[2] = 'right';
	    arrayAlinha[3] = 'left';
    	arrayAlinha[4] = 'left';
    	arrayAlinha[5] = 'left';
    	arrayAlinha[6] = 'left';
    	arrayAlinha[7] = 'rigth';
	}
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'buscarDetalhesLog()' );
}

function formataTabelaDetalhes(){
	var divRegistro = $('#divTabelaDetalhes div.divRegistros');
	divRegistro.css({'padding-bottom':'1px'}); 
	
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	var arrayAlinha = new Array();

	if(linha.hasClass('semRegistros')){
		arrayAlinha[0]= 'center';
	} else {	
		arrayLargura[0] = '21px';   //Contador
		arrayLargura[1] = '70px';  	//Id Ocorrência
		arrayLargura[2] = '113px';	//Dh Ocorrência
		arrayLargura[3] = '52px';	//Tipo Ocorrência
		arrayLargura[4] = '48px';	//Criticidade
		arrayLargura[5] = '64px';	//Cod. Mensagem
		arrayLargura[6] = '';	//Descrição
		arrayLargura[7] = '17px'; // Fixo para definir o tamanho da coluna do campo da ordenação inicial que fica sobre a barra de rolagem
	
		arrayAlinha[0] = 'right';
    	arrayAlinha[1] = 'rigth';
	    arrayAlinha[2] = 'left';
    	arrayAlinha[3] = 'right';
	    arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'left';
	}
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
}

function formataTabelaErros(){
	var divRegistro = $('#divTabelaErro div.divRegistros');
	divRegistro.css({'padding-bottom':'1px'}); 
	
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	var arrayAlinha = new Array();

	if(linha.hasClass('semRegistros')){
		arrayAlinha[0]= 'center';
	} else {		
		arrayLargura[0] = '21px';
		arrayLargura[1] = '55px';  	//Cooper
		arrayLargura[2] = '113px';	//Dh Erro
		arrayLargura[3] = '60px';	//SqlCode
		arrayLargura[4] = '';	//Mensagem
		arrayLargura[5] = '14px'; // Fixo para definir o tamanho da coluna do campo da ordenação inicial que fica sobre a barra de rolagem
	
		arrayAlinha[0] = 'rigth';
	    arrayAlinha[1] = 'rigth';
    	arrayAlinha[2] = 'left';
	    arrayAlinha[3] = 'right';
    	arrayAlinha[4] = 'left';
	}
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
}

