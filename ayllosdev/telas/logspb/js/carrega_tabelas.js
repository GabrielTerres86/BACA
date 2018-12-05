/*
Autor: Bruno Luiz katzjarowski - Mout's
Data: 06/11/2018
Ultima alteração:

Alterações:
	1 - Alterar altura das linhas (padding 7px) - Bruno Luiz Katzjarowski - Mout's - 15/11/2018
*/

/*
tableConsulta
*/
function carregaTabelas(response){
	var valores = response.retorno.mensagem.item;
	if(typeof valores == 'undefined'){
		hideShowTabela(false);
		showError('error', 'Consulta n&atilde;o retornou resultados.', 'Alerta - Aimaro', 'hideMsgAguardo();');
		return false;
	}else{
		hideMsgAguardo();
	}
	habilitarCamposFiltros(false);
	
	var cddopcao = $('#cddopcao').val();
	var divRegistros = $('.divRegistros');
	$('.tabelaConsultaLog').remove();
	var tabela = getTabelaZerada();
	$(divRegistros).append(tabela);

	$('.tituloRegistros').remove();  

	var colunasParam = getColunas($('#selTipo','#frmLogSPB').val(),cddopcao);
	var thead = $('thead',$(tabela));
	var tbody = $('tbody',$(tabela));

	/* Adicionar cabeçalho */
	var cabecalho = $('<tr>');

	var colunasParamColunas = colunasParam.colunas;
	for (var i = 0; i < colunasParamColunas.length; i++) {
		var colunasCabecalho = colunasParamColunas[i];
		cabecalho.append($('<th>',{
			html: colunasCabecalho
		}));
	}
	$(thead).append(cabecalho);

	/* Adicionar linhas */
	inserirLinhas(valores, $(tabela), colunasParam);

	/* Formatar a tabela */
	formatarTabela(colunasParam, $(tabela));
	formataPaginacao(response);

	/* Atribuir evento de click na tabela */
	$('tr', '.tabelaConsultaLog').unbind("click").bind("click",function(){
		var linha = $(this);
		$('.corSelecao','.tabelaConsultaLog').removeClass('corSelecao');
		$(linha).addClass('corSelecao');
		$('#btDetalhesMensagem').attr('style','');
	});

	adicionarEventosBotoesTabela($(tabela));
	hideShowTabela(true);
	
	/** scrollTop só funciona em elementos recuperados por javascript puro, jquery não recupera */
	var tab = document.getElementById('tabelaResultadoConsulta');
	tab.scrollTop = 0;
	tab.scrollLeft = 0;
}

function formataPaginacao(response){
	var nriniseq = parseInt(response.paginacao.nriniseq);
	var qtregist = parseInt(response.paginacao.qtregist);
	var nrregist = parseInt(response.paginacao.nrregist);

	$('#pagVoltar','#divRegistrosRodape').data('nriniseq',nriniseq);
	$('#pagVoltar','#divRegistrosRodape').data('nrregist',nrregist);
	
	var btVoltarPag = $('#pagVoltar','#divRegistrosRodape');
	var btProxPag = $('#pagProximo','#divRegistrosRodape');

	if(nriniseq >= 1){
		$(btVoltarPag).show();
	}else{
		$(btVoltarPag).hide();
	}

	if(qtregist > (nriniseq + nrregist - 1)){
		$(btProxPag).show();
	}else{
		$(btProxPag).hide();
	}

	/** 
	 * Atualizar Exibição
	*/
	var exibicao = $('#qtdItensTabela','#divRegistrosRodape');
	var strExibicao = 'Exibindo '+(nriniseq == 0 ? nriniseq+1 : nriniseq)+' at&eacute; ';

	if ((nriniseq + nrregist) > qtregist){
		strExibicao += qtregist;
	}else{
		strExibicao += (nriniseq + nrregist);
	}

	strExibicao += ' de '+qtregist;

	$('#aux_nrregist').val(qtregist);

	$(exibicao).html(strExibicao);

}

function abrirDetalhesMensagem(linha){
	if($('#cddopcao').val() != "S")
    	getDetalhesMensagem(linha);
    else{
    	carregaDetalhesDaMensagem(Array(),linha);
    }
}

function adicionarEventosBotoesTabela(tabela){
	$('#btDetalhesMensagem').unbind('click').bind('click',function(e){
		e.preventDefault();

		var linha = $(".corSelecao",'.tabelaConsultaLog');
		
		if($(linha).length == 0){
			showError('error', 'Favor selecionar um registro para consultar.', 'Alerta - Aimaro', '');
		}else{
			abrirDetalhesMensagem(linha);
		}
		$(this).blur();
		return false;
	});
}

function doubleClickTabela(){
	var linha = $(".corSelecao",'#tableConsulta');
	abrirDetalhesMensagem(linha);
}

function formatarTabela(colunasParam, tabela){
	var arrLargura = Array();
	var arrAlinha = Array();
	var ordemInicial = Array();

	var keys = colunasParam.keys;
	for (var i = 0; i < keys.length; i++) {
		var itemKey = keys[i];
		arrLargura.push(getLarguraColuna(itemKey));
		if(itemKey == 'valor' || itemKey == "vltransa") //Se for a coluna de valor jogar a mesma para a direita
			arrAlinha.push('right');
		else
			arrAlinha.push('left');
		
	}

	arrAlinha = Array();
	$('div.divRegistros', '.divTabelaLogSpb').css({ 'height': '150px', 'width' : '100%'});
	$("#divRegistrosRodape").formataRodapePesquisa();
	$(tabela).formataTabela(ordemInicial, arrLargura, arrAlinha, "doubleClickTabela();");

	/* forçar barras de rolagem */
	$('.divRegistros').attr('style',"overflow-y: scroll;overflow-x: scroll;height: 300px;width: 980px;");
	$('.divRegistrosRodape').attr('style','width: 980px;');
	$('thead', tabela).show();
	$('.tituloRegistros').hide();
	
	$(tabela).addClass('tabelaConsultaLog');
	
	/**
	 * Aplicar estilo ao cabeçalho para imitar padrão
	 */
	for (var i = 0; i < keys.length; i++) {
		var itemKey = keys[i];
		var colunaCabecalho = $('thead th', tabela)[i];
		$(colunaCabecalho).addClass('linhaCabecalho');
		if(itemKey == 'valor' || itemKey == "vltransa"){
			$(colunaCabecalho).attr('style','padding-right: 12px; text-align: right; width: '+getLarguraColuna(itemKey)+' !important;');
		}else
			$(colunaCabecalho).attr('style','text-align: left; width: '+getLarguraColuna(itemKey)+' !important;');
	}

	/** Alterando cor de fundo do cabeçalho */
	$('thead th', tabela).addClass('corFundoCabecalho');

	/* Aumentar altura das linhas */
	$('tbody tr',tabela).each(function(){
		var linha = $(this);
		for (var i = 0; i < keys.length; i++) {
			var itemKey = keys[i];
			var colunasLinha = $('td', linha)[i];
			$(colunasLinha).addClass('colunaConsulta');

			if(itemKey == 'valor' || itemKey == "vltransa"){
				$(colunasLinha).attr('style','padding-right: 12px; text-align: right; width: '+getLarguraColuna(itemKey)+' !important;');
			}else
				$(colunasLinha).attr('style','text-align: left; width: '+getLarguraColuna(itemKey)+' !important;');
		}
	});

	var linhasPares = $('.tabelaConsultaLog tbody tr:nth-child(even) td');
	$(linhasPares).addClass('tabelaBorda');

	if($('#cddopcao').val() != "S")
		$(tabela).attr('style','width: 3800px;');
	else
		$(tabela).attr('style','width: 2800px;');

	//Remover linha selecionada
	$('.corSelecao',tabela).removeClass('corSelecao');
	//Botão detalhes da mensagem já vem desabilitado por não ter uma linha selecionada
	$('#btDetalhesMensagem').attr('style','color: gray; cursor: default; pointer-events: none;');
}

/*
	Todas as colunas
*/
function inserirLinhas(valores, tabela, colunasParam){

	var tbody = $('tbody',$(tabela));

	if(typeof valores.length != "number"){
		var linha = getLinhasTabela(valores, colunasParam);
		$(tbody).append($(linha));
	}else{
		/* Inserir linhas */
		for (var i = 0; i < valores.length; i++) {
			var valLinha = valores[i];
			var linha = getLinhasTabela(valLinha, colunasParam);
			$(tbody).append($(linha));
		}
	}
}


function getLinhasTabela(linValores, colunasParam){
	var tr = $('<tr>');

	/* Adicionando parametros para consulta de detalhes da mensagem */
	$(tr).attr('data-nrseq_mensagem', linValores.nrseq_mensagem);
	$(tr).attr('data-idorigem', linValores.idorigem);
	var keys = colunasParam.keys;
	for (var i = 0; i < keys.length; i++) {
		var elemKey = keys[i];
		var valor = "";

		/* 
			Fazer validaçõa das colunas aqui de acordo com a key da mesma 
		*/
		if(elemKey == 'agenciaremet'){ //Remover zeros a esquera da coluna Agencia Remet.
			valor = linValores[elemKey];
			if(typeof valor == 'string')
				valor = valor.replace(/^0+/, '');
		}else{
			valor = linValores[elemKey];
		}

		/* criar coluna da linha */
		var td = $('<td>',{
			text: valor
		});

		/* Adicionar valor à linha */
		$(td).attr('data-'+elemKey, linValores[elemKey]);

		/* Adicionar coluna a linha */
		$(tr).append(td);
	}

	return tr;
}

/*
 @param tipo #selTipo - T|E|R
 	T -> Todas
 	E -> Enviadas
 	R -> Recebidas
 @param cddopcao C|M|S
 @return array
*/
function getColunas(tipo, cddopcao){
	var colunasTabelaPrincipal = {
		colunas: undefined,
		keys: undefined
	};
	/* colunas no caso de tipo ser 'T' */

	if(cddopcao == "C"){
		switch(tipo){
			case 'E':
			case 'T':
				colunasTabelaPrincipal.colunas = [
					"Data", //datamsg
					'Hora', //horamsg
					"Mensagem", //dsmensagem
					"Num. Controle", //numcontrole
					"Valor", //valor
					"Situa&ccedil;&atilde;o", //situacao
					"Banco Remet", //bancoremet
					"Ag&ecirc;ncia Remet", //agenciaremet
					"Conta Remet", //contaremet
					"Nome Remet", //nomeremet
					"CPF/CNPJ Remet", //cpfcnpjremet
					"Banco Dest", //bancodest
					"Ag&ecirc;ncia Dest", //agenciadest
					"Conta Dest", //contadest
					"Nome Dest", //nomedest
					"CPF/CNPJ Dest", //cpfcnpjdest
					'Motivo Devolu&ccedil;&atilde;o', //motdev
					"Caixa", //caixa
					"Origem", //origem
					"Operador", //operador
					"Crise", //crise
					"Cooperativa" //cooperativa
				];
				colunasTabelaPrincipal.keys = [
						"datamsg",'horamsg', "dsmensagem", "numcontrole", "valor", "situacao", "bancoremet", "agenciaremet", "contaremet",
						"nomeremet", "cpfcnpjremet", "bancodest", "agenciadest", "contadest", "nomedest",
						"cpfcnpjdest", 'motdev' ,"caixa", "origem", "operador", "crise", "cooperativa"
				];
			break;
			case 'R':
				colunasTabelaPrincipal.colunas = [
					"Data", //datamsg
					'Hora', //horamsg
					"Mensagem", //dsmensagem
					"Num. Controle", //numcontrole
					"Valor", //valor
					"Situa&ccedil;&atilde;o", //situacao
					"Banco Remet", //bancoremet
					"Ag&ecirc;ncia Remet", //agenciaremet
					"Conta Remet", //contaremet
					"Nome Remet", //nomeremet
					"CPF/CNPJ Remet", //cpfcnpjremet
					"Banco Dest", //bancodest
					"Ag&ecirc;ncia Dest", //agenciadest
					"Conta Dest", //contadest
					"Nome Dest", //nomedest
					"CPF/CNPJ Dest", //cpfcnpjdest
					'Motivo Devolu&ccedil;&atilde;o', //motdev
					"Crise", //crise
					"Cooperativa" //cooperativa
				];
				colunasTabelaPrincipal.keys = [
						"datamsg",'horamsg', "dsmensagem", "numcontrole", "valor", "situacao", "bancoremet", "agenciaremet", "contaremet",
						"nomeremet", "cpfcnpjremet", "bancodest", "agenciadest", "contadest", "nomedest",
						"cpfcnpjdest", 'motdev', "crise", "cooperativa"
				];
			break;
		};
	}else if(cddopcao == 'S'){
		colunasTabelaPrincipal.colunas = [
			"Data", //dhtransa
			"Hora", //hrtransa
			"Mensagem", //vltransa
			"Num. Controle", //numcontrole
			"Valor", //valor
			//"Situa&ccedil;&atilde;o", //situacao
			"Banco Remet.", //cdbanren
			"ISPB Remet.", //cdispbren
			"Ag&ecirc;ncia Remet.", //agenciaremet
			"Conta Remet.", //contaremet
			"Nome Remet.", //dsnomrem
			"CPF/CNPJ Remet.", //dscpfrem
			"Banco Dest.", //cdbandst
			"ISPB Dest.", //cdispbdst
			"Ag&ecirc;ncia Dest.", //cdagedst
			"Conta Dest.", //nrctadst
			"Nome Dest.", //dsnomdst
			"CPF/CNPJ Dest.", //dscpfdst
			"Caixa",
			"JDSPB" //dstransa
			//"Crise", //crise
			//"Cooperativa", //cooperativa
		];

		colunasTabelaPrincipal.keys = [
				"dhtransa", "hrtransa","nmevento", "nrctrlif", "vltransa", //"situacao", 
				"cdbanren", "cdispbren","cdagerem", "nrctarem",
				"dsnomrem", "dscpfrem", "cdbandst", "cdispbdst","cdagedst", "nrctadst",
				"dsnomdst", "dscpfdst", "caixa", "dstransa"//"crise", "cooperativa"
		];
	}else if(cddopcao == "M"){
		colunasTabelaPrincipal.colunas = [
					"Data", //datamsg
					'Hora', //horamsg
					"Mensagem", //dsmensagem
					"Num. Controle", //numcontrole
					"Valor", //valor
					"Situa&ccedil;&atilde;o", //situacao
					"Banco Remet", //bancoremet
					"Ag&ecirc;ncia Remet", //agenciaremet
					"Conta Remet", //contaremet
					"Nome Remet", //nomeremet
					"CPF/CNPJ Remet", //cpfcnpjremet
					"Banco Dest", //bancodest
					"Ag&ecirc;ncia Dest", //agenciadest
					"Conta Dest", //contadest
					"Nome Dest", //nomedest
					"CPF/CNPJ Dest", //cpfcnpjdest
					'Motivo Devolu&ccedil;&atilde;o', //motdev
					"Crise", //crise
					"Cooperativa", //cooperativa
					"Coop Migrada", //coopmigrada
					"Conta Migrada" //nrcontamigrada
				];

		colunasTabelaPrincipal.keys = [
				"datamsg",'horamsg', "dsmensagem", "numcontrole", "valor", "situacao", "bancoremet", "agenciaremet", "contaremet",
				"nomeremet", "cpfcnpjremet", "bancodest", "agenciadest", "contadest", "nomedest",
				"cpfcnpjdest", 'motdev', "crise", "cooperativa", "coopmigrada", "nrcontamigrada"
		];
	}

	return colunasTabelaPrincipal;
}


function getLarguraColuna(key){
	var largura = {
			datamsg: "80px",
			horamsg: '55px',
			dsmensagem: "100px",
			numcontrole: "100px", //"", 
			valor: "100px", //"valor", 
			situacao: "150px", //"situacao", 
			bancoremet: "330px", //"bancoremet", 
			agenciaremet: "100px", //"agenciaremet", 
			contaremet: "80px", //"contaremet",
			nomeremet: "360px", //"nomeremet", 
			cpfcnpjremet: "150px", //"cpfcnpjremet", 
			bancodest: "330px", //"bancodest",
			agenciadest: "100px", //"agenciadest", 
			contadest: "70px", //"contadest", 
			nomedest: "330px", //"nomedest",
			cpfcnpjdest: "150px", //"cpfcnpjdest",
			motdev: '330px', //motdev
			caixa: "70px", //"caixa",
			origem: "70px", //"origem", 
			operador: "70px", //"operador", 
			crise: "70px", //"crise", 
			cooperativa: "70px", //"cooperativa", 
			coopmigrada: "70px", //"coopmigrada", 
			nrcontamigrada: "70px", //"nrcontamigrada"
			//COLUNAS OPCAO S
			dhtransa: "70px", 
			hrtransa: "70px",
			nmevento: "70px", 
			nrctrlif: "70px", 
			vltransa: "70px", 
			cdbanren: "70px", 
			cdispbren: "70px",
			cdagerem: "150px", 
			nrctarem: "70px",
			dsnomrem: "350px", 
			dscpfrem: "90px", 
			cdbandst: "70px", 
			cdispbdst: "70px",
			cdagedst: "70px", 
			nrctadst: "70px",
			dsnomdst: "350px", 
			dscpfdst: "90px", 
			dstransa: "70px"
	};
	return largura[key];
}

function getTabelaZerada(){

	var conf = {
		"class": "tabelaConsultaLog",
		id: 'tableConsulta'
	};

	var tabela = $('<table>',conf);

	$(tabela).append($('<thead>')).append($('<tbody>'));

	return tabela;
}