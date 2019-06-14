/*!
 * FONTE        : penseg.js
 * CRIAÇÃO      : Guilherme/SUPERO
 * DATA CRIAÇÃO : Junho/2016
 * OBJETIVO     : Biblioteca de funções da tela PENSEG
 * --------------
 * ALTERAÇÕES   :
 * -----------------------------------------------------------------------
 * 000: [07/11/2018] Adicionado campos no formulário para selecionar os itens da lsita para "deleta-los". ( Christian Grauppe/ENVOLTI )
 * 001: [09/11/2018] Adicionado campos para busca e filtro da lista por CPF/CNPJ e Nr. de Apólice. ( Christian Grauppe/ENVOLTI )
 */

// Variaveis
var cregNrproposta,cregNrapolice,cregNrendosso,cregDtinivig,cregDtfimvig,cregNmsegura,cregNmmarca,cregDsmodelo,cregDschassi,cregNmsegur,cregNrdocpf
   ,cregDsplaca,cregNranofab,cregNranomod,cregCdcooper,cregNrdconta,cnewCdcooper,cnewNrdconta,cnewNmrescop,cnewNmprimtl
    ;

var rregNrproposta,rregNrapolice,rregNrendosso,rregDtinivig,rregDtfimvig,rregNmsegura,rregNmmarca,rregDsmodelo,rregDschassi,rregNmsegur,rregNrdocpf
   ,rregDsplaca,rregNranofab,rregNranomod,rregCdcooper,rregNrdconta,rnewCdcooper,rnewNrdconta,rnewNmrescop,rnewNmprimtl
   ,rregimgSitCoop;

var cCddopcao, cImgSitCoop,
    rCddopcao;

var cTodosCabecalho;

var indrowid    = "";
var idcontrato = "";
var qtdRegis = 20;

// Tela
$(document).ready(function() {
    estadoInicial();
});

function estadoInicial() {

    // Efeito de inicializacao
    $('#divTela').fadeTo(0,0.1);


    // Remove Opacidade da Tela
    removeOpacidade('divTela');

    buscaSegurosPendentes(1, qtdRegis);
    controlaLayout();
    return false;
}

// Monta a tela Principal
function controlaLayout() {
    // Habilta
    $('#frmCab').css({'display':'block'});
    rCddopcao       = $('label[for="cddopcao"]','#frmCab');
    cCddopcao       = $('#cddopcao','#frmCab');

    rCddopcao.css({'width':'121px'});
    cCddopcao.addClass('campo').css({'width':'750px'}).desabilitaCampo();

    indrowid   = "";
    idcontrato = "";

    layoutPadrao();
    return false;
}

/* Acessar tela principal da rotina */
function carregaDetalhes() {

    /* Monta o conteudo do Seguro selecionado*/

    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/penseg/form_dados.php",
        data: {
            idcontrato    : idcontrato,
            regNrproposta : regNrproposta,
            regNrapolice  : regNrapolice ,
            regNrendosso  : regNrendosso ,
            regDtinivig   : regDtinivig  ,
            regDtfimvig   : regDtfimvig  ,
            regNmsegura   : regNmsegura  ,
            regNmmarca    : regNmmarca   ,
            regDsmodelo   : regDsmodelo  ,
            regDschassi   : regDschassi  ,
            regDsplaca    : regDsplaca   ,
            regNranofab   : regNranofab  ,
            regNranomod   : regNranomod  ,
            regCdcooper   : regCdcooper  ,
            regNrdconta   : regNrdconta  ,
            regimgSitCoop : regimgSitCoop,
            regNrcpjcnpj  : regNrcpjcnpj,
            regNmdosegur  : regNmdosegur,
            redirect: "html_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
            $("#divConteudoOpcao").html(response);
            formataDivConteudo();
        }
    });
    return false;
}

// Cabecalho Principal
function formataDivConteudo() {

    /** Formulario Dados **/
    $("#divConteudoOpcao").css({'width':'640px'}).setCenterPosition();
    
    rregNrproposta      = $('label[for="regNrproposta"]','#frmDados');
    rregNrapolice       = $('label[for="regNrapolice"]','#frmDados');
    rregNrendosso       = $('label[for="regNrendosso"]','#frmDados');
    rregDtinivig        = $('label[for="regDtinivig"]','#frmDados');
    rregDtfimvig        = $('label[for="regDtfimvig"]','#frmDados');
    rregNmsegura        = $('label[for="regNmsegura"]','#frmDados');
    rregNmmarca         = $('label[for="regNmmarca"]','#frmDados');
    rregDsmodelo        = $('label[for="regDsmodelo"]','#frmDados');
    rregDschassi        = $('label[for="regDschassi"]','#frmDados');
    rregDsplaca         = $('label[for="regDsplaca"]','#frmDados');
    rregNranofab        = $('label[for="regNranofab"]','#frmDados');
    rregNranomod        = $('label[for="regNranomod"]','#frmDados');
    rregCdcooper        = $('label[for="regCdcooper"]','#frmDados');
    rregNrdconta        = $('label[for="regNrdconta"]','#frmDados');
    rnewCdcooper        = $('label[for="newCdcooper"]','#frmDados');
    rnewNrdconta        = $('label[for="newNrdconta"]','#frmDados');
    rnewNmrescop        = $('label[for="newNmrescop"]','#frmDados');
    rnewNmprimtl        = $('label[for="newNmprimtl"]','#frmDados');
    rregNmsegur         = $('label[for="regNmsegur"]','#frmDados');
    rregNrdocpf         = $('label[for="regNrdocpf"]','#frmDados');

    rregimgSitCoop      = $('#imgSituac','#frmDados');
    cregNrproposta      = $('#regNrproposta','#frmDados');
    cregNrapolice       = $('#regNrapolice','#frmDados');
    cregNrendosso       = $('#regNrendosso','#frmDados');
    cregDtinivig        = $('#regDtinivig','#frmDados');
    cregDtfimvig        = $('#regDtfimvig','#frmDados');
    cregNmsegura        = $('#regNmsegura','#frmDados');
    cregNmmarca         = $('#regNmmarca','#frmDados');
    cregDsmodelo        = $('#regDsmodelo','#frmDados');
    cregDschassi        = $('#regDschassi','#frmDados');
    cregDsplaca         = $('#regDsplaca','#frmDados');
    cregNranofab        = $('#regNranofab','#frmDados');
    cregNranomod        = $('#regNranomod','#frmDados');
    cregCdcooper        = $('#regCdcooper','#frmDados');
    cImgSitCoop         = $('#imgSitCoop','#frmDados');
    cregNrdconta        = $('#regNrdconta','#frmDados');
    cnewCdcooper        = $('#newCdcooper','#frmDados');
    cnewNrdconta        = $('#newNrdconta','#frmDados');
    cnewNmrescop        = $('#newNmrescop','#frmDados');
    cnewNmprimtl        = $('#newNmprimtl','#frmDados');
    cregNmsegur         = $('#regNmsegur','#frmDados');
    cregNrdocpf         = $('#regNrdocpf','#frmDados');
    
    cTodosCabDados      = $('input[type="text"],select,textArea','#frmDados');

    formataCabecalho();
    navegaCampos();
    return false;
}

// Formatacao da Tela
function formataCabecalho() {

    /** Formulario Dados **/
    // ROTULOS
    rregNrproposta.css({'width':'110px'});
    rregDtinivig.css({'width':'110px'});
    rregNmsegura.css({'width':'110px'});

    rregNrapolice.css({'width':'120px'});
    rregDtfimvig.css({'width':'120px'});

    rregNrendosso.css({'width':'90px'});

    rregNmmarca.css({'width':'110px'});
    rregDschassi.css({'width':'110px'});
    rregNranofab.css({'width':'110px'});

    rregNmsegur.css({ 'width': '110px' });
    rregNrdocpf.css({ 'width': '73px' });

    rregDsmodelo.css({'width':'120px'});
    rregDsplaca.css({'width':'70px'});
    rregNranomod.css({'width':'170px'});

    rregCdcooper.css({'width':'115px'});
    rregimgSitCoop.css({'margin-top':'5px','margin-left':'5px'});
    rnewCdcooper.css({'width':'115px'});
    rnewNmrescop.css({'width':'115px'});

    rregNrdconta.css({'width':'171px'});
    rnewNrdconta.css({'width':'129px'});
    rnewNmprimtl.css({'width':'368px'});

    // CAMPOS
    cregNrproposta.css({'width':'75px'});
    cregDtinivig.css({'width':'75px'});
    cregNmsegura.css({'width':'300px'});

    cregNrapolice.css({'width':'75px'});
    cregDtfimvig.css({'width':'75px'});

    cregNrendosso.css({'width':'75px'});

    cregNmmarca.css({'width':'110px'});
    cregDschassi.css({'width':'160px'});
    cregNranofab.css({'width':'60px'});

    cregNmsegur.css({ 'width': '290px' });
    cregNrdocpf.css({ 'width': '117px' });

    cregDsmodelo.css({'width':'250px'});
    cregDsplaca.css({'width':'80px'});
    cregNranomod.css({'width':'60px'});

    //cImgSitCoop.css({'width':'60px'});
    cregCdcooper.css({'width':'60px'});
    cnewCdcooper.css({'width':'120px'}).setMask('INTEGER','zzz','','');;
    cnewNmrescop.css({'width':'190px'});

    cregNrdconta.css({'width':'60px'});
    cnewNrdconta.css({'width':'90px'}).addClass('conta pesquisa').attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');

    cnewNmprimtl.css({'width':'220px'});

    cTodosCabDados.addClass('campo').desabilitaCampo();

    cnewCdcooper.habilitaCampo();

    highlightObjFocus( $('#frmDados') );
    return false;
}

function navegaCampos() {

    if (regimgSitCoop == 'sit_ok.png') {
        cnewNrdconta.habilitaCampo();
        cnewNrdconta.focus();
    }else{
        cnewCdcooper.focus();
    }

    cnewCdcooper.change(function() {
        if (cnewCdcooper.val() == 0) {
            showError("error","Por favor, selecione uma cooperativa!","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));cnewCdcooper.focus();");
            cnewNrdconta.desabilitaCampo();
            return false;
        }
        cnewNrdconta.habilitaCampo();
        cnewNrdconta.focus();
        return false;
    });
    cnewCdcooper.unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            if (cnewCdcooper.val() == 0) {
                showError("error","Por favor, selecione uma cooperativa!","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));cnewCdcooper.focus();");
                return false;
            }
            cnewNrdconta.habilitaCampo();
            cnewNrdconta.focus();
            return false;
        }
    });
    cnewNrdconta.unbind('keydown').bind('keydown', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            if ((cnewNrdconta.val() == '') ||
                (cnewNrdconta.val() == 0) ) {
                showError("error","Por favor, informe corretamente a Conta/DV!","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));cnewNrdconta.focus();");

                return false;
            }
            else {
                valida_conta_nova();
            }
            return false;
        }
    });

    $('#btnOK').unbind('click').bind('click', function() {
        if ( isHabilitado(cnewNrdconta) )  {
            valida_conta_nova();
            return false;
        }
    });
    return false;
}

// Valida Cooperado
function valida_conta_nova() {

    var newCdcooper = normalizaNumero(cnewCdcooper.val());
    var newNrdconta = normalizaNumero(cnewNrdconta.val());

    $.ajax({
        type        : "POST",
        dataType    : "html",
        url         : UrlSite + "telas/penseg/valida_conta_nova.php",
        data: {
            cdcooper : newCdcooper,
            nrdconta : newNrdconta,
            redirect: "html_ajax"
        },
        error   : function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#newNrdconta\',\'#frmDados\').focus();');
        },
        success : function(response) {
            hideMsgAguardo();
            eval(response);
        }
    });
    return false;
}


// Monta Grid Inicial
function buscaSegurosPendentes(nriniseq, nrregist, nrapolice, nrcpfcnj) {
    
    indrowid   = "";
    idcontrato = "";

    showMsgAguardo("Aguarde, consultando pend&ecirc;ncias...");
    
    $.ajax({
        type    : "POST",
        dataType: "html",
        url     : UrlSite + "telas/penseg/busca_seg_pendente.php",
        data: {
            nriniseq: nriniseq,
            nrregist: nrregist,
            nrapolice: nrapolice,
            nrcpfcnj: nrcpfcnj,
            redirect: "html_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
        },
        success: function(response) {
            $("#divCab").html(response);
            formataTabela();
            $('#divBotoes').css({'display':'block'});
            hideMsgAguardo();
        }
    });
    return false;
}

// Formata tabela de dados da remessa
function formataTabela() {

    // Habilita a conteudo da tabela
    $('#divCab').css({'display':'block'});
    $('#divCab').css({'width':'750px'});
    $('#divCab').css({'margin-left':'auto'});
    $('#divCab').css({'margin-right':'auto'});

    var divRegistro = $('div.divRegistros', '#tabPendencias');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );
    var conteudo    = $('#conteudo', linha).val();


    $('#tabPendencias').css({'margin-top':'1px'});
    divRegistro.css({'height':'320px','padding-bottom':'1px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0]  = '10px';
    arrayLargura[1]  = '120px';
    arrayLargura[2]  = '117px';
    arrayLargura[3]  = '117px';
    arrayLargura[4]  = '90px';
    arrayLargura[5]  = '105px';
    //arrayLargura[5]  = '60px';
   // arrayLargura[6]  = '10px';

    var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'right';
        arrayAlinha[3] = 'right';
        arrayAlinha[4] = 'right';
        arrayAlinha[5] = 'right';
        arrayAlinha[6] = 'center';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
    hideMsgAguardo();

	$("#iptdeltodos").unbind('click').bind('click', function() {
        if (this.checked) {
            $(".iptdel").each(function() {
                this.checked = true;
            });
        } else {
            $(".iptdel").each(function() {
                this.checked = false;
            });
        }
    });

    /* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
    para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
    excluir o registro selecionado */

    $('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
        $('table > tbody > tr > td', divRegistro).focus();
    });

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click( function() {
        selecionaTabela($(this));
    });

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).dblclick( function() {
        selecionaTabela($(this));
        btnAlterar();
    });

    // seleciona o registro que é focado
    $('table > tbody > tr', divRegistro).focus( function() {
        selecionaTabela($(this));
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();
    return false;
}

function selecionaTabela(tr) {
    //indrowid      = $('#indrowid', tr).val();
    idcontrato    = $('#idcontrato', tr).val();
    regNrproposta = $('#nrproposta', tr).val();
    regNrapolice  = $('#nrapolice', tr).val();
    regNrendosso  = $('#nrendosso', tr).val();
    regDtinivig   = $('#dtinicio_vigencia', tr).val();
    regDtfimvig   = $('#dttermino_vigencia', tr).val();
    regNmsegura   = $('#nmsegura', tr).val();
    regNmmarca    = $('#nmmarca', tr).val();
    regDsmodelo   = $('#dsmodelo', tr).val();
    regDschassi   = $('#dschassi', tr).val();
    regDsplaca    = $('#dsplaca', tr).val();
    regNranofab   = $('#nrano_fabrica', tr).val();
    regNranomod   = $('#nrano_modelo', tr).val();
    regCdcooper   = $('#cdcooper', tr).val();
    regNrdconta   = $('#nrdconta', tr).val();
    regimgSitCoop = $('#imgSitCoop', tr).val();

    regInsituac   = $('#indsituacao', tr).val();
    regNrcpjcnpj  = $('#nrcpf_cnpj_segurado', tr).val();
    regNmdosegur  = $('#nmdosegurado', tr).val();

    return false;
}

function btnAlterar() {

    /** Utiliza as variavies globais com o registro
    selecionado para poder altera-lo.

    Nesse caso eh passado o rowid do registro
    para alteracao **/

    //if (indrowid === undefined) {return false;}
    if (idcontrato === undefined) {return false;}

    /* Abre nova tela para manutenção do Seguro */
    $.ajax({
        type    : "POST",
        dataType: "html",
        url     : UrlSite + "telas/penseg/manter_pendencia.php",
        data: {
            redirect: "html_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
             carregaDetalhes();
            $("#divRotina").html(response);
             mostraRotina();
        }
    });
    return false;
}

// Função para visualizar div da rotina
function mostraRotina() {
    //$("#divRotina").centralizaRotinaH();
    $("#divRotina").css("visibility","visible");
}

// Função para esconder div da rotina e carregar dados da conta novamente
function encerraRotina(flgCabec) {
    $("#divRotina").css({"width":"545px","visibility":"hidden"});
    $("#divRotina").html("");

    // Esconde div de bloqueio
    unblockBackground();
    return false;
}


function gravarSeguro(){

    var newCdcooper = cnewCdcooper.val();
    var newNrdconta = cnewNrdconta.val();

    if ( $('#newCdcooper','#frmDados').hasClass('campoTelaSemBorda') ||
         $('#newNrdconta','#frmDados').hasClass('campoTelaSemBorda') ||
          ($('#newNmprimtl','#frmDados').val() == '' ||
           $('#newNmprimtl','#frmDados').val() == undefined )) {
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, atualizando dados...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/penseg/gravar_dados.php",
        data: {
            cdcooper   : newCdcooper,
            nrdconta   : newNrdconta,
            idcontrato : idcontrato,
            redirect   : "html_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            cTodosCabDados.removeClass('campoErro');
            hideMsgAguardo();
            try {
                if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                    try {
                        showError("inform", "Seguro atualizado com sucesso!", "Alerta - Ayllos", "encerraRotina(true);buscaSegurosPendentes(nriniseq, nrregist, nrapolice, nrcpfcnj);");
                    } catch(error) {
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
                    }
                } else {
                    try {
                        eval(response);
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
                    }
                }
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;
}

function replaceAll(texto,obj){

    /**
        Objetivo: Remover todos os caracter especiais
                  para evitar problemas na gravacao do
                  registro

        Parametros : texto --> Texto que sera analisado
                       obj --> Objeto referenciado para receber o texto ajustado
    **/

    // Lista todos os caracter especiais que serao substituidos
    var caracteresInvalidos = 'àèìòùâêîôûäëïöüáéíóúãõçÀÈÌÒÙÂÊÎÔÛÄËÏÖÜÁÉÍÓÚÃÕÇ<>;`´^~ªº¨§';
    // Lista todos os caracter que sera exibido
    var caracteresValidos =   'aeiouaeiouaeiouaeiouaocAEIOUAEIOUAEIOUAEIOUAOC';

    // Variaveis de controle
    var caracter = '';
    var letra = '';

    // Verifica todas as posicoes e troca todos os caracter invalidos
    for (i = 0; i < texto.length; i++) {
        if (caracteresInvalidos.indexOf(texto.charAt(i)) == -1){
            caracter = caracter+texto.charAt(i);
        }else{
            letra = caracteresValidos.charAt(caracteresInvalidos.indexOf(texto.charAt(i)));
            caracter=caracter+letra;
        }
    }

    // Recebe o texto convertido
    obj.value = caracter;
}

function deletarSeguros(operacao) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, atualizando dados...");
	bloqueiaFundo(divRotina);

	if (operacao) {
		var ids = "";

		$(".iptdel").each(function() {
			if (this.checked) {
				ids = ids + $(this).val() + ";";
			}
		});

		$.ajax({
			type    : "POST",
			dataType: "html",
			url     : UrlSite + "telas/penseg/deletar_dados.php",
			data: {
				registros: ids,
				redirect: "html_ajax"
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function(response) {
				hideMsgAguardo();
				try {
					hideMsgAguardo();
					showError("inform", "Seguro(s) deletado(s) com sucesso!", "Alerta - Ayllos", "buscaSegurosPendentes(nriniseq, nrregist, nrapolice, nrcpfcnj);");
				} catch(error) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			}
		});
	} else {
		numberOfChecked = $('input.iptdel:checkbox:checked').length;
		showConfirmacao('Deseja deletar o(s) '+numberOfChecked+' item(ns) selecionado(s)?', 'Confirma&ccedil;&atilde;o - Aimaro', 'deletarSeguros(\'confirma\');', 'hideMsgAguardo();', 'sim.gif', 'nao.gif');
	}

}

function btnBuscaSegurosFiltro() {

	nrapolice = $("#nrapolice").val();
	nrcpfcnj = $("#nrcpfcnj").val();
	nrregist = $("#nrregist").val();

	buscaSegurosPendentes(1, nrregist, nrapolice, nrcpfcnj);

}

function btnAtualizar(qtdRegis) {

	nrcpfcnj = nrapolice = "";

	$("#nrapolice").val(nrapolice);
	$("#nrcpfcnj").val(nrcpfcnj);

	buscaSegurosPendentes(1, qtdRegis);

}