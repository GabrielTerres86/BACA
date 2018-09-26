<?php
/*!
 * FONTE        : verifica_cidade.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : Janeiro/2017
 * OBJETIVO     : Buscar idcidade pelo nome e UF
 * --------------
 * ALTERAÇÕES   : 
 *               
 * --------------
 */	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();		
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	// Recebe a operação que está sendo realizada
    $nmcidade = (isset($_POST['nmcidade'])) ? $_POST['nmcidade'] : '';
    $cdufende = (isset($_POST['cdufende'])) ? $_POST['cdufende'] : '';
	    						
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<nmcidade>'.$nmcidade.'</nmcidade>';
    $xml .= '       <cdufende>'.$cdufende.'</cdufende>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = mensageria($xml, 'TELA_ATENDA_CVNCDC', 'CVNCDC_BUSCA_IDCIDADE', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);
			
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
        exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro',"bloqueiaFundo(divRotina)",false);
	}
	
    $idcidade = $xmlObjeto->roottag->tags[0]->cdata;
	echo "$('#idcidade', '#frmConvenioCdc').val('".$idcidade."');";

?>
