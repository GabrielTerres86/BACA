/*!
 * FONTE        : funcoes.js
 * CRIAÇÃO      : David
 * DATA CRIAÇÃO : Julho/2007
 * OBJETIVO     : Biblioteca de funções JavaScript
 * --------------  
 * ALTERAÇÕES   :
 * --------------
 * 000: [25/07/2008] Guilherme        (CECRED) : Incluir funções para F2
 * 000: [06/10/2008] David            (CECRED) : Novas funções para validar senha de coordenador
 * 000: [12/08/2009] Guilherme        (CECRED) : Incluir funções enterTab
 * 000: [22/10/2009] David            (CECRED) : Ajuste na função showError
 * 001: [11/02/2010] Rodolpho Telmo      (DB1) : Criado componente "limpaFormulario"
 * 002: [04/03/2010] Rodolpho Telmo      (DB1) : Criada função "zebradoLinhaTabela"
 * 003: [11/03/2010] Rodolpho Telmo      (DB1) : Criada função "trim"
 * 004: [11/03/2010] Rodolpho Telmo      (DB1) : Criada função "exibeRotina"
 * 005: [11/03/2010] Rodolpho Telmo      (DB1) : Criada função "fechaRotina"
 * 006: [11/03/2010] Rodolpho Telmo      (DB1) : Criada função "bloqueiaFundo"
 * 007: [11/03/2010] Rodolpho Telmo      (DB1) : Criada função "setCenterPositionH"
 * 008: [26/03/2010] Gabriel Santos      (DB1) : Criada função "number_format", similar á do php
 * 009: [29/03/2010] Rodolpho Telmo      (DB1) : Criada função "in_array", similar á do php
 * 010: [30/03/2010] Rodolpho Telmo      (DB1) : Criada função "layoutPadrao"
 * 011: [31/03/2010] Rodolpho Telmo      (DB1) : Plugin HotKeys aplicando padrão para acesso as funcionalidades dos botões em tela 
 * 012: [07/04/2010] Rodolpho Telmo      (DB1) : Criada função montaHtmlImpressao
 * 013: [16/04/2010] Rodolpho Telmo      (DB1) : Criado plugin jQuery limitaTexto
 * 014: [26/04/2010] Rodolpho Telmo      (DB1) : Criado função "revisaoCadastral" genérica
 * 015: [04/05/2010] Rodolpho Telmo      (DB1) : Criado função "formataTabela"
 * 016: [04/05/2010] Rodolpho Telmo      (DB1) : Criado função "zebraTabela"
 * 017: [17/05/2010] Rodolpho Telmo      (DB1) : Alterada função "atalhoTeclado"
 * 018: [18/05/2010] Rodolpho Telmo      (DB1) : Seleção de registros pelo teclado
 * 019: [18/05/2010] Rodolpho Telmo      (DB1) : Permitir Drag nas mensagens de Erro e Confirmação.
 * 020: [18/05/2010] Rodolpho Telmo      (DB1) : Criado plugin jQuery escondeMensagem
 * 021: [20/05/2010] Rodolpho Telmo      (DB1) : Criada função normalizaNumero
 * 022: [21/05/2010] Rodolpho Telmo      (DB1) : Manutenção das HotKeys sem o uso do ALT
 * 023: [21/05/2010] Rodolpho Telmo      (DB1) : HotKeys F8 para limpar campos
 * 024: [21/05/2010] Rodolpho Telmo      (DB1) : HotKeys F7 para abrir Telas de Pesquisas
 * 025: [25/05/2010] Rodolpho Telmo      (DB1) : Criada função selecionaRegistro
 * 026: [17/06/2010] Rodolpho Telmo      (DB1) : Criada função focaCampoErro
 * 027: [18/06/2010] Rodolpho Telmo      (DB1) : Criado nos campos cpf e cnpj 
 * 028: [18/06/2010] Rodolpho Telmo      (DB1) : Criada função verificaContadorSelect
 * 029: [18/06/2010] Gabriel Santos      (DB1) : Criada função implode
 * 030: [18/06/2010] Gabriel Santos      (DB1) : Criada função exibirMensagens
 * 031: [26/06/2010] Rodolpho Telmo      (DB1) : Criada função desbloqueia
 * 032: [29/06/2010] Rodolpho Telmo      (DB1) : Criada função truncar
 * 033: [30/06/2010] Rodolpho Telmo      (DB1) : Criada função verificaSemaforo
 * 034: [12/07/2010] Rodolpho Telmo      (DB1) : Criada função jQuery "formataRodapePesquisa"
 * 035: [15/07/2010] Rodolpho Telmo      (DB1) : Controle de identificação se as teclas shift e control estão pressionadas
 * 036: [16/07/2010] Rodolpho Telmo      (DB1) : Criada função "removeOpacidade"
 * 037: [11/08/2010] Gabriel Capoia      (DB1) : Criada função "mktime", similar á do php
 * 038: [11/08/2010] Gabriel Capoia      (DB1) : Criada função "dataParaTimestamp"
 * 039: [24/02/2011] Jorge 		      (CECRED) : Alterada função "showError"
 * 040: [18/04/2011] Rogerius e Rodolpho (DB1) : Manutenção dos HotKeys para a rotina do Zoom Genérico do Endereço
 * 041: [28/04/2011] Rogerius e Rodolpho (DB1) : Criada a função "verificaTipoPessoa"
 * 042: [28/04/2011] Rogerius e Rodolpho (DB1) : Criado extensão jQuery "addClassCpfCnpj"
 * 043: [28/04/2011] Rodolpho Telmo      (DB1) : Criado extensão jQuery "ponteiroMouse"
 * 044: [28/04/2011] Rodolpho Telmo      (DB1) : Adicionado comportamento nas extensões "desabilitaCampo" e "habilitaCampo"
 * 045: [14/05/2011] Rodolpho Telmo      (DB1) : Manutenção das funções "desabilitaCampo" e "habilitaCampo"
 * 046: [13/06/2011] Rogérius Militão    (DB1) : Criado a função "converteMoedaFloat"
 * 047: [16/06/2011] Jorge   		  (CECRED) : Alterada funcao "showError"
 * 048: [19/07/2011] Rogérius Militão 	 (DB1) : Criado a função "mascara" 
 * 049: [03/08/2011] Rogérius Militão 	 (DB1) : Manutenção da funcao "formataTabela" 
 * 050: [19/08/2011] Rogérius Militão 	 (DB1) : Manutenção da funcao "atalhoTeclado", adicionado a opcao btsair
 * 051: [26/08/2011] Adriano		  (CECRED) : Alterado a mascara email na funcao layoutPadrao.
 * 052: [30/08/2011] Rogérius Militão 	 (DB1) : Manutenção nas setas que percorre os registros da tabela.
 * 053: [22/09/2011] Rogérius Militão 	 (DB1) : Manutenção na tecla de atalho F1, para nao abrir o HELP no IE.
 * 054: [22/11/2011] Rogérius Militão	 (DB1) : Alterado o evento para a classe INPUT.PESQUISA na funcao layoutPadrao.
 * 055: [28/11/2011] David            (CECRED) : Permitir tecla backspace somente em campos INPUT e TEXTAREA, para inibir a opção VOLTAR do browser.
 * 056: [16/12/2011] David            (CECRED) : Substituir método $(elem).attr() por $(elem).prop(). Necessário para propriedades 'disabled', 'readonly' e 'checked'.
 * 057: [08/02/2012] Rogérius Militão 	 (DB1) : Adicionada a linha normalizaNumero(conta) na função validaNroConta().
 * 058: [08/02/2012] Rogérius Militão 	 (DB1) : Adicionada a linha normalizaNumero(cpfCnpj) na função validaCpfCnpj().
 * 059: [10/02/2012] Rogérius Militão 	 (DB1) : Criado a função "isHabilitado( objeto )" para verificar se o campo está habilitado atraves das classes.
 * 060: [10/02/2012] Rogérius Militão 	 (DB1) : Manutenção "desabilitaCampo", adicionado para remover as classes que tem focu.
 * 061: [17/02/2012] Rogérius Militão 	 (DB1) : Manutenção layoutPadrao, na opcao "pesquisa", alterado "hasClass('campo')" pela funcao "isHabilitado".
 * 062: [17/02/2012] Rogérius Militão 	 (DB1) : Manutenção ponteiroMouse, alterado "hasClass('campo')" pela funcao "isHabilitado".
 * 063: [29/03/2012] Rogérius Militão	 (DB1) : Manutenção layoutPadrao, alterado selector "a" para nao pegar campos botao $('a[class!="botao"]','.formulario').attr('tabindex','-1');	
 * 064: [26/04/2012] Rogérius Militão	 (DB1) : Manutenção layoutPadrao, no input.cpf e input.cnpj foi adicionado a "$(this).removeClass('campo').addClass('campoFocusIn');" para tratar o novo focu;
 * 065: [01/06/2012] David Kistner    (CECRED) : Criada funcao CheckNavigator()
 * 066: [03/10/2012] Adriano Marchi   (CECRED) : Incluido a classe porcento_n, moeda_15 na função layoutPadrao.
 * 067: [04/04/2014] Carlos           (CECRED) : Incluida a funcao validaEmail.
 * 068: [13/06/2014] Douglas          (CECRED) : Ajustado validaEmail para utilizar expressão regular. Antes não validava o domínio do email. (Chamado 122814)
 * 069: [20/06/2014] James			  (CECRED) : Incluido a funcao replaceAll
 * 070: [02/07/2014] James			  (CECRED) : Incluido a função base64_decode();
 * 071: [02/07/2014] James		      (CECRED) : Incluido a função base64_encode();
 * 072: [19/12/2014] Kelvin 		  (CECRED) : Adicionado nova mascara de contrato (z.zzz.zzz.zz9) e (zz.zzz.zz9)  (Chamado 233714).
 * 073: [17/03/2015] Jonata           (Rkam)   : Ajuste na rotina de pedir senha do coordenador.
 * 074: [18/03/2015] Carlos           (CECRED) : Criada a função trocaClass(classAnterior,classAtual) para trocar uma class css por outra.
 * 075: [13/07/2015] Gabriel          (RKAM)   : Criada funcao controlaFocoEnter() para automatizar o foco no ENTER dos campos de determinado frame. 
 * 076: [04/09/2015] Adriano		  (CECRED) : Ajuste para corrigir o problema de formatação do arquivo.
 * 077: [15/10/2015] Kelvin			  (CECRED) : Criada funcao removeCaracteresInvalidos() e removeAcentos()
												 para auxiliar na remoção dos caracteres que invalidam o xml.
 * 078: [28/10/2015] Heitor           (RKAM)   : Criada funcao utf8_decode para utilizacao de acentuacao php x js
 * 079: [23/12/2015] Adriano          (CECRED) : Ajuste na rotina layoutPadrao para criar o tratamento para a classe porcento_4. 
 * 080: [23/03/2016] James            (CECRED) : Criado a classe Taxa no INPUT
 * 081: [27/06/2016] Jaison/James     (CECRED) : Criacao de glb_codigoOperadorLiberacao.
 * 082: [19/07/2016] Andrei           (RKAM)   : Ajuste na rotina layoutPadrao para incluir o tratamento para a classe porcento_6. 
 * 083: [12/07/2016] Evandro          (RKAM)   : Adicionado a função atalhoTeclado condição para fechar telas (divMsgsAlerta e divAnotacoes) com ESC ou F4
 * 084: [18/08/2016] Evandro          (RKAM)   : Adicionado condição na função showConfirmacao para voltar foco a classe FirstInputModal, ao fechar janela
 * 085: [21/10/2016] Odirlei Busana  (AMcom)   : Adicionado funçoes para chamada de tela de  solicitação de senha do cooperado. PRJ319 - SMS Cobrança
 * 080: [18/10/2016] Kelvin			  (CECRED) : Funcao removeCaracteresInvalidos nao estava removendo os caracteres ">" e "<", ajustado 
												 para remover os mesmos e criado uma flag para identificar se deve remover os acentos ou nao.
 * 081: [08/02/2017] Kelvin		      (CECRED) : Adicionado na funcao removeCaracteresInvalidos os caracteres ("º","°","ª") para ajustar o chamado 562089.
 * 086: [24/03/2017] JOnata           (RKAM)   : Ajuste devido a inclusão da include para soliticar senha do cartão magnético (M294).
 * 086: [12/04/2017] Reinert				   : Ajustado funcao RemoveCaracteresInvalidos para ignorar caractere "#".												 
 * 090: [13/03/2017] Jaison/Daniel    (CECRED) : Criada a funcao retornaDateDiff.
 * 091: [05/04/2017] Lombardi         (CECRED) : Criadas as funcoes lpad e rpad.
 * 092: [15/09/2017] Kelvin 		  (CECRED) : Alterações referente a melhoria 339.
 * 093: [06/10/2017] Kelvin 		  (CECRED) : Ajuste para ignorar campos com display none na funcao controlaFocoEnter. (PRJ339 - Kelvin).
 * 094: [15/12/2017] Jean Michel      (CECRED) : Inclusão da classe coordenadas para campo.
 * 095: [06/02/2018] Lombardi 		  (CECRED) : Colocado tratativa para tirar o background quando o type for 'radio'. (PRJ366)
 * 096: [21/03/2018] Reinert		  (CECRED) : Adicionado divUsoGAROPC na lista de divs reposicionaveis. 
 * 097: [02/04/2018] Lombardi 		  (CECRED) : Adicionado função validaAdesaoProduto para verificar se o tipo de conta permite a contratação do produto. (PRJ366)
 * 098: [07/04/2018] Renato Darosci   (SUPERO) : Ajustar controle de navegação para que a funcionalidade F1 funcione também na tela GAROPC. (PRJ404). 
 * 099: [16/04/2018] Lombardi 		  (CECRED) : Adicionado função validaValorProduto para verificar se o tipo de conta permite o valor da contratação do produto. (PRJ366)
 * 100: [26/04/2018] Christian		  (CECRED) : Tratativas no controle de tecla ESC. Chamadas a metodos indevidos, causando erros apenas na execucao do Ayllos embarcado no CRM.
 * 101: [27/08/2018] Marco Amorim     (Mout'S) : Criada a Função para remover Todos os Caracteres epeciais e acentos.
 * 102: [12/12/2018] Anderson-Alan    (Supero) : Criado funções para controle do novo formulário de Assinatura Eletronica com Senha do TA ou Internet. (P432)
 * 103: [30/01/2019] Luiz Otavio Momm (AMCOM)  : Adicionada a tela de associado para pesquisa por nome e cpfcgc e adicionado o evento de sair pelo teclado
 * 104: [07/06/2019] Jackson Barcellos (AMcom) : Manutenção da funcao "formataTabela" Adicionado metodo click
*/ 	 

var UrlSite     = parent.window.location.href.substr(0,parent.window.location.href.lastIndexOf("/") + 1); // Url do site
var UrlImagens	= UrlSite + "imagens/"; // Url para imagens     
var nmrotina    = ''; // Para armazenar o nome da rotina no uso da Ajuda (F2)
var semaforo	= 0;  // Semáforo para não permitir chamar a função controlaOperacao uma atrás da outra

var divRotina; 	// Variável que representa a Rotina com a qual está se trabalhando
var divError;  	// Variável que representa a div de Erros do sistema, usada para mensagens de Erros e Confirmações
var divConfirm;	// Variável que representa a div de Erros do sistema, usada para mensagens de Erros e Confirmações

var exibeAlerta = true;		// Variável lógica (boolean) glogal que libera a função "alerta()" chamar os alert() do javascript
var shift = false; 	// Variável lógica (boolean) glogal que indica se a tecla shift está prescionada
var control = false; 	// Variável lógica (boolean) glogal que indica se a tecla control está prescionada

var glb_codigoOperadorLiberacao = 0; // Global com operador de liberacao
	
var possui_senha_internet = false; //Variavel para armazenar retorno da funcao de verificacao de senha de internet
var idseqttl_senha_internet = 0; //Variavel para armazenar retorno da funcao de verificacao de senha de internet
	
$(document).ready(function () {

	// 053
	document.onhelp = new Function("return false"); // Previne a abertura do help no IE
	window.onhelp 	= new Function("return false"); // Previne a abertura do help no IE

	$("body").append('<div id="divAguardo"></div><div id="divError"></div><div id="divConfirm"></div><div id="divBloqueio"></div><div id="divF2"></div><div id="divUsoGenerico"></div><iframe src="' + UrlSite + 'blank.php" id="iframeBloqueio"></iframe>');
	
	// Inicializo a variável divRotiva e divError com o respectivo seletor jQuery da div
	// A qualquer momento pode-se alterar o valor da divRotina com a Rotina que está sendo implementada
	// O valor do divError não tem motivos para ser alterado
	divRotina 	= $('#divRotina');
	divError  	= $('#divError');	
	divConfirm  = $('#divConfirm');	
	
	// Iniciliza tirando os eventos para posteriormente bindá-los corretamente
	$(this).unbind('keyup').unbind('keydown').unbind('keypress');	
	
	$(this).unbind("keydown.backspace").bind("keydown.backspace",function(e) {
		if (getKeyValue(e) == 8) { // Tecla BACKSPACE
			var targetType = e.target.tagName.toUpperCase();			
			// Permite a tecla BACKSPACE somente em campos INPUT e TEXTAREA e se estiverem habilitados para digitação			
			if ((targetType == "INPUT" || targetType == "TEXTAREA") && !e.target.disabled && !e.target.readonly) return true;							
			return false; 
		}		
		return true;
	});
	
	$.ajaxSetup({ data: { sidlogin: $("#sidlogin","#frmMenu").val() } });
	
	/*!
	 * ALTERAÇÃO     : 022
	 * OBJETIVO      : Prevenir o comportamento padrão do browser em relação as teclas F1 a F12, para posteriormente utilizar estas teclas para fins específicos 
	 * FUNCIONAMENTO : Captura o evento da tecla pressionada e associa á função previneTeclasEspeciais funcionando para IE, Chrome e FF
	 */	
	$(this).keydown( previneTeclasEspeciais );
	function previneTeclasEspeciais(event){		
		// Essecial para funcionar no IE 
		var e = (window.event) ? window.event : event;
		// Verifica se a tecla pressionada é F1 a F12 retirando a F5
		if ( ( e.keyCode >= 112 ) && ( e.keyCode <= 123 ) && ( e.keyCode != 116 ) ) { 
			if ( $.browser.msie ) {
				e.returnValue	= false; // Previne o comportamento padrão no IE
				e.cancelBubble 	= true;  // Previne o comportamento padrão no IE
				e.keyCode       = 0;     // Previne o comportamento padrão no IE
				document.onhelp = new Function("return false"); // Previne a abertura do help no IE
				window.onhelp 	= new Function("return false"); // Previne a abertura do help no IE
			} else {
				e.stopPropagation(); // Previne o comportamento padrão nos browsers bons
				e.preventDefault();  // Previne o comportamento padrão nos browsers bons
			}
		}
	}
	
	/*!
	 * ALTERAÇÃO     : 035
	 * OBJETIVO      : Controle de identificação se as teclas shift e control estão pressionadas
	 * FUNCIONAMENTO : Ao pressionar qualquer tecla, o sistema verifica se é a shift/control, caso verdadeiro seta a variável global 
	 *                 correspondente para TRUE. Ao liberar a tecla, o sistema verifica novamente se é shift/control, caso afirmativo
	 *                 volta os valores das variáveiss globais correspondentes para FALSE.
	 */		
	$(this).keydown( function(e) {
		if (e.which == 16 ) { shift 	= true; } // Tecla Shift		
		if (e.which == 17 ) { control 	= true; } // Tecla Control
	}).keyup( function(e) {
		if (e.which == 16 ) { shift 	= false; } // Tecla Shift		
		if (e.which == 17 ) { control 	= false; } // Tecla Control
	});
	
	/*!
	 * ALTERAÇÃO  : 018 e 051
	 * OBJETIVO   : Teclas de atalho para selecinar os registro nas tabelas pelo teclado, utilizando as setas direcionais "para cima" e "para baixo"
	 * OBSERVAÇÃO : As tabelas devem estar criadas dentro do padrão adotado nas rotinas no módulo de CONTAS
	 */	
	$(this).keyup( function(e) { 			
		var tecla = e.which;	
		if ( (tecla == 38) || (tecla == 40) ) {
			
			var nrLinhaSelecao;	
			var divRegistro;	
			var divRegistros;	
			
			if ( divError.css('display') == 'block' || divConfirm.css('display') == 'block' ){
				return true;
			}else if ( $('#divUsoGenerico').css('visibility') == 'visible' ){
				divRegistros = $('div.divRegistros','#divUsoGenerico');
			}else if( $('#divRotina').css('visibility') == 'visible' && $('div.divRegistros','#divRotina').length ){
				divRegistros = $('div.divRegistros','#divRotina');
			}else if( $('#divMatric').css('visibility') == 'visible' || $('#divMatric').css('visibility') == 'inherit' ){
				divRegistros = $('div.divRegistros','#divMatric');
			}else {
				if ( $('#divRotina').css('visibility') == 'visible') return false;
				divRegistros = $('div.divRegistros');
			}		
				
			divRegistros.each( function() {
				if ( $(this).css('display') == 'block' ) {
					divRegistro = $(this);
				}				
			});			
			
			var tabela = $('table', divRegistro);
			
			var qtdeRegistros = $('table > tbody > tr', divRegistro).length;
			// Se possui um ou nenhum registro, não fazer nada
			if ( qtdeRegistros > 1 ) { 
				// Descobre qual linha está selecionada
				$('table > tbody > tr', divRegistro).each( function(i) {
					if ( $(this).hasClass( 'corSelecao' ) ) {
						nrLinhaSelecao = i;
					}					
				});	
				// Se teclou seta para cima e não é a primeira linha, selecionar registro acima
                if ((tecla == 38) && (nrLinhaSelecao > 0)) {
                    $('table', divRegistro).zebraTabela(nrLinhaSelecao - 1);
                    $('tbody > tr:eq(' + (nrLinhaSelecao - 1) + ') > td', tabela).first().focus();
				}
				// Se teclou seta para baixo e não é a ultima linha, selecionar registro abaixo
                if ((tecla == 40) && (nrLinhaSelecao < qtdeRegistros - 1)) {
                    $('table', divRegistro).zebraTabela(nrLinhaSelecao + 1);
                    $('tbody > tr:eq(' + (nrLinhaSelecao + 1) + ') > td', tabela).first().focus();
				}			
			}
		}
	});				
	
	/*!
	 * ALTERAÇÃO  : 011
	 * OBJETIVO   : Teclas de atalho (HotKeys) para os botões da tela corrente (em exibição)
	 * Padrão     : (   F1   ) -> Botão Salvar (Concluir)
	 *              (   F2   ) -> Ajuda da CECRED
	 *              (   F3   ) -> Botão Inserir
	 *              (   F4   ) -> Botão Voltar (ESC)
	 *              (   F5   ) -> Atualizar página ( não presica implementar, pois é padrão do Browser )
	 *              (   F7   ) -> Abre Pesquisa ( Implementação na função layoutrPadrao() )
	 *              (   F8   ) -> Limpar Campo  ( Implementação na função layoutrPadrao() )
	 *              (   F9   ) -> Botão Alterar
	 *              (   F10  ) -> Botão Consultar
	 *              (   F11  ) -> Botão Limpar
	 *              ( DELETE ) -> Botão Excluir
	 *              (   ESC  ) -> Botão Voltar
	 *              ( INSERT ) -> Botão Inserir	 
	 * OBSERVAÇÃO : Para que os atalhos funcionem, os botões em tela devem estar com a propriedade "id" igual a um dos valores abaixo:
	 *              btIncluir | btExcluir | btVoltar | btAlterar | btSalvar | btConsultar | btLimpar
	 */	 
    $(this).keyup(atalhoTeclado);
	function atalhoTeclado(e) {

        var arrayTeclas = new Array();
        arrayTeclas[13] = 'btEnter';		// ENTER		
        arrayTeclas[45] = 'btIncluir';		// INSERT
        arrayTeclas[46] = 'btExcluir';		// DELETE
        arrayTeclas[27] = 'btVoltar';		// ESC - VOLTAR
		arrayTeclas[112] = 'btSalvar';		// F1  - SALVAR
		arrayTeclas[114] = 'btIncluir';		// F3  - INSERIR
		arrayTeclas[115] = 'btVoltar';		// F4  - VOLTAR	
		arrayTeclas[120] = 'btAlterar';		// F9  - ALTERAR
		arrayTeclas[121] = 'btConsultar';   // F10 - CONSULTAR		
		arrayTeclas[122] = 'btLimpar';      // F11 - LIMPAR
		
		// Se o divAguardo estiver sendo exibido, então não aceitar atalhos do teclado
        if ($('#divAguardo').css('display') == 'block') { return true; }

		/*!
		 * ALTERAÇÃO : 017
		 * OBJETIVO  : Quando o divError estiver visível na tela, e a tecla é ESC (27) ou F4 for pressionada, então chamar o clique do botão "Não" do divError,
		 *             pois caso contrário a função chama o clique o botão com o ID = 'btVoltar'
		 */
        if (divError.css('display') == 'block') {
			// Se teclar ENTER (13)	
			if (e.which == 13) {
				// $('#btnError','#divError').click();
			}			
			return true;				

        } else if (divConfirm.css('display') == 'block') {
			// Se teclar ESC (27) ou F4 (115)
            if ((e.which == 27) || (e.which == 115)) {
                $('#btnNoConfirm', '#divConfirm').click();
			}
			return true;
			
		// Se for tecla F2, abre ajuda padrão		
        } else if (e.keyCode == 113) {
			mostraAjudaF2();
			return true;			
			

		// Se for as teclas ENTER | INSERT | DELET | ESC | F1 | F3 | F4 | F9 | F10 | F11
        } else if (in_array(e.keyCode, [13, 35, 45, 46, 27, 112, 114, 115, 120, 121, 122])) {
			
            if (typeof e.result == 'undefined') {
			
				// Se a pesquisa estiver aberta, e a tecla é ESC (27) ou F4, então ativar o botão fechar da pesquisa				
				// ALTERAÇÃO 040
                if ($('#divFormularioEndereco').css('visibility') == 'visible') {
                    if (e.which == 27 || e.which == 115) {
                        $('.fecharPesquisa', '#divFormularioEndereco').click();
					} else {
                        $('#' + arrayTeclas[e.which] + ':visible', '#divFormularioEndereco').click();
					}					
					return true;
				
				// ALTERAÇÃO 040
                } else if ($('#divPesquisaEndereco').css('visibility') == 'visible') {
                    if (e.which == 27 || e.which == 115) {
                        $('.fecharPesquisa', '#divPesquisaEndereco').click();
					} else {
                        $('#' + arrayTeclas[e.which] + ':visible', '#divPesquisaEndereco').click();
					}					
					return true;				
					
                } else if ($('#divPesquisaAssociado').css('visibility') == 'visible') {
                    if (e.which == 27 || e.which == 115) {
                        $('.fecharPesquisa', '#divPesquisaAssociado').click();
					} 
					return true;						
				// ALTERAÇÃO 103
				} else if ($('#divPesquisaAssociadoDadosCadastrais').css('visibility') == 'visible') {
					if (e.which == 27 || e.which == 115) {
						$('.fecharPesquisa', '#divPesquisaAssociadoDadosCadastrais').click();
					} 
					return true;
				// ALTERAÇÃO 103
                } else if ($('#divMsgsAlerta').css('visibility') == 'visible') {
                    if (e.which == 27 || e.which == 115) {
                        encerraMsgsAlerta();
					} 
					return true;														
				
                } else if ($('#divAnotacoes').css('visibility') == 'visible') {
                    if (e.which == 27 || e.which == 115) {
                        encerraAnotacoes();
                    }
                    return true;

                } else if ($('#divPesquisa').css('visibility') == 'visible') {
                    if (e.which == 27 || e.which == 115) {
                        $('.fecharPesquisa', '#divPesquisa').click();
                    }
                    return true;

				// Verifica HotKeys válidos					
                } else if (in_array(e.which, [13, 35, 45, 46, 27, 112, 114, 115, 120, 121, 122])) {
					
					// Se a divUsoGenerico estiver visivel, então chamar os click os botões contidos nela
                    if ($('#divUsoGenerico').css('visibility') == 'visible') {
                        $('#' + arrayTeclas[e.which] + ':visible', '#divUsoGenerico').click();
						return true; 
					
					// Se a divRotina estiver visivel, então chamar os click os botões contidos nela
					// 050 - adicionado a opcao btsair
                    } else if ($('#divRotina').css('visibility') == 'visible') {
                        if ($('#divRotina').find('#' + arrayTeclas[e.which]).length) {
							if ($('#btConfirmar', '#divUsoGAROPC').css('visibility') == 'visible') {
								$('#btConfirmar' + ':visible', '#divUsoGAROPC').click();
							} else { 
                            $('#' + arrayTeclas[e.which] + ':visible', '#divRotina').click();
							}
                        } else if ($('#divRotina').find('#btSair').length && e.which == 27) {
                            $('#btSair:visible', '#divRotina').click();
						}
						return true; 	
					
					// Se é a tela do Matric, chamar os click dos botões contidos nela
                    } else if ($('#divMsgsAlerta').css('visibility') == 'visible') {
                        $('#' + arrayTeclas[e.which] + ':visible', '#divMsgsAlerta').click();
						return true; 
					
					// Se é a tela do Matric, chamar os click dos botões contidos nela
                    } else if ($('#divAnota').css('visibility') == 'visible' || $('#divAnota').css('visibility') == 'inherit') {
                        $('#' + arrayTeclas[e.which] + ':visible', '#divAnota').click();
						return true;

					// Se a divRotina estiver visivel, então chamar os click os botões contidos nela
                    } else if ($('#divTela').css('visibility') == 'visible' || $('#divTela').css('visibility') == 'inherit') {
                        $('#' + arrayTeclas[e.which] + ':visible', '#divTela').click();
						return true; 						
					
					// Se é a tela do Matric, chamar os click dos botões contidos nela
                    } else if ($('#divMatric').css('visibility') == 'visible' || $('#divMatric').css('visibility') == 'inherit') {
						
						//Se é pessoa juridica verifico se é um evento do botão de procuradores
                        if ($('#frmJuridico', '#divMatric').css('visibility') == 'visible' || $('#frmJuridico', '#divMatric').css('visibility') == 'inherit') {
							
                            var metodo = $('#' + arrayTeclas[e.which] + 'Proc:visible', '#divMatric').attr('onClick');
                            metodo = (typeof metodo == 'undefined') ? '' : metodo.toString();
							
                            if ($.browser.msie) {
                                metodo = metodo.replace('return false;', '');
                                metodo = metodo.replace('function anonymous()', '');
                                metodo = metodo.replace('{', '');
                                metodo = metodo.replace('}', '');
                            } else {
                                metodo = metodo.replace('return false;', '');
							}	
												
                            eval(metodo);
						}
                        $('#' + arrayTeclas[e.which] + ':visible', '#divMatric').click();
						return true; 
					}						
					return true; 				
				}
			}
		}
	}
	
	/*!
	 * ALTERAÇÃO  : 019 | 040 | 103
	 * OBJETIVO   : Tornar as mensagens padrão de Erro ou Confirmação "Movimentáveis", permitindo arrastar a janela para qualquer direção, com o objetivo
	 *              de desobstruindo os dados que se encontram logo abaixo da caixa de mensagem. Funcionalidade replicada as telas de rotinas.
	 */	 
	var elementosDrag = $('#divRotina, #divError, #divConfirm, #divPesquisa, #divPesquisaEndereco, #divPesquisaEnderecoAssociado, #divPesquisaAssociadoDadosCadastrais, #divFormularioEndereco, #divPesquisaAssociado, #divUsoGenerico, #divMsgsAlerta, #divUsoGAROPC');
	elementosDrag.unbind('dragstart');	
    elementosDrag.bind('dragstart', function (event) {
		return $(event.target).is('.ponteiroDrag');
	}).bind('drag', function (event) {
        $(this).css({ top: event.offsetY, left: event.offsetX });
    });  	
	
});


function highlightObjFocus(parentElement) {			
	// Verificar se o elemento pai é um objeto válido
	if ($.type(parentElement) != 'object' || parentElement.size() == 0) return false;
	
	// Faz pre-seleção dos sub-elementos 
    var subElements = $('input', parentElement);
	
	// Verificar se o elemento pai tem sub-elementos	
	if (subElements.size() == 0) return true;
	
	var validTypes = new Array();
	validTypes[1] = 'textarea';
	validTypes[2] = 'text';
	validTypes[3] = 'image';
	validTypes[4] = 'password';
	validTypes[5] = 'radio';
	validTypes[6] = 'checkbox';
	validTypes[7] = 'select';
	
    $('input,textarea', parentElement).each(function () {
		var typeElement = $(this).attr('type') != undefined ? $(this).attr('type') : $(this).get(0).tagName.toLowerCase();
		
        if (in_array(typeElement, validTypes)) {
			$(this).unbind('focusout.highlightfocus')
			       .unbind('focusin.highlightfocus')
				   .bind('focusout.highlightfocus', function () {
						if (typeElement == 'image') {
							if ($(this).attr('src') == UrlImagens + 'botoes/entrar_focus.gif')
				               $(this).attr('src', $(this).attr('src').replace('_focus.gif', '.gif'));
						} else {
				           $(this).removeClass(function () {
										if (typeElement == 'text' || typeElement == 'password' || typeElement == 'select') {
											return 'campoFocusIn';											
										} else {
											return typeElement + 'FocusIn';
										}
								    })
                                  .addClass(function () {
										if (typeElement == 'text' || typeElement == 'password' || typeElement == 'select') {
											return 'campo';
										} else {											
											return typeElement;
										}
									})
						}
				    })
				   .bind('focusin.highlightfocus', function () {
						if (typeElement == 'image') {							
							if ($(this).attr('src') == UrlImagens + "botoes/entrar.gif")
				               $(this).attr('src', $(this).attr('src').replace('.gif', '_focus.gif'));
						} else {																	
				           $(this).removeClass(function () {
										if (typeElement == 'text' || typeElement == 'password' || typeElement == 'select') {
											return 'campo';
										} else {											
											return typeElement;
										}
									})
								   .addClass(function () {
										if (typeElement == 'text' || typeElement == 'password' || typeElement == 'select') {
											return 'campoFocusIn';
										} else {											
											return typeElement + 'FocusIn';
										}
								    });
						}
				    });
					
		}
	});
	
	return true;	
}

/*!
 * OBJETIVO: Função para chamar a ajuda do sistema
 */
function mostraAjudaF2() {
	showMsgAguardo("Aguarde carregando dados de ajuda ...");			
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "f2/busca_help.php",
		data: {
			redirect: "html_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
		},
        success: function (response) {
			$("#divF2").html(response);
			// Centraliza o div na Tela
			$("#divF2").setCenterPosition();
		}				
	}); 	
}

/*!
 * OBJETIVO: Função para bloquear conteúdo atrás de um div
 */
function blockBackground(zIndex) {
	$("#iframeBloqueio").css({
		width: "100%",
		height: $(document).height() + "px",
		zIndex: zIndex - 2,
		display: "block"
	}); 	
	// Propriedados do div utilizado no bloqueio
	$("#divBloqueio").css({
		width: "100%",
		height: $(document).height() + "px",
		zIndex: zIndex - 1,
		display: "block"
	}); 
}

/*!
 * OBJETIVO: Função para desbloquear conteúdo atrás de um div
 */
function unblockBackground() {
	// Propriedades do div utilizado no bloqueio
	$("#divBloqueio").css({
		width: "1px",
		height: "1px",
		top: "0",
		left: "0",
		display: "none"
	});	
	$("#iframeBloqueio").css({
		width: "1px",
		height: "1px",
		top: "0",
		left: "0",
		display: "none"
	});
}

/*!
 * OBJETIVO  : Função para mostrar mensagem de erro ou notificação
 * ALTERAÇÃO : 019 - Para permitir Movimentar a mensagem de Error, alterou-se a forma de centralização da mensagem
 * ALTERAÇÃO : 039 - Condição do tipoMsg, caso venha com 'none' não mostrará ícone.
 * ALTERAÇÃO : 047 - Parametro numWidth opcional, largura da tabela de mensagem, caso nao seja passado, pega 300 como padrao.
 */	 
function showError(tipoMsg, msgError, titMsg, metodoMsg, numWidth) {
	
	// Construindo conteúdo da mensagem
	var strHTML = '';
	var display = '';	
	
    if (tipoMsg == 'none')
		display = 'display:none;';
	
	larg = Number(numWidth);	
	
	if (isNaN(larg)) {		
		larg = 300; // largura padrao
	}
		
	strHTML += '<table border="0" cellpadding="0" cellspacing="0" width="' + larg + '" id="tabMsgError">';
	strHTML += '	<tr>';
	strHTML += '		<td id="tdTitError" class="ponteiroDrag">' + titMsg + '</td>';
	strHTML += '	</tr>';
	strHTML += '	<tr>';
	strHTML += '		<td height="5"></td>';
	strHTML += '	</tr>';	
	strHTML += '	<tr>';
	strHTML += '		<td style="padding: 4px 6px 4px 6px;">';	
	strHTML += '			<table border="0" cellpadding="0" cellspacing="0">';
	strHTML += '				<tr>';
	strHTML += '					<td valign="top" style="padding-right: 5px;' + display + '"><img src="' + UrlImagens + (tipoMsg == "inform" ? "geral/ico_inform.jpg" : "geral/ico_atencao.jpg") + '"></td>';
	strHTML += '					<td class="' + (tipoMsg == "inform" ? "txtCarregando" : "txtCritica") + '" nowrap><center>' + msgError + '</center></td>';
	strHTML += '				</tr>';
	strHTML += '			</table>';
	strHTML += '		</td>';
	strHTML += '	</tr>';
	strHTML += '	<tr>';
	strHTML += '		<td height="5"></td>';
	strHTML += '	</tr>';		
	strHTML += '	<tr>';
	strHTML += '		<td align="center" style="padding-bottom: 8px;"><input type="image" id="btnError" name="btnError" src="' + UrlImagens + (tipoMsg == "inform" ? "botoes/fechar.gif" : "botoes/continuar.gif") + '"></td>';
	strHTML += '	</tr>';
	strHTML += '</table>';		
	
	// Atribui o conteúdo ao div da mensagem
	divError.html(strHTML);
	
	// Bloqueia o Fundo e Mostra a mensagem
    bloqueiaFundo(divError);
    divError.css('display', 'block').setCenterPosition();
	$('#btnError').focus();

	// Aplica métodos ao evento "click" do botão de confirmação
    $('#btnError').unbind('click').bind('click', function () {
		// Esconde mensagem
		divError.escondeMensagem();
		// Método passado por parâmetro		
        if (metodoMsg != '') { eval(metodoMsg); }
		return false;
	});	
	
	return false;
}

/*!
 * OBJETIVO  : Função para mostrar mensagem para confirmação e ações
 * ALTERAÇÃO : 019 - Para permitir Movimentar a mensagem de Confirmação, alterou-se esta função
 */	 
function showConfirmacao(msgConfirm, titConfirm, metodoYes, metodoNo, nomeBtnYes, nomeBtnNo) {
	
	// Construindo o conteúdo da mensagem
	var strHTML = "";	
	strHTML += '<table border="0" cellpadding="0" cellspacing="0" width="300">';
	strHTML += '	<tr>';
	strHTML += '		<td id="tdTitError" class="ponteiroDrag">' + titConfirm + '</td>';
	strHTML += '	</tr>';
	strHTML += '	<tr>';
	strHTML += '		<td style="padding-top: 4px; padding-right: 6px; padding-left: 6px;">';	
	strHTML += '			<table border="0" cellpadding="0" cellspacing="0">';
	strHTML += '				<tr>';
	strHTML += '					<td style="padding-right: 5px;"><img src="' + UrlImagens + 'geral/ico_interrogacao.jpg' + '"></td>';
	strHTML += '					<td class="txtCarregando" nowrap>' + msgConfirm + '</td>';
	strHTML += '				</tr>';
	strHTML += '			</table>';
	strHTML += '		</td>';
	strHTML += '	</tr>';
	strHTML += '	<tr>';
	strHTML += '		<td align="center" style="padding-bottom: 8px; padding-top: 6px;">';
	strHTML += '			<table border="0" cellpadding="0" cellspacing="0">';
	strHTML += '				<tr>';
	strHTML += '					<td><input type="image" id="btnYesConfirm" name="btnYesConfirm" src="' + UrlImagens + "botoes/" + nomeBtnYes + '"></td>';
	strHTML += '					<td width="25"></td>';		
	strHTML += '					<td><input type="image" id="btnNoConfirm" name="btnNoConfirm" src="' + UrlImagens + "botoes/" + nomeBtnNo + '"></td>';	
	strHTML += '				</tr>';
	strHTML += '			</table>';
	strHTML += '		</td>';
	strHTML += '	</tr>';
	strHTML += '</table>';	
	
	// Atribui o conteúdo ao divConfirm
	divConfirm.html(strHTML);
	
	// Aplica métodos ao evento "click" do botão de confirmação
	$("#btnYesConfirm").unbind("click");
    $("#btnYesConfirm").bind("click", function () {
		// Esconde mensagem
		divConfirm.escondeMensagem();
		// Método passado por parâmetro
		if (metodoYes != "") { 
			eval(metodoYes); 

            if ($(".FirstInputModal")) { $(".FirstInputModal").focus(); }
		}		
		return false;
	});
	
	// Aplica método ao evento "click" do botão de cancelamento
	$("#btnNoConfirm").unbind("click");
    $("#btnNoConfirm").bind("click", function () {
		// Esconde mensagem
		divConfirm.escondeMensagem();
		// Método passado por parâmetro

        if (metodoNo != "") {
            eval(metodoNo);
            if ($(".FirstInputModal")) { $(".FirstInputModal").focus(); }
        }
		return false;
	});
        
	// Bloqueia o Fundo e Mostra a mensagem
    bloqueiaFundo(divConfirm);
    divConfirm.css('display', 'block').setCenterPosition();
	$("#btnYesConfirm").focus(); 
}

/*!
 * OBJETIVO  : Função para mostrar mensagem de Aguardo
 * ALTERAÇÃO : 019 - Para permitir Movimentar a mensagem de Aguardo, alterou-se esta função
 */	 
function showMsgAguardo(msgAguardo) {	
	// Mensagem de espera
	var strHTML = "";
	strHTML += '<table border="0" cellpadding="0" cellspacing="0">';
	strHTML += '  <tr>';
	strHTML += '    <td><img src="' + UrlImagens + 'geral/indicator.gif" width="15" height="15"></td>';
	strHTML += '    <td nowrap><strong class="txtCarregando">&nbsp;&nbsp;&nbsp;' + msgAguardo + '</strong></td>';
	strHTML += '  </tr>';
	strHTML += '</table>';		

	// Atribui conte&uacute;do ao div da mensagem
	$('#divAguardo').html(strHTML);
	
	// Bloqueia o Fundo e Mostra a mensagem
    bloqueiaFundo($('#divAguardo'));
    $('#divAguardo').css('display', 'block').setCenterPosition();
}

/*!
 * OBJETIVO  : Função para esconder (ocultar) a mensagem de aguardo
 * ALTERAÇÃO : 019 - Alterou-se a função utilizando-se do novo método criado "escondeMensagem()", implementado neste arquivo
 */	
function hideMsgAguardo() {
    $("#divAguardo").escondeMensagem();
}	

/*!
 * OBJETIVO  : Retirar caracteres indesejados
 * PARÂMETROS: flgRetirar -> Se TRUE retira caracteres que não estão na variável "valid"
 *                           Se FALSE retira caracteres que estão na variável "valid"    
 */	
function retiraCaracteres(str, valid, flgRetirar) {
	
	var result = "";	// variável que armazena os caracteres v&aacute;lidos
    var temp = "";	// variável para armazenar caracter da string
	
	for (var i = 0; i < str.length; i++) {
        temp = str.substr(i, 1);
			
		// Se for um n&uacute;mero concatena na string result
		if ((valid.indexOf(temp) != "-1" && flgRetirar) || (valid.indexOf(temp) == "-1" && !flgRetirar)) {
			result += temp;
		}
	}
	
	return result;		
}

/*!
 * OBJETIVO  : Função para validar o número da conta/dv
 * PARÂMETRO : conta [Obrigatário] -> Número da conta que deseja-se validar. Aceita somente números
 */	
function validaNroConta(conta) {

	// 057
	conta = normalizaNumero(conta);
	
	if (parseInt(conta) == 0) {
		return false;
	}
	
	if (conta != "" && conta.length < 9) {
        var mult = 2;
        var soma = 0;
        var tam = conta.length;
		var str_aux = 0;
		
		for (var i = tam - 2; i >= 0; i--) {
            str_aux = parseInt(conta.substr(i, 1));
			soma = soma + (str_aux * mult);
			mult++;
		}

		var div = soma % 11;

		if (div > 1) {
			div = 11 - div;
        } else {
			div = 0;
		}

        if (div == conta.substr((tam - 1), 1)) {
			return true;
		}
	}
	
	return false;
}

/*!
 * OBJETIVO  : Função para retirar zeros atá encontrar outro número maior
 * PARÂMETRO : numero [Obrigatário] -> Número a ser retirado os zeros a esquerda
 */	
function retirarZeros(numero) {
	var flgMaior = false; // Flag para verificar se foi encontrado o primeiro n&uacute;mero maior que zero
    var result = "";    // Armazena conteudo de retorno
    var temp = "";    // Armazena caracter temporario do numero
	
	// Efetua leitura de todos os caracteres do numero e atribui a vari&aacute;vel temp
	for (var i = 0; i < numero.length; i++) {
        temp = numero.substr(i, 1);
		
        if ((temp == '0') && (numero.substr(i + 1, 1) != ',')) {
			if (flgMaior) { // Se já foi encontrado um número maior que zero
				result += temp;
			}
		} else if (!isNaN(temp)) { // Se for um número maior que zero
			result += temp;
			
			if (!flgMaior) {
				flgMaior = true; 
			}
		} else if (flgMaior) { // Se não for um número
			result += temp;
		}
	}
	
	return result;
}

/*!
 * OBJETIVO  : Função para retornar código da tecla pressionada
 */	
function getKeyValue(e) {
	// charCode para Firefox e keyCode para IE
	var keyValue = e.charCode ? e.charCode : e.keyCode ? e.keyCode : 0;	
	return keyValue;
}

/*!
 * OBJETIVO : Função para validar se é uma data válida
 */	
function validaData(data) {
	// Se string n&atilde;o conter 10 caracteres
	if (data.length != 10) {
		return false;
	}
	
    var dia = parseInt(data.substr(0, 2), 10);
    var mes = parseInt(data.substr(3, 2), 10);
	var ano = parseInt(data.substr(6));

	if (isNaN(dia) || isNaN(mes) || isNaN(ano) || String(ano).length != 4) {
		return false;
	}

	// Valida n&uacute;mero do m&ecirc;s
	if (mes < 1 || mes > 12) {
		return false;
	}

	// Valida se m&ecirc;s X possui 31 dias
	if ((mes == 1 || mes == 3 || mes == 5 || mes == 7 || mes == 8 || mes == 10 || mes == 12) && (dia < 1 || dia > 31)) {
		return false;
	}

	// Valida se m&ecirc;s X possui 30 dias
	if ((mes == 4 || mes == 6 || mes == 9 || mes == 11) && (dia < 1 || dia > 30)) {
		return false;
	}

	// Valida n&uacute;mero de dias para o m&ecirc;s de Fevereiro
	if (mes == 2) {
		if (dia < 1) {
			return false;
		}

		var bissexto = false;
		
		// Calcula para verificar se &eacute; ano bissexto
		if (ano % 100 == 0) {
			if (ano % 400 == 0) { 
				bissexto = true;
			}
        } else {
			if ((ano % 4) == 0) { 
				bissexto = true;
			}
		}		

		if (bissexto) { // Se for ano bissexto
			if (dia > 29) {
				return false;
			} 
        } else { // Se n&atilde;o for ano bissexto
			if (dia > 28) {
				return false;
			}
		}
	}
	
	return true;
}

/*!
 * OBJETIVO  : Função para validar números inteiros e decimais
 */	
function validaNumero(numero, validaFaixa, minimo, maximo) {
	// Retirar "." e "," do numero	
    numero = numero.replace(/\./g, "").replace(/,/g, ".");
	
	// Verifica se &eacute; um n&uacute;mero inteiro ou decimal
	numero = numero.search(".") == "-1" ? parseInt(numero) : parseFloat(numero); 
	
	// Se n&atilde;o for um n&uacute;mero v&aacute;lido
	if (isNaN(numero)) {
		return false;
	}
	
	// Se par&acirc;metro for true, verifica se n&uacute;mero est&aacute; dentro de uma faixa v&aacute;lida
	if (validaFaixa) {
		if (minimo == maximo) {
			if (numero >= minimo && numero <= maximo) {
				return false;
			}
		} else {
			if (numero < minimo || numero > maximo) {
				return false;
			}
		}
	}
	
	return true;
}

/*!
 * OBJETIVO   : Função para validar CPF ou CNPJ
 * PARÂMETROS : cpfcnpf [String ] -> [Obrigatório] número do CPF ou CNPJ a ser validado
 *              tipo    [Integer] -> [Obrigatório] Tipos válidos: (1) para CPF e (2) para CNPJ
 */	
function validaCpfCnpj(cpfcnpj, tipo) {

	// 058
	cpfcnpj = normalizaNumero(cpfcnpj);
	
	var strCPFCNPJ = new String(parseFloat(cpfcnpj));

	if (tipo == 1) { //CPF
		var invalid = "";
        var peso = 9;
		var calculo = 0;
        var resto = 0;

		if (strCPFCNPJ.length < 5) {
			return false;
		}
		
		for (var i = 1; i < 10; i++) {
			for (var j = 0; j < 11; j++) {
				invalid += i;
			}

			if (strCPFCNPJ == invalid) {
				return false;
			}
			
			invalid = "";
		}
		
		for (i = strCPFCNPJ.length - 3; i >= 0; i--) {
            calculo = parseInt(calculo) + parseInt(strCPFCNPJ.substr(i, 1)) * peso;
			 peso--;
		}
		
		resto = parseInt(calculo) % 11;
		
		if (resto == 10) {
			digito = 0;
		} else {
			digito = resto;
		}

        peso = 8;
		calculo = digito * 9;
		
		for (i = strCPFCNPJ.length - 3; i >= 0; i--) {
            calculo = parseInt(calculo) + parseInt(strCPFCNPJ.substr(i, 1)) * peso;
			 peso--;
		}		
		
		resto = parseInt(calculo) % 11;
		
		if (resto == 10) {
			digito = digito * 10;
		} else {
			digito = (digito * 10) + resto;
		}
		
        if (strCPFCNPJ.substr(strCPFCNPJ.length - 2, 2) != digito) {
			return false;
		} else {
			return true;
		}
	} else if (tipo == 2) { //CNPJ
		if (strCPFCNPJ.length < 3)
			return false;
			
        var calculo = 0;
		var resultado = 0;
        var peso = 2;
		
		//Calculo do digito 8 do CNPJ.
        calculo = new String(parseInt(strCPFCNPJ.substr(0, 1)) * 2);
        resultado = parseInt(strCPFCNPJ.substr(1, 1)) + parseInt(strCPFCNPJ.substr(3, 1)) + parseInt(strCPFCNPJ.substr(5, 1)) +
 							  parseInt(calculo.substr(0, 1)) + parseInt(calculo.substr(1, 1));
		
        calculo = new String(parseInt(strCPFCNPJ.substr(2, 1)) * 2);
        resultado = parseInt(resultado) + parseInt(calculo.substr(0, 1)) + parseInt(calculo.substr(1, 1));
		
        calculo = new String(parseInt(strCPFCNPJ.substr(4, 1)) * 2);
        resultado = parseInt(resultado) + parseInt(calculo.substr(0, 1)) + parseInt(calculo.substr(1, 1));
									
        calculo = new String(parseInt(strCPFCNPJ.substr(6, 1)) * 2);
        resultado = parseInt(resultado) + parseInt(calculo.substr(0, 1)) + parseInt(calculo.substr(1, 1));
		
		var resto = parseInt(resultado) % 10;
		
		if (resto == 0) {
			digito = resto;
		} else {
			digito = 10 - resto;
		}
		
		calculo = 0;
		
		for (var i = strCPFCNPJ.length - 3; i >= 0; i--) {
            calculo = parseInt(calculo) + parseInt(strCPFCNPJ.substr(i, 1)) * peso;
			peso++;
		
			if (peso > 9) {
				peso = 2;
			}
		}
	
		resto = parseInt(calculo) % 11;
		
		if (resto < 2) {
			digito = 0;
		} else {
			digito = 11 - resto;
		}
		
        if (strCPFCNPJ.substr(strCPFCNPJ.length - 2, 1) != digito) {
			return false;
		}
		
		//Calculo do digito 14 do CNPJ.		
        peso = 2;
		calculo = 0;
		
		for (var i = strCPFCNPJ.length - 2; i >= 0; i--) {
            calculo = parseInt(calculo) + parseInt(strCPFCNPJ.substr(i, 1)) * peso;
			peso++;
		
			if (peso > 9) {
				peso = 2;
			}
		}
		
		resto = parseInt(calculo) % 11;
		
		if (resto < 2) {
	 		digito = 0;
		} else {
			digito = 11 - resto;
		}
		
        if (strCPFCNPJ.substr(strCPFCNPJ.length - 1, 1) != digito) {
			return false;
		} else {
			return true;
		}
	}
}

/*!
 * OBJETIVO   : Função que retorna uma lista de caracteres permitidos
 */	
function charPermitido() {
    var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789\"!@#$%*() -_=+[]{}/?;:.,\\|" + String.fromCharCode(10, 13);
	return chars;
}

/*!
 * OBJETIVO: 
 */	
function cancelaPedeSenhaCoordenador(divBlock) {
    $("#divUsoGenerico").css("visibility", "hidden");
	$("#divUsoGenerico").html("");	

	if (divBlock == '') {
		unblockBackground();
	} else {
		blockBackground(parseInt($("#" + divBlock).css("z-index")));
	}
}

/*!
 * OBJETIVO: Função para pedir senha de Coordenador/Gerente para processo especial
 */
function pedeSenhaCoordenador(nvopelib, nmfuncao, nmdivfnc) {
	showMsgAguardo("Informe a senha do coordenador para continuar ...");			
	
	// Resetar a Global com operador de liberacao
    glb_codigoOperadorLiberacao = 0;

	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "includes/pede_senha.php",
		data: {
			nvopelib: nvopelib,
			nmfuncao: nmfuncao,
			nmdivfnc: nmdivfnc,
			redirect: "html_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
		},
        success: function (response) {
			$("#divUsoGenerico").html(response);
			$("#divUsoGenerico").centralizaRotinaH();
		}				
	}); 	
}

/*!
 * OBJETIVO: Função para solicitar confirmação da senha de Coordenador/Gerente para processo especial
 */
function confirmaSenhaCoordenador(nmfuncao) {
	showMsgAguardo("Aguarde, validando a senha ...");
	
    var nvopelib = $("#nvopelib", "#frmSenhaCoordenador").val();
    var cdopelib = $("#cdopelib", "#frmSenhaCoordenador").val();
    var cddsenha = $("#cddsenha", "#frmSenhaCoordenador").val();
	
    cddsenha = encodeURIComponent(cddsenha, "UTF-8");
	
	
	// Valida operador
	if ($.trim(cdopelib) == "") {
		hideMsgAguardo();
        showError("erro", "Informe o " + (nvopelib == 1 ? "Operador" : nvopelib == 2 ? "Coordenador" : "Gerente") + ".", "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')));$('#cdopelib','#frmSenhaCoordenador').focus()");
		return false;
    } else {
        glb_codigoOperadorLiberacao = cdopelib; // Global com operador de liberacao
	} 
	
	// Valida senha
	if ($.trim(cddsenha) == "") {
		hideMsgAguardo();
        showError("erro", "Informe a Senha.", "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')));$('#cddsenha','#frmSenhaCoordenador').focus()");
		return false;
	} 	
	
	// Executa script de saque atrav&eacute;s de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "includes/valida_senha.php", 
		data: {
			nvopelib: nvopelib,
			cdopelib: cdopelib,
			cddsenha: cddsenha,
			nmfuncao: nmfuncao,
			redirect: "script_ajax"
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
		},
        success: function (response) {
			try {
				eval(response);
            } catch (error) {
				hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}
		}				
	});				
}

/*!
 * OBJETIVO: Função para forçar TAB quando der enter no campo
 */
function enterTab(f, e) { 

	if (getKeyValue(e) == 13) { 
		var i; 
		for (i = 0; i < f.form.elements.length; i++) { 
			if (f == f.form.elements[i]) { break; } 
		} 

		i = (i + 1) % f.form.elements.length; 
		for (ii = i; ii < f.form.elements.length; ii++) { 
            if ((f.form.elements[ii].readOnly != true) && (f.form.elements[ii].type != 'button')) {
				break; 
			} 
		} 
		f.form.elements[ii].focus(); 
		return false; 

	} 
	else {
		return true; 
	}
} 
 
/*!
 * ALTERAÇÃO : 002
 * OBJETIVO  : Função para resetar as cores zebradas das linhas de uma tabela
 * PARÂMETRO : Recebe um seletor CSS das linhas (TR) de uma tabela
 */
function zebradoLinhaTabela(x) {
	var cor = '#F7F3F7';	
    x.each(function (e) {
		cor == '#F4F3F0' ? cor = '#FFFFFF' : cor = '#F4F3F0';
        $(this).css({ 'background-color': cor, 'color': '#444' });
	});
    x.hover(function () {
        $(this).css({ 'cursor': 'pointer', 'outline': '1px solid #6B7984', 'color': '#000' });
    }, function () {
        $(this).css({ 'cursor': 'auto', 'outline': '0px', 'color': '#444' });
	});
	return false;
}

/*!
 * ALTERAÇÃO : 003
 * OBJETIVO  : Função análoga ao "trim" do PHP, onde limpa os espaços em branco excedentes de uma string
 * PARâMETRO : str -> Uma string qualquer
 */
function trim(str) {
	str = str.replace(/^\s+/, '');
	for (var i = str.length - 1; i >= 0; i--) {
		if (/\S/.test(str.charAt(i))) {
			str = str.substring(0, i + 1);
			break;
		}
	}
	return str;
}

/*!
 * ALTERAÇÃO : 004
 * OBJETIVO  : Função similar á mostraRotina, com a melhoria de se passar o div a ser exibido e bloquear o fundo
 * PARÂMETRO : x -> div a ser exibido
 */
function exibeRotina(x) { 
    x.css('visibility', 'visible');
	x.centralizaRotinaH();
	bloqueiaFundo(x);
	return false;
}

/*!
 * ALTERAÇÃO : 005 
 * OBJETIVO  : Função similar á mostraRotina, com a melhoria de se passar o seletor jQuery da div a ser exibida e desbloquear o fundo.
 *             Ao desbloquear o fundo, tudo é desbloqueado, mas existem situações que precisamos manter alguma parte do sistema bloqueado,
 *             para isso utiliza-se do segundo parâmetro da função, que bloqueia a rotina indicada neste parâmetro
 * PARÂMETRO : rotina         -> Seletor jQuery a ser fechado
 *	           bloqueiaRotina -> Seletor jQuery ao qual seu fundo será bloqueado
 */
function fechaRotina(rotina, bloqueiaRotina, fncFechar) { 

    //Condição para voltar foco na opção selecionada
    var CaptaIdRetornoFoco = '';
    CaptaIdRetornoFoco = $(".SetFoco").attr("id");
    if (CaptaIdRetornoFoco) {
        $(CaptaIdRetornoFoco).focus();
    }

    rotina.css('visibility', 'hidden');
	unblockBackground();	
    if (typeof bloqueiaRotina == 'object') {
		bloqueiaFundo(bloqueiaRotina);		
	}
    if (typeof fncFechar != 'undefined') {
		eval(fncFechar);		
	}
	return false;
}

/*!
 * ALTERAÇÃO : 006
 * OBJETIVO  : Função similar á blockBackground, com a melhoria de se passar o div a ser bloqueado
 * PARÂMETRO : div       -> div ao qual o fundo será bloqueado 
 *             campoFoco -> [Opcional] id do campo ao qual será dado o foco
 *             formFoco  -> [Opcional] id do formulario ao qual o campoFoco está inserido
 *			   boErro    -> [Opcional] valores válidos (true|false), indicando se recebe a classe erro ou não
 */
function bloqueiaFundo(div, campoFoco, formFoco, boErro) {	
    if ((div.attr('id') != 'divMatric') && (div.attr('id') != 'divTela')) {
		zIndex = parseInt(div.css('z-index'));	
		blockBackground(zIndex);	
	}
    if ((typeof campoFoco != 'undefined') && (typeof formFoco != 'undefined')) {
        if ((typeof boErro == 'undefined') && (boErro)) {
            $('#' + campoFoco, '#' + formFoco).addClass('campoErro');
		}
        $('#' + campoFoco, '#' + formFoco).focus();
	}
		
	return true;
}

/*!
 * ALTERAÇÃO : 008
 * OBJETIVO  : Função similar á format_number do php
 * PARÂMETRO : number        -> O numero a ser formatado 
 *             decimals      -> Numero de casas decimais
 *             dec_point     -> [Opcional] Separador de decimal
 *             thousands_sep -> [Opcional] Separador de milhar
 * OBSERVAÇÃO: Se passado o 3º parametro, 4º é obrigatório.Se nenhum é passado, default 
 *             é ',' e '.' respectivamento do parametro 3 e 4
 */
function number_format(number, decimals, dec_point, thousands_sep) {
	var n = !isFinite(+number) ? 0 : +number, 
		prec = !isFinite(+decimals) ? 0 : Math.abs(decimals),
		sep = (typeof thousands_sep === 'undefined') ? ',' : thousands_sep, dec = (typeof dec_point === 'undefined') ? '.' : dec_point,
		s = '',
		toFixedFix = function (n, prec) {
			var k = Math.pow(10, prec);
		    return '' + Math.round(n * k) / k;
		};
	// Fix for IE parseFloat(0.55).toFixed(0) = 0;
	s = (prec ? toFixedFix(n, prec) : '' + Math.round(n)).split('.');
	if (s[0].length > 3) {
        s[0] = s[0].replace(/\B(?=(?:\d{3})+(?!\d))/g, sep);
    }
	if ((s[1] || '').length < prec) {
		s[1] = s[1] || '';
		s[1] += new Array(prec - s[1].length + 1).join('0');
    } return s.join(dec);
}

/*!
 * ALTERAÇÃO : 009
 * OBJETIVO  : Função similar á in_array do php, retorna "true" se o item existe no array e "false" caso contrário
 * PARÂMETRO : item  -> Item que está sendo verificado se existe no array
 *             array -> Conjunto de valores que serão analizados verificando se o item é igual a um deles
 */
function in_array(item, array) {
    for (var i = 0; i < array.length; i++) {
        if (item == array[i]) return true;
	}
	return false;
}

/*!
 * ALTERAÇÃO : 010
 * OBJETIVO  : Função que define máscaras, formatos, valores permitidos e layout de vários elementos dos formulários. 
 */
function layoutPadrao() {
	
    var caracAcentuacao = 'áàäâãÁÀÄÂÃéèëêÉÈËÊíìïîÍÌÏÎóòöôõÓÒÖÔÕúùüûÚÙÜÛçÇ';
    var caracEspeciais = '!@#$%&*()-_+=§:<>;/?[]{}°ºª¬¢£³²¹\\|\',.´`¨^~';
    var caracSuperEspeciais = '¨¹²³£¢¬§ªº°´<>&\'\"';
	var caracEspeciaisEmail = '!#$%&*()+=§:<>;/?[]{}°ºª¬¢£³²¹\\|\',´`¨^~';	

	// Aplicando Máscaras
    $('input.conta').setMask('INTEGER', 'zzzz.zzz-z', '.-', '');
    $('input.cheque').setMask('INTEGER', 'zzz.zzz.9', '.', '');
    $('input.renavan').setMask('INTEGER', 'zzz.zzz.zzz.zz9', '.', '');
    $('input.renavan2').setMask('INTEGER', 'zz.zzz.zzz.zz9', '.', ''); //GRAVAMES
    $('input.contaitg').setMask('STRING', '9.999.999-9', '.-', '');
    $('input.placa').setMask('STRING', '999-9999', '-', '');
    $('input.matricula').setMask('INTEGER', 'zzz.zzz', '.', '');
    $('input.cadempresa').setMask('INTEGER', 'zzzz.zzz.z', '.', '');
    $('input.cnpj').setMask('INTEGER', 'z.zzz.zzz/zzzz-zz', '/.-', '');
    $('input.cpf').setMask('INTEGER', '999.999.999-99', '.-', '');
    $('input.cep').setMask('INTEGER', 'zzzzz-zz9', '-', '');
    $('input.caixapostal').setMask('INTEGER', 'zz.zz9', '.', '');
    $('input.numerocasa').setMask('INTEGER', 'zzz.zz9', '.', '');
    $('input.contrato').setMask('INTEGER', 'z.zzz.zz9', '.', '');
    $('input.contrato2').setMask('INTEGER', 'z.zzz.zzz.zz9', '.', '');
    $('input.contrato3').setMask('INTEGER', 'zz.zzz.zz9', '.', '');
    $('input.insc_estadual').setMask('INTEGER', 'zzz.zzz.zzz.zzz', '.', '');
    $('input.dataMesAno').setMask('INTEGER', 'zz/zzzz', '/', '');
	//$('input.data'			).dateEntry({useMouseWheel:true,spinnerImage:''});   
    $('input.data').setMask("DATE", "", "", "");
    $('input.taxa').attr('alt', 'p2p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    $('input.monetario').attr('alt', 'n9p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    $('input.moeda').attr('alt', 'p9p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    $('input.moeda_6').attr('alt', 'p6p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    $('input.moeda_15').attr('alt', 'p0p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    $('input.porcento').attr('alt', 'p3x0c2a').autoNumeric().trigger('blur');
	$('input.porcento_n').attr('alt', 'n3x0c2a').css('text-align', 'right').autoNumeric().trigger('blur');
	$('input.porcento_4').attr('alt', 'p3x0c4a').autoNumeric().trigger('blur');
	$('input.porcento_6').attr('alt', 'p3x0c6a').autoNumeric().trigger('blur');
	$('input.porcento_7'	).attr('alt','p3x0c7a').autoNumeric().trigger('blur');	
	$('input.porcento_8'	).attr('alt','p3x0c8a').autoNumeric().trigger('blur');	
	$('input.indexador'	).attr('alt','p3x0c8a').autoNumeric().trigger('blur');	
	$('input.email'			).css({'text-transform':'lowercase'}).alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao+caracEspeciaisEmail});
	$('input.alpha'			).css({'text-transform':'uppercase'});
	$('input.alphanum'		).css({'text-transform':'uppercase'});		
	$('input.alphanumlower'	).css({'text-transform':'lowercase'});		
	
	$('input.alpha'			).alpha({ichars: caracAcentuacao+caracEspeciais});
	$('input.alphanum'		).alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao});
	$('input.alphanumlower'	).alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao});
	$('textarea.alphanum'   ).alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao});
	$('input.inteiro'		).numeric({ichars: caracAcentuacao+caracEspeciais+'.,\"'});
	$('input.codigo'		).numeric({ichars: caracAcentuacao+caracEspeciais+'.,\"'});
	
	$('.descricao'			).desabilitaCampo();
	$('.campoTelaSemBorda'	).attr('tabindex','-1');	
	$('label'				).addClass("txtNormalBold");
	$('input.codigo'		).attr('maxlength','4');	
	$('a[class!="botao"]','.formulario').attr('tabindex','-1');	
	$('input.coordenadas').attr('alt', 'n2x0c9a').css('text-align', 'right').autoNumeric().trigger('blur');

	// Alinhando os campos para direita
	$('.inteiro,.porcento,.numerocasa,.caixapostal,.cep,.conta,.contrato,.contrato2,.contrato3,.contaitg,.cnpj,.cpf,.matricula,.cadempresa,.insc_estadual,.coordenadas').css('text-align','right');	
	
	/*!
	 * ALTERAÇÃO  : 023
	 * OBJETIVO   : Tecla de atalho F8 igual ao modo CARACTER para limpar os campos input
	 */	
	/*
	* remover esse atalho, conforme NOVO LAYOUT padrão
	*$('input[type=\'text\'],select').keydown( function(e) {
	*	if ( e.keyCode == 119 ) {
	*		$(this).val(''); 
	*		$(this).trigger('change'); // ALTERAÇÃO 040
	*		return false;
	*	}
	*	return true;
	*});
	*/
	
	/*!
	 * ALTERAÇÃO  : 024
	 * OBJETIVO   : Tecla de atalho F7 igual ao modo CARACTER para abrir a Pesquisa
	 * OBSERVAÇÃO : Aplicado somente a campos que possuem a classe "pesquisa"
	 */	
	$('input.pesquisa').unbind('keydown.zoom').bind('keydown.zoom', function(e) {
		if ( e.keyCode == 118 ) {
			if ( isHabilitado($(this)) ) {
				$(this).next().click();
				return false;
			}
		}
		return true;
	});
	
	/*!
	 * ALTERAÇÃO  : 027
	 * OBJETIVO   : Ao entrar no campo cpf ou cnpj, verifica se não existe valor digitado, caso afirmativo limpa o campo para digitação
	 */		
	$('input.cnpj').unbind('focusin').bind('focusin', function() {
		$(this).addClass('campoFocusIn');	/*064*/
		valorAtual = normalizaNumero( $(this).val() );
		valorAtual = ( valorAtual == '0' ) ? '' : valorAtual;
		$(this).val( valorAtual );
	});
	$('input.cpf').unbind('focusin').bind('focusin', function() {
		$(this).addClass('campoFocusIn');	/*064*/
		valorAtual = normalizaNumero( $(this).val() );
		valorAtual = ( valorAtual == '0' ) ? '' : valorAtual;
		$(this).val( valorAtual );
	});	
	
	return true;
}

/*!
 * ALTERAÇÃO  : 012
 * OBJETIVO   : Função que retorna uma string padrão de aguardo para impressão
 * PARÂMETROS : titulo [String] -> Título que será incluso na mensagem
 */
function montaHtmlImpressao( titulo ) {
	var htmlImpressao = '';
	htmlImpressao  = '<html>';
	htmlImpressao += '	<head>';
	htmlImpressao += '		<title>Impressão AILOS - '+titulo+'</title>';
	htmlImpressao += '		<style type="text/css">';
	htmlImpressao += '      	body{background-color:#DEE3D6;text-align:center;font-size:12px;color:#333;padding:50px;}';
	htmlImpressao += '		</style>';
	htmlImpressao += '  </head>';
	htmlImpressao += '  <body>';
	htmlImpressao += '  	<center>';
	htmlImpressao += '  		<h1 style="font-size:18px;font-family:Arial,Helvetica,sans-serif;border:10px solid #fff;background-color:#F7F3F7;padding:30px 10px;font-weight:normal;width:500px;">';
	htmlImpressao += '       		Aguarde, carregando impress&atilde;o do(a)<br />'+titulo+' ...';
	htmlImpressao += '          </h1>';
	htmlImpressao += '  	</center>';
	htmlImpressao += '  </body>';
	htmlImpressao += '</html>';
	return htmlImpressao;
}

/*!
 * ALTERAÇÃO  : 014
 * OBJETIVO   : Deixar o processo de revisão Cadastral genérico. O arquivo revisaoCadastral.php agora serve para todas as rotinas de CONTAS
 * PARÂMETROS : chavealt [Obrigatório] -> Chave de alteração, este valor é retornado pelo progress quando é necessária a Revisão Cadastral
 *              tpatlcad [Obrigatório] -> Tipo de alteração, este valor é retornado pelo progress quando é necessária a Revisão Cadastral
 *              businobj [Obrigatório] -> Business Object da rotina que está sendo tratada
 */
function revisaoCadastral(chavealt, tpatlcad, businobj, stringArrayMsg, metodo) {
	
    if (typeof stringArrayMsg == 'undefined') stringArrayMsg = '';
    if (typeof metodo == 'undefined') metodo = 'controlaOperacao(\"\");';
		
	blockBackground(1000);
	showMsgAguardo('Aguarde, registrando revisão cadastral ...');
	
    nrdconta = normalizaNumero(nrdconta);
			
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/revisao_cadastral.php', 
		data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            chavealt: chavealt,
            tpatlcad: tpatlcad,
            businobj: businobj,
            stringArrayMsg: stringArrayMsg,
            metodo: metodo,
            redirect: 'script_ajax'
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a revis&atilde;o cadastral.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
		},
        success: function (response) {
			try {
				eval(response);
            } catch (error) {
				hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a revis&atilde;o cadastral.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
			}		
		}				
	});	 
}

/*!
 * ALTERAÇÃO  : 021 - Criação
 * OBJETIVO   : Para trabalhar com o números sem máscaras
 * PARAMETROS : numero [String] -> número que deseja-se normalizar
 * RETORNO    : Retorna zero caso seja vazio o número passado como parâmetro, ou retorna o número sem máscara
 */	 
function normalizaNumero(numero) {
	var retorno;
    numero = ((typeof numero == 'undefined') || (numero == null)) ? '' : numero;
    retorno = retiraCaracteres(numero, '0123456789,', true);
    retorno = retirarZeros(retorno);
    retorno = (retorno == '') ? 0 : retorno;
	return retorno;
}

/*!
 * ALTERAÇÃO  : 025 - Criada função
 * OBJETIVO   : Selecionar o registro corrente retornando a chave para ser enviada ao XML. 
 * OBSERVAÇÕES: Função utilizada no início da função "controlaOperacao" de cada rotina. 
 *              Comumente utilizada para operações de Alteração ou Exclusão
 * RETORNO    : Retorna vazio caso não existam registros para serem selecionados, ou retorna a chave do registro selecionado
 */	 	
function selecionaRegistro() {
	var retorno = '';
    $('table > tbody > tr', 'div.divRegistros').each(function () {
        if ($(this).hasClass('corSelecao')) {
            retorno = $('input', $(this)).val();
		}
	});	
	return retorno;
}

/*!
 * OBJETIVO   : Inserir comportamento no link da pesquisa associado para abrir o formulário de pesquisa
 */	 
function controlaPesquisaAssociado(nomeForm) {
    $('a', '#' + nomeForm).addClass('lupa').css({ 'float': 'right', 'font-size': '11px', 'cursor': 'pointer' });
    $('a', '#' + nomeForm).each(function () {
        $(this).click(function () {
            mostraPesquisaAssociado('nrdconta', nomeForm);
			return false;
		});
	});
}

/*!
 * OBJETIVO  : Função para exibir alertas padrão do javascript caso a variável global "exibeAlerta" estiver setada para TRUE
 *             á uma função auxiliar para o programador debugar as telas
 */
function alerta(mensagem) {
    if (exibeAlerta) alert(mensagem);
}

/*!
 * ALTERAÇÃO : 026
 * OBJETIVO  : Função para padrão de focar os campos com erro.
 * PARÂMETRO : campoFoco    [String]  -> id do campo ao qual será dado o foco
 *             formFoco     [String]  -> id do formulario ao qual o campoFoco está inserido
 *             desbloqueia  [Boolean] -> [Opcional] true para desbloquear e false para não fazer nada, por default = true
 *             divBloqueia  [String]  -> [Opcional] nome da div que o fundo será bloqueado
 */
function focaCampoErro(campoFoco, formFoco, desbloqueia, divBloqueia) {
	
    if (typeof desbloqueia == 'undefined') {
		unblockBackground();
	} else {
        if (desbloqueia) unblockBackground();
	}
	
    if (typeof divBloqueia != 'undefined') {
        zIndex = parseInt($('#' + divBloqueia).css('z-index'));
		blockBackground(zIndex); 
	}	
	
    $('#' + campoFoco, '#' + formFoco).addClass('campoErro');
    $('#' + campoFoco, '#' + formFoco).focus();
	
	return true;
}

/*!
 * ALTERAÇÃO  : 030
 * OBJETIVO   : Função recursiva para exibir um array de mensagens, onde cada mensagem será exibida por LIFO
 * PARÂMETROS : strArray [Obrigatorio] -> Array de strings que serãoo exibidas
 *              metodo 	 [Obrigatorio] -> Metodo que será executado após a ultima mensagem do array ser exibida
 */	
function exibirMensagens(strArray, metodo) {
    if (strArray != '') {
		// Definindo as variáveis
        var arrayMensagens = new Array();
        var novoArray = new Array();
        var elementoAtual = '';
		// Setando os valores
        arrayMensagens = strArray.split('|');
        elementoAtual = arrayMensagens.pop();
        arrayMensagens = implode('|', arrayMensagens);
		// Exibindo mensagem de erro
        showError('inform', elementoAtual, 'Alerta - Aimaro', "exibirMensagens('" + arrayMensagens + "','" + metodo + "')");
	} else {
		eval(metodo);
	}
}

/*!
 * ALTERAÇÃO  : 029
 * OBJETIVO   : Função semelhando ao implode do PHP, que retorna uma string contento todos os elementos de um array separados por um separador
 * PARÂMETROS : separador   [Obrigatorio] -> Separador que será utilizado na montagem da string
 *              arrayPedaco [Obrigatorio] -> Array que será implodido 
 */	
function implode(separador, arrayPedaco) {
    return ((arrayPedaco instanceof Array) ? arrayPedaco.join(separador) : arrayPedaco);
}  

/*!
 * ALTERAÇÃO  : 028
 * OBJETIVO   : Função para verificar se existem funções "montaSelect" sendo executadas
 * OBSERVAÇÃO : Utilizada pelos botoes das diversas rotinas, onde se essa função retornar FALSE, não é para executar a ação do botão
 */	
function verificaContadorSelect() {
    if (contadorSelect > 0) return false;
	return true;
}

/*!
 * ALTERAÇÃO  : 032
 * OBJETIVO   : Função para verificar se o sistema está processando alguma função "controlaOperacao", não permitindo chamá-la 
 *              enquanto ainda está sendo executada
 * OBSERVAÇÃO : Utilizada por todas rotinas
 */	
function verificaSemaforo() {
    if (semaforo > 0) return false;
	semaforo++;
	return true;
}

/*!
 * ALTERAÇÃO  : 031
 * OBJETIVO   : Função para desbloquear a tela, mas a melhoria de poder setar o foco em algum campo da tela
 * OBSERVAÇÃO : Utilizada na tela MATRIC nos retornos de erro
 */	
function desbloqueia(campoFoco, formFoco) {
	unblockBackground();
    if ((typeof campoFoco != 'undefined') && (typeof formFoco != 'undefined')) {
        $('#' + campoFoco, '#' + formFoco).focus();
	}
	return true;
}

/*!
 * ALTERAÇÃO  : 032
 * OBJETIVO   : Função para trucar textos em javascript
 * OBSERVAÇÃO : Utilizada na tela MATRIC apresentação dos dados da tabela dos procuradores
 */	
function truncar(texto, limite) {
	if (texto.length > limite) {
        texto = texto.substr(0, limite - 1) + '…';
	}
	return texto;
}

/*!
 * ALTERAÇÃO  : 036
 * OBJETIVO   : Função para remover o filtro de opacidade tanto no IE quanto no FF
 * PARÂMETROS : nome [String] -> Nome da div que deseja-se voltar a visualização em 100%, sem transparencia (opacidade)
 */	
function removeOpacidade(nome) {
    $('#' + nome).fadeTo(1000, 1, function () {
        if ($.browser.msie) {
			$(this).get(0).style.removeAttribute('filter');
		} else {
            $(this).css({ '-moz-opacity': '100', 'filter': 'alpha(opacity=100)', 'opacity': '100' });
		}
	});
	
}

/*!
 * ALTERAÇÃO  : 
 * OBJETIVO   : Função que dado um Array Associativo bidirecional retorna uma string contendo o nome das chaves do array separado pelo separador
 * PARÂMETROS : arrayDados  [Obrigatorio] -> Array Associativo que será implodido
 *              separador   [Obrigatorio] -> Separador que será utilizado na montagem da string
 */	
function retornaCampos(arrayDados, separador) {
	var str = '';
    if (arrayDados.length > 0) {
        for (registro in arrayDados[0]) {
            str += registro + separador;
		}
        str = str.substring(0, (str.length - 1));
	}
	return str;
}

/*!
 * ALTERAÇÃO  : 
 * OBJETIVO   : Função que dado um Array Associativo bidirecional retorna uma string contendo os dados de um registro implodidos com o sepValores
				e todos os registros são implodidos com o sepRegs
 * PARÂMETROS : arrayDados  [Obrigatorio] -> Array Associativo que será implodido
 *              sepValores  [Obrigatorio] -> Separador que será utilizado para separar os dados
 *              sepRegs     [Obrigatorio] -> Separador que será utilizado para separar os registros
 */
function retornaValores(arrayDados, sepValores, sepRegs, strCampos) {
	var str = '';
    var arrayCampos = new Array();
    arrayCampos = strCampos.split('|');
	
    if (arrayDados.length > 0) {
        for (registro in arrayDados) {
            for (i in arrayCampos) {
			
			//for( dado in arrayDados[registro] ) {
                str += arrayDados[registro][arrayCampos[i]] + sepValores;
			}
            str = str.substring(0, (str.length - 1));
			str += sepRegs;
		}
        str = str.substring(0, (str.length - 1));
	}
	return str;
}


/*!
 * ALTERAÇÃO  : 046 
 * OBJETIVO   :	Função que converte um valor de financeiro para float 
 * PARÂMETROS : valor [String ] -> [Obrigatório] Valor financeiro
 * RETORNO    : Retorna um valor float
 */
function converteMoedaFloat(valor) {
	valor = valor != '' ? valor : '0';
    valor = valor.replace(/\./g, '');
    valor = valor.replace(/,/g, '.');
	valor = parseFloat(valor);
	return valor;
}

/*!
 * ALTERAÇÃO  : 048 
 * OBJETIVO   :	Função que coloca mascara em uma string 
 * PARÂMETROS : v [String ] -> String que vai receber a mascara. Ex.: 1111111
			  : m [String ] -> String com o formato da mascara. Ex.: ###.###.#	
 * RETORNO    : Retorna uma string com mascara. Ex.: 111.111.1
 */
function mascara(v, m) {
    var t1 = v.length - 1; // tamanho da string
    var t2 = m.length - 1; // tamanho da mascara
	var l1 = ''; // ultima letra string
	var l2 = ''; // ultima letra mascara
	var i1 = 0; // indice string
	var i2 = 0; // indice mascara
	
	var retorno = '';	
    var ultima = '';
	
    for (i1 = t1; i1 >= 0; i1--) {
		l1 = v.charAt(i1);
        while (ultima != '#' && t2 >= i2) {
            l2 = m.charAt(t2 - i2);
            if (l2 == '#') {
				retorno = l1 + retorno;
			} else {
				retorno = l2 + retorno;
			}
			ultima = l2;
			i2++;
		}
		ultima = '';
	}	
	return retorno;
}


/*!
 * Várias funções criadas como plugins do jQuery
 */
$.fn.extend({ 
	
	/*!
	 * OBJETIVO: Função para centralizar objetos na tela
	 */
    setCenterPosition: function () {
		// Captura posi&ccedil;&atilde;o esquerda e do topo do documento onde a barra de rolagem est&aacute; posicionada
		var curScrollX = $(window).scrollLeft();
		var curScrollY = $(window).scrollTop(); 

		// Calcula tamanho que deve sobrar ao redor do div
		var objOffsetY = ($(window).innerHeight() - $(this).outerHeight()) / 2;
		var objOffsetX = $.browser.msie ? ($(window).innerWidth() - $(this).outerWidth()) / 2 : ($("body").offset().width - $(this).outerWidth()) / 2;
	
		// Atribui posi&ccedil;&atilde;o ao div
		$(this).css({
			left: curScrollX + objOffsetX,
			top: curScrollY + objOffsetY
		});		
	},

	/*!
	 * ALTERAÇÃO : 007
	 * OBJETIVO  : Função similar á setCenterPosition, só que centraliza a Rotina na horizontal dentro de outro elemento "tdTela"
	 */	
    centralizaRotinaH: function () {
	
		// Calcula o centro da Tela ao qual o objeto será centralizado 
		var larguraRotina = $("#tdConteudoTela").innerWidth();
		var larguraObjeto = $(this).innerWidth();				
		
        var metadeRotina = Math.floor(larguraRotina / 2);
        var metadeObjeto = Math.floor(larguraObjeto / 2);
		
		// A nova posição será o metade da largura da Tela menos (-) metade da do objeto mais (+)
		// 177 = largura do menu (175px) + padding_left do menu (2px) 
		var left = metadeRotina - metadeObjeto + 178;
        $(this).css('left', left.toString());
        $(this).css('top', '91px');
	},
	
	/*!
	 * ALTERAÇÃO : 020 - Criação do método
	 * OBJETIVO  : Facilitar a chamada e ocultar as mensagens padrão do sistema, onde somente um método agora é responsável por realizar tal tarefa
	 */	
    escondeMensagem: function () {
        $(this).css({ left: '0px', top: '0px', display: 'none' });
		unblockBackground();	
	},
	
	/*!
	 * ALTERAÇÃO 45 - Somente trabalhar com determinados tipos e tags
	 * ALTERAÇÃO 44 - Se possui a classe pesquisa, então controla ponteiro do mouse do próximo campo
	 * OBJETIVO: Função para desabilitar o(s) campo(s)
	 */		
    desabilitaCampo: function () {
        return this.each(function () {
			var type = this.type;
            var tag = this.tagName.toLowerCase();
            if (in_array(tag, ['input', 'select', 'textarea']) && (type != 'image')) {
                $(this).addClass('campoTelaSemBorda').removeClass('campo campoFocusIn textareaFocusIn radioFocusIn checkboxFocusIn selectFocusIn').prop('readonly', true).prop('disabled', true);
                if (type == 'radio') $(this).css('background', 'none');
                if (type == 'textarea') $(this).prop('disabled', false);
                if ($(this).hasClass('pesquisa')) $(this).next().ponteiroMouse();
			}
		});		
	},
	
	/*!
	 * ALTERAÇÃO 45 - Somente trabalhar com determinados tipos e tags
	 * ALTERAÇÃO 44 - Se possui a classe pesquisa, então controla ponteiro do mouse do próximo campo	 
	 * OBJETIVO: Função para habilitar o(s) campo(s)
	 */		
    habilitaCampo: function () {
        return this.each(function () {
			var type = this.type;
            var tag = this.tagName.toLowerCase();
            if ((in_array(tag, ['input', 'select', 'textarea'])) && (type != 'image')) {
				if (type == 'radio') $(this).css('background', 'none');
                $(this).addClass('campo').removeClass('campoTelaSemBorda').prop('readonly', false).prop('disabled', false);
                if ($(this).hasClass('pesquisa')) $(this).next().ponteiroMouse();
			}
		});		
	},
	
	/*!
	 * ALTERAçãO  : 034
	 * OBJETIVO   : Função responsável por formatar o rodapé das pesquisas genéricas e pesquisa associado
	 */
    formataRodapePesquisa: function () {
        $(this).css({ 'border': '1px' });
        $('table', $(this)).css({ 'width': '100%' });
		var linhaRodape = $('table > tbody > tr', $(this));
        linhaRodape.css({ 'height': '18px' });
        $('td', linhaRodape).css({ 'text-align': 'center', 'background-color': '#f7d3ce', 'color': '#333', 'padding': '0px 5px 0px 5px', 'font-size': '10px' });
        $('td:eq(0)', linhaRodape).css({ 'width': '20%' });
        $('td:eq(1)', linhaRodape).css({ 'width': '60%' });
        $('td:eq(2)', linhaRodape).css({ 'width': '20%' });
        $('td > a', linhaRodape).css({ 'width': '99%', 'display': 'block', 'cursor': 'pointer', 'color': '#333', 'font-size': '10px' });
        $('td > a', linhaRodape).hover(function () {
            $(this).css({ 'text-decoration': 'underline', 'color': '#000' });
        }, function () {
            $(this).css({ 'text-decoration': 'none', 'color': '#333' });
		});			
	},
	
	/*!
	 * ALTERAÇÃO : 001
	 * OBJETIVO  : Plugin para limpar os dados de um formulário. 
	 * UTILIZAÇÃO: Via jQuery, onde a partir de um seletor podemos disparar esta funcionalidade da seguinte forma: $('seletor').limpaFormulario
	 * PARâMETRO : Podemos passar tanto o formulário ou algum elemento dele para ser limpado
	 */	
    limpaFormulario: function () {
        return this.each(function () {
			// Obtenho o tipo do elemento
			var type = this.type;
			// Normaliza o nome
			var tag = this.tagName.toLowerCase();
			// Se for um formulário realiza a chamada para todos os seus elementos
            if (tag == 'form') return $(':input', this).limpaFormulario();
			// Para tipos TEXT | PASSWORD | TEXTAREA mudo o valor para vazio
			if (type == 'text' || type == 'password' || tag == 'textarea' || type == 'hidden') this.value = '';
			// Para CHECKBOX | RADIO deixo os elementos desmarcados
            else if (type == 'checkbox' || type == 'radio') this.checked = false;
			// Para SELECT, coloco o índice de seleção para -1
			//else if (tag == 'select') this.selectedIndex = -1;
		});
	},

	/*!
	 * ALTERAÇÃO  : 015 - Criação da função
	 * OBJETIVO   : Facilitar o processo de formatação e padronização das tabelas que apresentam registros. Este padrão utiliza-se do plugin jQuery TableSorter
	 *              que adiciona a funcionalidade de ordenação das tabelas.
	 * PARÂMETROS : ordemInicial     [Obrigatório] -> Array bidimencional representando a ordenação inicial dos dados contidos na tabela
	 *              larguras         [Opcional]    -> Array unidimencional onde constam-se as larguras de cada coluna da tabela
	 *              alinhamento      [Opcional]    -> Array unidimencional onde constam-se os alinhamentos de cada coluna da tabela
	 *              metodoDuploClick [Opcional]    -> Metodo que será chamado no duplo clique na linha "registro" da tabela
	 * 				metodoClick      [Opcional]    -> Metodo que será chamado no clique na linha "registro" da tabela 07/06/2019 Jackson Barcellos AMcom	 
	 */
    formataTabela: function (ordemInicial, larguras, alinhamento, metodoDuploClick, metodoClick) {

		var tabela = $(this);

		// Forma personalizada de extração dos dados para ordenação, pois para números e datas os dados devem ser extraídos para serem ordenados
		// não da forma que são apresentados na tela. Portanto adotou-se o padrão de no início da tag TD, inserir uma tag SPAN com o formato do 
		// dado aceito para ordenação
        var textExtraction = function (node) {
            if ($('span', node).length == 1) {
				return $('span', node).html();
			} else {
				return node.innerHTML;
			}
		}

		// Configurações para o Sorter
		tabela.has("tbody > tr").tablesorter({ 
            sortList: ordemInicial,
            textExtraction: textExtraction,
            widgets: ['zebra'],
            cssAsc: 'headerSortUp',
            cssDesc: 'headerSortDown',
            cssHeader: 'headerSort'
		});

		// O thead no IE não funciona corretamento, portanto ele é ocultado no arquivo "estilo.css", mas seu conteúdo
		// é copiado para uma tabela fora da tabela original
		var divRegistro = tabela.parent();
        divRegistro.before('<table class="tituloRegistros"><thead>' + $('thead', tabela).html() + '</thead></table>');

        var tabelaTitulo = $('table.tituloRegistros', divRegistro.parent());

		// $('thead', tabelaTitulo ).append( $('thead', tabela ).html() );
        $('thead > tr', tabelaTitulo).append('<th class="ordemInicial"></th>');

		// Formatando - Largura 
		if (typeof larguras != 'undefined') {
            for (var i in larguras) {
                $('td:eq(' + i + ')', tabela).css('width', larguras[i]);
                $('th:eq(' + i + ')', tabelaTitulo).css('width', larguras[i]);
			}		
		}	

		// Calcula o número de colunas Total da tabela
        var nrColTotal = $('thead > tr > th', tabela).length;

		// Formatando - Alinhamento
		if (typeof alinhamento != 'undefined') {
            for (var i in alinhamento) {
				var nrColAtual = i;
				nrColAtual++;
                $('td:nth-child(' + nrColTotal + 'n+' + nrColAtual + ')', tabela).css('text-align', alinhamento[i]);
			}		
		}			

		// Controla Click para Ordenação
        $('th', tabelaTitulo).each(function (i) {
            $(this).mousedown(function () {
                if ($(this).hasClass('ordemInicial')) {
					tabela.has("tbody > tr").tablesorter({ sortList: ordemInicial }).tablesorter({ sortList: ordemInicial });
				} else {
                    $('th:eq(' + i + ')', divRegistro).click();
				}
			});
            $(this).mouseup(function () {

				tabela.zebraTabela();		

                $('table > tbody > tr', divRegistro).each(function (i) {
                    $(this).unbind('click').bind('click', function () {
                        $('table', divRegistro).zebraTabela(i);
                        if (typeof metodoClick != 'undefined') {
                        	eval(metodoClick);
                        }						
					});
				});				

                $('th', tabela).each(function (i) {
					var classes = $(this).attr('class');
                    if (classes != 'ordemInicial') {
                        $('th:eq(' + i + ')', tabelaTitulo).removeClass('headerSort headerSortUp headerSortDown');
                        $('th:eq(' + i + ')', tabelaTitulo).addClass(classes);
					}
				});				
			});			
		});	

        $('table > tbody > tr', divRegistro).each(function (i) {
            $(this).bind('click', function () {
                $('table', divRegistro).zebraTabela(i);
                if (typeof metodoClick != 'undefined') {
                	eval(metodoClick);
                }				
			});
		});

        if (typeof metodoDuploClick != 'undefined') {
            $('table > tbody > tr', divRegistro).dblclick(function () {
                eval(metodoDuploClick);
			});	

            $('table > tbody > tr', divRegistro).keypress(function (e) {
                if (e.keyCode == 13) {
                    eval(metodoDuploClick);
				}
			});

		}

        $('td:nth-child(' + nrColTotal + 'n)', tabela).css('border', '0px');

		// Iniciar com a primeira linha selecionado e retornar o valor da chave deste primerio registro, que se encontra no input do tipo hidden
		tabela.zebraTabela(0);	
		return true;
	},

	/*!
	 * ALTERAÇÃO  : 016 - Criação da função
	 * OBJETIVO   : Utilizada  na função acima "formataTabela" é chamada através de um seletor jQuery de tabela, e ele zebra as linhas da tabela.
	 *              Caso nehum parâmetro é informado, a linha que estava selecionada continua selecionada.
	 * PARÂMETROS : indice [Inteiro] -> Indica a linha que deve estar selecionada, ficando com uma cor diferenciada.
	 */
    zebraTabela: function (indice) {
		
		var tabela = $(this);
		
        $('tbody > tr', tabela).removeClass('corPar corImpar corSelecao');
        $('tbody > tr:odd', tabela).addClass('corPar');
        $('tbody > tr:even', tabela).addClass('corImpar');
		
        if (typeof indice != 'undefined') {
            $('tbody > tr', tabela).removeClass('corSelecao');
            $('tbody > tr:eq(' + indice + ')', tabela).addClass('corSelecao');
		}
		
        $('tr', tabela).hover(function () {
            $(this).css({ 'cursor': 'pointer', 'outline': '1px solid #6B7984', 'color': '#000' });
        }, function () {
            $(this).css({ 'cursor': 'auto', 'outline': '0px', 'color': '#444' });
		});
		
		return false;
	},

	/*!
	 * ALTERAÇÃO  : 013
	 * OBJETIVO   : Plugin para limitar a quantidade de linhas e colunas de um textarea. 
	 *              O número de colunas e linhas aceitos pelo "textarea" será os valores de suas propriedades "cols" e "rows" respctivamente.
	 * UTILIZAÇÃO : Via jQuery, onde a partir de um seletor podemos disparar esta funcionalidade da seguinte forma: $('seletor').limitaTexto;
	 */
    limitaTexto: function () {
		function limita(x) {
			var testoAux = '';
			var nrLinhasAtual, nrColunasAtual, nrLinhas, nrColunas = 0;
			var arrayLinhas = x.val().split("\n");

            nrLinhas = x.attr('rows');
			nrColunas = x.attr('cols');			
			nrLinhasAtual = arrayLinhas.length;			

            for (var i in arrayLinhas) {
				nrColunasAtual = arrayLinhas[i].length;			
                if (eval(nrColunasAtual >= nrColunas)) { arrayLinhas[i] = arrayLinhas[i].substring(0, nrColunas); }
                testoAux += (testoAux == '') ? arrayLinhas[i] : '\n' + arrayLinhas[i];
			}
            x.val(testoAux);

            if (nrLinhasAtual > nrLinhas) {
				testoAux = x.val().split("\n").slice(0, nrLinhas); 
                x.val(testoAux.join("\n"));
			}
		}

        this.each(function () {
			var textArea = $(this);
            textArea.keyup(function () { limita(textArea); });
            textArea.bind('paste', function (e) { setTimeout(function () { limita(textArea) }, 75); });
		});
		
		return this;
	},
	
	/*!
	 * ALTERAÇÃO  : 042 
	 * OBJETIVO   : Adicionar a classe "cpf" ou "cnpj" nos campos que possuem valores válidos de cpf ou cnpj respectivamente
	 */
    addClassCpfCnpj: function () {
        return this.each(function () {
			var type = this.type;
			var tag = this.tagName.toLowerCase();
			if (tag == 'input' && type == 'text') {
                if (verificaTipoPessoa(this.value) == 1) {
					$(this).removeClass('cnpj').addClass('cpf'); 
                } else if (verificaTipoPessoa(this.value) == 2) {
					$(this).removeClass('cpf').addClass('cnpj'); 
				} else {
					$(this).removeClass('cpf').removeClass('cnpj');
				}
			}	
		});
	},
	
	/*!
	 * ALTERAÇÃO  : 043
	 * OBJETIVO   : Somente aplicar comportamento para links <a> que possuem a classe "lupa", onde será
	 *              verificado se o campo anterior possui a classe "campo", e caso afirmativo coloca
	 *              a classe "pointer", caso negativo retira esta classe.
	 */		
    ponteiroMouse: function () {
        return this.each(function () {
			// Se não form TAG de link <a>, então não faz nada
			if (this.tagName.toLowerCase() != 'a') return false;						
			// Se não possuir a classe "lupa", não faz nada
			if (!$(this).hasClass('lupa')) return false;			
			// Se o campo anterior possuir a classe "campo", então adiciona a classe "pointer"
            if (isHabilitado($(this).prev())) {
				$(this).addClass('pointer');
			} else {
				$(this).removeClass('pointer');
			}
			return false;			
		});
	},
    removeOpacidade: function () {
        $(this).fadeTo(1000, 1, function () {
            if ($.browser.msie) {
				$(this).get(0).style.removeAttribute('filter');
			} else {
                $(this).css({ '-moz-opacity': '100', 'filter': 'alpha(opacity=100)', 'opacity': '100' });
			}
		});
	},
    trocaClass: function (classAnterior, classAtual) {
        return this.each(function () {
			$(this).removeClass(classAnterior).addClass(classAtual);
		});		
	}
});

/*!
 * ALTERAÇÃO  : 037
 * OBJETIVO   : Transforma data para timestamp
 * UTILIZAÇÃO : *     example 1: mktime(14, 10, 2, 2, 1, 2008);  
				*     returns 1: 1201871402  
				*     example 2: mktime(0, 0, 0, 0, 1, 2008);  
				*     returns 2: 1196463600  
				*     example 3: make = mktime();  
				*     example 3: td = new Date();  
				*     example 3: real = Math.floor(td.getTime()/1000);  
				*     example 3: diff = (real - make);  
				*     results 3: diff < 5  
				*     example 4: mktime(0, 0, 0, 13, 1, 1997)  
				*     returns 4: 883609200  
				*     example 5: mktime(0, 0, 0, 1, 1, 1998)  
				*     returns 5: 883609200  
				*     example 6: mktime(0, 0, 0, 1, 1, 98)  
				*     returns 6: 883609200  
 */
 function mktime() {  
     // Get UNIX timestamp for a date    
     //   
     // version: 901.2514  
     // discuss at: http://phpjs.org/functions/mktime  
     // +   original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net) 
       
     var no, ma = 0, mb = 0, i = 0, d = new Date(), argv = arguments, argc = argv.length;  
   
    if (argc > 0) {
        d.setHours(0, 0, 0); d.setDate(1); d.setMonth(1); d.setYear(1972);
     }  
    
     var dateManip = {  
        0: function (tt) { return d.setHours(tt); },
        1: function (tt) { return d.setMinutes(tt); },
        2: function (tt) { var set = d.setSeconds(tt); mb = d.getDate() - 1; return set; },
        3: function (tt) { var set = d.setMonth(parseInt(tt) - 1); ma = d.getFullYear() - 1972; return set; },
        4: function (tt) { return d.setDate(tt + mb); },
        5: function (tt) { return d.setYear(tt + ma); }
     };  
       
    for (i = 0; i < argc; i++) {
        no = parseInt(argv[i] * 1);
         if (isNaN(no)) {  
             return false;  
         } else {  
             // arg is number, let's manipulate date object  
            if (!dateManip[i](no)) {
                 // failed  
                 return false;  
             }  
         }  
     }     
    return Math.floor(d.getTime() / 1000);
}

/*!
 * ALTERAÇÃO  : 038
 * OBJETIVO   : Receber uma data no formato dd/mm/aaaa , obter as substrings referentes é ao dia, mes e ao ano e passar como parametro na 
 *				função mktime.              
 * PARÂMETROS : data ->  Data no formato dd/mm/aaaa. 
 */
function dataParaTimestamp(data) {
    dia = data.substr(0, 2);
    mes = data.substr(3, 2);
    ano = data.substr(6, 4);
	return mktime(0, 0, 0, mes, dia, ano);
}

/*!
 * ALTERAÇÃO  : 041
 * OBJETIVO   : Função para verificar se número passado como parâmetro é um CPF ou CNPJ
 * PARÂMETROS : numero [String ] -> [Obrigatório] número do CPF ou CNPJ a ser verificado
 * RETORNO    : Retorna o valor [1] para pessoa Física e [2] para Jurídica e [0] quando não é nenhum dos dois
 */	
function verificaTipoPessoa(numero) {
    if (validaCpfCnpj(numero, 1)) {
		return 1;
    } else if (validaCpfCnpj(numero, 2)) {
		return 2;
	} else {
		return 0;
	}
}

function milisegundos() {
	return Number(new Date());	
}

/*!
 * ALTERAÇÃO  : 059
 * OBJETIVO   : Verifica se o campo está habilitado
 * UTILIZAÇÃO : 
*/
function isHabilitado(objeto) {

	var classes = new Array();
	
	classes[0] = 'campo';
	classes[1] = 'campoFocusIn';
	classes[2] = 'textareaFocusIn';
	classes[3] = 'radioFocusIn';
	classes[4] = 'checkboxFocusIn';
	classes[5] = 'selectFocusIn';

    if (typeof objeto == 'object') {
        for (var i in classes) if (objeto.hasClass(classes[i])) return true;
	}
	
	return false;
}

function controlaFocoEnter(frmName) {

    var cTodos = $("input[type='text'],input[type='radio'],select,textarea", '#' + frmName);

    cTodos.unbind('keypress').bind('keypress', function (e) {
		
        if (e.keyCode == 9 || e.keyCode == 13) {
				
			var indice = cTodos.index(this);	
				
			while (true) {
			
				indice++;
				
				// Desconsiderar os que estao bloqueados
				if (jQuery(cTodos[indice]).hasClass('campoTelaSemBorda')) {
					continue;
				}

				//Desconsiderar os que estao com display none
				if (jQuery(cTodos[indice]).css('display') == 'none') {					
					continue;
				}

				// Se campo nao e' nullo, focar no proximo
                if (cTodos[indice] != null) {
					cTodos[indice].focus();
				}
			
				break;

			}										
			return false;
		}
	});

}

function CheckNavigator() {
	var navegador = 'undefined';
    var versao = '0';
	
    if (navigator.userAgent.search(/chrome/i) != ' -1') {
		navegador = 'chrome';
        versao = navigator.userAgent.substr(navigator.userAgent.search(/chrome/i) + 7);
        versao = versao.substr(0, versao.search(' '));
	} else if (navigator.userAgent.search(/firefox/i) != '-1') {		
		navegador = 'firefox';
        versao = navigator.userAgent.substr(navigator.userAgent.search(/firefox/i) + 8);
        versao = versao.substr(0, versao.search(' '));
	} else if (navigator.userAgent.search(/msie/i) != '-1') {
		navegador = 'msie';
		if (navigator.userAgent.search(/trident/i) != '-1') {
			versao = navigator.userAgent.substr(navigator.userAgent.search(/trident/i) + 8);
            versao = versao.substr(0, versao.search(';'));
			
			switch (versao) {
				case '4.0': versao = '8.0'; break;
				default: versao = '9.0'; break;
			}
		} else {
			versao = navigator.userAgent.substr(navigator.userAgent.search(/msie/i) + 5);
            versao = versao.substr(0, versao.search(';'));
		}		
	}
	
	return { navegador: navegador, versao: versao };
}

//funcao pode ou nao ter parametro de retorno
function verificaAguardoImpressao(callback) {		
	try {
		var httpState = parent.document.getElementById("frameBlank").contentWindow.document.readyState.toUpperCase();		
		
		if (httpState == undefined || httpState.toUpperCase() == "COMPLETE" || httpState.toUpperCase() == "INTERACTIVE") {
			hideMsgAguardo();
			
			if (callback != undefined) {
				eval(callback);			
			}		
		} else {
            setTimeout(function () { verificaAguardoImpressao(callback) }, 500);
		}
	} catch (err) {
		hideMsgAguardo();
        showError("error", "Erro no sistema de impress&atilde;o: " + err.message + "<br>Feche o navegador e reinicie o sistema Aimaro.", "Alerta - Aimaro", "");
	}			

	return true;
}

function carregaImpressaoAyllos(form, action, callback) {
	
	try {
		showMsgAguardo('Aguarde, carregando impress&atilde;o ...');
		
		var NavVersion = CheckNavigator();	
		
		if (action.search(/\?/) == '-1') {	
			action = action + '?';
		} else {
			action = action + '&';
		}
		
		action = action + 'keylink=' + milisegundos();
		
		// Configuro o formulário para posteriormente submete-lo
        $('#' + form).attr('method', 'post');
        $('#' + form).attr('action', action);
        $('#' + form).attr("target", (NavVersion.navegador == 'chrome' ? '_blank' : 'frameBlank'));
        $('#' + form).submit();
		verificaAguardoImpressao(callback);	
	} catch (err) {	
		hideMsgAguardo();
        showError("error", "Erro no sistema de impress&atilde;o: " + err.message + "<br>Feche o navegador e reinicie o sistema Aimaro.", "Alerta - Aimaro", "");
	}
	
	return true;
}

function normalizaTexto(strNormaliza) {

    strNormaliza = trim(strNormaliza);
    strNormaliza = strNormaliza.replace(/['"]*/g, '');

	return strNormaliza;	
}

/* http://stackoverflow.com/questions/46155/validate-email-address-in-javascript */
function validaEmail(emailAddress) {
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(emailAddress);
}

function replaceAll(str, de, para) {
    var pos = str.indexOf(de);
    while (pos > -1) {
		str = str.replace(de, para);
        pos = str.indexOf(de);
    }
    return (str);
}

function base64_decode(data) {

  var b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
  var o1, o2, o3, h1, h2, h3, h4, bits, i = 0,
    ac = 0,
    dec = '',
    tmp_arr = [];

  if (!data) {
    return data;
  }

  data += '';

  do { // unpack four hexets into three octets using index points in b64
    h1 = b64.indexOf(data.charAt(i++));
    h2 = b64.indexOf(data.charAt(i++));
    h3 = b64.indexOf(data.charAt(i++));
    h4 = b64.indexOf(data.charAt(i++));

    bits = h1 << 18 | h2 << 12 | h3 << 6 | h4;

    o1 = bits >> 16 & 0xff;
    o2 = bits >> 8 & 0xff;
    o3 = bits & 0xff;

    if (h3 == 64) {
      tmp_arr[ac++] = String.fromCharCode(o1);
    } else if (h4 == 64) {
      tmp_arr[ac++] = String.fromCharCode(o1, o2);
    } else {
      tmp_arr[ac++] = String.fromCharCode(o1, o2, o3);
    }
  } while (i < data.length);

  dec = tmp_arr.join('');

  return dec.replace(/\0+$/, '');
}

function base64_encode(data) {
  
  var b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
  var o1, o2, o3, h1, h2, h3, h4, bits, i = 0,
    ac = 0,
    enc = '',
    tmp_arr = [];

  if (!data) {
    return data;
  }

  do { // pack three octets into four hexets
    o1 = data.charCodeAt(i++);
    o2 = data.charCodeAt(i++);
    o3 = data.charCodeAt(i++);

    bits = o1 << 16 | o2 << 8 | o3;

    h1 = bits >> 18 & 0x3f;
    h2 = bits >> 12 & 0x3f;
    h3 = bits >> 6 & 0x3f;
    h4 = bits & 0x3f;

    // use hexets to index into b64, and append result to encoded string
    tmp_arr[ac++] = b64.charAt(h1) + b64.charAt(h2) + b64.charAt(h3) + b64.charAt(h4);
  } while (i < data.length);

  enc = tmp_arr.join('');

  var r = data.length % 3;

  return (r ? enc.slice(0, r - 3) : enc) + '==='.slice(r || 3);
}

/*! OBJETIVO: Remover acentos*/
function removeAcentos(str) {
    return str.replace(/[àáâãäå]/g, "a").replace(/[ÀÁÂÃÄÅ]/g, "A").replace(/[ÒÓÔÕÖØ]/g, "O").replace(/[òóôõöø]/g, "o").replace(/[ÈÉÊË]/g, "E").replace(/[èéêë]/g, "e").replace(/[Ç]/g, "C").replace(/[ç]/g, "c").replace(/[ÌÍÎÏ]/g, "I").replace(/[ìíîï]/g, "i").replace(/[ÙÚÛÜ]/g, "U").replace(/[ùúûü]/g, "u").replace(/[ÿ]/g, "y").replace(/[Ñ]/g, "N").replace(/[ñ]/g, "n");
}

/*! OBJETIVO  : Remover caracteres que invalidam o xml
	PARAMETROS: str           -> Texto que contera os caracteres invalidos que irao ser removidos
				flgRemAcentos -> Flag para identificar se é necessário remover acentuacao
*/

function removeCaracteresInvalidos(str, flgRemAcentos){
	
	//Se necessario remover acentuacao
	if (flgRemAcentos){
		return removeAcentos(str.replace(/[^A-z0-9\sÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ\!\@\#\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\°\º\ª]/g,""));				 
	}
		
	else
	    return str.replace(/[^A-z0-9\sÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ\!\@\#\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\°\º\ª]/g, "");
	
}

/*! OBJETIVO  : Remover caracteres invalidos no email
                Mantém apenas letras A-z (maúsculas e minúsculas, sem acentos), números 0-9 e os caracteres _ @ . % + -
	PARAMETROS: str -> Texto que contera os caracteres invalidos que irao ser removidos
*/
function removeCaracteresInvalidosEmail(str) {
    return str.replace(/[^\w@.%+-]/g, "");
}

/*! OBJETIVO  : Remover caracteres indevidos da tela SLIP contabil
	PARAMETROS: str           -> Texto que contera os caracteres invalidos que irao ser removidos
*/
function removeCaracteresSlip(str, flgRemAcentos){
	return str.replace(/[\,\°\º\ª]/g, "");
}

//Função para remover Todos os Caracteres epeciais e acentos
function removeTodosCaracteresInvalidos(str) {
    return str.replace(/[^\w\s\.]/g, "");
}

function utf8_decode(str_data) {
  var tmp_arr = [],
    i = 0,
    ac = 0,
    c1 = 0,
    c2 = 0,
    c3 = 0,
    c4 = 0;

  str_data += '';

  while (i < str_data.length) {
    c1 = str_data.charCodeAt(i);
    if (c1 <= 191) {
      tmp_arr[ac++] = String.fromCharCode(c1);
      i++;
    } else if (c1 <= 223) {
      c2 = str_data.charCodeAt(i + 1);
      tmp_arr[ac++] = String.fromCharCode(((c1 & 31) << 6) | (c2 & 63));
      i += 2;
    } else if (c1 <= 239) {
      // http://en.wikipedia.org/wiki/UTF-8#Codepage_layout
      c2 = str_data.charCodeAt(i + 1);
      c3 = str_data.charCodeAt(i + 2);
      tmp_arr[ac++] = String.fromCharCode(((c1 & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
      i += 3;
    } else {
      c2 = str_data.charCodeAt(i + 1);
      c3 = str_data.charCodeAt(i + 2);
      c4 = str_data.charCodeAt(i + 3);
      c1 = ((c1 & 7) << 18) | ((c2 & 63) << 12) | ((c3 & 63) << 6) | (c4 & 63);
      c1 -= 0x10000;
      tmp_arr[ac++] = String.fromCharCode(0xD800 | ((c1 >> 10) & 0x3FF));
      tmp_arr[ac++] = String.fromCharCode(0xDC00 | (c1 & 0x3FF));
      i += 4;
    }
  }

  return tmp_arr.join('');
}

function formataVerificaSenha(){
    
    
  // label
  rCddsenha = $('label[for="cddsenha"]','#divSolicitaSenha');
  rCddsenha.css('width','150px').css('font-weight','bold').addClass('rotulo-linha');
  
  //Campo
  cCddsenha = $('#cddsenha','#divSolicitaSenha');
  cCddsenha.css('width','100px').attr('maxlength','8');
  cCddsenha.addClass('campo');
  cCddsenha.focus();
  

  var divRegistro = $('div.divRegistros', '#divConteudoSnh');
  var tabela = $('table', divRegistro);

  tabela.zebraTabela(0);
  
  $('#divConteudoSnh').css({'width': '100%'});
  divRegistro.css({'height':'48px'});
                    
  var ordemInicial = new Array();
            
  var arrayLargura = new Array();
  arrayLargura[0] = '65px';
  arrayLargura[1] = '200px';
                    
  var arrayAlinha = new Array();
  arrayAlinha[0] = 'right';
  arrayAlinha[1] = 'left';
  arrayAlinha[2] = 'center';
                            
  tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

  $('tbody > tr', tabela).each(function () {
      if ($(this).hasClass('corSelecao')) {
          $(this).focus();		
      }
  });
  ajustarCentralizacao();	
  
  layoutPadrao();
  
  return false;
}
// Função para seleção de titular para consulta e alteração de dados
function selecionaTtlInternetSenha(idseqttl,incadsen,inbloque) {
    
    if (inbloque == 1 || incadsen == 1){     
        $('#btConSnh').trocaClass('botao','botaoDesativado').css('cursor','default').attr("onClick","return false;");
        $('#cddsenha','#divSolicitaSenha').desabilitaCampo();
        return false;
    }else{
        $('#btConSnh').trocaClass('botaoDesativado','botao').css('cursor','default').attr("onClick","validaSenhaInternet();fechaRotina($('#divUsoGenerico'));return false;");
        $('#cddsenha', '#divSolicitaSenha').habilitaCampo();
        $('#cddsenha').focus();
    }
    
    $('#idseqttl','#divSolicitaSenha').val(idseqttl);
}


//Verifica se tem senha da internet e se está ativa
function verificaSenhaInternet(retorno, nrdconta, idseqttl){  
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, Verificando conta cooperado...");
    
    // Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'includes/senha_internet/verifica_senha_internet.php',
		data: {
			nrdconta: nrdconta,
            idseqttl: idseqttl,
            retorno: retorno,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Aimaro","blockBackground(parseInt($('#divUsoGenerico').css('z-index')));");							
		},
		success: function(response) {			
				hideMsgAguardo();				
				try {
					eval( response );
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','blockBackground(parseInt($("#divUsoGenerico").css("z-index")));');
				}
				
		}				
	});
		
	return false;
}
//Solicita senha ao cooperado
function solicitaSenhaInternet(retorno, nrdconta, idseqttl){
    
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando tela de senha...");   
    
    // Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'includes/senha_internet/form_senha_internet.php',
		data: {
           nrdconta: nrdconta,
           idseqttl: idseqttl,
           retorno: retorno,
           redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Aimaro","return false;");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
                            exibeRotina($('#divUsoGenerico'));
                            $('#divUsoGenerico').html(response);
                            $('#divUsoGenerico').css({'width':'410px'});//css({'left':'340px','top':'91px'});
                            
                            bloqueiaFundo($('#divUsoGenerico'));                            
                            formataVerificaSenha();
                          
                            return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
					}
				}
		}				
	});
		
	return false;
}
//Valida se a senha está correta
function validaSenhaInternet(){
    
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, Validando senha cooperado...");    
    
    var cddsenha = $('#cddsenha','#divSolicitaSenha').val();
    var idseqttl = $('#idseqttl','#divSolicitaSenha').val();
    var retorno  = $('#retorno' ,'#divSolicitaSenha').val();
    var nrdconta = $('#nrdconta','#divSolicitaSenha').val();
    
    idseqttl_senha_internet = idseqttl;
    
    if (idseqttl == ''){
        showError("error","Selecione um titular.","Alerta - Aimaro","blockBackground(parseInt($('#divUsoGenerico').css('z-index')));");							
    }
  
  
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'includes/senha_internet/valida_senha_internet.php',
		data: {
			nrdconta: nrdconta,
            idseqttl: idseqttl,
            cddsenha: cddsenha,
            retorno: retorno,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Aimaro","return false;");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						if(response.indexOf(""))
                          $('#divUsoGenerico').html(response);
                        else
                          eval(response);
						  return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
					}
				}
		}				
	});
		
	return false;
}

function formataVerificaSenhaMagnetico() {


    // label
    rCddsenha = $('label[for="cddsenha"]', '#divSolicitaSenhaMagnetico');
    rCddsenha.css('width', '150px').css('font-weight', 'bold').addClass('rotulo-linha');

    //Campo
    cCddsenha = $('#cddsenha', '#divSolicitaSenhaMagnetico');
    cCddsenha.css('width', '100px').attr('maxlength', '8');
    cCddsenha.addClass('campo');
    cCddsenha.focus();

    ajustarCentralizacao();

    layoutPadrao();

    return false;
}

//Solicita senha do cartao magnetico ao cooperado
function solicitaSenhaMagnetico(retorno, nrdconta, validaInternet) {

	if(validaInternet)
		validainternet = "s";
	else
		validainternet = "n";

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando tela de senha...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'includes/senha_magnetico/form_senha_magnetico.php',
        data: {
            nrdconta: nrdconta,
            retorno: retorno,
            redirect: 'html_ajax', // Tipo de retorno do ajax
			validainternet : validainternet
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "return false;");
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    exibeRotina($('#divUsoGenerico'));
                    $('#divUsoGenerico').html(response);
                    $('#divUsoGenerico').css({ 'width': '410px' });//css({'left':'340px','top':'91px'});

                    bloqueiaFundo($('#divUsoGenerico'));
                    formataVerificaSenhaMagnetico();

                    return false;
                } catch (error) {
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground();');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground();');
                }
            }
        }
    });

    return false;
}
//Valida se a senha está correta
function validaSenhaMagnetico() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, Validando senha cooperado...");

    var cddsenha = $('#cddsenha', '#divSolicitaSenhaMagnetico').val();
    var retorno = $('#retorno', '#divSolicitaSenhaMagnetico').val();
    var nrdconta = $('#nrdconta', '#divSolicitaSenhaMagnetico').val();
	var validainternet = $('#validainternet', '#divSolicitaSenhaMagnetico').val();

    $.ajax({
        type: 'POST',
        url: UrlSite + 'includes/senha_magnetico/valida_senha_magnetico.php',
        data: {
            nrdconta: nrdconta,
            cddsenha: cddsenha,
            retorno: retorno,
			validainternet:validainternet,
            redirect: 'html_ajax' // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "return false;");
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    if (response.indexOf(""))
                        $('#divUsoGenerico').html(response);
                    else
                        eval(response);
                    return false;
                } catch (error) {
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground();');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground();');
                }
            }
        }
    });

    return false;
}

function formataVerificaSenhaTAOnline() {

    //Campo
    cCddsenha = $('#cddsenha', '#divSolicitaSenhaTAOnline');
    cCddsenha.css('width', '172px').attr('maxlength', '8');
	cCddsenha.css('margin-left', '112px');
    cCddsenha.addClass('campo');
    cCddsenha.focus();

	bBtVoltar = $('#btVoltar', '#divBotoesSenhaTAOnline');
	bBtVoltar.css('margin-right', '36px');

	bBtValidar = $('#btValidar', '#divBotoesSenhaTAOnline');
	bBtValidar.css('margin-right', '-2px');

    ajustarCentralizacao();

    layoutPadrao();

    return false;
}

//Solicita senha do cartao online ao cooperado
function solicitaSenhaTAOnline(retorno, nrdconta, nrcrcard) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando tela de senha...");

    // Carrega conteudo da opção atraves de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'includes/senha_ta_online/form_senha_ta_online.php',
        data: {
            nrdconta: nrdconta,
            retorno: retorno,
            redirect: 'html_ajax', // Tipo de retorno do ajax
			nrcrcard : nrcrcard
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "return false;");
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    exibeRotina($('#divUsoGenerico'));
                    $('#divUsoGenerico').html(response);
                    $('#divUsoGenerico').css({ 'width': '410px' });//css({'left':'340px','top':'91px'});

                    bloqueiaFundo($('#divUsoGenerico'));
                    formataVerificaSenhaTAOnline();

                    return false;
                } catch (error) {
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground();');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground();');
                }
            }
        }
    });

    return false;
}
//Valida se a senha esta correta
function validaSenhaTAOnline() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, Validando senha cooperado...");

    var cddsenha = $('#cddsenha', '#divSolicitaSenhaTAOnline').val();
    var retorno = $('#retorno', '#divSolicitaSenhaTAOnline').val();
    var nrdconta = $('#nrdconta', '#divSolicitaSenhaTAOnline').val();
	var nrcrcard = $('#nrcrcard', '#divSolicitaSenhaTAOnline').val();
	var validainternet = $('#validainternet', '#divSolicitaSenhaTAOnline').val();

    $.ajax({
        type: 'POST',
        url: UrlSite + 'includes/senha_ta_online/valida_senha_ta_online.php',
        data: {
            nrdconta: nrdconta,
			nrcrcard: nrcrcard,
            cddsenha: cddsenha,
            retorno: retorno,
			validainternet:validainternet,
            redirect: 'html_ajax' // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "return false;");
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    if (response.indexOf(""))
                        $('#divUsoGenerico').html(response);
                    else
                        eval(response);
                    return false;
                } catch (error) {
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground();');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground();');
                }
            }
        }
    });

    return false;
}

/*! OBJETIVO: Calcular a diferenca entre datas em: Dias, Semanas, Meses e Anos */
function retornaDateDiff(tipo, dtini, dtfim) {

    var DateDiff = {

        inDays: function (d1, d2) {
            var t2 = d2.getTime();
            var t1 = d1.getTime();

            return parseInt((t2 - t1) / (24 * 3600 * 1000));
        },

        inWeeks: function (d1, d2) {
            var t2 = d2.getTime();
            var t1 = d1.getTime();

            return parseInt((t2 - t1) / (24 * 3600 * 1000 * 7));
        },

        inMonths: function (d1, d2) {
            var d1Y = d1.getFullYear();
            var d2Y = d2.getFullYear();
            var d1M = d1.getMonth();
            var d2M = d2.getMonth();

            return (d2M + 12 * d2Y) - (d1M + 12 * d1Y);
        },

        inYears: function (d1, d2) {
            return d2.getFullYear() - d1.getFullYear();
        }
    }

    var dt_s1 = dtini.split('/');
    var d1 = new Date(dt_s1.slice(0, 3).reverse().join('/'));
    var dt_s2 = dtfim.split('/');
    var d2 = new Date(dt_s2.slice(0, 3).reverse().join('/'));

    switch (tipo.toUpperCase()) {
        case 'D': // Days
            return DateDiff.inDays(d1, d2);
            break;
        case 'W': // Weeks
            return DateDiff.inWeeks(d1, d2);
            break;
        case 'M': // Months
            return DateDiff.inMonths(d1, d2);
            break;
        case 'Y': // Years
            return DateDiff.inYears(d1, d2);
            break;
    }
}

/*! OBJETIVO: completar string a esquesrda com carcater passado por parametro */
function lpad(numero, tamanho, caracter) {
  caracter = caracter || '0';
  numero = numero + '';
  return numero.length >= tamanho ? numero : new Array(tamanho - numero.length + 1).join(caracter) + numero;
}

/*! OBJETIVO: completar string a direita com carcater passado por parametro */
function rpad(numero, tamanho, caracter) {
  caracter = caracter || '0';
  numero = numero + '';
  return numero.length >= tamanho ? numero : numero + new Array(tamanho - numero.length + 1).join(caracter);
}

function validaAdesaoProduto (nrdconta, cdprodut, executa_depois) {
	
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'includes/valida_adesao_produto.php', 
		data: {
			nrdconta: nrdconta,
			cdprodut: cdprodut, 
			executa_depois: executa_depois,
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

function validaValorProduto(nrdconta, cdprodut, vlcontra, executar, nmdivfnc, cddchave) {
	
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'includes/valida_valor_produto.php', 
		data: {
			nrdconta: nrdconta,
			cdprodut: cdprodut,
			vlcontra: vlcontra,
			executar: executar,
			nmdivfnc: nmdivfnc,
			cddchave: cddchave,
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
