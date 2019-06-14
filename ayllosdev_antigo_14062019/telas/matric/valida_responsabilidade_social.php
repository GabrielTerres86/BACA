 <? 
/*!
 * FONTE        : valida_responsabilidade_social.php
 * CRIAÇÃO      : Tiago (CECRED)
 * DATA CRIAÇÃO : 27/09/2016 
 * OBJETIVO     : Rotina para validar CPF/CNPJ Bloqueados por responsabilidade social
 * --------------
 * ALTERAÇÕES	: 
 */
?> 
<?php 
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
		
	// Guardo os parâmetos do POST em variáveis	
	$inpessoa = (isset($_POST["inpessoa"])) ? $_POST["inpessoa"] : '';
	$nrcpfcgc = (isset($_POST["nrcpfcgc"])) ? $_POST["nrcpfcgc"] : '';
	
	// Monta o xml de requisição
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml       .=		"<inpessoa>".$inpessoa."</inpessoa>";
	$xml       .=		"<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";		
						
	$xmlResult = mensageria($xml, "COCNPJ", "VERIFICA_CNPJ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes["NMDCAMPO"];

		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrcpfcgc";
		}

		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','focaCampoErro(\''.$nmdcampo.'\',\'frmCadastro\');',false);		
					
	} else {
		
		/*aqui manda msg pra tela*/
		$bloqueado = $xmlObjeto->roottag->tags[0]->tags[0]->tags[0]->cdata;
		
		if($bloqueado == 'SIM'){
			
		}else{
			
		}
		
		/*exibirErro('error',utf8_encode($cdcnae),'Alerta - Aimaro','focaCampoErro(\''.$nmdcampo.'\',\'frmCadastro\');',false);*/
	}
	
					
?>
