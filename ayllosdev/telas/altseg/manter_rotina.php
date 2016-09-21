<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Cristian Filipe Fernandes        
 * DATA CRIAÇÃO :  25/11/2013
 * OBJETIVO     : Rotina para manter as operações da tela ALTSEG
 * --------------
 * ALTERAÇÕES   : 08/03/2016 - Liberando acesso para o departamento COORD.PRODUTOS 			
 *                             conforme solicitado no chamado 399940. (Kelvin)
 * -------------- 
 */
?> 
<?
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	
	// Verifica Permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibeErro($msgError);		
	}

	$cdsegura = (isset($_POST['cdsegura']))? $_POST['cdsegura'] : '';
	$tpseguro = (isset($_POST['tpseguro']))? $_POST['tpseguro'] : '';
	$tpplaseg = (isset($_POST['tpplaseg']))? $_POST['tpplaseg'] : '';
	$cdsitpsg = (isset($_POST['cdsitpsg']))? $_POST['cdsitpsg'] : '';
	$dsmorada = (isset($_POST['dsmorada']))? $_POST['dsmorada'] : '';
	$ddcancel = (isset($_POST['ddcancel']))? $_POST['ddcancel'] : '';
	$dddcorte = (isset($_POST['dddcorte']))? $_POST['dddcorte'] : '';
	$ddmaxpag = (isset($_POST['ddmaxpag']))? $_POST['ddmaxpag'] : '';
	$dsocupac = (isset($_POST['dsocupac']))? $_POST['dsocupac'] : '';
	$flgunica = (isset($_POST['flgunica']))? $_POST['flgunica'] : '';
	$inplaseg = (isset($_POST['inplaseg']))? $_POST['inplaseg'] : '';
	$mmpripag = (isset($_POST['mmpripag']))? $_POST['mmpripag'] : '';
	$nrtabela = (isset($_POST['nrtabela']))? $_POST['nrtabela'] : '';
	$qtdiacar = (isset($_POST['qtdiacar']))? $_POST['qtdiacar'] : '';
	$qtmaxpar = (isset($_POST['qtmaxpar']))? $_POST['qtmaxpar'] : '';
	$vlmorada = (isset($_POST['vlmorada']))? $_POST['vlmorada'] : '';
	$vlplaseg = (isset($_POST['vlplaseg']))? $_POST['vlplaseg'] : '';
	
	// Dependendo da operação, chamo uma procedure diferente
	$retornoCampo = "";
	
	if ($inplaseg == 0 &&  $tpseguro == "4" ) {
		$inplaseg = 2;
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "	    <Bo>b1wgen0033.p</Bo>";
	$xmlSetPesquisa .= "        <Proc>atualizar_plano_seguro</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPesquisa .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetPesquisa .= "        <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetPesquisa .= "        <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetPesquisa .= "        <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetPesquisa .= "        <nrdconta>".$glbvars["nrdconta"]."</nrdconta>";
	$xmlSetPesquisa .= "        <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetPesquisa .= "        <idseqttl>".$glbvars["idseqttl"]."</idseqttl>";
	$xmlSetPesquisa .= "        <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetPesquisa .= "        <flgerlog>".$glbvars["flgerlog"]."</flgerlog>";
	$xmlSetPesquisa .= "		<cdsegura>".$cdsegura."</cdsegura>";
	$xmlSetPesquisa .= "		<tpseguro>".$tpseguro."</tpseguro>";
	$xmlSetPesquisa .= "		<tpplaseg>".$tpplaseg."</tpplaseg>";
	$xmlSetPesquisa .= "		<cdsitpsg>".$cdsitpsg."</cdsitpsg>";
	$xmlSetPesquisa .= "		<dsmorada>".$dsmorada."</dsmorada>";
	$xmlSetPesquisa .= "		<ddcancel>".$ddcancel."</ddcancel>";
	$xmlSetPesquisa .= "		<dddcorte>".$dddcorte."</dddcorte>";
	$xmlSetPesquisa .= "		<ddmaxpag>".$ddmaxpag."</ddmaxpag>";
	$xmlSetPesquisa .= "		<dsocupac>".$dsocupac."</dsocupac>";
	$xmlSetPesquisa .= "		<flgunica>".$flgunica."</flgunica>";
	$xmlSetPesquisa .= "		<inplaseg>".$inplaseg."</inplaseg>";
	$xmlSetPesquisa .= "		<mmpripag>".$mmpripag."</mmpripag>";
	$xmlSetPesquisa .= "		<nrtabela>".$nrtabela."</nrtabela>";
	$xmlSetPesquisa .= "		<qtdiacar>".$qtdiacar."</qtdiacar>";
	$xmlSetPesquisa .= "		<qtmaxpar>".$qtmaxpar."</qtmaxpar>";
	$xmlSetPesquisa .= "		<vlmorada>".$vlmorada."</vlmorada>";
	$xmlSetPesquisa .= "		<vlplaseg>".$vlplaseg."</vlplaseg>";
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPesquisa );
	
	$xmlObjPesquisa = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") {
		$msgErro	= $xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata;
			$erros = exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoCampo,false);
	} 	
	
	$pesquisa = $xmlObjPesquisa->roottag->tags[0]->tags[0];
	$registros = $xmlObjPesquisa->roottag->tags[0]->tags;
	
	if ($cddopcao == "A")
	{
		exibirErro('inform',"Plano alterado com sucesso",'Alerta - Ayllos','estadoInicial();',false);
		
	}else if ($cddopcao == "I")
	{
		exibirErro('inform',"Plano Incluido com sucesso",'Alerta - Ayllos','estadoInicial();',false);
	}
?>