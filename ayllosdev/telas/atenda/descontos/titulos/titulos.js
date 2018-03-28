/*!
 * FONTE        : titulos.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : Março/2009
 * OBJETIVO     : Biblioteca de funções da subrotina de Descontos de Títulos
 * --------------
 * ALTERAÇÕES   : 22/11/2016
 * --------------
 * 000: [08/06/2010] David     (CECRED) : Adaptação para RATING
 * 000: [22/09/2010] David     (CECRED) : Ajuste para enviar impressoes via email para o PAC Sede
 * 001: [04/05/2010] Rodolpho     (DB1) : Adaptação para o Zoom Endereço e Avalistas genérico
 * 002: [12/09/2011] Adriano   (CECRED) : Ajuste para Lista Negra
 * 003: [10/07/2012] Jorge     (CECRED) : Alterado esquema para impressao em gerarImpressao().
 * 004: [11/07/2012] Lucas     (CECRED) : Lupas para listagem de Linhas de Desconto de Título disponíveis.
 * 005: [05/11/2012] Adriano   (CECRED) : Ajustes referente ao projeto GE.
 * 005: [01/04/2013] Lucas R.  (CECRED) : Ajustes na function controlaLupas.
 * 006: [21/05/2015] Reinert   (CECRED) : Alterado para apresentar mensagem ao realizar inclusao
 *                                        de proposta de novo limite de desconto de titulo para
 *                                        menores nao emancipados.
 * 007: [20/08/2015] Kelvin    (CECRED) : Ajuste feito para não inserir caracters 
 *                                        especiais na observação, conforme solicitado
 *                                        no chamado 315453.
 * 
 * 008: [17/12/2015] Lunelli   (CECRED) : Edição de número do contrato de limite (Lunelli - SD 360072 [M175])
 * 009: [27/06/2016] Jaison/James (CECRED) : Inicializacao da aux_inconfi6.
 * 010: [18/11/2016] Jaison/James (CECRED) : Reinicializa glb_codigoOperadorLiberacao somente quando pede a senha do coordenador.
 * 011: [22/11/2016] Jaison/James (CECRED) : Zerar glb_codigoOperadorLiberacao antes da cdopcolb.
 * 012: [09/03/2017] Adriano    (CECRED): Ajuste devido ao tratamento para validar titulos já inclusos em outro borderô - SD 603451.
 * 013: [26/06/2017] Jonata (RKAM): Ajuste para rotina ser chamada através da tela ATENDA > Produtos ( P364).
 * 014: [13/03/2018] Leonardo Oliveira (GFT): Novos métodos 'acessaValorLimite', 'formataValorLimite', 'renovaValorLimite' e 'converteNumero'.
 * 015: [16/03/2018] Leonardo Oliveira (GFT): Alteração dos métodos 'acessaValorLimite', 'formataValorLimite' e 'renovaValorLimite' para mostrar dialogo de confirmação e condirerar alteração de linha
 * 016: [22/03/2018] Leonardo Oliveira (GFT): Ajustes no fluxo de renovação do limite de desconto de titulos, validação das linhas de credito bloqueadas
 * 017: [28/03/2018] Andre Avila (GFT): Criação do método carregaLimitesTitulosPropostas e carregaDadosAlteraLimiteDscTitPropostas.
 */

var contWin    = 0;  // Variável para contagem do número de janelas abertas para impressos
var nrcontrato = ""; // Variável para armazenar número do contrato de descto selecionado
var nrbordero = ""; // Variável para armazenar número do bordero de descto selecionado
var situacao_limite = ""; // Variável para armazenar a situação do limite atualmente selecionado
var idLinhaB   = 0;  // Variável para armazanar o id da linha que contém o bordero selecionado
var idLinhaL   = 0;  // Variável para armazanar o id da linha que contém o limite selecionado
var dtrating   = 0;  // Data rating (é calculada e alimentada no titulos_limite_incluir.php)
var diaratin   = 0;  // Dia do rating da tabela tt-risco (é alimentada no titulos_limite_incluir.php)
var vlrrisco   = 0;  // Valor do risco (é alimentada no titulos_limite_incluir.php)

// ALTERAÇÃO 001: Criação de variáveis globais 
var nomeForm        = 'frmDadosLimiteDscTit';   // Variável para guardar o nome do formulário corrente
var boAvalista      = 'b1wgen0028.p';           // BO para esta rotina
var procAvalista    = 'carrega_avalista';       // Nome da procedures que busca os avalistas
var operacao        = ''                        // Operação corrente

var strHTML         = ''; // Variável usada na criação da div de alerta do grupo economico.
var strHTML2        = ''; // Variável usada na criação do form onde serão mostradas as mensagens de alerta do grupo economico.  
var dsmetodo        = ''; // Variável usada para manipular o método a ser executado na função encerraMsgsGrupoEconomico.


var aux_inconfir = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi2 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi3 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi4 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi5 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi6 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/

var tpctrlim = "";
var idcobope = "";
var cdageori = "";


//novos
var situacao_analise = ""; // Variável para armazenar a situação da análise atualmente selecionado
var decisao = ""; // Variável para armazenar a decisão atualmente selecionado
var valor_limite = 0; // Variável para armazenar  o valor do limite atualmente selecionado


// ALTERAÇÃO 001: Carrega biblioteca javascript referente aos AVALISTAS
$.getScript(UrlSite + 'includes/avalistas/avalistas.js');

// BORDERÔS DE DESCONTO DE TÍTULOS
// Mostrar o <div> com os borderos de desconto de títulos
function carregaBorderosTitulos() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando border&ocirc;s de desconto de t&iacute;tulos ...");
    
    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            executandoProdutos: executandoProdutos,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $("#divOpcoesDaOpcao2").html(response);
        }               
    });
    return false;
}

// Função para seleção do bordero
function selecionaBorderoTitulos(id, qtBorderos, bordero, contrato) {
    var cor = "";

    // Formata cor da linha da tabela que lista os borderos de descto titulos
    for (var i = 1; i <= qtBorderos; i++) {
        if (cor == "#F4F3F0") {
            cor = "#FFFFFF";
        } else {
            cor = "#F4F3F0";
        }

        // Formata cor da linha
        $("#trBordero" + i).css("background-color", cor);

        if (i == id) {
            // Atribui cor de destaque para bordero selecionado
            $("#trBordero" + id).css("background-color", "#FFB9AB");

            // Armazena número do bordero selecionado
            nrbordero = retiraCaracteres(bordero, "0123456789", true);
            nrcontrato = retiraCaracteres(contrato, "0123456789", true);
            idLinhaB = id;
        }
    }
    return false;
}

/*Mostra lupa de pagadores*/
function mostraPesquisaPagador(nrdconta,nomeForm){
    procedure = 'COBR_PESQUISA_PAGADORES';
    titulo = 'Pagador';
    qtReg = '30';
    filtros = ';nrinssac;;N;;N;;|Nome do Pagador;nmdsacad;280;S;;S;;|Conta;nrdconta;;N;' + normalizaNumero(nrdconta) + ';N;;';
    colunas = 'CPF/CNPJ;nrinssac;30%;center|Nome;nmdsacad;80%;left;|;nrdconta;;;;N';
    mostraPesquisa('COBRAN', procedure, titulo, qtReg, filtros, colunas, nomeForm, '$("#dtvencto","#'+nomeForm+'").focus();bloqueiaFundo(divRotina);');
    // $('#formPesquisa').css('display', 'none');
    return false;
}

/*Busca pagador da conta*/
function buscaPagador(nrdconta,nrinssac,nomeForm) {
    showMsgAguardo('Aguarde, buscando dados da Conta...');  
    
    nrdconta = normalizaNumero(nrdconta);
    nrinssac = normalizaNumero(nrinssac);
            
    $.ajax({        
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/atenda/descontos/manter_rotina.php', 
        data    : { 
                    operacao: 'BUSCAR_PAGADOR',
                    nrdconta: nrdconta,   
                    nrinssac: nrinssac,   
                    frmOpcao: nomeForm,
                    redirect: 'script_ajax'

                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nrinssac\',\''+nomeForm+'\').focus();');
                },
        success : function(response) { 
                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);
                    eval(response);
                }
    }); 
}

function controlaOpcao(){
    $("#dtvencto").focus();
}

// OPÇÕES CONSULTA/EXCLUSÃO/IMPRIMIR/LIBERAÇÃO/ANÁLISE
// Mostrar dados do bordero para fazer
function mostraDadosBorderoDscTit(opcaomostra) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_carregadados.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            cddopcao: opcaomostra,
            nrborder: nrbordero,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao3").html(response);
        }
    });
    return false;
}

// Mostrar dados do bordero para fazer
function mostrarBorderoIncluir() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_incluir.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao3").html(response);
        }
    });
    return false;
}
// FUNCAO PARA INCLUIR O TITULO NO BORDERO (MANDA DA TABELA DE FILTRO PARA A DE SELECIONADOS)
function incluiTituloBordero(td){
    var selecionados = $(".divRegistrosTitulosSelecionados table","#divIncluirBordero");
    var registros = $(".divRegistrosTitulos table","#divIncluirBordero");
    var td = $(td);
    var tr = td.parent();
    var id = tr.attr("id");
    if (selecionados.find("#"+id).length>0){
        showError("error", "T&iacute;tulo j&aacute; incluso na lista de selecionados.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }
    else{
        td.removeClass('corSelecao');
        td.attr("onclick","");
        td.unbind('click').bind('click',function(){
            removeTituloBordero(td);
        });
        td.find("button").text("Remover");
        tr.unbind("click");

        selecionados.append(tr).zebraTabela();
        selecionados.trigger("update");
        registros.trigger("update");
        selecionados.find('> tbody > tr').each(function (i) {
            $(this).unbind('click').bind('click', function () {
                selecionados.zebraTabela(i);
            });
        });
        registros.find('> tbody > tr').each(function (i) {
            $(this).unbind('click').bind('click', function () {
                registros.zebraTabela(i);
            });
        });

        if (typeof arrayLarguraInclusaoBordero != 'undefined') {
            for (var i in arrayLarguraInclusaoBordero) {
                $('td:eq(' + i + ')', selecionados).css('width', arrayLarguraInclusaoBordero[i]);
                $('td:eq(' + i + ')', registros).css('width', arrayLarguraInclusaoBordero[i]);
            }       
        }   
    }
}
//Busca os titulos do bordero
function buscarTitulosBordero() {
    showMsgAguardo('Aguarde, buscando dados da Conta...');  
    var nomeForm = "formPesquisaTitulos";
    var nrdconta = normalizaNumero($("#nrdconta","#"+nomeForm).val());
    var nrctrlim = normalizaNumero($("#nrctrlim","#"+nomeForm).val());
    var nrinssac = normalizaNumero($("#nrinssac","#"+nomeForm).val());
    var dtvencto = $("#dtvencto","#"+nomeForm).val();
    var vltitulo = $("#vltitulo","#"+nomeForm).val();
    var nrnosnum = normalizaNumero($("#nrnosnum","#"+nomeForm).val());

    $.ajax({        
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/atenda/descontos/manter_rotina.php', 
        data    : { 
                    operacao: 'BUSCAR_TITULOS_BORDERO',
                    nrdconta: nrdconta,
                    nrctrlim: nrctrlim,
                    nrinssac: nrinssac,
                    dtvencto: dtvencto,
                    vltitulo: vltitulo,
                    nrnosnum: nrnosnum,
                    frmOpcao: nomeForm,
                    redirect: 'script_ajax'

                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nrinssac\',\''+nomeForm+'\').focus();');
                },
        success : function(response) { 
                    hideMsgAguardo();
                    var registros = $(".divRegistrosTitulos","#divIncluirBordero");
                    registros.parent().find("table").remove();                   //remove o cabecalho para poder regerar o formatatabela
                    registros.html(response);
                    var table = registros.find(">table");
                    var ordemInicial = new Array();
                    table.formataTabela( ordemInicial, arrayLarguraInclusaoBordero, arrayAlinhaInclusaoBordero, '' );
                    bloqueiaFundo(divRotina);
                }
    }); 
}

// FUNCAO QUE REMOVE OS TITULOS DO BORDERO
function removeTituloBordero(td){
    var selecionados = $(".divRegistrosTitulosSelecionados table","#divIncluirBordero");
    td.parent().remove();
    selecionados.zebraTabela();
    selecionados.trigger("update");
    if (typeof arrayLarguraInclusaoBordero != 'undefined') {
        for (var i in arrayLarguraInclusaoBordero) {
            $('td:eq(' + i + ')', registros).css('width', arrayLarguraInclusaoBordero[i]);
        }       
    }   
    selecionados.find('> tbody > tr').each(function (i) {
        $(this).unbind('click').bind('click', function () {
            selecionados.zebraTabela(i);
        });
    });

}
// OPÇÃO CONSULTAR
// Mostrar títulos do bordero
function carregaTitulosBorderoDscTit() { 
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando t&iacute;tulos do border&ocirc; ...");
    
    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_consultar_visualizatitulos.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrborder: nrbordero,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $("#divOpcoesDaOpcao4").html(response);
        }               
    });
    return false;
} 

// OPÇÃO EXCLUIR
// Função para excluir um bordero de desconto de títulos
function excluirBorderoDscTit() {
    // Se não tiver nenhum bordero selecionado
    if (nrbordero == "") {
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, excluindo border&ocirc; ...");

    // Executa script de exclusão através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_excluir.php",
        data: {
            nrdconta: nrdconta,
            nrborder: nrbordero,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
    return false;
}

// OPÇÃO IMPRIMIR
// Função para mostrar a opção Imprimir dos borderos de desconto de títulos
function mostraImprimirBordero(){
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Imprimir ...");
    
    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_imprimir.php",
        dataType: "html",
        data: {
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $("#divOpcoesDaOpcao3").html(response);
        }               
    });
    return false;
}




// LIMITES DE DESCONTO DE TITULOS
function carregaLimitesTitulosPropostas() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando Propostas de limites de desconto de t&iacute;tulos ...");
    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_propostas.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });

    return false;
}


// Carregar os dados para consulta de propostas de limite de desconto de títulos
function carregaDadosAlteraLimiteDscTitPropostas() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados da Proposta de limites de desconto de t&iacute;tulos ...");
    
    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_alterar_propostas.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrcontrato,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $("#divOpcoesDaOpcao3").html(response);
            controlaLupas(nrdconta);
        }               
    });     
}


// Função para verificar se deve ser enviado e-mail ao PAC Sede
function verificaEnvioEmail(idimpres,limorbor) {
    showConfirmacao("Efetuar envio de e-mail para Sede?","Confirma&ccedil;&atilde;o - Ayllos","gerarImpressao(" + idimpres + "," + limorbor + ",'yes');","gerarImpressao(" + idimpres + "," + limorbor + ",'no');","sim.gif","nao.gif");
}

// Função para gerar impressão em PDF
function gerarImpressao(idimpres,limorbor,flgemail,fnfinish) {
    
    if (idimpres == 8) {
        imprimirRating(false,3,nrcontrato,"divOpcoesDaOpcao3",fnfinish);
        return false;       
    }
    
    $("#nrdconta","#frmImprimirDscTit").val(nrdconta);
    $("#idimpres","#frmImprimirDscTit").val(idimpres);
    $("#flgemail","#frmImprimirDscTit").val(flgemail);
    $("#nrctrlim","#frmImprimirDscTit").val(nrcontrato);
    $("#nrborder","#frmImprimirDscTit").val(nrbordero);     
    $("#limorbor","#frmImprimirDscTit").val(limorbor);
    
    var action = $("#frmImprimirDscTit").attr("action");
    var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
    
    carregaImpressaoAyllos("frmImprimirDscTit",action,callafter);
    return false;
}

// OPÇÃO LIBERAR
// Liberar/Analisar bordero de desconto de títulos
function liberaAnalisaBorderoDscTit(opcao, idconfir, idconfi2, idconfi3, idconfi4, idconfi5, idconfi6, indentra, indrestr) {

    var nrcpfcgc = normalizaNumero($("#nrcpfcgc", "#frmCabAtenda").val());
    var mensagem = '';
    var cdopcoan = 0;
    var cdopcolb = 0;

    // Reinicializa somente quando pede a senha
    if (idconfi6 == 51) {
        glb_codigoOperadorLiberacao = 0;
    }

    // Mostra mensagem de aguardo
    if (opcao == "N") {
        mensagem = "analisando";
        cdopcoan = glb_codigoOperadorLiberacao;
    } else {
        mensagem = "liberando";
        cdopcolb = glb_codigoOperadorLiberacao;
    }

    showMsgAguardo("Aguarde, " + mensagem + " o border&ocirc; ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_liberaranalisar.php",
        data: {
            nrdconta: nrdconta,
            nrborder: nrbordero,
            cddopcao: opcao,
            inconfir: idconfir,
            inconfi2: idconfi2,
            inconfi3: idconfi3,
            inconfi4: idconfi4,
            inconfi5: idconfi5,
            inconfi6: idconfi6,
            indentra: indentra,
            indrestr: indrestr,
            nrcpfcgc: nrcpfcgc,
            cdopcoan: cdopcoan,
            cdopcolb: cdopcolb,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
    return false;
}

// LIMITES DE DESCONTO DE TITULOS
// Mostrar o <div> com os limites de desconto de títulos
function carregaLimitesTitulos() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando Contratos de limites de desconto de t&iacute;tulos ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });
    return false;
}

// Função para seleção do limite

function selecionaLimiteTitulos(id,qtLimites,limite,dssitlim, dssitest, insitapr, vlLimite) {

    situacao_analise = dssitest;
    decisao = insitapr;
    valor_limite = vlLimite;

    nrcontrato = null;
    idLinhaL = null;
    situacao_limite = null;

    var cor = "";
    
    // Formata cor da linha da tabela que lista os limites de descto titulos
    for (var i = 1; i <= qtLimites; i++) {      
        if (cor == "#F4F3F0") {
            cor = "#FFFFFF";
        } else {
            cor = "#F4F3F0";
        }       
        
        // Formata cor da linha
        $("#trLimite" + i).css("background-color",cor);
        
        if (i == id) {
            // Atribui cor de destaque para limite selecionado
            $("#trLimite" + id).css("background-color","#FFB9AB");
            // Armazena número do limite selecionado
            nrcontrato = limite;
            idLinhaL = id;
            situacao_limite = dssitlim;

        }
    }
    return false;
}

// Função para mostrar a opção Imprimir dos limites de desconto de títulos
function mostraImprimirLimite() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Imprimir ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_imprimir.php",
        dataType: "html",
        data: {
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao3").html(response);
        }
    });
    return false;
}

// Função para cancelar um limite de desconto de títulos
function cancelaLimiteDscTit() {
    // Se não tiver nenhum limite selecionado
    if (nrcontrato == "") {
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, cancelando limite ...");

    // Executa script de cancelamento através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_cancelar.php",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrcontrato,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
    return false;
}

// Função para excluir um limite de desconto de títulos
function excluirLimiteDscTit() {    
    // Se não tiver nenhum limite selecionado
    if (nrcontrato == "") {
        return false;
    }
    
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, excluindo limite ...");
    
    // Executa script de exclusão através de ajax
    $.ajax({        
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_excluir.php", 
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrcontrato,
            redirect: "script_ajax"
        }, 
        error: function(objAjax,responseError,objExcept) {
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
    return false;
}

// OPÇÃO CONSULTAR
// Carregar os dados para consulta de limite de desconto de títulos
function carregaDadosConsultaLimiteDscTit() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados de desconto de t&iacute;tulos ...");
    
    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_consultar.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrcontrato,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $("#divOpcoesDaOpcao3").html(response);
        }               
    });
    return false;
}

// OPÇÃO INCLUIR
// Carregar os dados para inclusãoo de limite de títulos
function carregaDadosInclusaoLimiteDscTit(inconfir) {

    showMsgAguardo("Aguarde, carregando dados de desconto de t&iacute;tulos ...");
    
    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_incluir.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            inconfir: inconfir,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $("#divOpcoesDaOpcao3").html(response);
            $("#divConteudoOpcao").css('display','none');
            controlaLupas(nrdconta);
        }               
    });
    return false;
}

// OPÇÃO ALTERAR
function mostraTelaAltera() {

    showMsgAguardo('Aguarde, abrindo altera&ccedil;&atilde;o...');

    exibeRotina($('#divUsoGenerico'));

    if (situacao_limite != "EM ESTUDO") {
        showError("error", "N&atilde;o &eacute; poss&iacute;vel alterar contrato. Situa&ccedil;&atilde;o do limite ATIVO.", "Alerta - Ayllos", "fechaRotinaAltera();");
        return false;
    }

    limpaDivGenerica();

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/titulos/titulos_limite_alterar_form.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });

    $('#todaProp', '#frmAltera').focus();
    return false;
}

function confirmaEnvioAnalise(){
    showConfirmacao('Confirma envio da Proposta para An&aacute;lise de Cr&eacute;dito?', 'Confirma&ccedil;&atilde;o - Ayllos', 'validaAnaliseTitulo();', 'return false;', 'sim.gif', 'nao.gif');
}

//OPÇÂO ANALISAR
//Avaliar se é possível executar a ação de analisar
function validaAnaliseTitulo(){

    // pega os valores conforme o status que está na tabela (descomentar quando não estiver usando o mock)
    var insitapr = decisao;
    var dssitest = situacao_analise;
    if (dssitest == 'ANALISE FINALIZADA' && insitapr == 'REJEITADO AUTOMATICAMENTE'){
        showConfirmacao('Confirma envio da Proposta para An&aacute;lise de Cr&eacute;dito? <br> Observa&ccedil;&atildeo: Ser&aacute; necess&aacute;ria aprova&ccedil;&atilde;o de seu Coordenador pois a mesma foi reprovada automaticamente!', 'Confirma&ccedil;&atilde;o - Ayllos', 'pedeSenhaCoordenador(2,\'enviarPropostaAnaliseComLIberacaoCordenador()\',\'divRotina\');', 'controlaOperacao(\'\');', 'sim.gif', 'nao.gif');
    }else{
        enviarPropostaAnalise();
    }
    return false;
}

// funcao que é chamada caso seja aprovado com senha coordenador
function enviarPropostaAnaliseComLIberacaoCordenador(){
    showMsgAguardo("Aguarde, enviando dados para esteira ...");

    var operacao = "ENVIAR_ESTEIRA";

    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/manter_rotina.php",
        dataType: "html",
        data: {
            operacao: operacao,
            nrdconta: nrdconta,
            nrctrlim: nrcontrato,

            redirect: "html_ajax"
        },
        success: function(response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        },  
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
        }
                        
    }); 
    return false;
}


// OPÇÃO ANALISAR
// Carregar os dados para consulta de limite de desconto de títulos
function enviarPropostaAnalise() {
    //alert("Proposta enviada para analise.\nObs.: Função ainda em desenvolvimento!");
    
    showMsgAguardo("Aguarde, enviando proposta para an&aacute;lise ...");

    var operacao = "ENVIAR_ANALISE";

    
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/manter_rotina.php",
        dataType: "html",
        data: {
            operacao: operacao,
            nrdconta: nrdconta,
            nrctrlim: nrcontrato,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
            
        }               
    }); 
}

function efetuarNovoLimite(){
        showConfirmacao(
                        "Deseja confirmar novo limite?",
                        "Confirma&ccedil;&atilde;o - Ayllos",
                        "confirmaNovoLimite(0);",
                        "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))",
                        "sim.gif",
                        "nao.gif");
        return false;
}

function confirmaNovoLimite(cddopera) {
    showMsgAguardo("Aguarde, confirmando novo limite ...");
    
    var operacao = "CONFIMAR_NOVO_LIMITE";
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/manter_rotina.php",
        dataType: "html",
        data: {
            operacao: operacao,
            nrdconta: nrdconta,
            nrctrlim: nrcontrato,
            vllimite: valor_limite,
            cddopera: cddopera,

            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                  eval(response);
                    hideMsgAguardo();
              } catch (error) {
                  hideMsgAguardo();
                  showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
              }
        }           
    });
    return false;
}

function verificaMensagens(mensagem_01,mensagem_02,mensagem_03,mensagem_04,mensagem_05,qtctarel,grupo,vlutiliz,vlexcedi) {

    if (mensagem_01 != ''){

        showConfirmacao(mensagem_01
                       ,"Confirma&ccedil;&atilde;o - Ayllos"
                       ,"verificaMensagens('','" + mensagem_02 + "','" + mensagem_03 + "','" + mensagem_04 + "','"+ mensagem_05 + "','" + qtctarel + "','" + grupo + "','" + vlutiliz + "','" + vlexcedi + "')"
                       ,"telaOperacaoNaoEfetuada()"
                       ,"sim.gif","nao.gif");
    }
    else if (mensagem_02 != ''){

        showConfirmacao('<center>' + (mensagem_02 + "<br>Deseja confirmar esta operação?") + '</center>'
                       ,"Confirma&ccedil;&atilde;o - Ayllos"
                       ,"verificaMensagens('','','" + mensagem_03 + "','" + mensagem_04 + "','" + mensagem_05 + "','" + qtctarel + "','" + grupo + "','" + vlutiliz + "','" + vlexcedi + "')"
                       ,"telaOperacaoNaoEfetuada()"
                       ,"sim.gif","nao.gif");
    }
    else if (mensagem_03 != ''){

        exibeRotina($('#divUsoGenerico'));

        limpaDivGenerica();

        // Carrega conteúdo da opção através do Ajax
        $.ajax({
            type: 'POST',
            dataType: 'html',
            url: UrlSite + 'telas/atenda/descontos/titulos/titulos_tabela_grupo.php',
            data: {
             mensagem_03: mensagem_03,
             mensagem_04: mensagem_04,
                nrdconta: nrdconta,
                qtctarel: qtctarel,
                   grupo: grupo,
                vlutiliz: vlutiliz,
                vlexcedi: vlexcedi,
                redirect: 'html_ajax'
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            },
            success: function (response) {
                $('#divUsoGenerico').html(response);
                layoutPadrao();
                formataMensagem03();
                hideMsgAguardo();
                bloqueiaFundo($('#divUsoGenerico'));
            }
        });
    }
    else if (mensagem_04 != ''){

        showError("inform",mensagem_04,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));verificaMensagens('','','','','"+ mensagem_05 +"','','','','');");
    }
    else if(mensagem_05 != ''){

        showConfirmacao('<center>' + mensagem_05 + '</center>'
                       ,"Confirma&ccedil;&atilde;o - Ayllos"
                       ,"verificaMensagens('','','','', '','','','','')"
                       ,"telaOperacaoNaoEfetuada()"
                       ,"sim.gif","nao.gif");
    }
    else{
        confirmaNovoLimite(1);
    }
    return false;
}


function telaOperacaoNaoEfetuada() {
    fechaRotina($('#divUsoGenerico'),'divRotina');
    showError('inform','Opera&ccedil;&atilde;o n&atilde;o efetuada!','Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
    return false;
}

function formataMensagem03() {

    var Labels = $('label[for="vlutiliz"],label[for="vlexcedi"]','#divGrupoEconomico');

    Labels.css({'width':'120px','height':'22px','float':'left','display':'block'});

    var Inputs = $('input','#divGrupoEconomico');
    Inputs.css({'width':'120px','text-align':'right','float':'left','display':'block'});
    Inputs.desabilitaCampo();

    var divRegistro = $('div.divRegistros','#divGrupoEconomico');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'100px'});
    divRegistro.css({'width':'250px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '230px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';

    var metodoTabela = '';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

    $('#btnContinuar').unbind('click');

    return false;
}

function aceitarRejeicao(confirm) {
    if(!confirm || confirm == 0){
        showConfirmacao(
                        "Deseja rejeitar este limite?",
                        "Confirma&ccedil;&atilde;o - Ayllos",
                        "aceitarRejeicao(1);",
                        "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))",
                        "sim.gif",
                        "nao.gif");
        return false;
    }
    if(confirm == 1){
            showMsgAguardo("Aguarde, confirmando rejei&ccedil;&atilde;o do limite ...");

            var operacao = "ACEITAR_REJEICAO_LIMITE";
            
            $.ajax({        
                type: "POST", 
                url: UrlSite + "telas/atenda/descontos/manter_rotina.php",
                dataType: "html",
                data: {
                    operacao: operacao,
                    nrdconta: nrdconta,
                    nrctrlim: nrcontrato,
                    vllimite: valor_limite,
                    //cddopera: cddopera,

                    redirect: "html_ajax"
                },      
                error: function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
                },
                success: function(response) {
                    try {
                        eval(response);
                        hideMsgAguardo();
                    } catch (error) {
                        hideMsgAguardo();
                        showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                    }
                }           
            }); 
        return false;
    }
}


function exibeAlteraNumero() {

    showMsgAguardo('Aguarde, abrindo altera&ccedil;&atilde;o...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();
    
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/titulos/numero.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "bloqueiaFundo($('#divUsoGenerico'));");
        },
        success: function (response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });

    return false;
}

function fechaRotinaAltera() {

    fechaRotina($('#divUsoGenerico'), $('#divRotina'));
    carregaLimitesTitulos();
    return false;

}

function fechaRotinaDetalhe() {

    fechaRotina($('#divUsoGenerico'), $('#divRotina'));
    carregaLimitesTitulos();
    return false;

}

function limpaDivGenerica() {

    $('#numero').remove();
    $('#altera').remove();

    return false;
}

function confirmaAlteraNrContrato() {
    showConfirmacao("Alterar n&uacute;mero da proposta?", "Confirma&ccedil;&atilde;o - Ayllos", "AlteraNrContrato();", "$('#new_nrctrlim','#frmNumero').focus();blockBackground(parseInt($('#divUsoGenerico').css('z-index')));", "sim.gif", "nao.gif");
}

// Função para alterar apenas o numero de contrato de limite 
function AlteraNrContrato() {

    showMsgAguardo("Aguarde, alterando n&uacute;mero do contrato ...");

    var nrctrant = $('#nrctrlim', '#frmNumero').val().replace(/\./g, "");
    var nrctrlim = $('#new_nrctrlim', '#frmNumero').val().replace(/\./g, "");

    // Valida número do contrato
    if (nrctrlim == "" || nrctrlim == "0" || !validaNumero(nrctrlim, true, 0, 0)) {
        hideMsgAguardo();
        showError("error", "Numero da proposta deve ser diferente de zero.", "Alerta - Ayllos", "$('#new_nrctrlim','#frmNumero').focus();blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
        return false;
    }

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_alterar_numero.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            nrctrant: nrctrant,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao3").html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });
}

// Carregar os dados para consulta de limite de desconto de títulos
function carregaDadosAlteraLimiteDscTit() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados de desconto de t&iacute;tulos ...");
    
    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_alterar.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrcontrato,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $("#divOpcoesDaOpcao3").html(response);
            controlaLupas(nrdconta);
        }               
    });     
}

// Função para gravar dados do limite de desconto de titulo
function gravaLimiteDscTit(cddopcao) {

    var nrcpfcgc = $("#nrcpfcgc","#frmCabAtenda").val().replace(".","").replace(".","").replace("-","").replace("/","");
    
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando " + (cddopcao == "A" ? "altera&ccedil;&atilde;o" : "inclus&atilde;o") + " do limite ...");
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_grava_proposta.php",
        data: {
            nrdconta: nrdconta,
            cddopcao: cddopcao,
            nrcpfcgc: nrcpfcgc,
            
            nrctrlim: $("#nrctrlim","#frmDadosLimiteDscTit").val().replace(/\./g,""),
            vllimite: $("#vllimite","#frmDadosLimiteDscTit").val().replace(/\./g,""),
            dsramati: $("#dsramati","#frmDadosLimiteDscTit").val(),
            vlmedtit: $("#vlmedtit","#frmDadosLimiteDscTit").val().replace(/\./g,""),
            vlfatura: $("#vlfatura","#frmDadosLimiteDscTit").val().replace(/\./g,""),
            vloutras: $("#vloutras","#frmDadosLimiteDscTit").val().replace(/\./g,""),
            vlsalari: $("#vlsalari","#frmDadosLimiteDscTit").val().replace(/\./g,""),
            vlsalcon: $("#vlsalcon","#frmDadosLimiteDscTit").val().replace(/\./g,""),
            dsdbens1: $("#dsdbens1","#frmDadosLimiteDscTit").val(),
            dsdbens2: $("#dsdbens2","#frmDadosLimiteDscTit").val(),            
            cddlinha: $("#cddlinha","#frmDadosLimiteDscTit").val(),
            dsobserv: removeCaracteresInvalidos(removeAcentos($("#dsobserv","#frmDadosLimiteDscTit").val())),
            qtdiavig: $("#qtdiavig","#frmDadosLimiteDscTit").val().replace(/dias/,""),

            // 1o. Avalista 
            nrctaav1: normalizaNumero($("#nrctaav1","#frmDadosLimiteDscTit").val()),
            nmdaval1: $("#nmdaval1","#frmDadosLimiteDscTit").val(),
            nrcpfav1: normalizaNumero($("#nrcpfav1","#frmDadosLimiteDscTit").val()),
            tpdocav1: $("#tpdocav1","#frmDadosLimiteDscTit").val(),
            dsdocav1: $("#dsdocav1","#frmDadosLimiteDscTit").val(),
            nmdcjav1: $("#nmdcjav1","#frmDadosLimiteDscTit").val(),
            cpfcjav1: normalizaNumero($("#cpfcjav1","#frmDadosLimiteDscTit").val()),
            tdccjav1: $("#tdccjav1","#frmDadosLimiteDscTit").val(),
            doccjav1: $("#doccjav1","#frmDadosLimiteDscTit").val(),
            ende1av1: $("#ende1av1","#frmDadosLimiteDscTit").val(),
            ende2av1: $("#ende2av1","#frmDadosLimiteDscTit").val(),
            nrcepav1: normalizaNumero($("#nrcepav1","#frmDadosLimiteDscTit").val()),
            nmcidav1: $("#nmcidav1","#frmDadosLimiteDscTit").val(),
            cdufava1: $("#cdufava1","#frmDadosLimiteDscTit").val(),
            nrfonav1: $("#nrfonav1","#frmDadosLimiteDscTit").val(),
            emailav1: $("#emailav1","#frmDadosLimiteDscTit").val(),
            nrender1: normalizaNumero($("#nrender1","#frmDadosLimiteDscTit").val()),
            complen1: $("#complen1","#frmDadosLimiteDscTit").val(),
            nrcxaps1: normalizaNumero($("#nrcxaps1","#frmDadosLimiteDscTit").val()),

            // 2o. Avalista 
            nrctaav2: normalizaNumero($("#nrctaav2","#frmDadosLimiteDscTit").val()),
            nmdaval2: $("#nmdaval2","#frmDadosLimiteDscTit").val(),
            nrcpfav2: normalizaNumero($("#nrcpfav2","#frmDadosLimiteDscTit").val()),
            tpdocav2: $("#tpdocav2","#frmDadosLimiteDscTit").val(),
            dsdocav2: $("#dsdocav2","#frmDadosLimiteDscTit").val(),
            nmdcjav2: $("#nmdcjav2","#frmDadosLimiteDscTit").val(),
            cpfcjav2: normalizaNumero($("#cpfcjav2","#frmDadosLimiteDscTit").val()),
            tdccjav2: $("#tdccjav2","#frmDadosLimiteDscTit").val(),
            doccjav2: $("#doccjav2","#frmDadosLimiteDscTit").val(),
            ende1av2: $("#ende1av2","#frmDadosLimiteDscTit").val(),
            ende2av2: $("#ende2av2","#frmDadosLimiteDscTit").val(),
            nrcepav2: normalizaNumero($("#nrcepav2","#frmDadosLimiteDscTit").val()),
            nmcidav2: $("#nmcidav2","#frmDadosLimiteDscTit").val(),
            cdufava2: $("#cdufava2","#frmDadosLimiteDscTit").val(),
            nrfonav2: $("#nrfonav2","#frmDadosLimiteDscTit").val(),
            emailav2: $("#emailav2","#frmDadosLimiteDscTit").val(),
            nrender2: normalizaNumero($("#nrender2","#frmDadosLimiteDscTit").val()),
            complen2: $("#complen2","#frmDadosLimiteDscTit").val(),
            nrcxaps2: normalizaNumero($("#nrcxaps2","#frmDadosLimiteDscTit").val()),
            
            // Variáveis globais alimentadas na função validaDadosRating em rating.js 
            nrgarope: nrgarope,
            nrinfcad: nrinfcad,
            nrliquid: nrliquid,
            nrpatlvr: nrpatlvr,         
            vltotsfn: vltotsfn,
            perfatcl: perfatcl,
            nrperger: nrperger, 
            
            redirect: "script_ajax"
        }, 
        error: function(objAjax,responseError,objExcept) {
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

// Validar os dados da proposta de limite
function validaLimiteDscTit(cddopcao,idconfir,idconfi2,idconfi5) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando dados do limite ...");
    
    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_valida_proposta.php",
        data: {
            nrdconta: nrdconta,
            nrctrlim: $("#nrctrlim","#frmDadosLimiteDscTit").val().replace(/\./g,""),
            cddopcao: cddopcao,
            dtrating: dtrating, 
            diaratin: diaratin, 
            vlrrisco: vlrrisco, 
            vllimite: $("#vllimite","#frmDadosLimiteDscTit").val().replace(/\./g,""),
            cddlinha: $("#cddlinha","#frmDadosLimiteDscTit").val(),
            inconfir: idconfir,
            inconfi2: idconfi2,
            inconfi4: 71,
            inconfi5: idconfi5,
            redirect: "html_ajax"
    
        },      
        error: function(objAjax,responseError,objExcept) {
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

// Função para validar o numero de contrato
function validaNrContrato() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando n&uacute;mero do contrato ...");
    
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_incluir_validaconfirma.php",
        data: {
            nrdconta: nrdconta,
            nrctrlim: $("#nrctrlim","#frmDadosLimiteDscTit").val().replace(/\./g,""),

            nrctaav1: 0,
            nrctaav2: 0,
            redirect: "script_ajax"
        }, 
        error: function(objAjax,responseError,objExcept) {
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

/*!
 * OBJETIVO : Função para validar avalistas 
 * ALTERAÇÃO 001: Padronizado o recebimento de valores 
 */
function validarAvalistas() {

    showMsgAguardo('Aguarde, validando dados dos avalistas ...');   
    
    var nrctaav1 = normalizaNumero( $('#nrctaav1','#'+nomeForm).val() );
    var nrcpfav1 = normalizaNumero( $('#nrcpfav1','#'+nomeForm).val() );
    var cpfcjav1 = normalizaNumero( $('#cpfcjav1','#'+nomeForm).val() );
    var nrctaav2 = normalizaNumero( $('#nrctaav2','#'+nomeForm).val() );
    var nrcpfav2 = normalizaNumero( $('#nrcpfav2','#'+nomeForm).val() );
    var cpfcjav2 = normalizaNumero( $('#cpfcjav2','#'+nomeForm).val() );    
    
    var nmdaval1 = trim( $('#nmdaval1','#'+nomeForm).val() );
    var ende1av1 = trim( $('#ende1av1','#'+nomeForm).val() );
    var nrcepav1 = normalizaNumero($("#nrcepav1",'#'+nomeForm).val())
    
    var nmdaval2 = trim( $('#nmdaval2','#'+nomeForm).val() );
    var ende1av2 = trim( $('#ende1av2','#'+nomeForm).val() );
    var nrcepav2 = normalizaNumero($("#nrcepav2",'#'+nomeForm).val())
    
    $.ajax({        
        type: 'POST', 
        url: UrlSite + 'telas/atenda/descontos/titulos/titulos_avalistas_validadados.php',
        data: {
            nrdconta: nrdconta, nrctaav1: nrctaav1, nmdaval1: nmdaval1, 
            nrcpfav1: nrcpfav1, cpfcjav1: cpfcjav1, ende1av1: ende1av1, 
            nrctaav2: nrctaav2, nmdaval2: nmdaval2, nrcpfav2: nrcpfav2, 
            cpfcjav2: cpfcjav2, ende1av2: ende1av2, cddopcao: operacao,
            nrcepav1: nrcepav1, nrcepav2: nrcepav2, redirect: 'script_ajax'
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina);');
        },
        success: function(response) {
            try {
                eval(response);             
            } catch(error) {
                hideMsgAguardo();
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. ' + error.message,'Alerta - Ayllos','bloqueiaFundo(divRotina);');
            }
        }               
    });
}

function controlaLupas(nrdconta) {

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtros, colunas; 
    
    // Nome do Formulário que estamos trabalhando
    var nomeFormulario = 'frmDadosLimiteDscTit';
        
    // Atribui a classe lupa para os links de desabilita todos
    $('a','#'+nomeFormulario).addClass('lupa').css('cursor','auto');
    
    // Percorrendo todos os links
    $('a','#'+nomeFormulario).each( function(i) {
    
        if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
                
        $(this).click( function() {
            if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
                return false;
            } else {                        
                campoAnterior = $(this).prev().attr('name');

                if ( campoAnterior == 'cddlinha' ) {
                    bo          = 'b1wgen0030.p';
                    procedure   = 'lista-linhas-desc-tit';
                    titulo      = 'Linhas de Desconto de T&iacute;tulo';
                    qtReg       = '5';
                    filtros     = 'C&oacutedigo;cddlinha;30px;S;0|Descr;cddlinh2;100px;S;;N;|Taxa;txmensal;100px;S;;N;codigo;|Conta;nrdconta;100px;S;' + nrdconta + ';N;codigo;';
                    colunas     = 'Cod.;cddlinha;15%;right|Descr;dsdlinha;65%;left|Taxa;txmensal;20%;left';
                    mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
                    return false;
                }
            }
        });
    });
    
    $('#cddlinha','#'+nomeFormulario).unbind('change').bind('change',function() {       
                
        //Adiciona filtro por conta para a Procedure
        var filtrosDesc = 'nrdconta|'+ nrdconta;
        
        buscaDescricao('b1wgen0030.p','lista-linhas-desc-tit','Linhas de Desconto de T&iacute;tulo',$(this).attr('name'),'cddlinh2',$(this).val(),'dsdlinha',filtrosDesc,nomeFormulario);
        return false;
    }); 
    
    $('#cddlinha','#'+nomeFormulario).unbind('keypress').bind('keypress',function(e) {      
        
        if(e.keyCode == 13){
        
            //Adiciona filtro por conta para a Procedure
            var filtrosDesc = 'nrdconta|'+ nrdconta;
            
            buscaDescricao('b1wgen0030.p','lista-linhas-desc-tit','Linhas de Desconto de T&iacute;tulo',$(this).attr('name'),'cddlinh2',$(this).val(),'dsdlinha',filtrosDesc,nomeFormulario);
                        
            return false;
            
        }
        
    }); 
    
    
    return false;
}
// Função para fechar div com mensagens de alerta
function encerraMsgsGrupoEconomico(){
    
    // Esconde div
    $("#divMsgsGrupoEconomico").css("visibility","hidden");
    
    $("#divListaMsgsGrupoEconomico").html("&nbsp;");
    
    // Esconde div de bloqueio
    unblockBackground();
    blockBackground(parseInt($("#divRotina").css("z-index")));
    
    eval(dsmetodo);
    
    return false;
    
}

function mostraMsgsGrupoEconomico(){
    
    
    if(strHTML != ''){
        
        // Coloca conteúdo HTML no div
        $("#divListaMsgsGrupoEconomico").html(strHTML);
        $("#divMensagem").html(strHTML2);
                
        // Mostra div 
        $("#divMsgsGrupoEconomico").css("visibility","visible");
        
        exibeRotina($("#divMsgsGrupoEconomico"));
        
        // Esconde mensagem de aguardo
        hideMsgAguardo();
                    
        // Bloqueia conteúdo que está átras do div de mensagens
        blockBackground(parseInt($("#divMsgsGrupoEconomico").css("z-index")));
                
    }
    
    return false;
    
}
function formataGrupoEconomico(){

    var divRegistro = $('div.divRegistros','#divMsgsGrupoEconomico');       
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );
            
    divRegistro.css({'height':'140px'});
    
    $('#divListaMsgsGrupoEconomico').css({'height':'200px'});
    $('#divMensagem').css({'width':'250px'});
    
    var ordemInicial = new Array();
                    
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    
    tabela.formataTabela( ordemInicial, '', arrayAlinha );
    
    return false;
    
}



function buscaGrupoEconomico() {

    showMsgAguardo("Aguarde, verificando grupo econ&ocirc;mico...");
    
    $.ajax({        
        type: 'POST', 
        url: UrlSite + 'telas/atenda/descontos/titulos/busca_grupo_economico.php',
        data: {
            nrdconta: nrdconta, 
            redirect: 'html_ajax'
        },      
        error: function(objAjax,responseError,objExcept) {
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
    
    return false;
    
}

function calcEndividRiscoGrupo(nrdgrupo) {

    showMsgAguardo("Aguarde, calculando endividamento e risco do grupo econ&ocirc;mico...");

    $.ajax({        
        type: 'POST', 
        url: UrlSite + 'telas/atenda/descontos/titulos/calc_endivid_grupo.php',
        data: {
            nrdconta: nrdconta, 
            nrdgrupo: nrdgrupo,
            redirect: 'html_ajax'
        },      
        error: function(objAjax,responseError,objExcept) {
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
    
    return false;
    
}
function removeAcentos(str){
    return str.replace(/[àáâãäå]/g,"a").replace(/[ÀÁÂÃÄÅ]/g,"A").replace(/[ÒÓÔÕÖØ]/g,"O").replace(/[òóôõöø]/g,"o").replace(/[ÈÉÊË]/g,"E").replace(/[èéêë]/g,"e").replace(/[Ç]/g,"C").replace(/[ç]/g,"c").replace(/[ÌÍÎÏ]/g,"I").replace(/[ìíîï]/g,"i").replace(/[ÙÚÛÜ]/g,"U").replace(/[ùúûü]/g,"u").replace(/[ÿ]/g,"y").replace(/[Ñ]/g,"N").replace(/[ñ]/g,"n");
}

function removeCaracteresInvalidos(str){
    return str.replace(/[^A-z0-9\sÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ\!\@\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\>\<]/g,"");                
}

function mostraListagemRestricoes(opcao,idconfir,idconfi2,idconfi3,idconfi4,idconfi5,idconfi6,indentra,indrestr) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando listagem ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_restricoes.php",
        dataType: "html",
        data: {
            cddopcao: opcao,
            inconfir: idconfir,
            inconfi2: idconfi2,
            inconfi3: idconfi3,
            inconfi4: idconfi4,
            inconfi5: idconfi5,
            inconfi6: idconfi6,
            indentra: indentra,
            indrestr: indrestr,
            nrdconta: nrdconta,
            nrborder: nrbordero,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $("#divOpcoesDaOpcao2").html(response);
        }               
    });     
}

//Funcao para formatar a tabela com inconsistências encontradas
function tabela(){

    var divRegistro = $('div.divRegistros', '#divMsgsGenericas');
    var tabela      = $('table',divRegistro );  
    var linha       = $('table > tbody > tr', divRegistro );
            
    $('#divMsgsGenericas').css('width', '400px');
    divRegistro.css({ 'height': '230px', 'width' : '100%'});

    var ordemInicial = new Array();
        ordemInicial = [[1,0]];     
            
    var arrayLargura = new Array(); 
        arrayLargura[0] = '25%';

    var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        
    var metodoTabela = '';
                
    tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,metodoTabela);           
            
    
    $('div.divRegistros', '#divListaMsgsGenericas').css('display', 'block');
        
}

    
// Função para fechar div com mensagens de alerta
function encerraMsgsGenericas(){
    
    // Esconde div
    $("#divMsgsGenericas").css("visibility", "hidden");
    
    $("#divListaMsgsGenericas").html("&nbsp;");
    
    // Esconde div de bloqueio
    unblockBackground();
    blockBackground(parseInt($("#divRotina").css("z-index")));
    
    return false;
    
}

function mostraMsgsGenericas(){
    
    
    if(strHTML != ''){
        
        //Coloca o titulo na tela
        $("#tituloDaTela", "#divMsgsGenericas").html("Inconsist&ecirc;ncias");

        // Coloca conteúdo HTML no div
        $("#divListaMsgsGenericas").html(strHTML);
        
        // Mostra div 
        $("#divMsgsGenericas").css("visibility", "visible");
        
        tabela();

        exibeRotina($("#divMsgsGenericas"));
        
        // Esconde mensagem de aguardo
        hideMsgAguardo();
                    
        // Bloqueia conteúdo que está átras do div de mensagens
        blockBackground(parseInt($("#divMsgsGenericas").css("z-index")));
                
    }
    
    return false;
    
}

function carregaDadosDetalhesProposta(){
    showMsgAguardo("Aguarde, carregando detalhes da proposta ...");
    
    exibeRotina($('#divOpcoesDaOpcao2'));

    //limpaDivGenerica();

    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_detalhes_proposta.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrcontrato,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            //$('#divUsoGenerico').html(response);

            if (response.indexOf('showError("error"') == -1) {
                $('#divOpcoesDaOpcao2').html(response);
                $("#divConteudoOpcao").css('display','none');
                formataDetalhesProposta();
                //layoutPadrao();
                //hideMsgAguardo();
                //bloqueiaFundo($('#divUsoGenerico'));
            } else {
                eval(response);
            }
            return false;
        }               
    }); 
    
}

function formataDetalhesProposta() {
    var divRegistro = $('div.divRegistros', '#divResultadoAciona');
    var tabela = $('table', divRegistro);
    var tabelaHeader = $('table > thead > tr > th', divRegistro);
    var fonteLinha = $('table > tbody > tr > td', divRegistro);

    tabelaHeader.css({'font-size': '11px'});
    fonteLinha.css({'font-size': '11px'});

    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});

    divRegistro.css({'height':'205px', 'width':'930px'});
    
    var ordemInicial = new Array();

    var arrayLargura = new Array();

    arrayLargura[0] = '80px';
    arrayLargura[1] = '110px';
    arrayLargura[2] = '100px';
    arrayLargura[3] = '196px';
    arrayLargura[4] = '120px';
    //arrayLargura[5] = '20px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'left';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
    
    return false;
}

function abreProtocoloAcionamento(dsprotocolo) {

    showMsgAguardo('Aguarde, carregando...');

    // Executa script de através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        //url: UrlSite + 'telas/atenda/emprestimos/form_acionamentos.php',
        url: UrlSite + 'telas/atenda/descontos/titulos/titulos_limite_protocolo_acionamento.php',
        data: {
            dsprotocolo: dsprotocolo,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            hideMsgAguardo();
            if (response.substr(0,4) == "hide") {
                eval(response);
            } else {
                $('#nmarquiv', '#frmImprimir').val(response);
                //var action = UrlSite + 'telas/atenda/emprestimos/form_acionamentos.php';
                var action = UrlSite + 'telas/atenda/descontos/titulos/titulos_limite_protocolo_acionamento.php';
                carregaImpressaoAyllos("frmImprimir",action,"bloqueiaFundo(divRotina);");
            }
            return false;
        }
    });
}


// renovação
function acessaValorLimite(flgvalida) {

    if(!flgvalida){
        flgvalida = 0;
    }
    showMsgAguardo('Aguarde, carregando ...');

    var vllimite = $('#vllimite','#frmTitulos').val();
    var nrctrlim = $('#nrctrlim','#frmTitulos').val();
    var flgstlcr = $('#flgstlcr','#frmTitulos').val() == "yes"?1:0;
    var cddlinha = $('#cddlinha','#frmTitulos').val();
    var dsdlinha = $('#dsdlinha','#frmTitulos').val();

    if(flgvalida == 0 && flgstlcr == 1){
       showConfirmacao(
        "Deseja renovar o Limite de desconto de título atual?",
        "Confirma&ccedil;&atilde;o - Ayllos",
        "acessaValorLimite(1);",
        "hideMsgAguardo();","sim.gif","nao.gif");
        return false; 
    }
    
    if(flgvalida == 0 && flgstlcr == 0){
        showError(
            "inform",
            "Linha de crédito bloqueada, para realizar a operação altere para uma linha liberada ou efetue o desbloqueio da linha",
            "Alerta - Ayllos",
            "acessaValorLimite(1);");
        return false;
    }

    //mostrat rotina valor limite
    exibeRotina($('#divUsoGenerico'));
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/titulos/titulos_valor_limite.php',
        data: {
            vllimite: vllimite,
            nrctrlim: nrctrlim,
            cddlinha: cddlinha,
            flgstlcr: flgstlcr,
            dsdlinha: dsdlinha,
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            //$('#divUsoGenerico').html(response);
            $("#divOpcoesDaOpcao2").html(response);
            //layoutPadrao();
            formataValorLimite();
            $('#vllimite','#frmReLimite').desabilitaCampo();
            hideMsgAguardo();
           // bloqueiaFundo($('#divUsoGenerico'));
        }
    });

    return false;   
}

function formataValorLimite() {
    highlightObjFocus( $('#frmReLimite') );

    var Lvllimite = $('label[for="vllimite"]','#frmReLimite');
    var Lcddlinha = $('label[for="cddlinha"]','#frmReLimite');
    var Ldsdlinha = $('label[for="dsdlinha"]','#frmReLimite');
    
    var Cvllimite = $('#vllimite','#frmReLimite');
    var Ccddlinha = $('#cddlinha','#frmReLimite');
    var Cdsdlinha = $('#dsdlinha','#frmReLimite');

    if(Lcddlinha.length && Ccddlinha.length){

        Lcddlinha.css({'width': '60px'}).addClass('rotulo');
        Ccddlinha.css({'width': '60px'}).addClass('codigo pesquisa');

        Ldsdlinha.css({'width': '60px'}).addClass('rotulo');
        Cdsdlinha.css({'width': '180px'}).addClass('descricao');
        Cdsdlinha.desabilitaCampo();

        //pesquisa
        var campoAnterior = '';
        var qtReg, filtrosPesq, filtrosDesc, colunas;
      
        $('a', '#frmReLimite').ponteiroMouse();
        $('a', '#frmReLimite').each( function(i) {
        
            if ( !$(this).prev().hasClass('campoTelaSemBorda') ) {
                $(this).css('cursor','pointer');
            }
                    
            $(this).click( function() {
                if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
                    return false;
                } else {                        
                    campoAnterior = $(this).prev().attr('name');

                    if ( campoAnterior == 'cddlinha' ) {
                        filtrosPesq = 'Linha;cddlinha;30px;S;|Descrição;dsdlinha;200px;S;|Tipo;tpdlinha;20px;N;' + inpessoa + '|;flgstlcr;;;1;N';
                        colunas = 'Código;cddlinha;11%;right|Descrição;dsdlinha;49%;left|Tipo;dsdtplin;18%;left|Taxa;dsdtxfix;22%;center';
                        fncOnClose = 'cddlinha = $("#cddlinha","#frmNovoLimite").val()';
                        mostraPesquisa('zoom0001',
                        'BUSCALINHAS', 
                        'Linhas de Crédito',
                        '20', 
                        filtrosPesq,
                        colunas,
                        divRotina,
                        fncOnClose);
                    }
                }
            });
        });

        Cdsdlinha.unbind('change').bind('change', function() {
            filtrosDesc = 'tpdlinha|' + inpessoa + ';flgstlcr|1;nriniseq|1;nrregist|30';
            buscaDescricao(
                'zoom0001',
                'BUSCALINHAS',
                'Linhas de Crédito',
                $(this).attr('name'),'dsdlinha',$(this).val(),
                'dsdlinha',
                filtrosDesc,
                'frmNovoLimite');
            return false;
        }).next().unbind('click').bind('click', function () {
            filtrosPesq = 'Linha;cddlinha;30px;S;|Descrição;dsdlinha;200px;S;|Tipo;tpdlinha;20px;N;' + inpessoa + '|;flgstlcr;;;1;N';
            colunas = 'Código;cddlinha;11%;right|Descrição;dsdlinha;49%;left|Tipo;dsdtplin;18%;left|Taxa;dsdtxfix;22%;center';
            fncOnClose = 'cddlinha = $("#cddlinha","#frmNovoLimite").val()';
            mostraPesquisa('zoom0001',
                'BUSCALINHAS', 
                'Linhas de Crédito',
                '20', 
                filtrosPesq,
                colunas,
                divRotina,
                fncOnClose);
            return false;
        });

    }
    
    if(Lvllimite.length && Cvllimite.length){
        Lvllimite.css({'width': '60px'}).addClass('rotulo');
        Cvllimite.css({'width': '100px'});
        Cvllimite.habilitaCampo();
        Cvllimite.focus();

        Cvllimite.unbind('keypress').bind('keypress', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }
            if ( e.keyCode == 13) {
                renovaValorLimite();
                return false;
            }
        });
    }
    $('#btRenovar').unbind('click').bind('click', function(){
        renovaValorLimite();
        return false;
    });

    return false;
}


function renovaValorLimite() {

    showMsgAguardo('Aguarde, efetuando renovacao...');

    var vllimite = converteNumero($('#vllimite','#frmReLimite').val());
    var nrctrlim = $('#nrctrlim','#frmReLimite').val();
    var cddlinha = $('#cddlinha','#frmReLimite').val();

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_renova_limite.php",
        data: {
            nrdconta: nrdconta,
            vllimite: vllimite,
            cddlinha: cddlinha,
            nrctrlim: nrctrlim.replace(/[^0-9]/g,''),
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
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

    return false;
}

function converteNumero (numero){
  return numero.replace('.','').replace(',','.');
}


function mostrarBorderoResumo() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_resumo.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao4").html(response);
        }
    });
    
    return false;
}

function mostrarDetalhesPagador() {
    showMsgAguardo("Aguarde, carregando dados do pagador ...");

    var idtitulo = "";

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_detalhe.php",
        dataType: "html",
        data: {
            idtitulo: idtitulo,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao5").html(response);
        }
    });
    
    return false;
}


function selecionaTituloResumo(idtitulo, nmdsacad){
    console.log("[ID Boleto] - " + idtitulo);
    console.log("[Nome Sacado] - " + nmdsacad);
}