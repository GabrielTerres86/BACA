
function mostraTabelaHistoricoGravames( nriniseq, nrregist ) {

	showMsgAguardo('Aguarde, buscando hist&oacute;rico...');
	limpaDivGenerica();
	$('#divUsoGenerico').css('width','1075px');
	exibeRotina($('#divUsoGenerico'));

	var dschassi = $("#dschassi","#frmTipo").val();
	var cdcoptel = cdcooper;
	var nrctrpro = nrctremp;

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		//url: UrlSite + 'telas/manbem/historico_gravames.php',
		url: UrlSite + 'telas/atenda/prestacoes/cooperativa/historico_gravames.php',
		data: {
			operacao: operacao,
			nrdconta: nrdconta,
			nrctrpro: nrctrpro,
			dschassi: dschassi,
			cdcoptel: cdcoptel,
			nriniseq: nriniseq,
			nrregist: nrregist,
			redirect: 'html_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			controlaLayoutHistoricoGravames( );
		}
	});
	return false;
}

function controlaLayoutHistoricoGravames() {

	var divRegistro = $('#divDetGravTabela');
	var tabela      = $('table',divRegistro);
	var linha       = $('table > tbody > tr', divRegistro);
	divRegistro.css({'height':'250px'});
	$('div.divRegistros').css({'height':'200px'});
	$('div.divRegistros table tr td:nth-of-type(8)').css({'text-transform':'uppercase'});
	$('div.divRegistros .dtenvgrv').css({'width':'25px'});
	$('div.divRegistros .dtretgrv').css({'width':'25px'});

	var ordemInicial = new Array();
	ordemInicial = [[0,0]];

	var arrayLargura = new Array();
	// arrayLargura[0] = '30px';
	// arrayLargura[1] = '20px';
	// arrayLargura[2] = '60px';
	// arrayLargura[3] = '40px';
	// arrayLargura[4] = '55px';
	// arrayLargura[5] = '50px';
	// arrayLargura[6] = '115px';
	// arrayLargura[7] = '';
	// arrayLargura[8] = '25px';
	// arrayLargura[9] = '25px';
	// arrayLargura[10] = '55px';
	arrayLargura[0] = '31px';  	//Coop
	arrayLargura[1] = '30px';	//PA
	arrayLargura[2] = '101px';	//Operação
	arrayLargura[3] = '48px';	//Lote
	arrayLargura[4] = '65px';	//Conta/DV
	arrayLargura[5] = '65px';	//Contrato
	arrayLargura[6] = '140px';	//Chassi
	arrayLargura[7] = '190px';	//Bem
	arrayLargura[8] = '91px';	//Data Envio
	arrayLargura[9] = '91px';	//Data Ret
	arrayLargura[10] = '';		//Situação
	arrayLargura[11] = '14px'; // Fixo para definir o tamanho da coluna do campo da ordenação inicial que fica sobre a barra de rolagem

	var arrayAlinha = new Array();
	// arrayAlinha[0] = 'right';
	// arrayAlinha[1] = 'right';
	// arrayAlinha[2] = 'left';
	// arrayAlinha[3] = 'right';
	// arrayAlinha[4] = 'right';
	// arrayAlinha[5] = 'right';
	// arrayAlinha[6] = 'center';
	// arrayAlinha[7] = 'left';
	// arrayAlinha[8] = 'left';
	// arrayAlinha[9] = 'left';
	// arrayAlinha[10] = 'left';
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
	arrayAlinha[10] = 'left';
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	for( var i in arrayLargura ) {
		$('td:eq('+i+')', tabela ).css('width', arrayLargura[i] );
	}

	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo($('#divUsoGenerico'));
	return false;
}
