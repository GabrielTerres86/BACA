<?php
/*!
 * FONTE        : mater_rotina.php
 * CRIAÇÃO      : Andre Santos (SUPERO)
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Mostrar opcao Principal da rotina de Convenio CDC da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 11/08/2016 - Inclusao de campos para apresentacao no site da cooperativa.
 *                             (Jaison/Anderson)
 *
 *	              29/11/2017 - Inclusão de novos parametros, Prj. 402 (Jean Michel).
 * --------------
 */
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");	
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$cddopcao           = (isset($_POST['cddopcao']))           ? $_POST['cddopcao']           : '';
	$operacao           = (isset($_POST['operacao']))           ? $_POST['operacao']           : '';
	$nrdconta           = (isset($_POST['nrdconta']))           ? $_POST['nrdconta']           : '';
	$inpessoa           = (isset($_POST['inpessoa']))           ? $_POST['inpessoa']           : '';
	$idmatriz           = (isset($_POST['idmatriz']))           ? $_POST['idmatriz']           : '';
	$idcooperado_cdc    = (isset($_POST['idcooperado_cdc']))    ? $_POST['idcooperado_cdc']    : '';
	$flgconve           = (isset($_POST['flgconve']))           ? $_POST['flgconve']           : '';
	$dtinicon           = (isset($_POST['dtinicon']))           ? $_POST['dtinicon']           : '';
	
	$inmotcan           = (isset($_POST['inmotcan']))           ? $_POST['inmotcan']           : '';
	$dtcancon           = (isset($_POST['dtcancon']))           ? $_POST['dtcancon']           : '';
	$dsmotcan           = (isset($_POST['dsmotcan']))           ? $_POST['dsmotcan']           : '';
	$dtrencon           = (isset($_POST['dtrencon']))           ? $_POST['dtrencon']           : '';
	$dttercon           = (isset($_POST['dttercon']))           ? $_POST['dttercon']           : '';	
	
	$nmfantasia         = (isset($_POST['nmfantasia']))         ? $_POST['nmfantasia']         : '';
	$cdcnae             = (isset($_POST['cdcnae']))             ? $_POST['cdcnae']             : '';
	$dslogradouro       = (isset($_POST['dslogradouro']))       ? $_POST['dslogradouro']       : '';
	$dscomplemento      = (isset($_POST['dscomplemento']))      ? $_POST['dscomplemento']      : '';
	$nrendereco         = (isset($_POST['nrendereco']))         ? $_POST['nrendereco']         : '';
	$nmbairro           = (isset($_POST['nmbairro']))           ? $_POST['nmbairro']           : '';
	$nrcep              = (isset($_POST['nrcep']))              ? $_POST['nrcep']              : '';
	$idcidade           = (isset($_POST['idcidade']))           ? $_POST['idcidade']           : '';
	$dstelefone         = (isset($_POST['dstelefone']))         ? $_POST['dstelefone']         : '';
	$dsemail            = (isset($_POST['dsemail']))            ? $_POST['dsemail']            : '';
	$nrlatitude         = (isset($_POST['nrlatitude'])) 				? str_replace(",",".",str_replace(".","",$_POST['nrlatitude'])) 			 : '';
	$nrlongitude        = (isset($_POST['nrlongitude'])) 				? str_replace(",",".",str_replace(".","",$_POST['nrlongitude'])) 			 : '';

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	}

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= '		<nrdconta>'				.$nrdconta.                  '</nrdconta>';
  $xml .= "   <inpessoa>"				.$inpessoa.                  "</inpessoa>";
	$xml .= '		<idmatriz>'				.$idmatriz.                  '</idmatriz>';
	$xml .= "		<idcooperado_cdc>".$idcooperado_cdc.           "</idcooperado_cdc>";
	$xml .= "		<flgconve>"       .$flgconve.                  "</flgconve>";
	$xml .= "		<dtinicon>"	      .$dtinicon.                  "</dtinicon>";
	
	$xml .= "		<inmotcan>"	      .$inmotcan.                  "</inmotcan>";
	$xml .= "		<dtcancon>"	      .$dtcancon.                  "</dtcancon>";
	$xml .= "		<dsmotcan>"	      .utf8_decode($dsmotcan).     "</dsmotcan>";
	$xml .= "		<dtrencon>"	      .$dtrencon.                  "</dtrencon>";
	$xml .= "		<dttercon>"	      .$dttercon.                  "</dttercon>";
	
	$xml .= "		<nmfantasia>"     .utf8_decode($nmfantasia).   "</nmfantasia>";
	$xml .= "		<cdcnae>"		      .$cdcnae.                    "</cdcnae>";
	$xml .= "		<dslogradouro>"   .utf8_decode($dslogradouro). "</dslogradouro>";
	$xml .= "		<dscomplemento>"  .utf8_decode($dscomplemento)."</dscomplemento>";
	$xml .= "		<nrendereco>"     .$nrendereco.					  		 "</nrendereco>";
	$xml .= "		<nmbairro>"		    .utf8_decode($nmbairro).		 "</nmbairro>";
	$xml .= "		<nrcep>"					.$nrcep.						    		 "</nrcep>";
	$xml .= "		<idcidade>"				.$idcidade.					 	  		 "</idcidade>";
	$xml .= "		<dstelefone>"			.$dstelefone.				 	  		 "</dstelefone>";
	$xml .= "		<dsemail>"				.$dsemail.					 	  		 "</dsemail>";	
	$xml .= "		<nrlatitude>"			.$nrlatitude. 						   "</nrlatitude>";
	$xml .= "		<nrlongitude>"		.$nrlongitude.							 "</nrlongitude>";
	
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	$nomdeacao = ($operacao == 'FCE' ? 'CVNCDC_EXCLUI_FILIAL' : 'CVNCDC_GRAVA');
	$xmlResult = mensageria($xml, "TELA_ATENDA_CVNCDC", $nomdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
    
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
				$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos',"bloqueiaFundo(divRotina)",false);
	}
?>