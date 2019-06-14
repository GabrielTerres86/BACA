<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 12/03/2010 
 * OBJETIVO     : Rotina para validar/alterar os dados do CÔNJUGE da tela de CONTAS
 *
 * ALTERACOES   : [18/09/2015] Gabriel (RKAM)      : Reformulacao Cadastral (Gabriel)
 */
?>
 
<?	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '' ;		
	$nmconjug = (isset($_POST['nmconjug'])) ? $_POST['nmconjug'] : '' ;
	$nrcpfcjg = (isset($_POST['nrcpfcjg'])) ? $_POST['nrcpfcjg'] : '' ;
	$dtnasccj = (isset($_POST['dtnasccj'])) ? $_POST['dtnasccj'] : '' ;
	$tpdoccje = (isset($_POST['tpdoccje'])) ? $_POST['tpdoccje'] : '' ;
	$nrdoccje = (isset($_POST['nrdoccje'])) ? $_POST['nrdoccje'] : '' ;
	$cdoedcje = (isset($_POST['cdoedcje'])) ? $_POST['cdoedcje'] : '' ;
	$cdufdcje = (isset($_POST['cdufdcje'])) ? $_POST['cdufdcje'] : '' ;
	$dtemdcje = (isset($_POST['dtemdcje'])) ? $_POST['dtemdcje'] : '' ;
	$grescola = (isset($_POST['grescola'])) ? $_POST['grescola'] : '' ;
	$cdfrmttl = (isset($_POST['cdfrmttl'])) ? $_POST['cdfrmttl'] : '' ;
	$cdnatopc = (isset($_POST['cdnatopc'])) ? $_POST['cdnatopc'] : '' ;
	$cdocpcje = (isset($_POST['cdocpcje'])) ? $_POST['cdocpcje'] : '' ;
	$tpcttrab = (isset($_POST['tpcttrab'])) ? $_POST['tpcttrab'] : '' ;
	$nmextemp = (isset($_POST['nmextemp'])) ? $_POST['nmextemp'] : '' ;
	$dsproftl = (isset($_POST['dsproftl'])) ? $_POST['dsproftl'] : '' ;
	$cdnvlcgo = (isset($_POST['cdnvlcgo'])) ? $_POST['cdnvlcgo'] : '' ;
	$nrfonemp = (isset($_POST['nrfonemp'])) ? $_POST['nrfonemp'] : '' ;
	$nrramemp = (isset($_POST['nrramemp'])) ? $_POST['nrramemp'] : '' ;
	$cdturnos = (isset($_POST['cdturnos'])) ? $_POST['cdturnos'] : '' ;
	$dtadmemp = (isset($_POST['dtadmemp'])) ? $_POST['dtadmemp'] : '' ;
	$vlsalari = (isset($_POST['vlsalari'])) ? $_POST['vlsalari'] : '' ;
	$nrdocnpj = (isset($_POST['nrdocnpj'])) ? $_POST['nrdocnpj'] : '' ;
	$nrctacje = (isset($_POST['nrctacje'])) ? $_POST['nrctacje'] : '' ;
	$dsescola = (isset($_POST['dsescola'])) ? $_POST['dsescola'] : '' ;
	$rsfrmttl = (isset($_POST['rsfrmttl'])) ? $_POST['rsfrmttl'] : '' ;
	$rsnatocp = (isset($_POST['rsnatocp'])) ? $_POST['rsnatocp'] : '' ;
	$rsdocupa = (isset($_POST['rsdocupa'])) ? $_POST['rsdocupa'] : '' ;
	$dsctrtab = (isset($_POST['dsctrtab'])) ? $_POST['dsctrtab'] : '' ;
	$rsnvlcgo = (isset($_POST['rsnvlcgo'])) ? $_POST['rsnvlcgo'] : '' ;
	$dsturnos = (isset($_POST['dsturnos'])) ? $_POST['dsturnos'] : '' ;
	$cdgraupr = (isset($_POST['cdgraupr'])) ? $_POST['cdgraupr'] : '' ;
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '' ;
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = "";
	switch($operacao) {
		case 'AV': $procedure = 'valida_dados'; break;
		case 'VA': $procedure = 'grava_dados'; break;
		default: return false;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
		
	// Monta o xml dinâmico de acordo com a operação
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0057.p</Bo>";
	$xml .= "		<Proc>".$procedure."</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";	
	$xml .= "       <nmconjug>".$nmconjug."</nmconjug>";
	$xml .= "       <nrcpfcjg>".$nrcpfcjg."</nrcpfcjg>";
	$xml .= "       <nrctacje>".$nrctacje."</nrctacje>";	
	$xml .= "       <dtnasccj>".$dtnasccj."</dtnasccj>";
	$xml .= "       <tpdoccje>".$tpdoccje."</tpdoccje>";
	$xml .= "       <nrdoccje>".$nrdoccje."</nrdoccje>";
	$xml .= "       <cdoedcje>".$cdoedcje."</cdoedcje>";
	$xml .= "       <cdufdcje>".$cdufdcje."</cdufdcje>";
	$xml .= "       <dtemdcje>".$dtemdcje."</dtemdcje>";
	$xml .= "       <grescola>".$grescola."</grescola>";
	$xml .= "       <cdfrmttl>".$cdfrmttl."</cdfrmttl>";
	$xml .= "       <cdnatopc>".$cdnatopc."</cdnatopc>";
	$xml .= "       <cdocpcje>".$cdocpcje."</cdocpcje>";
	$xml .= "       <tpcttrab>".$tpcttrab."</tpcttrab>";
	$xml .= "       <nmextemp>".$nmextemp."</nmextemp>";
	$xml .= "       <dsproftl>".$dsproftl."</dsproftl>";
	$xml .= "       <cdnvlcgo>".$cdnvlcgo."</cdnvlcgo>";
	$xml .= "       <nrfonemp>".$nrfonemp."</nrfonemp>";
	$xml .= "       <nrramemp>".$nrramemp."</nrramemp>";
	$xml .= "       <cdturnos>".$cdturnos."</cdturnos>";
	$xml .= "       <dtadmemp>".$dtadmemp."</dtadmemp>";
	$xml .= "       <vlsalari>".$vlsalari."</vlsalari>";
	$xml .= "       <nrdocnpj>".$nrdocnpj."</nrdocnpj>";
	$xml .= "       <dsescola>".$dsescola."</dsescola>";
	$xml .= "       <rsfrmttl>".$rsfrmttl."</rsfrmttl>";
	$xml .= "       <rsnatocp>".$rsnatocp."</rsnatocp>";
	$xml .= "       <rsdocupa>".$rsdocupa."</rsdocupa>";
	$xml .= "       <dsctrtab>".$dsctrtab."</dsctrtab>";
	$xml .= "       <rsnvlcgo>".$rsnvlcgo."</rsnvlcgo>";
	$xml .= "       <dsturnos>".$dsturnos."</dsturnos>";
	$xml .= "       <cdgraupr>".$cdgraupr."</cdgraupr>";	
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msg 		= Array();	
	$msgRetorno = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];	
	$msgAlerta  = $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'];	
	$msgRvcad   = $xmlObjeto->roottag->tags[0]->attributes['MSGRVCAD'];	
	if ($msgRetorno != '' ) $msg[] = $msgRetorno;
	if ($msgAlerta  != '' ) $msg[] = $msgAlerta;
	if ($msgRvcad  != '' ) $msg[] = $msgRvcad;
	$stringArrayMsg = implode( "|", $msg);
	
	
	// Verificação da revisão Cadastral
	$msgAtCad = $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'];
	$chaveAlt = $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'];
	$tpAtlCad = $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'];

	if ($operacao == 'AV') {	
		
		// Se chegou até aqui, já realizou a validação, agora precisa solicitar confirmação e alteração		
		exibirConfirmacao('Deseja confirmar altera&ccedil;&atilde;o?','Confirmação - Aimaro','controlaOperacao(\'VA\');','bloqueiaFundo(divRotina);',false);		
		
	} else if ($operacao == 'VA') {
	
		// Caso a operação não é validar, então já realizou a validação, agora precisa verificar se existe "Verificação de Revisão Cadastral"
		if ($msgAtCad != '' && $flgcadas != 'M') {		
			exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0057.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FA\")\')',false);
		} else {	
		
			// Se não é validar, então é alteração, portanto mostrar mensagem de sucesso e retornar para página principal
			echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao()\');';
		}
	}
?>