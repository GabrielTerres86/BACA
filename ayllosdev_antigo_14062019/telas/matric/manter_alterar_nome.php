<? 
/*!
 * FONTE        : manter_fisico.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 21/06/2010 
 * OBJETIVO     : Rotina para manter (validar e alterar) a operação [ X - Alteração Nome ] da tela MATRIC
 * ALTERAÇÕES   : 09/06/2012 - Ajustes referente ao projeto GP - Sócios Menores (Adriano)
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ; 
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
	$rowidass = (isset($_POST['rowidass'])) ? $_POST['rowidass'] : '' ; 
	$nmprimtl = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '' ;
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '' ;
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '' ;		                                                       
	$cdagepac = (isset($_POST['cdagepac'])) ? $_POST['cdagepac'] : '' ;		                                                       
	$dtdemiss = (isset($_POST['dtdemiss'])) ? $_POST['dtdemiss'] : '' ;		                                                       
	$inmatric = (isset($_POST['inmatric'])) ? $_POST['inmatric'] : '' ;		                                                       
	$dtnasctl = (isset($_POST['dtnasctl'])) ? $_POST['dtnasctl'] : '' ;		                                                       
	$nmmaettl = (isset($_POST['nmmaettl'])) ? $_POST['nmmaettl'] : '' ;		                                                       
	$dtcnscpf = (isset($_POST['dtcnscpf'])) ? $_POST['dtcnscpf'] : '' ;		                                                       
	$cdsitcpf = (isset($_POST['cdsitcpf'])) ? $_POST['cdsitcpf'] : '' ;	
	$inhabmen = (isset($_POST['inhabmen'])) ? $_POST['inhabmen'] : '' ;	
	$dthabmen = (isset($_POST['dthabmen'])) ? $_POST['dthabmen'] : '' ;	
	$verrespo = (isset($_POST['verrespo'])) ? $_POST['verrespo'] : '' ;	
	$permalte = (isset($_POST['permalte'])) ? $_POST['permalte'] : '' ;	
	$arrayFilhos = (isset($_POST['arrayFilhos'])) ? $_POST['arrayFilhos'] : '' ;	
		

	if ( $operacao == 'XV' ) validaDados();
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	switch($operacao) {
	
		case 'XV': $procedure = 'valida_dados'; $cddopcao = 'X'; break;
		case 'VX': $procedure = 'grava_dados' ; $cddopcao = 'X'; break;
		case 'PI': $procedure = 'valida_dados'; $cddopcao = "PI"; break;
		case 'PA': $procedure = 'valida_dados'; $cddopcao = "PA"; break;
		default: return false;
		
	}
		
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0052.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';    	
	$xml .= '       <idseqttl>1</idseqttl>';    	
	$xml .= '       <rowidass>'.$rowidass.'</rowidass>';    	
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';    	
	$xml .= '		<nmprimtl>'.$nmprimtl.'</nmprimtl>';    
	$xml .= '       <nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';    
	$xml .= '       <inpessoa>'.$inpessoa.'</inpessoa>';
	$xml .= '       <cdagepac>'.$cdagepac.'</cdagepac>';    
	$xml .= '       <dtdemiss>'.$dtdemiss.'</dtdemiss>';    
	$xml .= '       <inmatric>'.$inmatric.'</inmatric>';    
	$xml .= '       <dtnasctl>'.$dtnasctl.'</dtnasctl>';    
	$xml .= '       <nmmaettl>'.$nmmaettl.'</nmmaettl>';    
	$xml .= '       <dtcnscpf>'.$dtcnscpf.'</dtcnscpf>';    
	$xml .= '       <cdsitcpf>'.$cdsitcpf.'</cdsitcpf>';    
	
	if($procedure == "valida_dados"){ 
	
		$xml .= '		<verrespo>'.$verrespo.'</verrespo>'; 	
		$xml .= '		<permalte>'.$permalte.'</permalte>'; 
		$xml .= '       <dthabmen>'.$dthabmen.'</dthabmen>';
		$xml .= '       <inhabmen>'.$inhabmen.'</inhabmen>';
				
	}
	
	if($procedure == 'valida_dados' ||
	   $procedure == 'grava_dados'){
	   
		$xml .= '       <nmrotina>MATRIC</nmrotina>';
		
		/*Resp. Legal*/
		foreach ($arrayFilhos as $key => $value) {
    
			$campospc = "";
			$dadosprc = "";
			$contador = 0;
			
			foreach( $value as $chave => $valor ){
				
				$contador++;
				
				if($contador == 1){
					$campospc .= $chave;
					
				}else{
					$campospc .= "|".$chave;
				}
				
				if($contador == 1){
					$dadosprc .= $valor;
					
				}else{
					$dadosprc .= ";".$valor;
				}
				
			}
			
			$xml .= retornaXmlFilhos( $campospc, $dadosprc, 'RespLegal', 'Responsavel');
			
		}
		
	}
		
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';                                      
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	

	// Include do arquivo que analisa o resultado do XML
	include('./manter_resultado.php');		
	
	// Validações em PHP
	function validaDados(){
		
		$nomeForm = ( $GLOBALS['inpessoa'] == 1 ) ? 'frmFisico' : 'frmJuridico';
		
		echo '$("input,select","#'.$nomeForm.'").removeClass("campoErro");';
		
		//Nome do titular
		if ( $GLOBALS['nmprimtl'] == ''  ) {
			$msgErro = ( $GLOBALS['inpessoa'] == 1 ) ? 'Nome deve ser preenchido.' : 'Rasão social deve se preenchida.' ;
			exibirErro('error',$msgErro,'Alerta - Aimaro','focaCampoErro(\'nmprimtl\',\''.$nomeForm.'\');',false);
		}	
		
		
	}	
		
?>