<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jorge I. Hamaguchi 
 * DATA CRIAÇÃO : 25/07/2013
 * OBJETIVO     : Rotina para geração de relatorios da tela RELINT.
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 

<?	
	session_cache_limiter("private");
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdagetel = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0 ;
	$nmarqtel = (isset($_POST['nmarqtel'])) ? $_POST['nmarqtel'] : '' ;
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	$nmendter = session_id();
	
	// Verifica Procedure a ser executada	
	switch($cddopcao) {
		case 'V': { $procedure = 'gerar_relatorio_relint'; 	} break;
		case 'R': { $procedure = 'gerar_relatorio_relint'; 	} break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('atencao',$msgError,'Alerta - Ayllos','',false);
	}

	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0158.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<cdagetel>'.$cdagetel.'</cdagetel>';
	$xml .= '		<nmarqtel>'.$nmarqtel.'</nmarqtel>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
    // Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	$xmlObjCarregaImpressao = getObjectXML($xmlResult);
	

	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjCarregaImpressao->roottag->tags[0]->name == "ERRO") {
	    
		$msgerro = $xmlObjCarregaImpressao->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		
		if($cddopcao == "V"){
			$msgerro = "<script type='text/javascript'>alert('".$msgerro."');</script>";
		}else if($cddopcao == "R"){
			$msgerro = "showError('error','".$msgerro."','Alerta - Ayllos','hideMsgAguardo();');";
		}
		echo $msgerro;
		exit();
    }
	//Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjCarregaImpressao->roottag->tags[0]->attributes["NMARQPDF"];
	
	if ($cddopcao == "V"){
		//Chama função para mostrar PDF do impresso gerado no browser	 
		visualizaPDF($nmarqpdf);
	}else if ($cddopcao == "R"){
		echo "showError('inform','O Arquivo foi gerado em ".$nmarqpdf."','Alerta - Ayllos','hideMsgAguardo();');";
		exit();
	}
	
?>