/*
Autor: Bruno Luiz Katzjarowski - Mout's
Data: 10/11/2018
Ultima alteração:

Alterações:
*/

function carregaDetalhesDaMensagem(response,linha){
 	var cddopcao = $('#cddopcao').val();

	$('#detalhesConsultaCM').hide();
	$('#envioEmail').hide(); //Esconder form de envio de e-mail para criação de relatorio csv
	$('#btEnviarEmail').hide();
	$('#linkAba0').html('Detalhes da Mensagem');
	$('#btFechaConsulta').text('Voltar');

 	if(cddopcao == "S"){
		$('#detalhesConsultaCM').hide();
		$('#detalhesConsultaS').show();
 	}else{
		$('#detalhesConsultaCM').show();
		$('#detalhesConsultaS').hide();
 	}
 	var valores = getValoresLinha(linha); //return {valores: {key: val, keys: [key,key,...]}}

 	if(cddopcao != "S"){
		carregarTabelaLayout1(response,valores); 
 		carregarTabelaLayout2(response);
 		carregarTabelaLayout3(response);
     	carregarTabelaLayout4(response);
		blockBackground(1);
		exibeRotina($('#divRotina'));

		/** 
		 * Se for internet explorer formatar as tabelas
		*/
		if(detectIE() != false){
			formatarLayouts();
		}

		carregaLayoutOpcaoCM();

 	}else{
		exibeRotina($('#divRotina'));
		carregarTabelaLayoutS(linha);
 	}
	 
	/** 
	 * REMOVER TRIGGER QUE IMPEDIA SELEÇÃO DO TEXTO NA TELA DE DETALHES DA MENSAGEM
	*/
	$('#divRotina').unbind('mousedown');
	//atribuiArrastar($('#divRotina'));

}

function carregaLayoutOpcaoCM(){
	var divConteudoOpcao = $('#divConteudoOpcao');
	$(divConteudoOpcao).css({
		'width': '950px'
	});
	ajustarCentralizacao();
}

function carregarTabelaLayoutS(linha){

	if($(linha).length == 0){
		linha = $('.corSelecao','.tabelaConsultaLog');
	}

	var divPrincipal = $('#detalhesConsultaS');
	var valores = getValoresLinha(linha);

	var valKeys = valores.keys;
	for (var i = 0; i < valKeys.length; i++) {
		var elemKey = valKeys[i];
		var elem = $('#'+elemKey,divPrincipal);
		var valor = valores.valores[elemKey];
		$(elem).val(valor);
		$(elem).attr('readonly',true);
	}

	$('#dsmotivo',divPrincipal).attr('readonly',true);
}

function carregarTabelaLayout4(response){
	var layout4 = response.retorno.layout_4;
	var tabela = $('#tabelLayout4');
	var tbody = $('tbody',tabela);
	//{cdfase: "20", nmfase: "Não utiliza OFSAA", datafase: "27-09-2018 13:28:11", xmlfase: Array(0)}
	$('tr',tbody).remove(); //Remover itens antigos da tabela

	var colunas = ['cdfase', 'nmfase', 'dscompl', 'datafase', 'xmlfase'];

	if(typeof layout4 == "undefined"){
		$(tabela).hide();
		return false;
	}else if(typeof layout4.item4 == "undefined"){
		$(tabela).hide();
		return false;
	}else{$(tabela).show();}

	if(typeof layout4.item4.length == "number"){
		var itens = layout4.item4;

		for (var i = 0; i < itens.length; i++) {
			var linhaItem4 = itens[i];
			$(tbody).append(getLinhaLayout4(colunas, linhaItem4));
		}

	}else{
		$(tbody).append(getLinhaLayout4(colunas, layout4.item4));
	}

}

function carregarTabelaLayout3(response){
	var layout3 = response.retorno.layout_3;
	var tabela = $('#tabelLayout3');
	var tbody = $('tbody',tabela);
	$('tr',tbody).remove(); //Remover itens antigos da tabela
	//{datamsg: "27-09-2018 13:28:11", mensagem: "PAG0111", numcontroledevolucao: "1180927010648488352A"}

	var colunas = ['mensagem', 'numcontroledevolucao', 'datamsg']; //Adicionar a coluna à mais aqui e em detalhes_consulta_cm.php
	if(typeof layout3 == "undefined"){
		$(tabela).hide();
		return false;
	}else if(typeof layout3.item3 == "undefined"){
		$(tabela).hide();
		return false;
	}else{$(tabela).show();}

	if(typeof layout3.item3.length == "number"){
		var itens = layout3.item3;

		for (var i = 0; i < itens.length; i++) {
			var linha = itens[i];
			//Inserir linha na tabela
			$(tbody).append(getLinhaLayout3(colunas, linha));
		}

	}else{
		$(tbody).append(getLinhaLayout3(colunas, layout3.item3));
	}
}	

function carregarTabelaLayout2(response){
	var layout2 = response.retorno.layout_2;
	var tabela = $('#tabelLayout2');
	var tbody = $('tbody',tabela);

	//remover itens antigos da tabela
	$('tr',tbody).remove();
	//{cdfase: "100", nmfase: "HORA BACEN", datafase: "04-09-2018 11:22:49", xmlfase: Array(0)}

	if(typeof layout2.item == "undefined"){
		$(tabela).hide();
		console.log(layout2);
		return false;
	}else{
		$(tabela).show();
	}

	/* se retornou mais de um registro */
	var colunas = ['cdfase', 'nmfase', 'dscompl', 'datafase', 'xmlfase'];
	if(typeof layout2.item.length == "number"){
		var itens = layout2.item;
		for (var i = 0; i < itens.length; i++) {
			var linha = itens[i];
			$(tbody).append(getLinhaLayout2(colunas, linha));
		}
	}else{
		$(tbody).append(getLinhaLayout2(colunas, layout2.item));
	}
}

function carregarTabelaLayout1(response,valores){
	var layout1 = response.retorno.layout_1;


	if(typeof layout1.item1 == "undefined"){
		$("#tableDetalhesCM1").hide();
		$("#tableDetalhesCM2").hide();
		console.log(layout1);
		return false;
	}else{
		$("#tableDetalhesCM1").show();
		$("#tableDetalhesCM2").show();
	}

	/* Atribuir valores as colunas da tabela de valores detalhes_consulta_cm.php */
	for ( key in layout1.item1 ){
		var elem = $('#td_'+key); //Elemento à receber o valor
		if(typeof layout1.item1[key] == "object")
			$(elem).html("");
		else{
			$(elem).html(layout1.item1[key]);
		}
	}
}

function getLinhaLayout2(colunas, linha){
	var tr = $('<tr>')

	for (var i = 0; i < colunas.length; i++) {
		var coluna = colunas[i];
		if(coluna == "xmlfase"){
			if(linha[coluna] != ""){

				//ATRIBUIR EVENTO DE ON CLICK PARA ABERTURA DO XML AQUI
				var td = $('<td>',{
					"class": 'colunaXML',
					"data-xml": linha[coluna]
				});

				var btXml = getBtXml();

				$(td).append(btXml);
				$(tr).append(td);
			}else{
				$(tr).append($('<td>',{
					text: '',
					"data-xml": ""
				}));
			}
		}else{
			$(tr).append($('<td>',{
				text: linha[coluna]
			}));
		}
	}
	return tr;
}

function doubleClickXML(xml){
	submitHiddenForm(
	    UrlSite + "telas/logspb/imprimir_xml.php",
	    {
	        xml: $(xml).data('xml')
	    }
	);

}

/*
	Autor: Bruno Luiz Katzjarowski - Mout's
	Criar um form invisivel e dar submit nele para enviar um post para outra página
*/
function submitHiddenForm(url, params) {
    var f = $("<form target='_blank' method='POST' style='display:none;'></form>").attr({
        action: url
    }).appendTo(document.body);
    for (var i in params) {
        if (params.hasOwnProperty(i)) {
            $('<input type="hidden" />').attr({
                name: i,
                value: params[i]
            }).appendTo(f);
        }
    }
    f.submit();
    f.remove();
}

function getLinhaLayout3(colunas, linha){
	var tr = $('<tr>')
	// ['datamsg', 'datamsg', 'numcontroledevolucao'];
	for (var i = 0; i < colunas.length; i++) {
		var coluna = colunas[i];
		
		$(tr).append($('<td>',{
			text: linha[coluna]
		}));
	}
	return tr;
}

function getLinhaLayout4(colunas, linha){
	var tr = $('<tr>')

	for (var i = 0; i < colunas.length; i++) {
		var coluna = colunas[i];
		if(coluna == "xmlfase"){
			if(linha[coluna] != ""){
				//ATRIBUIR EVENTO DE ON CLICK PARA ABERTURA DO XML AQUI
				var td = $('<td>',{
					"class": 'colunaXML',
					"data-xml": linha[coluna]
				});

				var btXml = getBtXml();

				$(td).append(btXml);
				$(tr).append(td);
			}else{
				$(tr).append($('<td>',{
					text: '',
					"data-xml": ""
				}));
			}
		}else{
			$(tr).append($('<td>',{
				text: linha[coluna]
			}));
		}
	}
	return tr;
}

function getValoresLinha(linha){
	var colunas = $('td',linha);

	var valores = Array();
	var keys = Array();
	$(colunas).each(function(){
		var data = $(this).data();
		for ( key in data ) {
			valores[key] = $(this).data(key);
			keys.push(key);
		}
	});

	return {
		valores: valores,
		keys: keys
	};
}

function getBtXml(){
	var btXml = $('<a>',{
		href: '#',
		text: 'XML',
		"class": 'botao'
	});
	$(btXml).unbind('click').bind('click',function(e){
		e.preventDefault();
		doubleClickXML($(this).closest('td'));
		$(this).blur();
		return false;
	});

	return btXml;
}

function formatarLayouts(){
	var cont = 1;
	$('tbody tr','#tableDetalhesCM1').each(function(){
		if((cont%2) > 0){
			$(this).addClass('corPar');
		}else{
			$(this).addClass('corImpar');
		}
		cont++;
	});
	cont = 1;

	$('tbody tr','#tableDetalhesCM2').each(function(){
		if((cont%2) > 0){
			$(this).addClass('corPar');
		}else{
			$(this).addClass('corImpar');
		}
		cont++;
	});
	cont = 1;
	

	$('tbody tr','#tabelLayout2').each(function(){
		if((cont%2) > 0){
			$(this).addClass('corPar');
		}else{
			$(this).addClass('corImpar');
		}
		cont++;
	});
	cont = 1;

	$('tbody tr','#tabelLayout3').each(function(){
		if((cont%2) > 0){
			$(this).addClass('corPar');
		}else{
			$(this).addClass('corImpar');
		}
		cont++;
	});
	cont = 1;

	$('tbody tr','#tabelLayout4').each(function(){
		if((cont%2) > 0){
			$(this).addClass('corPar');
		}else{
			$(this).addClass('corImpar');
		}
		cont++;
	});
	cont = 1;
}

function atribuiArrastar(elementosDrag){

	elementosDrag.unbind('dragstart');	
    elementosDrag.bind('dragstart', function (event) {
		return $(event.target).is('.ponteiroDrag');
	}).bind('drag', function (event) {
        $(this).css({ top: event.offsetY, left: event.offsetX });
    });
}