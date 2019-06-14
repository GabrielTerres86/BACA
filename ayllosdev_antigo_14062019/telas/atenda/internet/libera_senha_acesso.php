<?php 

	/************************************************************************
	 Fonte: libera_senha_acesso.php                                  
	 Autor: David                                                     
	 Data : Junho/2008                   Última Alteração: 24/11/2015
	                                                                  
	 Objetivo  : Liberar Senha de Acesso ao InternetBank - Rotina de 
	             Internet da tela ATENDA)                            
	                                                                  
	 Alterações: 04/09/2008 - Carregar contrato ao final da liberação
	                          (David).                                
	                                                                  
	             18/05/2012 - Apresentar mensagem informando o prazo  
	                          para cadastrar a frase (David).        
	                                                                 
	             11/01/2013 - Requisitar cadastro de Letras ao       
	                          liberar acesso (Lucas).                
	
				 03/10/2015 - Reformulacao cadastral (Gabriel-RKAM).
				 
				 24/11/2015 - Adicionado param de retorno flgimpte,
						      indicador de impressao do termo de responsabilidade.
							  (Jorge/David) Projeto Multipla Assinatura PJ.

                 17/06/2016 - M181 - Alterar o CDAGENCI para          
                           passar o CDPACTRA (Rafael Maciel - RKAM) 
							  
				 26/07/2016 - Corrigi a recuperacao de dados do XML. SD 479874 (Carlos R.)			  

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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"L")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"]) || !isset($_POST["cdsnhnew"]) || !isset($_POST["cdsnhrep"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$cdsnhnew = $_POST["cdsnhnew"];
	$cdsnhrep = $_POST["cdsnhrep"];
	$executandoProdutos = $_POST['executandoProdutos'];
	$idastcjt = ( isset($_POST['idastcjt']) ) ? $_POST['idastcjt'] : null;
	$qtdTitular = ( isset($_POST['qtdTitular']) ) ? $_POST['qtdTitular'] : 0;
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se sequência de titular é um inteiro válido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}
	
	// Verifica se nova senha é um inteiro válido
	if (!validaInteiro($cdsnhnew)) {
		exibeErro("Nova senha inv&aacute;lida.");
	}	
	
	// Verifica se confirmação de nova senha é um inteiro válido
	if (!validaInteiro($cdsnhrep)) {
		exibeErro("Confirma&ccedil;&atilde;o de nova senha inv&aacute;lida.");
	}				
	
	// Monta o xml de requisição
	$xmlSetLiberar  = "";
	$xmlSetLiberar .= "<Root>";
	$xmlSetLiberar .= "	<Cabecalho>";
	$xmlSetLiberar .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlSetLiberar .= "		<Proc>liberar-senha-internet</Proc>";
	$xmlSetLiberar .= "	</Cabecalho>";
	$xmlSetLiberar .= "	<Dados>";
	$xmlSetLiberar .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetLiberar .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlSetLiberar .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetLiberar .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetLiberar .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetLiberar .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetLiberar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetLiberar .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlSetLiberar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetLiberar .= "		<cdsnhnew>".$cdsnhnew."</cdsnhnew>";
	$xmlSetLiberar .= "		<cdsnhrep>".$cdsnhrep."</cdsnhrep>";
	$xmlSetLiberar .= "	</Dados>";
	$xmlSetLiberar .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetLiberar);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLiberar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjLiberar->roottag->tags[0]->name) && strtoupper($xmlObjLiberar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLiberar->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$qtdiaace = ( isset($xmlObjLiberar->roottag->tags[0]->attributes["QTDIAACE"]) ) ? $xmlObjLiberar->roottag->tags[0]->attributes["QTDIAACE"] : 0;
	$flgletca = ( isset($xmlObjLiberar->roottag->tags[0]->attributes["FLGLETCA"]) ) ? $xmlObjLiberar->roottag->tags[0]->attributes["FLGLETCA"] : '';
	$flgimpte = ( isset($xmlObjLiberar->roottag->tags[0]->attributes["FLGIMPTE"]) ) ? $xmlObjLiberar->roottag->tags[0]->attributes["FLGIMPTE"] : '';
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
	// Procura indice da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se nao vem da rotina PRODUTOS
	if ($executandoProdutos != 'true') {
		// Se o indice da opção "@" foi encontrado 
		if (!($idPrincipal === false)) {
			echo 'callafterInternet = \'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'");\';$("#btnAceIntResp").bind("click");';
		} else {
			echo 'callafterInternet = \'blockBackground(parseInt($("#divRotina").css("z-index")));\';';
		}
	}
	
	$strMsg = " ATENCAO! O cooperado tem ".$qtdiaace.($qtdiaace > 1 ? " dias " : " dia ")."para acessar a internet<br>e cadastrar uma frase para o acesso da conta.";
	
	$metodo = '';

	if ($executandoProdutos == 'true') {
		$metodo = 'mostraDivAlteraSenhaLetras();';
	}
	
	// Carregar contrato de responsabilidade de acesso a Internet
	echo 'showError("inform","'.$strMsg.'","Notifica&ccedil;&atilde;o - Aimaro","'.'carregarContrato(\"'.$flgletca.'\",\"'.$flgimpte.'\",\"'.$metodo.'\");'.$metodo.'");';
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>