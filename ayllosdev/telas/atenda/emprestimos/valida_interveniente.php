<? 
/*!
 * FONTE        : valida_interveniente.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 06/05/2011 
 * OBJETIVO     : valida os dados dos intervenientes.
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [12/05/2017] Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
 */
?>
 
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$nrctaava = (isset($_POST['nrctaava'])) ? $_POST['nrctaava'] : '';
	$cdnacion = (isset($_POST['cdnacion'])) ? $_POST['cdnacion'] : '';
	$tpdocava = (isset($_POST['tpdocava'])) ? $_POST['tpdocava'] : '';
	$nmconjug = (isset($_POST['nmconjug'])) ? $_POST['nmconjug'] : '';
	$tpdoccjg = (isset($_POST['tpdoccjg'])) ? $_POST['tpdoccjg'] : '';
	$dsendre1 = (isset($_POST['dsendre1'])) ? $_POST['dsendre1'] : '';
	$nrfonres = (isset($_POST['nrfonres'])) ? $_POST['nrfonres'] : '';
	$nmcidade = (isset($_POST['nmcidade'])) ? $_POST['nmcidade'] : '';
	$nrcepend = (isset($_POST['nrcepend'])) ? $_POST['nrcepend'] : '';
	$nmdavali = (isset($_POST['nmdavali'])) ? $_POST['nmdavali'] : '';
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '';
	$nrdocava = (isset($_POST['nrdocava'])) ? $_POST['nrdocava'] : '';
	$nrcpfcjg = (isset($_POST['nrcpfcjg'])) ? $_POST['nrcpfcjg'] : '';
	$nrdoccjg = (isset($_POST['nrdoccjg'])) ? $_POST['nrdoccjg'] : '';
	$dsendre2 = (isset($_POST['dsendre2'])) ? $_POST['dsendre2'] : '';
	$dsdemail = (isset($_POST['dsdemail'])) ? $_POST['dsdemail'] : '';
	$cdufresd = (isset($_POST['cdufresd'])) ? $_POST['cdufresd'] : '';
	$nomeform = (isset($_POST['nomeform'])) ? $_POST['nomeform'] : '';
	$cddopcao = 'A';                                                  
	
	$tpdocava = ( $tpdocava == 'null' ) ? '' : $tpdocava;
	$tpdoccjg = ( $tpdoccjg == 'null' ) ? '' : $tpdoccjg;
	$cdufresd = ( $cdufresd == 'null' ) ? '' : $cdufresd;
				
	// Monta o xml de requisição
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0002.p</Bo>";
	$xml .= "		<Proc>valida-interv</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";			
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";            
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";            
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";            
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	        
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";            
	$xml .= "		<nrctaava>".$nrctaava."</nrctaava>";                        
	$xml .= "		<cdnacion>".$cdnacion."</cdnacion>";                        
	$xml .= "		<tpdocava>".$tpdocava."</tpdocava>";                        
	$xml .= "		<nmconjug>".$nmconjug."</nmconjug>";                        
	$xml .= "		<tpdoccjg>".$tpdoccjg."</tpdoccjg>";                        
	$xml .= "		<dsendre1>".$dsendre1."</dsendre1>";                        
	$xml .= "		<nrfonres>".$nrfonres."</nrfonres>";                        
	$xml .= "		<nmcidade>".$nmcidade."</nmcidade>";                        
	$xml .= "		<nrcepend>".$nrcepend."</nrcepend>";                        
	$xml .= "		<nmdavali>".$nmdavali."</nmdavali>";                        
	$xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";                        
	$xml .= "		<nrdocava>".$nrdocava."</nrdocava>";                        
	$xml .= "		<nrcpfcjg>".$nrcpfcjg."</nrcpfcjg>";                        
	$xml .= "		<nrdoccjg>".$nrdoccjg."</nrdoccjg>";                        
	$xml .= "		<dsendre2>".$dsendre2."</dsendre2>";                        
	$xml .= "		<dsdemail>".$dsdemail."</dsdemail>";                        
	$xml .= "		<cdufresd>".$cdufresd."</cdufresd>";                        
	$xml .= "	</Dados>";                                                      
	$xml .= "</Root>";                                                          
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	$nomeCampo = $xmlObj->roottag->tags[0]->attributes['NMDCAMPO'];
	
	if ( $nomeCampo != '' ) {
		$mtdErro = 'focaCampoErro(\''.$nomeCampo.'\',\''.$nomeform.'\');bloqueiaFundo(divRotina);';
	} else {
		$mtdErro = 'bloqueiaFundo(divRotina);';
	}
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$mtdErro,false);
	}
				
?>