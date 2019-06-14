<?php
/*!
 * FONTE        : busca_informacoes_cadastro.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : Janeiro/2017
 * OBJETIVO     : Buscar informações de cadastro do associado
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
    $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	    						
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = mensageria($xml, 'TELA_ATENDA_CVNCDC', 'CVNCDC_BUSCA_INF_CADASTRO', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);
			
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
        exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro',"bloqueiaFundo(divRotina)",false);
	}
	
    $dsendere = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;
    $nrendere = $xmlObjeto->roottag->tags[0]->tags[1]->cdata;
    $complend = $xmlObjeto->roottag->tags[0]->tags[2]->cdata;
    $nmbairro = $xmlObjeto->roottag->tags[0]->tags[3]->cdata;
    $nrcepend = $xmlObjeto->roottag->tags[0]->tags[4]->cdata;
    $nmcidade = $xmlObjeto->roottag->tags[0]->tags[5]->cdata;
    $cdufende = $xmlObjeto->roottag->tags[0]->tags[6]->cdata;
    $idcidade = $xmlObjeto->roottag->tags[0]->tags[7]->cdata;
    $nrtelefo = $xmlObjeto->roottag->tags[0]->tags[8]->cdata;
    $dsdemail = $xmlObjeto->roottag->tags[0]->tags[9]->cdata;
    $nmfansia = $xmlObjeto->roottag->tags[0]->tags[10]->cdata;
	
	echo "$('#nmfantasia', '#frmConvenioCdc').val('".$nmfansia."');";
	echo "$('#nrcepend', '#frmConvenioCdc').val('".$nrcepend."');";
	echo "$('#dslogradouro', '#frmConvenioCdc').val('".$dsendere."');";
	echo "$('#nrendereco', '#frmConvenioCdc').val('".$nrendere."');";
	echo "$('#dscomplemento', '#frmConvenioCdc').val('".$complend."');";
	echo "$('#nmbairro', '#frmConvenioCdc').val('".$nmbairro."');";
	echo "$('#idcidade', '#frmConvenioCdc').val('".$idcidade."');";
	echo "$('#dscidade', '#frmConvenioCdc').val('".$nmcidade."');";
	echo "$('#cdufende', '#frmConvenioCdc').val('".$cdufende."');";
	echo "$('#dstelefone', '#frmConvenioCdc').val('".$nrtelefo."');";
	echo "$('#dsemail', '#frmConvenioCdc').val('".$dsdemail."');";

?>
