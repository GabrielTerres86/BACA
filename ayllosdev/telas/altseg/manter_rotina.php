<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Cristian Filipe Fernandes        
 * DATA CRIAÇÃO :  25/11/2013
 * OBJETIVO     : Rotina para manter as operações da tela ALTSEG
 * --------------
 * ALTERAÇÕES   : 
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
	
	$param = (isset($_POST['param']))? $_POST['param'] : '';
	$cddopcao = (isset($_POST['cddopcao']))? $_POST['cddopcao'] : '';
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
	switch($param) {
		case 'C': $procedure = 'buscar_plano_seguro'; 
		          $retornoCampo = "focaCampoErro('tpplaseg', 'frmInfSeguradora')";	break;
		case 'A': $procedure = 'atualizar_plano_seguro'; 		break;
		case 'I': $procedure = 'atualizar_plano_seguro'; 		break;
	}
	
	if ($inplaseg == 0 &&  $tpseguro == "4" ) {
		$inplaseg = 2;
	}
	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "	    <Bo>b1wgen0033.p</Bo>";
	$xmlSetPesquisa .= "        <Proc>$procedure</Proc>";
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
	
	$dsmorada = getByTagName($pesquisa->tags, 'dsmorada');
	$vlplaseg = formataMoeda(getByTagName($pesquisa->tags, 'vlplaseg'));
	$dsocupac = getByTagName($pesquisa->tags, 'dsocupac');
	$nrtabela = getByTagName($pesquisa->tags, 'nrtabela');
	$vlmorada = formataMoeda(getByTagName($pesquisa->tags, 'vlmorada'));
	$flgunica = getByTagName($pesquisa->tags, 'flgunica');
	$inplaseg = getByTagName($pesquisa->tags, 'inplaseg');
	$cdsitpsg = getByTagName($pesquisa->tags, 'cdsitpsg');
	$ddcancel = getByTagName($pesquisa->tags, 'ddcancel');
	$dddcorte = getByTagName($pesquisa->tags, 'dddcorte');
	$ddmaxpag = getByTagName($pesquisa->tags, 'ddmaxpag');
	$mmpripag = getByTagName($pesquisa->tags, 'mmpripag');
	$qtdiacar = getByTagName($pesquisa->tags, 'qtdiacar');
	$qtmaxpar = getByTagName($pesquisa->tags, 'qtmaxpar');
	

	if((!$tpplaseg) && ($cddopcao == "C"))
	{
		include('tab_plano_seguradora.php');
		
	} else if($cddopcao == "C" || $param == "C")
	{
		if($tpseguro == "11")
		{			
		
			echo"
			$('#dsmorada', '#frmInfPlanoCasa').val('$dsmorada');
			$('#vlplaseg2', '#frmInfPlanoCasa').val('$vlplaseg');
			$('#dsocupac', '#frmInfPlanoCasa').val('$dsocupac');
			$('#nrtabela', '#frmInfPlanoCasa').val('$nrtabela');
			$('#vlmorada', '#frmInfPlanoCasa').val('$vlmorada');
			$('#flgunica', '#frmInfPlanoCasa').val('$flgunica');
			$('#inplaseg', '#frmInfPlanoCasa').val('$inplaseg');
			$('#cdsitpsg', '#frmInfPlanoCasa').val('$cdsitpsg');
			$('#ddcancel', '#frmInfPlanoCasa').val('$ddcancel');
			$('#dddcorte', '#frmInfPlanoCasa').val('$dddcorte');
			$('#ddmaxpag', '#frmInfPlanoCasa').val('$ddmaxpag');
			$('#mmpripag', '#frmInfPlanoCasa').val('$mmpripag');
			$('#qtdiacar', '#frmInfPlanoCasa').val('$qtdiacar');
			$('#qtmaxpar', '#frmInfPlanoCasa').val('$qtmaxpar');";
		}else {
		
			if ($inplaseg == 2 ) {
				$inplaseg = 0;
			}
		
			echo"
			$('#dsmorada', '#frmInfPlano').val('$dsmorada');
			$('#vlplaseg', '#frmInfPlano').val('$vlplaseg');
			$('#dsocupac', '#frmInfPlano').val('$dsocupac');
			$('#nrtabela', '#frmInfPlano').val('$nrtabela');
			$('#vlmorada', '#frmInfPlano').val('$vlmorada');
			$('#flgunica', '#frmInfPlano').val('$flgunica');
			$('#inplaseg', '#frmInfPlano').val('$inplaseg');
			$('#cdsitpsg', '#frmInfPlano').val('$cdsitpsg');
			$('#ddcancel', '#frmInfPlano').val('$ddcancel');
			$('#dddcorte', '#frmInfPlano').val('$dddcorte');
			$('#ddmaxpag', '#frmInfPlano').val('$ddmaxpag');
			$('#mmpripag', '#frmInfPlano').val('$mmpripag');
			$('#qtdiacar', '#frmInfPlano').val('$qtdiacar');
			$('#qtmaxpar', '#frmInfPlano').val('$qtmaxpar');";
		}
	}else if ($param == "A")
	{
		echo "$('input[type=\'text\'],select, input[type=\'checkbox\']','#frmInfPlano').desabilitaCampo();"; 
		echo "$('input[type=\'text\'],select, input[type=\'checkbox\']','#frmInfPlanoCasa').desabilitaCampo();"; 
		exibirErro('inform',"Plano alterado com sucesso",'Alerta - Ayllos','estadoInicial();',false);
	}else if ($param == "I")
	{
		exibirErro('inform',"Plano Incluido com sucesso",'Alerta - Ayllos','estadoInicial();',false);
	}
?>