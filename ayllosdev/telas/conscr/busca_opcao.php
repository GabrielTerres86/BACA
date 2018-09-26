<? 
/*!
 * FONTE        : busca_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 01/12/2011 
 * OBJETIVO     : Rotina para busca 
 */
?>

<?	
	
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$procedure = ''; 
	$retornoAposErro= '';
	
	// Guardo os parâmetos do POST em variáveis	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '';
	$cdvencto = (isset($_POST['cdvencto'])) ? $_POST['cdvencto'] : '';
	$cdmodali = (isset($_POST['cdmodali'])) ? $_POST['cdmodali'] : '';
	$cdsubmod = (isset($_POST['cdsubmod'])) ? $_POST['cdsubmod'] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	switch( $cddopcao ) {
		// Complemento
		case 'C': 	$procedure = 'Busca_Complemento'; break;

		// Historico
		case 'H': 	$procedure = 'Busca_Historico'; break;
		
		// Fluxo
		case 'F': 	if ( $operacao == 'fluxo' ) {
						$procedure = 'Busca_Fluxo';
					} else if ( $operacao == 'vencimento') {
						$procedure = 'Busca_Fluxo_Vencimento';
					}
		break;
		
		// Modalidade
		case 'M': 	if ( $operacao == 'modalidade' ) {
						$procedure = 'Busca_Modalidade';
					} else if ( $operacao == 'detalhe') {
					 	$procedure = 'Busca_Modalidade_Detalhe';
					} else if ( $operacao == 'vencimento') {
						$cdmodali  = !empty($cdsubmod) ? $cdsubmod : $cdmodali;
						$procedure = 'Busca_Modalidade_Vencimento';
					}
		break;		
		default: return false; break;
	}
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0125.p</Bo>";
	$xml .= "        <Proc>".$procedure."</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars['cdagenci']."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";	
	$xml .= "		<dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";	
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";	
	$xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= "		<cdvencto>".$cdvencto."</cdvencto>";	
	$xml .= "		<cdmodali>".$cdmodali."</cdmodali>";	
	$xml .= "  </Dados>";
	$xml .= "</Root>";	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$retornoAposErro,false);
	}

	$registro 	= $xmlObj->roottag->tags[0]->tags;
	$msgretor 	= $xmlObj->roottag->tags[0]->attributes['MSGRETOR'];
	$cdmodali 	= $xmlObj->roottag->tags[0]->attributes['CDMODALI'];
	$dsmodali 	= $xmlObj->roottag->tags[0]->attributes['DSMODALI'];
	
	$qtdfluxo	= count($registro);

	if ( empty($msgretor) and $qtdfluxo > 0  ) {
	
		// Complemento 
		if ( $cddopcao == 'C' ) {
			include('form_complemento.php');
	
		// Historico 
		} else if ( $cddopcao == 'H' ) {
			include('tab_historico.php');
		
		// Fluxo
		} else if ( $cddopcao == 'F' ) {
			//
			if ( $operacao == 'fluxo') {
				include('form_fluxo.php');
			//	
			} else if ( $operacao == 'vencimento' ) {
				include('tab_fluxo_vencimento.php');
			}
			
		// Modalidade	
		} else if ( $cddopcao == 'M' ) {
			//
			if ( $operacao == 'modalidade' ) {
				include('tab_modalidade.php');
				
			// Detalhe	
			} else if ( $operacao == 'detalhe' ) {
				include('tab_modalidade_detalhe.php');
			
			// Vencimento
			} else if ( $operacao == 'vencimento' ) {
				include('tab_modalidade_vencimento.php');
			}
		}
	} 
	
?>

<script>
msgretor = '<?php echo $msgretor ?>';
qtdregis = '<?php echo $qtdfluxo ?>';
</script>