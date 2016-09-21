<?php 

	/************************************************************************
	 Fonte: confirma_novo_limite.php                                  
	 Autor: David                                                     
	 Data : Março/2008                   Última Alteração: 26/03/2013 
	                                                                  
	 Objetivo  : Confirma Novo Limite de Crédito (rotina de Limite de 
	             Crédito da tela ATENDA)                              
	                                                                  
	 Alterações: 19/01/2010 - Adaptação para novo RATING (Guilherme). 
																	   
				  05/09/2011 - Incluido a chamada para a procedure	   
			                   alerta_fraude (Adriano).				   
																	   
				  30/09/2011 - Adaptacao Rating Singulares(Guilherme)  
	                                                                  
	             09/11/2011 - Tratado para validar a classificacao   
	                          do risco antes de confirmar o novo      
	                          limite. (Fabricio)                      
	
				  26/03/2013 - Retirado a chamada da procedure alerta_fraude
							  (Adriano).
								   
	************************************************************************/

	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["inconfir"]) || !isset($_POST["nrcpfcgc"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$inconfir = $_POST["inconfir"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$nrctrrat = $_POST["nrctrrat"];
	$flgratok = $_POST["flgratok"];
	
	
	// Verifica se número da conta éum inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se indicador de confirmação é um inteiro válido
	if (!validaInteiro($inconfir)) {
		exibeErro("Indicador de confirma&ccedil;&atilde;o inv&aacute;lido.");
	}	
	
	// Verifica se o CPF/CNPJ &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("N&uacute;mero de CPF/CNPJ inv&aacute;lido.");
	}
	
	$camposRS = (isset($_POST['camposRS'])) ? $_POST['camposRS'] : '';
	$dadosRtS = (isset($_POST['dadosRtS'])) ? $_POST['dadosRtS'] : '';
	
	if (($glbvars['cdcooper'] == 3) && ($flgratok == "false")) {
		$tpctrrat = 1;
		include("../../../includes/rating/rating_busca_dados_singulares.php");
	} else {
	
			
		// Monta o xml de requisição
		$xmlSetLimite  = "";
		$xmlSetLimite .= "<Root>";
		$xmlSetLimite .= "	<Cabecalho>";
		$xmlSetLimite .= "		<Bo>b1wgen0019.p</Bo>";
		$xmlSetLimite .= "		<Proc>confirmar-novo-limite</Proc>";
		$xmlSetLimite .= "	</Cabecalho>";
		$xmlSetLimite .= "	<Dados>";
		$xmlSetLimite .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlSetLimite .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlSetLimite .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlSetLimite .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlSetLimite .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlSetLimite .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xmlSetLimite .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlSetLimite .= "		<idseqttl>1</idseqttl>";
		$xmlSetLimite .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xmlSetLimite .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
		$xmlSetLimite .= "		<inproces>".$glbvars["inproces"]."</inproces>";
		$xmlSetLimite .= "		<inconfir>".$inconfir."</inconfir>";
		$xmlSetLimite .= retornaXmlFilhos( $camposRS, $dadosRtS, 'Classificacao_Risco', 'Itens');
		$xmlSetLimite .= "	</Dados>";
		$xmlSetLimite .= "</Root>";	
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlSetLimite);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjRating = getObjectXML($xmlResult);
		
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjRating->roottag->tags[0]->name) == "ERRO") {		
			// Variável com o nome do div onde serão mostradas as críticas do rating - Utilizado na include rating_tabela_criticas.php
			$iddivcri = "divConteudoOpcao";
			
			// Procura indíce da opção "@"
			$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
			
			if ($idPrincipal == false) {
				$idPrincipal = 0;
			}
			
			// Alimentar variável javascript global que armazena função que será acionada quando a lista de críticas do rating for fechada
			echo 'fncRatingSuccess = \'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'")\';';		
			
			// Monta tabela com críticas do rating
			include ("../../../includes/rating/rating_tabela_criticas.php");		
		} else {
			
			// Mostra se Bo retornar mensagem de confirmação
			if (strtoupper($xmlObjRating->roottag->tags[0]->name) == "CONFIRMACAO") {
				$confirma = $xmlObjRating->roottag->tags[0]->tags[0]->tags;		
				exibeConfirmacao($confirma[0]->cdata,$confirma[1]->cdata);
			}
			
			// Procura índice da opção "@"
			$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
			
			if ($idPrincipal == false) {
				$idPrincipal = 0;
			}
			
			// Armazena função que será acionada quando leitura das informações sobre rating foram finalizadas		
			echo 'fncRatingSuccess = \'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'")\';';		
					
			// Variável com o nome do div onde será mostrado os dados do rating efetivado - Utilizado na include rating_mostra_dados.php
			$divShowDados = "divConteudoOpcao";
			
			echo 'lcrShowHideDiv(\'divConteudoOpcao\', \'divDadosRatingSingulares\');';
			
			// Include para mostrar informações sobre o rating efetivado na confirmação do limite
			include("../../../includes/rating/rating_mostra_dados.php");
			
			
		}
		
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
	// Função para mostrar mensagem de confirmação retornada pela BO
	function exibeConfirmacao($aux_inconfir,$msgConfirmacao) {
		echo 'hideMsgAguardo();';
		echo 'showConfirmacao("'.$msgConfirmacao.'","Confirma&ccedil;&atilde;o - Ayllos","confirmaNovoLimite(\''.($aux_inconfir + 1).'\',\'true\')","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
		exit();	
	}

?>