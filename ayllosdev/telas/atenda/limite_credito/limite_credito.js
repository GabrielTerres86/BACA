/*!
 * FONTE        : limite_credito.js
 * CRIAÇÃO      : David
 * DATA CRIAÇÃO : Setembro/2007
 * OBJETIVO     : Biblioteca de funções da rotina de Limite de Crédito 
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [13/04/2010] David     (CECRED)  : Adaptação para novo RATING
 * 000: [16/09/2010] David     (CECRED)  : Ajuste para enviar impressoes via email para o PAC Sede
 * 000: [27/10/2010] David     (CECRED)  : Tratamento para projeto de linhas de crédito 
 * 001: [28/04/2011] Rodolpho      (DB1) : Adaptação para o Zoom Endereço e Avalistas genérico
 * 002: [28/06/2011] Rogérius      (DB1) : Tableless - Inlcui as funções formatacaoPrincipal(), formatacaoUltimasAlteracoes() e formatacaoImprimir()
 * 003: [05/09/2011] Adriano   (CECRED)  : Alterado a function confirmaNovoLimite para passar o nrcpfcgc na requisição ajax;
 * 004: [23/09/2011] Guilherme (CECRED)  : Adaptar para Rating Singulares
 * 005: [09/11/2011] Fabricio  (CECRED)  : Incluido parametro na funcao trataRatingSingulares para verificar se todos os itens estao selecionados, antes
 *                                         de continuar a operacao.
 *                                         Incluido parametro flgratok na funcao confirmaNovoLimite, para indicar se ja foi informado os itens do rating.
 * 006: [30/05/2012] JOrge     (CECRED)  : Criado funcao checaEnter(), funcao para retornar true caso seja tecla Enter. 
 * 007: [27/06/2012] Jorge     (CECRED)  : Alterado esquema para impressao, retirao window.open (Jorge)
 * 008: [28/08/2012] Lucas R.  (CECRED)  : Declarado variavel flgProposta.
 * 009: [22/11/2012] Adriano   (CECRED)  : Ajustes referente ao projeto GE.
 * 010: [02/07/2014] Jonata      (RKAM)  : Permitir alterar a observacao da proposta.
 * 011: [23/12/2014] James               : Incluir a acao Renovar. (James)
 * 012: [09/01/2015] Tiago     (CECRED)  : Incluir acao alterar proposta.
 * 013: [20/02/2015] Kelvin    (CECRED)  : Corrigido erro das abas duplicadas
 * 014: [23/02/2015] Kelvin    (CECRED)  : Adicionado formatação no momento de adicionar os valores nos campos dos "dados da renda" e o campo SFN do "rating"
 * 015: [06/04/2015] Jonata      (RKAM)  : Consultas Automatizadas.
 * 016: [01/06/2015] Reinert   (CECRED)  : Alterado para apresentar mensagem de confirmacao de proposta para
 *                                         menores nao emancipados. (Reinert)
 * 017:[08/10/2015] Gabriel    (RKAM)    : Reformulacao cadastral (Gabriel-RKAM).
 * 018:[26/01/2016] Heitor     (RKAM)    : Chamado 364592 - Alterada atribuicao ao campo vloutras, nao estava preenchendo corretamente ao retornar valor decimal
 *
 * 018: [17/12/2015] Lunelli   (CECRED)  : Edição de número do contrato de limite (Lucas Lunelli - SD 360072 [M175])
 * 019: [15/07/2016] Andrei    (RKAM)    : Ajuste para utilizar rotina convertida a buscar as linhas de limite de credito.
 * 020: [25/07/2016] Evandro     (RKAM)  : Alterado função controlaFoco.         
 * 021: [08/08/2017] Heitor    (MOUTS)   : Implementacao da melhoria 438.
 * 022: [14/11/2017] Mateus Z    (MOUTS) : Adicionado a coluna Operador na tabela Ultimas Alterações. Chamado 791852
 * 022: [01/12/2017] Jonata      (RKAM)  : Não permitir acesso a opção de incluir quando conta demitida.
 * 023: [05/12/2017] Lombardi  (CECRED)  : Gravação do campo idcobope e inserção da tela GAROPC. Projeto 404
 * 024: [18/12/2017] Augusto / Marcos (Supero): P404 - Inclusão de Garantia de Cobertura das Operações de Crédito
 * 025: [06/03/2018] Reinert (CECRED)    : Adicionado parametro idcobope na chamada do fonte confirma_novo_limite. (PRJ404 Reinert)
 * 026: [15/03/2018] Diego Simas (AMcom) : Alterado para exibir tratativas quando o limite de crédito foi
 *                                         cancelado de forma automática pelo Ayllos.
 * 027: [22/03/2018] Diego Simas (AMcom) : Implementado nova situação para considerar Cancelamento Automático de Limite
 *                                         por inadimplência e também novo campo onde contém a data do cancelamento automático.
 * 028: [13/04/2018] Lombardi  (CECRED)  : Inluidas funcoes validaAdesaoValorProduto e senhaCoordenador. PRJ366 (Lombardi).
 * 029: [27/06/2018] Christian Grosch (CECRED): Ajustes JS para execução do Ayllos em modo embarcado no CRM.
 * 030: [09/10/2018] Marco Antonio Rodrigues Amorim(Mout's) : Remove ponto do usuario e substitui virgula da casa decimal por ponto.
 * 031: [27/11/2018] Bruno Luiz Katzjarowski (Mout's): Criação da nova tela principal (nova rotina acessaTela) 
 * 032: [15/05/2019] Anderson Schloegel (Mout's): PJ470 - Mout's - Desabilitar campo de contrato para aba Novo Limite
 * 033: [04/06/2019] Mateus Z  (Mouts) : Alteração para chamar tela de autorização quando alterar valor. PRJ 470 - SM2
 * 034: [30/05/2019] Mateus Zimmermann (Mout's): PRJ 438 - Criadada váriaveis para armazenar conta e contrato formatados. 
 * 035: [29/06/2019] Mateus Z (Mouts): PRJ 438 - Sprint 13 - Alterado largura da coluna Motivo da tela Últimas alterações para 
 *                   suportar o motivo 'Cancelado automaticamente por inadimplência' (Mateus Z / Mouts) 
 * 035: [15/02/2019] Luiz Otávio Olinger Momm (AMCOM) : Adicionado campos de rating conforme estória 13988.
 * 036: [18/02/2019] Luiz Otávio Olinger Momm (AMCOM) : Adicionado botão Analisar conforme estória 16678.
 * 037: [21/03/2019] Luiz Otávio Olinger Momm (AMCOM) : Remover Etapa Rating
 * 038: [12/04/2019] Luiz Otávio Olinger Momm (AMCOM) : Atualizar tela após análise do Rating
 * 039: [15/04/2019] Luiz Otávio Olinger Momm (AMCOM) : Identificação quando for Analisar e quando for Alterar Rating P450 
 * 040: [21/03/2019] Luiz Otávio Olinger Momm (AMCOM) : Remover Etapa Rating Novo Limite Credito
 * 041: [29/03/2019] Luiz Otávio Olinger Momm (AMCOM) : Manter Etapa Rating Novo Limite Credito para Central Ailos

*/
 
var callafterLimiteCred = '';
var nrctrimp = '0';  // Variável para armazenar código do contrato para impressão
var nrctrpro = '0';  // Variável para armazenar contrato da proposta
var cddlinha = '';   // Variável para acumular código da linha de crédito informada no form de novo limite
var situacao_limite = ""; // Variável para armazenar a situação do limite atualmente selecionado
var flgProposta;     //Existe ou não uma proposta cadastrada
var flgAltera;
var dsinfcad;

var nomeForm = 'frmNovoLimite';             // Variável para guardar o nome do formulário corrente
var boAvalista = 'b1wgen0019.p';            // BO para esta rotina
var procAvalista = 'obtem-dados-avalista';  // Nome da procedures que busca os avalistas

var strHTML = ''; // Variável usada na criação da div de alerta do grupo economico.
var strHTML2 = ''; // Variável usada na criação do form onde serão mostradas as mensagens de alerta do grupo economico. 
var dsmetodo = ''; // Variável usada para manipular o método a ser executado na função encerraMsgsGrupoEconomico.
        
var aux_inconfir = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi2 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/

var idSocio = 0;       // Indicador do socio para as consultas automatizadas
var ant_inconcje = 0;
        
        
// Variável que armazena o nome da rotina conforme tipo de pessoa (1 - Física / 2 - Jurídica)
var strTitRotinaLC = inpessoa == 1 ? "Limite de Cr&eacute;dito" : "Limite Empresarial";
var strTitRotinaUC = inpessoa == 1 ? "LIMITE DE CR&Eacute;DITO" : "LIMITE EMPRESARIAL";

// array com os dados do rating das singulares
var arrayRatingSingulares = new Array();

// Pj470 - SM2 -- Mateus Zimmermann -- Mouts
var aux_vllimite_anterior = "";
// Fim Pj470 - SM2

// Carrega biblioteca javascript referente ao RATING
$.getScript(UrlSite + 'includes/rating/rating.js');

// Carrega biblioteca javascript referente aos AVALISTAS
//$.getScript(UrlSite + 'includes/avalistas/avalistas.js');	

// Carrega biblioteca javascript referente as CONSULTAS AUTOMATIZADAS
$.getScript(UrlSite + "includes/consultas_automatizadas/protecao_credito.js");

// bruno - prj 438 - sprint 7 - rating
$.getScript(UrlSite + "telas/atenda/limite_credito/js/tela_rating.js");

// PRJ 438 - sprint 7 - Avalistas
$.getScript(UrlSite + "telas/atenda/limite_credito/js/tela_avalistas.js");

//bruno - prj 470 - tela autorizacao
$.getScript(UrlSite + 'includes/autorizacao_contrato/autorizacao_contrato.js');

//bruno - prj 470 - tela autorizacao
var var_globais = { 
    vllimite: '',
	dslimcre: '',
	dtmvtolt: '',
	dsfimvig: '',
	dtfimvig: '',
	nrctrlim: '',
	qtdiavig: '',
	dsencfi1: '',
	dsencfi2: '',
	dsencfi3: '',
	dssitlli: '',
	dsmotivo: '',
	nmoperad: '',
	flgpropo: '',
	nrctrpro: '',
	cdlinpro: '',
	vllimpro: '',
	nmopelib: '',
	flgenvio: '',
	flgenpro: '',
	cddlinha: '',
	dsdlinha: '',
	tpdocmto: '',
	flgdigit: '',
	dsobserv: '',
	dstprenv: '',
	dtrenova: '',
	qtrenova: '',
	flgimpnp: '',
	dslimpro: '',
	idcobope: '',
	inpessoa: '',
	nrdconta: '',
	nivrisco: '',
	dsdtxfix: '',
	dtultmaj: '',
	dtcanlim: '',
	nrdcontaFormatada: '',
	habrat: 'N'
}

//bruno - prj - 438 - sprint 7 - tela principal
//guardar dados vindos da proc de consulta para ativo e pausado
//atribuido em tabelas/tabela_tela_principal.php
var aux_limites = {
    ativo: {
        dtpropos: "",
        dtinivig: "",
        nrctrlim: "",
        vllimite: "",
        txmensal: "",
        dtfimvig: "",
        dtrenova: "",
        insitlim: "",
        lfgsitua: "",
        inpessoa: "",
        qtdiavig: "",
        cddlinha: "",
        dsdlinha: "",
        nivrisco: "",
        dsdtxfix: "",
        nrgarope: "",
        nrinfcad: "",
        nrliquid: "",
        nrpatlvr: "",
        nrperger: "",
        idcobope: "",
        dsobserv: "",
        nrctrlimFormatado: ""
    },
    pausado: {
        dtpropos: "",
        dtinivig: "",
        nrctrlim: "",
        vllimite: "",
        txmensal: "",
        dtfimvig: "",
        dtrenova: "",
        insitlim: "",
        lfgsitua: "",
        inpessoa: "",
        qtdiavig: "",
        cddlinha: "",
        dsdlinha: "",
        nivrisco: "",
        dsdtxfix: "",
        nrgarope: "",
        nrinfcad: "",
        nrliquid: "",
        nrpatlvr: "",
        nrperger: "",
        idcobope: "",
        dsobserv: ""
    }
};

//bruno - prj - 438 - sprint 7 - tela principal
var aux_cddopcao = "";

//bruno - prj - 438 - sprint 7 - tela ratong
var aux_opcaoAtiva = "";

// bruno - prj 438 - sprint 7 - demo limite credito
$.getScript(UrlSite + "telas/atenda/limite_credito/js/tela_demo_limite_credito.js");

var aux_nrctaav0 = '';
var aux_nmdaval0 = '';
var aux_nrcpfav0 = '';
var aux_tpdocav0 = '';
var aux_dsdocav0 = '';
var aux_nmdcjav0 = '';
var aux_cpfcjav0 = '';
var aux_tdccjav0 = '';
var aux_doccjav0 = '';
var aux_ende1av0 = '';
var aux_ende2av0 = '';
var aux_nrfonav0 = '';
var aux_emailav0 = '';
var aux_nmcidav0 = '';
var aux_cdufava0 = '';
var aux_nrcepav0 = '';
var aux_cdnacio0 = '';
var aux_vledvmt0 = '';
var aux_vlrenme0 = '';
var aux_nrender0 = '';
var aux_complen0 = '';
var aux_nrcxaps0 = '';
var aux_inpesso0 = '';
var aux_dtnasct0 = '';
var aux_vlrencj0 = '';

var aux_nrctaav1 = '';
var aux_nmdaval1 = '';
var aux_nrcpfav1 = '';
var aux_tpdocav1 = '';
var aux_dsdocav1 = '';
var aux_nmdcjav1 = '';
var aux_cpfcjav1 = '';
var aux_tdccjav1 = '';
var aux_doccjav1 = '';
var aux_ende1av1 = '';
var aux_ende2av1 = '';
var aux_nrfonav1 = '';
var aux_emailav1 = '';
var aux_nmcidav1 = '';
var aux_cdufava1 = '';
var aux_nrcepav1 = '';
var aux_cdnacio1 = '';
var aux_vledvmt1 = '';
var aux_vlrenme1 = '';
var aux_nrender1 = '';
var aux_complen1 = '';
var aux_nrcxaps1 = '';
var aux_inpesso1 = '';
var aux_dtnasct1 = '';
var aux_vlrecjg1 = '';

// PRJ 438
var aux_dtmvtolt = '';

var aux_operacao = ''; // Controlar se é alteraca ou inclusao

/**
 * bruno - prj - 438 - sprint 7 - tela principal
 * Função para acessar opções da rotina
 * @param {código da opção} cddopcao 
 */
function acessaTela(cddopcao) {

    aux_cddopcao = cddopcao;

    var flpropos;
	
	//Projeto CRM: Se for uma das situações não deve permitir acesso a inclusão.
	if((sitaucaoDaContaCrm == '4' || 
	    sitaucaoDaContaCrm == '7' || 
	    sitaucaoDaContaCrm == '8' ) &&
        (cddopcao == "N" || cddopcao == "N1")){
	    showError('inform', 'Situa&ccedil;&atilde;o de conta n&atilde;o permite acesso34.', 'Alerta - Aimaro', 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
		return false;
		
    }

    var msgAguarde = '';
    var urlOperacao = UrlSite + "telas/atenda/limite_credito/";
    
    switch (cddopcao) {
        case '@': //Opção principal
            msgAguarde = ", carregando dados do " + strTitRotinaLC;
            urlOperacao += "form_tela_principal.php"; //Bruno - prj - 438 - sprint 7 - tela principal
            aux_opcaoAtiva = 'PRINCIPAL';
            break;
        case 'ALT':
                mostraTelaAltera();
                return false;
            break;
        case 'N': // Opção Novo Limite N ou N1
        case 'N1':
            msgAguarde = ", carregando op&ccedil;&atilde;o para novo " + strTitRotinaLC;
            urlOperacao += "novo_limite.php";
            nomeForm = 'frmNovoLimite';
            flpropos = true;
            cddopcao = "N";
            break;
        case 'U': // Opção Últimas Alterações
            msgAguarde = ", carregando &uacute;ltimas altera&ccedil;&otilde;es do " + strTitRotinaLC;
		    urlOperacao += "ultimas_alteracoes.php";
            break;
        case 'I': // Opção Imprimir		
            msgAguarde = ", carregando op&ccedil;&atilde;o para impress&otilde;es";
		    urlOperacao += "imprimir.php";
            break;
        case 'IA': //Opcao: Impressao com tela de autorizacao
            chamarImpressaoLimiteCredito(false);
            return false;
            break;
        case 'A': // Opção consulta limite ativo
		    msgAguarde = ", carregando o limite ativo ";
		    urlOperacao += "novo_limite.php";
		    flpropos = false;
            break;
        case 'P': // Opcao consulta limite proposto
		    msgAguarde = ", carregando o limite proposto ";
		    urlOperacao += "novo_limite.php";
		    flpropos = true;
            break;
        case 'E': // Opcao efetivar limite
		    msgAguarde = ", carregando a efetiva&ccedil;&atilde;o ";
		    urlOperacao += "form_efetivar.php";
		    flpropos = true;
            break;   
        case 'R': // Opção renovar
		    msgAguarde = ", carregando o limite ativo ";
		    urlOperacao += "novo_limite.php";
		    flpropos = false;
            break; 
    }
		
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde" + msgAguarde + " ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST", 
		dataType: "html",
		url: urlOperacao,
		data: {
			nrdconta: nrdconta,
			cddopcao: cddopcao,
            flpropos: flpropos,
            inpessoa: var_globais.inpessoa, //bruno - prj 438 - sprint 7 - novo limite
			inconfir: cddopcao == 'A' || cddopcao == 'P' ? 0 : 1, // Se for consulta NÃO fazer validação, senão, fazer validação
			redirect: "html_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
        	if (response.indexOf('showError("error"') == -1) {
				$("#divConteudoOpcao").html(response);
				controlaFoco(cddopcao);
			}else{
				eval(response);
			}
		}				
	});	
}

/*  Criar array de objetos com os dados do Rating - 004 */
function trataRatingSingulares(qtdTotalTopicos) {
    if (aux_cdcooper == 3 || var_globais.habrat == 'N') {
        showMsgAguardo("Aguarde, validando itens do rating...");

        arrayRatingSingulares = new Array();

        //var nomeCampo = "";
        $("select", '#frmDadosRatingSingulares').each(function () {
        
            i = arrayRatingSingulares.length;
        
            eval('var regFilho' + i + ' = new Object();');
        
            eval('regFilho' + i + '["nrtopico"] = $(this).attr("name").substr($(this).attr("name").indexOf("topico_") + 7, ($(this).attr("name").indexOf("item_") - 1) - ($(this).attr("name").indexOf("topico_") + 7))');
            eval('regFilho' + i + '["nritetop"] = $(this).attr("name").substr($(this).attr("name").indexOf("item_") + 5)');
            eval('regFilho' + i + '["nrseqite"] = $(this).val()');
        
            eval('arrayRatingSingulares[' + i + '] = regFilho' + i + ';');
            
            if (arrayRatingSingulares[i]["nrseqite"] == "" || !validaNumero(arrayRatingSingulares[i]["nrseqite"], true, 0, 0)) {
                hideMsgAguardo();
                showError("error", "Item " + arrayRatingSingulares[i]["nrtopico"] + "." + arrayRatingSingulares[i]["nritetop"] + " n&atilde;o informado.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                return false;
            } else {
                if (qtdTotalTopicos == i + 1) {
                    confirmaNovoLimite(1, true);
                }
            }
            i++;
        });
    
        return false;
    } else {
        confirmaNovoLimite(1, true);
    }
}

// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes, id, cddopcao) {

    var flpropos;
    
    //Projeto CRM: Se for uma das situações não deve permitir acesso a inclusão.
    if((sitaucaoDaContaCrm == '4' || 
        sitaucaoDaContaCrm == '7' || 
        sitaucaoDaContaCrm == '8' ) &&
        (cddopcao == "N" || cddopcao == "N1")){ 

        showError('inform', 'Situa&ccedil;&atilde;o de conta n&atilde;o permite acesso.', 'Alerta - Aimaro', 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
        return false;
        
    }
    
    if (cddopcao == "@") {  // Opção Principal
        var msg = ", carregando dados do " + strTitRotinaLC;
		var urlOperacao = UrlSite + "telas/atenda/limite_credito/form_tela_principal.php"; //Bruno - prj - 438 - sprint 7 - tela principal
    } else if (cddopcao == "N" || cddopcao == "N1") { // Opção Novo Limite
        var msg = ", carregando op&ccedil;&atilde;o para novo " + strTitRotinaLC;
        var urlOperacao = UrlSite + "telas/atenda/limite_credito/novo_limite.php";
        nomeForm = 'frmNovoLimite';
        flpropos = true;

        if (cddopcao == "N" && $("a[name=N]").text() == "Alterar Limite") {
            mostraTelaAltera();
            return false;
        } else {
            cddopcao = "N";
        }

    } else if (cddopcao == "U") { // Opção Últimas Alterações
        var msg = ", carregando &uacute;ltimas altera&ccedil;&otilde;es do " + strTitRotinaLC;
        var urlOperacao = UrlSite + "telas/atenda/limite_credito/ultimas_alteracoes.php";
    } else if (cddopcao == "I") { // Opção Imprimir     
        var msg = ", carregando op&ccedil;&atilde;o para impress&otilde;es";
        var urlOperacao = UrlSite + "telas/atenda/limite_credito/imprimir.php";
    } else if (cddopcao == "A") { // Opção consulta limite ativo
        var msg = ", carregando o limite ativo ";
        var urlOperacao = UrlSite + "telas/atenda/limite_credito/novo_limite.php";
        flpropos = false;
    } else if (cddopcao == "P") { // Opcao consulta limite proposto
        var msg = ", carregando o limite proposto ";
        var urlOperacao = UrlSite + "telas/atenda/limite_credito/novo_limite.php";
        flpropos = true;
    }else if(cddopcao == 'IA'){

    	var aux_vllimite = $("#vllimite", "#frmNovoLimite").val().replace(/\./g, "");
    	aux_vllimite_anterior = aux_vllimite_anterior.replace(/\./g, "");

    	if (aux_vllimite_anterior == aux_vllimite) {
			acessaOpcaoAba(8,0,'@');
		} else {
        chamarImpressaoLimiteCredito(false);
		}
        return false;
    }   
        
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde" + msg + " ...");
    
    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST", 
        dataType: "html",
        url: urlOperacao,
        data: {
            nrdconta: nrdconta,
            cddopcao: cddopcao,
            flpropos: flpropos,
            inpessoa: var_globais.inpessoa, //bruno - prj 438 - sprint 7 - novo limite
            inconfir: cddopcao == 'A' || cddopcao == 'P' ? 0 : 1, // Se for consulta NÃO fazer validação, senão, fazer validação
            redirect: "html_ajax"
        },      
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divConteudoOpcao").html(response);
            controlaFoco(cddopcao);
        }               
    }); 
}

// Função para confirmar novo Limite de Crédito
function confirmaNovoLimite(inconfir, flgratok) {

    var nrcpfcgc = $("#nrcpfcgc", "#frmCabAtenda").val().replace(".", "").replace(".", "").replace("-", "").replace("/", "");
    var camposRS = "";
    var dadosRtS = "";
    var nrctrrat = $("#nrctrpro", "#frmDadosLimiteCredito").val();
    var idcobope = $("#idcobope", "#frmDadosLimiteCredito").val();
    
    if (flgratok) {
        camposRS = retornaCampos(arrayRatingSingulares, '|');
        dadosRtS = retornaValores(arrayRatingSingulares, ';', '|', camposRS);
    }
    
    showMsgAguardo("Aguarde, confirmando novo " + strTitRotinaLC + " ...");
    
    // Executa script de confirmação através de ajax
    $.ajax({        
        type: "POST",
        url: UrlSite + "telas/atenda/limite_credito/confirma_novo_limite.php", 
        data: {
            nrdconta: nrdconta,
            inconfir: inconfir,
            nrcpfcgc: nrcpfcgc,
            nrctrrat: nrctrrat,
            flgratok: flgratok,
            idcobope: idcobope,
            /** Variaveis ref ao rating singulares **/
            camposRS: camposRS,
            dadosRtS: dadosRtS,
            inpessoa: var_globais.inpessoa, //bruno - prj 438 - sprint 7 - novo limite
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

// Função para excluir proposta de Limite de Crédito
function excluirNovoLimite() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, excluindo novo " + strTitRotinaLC + " ...");   
    // Executa script de confirmação através de ajax
    $.ajax({        
        type: "POST",
        url: UrlSite + "telas/atenda/limite_credito/excluir_novo_limite.php", 
        data: {
            nrdconta: nrdconta,
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

// Função para cancelar Limite de Crédito atual
function cancelarLimiteAtual(nrctrlim) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, cancelando " + strTitRotinaLC + " atual ...");
    
    //bruno - prj 470 - atualizar var_globais
    var_globais.nrctrlim = nrctrlim;
	
    // Executa script de confirmação através de ajax
    $.ajax({        
        type: "POST",
        url: UrlSite + "telas/atenda/limite_credito/cancelar_limite_atual.php", 
        data: {
            nrdconta: nrdconta,         
            nrctrlim: nrctrlim,
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

function renovarLimiteAtual(nrctrlim) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, renovando " + strTitRotinaLC + " atual ...");
    
    // Executa script de confirmação através de ajax
    $.ajax({        
        type: "POST",
        url: UrlSite + "telas/atenda/limite_credito/renovar_limite_atual.php", 
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
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

// Função para validar novo limite de crédito
function validarNovoLimite(inconfir, inconfi2) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando novo " + strTitRotinaLC + " ...");
    
    var nrctrlim = $("#nrctrlim", "#frmNovoLimite").val().replace(/\./g, "");
    var cddlinha = $("#cddlinha", "#frmNovoLimite").val();
    var vllimite = $("#vllimite", "#frmNovoLimite").val().replace(/\./g, "");
    var flgimpnp = $("#flgimpnp", "#frmNovoLimite").val();
    
    //bruno - prj - 438 - sprint 7 - tela principal
    if(flgimpnp == "" || typeof flgimpnp == 'undefined'){
        flgimpnp = aux_novoLimite.flgimpnp; //aux_novoLimite está sendo setado em novo_limite.php
    }
	
    //bruno - prj 470 - atualizar var_globais
    var_globais.nrctrlim = $("#nrctrlim", "#frmNovoLimite").val().replace(/\./g, "");
    var_globais.cddlinha = $("#cddlinha", "#frmNovoLimite").val();
    var_globais.vllimite = $("#vllimite", "#frmNovoLimite").val().replace(/\./g, "");
    var_globais.flgimpnp = $("#flgimpnp", "#frmNovoLimite").val();
	
	// PJ470 - Mout's - Desabilitar campo de contrato

	// Valida número do contrato
    //if (nrctrlim == "" || !validaNumero(nrctrlim, true, 0, 0)) {
	//	hideMsgAguardo();
    //    showError("error", "N&uacute;mero de contrato inv&aacute;lido.", "Alerta - Aimaro", "$('#nrctrlim','#frmNovoLimite').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
	//	return false;
	//}
	
	// Valida linha de crédito
    if (cddlinha == "" || !validaNumero(cddlinha, true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Linha de cré	dito inv&aacute;lida.", "Alerta - Aimaro", "$('#cddlinha','#frmNovoLimite').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

    // Valida valor do limite de crédito
    if (vllimite == "" || !validaNumero(vllimite, true, 0, 0)) {
        hideMsgAguardo();
        showError("error", "Valor do " + strTitRotinaLC + " inv&aacute;lido.", "Alerta - Aimaro", "$('#vllimite','#frmNovoLimite').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }   
    
    // Executa script de validação do limite através de ajax
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/limite_credito/validar_novo_limite.php",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            cddlinha: cddlinha,
            vllimite: vllimite,
            flgimpnp: flgimpnp,
            inconfir: inconfir,
            inconfi2: inconfi2,
            cddopcao: aux_cddopcao, //bruno - prj 438 - sprint 7 - novo limite
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

// Função para cadastrar novo plano de capital
function cadastrarNovoLimite() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, cadastrando novo " + strTitRotinaLC + " ...");
    
    nrinfcad = (typeof (nrinfcad) == "undefined") ? 1 : nrinfcad;
    
    // 09/10/2018 - Remove ponto do usuario e substitui virgula da casa decimal por ponto
    var f = function(valor){
        valor = valor.replace(".","");
        valor = valor.replace(",",".");
        return valor;
    }

    // PRJ 438 - Sprint 7 - Função com a atribuição das variaveis dos avalistas
    geraRegsDinamicosAvalistas();
    //prj 438 - sprint 7 - Atualizar valor do limite
    var_globais.vllimite = $("#vllimite", "#frmNovoLimite").val().replace(/\./g, "");
    
    //bruno - prj 470 - atualizar var_globais
    var_globais.vllimite = $("#vllimite", "#frmNovoLimite").val().replace(/\./g, ""); 
    var_globais.nrctrlim = $("#nrctrlim", "#frmNovoLimite").val().replace(/\./g, "");
    var_globais.cddlinha =  $("#cddlinha", "#frmNovoLimite").val();
    var_globais.vllimite =  $("#vllimite", "#frmNovoLimite").val().replace(/\./g, "");
    var_globais.flgimpnp =  $("#flgimpnp", "#frmNovoLimite").val();


    var vlsalari = f($("#vlsalari", "#frmNovoLimite").val());
    var vlsalcon = f($("#vlsalcon", "#frmNovoLimite").val());
    var vloutras = f($("#vloutras", "#frmNovoLimite").val());
    var vlalugue = f($("#vlalugue", "#frmNovoLimite").val());
	
    //bruno - prj 438 - sprint 7 - tela principal
    var flgimpnp = $("#flgimpnp", "#frmNovoLimite").val();
    if(flgimpnp == "" || typeof flgimpnp == 'undefined'){
        flgimpnp = aux_novoLimite.flgimpnp;
    }

    var aux_nrperger = $("#nrperger", "#frmNovoLimite").val();
    if(aux_nrperger == "" || typeof aux_nrperger == "undefined"){
        aux_nrperger = 0;
    }

    var nrctaav1 = (typeof aux_nrctaav0 == 'undefined') ? 0  : aux_nrctaav0;
    var nmdaval1 = (typeof aux_nmdaval0 == 'undefined') ? '' : aux_nmdaval0;
	var nrcpfav1 = (typeof aux_nrcpfav0 == 'undefined') ? '' : aux_nrcpfav0;
	var tpdocav1 = (typeof aux_tpdocav0 == 'undefined') ? '' : aux_tpdocav0;
	var dsdocav1 = (typeof aux_dsdocav0 == 'undefined') ? '' : aux_dsdocav0;
	var nmdcjav1 = (typeof aux_nmdcjav0 == 'undefined') ? '' : aux_nmdcjav0;
	var cpfcjav1 = (typeof aux_cpfcjav0 == 'undefined') ? '' : aux_cpfcjav0;
	var tdccjav1 = (typeof aux_tdccjav0 == 'undefined') ? '' : aux_tdccjav0;
	var doccjav1 = (typeof aux_doccjav0 == 'undefined') ? '' : aux_doccjav0;
	var ende1av1 = (typeof aux_ende1av0 == 'undefined') ? '' : aux_ende1av0;
	var ende2av1 = (typeof aux_ende2av0 == 'undefined') ? '' : aux_ende2av0;
	var nrfonav1 = (typeof aux_nrfonav0 == 'undefined') ? '' : aux_nrfonav0;
	var emailav1 = (typeof aux_emailav0 == 'undefined') ? '' : aux_emailav0;
	var nmcidav1 = (typeof aux_nmcidav0 == 'undefined') ? '' : aux_nmcidav0;
	var cdufava1 = (typeof aux_cdufava0 == 'undefined') ? '' : aux_cdufava0;
	var nrcepav1 = (typeof aux_nrcepav0 == 'undefined') ? '' : aux_nrcepav0;
	var cdnacio1 = (typeof aux_cdnacio0 == 'undefined') ? '' : aux_cdnacio0;
	var vledvmt1 = (typeof aux_vledvmt0 == 'undefined') ? '' : aux_vledvmt0;
	var vlrenme1 = (typeof aux_vlrenme0 == 'undefined') ? '' : aux_vlrenme0;
	var nrender1 = (typeof aux_nrender0 == 'undefined') ? '' : aux_nrender0;
	var complen1 = (typeof aux_complen0 == 'undefined') ? '' : aux_complen0;
	var nrcxaps1 = (typeof aux_nrcxaps0 == 'undefined') ? '' : aux_nrcxaps0;
	var inpesso1 = (typeof aux_inpesso0 == 'undefined') ? '' : aux_inpesso0;
	var dtnasct1 = (typeof aux_dtnasct0 == 'undefined') ? '' : aux_dtnasct0;
	var vlrecjg1 = (typeof aux_vlrencj0 == 'undefined') ? '' : aux_vlrencj0;

	var nrctaav2 = (typeof aux_nrctaav1 == 'undefined') ? 0  : aux_nrctaav1;
	var nmdaval2 = (typeof aux_nmdaval1 == 'undefined') ? '' : aux_nmdaval1;
	var nrcpfav2 = (typeof aux_nrcpfav1 == 'undefined') ? '' : aux_nrcpfav1;
	var tpdocav2 = (typeof aux_tpdocav1 == 'undefined') ? '' : aux_tpdocav1;
	var dsdocav2 = (typeof aux_dsdocav1 == 'undefined') ? '' : aux_dsdocav1;
	var nmdcjav2 = (typeof aux_nmdcjav1 == 'undefined') ? '' : aux_nmdcjav1;
	var cpfcjav2 = (typeof aux_cpfcjav1 == 'undefined') ? '' : aux_cpfcjav1;
	var tdccjav2 = (typeof aux_tdccjav1 == 'undefined') ? '' : aux_tdccjav1;
	var doccjav2 = (typeof aux_doccjav1 == 'undefined') ? '' : aux_doccjav1;
	var ende1av2 = (typeof aux_ende1av1 == 'undefined') ? '' : aux_ende1av1;
	var ende2av2 = (typeof aux_ende2av1 == 'undefined') ? '' : aux_ende2av1;
	var nrfonav2 = (typeof aux_nrfonav1 == 'undefined') ? '' : aux_nrfonav1;
	var emailav2 = (typeof aux_emailav1 == 'undefined') ? '' : aux_emailav1;
	var nmcidav2 = (typeof aux_nmcidav1 == 'undefined') ? '' : aux_nmcidav1;
	var cdufava2 = (typeof aux_cdufava1 == 'undefined') ? '' : aux_cdufava1;
	var nrcepav2 = (typeof aux_nrcepav1 == 'undefined') ? '' : aux_nrcepav1;
	var cdnacio2 = (typeof aux_cdnacio1 == 'undefined') ? '' : aux_cdnacio1;
	var vledvmt2 = (typeof aux_vledvmt1 == 'undefined') ? '' : aux_vledvmt1;
	var vlrenme2 = (typeof aux_vlrenme1 == 'undefined') ? '' : aux_vlrenme1;
	var nrender2 = (typeof aux_nrender1 == 'undefined') ? '' : aux_nrender1;
	var complen2 = (typeof aux_complen1 == 'undefined') ? '' : aux_complen1;
	var nrcxaps2 = (typeof aux_nrcxaps1 == 'undefined') ? '' : aux_nrcxaps1;
	var inpesso2 = (typeof aux_inpesso1 == 'undefined') ? '' : aux_inpesso1;
    var dtnasct2 = (typeof aux_dtnasct1 == 'undefined') ? '' : aux_dtnasct1;
	var vlrecjg2 = (typeof aux_vlrecjg1 == 'undefined') ? '' : aux_vlrecjg1;

	var dsobserv = removeAcento($("#dsobserv", "#frmNovoLimite").val());

	// Executa script de cadastro do limite atravé	s de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/limite_credito/cadastrar_novo_limite.php",
		data: {
			nrdconta: nrdconta,
			nrctrlim: $("#nrctrlim", "#frmNovoLimite").val().replace(/\./g, ""),
			cddlinha: $("#cddlinha", "#frmNovoLimite").val(),
			vllimite: $("#vllimite", "#frmNovoLimite").val().replace(/\./g, ""),
			flgimpnp: flgimpnp, //bruno - prj 438 - sprint 7 - tela principal
			vlsalari: vlsalari > 0 ? $("#vlsalari", "#frmNovoLimite").val().replace(/\./g, "") : '0,00',
			vlsalcon: vlsalcon > 0 ? $("#vlsalcon", "#frmNovoLimite").val().replace(/\./g, "") : '0,00',
			vloutras: vloutras > 0 ? $("#vloutras", "#frmNovoLimite").val().replace(/\./g, "") : '0,00',
			vlalugue: vlalugue > 0 ? $("#vlalugue", "#frmNovoLimite").val().replace(/\./g, "") : '0,00',
			inconcje: ($("#inconcje_1", "#frmNovoLimite").prop('checked')) ? 1 : 0,
			dsobserv: dsobserv,
			dtconbir: dtconbir,			
			/** Variáveis globais alimentadas na função validaDadosRating em rating.js **/
			//bruno - prj 438 - sprint 7 - tela rating
			nrgarope: $("#nrgarope", "#frmNovoLimite").val(),
			nrinfcad: $("#nrinfcad", "#frmNovoLimite").val(),
			nrliquid: $("#nrliquid", "#frmNovoLimite").val(),
			nrpatlvr: $("#nrpatlvr", "#frmNovoLimite").val(),			
			perfatcl: "0,00",
			nrperger: aux_nrperger,
			/** ---------------------------------------------------------------------- **/
			nrctaav1: normalizaNumero(nrctaav1),
			nmdaval1: nmdaval1,
			nrcpfav1: normalizaNumero(nrcpfav1),
			tpdocav1: tpdocav1,
			dsdocav1: dsdocav1,
			nmdcjav1: nmdcjav1,
			cpfcjav1: normalizaNumero(cpfcjav1),
			tdccjav1: tdccjav1,
			doccjav1: doccjav1,
			ende1av1: ende1av1,
			ende2av1: ende2av1,
			nrcepav1: normalizaNumero(nrcepav1),
			nmcidav1: nmcidav1,
			cdufava1: cdufava1,
			nrfonav1: nrfonav1,
			emailav1: emailav1,
			nrender1: normalizaNumero(nrender1),
			complen1: complen1,
			nrcxaps1: normalizaNumero(nrcxaps1),
			vlrenme1: vlrenme1,
			vlrecjg1: vlrecjg1,
			cdnacio1: cdnacio1,
			inpesso1: inpesso1,
			dtnasct1: dtnasct1,
			
			nrctaav2: normalizaNumero(nrctaav2),
			nmdaval2: nmdaval2,
			nrcpfav2: normalizaNumero(nrcpfav2),
			tpdocav2: tpdocav2,
			dsdocav2: dsdocav2,
			nmdcjav2: nmdcjav2,
			cpfcjav2: normalizaNumero(cpfcjav2),
			tdccjav2: tdccjav2,
			doccjav2: doccjav2,
			ende1av2: ende1av2,
			ende2av2: ende2av2,
			nrcepav2: normalizaNumero(nrcepav2),
			nmcidav2: nmcidav2,
			cdufava2: cdufava2,
			nrfonav2: nrfonav2,
			emailav2: emailav2,
			nrender2: normalizaNumero(nrender2),
			complen2: complen2,
			nrcxaps2: normalizaNumero(nrcxaps2),
			vlrenme2: vlrenme2,
			idcobope: $("#idcobert", "#frmNovoLimite").val(),
			vlrecjg2: vlrecjg2,
			cdnacio2: cdnacio2,
			inpesso2: inpesso2,
			dtnasct2: dtnasct2,
			redirect: "script_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {                                       
                eval(response);
                changeAbaPropLabel("Alterar Limite");               
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }               
    }); 
}

// Função para verificar se deve ser enviado e-mail ao PAC Sede
function verificaEnvioEmail(idimpres, flgimpnp, nrctrlim) {   
    showConfirmacao("Efetuar envio de e-mail para Sede?", "Confirma&ccedil;&atilde;o - Aimaro", "carregarImpresso(" + idimpres + ",'yes','" + flgimpnp + "'," + nrctrlim + ");", "carregarImpresso(" + idimpres + ",'no','" + flgimpnp + "'," + nrctrlim + ");", "sim.gif", "nao.gif");
}

// Função para carregar impresso desejado em PDF (Proposta, Contrato ou Rescisão do Limite de Crédito)
function carregarImpresso(idimpres, flgemail, flgimpnp, nrctrlim, fnfinish) {
    if (nrctrlim == undefined || nrctrlim == 0) {
        nrctrlim = retiraCaracteres($("#contrato", "#frmImprimir").val(), "0123456789", true);
        
        if (nrctrlim == "" || !validaNumero(nrctrlim, true, 0, 0)) {
            showError("error", "Informe o n&uacute;mero do contrato.", "Alerta - Aimaro", "$('#contrato','#frmImprimir').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
            return false;       
        }
    }   
    
    /* alteracao 006 */
    if (idimpres == "5") {
        imprimirRating(false, 1, nrctrlim, "divConteudoOpcao", fnfinish);
        return;
    }   
    
    $("#nrdconta", "#frmImprimir").val(nrdconta);
    $("#idimpres", "#frmImprimir").val(idimpres);
    $("#nrctrlim", "#frmImprimir").val(nrctrlim);
    $("#flgemail", "#frmImprimir").val(flgemail);
    $("#flgimpnp", "#frmImprimir").val(flgimpnp);
    
    var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
    var action = $('#frmImprimir').attr('action');
    
    if (callafterLimiteCred != '') {
        callafter = callafterLimiteCred;
    }

    carregaImpressaoAyllos("frmImprimir", action, callafter);
}

function checaEnter(campo, e) {

    var keycode; 
    if (window.event) keycode = window.event.keyCode; 
    else if (e) keycode = e.which; 
    else return true; 

    if (keycode == 13)
        return false; 
    else 
        return true; 
}

function trataGAROPC(cddopcao, nrctrlim) {
	
	if (cddopcao == 'N' || 
	   (cddopcao == 'A' && normalizaNumero($('#idcobert','#frmNovoLimite').val()) > 0) || 
	   (cddopcao == 'P' && normalizaNumero($('#idcobert','#frmNovoLimite').val()) > 0)) {
		//bruno - prj 438 - sprint 7 - novo limite
	    $('#frmGAROPC').remove();
    abrirTelaGAROPC(cddopcao, nrctrlim);
  } else {
	    if (cdcooper == 3) {
	        abrirRating();
	        validarDadosRating("2","A_COMITE_APROV","3");
      } else {
          $("#frmOrgaos").remove();
          $("#frmNovoLimite").css("width", 530);
          $("#divDadosAvalistas").css("display","block");
          hideMsgAguardo();
          blockBackground(parseInt($("#divRotina").css("z-index")));
      }

    $('#divRotina').css({'display':'block'});
    bloqueiaFundo($('#divRotina'));
  }
}

function abrirTelaGAROPC(cddopcao, nrctrlim) {

    showMsgAguardo('Aguarde, carregando ...');
    
    //exibeRotina($('#divFormGAROPC'));
    //$('#divRotina').css({'display':'none'});
    
    var tipaber = '';
    var idcobert = normalizaNumero($('#idcobert','#frmNovoLimite').val());
    var codlinha = normalizaNumero($('#cddlinha','#frmNovoLimite').val());
    var vllimite = $('#vllimite','#frmNovoLimite').val();
    
    switch (cddopcao) {
      case 'N':
        tipaber = (idcobert > 0) ? 'A' : 'I';
        break;
      default:
        tipaber = 'C';
        break;
    }
    
    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/garopc/garopc.php',
        data: {
            nmdatela     : 'LIMITE_CREDITO',
            tipaber      : tipaber,
            nrdconta     : nrdconta,
            tpctrato     : 1,
            idcobert     : idcobert,
            dsctrliq     : cddopcao = 'P' ? nrctrlim : '',
            codlinha     : codlinha,
            vlropera     : vllimite,
            divanterior  : 'divRotina',
            ret_nomcampo : 'idcobert',
            ret_nomformu : 'frmNovoLimite',
            ret_execfunc : 'lcrShowHideDiv(\\\'divDadosObservacoes\\\',\\\'divDadosRenda\\\');$(\\\'#divRotina\\\').css({\\\'display\\\':\\\'block\\\'});bloqueiaFundo($(\\\'#divRotina\\\'));',
            ret_errofunc : '$(\\\'#divRotina\\\').css({\\\'display\\\':\\\'block\\\'});bloqueiaFundo($(\\\'#divRotina\\\'));',
            redirect     : 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            hideMsgAguardo();
            // Criaremos uma div oculta para conter toda a estrutura da tela GAROPC
            $('#divUsoGAROPC').html(response).hide();
            // Iremos incluir o conteúdo do form da div oculta dentro da div principal de descontos
            $("#frmGAROPC", "#divUsoGAROPC").appendTo('#divFormGAROPC');
            // Iremos remover os botões originais da GAROPC e usar os proprios da tela
            $("#divBotoes","#frmGAROPC").detach();
            
            $("#divDadosRenda").css("display", "none");
            $("#divFormGAROPC").css("display", "block");
            $("#divBotoesGAROPC").css("display", "block");
            
            bloqueiaFundo($('#divFormGAROPC'));
            blockBackground(parseInt($("#divRotina").css("z-index")));
            $("#frmNovoLimite").css("width", 540);
        }
    });
} 

// Função para mostrar div com formulário de dados para digitação ou consulta
function lcrShowHideDiv(divShow, divHide) {
    $("#" + divShow).css("display", "block");
    $("#" + divHide).css("display", "none");
}

function travaCamposLimite(){
    //----------------------------------------------------------------
    // FORMULÁRIO NOVO LIMITE 
    //----------------------------------------------------------------      
    var cTodosLimite = $('input, select', '#' + nomeForm + ' .fsLimiteCredito');
    $('label', '#' + nomeForm + ' .fsLimiteCredito').addClass('rotulo').css('width', '200px');
    $('#nrctrlim', '#' + nomeForm + ' .fsLimiteCredito').addClass('contrato').css('width', '60px');
    $('#cddlinha', '#' + nomeForm + ' .fsLimiteCredito').addClass('codigo pesquisa').attr('maxlength', '3').css('width', '35px');
    $('#dsdlinha', '#' + nomeForm + ' .fsLimiteCredito').addClass('descricao').css('width', '170px');
    $('#vllimite', '#' + nomeForm + ' .fsLimiteCredito').addClass('moeda').css('width', '90px');
    $('#flgimpnp', '#' + nomeForm + ' .fsLimiteCredito').css('width', '70px');
    $('#dsobserv', '#' + nomeForm + ' .fsObservacoes').addClass('campo');

    cTodosLimite.desabilitaCampo();    
}

// Função para formata o layout
function controlaLayout(cddopcao) {

    //----------------------------------------------------------------
    // FORMULÁRIO NOVO LIMITE
    //----------------------------------------------------------------      

	$('#divConteudoOpcao').css({
        'width': '540px'
    });

    var cTodosLimite = $('input, select', '#' + nomeForm + ' .fsLimiteCredito');
    $('label', '#' + nomeForm + ' .fsLimiteCredito').addClass('rotulo').css('width', '200px');
    $('#nrctrlim', '#' + nomeForm + ' .fsLimiteCredito').addClass('contrato').css('width', '60px');
    $('#cddlinha', '#' + nomeForm + ' .fsLimiteCredito').addClass('codigo pesquisa').attr('maxlength', '3').css('width', '35px');
    $('#dsdlinha', '#' + nomeForm + ' .fsLimiteCredito').addClass('descricao').css('width', '170px');
    $('#vllimite', '#' + nomeForm + ' .fsLimiteCredito').addClass('moeda').css('width', '90px');
    $('#flgimpnp', '#' + nomeForm + ' .fsLimiteCredito').css('width', '70px');
    $('#dsobserv', '#' + nomeForm + ' .fsObservacoes').addClass('campo');
    // PRJ 438 - Sprint 7 - Novo campo Nivel de Risco
    $('#nivrisco', '#' + nomeForm + ' .fsLimiteCredito').css('width', '30px');
    $('label[for="flgYes"]').css({'width': "30px"});
    $('label[for="flgNo"]').css({'width': "30px"});
                
    // Se for novo limite ou alteracao, habilitar campos
    //prj - 438 - srpint 7 - rubens - layout limite credito
    if (cddopcao == 'N') {
        cTodosLimite.habilitaCampo();

        // PRJ 438 - Sprint 7 - No momento o campo Nivel de Risco sempre estará desabilitado
        $('#nivrisco', '#' + nomeForm + ' .fsLimiteCredito').desabilitaCampo();
        $('#dsdtxfix', '#' + nomeForm + ' .fsLimiteCredito').desabilitaCampo();
        $('#nrctrlim', '#' + nomeForm).desabilitaCampo(); // PJ470 - Mout's - Desabilitar campo de contrato

    } else {
        cTodosLimite.desabilitaCampo();
    }
        
    controlaLayoutTelaRating();
    //bruno - prj 438 - sprint 7 - tela principal
    switch(cddopcao){
        case 'N':
            if(flgProposta){
                controlaLayoutAlterarlimiteEstudo();
            }
            break;
        case 'A': //Consulta limite Ativo
            controlaLayoutConsultaLimiteAtivo();
            break;
        case 'P': //Consulta limite Proposto
            controlaLayoutConsultalimiteEstudo();
            break;
    }
		
    if (flgProposta) {
        $('#nrctrlim', '#' + nomeForm + ' .fsLimiteCredito').desabilitaCampo();
        changeAbaPropLabel("Alterar Limite");
    } else {
        changeAbaPropLabel("Novo Limite");              
    }
    
    //----------------------------------------------------------------
    // FORMULÁRIO DADOS DA RENDA
    //----------------------------------------------------------------  

    var rSalTit = $('label[for="vlsalari"]', '#' + nomeForm + ' .fsDadosRenda');
    var rSalCjg = $('label[for="vlsalcon"]', '#' + nomeForm + ' .fsDadosRenda');
    var rOutras = $('label[for="vloutras"]', '#' + nomeForm + ' .fsDadosRenda');
    var rAlugue = $('label[for="vlalugue"]', '#' + nomeForm + ' .fsDadosRenda');
    var rInconc = $('label[for="inconcje"]', '#' + nomeForm + ' .fsConjuge');
    var cValores = $('input type="text"', '#' + nomeForm + ' .fsDadosRenda');
    var cInconcje = $('input', '#' + nomeForm + ' .fsConjuge');
    
    rSalTit.addClass('rotulo').css({ 'width': '130px' });
    rOutras.addClass('rotulo').css({ 'width': '130px' });
    rSalCjg.addClass('rotulo-linha').css({ 'width': '80px' });
    rAlugue.addClass('rotulo-linha').css({ 'width': '80px' });
    rInconc.addClass('rotulo-linha').css({ 'width': '130px' });
    cValores.addClass('moeda').css({ 'width': '90px' }).val('0').habilitaCampo();
    cInconcje.css({ 'width': '30px' }).habilitaCampo();
    
    //----------------------------------------------------------------
    // FORMULÁRIO OBSERVAÇÕES
    //----------------------------------------------------------------      
    $('#dsobserv', '#' + nomeForm + ' .fsObservacoes').addClass('campo').css({ 'width': '95%', 'height': '90px' });
    
    //----------------------------------------------------------------
    // FORMULÁRIO RATING SINGULARES
    //----------------------------------------------------------------      
    $('fieldset').css({ 'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px' });
    $('fieldset > legend').css({ 'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px' });
    
    // Se nao for pessoa fisica, esconder informacoes do conjuge
    if (inpessoa != 1) {    
        $(".fsConjuge", "#divDadosRenda").css('display', 'none');
    }
    
	// PRJ 438 - Sprint 7 - Alterado div, agora o campo inconcje está na divDadosLimite
    // Se nao tiver conjuge, desabilita a consulta automatizadas para o mesmo
    if (nrcpfcjg == 0 && nrctacje == 0) {   
        $("input[name='inconcje']", "#divDadosLimite").desabilitaCampo();
    }
    
    layoutPadrao(); 
    cValores.trigger('blur');
    controlaPesquisas();

    callafterLimiteCred = '';
}

// Função que formata a tabela ultimas alteracoes
function formataUltimasAlteracoes() {
            
    var divRegistro = $('div.divRegistros');        
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);
            
    divRegistro.css({ 'height': '200px', 'width': '100%' });
    
    var ordemInicial = new Array();
    ordemInicial = [[1, 1]];
            
    var arrayLargura = new Array();
    arrayLargura[0] = '60px';
    arrayLargura[1] = '60px';
    arrayLargura[2] = '60px';
    arrayLargura[3] = '75px';
	arrayLargura[4] = '75px';	
    // PRJ 438 - Sprint 13 - Alterado largura da coluna Motivo para suportar o motivo 'Cancelado automaticamente por inadimplência' (Mateus Z / Mouts)
	arrayLargura[5] = '240px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'left';
	arrayAlinha[6] = 'left';
	
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
    return false;
}

// Função que formata a imprimir
function formataImprimir() {

    $('#frmImprimir').css({ 'padding': '10px' });
    
    // label
    rContrato = $('label[for="contrato"]', '#frmImprimir');
    rContrato.css({ 'font-weight': 'bold' })
    
    // campo
    cContrato = $('#contrato', '#frmImprimir');
    cContrato.addClass('contrato campo').css({ 'width': '100px', 'text-align': 'right' });
    
    layoutPadrao();
    
}

// Função que formata a pagina principal
function formataPrincipal() {

    $('input, select', '#frmDadosLimiteCredito').desabilitaCampo();     

    // rotulo
    rVllimite = $('label[for="vllimite"]', '#frmDadosLimiteCredito');
    rDtmvtolt = $('label[for="dtmvtolt"]', '#frmDadosLimiteCredito');
    rCddlinha = $('label[for="cddlinha"]', '#frmDadosLimiteCredito');
    rDtfimvig = $('label[for="dtfimvig"]', '#frmDadosLimiteCredito');
    rNrctrlim = $('label[for="nrctrlim"]', '#frmDadosLimiteCredito');
    rQtdiavig = $('label[for="qtdiavig"]', '#frmDadosLimiteCredito');
    rDsencfi1 = $('label[for="dsencfi1"]', '#frmDadosLimiteCredito');
    rDsencfi2 = $('label[for="dsencfi2"]', '#frmDadosLimiteCredito');
    rDsencfi3 = $('label[for="dsencfi3"]', '#frmDadosLimiteCredito');
    rDssitlli = $('label[for="dssitlli"]', '#frmDadosLimiteCredito');
    rDtcanlim = $('label[for="dtcanlim"]', '#frmDadosLimiteCredito');
    rNmoperad = $('label[for="nmoperad"]', '#frmDadosLimiteCredito');
    rNmopelib = $('label[for="nmopelib"]', '#frmDadosLimiteCredito');
    rFlgenvio = $('label[for="flgenvio"]', '#frmDadosLimiteCredito');
    rDstprenv = $('label[for="dstprenv"]', '#frmDadosLimiteCredito');
    rQtrenova = $('label[for="qtrenova"]', '#frmDadosLimiteCredito');
    rDtrenova = $('label[for="dtrenova"]', '#frmDadosLimiteCredito');
    rDtultmaj = $('label[for="dtultmaj"]', '#frmDadosLimiteCredito');
    // [031]
    rDtratingnota = $('label[for="ratingnota"]', '#frmDadosLimiteCredito');
    rDtratingorigem = $('label[for="ratingorigem"]', '#frmDadosLimiteCredito');
    rDtratingstatus = $('label[for="ratingstatus"]', '#frmDadosLimiteCredito');
    // [031]

    rVllimite.addClass('rotulo').css({ 'width': '126px' });
    rDtmvtolt.addClass('rotulo-linha').css({ 'width': '110px' });
    rCddlinha.addClass('rotulo').css({ 'width': '126px' });
    rDtfimvig.addClass('rotulo-linha').css({ 'width': '110px' });
    rNrctrlim.addClass('rotulo').css({ 'width': '126px' });
    rQtdiavig.addClass('rotulo-linha').css({ 'width': '250px' });
    rDsencfi1.addClass('rotulo').css({ 'width': '126px' });
    rDsencfi2.addClass('rotulo').css({ 'width': '126px' });
    rDsencfi3.addClass('rotulo').css({ 'width': '126px' });
    rDssitlli.addClass('rotulo').css({ 'width': '126px' });
    rDtcanlim.addClass('rotulo-linha').css({ 'width': '250px' });
    rNmoperad.addClass('rotulo').css({ 'width': '126px' });
    rNmopelib.addClass('rotulo').css({ 'width': '126px' });
    rFlgenvio.addClass('rotulo').css({ 'width': '126px' });
    rDstprenv.addClass('rotulo').css({ 'width': '126px' });
    rQtrenova.addClass('rotulo-linha').css({ 'width': '83px' });
    rDtrenova.addClass('rotulo-linha').css({ 'width': '91px' });
    rDtultmaj.addClass('rotulo-linha').css({ 'width': '80px' });

    // [031]
    rDtratingnota.addClass('rotulo').css({ 'width': '126px' });
    rDtratingorigem.addClass('rotulo').css({ 'width': '126px' });
    rDtratingstatus.addClass('rotulo').css({ 'width': '126px' });
    // [031]

    // campos
    cVllimite = $('#vllimite', '#frmDadosLimiteCredito');
    cDtmvtolt = $('#dtmvtolt', '#frmDadosLimiteCredito');
    cCddlinha = $('#cddlinha', '#frmDadosLimiteCredito');
    cDtfimvig = $('#dtfimvig', '#frmDadosLimiteCredito');
    cNrctrlim = $('#nrctrlim', '#frmDadosLimiteCredito');
    cQtdiavig = $('#qtdiavig', '#frmDadosLimiteCredito');
    cDsencfi1 = $('#dsencfi1', '#frmDadosLimiteCredito');
    cDsencfi2 = $('#dsencfi2', '#frmDadosLimiteCredito');
    cDsencfi3 = $('#dsencfi3', '#frmDadosLimiteCredito');
    cDssitlli = $('#dssitlli', '#frmDadosLimiteCredito');
    cDtcanlim = $('#dtcanlim', '#frmDadosLimiteCredito');
    cNmoperad = $('#nmoperad', '#frmDadosLimiteCredito');
    cNmopelib = $('#nmopelib', '#frmDadosLimiteCredito');
    cFlgenvio = $('#flgenvio', '#frmDadosLimiteCredito');
    cDstprenv = $('#dstprenv', '#frmDadosLimiteCredito');
    cQtrenova = $('#qtrenova', '#frmDadosLimiteCredito');
    cDtrenova = $('#dtrenova', '#frmDadosLimiteCredito');
    cDtultmaj = $('#dtultmaj', '#frmDadosLimiteCredito');
    // [031]
    cRatingnota = $('#ratingnota', '#frmDadosLimiteCredito');
    cRatingorigem = $('#ratingorigem', '#frmDadosLimiteCredito');
    cRatingstatus = $('#ratingstatus', '#frmDadosLimiteCredito');
    // [031]

    cVllimite.css({ 'width': '220px' });
    cDtmvtolt.css({ 'width': '70px' });
    cCddlinha.css({ 'width': '220px' });
    cDtfimvig.css({ 'width': '70px' });
    cNrctrlim.css({ 'width': '80px' });
    cQtdiavig.css({ 'width': '70px' });
    cDsencfi1.css({ 'width': '336px' });
    cDsencfi2.css({ 'width': '336px' });
    cDsencfi3.css({ 'width': '336px' });
    cDssitlli.css({ 'width': '336px' });
    cDtultmaj.css({ 'width': '80px' });
    cDtcanlim.css({ 'width': '70px' });
    cNmoperad.css({ 'width': '336px' });
    cNmopelib.css({ 'width': '336px' });
    cFlgenvio.css({ 'width': '336px' });
    cDstprenv.css({ 'width': '80px' });
    cQtrenova.css({ 'width': '70px' });
    cDtrenova.css({ 'width': '70px' });

    // [031]
    cRatingnota.css({ 'width': '336px' });
    cRatingorigem.css({ 'width': '336px' });
    cRatingstatus.css({ 'width': '336px' });
    // [031]

    // ie
    if ($.browser.msie) {
        $('#novoContratoLimite').css({ 'padding': '10px', 'text-align': 'center', 'height': '30px', 'width': '93%' });
        cDsencfi1.css({ 'width': '333px' });
        cDsencfi2.css({ 'width': '333px' });
        cDsencfi3.css({ 'width': '333px' });
    }   

}

// Função que controla a lupa de pesquisa
function controlaPesquisas() {		
	
	var campoAnterior = '';
	var procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas;	
    var bo = 'zoom0001';
	
    $('a', '#' + nomeForm).ponteiroMouse();
	
	// CÓDIGO DA LINHA
	titulo      = 'Linhas de Crédito';
	procedure   = 'BUSCALINHAS';
	$('#cddlinha','#'+nomeForm).unbind('change').bind('change', function() {
	    filtrosDesc = 'tpdlinha|' + inpessoa + ';flgstlcr|1;nriniseq|1;nrregist|30';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsdlinha',$(this).val(),'dsdlinha',filtrosDesc,'frmNovoLimite');
		$('#cddlinha', '#frmNovoLimite').attr('aux', '');
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsdtxfix',$(this).val(),'dsdtxfix',filtrosDesc,'frmNovoLimite');
		$('#cddlinha', '#frmNovoLimite').attr('aux', '');
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'qtdiavig',$(this).val(),'qtdiavig',filtrosDesc,'frmNovoLimite');
		return false;
    }).next().unbind('click').bind('click', function () {
        filtrosPesq = 'Linha;cddlinha;30px;S;|Descrição;dsdlinha;200px;S;|Tipo;tpdlinha;20px;N;' + inpessoa + "|;dsdtxfix;;;|;flgstlcr;;;1;N|;qtdiavig;;;";
        colunas = 'Código;cddlinha;11%;right|Descrição;dsdlinha;49%;left|Tipo;dsdtplin;18%;left|Taxa;dsdtxfix;22%;center';
        fncOnClose = 'cddlinha = $("#cddlinha","#frmNovoLimite").val()';
        mostraPesquisa(bo, procedure, titulo, '20', filtrosPesq, colunas, divRotina, fncOnClose);
        return false;
    });    

    aplicarEventosLupasTelaRating();
    aplicarEventosLupasTelaAvalista();
}


//Função para controle de navegação 
function controlaFoco(opcao) {

    if (opcao == "@") { //Principal

        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmDadosLimiteCredito") {
                $(this).find("#divBotoes > a").attr({ href: 'javascript:void(null);' });
                $(this).find("#divBotoes > a").first().addClass("FirstInputModal").focus().css({ 'position': 'relative', 'top': '-3px' });
                $(this).find("#divBotoes > a img").first().css({ 'margin': '0 0 0 -3px' });
                $(this).find("#divBotoes > a").last().addClass("LastInputModal").css({ 'position': 'relative', 'top': '-4px' });
                $(this).find("#divBotoes > a img").last().css({ 'margin': '0 0 0 -3px' });
                $(this).find("#divBotoes > a").last().addClass("FluxoNavega");
                $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");

                $(this).find("#divDadosPrincipal_2 :input[type=image]").first().addClass("FirstInputModal").focus();
                $(this).find("#divDadosPrincipal_2 :input[type=image]").addClass("FluxoNavega");
                $(this).find("#divDadosPrincipal_2 :input[type=image]").last().addClass("LastInputModal");

                
                //Se estiver com foco na classe LastInputModal
                $(".FirstInputModal").focus(function () {
                    $(this).bind('keydown', function (e) {
                        if (e.keyCode == 27) {
                            encerraRotina();
                        }
                    })              
                });
                
                
                //Se estiver com foco na classe LastInputModal
                $(".LastInputModal").focus(function () {
                    var pressedShift = false;

                    $(this).bind('keyup', function (e) {
                        if (e.keyCode == 16) {
                            pressedShift = false;//Quando tecla shift for solta passa valor false 
                        }
                    })

                    $(this).bind('keydown', function (e) {

                        if (e.keyCode == 13) {
                            e.preventDefault();
                            e.stopImmediatePropagation();
                            $(".LastInputModal").click();
                        }
                        if (e.keyCode == 16) {
                            pressedShift = true;//Quando tecla shift for pressionada passa valor true 
                        }
                        if ((e.keyCode == 9) && pressedShift == true) {
                            return setFocusCampo($(target), e, false, 0);
                        }
                        else if (e.keyCode == 9) {
                            e.stopPropagation();
                            e.preventDefault();
                            $(".FirstInputModal").focus();
                        }
                    });
                });
            }

            //Se estiver com foco na classe FluxoNavega
            $(".FluxoNavega").focus(function () {
                $(this).bind('keydown', function (e) {
                    if (e.keyCode == 13) {
                        e.preventDefault();
                        e.stopImmediatePropagation();
                        $(this).click();
                    }
                });
            });

        });

        $(".FirstInputModal").focus();
    }
    if (opcao == "N") { //Novo Limite

        $('input', '#frmNovoLimite').keydown( function(e) {
	        var key = e.charCode ? e.charCode : e.keyCode ? e.keyCode : 0;
	        if(key == 13) {
	            e.preventDefault();
	            var inputs = $(this).closest('form').find(':input:visible:not([disabled]):not([readonly])');
	            inputs.eq( inputs.index(this) + 1 ).focus();
	        }
    	});
    }
    if (opcao == "I") { //Imprimir

        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmImprimir") {
                $(this).find("#frmImprimir > :input[type=text]").first().addClass("FirstInputModal").focus();
                $(this).find("#divBotoes > a").last().addClass("LastInputModal");

                //Se estiver com foco na classe LastInputModal
                $(".LastInputModal").focus(function () {
                    var pressedShift = false;

                    $(this).bind('keyup', function (e) {
                        if (e.keyCode == 16) {
                            pressedShift = false;//Quando tecla shift for solta passa valor false 
                        }
                    })

                    $(this).bind('keydown', function (e) {

                        if (e.keyCode == 13) {
                            e.stopPropagation();
                            e.preventDefault();
                            $(".LastInputModal").click();
                        }
                        if (e.keyCode == 16) {
                            pressedShift = true;//Quando tecla shift for pressionada passa valor true 
                        }
                        if ((e.keyCode == 9) && pressedShift == true) {
                            return setFocusCampo($(target), e, false, 0);
                        }
                        else if (e.keyCode == 9) {
                            //e.stopPropagation();
                            //e.preventDefault();
                            $(".FirstInputModal").focus();
                        }
                    });
                });
            }
        });
        $(".FirstInputModal").focus();
    }
    if (opcao == "U") { //Últimas alterações
        $('#divConteudoOpcao').bind('keydown', function (e) {
            if (e.keyCode == 27) {
                encerraRotina();
            }
        })

        $('#divConteudoOpcao').each(function () {
            $(".tituloRegistros").find("thead tr th").first().addClass("FirstInputModal").focus();
        });
    }

    if (opcao == "A") { //Cons.Lim.Ativo

        $('#divConteudoOpcao').bind('keydown', function (e) {
            if (e.keyCode == 27) {
                encerraRotina();
            }
        })

        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario

            if (IdForm == "frmNovoLimite") {
                $("#frmNovoLimite").find("#divDadosLimite #divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
                $("#frmNovoLimite").find("#divDadosLimite #divBotoes > :input[type=image]").addClass("FluxoNavega");
                $("#frmNovoLimite").find("#divDadosLimite #divBotoes > :input[type=image]").last().addClass("LastInputModal");

                //Se estiver com foco na classe LastInputModal
                $(".LastInputModal").focus(function () {
                    var pressedShift = false;

                    $(this).bind('keyup', function (e) {
                        if (e.keyCode == 16) {
                            pressedShift = false;//Quando tecla shift for solta passa valor false 
                        }
                    })

                    $(this).bind('keydown', function (e) {

                        if (e.keyCode == 13) {
                            $(".LastInputModal").click();
                        }
                        if (e.keyCode == 27) {
                            encerraRotina();
                        }
                        if (e.keyCode == 16) {
                            pressedShift = true;//Quando tecla shift for pressionada passa valor true 
                        }
                        if ((e.keyCode == 9) && pressedShift == true) {
                            return setFocusCampo($(target), e, false, 0);
                        }
                        else if (e.keyCode == 9) {
                            $(".FirstInputModal").focus();
                        }
                    });
                });
            }

            //Se estiver com foco na classe FluxoNavega
            $(".FluxoNavega").focus(function () {
                $(this).bind('keydown', function (e) {
                    if (e.keyCode == 13) {
                        $(this).click();
                    }
                });
            });

        });

        $(".FirstInputModal").focus();
    }

    if (opcao == "P") { //Cons.Lim.Proposto
        $('#divConteudoOpcao').bind('keydown', function (e) {
            if (e.keyCode == 27) {
                encerraRotina();
            }
        })

        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmNovoLimite") {
                $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");
                $(this).find("#divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
            }
	});	

        //Se estiver com foco na classe FluxoNavega
        $(".FluxoNavega").focus(function () {
            $(this).bind('keydown', function (e) {


                if (e.keyCode == 13) {
                    $(this).click();
                }
                if (e.keyCode == 27) {
                    encerraRotina();
}
            });
        });

        $(".FirstInputModal").focus();
    }
    if(opcao == null){
    	$(":input").blur();	
    }
}



// Função para fechar div com mensagens de alerta
function encerraMsgsGrupoEconomico() {
    
    // Esconde div
    $("#divMsgsGrupoEconomico").css("visibility", "hidden");
    
    $("#divListaMsgsGrupoEconomico").html("&nbsp;");
    
    // Esconde div de bloqueio
    unblockBackground();
    blockBackground(parseInt($("#divRotina").css("z-index")));
    
    eval(dsmetodo);
    
    return false;
    
}

function mostraMsgsGrupoEconomico() {
    
    
    if (strHTML != '') {
        
        // Coloca conteúdo HTML no div
        $("#divListaMsgsGrupoEconomico").html(strHTML);
        $("#divMensagem").html(strHTML2);
                
        // Mostra div 
        $("#divMsgsGrupoEconomico").css("visibility", "visible");
        
        exibeRotina($("#divMsgsGrupoEconomico"));
        
        // Esconde mensagem de aguardo
        hideMsgAguardo();
                    
        // Bloqueia conteúdo que está átras do div de mensagens
        blockBackground(parseInt($("#divMsgsGrupoEconomico").css("z-index")));
                
    }
    
    return false;
    
}

function formataGrupoEconomico() {

    var divRegistro = $('div.divRegistros', '#divMsgsGrupoEconomico');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);
            
    divRegistro.css({ 'height': '140px' });
    
    $('#divListaMsgsGrupoEconomico').css({ 'height': '200px' });
    $('#divMensagem').css({ 'width': '250px' });
    
    var ordemInicial = new Array();
                    
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    
    tabela.formataTabela(ordemInicial, '', arrayAlinha);
    
    return false;
    
}



function buscaGrupoEconomico() {

    showMsgAguardo("Aguarde, verificando grupo econ&ocirc;mico...");
    
    $.ajax({        
        type: 'POST', 
        url: UrlSite + 'telas/atenda/descontos/titulos/busca_grupo_economico.php',
        data: {
            nrdconta: nrdconta, 
			// PRJ 438 - Sprint 7 - Flag para nao validar o avalista, que já é validado anteriormente (0 não validar / 1 validar)
			flgValidarAvalistas: 0,	
            redirect: 'html_ajax'
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
			// PRJ 438 - Sprint 7 - Flag para nao validar o avalista, que já é validado anteriormente (0 não validar / 1 validar)
			flgValidarAvalistas: 0,
            redirect: 'html_ajax'
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
    
    return false;
    
}

function escondeObservacoes() {
    $("#divDadosPrincipal, #divDadosPrincipal_2").css('display', 'block');
    $("#divDadosObservacoes").css("display", "none");
}

function confirmaAlteracaoObservacao(nrctrpro) {
    showConfirmacao('Deseja confirmar a altera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'atualizaObservacoes(' + nrctrpro + ')', 'blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
}

function atualizaObservacoes(nrctrpro) {
    
    showMsgAguardo("Aguarde, gravando as observa&ccedil;&otilde;es...");

    $.ajax({        
        type: 'POST', 
        url: UrlSite + 'telas/atenda/limite_credito/grava_observacao.php',
        data: {
            nrdconta: nrdconta, 
            nrctrlim: nrctrpro,
            dsobserv: $("#dsobserv", "#divDadosObservacoes").val(),
            redirect: 'html_ajax'
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
    
    return false;
    
}

//***********************************************************TIAGO********************************************************
// Função para validar novo limite de crédito
function validarAlteracaoLimite(inconfir, inconfi2, flgimpnp) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando novo " + strTitRotinaLC + " ...");
    
    
	
    var nrctrlim = $("#nrctrlim", "#frmNovoLimite").val().replace(/\./g, "");
    var cddlinha = $("#cddlinha", "#frmNovoLimite").val();
    var vllimite = $("#vllimite", "#frmNovoLimite").val().replace(/\./g, "");
    //bruno - prj 438 - sprint 7 - novo limite
    if(flgimpnp == "" || typeof flgimpnp == 'undefined'){
        flgimpnp = 'yes';
    }
    
    // Valida número do contrato
    if (nrctrlim == "" || !validaNumero(nrctrlim, true, 0, 0)) {
        hideMsgAguardo();
        showError("error", "N&uacute;mero de contrato inv&aacute;lido.", "Alerta - Aimaro", "$('#nrctrlim','#frmNovoLimite').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    } 
    
    // Valida linha de crédito
    if (cddlinha == "" || !validaNumero(cddlinha, true, 0, 0)) {
        hideMsgAguardo();
        showError("error", "Linha de cré	dito inv&aacute;lida.", "Alerta - Aimaro", "$('#cddlinha','#frmNovoLimite').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    // Valida valor do limite de crédito
    if (vllimite == "" || !validaNumero(vllimite, true, 0, 0)) {
        hideMsgAguardo();
        showError("error", "Valor do " + strTitRotinaLC + " inv&aacute;lido.", "Alerta - Aimaro", "$('#vllimite','#frmNovoLimite').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }   
    
    // Executa script de validação do limite através de ajax
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/limite_credito/validar_alteracao_limite.php",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            cddlinha: cddlinha,
            vllimite: vllimite,
            flgimpnp: flgimpnp,
            inconfir: inconfir,
            inconfi2: inconfi2,
            cddopcao: aux_cddopcao, //bruno - prj 438 - sprint 7 - novo limite
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

// Função para cadastrar novo plano de capital
function alterarNovoLimite() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, alterando o " + strTitRotinaLC + " ...");
            
    // bruno - prj 438 - sprint 7 - tela rating
    var aux_perfatcl = $("#perfatcl", "#frmNovoLimite").val();
    if(aux_perfatcl == "" || typeof aux_perfatcl == "undefined"){
        aux_perfatcl = 0;
    }

    // Função com a atribuição das variaveis dos avalistas
	geraRegsDinamicosAvalistas();

	var nrctaav1 = (typeof aux_nrctaav0 == 'undefined') ? 0  : aux_nrctaav0;
    var nmdaval1 = (typeof aux_nmdaval0 == 'undefined') ? '' : aux_nmdaval0;
	var nrcpfav1 = (typeof aux_nrcpfav0 == 'undefined') ? '' : aux_nrcpfav0;
	var tpdocav1 = (typeof aux_tpdocav0 == 'undefined') ? '' : aux_tpdocav0;
	var dsdocav1 = (typeof aux_dsdocav0 == 'undefined') ? '' : aux_dsdocav0;
	var nmdcjav1 = (typeof aux_nmdcjav0 == 'undefined') ? '' : aux_nmdcjav0;
	var cpfcjav1 = (typeof aux_cpfcjav0 == 'undefined') ? '' : aux_cpfcjav0;
	var tdccjav1 = (typeof aux_tdccjav0 == 'undefined') ? '' : aux_tdccjav0;
	var doccjav1 = (typeof aux_doccjav0 == 'undefined') ? '' : aux_doccjav0;
	var ende1av1 = (typeof aux_ende1av0 == 'undefined') ? '' : aux_ende1av0;
	var ende2av1 = (typeof aux_ende2av0 == 'undefined') ? '' : aux_ende2av0;
	var nrfonav1 = (typeof aux_nrfonav0 == 'undefined') ? '' : aux_nrfonav0;
	var emailav1 = (typeof aux_emailav0 == 'undefined') ? '' : aux_emailav0;
	var nmcidav1 = (typeof aux_nmcidav0 == 'undefined') ? '' : aux_nmcidav0;
	var cdufava1 = (typeof aux_cdufava0 == 'undefined') ? '' : aux_cdufava0;
	var nrcepav1 = (typeof aux_nrcepav0 == 'undefined') ? '' : aux_nrcepav0;
	var cdnacio1 = (typeof aux_cdnacio0 == 'undefined') ? '' : aux_cdnacio0;
	var vledvmt1 = (typeof aux_vledvmt0 == 'undefined') ? '' : aux_vledvmt0;
	var vlrenme1 = (typeof aux_vlrenme0 == 'undefined') ? '' : aux_vlrenme0;
	var nrender1 = (typeof aux_nrender0 == 'undefined') ? '' : aux_nrender0;
	var complen1 = (typeof aux_complen0 == 'undefined') ? '' : aux_complen0;
	var nrcxaps1 = (typeof aux_nrcxaps0 == 'undefined') ? '' : aux_nrcxaps0;
	var inpesso1 = (typeof aux_inpesso0 == 'undefined') ? '' : aux_inpesso0;
	var dtnasct1 = (typeof aux_dtnasct0 == 'undefined') ? '' : aux_dtnasct0;
	var vlrecjg1 = (typeof aux_vlrencj0 == 'undefined') ? '' : aux_vlrencj0;

	var nrctaav2 = (typeof aux_nrctaav1 == 'undefined') ? 0  : aux_nrctaav1;
	var nmdaval2 = (typeof aux_nmdaval1 == 'undefined') ? '' : aux_nmdaval1;
	var nrcpfav2 = (typeof aux_nrcpfav1 == 'undefined') ? '' : aux_nrcpfav1;
	var tpdocav2 = (typeof aux_tpdocav1 == 'undefined') ? '' : aux_tpdocav1;
	var dsdocav2 = (typeof aux_dsdocav1 == 'undefined') ? '' : aux_dsdocav1;
	var nmdcjav2 = (typeof aux_nmdcjav1 == 'undefined') ? '' : aux_nmdcjav1;
	var cpfcjav2 = (typeof aux_cpfcjav1 == 'undefined') ? '' : aux_cpfcjav1;
	var tdccjav2 = (typeof aux_tdccjav1 == 'undefined') ? '' : aux_tdccjav1;
	var doccjav2 = (typeof aux_doccjav1 == 'undefined') ? '' : aux_doccjav1;
	var ende1av2 = (typeof aux_ende1av1 == 'undefined') ? '' : aux_ende1av1;
	var ende2av2 = (typeof aux_ende2av1 == 'undefined') ? '' : aux_ende2av1;
	var nrfonav2 = (typeof aux_nrfonav1 == 'undefined') ? '' : aux_nrfonav1;
	var emailav2 = (typeof aux_emailav1 == 'undefined') ? '' : aux_emailav1;
	var nmcidav2 = (typeof aux_nmcidav1 == 'undefined') ? '' : aux_nmcidav1;
	var cdufava2 = (typeof aux_cdufava1 == 'undefined') ? '' : aux_cdufava1;
	var nrcepav2 = (typeof aux_nrcepav1 == 'undefined') ? '' : aux_nrcepav1;
	var cdnacio2 = (typeof aux_cdnacio1 == 'undefined') ? '' : aux_cdnacio1;
	var vledvmt2 = (typeof aux_vledvmt1 == 'undefined') ? '' : aux_vledvmt1;
	var vlrenme2 = (typeof aux_vlrenme1 == 'undefined') ? '' : aux_vlrenme1;
	var nrender2 = (typeof aux_nrender1 == 'undefined') ? '' : aux_nrender1;
	var complen2 = (typeof aux_complen1 == 'undefined') ? '' : aux_complen1;
	var nrcxaps2 = (typeof aux_nrcxaps1 == 'undefined') ? '' : aux_nrcxaps1;
	var inpesso2 = (typeof aux_inpesso1 == 'undefined') ? '' : aux_inpesso1;
	var dtnasct2 = (typeof aux_dtnasct1 == 'undefined') ? '' : aux_dtnasct1;
	var vlrecjg2 = (typeof aux_vlrecjg1 == 'undefined') ? '' : aux_vlrecjg1;

	var dsobserv = removeAcento($("#dsobserv", "#frmNovoLimite").val());

	var dataAlterar = {
		nrdconta: nrdconta,
		nrctrlim: $("#nrctrlim", "#frmNovoLimite").val().replace(/\./g, ""),
		cddlinha: $("#cddlinha", "#frmNovoLimite").val(),
		vllimite: $("#vllimite", "#frmNovoLimite").val().replace(/\./g, ""),
		flgimpnp: aux_novoLimite.flgimpnp,//bruno - prj 438 - sprint 7 - novo limite  //$("#flgimpnp", "#frmNovoLimite").val(),
		vlsalari: $("#vlsalari", "#frmNovoLimite").val().replace(/\./g, ""),
		vlsalcon: $("#vlsalcon", "#frmNovoLimite").val().replace(/\./g, ""),
		vloutras: $("#vloutras", "#frmNovoLimite").val().replace(/\./g, ""),
		vlalugue: $("#vlalugue", "#frmNovoLimite").val().replace(/\./g, ""),
		inconcje: ($("#inconcje_1", "#frmNovoLimite").prop('checked')) ? 1 : 0,
		dsobserv: dsobserv,
		dtconbir: dtconbir,			
		/** Variáveis globais alimentadas na função validaDadosRating em rating.js **/
		// bruno - prj 438 - sprint 7 - tela rating
		nrgarope: $("#nrgarope", "#frmNovoLimite").val(),
		nrinfcad: $("#nrinfcad", "#frmNovoLimite").val(),
		nrliquid: $("#nrliquid", "#frmNovoLimite").val(),
		nrpatlvr: $("#nrpatlvr", "#frmNovoLimite").val(),
		perfatcl: "0",
		nrperger: $("#nrperger", "#frmNovoLimite").val(),
		/** ---------------------------------------------------------------------- **/
		nrctaav1: normalizaNumero(nrctaav1),
		nmdaval1: nmdaval1,
		nrcpfav1: normalizaNumero(nrcpfav1),
		tpdocav1: tpdocav1,
		dsdocav1: dsdocav1,
		nmdcjav1: nmdcjav1,
		cpfcjav1: normalizaNumero(cpfcjav1),
		tdccjav1: tdccjav1,
		doccjav1: doccjav1,
		ende1av1: ende1av1,
		ende2av1: ende2av1,
		nrcepav1: normalizaNumero(nrcepav1),
		nmcidav1: nmcidav1,
		cdufava1: cdufava1,
		nrfonav1: nrfonav1,
		emailav1: emailav1,
		nrender1: normalizaNumero(nrender1),
		complen1: complen1,
		nrcxaps1: normalizaNumero(nrcxaps1),
		vlrenme1: vlrenme1,
		vlrecjg1: vlrecjg1,
		cdnacio1: cdnacio1,
		inpesso1: inpesso1,
		dtnasct1: dtnasct1,
		
		nrctaav2: normalizaNumero(nrctaav2),
		nmdaval2: nmdaval2,
		nrcpfav2: normalizaNumero(nrcpfav2),
		tpdocav2: tpdocav2,
		dsdocav2: dsdocav2,
		nmdcjav2: nmdcjav2,
		cpfcjav2: normalizaNumero(cpfcjav2),
		tdccjav2: tdccjav2,
		doccjav2: doccjav2,
		ende1av2: ende1av2,
		ende2av2: ende2av2,
		nrcepav2: normalizaNumero(nrcepav2),
		nmcidav2: nmcidav2,
		cdufava2: cdufava2,
		nrfonav2: nrfonav2,
		emailav2: emailav2,
		nrender2: normalizaNumero(nrender2),
		complen2: complen2,
		nrcxaps2: normalizaNumero(nrcxaps2),
		vlrenme2: vlrenme2,
		vlrecjg2: vlrecjg2,
		cdnacio2: cdnacio2,
		inpesso2: inpesso2,
		dtnasct2: dtnasct2,
		idcobope: $("#idcobert", "#frmNovoLimite").val(),
		redirect: "script_ajax"
    };

	// Executa script de cadastro do limite atravé	s de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/limite_credito/alterar_novo_limite.php",
		data: dataAlterar,		
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

function buscaDadosProposta(nrdconta, nrctrlim) {

    //bruno - prj 438 - sprint 7 - novo limite
    var inpessoa = "";
    switch(aux_cddopcao){
        case 'P':
            inpessoa = aux_limites.pausado.inpessoa;
            break;
        case 'A':
            inpessoa = aux_limites.ativo.inpessoa;
            break;
        case 'N':
            if(flgProposta){ //Alterar proposta
                inpessoa = aux_limites.pausado.inpessoa;
            }
            break;
    }

    // Executa script de confirmação através de ajax
    $.ajax({        
        type: "POST",
        url: UrlSite + "telas/atenda/limite_credito/obtem_dados_proposta.php", 
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            redirect: "script_ajax"
        }, 
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {               
                eval(response);             
                hideMsgAguardo();               
                blockBackground(parseInt($("#divRotina").css("z-index")));              
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }               
    });             

}

function dadosRenda() {

    var nrctrlim = $("#nrctrlim", ".fsLimiteCredito").val();
    var cTodosRenda = $('input, select', '#divDadosRenda');     
    
    showMsgAguardo("Aguarde, consultando dados ...");
            
    $("#divDadosLimite").css("display", "none");
    $("#divDadosRenda").css("display", "block");
    cTodosRenda.desabilitaCampo();

    buscaDadosProposta(nrdconta, nrctrlim);
    
}

function setDadosProposta(vlsalari, vlsalcon, vloutras, vlalugue, nrctaav1, nrctaav2, inconcje, nrcpfav1, nrcpfav2, idcobert) {
    //Nao estava preenchendo corretamente o campo quando retornava um valor decimal
    //Chamado 364592
    vlsalari = vlsalari.replace(",", ".");
    vlsalcon = vlsalcon.replace(",", ".");
    vloutras = vloutras.replace(",", ".");
    vlalugue = vlalugue.replace(",", ".");

    $("#vlsalari").val(number_format(vlsalari, 2, ",", "."));
    $("#vlsalcon").val(number_format(vlsalcon, 2, ",", "."));
    $("#vloutras").val(number_format(vloutras, 2, ",", "."));
    $("#vlalugue").val(number_format(vlalugue, 2, ",", "."));
    $("#inconcje_" + inconcje).prop('checked', 'true');
        
    $("#nrctaav1", "#frmNovoLimite").val(nrctaav1);
    $("#nrctaav2", "#frmNovoLimite").val(nrctaav2);
    $("#nrcpfav1", "#frmNovoLimite").val(nrcpfav1);
    $("#nrcpfav2", "#frmNovoLimite").val(nrcpfav2);
    $("#idcobert", "#frmNovoLimite").val(idcobert);
    
    // Salvar o valor da consulta do conjuge antes de ser alterado pelo usuario
    ant_inconcje = inconcje;
    
}

/* [033] */
function btContinuarObservacao(nrgarope, nrinfcad, nrliquid, nrpatlvr) {
    if (aux_cdcooper == 3 || var_globais.habrat == 'N') {
        setDadosRating(nrgarope, nrinfcad, nrliquid, nrpatlvr);
        hideMsgAguardo();
    $("#divDadosObservacoes").css("display", "none");
        controlaOperacao('A_PROTECAO_TIT');
    } else {
        $("#divDadosObservacoes").css("display", "none");
    controlaOperacao('C_COMITE_APROV');
    }
    return false;
}
/* [033] */

function setDadosRating(nrgarope, nrinfcad, nrliquid, nrpatlvr) {

    var nrctaav1 = normalizaNumero($('#nrctaav1', '#divDadosAvalistas').val());
    var nrcpfav1 = normalizaNumero($('#nrcpfav1', '#divDadosAvalistas').val());
    
    var nrctaav2 = normalizaNumero($('#nrctaav2', '#divDadosAvalistas').val());
    var nrcpfav2 = normalizaNumero($('#nrcpfav2', '#divDadosAvalistas').val());
    
    $("#ant_nrctaav1", "#divDadosAvalistas").val(nrctaav1);
    $("#ant_nrcpfav1", "#divDadosAvalistas").val(nrcpfav1);
    $("#ant_nrctaav2", "#divDadosAvalistas").val(nrctaav2);
    $("#ant_nrcpfav2", "#divDadosAvalistas").val(nrcpfav2);
    
    carregaAvalista(1);
    carregaAvalista(2);
                        
    // Este campo foi para a tela de consultas automatizadas.
    // Colocar "1" somente para validar os dados do Rating
    nrinfcad = (nrinfcad == 0) ? 1 : nrinfcad;
                    
    $("#nrgarope").val(nrgarope);   
    $("#nrinfcad").val(nrinfcad);
    $("#nrliquid").val(nrliquid);
    $("#nrpatlvr").val(nrpatlvr);
        
}

function setDadosObservacao(dsobserv) {
    $("#dsobserv").val(dsobserv);
    $('#dsobserv', '#' + nomeForm + ' .fsObservacoes').val(dsobserv);
}

function changeAbaPropLabel(dslababa) {
    $("a[name=N]").text(dslababa);
}

function trataObservacao(cddopcao) {

    var cTodosObservacao = $("input, select, textarea", "#divDadosObservacoes");
    
    // Se nao for Inclusao ou alteracao, desabilitar os campos
    if (cddopcao != 'N') {
        cTodosObservacao.desabilitaCampo();
    }
    
}

function efetuar_consultas() {

    var cddopcao = (flgProposta == 1) ? 'A' : 'I';
                
    showMsgAguardo('Aguarde, efetuando consultas ...');
                
    $.ajax({
        type: 'POST',
        url: UrlSite + 'includes/consultas_automatizadas/efetuar_consultas.php',
        data: {
            nrdconta: nrdconta,
            nrdocmto: nrctrrat,
            inprodut: 3, // Cheque especial
            cddopcao: cddopcao,
            insolici: 1,
            redirect: 'script_ajax'
          },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            hideMsgAguardo();               
            eval(response);
            return false;
        }
    });
    return false;
}

// Function para controlar as telas das consultas automatizadas
function controlaOperacao(operacao) {

    var nrctrlim = $("#nrctrlim", "#frmNovoLimite").val();

    //bruno - prj 438 - sprint 7 - tela principal
    if(nrctrlim == "" || typeof nrctrlim == 'undefined'){
        nrctrlim = aux_limites.ativo.nrctrlim;
        
        //Se for consulta do limite proposto recuperar o valor do contrato do limite proposto|pausado
        if(aux_cddopcao == 'P' && aux_limites.pausado.nrctrlim != ""){
            nrctrlim = aux_limites.pausado.nrctrlim;
        }
    }

    var iddoaval_busca = 0;
    var inpessoa_busca = 0;
    var nrdconta_busca = 0;
    var nrcpfcgc_busca = 0;
    var inconcje = 0;

    if (inpessoa == 1) {
        inconcje = $("#inconcje_1", "#divDadosRenda").prop('checked') ? 1 : 0;
    }

    switch (operacao) {
    
        case 'A_INICIO':
        case 'C_INICIO': 
        case 'I_INICIO': {
            idSocio = 0;
            lcrShowHideDiv('divFormRating', 'frmOrgaos'); //bruno - prj 438 - sprint 7 - tela rating
            return false;
        }
    
        case 'I_PROTECAO_TIT': {
            idSocio = 0;
        }
    
        case 'A_PROTECAO_TIT': {
            idSocio = 0;
            inpessoa_busca = inpessoa;
            nrdconta_busca = nrdconta;
            nrcpfcgc_busca = 0; 
            break;
        }
    
        case 'C_PROTECAO_TIT': {
            idSocio = 0;
            inpessoa_busca = inpessoa;
            nrdconta_busca = nrdconta;
            nrcpfcgc_busca = 0;
            break;
        }
        
        case 'A_PROTECAO_SOC':
        case 'C_PROTECAO_SOC': {
            idSocio = idSocio + 1;
            inpessoa_busca = inpessoa;
            nrdconta_busca = nrdconta;
            nrcpfcgc_busca = 0;
            break;
        }
        
        case 'A_PROTECAO_AVAL':
        case 'C_PROTECAO_AVAL': {  // Aval 1
            iddoaval_busca = 1;
            idSocio = 0;
            inpessoa_busca = $("#inpesso1", "#divDadosAvalistas").val();
            nrdconta_busca = normalizaNumero($("#nrctaav1", "#divDadosAvalistas").val());
            nrcpfcgc_busca = normalizaNumero($("#nrcpfav1", "#divDadosAvalistas").val());
            
            var ant_nrctaav1 = normalizaNumero($("#ant_nrctaav1", "#divDadosAvalistas").val());
            var ant_nrcpfav1 = normalizaNumero($("#ant_nrcpfav1", "#divDadosAvalistas").val());
             
            // Se nao tem avalista 1, ou se mudaram os dados do aval 1, vai para o proximo 
            if ((nrdconta_busca == 0 && nrcpfcgc_busca == 0) ||
                 (nrdconta_busca != ant_nrctaav1) ||
                 (nrcpfcgc_busca != ant_nrcpfav1)) {
                controlaOperacao(operacao.substr(0, 2) + "DADOS_AVAL");
                return false;
            }
            
            break;
        }
        
        case 'A_DADOS_AVAL':
        case 'C_DADOS_AVAL': {  // Aval 2
            iddoaval_busca = 2;
            inpessoa_busca = $("#inpesso2", "#divDadosAvalistas").val();
            nrdconta_busca = normalizaNumero($("#nrctaav2", "#divDadosAvalistas").val());
            nrcpfcgc_busca = normalizaNumero($("#nrcpfav2", "#divDadosAvalistas").val());
            
            var ant_nrctaav2 = normalizaNumero($("#ant_nrctaav2", "#divDadosAvalistas").val());
            var ant_nrcpfav2 = normalizaNumero($("#ant_nrcpfav2", "#divDadosAvalistas").val());
                        
            // Se nao tem avalista 2, ou se mudaram os dados do aval 2, vai para a proxima tela 
            if ((nrdconta_busca == 0 && nrcpfcgc_busca == 0) ||
                 (nrdconta_busca != ant_nrctaav2) ||
                 (nrcpfcgc_busca != ant_nrcpfav2)) {
                
                if (operacao == 'A_DADOS_AVAL') { // Alteracao
                    buscaGrupoEconomico();
                } else {                        
                    acessaOpcaoAba(8, 0, '@'); // Consulta
                }
                return false;
            }
            
            operacao = operacao.substr(0, 1) + '_PROTECAO_AVAL_2';
            break;
        }   
        
        case 'A_COMITE_APROV': {
            if (aux_cdcooper == 3 || var_globais.habrat == 'N') {
                validaItensRating(operacao, true);
                return false;
            } else {
                return true;
            }
        }
        
        case 'A_AVAIS': {
            $("#frmOrgaos").remove();   
            $("#frmNovoLimite").css("width", 530);
            $("#divDadosAvalistas").css('display', 'block');
            return false;
        }
        
        case 'C_COMITE_APROV': {
            //bruno - prj 438 - sprint 7 - tela rating
            $("#divFormRating").css("display", "none");
            $("#frmOrgaos").remove();   
            $("#frmNovoLimite").css("width", 530);
            $("#divDadosAvalistas").css('display', 'block');
            return false;
        }   

        case 'A_PROTECAO_CONJ':
            if (ant_inconcje == 0) {
                controlaOperacao('A_COMITE_APROV');
                return false;
            } else {
                if (aux_cdcooper == 3 || var_globais.habrat == 'N') {
                    validaItensRating(operacao, true);
                } else {
                    return true;
                }
            }

        case 'C_PROTECAO_CONJ': {
            iddoaval_busca = 99;
            inpessoa_busca = 1;
            nrdconta_busca = nrctacje; 
            nrcpfcgc_busca = nrcpfcjg;      
            break;
        }
    
    }
        
    // Esconde div do RATING e AVAIS e remover o das consultas automatizadas
    //bruno - prj 438 - sprint 7 - tela rating
    $("#divFormRating").css("display", "none");
    $("#divDadosAvalistas").css("display", "none");
    $("#frmOrgaos").remove();
    
    showMsgAguardo('Aguarde, abrindo consultar ...');

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'includes/consultas_automatizadas/form_orgaos.php',
        data: {
            nrdconta: nrdconta,
            nrdocmto: nrctrlim,
            iddoaval_busca: iddoaval_busca, 
            inpessoa_busca: inpessoa_busca, 
            nrdconta_busca: nrdconta_busca,
            nrcpfcgc_busca: nrcpfcgc_busca,
            operacao: operacao,
            inprodut: 3,
            idSocio: idSocio,  
            inconcje: inconcje, 
            dtcnsspc: dtconbir,
            redirect: 'html_ajax' 
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
        
            hideMsgAguardo();
        
            if (response.indexOf('showError("error"') == -1) {
                                
                $('#frmNovoLimite').append(response);
                $('fieldset', '#frmOrgaos').css('height', 'auto');
                                    
                dsinfcad = (operacao == 'I_PROTECAO_TIT') ? "" : dsinfcad;
                                        
                formata_protecao(operacao, nrinfcad, dsinfcad);

            } else {
                eval(response);
            }
            return false;
        }
    });

}

function controlaSocios(operacao, cdcooper, idSocio, qtSocios) {
                
    if (operacao == "A_PROTECAO_TIT") {
        if ($("#nrinfcad", "#frmOrgaos").val() != undefined) {
            dtconbir = $("#dtcnsspc", "#frmOrgaos").val();
            nrinfcad = $("#nrinfcad", "#frmOrgaos").val();
        }
    }           
                
    if (idSocio > qtSocios) { // Nao tem mais socios, mostrar avais
    
        $("#frmOrgaos").remove();   
        $("#frmNovoLimite").css("width", 530);
        $("#divDadosAvalistas").css('display', 'block');
        
    }
    else { // Proximo socio
        controlaOperacao(operacao.substr(0, 2) + "PROTECAO_SOC");
    }

}

function validaItensRating(operacao, flgarray) {

    validaDadosRating(cdcooper, operacao, 3);

}

function confirmaInclusaoMenor(nrdconta, cddopcao, flpropos, inconfir) {

    // Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando...');
    
    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST", 
        dataType: "html",
        url: UrlSite + "telas/atenda/limite_credito/novo_limite.php",
        data: {
            nrdconta: nrdconta,
            cddopcao: cddopcao,
            flpropos: flpropos,
            inconfir: inconfir,
            inpessoa: var_globais.inpessoa, //bruno - prj 438 - sprint 7 - novo limite
            redirect: "html_ajax"
        },      
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divConteudoOpcao").html(response);
            controlaFoco(cddopcao);
        }               
    });
}

function mostraTelaAltera() {

    showMsgAguardo('Aguarde, abrindo altera&ccedil;&atilde;o...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/limite_credito/alterar_novo_limite_form.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
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


function exibeAlteraNumero() {
    
    showMsgAguardo('Aguarde, abrindo altera&ccedil;&atilde;o...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();
    
    /*
    if (situacao_limite != "") {
        showError("error", "&Eacute; poss&iacute;vel alterar apenas contratos nao efetivados.", "Alerta - Aimaro", "fechaRotinaAltera();");
        return false;
    }
    */

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/limite_credito/numero.php',
        data: {
            nrctrpro: var_globais.nrctrpro,
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "bloqueiaFundo($('#divUsoGenerico'));");
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
    acessaOpcaoAba(10,2,"@");
    //bruno - prj 438 - sprint 7 - fluxo novo limite
    //acessaOpcaoAba(8, 0, '@'); // Consulta
    return false;

}

function limpaDivGenerica() {

    $('#numero').remove();
    $('#altera').remove();

    return false;
}

function confirmaAlteraNrContrato() {
    showConfirmacao("Alterar n&uacute;mero da proposta?", "Confirma&ccedil;&atilde;o - Aimaro", "AlteraNrContrato();", "$('#new_nrctrlim','#frmNumero').focus();blockBackground(parseInt($('#divUsoGenerico').css('z-index')));", "sim.gif", "nao.gif");
}

// Função para alterar apenas o numero de contrato de limite 
function AlteraNrContrato() {

    showMsgAguardo("Aguarde, alterando n&uacute;mero do contrato ...");

    var nrctrant = $('#nrctrlim', '#frmNumero').val().replace(/\./g, "");
    var nrctrlim = $('#new_nrctrlim', '#frmNumero').val().replace(/\./g, "");

    // Valida número do contrato
    if (nrctrlim == "" || nrctrlim == "0" || !validaNumero(nrctrlim, true, 0, 0)) {
        hideMsgAguardo();
        showError("error", "Numero da proposta deve ser diferente de zero.", "Alerta - Aimaro", "$('#new_nrctrlim','#frmNumero').focus();blockBackground(parseInt($('#divUsoGenerico').css('z-index')));");
        return false;
    }

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/limite_credito/alterar_novo_limite_numero.php",        
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            nrctrant: nrctrant,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
        },
        success: function (response) {
            $("#divMsg").html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });
}

function validaAdesaoValorProduto(executar, vllimite) {
	
    var vllimite = vllimite != null ? vllimite : $("#vllimite", "#frmNovoLimite").val().replace(/\./g, "");
	
	// PJ470 - Mout's - buscar o nro do contrato via ajax
    var verifica_contrato = $("#nrctrlim","#frmNovoLimite").val().replace(/\./g, "");;

    if (verifica_contrato == null || verifica_contrato == 0) {
    
	$.ajax({
		type: "POST", 
		url: UrlSite + "telas/atenda/limite_credito/obtem_nro_contrato.php",
		data: {
			nrdconta: nrdconta
		},	
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel retornar o n&uacute;mero do contrato.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#nrctrlim", "#frmNovoLimite").val(response);
			var_globais.nrctrlim = response;			
			nrctrlim = response;			
		}				
	}); // fim PJ470
    }
	
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/limite_credito/valida_valor_adesao_produto.php', 
		data: {
			nrdconta: nrdconta,
			vllimite: vllimite,
			executar: executar,
			redirect: 'script_ajax'
		}, 
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
		},
		success: function (response) {
			hideMsgAguardo();
            try {
				eval(response);
			} catch (error) {
				showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground();');
			}
		}				
	});	
}

function senhaCoordenador(executaDepois) {
	pedeSenhaCoordenador(2,executaDepois,'divRotina');
}

/**
 * Autor: Bruno Luiz Katzjarowski;
 * Ajustar div no centro da tela
 * prj - 438 - sprint 7 - tela principal
 */
function ajustarCentralizacao() {
    var x = $.browser.msie ? $(window).innerWidth() : $("body").offset().width;
    x = x - 178;
    $('#divRotina').css({ 'width': x + 'px' });
    $('#divRotina').centralizaRotinaH();
    return false;
}


/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 29/11/2018
 */
function controlaLayoutConsultaLimiteAtivo(){
    var formNovoLimite = "#frmNovoLimite";

    $('#nrctrlim',formNovoLimite).val(aux_limites.ativo.nrctrlim);
}

/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 29/11/2018
 */
function controlaLayoutConsultalimiteEstudo(){
    var formNovoLimite = "#frmNovoLimite";

    $('#nrctrlim',formNovoLimite).val(aux_limites.pausado.nrctrlim);
}

/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 30/11/2018
 */
function controlaLayoutAlterarlimiteEstudo(){
    var formNovoLimite = "#frmNovoLimite";

    $('#nrctrlim',formNovoLimite).val(aux_limites.pausado.nrctrlim);
}

/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 30/11/2018
 */
function abrirGaropc(){
    var nrctrlim_aux = "";
    switch(aux_cddopcao){
        case 'A':
            nrctrlim_aux = aux_limites.ativo.nrctrlim;
            break;
        case 'P':
            nrctrlim_aux = aux_limites.pausado.nrctrlim;
            break;

    }

    trataObservacao(aux_cddopcao);
	trataGAROPC(aux_cddopcao,nrctrlim_aux);
		
	// Mostra div com campos para dados de renda
	$("#divDadosLimite").css("display","none");
}

/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 03/12/2018
 * Abrir tela Rating
 */
function abrirRating(){
    $('#divFormRating').show();
    blockBackground(parseInt($('#divRotina').css('z-index')));
}


/**
 * Controla layout tela rating
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 03/12/2018
 */
function controlaLayoutTelaRating(){
    var nomeFormRating = 'fsRating';
    
    var cTodos_2 = $('input', '#' + nomeFormRating + ' fieldset:eq(1)');
    var rRotulo_2 = $('label[for="nrgarope"],label[for="nrpatlvr"],label[for="nrperger"]', '#' + nomeFormRating);

    var rGarantia = $('label[for="nrgarope"]', '#' + nomeFormRating);
    var rLiquidez = $('label[for="nrliquid"]', '#' + nomeFormRating);
    var rPatriLv = $('label[for="nrpatlvr"]', '#' + nomeFormRating);
    var rPercep = $('label[for="nrperger"]', '#' + nomeFormRating);
    var rNrinfcad = $('label[for="nrinfcad"]', '#' + nomeFormRating);

    var cCodigo = $('#nrinfcad,#nrgarope,#nrliquid,#nrpatlvr,#nrperger', '#' + nomeFormRating);

    var cGarantia = $('#dsgarope', '#' + nomeFormRating);
    var cLiquidez = $('#dsliquid', '#' + nomeFormRating);
    var cPatriLv = $('#dspatlvr', '#' + nomeFormRating);
    var cPercep = $('#nrperger', '#' + nomeFormRating);
    var cDsPercep = $('#dsperger', '#' + nomeFormRating);
    var lupa = $('#lupanrperger', '#' + nomeFormRating);
    var cDsinfcad = $('#dsinfcad', '#' + nomeFormRating);
    var cNrinfcad = $('#nrinfcad', '#' + nomeFormRating);

    rRotulo_2.addClass('rotulo');
    rLiquidez.addClass('rotulo-linha');
    rPatriLv.css('width', '106px');
    rPercep.addClass('rotulo-linha');
    rGarantia.addClass('rotulo-linha');
    rNrinfcad.addClass('rotulo-linha');

    cCodigo.addClass('codigo pesquisa').css('width', '35px');
    cGarantia.addClass('descricao').css('width', '123px');
    cLiquidez.addClass('descricao').css('width', '123px');
    cPatriLv.addClass('descricao').css('width', '302px');
    cDsPercep.addClass('descricao').css('width', '181px');
    cDsinfcad.addClass('descricao').css('width', '181px');
    cNrinfcad.addClass('campo').css('width', '35px'); //Inf. Cadastrais

    if(inpessoa == 1){
    	$("#divRatingPJ").css("display","none");
    }

}

/** 
 * Aplicar eventos em Lupas e campos para a tela Rating - Consulta/Alteração/Inclusão
 * Autor: Bruno Luiz katzjarowski
 * Data: 04/12/2018
*/
function aplicarEventosLupasTelaRating(){
    //bruno - prj 438 - sprint 7 - tela rating

    /* Campo Inf. cadastrais na tela Rating - form_rating.php */
    $('#nrinfcad','#'+nomeForm).unbind('change').bind('change',function(){
        bo			= 'b1wgen0059.p';
        procedure   = 'busca_seqrating';
        titulo      = 'Informa&ccedil&atildeo Cadastral';
        nrtopico    = ( var_globais.inpessoa == 1 ) ? '1' : '3';
        nritetop    = ( var_globais.inpessoa == 1 ) ? '4' : '3';
        filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop+';flgcompl|no;nrseqite|'+$(this).val();
        buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsinfcad',$(this).val(),'dsseqit1',filtrosDesc,nomeForm);
    }).next().unbind('click').bind('click',function(){
        bo			= 'b1wgen0059.p';
		procedure   = 'busca_seqrating';
		titulo      = 'Itens do Rating';
		qtReg		= '20';
		nrtopico    = ( var_globais.inpessoa == 1 ) ? '1' : '3';
		nritetop    = ( var_globais.inpessoa == 1 ) ? '4' : '3';
		filtros		= 'C&oacuted. Inf. Cadastral;nrinfcad;30px;S;0|Inf. Cadastral;dsinfcad;200px;S;|;nrtopico;;;'+nrtopico+';N|;nritetop;;;'+nritetop+';N|;flgcompl;;;no;N';
		colunas 	= 'Seq. Item;nrseqite;20%;right|Descri&ccedil&atildeo Seq. Item;dsseqite;80%;left;dsseqit1';
		mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
		return false;
    });


    /* Campo Garantia na tela Rating - form_rating.php */
    $('#nrgarope','#'+nomeForm).unbind('change').bind('change',function(){
        bo = 'b1wgen0059.p';
        procedure = 'busca_seqrating';
        titulo = 'Garantia';
        nrtopico = (var_globais.inpessoa == 1) ? '2' : '4';
        nritetop = (var_globais.inpessoa == 1) ? '2' : '2';
        filtrosDesc = 'nrtopico|' + nrtopico + ';nritetop|' + nritetop + ';flgcompl|no;nrseqite|' + $(this).val();
        buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsgarope', $(this).val(), 'dsseqit1', filtrosDesc, nomeForm);
    }).next().unbind('click').bind('click',function(){
        bo = 'b1wgen0059.p';
        procedure = 'busca_seqrating';
        titulo = 'Itens do Rating';
        qtReg = '20';
        nrtopico = (var_globais.inpessoa == 1) ? '2' : '4';
        nritetop = (var_globais.inpessoa == 1) ? '2' : '2';
        filtrosPesq = 'C&oacuted. Inf. Cadastral;nrgarope;30px;S;0|Inf. Cadastral;dsgarope;200px;S;|;nrtopico;;;' + nrtopico + ';N|;nritetop;;;' + nritetop + ';N|;flgcompl;;;no;N';
        colunas = 'Seq. Item;nrseqite;20%;right|Descri&ccedil&atildeo Seq. Item;dsseqite;80%;left;dsseqit1';
        mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
        return false;
    });

    /* Campo nrliquid Liquidez - tela rating - form_rating.php  */
    $('#nrliquid','#'+nomeForm).unbind('change').bind('change',function(){
        bo = 'b1wgen0059.p';
        procedure = 'busca_seqrating';
        titulo = 'Liquidez';
        nrtopico = (var_globais.inpessoa == 1) ? '2' : '4';
        nritetop = (var_globais.inpessoa == 1) ? '3' : '2';
        filtrosDesc = 'nrtopico|' + nrtopico + ';nritetop|' + nritetop + ';flgcompl|no;nrseqite|' + $(this).val();
        buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsliquid', $(this).val(), 'dsseqit1', filtrosDesc, nomeForm);
        return false;
    }).next().unbind('click').bind('click',function(){
        bo = 'b1wgen0059.p';
        procedure = 'busca_seqrating';
        titulo = 'Itens do Rating';
        qtReg = '20';
        nrtopico = (var_globais.inpessoa == 1) ? '2' : '4';
        nritetop = (var_globais.inpessoa == 1) ? '3' : '3';
        filtrosPesq = 'C&oacuted. Inf. Cadastral;nrliquid;30px;S;0|Inf. Cadastral;dsliquid;200px;S;|;nrtopico;;;' + nrtopico + ';N|;nritetop;;;' + nritetop + ';N|;flgcompl;;;no;N';
        colunas = 'Seq. Item;nrseqite;20%;right|Descri&ccedil&atildeo Seq. Item;dsseqite;80%;left;dsseqit1';
        mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
        return false;
    });

    /* Campo nrpatlvr - Patr. pessoal livre - tela Rating - form_rating.php */
    $('#nrpatlvr','#'+nomeForm).unbind('change').bind('change',function(){
        bo = 'b1wgen0059.p';
        procedure = 'busca_seqrating';
        titulo = 'Patrim&ocircnio Livre';
        nrtopico = (var_globais.inpessoa == 1) ? '1' : '3';
        nritetop = (var_globais.inpessoa == 1) ? '8' : '9';
        filtrosDesc = 'nrtopico|' + nrtopico + ';nritetop|' + nritetop + ';flgcompl|no;nrseqite|' + $(this).val();
        buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dspatlvr', $(this).val(), 'dsseqit1', filtrosDesc, nomeForm);
        return false;
    }).next().unbind('click').bind('click',function(){                    
        bo = 'b1wgen0059.p';
        procedure = 'busca_seqrating';
        titulo = 'Itens do Rating';
        qtReg = '20';
        nrtopico = (var_globais.inpessoa == 1) ? '1' : '3';
        nritetop = (var_globais.inpessoa == 1) ? '8' : '9';
        filtrosPesq = 'C&oacuted. Inf. Cadastral;nrpatlvr;30px;S;0|Inf. Cadastral;dspatlvr;200px;S;|;nrtopico;;;' + nrtopico + ';N|;nritetop;;;' + nritetop + ';N|;flgcompl;;;no;N';
        colunas = 'Seq. Item;nrseqite;20%;right|Descri&ccedil&atildeo Seq. Item;dsseqite;80%;left;dsseqit1';
        mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
        return false;
    });

    /**
     * Campo nrperger - Percepção geral com relação a empresa - tela rating - form_rating.php 
     */
    $('#nrperger','#'+nomeForm).unbind('change').bind('change',function(){
        bo = 'b1wgen0059.p';
        procedure = 'busca_seqrating';
        titulo = 'Patrim&ocircnio Livre';
        nrtopico = '3';
        nritetop = '11';
        filtrosDesc = 'nrtopico|' + nrtopico + ';nritetop|' + nritetop + ';flgcompl|no;nrseqite|' + $(this).val();
        buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsperger', $(this).val(), 'dsseqit1', filtrosDesc, nomeForm);
        return false;
    }).next().unbind('click').bind('click',function(){                    
        bo = 'b1wgen0059.p';
        procedure = 'busca_seqrating';
        titulo = 'Itens do Rating';
        qtReg = '20';
        nrtopico = '3';
        nritetop = '11';
        filtrosPesq = 'C&oacuted. Inf. Cadastral;nrperger;30px;S;0|Inf. Cadastral;dsperger;200px;S;|;nrtopico;;;' + nrtopico + ';N|;nritetop;;;' + nritetop + ';N|;flgcompl;;;no;N';
        colunas = 'Seq. Item;nrseqite;20%;right|Descri&ccedil&atildeo Seq. Item;dsseqite;80%;left;dsseqit1';
        mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
        return false;
    });
}

/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * bruno - prj 438 - tela rating
 * @param {numero cooperado} cdcooper 
 * @param {codigo da operacao} operacao 
 * @param {???} inprodut 
 */
function validarDadosRating(cdcooper , operacao , inprodut) { 

	var vlprodut;

	showMsgAguardo("Aguarde, validando dados do rating ...");

	if (inprodut == 3 && operacao == 'I_PROT_CRED') { // Limite de credito
		vlprodut = $("#vllimite","#frmNovoLimite").val().replace(".","").replace(",",".");
	}
		
	nrgarope = $("#nrgarope","#"+nomeForm).val();
	nrliquid = $("#nrliquid","#"+nomeForm).val();
	nrpatlvr = $("#nrpatlvr","#"+nomeForm).val();	
		
		
	if (inprodut == 3) { // Limite de credito
		if (operacao != 'A_PROT_CRED' && operacao != 'I_PROT_CRED') {			
			nrinfcad = $("#nrinfcad","#frmOrgaos").val();
			dtconbir = $("#dtcnsspc","#frmOrgaos").val();
		} else {
			nrinfcad = (nrinfcad == 0 || operacao == 'I_PROT_CRED' ) ? undefined : nrinfcad;
		}
	} else {
		nrinfcad = $("#nrinfcad","#"+nomeForm).val();
		//vltotsfn = $("#vltotsfn","#"+nomeForm).val().replace(/\./g,"");
    }
    
    //perfatcl = (inpessoa == 1) ? "0,00" : $("#perfatcl","#frmDadosRating").val().replace(/\./g,"");
	nrperger = (var_globais.inpessoa == 1) ? "0" : $("#nrperger","#"+nomeForm).val();
			
	if (aux_cdcooper == 3 || var_globais.habrat == 'N') {
	
		if (nrgarope != "" && validaNumero(nrgarope,true,0,0)) {
			hideMsgAguardo();
			showError("error","N&atilde;o pode ser informado nenhuma garantia.","Alerta - Aimaro","$('#nrgarope','#'+'"+nomeForm+"').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
		
		if (nrpatlvr != "" && validaNumero(nrpatlvr,true,0,0)) {
			hideMsgAguardo();
			showError("error","N&atilde;o pode ser informado nenhum Patrim&ocirc;nio Pessoal Livre.","Alerta - Aimaro","$('#nrpatlvr','#'+'"+nomeForm+"').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}	
		
		if (inpessoa != 1 && (nrperger != "" && validaNumero(nrperger,true,0,0))) {
			hideMsgAguardo();
			showError("error","N&atilde;o pode ser informado nenhuma Percep&ccedil;&atilde;o Geral.","Alerta - Aimaro","$('#nrperger','#'+'"+nomeForm+"').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
	
	}

	// Executa o script de valida��o dos dados do rating atrav�s de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "includes/rating/rating_valida_dados.php",
		data: {
			nrdconta: nrdconta,			
			nrgarope: nrgarope,
			nrinfcad: nrinfcad,
			nrliquid: nrliquid,
			nrpatlvr: nrpatlvr,			
			nrperger: nrperger,
			operacao: operacao,
			inprodut: inprodut,
			inpessoa: inpessoa,
			vlprodut: vlprodut,
			redirect: "script_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				// PRJ 438 - Ajuste pra esconder o form apenas em caso de nenhuma critica
				if (response.indexOf('showError("error"') == -1) {
					$('#divFormRating', '#frmNovoLimite').hide();
				}
                eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	}); 
}

/**
 * Autor: Bruno Luiz katzjarowski - Mout's
 * bruno - prj 438 - tela rating
 * @param aux_data cadastrar_novo_limite.php -> linha 358
 */
function atualizarDadosRating(aux_data, fncSucesso){
    showMsgAguardo("Aguarde, atualizando dados do rating ...");
    fncRatingSuccess = fncSucesso;
	$.ajax({
		type: "POST", 
		url: UrlSite + "includes/rating/rating_atualiza_dados.php",
		data: aux_data,		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
}

/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * bruno - prj 438 - sprint 7 - tela rating
 */
function getDadosRating(){
    $.ajax({
		type: "POST", 
		url: UrlSite + "telas/atenda/limite_credito/rating_buscar_dados.php", 
        data: {
            nrdconta: var_globais.nrdconta,
            redirect: "script_ajax"
        },
        dataType: 'json',
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
            atualizarCampoNrinfcad(response.rating);
		}				
	});	
}

//bruno - prj 438 - sprint 7 - tela rating
function atualizarCampoNrinfcad(rating){
    $('#nrinfcad',"#frmNovoLimite").val(rating.nrinfcad);
    $('#nrinfcad',"#frmNovoLimite").trigger('change');
    
    $('#nrpatlvr',"#frmNovoLimite").val(rating.nrpatlvr);
    $('#nrpatlvr',"#frmNovoLimite").trigger('change');

    $('#nrperger',"#frmNovoLimite").val(rating.nrperger);
    $('#nrperger',"#frmNovoLimite").trigger('change');

    if(aux_opcaoAtiva == "ALTERAR"){
        /* 036 */
        if (aux_cdcooper == 3 || var_globais.habrat == 'N') {
          atualizarCamposRating(aux_limites.pausado);
        }
        /* 036 */
    }
}

// Função que formata a pagina Efetivar
function formataEfetivar() {

	$('#divConteudoOpcao').css({
        'width': '500px'
    });

	$('input, select', '#frmEfetivar').desabilitaCampo();		

	// rotulo
	rNrctrlim = $('label[for="nrctrlim"]', '#frmEfetivar');
    rVllimite = $('label[for="vllimite"]', '#frmEfetivar');
    rCddlinha = $('label[for="cddlinha"]', '#frmEfetivar');
    rDataterm = $('label[for="dataterm"]', '#frmEfetivar');
    rNivrisco = $('label[for="nivrisco"]', '#frmEfetivar');
    rDsdtxfix = $('label[for="dsdtxfix"]', '#frmEfetivar');

    rNivrisco.addClass('rotulo').css({ 'width': '130px' });
    rDataterm.addClass('rotulo-linha').css({ 'width': '150px' });
    rNrctrlim.addClass('rotulo').css({ 'width': '130px' });
    rVllimite.addClass('rotulo-linha').css({ 'width': '150px' });
    rCddlinha.addClass('rotulo').css({ 'width': '130px' });
    rDsdtxfix.addClass('rotulo-linha').css({ 'width': '40px' });
	
	// campos
    cNrctrlim = $('#nrctrlim', '#frmEfetivar');
    cVllimite = $('#vllimite', '#frmEfetivar');
    cCddlinha = $('#cddlinha', '#frmEfetivar');
    cDataterm = $('#dataterm', '#frmEfetivar');
    cNivrisco = $('#nivrisco', '#frmEfetivar'); 
    cDsdtxfix = $('#dsdtxfix', '#frmEfetivar');

    cNrctrlim.addClass('contrato').css({ 'width': '70px' });
    cVllimite.addClass('moeda').css({ 'width': '100px' });
    cCddlinha.css({ 'width': '180px' });
	cDataterm.css({ 'width': '70px' });
    cNivrisco.css({ 'width': '70px' });
    cDsdtxfix.css({ 'width': '100px' });

    $('#btVoltar', '#frmEfetivar').unbind('click').bind('click',function(e){
    	e.preventDefault();
		acessaTela('@');

		return false;
	});

	$('#btContinuar', '#frmEfetivar').unbind('click').bind('click',function(e){
		e.preventDefault();
        showConfirmacao('Deseja confirmar novo ' + strTitRotinaLC + '?',
                        'Confirmação - Aimaro',
                        'efetivarLimiteCredito()',
                        "blockBackground(parseInt($('#divRotina').css('z-index')))"
                        ,'sim.gif','nao.gif');
        return false;
	});

	layoutPadrao();
}

function setDadosEfetivar() {

	var dataTermino = calcularDataTermino();
		
    $("#nrctrlim", "#frmEfetivar").val(aux_limites.pausado.nrctrlim);
    $("#vllimite", "#frmEfetivar").val(aux_limites.pausado.vllimite);
    $("#cddlinha", "#frmEfetivar").val(aux_limites.pausado.cddlinha + ' ' + aux_limites.pausado.dsdlinha);
    $("#dataterm", "#frmEfetivar").val(dataTermino);
	$("#nivrisco", "#frmEfetivar").val(aux_limites.pausado.nivrisco);
	$("#dsdtxfix", "#frmEfetivar").val(aux_limites.pausado.txjurfix + '% + TR');
	
}

/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 06/12/2018
 */
function abrirTelaDemoLimiteCredito(abrir){
    if(typeof abrir == 'undefined'){
        abrir = false;
    }

    if(abrir){
        $('#divDadosAvalistas','#'+nomeForm).hide();
        $('#divDemoLimiteCredito','#'+nomeForm).show();

        formatarCamposDemoLimiteCredito();

    }else{
        $('#divDadosAvalistas','#'+nomeForm).show();
        $('#divDemoLimiteCredito','#'+nomeForm).hide();
    }
}

// PRJ 438 - Sprint 7
function telefone(fone){
	if(fone != null){
		fone = fone.replace(/\D/g,"");                 //Remove tudo o que não é dígito
		if (fone.length < 10 || fone.length > 11)
			return '';
		fone = fone.replace(/^(\d\d)(\d)/g,"($1) $2"); //Coloca parênteses em volta dos dois primeiros dígitos
		fone = fone.replace(/(\d{4})(\d)/,"$1-$2");    //Coloca hífen entre o quarto e o quinto dígitos
		return fone;
	} else {
		return '';
	}
}

// PRJ 438
function calcularDataTermino(){

	var qtdiavig = isNaN(parseInt(aux_limites.pausado.qtdiavig)) ? 0 : parseInt(aux_limites.pausado.qtdiavig);
	
	var dia = aux_dtmvtolt.substr(0, 2);
    var mes = aux_dtmvtolt.substr(3, 2);
    var ano = aux_dtmvtolt.substr(6, 4);

	var dtmvtolt = new Date(mes + "/" + dia + "/" + ano);

    dtmvtolt.setDate(dtmvtolt.getDate() + qtdiavig);
    
    dia = ("0" + dtmvtolt.getDate()).slice(-2);
    mes = ("0" + (dtmvtolt.getMonth() + 1)).slice(-2);
    ano = dtmvtolt.getFullYear();

    if (dia == null || mes == null || ano == null){
    	return '';
    }
    return dia + '/' + mes + '/' + ano;
}

function showConfirmacaoRenovar(){

	showConfirmacao('Deseja renovar o ' + strTitRotinaLC + ' atual?',
            'Confirmação - Aimaro',
            'validaAdesaoValorProduto(\'renovarLimiteAtual('+aux_limites.ativo.nrctrlim+')\','+aux_limites.ativo.vllimite+')',
            "blockBackground(parseInt($('#divRotina').css('z-index')))",
            'sim.gif','nao.gif');	
}

// Função que formata a pagina dados do limite de crédito
function formataDadosLimiteCredito() {

	$('input, select', '#frmDadosLimiteCredito').desabilitaCampo();		

	// rotulo
    rVllimite = $('label[for="vllimite"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rDtmvtolt = $('label[for="dtmvtolt"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rCddlinha = $('label[for="cddlinha"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rDtfimvig = $('label[for="dtfimvig"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rNrctrlim = $('label[for="nrctrlim"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rQtdiavig = $('label[for="qtdiavig"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rDsencfi1 = $('label[for="dsencfi1"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rDsencfi2 = $('label[for="dsencfi2"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rDsencfi3 = $('label[for="dsencfi3"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rDssitlli = $('label[for="dssitlli"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rDtcanlim = $('label[for="dtcanlim"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rNmoperad = $('label[for="nmoperad"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rNmopelib = $('label[for="nmopelib"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rFlgenvio = $('label[for="flgenvio"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rDstprenv = $('label[for="dstprenv"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rQtrenova = $('label[for="qtrenova"]', '#' + nomeForm + ' #divDadosLimiteCredito');
    rDtrenova = $('label[for="dtrenova"]', '#' + nomeForm + ' #divDadosLimiteCredito');
	rDtultmaj = $('label[for="dtultmaj"]', '#' + nomeForm + ' #divDadosLimiteCredito');

    rVllimite.addClass('rotulo').css({ 'width': '126px' });
    rDtmvtolt.addClass('rotulo-linha').css({ 'width': '110px' });
    rCddlinha.addClass('rotulo').css({ 'width': '126px' });
    rDtfimvig.addClass('rotulo-linha').css({ 'width': '110px' });
    rNrctrlim.addClass('rotulo').css({ 'width': '126px' });
    rQtdiavig.addClass('rotulo-linha').css({ 'width': '210px' });
    rDsencfi1.addClass('rotulo').css({ 'width': '126px' });
    rDsencfi2.addClass('rotulo').css({ 'width': '126px' });
    rDsencfi3.addClass('rotulo').css({ 'width': '126px' });
    rDssitlli.addClass('rotulo').css({ 'width': '126px' });
    rDtcanlim.addClass('rotulo').css({ 'width': '126px' });
    rNmoperad.addClass('rotulo').css({ 'width': '126px' });
    rNmopelib.addClass('rotulo').css({ 'width': '126px' });
    rFlgenvio.addClass('rotulo').css({ 'width': '126px' });
    rDstprenv.addClass('rotulo').css({ 'width': '126px' });
    rQtrenova.addClass('rotulo-linha');
    rDtrenova.addClass('rotulo-linha').css({ 'width': '91px' });
	rDtultmaj.addClass('rotulo').css({ 'width': '126px' });
	
	// campos
    cVllimite = $('#vllimite', '#' + nomeForm + ' #divDadosLimiteCredito');
    cDtmvtolt = $('#dtmvtolt', '#' + nomeForm + ' #divDadosLimiteCredito');
    cCddlinha = $('#cddlinha', '#' + nomeForm + ' #divDadosLimiteCredito');
    cDtfimvig = $('#dtfimvig', '#' + nomeForm + ' #divDadosLimiteCredito');
    cNrctrlim = $('#nrctrlim', '#' + nomeForm + ' #divDadosLimiteCredito');
    cQtdiavig = $('#qtdiavig', '#' + nomeForm + ' #divDadosLimiteCredito');
    cDsencfi1 = $('#dsencfi1', '#' + nomeForm + ' #divDadosLimiteCredito');
    cDsencfi2 = $('#dsencfi2', '#' + nomeForm + ' #divDadosLimiteCredito');
    cDsencfi3 = $('#dsencfi3', '#' + nomeForm + ' #divDadosLimiteCredito');
    cDssitlli = $('#dssitlli', '#' + nomeForm + ' #divDadosLimiteCredito');
    cDtcanlim = $('#dtcanlim', '#' + nomeForm + ' #divDadosLimiteCredito');
    cNmoperad = $('#nmoperad', '#' + nomeForm + ' #divDadosLimiteCredito');
    cNmopelib = $('#nmopelib', '#' + nomeForm + ' #divDadosLimiteCredito');
    cFlgenvio = $('#flgenvio', '#' + nomeForm + ' #divDadosLimiteCredito');
    cDstprenv = $('#dstprenv', '#' + nomeForm + ' #divDadosLimiteCredito');
    cQtrenova = $('#qtrenova', '#' + nomeForm + ' #divDadosLimiteCredito');
    cDtrenova = $('#dtrenova', '#' + nomeForm + ' #divDadosLimiteCredito');
	cDtultmaj = $('#dtultmaj', '#' + nomeForm + ' #divDadosLimiteCredito');

    cVllimite.css({ 'width': '180px' });
    cDtmvtolt.css({ 'width': '70px' });
    cCddlinha.css({ 'width': '180px' });
    cDtfimvig.css({ 'width': '70px' });
    cNrctrlim.css({ 'width': '80px' });
    cQtdiavig.css({ 'width': '70px' });
    cDsencfi1.css({ 'width': '336px' });
    cDsencfi2.css({ 'width': '336px' });
    cDsencfi3.css({ 'width': '336px' });
    cDssitlli.css({ 'width': '336px' });
    cDtultmaj.css({ 'width': '80px' });
    cDtcanlim.css({ 'width': '70px' });
    cNmoperad.css({ 'width': '336px' });
    cNmopelib.css({ 'width': '336px' });
    cFlgenvio.css({ 'width': '336px' });
    cDstprenv.css({ 'width': '80px' });
    cQtrenova.css({ 'width': '45px' });
    cDtrenova.css({ 'width': '70px' });

}

function setarDadosLimiteCredito(){

	$('#nivrisco', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.nivrisco);
	$('#dsdtxfix', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.dsdtxfix);
	$('#vllimite', '#' + nomeForm + ' #divDadosLimiteCredito').val(number_format(var_globais.vllimite, 2).replace('.',',').replace(',','.'));
	$('#dtmvtolt', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.dtmvtolt);
	$('#cddlinha', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.cddlinha + ' - ' + var_globais.dsdlinha);
	$('#dtfimvig', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.dtfimvig);
	$('#nrctrlim', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.nrctrlim);
	$('#qtdiavig', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.qtdiavig);
	$('#dstprenv', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.dstprenv);
	$('#qtrenova', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.qtrenova);
	$('#dtrenova', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.dtrenova);
	$('#dtcanlim', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.dtcanlim);
	$('#dsencfi1', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.dsencfi1);
	$('#dsencfi2', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.dsencfi2);
	$('#dsencfi3', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.dsencfi3);
	$('#dssitlli', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.dssitlli + (var_globais.dsmotivo.trim() == "" ? "" : " - " + var_globais.dsmotivo));
	$('#dtultmaj', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.dtultmaj);
	$('#nmoperad', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.nmoperad);
	$('#nmopelib', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.nmopelib);
	$('#flgenvio', '#' + nomeForm + ' #divDadosLimiteCredito').val(var_globais.flgenvio);

}

/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 18/12/2018;
 * prj 470 - tela autorizacao
 */
function chamarImpressaoLimiteCredito(flagCancelamento, flgAlteracao){

    if(typeof flagCancelamento == 'undefined'){
        flagCancelamento = false;
    }

    var nrctrlim = flagCancelamento ? var_globais.nrctrlim : $("#nrctrlim", "#frmNovoLimite").val().replace(/\./g, "");
    var vllimite = flagCancelamento ? var_globais.vllimite : $("#vllimite", "#frmNovoLimite").val().replace(/\./g, "");

	var params = {
		nrdconta : nrdconta,
		obrigatoria: 1,
		tpcontrato: (flagCancelamento ? 25 : 29), //Cancelamento == 29, inclusao == 25
		nrcontrato: nrctrlim,
		vlcontrato: vllimite,
        funcaoImpressao: (flagCancelamento ? "carregarImpresso(4,'no','no','"+var_globais.nrctrlim+"');" : "acessaOpcaoAba(8,2,'I');"),
        funcaoGeraProtocolo: "acessaOpcaoAba(8,0,'@');"
	};
	mostraTelaAutorizacaoContrato(params);
}		
 
function setarDadosIdcobertAndObservacao(){

	if (aux_cddopcao == 'P') {
		$("#idcobert", "#frmNovoLimite").val(aux_limites.pausado.idcobope);
		$("#dsobserv", "#frmNovoLimite").val(aux_limites.pausado.dsobserv);
	} else if (aux_cddopcao == 'N' && aux_operacao == 'A') {
		$("#idcobert", "#frmNovoLimite").val(aux_limites.pausado.idcobope);
		$("#dsobserv", "#frmNovoLimite").val(aux_limites.pausado.dsobserv);
	} else if (aux_cddopcao == 'A') {
		$("#idcobert", "#frmNovoLimite").val(aux_limites.ativo.idcobope);
		$("#dsobserv", "#frmNovoLimite").val(aux_limites.ativo.dsobserv);
	}
}

function removeAcento (text) {
    text = text.toLowerCase();
    text = text.replace(new RegExp('[ÁÀÂÃ]','gi'), 'a');
    text = text.replace(new RegExp('[ÉÈÊ]','gi'), 'e');
    text = text.replace(new RegExp('[ÍÌÎ]','gi'), 'i');
    text = text.replace(new RegExp('[ÓÒÔÕ]','gi'), 'o');
    text = text.replace(new RegExp('[ÚÙÛ]','gi'), 'u');
    text = text.replace(new RegExp('[Ç]','gi'), 'c');
    return text;
}
/* [032] */
function ratingMotor() {

    showMsgAguardo('Aguarde, enviando rating ...');
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/limite_credito/rating/ajax_rating.php',
        dataType: "json",
        data: {
            flgopcao: 'analisarRating',
            cdcooper: 1, // na Análise não é necessário retornar.
            btntipo: '1',
            nrcpfcgc: '',
            nrdconta:   var_globais.nrdconta,
            nrcontrato: var_globais.nrctrpro,
            justificativa: '',
            notanova: ''
        }
    }).done(function(jsonResult) {
        hideMsgAguardo();
        if (jsonResult.erro == true) {
            showError('error', jsonResult.msg, 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        } else {
            // [034]
            showError('inform', 'Operação realizada com sucesso', 'Aviso - Aimaro', 'bloqueiaFundo(divRotina);acessaOpcaoAba(10,2,"@");');
            // [034]
        }
        return true;
    }).fail(function(jsonResult) {
        hideMsgAguardo();
        showError('error', 'Falha de comunicação com servidor. Tente novamente.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
    }).always(function() {

    });
}

function btnCreditoRating() {
    /*
    Variáveil nrdconta global no JS ao clicar na linha
    */
    // var nrcontrato = $('#nrctrlim', '#frmDadosLimiteCredito').val().replace(/\./g, "");
    carregarAlteracaoRating(nrdconta, nrctrpro, '1');
}

function carregarAlteracaoRating(nrdconta, contrato, tipoProduto) {
    showMsgAguardo('Aguarde, enviando rating ...');
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/limite_credito/rating/rating.php',
        data: {
            nrdconta: nrdconta,
            contrato: contrato,
            tipoProduto: 1,
            btntipo: '2',
            redirect: 'html_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            if (response.toLowerCase().indexOf("ERRO RATING".toLowerCase()) != -1) {
                showError('error', response, 'Alerta - Aimaro',"unblockBackground()");
            } else {
                $('#divUsoGenerico').html(response);
                exibeRotina($('#divUsoGenerico'));
                layoutPadrao();
                bloqueiaFundo($('#divUsoGenerico'));

                $("#btVoltar", "#divBotoesFormRatingManutencao").unbind('click').bind('click', function() {
                    fechaRotina($('#divUsoGenerico'),divRotina);
                    return false;
                });

                $("#btSalvar", "#divBotoesFormRatingManutencao").unbind('click').bind('click', function() {
                    salvarAlteracaoRating();
                });
            }
            return false;
        }
    });

    return false;
}


function salvarAlteracaoRating() {
    showMsgAguardo('Aguarde, enviando rating ...');
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/limite_credito/rating/ajax_rating.php',
        dataType: "json",
        data: {
            flgopcao: 'salvarRating',
            btntipo: '2',
            nrdconta: $("#divBotoesFormRatingManutencao").data('nrdconta'),
            nrcontrato: $("#divBotoesFormRatingManutencao").data('nrcontrato'),
            justificativa: $("#campoJustificativa", "#frmRatingManutencao").val(),
            notanova: $("#notanova", "#frmRatingManutencao").val()
        }
    }).done(function(jsonResult) {
        hideMsgAguardo();
        if (jsonResult.erro == true) {
            showError('error', jsonResult.msg, 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        } else {
            fechaRotina($('#divUsoGenerico'),divRotina);
        }
        return true;
    }).fail(function(jsonResult) {
        hideMsgAguardo();
        showError('error', 'Falha de comunicação com servidor. Tente novamente.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
    }).always(function() {

    });
}
/* [032] */