<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jonata (Rkam)
 * DATA CRIAÇÃO : 11/08/2014 
 * OBJETIVO     : Rotina para validar/alterar os dados do Protecao. ao Credito da tela de CONTAS
 * ALTERACOES	: 12/01/2016 - Inclusao do parametro de assinatura conjunta, Prj. 131 (Jean Michel)
 */
?>
 
<?	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';	
	
	// Guardo os parâmetos do POST em variáveis
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '' ;		
	$cdagepac = (isset($_POST['cdagepac'])) ? $_POST['cdagepac'] : '' ;
	$cdsitdct = (isset($_POST['cdsitdct'])) ? $_POST['cdsitdct'] : '' ;
	$cdtipcta = (isset($_POST['cdtipcta'])) ? $_POST['cdtipcta'] : '' ;
	$cdbcochq = (isset($_POST['cdbcochq'])) ? $_POST['cdbcochq'] : '' ;
	$nrdctitg = (isset($_POST['nrdctitg'])) ? $_POST['nrdctitg'] : '' ;
	$cdagedbb = (isset($_POST['cdagedbb'])) ? $_POST['cdagedbb'] : '' ;
	$cdbcoitg = (isset($_POST['cdbcoitg'])) ? $_POST['cdbcoitg'] : '' ;
	$cdsecext = (isset($_POST['cdsecext'])) ? $_POST['cdsecext'] : '' ;
	$dtcnsscr = (isset($_POST['dtcnsscr'])) ? $_POST['dtcnsscr'] : '' ;
	$dtcnsspc = (isset($_POST['dtcnsspc'])) ? $_POST['dtcnsspc'] : '' ;
	$dtdsdspc = (isset($_POST['dtdsdspc'])) ? $_POST['dtdsdspc'] : '' ;
	$dtabtcoo = (isset($_POST['dtabtcoo'])) ? $_POST['dtabtcoo'] : '' ;
	$dtelimin = (isset($_POST['dtelimin'])) ? $_POST['dtelimin'] : '' ;
	$dtabtcct = (isset($_POST['dtabtcct'])) ? $_POST['dtabtcct'] : '' ;
	$dtdemiss = (isset($_POST['dtdemiss'])) ? $_POST['dtdemiss'] : '' ;
	$flgiddep = (isset($_POST['flgiddep'])) ? $_POST['flgiddep'] : '' ;
	$tpavsdeb = (isset($_POST['tpavsdeb'])) ? $_POST['tpavsdeb'] : '' ;
	$tpextcta = (isset($_POST['tpextcta'])) ? $_POST['tpextcta'] : '' ;
	$inadimpl = (isset($_POST['inadimpl'])) ? $_POST['inadimpl'] : '' ;
	$inlbacen = (isset($_POST['inlbacen'])) ? $_POST['inlbacen'] : '' ;
	$idastcjt = (isset($_POST['idastcjt'])) ? $_POST['idastcjt'] : '' ;
	$flgexclu = 'N';
	$flgcreca = 'N';
	$flgrestr = (isset($_POST['flgrestr'])) ? $_POST['flgrestr'] : '' ;
	$flgcrdpa = (isset($_POST['flgcrdpa'])) ? $_POST['flgcrdpa'] : '' ;
	$cdcatego = (isset($_POST['cdcatego'])) ? $_POST['cdcatego'] : '' ;

		
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = "";
	
	switch($operacao) {
		case 'AV': $procedure  = 'valida_dados'; break;
		case 'VA': $procedure  = 'grava_dados'; break;
		default: return false;
	}	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'A')) <> "") exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0074.p</Bo>";
	$xml .= "		<Proc>".$procedure."</Proc>";
	$xml .= "	</Cabecalho>";	
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<cdagepac>'.$cdagepac.'</cdagepac>';
	$xml .= '		<cdsitdct>'.$cdsitdct.'</cdsitdct>';	
	$xml .= '		<cdtipcta>'.$cdtipcta.'</cdtipcta>';
	$xml .= '		<cdbcochq>'.$cdbcochq.'</cdbcochq>';
	$xml .= '		<nrdctitg>'.$nrdctitg.'</nrdctitg>';
	$xml .= '		<cdagedbb>'.$cdagedbb.'</cdagedbb>';
	$xml .= '		<cdbcoitg>'.$cdbcoitg.'</cdbcoitg>';
	$xml .= '		<cdsecext>'.$cdsecext.'</cdsecext>';
	$xml .= '		<dtcnsscr>'.$dtcnsscr.'</dtcnsscr>';
	$xml .= '		<dtcnsspc>'.$dtcnsspc.'</dtcnsspc>';
	$xml .= '		<dtdsdspc>'.$dtdsdspc.'</dtdsdspc>';
	$xml .= '		<dtabtcoo>'.$dtabtcoo.'</dtabtcoo>';
	$xml .= '		<dtelimin>'.$dtelimin.'</dtelimin>';
	$xml .= '		<dtabtcct>'.$dtabtcct.'</dtabtcct>';
	$xml .= '		<dtdemiss>'.$dtdemiss.'</dtdemiss>';
	$xml .= '		<flgiddep>'.$flgiddep.'</flgiddep>';
	$xml .= '		<tpavsdeb>'.$tpavsdeb.'</tpavsdeb>';
	$xml .= '		<tpextcta>'.$tpextcta.'</tpextcta>';
	$xml .= '		<inadimpl>'.$inadimpl.'</inadimpl>';
	$xml .= '		<inlbacen>'.$inlbacen.'</inlbacen>';
	$xml .= '		<cddopcao>A</cddopcao>';
	$xml .= '		<tpevento>A</tpevento>';
	$xml .= '		<flgexclu>'.$flgexclu.'</flgexclu>';
	$xml .= '		<flgcreca>'.$flgcreca.'</flgcreca>';
	$xml .= '		<flgrestr>'.$flgrestr.'</flgrestr>';
	$xml .= '		<flgcrdpa>'.$flgcrdpa.'</flgcrdpa>';
	$xml .= '		<idastcjt>'.$idastcjt.'</idastcjt>';
	$xml .= '		<cdcatego>'.$cdcatego.'</cdcatego>';
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
		
	// Se é Validação
	if( $operacao == 'AV' ) {
		exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacao(\'VA\');','bloqueiaFundo(divRotina)',false);		
	}
		
?>