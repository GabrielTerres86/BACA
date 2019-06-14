<?php 

	//************************************************************************//
	//*** Fonte: busca_ispb.php     	 	                           	   ***//
	//*** Autor: Vanessa                                                   ***//
	//*** Data : abril/2015                  Última Alteração: 23/04/2015  ***//
	//***                                                                  ***//
	//*** Objetivo  : Busca informações do ispb pelo cod do banco	       ***//
	//***                                                                  ***//	 
	//***                                                                  ***//	 
	//*** Alterações: 													   ***//	 
	//***                                                                  ***//
	//***                                                                  ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	//if $_POST["cddbanco"] != ' ' || $_POST["cddbanco"] != ' '{
		// Verifica se o n&uacute;mero do banco foi informado
		if (!isset($_POST["cddbanco"])) {
			$cddbanco = 0;
		}else{
		  $cddbanco = $_POST["cddbanco"];	
		}

		if (!isset($_POST["cdispbif"])) {
			$nrispbif = 0;
		}else{
		  $nrispbif = $_POST["cdispbif"];	
		}		

			
		$nmextbcc = "";
		$nrregist = 1;
		$nriniseq = 1;
		
		

		// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
		if (!validaInteiro($cddbanco)) {
			exibeErro("Banco inv&aacute;lida.");
		}
		
		// Monta o xml de requisi&ccedil;&atilde;o
		$xmlSetNrIspb  = "";
		$xmlSetNrIspb .= "<Root>";
		$xmlSetNrIspb .= "	<Cabecalho>";
		$xmlSetNrIspb .= "		<Bo>b1wgen0015.p</Bo>";
		$xmlSetNrIspb .= "		<Proc>busca_crapban</Proc>";
		$xmlSetNrIspb .= "	</Cabecalho>";
		$xmlSetNrIspb .= "	<Dados>";
		$xmlSetNrIspb .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlSetNrIspb .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlSetNrIspb .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlSetNrIspb .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlSetNrIspb .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
		$xmlSetNrIspb .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xmlSetNrIspb .= "		<cddbanco>".$cddbanco."</cddbanco>";
		$xmlSetNrIspb .= "		<nmextbcc>".$nmextbcc."</nmextbcc>";
		$xmlSetNrIspb .= "		<cdispbif>".$nrispbif."</cdispbif>";
		$xmlSetNrIspb .= "	</Dados>";
		$xmlSetNrIspb .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlSetNrIspb);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjNrIspb = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra cr&iacute;tica
		if (strtoupper($xmlObjNrIspb->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjNrIspb->roottag->tags[0]->tags[0]->tags[4]->cdata);
		} 			
		
			$cddbanco = str_pad($xmlObjNrIspb->roottag->tags[0]->tags[0]->tags[0]->cdata, 3, "0", STR_PAD_LEFT);
			$cdispbif = str_pad($xmlObjNrIspb->roottag->tags[0]->tags[0]->tags[6]->cdata, 8, "0", STR_PAD_LEFT);
			$nmdbanco = $xmlObjNrIspb->roottag->tags[0]->tags[0]->tags[6]->cdata;
			echo $cdispbif ."-". $cddbanco;
		
	//}
?>