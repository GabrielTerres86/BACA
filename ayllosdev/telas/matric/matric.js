/*!
 * FONTE        : matric.js
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 07/06/2010
 * OBJETIVO     : Biblioteca de funções da tela MATRIC
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 000: [11/02/2011] Gabriel Ramirez  (CECRED)	: Aumentado campo do nome para 50 posicoes 
 * 001: [26/04/2011] Rodolpho e Rogerius (DB1)	: Adicionado zoom generico do CEP.  
 * 002: [16/04/2012] Rogérius Militão (DB1) 	: Novo ayout padrão
 * 003: [15/06/2012] Adriano 		  (CECRED)  : Ajustes referente ao projeto GP - Socios Menores 
 * 004: [02/07/2012] Jorge Hamaguchi  (CECRED)  : Alterado funcao imprime(), novo esquema para impressao.
 * 005: [09/08/2013] Lucas Reinert	  (CECRED)  : Incluido campo UF de naturalidade
 * 006: [15/08/2013] Carlos           (CECRED)  : Alteração da sigla PAC para PA
 * 007: [09/05/2014] Douglas          (CECRED)  : Solicitar senha de coordenador quando operação "X"
 * 007: [23/09/2014] Jorge Hamaguchi  (CECRED)  : Ajuste em funcao limpaTela(), retirado atribuicao de valor '' para campo opcao.
 * 009: [28/01/2015] Carlos           (CECRED)  : #239097 Ajustes para cadastro de Resp. legal 0 menor/maior.
 * 010: [12/05/2015] Carlos           (CECRED)  : #271162 Inclusão do botao concluir para salvar o cadastro quando a opção for de Alteração.
 * 011: [09/07/2015] Gabriel          (RKAM)    : Projeto Reformulacao Cadastral.
 * 012: [05/10/2015] Kelvin 		  (CECRED)  : Adicionado nova opção "J" para alteração apenas do cpf/cnpj e removido a possibilidade de
												  alteração pela opção "X", conforme solicitado no chamado 321572 (Kelvin).
 * 013: [03/12/2015] Jaison/Andrino   (CECRED)  : Adicao do campo flserasa na pesquisa generica de BUSCA_CNAE.
 * 014: [15/12/2015] Douglas          (CECRED)  : Ajustado para quando sair do campo CPF, limpar os campos apenas quando a opcao da tela eh "I" (Chamado - 369594)
 * 015: [29/01/2016] Tiago Castro(RKAM)         : Chamados 388971/394261 - Incluido validacao para forcar usuario a clicar no botao prosseguir.
 *												  pois ao teclar ENTER mais de 1 vez era criado mais de uma conta.
 * 015: [18/02/2016] Jorge Hamaguchi  (CECRED)  : Ajuste para pedir senha do coodenador quando for duplicar conta.
 * 015: [29/01/2016] Tiago Castro(RKAM)         : Chamados 388971/394261 - Incluido validacao para forcar usuario a clicar no botao prosseguir.
 *												  Ao teclar ENTER mais de uma vez, era criado mais de uma conta.
 * 016: [10/04/2016] Rafael (RKAM)              : Ajuste para comportamento acertivo quando o site da receita não estiver disponível
 * 018: [20/04/2016] Heitor (RKAM)              : Limitado o campo NRENDERE em 5 posicoes, chamado 435477 
 * 019: [27/04/2016] Gisele (RKAM)              : Incluido  procedimento que verificar qual conexão do banco se é produção sim ou não.
 *                                                se for produção o sistema permanece executando a consulta no site da receita federal, 
 *                                                caso seja outro banco exemplo desenvolvimento a tela não executa consulta da Receita Federal.
 *
 * 014: [15/12/2015] Douglas          (CECRED)  : Ajustado para quando sair do campo CPF, limpar os campos apenas quando a opcao da tela eh "I" (Chamado -
 369594)
 * 015: [17/05/2016] Kelvin 		  (CECRED)  : Adicionado inclusão de nacionalidade, conforme solicitado no chamado 422806. (Kelvin)
 * 016: [06/07/2016] Lucas Ranghetti  (CECRED)  : Alterar campo cCnae para suportar até 7 posicoes. (#481816)
 * 017: [22/07/2016] Maciel 		  (RKAM)  : Ajustes no JS para o conportamento correto da consulta a receita
 * 018: [22/07/2016] Maciel 		  (RKAM)  : Aumento do tempo para consulta na receita federal
 * 019: [10/10/2016] Carlos           (CECRED): #537134 Comentada a consulta automatizada do CPF/CNPJ na receita devido aos constantes
 *                                              bloqueios de acesso.
 * 020: [25/10/2016] Tiago            (CECRED): M310 Tratamento para abertura de conta com CNAE CPF/CPNJ restrito ou proibidos.
 * 021: [08/02/2017] Kelvin           (CECRED): Ajuste realiazado para tratar o chamado 566462. 
 * 022: [03/03/2017] Adriano          (CECRED): Ajuste devido a conversão das rotinas busca_nat_ocupacao, busca_ocupacao (Adriano - SD 614408).
 * 023: [12/04/2017] Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
 * 024: [14/06/2017] Adriano          (CECRED): Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
 *		                                        crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava.
 * 025: [31/07/2017] Odirlei Busana   (AMcom) : Aumentado campo dsnatura de 25 para 50, PRJ339-CRM.	
 * 026: [04/08/2017] Adriano          (CECRED): Ajuste para chamar a package zoom001 na busca de código cnae.
 * 027: [28/08/2017] Kelvin			  (CECRED): Criando opcao de solicitar relacionamento caso cnpj informado esteja cadastrado na cooperativa. (Kelvin)
 * 028: [19/09/2017] Kelvin			  (CECRED): Ajuste no problema ao carregar contas com situacao de cpf diferente de 0. (PRJ339)			                         
 * 028: [25/09/2017] Kelvin			  (CECRED):	Adicionado uma lista de valores para carregar orgao emissor. (PRJ339)			                         
 * 027: [29/09/2017] Adriano          (CECRED): Ajuste para forçar a nacionalidade como 42 - Brasileira ao informar o tp. nacionalidade como 1 - Brasileiro. 
 * 031: [16/10/2017] Kelvin 		  (CECRED): Removendo o campo caixa postal. (PRJ339).
 * 029: [23/10/2017] Odirlei Busana	  (AMcom): Ajustado para chamar a rotina de reposavel legal apos a inclusão devido a 
 *                                             replicação dos dados da pessoa. (PRJ339).

 */

// Definição de algumas variáveis globais 
var cdpactra = 0;  // PA de operador logado
var operacao = ''; // Armazena a operação corrente da tela MATRIC
var nrdconta = ''; // Armazena o Número da Conta/dv
var rowidass = ''; // Armazena a chave do registro
var tppessoa = ''; // Armazena o tipo da pessoa (1 ou 2)
var nrdcontaOld = ''; // Variável auxiliar para guardar o número da conta passada
var operacaoOld = ''; // Variável auxiliar para guardar a operação passada
var nrJanelas = ''; // Armazena o número de janelas para as impressões
var indarrayAvt = ''; // Variável que armazena o procurador que está selecionado na tabela
var semaforo = 0; // Semáforo para não permitir chamar a função controlaOperacao uma atrás da outra
var operProc = ''; // Armazena a operação corrente da rotina procuradores
var nrcpfcgc = ''; // Armazena o cpf corrente da rotina procuradores
var rowidavt = ''; // Armazena a chave do registro de procuradores
var nrdconta_org = 0; // Conta origem para ser duplicada
var hrinicad = 0; // Horario de inicio do cadastro
var XMLContas = "";
 
// Opções que o operador tem acesso na tela MATRIC
var flgAlterar = ''; // Operador possui permissão para Alterar
var flgConsultar = ''; // Permissão para Consultar
var flgIncluir = ''; // Permissão para Incluir
var flgRelatorio = ''; // Permissão para emitir o relatório
var flgNome = ''; // Permissão para alterar o nome
var flgDesvincula = ''; // Permissão para Desvincular
var flgCpfCnpj = ''; // Permissão para alterar o cpf ou o cnpj

// Opções que o operador tem acesso na rotina PROCURADORES da tela MATRIC
var flgAlterarProc = ''; // Permissão para Alterar Procurador
var flgConsultarProc = ''; // Permissão para Consultar Procurador
var flgExcluirProc = ''; // Permissão para Excluir Procurador
var flgIncluirProc = ''; // Permissão para Incluir Procurador
var aux_operacao = ''; // Armazena a operação da tela
var nrdeanos = 0;  // Armazena o número de anos para controlar os botoes
var dtmvtolt = ''; // Armazena a data atual do sistema

var verrespo = false; 				 	// Variável global para indicar se deve validar ou nao os dados dos Resp.Legal na BO55
var permalte = true; 			     	// Está variável sera usada para controlar se a "Alteração/Exclusão/Inclusão - Resp. Legal" deverá ser feita somente na tela contas
var arrayBensMatric = new Array(); 	// Variável global para armazenar os bens dos procuradores
var arrayFilhosAvtMatric = new Array(); // Variável global para armazenar os procuradores
var arrayBackupAvt = new Array(); 		// Array que armazena o arrayFilhosAvtMatric antes de qualquer operação.
var arrayBackupBens = new Array(); 		// Array que armazena o arrayFilhosBensMatric antes de qualquer operação.
var arrayFilhos = new Array(); 			// Variável global para armazenar os responsaveis legais
var arrayBackupFilhos = new Array();    // Array que armazena o arrayFilhos antes de qualquer operação.

//Variaveis que armazenam informações do parcelamento
var dtdebito = '';
var qtparcel = '';
var vlparcel = '';
var msgRetor = '';
var aux_cdrotina = ''; //Armazena a operacao corrente da tela para quando for chamar a rotina procuradores e resp.legal

var outconta = '';

exibeAlerta = false;

$(document).ready(function() {
	// Inicializa algumas variáveis
    idseqttl = 1;
	exibeAlerta = false;
	controlaOperacao();		
	
}); 

function controlaOperacao(novaOp) {
	
    operacao = (typeof novaOp != 'undefined') ? novaOp : operacao;
		
	if (!controlaAcessoOperacoes()) { return false; }	
		
	var mensagem = '';
		
	switch (operacao) {
	
        case 'FC': mensagem = 'Aguarde, buscando dados ...'; break;
		case 'CX': mensagem = 'Aguarde, verificando conta/dv ...'; break;
		case 'CJ': mensagem = 'Aguarde, verificando conta/dv ...'; break;
        case 'CI': mensagem = 'Aguarde, buscando dados ...'; break;
		case 'CA': mensagem = 'Aguarde, verificando conta/dv ...'; break;
		case 'CD': mensagem = 'Aguarde, verificando conta/dv ...'; break;
		
        case 'IC': showConfirmacao('Deseja cancelar inclus&atilde;o?', 'Confirma&ccedil;&atilde;o - Matric', 'estadoInicial()', '', 'sim.gif', 'nao.gif'); semaforo--; return false; break;
        case 'XC': showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Matric', 'estadoInicial()', '', 'sim.gif', 'nao.gif'); semaforo--; return false; break;
        case 'AC': showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Matric', 'estadoInicial()', '', 'sim.gif', 'nao.gif'); semaforo--; return false; break;
        case 'DC': showConfirmacao('Deseja cancelar desvinculação?', 'Confirma&ccedil;&atilde;o - Matric', 'estadoInicial()', '', 'sim.gif', 'nao.gif'); semaforo--; return false; break;
		
		case 'IV': manterRotina(); semaforo--; return false; break;
		case 'XV': manterRotina(); semaforo--; return false; break;
		case 'JV': manterRotina(); semaforo--; return false; break;
		case 'AV': manterRotina(); semaforo--; return false; break;
        case 'AR': manterRotina(); semaforo--; return false; break;
		case 'DV': manterRotina(); semaforo--; return false; break;
		
		case 'VI': manterRotina(); semaforo--; return false; break;		
		case 'VX': manterRotina(); semaforo--; return false; break;
		case 'VJ': manterRotina(); semaforo--; return false; break;
		case 'VA': manterRotina(); semaforo--; return false; break;
		case 'VD': manterRotina(); semaforo--; return false; break;
				
		case 'CR': verificaRelatorio(); semaforo--; return false; break;
		case 'PI': //Valida dthabmen, inhabmen, dtnascto
				   manterRotina(); 
				   semaforo--;
				   return false; 
				   break;	
		case 'PA': //Valida dthabmen, inhabmen, dtnascto
				   manterRotina(); 
				   semaforo--;
				   return false; 
				   break;			   
		
        default: mensagem = 'Aguarde, abrindo tela ...'; break;
	}
    showMsgAguardo(mensagem);
			
	// Carrega dados da conta através de ajax
	$.ajax({		
        type: 'POST',
		dataType: 'html',
        url: UrlSite + 'telas/matric/principal.php',
        data:
				{ 
					nmdatela: 'MATRIC',
					nmrotina: '',
					nrdconta: nrdconta,	
					operacao: operacao,
					redirect: 'script_ajax' 
				},
        error: function (objAjax, responseError, objExcept) {
					semaforo--;
					hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Matric', '$(\'#nrdconta\',\'#frmCabMatric\').focus()');
				},
        success: function (response) {
					semaforo--;
					hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
						try {
							$('#divMatric').html(response);
							
                    if ($("#dtnasctl", "#frmFisico").val() == "" && $('input[name="inpessoa"]:checked', '#frmCabMatric').val() == 1) {
								$('#divMatric').html(response);
								return false;
							}
							
							return false;
							
                } catch (error) {
							hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
						}
					} else {
						try {
                    eval(response);
							controlaFoco();
                } catch (error) {
							hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
						}
					}
				}
	}); 
}

function manterRotina() {
		
	hideMsgAguardo();		
	var mensagem = '';
		
	switch (operacao) {	
	
		case 'VI': mensagem = 'Aguarde, incluindo ...'; break;                                                              
		case 'VX': mensagem = 'Aguarde, alterando ...'; break;                                                              
		case 'VJ': mensagem = 'Aguarde, alterando ...'; break;                                                              
		case 'VA': mensagem = 'Aguarde, alterando ...'; break;
		case 'VD': mensagem = 'Aguarde, desvinculando ...'; break;
		case 'IV': mensagem = 'Aguarde, validando inclus&atilde;o ...'; break;
		case 'XV': mensagem = 'Aguarde, validando altera&ccedil;&atilde;o ...'; break;
		case 'JV': mensagem = 'Aguarde, validando altera&ccedil;&atilde;o ...'; break;
		case 'AV': mensagem = 'Aguarde, validando altera&ccedil;&atilde;o ...'; break;
        case 'AR': mensagem = 'Aguarde, validando altera&ccedil;&atilde;o ...'; break;
		case 'DV': mensagem = 'Aguarde, validando desvincula&ccedil;&atilde;o ...'; break;
		case 'PI': mensagem = 'Aguarde, validando alteração ...'; break;	
		case 'PA': mensagem = 'Aguarde, validando alteração ...'; break;	
		case 'CD': mensagem = 'Aguarde, verificando CPF/CNPJ ...'; break;
		default: return false; break;
		
	}
	
    showMsgAguardo(mensagem);
	
    nrdconta = normalizaNumero($('#nrdconta', '#frmCabMatric').val());
    cdagepac = $('#cdagepac', '#frmCabMatric').val();
    rowidass = $('#rowidass', '#frmCabMatric').val();
    inpessoa = $('input[name="inpessoa"]:checked', '#frmCabMatric').val();
	
	// Obtem o nome do formulario
    nomeForm = (inpessoa == 1) ? 'frmFisico' : 'frmJuridico';
	
	//-------------------------------------------------------------------------------------------------
	// [ X ] - Caso for operacao de alteração de nome 
	//-------------------------------------------------------------------------------------------------
	// Se for chamado a partir do botao da tela
	// temos que executar a solicitação de senha do coordenador
	if (operacao == 'VX' || operacao == 'VJ') {
		mostrarRotina(operacao);
	}
	// Se for chamda pelo manter_resultado.php que realiza a gravação
	//executamos o manter Outros()
	if (operacao == 'XV' || operacao == 'JV') {
		manterOutros(nomeForm);
	}
	
	
	//-------------------------------------------------------------------------------------------------
	// [ D ] - Caso for operacao de desvinculação
	//-------------------------------------------------------------------------------------------------
    if ((operacao == 'VD') || (operacao == 'DV')) {
		
        nmprimtl = normalizaTexto($('#nmprimtl', '#' + nomeForm).val());
        nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#' + nomeForm).val());
				
		$.ajax({		
			type: 'POST',
			url: UrlSite + 'telas/matric/manter_desvincular.php', 		
			data: {
				nrdconta: nrdconta,
				inpessoa: tppessoa,
				rowidass: rowidass,
				cdagepac: cdagepac,
				nmprimtl: nmprimtl,
				nrcpfcgc: nrcpfcgc,
				operacao: operacao,
				redirect: 'script_ajax'
			}, 
            error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
			},
            success: function (response) {
				try {
					eval(response);
					return false;
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}
		});				
	}	
	
	
	//-------------------------------------------------------------------------------------------------
	// [ I | A ] - Caso for operacao for inclusão ou alteração e for PF - Pessoa Física 
	//-------------------------------------------------------------------------------------------------
    if ((in_array(operacao, ['VI', 'IV', 'VA', 'AV','AR', 'PI', 'PA'])) && (inpessoa == 1)) {
	
        cdtipcta = $('#cdtipcta', '#frmFisico').val();
        nmprimtl = normalizaTexto($('#nmprimtl', '#frmFisico').val());
        nmttlrfb = normalizaTexto($('#nmttlrfb', '#frmFisico').val());
        nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#frmFisico').val());
        dtcnscpf = $('#dtcnscpf', '#frmFisico').val();
        nrdocptl = normalizaTexto($('#nrdocptl', '#frmFisico').val());
        cdoedptl = normalizaTexto($('#cdoedptl', '#frmFisico').val());
        dtemdptl = $('#dtemdptl', '#frmFisico').val();
        tpnacion = $('#tpnacion', '#frmFisico').val();
        cdnacion = $('#cdnacion', '#frmFisico').val();
        dtnasctl = $('#dtnasctl', '#frmFisico').val();
        dsnatura = $('#dsnatura', '#frmFisico').val();
        inhabmen = $('#inhabmen', '#frmFisico').val();
        dthabmen = $('#dthabmen', '#frmFisico').val();
        cdestcvl = $('#cdestcvl', '#frmFisico').val();
        nmconjug = normalizaTexto($('#nmconjug', '#frmFisico').val());
        cdempres = $('#cdempres', '#frmFisico').val()
        nrcadast = normalizaNumero($('#nrcadast', '#frmFisico').val());
        cdocpttl = $('#cdocpttl', '#frmFisico').val();
        rowidcem = $("#rowidcem", "#frmFisico").val();
        dsdemail = $("#dsdemail", "#frmFisico").val();
        nrdddres = $("#nrdddres", "#frmFisico").val();
        nrtelres = $("#nrtelres", "#frmFisico").val();
        nrdddcel = $("#nrdddcel", "#frmFisico").val();
        nrtelcel = $("#nrtelcel", "#frmFisico").val();
        cdopetfn = $("#cdopetfn", "#frmFisico").val();
        nmmaettl = normalizaTexto($('#nmmaettl', '#frmFisico').val());
        nmpaittl = normalizaTexto($('#nmpaittl', '#frmFisico').val());
        dsendere = $('#dsendere', '#frmFisico').val();
        nrendere = normalizaNumero($('#nrendere', '#frmFisico').val());
        complend = $('#complend', '#frmFisico').val();
        nmbairro = normalizaTexto($('#nmbairro', '#frmFisico').val());
        nrcepend = normalizaNumero($('#nrcepend', '#frmFisico').val());
        nmcidade = normalizaTexto($('#nmcidade', '#frmFisico').val());
        dtadmiss = $('#dtadmiss', '#frmFisico').val();
        dtdemiss = $('#dtdemiss', '#frmFisico').val();
        cdmotdem = $('#cdmotdem', '#frmFisico').val();
        cdsitcpf = $('#cdsitcpf option:selected', '#frmFisico').val();
        tpdocptl = $('#tpdocptl option:selected', '#frmFisico').val();
        cdufdptl = $('#cdufdptl option:selected', '#frmFisico').val();
        cdufnatu = $('#cdufnatu option:selected', '#frmFisico').val();
        cdufende = $('#cdufende option:selected', '#frmFisico').val();
        cdsexotl = $('input[name="cdsexotl"]:checked', '#frmFisico').val();
        dsproftl = $('#dsproftl', '#frmFisico').val();
        nmmaeptl = $('#nmmaeptl', '#frmFisico').val();
        nmpaiptl = $('#nmpaiptl', '#frmFisico').val();
        nmsegntl = $('#nmsegntl', '#frmFisico').val();
        inconrfb = $('#inconrfb', '#frmFisico').val();
        idorigee = $('#idorigee', '#frmFisico').val();
		// Indicador se esta conectado no banco de producao
        inbcprod = $('#inbcprod', '#frmCabMatric').val();
		
        if (operacao == 'AR'){
            verrespo = true;
        }
        
		//Normalilza os campos de valor
        vlparcel = number_format(parseFloat(vlparcel.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
						
		//Valida CPF	
        if (!validaCpfCnpj(nrcpfcgc, 1) && operacao == 'IV') {
			hideMsgAguardo();
            showError('error', 'CPF inv&aacute;lido.', 'Alerta - Ayllos', 'focaCampoErro(\'nrcpfcgc\',\'frmFisico\');');
			return false; 
		}
		// Somente executa se esta conectado no banco de producao
        if (inbcprod == 'S' && dtcnscpf == "" && operacao == 'IV') {
			hideMsgAguardo();
            showError('error', 'Deve ser feita a consulta na RFB.', 'Alerta - Ayllos', 'focaCampoErro(\'nrcpfcgc\',\'frmFisico\');');
			return false; 
		}
		
        if (cdsitcpf == "" && operacao == 'IV') {
			hideMsgAguardo();
            showError('error', 'CPF/CNPJ com situa&ccedil&atilde;o diferente de regular. Cadastro n&atilde;o permitido.', 'Alerta - Ayllos', 'focaCampoErro(\'nrcpfcgc\',\'frmFisico\');');
			return false; 
		}
							
        if (dsdemail != '') {
            dsdemail = removeAcentos(removeCaracteresInvalidos(dsdemail));
        }

        if (nmprimtl != '') {
            nmprimtl = removeAcentos(removeCaracteresInvalidos(nmprimtl));
        }

        if (nmconjug != '') {
            nmconjug = removeAcentos(removeCaracteresInvalidos(nmconjug));
        }

        if (nmsegntl != '') {
            nmsegntl = removeAcentos(removeCaracteresInvalidos(nmsegntl));
        }

        if (nmttlrfb != '') {
            nmttlrfb = removeAcentos(removeCaracteresInvalidos(nmttlrfb));
        }

		$.ajax({		
			type: 'POST',
			url: UrlSite + 'telas/matric/manter_fisico.php', 		
			data: {
				nrdconta: nrdconta, cdagepac: cdagepac, inpessoa: inpessoa,
				nmprimtl: nmprimtl, nrcpfcgc: nrcpfcgc, dtcnscpf: dtcnscpf,
				cdsitcpf: cdsitcpf, tpdocptl: tpdocptl, nrdocptl: nrdocptl,
				cdoedptl: cdoedptl, cdufdptl: cdufdptl, dtemdptl: dtemdptl,
				tpnacion: tpnacion, cdnacion: cdnacion, dtnasctl: dtnasctl,
				dsnatura: dsnatura, cdsexotl: cdsexotl, cdestcvl: cdestcvl,
				nmconjug: nmconjug, cdempres: cdempres, nrcadast: nrcadast,
				cdocpttl: cdocpttl, rowidcem: rowidcem, dsdemail: dsdemail, 
				nrdddres: nrdddres, nrtelres: nrtelres, nrdddcel: nrdddcel, 
				nrtelcel: nrtelcel, cdopetfn: cdopetfn, nmmaettl: nmmaettl, 
				nmpaittl: nmpaittl, dsendere: dsendere, nrendere: nrendere, 
				complend: complend, nmbairro: nmbairro, nrcepend: nrcepend, 
				nmcidade: nmcidade, cdufende: cdufende, dtadmiss: dtadmiss, 
				dtdemiss: dtdemiss, cdmotdem: cdmotdem, rowidass: rowidass, 
				operacao: operacao, qtparcel: qtparcel, dtdebito: dtdebito, 
				vlparcel: vlparcel, nmttlrfb: nmttlrfb, dsproftl: dsproftl, 
				nmmaeptl: nmmaeptl, nmpaiptl: nmpaiptl,	nmsegntl: nmsegntl, 
				cdtipcta: cdtipcta, inhabmen: inhabmen, dthabmen: dthabmen, 
				verrespo: verrespo, permalte: permalte, cdufnatu: cdufnatu, 
				inconrfb: inconrfb, hrinicad: hrinicad, arrayFilhos: arrayFilhos, 
				idorigee: idorigee,
				redirect: 'script_ajax'
			}, 
            error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				
			},
            success: function (response) {
				try {
					eval(response);
					return false;
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}				
		});	
	}
	
	
	//-------------------------------------------------------------------------------------------------
	// [ I | A ] - Caso for operacao for inclusão ou alteração e for PJ - Pessoa Jurídica
	//-------------------------------------------------------------------------------------------------
    if ((in_array(operacao, ['VI', 'IV', 'VA', 'AV'])) && (inpessoa == 2)) {
				
        cdtipcta = $('#cdtipcta', '#frmJuridico').val();
        nmprimtl = normalizaTexto($('#nmprimtl', '#frmJuridico').val()).replace("&", "e");;
        nmfansia = normalizaTexto($('#nmfansia', '#frmJuridico').val()).replace("&", "e");;
        nmttlrfb = normalizaTexto($('#nmttlrfb', '#frmJuridico').val()).replace("&", "e");
        nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#frmJuridico').val());
        dtcnscpf = $('#dtcnscpf', '#frmJuridico').val();
        nrinsest = normalizaNumero($('#nrinsest', '#frmJuridico').val());
        natjurid = $('#natjurid', '#frmJuridico').val();
        dtiniatv = $('#dtiniatv', '#frmJuridico').val();
        cdseteco = $('#cdseteco', '#frmJuridico').val();
        nrdddtfc = $('#nrdddtfc', '#frmJuridico').val();
        nrtelefo = normalizaNumero($('#nrtelefo', '#frmJuridico').val());
        cdrmativ = $('#cdrmativ', '#frmJuridico').val();
        rowidcem = $("#rowidcem", "#frmJuridico").val();
        dsdemail = $("#dsdemail", "#frmJuridico").val();
        cdcnae = $('#cdcnae', '#frmJuridico').val();
        dsendere = $('#dsendere', '#frmJuridico').val();
        nrendere = normalizaNumero($('#nrendere', '#frmJuridico').val());
        complend = $('#complend', '#frmJuridico').val();
        nmbairro = normalizaTexto($('#nmbairro', '#frmJuridico').val());
        nrcepend = normalizaNumero($('#nrcepend', '#frmJuridico').val());
        nmcidade = normalizaTexto($('#nmcidade', '#frmJuridico').val());
        cdufende = $('#cdufende', '#frmJuridico').val();
        dtadmiss = $('#dtadmiss', '#frmJuridico').val();
        dtdemiss = $('#dtdemiss', '#frmJuridico').val();
        cdmotdem = $('#cdmotdem', '#frmJuridico').val();
        cdsitcpf = $('#cdsitcpf option:selected', '#frmJuridico').val();
        tppessoa = (in_array(operacao, ['VI', 'IV'])) ? 2 : tppessoa;
        inconrfb = $('#inconrfb', '#frmJuridico').val();
        idorigee = $('#idorigee', '#frmJuridico').val();
        nrlicamb = $('#nrlicamb', '#frmJuridico').val();
		// Indicador se estã conectado no banco de producao
        inbcprod = $('#inbcprod', '#frmCabMatric').val();
					
		//Normalilza os campos de valor
        vlparcel = number_format(parseFloat(vlparcel.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
		
		//Valida CNPJ
        if (!validaCpfCnpj(nrcpfcgc, 2) && operacao == 'IV') {
			hideMsgAguardo();
            showError('error', 'CNPJ inv&aacute;lido.', 'Alerta - Ayllos', 'focaCampoErro(\'nrcpfcgc\',\'frmJuridico\');');
			return false; 
		}	
		// Somente executa se esta conectado no banco de producao	
        if (inbcprod == 'S' && dtcnscpf == "" && operacao == 'IV') {
			hideMsgAguardo();
            showError('error', 'Deve ser feita a consulta na RFB.', 'Alerta - Ayllos', 'focaCampoErro(\'nrcpfcgc\',\'frmFisico\');');
			return false; 
		}	
		
        if (cdsitcpf == "" && operacao == 'IV') {
			hideMsgAguardo();
            showError('error', 'CPF/CNPJ com situa&ccedil&atilde;o diferente de regular. Cadastro n&atilde;o permitido.', 'Alerta - Ayllos', 'focaCampoErro(\'nrcpfcgc\',\'frmJuridico\');');
			return false; 
		}
			
        if (dsdemail != '') {
            dsdemail = removeAcentos(removeCaracteresInvalidos(dsdemail));
        }

        if (nmprimtl != '') {
            nmprimtl = removeAcentos(removeCaracteresInvalidos(nmprimtl));
        }

        if (nmfansia != '') {
            nmfansia = removeAcentos(removeCaracteresInvalidos(nmfansia));
        }

        if (nmttlrfb != '') {
            nmttlrfb = removeAcentos(removeCaracteresInvalidos(nmttlrfb));
        }

		$.ajax({		
			type: 'POST',
			url: UrlSite + 'telas/matric/manter_juridico.php', 		
			data: {
				nrdconta: nrdconta, cdagepac: cdagepac, inpessoa: tppessoa,
				nmprimtl: nmprimtl, nmfansia: nmfansia, nrcpfcgc: nrcpfcgc,
				dtcnscpf: dtcnscpf, nrinsest: nrinsest, natjurid: natjurid,
				dtiniatv: dtiniatv, cdseteco: cdseteco, nrdddtfc: nrdddtfc,
				nrtelefo: nrtelefo, cdrmativ: cdrmativ, rowidcem: rowidcem,
				dsdemail: dsdemail, dsendere: dsendere, nrendere: nrendere, 
				complend: complend, nmbairro: nmbairro, nrcepend: nrcepend, 
				nmcidade: nmcidade, cdufende: cdufende, dtadmiss: dtadmiss, 
				dtdemiss: dtdemiss, cdmotdem: cdmotdem, cdsitcpf: cdsitcpf, 
				rowidass: rowidass, qtparcel: qtparcel,	dtdebito: dtdebito, 
				vlparcel: vlparcel, operacao: operacao, cdtipcta: cdtipcta, 
				cdcnae: cdcnae, inconrfb: inconrfb, nmttlrfb: nmttlrfb, 
				hrinicad: hrinicad, arrayFilhos: arrayFilhos,  
				arrayFilhosAvtMatric: arrayFilhosAvtMatric, 
				arrayBensMatric: arrayBensMatric, idorigee: idorigee,
				nrlicamb: nrlicamb,
				redirect: 'script_ajax'
			}, 
            error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
			},
            success: function (response) {
				try {
					eval(response);
					return false;
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}				
		});			        
	}                                 
}       	

function verificaCpfCgcRespSocial(inpessoa, nrcpfcgc) {
    
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/matric/valida_responsabilidade_social.php',
        data: {
            inpessoa: inpessoa,
            nrcpfcgc: nrcpfcgc,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
        },
        success: function (response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
            }
        }
    });

    return false;
}

//Função criado para resolver problema de mensagens no IE.
function estadoInicial() {

    showMsgAguardo('Aguarde, carregando ...');
    setTimeout('limpaTela()', 150);
	
	return false;
	
}

function limpaTela(oldVal) {
		
	fechaRotina($('#divRotina'));
		
    showMsgAguardo('Aguarde, carregando ...');
    setTimeout('', 900);
	
	operacao = '';
	nrdconta = '';
	rowidass = '';
    tppessoa = 1;
				
    $("input,select", "#divMatric").removeClass("campoErro");
	
	$('#frmCabMatric').limpaFormulario();
    $('#frmJuridico').css('display', 'none').limpaFormulario();
    $('#frmFisico').css('display', 'block').limpaFormulario();

    $('#opcao', '#frmCabMatric').val('FC').habilitaCampo();
    $('#nrdconta', '#frmCabMatric').val('').habilitaCampo();
		
	formataCabecalho();
	controlaBotoes();	
	formataPessoaFisica();
	formataPessoaJuridica();
	controlaPesquisas();
	hideMsgAguardo();
	controlaFoco();
	
}

function bloqueiaCabecalho() {
	
	// Definindo variaveis
    var valorPAC = normalizaNumero($('#cdagepac', '#frmCabMatric').val());
    var descPAC = $('#nmresage', '#frmCabMatric').val();
	
	// Verifico se o PA está informado
    if (valorPAC == 0) {
        showError('error', 'PA n&atilde;o cadastrado.', 'Alerta - Matric', 'focaCampoErro(\'cdagepac\',\'frmCabMatric\');');
		return false;
	}

	//Verifico a descrição do PA
    if (descPAC == '') {
        showError('error', 'PA inv&aacute;lido.', 'Alerta - Matric', 'focaCampoErro(\'cdagepac\',\'frmCabMatric\');');
		return false;
	}
	
    if ($('#cdagepac', '#frmCabMatric').hasClass('campoErro')) { return false; }
	
	// Se o PA é diferente de zero, então bloqueia o cabecalho
    $('input:text,input:radio,select', '#frmCabMatric').removeClass('campoErro').desabilitaCampo();
	
    $('a', '#frmCabMatric').unbind('click').css('cursor', 'auto');
	
	return true;	
	
}

function processoIncluir() {
				
	// Libera os devidos campos do Cabeçalho
    $('#cdagepac,#pessoaFi,#pessoaJu', '#frmCabMatric').habilitaCampo();
	
	// O nr. conta vem vazio, portanto colocar o antigo valor e desabilita o campo
    $('#nrdconta', '#frmCabMatric').desabilitaCampo();
    $('#opcao', '#frmCabMatric').desabilitaCampo();
			
	// Sugerir PA de trabalho
    $("#cdagepac", "#frmCabMatric").val(cdpactra).focus();
	
	// Sugerir PF
    $('#pessoaFi', '#frmCabMatric').attr('checked', true);
	
	// Controla exibição do formulário Físico
    $('#pessoaFi', '#frmCabMatric').click(function () {
		
        if ($('#frmFisico').css('display') == 'none') {
            $('#frmJuridico').css('display', 'none');
            $('#frmFisico').css('display', 'block');
		} 
				
	});	
	
	// Controla exibição do formulário Jurídico
    $('#pessoaJu', '#frmCabMatric').click(function () {
				
        if ($('#frmJuridico').css('display') == 'none') {
            $('#frmFisico').css('display', 'none');
            $('#frmJuridico').css('display', 'block');
		} 
				
	});
		
	controlaPesquisas();	
	return false;
	
}

function controlaAcessoOperacoes() {
				
	if (operacao == '') {
        $('#nrdconta', '#frmCabMatric').val('');
		nrdconta = 0;
		semaforo--;
		return true;
	} 
	
	nrdcontaOld = nrdconta;	
		
    if (in_array(operacao, ['VX', 'XV', 'XC'])) {
		 operacaoOld = 'CX'; 
    } else if (in_array(operacao, ['VJ', 'JV', 'JC'])) {
		operacaoOld = 'CJ'; 
    } else if (in_array(operacao, ['VI', 'IV', 'IC'])) {
		operacaoOld = 'CI'; 
    } else if (in_array(operacao, ['VA', 'AV', 'AC'])) {
		operacaoOld = 'CA'; 
    } else if (in_array(operacao, ['VD', 'DV', 'DC'])) {
		operacaoOld = 'CD'; 
    } else {
		operacaoOld = operacao; 
	}
	
	// Verifica permissões de acesso	
    if ((operacao == 'CA') && (flgAlterar != '1')) { showError('error', 'Seu usuário não possui permissão de alteração.', 'Alerta - Ayllos', 'semaforo--;'); return false; }
    if ((operacao == 'CI') && (flgIncluir != '1')) { showError('error', 'Seu usuário não possui permissão de inclusão.', 'Alerta - Ayllos', 'semaforo--;'); return false; }
    if ((operacao == 'FC') && (flgConsultar != '1')) { showError('error', 'Seu usuário não possui permissão de consulta.', 'Alerta - Ayllos', 'semaforo--;'); return false; }
    if ((operacao == 'CR') && (flgRelatorio != '1')) { showError('error', 'Seu usuário não possui permissão para emissão do relatório.', 'Alerta - Ayllos', 'semaforo--;'); return false; }
    if ((operacao == 'CX') && (flgNome != '1')) { showError('error', 'Seu usuário não possui permissão alteração do nome.', 'Alerta - Ayllos', 'semaforo--;'); return false; }
    if ((operacao == 'CJ') && (flgCpfCnpj != '1')) { showError('error', 'Seu usuário não possui permissão alteração do CPF/CNPJ.', 'Alerta - Ayllos', 'semaforo--;'); return false; }
    if ((operacao == 'CD') && (flgDesvincula != '1')) { showError('error', 'Seu usuário não possui permissão para desvincular.', 'Alerta - Ayllos', 'semaforo--;'); return false; }
			
	return true;
}

function controlaLayout() {

    $('#divMatric').fadeTo(0, 0.1);
	
    $('fieldset').css({ 'margin': '0px', 'border-color': '#777', 'margin': '3px 0px' });
	
	formataPessoaFisica();
	formataPessoaJuridica();	
		
	// Caso for Pessoa Física, mostra Form de Pessoa Física, caso contrário mostra Form de Pessoa Jurídica
	 if (tppessoa == 1) { 
        $('#frmFisico').css('display', 'block');
	} else if (tppessoa == 2 || tppessoa == 3) { 
        $('#frmJuridico').css('display', 'block');
	}
	
	layoutPadrao();		
	controlaPesquisas();
	
	controlaBotoes();
	
	$('input').trigger('blur');	
	removeOpacidade('divMatric');
	
}

function controlaBotoes() {
		
    $('#btLimparIni').css('display', 'none');
    $('#btProsseguirIni').css('display', 'none');
    $('#btVoltarInc').css('display', 'none');
    $('#btProsseguirInc').css('display', 'none');
    $('#btVoltarPreInc').css('display', 'none');
    $('#btProsseguirPreInc').css('display', 'none');
    $('#btVoltarAlt').css('display', 'none');
    $('#btSalvarAlt').css('display', 'none');
    $('#btProsseguirAlt').css('display', 'none');
    $('#btVoltarAltNome').css('display', 'none');
    $('#btSalvarAltNome').css('display', 'none');
    $('#btVoltarCns').css('display', 'none');
    $('#btProsseguirCns').css('display', 'none');
    $('#btVoltarDesvinc').css('display', 'none');
    $('#btSalvarDesvinc').css('display', 'none');
    $('#btVoltarAltCpfCnpj').css('display', 'none');
    $('#btSalvarAltCpfCnpj').css('display', 'none');
	
	
	aux_cdrotina = operacao;
				
	switch (operacao) {
	
		case 'FC': 
		
            $('#btVoltarCns').unbind("click").bind("click", (function () {
				estadoInicial();
			}));
				
            $('#btVoltarCns').css('display', 'inline');
			
            if ($('input[name="inpessoa"]:checked', '#frmCabMatric').val() == 1) {
					
                if (($('#inhabmen', '#frmFisico').val() == 0 && nrdeanos < 18) || $('#inhabmen', '#frmFisico').val() == 2) {
										
                    $('#btProsseguirCns').unbind("click").bind("click", (function () {
                        abrirRotina('RESPONSAVEL LEGAL', 'Responsavel Legal', 'responsavel_legal', 'responsavel_legal', 'SC');
					}));
					
                    $('#btProsseguirCns').css('display', 'inline');
				
				}
				
                $('#btVoltarCns', '#divBotoes').css('display', 'inline');
		
            } else {
											
                $('#btProsseguirCns').unbind("click").bind("click", (function () {
					rollBack();
                    abrirRotina('PROCURADORES', 'Representante/Procurador', 'procuradores', 'procuradores', 'FC');
				}));
				
                $('#btProsseguirCns').css('display', 'inline');
				
			}
					
			break;
			
		case 'CI': 
			
            if (isHabilitado($('#cdagepac', '#frmCabMatric')) == false && $('#cdagepac', '#frmCabMatric').val() == '') {
				
                $('#btProsseguirPreInc').unbind("click").bind("click", (function () {
					consultaPreIncluir();								
				}));
							
                $('#btVoltarPreInc').css('display', 'inline');
                $('#btProsseguirPreInc').css('display', 'inline');
								
				processoIncluir();
					
				return true;
				
            } else {
				
                if ($('input[name="inpessoa"]:checked', '#frmCabMatric').val() == 1) {
					
                    $('#btProsseguirInc').unbind("click").bind("click", (function () {
						controlaOperacao('IV');				
					}));
					
                    $('#btVoltarInc').css('display', 'inline');
                    $('#btProsseguirInc').css('display', 'inline');
						
                } else {
				
                    $('#btProsseguirInc').unbind("click").bind("click", (function () {
						rollBack();					
						operacao = 'IV';
						manterRotina();
						
					}));
					
                    $('#btVoltarInc').css('display', 'inline');
                    $('#btProsseguirInc').css('display', 'inline');
				}
				 
			} 
			
			break;
			
		case 'CA': 
		
            if ($('input[name="inpessoa"]:checked', '#frmCabMatric').val() == 1) {
			
                if (($('#inhabmen', '#frmFisico').val() == 0 && nrdeanos < 18) || $('#inhabmen', '#frmFisico').val() == 2) {

                    $('#btSalvarAlt').css('display', 'inline');
                    $('#btSalvarAlt').unbind("click").bind("click", (function () {
						controlaOperacao('AV');
					}));
					
                    $('#btVoltarAlt').css('display', 'inline');
					
                } else {
				
                    $('#btSalvarAlt').unbind("click").bind("click", (function () {
						controlaOperacao('AV');						
					}));
                    $('#btVoltarAlt').css('display', 'inline');
                    $('#btSalvarAlt').css('display', 'inline');
					
				}
				
            } else {
				
                $('#btSalvarAlt').unbind("click").bind("click", (function () {
					controlaOperacao('AV');
				}));
									
                $('#btVoltarAlt').css('display', 'inline');
                $('#btSalvarAlt').css('display', 'inline');
			}
			
			break;
			
		case 'CX': 
			
            $('.opAltNome').css('display', 'inline');
			break;
		case 'CJ':
            $('.opAltCpfCnpj').css('display', 'inline');
			break;
		case 'CD': 
		
            $('.opDesvinc').css('display', 'inline');
			break;
			
        default:
						
            $('.opInicial').css('display', 'inline');
			break;
			
	}
	
	
}

function formataCabecalho() {

	highlightObjFocus($('#frmCabMatric'));

    var rOpcao = $('label[for="opcao"]', '#frmCabMatric');
    var rNrConta = $('label[for="nrdconta"]', '#frmCabMatric');
    var rCodAgencia = $('label[for="cdagepac"]', '#frmCabMatric');
    var rNrMatric = $('label[for="nrmatric"]', '#frmCabMatric');
    var rInpessoa = $('label[for="inpessoa"]', '#frmCabMatric');
	
    var cTodos = $('input[type="text"],select', '#frmCabMatric');
    var cOpcao = $('#opcao', '#frmCabMatric');
    var cNrConta = $('#nrdconta', '#frmCabMatric');
    var cCodAgencia = $('#cdagepac', '#frmCabMatric');
    var cDesAgencia = $('#nmresage', '#frmCabMatric');
    var cNrMatric = $('#nrmatric', '#frmCabMatric');
    var cNatureza = $('#input[name="inpessoa"]', '#frmCabMatric');
	
    rOpcao.addClass('rotulo').css({ 'width': '42px' });
    rNrConta.addClass('rotulo').css({ 'width': '42px' });
    rCodAgencia.addClass('rotulo-linha').css({ 'width': '32px' });
    rNrMatric.addClass('rotulo-linha').css({ 'width': '37px' });
    rInpessoa.addClass('rotulo-linha').css({ 'width': '2px' });
	
	cTodos.desabilitaCampo();
    cOpcao.css('width', '624px');
    cNrConta.addClass('conta pesquisa').css('width', '85px');
    cCodAgencia.addClass('codigo pesquisa').css('width', '50px');
    cDesAgencia.addClass('descricao').css('width', '174px');
    cNrMatric.addClass('matricula').css('width', '70px');
	
    $('#pessoaFi,#pessoaJu', '#frmCabMatric').desabilitaCampo();
	
    if ($.browser.msie) {
        cOpcao.css('width', '622px');
        cDesAgencia.css('width', '175px');
	}	
	
	if (operacao == 'CI') {
		// Se eu mudar a opção, muda a variável global operacao
        $("#pessoaFi,#pessoaJu", "#frmCabMatric").unbind('keypress').bind('keypress', function (e) {
			
            if (divError.css('display') == 'block') { return false; }

			if (e.keyCode == 9) {
				$("#btProsseguirPreInc").focus();
				return false;
			}	
			
		});
	}

    if (operacao == '' || operacao == 'FC') {
		
		cNrConta.habilitaCampo();
		cOpcao.habilitaCampo();

		// Se eu mudar a opção, muda a variável global operacao
        cOpcao.unbind('change').bind('change', function () {

			operacao = $(this).val();
			aux_operacao = $(this).val();
			
			// Se for inclusao, desabilitar c/c e habilitar PA
			if (operacao == 'CI') {	
				cNrConta.val("");	
				$('#frmJuridico').limpaFormulario();
				$('#frmFisico').limpaFormulario();
				controlaOperacao(operacao); 
			} else {
				cNrConta.focus();
			}
			
		});
		
		// Se pressionar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida ação
        cNrConta.unbind('keypress').bind('keypress', function (e) {
		
            if (divError.css('display') == 'block') { return false; }
			
			// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
            if (e.keyCode == 13) {
				// Armazena o número da conta na variável global
                nrdconta = normalizaNumero($(this).val());
				nrdcontaOld = nrdconta;
			
				// Verifica se o número da conta é vazio
                if (nrdconta == '') { return false; }
					
				// Verifica se a conta é válida
                if (!validaNroConta(nrdconta)) {
                    showError('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Matric', 'focaCampoErro(\'nrdconta\',\'frmCabMatric\');');
					return false; 
				}
				
				// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
                controlaOperacao($('#opcao', '#frmCabMatric').val());
				return false;
			}
			
		});		
	
	} else {
		// Selecionar a a opção (operação) correta
        $('#opcao option:selected', '#frmCabMatric').val();
        $('#opcao', '#frmCabMatric').val(operacao);
	
		cNrConta.desabilitaCampo();
		cOpcao.desabilitaCampo();
	}	
	
	cNrConta.trigger('blur');
	return false;	
}

function formataRodape(nomeForm) {
	
    var rDtAdmissao = $('label[for="dtadmiss"]', '#' + nomeForm);
    var rDtSaida = $('label[for="dtdemiss"]', '#' + nomeForm);
    var rMotivo = $('label[for="cdmotdem"]', '#' + nomeForm);

    rDtAdmissao.addClass('rotulo').css('width', '72px');
    rDtSaida.addClass('rotulo-linha').css({ 'width': '41px' });
    rMotivo.addClass('rotulo-linha').css({ 'width': '46px' });

    var cTodosPJ3 = $('#dtadmiss,#dtdemiss,#cdmotdem,#dsmotdem', '#' + nomeForm);
    var cDtAdmissao = $('#dtadmiss', '#' + nomeForm);
    var cDtSaida = $('#dtdemiss', '#' + nomeForm);
    var cCodMotivo = $('#cdmotdem', '#' + nomeForm);
    var cDesMotivo = $('#dsmotdem', '#' + nomeForm);

	cTodosPJ3.desabilitaCampo();
    cDtAdmissao.addClass('data').css('width', '100px');
    cDtSaida.addClass('data').css('width', '100px');
    cCodMotivo.addClass('codigo pesquisa').css({ 'width': '40px' });
    cDesMotivo.addClass('descricao').css('width', '227px');
	
    if ($.browser.msie) {
        cDesMotivo.css('width', '230px');
	}
	
	// [ A ] - Se operacão é inclusão, habilito os campos
	if (operacao == 'CA') {
		cDtSaida.habilitaCampo();
		cCodMotivo.habilitaCampo();		
	}

	return false;
}

// ALTERAÇÃO 001: alterado a formatação dos campos de endereco, 
//				  e a ação de habilitar os campos foi passado para as funções formataPessoaFisica e formataPessoaJuridica
function formataEndereco(nomeForm) {

    var inpessoa = $('input[name="inpessoa"]:checked', '#frmCabMatric').val();

	// rotulo endereco
    var rCep = $('label[for="nrcepend"]', '#' + nomeForm);
    var rEnd = $('label[for="dsendere"]', '#' + nomeForm);
    var rNum = $('label[for="nrendere"]', '#' + nomeForm);
    var rCom = $('label[for="complend"]', '#' + nomeForm);
    var rBai = $('label[for="nmbairro"]', '#' + nomeForm);
    var rEst = $('label[for="cdufende"]', '#' + nomeForm);
    var rCid = $('label[for="nmcidade"]', '#' + nomeForm);
    var rOri = $('label[for="idorigee"]', '#' + nomeForm);

    rCep.addClass('rotulo').css('width', '72px');
    rEnd.addClass('rotulo-linha').css('width', '36px');
    rNum.addClass('rotulo').css('width', '72px');
    rCom.addClass('rotulo-linha').css('width', '54px');
    rBai.addClass('rotulo-linha').css('width', '54px');
    rEst.addClass('rotulo').css('width', '72px');
    rCid.addClass('rotulo-linha').css('width', '54px');
    rOri.addClass('rotulo').css('width', '72px');
	
	// campo endereco
    var cTodos = $('#dsendere,#nrendere,#complend,#nmbairro,#nrcepend,#nmcidade,#cdufende,#idorigee', '#' + nomeForm);
    var endDesabilita = $('#dsendere,#cdufende,#nmbairro,#nmcidade', '#' + nomeForm);
    var cCep = $('#nrcepend', '#' + nomeForm);
    var cEnd = $('#dsendere', '#' + nomeForm);
    var cNum = $('#nrendere', '#' + nomeForm);
    var cCom = $('#complend', '#' + nomeForm);
    var cBai = $('#nmbairro', '#' + nomeForm);
    var cEst = $('#cdufende', '#' + nomeForm);
    var cCid = $('#nmcidade', '#' + nomeForm);
    var cOri = $('#idorigee', '#' + nomeForm);

	cTodos.desabilitaCampo();
    cCep.addClass('cep pesquisa').css('width', '100px').attr('maxlength', '9');
    cEnd.addClass('alphanum').css('width', '427px').attr('maxlength', '40');
    cNum.addClass('numerocasa').css('width', '100px').attr('maxlength', '6');
    cCom.addClass('alphanum').css('width', '426px').attr('maxlength', '40');
    cBai.addClass('alphanum').css('width', '426px').attr('maxlength', '40');
    cEst.css('width', '100px');
    cCid.addClass('alphanum').css('width', '426px').attr('maxlength', '25');
    cOri.css('width', '100px');
	
	// Validar que o CEP do cooperado seja numa cidade de atuacao da cooperativa. Somente alerta, nao trava
    cNum.unbind('blur').bind('blur', function () {
		
        inpessoa = $('input[name="inpessoa"]:checked', '#frmCabMatric').val();
		
		if (isHabilitado($(this)) == false || cCid.val() == "") {
			return false;
		}	
				
		if (operacao == 'CA' || operacao == "PA") { // Evitar a validacao quando acessada a opcao de ALTERACAO
			operacao = 'CC';
			return false;
		}
		
		operacao = "CC";
		
		manterOutros(nomeForm);
		
		return false;
	
	});
	
	
		
	return false;

}

// ALTERAÇÃO 001: adicionado a ação de habilitar os campos do endereco
function formataPessoaFisica() {

	highlightObjFocus($('#frmFisico'));

	/* ----------------------- */
	/*    FIELDSET TITULAR     */
	/* ----------------------- */
    var rRotuloPF1 = $('label[for="tpdocptl"]', '#frmFisico');
    var rCPF = $('label[for="nrcpfcgc"]', '#frmFisico');
    var rNomeTitular = $('label[for="nmprimtl"],label[for="nmttlrfb"]', '#frmFisico');
    var rDtConsulta = $('label[for="dtcnscpf"]', '#frmFisico');
    var rSituacao = $('label[for="cdsitcpf"]', '#frmFisico');
    var rOrgEmissor = $('label[for="cdoedptl"]', '#frmFisico');
    var rEstEmissor = $('label[for="cdufdptl"]', '#frmFisico');
    var rDtEmissao = $('label[for="dtemdptl"]', '#frmFisico');

    rRotuloPF1.addClass('rotulo').css('width', '72px');
    rCPF.css('width', '72px');
    rNomeTitular.addClass('rotulo').css('width', '72px');
    rDtConsulta.css('width', '58px');
    rSituacao.css('width', '58px');
    rOrgEmissor.addClass('rotulo').css('width', '72px');
    rEstEmissor.css('width', '27px');
    rDtEmissao.css('width', '51px');
	
    var cTodosPF1 = $('input,select', '#frmFisico fieldset:eq(0)');
    var cNomeTitular = $('#nmprimtl', '#frmFisico');
    var cNomeRFB = $('#nmttlrfb', '#frmFisico');
    var cCPF = $('#nrcpfcgc', '#frmFisico');
    var cDtConsulta = $('#dtcnscpf', '#frmFisico');
    var cSituacao = $('#cdsitcpf', '#frmFisico');
    var cTpDocumento = $('#tpdocptl', '#frmFisico');
    var cNrDocumento = $('#nrdocptl', '#frmFisico');
    var cOrgEmissor = $('#cdoedptl', '#frmFisico');
    var cEstEmissor = $('#cdufdptl', '#frmFisico');
    var cDtEmissao = $('#dtemdptl', '#frmFisico');
    
	// Indicador se estã conectado no banco de producao
    var inbcprod = $('#inbcprod', '#frmCabMatric');
	
	cTodosPF1.desabilitaCampo();
    cNomeTitular.addClass('alphanum').css('width', '586px').attr('maxlength', '50');
    cNomeRFB.addClass('alphanum').css('width', '586px');
    cCPF.addClass('cpf').css('width', '115px');
    cDtConsulta.addClass('data').css('width', '75px');
    cSituacao.css('width', '133px');
    cTpDocumento.css('width', '183px');
    cNrDocumento.addClass('alphanum').css({ 'width': '400px', 'text-align': 'right' }).attr('maxlength', '40');
    cOrgEmissor.addClass('alphanum').css('width', '60px').attr('maxlength', '5');
    cEstEmissor.css('width', '55px');
    cDtEmissao.addClass('data').css('width', '95px');
	
    if ($.browser.msie) {
        cNomeTitular.css('width', '584px');
        cNomeRFB.css('width', '584px');
        rDtEmissao.css('width', '49px');
	}	
	
	controlaFocoEnter("frmFisico");
	
    cCPF.unbind('keydown').bind('keydown', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            if (!validaCpfCnpj($(this).val(), 1)) {
                showError('error', 'CPF inv&aacute;lido.', 'Alerta - Ayllos', '$(\'#nrcpfcgc\',\'#frmFisico\').focus();');
				return false;
			}
		
			// Obter o horario de inicio do cadastro.
			var data = new Date();
            hrinicad = ((data.getHours() * 3600) + (data.getMinutes() * 60) + data.getSeconds());
			
			operacao = 'LCD';
			manterOutros('frmFisico');
			return false;
		}
	});	
	
    cCPF.unbind('blur').bind('blur', function (e) {
        if ($('#opcao', '#frmCabMatric').val() == "CI") {
			if ($(this).val() != normalizaNumero(nrcpfcgc)) {
				// Limpar dados da RFB
                $("#nmttlrfb", "#frmFisico").val("");
                $("#cdsitcpf", "#frmFisico").val(0);
                $("#dtcnscpf", "#frmFisico").val("");
                $("#dtnasctl", "#frmFisico").val("");
                $("#inconrfb", "#frmFisico").val("");
				
				nrcpfcgc = $(this).val();
			}
		}
	});
	
	/* ----------------------- */
	/*  FIELDSET INF. COMPL.   */
	/* ----------------------- */	
    var rRotuloPF2 = $('label[for="tpnacion"],label[for="cdnacion"],label[for="dsnatura"],label[for="cdestcvl"],label[for="cdempres"],label[for="cdocpttl"],label[for="inhabmen"],label[for="nrtelres"]', '#frmFisico');
    var rRotulo70 = $('label[for="dtnasctl"],label[for="cdsexotl"]', '#frmFisico');
    var rNrcadast = $('label[for="nrcadast"]', '#frmFisico');
    var rNmconjug = $('label[for="nmconjug"]', '#frmFisico');
    var rDthanmen = $('label[for="dthabmen"]', '#frmFisico');
    var rEmail = $('label[for="dsdemail"]', '#frmFisico');
    var rTelefones = $('label[for="nrtelcel"],label[for="cdopetfn"]', '#frmFisico');
	
    rRotuloPF2.addClass('rotulo').css('width', '72px');
    rRotulo70.css('width', '60px');
    rNrcadast.css({ 'width': '91px' });
    rNmconjug.addClass('rotulo-linha').css({ 'width': '55px' });
    rDthanmen.css('width', '306px');
    rEmail.css({ 'width': '55px' });
    rTelefones.css({ 'width': '70px' });
	
    var cTodosPF2 = $('input,select', '#frmFisico fieldset:eq(1)');
    var cCodigoPF1 = $('#cdnacion,#tpnacion,#cdestcvl,#cdempres,#cdocpttl', '#frmFisico');
    var cDescricaoPF1 = $('#dsnacion,#destpnac,#dsestcvl,#nmresemp,#dsocpttl', '#frmFisico');
    var cCodTpNacio = $('#tpnacion', '#frmFisico');
    var cDesTpNacio = $('#destpnac', '#frmFisico');
    var cCodNacion = $('#cdnacion', '#frmFisico');
    var cDesNacion = $('#dsnacion', '#frmFisico');
    var cCPF = $('#nrcpfcgc', '#frmFisico');
    var cDtNasc = $('#dtnasctl', '#frmFisico');
    var cDtConsulta = $('#dtcnscpf', '#frmFisico');
    var cDesNatura = $('#dsnatura', '#frmFisico');
    var cCdufnatu = $('#cdufnatu', '#frmFisico');
    var cInhabmen = $('#inhabmen', '#frmFisico');
    var cDthabmen = $('#dthabmen', '#frmFisico');
    var cCodEstCivil = $('#cdestcvl', '#frmFisico');
    var cDesEstCivil = $('#dsestcvl', '#frmFisico');
    var cNmConjuge = $('#nmconjug', '#frmFisico');
    var cCodEmpresa = $('#cdempres', '#frmFisico');
    var cDesEmpresa = $('#nmresemp', '#frmFisico');
    var cCadEmpresa = $('#nrcadast', '#frmFisico');
    var cCodOcupacao = $('#cdocpttl', '#frmFisico');
    var cDesOcupacao = $('#dsocpttl', '#frmFisico');
    var cEmail = $('#dsdemail', '#frmFisico');
    var cDDDs = $('#nrdddres,#nrdddcel', '#frmFisico');
    var cTelefones = $('#nrtelres,#nrtelcel', '#frmFisico');
    var cOperadoras = $('#cdopetfn', '#frmFisico');
    var cSexo = $('input[name=\'cdsexotl\']', '#frmFisico');
    var cTodosEnd = $('#dsendere,#nrendere,#complend,#nmbairro,#nrcepend,#nmcidade,#cdufende,#idorigee', '#frmFisico');
    var cEndDesabilita = $('#dsendere,#cdufende,#nmbairro,#nmcidade', '#frmFisico');
	
	cTodosPF2.desabilitaCampo();
    cCodigoPF1.addClass('codigo pesquisa').css({ 'width': '40px' });
	cDescricaoPF1.addClass('descricao');
    cDesTpNacio.css('width', '526px');
    cDesNacion.css('width', '526px');
    cDtNasc.addClass('data').css('width', '75px');
    cDesNatura.addClass('pesquisa alphanum').css('width', '330px').attr('maxlength', '50');
    cInhabmen.css('width', '183px');
    cDthabmen.addClass('data').css('width', '94px');
    cDesEstCivil.css('width', '200px');
    cNmConjuge.addClass('alphanum').css('width', '265px').attr('maxlength', '50');
    cDesEmpresa.css('width', '340px');
    cCadEmpresa.addClass('cadempresa').css('width', '92px');
    cDesOcupacao.css('width', '200px');
    cEmail.css('width', '268px');
    cDDDs.addClass('inteiro').css('width', '40px');
    cTelefones.addClass('inteiro').css('width', '118px');
    cCdufnatu.css('width', '60px');
    cOperadoras.css('width', '118px');

    if ($.browser.msie) {
        cDthabmen.css('width', '92px');
        cEmail.css('width', '266px');
        cDesTpNacio.css('width', '524px');
        cDesNacion.css('width', '398px');
        cDesNatura.css('width', '328px');
        cDesEmpresa.css('width', '338px');
        cNmConjuge.css('width', '266px');
        cTelefones.css('width', '117px');
	}
	
	// Blur do Tp. Nacion
    cCodTpNacio.unbind('blur').bind('blur', function () {
	
		if (isHabilitado($(this)) == false) {
			return false;
		}		
	
		if ($(this).val() == 1) { // Se for brasileiro/a
			cCdufnatu.val("").habilitaCampo();
            cCodNacion.val("42");
			cDesNacion.val("BRASILEIRA");
			controlaPesquisas();
			cDesNatura.focus();
		}
		else {
			cCdufnatu.val("EX").desabilitaCampo();
			if (cDesNacion.val() == "BRASILEIRA") {
                cCodNacion.val("");
				cDesNacion.val("");
			}
			cCodNacion.focus();
			controlaPesquisas();
		}
		return false;
		
	});	
	// Somente executa se esta conectado no banco de producao
    //console.log(' 1- '+inbcprod.val());
/*  Não consultar receita enquanto se estuda solução (Chamado #537134)
    if (inbcprod.val() == 'S') {
	// Carregar captcha para consulta na Receita federal
        cDtConsulta.unbind('focus').bind('focus', function () {
	
		// Se tela bloqueada, ja tem outro processo rodando, desconsiderar.
            if ($("#divBloqueio").css('display') == 'block') {
			cDtNasc.focus();
			return false;
		}	
				
		if (cCPF.val() == "" || cDtNasc.val() == "" || cDtConsulta.val() != "") {
			return false;
            } else {
                validaAcessoEexecuta(UrlSite, 'CPF');
            }
	});
    }  */

    cNomeTitular.unbind('blur').bind('blur', function (e) {
		if ($(this).val() != "" && cNomeRFB.val() != "") {
            if ($(this).val().toUpperCase() != cNomeRFB.val().toUpperCase()) {
                showError('error', 'Nome informado diverge do existente na Receita Federal.', 'Alerta - Ayllos', '$("#tpdocptl","#frmFisico").focus();');
				return false;
			}
		}					
	});
	
    cDthabmen.unbind('change').bind('change', function () {
		
		var ope = '';
		
        if ($('#opcao option:selected', '#frmCabMatric').val() == 'CA') {
			ope = "PA";
        } else if ($('#opcao option:selected', '#frmCabMatric').val() == 'CI') {
				ope = 'PI';
		}	
		
		controlaOperacao(ope);
							
	});
	
    cInhabmen.unbind('change').bind('change', function () {
	
		var ope = '';
		
        if ($('#opcao option:selected', '#frmCabMatric').val() == 'CA') {
			ope = "PA";
        } else if ($('#opcao option:selected', '#frmCabMatric').val() == 'CI') {
			ope = 'PI';
		}	
		
        if ($(this).val() != 1) {
			cDthabmen.desabilitaCampo();
			cDthabmen.val('');	
			cCodEstCivil.focus();
        } else {
			cDthabmen.habilitaCampo();
		}
				
		controlaOperacao(ope);
		
	});
	
		
	/* ----------------------- */
	/*    FIELDSET FILIAÇÃO    */
	/* ----------------------- */
    var rRotulosPF3 = $('label[for="nmmaettl"]', '#frmFisico');
    var rNmpaittl = $('label[for="nmpaittl"]', '#frmFisico');
    var cNomesPais = $('#nmmaettl,#nmpaittl', '#frmFisico');
	
    rRotulosPF3.addClass('rotulo').css('width', '72px');
    rNmpaittl.addClass('rotulo-linha').css({ 'width': '60px' });
    cNomesPais.addClass('alphanum').css('width', '260px').attr('maxlength', '40').desabilitaCampo();

    if ($.browser.msie) {
        rNmpaittl.css({ 'width': '64px' });
        cNomesPais.css('width', '258px');
	}
	
	// Formata fieldsets comuns a PF e PJ
	formataEndereco('frmFisico');
	formataRodape('frmFisico');	
	
	// [ I ] - Se operacão é inclusão, habilito os campos
	if (operacao == 'CI') {
        $('#pessoaFi', '#frmCabMatric').keypress(function (e) {
            if (e.which == 13) {
                if (bloqueiaCabecalho()) {
					cTodosPF1.habilitaCampo();	
					cTodosPF2.habilitaCampo();
					cTodosEnd.habilitaCampo();
					cNomeRFB.desabilitaCampo();
					cEndDesabilita.desabilitaCampo();
					cNomesPais.habilitaCampo();	
					cDescricaoPF1.desabilitaCampo();
					controlaNomeConjuge();
					controlaBotoes();
					controlaPesquisas();
					cCPF.focus();
					return true;
				}	
			}
		});	
	} else // [ X ] - Se operacão for alteração do nome/cpf
	if (operacao == 'CX') {
		cNomeTitular.habilitaCampo();
	// [ A ] - Se operacão for alteração 	
	} else if (operacao == 'CJ') {
		cCPF.habilitaCampo();
	} else if (operacao == 'CA') {
		cEndDesabilita.desabilitaCampo();		
		controlaNomeConjuge();	
	}
	
	return false;
}

// ALTERAÇÃO 001: adicionado a ação de habilitar os campos do endereco
function formataPessoaJuridica() {
	
	highlightObjFocus($('#frmJuridico'));
    $('fieldset:eq(3)', '#frmJuridico').css({ 'padding': '0px' });
	
	/* ----------------------- */
	/*    FIELDSET EMPRESA     */
	/* ----------------------- */
    var rRotuloPJ1 = $('label[for="nmfansia"],label[for="nmttlrfb"],label[for="nrcpfcgc"],label[for="nrinsest"],label[for="dtiniatv"],label[for="nrdddtfc"],label[for="nmprimtl"],label[for="dsdemail"]', '#frmJuridico');
    var rRazaoSocial = $('label[for="nmprimtl"]', '#frmJuridico');
    var rDtConsulta = $('label[for="dtcnscpf"]', '#frmJuridico');
    var rSituacao = $('label[for="cdsitcpf"]', '#frmJuridico');
    var rNatJuricica = $('label[for="natjurid"]', '#frmJuridico');
    var rSetEconomico = $('label[for="cdseteco"]', '#frmJuridico');
    var rRamo = $('label[for="cdrmativ"]', '#frmJuridico');
    var rCnae = $('label[for="cdcnae"]', '#frmJuridico');
    var rNrlicamb = $('label[for="nrlicamb"]', '#frmJuridico');

    rRotuloPJ1.addClass('rotulo').css('width', '86px');
    rRazaoSocial.css('width', '86px');
    rDtConsulta.css('width', '95px');
    rSituacao.css('width', '108px');
    rNatJuricica.css('width', '95px');
    rSetEconomico.css('width', '95px');
    rRamo.css('width', '95px');
    rCnae.css('width', '50px');
    rNrlicamb.addClass('rotulo').css('width', '86px');

    var cTodosPJ1 = $('input,select', '#frmJuridico fieldset:eq(0)');
    var cTodosPJ3 = $('input,select', '#frmJuridico fieldset:eq(2)');
    var cCodigoPJ1 = $('#natjurid,#cdseteco,#cdrmativ', '#frmJuridico');
    var cDescricaoPJ1 = $('#rsnatjur,#nmseteco,#dsrmativ,#dscnae', '#frmJuridico');

	cTodosPJ1.desabilitaCampo();
	cCodigoPJ1.addClass('codigo pesquisa');	
    cDescricaoPJ1.addClass('descricao').css('width', '284px');

    var cRazaoSocial = $('#nmprimtl', '#frmJuridico');
    var cNomeFantasia = $('#nmfansia,#nmttlrfb', '#frmJuridico');
    var cNomeRFB = $('#nmttlrfb', '#frmJuridico');
    var cCNPJ = $('#nrcpfcgc', '#frmJuridico');
    var cDtConsulta = $('#dtcnscpf', '#frmJuridico');
    var cSituacao = $('#cdsitcpf', '#frmJuridico');
    var cInscricaoEst = $('#nrinsest', '#frmJuridico');
    var cCodNatJuridica = $('#natjurid', '#frmJuridico');
    var cDesNatJuridica = $('#rsnatjur', '#frmJuridico');
    var cInicioAtiv = $('#dtiniatv', '#frmJuridico');
    var cCodSetorEcon = $('#cdseteco', '#frmJuridico');
    var cDesSetorEcon = $('#nmseteco', '#frmJuridico');
    var cCodRamoAtiv = $('#cdrmativ', '#frmJuridico');
    var cDesRamoAtiv = $('#dsrmativ', '#frmJuridico');
    var cDDD = $('#nrdddtfc', '#frmJuridico');
    var cTelefone = $('#nrtelefo', '#frmJuridico');
    var cTodosEnd = $('#dsendere,#nrendere,#complend,#nmbairro,#nrcepend,#nmcidade,#cdufende,#idorigee', '#frmJuridico');	
    var cEndDesabilita = $('#dsendere,#cdufende,#nmbairro,#nmcidade', '#frmJuridico');
    var cEmail = $('#dsdemail', '#frmJuridico');
    var cCnae = $('#cdcnae', '#frmJuridico');
    var cDscnae = $('#dscnae', '#frmJuridico');
    
	// Indicador se estã conectado no banco de producao
    var inbcprod = $('#inbcprod', '#frmCabMatric');
	
	
    var cNrlicamb = $('#nrlicamb', '#frmJuridico');

    cRazaoSocial.addClass('alphanum').css('width', '572px').attr('maxlength', '50');
    cNomeFantasia.addClass('alphanum').css('width', '572px').attr('maxlength', '40');
    cCNPJ.addClass('cnpj').css('width', '135px');
    cDtConsulta.addClass('data').css('width', '103px');
    cInscricaoEst.addClass('insc_estadual').css('width', '135px');
    cSituacao.css('width', '125px');
    cInicioAtiv.addClass('data').css('width', '135px');
    cDDD.css('width', '35px').attr('maxlength', '3').addClass('inteiro');
    cTelefone.css('width', '97px').addClass('alphanum').attr('maxlength', '10');
    cEmail.css('width', '180px');
    cCodNatJuridica.css('width', '60px').addClass('inteiro');
    cDesNatJuridica.css('width', '259px');
    cCnae.css('width', '60px').attr('maxlength', '7');
    cDscnae.css('width', '259px');
    cNrlicamb.css('width', '135px').attr('maxlength', '15');
	
    if ($.browser.msie) {
        cRazaoSocial.css('width', '570px');
        cNomeFantasia.css('width', '570px');
        cSituacao.css('width', '123px');
        cDescricaoPJ1.css('width', '282px');
        cDscnae.css('width', '257px');
        cDesNatJuridica.css('width', '257px');
	}

	controlaFocoEnter("frmJuridico");
	
	// CNPJ
    cCNPJ.unbind('keydown').bind('keydown', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
			// Valida CNPJ		
            if (!validaCpfCnpj($(this).val(), 2)) {
                showError('error', 'CNPJ inv&aacute;lido.', 'Alerta - Ayllos', '$(\'#nrcpfcgc\',\'#frmJuridico\').focus();');
				return false; 
			} 
					
			// Obter o horario de inicio do cadastro.
			var data = new Date();
            hrinicad = ((data.getHours() * 3600) + (data.getMinutes() * 60) + data.getSeconds());
			
			operacao = 'LCD';
			manterOutros('frmJuridico');
		}
	});	
	
    cCNPJ.unbind('blur').bind('blur', function (e) {
		if ($('#opcao', '#frmCabMatric').val() == "CI") {
			if ($(this).val() != normalizaNumero(nrcpfcgc)) {
				$("#nmttlrfb", "#frmJuridico").val("");
				$("#cdsitcpf", "#frmJuridico").val(0);
				$("#dtcnscpf", "#frmJuridico").val("");
				$("#inconrfb", "#frmJuridico").val("");
				
				nrcpfcgc = $(this).val();
		    }
	    }
				
	});
	// Somente executa se esta conectado no banco de producao
    //console.log(' 2- '+inbcprod.val());
/*  Não consultar receita enquanto se estuda solução (Chamado #537134)
    if (inbcprod.val() == 'S') {
	// Carregar captcha para consulta na Receita federal
        cDtConsulta.unbind('focus').bind('focus', function () {
					
		// Se tela bloqueada, ja tem outro processo rodando, desconsiderar.
            if ($("#divBloqueio").css('display') == 'block') {
			cCNPJ.focus();
			return false;
		}
					
		if (cCNPJ.val() == "" || cDtConsulta.val() != "") {
			return false;
            } else {
                validaAcessoEexecuta(UrlSite, 'CNPJ');
		}
	});
    } */
	
    cRazaoSocial.unbind('blur').bind('blur', function (e) {

		var value = '';
        if (cNomeRFB.val() != "") {
			value = cNomeRFB.val().toUpperCase();
			value = limpaCharEsp(value);
			cNomeRFB.val(value);
		}
        if ($(this).val() != "") {
			value = $(this).val().toUpperCase();
			value = limpaCharEsp(value);
			$(this).val(value);
		}
		
		if ($(this).val() != "" && cNomeRFB.val() != "") {
			var rfb = cNomeRFB.val().toUpperCase();
			value = $(this).val().toUpperCase();
			
            if (rfb != value) {
                showError('error', 'Nome informado diverge do existente na Receita Federal.', 'Alerta - Ayllos', '$("#nmfansia","#frmJuridico").focus();');
				return false;
			}
		}					
	});
	
	// Formata fieldsets comuns a PF e PJ
	formataEndereco('frmJuridico');
	formataRodape('frmJuridico');
	
	// Formata o divBotoes
    $('#divBotoes', '#frmJuridico').css({ 'text-align': 'center', 'padding-top': '3px' });
	

	// [ I ] - Se operacão é inclusão, habilito os campos
	if (operacao == 'CI') {
        $('#pessoaJu', '#frmCabMatric').keypress(function (e) {
            if (e.which == 13) {
                if (bloqueiaCabecalho()) {
					cTodosPJ1.habilitaCampo();
					cTodosEnd.habilitaCampo();
					cNomeRFB.desabilitaCampo();
					cEndDesabilita.desabilitaCampo();
					cDescricaoPJ1.desabilitaCampo();
					controlaBotoes();
					controlaPesquisas();
					cCNPJ.focus();
					return false;
				}	
			}
		});
	} else  // [ X ] - Se operacão for alteração do Razão Social/CNPJ
        if (operacao == 'CX') {
		cRazaoSocial.habilitaCampo();
	// [ A ] - Se operacão for alteração 	
        } else if (operacao == 'CJ') {
		cCNPJ.habilitaCampo();
	} else if (operacao == 'CA') {
		cEndDesabilita.desabilitaCampo();
		controlaPesquisas();
	}	
	
	return false;
}

function controlaFoco() {
		
    if (operacao == '') {
        $('#opcao', '#frmCabMatric').focus();
	} else if (operacao == 'FC') { 
		$('.opConsultar').focus();		
	} else if (operacao == 'CD') {
		$('#btSalvarDesvinc').focus();
    } else if ((operacao == 'CX') && (tppessoa == 1)) {
        $('#nrcpfcgc', '#frmFisico').focus();
    } else if ((operacao == 'CX') && (tppessoa == 2)) {
        $('#nmprimtl', '#frmJuridico').focus();
    } else if ((operacao == 'PA') && (tppessoa == 1)) {
        $('#dtnasctl', '#frmFisico').focus();
    } else if ((operacao == 'CA') && (tppessoa == 1)) {
        $('#dtdemiss', '#frmFisico').focus();
    } else if ((operacao == 'CA') && (tppessoa == 2)) {
        $('#dtdemiss', '#frmJuridico').focus();
	}	
	return false;
}


function controlaPesquisas() {
	
	// Definindo as variáveis
    var bo = 'b1wgen0059.p';
    var procedure = '';
    var titulo = '';
    var qtReg = '';
    var filtrosPesq = '';
    var filtrosDesc = '';
    var colunas = '';
    var camposOrigem = 'nrcepend;dsendere;nrendere;complend;nrcxapst;nmbairro;cdufende;nmcidade';
	
	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
    var linkConta = $('a:eq(0)', '#frmCabMatric');
    if (linkConta.prev().hasClass('campoTelaSemBorda')) {
        linkConta.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkConta.css('cursor', 'pointer').unbind('click').bind('click', function () {
            mostraPesquisaAssociado('nrdconta', 'frmCabMatric');
		});
	}
	
	/*----------------*/
	/*  CONTROLE PA   */
	/*----------------*/
    var linkPAC = $('a:eq(2)', '#frmCabMatric');
    if (linkPAC.prev().hasClass('campoTelaSemBorda')) {
        linkPAC.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkPAC.css('cursor', 'pointer').unbind('click').bind('click', function () {
            procedure = 'busca_pac';
            titulo = 'Agência PA';
            qtReg = '20';
            filtrosPesq = 'Cód. PA;cdagepac;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
            colunas = 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
            mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas);
			return false;	
		});
		
        linkPAC.prev().unbind('blur').bind('blur', function () {
            procedure = 'busca_pac';
            titulo = 'Agência PA';
			filtrosDesc = '';
            buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'nmresage', $(this).val(), 'dsagepac', filtrosDesc, 'frmCabMatric');
			return false;
		});
		
        linkPAC.prev().unbind('keypress').bind('keypress', function (e) {
			if (e.keyCode == 13) {
                $("#pessoaFi", "#frmCabMatric").focus();
			}
		});
		
	}
	
	/*-------------------------------*/
	/*  CONTROLE ORGAO EMISSOR		 */
	/*-------------------------------*/	
    var linkOrgao = $('a:eq(0)', '#frmFisico');
    if (linkOrgao.prev().hasClass('campoTelaSemBorda')) {
        linkOrgao.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkOrgao.css('cursor', 'pointer').unbind('click').bind('click', function () {
		var filtrosPesq = "Código;cdoedptl;100px;S;|Descrição;nmoedptl;200px;S;";
		var colunas = 'Código;cdorgao_expedidor;25%;left|Descrição;nmorgao_expedidor;75%;left';
		mostraPesquisa("ZOOM0001", "BUSCA_ORGAO_EXPEDIDOR", "Org&atilde;o expedidor", "30", filtrosPesq, colunas, '','','frmFisico');
	});

        /*linkOrgao.prev().bind('blur', function () {            
			buscaDescricao("ZOOM0001", "BUSCA_ORGAO_EXPEDIDOR", "Org&atilde;o expedidor", $(this).attr('name'), 'nmoedptl', $(this).val(), 'nmoedptl', '', 'frmFiltro');
			return false;
		});		*/
	}
	
	/*-------------------------------*/
	/*  CONTROLE TIPO NACIONALIDADE  */
	/*-------------------------------*/	
    var linkTpNacio = $('a:eq(1)', '#frmFisico');
    if (linkTpNacio.prev().hasClass('campoTelaSemBorda')) {
        linkTpNacio.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkTpNacio.css('cursor', 'pointer').unbind('click').bind('click', function () {
            procedure = 'busca_tipo_nacionalidade';
            titulo = 'Tipo Nacionalidade';
            qtReg = '30';
            filtrosPesq = 'Cód. Tp. Nacion.;tpnacion;30px;S;0;;codigo|Tp. Nacion.;destpnac;200px;S;;;descricao';
            colunas = 'Código;tpnacion;20%;right|Tipo Nacionalidade;destpnac;80%;left';
            mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas);
			return false;	
		});

        linkTpNacio.prev().bind('blur', function () {
            procedure = 'busca_tipo_nacionalidade';
            titulo = 'Tipo Nacionalidade';
			filtrosDesc = '';
            buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'destpnac', $(this).val(), 'destpnac', filtrosDesc, 'frmFisico');
			return false;
		});		
	}	
	
	/*--------------------------*/
	/*  CONTROLE NACIONALIDADE  */
	/*--------------------------*/	
	
    var linkNaciona = $('a:eq(2)', '#frmFisico');
	
    if (linkNaciona.prev().hasClass('campoTelaSemBorda')) {
        linkNaciona.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	}
    else {
        linkNaciona.addClass('lupa').css('cursor', 'pointer').unbind('click').bind('click', function () { 

			var filtrosPesq = "Código;cdnacion;100px;S;0|Descrição;dsnacion;200px;S;";
			var colunas = 'Código;cdnacion;25%;right|Descrição;dsnacion;75%;left';
			mostraPesquisa("ZOOM0001", "BUSCANACIONALIDADES", "Nacionalidades", "30", filtrosPesq, colunas);
			
			return false;
			
		});       
        
        linkNaciona.prev().unbind('change').bind('change', function () {
            
            buscaDescricao("ZOOM0001", "BUSCANACIONALIDADES", "Nacionalidade", $(this).attr('name'), 'dsnacion', $(this).val(), 'dsnacion', '', 'frmFisico');
			return false;

		});
	}
	
	
	/*--------------------------*/
	/*  CONTROLE NATURALIDADE   */
	/*--------------------------*/	
    var linkNatura = $('a:eq(3)', '#frmFisico');
    if (linkNatura.prev().hasClass('campoTelaSemBorda')) {
        linkNatura.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkNatura.css('cursor', 'pointer').unbind('click').bind('click', function () {
            procedure = 'busca_naturalidade';
            titulo = 'Naturalidade';
            qtReg = '50';
            filtrosPesq = 'Naturalidade;dsnatura;200px;S;;;descricao';
            colunas = 'Naturalidade;dsnatura;100%;left';
            mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas);
			return false;	
		});
	}
	
	/*-------------------------------*/
	/*     CONTROLE ESTADO CIVIL     */
	/*-------------------------------*/	
    var linkEstCivil = $('a:eq(4)', '#frmFisico');
    if (linkEstCivil.prev().hasClass('campoTelaSemBorda')) {
        linkEstCivil.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
	
        linkEstCivil.css('cursor', 'pointer').unbind('click').bind('click', function () {
            procedure = 'busca_estado_civil';
            titulo = 'Estado Civil';
            qtReg = '30';
            filtrosPesq = 'Cód. Est. Civil.;cdestcvl;30px;S;0;;codigo|Est. Civil;dsestcvl;200px;S;;;descricao';
            colunas = 'Código;cdestcvl;20%;right|Estado Civil;dsestcvl;80%;left';
            mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas);
			return false;	
		});
				
        linkEstCivil.prev().unbind('change').bind('change', function () {
				
			controlaNomeConjuge();
            procedure = 'busca_estado_civil';
            titulo = 'Estado Civil';
			filtrosDesc = '';
            buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsestcvl', $(this).val(), 'dsestcvl', filtrosDesc, 'frmFisico');
						
			//Quando estado civil for "Casado" e idade for menor que 18 anos, a pessoa passa automaticamente a ser emancipada.
            if (($(this).val() == "2" ||
				$(this).val() == "3" ||
				$(this).val() == "4" ||
				$(this).val() == "8" ||
				$(this).val() == "9" ||
				$(this).val() == "11") &&
				nrdeanos < 18 &&
				$('#inhabmen', '#frmFisico').val() == 0) {
                $('#inhabmen', '#frmFisico').val(1).habilitaCampo();
                $('#dthabmen', '#frmFisico').val(dtmvtolt).habilitaCampo();

            } else {
                $('#inhabmen', '#frmFisico').habilitaCampo();
                $('#dthabmen', '#frmFisico').habilitaCampo();
			}
				
			return false;
			
		});
			
	}
	
	/*-------------------------------*/
	/*        CONTROLE EMPRESA       */
	/*-------------------------------*/	
    var linkEmp = $('a:eq(5)', '#frmFisico');
    if (linkEmp.prev().hasClass('campoTelaSemBorda')) {
        linkEmp.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkEmp.css('cursor', 'pointer').unbind('click').bind('click', function () {
            procedure = 'busca_empresa';
            titulo = 'Empresa';
            qtReg = '30';
            filtrosPesq = 'Cód. Empresa;cdempres;30px;S;0;;codigo|Empresa;nmresemp;200px;S;;;descricao';
            colunas = 'Código;cdempres;20%;right|Empresa;nmresemp;80%;left';
            mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas);
			return false;	
		});
        linkEmp.prev().unbind('change').bind('change', function () {
            procedure = 'busca_empresa';
            titulo = 'Empresa';
			filtrosDesc = '';
            buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'nmresemp', $(this).val(), 'nmresemp', filtrosDesc, 'frmFisico');
			return false;
		});
        linkEmp.prev().unbind('blur').bind('blur', function () {
            $(this).unbind('change').bind('change', function () {
                procedure = 'busca_empresa';
                titulo = 'Empresa';
				filtrosDesc = '';
                buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'nmresemp', $(this).val(), 'nmresemp', filtrosDesc, 'frmFisico');
				return false;
			});
		});
	}
	
	/*-------------------------------*/
	/*        CONTROLE OCUPAÇÃO      */
	/*-------------------------------*/	
    var linkEmp = $('a:eq(6)', '#frmFisico');
    if (linkEmp.prev().hasClass('campoTelaSemBorda')) {
        linkEmp.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkEmp.css('cursor', 'pointer').unbind('click').bind('click', function () {
            
            filtrosPesq = 'Cód. Ocupação;cdocpttl;30px;S;0;;codigo|Ocupação;dsocpttl;200px;S;;;descricao';
            colunas = 'Código;cdocupa;20%;right|Ocupação;rsdocupa;80%;left';
            mostraPesquisa("ZOOM0001", "BUSCOCUPACAO", "Ocupação", "30", filtrosPesq, colunas);
			return false;	

		});
        linkEmp.prev().unbind('change').bind('change', function () {
            
			filtrosDesc = '';
            buscaDescricao("ZOOM0001", "BUSCOCUPACAO", "Ocupação", $(this).attr('name'), 'dsocpttl', $(this).val(), 'rsdocupa', filtrosDesc, 'frmFisico');
			return false;

		});
        linkEmp.prev().unbind('blur').bind('blur', function () {
            $(this).unbind('change').bind('change', function () {
                
				filtrosDesc = '';
                buscaDescricao("ZOOM0001", "BUSCOCUPACAO", "Ocupação", $(this).attr('name'), 'dsocpttl', $(this).val(), 'rsdocupa', filtrosDesc, 'frmFisico');
				return false;
			});
		});
	}
	
    var linkMotivo = $('a:eq(8)', '#frmFisico');
    if (linkMotivo.prev().hasClass('campoTelaSemBorda')) {
        linkMotivo.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkMotivo.css('cursor', 'pointer').unbind('click').bind('click', function () {
            procedure = 'busca_motivo_demissao';
            titulo = 'Motivo de saída';
            qtReg = '30';
            filtrosPesq = 'Cód. Motivo saída;cdmotdem;30px;S;0;;codigo|Motivo de saída;dsmotdem;200px;S;;;descricao';
            colunas = 'Código;cdmotdem;20%;right|Motivo de saída;dsmotdem;80%;left';
            mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas);
			return false;	
		});
        linkMotivo.prev().unbind('change').bind('change', function () {
            procedure = 'busca_motivo_demissao';
            titulo = 'Motivo de saída';
			filtrosDesc = '';
            buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsmotdem', $(this).val(), 'dsmotdem', filtrosDesc, 'frmFisico');
			return false;
		});
        linkMotivo.prev().unbind('blur').bind('blur', function () {
            $(this).unbind('change').bind('change', function () {
                procedure = 'busca_motivo_demissao';
                titulo = 'Motivo de saída';
				filtrosDesc = '';
                buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsmotdem', $(this).val(), 'dsmotdem', filtrosDesc, 'frmFisico');
				return false;
			});		
		});
	}
	
	/*-------------------------------*/
	/*     CONTROLE NAT. JURIDICA    */
	/*-------------------------------*/	
    var linkNatJur = $('a:eq(0)', '#frmJuridico');
    if (linkNatJur.prev().hasClass('campoTelaSemBorda')) {
        linkNatJur.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkNatJur.css('cursor', 'pointer').unbind('click').bind('click', function () {
            procedure = 'busca_natureza_juridica';
            titulo = 'Nat. Jurídica';
            qtReg = '30';
            filtrosPesq = 'Cód. Nat. Jurídica;natjurid;30px;S;0;;codigo|Nat. Jurídica;rsnatjur;200px;S;;;descricao';
            colunas = 'Código;cdnatjur;20%;right|Nat. Jurídica;rsnatjur;80%;left';
            mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas);
			return false;	
		});
        linkNatJur.prev().unbind('change').bind('change', function () {
            procedure = 'busca_natureza_juridica'; //
            titulo = 'Nat. Jurídica';
			filtrosDesc = '';
            buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'rsnatjur', $(this).val(), 'rsnatjur', filtrosDesc, 'frmJuridico');
			return false;
		});
        linkNatJur.prev().unbind('blur').bind('blur', function () {
            $(this).unbind('change').bind('change', function () {
                procedure = 'busca_natureza_juridica';
                titulo = 'Nat. Jurídica';
				filtrosDesc = '';
                buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'rsnatjur', $(this).val(), 'rsnatjur', filtrosDesc, 'frmJuridico');
				return false;
			});
		});	
	}
	
	/*-------------------------------*/
	/*    CONTROLE SETOR ECONOMICO   */
	/*-------------------------------*/	
    var linkSetEco = $('a:eq(1)', '#frmJuridico');
    if (linkSetEco.prev().hasClass('campoTelaSemBorda')) {
        linkSetEco.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkSetEco.css('cursor', 'pointer').unbind('click').bind('click', function () {
            procedure = 'busca_setor_economico';
            titulo = 'Setor Econômico';
            qtReg = '30';
            filtrosPesq = 'Cód. Setor Econômico;cdseteco;30px;S;0;;codigo|Setor Econômico;nmseteco;200px;S;;;descricao';
            colunas = 'Código;cdseteco;20%;right|Setor Econômico;nmseteco;80%;left';
            mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas);
			return false;	
		});
        linkSetEco.prev().unbind('change').bind('change', function () {
            procedure = 'busca_setor_economico';
            titulo = 'Setor Econômico';
			filtrosDesc = '';
            buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'nmseteco', $(this).val(), 'nmseteco', filtrosDesc, 'frmJuridico');
			return false;
		});
        linkSetEco.prev().unbind('blur').bind('blur', function () {
            $(this).unbind('change').bind('change', function () {
                procedure = 'busca_setor_economico';
                titulo = 'Setor Econômico';
				filtrosDesc = '';
                buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'nmseteco', $(this).val(), 'nmseteco', filtrosDesc, 'frmJuridico');
				return false;
			});		
		});
	}
	
	/*-------------------------------*/
	/*    CONTROLE RAMO ATIVIDADE    */
	/*-------------------------------*/	
    var linkRamo = $('a:eq(2)', '#frmJuridico');
    if (linkRamo.prev().hasClass('campoTelaSemBorda')) {
        linkRamo.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkRamo.css('cursor', 'pointer').unbind('click').bind('click', function () {
            procedure = 'busca_ramo_atividade';
            titulo = 'Ramo Atividade';
            qtReg = '30';
            filtrosPesq = 'Cód. Ramo Atividade;cdrmativ;30px;S;0;;descricao|Ramo Atividade;dsrmativ;200px;S;;;descricao|Cód. Setor Econômico;cdseteco;30px;N;;;codigo|Setor Econômico;nmseteco;200px;N;;;descricao';
            colunas = 'Código;cdrmativ;20%;right|Ramo Atividade;nmrmativ;80%;left';
            mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas);
			return false;	
		});
        linkRamo.prev().unbind('change').bind('change', function () {
            procedure = 'busca_ramo_atividade';
            titulo = 'Ramo Atividade';
			filtrosDesc = 'cdseteco';
            buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsrmativ', $(this).val(), 'nmrmativ', filtrosDesc, 'frmJuridico');
			return false;
		});
        linkRamo.prev().unbind('blur').bind('blur', function () {
            $(this).unbind('change').bind('change', function () {
                procedure = 'busca_ramo_atividade';
                titulo = 'Ramo Atividade';
				filtrosDesc = 'cdseteco';
                buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsrmativ', $(this).val(), 'nmrmativ', filtrosDesc, 'frmJuridico');
				return false;
			});	
		});	
	}
	
	/*-----------------------------------------------*/
	/*    CONTROLE CNAE						         */
	/*-----------------------------------------------*/
    var linkCnae = $('a:eq(3)', '#frmJuridico');
    if (linkCnae.prev().hasClass('campoTelaSemBorda')) {
        linkCnae.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkCnae.css('cursor', 'pointer').unbind('click').bind('click', function () {
            procedure = 'BUSCA_CNAE';
            titulo = 'CNAE';
            qtReg = '30';
            filtrosPesq = 'Cód. CNAE;cdcnae;60px;S;0;;descricao|Desc. CNAE;dscnae;200px;S;;;descricao|;flserasa;;N;2;N;;descricao';
            colunas = 'Código;cdcnae;20%;right|Desc CANE;dscnae;80%;left';
            mostraPesquisa('ZOOM0001', procedure, titulo, qtReg, filtrosPesq, colunas);
			return false;	
		});
        linkCnae.prev().unbind('change').bind('change', function () {
            procedure = 'BUSCA_CNAE';
            titulo = 'CNAE';
			filtrosDesc = 'flserasa|2';
			buscaDescricao('ZOOM0001', procedure, titulo, $(this).attr('name'), 'dscnae', $(this).val(), 'dscnae', filtrosDesc, 'frmJuridico');
			return false;
		});
	}
	

	/*-----------------------------------------------*/
	/*    CONTROLE ENDEREÇO FISICO E JURIDICO        */
	/*-----------------------------------------------*/
	// ALTERAÇÃO 001: adicionado o controle do endereco de pessoa fisica e juridica	
    var linkEnderecoFisico = $('a:eq(7)', '#frmFisico');
    if (linkEnderecoFisico.prev().hasClass('campoTelaSemBorda')) {
        linkEnderecoFisico.addClass('lupa').css('cursor', 'auto');
	} else {
        linkEnderecoFisico.css('cursor', 'pointer');
		linkEnderecoFisico.prev().buscaCEP('frmFisico', camposOrigem, $('#divMatric'));
	}	

    var linkEnderecoJuridico = $('a:eq(4)', '#frmJuridico')
    if (linkEnderecoJuridico.prev().hasClass('campoTelaSemBorda')) {
        linkEnderecoJuridico.addClass('lupa').css('cursor', 'auto');
	} else {
        linkEnderecoJuridico.css('cursor', 'pointer');
		linkEnderecoJuridico.prev().buscaCEP('frmJuridico', camposOrigem, $('#divMatric'));
	}
	
	/*-------------------------------*/
	/*    CONTROLE MOTOVO DEMISSAO   */
	/*-------------------------------*/		
    var linkMotivo = $('a:eq(5)', '#frmJuridico');
    if (linkMotivo.prev().hasClass('campoTelaSemBorda')) {
        linkMotivo.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkMotivo.css('cursor', 'pointer').unbind('click').bind('click', function () {
            procedure = 'busca_motivo_demissao';
            titulo = 'Motivo de saída';
            qtReg = '30';
            filtrosPesq = 'Cód. Motivo de saída;cdmotdem;30px;S;0;;codigo|Motivo de saída;dsmotdem;200px;S;;;descricao';
            colunas = 'Código;cdmotdem;20%;right|Motivo de saída;dsmotdem;80%;left';
            mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas);
			return false;	
		});
        linkMotivo.prev().unbind('change').bind('change', function () {
            procedure = 'busca_motivo_demissao';
            titulo = 'Motivo de saída';
			filtrosDesc = '';
            buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsmotdem', $(this).val(), 'dsmotdem', filtrosDesc, 'frmJuridico');
			return false;
		});
        linkMotivo.prev().unbind('blur').bind('blur', function () {
            $(this).unbind('change').bind('change', function () {
                procedure = 'busca_motivo_demissao';
                titulo = 'Motivo de saída';
				filtrosDesc = '';
                buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsmotdem', $(this).val(), 'dsmotdem', filtrosDesc, 'frmJuridico');
				return false;
			});	
		});	
	}	
}

function verificaResponsavelLegal() {
	
    if ($('input[name="inpessoa"]:checked', '#frmCabMatric').val() == 1) {
		
        if ($('#inhabmen', '#frmFisico').val() == 0 && nrdeanos < 18 || $('#inhabmen', '#frmFisico').val() == 2) {
            abrirRotina('RESPONSAVEL LEGAL', 'Responsavel Legal', 'responsavel_legal', 'responsavel_legal', 'CT');
		}
		else {
            //Alterado, pois validacao responsavel legal sera chamada apos salvar os dados, devido a replicação de dados da pessoa.		    
            //controlaOperacao("VI");
            impressao_inclusao();
		}
	}
	else {
        //Alterado, pois validacao responsavel legal sera chamada apos salvar os dados, devido a replicação de dados da pessoa.		    
        //controlaOperacao("VI");
        impressao_inclusao();
	}
}

function controlaNomeConjuge() {

    var estadoCivil = $('#cdestcvl', '#frmFisico');
    var nomeConjuge = $('#nmconjug', '#frmFisico');
    var codEmpresa = $('#cdempres', '#frmFisico');
    var sexo = $('input[name=\'cdsexotl\']', '#frmFisico');
		
    if (in_array(parseInt(estadoCivil.val()), [1, 5, 6, 7])) {
		nomeConjuge.val('').desabilitaCampo();
		codEmpresa.focus();
        estadoCivil.unbind('focusout').bind('focusout', function () {
			estadoCivil.removeClass('campoFocusIn').addClass('campo');	
			return true;
		});
	} else {
		nomeConjuge.habilitaCampo().focus();
		
        estadoCivil.unbind('focusout').bind('focusout', function () {
			estadoCivil.removeClass('campoFocusIn').addClass('campo');
			return true;
		});
	}
    if ($('#cdagepac', '#frmCabMatric').prop('disabled')) {
		estadoCivil.trigger('focusout'); 
	}
	
}

function imprime() {
	
    $('#sidlogin', '#frmCabMatric').remove();
	
    $('#frmCabMatric').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');
							
    $('#nrdconta', '#frmCabMatric').val(nrdconta);
	
    var action = UrlSite + 'telas/matric/imp_relatorio.php?nrdconta=' + nrdconta;
    var callback = ($('#opcao', '#frmCabMatric').val() == 'CI') ? 'efetuar_consultas();' : '';

    carregaImpressaoAyllos("frmCabMatric", action, callback);
	
}

function consultaInicial() { 	
	
    if (divError.css('display') == 'block') { return false; }
    if ($('#nrdconta', '#frmCabMatric').hasClass('campoTelaSemBorda')) { return false; }
				
	// Armazena o número da conta na variável global
    nrdconta = normalizaNumero($('#nrdconta', '#frmCabMatric').val());
	nrdcontaOld = nrdconta;

	// Verifica se o número da conta é vazio
    if (nrdconta == '') { return false; }
		
	// Verifica se a conta é válida
    if (!validaNroConta(nrdconta)) {
        showError('error', 'Conta/dv inválida.', 'Alerta - Matric', 'focaCampoErro(\'nrdconta\',\'frmCabMatric\');');
		return false; 
	}
	
	// Se chegou até aqui, a conta é diferente de vazio e é válida, então realizar a operação desejada
    controlaOperacao($('#opcao', '#frmCabMatric').val());
	return false;
	
};	

function consultaPreIncluir() {

	showMsgAguardo('Aguarde, validando inclus&atilde;o ...');
	
    cdagepac = $('#cdagepac', '#frmCabMatric').val();
    inpessoa = $('input[name="inpessoa"]:checked', '#frmCabMatric').val();
			
	// Carrega dados da conta através de ajax
	$.ajax({		
        type: 'POST',
        url: UrlSite + 'telas/matric/valida_inicio_inclusao.php',
        data:
				{ 
					nrdconta: nrdconta,
					cdagepac: cdagepac,
					inpessoa: inpessoa,
					redirect: 'script_ajax' 
				},
        error: function (objAjax, responseError, objExcept) {
					hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisi&ccedil;&atilde;o', 'Alerta - Matric', '$(\'#nrdconta\',\'#frmCabMatric\').focus()');
				},
        success: function (response) {
					try {
                eval(response);
            } catch (error) {
						hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o', 'Alerta - Ayllos', 'unblockBackground()');
					}					
				}
	});
	
	return false;
}

// ALTERAÇÃO 001: adicionado a ação de habilitar os campos do endereco
function formataInclusao() {
	
    if ($.browser.msie) {
	
        if ($('#cdagepac', '#frmCabMatric').hasClass('campoErro')) {
            $('#cdagepac', '#frmCabMatric').trigger('change');
		}	
		
	}
		
    if ($('#frmFisico').css('display') == 'block') {
	
        if (bloqueiaCabecalho()) {
			
            var cTodosPF1 = $('input,select', '#frmFisico fieldset:eq(0)');
            var cTodosPF2 = $('input,select', '#frmFisico fieldset:eq(1)');
            var cNomeRFB = $('#nmttlrfb', '#frmFisico');
            var cNomesPais = $('#nmmaettl,#nmpaittl', '#frmFisico');
            var cDescricaoPF1 = $('#destpnac,#dsestcvl,#nmresemp,#dsocpttl', '#frmFisico');
            var cCPF = $('#nrcpfcgc', '#frmFisico');
            var cTodosEnd = $('#dsendere,#nrendere,#complend,#nmbairro,#nrcepend,#nmcidade,#cdufende', '#frmFisico');			
            var cEndDesabilita = $('#dsendere,#cdufende,#nmbairro,#nmcidade', '#frmFisico');
			
			
			cTodosPF1.habilitaCampo();	
			cTodosPF2.habilitaCampo();
			cTodosEnd.habilitaCampo();
			cNomeRFB.desabilitaCampo();
			cEndDesabilita.desabilitaCampo();
			cNomesPais.habilitaCampo();	
			cDescricaoPF1.desabilitaCampo();
			controlaNomeConjuge();
			controlaBotoes();
			controlaPesquisas();
			cCPF.focus();
								
			return true;
			
		}
    } else if ($('#frmJuridico').css('display') == 'block') {
        if (bloqueiaCabecalho()) {
			
            var cTodosPJ1 = $('input,select', '#frmJuridico fieldset:eq(0)');
            var cDescricaoPJ1 = $('#rsnatjur,#nmseteco,#dsrmativ,#dscnae', '#frmJuridico');
            var cCNPJ = $('#nrcpfcgc', '#frmJuridico');
            var cNomeRFB = $('#nmttlrfb', '#frmJuridico');
            var cTodosEnd = $('#dsendere,#nrendere,#complend,#nmbairro,#nrcepend,#nmcidade,#cdufende', '#frmJuridico');
            var cEndDesabilita = $('#dsendere,#cdufende,#nmbairro,#nmcidade', '#frmJuridico');
			
			cTodosPJ1.habilitaCampo();
			cTodosEnd.habilitaCampo();
			cNomeRFB.desabilitaCampo();
			cEndDesabilita.desabilitaCampo();
			cDescricaoPJ1.desabilitaCampo();
			controlaBotoes();
			controlaPesquisas();
			cCNPJ.focus();
											
            document.getElementById("btProsseguirPreInc").innerHTML = "Prosseguir";
								
            $('#btProsseguirPreInc').unbind("click").bind("click", (function () {
				operacao = 'IV';
				manterRotina();					
			}));
					
			return true;
			
		}	
		
	}
	
	return false;		
	
}

function verificaRelatorio() {
	
    showMsgAguardo('Aguarde, validando ...');
	
    var cddopcao = $('#opcao', '#frmCabMatric').val();
	
	$.ajax({		
        type: 'POST',
		dataType: 'html',
        url: UrlSite + 'telas/matric/verifica_relatorio.php',
        data:
				{ 
					nrdconta: nrdconta,	
					cddopcao: cddopcao,
					redirect: 'script_ajax' 
				},
        error: function (objAjax, responseError, objExcept) {
					hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Matric', '$(\'#nrdconta\',\'#frmCabMatric\').focus()');
				},
        success: function (response) {
					hideMsgAguardo();
							
            if (response.indexOf('showError("error"') == -1) {
						
						// Se esta incluindo, efetuar consultas
                var metodo = ($('#opcao', '#frmCabMatric').val() == 'CI') ? 'efetuar_consultas();' : '';

                showConfirmacao("Deseja visualizar a impress&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "imprime();", metodo, "sim.gif", "nao.gif");
					} else {
						try {
                    eval(response);
                } catch (error) {
							hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
						}
					}
				}
	}); 

	return false;
}

function exibirMsgMatric(strAlerta, msgRetorno, qtparcel, vlparcel) {
	
    if (strAlerta != '') {
		// Definindo as variáveis
				
        var arrayMensagens = new Array();
        var novoArray = new Array();
        var elementoAtual = '';
		// Setando os valores
        arrayMensagens = strAlerta.split('|');
		
        elementoAtual = arrayMensagens.splice(0, 1);
        arrayMensagens = implode('|', arrayMensagens);
		// Exibindo mensagem de erro
        showError('inform', elementoAtual, 'Alerta - Ayllos', "exibirMsgMatric('" + arrayMensagens + "','" + msgRetorno + "','" + qtparcel + "','" + vlparcel + "')");
	} else {
        qtparcel = (typeof qtparcel == 'undefined') ? 0 : qtparcel;
        if (qtparcel > 0) {
            exibeParcelamento(qtparcel, vlparcel, msgRetorno);
        } else if (msgRetorno != '') {
            var op = operacao.substr(0, 1);
            showConfirmacao(msgRetorno, 'Confirma&ccedil;&atilde;o - MATRIC', 'controlaOperacao(\'V' + op + '\');', 'unblockBackground();', 'sim.gif', 'nao.gif');
		}
	}
	return false;
}

//---------------------------------------------------------
//  FUNÇÕES PARA O PARCELAMENTO
//---------------------------------------------------------

function exibeParcelamento(qtparcel, vlparcel, msgRetor) {
	
    showMsgAguardo('Aguarde, abrindo parcelamento ...');
	
    $.getScript(UrlSite + 'telas/matric/parcelamento/parcelamento.js', function () {
		$.ajax({		
            type: 'POST',
			dataType: 'html',
            url: UrlSite + 'telas/matric/parcelamento/parcelamento.php',
            data: {
						qtparcel: qtparcel,
						vlparcel: vlparcel,
						msgRetor: msgRetor,
						redirect: 'html_ajax'
					},		
            error: function (objAjax, responseError, objExcept) {
						hideMsgAguardo();
                showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
					},
            success: function (response) {
                if (response.indexOf('showError("error"') == -1) {
							$('#divUsoGenerico').html(response);
							hideMsgAguardo();
                    bloqueiaFundo($('#divUsoGenerico'));
						} else {
							try {
								hideMsgAguardo();
                        eval(response);
								controlaFoco();
                    } catch (error) {
								hideMsgAguardo();
                        showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
							}
						}
						return false;
					}				 
		});	
	});
}

function abrirProcuradores() {
		
    $('#btProsseguirInc').unbind("click").bind("click", (function () {
		impressao_inclusao();							
	}));
	
    abrirRotina('PROCURADORES', 'Representante/Procurador', 'procuradores', 'procuradores', 'CI');
}

// Função para acessar rotina 
function abrirRotina(nomeValidar, nomeTitulo, nomeScript, nomeURL, ope) {
				
	// Se ja abriu a rotina, desconsiderar	
    if (semaforo > 0) {
		return false;
	}
		
	semaforo++;	
		
	operacao = ope;
    inpessoa = $('input[name="inpessoa"]:checked', '#frmCabMatric').val();
    nomeForm = (inpessoa == 1) ? 'frmFisico' : 'frmJuridico';
	permalte = true;
    dtnasctl = $('#dtnasctl', '#frmFisico').val();
    cdhabmen = $('#inhabmen', '#frmFisico').val();
	nmrotina = 'MATRIC';		
    nrcpfcgc = $('#nrcpfcgc', '#' + nomeForm).val();
    nrdconta = normalizaNumero($("#nrdconta", "#frmCabMatric").val());
	
	
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde, carregando  " + nomeTitulo + " ...");
	
	if (ope == 'RFB') {
		var url = UrlSite + "includes/" + nomeScript + "/" + nomeURL;
	} else {
		var url = UrlSite + "telas/contas/" + nomeScript + "/" + nomeURL;
	}
	
	var urlScript = UrlSite + "includes/" + nomeURL + "/" + nomeURL;
	
		
	// Carrega biblioteca javascript da rotina
	// Ao carregar efetua chamada do conteúdo da rotina através de ajax
    $.getScript(urlScript + ".js?keyrand="+Math.floor((Math.random() * 1000) + 1), function () {
																		
		operacao_rsp = operacao;
	
        //console.log(url);

		$.ajax({
			type: "POST",
			dataType: "html",
            url: url + ".php?keyrand="+Math.floor((Math.random() * 1000) + 1),
			data: {
				nrdconta: nrdconta,
				idseqttl: 1,
				nmdatela: "MATRIC",
				inpessoa: inpessoa,
				dtnasctl: dtnasctl,
				nrcpfcgc: nrcpfcgc,
				nmrotina: nomeValidar,
				redirect: "html_ajax" // Tipo de retorno do ajax
			},
            error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "");
			},
            success: function (response) {
				
				$("#divRotina").html(response);
											
                $('.fecharRotina').click(function () {
					fechaRotina(divRotina);
					return false;
				});
				
				semaforo--;
			
			}				 
		}); 
	});
}

function sincronizaArray() {
	
	arrayBackupAvt.length = 0;
	arrayBackupBens.length = 0;
	arrayBackupFilhos.length = 0;
	
    for (i in arrayFilhosAvtMatric) {
	
        eval('var arrayAux' + i + ' = new Object();');
		
        for (campo in arrayFilhosAvtMatric[0]) {
		
            eval('arrayAux' + i + '[\'' + campo + '\']= arrayFilhosAvtMatric[' + i + '][\'' + campo + '\'];');
			
		}
		
        eval('arrayBackupAvt[' + i + '] = arrayAux' + i + ';');
	}

    for (i in arrayBensMatric) {
	
        eval('var arrayAux' + i + ' = new Object();');
		
        for (campo in arrayBensMatric[0]) {
		
            eval('arrayAux' + i + '[\'' + campo + '\']= arrayBensMatric[' + i + '][\'' + campo + '\'];');
			
		}
		
        eval('arrayBackupBens[' + i + '] = arrayAux' + i + ';');
				
	}
	
	/* Responsaveis legais */
    for (i in arrayFilhos) {
	
        eval('var arrayAux' + i + ' = new Object();');

        for (campo in arrayFilhos[0]) {
            eval('arrayAux' + i + '[\'' + campo + '\']= arrayFilhos[' + i + '][\'' + campo + '\'];');
		}

        eval('arrayBackupFilhos[' + i + '] = arrayAux' + i + ';');
	}

	
	return false;
}

function rollBack() {

	arrayFilhosAvtMatric.length = 0;
	arrayBensMatric.length = 0;
	arrayFilhos.length = 0;
	
    for (i in arrayBackupAvt) {
	
        eval('var arrayAux' + i + ' = new Object();');
		
        for (campo in arrayBackupAvt[0]) {
		
            eval('arrayAux' + i + '[\'' + campo + '\']= arrayBackupAvt[' + i + '][\'' + campo + '\'];');
			
		}
		
        eval('arrayFilhosAvtMatric[' + i + '] = arrayAux' + i + ';');
	}

    for (i in arrayBackupBens) {
	
        eval('var arrayAux' + i + ' = new Object();');
		
        for (campo in arrayBackupBens[0]) {
		
            eval('arrayAux' + i + '[\'' + campo + '\']= arrayBackupBens[' + i + '][\'' + campo + '\'];');
			
		}
		
        eval('arrayBensMatric[' + i + '] = arrayAux' + i + ';');
				
	}
		
			
    for (i in arrayBackupFilhos) {
	
        eval('var arrayAux' + i + ' = new Object();');
		
        for (campo in arrayBackupFilhos[0]) {
		
            eval('arrayAux' + i + '[\'' + campo + '\']= arrayBackupFilhos[' + i + '][\'' + campo + '\'];');
			
		}
		
        eval('arrayFilhos[' + i + '] = arrayAux' + i + ';');
				
	}
	return false;
}





function mostrarRotina(operacao) {

	showMsgAguardo('Aguarde, abrindo ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/matric/rotina.php', 
		data: {
			operacao: operacao,
			redirect: 'html_ajax'			
			}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
		},
        success: function (response) {
			$('#divRotina').html(response);
			
			if (operacao == 'VX' || operacao == 'LCD' || operacao == 'LCC') {
				buscaSenha(operacao)
            } else if (operacao == 'VJ') {
				manterOutros(nomeForm);
			}
			
			return false;
		}				
	});
	
	return false;
}

function buscaSenha(operacao) {

	hideMsgAguardo();		
		
	showMsgAguardo('Aguarde, abrindo ...');

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/matric/form_senha.php', 
		data: {
			operacao: operacao,
			redirect: 'script_ajax'			
			}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
		},
        success: function (response) {
		
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divConteudoRotina').html(response);
					exibeRotina($('#divRotina'));
					formataSenha();
                    $('#codsenha', '#frmSenha').unbind('keydown').bind('keydown', function (e) {
                        if (divError.css('display') == 'block') { return false; }
						// Se é a tecla ENTER, 
                        if (e.keyCode == 13) {
							validarSenha(operacao);
							return false;			
						} 
					});
					return false;
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			} else {
				try {
                    eval(response);
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}
		}				
	});
	
	return false;
}



function buscaContas() {

	hideMsgAguardo();		
		
	showMsgAguardo('Aguarde, listando as C/C ...');

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/matric/lista_contas.php', 
		data: {
			XMLContas: XMLContas,
			redirect: 'script_ajax'			
			}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
		},
        success: function (response) {
		
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divConteudoRotina').html(response);
					$('#tdTituloRotina').html('DUPLICAR C/C');
					exibeRotina($('#divRotina'));
					formataContas();
					return false;
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			} else {
				try {
                    eval(response);
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}
		}				
	});
	
	return false;
}

function formataSenha() {

	highlightObjFocus($('#frmSenha'));

    rOperador = $('label[for="operauto"]', '#frmSenha');
    rSenha = $('label[for="codsenha"]', '#frmSenha');
	
    rOperador.addClass('rotulo').css({ 'width': '165px' });
    rSenha.addClass('rotulo').css({ 'width': '165px' });

    cOperador = $('#operauto', '#frmSenha');
    cSenha = $('#codsenha', '#frmSenha');
	
    cOperador.addClass('campo').css({ 'width': '100px' }).attr('maxlength', '10');
    cSenha.addClass('campo').css({ 'width': '100px' }).attr('maxlength', '10');
	
    $('#divConteudoRotina').css({ 'width': '400px', 'height': '120px' });

	// centraliza a divRotina
    $('#divRotina').css({ 'width': '425px' });
    $('#divConteudo').css({ 'width': '400px' });
	$('#divRotina').centralizaRotinaH();
	
	hideMsgAguardo();		
    bloqueiaFundo($('#divRotina'));
	cOperador.focus();
	
	return false;
}

function formataContas() {
	
	var divRegistro = $('div.divRegistros');		
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);
	
    $('#divConteudoRotina').css({ 'width': '400px', 'height': '190px' });
	
    divRegistro.css({ 'height': '110px', 'padding-bottom': '2px' });
	
	var ordemInicial = new Array();
    ordemInicial = [[0, 1], [0, 1]];
			
	var arrayLargura = new Array();
	arrayLargura[0] = '100px';
	arrayLargura[1] = '1px';
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
		
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

	hideMsgAguardo();	
	
    bloqueiaFundo($('#divRotina'));
	
}

function selecionaConta(nrdconta) {
	
    var inpessoa = $('input[name="inpessoa"]:checked', '#frmCabMatric').val();
	
    nomeForm = (inpessoa == 1) ? 'frmFisico' : 'frmJuridico';
	operacao = 'BCC';
	nrdconta_org = normalizaNumero(nrdconta);
	manterOutros(nomeForm);
}

function validarSenha(operacao) {
		
	hideMsgAguardo();		
	
	// Situacao
    operauto = $('#operauto', '#frmSenha').val();
    var codsenha = $('#codsenha', '#frmSenha').val();
    var cddopcao = (operacao == 'LCD' || operacao == 'LCC') ? 'I' : 'X';
	
    showMsgAguardo('Aguarde, validando dados ...');

	$.ajax({		
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/matric/valida_senha.php',
			data: {
            operauto: operauto,
            codsenha: codsenha,
            cddopcao: cddopcao,
            redirect: 'script_ajax'
			}, 
        error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
			},
        success: function (response) {
				try {
					eval(response);
					// se não ocorreu erro, vamos gravar as alçterações
                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                    if (cddopcao == 'X') {
						manterOutros(nomeForm);
                    } else if (operacao == 'LCD') {
							selecionaConta(outconta);
                    } else if (operacao == 'LCC') {
							buscaContas();
						}
					}
					return false;
            } catch (error) {
					hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
				}
			}
		});	
		
	return false;
}

function manterOutros(nomeForm) {

    inmatric = $('#inmatric', '#frmCabMatric').val();
    cdagepac = $('#cdagepac', '#frmCabMatric').val();
    nmprimtl = $('#nmprimtl', '#' + nomeForm).val();
    nrcpfcgc = $('#nrcpfcgc', '#' + nomeForm).val();
    cdsitcpf = $('#cdsitcpf', '#' + nomeForm).val();
    dtdemiss = $('#dtdemiss', '#' + nomeForm).val();
    dtcnscpf = $('#dtcnscpf', '#' + nomeForm).val();
    dtnasctl = (nomeForm == 'frmFisico') ? $('#dtnasctl', '#' + nomeForm).val() : '';
    nmmaettl = (nomeForm == 'frmFisico') ? $('#nmmaettl', '#' + nomeForm).val() : '';
    nmcidade = $("#nmcidade", '#' + nomeForm).val();
    cdufende = $("#cdufende", '#' + nomeForm).val();
    inpessoa = $('input[name="inpessoa"]:checked', '#frmCabMatric').val();
	inhabmen = (nomeForm == 'frmFisico') ? $('#inhabmen', '#' + nomeForm).val() : '';
	dthabmen = (nomeForm == 'frmFisico') ? $('#dthabmen', '#' + nomeForm).val() : '';	
					
	// Normaliza os valores
    nmprimtl = normalizaTexto(nmprimtl);
    nrcpfcgc = normalizaNumero(nrcpfcgc);
    nrdconta = normalizaNumero(nrdconta);
	
    if (nomeForm == 'frmFisico') {
        if (!validaCpfCnpj(nrcpfcgc, 1) && operacao == 'XV') {
			hideMsgAguardo();
            showError('error', 'CPF inv&aacute;lido.', 'Alerta - Ayllos', 'focaCampoErro(\'nrcpfcgc\',\'frmFisico\');');
			return false; 
		}
        else if (!validaCpfCnpj(nrcpfcgc, 1) && operacao == 'JV') {
			hideMsgAguardo();
            showError('error', 'CPF inv&aacute;lido.', 'Alerta - Ayllos', 'focaCampoErro(\'nrcpfcgc\',\'frmFisico\');');
			return false; 
		}
    } else {
        if (!validaCpfCnpj(nrcpfcgc, 2) && operacao == 'XV') {
			hideMsgAguardo();
            showError('error', 'CNPJ inv&aacute;lido.', 'Alerta - Ayllos', 'focaCampoErro(\'nrcpfcgc\',\'frmJuridico\');');
			return false; 
		}
        else if (!validaCpfCnpj(nrcpfcgc, 2) && operacao == 'JV') {
			hideMsgAguardo();
            showError('error', 'CNPJ inv&aacute;lido.', 'Alerta - Ayllos', 'focaCampoErro(\'nrcpfcgc\',\'frmJuridico\');');
			return false; 
		}
	}	
	
	var mensagem = '';
	
	switch (operacao) {
        case 'CC': mensagem = 'Aguarde, verificando a cidade do CEP ...'; break;
		case 'LCD': mensagem = 'Aguarde, verificando situação do CPF/CNPJ ...'; break;
        case 'BCC': mensagem = 'Aguarde, gerando a C/C ...'; break;
        case 'DCC': mensagem = 'Aguarde, duplicando a C/C ...'; break;

    }
		
    if (mensagem != '') {
        showMsgAguardo(mensagem);
	}
	
  
    if (nmprimtl != '') {
        nmprimtl = removeAcentos(removeCaracteresInvalidos(nmprimtl));
    }

	$.ajax({		
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/matric/manter_outros.php',
		data: {
			nrdconta: nrdconta,	
			nmprimtl: nmprimtl,
			nrcpfcgc: nrcpfcgc, 
			inpessoa: inpessoa,
			cdagepac: cdagepac,
			rowidass: rowidass,	
			dtdemiss: dtdemiss,
			dtcnscpf: dtcnscpf,
			inmatric: inmatric,
			dtnasctl: dtnasctl,
			nmmaettl: nmmaettl,
			cdsitcpf: cdsitcpf,
			nmcidade: nmcidade,
			cdufende: cdufende,	
			operacao: operacao,		
			verrespo: verrespo,	
			permalte: permalte,
			nrdconta_org: nrdconta_org,
			nrdconta_dst: nrdconta,
			inhabmen: inhabmen,
			dthabmen: dthabmen,
			arrayFilhos: arrayFilhos,
			redirect: 'script_ajax'
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
		},
        success: function (response) {
			try {
				if (mensagem != '') {
					hideMsgAguardo();
				}
				eval(response);
				return false;
            } catch (error) {
				hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
			}
		}
	});
		
	return false;
}

function impressao_inclusao() {
	controlaOperacao("CR");
}

function efetuar_consultas() {
					
	showMsgAguardo('Aguarde, efetuando consultas ...');
				
	$.ajax({
        type: 'POST',
        url: UrlSite + 'includes/consultas_automatizadas/efetuar_consultas.php',
        data: {
            nrdconta: nrdconta,
            nrdocmto: 0,
            inprodut: 6, // Inclusao de conta
            insolici: 1,
            redirect: 'script_ajax'
		  },
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
		},
        success: function (response) {
			hideMsgAguardo();
			eval(response);
			return false;
		}
	});
	return false;
}

function limpaCharEsp(texto) {
    var chars = ["=", "%", "&", "#", "+", "?", "'", ",", ".", "/", ";", "[", "]", "!", "@", "$", "(", ")", "*", "|", ":", "<", ">", "~", "{", "~", "}", "~", "  "];
    for (var x = 0; x < chars.length; x++) {
        while (texto.indexOf(chars[x]) > 0) {
			texto = texto.replace(chars[x], ' ');
		}
	}
	return texto;
}


// Somente para nao dar erro quando fechada alguma rotina
function btnVoltar() {
	
}

function validaAcessoEexecuta(UrlSite, tipo) {
    //alert('in');

    //abrirRotina('', 'Consulta RFB', 'consulta_rfb', 'consulta_rfb', 'RFB');
    if((tipo) && (tipo == 'CPF')){
        var url = UrlSite + "includes/consulta_rfb/rfb/cpf/getcaptcha.php";
    }else{
        var url = UrlSite + "includes/consulta_rfb/rfb/cnpj/getcaptcha.php";
    }
    var metodo = '$("#divBloqueio").css("display", "")';
    var mensagem = "Site de consulta da Receita Federal do Brasil indisponível. Efetue a consulta manualmente. ";
    var tipo = "error";
    var titulo = "Alerta - Ayllos";
    var cDtConsulta = $('#dtcnscpf');
    //console.log('Primeiro ['+cDtConsulta.attr('receitadisponivel')+']');
    if ((!(cDtConsulta.attr('receitadisponivel')) || (cDtConsulta.attr('receitadisponivel') == undefined) || (cDtConsulta.attr('receitadisponivel') == 'vazio'))) {
        showMsgAguardo("Aguarde, consulta a receita ...");
        //console.log('Entrou ['+cDtConsulta.attr('receitadisponivel')+']');
        $('#nrcpfcgc', '#frmFisico').bind('blur', function(){
            //console.log('entrou - change nrcpfcgc');
            $('#dtcnscpf').attr('receitadisponivel', 'vazio');
        });

        $('#nrcpfcgc', '#frmJuridico').bind('blur', function(){
            //console.log('entrou - change nrcpfcgc');
            $('#dtcnscpf').attr('receitadisponivel', 'vazio');
        });

        $('#dtnasctl', '#frmFisico').bind('blur', function(){
            //console.log('entrou - change dtcnscpf');
            $('#dtcnscpf').attr('receitadisponivel', 'vazio');
        });

        //console.log('Antes do ajax ['+cDtConsulta.attr('receitadisponivel')+']');

        $.ajax({
            type: "GET",
            url: url,
            timeout: 10000,
            data: {},
            complete: function () {
                hideMsgAguardo();
            },
            error: function (objAjax, responseError, objExcept) {
                var cDtConsulta = $('#dtcnscpf');
                //console.log('Erro ['+cDtConsulta.attr('receitadisponivel')+']');
                cDtConsulta.attr('receitadisponivel', 'false');
                //console.log('Erro - deveria apresentar mensagem');
                showError(tipo, mensagem, titulo, metodo);
            },
            success: function (response) {
                var cDtConsulta = $('#dtcnscpf');
                if (response != "") {
                    //console.log('Sucesso ['+cDtConsulta.attr('receitadisponivel')+']');
                    cDtConsulta.attr('receitadisponivel', 'true');
                    abrirRotina('', 'Consulta RFB', 'consulta_rfb', 'consulta_rfb', 'RFB');
                } else {
                    //console.log('Erro2 ['+cDtConsulta.attr('receitadisponivel')+']');
                    cDtConsulta.attr('receitadisponivel', 'false');
                    showError(tipo, mensagem, titulo, metodo);
                }
		}				
	});
}


}

function populaCamposRelacionamento(dtconsultarfb, nrcpfcgc, cdsituacaoRfb, nmpessoa, nmpessoaReceita, tpsexo, dtnascimento,
								    tpdocumento, nrdocumento, idorgaoExpedidor, cdufOrgaoExpedidor, dtemissaoDocumento,
								    tpnacionalidade, inhabilitacaoMenor, dthabilitacaoMenor, cdestadoCivil, nmmae,
								    nmconjugue, nmpai, naturalidadeDsCidade, naturalidadeCdEstado,comercialNrddd, comercialNrTelefone,
								    residencialNrddd, residencialNrTelefone, celularCdOperadora, celularNrDdd, celularNrTelefone, residencialNrCep,
								    residencialNmLogradouro, residencialNrLogradouro, residencialDsComplemento, residencialNmBairro,
								    residencialCdEstado, residencialDsCidade, residencialTporigem, correspondenciaNrCep,
								    correspondenciaNmLogradouro, correspondenciaNrLogradouro, correspondenciaDsComplemento,
								    correspondenciaNmBairro, correspondenciaCdEstado, correspondenciaDsCidade, correspondenciaTporigem,
								    dsnacion, cdExpedidor, dsdemail, nmfantasia, comercialNrCep, comercialNmLogradouro, comercialNrLogradouro,
								    comercialDsComplemento, comercialNmBairro, comercialCdEstado, comercialDsCidade, comercialTporigem,
									nrInscricao, nrLicenca, cdNatureza, cdSetor, cdRamo, cdCnae, dtInicioAtividade, cdNaturezaOcupacao, 
									cdNacionalidade, cdCadastroEmpresa) {
	
	var bo = 'b1wgen0059.p';	
	var nomeForm = (inpessoa == 1) ? 'frmFisico' : 'frmJuridico';
	
	if(residencialNrCep != ""){
	
		if (operacao == 'CA' || operacao == "PA") { // Evitar a validacao quando acessada a opcao de ALTERACAO
			operacao = 'CC';
			return false;
		}
		
		operacao = "CC";
		
		manterOutros(nomeForm);
						
	}
	
	$('#tpdocptl', '#' + nomeForm).val(tpdocumento);
	$('#nrdocptl', '#' + nomeForm).val(nrdocumento);
	$('#nmttlrfb', '#' + nomeForm).val(nmpessoaReceita);
	$('#cdsitcpf', '#' + nomeForm).val(cdsituacaoRfb);
	$('#nmprimtl', '#' + nomeForm).val(nmpessoa);  
	$('#dtcnscpf', '#' + nomeForm).val(dtconsultarfb);		
	$('#dsdemail', '#' + nomeForm).val(dsdemail);
	$('#nrcepcor', '#' + nomeForm).val(correspondenciaNrCep);
	$('#dsendcor', '#' + nomeForm).val(correspondenciaNmLogradouro);
	$('#nrendcor', '#' + nomeForm).val(correspondenciaNrLogradouro);
	$('#complcor', '#' + nomeForm).val(correspondenciaDsComplemento);
	$('#nmbaicor', '#' + nomeForm).val(correspondenciaNmBairro) ;
	$('#cdufcorr', '#' + nomeForm).val(correspondenciaCdEstado);
	$('#nmcidcor', '#' + nomeForm).val(correspondenciaDsCidade);
	$('#idoricor', '#' + nomeForm).val(correspondenciaTporigem); 
	
	
	if (inpessoa == 1) {
		$('#dsnacion', '#' + nomeForm).val(dsnacion);
		$('#inhabmen', '#' + nomeForm).val(inhabilitacaoMenor);
		$('#dthabmen', '#' + nomeForm).val(dthabilitacaoMenor);		
		$('#cdestcvl', '#' + nomeForm).val(cdestadoCivil);	
		$('#tpnacion', '#' + nomeForm).val(tpnacionalidade);
		$('#cdoedptl', '#' + nomeForm).val(cdExpedidor);
		$('#cdnacion', '#' + nomeForm).val(cdNacionalidade);
		$('#cdufdptl', '#' + nomeForm).val(cdufOrgaoExpedidor);
		$('#dtemdptl', '#' + nomeForm).val(dtemissaoDocumento);
		$('#dtnasctl', '#' + nomeForm).val(dtnascimento); 
		$('#nmconjug', '#' + nomeForm).val(nmconjugue);
		$('#nmmaettl', '#' + nomeForm).val(nmmae);	
		$('#nmpaittl', '#' + nomeForm).val(nmpai);
		$('#dsnatura', '#' + nomeForm).val(naturalidadeDsCidade);
		$('#cdufnatu', '#' + nomeForm).val(naturalidadeCdEstado);
		$('#nrdddres', '#' + nomeForm).val(residencialNrddd);
		$('#nrtelres', '#' + nomeForm).val(residencialNrTelefone);
		$('#cdopetfn', '#' + nomeForm).val(celularCdOperadora);
		$('#nrdddcel', '#' + nomeForm).val(celularNrDdd);
		$('#nrtelcel', '#' + nomeForm).val(celularNrTelefone);
		$('#nrcepend', '#' + nomeForm).val(residencialNrCep);
		$('#dsendere', '#' + nomeForm).val(residencialNmLogradouro);
		$('#nrendere', '#' + nomeForm).val(residencialNrLogradouro);
		$('#complend', '#' + nomeForm).val(residencialDsComplemento);
		$('#nmbairro', '#' + nomeForm).val(residencialNmBairro);
		$('#cdufende', '#' + nomeForm).val(residencialCdEstado);
		$('#nmcidade', '#' + nomeForm).val(residencialDsCidade);
		$('#idorigee', '#' + nomeForm).val(residencialTporigem); 
		$('#cdocpttl', '#' + nomeForm).val(cdNaturezaOcupacao); 
		$('#nrcadast', '#' + nomeForm).val(cdCadastroEmpresa); 		 
				
		if (tpsexo == 1) {
			$('#sexoFem', '#' + nomeForm).prop('checked', false);	  	
			$('#sexoMas', '#' + nomeForm).prop('checked', true);
		}
		else {
			$('#sexoMas', '#' + nomeForm).prop('checked', false);
			$('#sexoFem', '#' + nomeForm).prop('checked', true);	  		
		}
		
		procedure = 'busca_tipo_nacionalidade';
		titulo = 'Tipo Nacionalidade';
		filtrosDesc = '';
		buscaDescricao(bo, procedure, titulo, 'tpnacion', 'destpnac', tpnacionalidade, 'destpnac', filtrosDesc, nomeForm);

		procedure = 'busca_estado_civil';
		titulo = 'Estado Civil';
		filtrosDesc = '';
		buscaDescricao(bo, procedure, titulo, 'cdestcvl', 'dsestcvl', cdestadoCivil, 'dsestcvl', filtrosDesc, 'frmFisico');
		
		procedure = 'BUSCOCUPACAO';
		titulo = 'Ocupação';
		filtrosDesc = '';
		buscaDescricao("ZOOM0001", procedure, titulo, 'cdocpttl', 'dsocpttl', cdNaturezaOcupacao, 'rsdocupa', filtrosDesc, 'frmFisico');
		
		procedure = 'BUSCANACIONALIDADES';
		titulo = 'Nacionalidade';
		filtrosDesc = '';
		buscaDescricao("ZOOM0001", procedure, titulo, 'cdnacion', 'dsnacion', cdNacionalidade, 'dsnacion', filtrosDesc, 'frmFisico');
		
	}
	else if (inpessoa == 2){		
		$('#nmfansia', '#' + nomeForm).val(nmfantasia);
		$('#nrcepend', '#' + nomeForm).val(comercialNrCep);
		$('#dsendere', '#' + nomeForm).val(comercialNmLogradouro);
		$('#nrendere', '#' + nomeForm).val(comercialNrLogradouro);
		$('#complend', '#' + nomeForm).val(comercialDsComplemento);
		$('#nmbairro', '#' + nomeForm).val(comercialNmBairro);
		$('#cdufende', '#' + nomeForm).val(comercialCdEstado);
		$('#nmcidade', '#' + nomeForm).val(comercialDsCidade);
		$('#idorigee', '#' + nomeForm).val(comercialTporigem); 	
		$('#nrdddtfc', '#' + nomeForm).val(comercialNrddd);
		$('#nrtelefo', '#' + nomeForm).val(comercialNrTelefone);
		$('#nrinsest', '#' + nomeForm).val(nrInscricao); 		
		$('#nrlicamb', '#' + nomeForm).val(nrLicenca);
		$('#natjurid', '#' + nomeForm).val(cdNatureza);		
		$('#cdseteco', '#' + nomeForm).val(cdSetor);
		$('#cdrmativ', '#' + nomeForm).val(cdRamo);
		$('#cdcnae', '#' + nomeForm).val(cdCnae);
		$('#dtiniatv', '#' + nomeForm).val(dtInicioAtividade);
		
		procedure = 'busca_natureza_juridica';
		titulo = 'Nat. Jurídica';
		filtrosDesc = '';
		buscaDescricao(bo, procedure, titulo, 'natjurid', 'rsnatjur', cdNatureza, 'rsnatjur', filtrosDesc, 'frmJuridico');
		
		procedure = 'busca_setor_economico';
		titulo = 'Setor Econômico';
		filtrosDesc = '';
		buscaDescricao(bo, procedure, titulo, 'cdseteco', 'nmseteco', cdSetor, 'nmseteco', filtrosDesc, 'frmJuridico');				

		procedure = 'busca_ramo_atividade';
		titulo = 'Ramo Atividade';
		filtrosDesc = 'cdseteco';
		buscaDescricao(bo, procedure, titulo, 'cdrmativ', 'dsrmativ', cdRamo, 'nmrmativ', filtrosDesc, 'frmJuridico');

		procedure = 'BUSCA_CNAE';
		titulo = 'CNAE';
		filtrosDesc = 'flserasa|2';
		buscaDescricao('ZOOM0001', procedure, titulo, 'cdcnae', 'dscnae', cdCnae, 'dscnae', filtrosDesc, 'frmJuridico');				
		
	}

}