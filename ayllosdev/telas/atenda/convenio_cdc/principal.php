<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Andre Santos (SUPERO)
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Mostrar opcao Principal da rotina de Liberar/Bloquear da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 24/08/2015 - Projeto Reformulacao cadastral		   
 *						  	  (Tiago Castro - RKAM)			 
 * --------------
 */	
?>
<?	
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	isPostMethod();
	require_once("../../../class/xmlfile.php");
			
		
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : 0  ;
	
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0194.p</Bo>";					
	$xml .= "		<Proc>pc-busca-convenios</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<cddopcao>C</cddopcao>';
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);	
	// Cria objeto para classe de tratamento de XML
	$xmlObjRegistro = getObjectXML($xmlResult);
	
    if (strtoupper($xmlObjRegistro->roottag->tags[0]->name) == 'ERRO') {
        exibirErro('error',$xmlObjRegistro->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
    }
	
	$flgativo = $xmlObjRegistro->roottag->tags[0]->attributes['FLGATIVO'];
	$dtcnvcdc = $xmlObjRegistro->roottag->tags[0]->attributes['DTCNVCDC'];

	include('form_convenio_cdc.php');
?>
<script >
	controlaLayout();
</script>
