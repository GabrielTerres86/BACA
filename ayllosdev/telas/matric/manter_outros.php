<? 
/*!
 * FONTE        : manter_outros.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 21/06/2010 
 * OBJETIVO     : Rotina para manter (validar e alterar) a operação [ X - Alteração Nome ] da tela MATRIC
 * ALTERAÇÕES   : 09/06/2012 - Ajustes referente ao projeto GP - Sócios Menores (Adriano)
 *                14/07/2015 - Projeto reformulacao cadastral (Gabriel-RKAM).
				  01/10/2015 - Adicionado nova opção "J" para alteração
							   apenas do cpf/cnpj e removido a possibilidade de
							   alteração pela opção "X", conforme solicitado no 
							   chamado 321572 (Kelvin).
				  17/06/2016 - M181 - Alterar o CDAGENCI para passar o CDPACTRA (Rafael Maciel - RKAM)
				  08/02/2017 - Ajuste realiazado para tratar o chamado 566462. (Kelvin)
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
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
	$nmprimtl = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '' ;
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '' ;		                                                       	
	$permalte = (isset($_POST['permalte'])) ? $_POST['permalte'] : '' ;	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;	
	$inhabmen = (isset($_POST['inhabmen'])) ? $_POST['inhabmen'] : '' ;	
	$dthabmen = (isset($_POST['dthabmen'])) ? $_POST['dthabmen'] : '' ;	
	
	$arrayFilhos = (isset($_POST['arrayFilhos'])) ? $_POST['arrayFilhos'] : '' ;	
		

	if ( $operacao == 'XV' || $operacao == 'JV'  ) validaDados();
	
	// Dependendo da operação, chamo uma procedure diferente
	$bo        = 'b1wgen0052.p';
	$procedure = '';
	
	switch($operacao) {
	
		case 'XV' : $procedure = 'Valida_Dados';   $cddopcao = 'X';  break;
		case 'JV' : $procedure = 'Valida_Dados';   $cddopcao = 'J';  break;
		case 'VX' : $procedure = 'Grava_Dados' ;   $cddopcao = 'X';  break;
		case 'VJ' : $procedure = 'Grava_Dados' ;   $cddopcao = 'J';  break;
		case 'PI' : $procedure = 'Valida_Dados';   $cddopcao = "PI"; break;
		case 'PA' : $procedure = 'Valida_Dados';   $cddopcao = "PA"; break;
		case 'CC' : $procedure = 'Valida_Cidades'; $cddopcao = 'C';  break; 
		case 'LCD': $procedure = 'LISTA_CONTAS_DUPLICACAO'; $bo = 'MATRIC'; break;
		case 'BCC': $procedure = 'Retorna_Conta'; break;
		case 'DCC': $procedure = 'DUPLICACAO_CONTA'; $bo = 'MATRIC'; break;
		default: return false;
	}
	
	$flgProgress = (substr($bo,0,6) == 'b1wgen');
		
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	
	if ($flgProgress) {
		$xml .= '	<Cabecalho>';
		$xml .= '		<Bo>'.$bo.'</Bo>';
		$xml .= '		<Proc>'.$procedure.'</Proc>';
		$xml .= '	</Cabecalho>';
	}
	
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';


	if ($flgProgress) {
		$xml .= '		<cdagenci>'.$glbvars['cdpactra'].'</cdagenci>';
		$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
		$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
		$xml .= '		<inhabmen>'.$inhabmen.'</inhabmen>';
		$xml .= '		<inhabmen>'.$dthabmen.'</inhabmen>';		
		$xml .= '       <idseqttl>1</idseqttl>';    
		$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>'; 
	}	 	
	
	// Concatenar os parametros via POST para o XML
	foreach ($_POST as $key => $value) {

		// Desconsiderar certos parametros
		if (in_array($key,array('arrayFilhos'))) {
			continue;
		}
	
		$xml .= "<$key>$value</$key>";   
		
	}
	

	
	if($procedure == 'Valida_Dados' ||
	   $procedure == 'Grava_Dados') {
	   
		$xml .= '       <nmrotina>MATRIC</nmrotina>';
		
		// Resp. Legal
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
	
		
	if  ($flgProgress) {
		$xmlResult = getDataXML($xml);
		$xmlObjeto = getObjectXML($xmlResult);	
	} else {
		$xmlResult = mensageria($xml, $bo, $procedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = simplexml_load_string($xmlResult);
	}
		
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