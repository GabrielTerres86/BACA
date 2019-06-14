<?php
/*!
 * FONTE        : buscar_cooperado.php
 * CRIAÇÃO      : Jonata - Mouts        
 * DATA CRIAÇÃO : Setembro/2018
 * OBJETIVO     : Rotina para buscar o cooperado
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 
<?php	

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Recebe a operação que está sendo realizada
	$nrdconta       = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 
	$nrregist		= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0 ;
	$nriniseq		= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0 ;
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
	$xml 	   .= "     <nrregist>".$nrregist."</nrregist>";
	$xml 	   .= "     <nriniseq>".$nriniseq."</nriniseq>";
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";

	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_PESSOA", "BUSCAR_FUN_COOPERADO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
						
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrdconta";
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','formataFiltro();focaCampoErro(\''.$nmdcampo.'\',\'frmFiltro\');',false);		
								
	} 

	$qtregist 	= $xmlObjeto->roottag->tags[0]->tags[1]->attributes["QTREGIST"];
	$registros 	= $xmlObjeto->roottag->tags[0]->tags[1]->tags;
	$registros1 = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	
	include('form_cargos_funcoes.php');
	

?>