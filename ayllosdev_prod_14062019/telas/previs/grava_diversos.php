<? 
/*!
 * FONTE        : grava_diversos.php
 * CRIAÇÃO      : Adriano (CECRED)
 * DATA CRIAÇÃO : 22/08/2012
 * OBJETIVO     : Rotina para gravar os campos "Diversos" para o fluxo de saída/entrada.
 * --------------
 * ALTERAÇÕES   : 
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

	
	// Recebe a operação que está sendo realizada
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$cdmovmto = (isset($_POST['cdmovmto'])) ? $_POST['cdmovmto'] : '';
	$vlrepass = (isset($_POST['vlrepass'])) ? $_POST['vlrepass'] : '';
	$vlnumera = (isset($_POST['vlnumera'])) ? $_POST['vlnumera'] : '';
	$vlrfolha = (isset($_POST['vlrfolha'])) ? $_POST['vlrfolha'] : '';
	$vloutros = (isset($_POST['vloutros'])) ? $_POST['vloutros'] : '';
	$dtmvtolx = (isset($_POST['dtmvtolx'])) ? $_POST['dtmvtolx'] : '';
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		
	}
		
	//Monta o XML de requisição 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0131.p</Bo>";
	$xml .= "        <Proc>diversos</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "       <cdagenci>".$glbvars['cdagenci']."</cdagenci>";
	$xml .= "       <nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xml .= "       <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xml .= "       <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
	$xml .= "       <nmdatela>".$glbvars['nmdatela']."</nmdatela>";
	$xml .= "       <tpdmovto>".$cdmovmto."</tpdmovto>";
		
		$campospc = "";
		$dadosprc = "";
		$contador = 0;
		
		foreach ($vlrepass as $key => $value) {
					
			$contador++;
						
			if($contador == 1){
				$campospc .= "cdbcoval".$key;
				
			}else{
				$campospc .= "|"."cdbcoval".$key;
			}
			
			if($contador == 1){
				$dadosprc .= $value;
				
			}else{
				$dadosprc .= ";".$value;
			}
												
		}
	
		$xml .= retornaXmlFilhos( $campospc, $dadosprc, 'Vlrepass', 'vlrepass');
		
			
		$campospc = "";
		$dadosprc = "";
		$contador = 0;
			
		foreach ($vlnumera as $key => $value) {
				
			$contador++;
			
			if($contador == 1){
				$campospc .= "cdbcoval".$key;
				
			}else{
				$campospc .= "|"."cdbcoval".$key;
			}
			
			if($contador == 1){
				$dadosprc .= $value;
				
			}else{
				$dadosprc .= ";".$value;
			}
								
		}
			
		$xml .= retornaXmlFilhos( $campospc, $dadosprc, 'Vlnumera', 'vlnumera');
		
	
		$campospc = "";
		$dadosprc = "";
		$contador = 0;
		
		foreach ($vlrfolha as $key => $value) {
					
			$contador++;
			
			if($contador == 1){
				$campospc .= "cdbcoval".$key;
				
			}else{
				$campospc .= "|"."cdbcoval".$key;
			}
			
			if($contador == 1){
				$dadosprc .= $value;
				
			}else{
				$dadosprc .= ";".$value;
			}
							
		}

		$xml .= retornaXmlFilhos( $campospc, $dadosprc, 'Vlrfolha', 'vlrfolha');
		
	
		$campospc = "";
		$dadosprc = "";
		$contador = 0;
			
		foreach ($vloutros as $key => $value) {
				
			$contador++;
			
			if($contador == 1){
				$campospc .= "cdbcoval".$key;
				
			}else{
				$campospc .= "|"."cdbcoval".$key;
			}
			
			if($contador == 1){
				$dadosprc .= $value;
				
			}else{
				$dadosprc .= ";".$value;
			}
							
		}
		
		$xml .= retornaXmlFilhos( $campospc, $dadosprc, 'Vloutros', 'vloutros');
		
	
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
	
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		//exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
		exibirErro('error',$msgErro,'Alerta - Ayllos','bloqueiaCampo();',false);
		
	}		

	
	//Monta o XML de requisição 
	$xmlBusca  = "";
	$xmlBusca .= "<Root>";
	$xmlBusca .= "  <Cabecalho>";
	$xmlBusca .= "	    <Bo>b1wgen0131.p</Bo>";
	$xmlBusca .= "        <Proc>busca_dados_fluxo_singular</Proc>";
	$xmlBusca .= "  </Cabecalho>";
	$xmlBusca .= "  <Dados>";
	$xmlBusca .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xmlBusca .= "       <dtmvtolx>".$dtmvtolx."</dtmvtolx>";
	
		if($cdmovmto == "E"){
			$xmlBusca .= "       <tpdmovto>1</tpdmovto>";
		}else if($cdmovmto == "S"){
			$xmlBusca .= "       <tpdmovto>2</tpdmovto>";
		}
	
	$xmlBusca .= "  </Dados>";
	$xmlBusca .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResultBusca = getDataXML($xmlBusca);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjetoBusca = getObjectXML($xmlResultBusca);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjetoBusca->roottag->tags[0]->name) == "ERRO" ) {
	
		$msgErro	= $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','bloqueiaCampo();',false);
		
	}
		
	if($cdmovmto == "E" || $cdmovmto == "S"){
		
		$cdbcoval = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[0]->tags;
		$tpdmovto = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[1]->tags;
		$vlcheque = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[2]->tags;
		$vltotdoc = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[3]->tags;
		$vltotted = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[4]->tags;
		$vltottit = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[5]->tags;
		$vldevolu = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[6]->tags;
		$vlmvtitg = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[7]->tags; 
		$vlttinss = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[8]->tags;
		$vltrdeit = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[9]->tags;
		$vlsatait = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[10]->tags;
		$vlfatbra = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[11]->tags;
		$vlconven = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[12]->tags;
		$vlrepass = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[13]->tags;
		$vlnumera = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[14]->tags;
		$vlrfolha = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[15]->tags;
		$vldivers = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[16]->tags;
		$vlttcrdb = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[17]->tags;				
		
		$vloutros = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags[18]->tags;
		
	}
	

	$registro = $xmlObjetoBusca->roottag->tags[0]->tags[0]->tags;  
	include('form_cabecalho.php');
	include('form_fluxo.php');
	
	
		
?>

<script type="text/javascript">
		
	controlaLayout();
	$('#vlrepass1','#frmFluxo').focus();
	
	
</script>
	
	
	
