//*********************************************************************************************//
//*** Fonte: cusapl.js                                                 						          ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: 21/03/2019  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Biblioteca de funções da tela                     						            ***//
//***                                                                  						          ***//
//*** Alterações: 																			                                    ***//
//***						21/03/2019 - Adição de tolerânica para conciliação - projeto 411.3 (Petter Rafael - Envolti)
//*********************************************************************************************//

var Cdsvlrprm24;
var frmCab   		= 'frmCab';
var frmPesquisa   		= 'frmPesquisa';
var cNrdconta;

$(document).ready(function() {
  	atualizaSeletor();
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});

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

function btnconsulta() {//alert('teste');
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
  }
  else{
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

      // Carrega conte�do da op��o atrav�s de ajax
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

  // Carrega conte�do da op��o atrav�s de ajax
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
  var cdcooper = $("#cdcooper", "#frmCab").val()

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
  $("#btVoltar").show();
  $("#Legenda1").show();
  $("#divRegistrosArquivo").html('');
  $('#tableArquivos .selecionada').removeClass( 'selecionada' );
}

function consultaRegistrosArquivos(idArquivo, idLinha,idtable){
  $("#btVoltar").hide();
  $("#btVoltarSegGridTelaA").show();

  selecionaLinha(idtable,idLinha);

  if(idArquivo==''){ limpaRegistrosArquivos(); return false;}
  // Mostra mensagem de aguardo
  showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

  // Carrega conte�do da op��o atrav�s de ajax
  $.ajax({
      type: "POST",
      url: UrlSite + "telas/cusapl/registros_arquivos.php",
      data: {
          idarquivo   : idArquivo,		   
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
    .append('<option value="0"> Todas</option>'+arrayCoops)
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
  var datade = '';
  var datate = '';
  var nmarquiv = $("#nmarquiv", "#frmPesquisa").val();
  var dscodib3 = $("#dscodib3", "#frmPesquisa").val();

  if( $("#datade", "#frmPesquisa").val()!='' ){
    var datadeRaw = $("#datade", "#frmPesquisa").val().split('-');
    datade = datadeRaw[2] +'/'+ datadeRaw[1] +'/'+ datadeRaw[0];
  }
  if( $("#datate", "#frmPesquisa").val()!='' ){
    var datateRaw = $("#datate", "#frmPesquisa").val().split('-');
    datate = datateRaw[2] +'/'+ datateRaw[1] +'/'+ datateRaw[0];
  }

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

  if( $("#datade", "#frmPesquisa").val()!='' ){
    var datadeRaw = $("#datade", "#frmPesquisa").val().split('-');
    datade = datadeRaw[2] +'/'+ datadeRaw[1] +'/'+ datadeRaw[0];
  }
  if( $("#datate", "#frmPesquisa").val()!='' ){
    var datateRaw = $("#datate", "#frmPesquisa").val().split('-');
    datate = datateRaw[2] +'/'+ datateRaw[1] +'/'+ datateRaw[0];
  }

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
    arrayLargura[0] = '55px';
    arrayLargura[1] = '250px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'left';

    var metodoTabela = 'selecionaEmpresa();';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    hideMsgAguardo();

    return false;
}
function sortTable(idTable, n) {
  var table,    rows,    switching,    i,    x,    y,    shouldSwitch,    dir,    switchcount = 0;
  table = document.getElementById(idTable);    switching = true;    dir = "asc";

  while (switching) {
    switching = false;    rows = table.getElementsByTagName("TR");

    for (i = 1; i < (rows.length - 1); i++) {
      shouldSwitch = false;
      x = rows[i].getElementsByTagName("TD")[n];
      y = rows[i + 1].getElementsByTagName("TD")[n];

      if (dir == "asc") {
        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) { shouldSwitch= true;    break; }		  
      }
	  else if (dir == "desc") {
        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) { shouldSwitch= true;    break; }			  
      }
    }
    if (shouldSwitch) { rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);    switching = true;    switchcount ++; }
	else {
      if (switchcount == 0 && dir == "asc") { dir = "desc";     switching = true; }
    }
  }
}
function buscaConta() {
	if( $('.filtroconta').val()==undefined || $('.filtroconta').val()=='' || $('.filtroconta').val()==null ){
    $('#dtmvtolt').val('')
    return false;
  }

  	showMsgAguardo('Aguarde, buscando dados da Conta...');
	nrdconta = normalizaNumero($('.filtroconta').val());

	$.ajax({
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cusapl/busca_conta.php',
		data    :
				{ nrdconta: nrdconta,
				  idseqttl: 1,
          cdcooper: parseInt($('.filtrocooperativa').val()),
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


function buscaLogOperacoes(){
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
  var datade = '';
  var datate = '';
  var nmarquiv = $("#nmarquiv", "#frmPesquisa").val();
  var dscodib3 = $("#dscodib3", "#frmPesquisa").val();

  if( $("#datade", "#frmPesquisa").val()!='' ){
    var datadeRaw = $("#datade", "#frmPesquisa").val().split('-');
    datade = datadeRaw[2] +'/'+ datadeRaw[1] +'/'+ datadeRaw[0];
  }
  if( $("#datate", "#frmPesquisa").val()!='' ){
    var datateRaw = $("#datate", "#frmPesquisa").val().split('-');
    datate = datateRaw[2] +'/'+ datateRaw[1] +'/'+ datateRaw[0];
  }

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
              $("#btReenvio").show();
              hideMsgAguardo();
          }
      }
  });
  return false;
}

function atualizaSelecao(idCkb,idTd){
  if(idCkb=='*'){
    if($('#ckbAll')[0].checked){
      $('.ckbSelecionaLinha').prop('checked', true);
      $('.arqselecionavel').addClass( "arqselecionado" );
    }
    else{
      $('.ckbSelecionaLinha').prop('checked', false);
      $('.arqselecionavel').removeClass( "arqselecionado" );
    }
    return false;
  }
  if($('#'+idCkb)[0].checked && !$('#'+idTd).hasClass( "arqselecionado" )){
    $('#'+idTd).addClass( "arqselecionado" );
  }
  else{
    $('#'+idTd).removeClass( "arqselecionado" );
    $('#ckbAll').prop('checked', false);
  }
}

function selecionaLinha(table,idlinha){
  $('#'+table+' .selecionada').removeClass( 'selecionada' );
  $('#'+idlinha).addClass( 'selecionada' );
}

function reenvioItens(){
  var selecionados = $('.arqselecionado');
  var selen = selecionados.length;
  var ids='';
  if(selen<=0){
    showError("error", "Favor selecionar pelo menos 1 registro com Situa&ccedil;&atilde;o = 'Erro'", "Alerta - Ayllos", "");
    return false;
  }
  for (var i = 0; i < selen; i++) {
    ids= ids+selecionados[i].innerText+';';
  }

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
