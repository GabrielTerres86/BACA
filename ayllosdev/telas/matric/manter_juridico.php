<? 
/*!
 * FONTE        : manter_juridico.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 17/06/2010 
 * OBJETIVO     : Rotina para validar/alterar os dados de pessoa juridica da tela MATRIC
 * ALTERAÇÕES   : 09/06/2012 - Ajustes referente ao projeto GP - Sócios Menores (Adriano)
 *                09/07/2015 - Projeto Reformulacao Cadastral (Gabriel-RKAM). 
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
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;	
	$nmprimtl = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '' ;
	$nmfansia = (isset($_POST['nmfansia'])) ? $_POST['nmfansia'] : '' ;
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '' ;
	$dtcnscpf = (isset($_POST['dtcnscpf'])) ? $_POST['dtcnscpf'] : '' ;
	$natjurid = (isset($_POST['natjurid'])) ? $_POST['natjurid'] : '' ; 
	$dtiniatv = (isset($_POST['dtiniatv'])) ? $_POST['dtiniatv'] : '' ;
	$cdseteco = (isset($_POST['cdseteco'])) ? $_POST['cdseteco'] : '' ;
	$nrtelefo = (isset($_POST['nrtelefo'])) ? $_POST['nrtelefo'] : '' ;
	$nrdddtfc = (isset($_POST['nrdddtfc'])) ? $_POST['nrdddtfc'] : '' ;
	$cdrmativ = (isset($_POST['cdrmativ'])) ? $_POST['cdrmativ'] : '' ;
	$dsendere = (isset($_POST['dsendere'])) ? $_POST['dsendere'] : '' ;
	$nmbairro = (isset($_POST['nmbairro'])) ? $_POST['nmbairro'] : '' ;
	$nrcepend = (isset($_POST['nrcepend'])) ? $_POST['nrcepend'] : '' ;
	$nmcidade = (isset($_POST['nmcidade'])) ? $_POST['nmcidade'] : '' ;
	$cdufende = (isset($_POST['cdufende'])) ? $_POST['cdufende'] : '' ;
	$dtdemiss = (isset($_POST['dtdemiss'])) ? $_POST['dtdemiss'] : '' ;
	$arrayFilhosAvtMatric = (isset($_POST['arrayFilhosAvtMatric'])) ? $_POST['arrayFilhosAvtMatric'] : '';
	$arrayBensMatric      = (isset($_POST['arrayBensMatric']))      ? $_POST['arrayBensMatric'] 	 : '';
	$arrayFilhos          = (isset($_POST['arrayFilhos'])) 			? $_POST['arrayFilhos'] 		 : '';
	$idorigee = (isset($_POST['idorigee'])) ? $_POST['idorigee'] : '' ;
	$nrlicamb = (isset($_POST['nrlicamb'])) ? $_POST['nrlicamb'] : '' ;
	
	if ( ($operacao == 'AV') || ($operacao == 'IV') ) validaDados();
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	$inpessoa  = 2;
	
	switch($operacao) {
	
		case 'IV': $procedure = 'valida_dados'; $cddopcao = 'I'; break;
		case 'VI': $procedure = 'grava_dados' ; $cddopcao = 'I'; break;
		case 'AV': $procedure = 'valida_dados'; $cddopcao = 'A'; break;
		case 'VA': $procedure = 'grava_dados' ; $cddopcao = 'A'; break;
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
	$xml .= '		<idseqttl>1</idseqttl>';	 
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';  
	
	// Concatenar os parametros via POST para o XML
	foreach ($_POST as $key => $value) {

		// Desconsiderar certos parametros
		if (in_array($key,array('arrayFilhosAvtMatric','arrayBensMatric','arrayFilhos'))) {
			continue;
		}
		
		// Retirar caracteres nao desejados
		if ($key == 'complend' || $key == 'dsendere') {
			$array1 = array("=","%","&","#","+","?","'",",",".","/",";","[","]","!","@","$","(",")","*","|",":","<",">","~","{","~","}","~");

			// limpeza dos caracteres nos campos 
			$value = trim(str_replace( $array1, " " , $value));
		}
	
		$xml .= "<$key>$value</$key>";   
		
	} 
	
	if($procedure == "grava_dados" || $procedure == "valida_dados"){ 

		/*Procuradores*/
		foreach ($arrayFilhosAvtMatric as $key => $value) {
			
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
			
			$xml .= retornaXmlFilhos( $campospc, $dadosprc, 'Procuradores', 'Procuradores');
			
		}
		
		/*Bens dos procuradores*/
		foreach ($arrayBensMatric as $key => $value) {
    
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
			
			$xml .= retornaXmlFilhos( $campospc, $dadosprc, 'Bens', 'Itens');
			
		}
		
	}
	
	if($procedure == "grava_dados"){ 

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
		
		$xml .= '		<idorigee>'.$idorigee.'</idorigee>';
		$xml .= '		<nrlicamb>'.$nrlicamb.'</nrlicamb>';  
	}
	
	$xml .= '	</Dados>';	
	$xml .= '</Root>';
	
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Include do arquivo que analisa o resultado do XML
	include('./manter_resultado.php');		
	
	// Validações em PHP
	function validaDados(){
	
		echo '$("input,select","#frmJuridico").removeClass("campoErro");';
		
		//-----------------------------
		//	   Dados da Empresa	  
		//-----------------------------
		
		//Razão social
		if ( $GLOBALS['nmprimtl'] == ''  ) exibirErro('error','Razão social deve ser preenchida.','Alerta - Ayllos','focaCampoErro(\'nmprimtl\',\'frmJuridico\');',false);
		
		//Razão social
		if ( $GLOBALS['nmfansia'] == ''  ) exibirErro('error','Nome fantasia deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'nmfansia\',\'frmJuridico\');',false);
		
		//CNPJ
		if ( $GLOBALS['nrcpfcgc'] == '' || $GLOBALS['nrcpfcgc'] == 0 ) exibirErro('error','CNPJ deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'nrcpfcgc\',\'frmJuridico\');',false);
						
		//Natureza jurídica
		if ( $GLOBALS['natjurid'] == '' || $GLOBALS['natjurid'] == 0 ) exibirErro('error','Naturaza jurídica deve ser selecionada.','Alerta - Ayllos','focaCampoErro(\'natjurid\',\'frmJuridico\');',false);
				
		//Data de inicio de atividade
		if ( $GLOBALS['dtiniatv'] == '' || !validaData( $GLOBALS['dtiniatv'] ) ) exibirErro('error','Data de início ativ. inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'dtiniatv\',\'frmJuridico\');',false);
				
		//Setor econômico
		if ( $GLOBALS['cdseteco'] == '' || $GLOBALS['cdseteco'] == 0 ) exibirErro('error','Setor econômico deve ser selecionado.','Alerta - Ayllos','focaCampoErro(\'cdseteco\',\'frmJuridico\');',false);
			
		//Cód. DDD
		if ( $GLOBALS['nrdddtfc'] == '' || $GLOBALS['nrdddtfc'] == 0 ) exibirErro('error','Código DDD inválido.','Alerta - Ayllos','focaCampoErro(\'nrdddtfc\',\'frmJuridico\');',false);
		
		//Nº Telefone
		if ( $GLOBALS['nrtelefo'] == '' || $GLOBALS['nrtelefo'] == 0 ) exibirErro('error','Número de telefone deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'nrtelefo\',\'frmJuridico\');',false);
		
		//Ramo atividade
		if ( $GLOBALS['cdrmativ'] == '' || $GLOBALS['cdrmativ'] == 0 ) exibirErro('error','Ramo de atividade deve ser selecionado.','Alerta - Ayllos','focaCampoErro(\'cdrmativ\',\'frmJuridico\');',false);
		
		//-----------------------------
		//		    Endereço
		//-----------------------------	

		//CEP
		if ( $GLOBALS['nrcepend'] == '' || $GLOBALS['nrcepend'] == 0 ) exibirErro('error','CEP deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'nrcepend\',\'frmJuridico\');',false);
		
		//Endereço
		if ( $GLOBALS['dsendere'] == ''  ) exibirErro('error','Endereço deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'dsendere\',\'frmJuridico\');',false);
				
		//Bairro
		if ( $GLOBALS['nmbairro'] == ''  ) exibirErro('error','Bairro deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'nmbairro\',\'frmJuridico\');',false);
		
		//U.F.
		if ( $GLOBALS['cdufende'] == ''  ) exibirErro('error','U.F. deve ser selecionado.','Alerta - Ayllos','focaCampoErro(\'cdufende\',\'frmJuridico\');',false);

		//Cidade
		if ( $GLOBALS['nmcidade'] == ''  ) exibirErro('error','Cidade deve ser preenchida.','Alerta - Ayllos','focaCampoErro(\'nmcidade\',\'frmJuridico\');',false);
		
		//-----------------------------
		//   Entrada/Saída Cooperado	  
		//-----------------------------
				
		//Data de saída
		if ( ( $GLOBALS['dtdemiss'] != '' ) && !validaData( $GLOBALS['dtdemiss'] ) ) exibirErro('error','Data de sa&iacute;da inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'dtdemiss\',\'frmJuridico\');',false);
				
	}	
?>