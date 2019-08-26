<? 
/*!
 * FONTE        : grava_apli_resg.php
 * CRIAÇÃO      : Adriano (CECRED)
 * DATA CRIAÇÃO : 28/08/2012
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
	$dtmvtolx = (isset($_POST['dtmvtolx'])) ? $_POST['dtmvtolx'] : '';
	$cdcoopex = (isset($_POST['cdcoopex'])) ? $_POST['cdcoopex'] : '';
	$vlresgat = (isset($_POST['vlresgat'])) ? $_POST['vlresgat'] : '';
	$vlresgan = (isset($_POST['vlresgan'])) ? $_POST['vlresgan'] : '';
	$vlaplica = (isset($_POST['vlaplica'])) ? $_POST['vlaplica'] : '';
	$vlaplian = (isset($_POST['vlaplian'])) ? $_POST['vlaplian'] : '';
	$cdmovmto = (isset($_POST['cdmovmto'])) ? $_POST['cdmovmto'] : '';
	
			
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		
	}
		
	
	//Monta o XML de requisição 
	$xmlApliResg  = "";
	$xmlApliResg .= "<Root>";
	$xmlApliResg .= "  <Cabecalho>";
	$xmlApliResg .= "	    <Bo>b1wgen0131.p</Bo>";
	$xmlApliResg .= "        <Proc>grava_apli_resg</Proc>";
	$xmlApliResg .= "  </Cabecalho>";
	$xmlApliResg .= "  <Dados>";
	$xmlApliResg .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xmlApliResg .= "       <cdagenci>".$glbvars['cdagenci']."</cdagenci>";
	$xmlApliResg .= "       <nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xmlApliResg .= "       <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xmlApliResg .= "       <nmdatela>".$glbvars['nmdatela']."</nmdatela>";
	$xmlApliResg .= "       <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
	$xmlApliResg .= "       <dtmvtolx>".$dtmvtolx."</dtmvtolx>";
	$xmlApliResg .= "       <vlresgat>".$vlresgat."</vlresgat>";
	$xmlApliResg .= "       <vlresgan>".$vlresgan."</vlresgan>";
	$xmlApliResg .= "       <vlaplica>".$vlaplica."</vlaplica>";
	$xmlApliResg .= "       <vlaplian>".$vlaplian."</vlaplian>";
	$xmlApliResg .= "  </Dados>";
	$xmlApliResg .= "</Root>";	

	
	// Executa script para envio do XML
	$xmlResultApliResg = getDataXML($xmlApliResg);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjetoApliResg = getObjectXML($xmlResultApliResg);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjetoApliResg->roottag->tags[0]->name) == "ERRO" ) {
	
		$msgErro	= $xmlObjetoApliResg->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','bloqueiaCampo();',false);
		
		
	}		

	//Monta o XML de requisição 
	$xmlCons  = "";
	$xmlCons .= "<Root>";
	$xmlCons .= "  <Cabecalho>";
	$xmlCons .= "	    <Bo>b1wgen0131.p</Bo>";
	$xmlCons .= "        <Proc>busca_dados_consolidado_singular</Proc>";
	$xmlCons .= "  </Cabecalho>";
	$xmlCons .= "  <Dados>";
	$xmlCons .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xmlCons .= "       <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
	$xmlCons .= "       <cdcoopex>".$cdcoopex."</cdcoopex>";
	$xmlCons .= "  </Dados>";
	$xmlCons .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResultCons = getDataXML($xmlCons);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjetoCons = getObjectXML($xmlResultCons);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if( strtoupper($xmlObjetoCons->roottag->tags[0]->name) == "ERRO" ) {
	
		$msgErro	= $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','bloqueiaCampo();',false);
			
		
	}
	
	$cdcooper = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[0]->cdata;
	$cdagenci = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[1]->cdata;
	$cdoperad = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[2]->cdata;
	$dtmvtolt = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[3]->cdata;
	$vlentrad = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[4]->cdata;
	$vlsaidas = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[5]->cdata;
	$vlresult = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[6]->cdata;
	$vlsldfin = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[7]->cdata;
	$vlsldcta = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[8]->cdata;
	$vlresgat = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[9]->cdata;
	$vlaplica = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[10]->cdata;
	$nmrescop = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[11]->cdata;
	$nmoperad = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[12]->cdata;
	$hrtransa = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags[13]->cdata;
		
	
	$registro = $xmlObjetoCons->roottag->tags[0]->tags[0]->tags;  
	include('form_cabecalho.php');
	include('form_fluxo.php');
		
		
?>

<script type="text/javascript">
		
	controlaLayout();
	$('#vlresgat','#frmFluxo').focus();
	
	
</script>
	
	
	
