<?php 

	//************************************************************************//
	//*** Fonte: principal.php                                             ***//
	//*** Autor: David                                                     ***//
	//*** Data : Fevereiro/2008               Última Alteração: 22/03/2018 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opção Principal da rotina de Limite de       ***//
	//***             Crédito da tela ATENDA                               ***//
	//***                                                                  ***//
	//*** Alterações: 28/06/2010 - Incluir campo de envio a sede           ***//
	//****						  (Gabrel)								   ***//
	//***                                                                  ***//
	//***             16/09/2010 - Ajuste para enviar impressoes via email ***//
	//***                          para o PAC Sede (David).                ***//
	//***                                                                  ***//
	//***             27/10/2010 - Tratamento para projeto de linhas de    ***//
	//***                          crédito (David).                        ***//
	//***                    											   ***//
	//***             13/01/2011 - Inclusao do campo dsencfi3 (Adriano).   ***//
	//***																   ***//
	//***             28/06/2011 - Tabless (Rogerius - DB1).			   ***//
	//***																   ***//
	//***			  09/07/2012 - Retirado campo "redirect" (Jorge)       ***//
	//***																   ***//
	//***			  18/03/2014 - Incluir botao consultar imagem e os     ***//
	//***						   devidos ajustes (Lucas R.)   		   ***//
	//***                                                                  ***//
	//***             02/07/2014 - Permitir alterar a observacao da        ***//
	//****                         proposta (Chamado 169007) (Jonata-RKAM) ***//
	//***                                                                  ***//
	//***             23/12/2014 - Incluir o campo data de renovacao  e    ***//
	//***						   Tipo da Renovacao. (James)              ***//
	//***                                                                  ***//
	//***             02/01/2015 - Ajuste format numero contrato/bordero   ***//
	//***                          para consultar imagem do contrato;      ***//
	//***                          adequacao ao format pre-definido para   ***//
	//***                          nao ocorrer divergencia ao              ***//
    //***                          pesquisar no SmartShare.                ***//
    //***                          (Chamado 181988) - (Fabricio)           ***//
    //***                                                                  ***//
    //***             09/01/2015 - Altercoes referentes ao projeto de      ***//
    //***                          melhoria para alteracao de propoosta    ***//
    //***                          SD237152 (Tiago/Gielow).                ***//
	//***                                                                  ***//
	//***             06/04/2015 - Consultas automatizadas (Jonata-RKAM)   ***//   
	//***                                                                  ***//
	//***  			  08/07/2015 - Tratamento de caracteres especiais e	   ***// 
	//***						   remover quebra de linha da observação   ***//
	//***						   (Lunelli - SD SD 300819 | 300893) 	   ***//
	//***																   ***//
	//***    		  20/07/2015 - Ajuste no tratamento de caracteres 	   ***//
	//***                         (Kelvin)	   							   ***//
	//***                                                                  ***//
	//***             08/08/2017 - Implementacao da melhoria 438.          ***//
	//***                          Heitor (Mouts).                         ***//
	//***																   ***//
	//***			  06/03/2018 - Adicionado variável idcobope. 		   ***//
	//***					       (PRJ404 Reinert)						   ***//
    //***                                                                  ***//
	//***             22/03/2018 - Verifica situacao do limite,            ***// 
    //***                          se foi cancelado automaticamente        ***//  
    //***                          por inadimplencia.                      ***//
	//***                          Diego Simas (AMcom).                    ***//
    //***                                                                  ***//     
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$cddopcao = $_POST["cddopcao"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
	$xmlGetLimite  = "";
	$xmlGetLimite .= "<Root>";
	$xmlGetLimite .= "	<Cabecalho>";
	$xmlGetLimite .= "		<Bo>b1wgen0019.p</Bo>";
	$xmlGetLimite .= "		<Proc>obtem-cabecalho-limite</Proc>";
	$xmlGetLimite .= "	</Cabecalho>";
	$xmlGetLimite .= "	<Dados>";
	$xmlGetLimite .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetLimite .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetLimite .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetLimite .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetLimite .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetLimite .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetLimite .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetLimite .= "		<idseqttl>1</idseqttl>";
	$xmlGetLimite .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetLimite .= "	</Dados>";
	$xmlGetLimite .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetLimite);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLimite = getObjectXML(retiraAcentos(removeCaracteresInvalidos($xmlResult)));
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLimite->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$limite = $xmlObjLimite->roottag->tags[0]->tags[0]->tags;
	
	$vllimite = getByTagName($limite,"vllimite");
	$dslimcre = getByTagName($limite,"dslimcre");
	$dtmvtolt = getByTagName($limite,"dtmvtolt");
	$dsfimvig = getByTagName($limite,"dsfimvig");	
	$dtfimvig = getByTagName($limite,"dtfimvig");
	$nrctrlim = getByTagName($limite,"nrctrlim");
	$qtdiavig = getByTagName($limite,"qtdiavig");
	$dsencfi1 = getByTagName($limite,"dsencfi1");
	$dsencfi2 = getByTagName($limite,"dsencfi2");
	$dsencfi3 = getByTagName($limite,"dsencfi3");
	$dssitlli = getByTagName($limite,"dssitlli");
	$dsmotivo = getByTagName($limite,"dsmotivo");
	$nmoperad = getByTagName($limite,"nmoperad");
	$flgpropo = getByTagName($limite,"flgpropo");
	$nrctrpro = getByTagName($limite,"nrctrpro");
	$cdlinpro = getByTagName($limite,"cdlinpro");
	$vllimpro = getByTagName($limite,"vllimpro");	
	$nmopelib = getByTagName($limite,"nmopelib");
	$flgenvio = getByTagName($limite,"flgenvio");
	$flgenpro = getByTagName($limite,"flgenpro");
	$cddlinha = getByTagName($limite,"cddlinha");
	$dsdlinha = getByTagName($limite,"dsdlinha");
	$tpdocmto = 84; //limite credito
	$flgdigit = getByTagName($limite,"flgdigit");
	$dsobserv = getByTagName($limite,'dsobserv');	
	$dstprenv = getByTagName($limite,"dstprenv");
	$dtrenova = getByTagName($limite,"dtrenova");
	$qtrenova = getByTagName($limite,"qtrenova");
	$flgimpnp = getByTagName($limite,"flgimpnp");
	$dslimpro = getByTagName($limite,"dslimpro");	
	$idcobope = getByTagName($limite,"idcobope");	
	$nivrisco = getByTagName($limite,"nivrisco");	
	$dsdtxfix = getByTagName($limite,"dsdtxfix");	
	//$dsobserv = removeCaracteresInvalidos($dsobserv);
	
	$xml  = "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "ATENDA", "LIM_ULTIMA_MAJ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjMaj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjMaj->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjMaj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$majora = $xmlObjMaj->roottag->tags[0]->tags[0]->tags;
	
	$dtultmaj = getByTagName($majora,"dtultmaj");	
	
	//Verifica situacao do limite, se foi cancelado automaticamente por inadimplencia
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "    <nrctrlim>".$nrctrlim."</nrctrlim>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "ZOOM0001", "CONSULTAR_CCL_LIMITE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
	$xmlObjeto = getObjectXML($xmlResult);	
	
	$param = $xmlObjeto->roottag->tags[0]->tags[0];

	$cancAuto = getByTagName($param->tags,'tipo');	
	$dtcanlim = getByTagName($param->tags,'data');
		
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',"controlaOperacao('');",false); 
	}else{
		if($cancAuto == 1){
			$dssitlli = "Cancelado Automaticamente por Inadimpl&ecirc;ncia";				
		}
	}

	//include ("form_tela_principal.php"); - bruno - prj - 438 - sprint 7 - tela principal

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
	//bruno - prj 438 - sprint 7 - tela principal
?>
<script type='text/javascript'>
	/**
	 * Salvar variaveis globais
	 */
    var_globais.vllimite = "<?php echo $vllimite; ?>";
	var_globais.dslimcre = "<?php echo $dslimcre; ?>";
	var_globais.dtmvtolt = "<?php echo $dtmvtolt; ?>";
	var_globais.dsfimvig = "<?php echo $dsfimvig; ?>";	
	var_globais.dtfimvig = "<?php echo $dtfimvig; ?>";
	var_globais.nrctrlim = "<?php echo $nrctrlim; ?>";
	var_globais.qtdiavig = "<?php echo $qtdiavig; ?>";
	var_globais.dsencfi1 = "<?php echo $dsencfi1; ?>";
	var_globais.dsencfi2 = "<?php echo $dsencfi2; ?>";
	var_globais.dsencfi3 = "<?php echo $dsencfi3; ?>";
	var_globais.dssitlli = "<?php echo $dssitlli; ?>";
	var_globais.dsmotivo = "<?php echo $dsmotivo; ?>";
	var_globais.nmoperad = "<?php echo $nmoperad; ?>";
	var_globais.flgpropo = "<?php echo $flgpropo; ?>";
	var_globais.nrctrpro = "<?php echo $nrctrpro; ?>";
	var_globais.cdlinpro = "<?php echo $cdlinpro; ?>";
	var_globais.vllimpro = "<?php echo $vllimpro; ?>";	
	var_globais.nmopelib = "<?php echo $nmopelib; ?>";
	var_globais.flgenvio = "<?php echo $flgenvio; ?>";
	var_globais.flgenpro = "<?php echo $flgenpro; ?>";
	var_globais.cddlinha = "<?php echo $cddlinha; ?>";
	var_globais.dsdlinha = "<?php echo $dsdlinha; ?>";
	var_globais.tpdocmto = "<?php echo $tpdocmto; ?>";
	var_globais.flgdigit = "<?php echo $flgdigit; ?>";
	var_globais.dsobserv = "<?php echo $dsobserv; ?>";	
	var_globais.dstprenv = "<?php echo $dstprenv; ?>";
	var_globais.dtrenova = "<?php echo $dtrenova; ?>";
	var_globais.qtrenova = "<?php echo $qtrenova; ?>";
	var_globais.flgimpnp = "<?php echo $flgimpnp; ?>";
	var_globais.dslimpro = "<?php echo $dslimpro; ?>";	
	var_globais.idcobope = "<?php echo $idcobope; ?>";
	var_globais.nivrisco = "<?php echo $nivrisco; ?>";	
	var_globais.dsdtxfix = "<?php echo $dsdtxfix; ?>";

	aux_cdcooper = '<?php echo $glbvars["cdcooper"]?>';
	aux_tpdocmto = '<?php echo $tpdocmto ?>';
	aux_GEDServidor = '<?php echo $GEDServidor;?>';

	aux_dtmvtolt = '<?php echo $glbvars["dtmvtolt"]?>';

</script>