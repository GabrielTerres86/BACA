
function mostraTabelaHistoricoGravames( nriniseq, nrregist ) {

	showMsgAguardo('Aguarde, buscando hist&oacute;rico...');
	limpaDivGenerica();
	$('#divUsoGenerico').css('width','750px');
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
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
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
	arrayLargura[0] = '30px';
	arrayLargura[1] = '20px';
	arrayLargura[2] = '60px';
	arrayLargura[3] = '40px';
	arrayLargura[4] = '55px';
	arrayLargura[5] = '50px';
	arrayLargura[6] = '115px';
	arrayLargura[7] = '';
	arrayLargura[8] = '25px';
	arrayLargura[9] = '25px';
	arrayLargura[10] = '55px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'center';
	arrayAlinha[7] = 'left';
	arrayAlinha[8] = 'left';
	arrayAlinha[9] = 'left';
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
