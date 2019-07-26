//*********************************************************************************************//
//*** Fonte: cusapl.js                                                 						          ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					    ***//
//***                                                                  						          ***//
//*** Objetivo  : Biblioteca de funções da tela                     						            ***//
//***                                                                  						          ***//
//*** Alterações: 																			                                    ***//
//***																		                ***//
//*********************************************************************************************//

var Cdsvlrprm24;
var frmCab   		= 'frmCab';
var frmPesquisa   		= 'frmPesquisa';
var cNrdconta;

$(document).ready(function() {
  	atualizaSeletor();
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
	$('label[for="cddopcao"]').css({'margin-left':'10px'});

    // Adicionar os itens do campo select das cooperativas
    //lista_coop();
});

function myTrim(x) {
    return x.replace(/^\s+|\s+$/gm,'');
}

// Botao Voltar
function btnVoltar() {
    estadoInicial();
    return false;
}

function atualizaSeletor(){
  cNrdconta			= $('#nrdconta','#'+frmPesquisa);

  return false;
}

function btnOK(nriniseq, nrregist) {
  cNrdconta.habilitaCampo().focus();
	if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    } else {
        $('#cddopcao', '#frmCab').attr('disabled', 'disabled');
        $('#cdcooper', '#frmCab').attr('disabled', 'disabled');
        $('#btnOK').hide();
        controlaOperacao(1,30);
    }
}

function btnconsulta() {
  $('#divLogsDeArquivo').html('');
  $('#divRegistrosArquivo').html('');
	if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    } else {
        consulta(1,30);
    }
}

function atualizaCooperativaSelecionada(combocooperativa){
  $('#nrdconta','#frmPesquisa').val('');
  $('#dtmvtolt','#frmPesquisa').val('');
  $('#nraplica','#frmPesquisa').val('0');

  if(combocooperativa.val()=='0'){
    $('#nrdconta','#frmPesquisa').attr('readonly', 'readonly');
    $('#brnBuscaConta').hide();
    } else {
    $('#nrdconta','#frmPesquisa').removeAttr("readonly");
    $('#brnBuscaConta').show();
  }
}

function btnconsultaCustodiaPendentes() {//alert('teste');
	if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    } else {
        consultaCustodiaPendentes(1,30);
    }
}

function btnBuscaLogsDeArquivos() {
    consultaLogsDeArquivos();//3995
}

function controlaOperacao(nriniseq, nrregist) {
    var cddopcao = $("#cddopcao", "#frmCab").val();
    var cdcooper = $("#cdcooper", "#frmCab").val();

    if (cddopcao == 'R' || cddopcao == 'E' ){
      $('#cddopcao', '#frmCab').removeAttr("disabled");
      $('#btnOK').show();
      showConfirmacao('Deseja confirmar a solicita&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacaoProc(1,30)','return false','sim.gif','nao.gif');
    }else{
      var hdnconta   = normalizaNumero($("#hdnconta", "#frmPesquisa").val());
      var hdncooper  = normalizaNumero($("#hdncooper", "#frmPesquisa").val());
      var hdnremessa = normalizaNumero($("#hdnremessa", "#frmPesquisa").val());

      // Mostra mensagem de aguardo
      showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

        // Carrega conte�do da op��es atrav�s de ajax
      $.ajax({
          type: "POST",
          dataType: 'html',
          url: UrlSite + "telas/cusapl/obtem_consulta.php",
          data: {
              cddopcao   : cddopcao,
              nriniseq   : nriniseq,
              nrregist   : nrregist,
              hdnconta   : hdnconta,
              hdncooper  : hdncooper,
              hdnremessa : hdnremessa,
              cdcooper : cdcooper,
              redirect   : "script_ajax" // Tipo de retorno do ajax
          },
          error: function(objAjax, responseError, objExcept) {
              hideMsgAguardo();
              showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
          },
          success: function(response) {
              if (response.substr(0, 14) == 'hideMsgAguardo') {
                  eval(response);
              } else {
                  $('#divFormulario').html(response);
                  hideMsgAguardo();
              }
          }
      });
      return false;
    }
}

function controlaOperacaoProc(nriniseq, nrregist){

  var cddopcao = $("#cddopcao", "#frmCab").val();
  var hdnconta   = normalizaNumero($("#hdnconta", "#frmPesquisa").val());
  var hdncooper  = normalizaNumero($("#hdncooper", "#frmPesquisa").val());
  var hdnremessa = normalizaNumero($("#hdnremessa", "#frmPesquisa").val());

  // Mostra mensagem de aguardo
  showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    // Carrega dados via ajax
  $.ajax({
      type: "POST",
      dataType: 'html',
      url: UrlSite + "telas/cusapl/obtem_consulta.php",
      data: {
          cddopcao   : cddopcao,
          nriniseq   : nriniseq,
          nrregist   : nrregist,
          hdnconta   : hdnconta,
          hdncooper  : hdncooper,
          hdnremessa : hdnremessa,
          redirect   : "script_ajax" // Tipo de retorno do ajax
      },
      error: function(objAjax, responseError, objExcept) {
          hideMsgAguardo();
          showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
      },
      success: function(response) {
          if (response.substr(0, 14) == 'hideMsgAguardo') {
              eval(response);
          } else {
            $("#divDados").html(response);
            $('#divRotina').html(response);
            hideMsgAguardo();
            // centraliza a divRotina
            $('#divRotina').css({'width':'575px'});
            $('#divConteudo').css({'width':'550px'});
            $('#divRotina').centralizaRotinaH();
            bloqueiaFundo( $('#divRotina') );
            exibeRotina($('#divRotina'));
          }
      }
  });
  return false;
}


function gravaCustodia() {
	var dataB3 = $("#dataB3","#frmCusApl").val();
  var vlminB3 = $("#vlminB3","#frmCusApl").val();
	var nomarq = $("#nomarq","#frmCusApl").val();
  var qtdarq = $("#qtdarq","#frmCusApl").val();
  var dsmail = $("#dsmail","#frmCusApl").val();
  var hrinicio = $("#hrinicio","#frmCusApl").val();
  var hrfinal = $("#hrfinal","#frmCusApl").val();
  var reghab = $("#reghab","#frmCusApl").val();
  var rgthab = $("#rgthab","#frmCusApl").val();
  var cnchab = $("#cnchab","#frmCusApl").val();
  var perctolval = $("#perctolval", "#frmCusApl").val();

  perctolval = perctolval.replace("," , ".");

  dsmail = myTrim(dsmail);

  if (dataB3 == '') {
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, incluindo configura&ccedil;&otilde;es de Custodia ...");

	// Executa script de consulta atrav�s de ajax
	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/cusapl/grava_custodia.php",
		data: {
			dataB3: dataB3,
            vlminB3: vlminB3,
			nomarq: nomarq,
			qtdarq: qtdarq,
			dsmail: dsmail,
			hrinicio: hrinicio,
			hrfinal: hrfinal,
            reghab: reghab,
            rgthab: rgthab,
            cnchab: cnchab,
            perctolval: perctolval,
			redirect: "script_ajax"
		},
		error: function(objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});
}

function gravaCustodiaAplicacoes() {
	var dataB3 = $("#dataB3","#frmCusApl").val();
  var vlminB3 = $("#vlminB3","#frmCusApl").val();
	var cdregtb3 = $("#cdregtb3","#frmCusApl").val();
  var cdfavrcb3 = $("#cdfavrcb3","#frmCusApl").val();
    var cdcooper = $("#cdcooper", "#frmCab").val();

  if (dataB3 == '') {
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, incluindo configura&ccedil;&otilde;es de Custodia ...");

	// Executa script de consulta atrav�s de ajax
	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/cusapl/grava_custodia_aplicacoes.php",
		data: {
      cdcooper: cdcooper,
			dataB3: dataB3,
      vlminB3: vlminB3,
			cdregtb3: cdregtb3,
			cdfavrcb3: cdfavrcb3,
			redirect: "script_ajax"
		},
		error: function(objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});
}

function estadoInicial() {
    $('#frmPesquisa').css({'display': 'block'});
    $('#divBotao').css('display', 'none');
    $('#divFormulario').html('');
    $('#divLogsDeArquivo').html('');
    $('#divBotoes', '#divTela').html('').css({'display':'block'});

    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();

    $('#btnOK').show();
    $('#cddopcao', '#frmCab').removeAttr("disabled");
    $('#cdcooper', '#frmCab').removeAttr("disabled");
    $("#cddopcao", "#frmCab").val('G').focus();
    $("#btReenvio").hide();

    $('#divcdcooper').css('display', 'none');

    return false;
}

function mostracooperativa(opcao){
    var cddopcao = $("#cddopcao","#frmCab").val();
    if (cddopcao == "C"){
      $('#divcdcooper').css('display', 'block');
    }else{
      $('#divcdcooper').css('display', 'none');
    }
}

function GerenciaPesquisa(opcao) {
  if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
      return false;
  }else{
      if (opcao == 1) {
        // Conta   campoRetorno, formRetorno, divBloqueia, fncFechar,cdCooper
        var cooperativa =parseInt($('.filtrocooperativa').val());
        $( "#frmPesquisaAssociado #cdcooper" ).remove();
        mostraPesquisaAssociado('nrdconta', 'frmPesquisa','',undefined, cooperativa );
      }
  }
  return false;
}

function fechaModal(){
  fechaRotina($('#divRotina'));
}

function limpaRegistrosArquivos(){
  $('#divRegistrosArquivo').html('');
}

function estadoInicialTelaA(){
  $("#btVoltarSegGridTelaA").hide();
	$("#btExportar").hide();
  $("#btVoltar").show();
  $("#Legenda1").show();
  $("#divRegistrosArquivo").html('');

    if($('#divLogsDeArquivo').length > 0) {
        $('#divLogsDeArquivo').html('');
    }
    if($('#divBuscaHistoricoAplicacao').length > 0) {
        $('#divBuscaHistoricoAplicacao').html('');
    }
    
  $('#tableArquivos .selecionada').removeClass( 'selecionada' );
}

function consultaRegistrosArquivos(idArquivo, nriniseq, nrregist) {
	executaConsultaRegistrosArquivos(idArquivo, nriniseq, nrregist, 'TELA');
}

function exportarRegistrosArquivos() {
	executaConsultaRegistrosArquivos(idarquivo, '', '', 'CSV');
}

function executaConsultaRegistrosArquivos(idArquivo, nriniseq, nrregist, inacao) {
  $("#btVoltar").hide();
  $("#btVoltarSegGridTelaA").show();

    var cdcooper = $("#cdcooper", "#frmPesquisa").val();
    var nrdconta = '';
    if ($("#nrdconta", "#frmPesquisa").val() != '') {
        nrdconta = normalizaNumero($("#nrdconta", "#frmPesquisa").val());
    }
    var nraplica = $("#nraplica", "#frmPesquisa").val();
    var flgcritic = 'N';
    if ($('#flgcritic', "#frmPesquisa")[0].checked) {
        flgcritic = 'S';
    }
    var nmarquiv = $("#nmarquiv", "#frmPesquisa").val();
    var dscodib3 = $("#dscodib3", "#frmPesquisa").val();
    var datade = $("#datade", "#frmPesquisa").val();
    var datate = $("#datate", "#frmPesquisa").val();

    if (idArquivo == '') {
        limpaRegistrosArquivos();
        return false;
    }
  // Mostra mensagem de aguardo
  showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

  // Carrega conte�do da op��o atrav�s de ajax
  $.ajax({
      type: "POST",
      url: UrlSite + "telas/cusapl/registros_arquivos.php",
      data: {
			inacao: inacao,
          idarquivo   : idArquivo,		   
            cdcooper: cdcooper,
            nrdconta: nrdconta,
            nraplica: nraplica,
            flgcritic: flgcritic,
            datade: datade,
            datate: datate,
            nmarquiv: nmarquiv,
            dscodib3: dscodib3,
			nriniseq: nriniseq,
			nrregist: nrregist,
          redirect   : "html_ajax" // Tipo de retorno do ajax
      },
      error: function(objAjax, responseError, objExcept) {
          hideMsgAguardo();
          showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
      },
      success: function(response) {
          if (response.substr(0, 14) == 'hideMsgAguardo') {
              eval(response);
          } else {
             $('#divRegistrosArquivo').html(response);
              $("#divDados").html(response);
              hideMsgAguardo();
          }
      }
  });
  return false;
}

function consultaAplicacoes(){

  var nrdconta = normalizaNumero($("#nrdconta", "#frmPesquisa").val());
  var cdcooper = parseInt($('.filtrocooperativa').val());
  // Mostra mensagem de aguardo
  showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

  // Carrega conte�do da op��o atrav�s de ajax
  $.ajax({
      type: "POST",
      url: UrlSite + "telas/cusapl/retorna_aplicacoes.php",
      data: {
          nrdconta   : nrdconta,
          cdcooper   : cdcooper,
          redirect   : "html_ajax" // Tipo de retorno do ajax
      },
      error: function(objAjax, responseError, objExcept) {
          hideMsgAguardo();
          showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
      },
      success: function(response) {
          if (response.substr(0, 14) == 'hideMsgAguardo') {
              eval(response);
          } else {
              $('#nraplica').html(response);
              hideMsgAguardo();
          }
      }
  });
  return false;
}

function atualizaCooperativas(combo){
  $("#cdcooper", "#frmPesquisa")
    .find('option')
    .remove()
    .end()
            .append('<option value="">Selecione</option>' + arrayCoops)
    .val('0');
  return false;
}

function atualizaCooperativas2(combo){
  $("#cdcooper", "#frmCab")
    .find('option')
    .remove()
    .end()
    .append(arrayCoops)
    .val('0');
  return false;
}

function consultaLogsDeArquivos(idArquivo,nomeArquivo,opcao,tipo){
  // Mostra mensagem de aguardo
  showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

  // Carrega conte�do da op��o atrav�s de ajax
  $.ajax({
      type: "POST",
      url: UrlSite + "telas/cusapl/log_arquivos.php",
      data: {
          idarquivo   : idArquivo,
          nomearquivo   : nomeArquivo,
          opcaoarquivo   : opcao,
          tipoarquivo   : tipo,
          redirect   : "html_ajax" // Tipo de retorno do ajax
      },
      error: function(objAjax, responseError, objExcept) {
          hideMsgAguardo();
          showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
      },
      success: function(response) {
          if (response.substr(0, 14) == 'hideMsgAguardo') {
              eval(response);
          } else {
              $("#divDados").html(response);
              $('#divRotina').html(response);
              hideMsgAguardo();
              // centraliza a divRotina
            	$('#divRotina').css({'width':'575px'});
            	$('#divConteudo').css({'width':'550px'});
            	$('#divRotina').centralizaRotinaH();
              bloqueiaFundo( $('#divRotina') );
              exibeRotina($('#divRotina'));
          }
      }
  });
  return false;
}

function consulta(nriniseq, nrregist) {

  var cdcooper = $("#cdcooper", "#frmPesquisa").val();
  var nrdconta='';
  if($("#nrdconta", "#frmPesquisa").val()!=''){
    nrdconta  = normalizaNumero($("#nrdconta", "#frmPesquisa").val());
  }
  var nraplica = $("#nraplica", "#frmPesquisa").val();
  var flgcritic='N';
  if($('#flgcritic', "#frmPesquisa")[0].checked){
    flgcritic = 'S';
  }

    var nmarquiv = $("#nmarquiv", "#frmPesquisa").val();
    var dscodib3 = $("#dscodib3", "#frmPesquisa").val();
    var datade = $("#datade", "#frmPesquisa").val();
    var datate = $("#datate", "#frmPesquisa").val();
/*
  var datade = '';
  var datate = '';
  if( $("#datade", "#frmPesquisa").val()!='' ){
    var datadeRaw = $("#datade", "#frmPesquisa").val().split('-');
    datade = datadeRaw[2] +'/'+ datadeRaw[1] +'/'+ datadeRaw[0];
  }
  if( $("#datate", "#frmPesquisa").val()!='' ){
    var datateRaw = $("#datate", "#frmPesquisa").val().split('-');
    datate = datateRaw[2] +'/'+ datateRaw[1] +'/'+ datateRaw[0];
  }
*/
  // Mostra mensagem de aguardo
  showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

  // Carrega conte�do da op��o atrav�s de ajax
  $.ajax({
      type: "POST",
      url: UrlSite + "telas/cusapl/busca_log_arquivos.php",
      data: {
          cdcooper   : cdcooper,
          nrdconta   : nrdconta,
          nraplica   : nraplica,
          flgcritic  : flgcritic,
          datade     : datade,
          datate     : datate,
          nmarquiv   : nmarquiv,
          dscodib3   : dscodib3,
			nriniseq: nriniseq,
			nrregist: nrregist,
          redirect   : "html_ajax" // Tipo de retorno do ajax
      },
      error: function(objAjax, responseError, objExcept) {
          hideMsgAguardo();
          showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
      },
      success: function(response) {
        if (response.trim().substr(0, 9) == 'showError') {
          hideMsgAguardo();
          showError("error", response.trim().substr(9,response.length) + ".", "Alerta - Ayllos", "");
        } else {
              $('#divLogsDeArquivo').html(response);
              $("#divDados").html(response);
              hideMsgAguardo();
          }
      }
  });
  return false;
}

function consultaCustodiaPendentes(nriniseq, nrregist) {

  var cdcooper = $("#cdcooper", "#frmPesquisa").val();
  var nrdconta  = $("#nrdconta", "#frmPesquisa").val();
  var nraplica = $("#nraplica", "#frmPesquisa").val();
  var flgcritic = $("#flgcritic", "#frmPesquisa").val();
  var datade = '';
  var datate = '';
  var nmarquiv = $("#nmarquiv", "#frmPesquisa").val();
  var dscodib3 = $("#dscodib3", "#frmPesquisa").val();
    var datade = $("#datade", "#frmPesquisa").val();
    var datate = $("#datate", "#frmPesquisa").val();

  // Mostra mensagem de aguardo
  showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

  // Carrega conte�do da op��o atrav�s de ajax
  $.ajax({
      type: "POST",
      url: UrlSite + "telas/cusapl/busca_log_operacoes.php",
      data: {
          cdcooper   : cdcooper,
          nrdconta   : nrdconta,
          nraplica   : nraplica,
          flgcritic  : flgcritic,
          datade     : datade,
          datate     : datate,
          nmarquiv   : nmarquiv,
          dscodib3   : dscodib3,
          redirect   : "html_ajax" // Tipo de retorno do ajax
      },
      error: function(objAjax, responseError, objExcept) {
          hideMsgAguardo();
          showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
      },
      success: function(response) {
          if (response.substr(0, 14) == 'hideMsgAguardo') {
              eval(response);
          } else {
              $('#divLogsDeArquivo').html(response);
              $("#divDados").html(response);
              hideMsgAguardo();
          }
      }
  });
  return false;
}
function selecionaArquivos() {

    if ($('table > tbody > tr', 'div#tableLogsDeArquivo div.divRegistros').hasClass('corSelecao')) {

        $('table > tbody > tr', 'div#tableLogsDeArquivo div.divRegistros').each(function() {
            if ($(this).hasClass('corSelecao')) {

            }
        });
    }

    return false;
}

function formataTabArquivos() {

    var divRegistro = $('div.divRegistros', '#divLogsDeArquivo', '#tableLogsDeArquivo');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({'height': '155px', 'width': '555px'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '28px';
    arrayLargura[1] = '97px';
    arrayLargura[2] = '102px';
    arrayLargura[3] = '102px';
    arrayLargura[4] = '102px';
    arrayLargura[5] = '102px';
    arrayLargura[6] = '102px';
    arrayLargura[7] = '102px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'left';
    arrayAlinha[5] = 'left';
    arrayAlinha[6] = 'left';
    arrayAlinha[7] = 'left';


    var metodoTabela = 'selecionaEmpresa();';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    hideMsgAguardo();

    return false;
}
function sortTable(idTable, n) {
  var table,    rows,    switching,    i,    x,    y,    shouldSwitch,    dir,    switchcount = 0;
    table = document.getElementById(idTable);
    switching = true;
    dir = "asc";

  while (switching) {
        switching = false;
        rows = table.getElementsByTagName("TR");

    for (i = 1; i < (rows.length - 1); i++) {
      shouldSwitch = false;
      x = rows[i].getElementsByTagName("TD")[n];
      y = rows[i + 1].getElementsByTagName("TD")[n];

      if (dir == "asc") {
                if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
                    shouldSwitch = true;
                    break;
                }
            } else if (dir == "desc") {
                if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                    shouldSwitch = true;
                    break;
      }
      }
    }
        if (shouldSwitch) {
            rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
            switching = true;
            switchcount++;
        } else {
            if (switchcount == 0 && dir == "asc") {
                dir = "desc";
                switching = true;
    }
  }
}
}

function buscaConta() {
	if( $('.filtroconta').val()==undefined || $('.filtroconta').val()=='' || $('.filtroconta').val()==null ){
        $('#dtmvtolt').val('');
    return false;
  }

  	showMsgAguardo('Aguarde, buscando dados da Conta...');
	nrdconta = normalizaNumero($('.filtroconta').val());
	cdcooper = $('#cdcooper', '#frmPesquisa').val();

	$.ajax({
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cusapl/busca_conta.php',
		data    :
				{ nrdconta: nrdconta,
				  idseqttl: 1,
                    cdcooper: cdcooper,
				  redirect: 'script_ajax'

				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nrdconta\',\'#frmCabCheque\').focus();');
				},
		success : function(response) {
      if (response.trim().substr(0, 9) == 'showError') {
        hideMsgAguardo();
        showError("error", response.trim().substr(9,response.length) + ".", "Alerta - Ayllos", "");
      } else{
  		    $('#dtmvtolt').val(response);
					hideMsgAguardo();
        }
		}
	});
}


function buscaLogOperacoes(nriniseq, nrregist) {
 
    // Verifica se foi passado argumento pra funçãoo
    if (typeof arguments[0] == 'undefined'){
        nriniseq = 1;  
        nrregist = 15;
    } 
    
  var cdcooper = $("#cdcooper", "#frmPesquisa").val();
  var nrdconta='';
  if($("#nrdconta", "#frmPesquisa").val()!=''){
    nrdconta  = normalizaNumero($("#nrdconta", "#frmPesquisa").val());
  }
    
  var nraplica = $("#nraplica", "#frmPesquisa").val();
  var flgcritic='N';
  if($('#flgcritic', "#frmPesquisa")[0].checked){
    flgcritic = 'S';
  }

  var nmarquiv = $("#nmarquiv", "#frmPesquisa").val();
  var dscodib3 = $("#dscodib3", "#frmPesquisa").val();
    var datade = $("#datade", "#frmPesquisa").val();
    var datate = $("#datate", "#frmPesquisa").val();


  // Mostra mensagem de aguardo
  showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opçõeso através de ajax
  $.ajax({
      type: "POST",
      url: UrlSite + "telas/cusapl/busca_log_operacoes.php",
      data: {
            nriniseq: nriniseq,
            nrregist: nrregist,
          cdcooper   : cdcooper,
          nrdconta   : nrdconta,
          nraplica   : nraplica,
          flgcritic  : flgcritic,
          datade     : datade,
          datate     : datate,
          nmarquiv   : nmarquiv,
          dscodib3   : dscodib3,
          redirect   : "html_ajax" // Tipo de retorno do ajax
      },
      error: function(objAjax, responseError, objExcept) {
          hideMsgAguardo();
          showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
      },
      success: function(response) {
          if (response.substr(0, 14) == 'hideMsgAguardo') {
              eval(response);
          } else {
              $('#divLogsDeArquivo').html(response);
              $("#divDados").html(response);
              $("#btReenvio").show();
              hideMsgAguardo();
          }
      }
  });
  return false;
}

/**
 * Busca os históricos da aplicação selecinada
 * 
 * Autor: David Valente [Envolti]
 * Data: 30/04/2019
 * 
 * @param {integer} idAplicacao 
 */
function buscaHistoricoAplicacao (idaplicacao, nriniseq, nrregist) {
    
        try {
            
            // Mostra mensagem de aguardo
            showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            $('#divBuscaHistoricoAplicacao').html('');

            // Carrega conteúdo da opçõeso através de ajax
            $.ajax({
                type: "POST",
                url: UrlSite + "telas/cusapl/busca_historico_aplicacao.php",
                data: {
                    nriniseq   : nriniseq,
                    nrregist   : nrregist,            
                    idaplicacao: idaplicacao,           
                    redirect: "html_ajax" // Tipo de retorno do ajax
                },
                error: function (objAjax, responseError, objExcept) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
                },
                success: function (response) {
                    if (response.substr(0, 14) == 'hideMsgAguardo') {
                        eval(response);
                    } else {
                        $('#divBuscaHistoricoAplicacao').html(response);
                        hideMsgAguardo();
                    }
                }
            });

            return true;

        } catch (error) {
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error + ".", "Alerta - Ayllos");            
        }
        
    }

function atualizaSelecao(idCkb,idTd){
  if(idCkb=='*'){
    if($('#ckbAll')[0].checked){
      $('.ckbSelecionaLinha').prop('checked', true);
      $('.arqselecionavel').addClass( "arqselecionado" );
        } else {
      $('.ckbSelecionaLinha').prop('checked', false);
      $('.arqselecionavel').removeClass( "arqselecionado" );
    }
    return false;
  }
  if($('#'+idCkb)[0].checked && !$('#'+idTd).hasClass( "arqselecionado" )){
    $('#'+idTd).addClass( "arqselecionado" );
    } else {
    $('#'+idTd).removeClass( "arqselecionado" );
    $('#ckbAll').prop('checked', false);
  }
}

function selecionaLinha(table,idlinha){
  $('#'+table+' .selecionada').removeClass( 'selecionada' );
  $('#'+idlinha).addClass( 'selecionada' );
}

function reenvioItens(){
    //var selecionados = $('.arqselecionado');
    //var selen = selecionados.length;
	var numberOfChecked = $('#tableOperacoes tbody input:checkbox:checked').length;
  var ids='';
    if (numberOfChecked <= 0) {
    showError("error", "Favor selecionar pelo menos 1 registro com Situa&ccedil;&atilde;o = 'Erro'", "Alerta - Ayllos", "");
    return false;
    } else {
		$('#tableOperacoes tbody input:checkbox:checked').each(function() {
			ids = ids + $(this).val() + ';';
		});
  }
/*    for (var i = 0; i < selen; i++) {
    ids= ids+selecionados[i].innerText+';';
    } */

  // Mostra mensagem de aguardo
  showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

  // Carrega conte�do da op��o atrav�s de ajax
  $.ajax({
      type: "POST", url: UrlSite + "telas/cusapl/re_envio_operacoes.php",
      data: {
          listids:ids,
          redirect   : "html_ajax" // Tipo de retorno do ajax
      },
      error: function(objAjax, responseError, objExcept) {
          hideMsgAguardo();
          showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "");
      },
      success: function(response) {

          if (response.trim().substr(0, 9) == 'showError') {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + response.trim().substr(9,response.length) + ".", "Alerta - Ayllos", "");
          } else if(response.trim()!=''){
            $("#divDados").html(response);
            $('#divRotina').html(response);
            hideMsgAguardo();
            // centraliza a divRotina
            $('#divRotina').css({'width':'575px'});
            $('#divConteudo').css({'width':'550px'});
            $('#divRotina').centralizaRotinaH();
            bloqueiaFundo( $('#divRotina') );
            exibeRotina($('#divRotina'));
          }
      }
  });
  return false;
}

function lista_coop() {
  //alert('teste');

	mensagem = 'Aguarde, processando ...';

	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);

	// Carrega dados da conta atrav�s de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/cusapl/busca_cooperativa.php",
		data: {
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
		    hideMsgAguardo();
			try {
				eval(response);
				hideMsgAguardo();
			} catch(error) {
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","");
			}
		}
	});
}

/*
 Ação por validar todos os campos datela que envolvem a operação
 de conciliação de valores devidos com a B3

 Autor: David Valente [Envolti]
 Data: Abril/2019
 */

function validaTelaCustoDevido() {
    // Declaração das variáveis
    var cdcooper = $("#cdcooper", "#frmPesquisa").val();
    var datade = $("#datade", "#frmPesquisa").val();
    var datate = $("#datate", "#frmPesquisa").val();

    // Verifica foi informada uma cooperativa
    if (cdcooper == "") {
        $("#msgErro").show();
        showError('error', 'Informe uma cooperativa', 'Alerta - Aimaro', '');
        return false;
    }
	if (datade == "") {
        $("#msgErro").show();
        showError('error', 'Informe uma data inicial', 'Alerta - Aimaro', '');
		return false;
	}
	if (datate == "") {
        $("#msgErro").show();
        showError('error', 'Informe uma data final', 'Alerta - Aimaro', '');
		return false;
	}

    return true;
}

/* 
 Ação responsável por buscar o calculo devido com a B3
 
 * Traz agrupadondo as contas dos cooperados pela cooperativa ou
 * Traz o valor detalhado por conta do cooperado
 
 Autor: David Valente  [Envolti]
 Data: Abril/2019
 
 */

function listaCustoDevido(tpproces) {
    var cdcooper = $("#cdcooper", "#frmPesquisa").val();
    var nrdconta = '';
    var datade = '';
    var datate = '';

    // Verifica foi informada uma cooperativa
    if (validaTelaCustoDevido()) {

        if ($("#nrdconta", "#frmPesquisa").val() != '') {
            nrdconta = normalizaNumero($("#nrdconta", "#frmPesquisa").val());
        }
        if ($("#datade", "#frmPesquisa").val() != '') {
			datade = $("#datade", "#frmPesquisa").val();
        }
        if ($("#datate", "#frmPesquisa").val() != '') {
			datate = $("#datate", "#frmPesquisa").val();
        }

        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

        // Carrega conteúdo da operaçãoo através de ajax
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/cusapl/lista_custo_devido.php",
            data: {
				tpproces: tpproces,
                cdcooper: cdcooper,
                nrdconta: nrdconta,
                dtde: datade,
                dtate: datate,
                redirect: "html_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            success: function (response) {
                if (response.substr(0, 14) == 'hideMsgAguardo') {
                    eval(response);
                } else {
                    $('#divLogsDeArquivo').html(response);
                    $("#divDados").html(response);
                    $("#btReenvio").show();
                    hideMsgAguardo();
                }
            }
        });
        return false;
    }

} // fim listaCustoDevido

function mostraTabelaInverstidores( nriniseq, nrregist ) {

	showMsgAguardo('Aguarde, buscando tabela...');
	limpaDivGenerica();
	$('#divUsoGenerico').css({ 'width': '90em', 'left': '19em' });
	exibeRotina($('#divUsoGenerico'));

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cusapl/tabela_investidor.php',
		data: {
			//operacao: operacao,
			nriniseq: nriniseq,
			nrregist: nrregist,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
            if (response.trim().substr(0, 9) == 'showError') {
                hideMsgAguardo();
                eval(response);
            } else if (response.trim() != '') {
				$('#divUsoGenerico').html(response);
				controlaLayoutTabelaInvestidores( );
			}
		}
	});
	return false;
}

function controlaLayoutTabelaInvestidores() {	
	$('#divUsoGenerico').css({ 'width': '800px'});
	var divRegistro = $('#divTabelaInvest');
	var tabela      = $('table',divRegistro);
	var linha       = $('table > tbody > tr', divRegistro);
	divRegistro.css({'height':'340px'});
	$('div.divRegistros').css({'height':'320px'});
	$('div.divRegistros table tr td:nth-of-type(8)').css({'text-transform':'uppercase'});
	$('div.divRegistros .dtenvgrv').css({'width':'25px'});
	$('div.divRegistros .dtretgrv').css({'width':'25px'});
	$('div#divBotoes').css({'padding':'10px'});

	var ordemInicial = new Array();
	//ordemInicial = [[0,0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '';  		//De
	arrayLargura[1] = '200px';	//Até
	arrayLargura[2] = '120px';	//Taxa Mensal
	arrayLargura[3] = '120px';  //Adicional
	arrayLargura[4] = '50px';	//Ação

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	for( var i in arrayLargura ) {
		$('td:eq('+i+')', tabela ).css( 'width', arrayLargura[i] );
	}

	$('.btnDelLinha', divRegistro).unbind('click').bind('click', function() {
		var rowCount = $(this).closest('tbody').find('tr').length;
		if (rowCount > 1) {
			$tr = $(this).closest('tr');
			/*
			var texto = "";
			var vlrdeatual = $tr.find('td.vlrde').attr('data-vlr');//.data("vlr");
			var vlrateatual = $tr.find('td.vlrate').attr('data-vlr');//.data("vlr");
			if (parseFloat(vlrateatual) <= 0 ) {
				//var vlrdeprev = $tr.prev('tr').find('td.vlrde span').html();
				var vlrdeprev = $tr.prev('tr').find('td.vlrde').data("vlr");
				texto = "Acima de ";
				$tr.prev('tr').find("td.infos input[name^='vlfaixde']").val(trasnformaNumber(vlrdeprev,'BD-BR'));
				$tr.prev('tr').find("td.infos input[name^='vlfaixate']").val(trasnformaNumber(vlrateatual,'BD-BR'));
				$tr.prev('tr').find('td.vlrde').html('<span>'+trasnformaNumber(vlrdeprev,'-')+'</span>'+texto+trasnformaNumber(vlrdeprev,'pt-BR')).attr("data-vlr", trasnformaNumber(vlrdeprev,'en-EN'));
				$tr.prev('tr').find('td.vlrate').html('<span>'+trasnformaNumber(vlrateatual,'-')+'</span>').attr("data-vlr", trasnformaNumber(vlrateatual,'en-EN'));
			} else {
				//var vlratenext = $tr.next('tr').find('td.vlrate span').html();
				var vlratenext = $tr.next('tr').find('td.vlrate').attr('data-vlr');
				if (parseFloat(vlratenext) <= 0) {
					texto = "Acima de ";
				}
				$tr.next('tr').find("input[name^='vlfaixde']").val(trasnformaNumber(vlrdeatual,'BD-BR'));
				$tr.next('tr').find('td.vlrde').html('<span>'+trasnformaNumber(vlrdeatual,'-')+'</span>'+texto+trasnformaNumber(vlrdeatual,'pt-BR')).attr("data-vlr", trasnformaNumber(vlrdeatual,'en-EN'));
			}
			*/
			$tr.remove();
			tabela.formataTabelaCUSAPL();
		} else {
			showError('error', 'N&atilde;o &eacute; permitido excluir todos os valores da tabela.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
	});

	$('.btnAddLinha', divRegistro).unbind('click').bind('click', function() {
		var vlrate;
		var $tr = $(this).closest('tr');
		var $clone = $tr.clone(true).removeAttr( "id" );
		var rowCount = $(this).closest('.divRegistros table').find('tbody > tr').length;
		$clone.find('input').each( function() {
			var tdcontent = "";
			var input = $(this).val();
			if ( $(this).hasClass('vlradic') || $(this).hasClass('vlrtaxmens') ) {
				var classvlr = $(this).attr('class');
				if ($(this).hasClass('vlrtaxmens')) { var cmpvlr = "pctaxmen"; } else { var cmpvlr = "vladicio"; }
				tdcontent = '<span>'+trasnformaNumber(input,'-')+'</span>'+'<input name="'+cmpvlr+'[]" type="text" value="'+input+'" class="campo '+classvlr+'" maxlength="25" />';
			} else {
				tdcontent = '<span>'+trasnformaNumber(input,'-')+'</span>'+input;
				$clone.find("td.infos").append(('<input name="'+$(this).data("name")+'[]" value="'+trasnformaNumber(trasnformaValor(input),'BD-BR')+'" type="hidden" />'));
			}
			$(this).parent().html(tdcontent).attr("data-vlr", trasnformaValor(input));
			if ($(this).hasClass('vlrate')) {
				vlrate = trasnformaValor(input);
			}
			if ($(this).hasClass('vlrde')) {
				vlrde = trasnformaValor(input);
			}
		});
		if ($clone != "") {
			$clone.find('a.btnAddLinha').remove();
			$clone.find('a.btnDelLinha').show();
			var texto = "";
			var vlrdeant = "";
			var eachCount = 0;

			divRegistro.find('tbody > tr:not(#AddLinha)').each( function () {
				eachCount++;
				var $tratual = $(this);
				var vlrdeatual = $tratual.find('td.vlrde').attr('data-vlr');
				var vlrateatual = $tratual.find('td.vlrate').attr('data-vlr');//.data('vlr');
				if (vlrateatual === null || vlrateatual === undefined || vlrateatual == '') { vlrateatual = '0.00'; }
				if (parseFloat(vlrateatual) > parseFloat(vlrate) || eachCount == rowCount) {
					if (eachCount == rowCount) {
						texto = "Acima de ";
					}
					//vlrate = parseFloat(vlrate)+0.01;
					$clone.find("td.infos").append(('<input name="idfrninv[]" value="0" type="hidden" />'));
					//$clone.find("td.infos").append(('<input name="vlfaixde[]" value="'+trasnformaNumber(vlrdeatual,'BD-BR')+'" type="hidden" />'));
					// - $tratual.find("td.infos input[name^='vlfaixde']").val(trasnformaNumber(vlrate,'BD-BR'));
					// - if (vlrdeatual == vlrate) {
					// - 	vlrdeatual = vlrdeant;
					// - }
					// - $clone.find('td.vlrde').attr("data-vlr", trasnformaNumber(vlrdeatual,'en-EN')).html('<span>'+trasnformaNumber(vlrdeatual,'-')+'</span>'+trasnformaNumber(vlrdeatual,'pt-BR'));
					// - $tratual.find('td.vlrde').attr("data-vlr", trasnformaNumber(vlrate,'en-EN')).html('<span>'+trasnformaNumber(vlrate,'-')+'</span>'+texto+trasnformaNumber(vlrate,'pt-BR'));
					if (eachCount == rowCount) {
						$clone.find('td.vlrde').attr("data-vlr", trasnformaNumber(vlrde,'en-EN')).html('<span>'+trasnformaNumber(vlrde,'-')+'</span>'+texto+trasnformaNumber(vlrde,'pt-BR'));
						$tratual.after($clone);
					} else {
						$tratual.before($clone);
					}
					$tr.find('input').val('');
					return false;
				}
				vlrdeant = vlrdeatual;
			});
			tabela.formataTabelaCUSAPL();
		}
	});

	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo($('#divUsoGenerico'));
	return false;
}

function trasnformaValor(texto) {
	var number = texto.replace(/\./g, '');
	number = number.replace(',', '.');
	return number;
}

function trasnformaNumber(number, format) {
	var group = false;
	if ( format == 'pt-BR' ) {
		group = true;
	}

	if (format == '-' ){
		number = number.toString().replace(',', '');
		number = number.replace('.', '');
	} else if ( format == 'BD-BR' ) {
		number = number.toString().replace('.', ',');
	} else {
		number = new Intl.NumberFormat(format, { style: 'decimal',  minimumFractionDigits:2, useGrouping:group}).format(number);
	}
	
	return number;
}

function btnGravarTabInvest() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, enviando informa&ccedil;&otilde;es ...");

	//var formSerialized = $( "form#formInvest" ).serialize();

    $.ajax({
        type: "POST",
		url: UrlSite + "telas/cusapl/tabela_investidor_rotina.php",
		/* data: {
			//operacao: operacao,
			formSerialized: formSerialized,
			redirect: 'html_ajax'
		}, */
        data: $('form#frmTabInvest').serialize(),
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "");
        },
        success: function (response) {
			hideMsgAguardo();
			eval(response);
        }
    });

    return false;
}

function Gera_Impressao(nmarquivo, callback) {
    hideMsgAguardo();

	dsform = 'frmPesquisa';

    var action = UrlSite + 'telas/cusapl/download_arquivo.php';

    $('#nmarquivo', '#'+dsform).remove();
    $('#sidlogin', '#'+dsform).remove();
    $('#opcao', '#'+dsform).remove();

    $('#'+dsform).append('<input type="hidden" id="nmarquivo" name="nmarquivo" value="' + nmarquivo + '" />');
    $('#'+dsform).append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');
    $('#'+dsform).append('<input type="hidden" id="opcao" name="opcao" value="' + $('#cddopcao', '#frmCabMovrgp').val() + '" />');

    carregaImpressaoAyllos(dsform, action, callback);

    return false;
}

function limpaDivGenerica() {
    return false;
}

$.fn.extend({
	/*!
	 * Formatar a tabela desta tela, sem setar Ordernação
	 */
	formataTabelaCUSAPL: function() {

		var tabela = $(this);
		
		var divRegistro = tabela.parent();

		$('table > tbody > tr', divRegistro).each( function(i) {
			$(this).bind('click', function() {
				$('table', divRegistro).zebraTabela( i );
			});
		});

		// Iniciar com a primeira linha selecionado e retornar o valor da chave deste primerio registro, que se encontra no input do tipo hidden
		tabela.zebraTabela(0);
		return true;
}
});