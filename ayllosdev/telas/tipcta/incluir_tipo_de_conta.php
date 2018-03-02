<?
/* * *********************************************************************

  Fonte: incluir_tipo_de_conta.php
  Autor: Lombardi
  Data : Dezembro/2018                       Última Alteração: 

  Objetivo  : Incluir Tipo de Conta.

  Alterações: 

 * ********************************************************************* */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'I',false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}
	
	$inpessoa = 				(isset($_POST['inpessoa']))  				? $_POST['inpessoa'] : 0;
	$dstipo_conta =   			(isset($_POST['dstipo_conta'])) 			? $_POST['dstipo_conta'] : '';
	$individual = 				(isset($_POST['individual'])) 				? $_POST['individual'] : 0;
	$conjunta_solidaria = 		(isset($_POST['conjunta_solidaria'])) 		? $_POST['conjunta_solidaria'] : 0;
	$conjunta_nao_solidaria = 	(isset($_POST['conjunta_nao_solidaria'])) 	? $_POST['conjunta_nao_solidaria'] : 0;
	$tpcadast = 				(isset($_POST['tpcadast'])) 				? $_POST['tpcadast'] : 0;
	$cdmodali = 				(isset($_POST['cdmodali'])) 				? $_POST['cdmodali'] : 0;
	$indconta_itg = 			(isset($_POST['indconta_itg'])) 			? $_POST['indconta_itg'] : 0;
	
	
    // Monta o xml de requisição        
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "     <inpessoa>"				.$inpessoa				."</inpessoa>";
    $xml .= "     <dstipo_conta>"			.$dstipo_conta			."</dstipo_conta>";
    $xml .= "     <individual>"				.$individual			."</individual>";
    $xml .= "     <conjunta_solidaria>"    	.$conjunta_solidaria	."</conjunta_solidaria>";
    $xml .= "     <conjunta_nao_solidaria>"	.$conjunta_nao_solidaria."</conjunta_nao_solidaria>";
    $xml .= "     <tpcadast>"               .$tpcadast				."</tpcadast>";
    $xml .= "     <cdmodali>"               .$cdmodali				."</cdmodali>";
    $xml .= "     <indconta_itg>"           .$indconta_itg			."</indconta_itg>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
	
	// Executa script para envio do XML
    $xmlResult = mensageria($xml, "TELA_TIPCTA", "INCLUIR_TIPO_DE_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
	
	
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
        
    }
	
	$cdtipo_conta = $xmlObj->roottag->tags[0]->cdata;
	
	exibirErro('inform','Tipo de Conta cadastrado com sucesso.','Alerta - Ayllos','$(\"#cddopcao\", \"#frmCab\").val(\"C\");mostrarConteudo('.$inpessoa.','.$cdtipo_conta.');', false);
    
?>