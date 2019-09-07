/* 
 * FONTE        : ratmov.php
 * CRIAÇÃO      : Luiz Otávio Olinger Momm - AMcom
 * DATA CRIAÇÃO : 29/01/2019
 * OBJETIVO     : Filtros - Alteração/Consulta da Nota do Rating após a Efetivação


* Intruções de uso para outras telas:
Funcão para reutilizar em demais telas para justificar o envio de alteração de Rating do Risco
Param: dadosRating será um array:
- contas, contratos, produtos e nova nota para salvar as informações de justificativa
- o campo tipo pessoa utilizado para rotina PARRAT com o tipoproduto caso precisar validar ou informar algo na interface
- id é o elemento TAG para congelar ou desabilitar algum elemento HTML usado na funcao callback;
item:
	novanota
	conta
	contrato
	tipoproduto
	tipoPessoa
	cpfcfc
	id  ---------------+
					   |
Exemplo:               |
function desabilitaTD(item) {
	if (item.novanota == '') { // motor
		$(item.id).css('background-color','red');
	} else {
		$(item.id).css('background-color','yellow');
	}
}
function salvar(dados) {
	// ajax mensageria
	for(dados) {
		// desfaz estilos
	}
}
function fechar(dados) {
	for(dados) {
		// desfaz estilos
	}
}

var dadosRating = [item, item, ...];
mostrarJustificativa(dadosRating, desabilitaTD, salvar, fechar);
*/

// Mantem fora do escopo da abertura de justificativa a funcao para fechar o dialog
var callbackFecharGeral;

function mostrarJustificativa(paramDadosRating, callbackStatusContrato, callbackSalvar, callbackFechar) {

	callbackFecharGeral = callbackFechar;

	$.ajax({
		type: 'POST',
		url: UrlSite + 'telas/ratmov/ratmov_justificar.php',
		data: {
			dadosRating: paramDadosRating
		}
	}).done(function(retornoHTML) {

		$('#divRotina').html(retornoHTML);
		$('#divRotina').css('width','400px').css('height','200px').css('background-color','#969FA9')

		zIndex = parseInt($('#divRotina').css('z-index'));
		blockBackground(zIndex);

		exibeRotina($('#divRotina'));
		$('#divRotina').css('display', 'block').setCenterPosition();
		layoutPadrao();

		if ($('.campoJustificativa').length == 0) {
			ratmov_enviaJustificativa(paramDadosRating, callbackSalvar);
		} else {
			$('.campoJustificativa').keyup(function () {
				var len = $.trim($(this).val().length);
				// Atualiza contador Justificativa
				ratmov_contadorJustificativa($(this), len);
				// Atualiza contador Justificativa
			});

			$('#btnSalvarJustificativa').click(function () {
				var btnSalvar = $(this);
				var validado = true;

				$('.campoJustificativa').each(function() {
					if ($.trim($(this).val().length) < 11) {
						validado = false;
					}
				});
				if (validado) {
					ratmov_enviaJustificativa(paramDadosRating, callbackSalvar);
				} else {
					// showError('error', 'Justificativa deve possuir 11 caracteres ou mais.', 'Alerta - Aimaro', '');
					$('#ratmovJustificativaValidacao').html('Todas as justificativas devem possuir no m&iacute;nimo 11 caracteres.').show();
				}
			});
		}

	}).fail(function(html) {
		
	}).always(function() {
		
	});


	for (index = 0; index < paramDadosRating.length; ++index) {
		var item = paramDadosRating[index][0];

		// Para esteira
		if (item.novanota != '') {
		}

		// Para esteira
		callbackStatusContrato(item);
	}

	return '';
}

function ratmov_enviaJustificativa(paramDadosRating, callbackSalvar) {
	$('.campoJustificativa').each(function() {
		for (i = 0; i < paramDadosRating.length; i++) {

			if (paramDadosRating[i][0]['id'] == $(this).data('idjustificativa')) {
				paramDadosRating[i][0]['justificativa'] = $(this).val();
			}
		}
	});

	var verificaNotasValidas = true;
	$("#ratmovErros").html('');
	
	var linhasErro = '';
	for (i = 0; i < dadosRating.length; i++) {
		if (
			dadosRating[i][0]['novanota'] != '' &&
			dadosRating[i][0]['novanota'].toUpperCase() != 'AA' &&
			dadosRating[i][0]['novanota'].toUpperCase() != 'A' &&
			dadosRating[i][0]['novanota'].toUpperCase() != 'B' &&
			dadosRating[i][0]['novanota'].toUpperCase() != 'C' &&
			dadosRating[i][0]['novanota'].toUpperCase() != 'D' &&
			dadosRating[i][0]['novanota'].toUpperCase() != 'E' &&
			dadosRating[i][0]['novanota'].toUpperCase() != 'F' &&
			dadosRating[i][0]['novanota'].toUpperCase() != 'G' &&
			dadosRating[i][0]['novanota'].toUpperCase() != 'H'
			) {
				item = dadosRating[i][0];
				verificaNotasValidas = false;
				linhasErro += '<div style="width: 310px; text-align: left;"><b>Rating novo &quot;'+ item['novanota'] +'&quot; inv&aacute;lido.</b><br>Verificar o contrato ' + item['contrato'] + ' para prosseguir.</div><br style="clear:both" />';
		}
	}
	
	if (verificaNotasValidas) {
		
		$('#btnRATMOV_SalvarSIM').click(function(){
			ratmov_fecharJustificativas();
			callbackSalvar(paramDadosRating);
		});

		$("#ratmovIDJustificativas").hide();
		$("#ratmovErros").hide();
		$("#ratmovConfirmacaoSalvar").show();
	} else {
		$("#ratmovConfirmacaoSalvar").hide();
		$("#ratmovIDJustificativas").hide();
		var linhasErro = '<br style="clear:both" />' + linhasErro;
		linhasErro += '<a href="#" class="botao" id="btnRATMOV_FecharErros" name="btnRATMOV_FecharErros" onClick="ratmov_fecharJustificativas(); return false;" style = "margin: 5px 0px 10px 30px; text-align:right;">Fechar</a>';
		$("#ratmovErros").html(linhasErro);
		$("#ratmovErros").show();
	}
}

function ratmov_repetirJustificativa(idOriginal) {
	var textoRepetir = '';
	if ($("#checkboxRepetirJustificativa").is(':checked') == true) {
		textoRepetir = $('#'+idOriginal).val();
	}
	var len = $.trim(textoRepetir).length;

	$(".campoJustificativa").each(function() {
		if ($(this).attr('id') != idOriginal) {

			$(this).val(textoRepetir);

			// Atualiza contador Justificativa
			ratmov_contadorJustificativa($(this), len);
			// Atualiza contador Justificativa

		}
	});
}

function ratmov_contadorJustificativa(textJustificativa, len) {
	var id = $(textJustificativa).data('idjustificativa');
	var elemento = $('#contadorJustificativa' + id);
	if (len < 11) {
		elemento.removeAttr('color');
		elemento.css('color', 'red');
	} else {
		elemento.removeAttr('color');
		elemento.css('color', '#000');
	}
	elemento.html(len + ' caracteres');
}

function ratmov_fecharJustificativas() {
	$(".campoJustificativa").each(function() {
		$(this).text('');
	});
	$(".campoJustificativa").prop('checked', true);
	fechaRotina($('#divRotina'));
	callbackFecharGeral();
}