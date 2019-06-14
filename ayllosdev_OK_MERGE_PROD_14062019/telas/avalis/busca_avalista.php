<? 
/*!
 * FONTE        : busca_avalista.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 29/11/2012
 * OBJETIVO     : Rotina para buscar avalistas na tela AVALIS
 * --------------
 * ALTERAÇÕES   :  05/08/2015 - Alterado para chamar a nova rotina do oracle (Jéssica - DB1)
 * -------------- 
 *
 * -------------- 
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$nmdavali	= (isset($_POST['nmdavali'])) ? $_POST['nmdavali'] : ''  ;
	
	$retornoAposErro = 'estadoInicial();';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro',$retornoAposErro,false);
	}	
	
	$xmlBuscaAvalista  = "";
	$xmlBuscaAvalista .= "<Root>";
	$xmlBuscaAvalista .= " <Dados>";
	$xmlBuscaAvalista .= "	 <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlBuscaAvalista .= "	 <nmdavali>".$nmdavali."</nmdavali>";
	$xmlBuscaAvalista .= " </Dados>";
	$xmlBuscaAvalista .= "</Root>";
					
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscaAvalista, "AVALIS", "BUSCADADOSAVALIS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjBuscaAvalista = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjBuscaAvalista->roottag->tags[0]->name) == 'ERRO') {	

		$msgErro	= $xmlObjBuscaAvalista->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$mtdErro = " $('#nmdavali','#frmAvalis').habilitaCampo().focus().addClass(\'campoErro\');bloqueiaFundo( $('#divRotina') );"; 
		
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);		
		
	} 
	
	$registros = $xmlObjBuscaAvalista->roottag->tags;
	
	include ('tab_avalista.php');
	
?>