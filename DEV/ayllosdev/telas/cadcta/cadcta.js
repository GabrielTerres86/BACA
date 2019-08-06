/*!
 * FONTE        : cadcta.js
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : Outubro/2017 
 * OBJETIVO     : Biblioteca de funções da tela CADCTA
 * --------------
 * ALTERAÇÕES   : [14/06/2018] Mateus Z (Mouts)     : Nova rotina "FATCA CRS" (PRJ414).
 * 
 *                [05/08/2019] Renato/Miguel (Supero): Manter indicador de cadastro positivo
 *                                                     bloqueado e não permitindo edição e 
 *                                                     ajustar a navegação da tela
 * --------------
 *
 */

var flgAcessoRotina = false; // Flag para validar acesso as rotinas da tela CONTAS
var flgMostraAnota = false; // Flag que indica se anotações devem ser mostradas após as mensagens

var nrdconta = ""; // Variável global para armazenar nr. da conta/dv
var nrdctitg = ""; // Variável global para armazenar nr. da conta integração
var inpessoa = ""; // Variável global para armazenar o tipo de pessoa (física/jurídica)
var idseqttl = ""; // Variável global para armazenar nr. da sequencia dos titulares
var cpfprocu = ""; // Variável global para armazenar nr. do cpf dos titulares
var dtdenasc = ""; // Variável global para armazenar a data de nascimento do titular
var cdhabmen = ""; // Variável global para armazenar o tipo de responsabilidade legal
var verrespo = false; //Variável global para indicar se deve validar ou nao os dados dos Resp.Legal na BO55
var permalte = false; // Está variável sera usada para controlar se a "Alteração/Exclusão/Inclusão - Resp. Legal" deverá ser feita somente na tela contas
var arr_guias_dadosp = [false, true, false, true, true, true, true]; // Array para descobrir em qual guia da rotina Dados pessoias o operador ja passou
var arr_guias_comercial = [false, false, false]; // Array para descobrir em qual guia da rotina Comercial PF o operador ja passou
var arr_guias_contacorrente = [false, false, false, false];// Array para descobrir em qual guia da rotina Conta Corrente o operador ja passou
var nrdrowid_rsp = ""; //Armqzena rowid do responsavel legal selecionado


var arrayFilhos = new Array(); // Variável global para armazenar os responsaveis legais

var contWinAnot = 0; // Para impressão das anotações
var nrJanelas   = 0; // Variável para contagem do número de janelas abertas para impressãosa dajsdj

//Variaveis de controle para uso da rotina Produtos
var produtosTelasServicos = new Array();
var produtosTelasServicosAdicionais = new Array();
var executandoProdutosServicos = false;
var executandoProdutos = false;
var executandoImpedimentos = false;
var executandoProdutosServicosAdicionais = false;
var posicao = 0;
var atualizarServicos = new Array();

var flgcreca = 'no';
var flgexclu = 'no';

$(document).ready(function () {

    var cNrConta = $('#nrdconta', '#frmCabCadcta');
    var cSeqTitular = $('#idseqttl', '#frmCabCadcta');    

    // Evento onKeyUp no campo "nrdconta"
    cNrConta.bind('keyup', function (e) {
        // Seta máscara ao campo
        if (!$(this).setMaskOnKeyUp("INTEGER", "zzzz.zzz-z", "", e)) {
            return false;
        }
    });
       

    // Evento onKeyDown no campo "nrdconta"
    cNrConta.bind('keydown', function (e) {
        // Captura código da tecla pressionada
        var keyValue = getKeyValue(e);

        if (keyValue == 118) { // Se for F7
            if ($(this).hasClass('campo')) {
                $('a', '#frmCabCadcta').first().click();
                return false;
            }
        }

        // Se alguma tecla foi pressionada, seta o idseqttl para 1
        if ((keyValue >= 48 && keyValue <= 57) || (keyValue >= 96 && keyValue <= 105)) {
            cSeqTitular.val('1');
            $('#idTableTTL', '#frmCabCadcta').val(0);
        }

        // Se o botão enter foi pressionado, carrega dados da conta
        if (keyValue == 13) {
            flgcadas = 'C';
            cSeqTitular.val('1');
            $('#idTableTTL', '#frmCabCadcta').val(0);
            obtemCabecalho();
            return false;
        }

        // Seta máscara ao campo
        return $(this).setMaskOnKeyDown("INTEGER", "zzzz.zzz-z", "", e);
    });

    // Evento onBlur no campo "nrdconta"
    cNrConta.bind('blur', function () {
        if ($(this).val() == '') {
            limparDadosCampos();
            return true;
        }

        // Valida número da conta
        if (!validaNroConta(retiraCaracteres($(this).val(), "0123456789", true))) {
            showError("error", "Conta/dv inválida.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
            limparDadosCampos();
            return false;
        }

        if (retiraCaracteres($(this).val(), "0123456789", true) != nrdconta) {
            limparDadosCampos();
            return true;
        }

        if (cSeqTitular.val() != idseqttl) {
            obtemCabecalho();
            return true;
        }

        return true;
    });

    
    formataTela();
    cNrConta.focus();
    
    // Se origem foi do CRM
	if (crm_inacesso == 1){
		
		if (normalizaNumero(crm_nrdconta) > 0){
            cNrConta.val(crm_nrdconta);
            cNrConta.desabilitaCampo();			
		}else{
			showError("error", "Numero de conta deve ser informado.", "Alerta - Ayllos", "");
            cNrConta.desabilitaCampo();		
            return false;    
		}
	}else{
        // Controle da pesquisa Assosicado
        controlaPesquisaAssociado('frmCabCadcta');
        
    }
        


    // Se foi chamada pela tela MATRIC (inclusao de nova conta), carregar as rotinas para finalizar cadastro
    if (cNrConta.val() != "" && cSeqTitular.val() != "") {
        obtemCabecalho();
    }
	
	startStopTables(0); // iniciar todas
    
    
	
});

function startStopTables(q){
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];			
		
	var arrayLargura = new Array();
	arrayLargura[0] = '63px';
	arrayLargura[1] = '200px';
	arrayLargura[2] = '100px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
    
    //Caso estiver inicializando, deve ocultar para exibir vazio
    if (q == 0){
        window.scrollTo(0, 0);
        //ocultar blocos de dados 
        $('.cnt2-1').css({'display':'none'});        
    }
	
	switch(q){
		case 1:

            if(inpessoa == 1){

                var arrayLargura1 = new Array();
                arrayLargura1[0] = '63px';
                arrayLargura1[1] = '200px';
                arrayLargura1[2] = '100px';

                var arrayAlinha1 = new Array();
                arrayAlinha1[0] = 'right';
                arrayAlinha1[1] = 'left';
                arrayAlinha1[2] = 'right';
            }else{
                
                var arrayLargura1 = new Array();
                arrayLargura1[0] = '400px';
                
                var arrayAlinha1 = new Array();
                arrayAlinha1[0] = 'left';
                arrayAlinha1[1] = 'right';
            }           

            var ordemInicial1 = new Array();
            ordemInicial1 = [[1,0]];	
    
			var divRegistro1 = $('.titulares .divRegistrosC');
			var tabela1 = $('table', divRegistro1);
			inpessoa == 1 ? divRegistro1.css('height','48px') : divRegistro1.css('height','32px');
			tabela1.formataTabela( ordemInicial1, arrayLargura1, arrayAlinha1, '' );
            
            //Marcar item ja selecionado, para garantir que mantenha marcado o titular selecionado ao carregar a tela                        
            if ( $('#idTableTTL', '#frmCabCadcta').val() ==''){
                $('#idTableTTL', '#frmCabCadcta').val(0);
            }           
            tabela1.zebraTabela($('#idTableTTL', '#frmCabCadcta').val());
            
            // seleciona o registro que é clicado
            $('table > tbody > tr', $('div.divRegistrosC', '#frmConsultaDados')).click(function() {                
                if (inpessoa == 1) {
                    
                    $('#idTableTTL', '#frmCabCadcta').val($(this).attr('id'));
                    
                    idseqttl = $(this).find('#idseqttl').val()       
                    $('#idseqttl', '#frmCabCadcta').val(idseqttl);   
                    $('#nrcpfcgc', '#frmCabCadcta').val($(this).find('#nrcpfcgc').val());                                     
                    setTimeout(function(){ carregarTabelasPF('S'); 
                    
                    }, 200);
                }

            });                        
			break;
		case 2:
			var divRegistro2 = $('.responsaveislegais .divRegistrosC');
			var tabela2 = $('table', divRegistro2);
			divRegistro2.css('height','32px');
			tabela2.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );            
			break;
		case 3:
			var arrayLargura3 = new Array();
			var arrayAlinha3 = new Array();
            
			
			arrayLargura3[0] = '67px';
			arrayLargura3[1] = '170px';
			arrayLargura3[2] = '80px';
            
            inpessoa == 1 ? arrayLargura3[3] = '85px' : arrayLargura3[3] = '65px';
			;
			
			arrayAlinha3[0] = 'right';
			arrayAlinha3[1] = 'left';
			arrayAlinha3[2] = 'right';
			arrayAlinha3[3] = 'left';
			arrayAlinha3[4] = 'left';
			var divRegistro3 = $('.procuradores .divRegistrosC');
			var tabela3 = $('table', divRegistro3);
			inpessoa == 1 ? divRegistro3.css('height','32px') : divRegistro3.css('height','48px');
            
			tabela3.formataTabela( ordemInicial, arrayLargura3, arrayAlinha3, '' );
            
            // seleciona o registro que é clicado
            $('table > tbody > tr', divRegistro3).dblclick(function() {              
                $('#nrdrowid_procurador', '#frmCabCadcta').val($(this).find('#nrdrowid').val());                
                setTimeout(function(){ openEditProcurador(); }, 500);
                

            });
            
			break;
		case 4:
            var arrayLargura4 = new Array();
            var arrayAlinha4 = new Array();
            
            arrayLargura4[0] = '200px';
            arrayLargura4[1] = '75px';
            arrayLargura4[2] = '75px';

            arrayAlinha4[0] = 'left';
            arrayAlinha4[1] = 'left';
            arrayAlinha4[2] = 'left';
            arrayAlinha4[3] = 'left';

			var divRegistro4 = $('.informativos .divRegistrosC');
			var tabela4 = $('table', divRegistro4);
			divRegistro4.css('height','48px');
			tabela4.formataTabela( ordemInicial, arrayLargura4, arrayAlinha4, '' );
            
            // seleciona o registro que é clicado
            $('table > tbody > tr', divRegistro4).dblclick(function() {              
                $('#nrdrowid_infor', '#frmCabCadcta').val($(this).find('#nrdrowid').val());  
                setTimeout(function(){ openEditInformativo(); }, 500);
                

            });
            
			break;
		case 5:
        
            var arrayLargura5 = new Array();
            var arrayAlinha5 = new Array();
            
            arrayLargura5[0] = '67px';
            arrayLargura5[1] = '284px';
            arrayLargura5[2] = '110px';

            arrayAlinha5[0] = 'right';
            arrayAlinha5[1] = 'left';
            arrayAlinha5[2] = 'right';
            arrayAlinha5[3] = 'left';
        
			var divRegistro5 = $('.participacaoEmpresas .divRegistrosC');
			var tabela5 = $('table', divRegistro5);
			divRegistro5.css('height','32px');
			tabela5.formataTabela( ordemInicial, arrayLargura5, arrayAlinha5, '' );
			break;
		case 6:
			var arrayLargura6 = new Array();
			var arrayAlinha6 = new Array();
			
			arrayLargura6[0] = '67px';
			arrayLargura6[1] = '170px';
			arrayLargura6[2] = '80px';
			arrayLargura6[3] = '65px';
			
			arrayAlinha6[0] = 'right';
			arrayAlinha6[1] = 'left';
			arrayAlinha6[2] = 'right';
			arrayAlinha6[3] = 'left';
			arrayAlinha6[4] = 'left';
			var divRegistro6 = $('.representantes .divRegistrosC');
			var tabela6 = $('table', divRegistro6);
			inpessoa == 1 ? divRegistro6.css('height','32px') : divRegistro6.css('height','48px');
			tabela6.formataTabela( ordemInicial, arrayLargura6, arrayAlinha6, '' );            
            
			break;
        default:
			for(var i = 1; i <= 6; i++){
				startStopTables(i);
			}
	}

    // Inserir os botoes de Incluir dentro da tabela
    if(inpessoa == 1){
        $('.ordemInicial', '.titulares').html('<a href="#" class="botao cnt2-2" onclick="openNewTitular();" style="float: none; display: inline-block;">+</a>');
    }else{
        $('.ordemInicial', '.titulares').remove();
    }    
    $('.ordemInicial', '.procuradores').html('<a href="#" class="botao cnt2-2" id="btnImprimir" name="btnImprimir" onclick="openNewProcurador(); return false;" style="float: none; display: inline-block;">+</a>');
    $('.ordemInicial', '.informativos').html('<a href="#" class="botao cnt2-2" id="btnImprimir" name="btnImprimir" onclick="openNewInformativo(); return false;" style="float: none; display: inline-block;">+</a>');    

    $('.ordemInicial', '.representantes').remove(); 
    $('.ordemInicial', '.participacaoEmpresas').remove();     
    $('.ordemInicial', '.responsaveislegais').remove();     
    
    $('.cnt2-2').css({ 'padding': '1px', 'margin': '2px', 'width': '15px' });
}

// Função para setar foco na rotina
function focoRotina(id, flgEvent) {
    if (!flgAcessoRotina || $("#labelRot" + id).html() == "&nbsp;") {
        return false;
    }

    if (flgEvent) { // MouserOver
        $("#labelRot" + id).css({
            backgroundColor: "#FFB4A0",
            cursor: "pointer"
        });
    } else { // MouseOut
        $("#labelRot" + id).css({
            backgroundColor: "#E3E2DD",
            cursor: "default"
        });
    }
}

// Função para fechar div com mensagens de alerta
function encerraMsgsAlerta() {
    // Esconde div
    $("#divMsgsAlerta").css("visibility", "hidden");

    $("#divListaMsgsAlerta").html("&nbsp;");

    if (flgMostraAnota) {
        // Mostra div 
        $("#divAnotacoes").css("visibility", "visible");

        // Bloqueia conteúdo que está átras do div de Anotações
        blockBackground(parseInt($("#divAnotacoes").css("z-index")));

        // Flag para não mostrar a tela de anotações
        flgMostraAnota = false;
    } else {
        // Esconde div de bloqueio
        unblockBackground();
    }
}

// Função para acessar rotinas da tela CONTAS
function acessaRotina(nomeValidar, nomeTitulo, nomeURL, opeProdutos, action) {
	
	action = ((!action) ? '' : action);
	
    // Verifica se é uma chamada válida
    if (!flgAcessoRotina) {
        return false;
    }

    // Mostra mensagem de aguardo	
    showMsgAguardo("Aguarde, carregando  " + nomeTitulo + " ...");

    var nomeDaTela = 'CADCTA';
    var url = UrlSite + "telas/cadcta/" + nomeURL + "/" + nomeURL;

    if ( nomeURL == 'produtos' || nomeURL == 'responsavel_legal') {

        var urlScript = UrlSite + "includes/" + nomeURL + "/" + nomeURL;

    } else if (executandoProdutos == true || executandoImpedimentos == true) {
        var url = UrlSite + "telas/atenda/" + nomeURL + "/" + nomeURL;
        var urlScript = UrlSite + "telas/atenda/" + nomeURL + "/" + nomeURL;
        var nomeDaTela = 'ATENDA';

    } else {

        var urlScript = UrlSite + "telas/cadcta/" + nomeURL + "/" + nomeURL;

    }
	
	//if (nomeURL == 'procuradores_fisica'){
	//	url = UrlSite + "telas/cadcta/" + nomeURL + "/" + 'principal';
	//}
	
	//console.log(url);

    verrespo = false;
    permalte = false;

    // Carrega biblioteca javascript da rotina
    // Ao carregar efetua chamada do conteúdo da rotina através de ajax
    $.getScript(urlScript + ".js", function () {

        nmrotina = removeAcentos(nomeTitulo);

        $.ajax({
            type: "POST",
            dataType: "html",
            url: url + ".php",
            data: {
                nrdconta: nrdconta,
                idseqttl: idseqttl,
                inpessoa: inpessoa,
                nmdatela: nomeDaTela,
                nmrotina: nomeValidar,
                flgcadas: flgcadas,
                opeProdutos: opeProdutos,
				opeaction: action,
                redirect: "html_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "");
            },
            success: function (response) {
                $("#divRotina").html(response);

                $('.fecharRotina').click(function () {
                    
                    idseqttl = $('#idseqttl', '#frmCabCadcta').val();
                    fechaRotina(divRotina);
					if (executandoImpedimentos){
						sequenciaImpedimentos();
					}
                    return false;
                });
            }
        });
    });
}

function removeAcentos(str) {
    return str.replace(/[àáâãäå]/g, "a").replace(/[ÀÁÂÃÄÅ]/g, "A").replace(/[ÒÓÔÕÖØ]/g, "O").replace(/[òóôõöø]/g, "o").replace(/[ÈÉÊË]/g, "E").replace(/[èéêë]/g, "e").replace(/[Ç]/g, "C").replace(/[ç]/g, "c").replace(/[ÌÍÎÏ]/g, "I").replace(/[ìíîï]/g, "i").replace(/[ÙÚÛÜ]/g, "U").replace(/[ùúûü]/g, "u").replace(/[ÿ]/g, "y").replace(/[Ñ]/g, "N").replace(/[ñ]/g, "n");
}

// Função para visualizar div da rotina
function mostraRotina() {
    $("#divRotina").css("visibility", "visible");
}

// Função para esconder div da rotina e carregar dados da conta novamente
function encerraRotina(flgCabec) {

    $("#divRotina").css("visibility", "hidden");
    $("#divRotina").html("");

    // Para esconder o F2
    nmrotina = ""

    if (executandoProdutos) {

        if (executandoProdutosServicos && (posicao < produtosTelasServicos.length)) {
            eval(produtosTelasServicos[posicao]);
            posicao++;
            return false;

        } else if (executandoProdutosServicosAdicionais && (posicao < produtosTelasServicosAdicionais.length)) {
            eval(produtosTelasServicosAdicionais[posicao]);
            posicao++;
            return false;
        }

    }

    if (flgCabec) {
        obtemCabecalho();
    } else {
        // Retira trava do fundo
        divError.escondeMensagem();
    }
}

function sequenciaImpedimentos() {
    if (executandoImpedimentos) {
		if (posicao <= produtosCancMContas.length) {
			if (produtosCancMContas[posicao - 1] == '' || produtosCancMContas[posicao - 1] == 'undefined'){
				eval(produtosCancM[posicao - 1]);
				posicao++;
			}else{
				eval(produtosCancMContas[posicao - 1]);
				posicao++;
			}
            return false;
        }else{
			eval(produtosCancM[posicao - 1]);
			posicao++;
			return false;
		}
    }
}

// Função para carregar dados da conta informada
function obtemCabecalho() {
	
    opbackgr = (typeof opbackgr == 'undefined') ? true : opbackgr;
    assincrono = (typeof assincrono == 'undefined') ? true : assincrono;

    if (opbackgr) showMsgAguardo('Aguarde, carregando dados da conta/dv ...');

    // Armazena conta/dv e seq.contas informadas
    nrdconta = normalizaNumero($("#nrdconta", "#frmCabCadcta").val());
    idseqttl = (typeof id == 'undefined') ? normalizaNumero($("#idseqttl", "#frmCabCadcta").val()) : id;	

    // Se nenhum dos tipos de conta foi informado
    if (nrdconta == '') {
        hideMsgAguardo();
        showError("error", "Informe o número da Conta/dv.", "Alerta - Ayllos", "$('#nrdconta').focus()");
        limparDadosCampos();
        return false;
    }

    if (!validaNroConta(nrdconta)) {
        hideMsgAguardo();
        showError("error", "Conta/dv inválida.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
        limparDadosCampos();
        return false;
    }   
    
    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        async: assincrono,
        url: UrlSite + "telas/cadcta/obtem_cabecalho.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            opbackgr: opbackgr,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
        },
        success: function (response) {
            try {

                $("#frmCabCadcta").fadeTo(1, 0.01);
                eval(response);
                removeOpacidade('frmCabCadcta');
                
                // Verifica se é uma chamada válida
                if (!flgAcessoRotina) {
                    return false;
                }

                obtemDadosDaConta();

                if(inpessoa == 1){
                    carregarTabelasPF();
                }else{
                    carregarTabelasPJ();
                }
                                
            } catch (error) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
            }
        }
    });    
        
}

// Função para carregar dados da conta informada
function obtemDadosDaConta() {

    // Verifica se é uma chamada válida
    if (!flgAcessoRotina) {
        return false;
    }


    showMsgAguardo('Aguarde, carregando dados da conta/dv ...');

    // Armazena conta/dv e seq.contas informadas
    nrdconta = normalizaNumero($("#nrdconta", "#frmCabCadcta").val());
    idseqttl = (typeof id == 'undefined') ? normalizaNumero($("#idseqttl", "#frmCabCadcta").val()) : id;    

    // Se nenhum dos tipos de conta foi informado
    if (nrdconta == '') {
        hideMsgAguardo();
        showError("error", "Informe o número da Conta/dv.", "Alerta - Ayllos", "$('#nrdconta').focus()");
        limparDadosCampos();
        return false;
    }

    if (!validaNroConta(nrdconta)) {
        hideMsgAguardo();
        showError("error", "Conta/dv inválida.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
        limparDadosCampos();
        return false;
    }

    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcta/obtem_dados_conta.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            inpessoa: inpessoa,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
        },
        success: function (response) {
            try {
                if ( response.indexOf('showError("error"') == -1 ) {
                    $('#rowDadosDaConta').html(response);
                    formataTela();
                    controlaTipoPessoa();
                } else {
                    eval(response);
                }

            } catch (error) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
            }
        }
    });
    
}

function controlaTipoPessoa(){
    if(inpessoa == 1){
        $('.pessoaJuridica').css({ 'display': 'none' });
        $('.pessoaFisica').css({ 'display': '' });
    }else{
        $('.pessoaFisica').css({ 'display': 'none' });
        $('.pessoaJuridica').css({ 'display': '' });
    } 
}

function controlaLayoutCadcta(operacao){
    if(operacao == 'A'){

        showMsgAguardo('Aguarde, carregando alteração da conta/dv ...');

        var camposEditaveis = $('#nmctajur ,#cdconsultor, #flgiddep, #flgrestr, #indserma, #fldevchq, #inlbacen, #nmtalttl, #qtfoltal, #nrinfcad,#nrperger, #nrpatlvr, #dsinfadi', '#frmCadcta');
        var camposEditCab   = $('#nmctajur', '#frmCabCadcta');
        var botoes = $('#btAlterar, #btContinuar, #btImpressoes, #btGrEconomico, #btImunidadeTributaria, #btClienteFinanceiro, #btOrgaosProtecaoCredito, #btImpedimentosDesligamento, #btDosie, #btFatcaCrs', '#frmCadcta');
        var botoesAlteracao = $('#btCancelar, #btSalvar', '#frmCadcta');
        camposEditaveis.habilitaCampo();
        camposEditCab.habilitaCampo();
        
        if (inpessoa == 1 ){
             $('#cdconsultor','#frmCadcta').focus();
        }else{
             camposEditCab.focus();
        }
                
        botoes.css('display', 'none');
        
        botoesAlteracao.css('display', '');

        
        var cCdempres  =  $('#cdempres', '#frmCadcta');
        var cCdnatopc  =  $('#cdnatopc', '#frmCadcta');
        var cCdocpttl  =  $('#cdocpttl', '#frmCadcta');        
        var cTpcttrab  =  $('#tpcttrab', '#frmCadcta');
        
        // Apenas habilita o campo se a  Nat. Ocupação for DIFERENTE de 11 (Sem Remuneração) AND 12 (Sem Vínculo)
        // e o Tp. Contrato Trabalho é DIFERENTE 3 (Sem Vínculo) 
        if ((cCdnatopc.val() != 11) && (cCdnatopc.val() != 12) && cTpcttrab.val() != 3) {
          cCdempres.habilitaCampo();
        }
        
        controlaPesquisas();
        
        hideMsgAguardo();
        
    }   
}

function carregarTabelasPF(tipo) {

    showMsgAguardo('Aguarde, carregando dados da conta/dv ...');

    // Armazena conta/dv e seq.contas informadas
    nrdconta = normalizaNumero($("#nrdconta", "#frmCabCadcta").val());
    idseqttl = normalizaNumero($("#idseqttl", "#frmCabCadcta").val());    
    
    // Se for diferente de S - Seleção titular, pois selecionaou um titular na grid
    if (tipo != "S") {
    
        // Se nenhum dos tipos de conta foi informado
        if (nrdconta == '') {
            hideMsgAguardo();
            showError("error", "Informe o número da Conta/dv.", "Alerta - Ayllos", "$('#nrdconta').focus()");
            limparDadosCampos();
            return false;
        }

        if (!validaNroConta(nrdconta)) {
            hideMsgAguardo();
            showError("error", "Conta/dv inválida.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
            limparDadosCampos();
            return false;
        }

        $.ajax({
            type: "POST",
            url: UrlSite + "telas/cadcta/titulares_pf.php",
            data: {
                nrdconta: nrdconta,
                idseqttl: idseqttl,
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
            },
            success: function (response) {
                try {
                    $('.cnt2-1.titulares').html(response);
                    startStopTables(1);
                } catch (error) {
                    hideMsgAguardo();
                    showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
                }
            }
        });
    }else{
        
        obtemDadosDaConta();
        
    }
    
    // Verifica se é uma chamada válida
    if (!flgAcessoRotina) {
        return false;
    }
   
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcta/responsavel_legal.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
        },
        success: function (response) {
            try {
                $('.cnt2-1.responsaveislegais').html(response);
                startStopTables(2);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
            }
        }
    });

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcta/procuradores_pf.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
        },
        success: function (response) {
            try {
                $('.cnt2-1.procuradores').html(response);
                startStopTables(3);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
            }
        }
    });

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcta/informativos.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
        },
        success: function (response) {
            try {
                $('.cnt2-1.informativos').html(response);
                startStopTables(4);
                hideMsgAguardo();
            } catch (error) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
            }
        }
    });
}

function carregarTabelasPJ() {

    showMsgAguardo('Aguarde, carregando dados da conta/dv ...');

    // Armazena conta/dv e seq.contas informadas
    nrdconta = normalizaNumero($("#nrdconta", "#frmCabCadcta").val());
    idseqttl = normalizaNumero($("#idseqttl", "#frmCabCadcta").val());    
    nrcpfcgc = normalizaNumero($("#nrcpfcgc", "#frmCabCadcta").val());    
    nmextttl = $("#nmextttl", "#frmCabCadcta").val();    

    // Se nenhum dos tipos de conta foi informado
    if (nrdconta == '') {
        hideMsgAguardo();
        showError("error", "Informe o número da Conta/dv.", "Alerta - Ayllos", "$('#nrdconta').focus()");
        limparDadosCampos();
        return false;
    }

    if (!validaNroConta(nrdconta)) {
        hideMsgAguardo();
        showError("error", "Conta/dv inválida.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
        limparDadosCampos();
        return false;
    }

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcta/titulares_pj.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            nrcpfcgc: nrcpfcgc,
            nmextttl: nmextttl,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
        },
        success: function (response) {
            try {
                $('.cnt2-1.titulares').html(response);
                startStopTables(1);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
            }
        }
    });

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcta/procuradores_pj.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
        },
        success: function (response) {
            try {
                $('.cnt2-1.procuradores').html(response);
                startStopTables(3);
                //hideMsgAguardo();
            } catch (error) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
            }
        }
    });
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcta/representantes_pj.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
        },
        success: function (response) {
            try {
                $('.cnt2-1.representantes').html(response);
                startStopTables(6);
                //hideMsgAguardo();
            } catch (error) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
            }
        }
    });
    
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcta/participacao_empresas.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
        },
        success: function (response) {
            try {
                $('.cnt2-1.participacaoEmpresas').html(response);
                startStopTables(5);
                hideMsgAguardo();
            } catch (error) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
            }
        }
    });
}

// Função para limpar campos com dados da conta
function limparDadosCampos() {
    // Limpa campos com dados pessoais da conta
    for (i = 0; i < document.frmCabCadcta.length; i++) {
        if (document.frmCabCadcta.elements[i].name == "nrdconta") continue;

        document.frmCabCadcta.elements[i].value = "";
    }

    // Limpa campos com saldos da conta
    for (i = 0; i < 24; i++) {
        $("#labelRot" + i).html("&nbsp;").unbind("click");

    }
    $("#idseqttl").html("<option value=\"1\"></option>");

    return true;
}

// Função para carregar os titulares da conta 
function obtemTitular() {

    var nmextttl = $("#nmextttl", "#frmCabCadcta").val(); // nome do titular

    //popula o combo somente na primeira vez
    if (nmextttl != "") {
        return false;
    }
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando os titulares da conta/dv ...");

    // Armazena conta/dv e seq.contas informadas
    nrdconta = retiraCaracteres($("#nrdconta", "#frmCabCadcta").val(), "0123456789", true);

    // Se nenhum dos tipos de conta foi informado
    if (nrdconta == "") {
        hideMsgAguardo();
        showError("error", "Informe o número da Conta/dv.", "Alerta - Ayllos", "$('#nrdconta').focus()");
        return false;
    }

    // Se conta/dv foi informada, valida
    if (nrdconta != "") {
        if (!validaNroConta(nrdconta)) {
            hideMsgAguardo();
            showError("error", "Conta/dv inválida.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
            limparDadosCampos();
            return false;
        }
    }

    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcta/obtem_titulares.php",
        data: {
            nrdconta: nrdconta,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Ayllos", "$('#nrdconta','#frmCabCadcta').focus()");
            }
        }
    });
}

/*!
 * ALTERAÇÃO : 006
 * OBJETIVO  : Função para formatar os campos do cabeçalho de contas, a fim de limparmos o código do formulário
 */
function formataTela() {
    
    $('#divTela').css({ 'display': 'block' }).fadeTo(0, 0.1);
    removeOpacidade('divTela');
    
    var grupoEditavel = $('#nrdconta', '#frmCabCadcta');
    var grupoAmbos = $('#cdagenci,#nrmatric,#cdtipcta,#cdsitdct,#cdcatego,#nmctajur', '#frmCabCadcta');
    var cTodosFrmCadcta = $('input,select,textarea', '#frmCadcta');
    var botoesAlteracao = $('#btCancelar, #btSalvar', '#frmCadcta');
    
    // não permitir cooperado altera a conta caso venha pelo CRM
    if (crm_inacesso !=1 ) {
      grupoEditavel.habilitaCampo();
    }
    grupoAmbos.desabilitaCampo();
    cTodosFrmCadcta.desabilitaCampo();

    botoesAlteracao.css('display', 'none');

    $('br', '#frmCabCadcta, #frmCadcta').css({ 'clear': 'both' });
    $('a', '#frmCabCadcta').css({ 'float': 'left', 'font-size': '11px', 'padding-top': '4px' });
    $('a', '#frmCadcta').css({ 'float': 'left', 'padding': '0px 0px 0px 3px' });
    $('.botao', '#frmCadcta').css({ 'float': '', 'padding': '3px 6px 3px 6px' });

    // Rótulos comum a PF e PJ
    $('label[for="nrdconta"]', '#frmCabCadcta').addClass('rotulo rotulo-60');
    $('label[for="idseqttl"]', '#frmCabCadcta').css({ 'width': '68px' });
    $('label[for="cdagenci"]', '#frmCabCadcta').addClass('rotulo-40');
    $('label[for="nrmatric"]', '#frmCabCadcta').css({ 'width': '70px' });
    $('label[for="cdtipcta"]', '#frmCabCadcta').css({ 'width': '85px' }).addClass('rotulo rotulo-40');;
    $('label[for="nrdctitg"]', '#frmCabCadcta').css({ 'width': '50px' });
    $('label[for="cdsitdct"]', '#frmCabCadcta').css({ 'width': '70px' });
    $('label[for="cdcatego"]', '#frmCabCadcta').css({ 'width': '85px' }).addClass('rotulo rotulo-40');
    $('label[for="idseqttl"]', '#frmCabCadcta').css({ 'display': 'none' });
    $('label[for="nrdctitg"]', '#frmCabCadcta').css({ 'display': 'none' });
    $('label[for="nmctajur"]', '#frmCabCadcta').css({ 'width': '93px' }).addClass('rotulo rotulo-40');
    
    // Largura dos campos comum a PF e PJ
    $('#nrdconta', '#frmCabCadcta').css({ 'width': '67px', 'text-align': 'right' });
    $('#cdagenci', '#frmCabCadcta').css({ 'width': '180px' })
    $('#nrmatric', '#frmCabCadcta').css({ 'width': '70px', 'text-align': 'right' });
    $('#cdtipcta', '#frmCabCadcta').css({ 'width': '200px' });
    $('#cdsitdct', '#frmCabCadcta').css({ 'width': '180px' });
    $('#idseqttl', '#frmCabCadcta').css({ 'display': 'none' });
    $('#nrdctitg', '#frmCabCadcta').css({ 'display': 'none' });
    $('#cdcatego', '#frmCabCadcta').css({ 'width': '200px' });
    $('#nmctajur', '#frmCabCadcta').css({ 'width': '445px','text-transform':'uppercase' });

    // Hack IE
    if ($.browser.msie) {
        $('#nrdctitg', '#frmCabCadcta').css({ 'width': '66px' });
        $('hr', '#frmCabCadcta, #frmCadcta').css({ 'margin': '25px 0px 0px 0px', ' ': '0px', 'color': '#777', 'display': 'block', 'height': '1px' });
    } else {
        $('hr', '#frmCabCadcta, #frmCadcta').css({ 'background-color': '#777', 'height': '1px', 'margin': '5px 0px 2px 0px' });
    }

    //Conta Corrente
    
    //rotulo
    var rCdbcochq         =  $('label[for="cdbcochq"]', '#frmCadcta');
    var rCdconsul         =  $('label[for="cdconsultor"]', '#frmCadcta');
    var rCdbcoitg         =  $('label[for="cdbcoitg"]', '#frmCadcta');
    var rCdagedbb         =  $('label[for="cdagedbb"]', '#frmCadcta');
    var rNrdctitg         =  $('label[for="nrdctitg"]', '#frmCadcta');
    var rNrctacns         =  $('label[for="nrctacns"]', '#frmCadcta');    
    
    rCdbcochq.addClass('rotulo').css({ 'width': '155px' });
    rCdconsul.addClass('rotulo-linha').css({ 'width': '90px' });
    rCdbcoitg.addClass('rotulo-linha').css({ 'width': '51px' });
    rCdagedbb.addClass('rotulo-linha').css({ 'width': '55px' });
    rNrdctitg.addClass('rotulo-linha').css({ 'width': '60px' });
    rNrctacns.addClass('rotulo-linha').css({ 'width': '100px' });
        
    //Campos
    var cCdbcochq         =  $('#cdbcochq', '#frmCadcta');
    var cCdconsul         =  $('#cdconsultor', '#frmCadcta');
    var cNmconsul         =  $('#nmconsultor', '#frmCadcta');
    var cCdbcoitg         =  $('#cdbcoitg', '#frmCadcta');
    var cCdagedbb         =  $('#cdagedbb', '#frmCadcta');
    var cNrdctitg         =  $('#nrdctitg', '#frmCadcta');
    var cDssititg         =  $('#dssititg', '#frmCadcta');
    var cNrctacns         =  $('#nrctacns', '#frmCadcta');    
        
    cCdbcochq.css('width','47px').addClass('inteiro');
    cCdconsul.css('width','50px').addClass('inteiro');
    cNmconsul.css('width','215px').addClass('texto');
    cCdbcoitg.css('width','47px').addClass('inteiro');
    cCdagedbb.css('width','52px').addClass('inteiro');
    cNrdctitg.css('width','100px').addClass('contaitg');
    cDssititg.css({'background-color':'#F7F3FF','width':'155px','border':'1px solid #F7F3FF','color':'#333','text-transform':'uppercase','padding-left':'0px'});    
    cNrctacns.css('width','100px').addClass('conta');
    
    //rotulo
    var rDscadpos         =  $('label[for="dscadpos"]', '#frmCadcta');
    var rFlgiddep         =  $('label[for="flgiddep"]', '#frmCadcta');
    var rFlblqtal         =  $('label[for="flblqtal"]', '#frmCadcta');
    var rFlgrestr         =  $('label[for="flgrestr"]', '#frmCadcta');
    var rIndserma         =  $('label[for="indserma"]', '#frmCadcta');
    var rFldevchq         =  $('label[for="fldevchq"]', '#frmCadcta');
    var rInlbacen         =  $('label[for="inlbacen"]', '#frmCadcta');
    var rDtcnsscr         =  $('label[for="dtcnsscr"]', '#frmCadcta');
    var rDtabtcta         =  $('label[for="dtabtcta"]', '#frmCadcta');
    var rDtadmiss         =  $('label[for="dtadmiss"]', '#frmCadcta');
    var rDtelimin         =  $('label[for="dtelimin"]', '#frmCadcta');
    var rDtdemiss         =  $('label[for="dtdemiss"]', '#frmCadcta');
            
    rDscadpos.addClass('rotulo').css({ 'width': '115px' });
    rFlgiddep.addClass('rotulo-linha').css({ 'width': '110px' });
    rFlblqtal.addClass('rotulo-linha').css({ 'width': '145px' });
    rFlgrestr.addClass('rotulo').css({ 'width': '100px' }); 
    rIndserma.addClass('rotulo-linha').css({ 'width': '130px' }); 
    rFldevchq.addClass('rotulo-linha').css({ 'width': '145px' }); 
    rInlbacen.addClass('rotulo').css({ 'width': '100px' }); 
    rDtcnsscr.addClass('rotulo-linha').css({ 'width': '160px' });
    rDtabtcta.addClass('rotulo-linha').css({ 'width': '120px' });
    rDtadmiss.addClass('rotulo').css({ 'width': '100px' }); 
    rDtelimin.addClass('rotulo-linha').css({ 'width': '135px' });
    rDtdemiss.addClass('rotulo-linha').css({ 'width': '120px' });
    
    //Campos
    var cDscadpos         =  $('#dscadpos', '#frmCadcta');    
    var cFlgiddep         =  $('#flgiddep', '#frmCadcta');
    var cFlblqtal         =  $('#flblqtal', '#frmCadcta');
    var cFlgrestr         =  $('#flgrestr', '#frmCadcta');
    var cIndserma         =  $('#indserma', '#frmCadcta');
    var cFldevchq         =  $('#fldevchq', '#frmCadcta');
    var cInlbacen         =  $('#inlbacen', '#frmCadcta');
    var cDtcnsscr         =  $('#dtcnsscr', '#frmCadcta');
    var cDtabtcta         =  $('#dtabtcta', '#frmCadcta');
    var cDtadmiss         =  $('#dtadmiss', '#frmCadcta');
    var cDtelimin         =  $('#dtelimin', '#frmCadcta');
    var cDtdemiss         =  $('#dtdemiss', '#frmCadcta');
    
    cDscadpos.css('width','50px');
    cFlgiddep.css('width','50px');
    cFlblqtal.css('width','50px');
    cFlgrestr.css('width','80px');
    cIndserma.css('width','50px');
    cFldevchq.css('width','50px');
    cInlbacen.css('width','50px');
    cDtcnsscr.css('width','75px');
    cDtabtcta.css('width','75px');
    cDtadmiss.css('width','75px');
    cDtelimin.css('width','75px');
    cDtdemiss.css('width','75px');
    
    //TALAO
    //rotulo
    var rNmtalttl         =  $('label[for="nmtalttl"]', '#frmCadcta');
    var rQtfoltal         =  $('label[for="qtfoltal"]', '#frmCadcta');
    
    rNmtalttl.addClass('rotulo').css({ 'width': '90px' });
    rQtfoltal.addClass('rotulo-linha').css({ 'width': '125px' });
    
    //Campos
    var cNmtalttl         =  $('#nmtalttl', '#frmCadcta');    
    var cQtfoltal         =  $('#qtfoltal', '#frmCadcta');
    
    cNmtalttl.css({'width':'290px', 'text-transform':'uppercase'});
    cQtfoltal.css('width','75px');

    //RENDAS AUTOMATICAS
    //rotulo
    var rDtrefere         =  $('label[for="dtrefere"]', '#frmCadcta');
    var rVltotmes         =  $('label[for="vltotmes"]', '#frmCadcta');
    
    rDtrefere.css({ 'width': '60px' });
    rVltotmes.css({ 'width': '95px' });

    //Campos    
    var cDtrefere         =  $('#dtrefere', '#frmCadcta');
    var cVltotmes         =  $('#vltotmes', '#frmCadcta');
    var cNmresemp         =  $('#nmresemp', '#frmCadcta');
    
    cDtrefere.css('width','75px');
    cVltotmes.css('width','75px');
    cNmresemp.css('width','130px');
    
    //INF. PROFISSIONAIS
    //rotulo
    var rCdempres         =  $('label[for="cdempres"]', '#frmCadcta');
    var rCdnatopc         =  $('label[for="cdnatopc"]', '#frmCadcta');
    var rCdocpttl         =  $('label[for="cdocpttl"]', '#frmCadcta');
    var rTpcttrab         =  $('label[for="tpcttrab"]', '#frmCadcta');
    
    rCdempres.css({ 'width': '55px' });
    rCdnatopc.css({ 'width': '95px' });
    rCdocpttl.css({ 'width': '55px' });
    rTpcttrab.css({ 'width': '95px' });

    //Campos    
    var cCdempres         =  $('#cdempres', '#frmCadcta');
    var cNmresemp         =  $('#nmresemp', '#frmCadcta');    
    var cCdnatopc         =  $('#cdnatopc', '#frmCadcta');
    var cCdocpttl         =  $('#cdocpttl', '#frmCadcta');
    var cRsocupa          =  $('#rsocupa', '#frmCadcta');    
    var cTpcttrab         =  $('#tpcttrab', '#frmCadcta');
    
    cCdempres.css('width','30px');
    cNmresemp.css('width','200px');
    cCdnatopc.css('width','30px');
    cCdocpttl.css('width','30px');
    cRsocupa.css('width','220px');
    cTpcttrab.css('width','165px');
    

    //INFORMACOES ADICIONAIS 
    //rotulo
    var rNrinfcad         =  $('label[for="nrinfcad"]', '#frmCadcta');
    var rNrpatlvr         =  $('label[for="nrpatlvr"]', '#frmCadcta');
    var rDsinfadi         =  $('label[for="dsinfadi"]', '#frmCadcta');
    var rNrperger         =  $('label[for="nrperger"]', '#frmCadcta');       
    
    rNrinfcad.addClass('rotulo');
    rNrpatlvr.addClass('rotulo');
    rNrperger.addClass('rotulo');
    rDsinfadi.addClass('rotulo');
    
    
    //Campos
    var cNrinfcad         =  $('#nrinfcad', '#frmCadcta');    
    var cNrpatlvr         =  $('#nrpatlvr', '#frmCadcta');
    var cNrperger         =  $('#nrperger', '#frmCadcta');    
    

    cNrinfcad.addClass('codigo pesquisa');
    cNrpatlvr.addClass('codigo pesquisa').css('clear', 'left');
    cNrperger.addClass('codigo pesquisa');
    
    var cDsinfcad         =  $('#dsinfcad', '#frmCadcta');
    var cDspatlvr         =  $('#dspatlvr', '#frmCadcta');    
    var cDsinfadi         =  $('#dsinfadi', '#frmCadcta');
    var cDsperger         =  $('#dsperger', '#frmCadcta');

    cDsinfcad.addClass('descricao').css('width','396px');
    cDspatlvr.addClass('descricao').css('width','522px');
    cDsperger.addClass('descricao').css('width','522px');
    cDsinfadi.addClass('alphanum').css({'width':'580px','height':'54px','float':'left','margin':'3px 0px 3px 3px','padding-right':'1px'});
	
	// Exibir o botão FATCA/CRS apenas se for o primeiro titular selecionado
    if(idseqttl != 1){
        $('#btFatcaCrs').css('display','none');
    }

    //Exibir blocos de dados 
    $('.cnt2-1').css({'display':'block'});
    
    layoutPadrao();
    cNrdctitg.trigger('blur');
    cNrctacns.trigger('blur');
    cNrperger.trigger('blur');

    setaNavegacaoCampos();
    

}

function setaNavegacaoCampos(){
    // Controlar navegacao    
     
	$('#nmctajur', '#frmCabCadcta').unbind('keypress').bind('keypress',function(e) {
		if (e.keyCode == 13 || e.keyCode == 9) {
			$('#cdconsultor', '#frmCadcta').focus();				
            return false;            				
		}
	});
    
    $('#cdconsultor','#frmCadcta').unbind('keypress').bind('keypress',function(e) {		
        if (e.keyCode == 13 || e.keyCode == 9) {        			
            $('#flgiddep', '#frmCadcta').focus();
            return false;            				
		}
	});
    
    // Campo incadpos ficará bloqueado e não será navegável
    /*$('#incadpos','#frmCadcta').unbind('keypress').bind('keypress',function(e) {
		if (e.keyCode == 13 || e.keyCode == 9) {			
			$('#flgiddep','#frmCadcta').focus();
            return false;            				
		}
	});*/
    
    $('#flgiddep','#frmCadcta').unbind('keypress').bind('keypress',function(e) {
		if (e.keyCode == 13 || e.keyCode == 9) {			
			$('#flgrestr','#frmCadcta').focus();
            return false;            				
		}
	});
    
    $('#flgrestr','#frmCadcta').unbind('keypress').bind('keypress',function(e) {		
        if (e.keyCode == 13 || e.keyCode == 9) {        			
			$('#indserma','#frmCadcta').focus();				
		}
	});
    
    $('#indserma','#frmCadcta').unbind('keypress').bind('keypress',function(e) {		
        if (e.keyCode == 13 || e.keyCode == 9) {        			
			$('#fldevchq','#frmCadcta').focus();
            return false;            				
		}
	});
    
    $('#fldevchq','#frmCadcta').unbind('keypress').bind('keypress',function(e) {		
        if (e.keyCode == 13 || e.keyCode == 9) {        			
			$('#inlbacen','#frmCadcta').focus();
            return false;            				
		}
	});
    
     $('#inlbacen','#frmCadcta').unbind('keypress').bind('keypress',function(e) {		
        if (e.keyCode == 13 || e.keyCode == 9) {        			
			$('#nmtalttl','#frmCadcta').focus();
            return false;            
		}
	});
    
    $('#nmtalttl','#frmCadcta').unbind('keypress').bind('keypress',function(e) {		
        if (e.keyCode == 13 || e.keyCode == 9) {        			
			$('#qtfoltal','#frmCadcta').focus();
            return false;            
		}
	});
    
    $('#qtfoltal','#frmCadcta').unbind('keypress').bind('keypress',function(e) {		
        if (e.keyCode == 13 || e.keyCode == 9) {        			
			if (inpessoa == 1) {
                $('#cdempres','#frmCadcta').focus();
                return false;       
            }else {
                $('#nrinfcad','#frmCadcta').focus();
                return false;            
            }
		}
	});
    
    $('#cdempres','#frmCadcta').unbind('keypress').bind('keypress',function(e) {		
        if (e.keyCode == 13 || e.keyCode == 9) {        			
			$('#nrinfcad','#frmCadcta').focus();
            return false;            
		}
	});
    
    $('#nrinfcad','#frmCadcta').unbind('keypress').bind('keypress',function(e) {		
        if (e.keyCode == 13 || e.keyCode == 9) {        			
			$('#nrpatlvr','#frmCadcta').focus();
            return false;            
		}
	});    
    
    // Patrimônio Livre
	$('#nrpatlvr','#frmCadcta').unbind('keypress').bind('keypress',function(e) {
		if (e.keyCode == 13) {			
			if (inpessoa == 1) {
				$('#dsinfadi','#frmCadcta').focus();
			} else {
				$('#nrperger','#frmCadcta').focus();	
			}
		}
        return false; 
	});
    
    $('#nrperger','#frmCadcta').unbind('keypress').bind('keypress',function(e) {		
        if (e.keyCode == 13 || e.keyCode == 9) {        			
			$('#dsinfadi','#frmCadcta').focus();
            return false;     
		}
	});
    

}

/*!
 * ALTERAÇÃO : 007
 * OBJETIVO  : Função para abrir um PDF com a ficha cadastral do titular vigente na tela
 */
function imprimeFichaCadastral(divBloqueio) {

    $('#sidlogin', '#frmCabCadcta').remove();
    $('#tpregist', '#frmCabCadcta').remove();

    $('#frmCabCadcta').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');
    $('#frmCabCadcta').append('<input type="hidden" id="tpregist" name="tpregist" value="' + inpessoa + '" />');

    var action = UrlSite + 'telas/cadcta/ficha_cadastral/imp_fichacadastral.php';
    var callafter = "";

    if (typeof divBloqueio != "undefined") { callafter = "bloqueiaFundo(" + divBloqueio.attr("id") + ");"; }

    carregaImpressaoAyllos("frmCabCadcta", action, callafter);

}


/*!
 * OBJETIVO  : Função para abrir um PDF com a declaracao de pessoa exposta politicamente
 */
function imprimeDeclaracao() {

    $('#sidlogin', '#frmCabCadcta').remove();
    $('#tpregist', '#frmCabCadcta').remove();

    $('#frmCabCadcta').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');
    $('#frmCabCadcta').append('<input type="hidden" id="tpregist" name="tpregist" value="' + inpessoa + '" />');

    $('#tpexposto', '#frmCabCadcta').remove();
    $('#cdocupacao', '#frmCabCadcta').remove();
    $('#cdrelacionamento', '#frmCabCadcta').remove();
    $('#dtinicio', '#frmCabCadcta').remove();
    $('#dttermino', '#frmCabCadcta').remove();
    $('#nmempresa', '#frmCabCadcta').remove();
    $('#nrcnpj_empresa', '#frmCabCadcta').remove();
    $('#nmpolitico', '#frmCabCadcta').remove();
    $('#nrcpf_politico', '#frmCabCadcta').remove();
    $('#inpolexp', '#frmCabCadcta').remove();
    $('#nmextttl', '#frmCabCadcta').remove();
    $('#nrcpfcgc', '#frmCabCadcta').remove();
    $('#rsdocupa', '#frmCabCadcta').remove();
    $('#dsrelacionamento', '#frmCabCadcta').remove();	
	$('#cidade', '#frmCabCadcta').remove();

    var url = UrlSite + "telas/cadcta/ppe/";

    $.ajax({
        type: "POST",
        dataType: "html",
        url: url + "busca_ppe.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            nomeform: 'frmCabCadcta',
            inpessoa: inpessoa,
            flgcadas: flgcadas,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "");
        },
        success: function (response) {
            $("#divRotina").html(response); //append dos campos em frmCabCadcta

            hideMsgAguardo();

            var action = UrlSite + 'telas/cadcta/ppe/imprime_declaracao.php';
            var callafter = "";

            if ($('#inpolexp', '#frmCabCadcta').val() != 2) {
                carregaImpressaoAyllos("frmCabCadcta", action, callafter);
            }
        }
    });
}


// Funcao chamada quando for inclusao de uma nova conta (Tela MATRIC)
function trataCadastramento() {

    // Limpar tela anterior
    $("#divMsgsAlerta").css('visibility', 'hidden');

    // Se vem da MATRIC, abrir 1.era rotina dependendo o tipo de pessoa
    if (inpessoa == 1) {
        //acessaRotina('Dados Pessoais', 'Dados Pessoais', 'dados_pessoais');        
        acessaRotina('IDENTIFICACAO', 'Identificação', 'identificacao_fisica');
    }
    else {
        acessaRotina('IDENTIFICACAO', 'Identificação', 'identificacao_juridica');
    }

}

function retornaImpedimentos(){
    
    // Limpar tela anterior
    $("#divMsgsAlerta").css('visibility', 'hidden');

    acessaRotina('IMPEDIMENTOS DESLIGAMENTO', 'Impedimentos', 'impedimentos_desligamento');
}

function openNewTitular(){
    
    var tpcontas = ['00','1','2','7','8','9','12','13','18' ];    
    var cdtipcta_idx = normalizaNumero($('#cdtipcta_idx', '#frmCabCadcta').val());    
    
    if ( tpcontas.indexOf(cdtipcta_idx) > 0  ){
        hideMsgAguardo();
        showError('error', 'Conta n&atilde;o permite mais de um titular!', 'Alerta - Ayllos', '');
        return false;
    }
    
    
    if (inpessoa >= 2){
        acessaRotina("IDENTIFICACAO","Dados Pessoais","identificacao_juridica", '', 'CI');
    }else{
        //acessaRotina("IDENTIFICACAO","Dados Pessoais","dados_pessoais", '', 'CI');
        acessaRotina('IDENTIFICACAO', 'Identificação', 'identificacao_fisica','','CI');
        
    }
}
function openEditTitular(){
    if (inpessoa >= 2){
        acessaRotina("IDENTIFICACAO","Dados Pessoais","identificacao_juridica", '', 'C');
    }else{
        //acessaRotina("IDENTIFICACAO","Dados Pessoais","dados_pessoais", '', 'C');        
        acessaRotina('IDENTIFICACAO', 'Identificação', 'identificacao_fisica','','C');
    }
}

function openNewRespLeg(){
    acessaRotina("RESPONSAVEL LEGAL","Responsavel Legal","responsavel_legal", '', 'TI');
}

function opeEditRespLeg(){
    acessaRotina("RESPONSAVEL LEGAL","Responsavel Legal","responsavel_legal", '', 'TC');
}

function openNewProcurador(){
    acessaRotina("PROCURADORES","Pessoas de Relacionamento","procuradores", '', 'TI');    
}

function openEditProcurador(){
    acessaRotina("PROCURADORES","Pessoas de Relacionamento","procuradores", '', 'TC');
    
}

function openEditInformativo(){
    if (inpessoa == 1){
        acessaRotina("INFORMATIVOS","Informativos","informativos", '', 'TC');
    }
}

function openNewInformativo(){
    if (inpessoa == 1){
        acessaRotina("INFORMATIVOS","Informativos","informativos", '', 'BI');
    }
}

function openEditPaticipacaoEmpresa(){
    if (inpessoa == 2){
        acessaRotina("PARTICIPACAO","Participacao","participacao", '', 'C');
    }
}

function openNewPaticipacaoEmpresa(){
    if (inpessoa == 2){
        acessaRotina("PARTICIPACAO","Participacao","participacao", '', 'TI');
    }
}

function abreTelaClienteFinanceiro(){
    window.scrollTo(0, 0);
    if (inpessoa == 1){
        acessaRotina("CONTA CORRENTE","Conta Corrente","conta_corrente_pf");
    }else{
        acessaRotina("CONTA CORRENTE","Conta Corrente","conta_corrente");
    }
}

function abreTelaImpressoes(){
    window.scrollTo(0, 0);
    acessaRotina("IMPRESSOES","Impressoes","impressoes", '', 'CA');
}

function abreTelaDesabOperacoes(){
    window.scrollTo(0, 0);
    acessaRotina("DESABILITAR OPERACOES","Desabilitar Operacoes","liberar_bloquear");
}

function abreTelaGrEconomico(){
    window.scrollTo(0, 0);
    acessaRotina("GRUPO ECONOMICO","Grupo Economico","grupo_economico");
}

function abreTelaImunidadeTributaria(){
    window.scrollTo(0, 0);
    if (inpessoa == 2){
        acessaRotina("IMUNIDADE TRIBUTARIA","Imunidade Tributaria","imunidade_tributaria");
    }
}

function abreTelaImpedimentoDesligamento(){
    window.scrollTo(0, 0);
    acessaRotina("IMPEDIMENTOS DESLIGAMENTO","Impedimentos Desligamento","impedimentos_desligamento");
}

function abreTelaOrgaosProtecaoCredito(){
    window.scrollTo(0, 0);
    acessaRotina("ORGAOS PROT. AO CREDITO","Protecao de Credito","protecao_credito");
}

function abreTelaDetalhamento(){
    window.scrollTo(0, 0);
    if (inpessoa == 1){
        acessaRotina("COMERCIAL","Comecial","comercial_pf");
    }
}

function abreTelaDetalheRendas(){
    window.scrollTo(0, 0);
    if (inpessoa == 1){
        acessaRotina("RENDAS AUTOMATICAS","Rendas Automaticas","rendas_automaticas");
    }
}

function abreTelaFatcaCrs(){
    window.scrollTo(0, 0);
    if (inpessoa == 1){
        acessaRotina('FATCA CRS','FATCA/CRS','fatca_crs_pf');
    }else{
        acessaRotina('FATCA CRS','FATCA/CRS','fatca_crs_pj');
    }
}

function mostrarPesquisaConsultor(){
    //Definição dos filtros
    var filtros = "Código Consultor;cdconsultor;50px;S;;S;|Código Operador;cdoperador;50px;S;;S;|Nome Consultor;nmconsultor;200px;S;;S;descricao";
    //Campos que serão exibidos na tela
    var colunas = 'Código;cdconsultor;20%;right|Código;cdoperador;20%;right|Nome Operador;nmconsultor;80%;left';
    //Exibir a pesquisa
    window.scrollTo(0, 0);
    mostraPesquisa("CADCON", "CADCON_CONSULTA_CONSULTORES", "Consultores","100",filtros,colunas);
}

function buscarDescricaoConsultor(cdconsultor){
    
    var bo, procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas, campoDescricao;    
    //Definição dos filtros    
    bo          = "CADCON"
    procedure   = "CADCON_CONSULTA_CONSULTORES";
    titulo      = 'Consultores';
    /*nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
    nritetop    = ( inpessoa == 1 ) ? '8' : '9';*/
    //filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop;
    buscaDescricao(bo,procedure,titulo,'cdconsultor','nmconsultor',cdconsultor,'nmconsultor',filtrosDesc,'frmCadcta','fechaRotina(divRotina);');
    
    fechaRotina(divRotina);
    
    
    
}

function controlaOpeCadcta(operacao){
    
    if ((operacao == 'A' || operacao == 'AV' || operacao == 'VA')&& 
        (flgAlterar_cadcta != '1')) {
        showError('error', 'Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
        return false;
    }
        
    switch (operacao) {
        case 'A':   // Consulta para Alteração
            controlaLayoutCadcta('A');
            break;
        case 'AV':  //alteração para validação
            manterRotinaCadcta(operacao);
            return false;
            break;
        case 'VA':  //salvar alteração
            manterRotinaCadcta(operacao);
            return false;
            break;
        case 'CA':  //cancela atualizacao
            showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','obtemCabecalho(\'\')','','sim.gif','nao.gif');
            return false;
            break;
        case 'OC':  //atualiza o cabecalho e os dados
            obtemCabecalho();
            return false;
            break;
    }
}

function manterRotinaCadcta(operacao) {
    
    // Primerio oculta a mensagem de aguardo
    hideMsgAguardo();
    
    var msgOperacao = '';
    switch (operacao) {
        case 'VE':
            msgOperacao = 'validando tipo de conta';
            break;
        case 'VA':
            msgOperacao = 'salvando altera&ccedil;&atilde;o ';
            break;
        case 'AV':
            msgOperacao = 'validando os dados';
            break;
        default:
            return false;
            break;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, ' + msgOperacao + ' ...');

    nrdrowid = '';
    cdagepac = $('#cdagenci', '#frmCabCadcta').val();
    cdsitdct = $('#cdsitdct', '#frmCabCadcta').val();
    cdtipcta = $('#cdtipcta', '#frmCabCadcta').val();
    nmctajur = $('#nmctajur', '#frmCabCadcta').val();
    cdbcochq = $('#cdbcochq', '#frmCadcta').val();
    nrdctitg = normalizaNumero($('#nrdctitg', '#frmCadcta').val());
    cdagedbb = $('#cdagedbb', '#frmCadcta').val();
    cdbcoitg = $('#cdbcoitg', '#frmCadcta').val();
    cdsecext = $('#cdsecext', '#frmCadcta').val();
    inadimpl = $('#inadimpl', '#frmCadcta').val();
    nrctacns = normalizaNumero($('#nrctacns', '#frmCadcta').val());
    nmtalttl = $('#nmtalttl', '#frmCadcta').val();
    qtfoltal = $('#qtfoltal', '#frmCadcta').val();
    cdempres = $('#cdempres', '#frmCadcta').val();
    nrinfcad = $('#nrinfcad', '#frmCadcta').val();
    nrperger = $('#nrperger', '#frmCadcta').val();    
    nrpatlvr = $('#nrpatlvr', '#frmCadcta').val();
    dsinfadi = $("#dsinfadi",'#frmCadcta').serialize();
    inadimpl = $('#inadimpl', '#frmCadcta').val();
    dtcnsspc = $('#dtcnsspc', '#frmCadcta').val();
    dtdsdspc = $('#dtdsdspc', '#frmCadcta').val();

    flgiddep = $('#flgiddep option:checked', '#frmCadcta').val();
    tpavsdeb = $('#tpavsdeb option:checked', '#frmCadcta').val();
    tpextcta = $('#tpextcta option:checked', '#frmCadcta').val();
    inlbacen = $('#inlbacen option:checked', '#frmCadcta').val();
    flgrestr = $('#flgrestr option:checked', '#frmCadcta').val();
    indserma = $('#indserma option:checked', '#frmCadcta').val();
    idastcjt = $('#idastcjt option:checked', '#frmCadcta').val();
    incadpos = $('#incadpos option:checked', '#frmCadcta').val();
    flblqtal = $('#flblqtal option:checked', '#frmCadcta').val(); 
    fldevchq = $('#fldevchq option:checked', '#frmCadcta').val();

    cdconsultor = $('#cdconsultor', '#frmCadcta').val(); //Melhoria 126

    // Pegar apenas o codigo, sem a descricao
    cdagepac = cdagepac.split(' - ')[0];
    cdtipcta = cdtipcta.split(' - ')[0];
    cdsitdct = cdsitdct.split(' - ')[0];
    
    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cadcta/manter_rotina.php',
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl, nrdrowid: nrdrowid,
            cdagepac: cdagepac, cdsitdct: cdsitdct, cdtipcta: cdtipcta,
            cdbcochq: cdbcochq, nrdctitg: nrdctitg, cdagedbb: cdagedbb,
            cdbcoitg: cdbcoitg, cdsecext: cdsecext, dsinfadi: dsinfadi,
            flgiddep: flgiddep, tpavsdeb: tpavsdeb, tpextcta: tpextcta, 
            flgrestr: flgrestr, inadimpl: inadimpl, inlbacen: inlbacen, 
            flgcreca: flgcreca, operacao: operacao, flgcadas: flgcadas, 
            indserma: indserma, cdconsul: cdconsultor, idastcjt: idastcjt, 
            nrctacns: nrctacns, incadpos: incadpos, flblqtal: flblqtal,
            fldevchq: fldevchq, nmtalttl: nmtalttl, qtfoltal: qtfoltal,
            cdempres: cdempres, cdempres: cdempres, nrinfcad: nrinfcad,
            nrpatlvr: nrpatlvr, nrperger: nrperger, nmctajur: nmctajur, 
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(' + responseError + ')', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {

                if (response != "") {                
                    eval(response);
                }

                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });
}

function controlaPesquisas() {

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas, campoDescricao;
    var camposOrigem = 'cepedct1;endrect1;nrendcom;complcom;cxpotct1;bairoct1;ufresct1;cidadct1';

    bo = 'b1wgen0059.p';

    /*-------------------------------------*/
    /*       CONTROLE DAS PESQUISAS        */
    /*-------------------------------------*/

    // Atribui a classe lupa para os links e desabilita todos
    $('a', '#frmCadcta').addClass('lupa').css('cursor', 'auto');

    // Percorrendo todos os links
    $('a', '#frmCadcta').each(function () {

        if (!$(this).prev().hasClass('campoTelaSemBorda')) { $(this).css('cursor', 'pointer'); }

        $(this).unbind("click").bind("click", (function () {
            if ($(this).prev().hasClass('campoTelaSemBorda')) {
                return false;
            } else {
                campoAnterior = $(this).prev().attr('name');

                // Código Empresa
                if (campoAnterior == 'cdempres') {
                    procedure = 'busca_empresa';
                    titulo = 'Empresa';
                    qtReg = '30';
                    filtrosPesq = 'Cód. Empresa;cdempres;30px;S;0|Nome Empresa;nmresemp;200px;S;';
                    colunas = 'Código;cdempres;20%;right|Empresa;nmresemp;80%;left';
                    mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas);
                    window.scrollTo(0, 0);
                    return false;

                } else if ( campoAnterior == 'nrinfcad' ) {
                    procedure = 'busca_seqrating';
                    titulo      = 'Informa&ccedil;&atilde;o Cadastral';
                    qtReg       = '20';                 
                    nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
                    nritetop    = ( inpessoa == 1 ) ? '4' : '3';
                    filtrosPesq = 'Cód. Inf. Cadastral;nrinfcad;30px;S;0|Inf. Cadastral;dsinfcad;200px;S;|nrtopico;nrtopico;0px;N;'+nrtopico+';N|nritetop;nritetop;0px;N;'+nritetop+';N';
                    colunas     = 'Código;nrseqite;20%;right|Inf. Cadastral;dsseqite;80%;left';
                    mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
                    window.scrollTo(0, 0);
                    return false;   
                
                // Patrimônio Livre
                } else if ( campoAnterior == 'nrpatlvr' ) {
                    procedure = 'busca_seqrating';
                    titulo      = 'Patrimonio Livre';
                    qtReg       = '20';
                    nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
                    nritetop    = ( inpessoa == 1 ) ? '8' : '9';
                    filtrosPesq = 'Cód. Patr. Livre;nrpatlvr;30px;S;0|Patrimonio Livre;dspatlvr;200px;S;|nrtopico;nrtopico;0px;N;'+nrtopico+';N|nritetop;nritetop;0px;N;'+nritetop+';N';
                    colunas     = 'Código;nrseqite;20%;right|Patrimonio Livre;dsseqite;80%;left';
                    mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
                    window.scrollTo(0, 0);
                    return false;

                // Percepção Geral
				} else if ( campoAnterior == 'nrperger' ) {
                    procedure = 'busca_seqrating';
					titulo      = 'Percep&ccedil;&atilde;o Geral';
					qtReg		= '20';
					nrtopico    = '3';
					nritetop    = '11';
					filtrosPesq	= 'Cód. Percepção;nrperger;30px;S;0|Percepção Geral;dsperger;200px;S;|nrtopico;nrtopico;0px;N;'+nrtopico+';N|nritetop;nritetop;0px;N;'+nritetop+';N';
					colunas 	= 'Código;nrseqite;20%;right|Percepção Geral;dsseqite;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
                    window.scrollTo(0, 0);
					return false;
                } else if ( campoAnterior == 'cdconsultor' ) {
                    mostrarPesquisaConsultor();
                }                    
            }
            return false;
        }));
    });
    
    
    $('#cdconsultor','#frmCadcta').unbind('change').bind('change',function() {       
		buscarDescricaoConsultor($(this).val());
		return false;
	});
    
    // Código Empresa
    $('#cdempres','#frmCadcta').unbind('change').bind('change',function() {       
		
        procedure   = 'busca_empresa';
        titulo      = 'Empresa';
        filtrosDesc = '';
        buscaDescricao(bo, procedure, titulo,$(this).attr('name'),'nmresemp',$(this).val(),'nmresemp',filtrosDesc,'frmCadcta');        
        window.scrollTo(0, 0);
        return false;
	});
        
                   
    
    
    
    // Inf. Cadastrais
	$('#nrinfcad','#frmCadcta').unbind('change').bind('change',function() {        
		procedure = 'busca_seqrating';
        titulo      = 'Informa&ccedil;&atilde;o Cadastral';
        qtReg       = '20';                 
        nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
        nritetop    = ( inpessoa == 1 ) ? '4' : '3';
        filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop;      
        buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsinfcad',$(this).val(),'dsseqite',filtrosDesc,'frmCadcta','fechaRotina(divRotina);');        
		return false;
	});
	
	
	// Patrimônio Livre
	$('#nrpatlvr','#frmCadcta').unbind('change').bind('change',function() {
        procedure   = 'busca_seqrating';
		titulo      = 'Patrim&ocirc;nio Livre';
		nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
		nritetop    = ( inpessoa == 1 ) ? '8' : '9';
		filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop;
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dspatlvr',$(this).val(),'dsseqite',filtrosDesc,'frmCadcta','fechaRotina(divRotina);');
		return false;
	});
	
	// Percepção Geral
	$('#nrperger','#frmCadcta').unbind('change').bind('change',function() {
        procedure   = 'busca_seqrating';
		titulo      = 'Percep&ccedil;&atilde;o Geral';
		nrtopico    = '3';
		nritetop    = '11';
		filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop;
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsperger',$(this).val(),'dsseqite',filtrosDesc,'frmCadcta','fechaRotina(divRotina);');
		return false;
	});	
}

function dossieDigidoc() {
	showMsgAguardo('Aguarde...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadcta/dossie_digidoc.php',
		data: {
      nrcpfcgc: normalizaNumero($('#nrcpfcgc','#frmCabCadcta').val()),
      nrdconta: normalizaNumero($('#nrdconta','#frmCabCadcta').val()),
      redirect: 'html_ajax'
    },
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();

			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			$('#divUsoGenerico').html(response);
			exibeRotina($('#divUsoGenerico'));
      $('#divUsoGenerico').css({'margin-top': '170px'});
      $('#divUsoGenerico').css({'width': '400px'});
      $('#divUsoGenerico').centralizaRotinaH();
	  bloqueiaFundo( $('#divUsoGenerico') );
      layoutPadrao();
      window.scrollTo(0, 0);

      return false;
		}
	});
}

function proximaRotina () {
	
	hideMsgAguardo();
	encerraRotina(false);
		
    if (flgcadas == 'M') {
        acessaRotina('IMPRESSOES','Impressões','impressoes');	
    } else {	
        showMsgAguardo('Aguarde, carregando tela ATENDA ...');
        setaParametros('ATENDA','',nrdconta,flgcadas); 	
        direcionaTela('ATENDA','no');
    }
	
}