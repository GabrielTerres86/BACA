/***********************************************************************
 Fonte: segemp.js                                                  
 Autor: Douglas Pagel (AMcom)
 Data : Fevereiro/2019                Ultima Alteracao: 
                                                                   
 Objetivo  : Cadastro de servicos ofertados na tela LCREDI
                                                                   	 
 Alterações:  

 001: [02/08/2019] Ajuste no limite dos campos tipo numerico para não exceder o tamanho no banco. (P438 Douglas Pagel /AMcom).

************************************************************************/

var RegLinha = new Object();

$(document).ready(function() {	
	
	estadoInicial();
		
});

function estadoInicial() {
    
    //Inicializa o array
    RegLinha = new Object();

    formataCabecalho();

    $('#cddopcao', '#frmCab').habilitaCampo().focus().val('C');
    $('#divBotoes').css({ 'display': 'none' });
    $('#frmFiltro').css('display', 'none');
    $('#divTabela').html('').css('display','none');
       	
}


function formataCabecalho() {

    // rotulo
    $('label[for="cddopcao"]', "#frmCab").addClass("rotulo").css({ "width": "45px" });

    // campo
    $("#cddopcao", "#frmCab").css("width", "530px").habilitaCampo();

    $('#divTela').css({ 'display': 'block' }).fadeTo(0, 0.1);
    removeOpacidade('divTela');
    $('#frmCab').css({ 'display': 'block' });
    highlightObjFocus($('#frmCab'));

    $('input[type="text"],select', '#frmCab').limpaFormulario().removeClass('campoErro');

    //Define aï¿½ï¿½o para ENTER e TAB no campo Opï¿½ï¿½o
    $("#cddopcao", "#frmCab").unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            montaFormFiltro();

            return false;

        }

    });

    //Define aï¿½ï¿½o para CLICK no botï¿½o de OK
    $("#btnOK", "#frmCab").unbind('click').bind('click', function () {

        // Se esta desabilitado o campo 
        if ($("#cddopcao", "#frmCab").prop("disabled") == true) {
            return false;
        }

        montaFormFiltro();

        $(this).unbind('click');

        return false;
        
    });

    layoutPadrao();

    return false;
}

function formataFiltro() {

    // Desabilitar a opï¿½ï¿½o
    $("#cddopcao", "#frmCab").desabilitaCampo();
    
    //rotulo
    $('label[for="idsegmento"]', "#frmFiltro").addClass("rotulo").css({ "width": "100px" });
   
    // campo
    $('#idsegmento', '#frmFiltro').addClass('inteiro').css({ 'width': '80px', 'text-align': 'right' }).attr('maxlength', '5').habilitaCampo();
    
    $('#frmFiltro').css({ 'display': 'block' });
    $('#divBotoes').css({ 'display': 'block' });
    $('#btConcluir', '#divBotoes').css({ 'display': 'none' });
    $('#btProsseguir', '#divBotoes').css({ 'display': 'inline' });
    $('#btVoltar', '#divBotoes').css({ 'display': 'inline' });
    
    highlightObjFocus($('#frmFiltro'));   
    
    // Se pressionar idsegmento
    $('#idsegmento', '#frmFiltro').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se ï¿½ a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $("#btProsseguir", "#divBotoes").click();

            return false;

        }

    });

    //Define aï¿½ï¿½o para CLICK no botï¿½o de Concluir
    $("#btProsseguir", "#divBotoes").unbind('click').bind('click', function () {

        consultaLinhaCredito('1','30');

    });

    //Define aï¿½ï¿½o para CLICK no botï¿½o de Voltar
    $("#btVoltar", "#divBotoes").unbind('click').bind('click', function () {

        controlaVoltar('1');

        return false;

    });

    $("#cdlcremp", "#frmFiltro").focus();

    layoutPadrao();

}

// Formata tabela de Segmentos
function formataTabelaSubsegmento() {
    
	var metodoTabela = '';
	var divRegistro = $('div.divRegistros', '#frmConsulta');
	var tabela = $('#tableSubsegmento', divRegistro);
	var linha = $('#tableSubsegmento table > tbody > tr', divRegistro);

	$('#tableSubsegmento').css({ 'margin-top': '5px' });
	divRegistro.css({ 'height': '100px', 'padding-bottom': '2px' });

	var ordemInicial = new Array();
	ordemInicial = [[0, 0]];
	var arrayLargura = new Array();
	var arrayAlinha = new Array();
	
	arrayLargura[0] = '75px';
	arrayLargura[1] = '286px';
	arrayLargura[2] = '120px';
					
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	
	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	layoutPadrao();

	return false;
}

function formataFormularioConsulta() {

//    highlightObjFocus($('#frmConsulta'));  

    //rotulo
    $('label[for="dssegmento"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="qtsimulacoes_padrao"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="limite_max_proposta"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "250px" });
    $('label[for="variacao_parc"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrintervalo_proposta"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "250px" });
    $('label[for="descricao_segmento"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
	$('label[for="qtdias_validade"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
	
	
	
	$('label[for="tipo_pessoa_1"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
	$('label[for="tipo_pessoa_2"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "102" });
	$('label[for="canal_3"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
	$('label[for="l_canal_3_0"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "100px" });
	$('label[for="l_canal_3_1"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "70px" });
	$('label[for="l_canal_3_2"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "80px" });
	$('label[for="canal_3_vlr"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "80px" });
	
	$('label[for="canal_10"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
	$('label[for="l_canal_10_0"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "100px" });
	$('label[for="l_canal_10_1"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "70px" });
	$('label[for="l_canal_10_2"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "80px" });
	$('label[for="canal_10_vlr"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "80px" });
	
	$('label[for="canal_4"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
	$('label[for="l_canal_4_0"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "100px" });
	$('label[for="l_canal_4_1"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "70px" });
	$('label[for="l_canal_4_2"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "80px" });
	$('label[for="canal_4_vlr"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "80px" });
	
	
    
    // campo
    $("#dssegmento", "#frmConsulta").css({ 'width': '445px', 'text-align': 'left' }).attr('maxlength', '90').desabilitaCampo();
    $('#qtsimulacoes_padrao', '#frmConsulta').css({ 'width': '40px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '2').desabilitaCampo();
    $('#limite_max_proposta', '#frmConsulta').css({ 'width': '40px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '2').desabilitaCampo();
    $('#variacao_parc', '#frmConsulta').css({ 'width': '40px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '2').desabilitaCampo();
    $('#nrintervalo_proposta', '#frmConsulta').css({ 'width': '40px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '2').desabilitaCampo();
    $('#descricao_segmento', '#frmConsulta').css({ 'width': '450px'}).attr('maxlength', '2000').desabilitaCampo();
	$('#tabFinali', '#frmConsulta').css({ 'height': '100px'});
    $('#qtdias_validade', '#frmConsulta').css({ 'width': '40px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '2').desabilitaCampo();
	
	$('#tipo_pessoa_1', '#frmConsulta').css({ 'width': '15px'}).desabilitaCampo();
	$('#tipo_pessoa_2', '#frmConsulta').css({ 'width': '15px'}).desabilitaCampo();
	$('#canal_3_vlr', '#frmConsulta').css({ 'width': '110px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
	$('#canal_10_vlr', '#frmConsulta').css({ 'width': '110px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
	$('#canal_4_vlr', '#frmConsulta').css({ 'width': '110px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
	
    $('#frmConsulta').css({ 'display': 'block' });
    $('#divBotoesConsulta').css('display', 'block');
    $('#btVoltar', '#divBotoesConsulta').css({ 'display': 'inline' });

    //Define ação dos campos
    $("#dssegmento", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    $("#qtsimulacoes_padrao", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    $("#limite_max_proposta", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    $("#variacao_parc", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    $("#nrintervalo_proposta", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    $("#descricao_segmento", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

	if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    $("#qtdias_validade", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    $("#tipo_pessoa_1", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    $("#tipo_pessoa_2", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    $("#canal_3_vlr", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    $("#canal_10_vlr", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para CLICK no botão de Concluir
    $("#btConcluir", "#divBotoesConsulta").unbind('click').bind('click', function () {

        if ($('#cddopcao', '#frmCab').val() == 'A') {

            showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o no segmento?', 'Confirma&ccedil;&atilde;o - Aimaro', 'alterarSegmento();', '$(\'#btVoltar\',\'#divBotoesConsulta\').focus();', 'sim.gif', 'nao.gif');

        } 

    });

    //Define ação para CLICK no botão de Voltar
    $("#btVoltar", "#divBotoesConsulta").unbind('click').bind('click', function () {

        controlaVoltar('2');

        return false;

    });
    
    layoutPadrao();
    
    if ($('#cddopcao', '#frmCab').val() == 'C'){

        $('input,select', '#frmConsulta').desabilitaCampo();

        $('#btConcluir', '#divBotoesConsulta').css({ 'display': 'none' });
		
		$('#btAlterarSubsegmento', '#divBotoesSubsegmentos').css({ 'display': 'none' });
		
    } else if ($('#cddopcao', '#frmCab').val() == 'A'){

        $('input,select,textarea', '#frmConsulta').habilitaCampo();
        $('#dssitlcr', '#frmConsulta').desabilitaCampo();
        $('#dsmodali', '#frmConsulta').desabilitaCampo();
        $('#dssubmod', '#frmConsulta').desabilitaCampo();
        $('#txmensal', '#frmConsulta').desabilitaCampo();
        $('#txdiaria', '#frmConsulta').desabilitaCampo();
        $('#dsfinemp', '#frmConsulta').desabilitaCampo();
		
		$('#btConsultarSubsegmento', '#divBotoesSubsegmentos').css({ 'display': 'none' });

    }
	
	acaoRadio();

    return false;

}


function alterarSegmento() {
   
    var codigo_segmento = $('#codigo_segmento', '#frmConsulta').val();
    var cddopcao = $('#cddopcao', '#frmCab').val();
    var dssegmento = $("#dssegmento", "#frmConsulta").val();
    var qtsimulacoes_padrao = $('#qtsimulacoes_padrao', '#frmConsulta').val();
	var limite_max_proposta = $('#limite_max_proposta', '#frmConsulta').val();
    var variacao_parc = $('#variacao_parc', '#frmConsulta').val();
    var nrintervalo_proposta = $('#nrintervalo_proposta', '#frmConsulta').val();
    var descricao_segmento = $('#descricao_segmento', '#frmConsulta').val();
	var qtdias_validade = $('#qtdias_validade', '#frmConsulta').val();
	var permis_pf = $('#tipo_pessoa_1', '#frmConsulta').prop('checked');
	var permis_pj = $('#tipo_pessoa_2', '#frmConsulta').prop('checked');
	var canal_3_tp = $('input[name=r_canal_3]:checked').val(); 
	var canal_3_vlr = isNaN(parseFloat($('#canal_3_vlr', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#canal_3_vlr', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
	//var canal_4_tp = $('input[name=r_canal_4]:checked').val(); 
	//var canal_4_vlr = isNaN(parseFloat($('#canal_4_vlr', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#canal_4_vlr', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
	var canal_10_tp = $('input[name=r_canal_10]:checked').val(); 
	var canal_10_vlr = isNaN(parseFloat($('#canal_10_vlr', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#canal_10_vlr', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
	
    //Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, alterando segmento ...');

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro');
    // Carrega conteudo da operacao atraves de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/segemp/alterar_segmento.php",
        data: {
			cddopcao :cddopcao,
			cdsegmento :codigo_segmento,
            dssegmento :dssegmento,
            qtsimulacoes_padrao     :qtsimulacoes_padrao,
            limite_max_proposta     :limite_max_proposta,
            variacao_parc           :variacao_parc,
            nrintervalo_proposta    :nrintervalo_proposta,
            descricao_segmento      :descricao_segmento,
			qtdias_validade			:qtdias_validade,
            permis_pf               :permis_pf,
			permis_pj               :permis_pj,
            canal_3_tp              :canal_3_tp,
            canal_3_vlr             :canal_3_vlr,
            //canal_4_tp              :canal_4_tp,
            //canal_4_vlr             :canal_4_vlr,
            canal_10_tp             :canal_10_tp,
            canal_10_vlr            :canal_10_vlr,
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Nao foi possivel concluir a requisicao.. " + error.message + ".", "Alerta - Aimaro", "$('#btVoltar','#divBotoesConsulta').focus();");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'Nao foi possivel concluir a requisicao.', 'Alerta - Aimaro', 'unblockBackground();$("#btVoltar","#divBotoesConsulta").focus();');
            }

        }
    });

    return false;
}

function controlaPesquisa(valor) {

    switch (valor) {

        case '1':
            controlaPesquisaSegmento();
            break;

        case '2':
            controlaPesquisaLinhasEmpr();
            break;

        case '5':
            controlaPesquisaFinalidadeEmpr();
            break;

    }

}

// Consulta Finalidades de emprï¿½stimo
function controlaPesquisaFinalidadeEmpr() {

    // Se esta desabilitado o campo 
    if ($("#cdfinemp", "#divAbaSubsegmento").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro');

    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;
    var varAux = $('#cdlcremp', '#divAbaSubsegmento').val();
    //Definiï¿½ï¿½o dos filtros
    var filtros = 'Finalidade do Empr.;cdfinemp;30px;S;0|Descri&ccedil&atildeo;dsfinemp;200px;S;|;tpfinali;;;1;N|;flgstfin;;;1;N|;cdlcrhab;;;' + varAux + ';N';

    //Campos que serï¿½o exibidos na tela
    var colunas = 'C&oacutedigo;cdfinemp;20%;right|Finalidade;dsfinemp;80%;left|Tipo;tpfinali;0%;left;;N|Flag;flgstfin;0%;left;;N';
                    
    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "BUSCAFINEMPR", "Finalidade do Empr&eacutestimo", "30", filtros, colunas, '', '$(\'#cdfinemp\',\'#divAbaSubsegmento\').focus();', 'divAbaSubsegmento');

    $("#divCabecalhoPesquisa > table").css("width", "500px");
    $("#divResultadoPesquisa > table").css("width", "500px");
    $("#divCabecalhoPesquisa").css("width", "500px");
    $("#divResultadoPesquisa").css("width", "500px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}

function controlaPesquisaLinhasEmpr() {

    // Se esta desabilitado o campo 
    if ($("#cdlcremp", "#divAbaSubsegmento").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro');

    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;
    var varAux = $('#cdfinemp', '#divAbaSubsegmento').val();
    //Definiï¿½ï¿½o dos filtros
    var filtros = 'Código;cdlcremp;30px;S;0|Descrição;dslcremp;200px;S;|;cdfinemp;;;' + varAux + ';N|;flgstlcr;;;1;N';//|;cdmodali;;;1;N';
	
    //Campos que serï¿½o exibidos na tela
    var colunas = 'C&oacutedigo;cdlcremp;20%;right|Linha;dslcremp;80%;left';
                    
    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "BUSCALINHASCREDITO", "Linhas de Crédito", "30", filtros, colunas, '', '$(\'#cdlcremp\',\'#divAbaSubsegmento\').focus();', 'divAbaSubsegmento');

    $("#divCabecalhoPesquisa > table").css("width", "500px");
    $("#divResultadoPesquisa > table").css("width", "500px");
    $("#divCabecalhoPesquisa").css("width", "500px");
    $("#divResultadoPesquisa").css("width", "500px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}

function controlaPesquisaSegmento() {

    // Se esta desabilitado o campo 
    if ($("#idsegmento", "#frmFiltro").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input', '#frmFiltro').removeClass('campoErro');

    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    var nrconven = normalizaNumero($('#idsegmento', '#frmFiltro').val());

    //Definiï¿½ï¿½o dos filtros
    var filtros = "Segmento;idsegmento;120px;S;;;|Descrição;dssegmento;120px;S;;descricao";
	

    //Campos que serï¿½o exibidos na tela
    var colunas = 'Código;idsegmento;10%;right|Descrição;dssegmento;50%;left';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "BUSCA_SEGMENTOS", "Segmentos", "30", filtros, colunas, '', '$(\'#idsegmento\',\'#frmFiltro\').focus();', 'frmFiltro');

    $("#divCabecalhoPesquisa > table").css("width", "600px");
    $("#divResultadoPesquisa > table").css("width", "600px");
    $("#divCabecalhoPesquisa").css("width", "600px");
    $("#divResultadoPesquisa").css("width", "600px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}


function controlaVoltar(ope,tpconsul) {
    
    switch (ope) {

        case '1':
            
            estadoInicial();

        break;

        case '2':

            //Limpa formulario
            $('input[type="text"]', '#frmFiltro').limpaFormulario();
            $('#divTabela').html('').css('display', 'none');
            formataFiltro();

        break;

        case '3':

            formataFiltro();

        break;

        case '4':

            if (tpconsul == 'C') {

                $('#nrctrpro', '#frmFiltro').focus();

            } else {
                $('#nrgravam', '#frmFiltro').focus();
            }

            fechaRotina($('#divRotina'));
            $('#divRotina').html(''); 

        break;

    }

    return false;

}


function montaFormFiltro() {

    var cddopcao = $("#cddopcao", "#frmCab").val();

    showMsgAguardo("Aguarde ...");

    //Requisiï¿½ï¿½o para montar o form correspondente a opï¿½ï¿½o escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/segemp/monta_form_filtro.php",
        data: {
            cddopcao: cddopcao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divFiltro').html(response);
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "estadoInicial();");
                }
            }
        }

    });

    return false;

}

function consultaLinhaCredito(nriniseq, nrregist) {

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var idsegmento = $("#idsegmento", "#frmFiltro").val();

    //Inicializa array
    RegLinha = new Object();

    showMsgAguardo("Aguarde, consultando segmento ...");

    $('input,select','#frmFiltro').desabilitaCampo();

    /* Remove foco de erro */
    $('input,select', '#frmFiltro').removeClass('campoErro');

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro').limpaFormulario();

    //Requisiï¿½ï¿½o para montar o form correspondente a opï¿½ï¿½o escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/segemp/consulta_segmento.php",
        data: {
            cddopcao: cddopcao,
            idsegmento: idsegmento,
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "estadoInicial();");
        },
        success: function (response) {    
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divTabela').html(response);
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "estadoInicial();");
                }
            }
        }

    });
    
    return false;

}

function rotinaSubsegmento(cddopcao){

	$('table.tituloRegistros > tbody > tr', '#divSubsegmentos').each(function() {
		if ($(this).hasClass('corSelecao')) {
			if($('#cdsubsegmento',$(this)).val() == "" || $('#cdsubsegmento',$(this)).val() == undefined || $('#cdsubsegmento',$(this)).val() == null){
				showError('error', 'Selecione um subsegmento!', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina);');
				return false;
			}else{						
				if(cddopcao == "A" || cddopcao == "C"){
					manterRotinaSubsegmento(cddopcao, $('#cdsegmento',$(this)).val(), $('#cdsubsegmento',$(this)).val());
				}
			}
		}
	});
	
}

function manterRotinaSubsegmento(cddopcao, cdsegmento, cdsubsegmento) {
	
	showMsgAguardo("Aguarde, consultando subsegmento ...");

	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		dataType: 'html',
		url: "form_cadastro.php", 
		data: {		
			cdsegmento: cdsegmento,
			cdsubsegmento: cdsubsegmento,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divTela').css('z-index')))");
			$('#cdcooper','#frmCab').habilitaCampo();
			$('#btnOK','#frmCab').habilitaCampo();			
		},
		success : function(response) {
			exibeRotina($('#divRotina'));
			$('#divRotina').html(response);
			hideMsgAguardo();
			bloqueiaFundo($('#divRotina'));
            
            if (cddopcao == 'A') {
                $('#cdsubsegmento','#frmCadastro').desabilitaCampo();
            }
            
		}		
	});
    return false;
}

function acaoRadio(){
	if ($('#cddopcao', '#frmCab').val() == 'A') {	
		var valor3 = $('input[name=r_canal_3]:checked').val(); 
		
		if (valor3 == 0) {
			$("#canal_3_vlr", "#frmConsulta").val('0,00').desabilitaCampo();
		}else {
			$("#canal_3_vlr", "#frmConsulta").habilitaCampo();
		}

		var valor10 = $('input[name=r_canal_10]:checked').val();
		
		if (valor10 == 0) {
			$("#canal_10_vlr", "#frmConsulta").val('0,00').desabilitaCampo();
		}else {
			$("#canal_10_vlr", "#frmConsulta").habilitaCampo();
		}
	}
}

function altGarantia() {

	if ($('#cddopcao', '#frmCab').val() == 'A') {	
		if ($('#garantia', '#divAbaSubsegmento').val() == 1) {
			$("#tpGarantia", "#divAbaSubsegmento").habilitaCampo();
			$("#percentual_maximo_autorizado", "#divAbaSubsegmento").habilitaCampo();
			$("#percentual_excedente", "#divAbaSubsegmento").habilitaCampo();
		}else {
			$("#tpGarantia", "#divAbaSubsegmento").desabilitaCampo();
			$("#percentual_maximo_autorizado", "#divAbaSubsegmento").val('0,00').desabilitaCampo();
			$("#percentual_excedente", "#divAbaSubsegmento").val('0,00').desabilitaCampo();
			
		}
	}
}

function formataFormularioSubsegmento() {
	
	//rotulo
	$('label[for="cdsubsegmento"]', "#divAbaSubsegmento").addClass("rotulo").css({ "width": "130px" });
    $('label[for="dssubsegmento"]', "#divAbaSubsegmento").addClass("rotulo").css({ "width": "130px" });
	$('label[for="cdfinemp"]', "#divAbaSubsegmento").addClass("rotulo").css({ "width": "130px" });
	$('label[for="cdlcremp"]', "#divAbaSubsegmento").addClass("rotulo").css({ "width": "130px" });
	$('label[for="garantia"]', "#divAbaSubsegmento").addClass("rotulo").css({ "width": "130px" });
	$('label[for="tpgarantia"]', "#divAbaSubsegmento").addClass("rotulo").css({ "width": "130px" });
	$('label[for="qtmaxparc"]', "#divAbaSubsegmento").addClass("rotulo").css({ "width": "130px" });
	$('label[for="percentual_maximo_autorizado"]', "#divAbaSubsegmento").addClass("rotulo").css({ "width": "130px" });
	$('label[for="valor_maximo_proposta"]', "#divAbaSubsegmento").addClass("rotulo-linha").css({ "width": "130px" });
	$('label[for="percentual_excedente"]', "#divAbaSubsegmento").addClass("rotulo").css({ "width": "130px" });
	
	//
	// campo
    $("#cdsubsegmento", "#divAbaSubsegmento").css({ 'width': '80px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '90').desabilitaCampo();
	$("#dssubsegmento", "#divAbaSubsegmento").css({ 'width': '330px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '90').desabilitaCampo();
	$("#cdfinemp", "#divAbaSubsegmento").css({ 'width': '40px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '90').desabilitaCampo();
	$("#dsfinemp", "#divAbaSubsegmento").css({ 'width': '267px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '90').desabilitaCampo();
    $("#cdlcremp", "#divAbaSubsegmento").css({ 'width': '40px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '90').desabilitaCampo();
	$("#dslcremp", "#divAbaSubsegmento").css({ 'width': '267px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '90').desabilitaCampo();
	$("#garantia", "#divAbaSubsegmento").css({ 'width': '80px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '90').desabilitaCampo();
	$("#tpgarantia", "#divAbaSubsegmento").css({ 'width': '80px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '90').desabilitaCampo();
	$("#qtmaxparc", "#divAbaSubsegmento").css({ 'width': '80px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '90').desabilitaCampo();
    $('#percentual_maximo_autorizado', '#divAbaSubsegmento').css({ 'width': '80px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '6').desabilitaCampo();
	$('#valor_maximo_proposta', '#divAbaSubsegmento').css({ 'width': '114px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
	$('#percentual_excedente', '#divAbaSubsegmento').css({ 'width': '80px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '6').desabilitaCampo();
	
	
    //Define ação dos campos
    $("#dssubsegmento", "#divAbaSubsegmento").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
	
    $("#cdfinemp", "#divAbaSubsegmento").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
	
	$("#cdlcremp", "#divAbaSubsegmento").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
	
	$("#garantia", "#divAbaSubsegmento").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
	
	$("#tpgarantia", "#divAbaSubsegmento").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
	
	$("#qtmaxparc", "#divAbaSubsegmento").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
	
	$("#percentual_maximo_autorizado", "#divAbaSubsegmento").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
	
	$("#valor_maximo_proposta", "#divAbaSubsegmento").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
	
	$("#percentual_excedente", "#divAbaSubsegmento").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se ï¿½ a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
	
	layoutPadrao();
		
		
	if ($('#cddopcao', '#frmCab').val() == 'C'){

        $('input,select', '#divAbaSubsegmento').desabilitaCampo();

        $('#btConcluirSub', '#divRotina').css({ 'display': 'none' });
		
		
    } else if ($('#cddopcao', '#frmCab').val() == 'A'){

        $('input,select,textarea', '#divAbaSubsegmento').habilitaCampo();
        $('#cdsubsegmento', '#divAbaSubsegmento').desabilitaCampo();
        $('#dsfinemp', '#divAbaSubsegmento').desabilitaCampo();
        $('#dslcremp', '#divAbaSubsegmento').desabilitaCampo();
    }
		
	
	// Finalidade de emprestimo
    $('#cdfinemp', '#divAbaSubsegmento').unbind('change').bind('change', function() {
        bo = 'zoom0001';
        procedure = 'BUSCAFINEMPR';
        titulo = 'Finalidade do Empr&eacute;stimo';
        filtrosDesc = 'flgstfin|1;nriniseq|1;nrregist|30';
        buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsfinemp', $(this).val(), 'dsfinemp', filtrosDesc, 'divAbaSubsegmento');

    });
	
	// Linha de Credito
    $('#cdlcremp', '#divAbaSubsegmento').unbind('change').bind('change', function() {
        bo = 'b1wgen0059.p';
        procedure = 'busca_linhas_credito';
        titulo = 'Linhas de Cr&eacute;dito';
        varAux = $('#cdfinemp', '#divAbaSubsegmento').val();
   
        varMod = 0;        
        varTip = 1
        filtrosDesc = 'flgstlcr|yes;cdfinemp|' + varAux + ';cdmodali|' + varMod + ';tpprodut|' + varTip;
        buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dslcremp', $(this).val(), 'dslcremp', filtrosDesc, 'divAbaSubsegmento');

    });
	
	$("#btConcluirSub", "#divRotina").unbind('click').bind('click', function () {

        if ($('#cddopcao', '#frmCab').val() == 'A') {

            showConfirmacao('Deseja alterar o subsegmento?', 'Confirmação - Aimaro', 'alterarSubSegmento();', '$(\'#btVoltarSub\',\'#divRotina\').focus();', 'sim.gif', 'nao.gif');

        } 

    });
	


}

function alterarSubSegmento() {
	var codigo_segmento = $('#codigo_segmento', '#frmConsulta').val();
	var cdsubsegmento = $('#cdsubsegmento', '#divAbaSubsegmento').val();
    var cddopcao = $('#cddopcao', '#frmCab').val();
    var dssubsegmento = removeCaracteresInvalidos($("#dssubsegmento", "#divAbaSubsegmento").val(), true);
    var cdlinha_credito = $('#cdlcremp', '#divAbaSubsegmento').val();
	var cdfinalidade = $('#cdfinemp', '#divAbaSubsegmento').val();
    var flggarantia = $('#garantia', '#divAbaSubsegmento').val();
    var tpgarantia = $('#tpGarantia', '#divAbaSubsegmento').val();
    var pemax_autorizad = isNaN(parseFloat($('#percentual_maximo_autorizado', '#divAbaSubsegmento').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#percentual_maximo_autorizado', '#divAbaSubsegmento').val().replace(/\./g, "").replace(/\,/g, "."));
	var peexcedente = isNaN(parseFloat($('#percentual_excedente', '#divAbaSubsegmento').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#percentual_excedente', '#divAbaSubsegmento').val().replace(/\./g, "").replace(/\,/g, "."));
	var vlmax_proposta = isNaN(parseFloat($('#valor_maximo_proposta', '#divAbaSubsegmento').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#valor_maximo_proposta', '#divAbaSubsegmento').val().replace(/\./g, "").replace(/\,/g, "."));
	
    //Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, alterando subsegmento ...');

    /* Remove foco de erro */
    $('input,select', '#divAbaSubsegmento').removeClass('campoErro');
	
    // Carrega conteudo da operacao atraves de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/segemp/alterar_subsegmento.php",
        data: {
			cddopcao :cddopcao,
			cdsubsegmento: cdsubsegmento,
			codigo_segmento :codigo_segmento,
			dssubsegmento :dssubsegmento,
			cdlinha_credito :cdlinha_credito,
			cdfinalidade :cdfinalidade,
			flggarantia :flggarantia,
			tpgarantia :tpgarantia,
			pemax_autorizad :pemax_autorizad,
			peexcedente :peexcedente,
			vlmax_proposta :vlmax_proposta,
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Nao foi possivel concluir a requisicao.. " + error.message + ".", "Alerta - Aimaro", "$('#btVoltarSub','#divRotina').focus();");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'Nao foi possivel concluir a requisicao.', 'Alerta - Aimaro', 'unblockBackground();$("#btVoltarSub","#divRotina").focus();');
            }

        }
    });

    return false;
}