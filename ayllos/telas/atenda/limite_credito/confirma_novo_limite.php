<?php 

	/************************************************************************
	 Fonte: confirma_novo_limite.php                                  
	 Autor: David                                                     
	 Data : Mar�o/2008                   �ltima Altera��o: 06/03/2018
	                                                                  
	 Objetivo  : Confirma Novo Limite de Cr�dito (rotina de Limite de 
	             Cr�dito da tela ATENDA)                              
	                                                                  
	 Altera��es: 19/01/2010 - Adapta��o para novo RATING (Guilherme). 
																	   
				  05/09/2011 - Incluido a chamada para a procedure	   
			                   alerta_fraude (Adriano).				   
																	   
				  30/09/2011 - Adaptacao Rating Singulares(Guilherme)  
	                                                                  
	             09/11/2011 - Tratado para validar a classificacao   
	                          do risco antes de confirmar o novo      
	                          limite. (Fabricio)                      
	
				  26/03/2013 - Retirado a chamada da procedure alerta_fraude
							  (Adriano).
								   
				  06/03/2018 - Adicionado parametro idcobope e valida��o de 
							   garantia bloqueada ao efetivar novo limite. 
							   (PRJ404 Reinert)
	************************************************************************/

	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["inconfir"]) || !isset($_POST["nrcpfcgc"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$inconfir = $_POST["inconfir"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$nrctrrat = $_POST["nrctrrat"];
	$flgratok = $_POST["flgratok"];
	$idcobope = $_POST["idcobope"];
	
	
	// Verifica se n�mero da conta �um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se indicador de confirma��o � um inteiro v�lido
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
		if ($idcobope > 0){
		// Monta o xml din�mico de acordo com a opera��o 
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <nmdatela>ATENDA</nmdatela>';
		$xml .= '       <idcobert>'.$idcobope.'</idcobert>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';

		$xmlResult = mensageria($xml, "BLOQ0001", "REVALIDA_BLOQ_GARANTIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);

		//----------------------------------------------------------------------------------------------------------------------------------	
		// Controle de Erros
		//----------------------------------------------------------------------------------------------------------------------------------
		if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
			// Procura ind�ce da op��o "N"
			$idAlteraLim = array_search("N",$glbvars["opcoesTela"]);
			
			if ($idAlteraLim == false) {
				$idAlteraLim = 1;
			}
			
			echo "showConfirmacao('Garantia de aplica&ccedil;&atilde;o resgatada/bloqueada. Deseja alterar o limite proposto?', 'Confirma&ccedil;&atilde;o - Ayllos', 'acessaOpcaoAba(".count($glbvars["opcoesTela"]).",".$idAlteraLim.",\'".$glbvars["opcoesTela"][$idAlteraLim]."\');', 'hideMsgAguardo(); bloqueiaFundo($(\'#divRotina\'))', 'sim.gif', 'nao.gif');";
			exit();
			}
		}
			
		// Monta o xml de requisi��o
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
		
		
		// Se ocorrer um erro, mostra cr�tica
		if (strtoupper($xmlObjRating->roottag->tags[0]->name) == "ERRO") {		
			// Vari�vel com o nome do div onde ser�o mostradas as cr�ticas do rating - Utilizado na include rating_tabela_criticas.php
			$iddivcri = "divConteudoOpcao";
			
			// Procura ind�ce da op��o "@"
			$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
			
			if ($idPrincipal == false) {
				$idPrincipal = 0;
			}
			
			// Alimentar vari�vel javascript global que armazena fun��o que ser� acionada quando a lista de cr�ticas do rating for fechada
			echo 'fncRatingSuccess = \'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'")\';';		
			
			// Monta tabela com cr�ticas do rating
			include ("../../../includes/rating/rating_tabela_criticas.php");		
		} else {
			
			// Mostra se Bo retornar mensagem de confirma��o
			if (strtoupper($xmlObjRating->roottag->tags[0]->name) == "CONFIRMACAO") {
				$confirma = $xmlObjRating->roottag->tags[0]->tags[0]->tags;		
				exibeConfirmacao($confirma[0]->cdata,$confirma[1]->cdata);
			}
			
			// Procura �ndice da op��o "@"
			$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
			
			if ($idPrincipal == false) {
				$idPrincipal = 0;
			}
			
			// Armazena fun��o que ser� acionada quando leitura das informa��es sobre rating foram finalizadas		
			echo 'fncRatingSuccess = \'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'")\';';		
					
			// Vari�vel com o nome do div onde ser� mostrado os dados do rating efetivado - Utilizado na include rating_mostra_dados.php
			$divShowDados = "divConteudoOpcao";
			
			echo 'lcrShowHideDiv(\'divConteudoOpcao\', \'divDadosRatingSingulares\');';
			
			// Include para mostrar informa��es sobre o rating efetivado na confirma��o do limite
			include("../../../includes/rating/rating_mostra_dados.php");
			
			
		}
		
	}
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
	// Fun��o para mostrar mensagem de confirma��o retornada pela BO
	function exibeConfirmacao($aux_inconfir,$msgConfirmacao) {
		echo 'hideMsgAguardo();';
		echo 'showConfirmacao("'.$msgConfirmacao.'","Confirma&ccedil;&atilde;o - Ayllos","confirmaNovoLimite(\''.($aux_inconfir + 1).'\',\'true\')","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
		exit();	
	}

?>