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
	
	$cddopcao = 	(isset($_POST['cddopcao']))  	? $_POST['cddopcao'] : 0;
	$inpessoa = 	(isset($_POST['inpessoa']))  	? $_POST['inpessoa'] : 0;
	$cdtipo_conta = (isset($_POST['cdtipo_conta'])) ? $_POST['cdtipo_conta'] : 0;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}
	
    // Monta o xml de requisição        
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "     <inpessoa>"		.$inpessoa		."</inpessoa>";
    $xml .= "     <cdtipo_conta>"	.$cdtipo_conta	."</cdtipo_conta>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
	
	// Executa script para envio do XML
    $xmlResult = mensageria($xml, "TELA_TIPCTA", "BUSCAR_TIPO_DE_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
	
	
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
        
    }
	
    echo '$(\'#inpessoa_'.getByTagName($xmlObj->roottag->tags[0]->tags,'inpessoa').'\', \'#frmTipoConta\').prop("checked", true);'.
		 '$(\'#cdtipo_conta\', \'#frmTipoConta\').val('.getByTagName($xmlObj->roottag->tags[0]->tags,'cdtipo_conta').');'.
		 '$(\'#dstipo_conta\', \'#frmTipoConta\').val(\''.getByTagName($xmlObj->roottag->tags[0]->tags,'dstipo_conta').'\');'.
		 '$(\'#individual\', \'#frmTipoConta\').prop("checked", '.(getByTagName($xmlObj->roottag->tags[0]->tags,'idindividual') == 1 ? 'true' : 'false').');'.
		 '$(\'#conjunta_solidaria\', \'#frmTipoConta\').prop("checked", '.(getByTagName($xmlObj->roottag->tags[0]->tags,'idconjunta_solidaria') == 1 ? 'true' : 'false').');'.
		 '$(\'#conjunta_nao_solidaria\', \'#frmTipoConta\').prop("checked", '.(getByTagName($xmlObj->roottag->tags[0]->tags,'idconjunta_nao_solidaria') == 1 ? 'true' : 'false').');'.
		 '$(\'#tpcadast\', \'#frmTipoConta\').val('.getByTagName($xmlObj->roottag->tags[0]->tags,'idtipo_cadastro').');'.
		 '$(\'#cdmodali\', \'#frmTipoConta\').val('.getByTagName($xmlObj->roottag->tags[0]->tags,'cdmodalidade_tipo').');'.
		 '$(\'#indconta_itg\', \'#frmTipoConta\').val('.getByTagName($xmlObj->roottag->tags[0]->tags,'indconta_itg').');';	 
?>