/*!
* FONTE        : cartao_credito.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : Março/2008
 * OBJETIVO     : Biblioteca de funções da rotina Cartão Crédito da tela ATENDA
* --------------
 * ALTERAÇÕES   :
* --------------
 * 000: [04/09/2008] David         (CECRED) : Adaptação para solicitação de 2 via de senha de cartão de crédito
 * 000: [21/11/2008] David	       (CECRED) : Não permitir solicitação de 2via quando número do cartão estiver zerado
 * 000: [23/04/2009] David         (CECRED) : Acerto no acesso as opções Alterar, Canc/Bloq e 2via e opções que alteram a validade do cartão
 * 000: [22/10/2010] David         (CECRED) : Alteração na função acessaOpcaoAba e adaptações para PJ
 * 000: [30/11/2010] Gabriel       (DB1) 	: Transferencia de PAC
* 000: [01/02/2011] Jorge         (CECRED) : Numero do cartao de credito, alterado de 4 campos para 1
 * 000: [23/03/2011] Jorge         (CECRED) : Funções de encerramento do cartao de credito e alterado condicoes na parte de Imprimir
 * 001: [05/04/2011] Rodolpho      (DB1) 	: Adaptação para o Zoom Endereço e Avalistas genérico
 * 001: [08/07/2011] Gabriel       (DB1) 	: Alterado para layout padrão
* 002: [18/07/2011] Guilherme     (Supero) : Incluida funcao para Extrato
* 003: [24/10/2011] Fabricio      (CECRED) : Incluido a funcao alteraDtVencimento()
* 004: [31/10/2011] Adriano       (CECRED) : Ajuste para Lista Negra
 * 005: [15/12/2011] Adriano  	   (CECRED) : Ajuste para a tabela de listagens dos extratos de cartao credito.
 * 006: [04/01/2012] Adriano       (CECRED) : Ajuste na função validaDadosExtrato para validar o periodo do extrato para ano atual + 1
* 007: [03/02/2012] Tiago         (CECRED) : Retirada mascara do campo Titular
* 008: [26/06/2012] Jorge         (CECRED) : Adequacao para submeter para impressao em funcao gerarImpressao() e ImprimeExtratoCartao2(), retirado funcao ImprimeExtratoCartao()
 * 009: [10/07/2012] Guilherme Maba(CECRED) : Ajuste de classe, css e valor para o campo nmextttl, também incluído na postagem para requisição em "../cadastrar_novo_cartao.php".
 * 010: [11/04/2013] Adriano	   (CECRED) : Retirado o parâmetro alertafraude e o tratamento do mesmo na função gerarImpressao.
 * 011: [12/08/2013] Carlos        (CECRED) : Alteração da sigla PAC para PA.
 * 012: [26/03/2014] Jean Michel   (CECRED) : Alteração de validações e novas funções p/ projeto cartões Bancoob.
 * 013: [15/05/2014] James		   (CECRED) : Criação e alteração das funções de alteracao de senha para o cartao com chip.
 * 014: [01/07/2014] Lucas Lunelli (CECRED) : Correção para não realizar validação ao clicar em voltar.
 * 015: [14/07/2014] Lucas Lunelli (CECRED) : Apenas habilitar botão de Exclusão para cartões Bancoob caso situação for 1 (Aprovado)
 * 016: [28/07/2014] Daniel		   (CECRED) : Incluso tratamento no caso de cartao MAESTRO.
 * 017: [20/08/2014] Daniel		   (CECRED) : Incluso ajustes solicitacao cartao pessoa juridica. SoftDesk 188116.
 * 018: [03/09/2014] James		   (CECRED) : Ajustes na alteração de senha do cartão Bancoob.
 * 019: [24/09/2014] Renato-Supero (CECRED) : Adicionar parametro nmempres no cadastro de novos cartões
 * 020: [01/10/2014] Vanessa       (CECRED) : Retirada da opção habilitar para cartões Bancoob
 * 021: [05/10/2014] Oscar         (CECRED) : Colocar AID'S cartão Cabal, fixo até atualizar firmware do PINPAD.
* 022: [20/11/2014] Oscar         (CECRED) : Ajustar tamanho retorno do script de senha.
 * 023: [01/12/2014] James	 	   (CECRED) : Ajuste para trocar a senha do cartão CABAL.
 * 024: [04/12/2014] Renato-Supero (CECRED) : Ajuste na regra de limite para cartão bancoob, afim de permitir limite zero e ajustar valores conforme progress, conforme SD 226052.
 * 025: [15/12/2014] Renato-Supero (CECRED) : Zerar o valor de limite quando for selecionado um Cartão MAESTRO, conforme SD 234067.
 * 026: [22/12/2014] Vanessa 	   (CECRED) : Liberar o campo Forma de Pagamento e obrigar a sua seleção, conforme SD 236434.
 * 027: [24/06/2015] James 	       (CECRED) : Ajuste para quando o cartao de credito estiver com a situacao "Solicitado", fazer a inclusao do cartao de credito. (James) 
 * 028: [03/07/2015] Renato Darosci(CECRED) : Impedir que seja possível informar limite para cartão somente débito
 * 029: [15/07/2015] Carlos        (CECRED) : #308949 Correção de habilitação/desabilitação do campo Lim. Débito e Forma de pagamento, através 
 *                                            da indicação "temDebito", extraída do campo Administradora (Carlos)
 * 030: [29/07/2015] James 		   (CECRED) : Ajuste na entrega do cartao para permitir informar o limite de saque no TAA, e incluir a opcao TAA.
* 031: [07/10/2015] Fabricio      (CECRED) : Setar fixo Debito CC Total como Forma de Pagamento quando for solicitado novo cartao BB - alteraDiaDebito.
*                                            (Chamado 332457)
 * 032: [08/10/2015] James		   (CECRED) : Desenvolvimento do projeto 126.
* 033: [09/10/2015] Gabriel       (RKAM)   : Reformulacao cadastral.
* 034: [14/10/2015] Jean Michel   (CECRED) : Alterado o width dos campo e label nmopetaa PRJ 215.
 * 035: [29/06/2016] Kelvin		   (CECRED)	: Ajuste para que o campo "Plastico da Empresa" seja obrigatório. SD 476461 
* 036: [08/08/2016] Fabricio      (CECRED) : Alterado id do form utilizado na function ImprimeExtratoCartao2 (chamado 477696).
 * 037: [05/10/2016] Kelvin		   (CECRED) : Ajuste feito ao realizar o cadastro de um novo cartão no campo  "habilita funcao debito"
*                                            conforme solicitado no chamado 508426. (Kelvin)
 * 038: [09/12/2016] Kelvin		   (CECRED) : Ajuste realizado conforme solicitado no chamado 574068. 										  
 * 039: [31/08/2017] Lucas Ranghetti(CECRED): Na Função lerCartaoChip, instanciar AIDGet para podermos enviar a Aplicação para a funcao SMC_EMV_TagsGet.
 * 040: [08/11/2017] Douglas       (CECRED) : Adicionado tratamento para não permitir solicitar cartão com número no campo "Empresa do Plástico" (Chamado 781013)
 * 041: [10/11/2017] Tiago         (CECRED) : Adicionado tratamento para não permitir solicitar cartão PF com numero de Identidade maior que 15 posicoes (Chamado 761563)
 * 042: [24/08/2017] Renato Darosci(SUPERO) : Realizar ajustes para incluir a tela de vizualização do histórico de alteração de limites (P360)
 * 043: [14/11/2017] Jonata          (RKAM) : Ajuste para apresentar mensagem que cartão deve ser cancelado através do SIPAGNET. (P364)
 * 044: [01/12/2017] Jonata          (RKAM) : Não permitir acesso a opção de incluir quando conta demitida.
 * 045: [29/03/2018] Lombardi	   (CECRED) : Ajuste para chamar a rotina de senha do coordenador. PRJ366.
 * 046: [13/08/2018] Carlos         (Ailos) : prb0040273 Verificação do estado do objeto oPinpad nas funções lerCartaoChip e fechaConexaoPinpad 
 *                                            para evitar travamento na entrega do cartão.
 * 046: [17/08/2018] Fabricio      (AILOS)  : Tratamento na altera_senha_pinpad() para ignorar a AID (application ID) 'A0000001510000'
 *                                            GP GlobalPlatform (por solicitacao da Cabal) em virtude da geracao dos novos chips - SCTASK0025102. (Fabricio)
 * 048: [22/08/2018] Ranghetti     (AILOS)  : Habilitar botao de impressao para cartoes BB - INC0022408.
 * 049: [12/12/2018] Anderson-Alan (SUPERO) : Criado funções para controle do novo formulário de Assinatura Eletronica com Senha do TA ou Internet. (P432)
 * 050: [26/02/2019] Lucas Henrique (SUPERO): P429 - Inseridos campos de 'Detalhes de Cartões de Crédito Informações do endereço do cooperado'
 * 051: [09/05/2019] Alcemir (Mouts)        : Incluido var inupgrad para passar por requisição (PRB0041641).
 * 052: [26/06/2019] Lucas Ranghetti (AILOS): Na fun validarNovoCartao devemos zerar o nrctrcrd quando for inclusao - PRB0041966. 
*/

var idAnt = 999; // Variável para o controle de cartão selecionado
var corAnt = "";  // Variável para o controle de cor de cartão selecionado
var flgativo = "";  // Variável que indica se cartão PJ está habilitado
var nrctrhcj = 0;   // Variável para armanezar número da proposta para pessoa jurídica
var nrctrcrd = 0;   // Variável para guardar o número de contrato do cartão de crédito
var cdadmcrd = 0;   // Variável para guardar o código da administradora do cartão de crédito
var nrcrcard = 0;   // Variável para guardar o código número do cartão de crédito
var flgcchip = 0;  // Variável para guardar se o cartão eh com Chip ou não.
var flgprovi = 0;
var dtassele;
var dsvlrprm;
var dtinsori;
var flgprcrd = 0;
var nrctrcrd_updown = 0;
var callafterCartaoCredito = '';
var metOpcaoAba = '';
var nomeacao = '';
var bCartaoSituacaoSolicitado = false;

var tipoAssinatura = 'impressa'; // Variável para o controle do tipo de assinatura disponivel, se Eletronica ou Impressa

// Variáveis para armazenar CPF dos representantes informados na opção habilitação
var cpfpriat = "";
var cpfsegat = "";
var cpfterat = "";
var dsdliber = "Op&ccedil;&atilde;o indisponivel. Motivo: Transferencia do PA.";
var iNumeroCPF = '';
var iNumeroCartao = '';
var dDataValidade = '';
var flpurcrd = 0;
var insitcrd = 0;
var idastcjt = 0;

// ALTERAÇÃO 001 - Variáveis globais que são utilizadas pelas funções do script "avalista.js"
var nomeForm = '';                    // Variável para guardar o nome do formulário corrente
var boAvalista = 'b1wgen0028.p';        // BO para esta rotina
var procAvalista = 'carrega_avalista';    // Nome da procedures que busca os avalistas
var operacao = '';
var globalesteira = false;
// Temporaria 
var bTelaAntiga = false;

var Representantes = new Array();
var ObjRepresent = new Object();
var sPortaPinpad = '';
var flagIdprocess = false;
var dsadmcrdList = {
    16: "AILOS DEBITO",
    14: "AILOS PLATINUM",
    13: "AILOS GOLD",
    12: "AILOS CLASSICO",
    11: "AILOS ESSENCIAL",
    15: "AILOS EMPRESAS"
};
var nmEmpresPla = "nome Empresa pl";
var novo_fluxo_envio = false;
var cTipoAcao = {
    NOVO_CARTAO: 1,
    UPGRADE_DOWNGRADE: 2,
    ALTERAR_ENDERECO: 3
};

var cTipoSenha = {
	SUPERVISOR: 'sup',
	COOPERADO: 'cop',
    OPERADOR: 'ope'
};
var cdopelib = 0;

var callbacckReturn = undefined;
var protocolo;
var glbadc = 'n';
var justificativaCartao;
var contigenciaAtiva = false;
var flgBancoob = false;

var flgPrincipal = true;

// Carrega biblioteca javascript referente aos AVALISTAS
$.getScript(UrlSite + 'includes/avalistas/avalistas.js');

/******************************************************************************************************************/
/*****************************************       FUNÇÕES GERAIS       *********************************************/
/******************************************************************************************************************/
// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao) {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde carregando cart&otilde;es de cr&eacute;dito ...");

    callafterCartaoCredito = '';

	// Atribui cor de destaque para aba da opção
    $("#linkAba0").attr("class", "txtBrancoBold");
    $("#imgAbaEsq0").attr("src", UrlImagens + "background/mnu_sle.gif");
    $("#imgAbaDir0").attr("src", UrlImagens + "background/mnu_sld.gif");
    $("#imgAbaCen0").css("background-color", "#969FA9");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/cartao_credito/principal.php",
        data: {
            nrdconta: nrdconta,
            inpessoa: inpessoa,
            sitaucaoDaContaCrm: sitaucaoDaContaCrm,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divConteudoOpcao").html(response);

            if (executandoProdutos) {
                opcaoNovo();
            }
            controlaFoco();
        }
    });
}

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao #divCartoes').each(function () {
        $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");
        $(this).find("#divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > :input[type=image]").last().addClass("LastInputModal");
    });

//Se estiver com foco na classe FluxoNavega
    $(".FluxoNavega").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 13) {
                $(this).click();
            }
        });
    });

    $(".FirstInputModal").focus();
}

function selecionaCartao(nrCtrCartao, nrCartao, cdAdmCartao, id, cor, situacao, FlgcChip, decisaoMotorEsteira, flgproviCartao, dataAssAle, dsVlrprm, dtinSolic, flgtitular) {

    callbacckReturn = "idAnt=0; setTimeout(function(){ selecionaCartao(" + nrCtrCartao + ",'" + nrCartao + "', " + cdAdmCartao + ", '" + id + "', '" + cor + "', '" + situacao + "', '" + FlgcChip + "', '" + decisaoMotorEsteira + "', '" + flgproviCartao + "', '" + dataAssAle + "', '" + dsVlrprm + "', '" + dtinSolic + "', " + flgtitular + "); }, 600);";
    if (id != idAnt) {
        // Armazena o número do contrato/proposta, número cartão, cód adm do cartão selecionado eme variaveis GLOBAIS
        nrctrcrd = nrCtrCartao;
		flgprcrd = flgtitular;
        nrcrcard = nrCartao.replace(/\./g, "");
        cdadmcrd = cdAdmCartao;
        flgcchip = ((FlgcChip == "yes") ? 1 : 0);
        flgprovi = flgproviCartao;
        dtassele = new Date(dataAssAle.replace(/(\d{2})[-/](\d{2})[-/](\d+)/, "$2/$1/$3"));
        dsvlrprm = new Date(dsVlrprm.replace(/(\d{2})[-/](\d{2})[-/](\d+)/, "$2/$1/$3"));
        dtinsori = new Date(dtinSolic.replace(/(\d{2})[-/](\d{2})[-/](\d+)/, "$2/$1/$3"));
        idAnt = id;
        corAnt = cor;
        situacao = situacao.toUpperCase();
		decisaoMotorEsteira = decisaoMotorEsteira.toUpperCase();
		console.log("setando comportamento");
        if (situacao == "SOLIC.") {
            bCartaoSituacaoSolicitado = true;
        } else {
            bCartaoSituacaoSolicitado = false;
        }

        $("#btnupdo").attr("onclick", "").unbind("click").bind('click', function () { return false; });
        $("#btnupdo").css('cursor', 'default');

        $("#btnaltr").attr("onclick", "").unbind("click").bind('click', function () { opcaoAlterar();return false; });
        $("#btnaltr").css('cursor', 'pointer');

        $("#btnreno").attr("onclick", "").unbind("click").bind('click', function () { opcaoRenovar();return false; });
        $("#btnreno").css('cursor', 'pointer');

        $("#btncanc").attr("onclick", "").unbind("click").bind('click', function () { opcaoCancBloq();return false; });
        $("#btncanc").css('cursor', 'pointer');

        $("#btnence").attr("onclick", "").unbind("click").bind('click', function () { opcaoEncerrar();return false; });
        $("#btnence").css('cursor', 'pointer');

        $("#btnexcl").attr("onclick", "").unbind("click").bind('click', function () { opcaoExcluir();return false; });
        $("#btnexcl").css('cursor', 'pointer');

        $("#btnextr").attr("onclick", "").unbind("click").bind('click', function () { opcaoExtrato();return false; }); //NOK
        $("#btnextr").css('cursor', 'pointer');

        //BANCOOB
        if (cdadmcrd > 9 && cdadmcrd < 81) {

            $("#btnaltr").attr("onclick", "").unbind("click").bind('click', function () { return false; });
            $("#btnaltr").css('cursor', 'default');

            $("#btnreno").attr("onclick", "").unbind("click").bind('click', function () { return false; });
            $("#btnreno").css('cursor', 'default');

            $("#btncanc").attr("onclick", "").unbind("click").bind('click', function () { return false; });
            $("#btncanc").css('cursor', 'default');

            $("#btnence").attr("onclick", "").unbind("click").bind('click', function () { return false; });
            $("#btnence").css('cursor', 'default');


            if (!(situacao == "ESTUDO" && decisaoMotorEsteira == 'SEM APROVACAO')) {
                $("#btnexcl").attr("onclick", "").unbind("click").bind('click', function () { return false; });
                $("#btnexcl").css('cursor', 'default');
            }
			// Codigo temporario - Se NAO for piloto deve habilitar para excluir como era antes.
			if (iPiloto == 0 && situacao == "APROV."){
                $("#btnexcl").attr("onclick", "").unbind("click").bind('click', function () { opcaoExcluir();return false; });
                $("#btnexcl").css('cursor', 'default');
			}

			
            if ((cdadmcrd > 10 && cdadmcrd < 17) &&  (situacao == "EM USO" ) && (cdadmcrd != 16 && cdadmcrd != 17)){
				$("#btnalterarLimite").removeAttr("situacao");
                $("#btnalterarLimite").attr("nrcrcard", nrcrcard);
                $("#btnalterarLimite").attr("cdAdmCartao", cdAdmCartao);
            } else if((cdadmcrd == 16 || cdadmcrd == 17) && situacao == "EM USO") {
                $("#btnalterarLimite").removeAttr("situacao");
            } else {
				 $("#btnalterarLimite").attr("situacao", "situacao");
				 
            }
			
			if((cdadmcrd > 10 && cdadmcrd < 17) && situacao == "APROV."){
                $("#btncanc").attr("onclick", "").unbind("click").bind('click', function () { opcaoCancBloq();return false; });
				$("#btncanc").css('cursor', 'pointer');
			}

            $("#btnextr").attr("onclick", "").unbind("click").bind('click', function () { return false; });
            $("#btnextr").css('cursor', 'default');
            
            $("#btnimpr").attr("onclick", "").unbind("click").bind('click', function () { return false; });
            $("#btnimpr").css('cursor', 'default');

            if (situacao == "EM USO" && nrcrcard != 0) {
                $("#btnupdo").attr("onclick", "").unbind("click").bind('click', function () { opcaoAlteraAdm();return false; });
                $("#btnupdo").css('cursor', 'default');
            }
        }else{
			// Habilitar botao de impressao para cartoes BB
            $("#btnimpr").attr("onclick", "").unbind("click").bind('click', function () { opcaoImprimir();return false; });
			$("#btnimpr").css('cursor', 'pointer');
        }


        //Se estiver executando a rotina de impedimentos e o cartão for CECRED deve deixar habilitado, pois ao clicar no botão de canelcar, deverá apresentar alerta
        //informando que o cartão deve ser cancelado através do SIPAGNET.
        if (executandoImpedimentos &&
            (cdadmcrd == 3 ||
                cdadmcrd == 11 ||
                cdadmcrd == 12 ||
                cdadmcrd == 13 ||
                cdadmcrd == 14 ||
                cdadmcrd == 15 ||
                cdadmcrd == 16 ||
                cdadmcrd == 17)) {
            $("#btncanc").attr("onclick", "").unbind("click").bind('click', function () { opcaoCancBloq();return false; });
            $("#btncanc").css('cursor', 'default');

        }

        return true;
    }
    return false;
}

// Função para voltar para o div anterior conforme parâmetros
function voltaDiv(esconder, mostrar, qtdade, novotam) {
    if (novotam == undefined) {
        var tamanho = 220;
    } else {
        var tamanho = novotam;
    }
//$("#divConteudoOpcao").css("height",tamanho);
    if (esconder == 0) {
        $("#divConteudoCartoes").css("display", "block");
        // voltamos a principal
        flgPrincipal = true;

        for (var i = 1; i <= qtdade; i++) {
            $("#divOpcoesDaOpcao" + i).css("display", "none");
        }
    } else {
        $("#divConteudoCartoes").css("display", "none");
        for (var i = 1; i <= qtdade; i++) {
            if (mostrar == i) {
                $("#divOpcoesDaOpcao" + i).css("display", "block");
            } else {
                $("#divOpcoesDaOpcao" + i).css("display", "none");
            }
        }
    }
}

/*!
 * OBJETIVO : Função para validar avalistas 
 * ALTERAÇÃO 001: Padronizado o recebimento de valores 
*/
function validarAvalistas(tipoacao) {

    showMsgAguardo('Aguarde, validando dados dos avalistas ...');

    var nrctaav1 = normalizaNumero($('#nrctaav1', '#' + nomeForm).val());
    var nrcpfav1 = normalizaNumero($('#nrcpfav1', '#' + nomeForm).val());
    var cpfcjav1 = normalizaNumero($('#cpfcjav1', '#' + nomeForm).val());
    var nrctaav2 = normalizaNumero($('#nrctaav2', '#' + nomeForm).val());
    var nrcpfav2 = normalizaNumero($('#nrcpfav2', '#' + nomeForm).val());
    var cpfcjav2 = normalizaNumero($('#cpfcjav2', '#' + nomeForm).val());

    var nmdaval1 = trim($('#nmdaval1', '#' + nomeForm).val());
    var ende1av1 = trim($('#ende1av1', '#' + nomeForm).val());
    var nrcepav1 = normalizaNumero($("#nrcepav1", '#' + nomeForm).val());
    var nmdaval2 = trim($('#nmdaval2', '#' + nomeForm).val());
    var ende1av2 = trim($('#ende1av2', '#' + nomeForm).val());
    var nrcepav2 = normalizaNumero($("#nrcepav2", '#' + nomeForm).val());

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/avalistas_validadados.php",
        data: {
            nrdconta: nrdconta, nrctaav1: nrctaav1, nmdaval1: nmdaval1,
            nrcpfav1: nrcpfav1, cpfcjav1: cpfcjav1, ende1av1: ende1av1,
            nrctaav2: nrctaav2, nmdaval2: nmdaval2, nrcpfav2: nrcpfav2,
            cpfcjav2: cpfcjav2, ende1av2: ende1av2, tipoacao: tipoacao,
            nrcepav1: nrcepav1, nrcepav2: nrcepav2, redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function controlaLayout(nomeForm) {

    $('#' + nomeForm).addClass('formulario');

    if (nomeForm == 'frmEntrega2via') {
        var Lrepsolic = $('label[for="repsolic"]', '#' + nomeForm);
        var Crepsolic = $('#repsolic', '#' + nomeForm);

        var Lcfseqca = $('label[for="cfseqca"]', '#' + nomeForm);
        var Ccfseqca = $('#cfseqca', '#' + nomeForm);

        var Ldtvalida = $('label[for="dtvalida"]', '#' + nomeForm);
        var Cdtvalida = $('#dtvalida', '#' + nomeForm);

        var Lflgimpnp = $('label[for="flgimpnp"]', '#' + nomeForm);
        var Cflgimpnp = $('#flgimpnp', '#' + nomeForm);

        Lrepsolic.addClass('rotulo').css('width', '250px');
        Lcfseqca.addClass('rotulo').css('width', '250px');
        Ldtvalida.addClass('rotulo').css('width', '250px');
        Lflgimpnp.addClass('rotulo').css('width', '250px');

        Crepsolic.css('width', '245px');
        Ccfseqca.css('width', '140px');
        Cdtvalida.css('width', '70px');
        Cflgimpnp.css('width', '70px');

        Crepsolic.habilitaCampo();
        Ccfseqca.habilitaCampo();
        Cdtvalida.habilitaCampo();
        Cflgimpnp.habilitaCampo();

        $("#divDadosEntrega").css("display", "block");

		// Esconde os cartões e avalistas
        $("#divOpcoesDaOpcao2").css("display", "none");
        $("#divDadosAvalistasEntrega").css("display", "none");

        Ccfseqca.setMask("INTEGER", "9999.9999.9999.9999", "", "");
        Cdtvalida.setMask("STRING", "99/9999", "/", "");
        Ccfseqca.focus();

    } else if (nomeForm == 'frmSol2viaSenha') {

        var Lrepsolic = $('label[for="repsolic"]', '#' + nomeForm);
        var Crepsolic = $('#repsolic', '#' + nomeForm);

        Lrepsolic.addClass('rotulo').css('width', '200px');
        Crepsolic.css('width', '250px');
        Crepsolic.habilitaCampo();

    } else if (nomeForm == 'frmSolicitacao') {

        var Lrepsolic = $('label[for="repsolic"]', '#' + nomeForm);
        var Crepsolic = $('#repsolic', '#' + nomeForm);

        var Lslmotivo = $('label[for="slmotivo"]', '#' + nomeForm);
        var Cslmotivo = $('#slmotivo', '#' + nomeForm);

        var Lnmtitcrd = $('label[for="nmtitcrd"]', '#' + nomeForm);
        var Cnmtitcrd = $('#nmtitcrd', '#' + nomeForm);

        Lrepsolic.addClass('rotulo').css('width', '200px');
        Lslmotivo.addClass('rotulo').css('width', '200px');
        Lnmtitcrd.addClass('rotulo').css('width', '185px');

        Crepsolic.css('width', '250px');
        Cslmotivo.css('width', '120px');
        Cnmtitcrd.css('width', '230px');

        Crepsolic.habilitaCampo();
        Cslmotivo.habilitaCampo();
        Cnmtitcrd.habilitaCampo();

        Cslmotivo.trigger("change");

    } else if (nomeForm == 'frmDtVencimento') {

        var Lnrcrcard = $('label[for="nrcrcard"]', '#' + nomeForm);
        var Cnrcrcard = $('#nrcrcard', '#' + nomeForm);

        var Lrepsolic = $('label[for="repsolic"]', '#' + nomeForm);
        var Crepsolic = $('#repsolic', '#' + nomeForm);

        var Ldddebito = $('label[for="dddebito"]', '#' + nomeForm);
        var Cdddebito = $('#dddebito', '#' + nomeForm);

        Lnrcrcard.addClass('rotulo').css('width', '200px');
        Lrepsolic.addClass('rotulo').css('width', '200px');
        Ldddebito.addClass('rotulo').css('width', '200px');

        Cnrcrcard.css('width', '130px');
        Crepsolic.css('width', '250px');
        Cdddebito.css('width', '40px');

        Cnrcrcard.desabilitaCampo();
        Crepsolic.habilitaCampo();
        Cdddebito.habilitaCampo();

    } else if (nomeForm == 'frmValorLimCre') {

        var Lnrcrcard = $('label[for="nrcrcard"]', '#' + nomeForm);
        var Cnrcrcard = $('#nrcrcard', '#' + nomeForm);

        var Lrepsolic = $('label[for="repsolic"]', '#' + nomeForm);
        var Crepsolic = $('#repsolic', '#' + nomeForm);

        var Lvllimcrd = $('label[for="vllimcrd"]', '#' + nomeForm);
        var Cvllimcrd = $('#vllimcrd', '#' + nomeForm);

        var Lflgimpnp = $('label[for="flgimpnp"]', '#' + nomeForm);
        var Cflgimpnp = $('#flgimpnp', '#' + nomeForm);

        Lnrcrcard.addClass('rotulo').css('width', '200px');
        Lrepsolic.addClass('rotulo').css('width', '200px');
        Lvllimcrd.addClass('rotulo').css('width', '200px');
        Lflgimpnp.addClass('rotulo').css('width', '200px');

        Cnrcrcard.css('width', '120px');
        Crepsolic.css('width', '250px');
        Cvllimcrd.css({'width': '80px', 'text-align': 'right'});
        Cflgimpnp.css('width', '80px');

        Cnrcrcard.desabilitaCampo();
        Crepsolic.habilitaCampo();
        Cvllimcrd.habilitaCampo();
        Cflgimpnp.habilitaCampo();

        Cvllimcrd.setMask("DECIMAL", "zzz.zz9,99", "", "");
        Cvllimcrd.focus();

    } else if (nomeForm == 'frmValorLimDeb') {

        var Lnrcrcard = $('label[for="nrcrcard"]', '#' + nomeForm);
        var Cnrcrcard = $('#nrcrcard', '#' + nomeForm);

        var Lvllimdeb = $('label[for="vllimdeb"]', '#' + nomeForm);
        var Cvllimdeb = $('#vllimdeb', '#' + nomeForm);

        Lnrcrcard.addClass('rotulo').css('width', '200px');
        Lvllimdeb.addClass('rotulo').css('width', '200px');

        Cnrcrcard.css('width', '130px');
        Cvllimdeb.css({'width': '80px', 'text-align': 'right'});

        Cnrcrcard.desabilitaCampo();
        Cvllimdeb.habilitaCampo();

    } else if (nomeForm == 'frmCanBlqCartao') {

        var Lrepsolic = $('label[for="repsolic"]', '#' + nomeForm);
        var Crepsolic = $('#repsolic', '#' + nomeForm);

        var Lnrcrcard = $('label[for="nrcrcard"]', '#' + nomeForm);
        var Cnrcrcard = $('#nrcrcard', '#' + nomeForm);

        var Ltpcanblq = $('label[for="tpcanblq"]', '#' + nomeForm);
        var Ctpcanblq = $('#tpcanblq', '#' + nomeForm);


        Lrepsolic.addClass('rotulo').css('width', '200px');
        Lnrcrcard.addClass('rotulo').css('width', '200px');
        Ltpcanblq.addClass('rotulo').css('width', '200px');

        Crepsolic.css('width', '250px');
        Cnrcrcard.css('width', '130px');
        Ctpcanblq.css('width', '110px');

        Cnrcrcard.desabilitaCampo();
        Crepsolic.habilitaCampo();
        Ctpcanblq.habilitaCampo();

    } else if (nomeForm == 'frmDadosCartao') {

        var Lnrcrcard = $('label[for="nrcrcard"]', '#' + nomeForm);
        var Lnmextttl = $('label[for="nmextttl"]', '#' + nomeForm);
        var Lnmtitcrd = $('label[for="nmtitcrd"]', '#' + nomeForm);
        var Lnrcpftit = $('label[for="nrcpftit"]', '#' + nomeForm);
        var Ldtpropos = $('label[for="dtpropos"]', '#' + nomeForm);
        var Ldtsolici = $('label[for="dtsolici"]', '#' + nomeForm);
        var Ldtlibera = $('label[for="dtlibera"]', '#' + nomeForm);
        var Ldtentreg = $('label[for="dtentreg"]', '#' + nomeForm);
        var Ldtcancel = $('label[for="dtcancel"]', '#' + nomeForm);
        var Ldtvalida = $('label[for="dtvalida"]', '#' + nomeForm);
        var Lqtanuida = $('label[for="qtanuida"]', '#' + nomeForm);
        var Lnrctamae = $('label[for="nrctamae"]', '#' + nomeForm);
        var Ldtanucrd = $('label[for="dtanucrd"]', '#' + nomeForm);
        var Lnmoperad = $('label[for="nmoperad"]', '#' + nomeForm);
        var Lnrctrcrd = $('label[for="nrctrcrd"]', '#' + nomeForm);
        var Ldsacetaa = $('label[for="dsacetaa"]', '#' + nomeForm);
        var Ldtacetaa = $('label[for="dtacetaa"]', '#' + nomeForm);
        var Lnmopetaa = $('label[for="nmopetaa"]', '#' + nomeForm);
        var Ldtrejeit = $('label[for="dtrejeit"]', '#' + nomeForm);
        var Lflgprovi  = $('label[for="flgprovi"]', '#' + nomeForm);

        var Cnrcrcard = $('#nrcrcard', '#' + nomeForm);
        var Cdscartao = $('#dscartao', '#' + nomeForm);
        var Cnmextttl = $('#nmextttl', '#' + nomeForm);
        var Cnmtitcrd = $('#nmtitcrd', '#' + nomeForm);
        var Cnrcpftit = $('#nrcpftit', '#' + nomeForm);
        var Cdtpropos = $('#dtpropos', '#' + nomeForm);
        var Cdtsolici = $('#dtsolici', '#' + nomeForm);
        var Cdtlibera = $('#dtlibera', '#' + nomeForm);
        var Cdtentreg = $('#dtentreg', '#' + nomeForm);
        var Cdtcancel = $('#dtcancel', '#' + nomeForm);
        var Cdsmotivo = $('#dsmotivo', '#' + nomeForm);
        var Cdtvalida = $('#dtvalida', '#' + nomeForm);
        var Cqtanuida = $('#qtanuida', '#' + nomeForm);
        var Cnrctamae = $('#nrctamae', '#' + nomeForm);
        var Cds2viasn = $('#ds2viasn', '#' + nomeForm);
        var Cds2viacr = $('#ds2viacr', '#' + nomeForm);
        var Cdsde2via = $('#dsde2via', '#' + nomeForm);
        var Cdtanucrd = $('#dtanucrd', '#' + nomeForm);
        var Cdspaganu = $('#dspaganu', '#' + nomeForm);
        var Cnmoperad = $('#nmoperad', '#' + nomeForm);
        var Cnrctrcrd = $('#nrctrcrd', '#' + nomeForm);
        var Cdsacetaa = $('#dsacetaa', '#' + nomeForm);
        var Cdtacetaa = $('#dtacetaa', '#' + nomeForm);
        var Cnmopetaa = $('#nmopetaa', '#' + nomeForm);
        var Cflgprovi = $('#flgprovi', '#' + nomeForm);


		//Pessoa Física e Jurídica
        var Ldsparent = $('label[for="dsparent"]', '#' + nomeForm);
        var Ldssituac = $('label[for="dssituac"]', '#' + nomeForm);
        var Lvlsalari = $('label[for="vlsalari"]', '#' + nomeForm);
        var Lvloutras = $('label[for="vloutras"]', '#' + nomeForm);
        var Lvlalugue = $('label[for="vlalugue"]', '#' + nomeForm);
        var Lvllimite = $('label[for="vllimite"]', '#' + nomeForm);
        var Ldddebito = $('label[for="dddebito"]', '#' + nomeForm);
        var Lvllimdeb = $('label[for="vllimdeb"]', '#' + nomeForm);
        var Lvlsalcon = $('label[for="vlsalcon"]', '#' + nomeForm);
        var Ldddebant = $('label[for="dddebant"]', '#' + nomeForm);
        var Lnrcctitg = $('label[for="nrcctitg"]', '#' + nomeForm);
        var Ldsgraupr = $('label[for="dsgraupr"]', '#' + nomeForm);
        var Lflgdebit = $('label[for="flgdebit"]', '#' + nomeForm);
        var Ldsdpagto = $('label[for="dsdpagto"]', '#' + nomeForm);

        var Cdsparent = $('#dsparent', '#' + nomeForm);
        var Cdssituac = $('#dssituac', '#' + nomeForm);
        var Cvlsalari = $('#vlsalari', '#' + nomeForm);
        var Cvlsalcon = $('#vlsalcon', '#' + nomeForm);
        var Cvloutras = $('#vloutras', '#' + nomeForm);
        var Cvlalugue = $('#vlalugue', '#' + nomeForm);
        var Cvllimite = $('#vllimite', '#' + nomeForm);
        var Cdddebito = $('#dddebito', '#' + nomeForm);
        var Cvllimdeb = $('#vllimdeb', '#' + nomeForm);
        var Cdddebant = $('#dddebant', '#' + nomeForm);
        var Cdtrejeit = $('#dtrejeit', '#' + nomeForm);
        var Cnrcctitg = $('#nrcctitg', '#' + nomeForm);
        var Cdsgraupr = $('#dsgraupr', '#' + nomeForm);
        var Cdsdpagto = $('#dsdpagto', '#' + nomeForm);

        var cTodos = $('input', '#' + nomeForm);

		//Campos Endereço entrega Cartão
		var Ldstipend = $('label[for="dstipend"]', '#' + nomeForm);
		var Ldsendere = $('label[for="dsendere"]', '#' + nomeForm);
		var Ldsbairro = $('label[for="dsbairro"]', '#' + nomeForm);
		var Ldscidade = $('label[for="dscidade"]', '#' + nomeForm);
		var Lnrcepend = $('label[for="nrcepend"]', '#' + nomeForm);
		var Ldsufende = $('label[for="dsufende"]', '#' + nomeForm);
		
		var Cdstipend = $('#dstipend', '#' + nomeForm);
		var Cdsendere = $('#dsendere', '#' + nomeForm);
		var Cdsbairro = $('#dsbairro', '#' + nomeForm);
		var Cdscidade = $('#dscidade', '#' + nomeForm);
		var Cnrcepend = $('#nrcepend', '#' + nomeForm);
		var Cdsufende = $('#dsufende', '#' + nomeForm);

		//Controle dos labels que são comuns para pessoa Fis. e Jur.
        Lnrcrcard.addClass('rotulo').css('width', '74px');
        Lnmextttl.addClass('rotulo').css('width', '74px');
        Lnmtitcrd.addClass('rotulo').css('width', '105px');
        Ldtpropos.addClass('rotulo').css('width', '74px');
        Ldtentreg.addClass('rotulo').css('width', '74px');
        Ldtvalida.addClass('rotulo').css('width', '99px');
        Lflgdebit.addClass('rotulo-linha').css('width', '125px');
        Ldsdpagto.addClass('rotulo-linha').css('width', '82px');
        Lnrctamae.addClass('rotulo').css('width', '68px');
        Lnrcctitg.addClass('rotulo').css('width', '99px');
        Ldtanucrd.addClass('rotulo').css('width', '150px');
        Lnmoperad.addClass('rotulo').css('width', '78px');
        Ldsacetaa.addClass('rotulo').css('width', '76px');
        Lnrcpftit.css('width', '90px');
        Ldtsolici.css('width', '95px');
        Ldtlibera.css('width', '85px');
        Ldtcancel.css('width', '95px');
        Lqtanuida.addClass('rotulo-linha').css('width', '113px');
        Lnrctrcrd.css('width', '62px');
        Ldtacetaa.css('width', '151px');
        Lnmopetaa.css('width', '120px');
        Ldsgraupr.css('width', '90px');
        Lflgprovi.css({'width': '120px', 'text-align': 'right'});

        Ldstipend.addClass('rotulo').css('width', '55px');
		Ldsendere.addClass('rotulo').css('width', '55px');
		Ldsbairro.addClass('rotulo').css('width', '55px');
		Ldscidade.addClass('rotulo-linha').css('width', '55px');
		Lnrcepend.addClass('rotulo').css('width', '55px');
		Ldsufende.addClass('rotulo-linha').css('width', '250px');
		
        Cnrcctitg.css({'width': '140px'});
        Cnrcrcard.css({'width': '120px'});
        Cdscartao.css({'width': '300px'});
        Cnmextttl.css({'width': '200px'});
        Cnmtitcrd.css({'width': '169px'});
        Cnrcpftit.css({'width': '130px', 'text-align': 'right'});
        Cdtpropos.css({'width': '70px', 'text-align': 'right'});
        Cdtsolici.css({'width': '92px', 'text-align': 'right'});
        Cdtlibera.css({'width': '75px', 'text-align': 'right'});
        Cdtentreg.css({'width': '70px', 'text-align': 'right'});
        Cdtcancel.css({'width': '92px', 'text-align': 'right'});
        Cdsmotivo.css({'width': '160px'});
        Cdtvalida.css({'width': '70px', 'text-align': 'right'});
        Cqtanuida.css({'width': '75px'});
        Cnrctamae.css({'width': '140px'});
        Cds2viasn.css({'width': '255px'});
        Cds2viacr.css({'width': '239px'});
        Cdsde2via.css({'width': '255px'});
        Cdtanucrd.css({'width': '70px'});
        Cdspaganu.css({'width': '80px', 'text-align': 'right'});
        Cnmoperad.css({'width': '279px'});
        Cnrctrcrd.css({'width': '75px', 'text-align': 'right'});
        Cdsacetaa.css({'width': '193px'});
        Cdtacetaa.css({'width': '75px', 'text-align': 'right'});
        Cnmopetaa.css({'width': '378px'});
        Cdsgraupr.css({'width': '130px'});
        Cdsdpagto.css({'width': '96px'});
        Cflgprovi.css({'width': '120px'});

		Cdstipend.css({'width': '200px'});
        Cdsendere.css({'width': '456px'});
		Cdsbairro.css({'width': '200px'});
		Cdscidade.css({'width': '195px'});
		Cnrcepend.css({'width': '100px'});
		Cdsufende.css({'width': '100px'});
		
		//Pessoa Física e Jurídica
        Ldsparent.addClass('rotulo').css('width', '74px');
        Lvlalugue.addClass('rotulo').css('width', '74px');

        Lvlsalari.addClass('rotulo').css('width', '74px');
        Ldssituac.css('width', '90px');
        Lvlsalcon.css('width', '95px');
        Lvloutras.css('width', '85px');
        Ldddebito.css('width', '105px');
        Lvllimite.css('width', '95px');

        Ldtrejeit.addClass('rotulo').css('width', '74px');
        Lvllimdeb.addClass('rotulo-linha').css('width', '92px');
        Ldddebant.addClass('rotulo-linha').css('width', '102px');

        Cdsparent.css({'width': '200px'});
        Cdssituac.css({'width': '130px', 'text-align': 'right'});
        Cvlsalari.css({'width': '70px', 'text-align': 'right'});
        Cvlsalcon.css({'width': '92px', 'text-align': 'right'});
        Cvloutras.css({'width': '75px', 'text-align': 'right'});
        Cvlalugue.css({'width': '70px', 'text-align': 'right'});
        Cvllimite.css({'width': '92px', 'text-align': 'right'});
        Cdddebito.css({'width': '55px', 'text-align': 'right'});

        Cdtrejeit.css({'width': '70px', 'text-align': 'right'});
        Cvllimdeb.css({'width': '92px', 'text-align': 'right'});
        Cdddebant.css({'width': '55px', 'text-align': 'right'});

        cTodos.desabilitaCampo();

        if (inpessoa == 2) {

            Ldsparent.css('width', '199px');
            Cdsparent.css({'width': '298px'});
            Ldssituac.addClass('rotulo').css('width', '74px');
            Cdssituac.css({'width': '70px', 'text-align': 'right'});

        }

        if ($.browser.msie) {
            Cds2viacr.css({'width': '236px'});
        }

    } else if (nomeForm == 'formUltDebitos') {

		
        var divRegistro = $('div.divRegistros', '#' + nomeForm);
        var tabela = $('table', divRegistro);

        divRegistro.css('height', '150px');

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        arrayLargura[0] = '100px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'right';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    } else if (nomeForm == 'frmEncCartao') {

        var Lrepsolic = $('label[for="repsolic"]', '#' + nomeForm);
        var Lnrcrcard = $('label[for="nrcrcard"]', '#' + nomeForm);
        var Ltpencerr = $('label[for="tpencerr"]', '#' + nomeForm);

        var Crepsolic = $('#repsolic', '#' + nomeForm);
        var Cnrcrcard = $('#nrcrcard', '#' + nomeForm);
        var Ctpencerr = $('#tpencerr', '#' + nomeForm);

        Lrepsolic.addClass('rotulo').css('width', '200px');
        Lnrcrcard.addClass('rotulo').css('width', '200px');
        Ltpencerr.addClass('rotulo').css('width', '200px');

        Crepsolic.css({'width': '250px'});
        Cnrcrcard.css({'width': '130px'});
        Ctpencerr.css({'width': '130px'});

        Cnrcrcard.desabilitaCampo();
        Crepsolic.habilitaCampo();
        Ctpencerr.habilitaCampo();

    } else if (nomeForm == 'frmEntregarDados') {

        var Lrepsolic = $('label[for="repsolic"]', '#' + nomeForm);
        var Lcfseqca = $('label[for="cfseqca"]', '#' + nomeForm);
        var Ldtvalida = $('label[for="dtvalida"]', '#' + nomeForm);

        var Crepsolic = $('#repsolic', '#' + nomeForm);
        var Ccfseqca = $('#cfseqca', '#' + nomeForm);
        var Cdtvalida = $('#dtvalida', '#' + nomeForm);

        Lrepsolic.addClass('rotulo').css('width', '200px');
        Lcfseqca.addClass('rotulo').css('width', '200px');
        Ldtvalida.addClass('rotulo').css('width', '200px');

        Crepsolic.css({'width': '250px'});
        Ccfseqca.css({'width': '140px'});
        Cdtvalida.css({'width': '74px'});

        Crepsolic.habilitaCampo();
        Ccfseqca.habilitaCampo();
        Cdtvalida.habilitaCampo();

        Cdtvalida.setMask("STRING", "99/9999", "/", "");
        Ccfseqca.setMask("INTEGER", "9999.9999.9999.9999", "", "");
        Ccfseqca.focus();

    } else if (nomeForm == 'frmConfirmaDados') {

        var Lcfseqca = $('label[for="cfseqca"]', '#' + nomeForm);
        var Ccfseqca = $('#cfseqca', '#' + nomeForm);

        Lcfseqca.addClass('rotulo').css('width', '200px');
        Ccfseqca.css({'width': '140px'});

        Ccfseqca.habilitaCampo();

        Ccfseqca.setMask("INTEGER", "9999.9999.9999.9999", "", "");
        Ccfseqca.focus();

    } else if (nomeForm == 'frmHabilitaCartao') {

        var Lnmprimtl = $('label[for="nmprimtl"]', '#' + nomeForm);
        var Lnrcpfcgc = $('label[for="nrcpfcgc"]', '#' + nomeForm);
        var Lflgativo = $('label[for="flgativo"]', '#' + nomeForm);
        var Lvllimglb = $('label[for="vllimglb"]', '#' + nomeForm);
        var Lnrcpfpri = $('label[for="nrcpfpri"]', '#' + nomeForm);
        var Lnmpespri = $('label[for="nmpespri"]', '#' + nomeForm);
        var Ldtnaspri = $('label[for="dtnaspri"]', '#' + nomeForm);
        var Lnrcpfseg = $('label[for="nrcpfseg"]', '#' + nomeForm);
        var Lnmpesseg = $('label[for="nmpesseg"]', '#' + nomeForm);
        var Ldtnasseg = $('label[for="dtnasseg"]', '#' + nomeForm);
        var Lnrcpfter = $('label[for="nrcpfter"]', '#' + nomeForm);
        var Lnmpester = $('label[for="nmpester"]', '#' + nomeForm);
        var Ldtnaster = $('label[for="dtnaster"]', '#' + nomeForm);

        var Cnmprimtl = $('#nmprimtl', '#' + nomeForm);
        var Cnrcpfcgc = $('#nrcpfcgc', '#' + nomeForm);
        var Cflgativo = $('#flgativo', '#' + nomeForm);
        var Cvllimglb = $('#vllimglb', '#' + nomeForm);
        var Cnrcpfpri = $('#nrcpfpri', '#' + nomeForm);
        var Cnmpespri = $('#nmpespri', '#' + nomeForm);
        var Cdtnaspri = $('#dtnaspri', '#' + nomeForm);
        var Cnrcpfseg = $('#nrcpfseg', '#' + nomeForm);
        var Cnmpesseg = $('#nmpesseg', '#' + nomeForm);
        var Cdtnasseg = $('#dtnasseg', '#' + nomeForm);
        var Cnrcpfter = $('#nrcpfter', '#' + nomeForm);
        var Cnmpester = $('#nmpester', '#' + nomeForm);
        var Cdtnaster = $('#dtnaster', '#' + nomeForm);

        Lnmprimtl.addClass('rotulo').css('width', '90px');
        Lnrcpfcgc.addClass('rotulo').css('width', '90px');
        Lflgativo.addClass('rotulo').css('width', '90px');
        Lvllimglb.css('width', '257px');
        Lnrcpfpri.addClass('rotulo').css('width', '90px');
        Lnmpespri.addClass('rotulo').css('width', '90px');
        Ldtnaspri.css('width', '100px');
        Lnrcpfseg.addClass('rotulo').css('width', '90px');
        Lnmpesseg.addClass('rotulo').css('width', '90px');
        Ldtnasseg.css('width', '100px');
        Lnrcpfter.addClass('rotulo').css('width', '90px');
        Lnmpester.addClass('rotulo').css('width', '90px');
        Ldtnaster.css('width', '100px');

        Cnmprimtl.css({'width': '405px'});
        Cnrcpfcgc.css({'width': '110px', 'text-align': 'right'});
        Cflgativo.css({'width': '50px'});
        Cvllimglb.css({'width': '95px', 'text-align': 'right'});
        Cnrcpfpri.css({'width': '90px', 'text-align': 'right'});
        Cnmpespri.css({'width': '230px'});
        Cdtnaspri.css({'width': '72px'});
        Cnrcpfseg.css({'width': '90px', 'text-align': 'right'});
        Cnmpesseg.css({'width': '230px'});
        Cdtnasseg.css({'width': '72px'});
        Cnrcpfter.css({'width': '90px', 'text-align': 'right'});
        Cnmpester.css({'width': '230px'});
        Cdtnaster.css({'width': '72px'});

    } else if (nomeForm == 'frmNovoCartao') {

        var Ldsgraupr = $('label[for="dsgraupr"]', '#' + nomeForm);
        var Lnrcpfcgc = $('label[for="nrcpfcgc"]', '#' + nomeForm);
        var Lnmextttl = $('label[for="nmextttl"]', '#' + nomeForm);
        var Lnmtitcrd = $('label[for="nmtitcrd"]', '#' + nomeForm);
        var Lnrdoccrd = $('label[for="nrdoccrd"]', '#' + nomeForm);
        var Ldtnasccr = $('label[for="dtnasccr"]', '#' + nomeForm);
        var Ldsadmcrd = $('label[for="dsadmcrd"]', '#' + nomeForm);
        var Ldscartao = $('label[for="dscartao"]', '#' + nomeForm);
        var Ldddebito = $('label[for="dddebito"]', '#' + nomeForm);
        var Lvlsalari = $('label[for="vlsalari"]', '#' + nomeForm);
        var Lvlsalcon = $('label[for="vlsalcon"]', '#' + nomeForm);
        var Lvloutras = $('label[for="vloutras"]', '#' + nomeForm);
        var Lvlalugue = $('label[for="vlalugue"]', '#' + nomeForm);
        var Lvllimpro = $('label[for="vllimpro"]', '#' + nomeForm);
        var Lflgdebit = $('label[for="flgdebit"]', '#' + nomeForm);
        var Lflgimpnp = $('label[for="flgimpnp"]', '#' + nomeForm);
        var Lvllimdeb = $('label[for="vllimdeb"]', '#' + nomeForm);
        var Ltpdpagto = $('label[for="tpdpagto"]', '#' + nomeForm);
        var Ltpenvcrd = $('label[for="tpenvcrd"]', '#' + nomeForm);
        var Lnmempres = $('label[for="nmempres"]', '#' + nomeForm);
        var Lnmprimtl = $('label[for="nmprimtl"]', '#' + nomeForm);
        var Lnrcpfcpf = $('label[for="nrcpfcpf"]', '#' + nomeForm);
        var Ldsrepinc = $('label[for="dsrepinc"]', '#' + nomeForm);

        var Cdsgraupr = $('#dsgraupr', '#' + nomeForm);
        var Cnrcpfcgc = $('#nrcpfcgc', '#' + nomeForm);
        var Cnmextttl = $('#nmextttl', '#' + nomeForm);
        var Cnmtitcrd = $('#nmtitcrd', '#' + nomeForm);
        var Cnrdoccrd = $('#nrdoccrd', '#' + nomeForm);
        var Cdtnasccr = $('#dtnasccr', '#' + nomeForm);
        var Cdsadmcrd = $('#dsadmcrd', '#' + nomeForm);
        var Cdscartao = $('#dscartao', '#' + nomeForm);
        var Cdddebito = $('#dddebito', '#' + nomeForm);
        var Cvlsalari = $('#vlsalari', '#' + nomeForm);
        var Cvlsalcon = $('#vlsalcon', '#' + nomeForm);
        var Cvloutras = $('#vloutras', '#' + nomeForm);
        var Cvlalugue = $('#vlalugue', '#' + nomeForm);
        var Cvllimpro = $('#vllimpro', '#' + nomeForm);
        var Cflgdebit = $('#flgdebit', '#' + nomeForm);
        var Cflgimpnp = $('#flgimpnp', '#' + nomeForm);
        var Cvllimdeb = $('#vllimdeb', '#' + nomeForm);
        var Ctpdpagto = $('#tpdpagto', '#' + nomeForm);
        var Ctpenvcrd = $('#tpenvcrd', '#' + nomeForm);
        var Cnmempres = $('#nmempres', '#' + nomeForm);
        var Cnmprimtl = $('#nmprimtl', '#' + nomeForm);
        var Cnrcpfcpf = $('#nrcpfcpf', '#' + nomeForm);
        var Cdsrepinc = $('#dsrepinc', '#' + nomeForm);


        Ldsgraupr.addClass('rotulo').css('width', '130px');
        Lnrcpfcgc.css('width', '95px');
        Lnmextttl.addClass('rotulo').css('width', '130px');
        Lnmtitcrd.addClass('rotulo').css('width', '130px');
        Lnrdoccrd.addClass('rotulo').css('width', '130px');
        Ldtnasccr.css('width', '95px');
        Ldsadmcrd.addClass('rotulo').css('width', '130px');
        Ldscartao.addClass('rotulo').css('width', '130px');
        Ldddebito.css('width', '95px');
        Lvlsalari.addClass('rotulo').css('width', '130px');
        Lvlsalcon.css('width', '95px');
        Lvloutras.addClass('rotulo').css('width', '130px');
        Lvlalugue.css('width', '95px');
        Lvllimpro.addClass('rotulo').css('width', '130px');
        Lflgimpnp.addClass('rotulo').css('width', '130px');
        Lvllimdeb.css('width', '95px');
        Lflgdebit.addClass('rotulo-linha').css('width', '170px');
        Ltpenvcrd.css('width', '90px');
        Ltpdpagto.addClass('rotulo').css('width', '130px');
        Lnmempres.addClass('rotulo').css('width', '130px');
        Lnmprimtl.addClass('rotulo').css('width', '130px');
        Lnrcpfcpf.addClass('rotulo').css('width', '130px');
        Ldsrepinc.addClass('rotulo').css('width', '130px');
        Lnrcpfcgc.addClass('rotulo').css('width', '130px');

        Cdsgraupr.css({'width': '110px'});
        Cnrcpfcgc.css({'width': '90px', 'text-align': 'right'});
        Cnmextttl.css({'width': '298px'});
        Cnmextttl.attr("disabled","disabled");
        Cnmempres.css({'width': '298px'});
        Cnmtitcrd.css({'width': '298px'});
        Cnrdoccrd.css({'width': '110px'});
        Cdtnasccr.css({'width': '90px'});
        Cdsadmcrd.css({'width': '298px'});
        Cdscartao.css({'width': '110px'});
        Cdddebito.css({'width': '90px'});
        Cvlsalari.css({'width': '110px', 'text-align': 'right'});
        Cvlsalcon.css({'width': '90px', 'text-align': 'right'});
        Cvloutras.css({'width': '110px', 'text-align': 'right'});
        Cvlalugue.css({'width': '90px', 'text-align': 'right'});
        Cvllimpro.css({'width': '110px', 'text-align': 'right'});
        Cflgimpnp.css({'width': '110px'});
        Cvllimdeb.css({'width': '90px', 'text-align': 'right'});
        Ctpenvcrd.css({'width': '90px', 'text-align': 'right'});
        Cnmprimtl.css({'width': '298px'});
        Cnrcpfcpf.css({'width': '120px'});
        Cdsrepinc.css({'width': '298px'});

		//Pessoa Jurídica
        if (inpessoa == 2) {
            Cvlsalari.css("display", "none");
            Lvlsalari.css("display", "none");
            Cvlsalcon.css("display", "none");
            Lvlsalcon.css("display", "none");
            Cvloutras.css("display", "none");
            Lvloutras.css("display", "none");
            Cvlalugue.css("display", "none");
            Lvlalugue.css("display", "none");
            Cdsgraupr.css("display", "none");
            Ldsgraupr.css("display", "none");
            Cnmextttl.css("display", "none");
            Lnmextttl.css("display", "none");
            $("#titular").hide();
            $("#titularidade").hide();
        } else if (inpessoa == 1) {
            $("#conteudoPJ").hide();
            $("#empresa").hide();
            $("#hr1").hide();
            $("#hr2").hide();
        }

    } else if (nomeForm == 'frmNovaValidade') {

        var Lnrcrcard = $('label[for="nrcrcard"]', '#' + nomeForm);
        var Ldtvalatu = $('label[for="dtvalatu"]', '#' + nomeForm);
        var Ldtaltval = $('label[for="dtaltval"]', '#' + nomeForm);
        var Ldtvalida = $('label[for="dtvalida"]', '#' + nomeForm);
        var Lflgimpnp = $('label[for="flgimpnp"]', '#' + nomeForm);

        var Cnrcrcard = $('#nrcrcard', '#' + nomeForm);
        var Cdtvalatu = $('#dtvalatu', '#' + nomeForm);
        var Cdtaltval = $('#dtaltval', '#' + nomeForm);
        var Cdtvalida = $('#dtvalida', '#' + nomeForm);
        var Cflgimpnp = $('#flgimpnp', '#' + nomeForm);

        Lnrcrcard.addClass('rotulo').css('width', '210px');
        Ldtvalatu.addClass('rotulo').css('width', '210px');
        Ldtaltval.addClass('rotulo-linha');
        Ldtvalida.addClass('rotulo').css('width', '210px');
        Lflgimpnp.addClass('rotulo').css('width', '210px');

        Cnrcrcard.css({'width': '155px'});
        Cdtvalatu.css({'width': '65px'});
        Cdtaltval.css({'width': '65px'});
        Cdtvalida.css({'width': '65px'});
        Cflgimpnp.css({'width': '65px'});

        Cnrcrcard.desabilitaCampo();
        Cdtvalatu.desabilitaCampo();
        Cdtaltval.desabilitaCampo();
        Cdtvalida.habilitaCampo();
        Cflgimpnp.habilitaCampo();

        Cdtvalida.setMask("STRING", "99/9999", "/", "");
        Cdtvalida.focus();
    }
    else if (nomeForm == 'frmExtrato') {

        var Lnrcrcard = $('label[for="nrcrcard"]', '#' + nomeForm);
        var Ldtvalida = $('label[for="dtextrat"]', '#' + nomeForm);

        var Cnrcrcard = $('#nrcrcard', '#' + nomeForm);
        var Cdtvalida = $('#dtextrat', '#' + nomeForm);

        Lnrcrcard.addClass('rotulo').css('width', '210px');
        Ldtvalida.addClass('rotulo').css('width', '210px');

        Cnrcrcard.css({'width': '155px'});
        Cdtvalida.css({'width': '65px'});

        Cnrcrcard.desabilitaCampo();
        Cdtvalida.habilitaCampo();

        Cdtvalida.setMask("STRING", "99/9999", "/", "");
        Cdtvalida.focus();

    } else if (nomeForm == 'divConteudoCartoes') {

        var divRegistro = $('div.divRegistros', '#' + nomeForm);
        var tabela = $('table', divRegistro);

        divRegistro.css('height', '150px');
		divRegistro.css('width', '850px');

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        var arrayAlinha = new Array();

        if (inpessoa == 1) {

            arrayLargura[0] = '141px';
            arrayLargura[1] = '114px';
            arrayLargura[2] = '108px';
            arrayLargura[3] = '101px';
            arrayLargura[4] = '112px';
            arrayLargura[5] = '112px';

            arrayAlinha[0] = 'left';
            arrayAlinha[1] = 'left';
            arrayAlinha[2] = 'center';
            arrayAlinha[3] = 'left';
            arrayAlinha[4] = 'left';
            arrayAlinha[5] = 'left';

        } else {
            arrayLargura[0] = '58px';
            arrayLargura[1] = '114px';
            arrayLargura[2] = '108px';
            arrayLargura[3] = '105px';
			arrayLargura[4] = '60px';
            arrayLargura[5] = '60px';
            arrayLargura[6] = '112px';

            arrayAlinha[0] = 'right';
            arrayAlinha[1] = 'left';
            arrayAlinha[2] = 'left';
            arrayAlinha[3] = 'center';
            arrayAlinha[4] = 'left';
            arrayAlinha[5] = 'left';
            arrayAlinha[6] = 'left';
        }

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

        $('tbody > tr', tabela).each(function () {
            if ($(this).hasClass('corSelecao')) {
                $(this).focus();
            }
        });

    } else if (nomeForm == 'divExtratoDetalhe') {

        var divRegistro = $('div.divRegistros', '#' + nomeForm);
        var tabela = $('table', divRegistro);

        divRegistro.css('width', '730px');

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        var arrayAlinha = new Array();

        arrayLargura[0] = '55px';
        arrayLargura[1] = '180px';
        arrayLargura[2] = '120px';
        arrayLargura[3] = '75px';
        arrayLargura[4] = '70px';
        arrayLargura[5] = '70px';


        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'left';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'center';
        arrayAlinha[5] = 'center';
        arrayAlinha[6] = 'center';


        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
    } else if (nomeForm == 'frmEntregaCartaoBancoob') {

        var Lnrcctitg = $('label[for="nrcctitg"]', '#' + nomeForm);
        var Cnrcctitg = $('#nrcctitg', '#' + nomeForm);

        var Lnrcctitg2 = $('label[for="nrcctitg2"]', '#' + nomeForm);
        var Cnrcctitg2 = $('#nrcctitg2', '#' + nomeForm);

        var Lrepsolic = $('label[for="repsolic"]', '#' + nomeForm);
        var Crepsolic = $('#repsolic', '#' + nomeForm);

        var Lnrcarfor = $('label[for="nrcarfor"]', '#' + nomeForm);
        var Cnrcarfor = $('#nrcarfor', '#' + nomeForm);
        Cnrcarfor.setMask("INTEGER", "9999.9999.9999.9999", "", "");

        var Ldtvalida = $('label[for="dtvalida"]', '#' + nomeForm);
        var Cdtvalida = $('#dtvalida', '#' + nomeForm);

        var btnProsseguir = $("#btnProsseguir");
        var btnLerCartaoChip = $("#btnLerCartaoChip");
        var btnLerCartaoMagnetico = $("#btnLerCartaoMagnetico");

        btnProsseguir.hide();
        btnLerCartaoChip.hide();
        btnLerCartaoMagnetico.hide();

        Lnrcctitg.addClass('rotulo').css('width', '130px');
        Lnrcctitg2.addClass('rotulo').css('width', '130px');
        Lrepsolic.addClass('rotulo').css('width', '130px');
        Lnrcarfor.addClass('rotulo').css('width', '130px');
        Ldtvalida.addClass('rotulo').css('width', '130px');

        Cnrcctitg.css('width', '140px');
        Cnrcctitg.setMask("INTEGER", "9999999999999", "", "");

        Cnrcctitg2.css('width', '140px');
        Cnrcctitg2.setMask("INTEGER", "9999999999999", "", "");

        Crepsolic.css('width', '245px');
        Cnrcarfor.css('width', '140px');
        Cdtvalida.css('width', '70px');

        if ((bCartaoSituacaoSolicitado) && (nomeacao == 'ENTREGAR_CARTAO')) {
            btnProsseguir.attr("onclick", "grava_dados_cartao_nao_gerado();return false;");
            Lnrcctitg.show();
            Cnrcctitg.show();
            Cnrcctitg.habilitaCampo();

            Lnrcctitg2.show();
            Cnrcctitg2.show();
            Cnrcctitg2.habilitaCampo();
        } else {
            btnProsseguir.attr("onclick", "valida_dados_cartao_bancoob();return false;");
            Lnrcctitg.hide();
            Cnrcctitg.hide();

            Lnrcctitg2.hide();
            Cnrcctitg2.hide();
        }

        Crepsolic.desabilitaCampo();
        Cnrcarfor.desabilitaCampo();
        Cdtvalida.desabilitaCampo();

        setTimeout(function () {
            if (flgcchip) {
                btnLerCartaoChip.show();
                lerCartaoChip();
            } else {
                btnLerCartaoMagnetico.show();
                lerCartaoMagnetico();
            }
        }, 200);

    } else if (nomeForm == 'frmSenhaNumericaTAA') {

        var Ldssentaa = $('label[for="dssentaa"]', '#' + nomeForm);
        var Ldssencfm = $('label[for="dssencfm"]', '#' + nomeForm);

        var Cdssentaa = $('#dssentaa', '#' + nomeForm);
        var Cdssencfm = $('#dssencfm', '#' + nomeForm);

        Ldssentaa.addClass('rotulo').css('width', '230px');
        Ldssencfm.addClass('rotulo').css('width', '230px');

        Cdssentaa.addClass('campo').css({'width': '100px'}).setMask("INTEGER", "zzzzzz", "", "");
        Cdssencfm.addClass('campo').css({'width': '100px'}).setMask("INTEGER", "zzzzzz", "", "");

        Cdssentaa.focus();
    } else if (nomeForm == 'frmSenhaLetrasTAA') {

        var Ldssennov = $('label[for="dssennov"]', '#' + nomeForm);
        var Ldssencon = $('label[for="dssencon"]', '#' + nomeForm);

        var cDssennov = $('#dssennov', '#' + nomeForm);
        var cDssencon = $('#dssencon', '#' + nomeForm);

        Ldssennov.addClass('rotulo').css('width', '220px');
        Ldssencon.addClass('rotulo').css('width', '220px');

        cDssennov.addClass('campo').css({'width': '50px'});
        cDssencon.addClass('campo').css({'width': '50px'});

        cDssennov.focus();

    } else if (nomeForm == 'divConteudoHistorico') {

        var divRegistro = $('div.divRegistros', '#' + nomeForm);
        var tabela = $('table', divRegistro);

        divRegistro.css('height', '150px');

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        var arrayAlinha = new Array();

        arrayLargura[0] = '120px';
        arrayLargura[1] = '100px';
        arrayLargura[2] = '120px';

        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'right';
        arrayAlinha[3] = 'right';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

        $('tbody > tr', tabela).each(function () {
            if ($(this).hasClass('corSelecao')) {
                $(this).focus();
            }
        });

    } else if (nomeForm == 'fieldsetTAA') {
        $('#fieldsetTAA').css({'border': '1px solid #bbb', 'margin': '3px', 'padding': '0px 3px 5px 3px'});
        $('legend:first', '#fieldsetTAA').css({
            'font-size': '11px',
            'color': '#333',
            'margin-left': '5px',
            'padding': '0px 2px'
        });
    } else if (nomeForm == 'frmListaEnderecos') {
        $('#btatualizardados').css({
            'float': 'none',
            'cursor': 'pointer'
        });

        hideMsgAguardo();
        fechaRotina($('#divRotina'),$('#divUsoGenerico'));
        $('#divUsoGenerico').setCenterPosition();
		$('#divUsoGenerico').css('top', '91px');
    }

	ajustarCentralizacao();
	
    return false;
}

/******************************************************************************************************************/
/*****************************************         OPÇÃO NOVO         *********************************************/
/******************************************************************************************************************/
function opcaoNovo(cdcooper) {

//Bloqueado solicitacao de novo cartao para cooperativa transulcred SD 574068
    if (cdcooper == 17) {
        showError("error", "Solicita&ccedil;&atilde;o n&atilde;o autorizada.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

	// Zeramos o contrato
    nrctrcrd = 0;

    // Saimos da tela principal
    flgPrincipal = false;

	// ALTERAÇÃO 001
    nomeForm = 'frmNovoCartao';

    var flgliber = $('#flgliber', '#divCartoes').val();


// Se nao esta liberado (Transferencia de PAC)
    if (flgliber == "no") {
        showError("error", dsdliber, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados para novo cart&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/cartao_credito/novo.php",
        data: {
            nrdconta: nrdconta,
            inpessoa: inpessoa,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {

            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });


}

function opcaoNovoOld(cdcooper) {

//Bloqueado solicitacao de novo cartao para cooperativa transulcred SD 574068
    if (cdcooper == 17) {
        showError("error", "Solicita&ccedil;&atilde;o n&atilde;o autorizada.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// ALTERA��O 001
    nomeForm = 'frmNovoCartao';

    var flgliber = $('#flgliber', '#divCartoes').val();


// Se nao esta liberado (Transferencia de PAC)
    if (flgliber == "no") {
        showError("error", dsdliber, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados para novo cart&atilde;o ...");

	bTelaAntiga = true;
	
// Carrega conte�do da op��o atrav�s de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/cartao_credito/novo_progress.php",
        data: {
            nrdconta: nrdconta,
            inpessoa: inpessoa,
            redirect: "html_ajax",
			tipo: "all"
        },
        error: function (objAjax, responseError, objExcept) {

            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
			//Vamos adequar a funcao do botao voltar.
			$(".btnVoltar", "#divBotoes").attr("onclick", "voltaDiv(0,1,4);return false;");
        }
    });


}

// - CECRED CArt�o fase III - Amasonas Supero
function alteraCartao() {
    if (cdadmcrd == 16 || cdadmcrd == 17) {
        hideMsgAguardo();
        showError("error", "Altera&ccedil;&atilde;o de limite n&atilde;o permitida, somente para cart&otilde;es do tipo cr&eacute;dito!", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

	if($("#btnalterarLimite").attr("situacao") != undefined && $("#btnalterarLimite").attr("situacao") == "situacao"){
		showError("error", "Altera&ccedil;&atilde;o de limite permitida apenas para cart&otilde;es com a situa&ccedil;&atilde;o 'Em Uso'.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return;
	}

    if (cdcooper == 17) {
        showError("error", "Solicita&ccedil;&atilde;o n&atilde;o autorizada.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }


    if (nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    showMsgAguardo("Aguarde...");

    // Saimos da tela principal
    flgPrincipal = false;

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/cartao_credito/verifica_pendencia_esteira.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            hideMsgAguardo();
            eval(response);
        }
    });

}

function alterarLimite() {

    if (nrctrcrd == 0) {
        return false;
    }

    showMsgAguardo("Aguarde...");

    // Carrega conte�do da op��o atrav�s de ajax
	if (inpessoa == 1){
		$.ajax({
			type: "POST",
			dataType: "html",
			url: UrlSite + "telas/atenda/cartao_credito/alterar_limite_cartao.php",
			data: {
				nrcrcard      : nrcrcard,
				nrdconta      : nrdconta,
				cdadmcrd      : cdadmcrd,
				cdAdmCartao   : ($("#btnalterarLimite").attr("cdAdmCartao") || 0),
				nrctrcrd      : nrctrcrd
			},
			error: function (objAjax, responseError, objExcept) {

				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function (response) {
				$("#divOpcoesDaOpcao1").html(response);
			}
		});
	} else {
		$.ajax({
			type: "POST",
			dataType: "html",
			url: UrlSite + "telas/atenda/cartao_credito/alterar_limite_cartao_pj.php",
			data: {
				nrcrcard      : nrcrcard,
				nrdconta      : nrdconta,
				cdadmcrd      : cdadmcrd,
				cdAdmCartao   : ($("#btnalterarLimite").attr("cdAdmCartao") || 0),
				nrctrcrd      : nrctrcrd
			},
			error: function (objAjax, responseError, objExcept) {

				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function (response) {
				$("#divOpcoesDaOpcao1").html(response);
			}
		});
	}
    

}

function mostraDivDadosCartao() {
    $("#divDadosNovoCartao").css("display", "block");
    $("#divDadosAvalistas").css("display", "none");
}

function buscaDados(cdtipcta, nrcpfstl, inpessoa, dtnasstl, nrdocstl, nmconjug, dtnasccj, nmtitcrd, nrcpfcgc, dtnasccr, nrdoccrd, vlsalari, nmsegntl) {


console.log('cdtipcta: '+cdtipcta+ ' nrcpfstl: '+nrcpfstl+ ' inpessoa: '+inpessoa+ ' dtnasstl: '+dtnasstl+ ' nrdocstl: '+nrdocstl+ ' nmconjug: '+nmconjug+ ' dtnasccj: '+dtnasccj+ ' nmtitcrd: '+nmtitcrd+ ' nrcpfcgc: '+nrcpfcgc+ ' dtnasccr: '+dtnasccr+ ' nrdoccrd: '+nrdoccrd+ ' vlsalari: '+vlsalari+ ' nmsegntl: '+nmsegntl);
    if (nrcpfcgc == "000.000.000-00") {
        $(".campoTelaSemBorda").each(function (k, v) {
            if ($(v).attr("id") == "nrcpfcgc") {
                nrcpfcgc = v.value;
                return false;
            }

        });
    }


    var objSelectPar = document.frmNovoCartao.dsgraupr;
    var escolha = objSelectPar.options[objSelectPar.options.selectedIndex].value;
    var nrcpfau = nrcpfstl.replace(/\./g, "");
    nrcpfau = nrcpfau.replace(/\-/g, "");
	
    if ($("#dsadmcrd", '#' + nomeForm).length && $("#dsadmcrd", '#' + nomeForm).val().indexOf(";") == -1 && $("#dsadmcrdcc[checked='checked']").val() != "outro") {
        dsadmcrd = $('#dsadmcrd', '#' + nomeForm).val() || "";
        cdadmcrd = $('#cdadmcrd', '#' + nomeForm).val() || 0;
    }
    else {
        var adm = ($('#listType option:selected', '#' + nomeForm).val() || "").split(";");
        dsadmcrd = (adm[0] || "");
        cdadmcrd = (adm[1] || 0);
    }

    /*var adm = $("#listType").val().split(";");
    dsadmcrd = adm[0];
    cdadmcrd = adm[1];*/

    if (cdadmcrd >= 10 && cdadmcrd < 81) {
		
		/*Tratamento para busca limite, dia de débito, proposto, forma de pagamento, envio*/	
        if (escolha == 6 || escolha == 7 || escolha == 8) {

            if (nrcpfau == 0) {
                showError("error", "Titular inexistente para cadastro de cartao.", "Alerta - Aimaro", "$('#nmtitcrd','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
				hideMsgAguardo();
                voltaDiv(0, 1, 4);
                return false;
            } else {
                nrcpfau = null;
                nrcpfau = nrcpfcgc.replace(/\./g, "");
                nrcpfau = nrcpfau.replace(/\-/g, "");
                buscaDadosCartao(cdadmcrd, nrcpfau, nmtitcrd, 1);
            }

        }

    }


    if (escolha == 6) { // Segundo Titular
        $("#nrcpfcgc", "#frmNovoCartao").val(nrcpfstl);
        $("#nmtitcrd", "#frmNovoCartao").val(nmsegntl);
        $("#nmextttl", "#frmNovoCartao").val(nmsegntl);
        $("#nrdoccrd", "#frmNovoCartao").val(nrdocstl);
        $("#dtnasccr", "#frmNovoCartao").val(dtnasstl);
    } else if (escolha == 1) { // Conjuge
        $("#nrcpfcgc", "#frmNovoCartao").val("");
        $("#nmtitcrd", "#frmNovoCartao").val(nmconjug);
        $("#nmextttl", "#frmNovoCartao").val(nmconjug);
        $("#nrdoccrd", "#frmNovoCartao").val("");
        $("#dtnasccr", "#frmNovoCartao").val(dtnasccj);
    } else if (escolha == 5) { // Primeiro Titular
        if(inpessoa != 2)
            $("#nrcpfcgc", "#frmNovoCartao").val(nrcpfcgc);
        $("#nmtitcrd", "#frmNovoCartao").val(nmtitcrd);
        $("#nmextttl", "#frmNovoCartao").val(nmtitcrd);
        $("#nrdoccrd", "#frmNovoCartao").val(nrdoccrd);
        $("#dtnasccr", "#frmNovoCartao").val(dtnasccr);
        $("#vlsalari", "#frmNovoCartao").val(vlsalari);
        if (nrctrcrd > 0) {
            carregarRepresentante("A", 0, nrcpfcgc);
        } else {
        carregarRepresentante("N", 0, nrcpfcgc);
        }
    } else if (escolha == 7 || escolha == 8) { // Terceiro Titular e Quarto Titular
        buscaTitulares(nrdconta, escolha);
    } else if (escolha == 3 || escolha == 4) { // Filhos ou Companheiro
        $("#nrcpfcgc", "#frmNovoCartao").val("");
        $("#nmtitcrd", "#frmNovoCartao").val("");
        $("#nmextttl", "#frmNovoCartao").val("");
        $("#nrdoccrd", "#frmNovoCartao").val("");
        $("#dtnasccr", "#frmNovoCartao").val("");
    }
     $("#nmextttl").attr("disabled",'disabled');

}

function alteraDiaDebito() {

    var objSelectDiaDebito = document.frmNovoCartao.dddebito;
    var objSelectAdmCrd = document.frmNovoCartao.dsadmcrd;
         // Remove as opções
    for (i = objSelectDiaDebito.options.length; i >= 0; i--) {
        objSelectDiaDebito.remove(i);
    }
         // pega o value da opção selecionada
    var dadosAdministradora = objSelectAdmCrd.options[objSelectAdmCrd.options.selectedIndex].value;

         // pega o cód da adm
    var codAdm = dadosAdministradora.slice(0, dadosAdministradora.search(";"));
         // pega os dias do débito na opção selecionada
    var diasDebito = dadosAdministradora.slice(dadosAdministradora.search(";") + 1);

// var dados  = objSelectAdmCrd.options[objSelectAdmCrd.options.selectedIndex].value;

    var nmbandei = dadosAdministradora.split(";")[3];

         //tira o identificador se tem débito ou não e fica só com os dias do débito
    var xDiasDebito = diasDebito.slice(0, diasDebito.search(";"));
		 //Dias do débito
    var sDiasDebito = xDiasDebito.split(",");
    for (i = 0; i < sDiasDebito.length; i++) {

        if (sDiasDebito[i] != 0) {
// cria o novo objeto options
            var objOptionNovo = document.createElement("option");
            objOptionNovo.text = sDiasDebito[i];
            objOptionNovo.id = sDiasDebito[i];
            objOptionNovo.value = sDiasDebito[i];
// adiciona ao select o novo objeto
            try {
                objSelectDiaDebito.add(objOptionNovo, null);
                objSelectDiaDebito.add(objOptionNovo, 0);
            } catch (ex) {
                objSelectDiaDebito.add(objOptionNovo);
            }
        }
    }

// Habilita o campo "vllimpro"
    if (nmbandei == "MAESTRO") {
        $("#vllimdeb", "#frmNovoCartao").val("0,00");
        $("#tpdpagto", "#frmNovoCartao").val("1");
        $("#tpdpagto", "#frmNovoCartao").prop("disabled", true);
    } else {
        $("#tpdpagto", "#frmNovoCartao").prop("disabled", false);
    }

// Habilita o campo "vllimdeb"
    if (dadosAdministradora.indexOf('temDebito') > 0) {
        $("#vllimdeb", "#frmNovoCartao").val("0,00");
		ativa("vllimdeb");
        $("#vllimdeb", "#frmNovoCartao").removeProp("disabled");
        $("#tpdpagto", "#frmNovoCartao").val("1");
        $("#tpdpagto", "#frmNovoCartao").prop("disabled", true);
    } else {
        $("#vllimdeb", "#frmNovoCartao").prop("disabled", true);
		desativa('vllimdeb');
    }

    /*SOMENTE p/ bancoob*/
    $("#nmextttl", "#frmNovoCartao").prop("disabled", true);
    $("#nrcpfcgc", "#frmNovoCartao").prop("disabled", true);
}

function alteraLimiteProposto() {
	try{
		var objSelectAdmCrd = document.frmNovoCartao.dsadmcrd;
		var dadosAdministradora = objSelectAdmCrd.options[objSelectAdmCrd.options.selectedIndex].value;
		var aLimiteProposto = dadosAdministradora.split(';');

	// Atualiza o campo Limite Proposto
		atualizaCampoLimiteProposto(aLimiteProposto[4].split("@"));

	// Habilita o campo "vllimpro"
		/*if (aLimiteProposto[3] == "MAESTRO") {
			$("#vllimpro", "#frmNovoCartao").desabilitaCampo();
		} else {
			$("#vllimpro", "#frmNovoCartao").habilitaCampo();
		}*/
	}catch(e){
		console.log("erro -  alteraLimiteProposto() ");
		console.log(e);
	}
}

function atualizaCampoLimiteProposto(aOpcao) {

    var objSelectLimiteProposto = document.frmNovoCartao.vllimpro;

    // Remove as opções
    for (i = objSelectLimiteProposto.options.length; i >= 0; i--) {
        objSelectLimiteProposto.remove(i);
    }

    for (i = 0; i < aOpcao.length; i++) {
// cria o novo objeto options
        var objOptionNovo = document.createElement("option");
        objOptionNovo.text = aOpcao[i];
        objOptionNovo.id = aOpcao[i];
        objOptionNovo.value = aOpcao[i];
        objSelectLimiteProposto.add(objOptionNovo, i);
    }
}

function alteraFuncaoDebito() {
    var objSelectAdmCrd = document.frmNovoCartao.dsadmcrd;
	if(objSelectAdmCrd == undefined || objSelectAdmCrd.options == undefined){
		return;
	}else{
    var dadosAdministradora = objSelectAdmCrd.options[objSelectAdmCrd.options.selectedIndex].value;
    var aLimiteProposto = dadosAdministradora.split(';');

    if ((aLimiteProposto[3] == "MAESTRO") || (inpessoa == 1)) {
        $("#flgdebit", "#frmNovoCartao").desabilitaCampo();
        $("#flgdebit", "#frmNovoCartao").prop('checked', true);
    } else if(idastcjt != 1) {
        $("#flgdebit", "#frmNovoCartao").habilitaCampo();
        $("#flgdebit", "#frmNovoCartao").prop('checked', true);
    }
}


}

function verificaEfetuaGravacao(cddopcao) {
    try {
        // Verifica se abre a tela para informar os representantes
        if (inpessoa == 2 && $("#dsrepinc option:selected").text()=="OUTROS") {
            carregaSelecionarRepresentantes(cddopcao);
        } else {
            validarNovoCartao(cddopcao);
        }
        return false;
    } catch (e) {

    }
}

function confirmaEndereco(tipoAcao, alguemAssinou) {
	var el = $('input[type="radio"]:checked', '#frmListaEnderecos');

	if (!el.length) {
		hideMsgAguardo();
		showError("error", "Deve ser selecionado um endere&ccedil;o para envio do cart&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            return false;
        }

	var label = el.parent().find('label'),
		enderecoCompleto = '',
        cdagenci = 0;
		
	if (label.length) {
		enderecoCompleto = label.html().trim();
        cdagenci = el.data("cdagenci");
        } else {
        var $outropa = $('#outropasel option:selected', '#frmListaEnderecos');
		enderecoCompleto = $outropa.data('endereco');
        cdagenci = $outropa.val();
        }

        showConfirmacao("O cart&atilde;o ser&aacute; enviado para o endere&ccedil;o:<br><br>"+enderecoCompleto+"<br><br>Confirma a opera&ccedil;&atilde;o?",
                    "Confirma&ccedil;&atilde;o - Aimaro",
                    "atualizaEndereco("+tipoAcao+", "+cdagenci+")",
                    "blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
    }

function atualizaEndereco(tipoAcao, cdagenci) {
    showMsgAguardo("Aguarde Enviando solicita&ccedil;&atilde;o ...");
    var idtipoenvio = $('input[type="radio"]:checked', '#frmListaEnderecos').attr("id");
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/cartao_credito/atualiza_endereco.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            tipoAcao: tipoAcao,
            idtipoenvio: (idtipoenvio || 0),
            cdagenci: cdagenci
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            hideMsgAguardo();
            eval(response);
}
    });
}

// Função para validar novo cartão de crédito
function validarNovoCartao(cddopcao) {
	
	// Para novas inclusoes devemos zerar o contrato, feito desta forma pois se operador 
	// utilizar a seta do mouse o contrato eh selecionado por baixo da tela
	if (cddopcao == 'I'){	
		nrctrcrd = 0;
	}	
	
    try {
// Mostra mensagem de aguardo
        if (nrctrcrd == null || nrctrcrd == 0) {
        showMsgAguardo("Aguarde, validando novo cart&atilde;o de cr&eacute;dito ...");
        } else {
            showMsgAguardo("Aguarde, validando altera&ccedil;&atilde;o de cart&atilde;o de cr&eacute;dito ...");
        }

        if (inpessoa == 1) {
            var dsgraupr = $("#dsgraupr option:selected", "#frmNovoCartao").text();
            var nrdoccrd = $("#nrdoccrd", "#frmNovoCartao").val();
            var flgimpnp = $("#flgimpnp", "#frmNovoCartao").val();
            var dsrepinc = "";
        } else {
            var dsgraupr = "";
            //var nrdoccrd = ""; //AjusteDoc
			var nrdoccrd = $("#nrdoccrd", "#frmNovoCartao").val(); //AjusteDoc
            var flgimpnp = "yes";
            var dsrepinc = $("#dsrepinc option:selected", "#frmNovoCartao").text();
            $("#nmempres","#frmNovoCartao").val($("#nmempres","#frmNovoCartao").val().replace(/[^a-zA-Z ]/g,''));
            var nmempres = $("#nmempres", "#frmNovoCartao").val();
        }

        var nmtitcrd = $("#nmtitcrd", "#frmNovoCartao").val();
        var dscartao = $("#dscartao", "#frmNovoCartao").val();
        var vllimdeb = $("#vllimdeb", "#frmNovoCartao").val().replace(/\./g, "");
        var nrcpfcgc = retiraCaracteres($("#nrcpfcgc", "#frmNovoCartao").val(), "0123456789", true);
        var dddebito = $("#dddebito", "#frmNovoCartao").val();
        var dtnasccr = $("#dtnasccr", "#frmNovoCartao").val();
		var flgdebit = $('#flgdebit', '#' + nomeForm).prop('checked');
        var dsrepres = "";
        var codgroup = $("#dsgraupr option:selected", "#frmNovoCartao").val();

        var dsadmcrd = "";
        var cdadmcrd = 0;

        var adm = "";
        // Se for um cartão múltiplo titular temos a tela de selação
        if ($("#dsadmcrdcc[checked='checked']", "#frmNovoCartao").val() != "outro") {
            adm = ($("#dsadmcrdcc[checked='checked']", "#frmNovoCartao").val() || "").split(";");
        }else{
            adm = ($('#listType option:selected', "#frmNovoCartao").val() || "").split(";");
        }
        // Se o adm ficou vazio é pq nao teve a tela de seleção, portanto é um multiplo adicional
        if (adm == "") {
            if (($("#dsadmcrd", "#frmNovoCartao").val() || "").indexOf(";") != -1) {
                var admAdicional = ($("#dsadmcrd", "#frmNovoCartao").val() || "").split(";");
                dsadmcrd = ($("#dsadmcrd option:selected", "#frmNovoCartao").text() || "").trim(); // Texto no option
                cdadmcrd = (admAdicional[0] || 0); // Value na coordenada zero do option
			} else {
                dsadmcrd = $("#dsadmcrd", "#frmNovoCartao").val();
                cdadmcrd = $("#cdadmcrd", "#frmNovoCartao").val();
            }

				} else {
            dsadmcrd = (adm[0] || "");
            cdadmcrd = (adm[1] || 0);
		}
		
        var tpdpagto = $("#tpdpagto option:selected", "#frmNovoCartao").val();
        var vllimpro = trim($("#vllimpro", "#frmNovoCartao").val() || "0").replace(/\./g, "");
        vllimpro.replace(/\./g, ",");

        $("input[type=checkbox][name='nrseqavl[]']").each(function () {
            if (this.checked != false) {
                if (dsrepres == "") {
                    dsrepres = this.value;
                } else {
                    dsrepres = dsrepres + "," + this.value;
                }
            }
        });

        if (!validaCpfCnpj(nrcpfcgc, 1)) {
            hideMsgAguardo();
            showError("error", "CPF inv&aacute;lido.", "Alerta - Aimaro", "$('#nrcpfcgc','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
            return false;
        }

        if (nmtitcrd == "") {
            hideMsgAguardo();
            showError("error", "016 - Nome do titular deve ser informado.", "Alerta - Aimaro", "$('#nmtitcrd','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
            return false;
        }

        if (inpessoa == 1 && nrdoccrd == "") {
            hideMsgAguardo();
            showError("error", "022 - Numero do documento errado.", "Alerta - Aimaro", "$('#nrdoccrd','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
            return false;
        }

        if (inpessoa == 1 && nrdoccrd.length > 15) {
            hideMsgAguardo();
            showError("error", "Identidade nao pode ter mais de 15 caracteres.", "Alerta - Aimaro", "$('#nrdoccrd','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
            return false;
        }


        if (dtnasccr == "") {
            hideMsgAguardo();
            showError("error", "013 - Data errada.", "Alerta - Aimaro", "$('#dtnasccr','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
            return false;
        }
        // Validações para cartão PJ
        if (inpessoa == 2 && (cdadmcrd >= 10 && cdadmcrd <= 80)) {
// Nome da Empresa deve estar preenchido
            if (nmempres.trim() == "") {
                hideMsgAguardo();
                showError("error", "Empresa do Plastico deve ser informada.", "Alerta - Aimaro", "$('#nmempres','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
                return false;
            }
		// Nome da Empresa não pode conter mais de 23 caracteres
            if (nmempres.length > 23) {
                hideMsgAguardo();
                showError("error", "Empresa do Plastico nao pode ter mais de 23 letras.", "Alerta - Aimaro", "$('#nmempres','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
                return false;
            }

// Nome da Empresa não pode conter numeros
            if (/[0-9]/gm.test(nmempres)) {
                hideMsgAguardo();
                showError("error", "Empresa do Plastico n&atilde;o pode conter n&uacute;meros.", "Alerta - Aimaro", "$('#nmempres','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
                return false;
            }
        }

        if (tpdpagto == 0) {
            hideMsgAguardo();
            showError("error", "Selecione uma Forma de Pagamento.", "Alerta - Aimaro", "$('#tpdpagto','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
            return false
        }

// Executa script de valida��o do cart�o atrav�s de ajax
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/cartao_credito/validar_novo.php",
            data: {
                nrdconta: nrdconta,
                inpessoa: inpessoa,
                dsgraupr: dsgraupr,
                nmtitcrd: nmtitcrd,
                dsadmcrd: dsadmcrd,
                dscartao: dscartao,
                flgimpnp: flgimpnp,
                vllimpro: vllimpro,
                vllimdeb: vllimdeb,
                nrcpfcgc: nrcpfcgc,
                dddebito: dddebito,
                dtnasccr: dtnasccr,
                nrdoccrd: nrdoccrd,
                dsrepinc: dsrepinc,
                tpdpagto: tpdpagto,
                dsrepres: dsrepres,
                nmempres: nmempres,
				flgdebit: flgdebit,
				cdadmcrd: cdadmcrd,
				nrctrcrd: nrctrcrd,
                cddopcao: cddopcao,
                redirect: "script_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                }
            }
        });
    } catch (e) {
        hideMsgAguardo();
        showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }
}
	  
function senhaCoordenador(executaDepois) {
	pedeSenhaCoordenador(2,executaDepois,'divRotina');
	
	setTimeout(function(){
		$( "#btnSenhaCoordenador" ).mouseover(function() {
		  faprovador = $("#cdopelib").val();
		});
		$(".campo").blur(function(){
			if( $(this).attr('id') =='cdopelib'){
				faprovador = $(this).val();
			}
			
		});
		
		$(".campo").change(function(){
			if( $(this).attr('id') =='cdopelib'){
				faprovador = $(this).val();
			}
		});
		
	},160);
	

}

//Necessári para captar o 'F' digitado pelo supervisor.
function altPedeSenhaCoordenador(callAfter, tipoOperad) {
    
    pedeSenhaCoordenador(tipoOperad,callAfter,'divRotina');
    
    //Apenas define corretamente os eventos se definidos dentro de setTimeOut.
    setTimeout(function(){
    $("#btnSenhaCoordenador","#frmSenhaCoordenador").mouseover(function() {
         cdopelib = $("#cdopelib","#frmSenhaCoordenador").val();
    });
    
    $("#cdopelib","#frmSenhaCoordenador").blur(function(){
        cdopelib = $("#cdopelib","#frmSenhaCoordenador").val();
    });
    
    $("#cdopelib","#frmSenhaCoordenador").change(function(){
        cdopelib = $("#cdopelib","#frmSenhaCoordenador").val();
    });
    },160);
}

/*!
 * OBJETIVO : Função para cadastrar nova proposta de cartão de crédito
 * ALTERAÇÃO 001: Padronizado o recebimento de valores e incluso o recebimento dos campos
 *                número, complemento e caixa postal para os avalistas 1 e 2
*/
function cadastrarNovoCartao(cddopcao) {

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, cadastrando nova proposta de cart&atilde;o de cr&eacute;dito ...");
	log4console("montando nova requisição");
// Recebendo valores
    var dsgraupr = (inpessoa == 1) ? $('#dsgraupr option:selected', '#' + nomeForm).text() : '';
    //var nrdoccrd = (inpessoa == 1) ? $('#nrdoccrd', '#' + nomeForm).val() : ''; //AjusteDoc
	var nrdoccrd = $('#nrdoccrd', '#' + nomeForm).val();
    var flgimpnp = (inpessoa == 1) ? $('#flgimpnp', '#' + nomeForm).val() : 'yes';
    var vlsalari = (inpessoa == 1) ? normalizaNumero($('#vlsalari', '#' + nomeForm).val()) : '0,00';
    var vlsalcon = (inpessoa == 1) ? normalizaNumero($('#vlsalcon', '#' + nomeForm).val()) : '0,00';
    var vloutras = (inpessoa == 1) ? normalizaNumero($('#vloutras', '#' + nomeForm).val()) : '0,00';
    var vlalugue = (inpessoa == 1) ? normalizaNumero($('#vlalugue', '#' + nomeForm).val()) : '0,00';
    var dsrepinc = $("#dsrepinc option:selected", "#" + nomeForm).text();
    var nrrepinc = (inpessoa == 1) ? '0' : $('#dsrepinc', '#' + nomeForm).val();

    var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#' + nomeForm).val());
    var vllimdeb = normalizaNumero($('#vllimdeb', '#' + nomeForm).val());

    var vllimpro = $("#vllimpro", "#frmNovoCartao").length && trim($("#vllimpro", "#frmNovoCartao").val());
    vllimpro = normalizaNumero(vllimpro);
    var nmtitcrd = $('#nmtitcrd', '#' + nomeForm).length && trim($('#nmtitcrd', '#' + nomeForm).val());
    var nmempres = $('#nmempres', '#' + nomeForm).length && trim($('#nmempres', '#' + nomeForm).val());
    var nmextttl = $('#nmextttl', '#' + nomeForm).length && trim($('#nmextttl', '#' + nomeForm).val());

    var dtnasccr = $('#dtnasccr', '#' + nomeForm).val();
    var dsadmcrd = "";
    var cdadmcrd = "";
    var adm = "";
    // Se for um cartão múltiplo titular temos a tela de selação
    if ($("#dsadmcrdcc[checked='checked']", "#frmNovoCartao").val() != "outro") {
        adm = ($("#dsadmcrdcc[checked='checked']", "#frmNovoCartao").val() || "").split(";");
    } else {
        adm = ($('#listType option:selected', "#frmNovoCartao").val() || "").split(";");
    }
    // Se o adm ficou vazio é pq nao teve a tela de seleção, portanto é um multiplo adicional
    if (adm == "") {
        if (($("#dsadmcrd", "#frmNovoCartao").val() || "").indexOf(";") != -1) {
            var admAdicional = ($("#dsadmcrd", "#frmNovoCartao").val() || "").split(";");
            dsadmcrd = ($("#dsadmcrd", "#frmNovoCartao").text() || "").trim(); // Texto no option
            cdadmcrd = (admAdicional[0] || 0); // Value na coordenada zero do option
        } else {
            dsadmcrd = $("#dsadmcrd", "#frmNovoCartao").val();
            cdadmcrd = $("#cdadmcrd", "#frmNovoCartao").val();
        }
    } else {
        dsadmcrd = (adm[0] || "");
        cdadmcrd = (adm[1] || 0);
    }
    var dscartao = $('#dscartao', '#' + nomeForm).val();
    var dddebito = $('#dddebito', '#' + nomeForm).val();

// Avalista 1
    var nrctaav1 = normalizaNumero($('#nrctaav1', '#' + nomeForm).val());
    var nrcpfav1 = normalizaNumero($('#nrcpfav1', '#' + nomeForm).val());
    var cpfcjav1 = normalizaNumero($('#cpfcjav1', '#' + nomeForm).val());
    var nrcepav1 = normalizaNumero($('#nrcepav1', '#' + nomeForm).val());
    var nrender1 = normalizaNumero($('#nrender1', '#' + nomeForm).val());
    var nrcxaps1 = normalizaNumero($('#nrcxaps1', '#' + nomeForm).val());
    var complen1 = $('#complen1', '#' + nomeForm).length && trim($('#complen1', '#' + nomeForm).val());
    var nmdaval1 = $('#nmdaval1', '#' + nomeForm).length && trim($('#nmdaval1', '#' + nomeForm).val());
    var dsdocav1 = $('#dsdocav1', '#' + nomeForm).length && trim($('#dsdocav1', '#' + nomeForm).val());
    var nmdcjav1 = $('#nmdcjav1', '#' + nomeForm).length && trim($('#nmdcjav1', '#' + nomeForm).val());
    var doccjav1 = $('#doccjav1', '#' + nomeForm).length && trim($('#doccjav1', '#' + nomeForm).val());
    var ende1av1 = $('#ende1av1', '#' + nomeForm).length && trim($('#ende1av1', '#' + nomeForm).val());
    var ende2av1 = $('#ende2av1', '#' + nomeForm).length && trim($('#ende2av1', '#' + nomeForm).val());
    var nmcidav1 = $('#nmcidav1', '#' + nomeForm).length && trim($('#nmcidav1', '#' + nomeForm).val());
    var nrfonav1 = $('#nrfonav1', '#' + nomeForm).length && trim($('#nrfonav1', '#' + nomeForm).val());
    var tpdocav1 = $('#tpdocav1', '#' + nomeForm).val() || "";
    var tdccjav1 = $('#tdccjav1', '#' + nomeForm).val() || "";
    var cdufava1 = $('#cdufava1', '#' + nomeForm).val() || "";
    var emailav1 = $('#emailav1', '#' + nomeForm).val() || "";

// Avalista 2
    var nrctaav2 = normalizaNumero($('#nrctaav2', '#' + nomeForm).val());
    var nrcpfav2 = normalizaNumero($('#nrcpfav2', '#' + nomeForm).val());
    var cpfcjav2 = normalizaNumero($('#cpfcjav2', '#' + nomeForm).val());
    var nrcepav2 = normalizaNumero($('#nrcepav2', '#' + nomeForm).val());
    var nrender2 = normalizaNumero($('#nrender2', '#' + nomeForm).val());
    var nrcxaps2 = normalizaNumero($('#nrcxaps2', '#' + nomeForm).val());
    var complen2 = $('#complen2', '#' + nomeForm).length && trim($('#complen2', '#' + nomeForm).val());
    var nmdaval2 = $('#nmdaval2', '#' + nomeForm).length && trim($('#nmdaval2', '#' + nomeForm).val());
    var dsdocav2 = $('#dsdocav2', '#' + nomeForm).length && trim($('#dsdocav2', '#' + nomeForm).val());
    var nmdcjav2 = $('#nmdcjav2', '#' + nomeForm).length && trim($('#nmdcjav2', '#' + nomeForm).val());
    var doccjav2 = $('#doccjav2', '#' + nomeForm).length && trim($('#doccjav2', '#' + nomeForm).val());
    var ende1av2 = $('#ende1av2', '#' + nomeForm).length && trim($('#ende1av2', '#' + nomeForm).val());
    var ende2av2 = $('#ende2av2', '#' + nomeForm).length && trim($('#ende2av2', '#' + nomeForm).val());
    var nmcidav2 = $('#nmcidav2', '#' + nomeForm).length && trim($('#nmcidav2', '#' + nomeForm).val());
    var nrfonav2 = $('#nrfonav2', '#' + nomeForm).length && trim($('#nrfonav2', '#' + nomeForm).val());
    var tpdocav2 = $('#tpdocav2', '#' + nomeForm).val() || "";
    var tdccjav2 = $('#tdccjav2', '#' + nomeForm).val() || "";
    var cdufava2 = $('#cdufava2', '#' + nomeForm).val() || "";
    var emailav2 = $('#emailav2', '#' + nomeForm).val() || "";

    var tpdpagto = $('#tpdpagto', '#' + nomeForm).val() || "";
    var tpenvcrd = $('#tpenvcrd', '#' + nomeForm).val() || "";
    var flgdebit = $('#flgdebit', '#' + nomeForm).prop('checked') || "";
    var dsrepres = "";

    $("input[type=checkbox][name='nrseqavl[]']").each(function () {
        if (this.checked != false) {
            if (dsrepres == "") {
                dsrepres = this.value;
            } else {
                dsrepres = dsrepres + "," + this.value;
            }
        }
    });

	log4console("enviando requisição para o progress");
// Executa script de cadastro de proposta de cart�o atrav�s de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/cartao_credito/cadastrar_novo_cartao.php',
        data: {
            nrdconta: nrdconta, inpessoa: inpessoa, dsgraupr: dsgraupr, nrdoccrd: nrdoccrd,
            flgimpnp: flgimpnp, vlsalari: vlsalari, vlsalcon: vlsalcon, vloutras: vloutras,
            vlalugue: vlalugue, nrrepinc: nrrepinc, nrcpfcgc: nrcpfcgc, vllimpro: vllimpro,
            vllimdeb: vllimdeb, nmtitcrd: nmtitcrd, nmempres: nmempres, dtnasccr: dtnasccr,
            dsadmcrd: dsadmcrd, cdadmcrd: cdadmcrd, dscartao: dscartao, dddebito: dddebito,
            nrctaav1: nrctaav1, nrcpfav1: nrcpfav1, cpfcjav1: cpfcjav1, nrcepav1: nrcepav1,
            nrender1: nrender1, nrcxaps1: nrcxaps1, complen1: complen1, nmdaval1: nmdaval1,
            dsdocav1: dsdocav1, nmdcjav1: nmdcjav1, doccjav1: doccjav1, ende1av1: ende1av1,
            ende2av1: ende2av1, nmcidav1: nmcidav1, nrfonav1: nrfonav1, tpdocav1: tpdocav1,
            tdccjav1: tdccjav1, cdufava1: cdufava1, emailav1: emailav1, nrctaav2: nrctaav2,
            nrcpfav2: nrcpfav2, cpfcjav2: cpfcjav2, nrcepav2: nrcepav2, nrender2: nrender2,
            nrcxaps2: nrcxaps2, complen2: complen2, nmdaval2: nmdaval2, dsdocav2: dsdocav2,
            nmdcjav2: nmdcjav2, doccjav2: doccjav2, ende1av2: ende1av2, ende2av2: ende2av2,
            nmcidav2: nmcidav2, nrfonav2: nrfonav2, tpdocav2: tpdocav2, tdccjav2: tdccjav2,
            cdufava2: cdufava2, emailav2: emailav2, nmextttl: nmextttl, tpdpagto: tpdpagto,
            tpenvcrd: tpenvcrd, executandoProdutos: executandoProdutos, dsrepres: dsrepres,
            dsrepinc: dsrepinc, flgdebit: flgdebit, nrctrcrd: nrctrcrd, cddopcao: cddopcao, 
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
				log4console("executando a resposta");
				log4console(response);
                eval(response);
            } catch (error) {
				log4console("Eitaaaa, caiu no catch");
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

/*******************************************************************************************************************/
/*****************************************          OPÇÃO IMPRIMIR	**********************************************/
/******************************************************************************************************************/

// Função para mostrar a opção Imprimir do cartão
function opcaoImprimir() {
    if ((inpessoa == 1 && nrctrcrd == 0) ||
        (inpessoa == 2 && nrctrhcj == 0)) {
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Imprimir ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/imprimir.php",
        dataType: "html",
        data: {
            cdadmcrd: cdadmcrd,
            inpessoa: inpessoa,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });

}

// Função para gerar impressão em PDF
function gerarImpressao(tpimpressao, idimpres, administradora, nrcontrato, codmotivo) {

// Se impressao for chamada pela opcao imprimir
    if (tpimpressao == 1) {
        if (inpessoa == 1) {
            var contrato = nrctrcrd;
        } else {
			// Se for termo de emissão PJ e não existir nenhum cartão cadastrado não gera impressão
            if (idimpres == 10) {
                if (nrctrcrd == 0) {
                    return false;
                } else {
                    var contrato = nrctrcrd;
                }
            } else {
                var contrato = nrctrhcj;
            }
        }
    } else {
        var contrato = nrcontrato;
    }

	// Se administrador vier em branco é porque deve ser pego do cartão selecionado - alteração limite crédito
    if (administradora == 0 || administradora == "") {
        administradora = cdadmcrd;
    }

    if (idimpres == 0) { // Utilizado para emitir contratos
        if (administradora == 1) {  // Administradora Credicard
            idimpres = 5;
        } else if (administradora == 2) {  // BRADESCO/VISA
            idimpres = 2;
        } else if (administradora == 3) {  // CECRED/VISA
            idimpres = inpessoa == 1 ? 2 : 9;
        } else if (administradora >= 83 && administradora <= 88) {  // MULTIPLO BB
            idimpres = 7;
        }
    }

    if ((idimpres == 2) || (idimpres == 5) || (idimpres == 7)) {
        var msg = "contrato";
    } else if (idimpres == 4) {
        var msg = "termo de cancelamento/bloqueio";
    } else if (idimpres == 3) {
        var msg = "proposta";
    } else if (idimpres == 1 || idimpres == 14) { // PF ou PJ
        var msg = "proposta de altera&ccedil;&atilde;o de limite";
    } else if (idimpres == 6) {
        var msg = "termo de solicita&ccedil;&atilde;o de segunda via";
    } else if (idimpres == 8 || idimpres == 15) {
        var msg = "termo de altera&ccedil;&atilde;o de data de vencimento";
    } else if (idimpres == 9) {
        var msg = "termo de entrega";
    } else if (idimpres == 10) {
        var msg = "termo de emiss&atilde;o";
    } else if (idimpres == 11) {
        var msg = "termo de solicita&ccedil;&atilde;o de segunda via de cart&atilde;o";
    } else if (idimpres == 12) {
        var msg = "termo de solicita&ccedil;&atilde;o de segunda via de senha";
    } else if (idimpres == 13) {
        var msg = "termo de cancelamento";
    } else if (idimpres == 16 || idimpres == 17) {
//caso venha com id 17, referente a pessoa fisica,
//se for com id 16, referente a pessoa juridica
        var msg = "termo de encerramento";
        if (idimpres == 17) {
            idimpres = 4;
        } else {
            idimpres = 16;
        }
    } else if (idimpres == 18) {
        var msg = "termo de entrega";
    }

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/valida_imprimir_dados.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            eval(response);
        }
    });

    $("#nrdconta", "#frmImprimir").val(nrdconta);
    $("#idimpres", "#frmImprimir").val(idimpres);
    $("#cdadmcrd", "#frmImprimir").val(administradora);
    $("#nrctrcrd", "#frmImprimir").val(contrato);
    $("#cdmotivo", "#frmImprimir").val(codmotivo);

    var action = $('#frmImprimir').attr("action");
    var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";

    if (callafterCartaoCredito != '') {
        callafter = callafterCartaoCredito;
        callafterCartaoCredito = '';
    }

    carregaImpressaoAyllos("frmImprimir", action, callafter);

}

/*******************************************************************************************************************/
/*****************************************          OPÇÃO CONSULTAR         *********************************************/
/******************************************************************************************************************/

// Função para consultar cartão de crédito
function consultaCartao() {
    if (nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, consultando dados do cart&atilde;o de cr&eacute;dito ...");

    // Saimos da tela principal
    flgPrincipal = false;

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/consultar_dados_cartao.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });
}

// Função para mostrar os avalistas na consulta de um cartão de crédito
function mostraAvais() {

	// ALTERAÇÃO 001
    nomeForm = 'frmDadosCartaoAvais';

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando avalistas do cart&atilde;o de cr&eacute;dito ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/consultar_dados_cartao_avais.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });
}

//Função para mostrar os ultimos débitos na consulta de um cartão
function mostraUltDebitos() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando &uacute;ltimos d&eacute;bitos do cart&atilde;o de cr&eacute;dito ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/consultar_dados_cartao_ultimos_debitos.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrcrcard: nrcrcard.replace(/\./g, ""),
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });
}

/***************************************************************************************************************/
/*****************************************          OPÇÃO LIBERAR         *********************************************/
/**************************************************************************************************************/
function opcaoLiberar() {

    var flgliber = $('#flgliber', '#divCartoes').val();

    if (nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Se nao esta liberado (Transferencia de PAC)
    if (flgliber == "no") {
        showError("error", dsdliber, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Liberar ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/liberar.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            cdadmcrd: cdadmcrd,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });

}

//Função para fazer liberação do cartão
//se idconfir = 1 ele executa o script php pra confirmar com mensagem diferenciada para conta encerrada
function liberacaoCartao(idconfir) {

    var nrcpfcgc = normalizaNumero($("#nrcpfcgc", "#frmCabAtenda").val());

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, confirmando libera&ccedil;&atilde;o do cart&atilde;o de cr&eacute;dito ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/liberar_liberacao.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            inconfir: idconfir,
            nrcpfcgc: nrcpfcgc,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });
}

// Função para desfazer Liberação do cartão de crédito
function desfazLiberacaoCartao() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, desfazendo libera&ccedil;&atilde;o do cart&atilde;o de cr&eacute;dito ...");

	// Executa script de cadastro de proposta de cartão através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/liberar_desfaz_liberacao.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

/***************************************************************************************************************/
/*****************************************      OPÇÃO  ENTREGAR        *********************************************/
/**************************************************************************************************************/
function opcaoEntregar() {

    var flgliber = $('#flgliber', '#divCartoes').val();

// Se nao esta liberado (Transferencia de PAC)
    if (flgliber == "no") {
        showError("error", dsdliber, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Entregar ...");

    if ((cdadmcrd >= 10) && (cdadmcrd <= 80)) {
        opcaoEntregarCartaoBancoob();
    } else {
        opcaoEntregarCartaoNormal();
    }
}

/* Funcao para carregar o formulario de entrega de cartao com Chip/Sem Chip */
function opcaoEntregarCartaoBancoob() {

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/entregar_cartao_bancoob.php",
        dataType: "html",
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });
}

/* Funcao para carregar o formulario de entrega de cartao sem chip */
function opcaoEntregarCartaoNormal() {

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/entregar.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            cdadmcrd: cdadmcrd,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });
}

// Função para mostrar a opção de informar os dados do cartão| numero e data de validade
function dadosEntrega() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados da entrega do cart&atilde;o de cr&eacute;dito ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/entregar_dados.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            inpessoa: inpessoa,
            nrctrcrd: nrctrcrd,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });
}

// Função para validar os dados informados do cartão| numero do cartão
function confirmaDadosEntrega() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando informa&ccedil;&otilde;es ...");

    var repsolic = inpessoa == 1 ? "" : $("#repsolic option:selected", "#frmEntregarDados").text();

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/entregar_dados_confirma.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            repsolic: repsolic,
            nrcrcard: retiraCaracteres($("#cfseqca", "#frmEntregarDados").val(), "0123456789", true),
            dtvalida: retiraCaracteres($("#dtvalida", "#frmEntregarDados").val(), "0123456789", true),
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao3").html(response);
        }
    });
}

// Função para validar entrega cartão de crédito
function entregaCartao() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando entrega do cart&atilde;o de cr&eacute;dito ...");

    var repsolic = inpessoa == 1 ? "" : $("#repsolic option:selected", "#frmEntregarDados").text();

	// Executa script de cadastro de proposta de cartão através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/entregar_valida_entrega.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            repsolic: repsolic,
            nrcrcard: retiraCaracteres($("#cfseqca", "#frmEntregarDados").val(), "0123456789", true),
            nrcrcard2: retiraCaracteres($("#cfseqca", "#frmConfirmaDados").val(), "0123456789", true),
            dtvalida: retiraCaracteres($("#dtvalida", "#frmEntregarDados").val(), "0123456789", true),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

/*	Entrega do Cartão Bradesco/... */
function efetuaEntregaCartaoNormal() {
    iNumeroCPF = inpessoa == 1 ? "0" : $("#repsolic", "#frmEntregarDados").val();
    iNumeroCartao = retiraCaracteres($("#cfseqca", "#frmEntregarDados").val(), "0123456789", true);
    dDataValidade = retiraCaracteres($("#dtvalida", "#frmEntregarDados").val(), "0123456789", true);
    efetuaEntregaCartao();
}

/*	Entrega do Cartão CECRED */
function efetuaEntregaCartaoComChip() {
    iNumeroCPF = 0;
    iNumeroCartao = retiraCaracteres($("#nrcrcard", "#frmEntregaCartaoBancoob").val(), "0123456789", true);
    dDataValidade = retiraCaracteres($("#dtvalida", "#frmEntregaCartaoBancoob").val(), "0123456789", true);

// Puro credito, somente sera feito a gravacao do cartao
    if (flpurcrd) {
        efetuaEntregaCartao();
    } else {
// Carrega a tela para informar a senha numerica no TAA
        entregaCartaoCarregaTelaSenhaNumericaTaa();
    }
}

/*	Entrega do Cartão CECRED */
function efetuaEntregaCartaoSemChip() {
    iNumeroCPF = 0;
    iNumeroCartao = retiraCaracteres($("#nrcrcard", "#frmEntregaCartaoBancoob").val(), "0123456789", true);
    dDataValidade = retiraCaracteres($("#dtvalida", "#frmEntregaCartaoBancoob").val(), "0123456789", true);

// Puro credito, somente sera feito a gravacao do cartao
    if (flpurcrd) {
        efetuaEntregaCartao();
    } else {
// Carrega a tela para informar a senha numerica no TAA
        entregaCartaoCarregaTelaSenhaNumericaTaa();
    }
}

// Efetua entrega do cartão de crédito
function efetuaEntregaCartao() {

    var nrcpfcgc = normalizaNumero($("#nrcpfcgc", "#frmCabAtenda").val());

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando entrega do cart&atilde;o de cr&eacute;dito ...");

	// Executa script de cadastro de proposta de cartão através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/entregar_entregarcartao.php",
        data: {
            nrdconta: nrdconta,
            inpessoa: inpessoa,
            nrctrcrd: nrctrcrd,
            cdadmcrd: cdadmcrd,
            nrcpfrep: iNumeroCPF,
            nrcrcard: iNumeroCartao,
            dtvalida: dDataValidade,
            nrcpfcgc: nrcpfcgc,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Desfaz entrega do cartão de crédito
function desfazEntregaCartao(idconfir) {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, desfazendo entrega do cart&atilde;o de cr&eacute;dito ...");

	// Executa script de cadastro de proposta de cartão através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/entregar_desfazentrega.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            inconfir: idconfir,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

/**************************************************************************************************************/
/*****************************************          OPÇÃO ALTERAR         ********************************************/
/**************************************************************************************************************/
// Função para mostrar a opção Alterar do cartão
function opcaoAlterar() {

    var flgliber = $('#flgliber', '#divCartoes').val();

    if (nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Se nao esta liberado (Transferencia de PAC)
    if (flgliber == "no") {
        showError("error", dsdliber, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Alterar ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/alterar.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });
}

// Função para mostrar a opção de alterar o Limite de débito
function alteraLimiteDebito() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es do Limite de D&eacute;bito do cart&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/alterar_limitedebito_carregadados.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            nrcrcard: nrcrcard,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });
}

// Função para alterar limite de débito do cartão
function alteraLimDeb() {

    var nrcpfcgc = normalizaNumero($("#nrcpfcgc", "#frmCabAtenda").val());

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, alterando limite de d&eacute;bito informado ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/alterar_limitedebito_alterar.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            vllimdeb: $("#vllimdeb", "#frmValorLimDeb").val().replace(/\./g, ""),
            nrcpfcgc: nrcpfcgc,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Função para mostrar a opção de alterar o Limite de crédito
function alteraLimiteCredito() {

	// ALTERAÇÃO 001
    nomeForm = 'frmValorLimCre';

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es do limite de cr&eacute;dito do cart&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/alterar_limitecredito_carregadados.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            inpessoa: inpessoa,
            nrctrcrd: nrctrcrd,
            nrcrcard: nrcrcard,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });
}

// Função para validar limite de crédito do cartão e mostrar os avalistas
function validaLimCre() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando limite de cr&eacute;dito do cart&atilde;o de cr&eacute;dito ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/alterar_limitecredito_validalimite.php",
        data: {
            nrdconta: nrdconta,
            inpessoa: inpessoa,
            nrctrcrd: nrctrcrd,
            repsolic: (inpessoa == 1 ? "" : $("#repsolic option:selected", "#frmValorLimCre").text()),
            vllimcrd: $("#vllimcrd", "#frmValorLimCre").val(),
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Função para alterar o limite de crédito do cartão de crédito
function alteraLimCre() {

    var nrcpfcgc = normalizaNumero($("#nrcpfcgc", "#frmCabAtenda").val());

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, alterando limite de cr&eacute;dito do cart&atilde;o ...");

	// Executa script de cadastro de proposta de cartão através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/alterar_limitecredito_alterar.php",
        data: {
            nrdconta: nrdconta,
            inpessoa: inpessoa,
            nrctrcrd: nrctrcrd,
            vllimcrd: $("#vllimcrd", "#frmValorLimCre").val().replace(/\./g, ""),
            flgimpnp: (inpessoa == 1 ? $("#flgimpnp", "#frmValorLimCre").val() : "yes"),
            nrcpfrep: (inpessoa == 1 ? "0" : $("#repsolic", "#frmValorLimCre").val()),

            nrctaav1: normalizaNumero($("#nrctaav1", "#frmValorLimCre").val()),
            nmdaval1: $("#nmdaval1", "#frmValorLimCre").val(),
            nrcpfav1: normalizaNumero($("#nrcpfav1", "#frmValorLimCre").val()),
            tpdocav1: $("#tpdocav1", "#frmValorLimCre").val(),
            dsdocav1: $("#dsdocav1", "#frmValorLimCre").val(),
            nmdcjav1: $("#nmdcjav1", "#frmValorLimCre").val(),
            cpfcjav1: normalizaNumero($("#cpfcjav1", "#frmValorLimCre").val()),
            tdccjav1: $("#tdccjav1", "#frmValorLimCre").val(),
            doccjav1: $("#doccjav1", "#frmValorLimCre").val(),
            ende1av1: $("#ende1av1", "#frmValorLimCre").val(),
            ende2av1: $("#ende2av1", "#frmValorLimCre").val(),
            nrcepav1: normalizaNumero($("#nrcepav1", "#frmValorLimCre").val()),
            nmcidav1: $("#nmcidav1", "#frmValorLimCre").val(),
            cdufava1: $("#cdufava1", "#frmValorLimCre").val(),
            nrfonav1: $("#nrfonav1", "#frmValorLimCre").val(),
            emailav1: $("#emailav1", "#frmValorLimCre").val(),
            nrender1: normalizaNumero($("#nrender1", "#frmValorLimCre").val()),
            complen1: $("#complen1", "#frmValorLimCre").val(),
            nrcxaps1: normalizaNumero($("#nrcxaps1", "#frmValorLimCre").val()),

            nrctaav2: normalizaNumero($("#nrctaav2", "#frmValorLimCre").val()),
            nmdaval2: $("#nmdaval2", "#frmValorLimCre").val(),
            nrcpfav2: normalizaNumero($("#nrcpfav2", "#frmValorLimCre").val()),
            tpdocav2: $("#tpdocav2", "#frmValorLimCre").val(),
            dsdocav2: $("#dsdocav2", "#frmValorLimCre").val(),
            nmdcjav2: $("#nmdcjav2", "#frmValorLimCre").val(),
            cpfcjav2: normalizaNumero($("#cpfcjav2", "#frmValorLimCre").val()),
            tdccjav2: $("#tdccjav2", "#frmValorLimCre").val(),
            doccjav2: $("#doccjav2", "#frmValorLimCre").val(),
            ende1av2: $("#ende1av2", "#frmValorLimCre").val(),
            ende2av2: $("#ende2av2", "#frmValorLimCre").val(),
            nrcepav2: normalizaNumero($("#nrcepav2", "#frmValorLimCre").val()),
            nmcidav2: $("#nmcidav2", "#frmValorLimCre").val(),
            cdufava2: $("#cdufava2", "#frmValorLimCre").val(),
            nrfonav2: $("#nrfonav2", "#frmValorLimCre").val(),
            emailav2: $("#emailav2", "#frmValorLimCre").val(),
            nrender2: normalizaNumero($("#nrender2", "#frmValorLimCre").val()),
            complen2: $("#complen2", "#frmValorLimCre").val(),
            nrcxaps2: normalizaNumero($("#nrcxaps2", "#frmValorLimCre").val()),
            nrcpfcgc: nrcpfcgc,

            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Função para mostrar a opção de alterar a Data de vencimento
function alteraDtVencimento(segundaVia) {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es da Data de Vencimento do cart&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/alterar_dtvenc_carregadados.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            inpessoa: inpessoa,
            nrcrcard: nrcrcard,
            cdadmcrd: cdadmcrd,
            segundaV: segundaVia,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });
}

// Função para efetuar a troca da data de vencimento
function alterarDataDeVencimento() {

    var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#frmCabAtenda').val());

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, alterando dia do d&eacute;bito do cart&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/alterar_dtvenc_alterar.php",
        data: {
            nrdconta: nrdconta,
            inpessoa: inpessoa,
            nrctrcrd: nrctrcrd,
            repsolic: (inpessoa == 1 ? "" : $("#repsolic option:selected", "#frmDtVencimento").text()),
            nrcpfrep: (inpessoa == 1 ? "0" : $("#repsolic", "#frmDtVencimento").val()),
            dddebito: $("#dddebito", "#frmDtVencimento").val(),
            nrcpfcgc: nrcpfcgc,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

/******************************************************************************************************/
/*****************************************      OPÇÃO SEGUNDA VIA      ********************************/
/******************************************************************************************************/
// Função para mostrar a opção 2via
function opcao2via() {

    var flgliber = $('#flgliber', '#divCartoes').val();

    if (nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Se nao esta liberado (Transferencia de PAC)
    if (flgliber == "no") {
        showError("error", dsdliber, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Segunda Via ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/2via.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);

            if (cdadmcrd > 9 && cdadmcrd < 81) {
                $("#btnsegct").prop("disabled", true);
                $("#btnsegct").css('cursor', 'default');
            } else {
                $("#btnsegct").prop("disabled", false);
                $("#btnsegct").css('cursor', 'pointer');
            }
        }
    });
}

// Função para mostrar a opção 2via do cartão
function opcao2viaCartao() {
    if (nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&otilde;es para Segunda Via do Cart&atilde;o...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/2via_cartao.php",
        dataType: "html",
        data: {
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });
}

// Função para mostrar a opção 2via de Senha
function opcao2viaSenha() {
    if (nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&otilde;es para Segunda Via da Senha...");

	// Cartão Bancoob
    if ((cdadmcrd >= 10) && (cdadmcrd <= 80)) {
        if (flgcchip) {
            opcao2viaSenhaCartaoChip();
        } else {
            hideMsgAguardo();
            showError("error", "Senha dever&aacute; ser alterada no SIPAGNET.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            return false;
        }
    } else {
        opcao2viaSenhaNormal();
    }
}

function opcao2viaSenhaNormal() {
	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/2via_senha.php",
        dataType: "html",
        data: {
            inpessoa: inpessoa,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });
}

function opcao2viaSenhaCartaoChip() {
	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/2via_senha_cartao_chip.php",
        dataType: "html",
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });
}

// Função para carregar opção de solicitação de segunda via de senha
function solicitar2viaSenha() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados para Segunda Via da Senha...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/2via_senha_solicitacao_carregadados.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao3").html(response);
        }
    });
}

// Função para solicitação da segunda via da senha
function efetuaSolicitacao2viaSenha() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando solicita&ccedil;&atilde;o de Segunda Via da Senha ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/2via_senha_solicitacao_efetuar.php",
        data: {
            nrdconta: nrdconta,
            cdadmcrd: cdadmcrd,
            nrctrcrd: nrctrcrd,
            inpessoa: inpessoa,
            repsolic: (inpessoa == 1 ? "" : $("#repsolic option:selected", "#frmSol2viaSenha").text()),
            nrcpfrep: (inpessoa == 1 ? "0" : $("#repsolic", "#frmSol2viaSenha").val()),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Função para carregar o motivos  da solicitação  da segunda via do cartão
function solicita2viaCartao() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados para solicita&ccedil;&atilde;o de Segunda Via do Cart&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/2via_solicitacao_carregadados.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            inpessoa: inpessoa,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao3").html(response);
        }
    });
}

//Função para alterar propriedades
function alteraMotivo() {
    var objSelectSolicitacao = document.frmSolicitacao.slmotivo;

	// pega o value da opção selecionada
    var motivo = objSelectSolicitacao.options[objSelectSolicitacao.options.selectedIndex].value;
    var metodoBlock = "blockBackground(parseInt($('#divRotina').css('z-index')))";

    if (motivo == 1) { //Defeito cartao
        $("#linkTela", "#frmSolicitacao").attr("src", UrlImagens + "botoes/concluir.gif");
        $("#linkTela", "#frmSolicitacao").unbind("click");
        $("#linkTela", "#frmSolicitacao").bind("click", function () {
            showConfirmacao('Deseja efetuar a solicita&ccedil;&atilde;o de segunda via do cart&atilde;o de cr&eacute;dito?', 'Confirma&ccedil;&atilde;o - Aimaro', 'efetuaSolicitacao2viaCartao(' + motivo + ')', metodoBlock, 'sim.gif', 'nao.gif');
            return false;
        });
    } else if (motivo == 2) { //Perda/Roubo
        $("#linkTela", "#frmSolicitacao").attr("src", UrlImagens + "botoes/concluir.gif");
        $("#linkTela", "#frmSolicitacao").unbind("click");
        $("#linkTela", "#frmSolicitacao").bind("click", function () {
            showConfirmacao('Deseja efetuar a solicita&ccedil;&atilde;o de segunda via do cart&atilde;o de cr&eacute;dito?', 'Confirma&ccedil;&atilde;o - Aimaro', 'efetuaSolicitacao2viaCartao(' + motivo + ')', metodoBlock, 'sim.gif', 'nao.gif');
            return false;
        });
    } else if (motivo == 5) { //mudança de nome
        $("#linkTela", "#frmSolicitacao").attr("src", UrlImagens + "botoes/prosseguir.gif");
        $("#linkTela", "#frmSolicitacao").unbind("click");
        $("#linkTela", "#frmSolicitacao").bind("click", function () {
            $("#divMotivoSolicitacao").css("display", "none");
            $("#divNovoNome").css("display", "block");
            $("#nmtitcrd", "#frmSolicitacao").focus();
            return false;
        });
    } else if (motivo == 7) { // Data de vencimento
        $("#linkTela", "#frmSolicitacao").attr("src", UrlImagens + "botoes/prosseguir.gif");
        $("#linkTela", "#frmSolicitacao").unbind("click");
        $("#linkTela", "#frmSolicitacao").bind("click", function () {
            $("#divMotivoSolicitacao").css("display", "none");
            alteraDtVencimento("true");
            return false;
        });
    }
}

function efetuaSolicitacao2viaCartao(motivo) {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando solicita&ccedil;&atilde;o de Segunda Via do Cart&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/2via_solicitacao_efetuar.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            inpessoa: inpessoa,
            cdmotivo: motivo,
            cdadmcrd: cdadmcrd,
            nmtitcrd: $("#nmtitcrd", "#frmSolicitacao").val(),
            repsolic: (inpessoa == 1 ? "" : $("#repsolic option:selected", "#frmSolicitacao").text()),
            nrcpfrep: (inpessoa == 1 ? "0" : $("#repsolic", "#frmSolicitacao").val()),
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Função para mostrar a opção da entrega da segunda via do cartão
function entrega2viaCartao() {

	// ALTERAÇÃO 001
    nomeForm = 'frmEntrega2via';

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados para entrega da Segunda Via do Cart&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/2via_entrega_carregadados.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            inpessoa: inpessoa,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao3").html(response);
        }
    });
}

// Função para validar os dados informados e mostrar os dados dos avalistas
function validaMostraavaisEntrega2viaCartao() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando informa&ccedil;&otilde;es ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/2via_entrega_validadados.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            inpessoa: inpessoa,
            nrcrcard: retiraCaracteres($("#cfseqca", "#frmEntrega2via").val(), "0123456789", true),
            dtvalida: retiraCaracteres($("#dtvalida", "#frmEntrega2via").val(), "0123456789", true),
            flgimpnp: $("#flgimpnp", "#frmEntrega2via").val(),
            repsolic: (inpessoa == 1 ? "" : $("#repsolic option:selected", "#frmEntrega2via").text()),
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Efetuar a entrega da segunda via do cartão
function efetuaEntrega2viaCartao() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando entrega da Segunda Via do Cart&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/2via_entrega_efetuar.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            inpessoa: inpessoa,
            cdadmcrd: cdadmcrd,
            nrcrcard: retiraCaracteres($("#cfseqca", "#frmEntrega2via").val(), "0123456789", true),
            dtvalida: retiraCaracteres($("#dtvalida", "#frmEntrega2via").val(), "0123456789", true),
            flgimpnp: $("#flgimpnp", "#frmEntrega2via").val(),
            repsolic: (inpessoa == 1 ? "" : $("#repsolic option:selected", "#frmEntrega2via").text()),
            nrcpfrep: (inpessoa == 1 ? "0" : $("#repsolic", "#frmEntrega2via").val()),

            nrctaav1: normalizaNumero($("#nrctaav1", "#frmEntrega2via").val()),
            nmdaval1: $("#nmdaval1", "#frmEntrega2via").val(),
            nrcpfav1: normalizaNumero($("#nrcpfav1", "#frmEntrega2via").val()),
            tpdocav1: $("#tpdocav1", "#frmEntrega2via").val(),
            dsdocav1: $("#dsdocav1", "#frmEntrega2via").val(),
            nmdcjav1: $("#nmdcjav1", "#frmEntrega2via").val(),
            cpfcjav1: normalizaNumero($("#cpfcjav1", "#frmEntrega2via").val()),
            tdccjav1: $("#tdccjav1", "#frmEntrega2via").val(),
            doccjav1: $("#doccjav1", "#frmEntrega2via").val(),
            ende1av1: $("#ende1av1", "#frmEntrega2via").val(),
            ende2av1: $("#ende2av1", "#frmEntrega2via").val(),
            nrcepav1: normalizaNumero($("#nrcepav1", "#frmEntrega2via").val()),
            nmcidav1: $("#nmcidav1", "#frmEntrega2via").val(),
            cdufava1: $("#cdufava1", "#frmEntrega2via").val(),
            nrfonav1: $("#nrfonav1", "#frmEntrega2via").val(),
            emailav1: $("#emailav1", "#frmEntrega2via").val(),
            nrender1: $("#nrender1", "#frmEntrega2via").val(),
            complen1: $("#complen1", "#frmEntrega2via").val(),
            nrcxaps1: $("#nrcxaps1", "#frmEntrega2via").val(),

            nrctaav2: normalizaNumero($("#nrctaav2", "#frmEntrega2via").val()),
            nmdaval2: $("#nmdaval2", "#frmEntrega2via").val(),
            nrcpfav2: normalizaNumero($("#nrcpfav2", "#frmEntrega2via").val()),
            tpdocav2: $("#tpdocav2", "#frmEntrega2via").val(),
            dsdocav2: $("#dsdocav2", "#frmEntrega2via").val(),
            nmdcjav2: $("#nmdcjav2", "#frmEntrega2via").val(),
            cpfcjav2: normalizaNumero($("#cpfcjav2", "#frmEntrega2via").val()),
            tdccjav2: $("#tdccjav2", "#frmEntrega2via").val(),
            doccjav2: $("#doccjav2", "#frmEntrega2via").val(),
            ende1av2: $("#ende1av2", "#frmEntrega2via").val(),
            ende2av2: $("#ende2av2", "#frmEntrega2via").val(),
            nrcepav2: normalizaNumero($("#nrcepav2", "#frmEntrega2via").val()),
            nmcidav2: $("#nmcidav2", "#frmEntrega2via").val(),
            cdufava2: $("#cdufava2", "#frmEntrega2via").val(),
            nrfonav2: $("#nrfonav2", "#frmEntrega2via").val(),
            emailav2: $("#emailav2", "#frmEntrega2via").val(),
            nrender2: $("#nrender2", "#frmEntrega2via").val(),
            complen2: $("#complen2", "#frmEntrega2via").val(),
            nrcxaps2: $("#nrcxaps2", "#frmEntrega2via").val(),

            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Desfazer solicitação da segunda via do cartão
function desfazSolicitacao2viaCartao() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, desfazendo solicita&ccedil;&atilde;o de Segunda Via do Cart&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/2via_desfazsolicitacao.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Desfazer solicitação da segunda via da senha
function desfazSolicitacao2viaSenha() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, desfazendo solicita&ccedil;&atilde;o de Segunda Via do Cart&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/2via_senha_desfazsolicitacao.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

/***************************************************************************************************************/
/*****************************************          OPÇÃO RENOVAR         ********************************************/
/**************************************************************************************************************/
// Função para mostrar a opção de renovação do cartão
function opcaoRenovar() {

	// ALTERAÇÃO 001
    nomeForm = 'frmNovaValidade';

    var flgliber = $('#flgliber', '#divCartoes').val();

    if (nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Se nao esta liberado (Transferencia de PAC)
    if (flgliber == "no") {
        showError("error", dsdliber, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados de renova&ccedil;&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/renovar_carregadados.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            nrcrcard: nrcrcard,
            inpessoa: inpessoa,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });
}

function validaDadosRenovacao() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando dados de renova&ccedil;&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/renovar_valida_mostraavais.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            inpessoa: inpessoa,
            dtvalida: retiraCaracteres($("#dtvalida", "#frmNovaValidade").val(), "0123456789", true),
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function efetuaRenovacaoCartao() {

    var nrcpfcgc = normalizaNumero($("#nrcpfcgc", "#frmCabAtenda").val());

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando renova&ccedil;&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/renovar_efetuarenovacao.php",
        data: {

            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            inpessoa: inpessoa,
            flgimpnp: (inpessoa == 1 ? $("#flgimpnp", "#frmNovaValidade").val() : "yes"),
            dtvalida: retiraCaracteres($("#dtvalida", "#frmNovaValidade").val(), "0123456789", true),
            nrctaav1: normalizaNumero($("#nrctaav1", "#frmNovaValidade").val()),
            nmdaval1: $("#nmdaval1", "#frmNovaValidade").val(),
            nrcpfav1: normalizaNumero($("#nrcpfav1", "#frmNovaValidade").val()),
            tpdocav1: $("#tpdocav1", "#frmNovaValidade").val(),
            dsdocav1: $("#dsdocav1", "#frmNovaValidade").val(),
            nmdcjav1: $("#nmdcjav1", "#frmNovaValidade").val(),
            cpfcjav1: normalizaNumero($("#cpfcjav1", "#frmNovaValidade").val()),
            tdccjav1: $("#tdccjav1", "#frmNovaValidade").val(),
            doccjav1: $("#doccjav1", "#frmNovaValidade").val(),
            ende1av1: $("#ende1av1", "#frmNovaValidade").val(),
            ende2av1: $("#ende2av1", "#frmNovaValidade").val(),
            nrcepav1: normalizaNumero($("#nrcepav1", "#frmNovaValidade").val()),
            nmcidav1: $("#nmcidav1", "#frmNovaValidade").val(),
            cdufava1: $("#cdufava1", "#frmNovaValidade").val(),
            nrfonav1: $("#nrfonav1", "#frmNovaValidade").val(),
            emailav1: $("#emailav1", "#frmNovaValidade").val(),
            nrender1: normalizaNumero($("#nrender1", "#frmNovaValidade").val()),
            complen1: $("#complen1", "#frmNovaValidade").val(),
            nrcxaps1: normalizaNumero($("#nrcxaps1", "#frmNovaValidade").val()),

            nrctaav2: normalizaNumero($("#nrctaav2", "#frmNovaValidade").val()),
            nmdaval2: $("#nmdaval2", "#frmNovaValidade").val(),
            nrcpfav2: normalizaNumero($("#nrcpfav2", "#frmNovaValidade").val()),
            tpdocav2: $("#tpdocav2", "#frmNovaValidade").val(),
            dsdocav2: $("#dsdocav2", "#frmNovaValidade").val(),
            nmdcjav2: $("#nmdcjav2", "#frmNovaValidade").val(),
            cpfcjav2: normalizaNumero($("#cpfcjav2", "#frmNovaValidade").val()),
            tdccjav2: $("#tdccjav2", "#frmNovaValidade").val(),
            doccjav2: $("#doccjav2", "#frmNovaValidade").val(),
            ende1av2: $("#ende1av2", "#frmNovaValidade").val(),
            ende2av2: $("#ende2av2", "#frmNovaValidade").val(),
            nrcepav2: normalizaNumero($("#nrcepav2", "#frmNovaValidade").val()),
            nmcidav2: $("#nmcidav2", "#frmNovaValidade").val(),
            cdufava2: $("#cdufava2", "#frmNovaValidade").val(),
            nrfonav2: $("#nrfonav2", "#frmNovaValidade").val(),
            emailav2: $("#emailav2", "#frmNovaValidade").val(),
            nrender2: normalizaNumero($("#nrender2", "#frmNovaValidade").val()),
            complen2: $("#complen2", "#frmNovaValidade").val(),
            nrcxaps2: normalizaNumero($("#nrcxaps2", "#frmNovaValidade").val()),
            nrcpfcgc: nrcpfcgc,

            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

}

/**************************************************************************************************************/
/*********************************          OPÇÃO ENCERRAMENTO         *********************************/
/*************************************************************************************************************/
// Função para mostrar a opção Encerrar do cartão
function opcaoEncerrar() {

    var flgliber = $('#flgliber', '#divCartoes').val();

    if (nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Se nao esta liberado (Transferencia de PAC)
    if (flgliber == "no") {
        showError("error", dsdliber, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Encerramento ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/encerramento.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });
}

//desfazer o encerramento do cartao de credito
function desfazEncCartao(indposic) {

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, desfazendo encerramento do cart&atilde;o de cr&eacute;dito ...");

	// Executa script de cadastro de proposta de cartão através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/encerramento_desfazer.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            indposic: indposic,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Função para realizar o encerramento do cartao
function encerrarCart(indposic) {

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando motivos de encerramento ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/encerramento_infos.php",
        dataType: "html",
        data: {
            nrcrcard: nrcrcard,
            nrctrcrd: nrctrcrd,
            inpessoa: inpessoa,
            nrdconta: nrdconta,
            indposic: indposic,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });
}

function encerramentoCartao(indposic) {

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, encerrando cart&atilde;o de cr&eacute;dito ...");

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/encerramento_cartao.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            inpessoa: inpessoa,
            nrcpfrep: (inpessoa == 1 ? "0" : $("#repsolic", "#frmEncCartao").val()),
            repsolic: (inpessoa == 1 ? "" : $("#repsolic option:selected", "#frmEncCartao").text()),
            indposic: $("#tpencerr", "#frmEncCartao").val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

/**************************************************************************************************************/
/*********************************          OPÇÃO CANCELAMENTO/BLOQUEIO         *********************************/
/*************************************************************************************************************/

function cancelaContrato(){
	var objTosend = {
		nrctrcrd : nrctrcrd,
		nrdconta : nrdconta
	};
	showMsgAguardo();
	$.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + "telas/atenda/cartao_credito/cancelamento_contrato.php",
        data: objTosend,
        error: function(objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            hideMsgAguardo();			
			
			eval(response);
			
            return false;
        }
    });
}


// Função para mostrar a opção CancBloq do cartão
function opcaoCancBloq() {
	
	
	if(cdadmcrd >= 11 && cdadmcrd < 17){
		//todo implementar canclamento cecred
		 showConfirmacao("Deseja cancelar este contrato? ", "Confirma&ccedil;&atilde;o - Aimaro", "cancelaContrato();", "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
		return;
	}
    var flgliber = $('#flgliber', '#divCartoes').val();

    if (executandoImpedimentos){
        hideMsgAguardo();
        showError("error", "O cancelamento do cart&atilde;o deve ser efetuado via SIPAGNET.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Se nao esta liberado (Transferencia de PAC)
    if (flgliber == "no") {
        showError("error", dsdliber, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Cancelamento/Bloqueio ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/cancelamento_bloqueio.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });
}

// Função para mostrar a opção de escolher o tipo de Cancelamento/Bloqueio
function tipoCancBlq(cancbloq) {
    if (cancbloq == 1) {
        var msgCancBlq = "cancelamento";
    } else {
        var msgCancBlq = "bloqueio";
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando motivos de " + msgCancBlq + " ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/cancelamento_bloqueio_tipodecancblq.php",
        dataType: "html",
        data: {
            nrcrcard: nrcrcard,
            nrctrcrd: nrctrcrd,
            inpessoa: inpessoa,
            nrdconta: nrdconta,
            cancbloq: cancbloq,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });
}

function cancelarBloquearCartao(indposic) {
    if (indposic == 1) {
        var msgCancBlq = "cancelando";
    } else {
        var msgCancBlq = "bloqueando";
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, " + msgCancBlq + " cart&atilde;o de cr&eacute;dito ...");

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/cancelamento_bloqueio_cancelabloqueia.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            inpessoa: inpessoa,
            nrcpfrep: (inpessoa == 1 ? "0" : $("#repsolic", "#frmCanBlqCartao").val()),
            repsolic: (inpessoa == 1 ? "" : $("#repsolic option:selected", "#frmCanBlqCartao").text()),
            indposic: $("#tpcanblq", "#frmCanBlqCartao").val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function desfazCancBlqCartao(indposic) {
    if (indposic == 2) {
        var msgCancBlq = "desbloqueando";
    } else {
        var msgCancBlq = "desfazendo cancelamento de";
    }
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, " + msgCancBlq + " cart&atilde;o de cr&eacute;dito ...");

	// Executa script de cadastro de proposta de cartão através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/cancelamento_bloqueio_desfazcancblq.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            indposic: indposic,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

/**************************************************************************************************************/
/*****************************************      OPÇÃO EXCLUIR      ********************************************/
/**************************************************************************************************************/
// Função para fazer a chamada da exclusão
function opcaoExcluir() {

    var flgliber = $('#flgliber', '#divCartoes').val();

    if (nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Se nao esta liberado (Transferencia de PAC)
    if (flgliber == "no") {
        showError("error", dsdliber, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    showConfirmacao("Deseja excluir o cart&atilde;o de cr&eacute;dito?", "Confirma&ccedil;&atilde;o - Aimaro", "excluiCartao();", "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");

}

// Função para excluir cartão de crédito
function excluiCartao(contrato) {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, excluindo cart&atilde;o de cr&eacute;dito ...");

	// Executa script de cadastro de proposta de cartão através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/excluir_cartao.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                idAnt = 999;
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

/******************************************************************************************************************/
/*****************************************      OPÇÃO HABILITAR      **********************************************/
/******************************************************************************************************************/

// Função para mostrar a opção Imprimir do cartão
function opcaoHabilitar() {

	// ALTERAÇÃO 001
    nomeForm = 'frmHabilitaCartao';

    var flgliber = $('#flgliber', '#divCartoes').val();

// Se nao esta liberado (Transferencia de PAC)
    if (flgliber == "no") {
        showError("error", dsdliber, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Habilitar ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/habilitar.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });
}

// Função para carregar dados do representante
function carregarRepresentante(cddopcao, idrepres, nrcpfrep) {

	// Carrega conteúdo da opção através de ajax
	if(inpessoa == 2)
		return;
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, verificando representante ...");
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/representantes_carregar.php",
        data: {
            cddopcao: cddopcao,
            idrepres: idrepres,
            nrcpfrep: nrcpfrep.replace(/\./g, "").replace(/\-/g, ""),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
				hideMsgAguardo();
                eval(response);
				
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Função para validar dados da habilitação
function validarDadosHabilita() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando dados ...");

    var vllimglb = $("#vllimglb", "#frmHabilitaCartao").val().replace(/\./g, "");
    var flgativo = $("#flgativo", "#frmHabilitaCartao").val();
    var nrcpfpri = $("#nrcpfpri", "#frmHabilitaCartao").val().replace(/\./g, "").replace(/\-/g, "");
    var nrcpfseg = $("#nrcpfseg", "#frmHabilitaCartao").val().replace(/\./g, "").replace(/\-/g, "");
    var nrcpfter = $("#nrcpfter", "#frmHabilitaCartao").val().replace(/\./g, "").replace(/\-/g, "");
    var nmpespri = $("#nmpespri", "#frmHabilitaCartao").val();
    var nmpesseg = $("#nmpesseg", "#frmHabilitaCartao").val();
    var nmpester = $("#nmpester", "#frmHabilitaCartao").val();
    var dtnaspri = $("#dtnaspri", "#frmHabilitaCartao").val();
    var dtnasseg = $("#dtnasseg", "#frmHabilitaCartao").val();
    var dtnaster = $("#dtnaster", "#frmHabilitaCartao").val();

    if (flgativo == "yes" && (vllimglb == "" || !validaNumero(vllimglb, true, 0, 0))) {
        hideMsgAguardo();
        showError("error", "Valor do limite empresarial inv&aacute;lido.", "Alerta - Aimaro", "$('#vllimglb','#frmHabilitaCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (nrcpfpri == "" || !validaNumero(nrcpfpri, false, 0, 0)) {
        hideMsgAguardo();
        showError("error", "CPF inv&aacute;lido.", "Alerta - Aimaro", "$('#nrcpfpri','#frmHabilitaCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (nrcpfseg == "" || !validaNumero(nrcpfseg, false, 0, 0)) {
        hideMsgAguardo();
        showError("error", "CPF inv&aacute;lido.", "Alerta - Aimaro", "$('#nrcpfseg','#frmHabilitaCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (nrcpfter == "" || !validaNumero(nrcpfter, false, 0, 0)) {
        hideMsgAguardo();
        showError("error", "CPF inv&aacute;lido.", "Alerta - Aimaro", "$('#nrcpfter','#frmHabilitaCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (dtnaspri != "" && !validaData(dtnaspri)) {
        hideMsgAguardo();
        showError("error", "Data de nascimento inv&aacute;lida.", "Alerta - Aimaro", "$('#dtnaspri','#frmResgate').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (dtnasseg != "" && !validaData(dtnasseg)) {
        hideMsgAguardo();
        showError("error", "Data de nascimento inv&aacute;lida.", "Alerta - Aimaro", "$('#dtnasseg','#frmResgate').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (dtnaster != "" && !validaData(dtnaster)) {
        hideMsgAguardo();
        showError("error", "Data de nascimento inv&aacute;lida.", "Alerta - Aimaro", "$('#dtnaster','#frmResgate').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/habilitar_validar.php",
        data: {
            nrdconta: nrdconta,
            vllimglb: vllimglb,
            flgativo: flgativo,
            nrcpfpri: nrcpfpri,
            nrcpfseg: nrcpfseg,
            nrcpfter: nrcpfter,
            nmpespri: nmpespri,
            nmpesseg: nmpesseg,
            nmpester: nmpester,
            dtnaspri: dtnaspri,
            dtnasseg: dtnasseg,
            dtnaster: dtnaster,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function gravarDadosHabilitacao() {
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, gravando dados de habilita&ccedil;&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/habilitar_gravar.php",
        data: {
            nrdconta: nrdconta,

			/** Dados de habilitação **/ 
            vllimglb: retiraCaracteres($("#vllimglb", "#frmHabilitaCartao").val(), "0123456789,", true),
            flgativo: $("#flgativo", "#frmHabilitaCartao").val(),
            nrcpfpri: normalizaNumero($("#nrcpfpri", "#frmHabilitaCartao").val()),
            nrcpfseg: normalizaNumero($("#nrcpfseg", "#frmHabilitaCartao").val()),
            nrcpfter: normalizaNumero($("#nrcpfter", "#frmHabilitaCartao").val()),
            nmpespri: $("#nmpespri", "#frmHabilitaCartao").val(),
            nmpesseg: $("#nmpesseg", "#frmHabilitaCartao").val(),
            nmpester: $("#nmpester", "#frmHabilitaCartao").val(),
            dtnaspri: $("#dtnaspri", "#frmHabilitaCartao").val(),
            dtnasseg: $("#dtnasseg", "#frmHabilitaCartao").val(),
            dtnaster: $("#dtnaster", "#frmHabilitaCartao").val(),

            /** Dados do primeiro avalista **/
            nrctaav1: normalizaNumero($("#nrctaav1", "#frmHabilitaCartao").val()),
            nmdaval1: $("#nmdaval1", "#frmHabilitaCartao").val(),
            nrcpfav1: normalizaNumero($("#nrcpfav1", "#frmHabilitaCartao").val()),
            tpdocav1: $("#tpdocav1", "#frmHabilitaCartao").val(),
            dsdocav1: $("#dsdocav1", "#frmHabilitaCartao").val(),
            nmdcjav1: $("#nmdcjav1", "#frmHabilitaCartao").val(),
            cpfcjav1: normalizaNumero($("#cpfcjav1", "#frmHabilitaCartao").val()),
            tdccjav1: $("#tdccjav1", "#frmHabilitaCartao").val(),
            doccjav1: $("#doccjav1", "#frmHabilitaCartao").val(),
            ende1av1: $("#ende1av1", "#frmHabilitaCartao").val(),
            ende2av1: $("#ende2av1", "#frmHabilitaCartao").val(),
            nrcepav1: normalizaNumero($("#nrcepav1", "#frmHabilitaCartao").val()),
            nmcidav1: $("#nmcidav1", "#frmHabilitaCartao").val(),
            cdufava1: $("#cdufava1", "#frmHabilitaCartao").val(),
            nrfonav1: $("#nrfonav1", "#frmHabilitaCartao").val(),
            emailav1: $("#emailav1", "#frmHabilitaCartao").val(),
            nrender1: normalizaNumero($("#nrender1", "#frmHabilitaCartao").val()),
            complen1: $("#complen1", "#frmHabilitaCartao").val(),
            nrcxaps1: normalizaNumero($("#nrcxaps1", "#frmHabilitaCartao").val()),

            /** Dados do segundo avalista **/
            nrctaav2: normalizaNumero($("#nrctaav2", "#frmHabilitaCartao").val()),
            nmdaval2: $("#nmdaval2", "#frmHabilitaCartao").val(),
            nrcpfav2: normalizaNumero($("#nrcpfav2", "#frmHabilitaCartao").val()),
            tpdocav2: $("#tpdocav2", "#frmHabilitaCartao").val(),
            dsdocav2: $("#dsdocav2", "#frmHabilitaCartao").val(),
            nmdcjav2: $("#nmdcjav2", "#frmHabilitaCartao").val(),
            cpfcjav2: normalizaNumero($("#cpfcjav2", "#frmHabilitaCartao").val()),
            tdccjav2: $("#tdccjav2", "#frmHabilitaCartao").val(),
            doccjav2: $("#doccjav2", "#frmHabilitaCartao").val(),
            ende1av2: $("#ende1av2", "#frmHabilitaCartao").val(),
            ende2av2: $("#ende2av2", "#frmHabilitaCartao").val(),
            nrcepav2: normalizaNumero($("#nrcepav2", "#frmHabilitaCartao").val()),
            nmcidav2: $("#nmcidav2", "#frmHabilitaCartao").val(),
            cdufava2: $("#cdufava2", "#frmHabilitaCartao").val(),
            nrfonav2: $("#nrfonav2", "#frmHabilitaCartao").val(),
            emailav2: $("#emailav2", "#frmHabilitaCartao").val(),
            nrender2: normalizaNumero($("#nrender2", "#frmHabilitaCartao").val()),
            complen2: $("#complen2", "#frmHabilitaCartao").val(),
            nrcxaps2: normalizaNumero($("#nrcxaps2", "#frmHabilitaCartao").val()),

            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function mostraDivDadosHabilita() {
    $("#divDadosAvalistas").css("display", "none");
    $("#divDadosHabilita").css("display", "block");

	// Aumenta tamanho do div onde o conteúdo da opção será visualizado
//$("#divConteudoOpcao").css("height","310");
}

function metodoBlock() {
    blockBackground(parseInt($('#divRotina').css('z-index')));
}

/**************************************************************************************************************/
/*************************************          OPÇÃO EXTRATO          ****************************************/
/**************************************************************************************************************/
// Função para mostrar a opção de Extrato do cartão
function opcaoExtrato() {

    nomeForm = 'frmExtrato';

    var flgliber = $('#flgliber', '#divCartoes').val();

    if (nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Se nao esta liberado (Transferencia de PAC)
    if (flgliber == "no") {
        showError("error", dsdliber, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (cdadmcrd != 3) {
        hideMsgAguardo();
        showError("error", "Op&ccedil;&atilde;o v&aacute;lida apenas para cart&otilde;es CECRED VISA.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    /*    if (situacaoAnt != 'Em uso'){
hideMsgAguardo();
showError("error","Op&ccedil;&atilde;o v&aacute;lida apenas para cart&otilde;es EM USO.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
return false;
}    */


// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando tela do Extrato ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/extrato_parametros.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrcrcard: nrcrcard,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });
}

function validaDadosExtrato(anoHoje) {

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando dados para Extrato...");

    var nrcrcard = $('#nrcrcard', '#frmExtrato').val();
    var dtextrat = $('#dtextrat', '#frmExtrato').val();
    var dtArr = dtextrat.split('/');


    if ((dtArr[0] == 0) || (dtArr[0] > 12) || (dtArr[1] > (anoHoje + 1))) {
        hideMsgAguardo();
        showError("error", "Per&iacute;odo informado &eacute; inv&aacute;lido. " + dtextrat, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    } else {
		// Carrega conteúdo da opção através de ajax
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/cartao_credito/extrato_exibir.php",
            data: {
                nrdconta: nrdconta,
                nrcrcard: nrcrcard,
                dtextrat: dtextrat,
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                $("#divExtratoDetalhe").html(response);

            }
        });

    }

}

function ImprimeExtratoCartao2(idImpres, nrConta, nrCartao, DtVctIni, DtVctFim) {

    $("#idimpres", "#frmImprimir").val(idImpres);

    $("#nrdconta", "#frmImprimirExtr").val(nrConta);
    $("#nrcrcard", "#frmImprimirExtr").val(nrCartao);
    $("#dtvctini", "#frmImprimirExtr").val(DtVctIni);
    $("#dtvctfim", "#frmImprimirExtr").val(DtVctFim);

    var action = $("#frmImprimirExtr").attr("action");
    var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";

    carregaImpressaoAyllos("frmImprimirExtr", action, callafter);

}

function CarregaTitulares(codAdministradora) {

    var codAdministradora = codAdministradora.split(";");
    var sel = $("select#dsgraupr");

    codAdministradora = codAdministradora[0];

    if (inpessoa == 1) {
        if (codAdministradora > 9 && codAdministradora < 81) {
            sel.find("option[value='1']").attr('disabled', true);
            sel.find("option[value='2']").attr('disabled', true);
            sel.find("option[value='3']").attr('disabled', true);
            sel.find("option[value='4']").attr('disabled', true);
            sel.find("option[value='5']").attr('disabled', false);
            sel.find("option[value='6']").attr('disabled', false);
            sel.find("option[value='7']").attr('disabled', false);
            sel.find("option[value='8']").attr('disabled', false);
            /*        $("#tpdpagto").attr('disabled', false); */
            $("#tpenvcrd").attr('disabled', true);
            $("#dscartao").attr('disabled', true);

        } else if (codAdministradora >= 83 && codAdministradora <= 88) {
            sel.find("option[value='1']").attr('disabled', true);
            sel.find("option[value='2']").attr('disabled', true);
            sel.find("option[value='3']").attr('disabled', true);
            sel.find("option[value='4']").attr('disabled', true);
            sel.find("option[value='5']").attr('disabled', true);
            sel.find("option[value='6']").attr('disabled', true);
            sel.find("option[value='7']").attr('disabled', true);
            sel.find("option[value='8']").attr('disabled', true);
//$("#tpdpagto").attr('disabled', true);
            $("#tpenvcrd").attr('disabled', true);
            $("#dscartao").attr('disabled', false);
            sel.val(5);
        }

        $('#dsgraupr').focus();
    } else {

        if ((codAdministradora >= 10) && (codAdministradora <= 80)) {
            $("#dscartao").attr('disabled', true);
        }

        carregaRepresentantes();
    }


}

function validaTitular() {

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando titular...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/validar_titular.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            eval(response);
        }
    });

}

function buscaDadosCartao(cdadmcrd, nrcpfcgc, nmtitcrd, inpessoa, floutros) {

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando dados...");

    if (typeof(cdadmcrd) != "number" ||cdadmcrd == undefined) {
        if (inpessoa == 1) {
            try {
                var crdAux = $('#dsadmcrd').children().attr("value").split(";");
                cdadmcrd = crdAux[0];
                log4console("new value =" + cdadmcrd);
            } catch (e) {
                var chklen = $('input[name="dsadmcrdcc"]').length;
                var outros = false;
                for (j = 0; j < chklen; j++) {
                    var o = $('input[name="dsadmcrdcc"]')[j];
                    if ($(o).attr("checked") == 'checked') {
                        if ($(o).val() == "outro")
                            outros = true;
                    }
                }
                if (outros) {
                    var auxADM = $("#listType").val();
                    cdadmcrd = auxADM.split(";")[1];
                }
            }
        }
    }   
	if(inpessoa == 2){
		 if ($('#dsadmcrd option:selected').text().length > 0 ) {
            if ($('#dsadmcrd option:selected').text().toUpperCase().indexOf("DEB") > -1) {
                cdadmcrd = 17;
            } else {
                cdadmcrd = 15;
            }
        } else {
		 if ($('#dsadmcrd').val().toUpperCase().indexOf("DEB") > -1) {
			cdadmcrd = 17;
		} else {
			cdadmcrd = 15;
            }
		}
	}
// Carrega conte�do da op��o atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/valida_dados_cartao.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            cdadmcrd: cdadmcrd,
            nrcpfcgc: nrcpfcgc,
            nmtitcrd: nmtitcrd,
            inpessoa: inpessoa,
			idastcjt: idastcjt,
			glbadc  : glbadc,
            floutros: floutros,
            nrctrcrd: nrctrcrd,
            redirect: "html_ajax"
        },
        success: function (response) {
            hideMsgAguardo();
            eval(response);
        }
    });
};

function opcaoAlteraAdm() {

    if (nrcrcard == 0 || nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

	if (flgprovi == '1') {
        hideMsgAguardo();
        showError("error", "N&atilde;o &eacute; poss&iacute;vel realizar Downgrade ou Upgrade em cart&otilde;es provis&oacute;rios", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    nrcrcard = nrcrcard.replace(/\./g, "");

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Upgrade / Downgrade ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/upgrade_downgrade.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrcrcard: nrcrcard,
			nrctrcrd: nrctrcrd,
            redirect: "html_ajax"

        },
        success: function (response) {
            hideMsgAguardo();
            $("#divOpcoesDaOpcao1").html(response);
        }
    });

}


function atualizaUpgradeDowngrade(contrato, nrctrcrd_novo)
{
	//showMsgAguardo("Aguarde, atualizando justificativa...");
	var codaadmi = $("#hdncodadm").val();
    var codnadmi = $("#dsadmant").val();
	var dsjustificativa = $("#dsjustificativa").val();
	if(dsjustificativa.length == 0 ){
		hideMsgAguardo();
        showError("error", "Por favor preencha a justificativa.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
	}
    nrcrcard = nrcrcard.replace(/\./g, "");

    if (codnadmi == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; nova administradora selecionada.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }
	
	showMsgAguardo("Aguarde, validando dados...");

// Carrega conte�do da op��o atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/updJustificativaUpgradeDowngrade.php",
        dataType: "html",
        data: {
			cdcooper  : cdcooper,
            nrdconta  : nrdconta,
            nrctrcrd  : contrato,
			ds_justif : dsjustificativa,
			cdadmnov  : codnadmi,
            nrctrcrd_novo : nrctrcrd_novo,
			inupgrad  : 1
        },
        success: function (response) {
            //hideMsgAguardo();
			var error = false;
            eval(response);
			hideMsgAguardo();
			//if(!error){
			//	validarUpDown();
			//}
        }
    });
}

function validarUpDown(contrato) {

    var codaadmi = $("#hdncodadm").val();
    var codnadmi = $("#dsadmant").val();
	var dsjustificativa = $("#dsjustificativa").val();

	if(dsjustificativa.length == 0 ){
		hideMsgAguardo();
        showError("error", "Por favor preencha a justificativa.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
	}
    nrcrcard = nrcrcard.replace(/\./g, "");

    if (codnadmi == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; nova administradora selecionada.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando dados...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/altera_administradora.php",
        dataType: "html",
        data: {
            codaadmi: codaadmi,
            codnadmi: codnadmi,
            nrdconta: nrdconta,
            nrcrcard: nrcrcard,
            contrato: contrato,
			dsjustificativa:dsjustificativa,
            piloto: iPiloto,
            redirect: "html_ajax"
        },
        success: function (response) {
            hideMsgAguardo();
            eval(response);
        }
    });
}

function buscaTitulares(nrdconta, escolha) {

    var idseqttl = escolha == 7 ? 3 : 4;

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando dados...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/busca_titulares.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            eval(response);
            hideMsgAguardo();
            blockBackground(parseInt($("#divRotina").css("z-index")));
        }
    });

}

function selecionaRepresentante() {

    if($(inpessoa!=2 && "#dsgraupr", "#frmNovoCartao").val() == 5){
        return;
    }
        
    var index = $("#dsrepinc", "#frmNovoCartao").val();
    var dsadmcrd = $('#dsadmcrd', '#frmNovoCartao').val();
    var cdadmcrd = $('#cdadmcrd', '#frmNovoCartao').val();
    if (Representantes[index] == null) {
        return false;
    }

    // Como inpessoa=2 então dsadmcrd para debito só pode ser 17!
    if(inpessoa == 2 && cdadmcrd != 17 && $("#dsrepinc").val() != '8'){
        ativa("tpdpagto");
        ativa("flgdebit");
        ativa("dddebito");
    }

	if(inpessoa ==2 && $("#dsrepinc option:selected").text()=="OUTROS"){
		$("#flgdebit").removeAttr("checked");
		desativa("flgdebit");
	}else if(inpessoa ==2 && idastcjt != 1 &&$("#dsrepinc option:selected").text()!="OUTROS"){
		ativa("flgdebit");
		$("#flgdebit").attr("checked",true);
	}
	if(glbadc == 'n' && idastcjt == 1){
		desativa("flgdebit");
	}
	
    $("#nrcpfcgc", "#frmNovoCartao").val(Representantes[index].nrcpfcgc);
    $("#nmtitcrd", "#frmNovoCartao").val(Representantes[index].nmdavali);
    $("#nrdoccrd", "#frmNovoCartao").val(Representantes[index].nrdocttl);
    $("#dtnasccr", "#frmNovoCartao").val(Representantes[index].dtnasttl);
    dsadmcrd = dsadmcrd.split(";");
    dsadmcrd = dsadmcrd[0];

    if (Representantes[index].floutros == 1) {
        $("#nrcpfcgc", "#frmNovoCartao").habilitaCampo();
        $("#dtnasccr", "#frmNovoCartao").habilitaCampo();

        $("#flgdebit", "#frmNovoCartao").desabilitaCampo();
        $("#flgdebit", "#frmNovoCartao").prop('checked', false);

    } else {
        desativa("nrcpfcgc");
		desativa("dtnasccr");        
// Atualiza o campo Habilita Funcao Debito
        alteraFuncaoDebito();
    }

    buscaDadosCartao(dsadmcrd, Representantes[index].nrcpfcgc, Representantes[index].nmdavali, 2, Representantes[index].floutros);
}

function carregaRepresentantes() {

//Lunelli var nrcpfcgc = $('#dsrepinc','#frmNovoCartao').val() == null ? 0 : $('#nrcpfcgc','#frmNovoCartao').val();
    var nrcpfcgc = 0;
    var cdadmcrd = $('#dsadmcrd', '#frmNovoCartao').val();

    $('#dsrepinc', '#frmNovoCartao').empty();

    cdadmcrd = cdadmcrd.split(";");
	
    var dsoutros = cdadmcrd[5];
    cdadmcrd = cdadmcrd[0];
	
    if(inpessoa == 2 && (isNaN(cdadmcrd))){
            log4console("Resolvido pj");
            dsoutros = "OUTROS";
            if($('#dsadmcrd').val().toUpperCase().indexOf("DEB") > -1){
                cdadmcrd = 17;
                
            }else{
                cdadmcrd = 15;
            }
    }
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando representantes...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/busca_representantes.php",
        dataType: "html",
        data: {
            tpctrato: 6,
            nrdconta: nrdconta,
            nrcpfcgc: nrcpfcgc,
            dsoutros: dsoutros,
            cdadmcrd: cdadmcrd,
			inpessoa: inpessoa,
			idastcjt: idastcjt,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {            
            nmtitcrd = $('#nmtitcrd', '#frmNovoCartao').val();
            nrcpfcgc = $('#nrcpfcgc', '#frmNovoCartao').val();
            eval(response);
            selecionaRepresentante();
        }
    });
}

function opcaoTAA() {

// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/verifica_acesso_tela_taa.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrcrcard: nrcrcard,
            nrctrcrd: nrctrcrd,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao4").css("display", "none");
            $("#divOpcoesDaOpcao1").html(response);
        }
    });
}

/**
* Função para ler o CHIP do cartão de crédito
 */
function lerCartaoChip() {

    var btnProsseguir = $("#btnProsseguir");
    var oLog = document.getElementById('log');
    var oRetornoJson = [];
    var bCheckSMC = true;
    var sTagNumeroCartao = 0;
    var sTagPortador = '';
    var sTagDataValidade = '';

    fechaConexaoPinpad(oPinpad);

    if (oPinpad == "" || oPinpad == false || typeof oPinpad == 'undefined') {
    try {
        var oPinpad = new ActiveXObject("Gertec.PPC");
    } catch (e) {
        hideMsgAguardo();
//showError("error","A rotina de entrega n&atilde;o &eacute; compat&iacute;vel com este navegador, acesse o Internet Explorer.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
        return;
    }
    }

// Abre a porta do PINPAD
    if (!abrePortaPinpad(oPinpad)) {
        return;
    }

    showMsgAguardo("Insira o cart&atilde;o com CHIP");

// Criado o timeout para conseguir mostrar a mensagem do Aguarde
    setTimeout(function () {
// Limpa tela
        oPinpad.LCD_Clear();
        try {
// Inicializa leitura do cartao
            oPinpad.InitSMC(0);
// Mostra na tela
            oPinpad.LCD_DisplayString(2, 18, 1, "Insira o cartao");
// Verifica se o cartao esta inserido
            while (bCheckSMC) {
                oRetornoJson = oPinpad.RequestKBDEntry(0);
                eval("oRetornoJson = " + oRetornoJson);
// Apertou para anular a operacao
                if (oRetornoJson.sKBDEntry == "C") {
                    hideMsgAguardo();
                    fechaConexaoPinpad(oPinpad);
                    return;
                }

                oRetornoJson = oPinpad.CheckSMC(0);
                eval("oRetornoJson = " + oRetornoJson);
                if (oRetornoJson.bStatus == 1) {
// Acende o LED
                    oPinpad.SetLED(1);
                    bCheckSMC = false;
                }
            }

            showMsgAguardo("Processando...");

// Criado o timeout para conseguir mostrar a mensagem do Aguarde
            setTimeout(function () {
                /* Limpa tela  */
                oPinpad.LCD_Clear();
                oPinpad.LCD_DisplayString(2, 18, 1, "Processando...");
                oPinpad.SMC_ReadTracks(0, "", "");

// Buscar AIDGet
                oRetornoJson = oPinpad.SMC_EMV_AIDGet(0);
                eval("oRetornoJson = " + oRetornoJson);
                szAIDList = oRetornoJson.szAIDList.split(";");

// Busca nome no cartao
                oRetornoJson = oPinpad.SMC_EMV_TagsGet(0, "5F20", szAIDList[0]);
                eval("oRetornoJson = " + oRetornoJson);
                sTagPortador = oRetornoJson.szTagsData;

                if (sTagPortador == "") {
                    oRetornoJson = oPinpad.SMC_EMV_TagsGet(0, "5F20", szAIDList[1]);
                    eval("oRetornoJson = " + oRetornoJson);
                    sTagPortador = oRetornoJson.szTagsData;
                }

                if (sTagPortador == "") {
                    oRetornoJson = oPinpad.SMC_EMV_TagsGet(0, "5F20", szAIDList[2]);
                    eval("oRetornoJson = " + oRetornoJson);
                    sTagPortador = oRetornoJson.szTagsData;
                }

// Busca Numero do cartao
                oRetornoJson = oPinpad.SMC_EMV_TagsGet(0, "5A", szAIDList[0]);
                eval("oRetornoJson = " + oRetornoJson);
                sTagNumeroCartao = oRetornoJson.szTagsData;

                if (sTagNumeroCartao == "") {
                    oRetornoJson = oPinpad.SMC_EMV_TagsGet(0, "5A", szAIDList[1]);
                    eval("oRetornoJson = " + oRetornoJson);
                    sTagNumeroCartao = oRetornoJson.szTagsData;
                }

                if (sTagNumeroCartao == "") {
                    oRetornoJson = oPinpad.SMC_EMV_TagsGet(0, "5A", szAIDList[2]);
                    eval("oRetornoJson = " + oRetornoJson);
                    sTagNumeroCartao = oRetornoJson.szTagsData;
                }

// Buscar Validade do cartao
                oRetornoJson = oPinpad.SMC_EMV_TagsGet(0, "5F24", szAIDList[0]);
                eval("oRetornoJson = " + oRetornoJson);
                sTagDataValidade = oRetornoJson.szTagsData;

                if (sTagDataValidade == "") {
                    oRetornoJson = oPinpad.SMC_EMV_TagsGet(0, "5F24", szAIDList[1]);
                    eval("oRetornoJson = " + oRetornoJson);
                    sTagDataValidade = oRetornoJson.szTagsData;
                }

                if (sTagDataValidade == "") {
                    oRetornoJson = oPinpad.SMC_EMV_TagsGet(0, "5F24", szAIDList[2]);
                    eval("oRetornoJson = " + oRetornoJson);
                    sTagDataValidade = oRetornoJson.szTagsData;
                }

				// Carrega conteúdo da opção através de ajax
                $.ajax({
                    type: "POST",
                    url: UrlSite + "telas/atenda/cartao_credito/processa_leitura_cartao_chip.php",
                    async: false,
                    dataType: "html",
                    data: {
                        tagPortador: sTagPortador,
                        tagNumeroCartao: sTagNumeroCartao,
                        tagDataValidade: sTagDataValidade,
                        redirect: "html_ajax"
                    },
                    error: function (objAjax, responseError, objExcept) {
                        hideMsgAguardo();
                        showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                    },
                    success: function (response) {
                        eval(response);
                    }
                });

                fechaConexaoPinpad(oPinpad);
// Habilita o botao de prosseguir
                btnProsseguir.show();
                hideMsgAguardo();
                bloqueiaFundo(divRotina);
            }, 300);

        } catch (e) {
            fechaConexaoPinpad(oPinpad);
            hideMsgAguardo();
            showError("error", "Erro ao ler o cart&atilde;o. " + e.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        }
    }, 500);
}

function imprimirTermoEntrega(flegMsg) {
    var idimpres = 0;
    if (cdadmcrd == 1) {  // Administradora Credicard 
		idimpres = 5; 
	} else if (cdadmcrd == 2) {  // BRADESCO/VISA 
		idimpres = 2; 
	} else if (cdadmcrd == 3) {  // CECRED/VISA 
		idimpres = $inpessoa == 1 ? 2 : 9;  // Imprime termo de entrega para pessoa jur�dicas
	} else if ((cdadmcrd >= 10) && (cdadmcrd <= 80)){
		idimpres = 18;
	}
	
    if (flegMsg == true) {
        showError("info", "N&atilde;o &eacute; obrigat&oacute;rio a impress&atilde;o do termo, imprima somente se for necess&aacute;rio.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }

	gerarImpressao(2, idimpres, cdadmcrd, nrctrcrd, 0);
}

function assinar(tipo) {
    if (tipo != 'eletronica' && tipo != 'impressa') {
        tipo = tipoAssinatura;

    }

    if (tipo == 'eletronica') {
        solicitaSenhaTAOnline("tipoAssinatura = 'impressa'; imprimirTermoEntrega(true); fechaRotina($('#divUsoGenerico'));", nrdconta, nrcrcard);

    } else if (tipo == 'impressa') {
        imprimirTermoEntrega();

    }
}

/**
* Função para ler o cartão de crédito magnetico
 */
function lerCartaoMagnetico() {

    var btnProsseguir = $("#btnProsseguir");
    var oRetornoJson = [];
    var aTrack = new Array();
    var bPassarCartao = true;
    var oDate = new Date();
    var sDataValidade = null;

    try {
        var oPinpad = new ActiveXObject("Gertec.PPC");
    } catch (e) {
        hideMsgAguardo();
        showError("error", "A rotina de entrega n&atilde;o &eacute; compat&iacute;vel com este navegador, acesse o Internet Explorer.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return;
    }

// Abre a conexao com o PINPAD
    if (!abrePortaPinpad(oPinpad)) {
        return;
    }

    showMsgAguardo("Passe o cart&atilde;o com a tarja magn&eacute;tica");

// Criado o timeout para conseguir mostrar a mensagem do Aguarde
    setTimeout(function () {
// Limpa tela
        oPinpad.LCD_Clear();
        oPinpad.LCD_DisplayString(2, 18, 1, "Passe o cartao");

        try {
            oPinpad.ReadMagCard_Start(60);

            while (bPassarCartao) {
                oRetornoJson = oPinpad.ReadMagCard_Get();
                eval("oRetornoJson = " + oRetornoJson);
                if (oRetornoJson.dwResult == 0) {
                    bPassarCartao = false;
// Erro de timeout
                } else if ((oRetornoJson.dwResult == 1021) || (oRetornoJson.dwResult == 11054) || (oRetornoJson.dwResult == 1016)) {
                    throw {message: 'N&atilde;o foi poss&iacute;vel ler o cart&atilde;o, tente novamente.'};
                }
            }

            aTrack = oRetornoJson.sTrack1.split('^');

            if (typeof aTrack[0] != 'undefined') {
                var sNumeroCartao = aTrack[0].substr(2, 16);
                $("#nrcrcard", "#frmEntregaCartaoBancoob").val(mascara(sNumeroCartao, '####.####.####.####'));
                $("#nrcarfor", "#frmEntregaCartaoBancoob").val(sNumeroCartao.substr(0, 4) + '.' + sNumeroCartao.substr(4, 2) + '**.****.' + sNumeroCartao.substr(12, 4));
            }

            if (typeof aTrack[1] != 'undefined') {
                $("#repsolic", "#frmEntregaCartaoBancoob").val(aTrack[1]);
            }

            if (typeof aTrack[2] != 'undefined') {
                sDataValidade = aTrack[2].substr(2, 2) + '/' + oDate.getFullYear().toString().substr(0, 2) + aTrack[2].substr(0, 2);
                $("#dtvalida", "#frmEntregaCartaoBancoob").val(sDataValidade);
            }

            fechaConexaoPinpad(oPinpad);
// Habilita o botao de prosseguir
            btnProsseguir.show();
            hideMsgAguardo();
            bloqueiaFundo(divRotina);
        } catch (e) {
            fechaConexaoPinpad(oPinpad);
            hideMsgAguardo();
            showError("error", e.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        }
    }, 500);
}

function solicitaPI(oPinpad, iNumeroCartao, sWTexto3, sMensagem) {

    var oRetornoJson = [];
    var bPedirPI = true;

    oPinpad.StartPINBlock(4, 4, 0, 0, 300, 4, 2, 1, sMensagem, 2, " ", 3, " ", 5, " ");

    while (bPedirPI) {
        oRetornoJson = oPinpad.GetPINBlock(1, 0, 2, sWTexto3, 16, '0'.charCodeAt(0), 0, iNumeroCartao, 10, 4, 3, " ", 6, " ");
        eval("oRetornoJson = " + oRetornoJson);

        if (oRetornoJson.dwResult == 11054) {
            throw {message: 'Tempo para informar a senha ultrapassou o limite, tente novamente.'};
        } else if (oRetornoJson.dwResult == 11053) {
            throw {message: 'Cooperado anulou a operac&atilde;o, informe a senha novamente.'};
        }

        if ((oRetornoJson.bPINStatus == 4) || (parseFloat(oRetornoJson.sEncDataBlk) == 0)) {
            throw {message: 'Erro ao alterar a senha. Codigo: ' + oRetornoJson.dwResult};
        }

        if (oRetornoJson.bPINStatus == 0) {
            bPedirPI = false;
        }
    }
    return oRetornoJson;
}

function valida_dados_cartao_bancoob() {

    var oNrcrcard = $('#nrcrcard', '#frmEntregaCartaoBancoob');
    var oDtvalida = $('#dtvalida', '#frmEntregaCartaoBancoob');

    showMsgAguardo("Aguarde, validando dados cart&atilde;o...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/valida_dados_cartao_bancoob.php",
        async: false,
        data: {
			nrdconta: nrdconta, // Número da conta
			nrctrcrd: nrctrcrd, // Número da proposta
            nrcrcard: retiraCaracteres(oNrcrcard.val(), "0123456789", true), // Número do cartão de crédito
            dtvalida: oDtvalida.val(), // Data de Validade
            flgcchip: flgcchip,
            flag2via: ((nomeacao == '2VIA_CARTAO_CHIP') ? true : false),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                bloqueiaFundo(divRotina);
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function altera_senha_pinpad() {

    var oRetornoJson = [];
    var oPinpad = new ActiveXObject("Gertec.PPC");
    var sNumeroCartao = $('#nrcrcard', '#frmEntregaCartaoBancoob').val();
    var sSTexto1 = '';
    var sSTexto2 = '';
    var sWTexto3 = 0;
    var sNTexto4 = 0;
    var aOperacao = new Array();
    var bErro = false;
    var aCabalAPP = { CABAL_CREDIT: 'A0000004421010', CABAL_DEBIT: 'A0000004422010' };

// Abre a conexao com o PINPAD
    if (!abrePortaPinpad(oPinpad)) {
        return false;
    }

    showMsgAguardo("Informe a senha de 4 d&iacute;gitos no PINPAD.");

    setTimeout(function () {
        try {
            oPinpad.InitSMC(0);
            oPinpad.ResetSMC(0);
            oRetornoJson = oPinpad.CheckSMC(0);
            eval("oRetornoJson = " + oRetornoJson);
// Vamos verificar se o cartao estah inserido
            if (oRetornoJson.bStatus != 1) {
                $('#repsolic', '#frmEntregaCartaoBancoob').val('');
                $('#nrcrcard', '#frmEntregaCartaoBancoob').val('');
                $('#nrcarfor', '#frmEntregaCartaoBancoob').val('');
                $('#dtvalida', '#frmEntregaCartaoBancoob').val('');
                $("#btnProsseguir").hide();
				throw { message: 'Favor inserir o cart&atilde;o no PINPAD.' };			
            }

            /* Limpa tela  */
            oPinpad.LCD_Clear();

// Vamos buscar a working key
            $.ajax({
                type: "POST",
                url: UrlSite + "telas/atenda/cartao_credito/retorna_ct.php",
                async: false,
                error: function (objAjax, responseError, objExcept) {
                    throw { message: 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.' };
                },
                success: function (response) {
                    eval("var oRetornoJson = " + response);
                    if (parseInt(oRetornoJson.bErro)) {
							throw { message: oRetornoJson.retorno };
                    }
                    sWTexto3 = oRetornoJson.retorno;
                }
            });

            iNumeroCartao = replaceAll(sNumeroCartao, '.', '');
            iNumeroCartao = iNumeroCartao.substr(3, 12);
// Solicita para informar a senha 1
            oRetornoJson = solicitaPI(oPinpad, iNumeroCartao, sWTexto3, "Informe a senha:");
            sSTexto1 = oRetornoJson.sEncDataBlk;
            oPinpad.StopPINBlock();
            oPinpad.LCD_Clear();

            hideMsgAguardo();
            showMsgAguardo("Confirme a senha no PINPAD....");

            setTimeout(function () {

                try {
// Solicita para informar a senha 2
                    oRetornoJson = solicitaPI(oPinpad, iNumeroCartao, sWTexto3, "Confirme senha:");
                    sSTexto2 = oRetornoJson.sEncDataBlk;
                    oPinpad.StopPINBlock();
                    oPinpad.LCD_Clear();

// Conferir se as duas senha informadas, conferem
                    if (sSTexto1 != sSTexto2) {
						throw { message: 'Senha informada n&atilde;o conferem.' };
                    }

                    showMsgAguardo("Processando...");

                    setTimeout(function () {

                        try {
                            oPinpad.LCD_DisplayString(2, 18, 1, "Processando...");

// WPDPK
                            $.ajax({
                                type: "POST",
                                url: UrlSite + "telas/atenda/cartao_credito/retorna_pi.php",
                                async: false,
                                data: {
                                    dataPin: base64_encode(sSTexto1),
                                    dataWk: base64_encode(sWTexto3),
                                    redirect: "script_ajax"
                                },
                                error: function (objAjax, responseError, objExcept) {
										throw { message: 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.' };
                                },
                                success: function (response) {
                                    eval("var oRetornoJson = " + response);
                                    if (parseInt(oRetornoJson.bErro)) {
											throw { message: oRetornoJson.retorno };
                                    }
                                    sNTexto4 = oRetornoJson.retorno;
                                }
                            });

// Vamos verificar se o cartao possui debito/credito
                            oRetornoJson = oPinpad.SMC_EMV_AIDGet(0);
                            eval("oRetornoJson = " + oRetornoJson);

                            if (oRetornoJson.szAIDList.length == 0) {
                                for (iAPP in aCabalAPP) {

                                    oRetornoJson = oPinpad.ResetSMC(0);
	                           	/* Verificar as aplicações presentes no chip */
                                    oRetornoJson = oPinpad.SMC_EMV_TagsGet(0, "84", aCabalAPP[iAPP]);
                                    eval("oRetornoJson = " + oRetornoJson);

                                    if (oRetornoJson.dwResult == 0) {
                                        aOperacao.push(aCabalAPP[iAPP]);
                                    }
                                }
                            } else {
                                aOperacao = oRetornoJson.szAIDList.split(';');
                            }

                            for (iAPP in aOperacao) {
                                /* Se application ID diferente de GP GlobalPlatform (solicitado pela Cabal para ignorarmos) - 
                                   SCTASK0025102 (Fabricio) */
                                if (aOperacao[iAPP] != 'A0000001510000') {
                                oRetornoJson = altera_cb(oPinpad, aOperacao[iAPP], sNTexto4, sNumeroCartao);
// Para cada transacao precisamos fechar a conexao e abrir novamente. (By GERTEC)
                                if (oRetornoJson.bOK) {
                                    oPinpad.CloseSerial();
                                    oPinpad.OpenSerial(sPortaPinpad);
                                } else {
                                    fechaConexaoPinpad(oPinpad);
                                    return;
                                }
                            }
                            }

                            fechaConexaoPinpad(oPinpad);
// Vamos verificar se a acao eh para entregar o cartao ou 2 via da senha
                            if (nomeacao == 'ENTREGAR_CARTAO') {
// Efetua a entrega do cartao com CHIP
                                efetuaEntregaCartaoComChip();
                            } else {
// Somente volta para a tela de consulta
                                showError("inform", 'Senha alterada com sucesso.', "Alerta - Aimaro", "acessaOpcaoAba(14,0,'2');");
                            }
                        } catch (e) {
                            fechaConexaoPinpad(oPinpad);
                            hideMsgAguardo();
                            showErrorCartao(e.message, "blockBackground(parseInt($('#divRotina').css('z-index')))");
                        }

                    }, 500);

                } catch (e) {
                    fechaConexaoPinpad(oPinpad);
                    hideMsgAguardo();
                    showErrorCartao(e.message, "blockBackground(parseInt($('#divRotina').css('z-index')))");
                }
            }, 500);

        } catch (e) {
            fechaConexaoPinpad(oPinpad);
            hideMsgAguardo();
            showErrorCartao(e.message, "blockBackground(parseInt($('#divRotina').css('z-index')))");
        }
    }, 500);
}

/**
 * Fecha a conexao com o PINPAD
 * @param Object Objeto Pinpad
 */
function fechaConexaoPinpad(oPinpad) {

    // Se houver conexao ativa, elimina	
    if (oPinpad != false && typeof oPinpad != 'undefined') {
    oPinpad.ReadMagCard_Stop();
    oPinpad.ChangeEMVCardPasswordStop();
    oPinpad.StopPINBlock();
// Apaga o LED
    oPinpad.SetLED(0);
// Fecha Porta
    oPinpad.CloseSerial();
}
}

function altera_cb(oPinpad, sAID, sNTexto4, sNumeroCartao) {

    var oRetornoJson = [];
    var sTexto1 = '';
    var sIdentificadorTransacao = '';
    var bRetorno = false;

    var oRetornoJson = oPinpad.ChangeEMVCardPasswordStart(sAID, '9F029F26829F368C9F279F105A5F349F1A955F2A9A9C9F37');
    eval("oRetornoJson = " + oRetornoJson);
    if (oRetornoJson.dwResult != 0) {
        hideMsgAguardo();
        showErrorCartao('Erro ao iniciar o processo de altera&ccedil;&atilde;o de senha.', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return bRetorno;
    }

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/retorna_cb.php",
        async: false,
        data: {
            data: base64_encode(oRetornoJson.sData),
            dataPin: sNTexto4,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showErrorCartao('N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            eval(response);

// Vamos verificar se estah carregado o script de alteracao de senha no PINPAD
            if (bRetorno) {
                oRetornoJson = oPinpad.FinishEMVCard(0, 0, 0, sTexto1, 0);
                eval("oRetornoJson = " + oRetornoJson);

                if ((oRetornoJson.dwResult != 2000) || (oRetornoJson.bDecision != 0)) {
                    bRetorno = false;
                    hideMsgAguardo();
                    showErrorCartao("Erro ao alterar senha. C&oacute;digo: " + oRetornoJson.dwResult + ". Status: " + oRetornoJson.bDecision, "blockBackground(parseInt($('#divRotina').css('z-index')))");
                }

                if (bRetorno) {
                    if (!confirma_cb(sIdentificadorTransacao, sNumeroCartao)) {
                        bRetorno = false;
                        return;
                    }
                }
            }
        }
    });

    return { 'bOK': bRetorno };
}

function confirma_cb(sIdentificadorTransacao, sNumeroCartao) {

    var bRetorno = false;

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/retorna_co.php",
        async: false,
        data: {
            identificadorTransacao: sIdentificadorTransacao,
            numeroCartao: replaceAll(sNumeroCartao, '.', ''),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showErrorCartao('N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            eval(response);
        }
    });
    return bRetorno;
}

/**
* Função para abrir a porta do PINPAD
 * @param Object PINPAD
 */
function abrePortaPinpad(oPinpad) {

    var oRetornoJson = [];

    /* Fecha Porta */
    oPinpad.CloseSerial();

// Verifica qual porta esta o PINPAD
    oRetornoJson = oPinpad.FindPort(2);
    eval("oRetornoJson = " + oRetornoJson);
    if (oRetornoJson.dwResult != 0) {
        hideMsgAguardo();
        showError("error", "Erro ao abrir a porta PINPAD", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    sPortaPinpad = 'COM' + oRetornoJson.pbPort[0];
    oRetornoJson = oPinpad.OpenSerial(sPortaPinpad);
    eval("oRetornoJson = " + oRetornoJson);
	/* Verifica se o Pinpad está conectado na Porta */
    if (oRetornoJson.dwResult != 0) {
        hideMsgAguardo();
        showError("error", "Erro ao conectar no PINPAD.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    return true;
}

/*
Sempre que for uma entrega de cartao e a situacao estiver "Solicitado",
todo erro sera fechado a tela atual e recarregado a consulta.
*/
function showErrorCartao(sMensagem, sScript) {
    var sScript = sScript || '';

    if ((bCartaoSituacaoSolicitado) && (nomeacao == 'ENTREGAR_CARTAO')) {
        sScript = sScript + ";acessaOpcaoAba(14,0,'2');";
    }

    hideMsgAguardo();
    showError("error", sMensagem, "Alerta - Aimaro", sScript);
    return false;
}

function validaVoltaTela() {
    blockBackground(parseInt($('#divRotina').css('z-index')));

    if ((bCartaoSituacaoSolicitado) && (nomeacao == 'ENTREGAR_CARTAO')) {
        acessaOpcaoAba(14, 0, '2');
    }
    return false;
}

function grava_dados_cartao_nao_gerado() {

    showMsgAguardo("Aguarde, efetuando entrega do cart&atilde;o de cr&eacute;dito ...");

    var oNrcctitg = $('#nrcctitg', '#frmEntregaCartaoBancoob');
    var oNrcctitg2 = $('#nrcctitg2', '#frmEntregaCartaoBancoob');
    var oNrcrcard = $('#nrcrcard', '#frmEntregaCartaoBancoob');
    var oRepsolic = $('#repsolic', '#frmEntregaCartaoBancoob');

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/cadastrar_cartao_nao_gerado.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            nrcrcard: retiraCaracteres(oNrcrcard.val(), "0123456789", true),
            nrcctitg: oNrcctitg.val(),
            nrcctitg2: oNrcctitg2.val(),
            repsolic: oRepsolic.val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
                bloqueiaFundo(divRotina);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function validaDadosLiberacaoTAA(operacao) {

    var operacao = operacao || 'liberarAcessoTaa';

    showMsgAguardo("Aguarde, validando os dados cart&atilde;o de cr&eacute;dito ...");

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/valida_liberacao_taa.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrcrcard: nrcrcard,
            nrctrcrd: nrctrcrd,
            operacao: operacao,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao4").html(response);
        }
    });
}

function liberarCartaoCreditoTAA(operacao) {

    showMsgAguardo("Aguarde, liberando cart&atilde;o de cr&eacute;dito ...");

    var operacao = operacao || 'liberarAcessoTaa';

    var oDssentaa = $('#dssentaa', '#frmSenhaNumericaTAA');
    var oDssencfm = $('#dssencfm', '#frmSenhaNumericaTAA');

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/liberar_cartao_credito_taa.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            nrcrcard: nrcrcard,
            dssentaa: oDssentaa.val(),
            dssencfm: oDssencfm.val(),
            operacao: operacao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
                bloqueiaFundo(divRotina);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function validaDadosBloqueioTAA() {

    showMsgAguardo("Aguarde, validando os dados cart&atilde;o de cr&eacute;dito ...");

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/valida_bloqueio_taa.php",
        data: {
            nrdconta: nrdconta,
            nrcrcard: nrcrcard,
            nrctrcrd: nrctrcrd,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
                bloqueiaFundo(divRotina);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function bloquearCartaoCreditoTAA() {

    showMsgAguardo("Aguarde, bloqueando cart&atilde;o de cr&eacute;dito ...");

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/bloquear_cartao_credito_taa.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            nrcrcard: nrcrcard,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
                bloqueiaFundo(divRotina);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function validaDadosSenhaNumericaTAA(operacao) {

    showMsgAguardo("Aguarde, validando os dados cart&atilde;o de cr&eacute;dito ...");

    var operacao = operacao || 'cadastrarSenhaNumericaTaa';

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/valida_senha_numerica_taa.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrcrcard: nrcrcard,
            nrctrcrd: nrctrcrd,
            operacao: operacao,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao4").html(response);
        }
    });
}

function alteraSenhaNumericaTAA() {

    showMsgAguardo("Aguarde, alterando senha TAA...");

    var oDssentaa = $('#dssentaa', '#frmSenhaNumericaTAA');
    var oDssencfm = $('#dssencfm', '#frmSenhaNumericaTAA');

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/alterar_senha_numerica_taa.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            nrcrcard: nrcrcard,
            dssentaa: oDssentaa.val(),
            dssencfm: oDssencfm.val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
                bloqueiaFundo(divRotina);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function validaDadosSenhaLetrasTAA(operacao) {

    showMsgAguardo("Aguarde, validando os dados cart&atilde;o de cr&eacute;dito ...");

    var operacao = operacao || 'cadastrarSenhaLetrasTaa';

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/valida_senha_letras_taa.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrcrcard: nrcrcard,
            nrctrcrd: nrctrcrd,
            operacao: operacao,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao4").html(response);
        }
    });
}

function alteraSenhaLetrasTAA(operacao) {

    showMsgAguardo("Aguarde, alterando senha TAA...");

    var operacao = operacao || 'cadastrarSenhaLetrasTaa';
    var oDssennov = $('#dssennov', '#frmSenhaLetrasTAA');
    var oDssencon = $('#dssencon', '#frmSenhaLetrasTAA');

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/alterar_senha_letras_taa.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            nrcrcard: nrcrcard,
            dssennov: oDssennov.val(),
            dssencon: oDssencon.val(),
            operacao: operacao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
                bloqueiaFundo(divRotina);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function entregaCartaoCarregaTelaSenhaNumericaTaa() {

    showMsgAguardo("Aguarde, validando os dados cart&atilde;o de cr&eacute;dito ...");

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/carrega_tela_senha_numerica_taa.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            operacao: 'entregarCartao',
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });
}

function entregaCartaoCarregaTelaSenhaLetrasTaa() {

    showMsgAguardo("Aguarde, validando os dados cart&atilde;o de cr&eacute;dito ...");

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/carrega_tela_senha_letras_taa.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            operacao: 'entregarCartao',
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });
}

function abreTelaLimiteSaque() {

    $("#divOpcoesDaOpcao1").css("display", "none");
    $("#divConteudoLimiteSaqueTAA").css("display", "block");

    var url = UrlSite + "telas/atenda/limite_saque_taa/limite_saque_taa.js";
    $.getScript(url, function () {
        controlaOperacaoLimiteSaqueTAA('CA', 'cartao_credito');
    }, true);

    return false;
}

function carregaSelecionarRepresentantes(cddopcao) {

    showMsgAguardo('Aguarde, carregando os representantes...');
    exibeRotina($('#divUsoGenerico'));

	// Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/cartao_credito/carrega_representante.php',
        data: {
            nrdconta: nrdconta,
            cddopcao: cddopcao,
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            if (response.indexOf('showError("error"') == -1) {
                $('#divUsoGenerico').html(response);
            } else {
                eval(response);
            }
        }
    });
    return false;
}

function controlaLayoutRepresentantes() {
    var divRegistro = $('#divSelecaoAvalista');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);
    divRegistro.css({ 'height': '100px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '25px';
    arrayLargura[1] = '120px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'left';
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    hideMsgAguardo();
    bloqueiaFundo($('#divUsoGenerico'));
    return false;
}

// Função para mostrar o histórico de alteração de limite de crédito
function mostraHisLimite() {

    // ALTERAÇÃO
    var nomeForm = 'frmHistoricoLimite';
    var nrcctitg = $('#nrcctitg', '#frmDadosCartao').val();
	if(nrcctitg == undefined){
			nrcctitg = nrctrcrd;
	}
// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando hist&oacute;rico de limite de cr&eacute;dito ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/consultar_historico_limite.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrcctitg: nrcctitg,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });
}

function carregaHistorico(type,contrato) {
    showMsgAguardo("Aguarde, carregando hist&oacute;rico ...");
	var sitcrd = $("#dssituac").val();
    var inupgrad = $("#inupgrad").val();
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/cartao_credito/historico.php",
        data: {
            nrcrcard: nrcrcard,
            nrdconta: nrdconta,
            nrctrcrd: contrato,
            inupgrad: inupgrad,
            type: type,
			dssituac : sitcrd
        },
        error: function (objAjax, responseError, objExcept) {

            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divConteudoCartoes").hide();
            hideMsgAguardo();
            $("#divOpcoesDaOpcao1").html(response);
            $("#divOpcoesDaOpcao1").show();
        }
    });
}

function enviaSolicitacao() {
    $('#nmtitcrd').click();
    $('#nmextttl').click();
    verificaEfetuaGravacao('I');
    return false;
}

function validarSenha(nrctrcrd, tipoSenha) {
	
    if (tipoSenha == undefined) {
	    tipoSenha = cTipoSenha.COOPERADO;
    }	
	
    idacionamento = $("#idacionamento","#frmNovoCartao").val();
    log4console("prj cartoes protocolo : "+protocolo);
	log4console("prj cartoes idacionamento : "+idacionamento);
	if(idacionamento == undefined && protocolo)
		idacionamento = protocolo;
    atualizaContrato(nrctrcrd,idacionamento,"S", function(){
        log4console(' add trigger back');
        $(".btnVoltar").attr('onclick','voltarParaTelaPrincipal();');
		//|| idastcjt !=1
        if (inpessoa == 1 || tipoSenha == cTipoSenha.SUPERVISOR || tipoSenha == cTipoSenha.OPERADOR) {
			log4console("indo solicitar senha");

			if (tipoSenha == cTipoSenha.SUPERVISOR) {
				altPedeSenhaCoordenador('registraSenha('+ nrctrcrd +',\'enviarBancoob( '+ nrctrcrd +' )\',4)', 2);
			} else if (tipoSenha == cTipoSenha.OPERADOR) {
                altPedeSenhaCoordenador('registraSenha('+ nrctrcrd +',\'enviarBancoob( '+ nrctrcrd +' )\',5)', 1);
            } else if (tipoSenha == cTipoSenha.COOPERADO) {
            	solicitaSenhaMagnetico('registraSenha('+ nrctrcrd +',\'enviarBancoob( '+ nrctrcrd +' )\',1)', nrdconta, true);
            }
            return;
        }
        if ($("#agentPassword:checked").val() != undefined) {
            var nrContaRepresentante =  ($("#agentPassword:checked").val().split("#")[2]);

            if (tipoSenha == cTipoSenha.COOPERADO) {
				solicitaSenhaMagnetico('registraSenha('+ nrctrcrd +',\'enviarBancoob( '+ nrctrcrd +')\',1)', nrContaRepresentante,true);
			}
        } else {
            showError("error", "Selecione um Representante para validar a senha. ", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        }

    });

}

function solicitaSenha(contrato,tipoSenha) {
    if (tipoSenha == undefined || tipoSenha == null) {
	    tipoSenha = cTipoSenha.COOPERADO;
	}
    try{
        if($("#btnsaveRequest").attr('onclick') != 'solicitaTipoSenha('+contrato+')'){
            $("#btnsaveRequest").attr('onclick','solicitaTipoSenha('+contrato+')');
    }}catch(e){
        console.log('estamos fora da tela novo');
    }
	//|| idastcjt !=1  inpessoa == 1
	if(inpessoa == 1 || tipoSenha == cTipoSenha.SUPERVISOR || tipoSenha == cTipoSenha.OPERADOR){
        validarSenha(contrato, tipoSenha);
        return;
    }
    showMsgAguardo("Aguarde ...");
    atualizaContrato(contrato,protocolo,"S", function(){
	var chklen =  $('input[name="dsadmcrdcc"]').length;
	var outros = false;
    for(j = 0; j< chklen; j++){	
            var o = $('input[name="dsadmcrdcc"]')[j];
            if($(o).attr("checked") == 'checked'){
                if($(o).val() == "outro")
                    outros = true;
            }
    }
	var esteira = outros? "s":"n";
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/cartao_credito/aprovacao_representantes.php",
        data: {
            tpacao: 'montagrid',
            nrdconta : nrdconta,
            nrctrcrd : contrato,
			esteira  : esteira
        },
        error: function (objAjax, responseError, objExcept) {

            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            exibeRotina($('#divRotina'));
            fechaRotina($('#divUsoGenerico'), $('#divRotina'));
            hideMsgAguardo();
            $("#divCartoes").show();
            $("#divBotoesSenha").hide();
            $("#stepRequest").hide();
            $("#ValidaSenha").html(response);
            $("#ValidaSenha").show();
            $('#tbTela').css({ 'width': '698px' });
            $('#divRotina').centralizaRotinaH();
            bloqueiaFundo($('#divRotina'));
            flgPrincipal = true;
        }
    });

    });

}
            
         
function solicitaTipoSenha(contrato,cdForm) {
    if (cdForm == undefined) {
        cdForm = 'novo';
    }
    try{
        if ($("#btnsaveRequest").attr('onclick') != 'solicitaTipoSenha(' + contrato + ',' + cdForm + ')') {
            $("#btnsaveRequest").attr('onclick', 'solicitaTipoSenha(' + contrato + ',' + cdForm + ')');
    }}catch(e){
        console.log('estamos fora da tela novo');
        }
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/cartao_credito/solicita_senha_autorizacao.php",
        data: {
            contrato:contrato,
            cdForm:cdForm
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");

        },
        success: function (response) {
            fechaRotina($('#divUsoGenerico'));
            exibeRotina($('#divRotina'));
            $('#divCartoes').hide();
            $('#divConteudoOpcao').append(response);
            $("#divBotoesSenha").show();
            $('#tbTela').css({ 'width': '410px' });
            $('#divRotina').centralizaRotinaH();
            bloqueiaFundo($('#divRotina'));
            // Saimos da tela principal
            flgPrincipal = false;
        }
    });
}

function verificaAutorizacoes() {
    
    showMsgAguardo("Aguarde ...");
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/cartao_credito/aprovacao_representantes.php",
        data: {
            tpacao: 'verificaAutorizacoes',
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd
        },
        error: function (objAjax, responseError, objExcept) {

            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            
            var autorizado = 3;
            eval(response);
            if(autorizado){
                $(".imprimeTermoBTN").show();
            }else{
                $("#continuaAprovacaoBTN").show();
            }
            hideMsgAguardo();

        }
    });
}

function voltadados() {
    $("#stepRequest").show();
    $("#ValidaSenha").hide();

}
var ipbancoob;
function imprimirTermoDeAdesao(btn) {
    showMsgAguardo("Aguarde...");
    var mapForm = document.createElement("form");
    mapForm.target = "Map";
    mapForm.method = "POST";

    mapForm.action = UrlSite + "telas/atenda/cartao_credito/imprimir_bancoob.php?inpessoa=" + inpessoa;
	if($(btn).attr("nmarqui") != undefined && $(btn).attr("nmarqui").length > 0){
		mapForm.action = UrlSite + "telas/atenda/cartao_credito/imprimir_bancoob.php?nmarqui="+$(btn).attr("nmarqui");
		var mapInput0 = document.createElement("input");
		mapInput0.type = "text";
		mapInput0.name = "nmarqui";
		mapInput0.value = $(btn).attr("nmarqui");
		mapForm.appendChild(mapInput0);
	}
    var mapInput = document.createElement("input");
    mapInput.type = "text";
    mapInput.name = "nrdconta";
    mapInput.value = nrdconta;
    var mapInput1 = document.createElement("input");
    mapInput1.type = "text";
    mapInput1.name = "nrctrcrd";
	if($("#emiteTermoBTN").attr("nrctrcrd"))
		mapInput1.value = $("#emiteTermoBTN").attr("nrctrcrd");
	else
    	mapInput1.value = nrctrcrd;
    var mapInput2 = document.createElement("input");
    mapInput2.type = "text";
    mapInput2.name = "cdcooper";
    mapInput2.value = $(btn).attr("cdcooper");
    var mapInput3 = document.createElement("input");
    mapInput3.type = "text";
    mapInput3.name = "cdagenci";
    mapInput3.value = $(btn).attr("cdagenci");
    var mapInput4 = document.createElement("input");
    mapInput4.type = "text";
    mapInput4.name = "nrdcaixa";
    mapInput4.value = $(btn).attr("nrdcaixa");
    var mapInput5 = document.createElement("input");
    mapInput5.type = "text";
    mapInput5.name = "idorigem";
    mapInput5.value = $(btn).attr("idorigem");
    var mapInput6 = document.createElement("input");
    mapInput6.type = "text";
    mapInput6.name = "cdoperad";
    mapInput6.value = $(btn).attr("cdoperad");//dsdircop
    var mapInput7 = document.createElement("input");
    mapInput7.type = "text";
    mapInput7.name = "dsdircop";
    mapInput7.value = $(btn).attr("dsdircop");
    mapForm.appendChild(mapInput);
    mapForm.appendChild(mapInput1);
    mapForm.appendChild(mapInput2);
    mapForm.appendChild(mapInput3);
    mapForm.appendChild(mapInput4);
    mapForm.appendChild(mapInput5);
    mapForm.appendChild(mapInput6);
    mapForm.appendChild(mapInput7);

    document.body.appendChild(mapForm);
	
	if(!(detectIE() === false)){
		mapForm.submit();
		hideMsgAguardo();
	}else{
		map = window.open("", "Map");

		if (map) {
			mapForm.submit();
			if($(btn).attr("nmarqui") == undefined || $(btn).attr("nmarqui").length == 0)
				voltarParaTelaPrincipal();
			else{
				hideMsgAguardo();
			}
		} else {
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. Pop Up bloqueados.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		}
		ipbancoob = map;
	}
	
    

	
}

function registraSenha(nrctrcrd, callback, indtipo_senha){
        showMsgAguardo("Aguarde...");
        var nrcpf = $("#nrcpfcgc","#frmNovoCartao").val();
        var nmaprovador = $("#nmextttl","#frmNovoCartao").val();
        if(nrcpf == undefined){
            nrcpf = $("#nrcpftit").val();
            nmaprovador = $("#nmextttl").val();
        }
        if (indtipo_senha == undefined) {
            indtipo_senha = 1;
        }
        if(inpessoa == 2 && (indtipo_senha == 1 || indtipo_senha == 2)){
            nmaprovador = ($("#agentPassword:checked").val().split("#")[1]);
            nrcpf = ($("#agentPassword:checked").val().split("#")[0]);
        }
		
		try{
			var rpr =  $("#dsgraupr").val();
		}catch(e){
			var rpr =  "";
		}
	  $.ajax({
            type: "POST",
            dataType: "html",
            url: UrlSite + "telas/atenda/cartao_credito/registra_senha.php",
            data: {
                tpacao: 'montagrid',
                nrdconta      : nrdconta,
                nrctrcrd      : nrctrcrd,
                nrcpf         : nrcpf,
				inpessoa      : inpessoa,
				dsgraupr      : rpr,
                nmaprovador   : nmaprovador,
                indtipo_senha : indtipo_senha,
                cdopelib      : cdopelib
            },
            error: function (objAjax, responseError, objExcept) {

                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                var error = false;
                hideMsgAguardo();

                eval(response);

                if (!error) {
				$("#divBotoesSenha").hide();
                $('#tbTela').css({ 'width': '850px' });
                    flgPrincipal = true;
                eval(callback);
				hideMsgAguardo();
                }

            }
        });
	    
}

function atualizaContrato(nrctrcrd,idacionamento,idproces, cbk)
{
	log4console("Atualizando contrato process "+idproces);
	var dsjustif = $("#justificativa").val();
	if(dsjustif != undefined && dsjustif.length == 0){
		dsjustif = justificativaCartao;
	}
    if(cdadmcrd == 0){
        if(inpessoa == 1){
            try{
                var crdAux = $('#dsadmcrd').children().attr("value").split(";");
                cdadmcrd = crdAux[0];
                log4console("new value ="+cdadmcrd);
            }catch(e){
                    var chklen =  $('input[name="dsadmcrdcc"]').length;
                    var outros = false;
                    for(j = 0; j< chklen; j++){	
                            var o = $('input[name="dsadmcrdcc"]')[j];
                            if($(o).attr("checked") == 'checked'){
                                if($(o).val() == "outro")
                                    outros = true;
                            }
                    }
                    if(outros){
                        var auxADM = $("#listType").val();
                        cdadmcrd = auxADM.split(";")[1];
                    }
            }
        }else{
            log4console("Resolvido");
            if($('#dsadmcrd').val().toUpperCase().indexOf("DEB") > -1){
                cdadmcrd = 17;
            }else{
                cdadmcrd = 15;
            }
        }
    }

    if(idacionamento == undefined)
        idacionamento = "";
    log4console("Executando a chamada atualiza_contrato");
	$.ajax({
            type: "POST",
            dataType: "html",
            url: UrlSite + "telas/atenda/cartao_credito/atualiza_contrato.php",
            data: {
                tpacao        : 'montagrid',
                nrctrcrd      : nrctrcrd,
                nrdconta      : nrdconta,
                idacionamento : idacionamento,
				dsjustif      : dsjustif,
                cdadmcrd      : cdadmcrd,
                inpessoa      : inpessoa,
                idproces      : idproces,
                flagIdprocess : flagIdprocess? "1":"2"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                hideMsgAguardo();
                log4console("chamada voltou chamando callback");
                cbk();
                eval(response);
            }
        });
	log4console("voltou stack");
}

function enviarBancoob(nrctrcrd){
              
    /* envia bancoob*/

    idacionamento = $("#idacionamento","#frmNovoCartao").val();
    log4console("5854 - protocolo : "+protocolo);
    atualizaContrato(nrctrcrd,idacionamento,"C",function(){
    var dsgraupr = $("#dsgraupr").val();
    showMsgAguardo("Aguarde Enviando solicita&ccedil;&atilde;o ...");
    var chklen =  $('input[name="dsadmcrdcc"]').length;
    var outros = false;
    for(j = 0; j< chklen; j++){	
            var o = $('input[name="dsadmcrdcc"]')[j];
            if($(o).attr("checked") == 'checked'){
                if($(o).val() == "outro")
                    outros = true;
            }
    }
    var objectSend = {
        tpacao: 'montagrid',
        nrdconta: nrdconta,
		glbadc  : glbadc,
        nrctrcrd: nrctrcrd,
        dsgraupr: dsgraupr,
        inpessoa: inpessoa,
        bancoob : 1
    };
    if(outros || globalesteira) {
        var objectSend = {
        tpacao: 'montagrid',
        nrdconta: nrdconta,
		glbadc  : glbadc,
        nrctrcrd: nrctrcrd,
        dsgraupr: dsgraupr,
        inpessoa: inpessoa,
        bancoob : 2,
        justificativa : $("#justificativa").val()
        }

    }
		
        $.ajax({
            type: "POST",
            dataType: "html",
            url: UrlSite + "telas/atenda/cartao_credito/solicitar_cartao_bancoob.php",
            data: objectSend,
            error: function (objAjax, responseError, objExcept) {

                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                hideMsgAguardo();
                eval(response);
            }
        });

    });
}

function reenviarBancoob(nrctrcrd){
	showMsgAguardo("Aguarde Enviando solicita&ccedil;&atilde;o ...");
	
	/* Para forcar o envio */
	var dsgraupr = 5;
	
	var objectSend = {
        tpacao: 'montagrid',
        nrdconta: nrdconta,
        glbadc  : glbadc,
        nrctrcrd: nrctrcrd,
        dsgraupr: dsgraupr,
        inpessoa: inpessoa,
        bancoob : 1
    };
	$.ajax({
            type: "POST",
            dataType: "html",
            url: UrlSite + "telas/atenda/cartao_credito/solicitar_cartao_bancoob.php",
            data: objectSend,
            error: function (objAjax, responseError, objExcept) {

                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                hideMsgAguardo();
                eval(response);
            }
        });
}

function verificaRetornoBancoob(nrctrcrd){
              
    /* envia bancoob*/
     showMsgAguardo("Aguarde Enviando verificando retorno do bancoob"); 
     var sitcrd = $("#dssituac").val();
        $.ajax({
            type: "POST",
            dataType: "html",
            url: UrlSite + "telas/atenda/cartao_credito/verifica_retorno_ws_bancoob.php",
            data: {
                nrdconta: nrdconta,
                nrctrcrd: nrctrcrd,
                dssituac: sitcrd            
            },
            error: function (objAjax, responseError, objExcept) {

                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                hideMsgAguardo();
                eval(response);
            }
        });
}

function alterarBancoob(autorizado,inpessoa,tipo, contrato){
    
    var vlnovlim = $("#vlnovlim").val();
    if(vlnovlim == undefined)
        vlnovlim = '100,00';
    while(vlnovlim.indexOf(".") > -1){
        vlnovlim = vlnovlim.replace(".","");
    }
    vlnovlim = vlnovlim.replace(",",".");
   /* if(parseFloat(vlnovlim) == 0){
        showError("error", "Por favor informe um valor sugerido para o novo limite.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return;
    }*/
    if (istitular)
        titular = 's';
    else
        titular = 'n';

    
    /* envia bancoob*/
     showMsgAguardo("Aguarde Enviando solicita&ccedil;&atilde;o ..."); 
        $.ajax({
            type: "POST",
            dataType: "html",
            url: UrlSite + "telas/atenda/cartao_credito/solicitar_cartao_bancoob.php",
            data: {
                tpacao: 'alterar',
                nrdconta      :   nrdconta,
                nrctrcrd      :   contrato,
                vlnovlim      :   vlnovlim,
                inpessoa      :   inpessoa,
                tipo          :   tipo,
                titular       :   titular,
                autorizado    :   autorizado,
                vlsugmot      :   vlsugmot,
                vllimmin      :   vllimmin,
                vllimmax      :   vllimmax,
				vlLimiteMaximo:   vlLimiteMaximo,
				limiteatualCC :   limiteatualCC,
                protocolo     :   protocolo,
				cdadmcrd      :   cdadmcrd,
                justificativa :   $("#justificativa").val()
				

            },
            error: function (objAjax, responseError, objExcept) {

                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                hideMsgAguardo();
                eval(response);
                //imprimirTermoDeAdesao(btn);
            }
        });

}

function alertarCooperado(tipoAcao) {
    if (tipoAcao == undefined) {
        tipoAcao = cTipoAcao.NOVO_CARTAO;
    }

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/alertar_cooperado.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            tipoAcao : tipoAcao,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            eval(response);
        }
    });
}

function atualizaLimite(){
    var vllimite_anterior = converteNumero($("#vllimtit", "#frmNovoCartao").val());
    var vllimite_alterado = converteNumero($("#vlnovlim", "#frmNovoCartao").val());
    var dsjustificativa = $("#justificativa", "#frmNovoCartao").val();

    showMsgAguardo("Aguarde Enviando solicita&ccedil;&atilde;o ...");
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/cartao_credito/atualiza_limite.php",
        data: {
            nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
            insitdec: 1,
            tpsituacao: 6,
            vllimite_anterior: vllimite_anterior,
            vllimite_alterado: vllimite_alterado,
            dsjustificativa: dsjustificativa
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            hideMsgAguardo();
            eval(response);
        }
    });

}

function reenviaEsteira(nrctrcrd){

    showMsgAguardo("Aguarde enviando para a Esteira ...");   
    
    var objectSend = {
        tpacao: 'montagrid',
        nrdconta: nrdconta,
        nrctrcrd: nrctrcrd,
		glbadc  : glbadc,
        dsgraupr: 5,
        inpessoa: inpessoa,
        bancoob : 2
    }
		
	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/atenda/cartao_credito/solicitar_cartao_bancoob.php",
		data: objectSend,
		error: function (objAjax, responseError, objExcept) {

			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			hideMsgAguardo();
			eval(response);
		}
	});

}

function log4console(param){
    console.log(param);
}
function formatNrcartao(nrcartaoParam){
	for(begin = 6; begin <12; begin++){
    	nrcartaoParam = replaceAt(begin,"*",nrcartaoParam );
    }
    console.log(nrcartaoParam);
    String.prototype.splice = function(idx, rem, str) {
        return this.slice(0, idx) + str + this.slice(idx + Math.abs(rem));
    };
    return (nrcartaoParam.splice(4,0,".").splice(9,0,".").splice(14,0,"."));

}

function replaceAt(index, replacement, str) {
    return str.substr(0, index) + replacement+ str.substr(index + replacement.length);
}
 
function ativa(id){
	
	$("#"+id).removeAttr("disabled");
	$("#"+id).removeAttr("readonly");
	console.log("ativanddo "+id);
}
function desativa(id){
	$("#"+id).attr("disabled",true);
	$("#"+id).attr("readonly",true);
}
 
function detectIE() {
  var ua = window.navigator.userAgent;

  var msie = ua.indexOf('MSIE ');
  if (msie > 0) {
    // IE 10 or older => return version number
    return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
  }

  var trident = ua.indexOf('Trident/');
  if (trident > 0) {
    // IE 11 => return version number
    var rv = ua.indexOf('rv:');
    return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
  }

  var edge = ua.indexOf('Edge/');
  if (edge > 0) {
    // Edge (IE 12+) => return version number
    return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
  }

  // other browser
  return false;
}

function abreProtocoloAcionamento(dsprotocolo) {

    showMsgAguardo('Aguarde, carregando...');

    // Executa script de através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/form_acionamentos.php',
        data: {
            dsprotocolo: dsprotocolo,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            hideMsgAguardo();			
			if (response.substr(0,4) == "hide") {
				eval(response);
			} else {
                $('#nmarqui', '#frmImprimir').val(response);
                //var action = UrlSite + 'telas/atenda/emprestimos/form_acionamentos.php';
				//var action = UrlSite + 'telas/conpro/impressao.php';
				$("#emiteTermoBTN").attr("nmarqui",response);
				$("#emiteTermoBTN").click();
			}
            return false;
        }
    });
}

function chamarCoordenador(nrctrcrd, idacionamento,idproces){
	senhaCoordenador("atualizaContrato(" + nrctrcrd + ",'" + idacionamento +"','" + idproces + "', function(){solicitaSenha("+nrctrcrd+", "+cTipoSenha.OPERADOR+");} )");	
}
function alterarLimiteProposta() {
    var cdAdmCartao = $("#btnalterarLimite").attr("cdAdmCartao");
    nomeForm = "frmValorLimCre";

    // Saimos da tela principal
    flgPrincipal = false;

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/cartao_credito/alterar_limite_cartao_proposta.php",
        data: {
            nrcrcard      : nrcrcard,
            nrdconta      : nrdconta,
            cdadmcrd      : cdadmcrd,
            cdAdmCartao   : cdAdmCartao,
            nrctrcrd      : nrctrcrd,
        },
        error: function (objAjax, responseError, objExcept) {

            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao1").html(response);
        }
    });
}

function alterarCartaoProposta() {
    nomeForm = "frmNovoCartao";
    
    // Saimos da tela principal
    flgPrincipal = false;

    $.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/atenda/cartao_credito/alterar_cecred.php",
		data: {
			nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
			inpessoa: inpessoa,
			redirect: "html_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {
							
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoesDaOpcao1").html(response);			
		}				
	});
}

function continuarCartaoProposta(nrctrcrd) {
    nomeForm = "frmNovoCartao";
    
    // Saimos da tela principal
    flgPrincipal = false;

    showMsgAguardo("Aguarde, carregando...");

    $.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/atenda/cartao_credito/continuar_cecred.php",
		data: {
			nrdconta: nrdconta,
            nrctrcrd: nrctrcrd,
			inpessoa: inpessoa,
			redirect: "html_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {							
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoesDaOpcao1").html(response);			
            hideMsgAguardo();
		}				
	});
}

function validaAlterarProposta() {
    if (nrctrcrd == 0) {
        hideMsgAguardo();
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }
    showMsgAguardo("Aguarde, carregando ...");
    $.ajax({
        dataType: "json",
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/verifica_administradora.php",
        data: {
            cdadmcrd: cdadmcrd,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            if (response.administradora == 2) { // Bancoob
                opcaoAlterarProposta();
            } else { // Demais
                hideMsgAguardo();
                showError("error", "O cart&atilde;o selecionado n&atilde;o &eacute; Bancoob.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function converteNumero(numero) {
    return numero.replace('.', '').replace(',', '.');
}

function opcaoAlterarProposta() {
    if (cdadmcrd == 16 || cdadmcrd == 17) {
        hideMsgAguardo();
        showError("error", "Edi&ccedil;&atilde;o de proposta n&atilde;o permitida, somente para cart&otilde;es do tipo cr&eacute;dito!", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }
    $.ajax({
            dataType: "html",
            type: "POST",
            url: UrlSite + "telas/atenda/cartao_credito/verifica_tipo_proposta.php",
            data: {
                nrdconta: nrdconta,
                nrctrcrd: nrctrcrd,
                cdadmcrd: cdadmcrd,
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
            },
            success: function (response) {
                hideMsgAguardo();                
                blockBackground(parseInt($("#divRotina").css("z-index")));
                eval(response);
            }
    });
}

// Função para retornar à partir da tela de Endereço
function voltarEndereco(tipoAcao) {
    exibeRotina($('#divRotina'));
    fechaRotina($('#divUsoGenerico'), $('#divRotina'));
    if (tipoAcao == cTipoAcao.ALTERAR_ENDERECO || tipoAcao == cTipoAcao.UPGRADE_DOWNGRADE) {
        voltarParaTelaPrincipal();
    }
    return false;
}

// Função para consultar endereços de entrega para o cooperado
function consultaEnderecos(tipoAcao) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, consultando dados do cart&atilde;o de cr&eacute;dito ...");

	// Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/consultar_enderecos.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            tipoacao: tipoAcao,
            nrctrcrd: nrctrcrd,
            nrctrcrd_updown: (nrctrcrd_updown || 0),
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            exibeRotina($('#divUsoGenerico'));
            $('#divUsoGenerico').html(response);
        }
    });
}

function validaReenvioAltLimite(nrcctitg) {

    if (nrcctitg == 0) {
        return false;
    }

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/valida_reenvio_alt_limite.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrcctitg: nrcctitg,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            hideMsgAguardo();
            eval(response)
        }
    });


}

function reenviarUltimaPropostaLimite(nrcrcard, cdadmcrd, nrctrcrd) {

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/cartao_credito/alterar_limite_cartao_proposta.php",
        dataType: "html",
        data: {
            nrcrcard      : nrcrcard,
            nrdconta      : nrdconta,
            cdadmcrd      : cdadmcrd,
            cdAdmCartao   : cdadmcrd,
            nrctrcrd      : nrctrcrd,
        },
        error: function (objAjax, responseError, objExcept) {

            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            voltaDiv(0,1,4);
			$("#divOpcoesDaOpcao1").html(response);
            }
    });


}

function alterarEndereco() {
    if (nrctrcrd == 0) {
        showError("error", "N&atilde;o h&aacute; cart&atilde;o selecionado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }
    if($("#btnalterarLimite").attr("situacao") != undefined && $("#btnalterarLimite").attr("situacao") == "situacao"){
		showError("error", "Altera&ccedil;&atilde;o de endere&ccedil;o permitida apenas para cart&otilde;es com a situa&ccedil;&atilde;o 'Em Uso'.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return;
	}

    if(flgprcrd == 0) {
        showError("error", "Altera&ccedil;&atilde;o de endere&ccedil;o permitida apenas para cart&otilde;es titular.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return;
    }

    consultaEnderecos(cTipoAcao.ALTERAR_ENDERECO);
    return false;
}

function validaLimite() {
    var vllimmot = $("#vllimmot", "#frmNovoCartao").val();
    var vllimpro = $("#vllimpro", "#frmNovoCartao").val();
    
    vllimmot = parseFloat((vllimmot || "0").replace(/\./g,'').replace(",","."));
    vllimpro = parseFloat((vllimpro || "0").replace(/\./g,'').replace(",","."));

    // rejeitado pelo motor
    if (vllimmot == 0) {
        return;
    }
    
    globalesteira = false;
    if (vllimpro > vllimmot) {
        globalesteira = true;
        showError("error", "Limite maior que o sugerido pelo motor, a proposta sera enviada para a esteira.</br>Limite sugerido pelo motor: R$ " + vllimmot + ".", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }
}

function removeAcentoJustificativaEsteira(){

	var _str = function ()
	{       
		var text = $("#justificativa").val();
		text = text.toLowerCase();                                                         
		text = text.replace(new RegExp('[ÁÀÂÃ]','gi'), 'a');
		text = text.replace(new RegExp('[ÉÈÊ]','gi'), 'e');
		text = text.replace(new RegExp('[ÍÌÎ]','gi'), 'i');
		text = text.replace(new RegExp('[ÓÒÔÕ]','gi'), 'o');
		text = text.replace(new RegExp('[ÚÙÛ]','gi'), 'u');
		text = text.replace(new RegExp('[Ç]','gi'), 'c');
		text = text.replace(new RegExp('[~^´`\'\"!@#$%¨]','gi'), '');
		return text;                 
	}
	$("#justificativa").val(_str);
}