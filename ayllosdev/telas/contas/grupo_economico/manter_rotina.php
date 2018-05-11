<?php 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Mauro (MOUTS)
 * DATA CRIAÇÃO : Agosto/2017
 * OBJETIVO     : Mostrar opcao Principal da rotina do Grupo Economico da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 
 20/02/2018 - #846981 Utilização da função removeCaracteresInvalidos (Carlos)
 
 */	
	session_start();	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");	
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();		
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';	
	switch ($operacao){
		case 'IncluirGrupo':
		case 'IncluirIntegrante':
		  $ope = "I";
		break;
		
		case 'AlterarGrupo':
		  $ope = "A";
		break;
		
		case 'ExcluirIntegrante':
		  $ope = "E";
		break;
		
		default:
		  $ope = "@";
		break;		
	}
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$ope)) <> "") {
	   exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	}
   
	switch ($operacao){
		case 'AlterarGrupo':
		case 'IncluirGrupo':
			$nrdconta 	  = (isset($_POST['nrdconta']))      ? $_POST['nrdconta']     : '';
			$nmgrupo  	  = (isset($_POST['nmgrupo']))       ? $_POST['nmgrupo']      : '';
			$dsobservacao = (isset($_POST['dsobservacao']))  ? $_POST['dsobservacao'] : '';
	
		    // Monta o xml de requisição
		    $xml  = "";
			$xml .= "<Root>";
			$xml .= "	<Dados>";
			$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
			$xml .= '		<nmgrupo>'.removeCaracteresInvalidos($nmgrupo).'</nmgrupo>';
			$xml .= "		<dsobservacao>".removeCaracteresInvalidos($dsobservacao)."</dsobservacao>";
			$xml .= "	</Dados>";
			$xml .= "</Root>";
			
			// Executa script para envio do XML
			$xmlResult = mensageria($xml, "TELA_GRUPO_ECONOMICO", "GRUPO_ECONOMICO_ATUALIZAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			// Cria objeto para classe de tratamento de XML
			$xmlObjeto = getObjectXML($xmlResult);
			
			if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
				$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				if ($msgErro == "") {
					$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
				}
				exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
			}
			
			echo "fechaRotina($('#divUsoGenerico'), $('#divRotina'));buscaDadosGrupoEconomico();";
		break;
		
		case 'IncluirIntegrante':
			$idgrupo 	    = (isset($_POST['idgrupo']))        ? $_POST['idgrupo']        : '';
			$tppessoa  	    = (isset($_POST['tppessoa']))       ? $_POST['tppessoa']       : '';
			$nrcpfcgc       = (isset($_POST['nrcpfcgc']))       ? $_POST['nrcpfcgc']       : '';
			$nrdconta       = (isset($_POST['nrdconta']))       ? $_POST['nrdconta']       : '';
			$nmprimtl       = (isset($_POST['nmprimtl']))       ? $_POST['nmprimtl']       : '';
			$tpvinculo      = (isset($_POST['tpvinculo']))      ? $_POST['tpvinculo']      : '';
			$peparticipacao = (isset($_POST['peparticipacao'])) ? converteFloat($_POST['peparticipacao']) : '';
		   
		    // Monta o xml de requisição
		    $xml  = "";
			$xml .= "<Root>";
			$xml .= "	<Dados>";
			$xml .= '		<idgrupo>'.$idgrupo.'</idgrupo>';
			$xml .= '		<tppessoa>'.$tppessoa.'</tppessoa>';
			$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
			$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
			$xml .= "		<nmintegrante>".removeCaracteresInvalidos($nmprimtl)."</nmintegrante>";
			$xml .= "		<tpvinculo>".$tpvinculo."</tpvinculo>";
			$xml .= "		<peparticipacao>".$peparticipacao."</peparticipacao>";
			$xml .= "	</Dados>";
			$xml .= "</Root>";
			
			// Executa script para envio do XML
			$xmlResult = mensageria($xml, "TELA_GRUPO_ECONOMICO", "GRUPO_ECONOMICO_INCLUIR_INTEGRANTES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			// Cria objeto para classe de tratamento de XML
			$xmlObjeto = getObjectXML($xmlResult);
			
			if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
				$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				if ($msgErro == "") {
					$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
				}
				exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos',"bloqueiaFundo($('#divUsoGenerico'));",false);
			}			
			echo 'carregaTelaConsultarIntegrantes();abreTelaInclusaoIntegrante();';
		break;
		
		case 'ExcluirIntegrante':
			$idgrupo	  = (isset($_POST['idgrupo'])) 		? $_POST['idgrupo'] : '';
			$idintegrante = (isset($_POST['idintegrante'])) ? $_POST['idintegrante'] : '';
			
		    // Monta o xml de requisição
		    $xml  = "";
			$xml .= "<Root>";
			$xml .= "	<Dados>";
			$xml .= '		<idgrupo>'.$idgrupo.'</idgrupo>';
			$xml .= '		<idintegrante>'.$idintegrante.'</idintegrante>';
			$xml .= "	</Dados>";
			$xml .= "</Root>";
			
			// Executa script para envio do XML
			$xmlResult = mensageria($xml, "TELA_GRUPO_ECONOMICO", "GRUPO_ECONOMICO_EXCLUIR_INTEGRANTES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			// Cria objeto para classe de tratamento de XML
			$xmlObjeto = getObjectXML($xmlResult);
			
			if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
				$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				if ($msgErro == "") {
					$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
				}
				exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
			}			
			echo 'carregaTelaConsultarIntegrantes();';		
		break;
	}
?>
