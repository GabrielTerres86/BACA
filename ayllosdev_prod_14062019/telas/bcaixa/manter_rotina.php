<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 03/11/2011 
 * OBJETIVO     : Rotina para manter as operações da tela BCAIXA
 * --------------
 * ALTERAÇÕES   : 28/08/2013 - Incluido o parametro dtrefere para a procedure Busca_Dados (Carlos)
 *
 *                15/08/2017 - Chamar rotina de senha do coordenador caso a data referencia seja difrente
 *                             da data atual (Lucas Ranghetti #665982)
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
	$dsiduser = session_id();	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$dtrefere = $dtmvtolt = (isset($_POST['dtmvtolt'])) ? $_POST['dtmvtolt'] : '';
	$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0 ; 
	$nrdcaixa = (isset($_POST['nrdcaixa'])) ? $_POST['nrdcaixa'] : 0 ;
	$cdopecxa = (isset($_POST['cdopecxa'])) ? $_POST['cdopecxa'] : '';
	$cdoplanc = (isset($_POST['cdoplanc'])) ? $_POST['cdoplanc'] : '';
	$vldentra = (isset($_POST['vldentra'])) ? $_POST['vldentra'] : 0 ;
	$vldsaida = (isset($_POST['vldsaida'])) ? $_POST['vldsaida'] : 0 ;
	$nrdlacre = (isset($_POST['nrdlacre'])) ? $_POST['nrdlacre'] : 0 ;
	$qtautent = (isset($_POST['qtautent'])) ? $_POST['qtautent'] : 0 ;
	$vldsdini = (isset($_POST['vldsdini'])) ? $_POST['vldsdini'] : 0 ;
	$nrdmaqui = (isset($_POST['nrdmaqui'])) ? $_POST['nrdmaqui'] : 0 ;
	$dsdcompl = (isset($_POST['dsdcompl'])) ? $_POST['dsdcompl'] : '';
	$vldocmto = (isset($_POST['vldocmto'])) ? $_POST['vldocmto'] : 0 ;
	$cdhistor = (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : 0 ;
	$nrdocmto = (isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : 0 ;
	$nrseqdig = (isset($_POST['nrseqdig'])) ? $_POST['nrseqdig'] : 0 ;
	$operauto = (isset($_POST['operauto'])) ? $_POST['operauto'] : '';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// procedure
	switch( $operacao ) {
		case 'BD': $procedure = 'Busca_Dados';		$retornoAposErro= "$('#cddopcao','#frmCab').focus();";	break;
		case 'VD': $procedure = 'Valida_Dados'; 															break;
		case 'VH': $procedure = 'Valida_Historico';															break;
		case 'GD': $procedure = 'Grava_Dados';	 															break;
		default: return false; 																				break;
	}
	
	// retorno em caso de erro
	if ( $cddopcao == 'L' ) { $retornoAposErro= "bloqueiaFundo($('#divRotina'));"; }	
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0120.p</Bo>";
	$xml .= "        <Proc>".$procedure."</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<cdprogra>'.$glbvars['cdprogra'].'</cdprogra>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '		<cdopecxa>'.$cdopecxa.'</cdopecxa>';	
	$xml .= '		<dtmvtolx>'.$dtmvtolt.'</dtmvtolx>';	
	$xml .= '		<cdagencx>'.$cdagenci.'</cdagencx>';	
	$xml .= '		<nrdcaixx>'.$nrdcaixa.'</nrdcaixx>';
	$xml .= '		<dtrefere>'.$dtrefere.'</dtrefere>';
	$xml .= '		<cdoplanc>'.$cdoplanc.'</cdoplanc>';
	$xml .= '		<vldentra>'.$vldentra.'</vldentra>';
	$xml .= '		<vldsaida>'.$vldsaida.'</vldsaida>';
	$xml .= '		<nrdlacre>'.$nrdlacre.'</nrdlacre>';
	$xml .= '		<qtautent>'.$qtautent.'</qtautent>';
	$xml .= '		<vldsdini>'.$vldsdini.'</vldsdini>';
	$xml .= '		<nrdmaqui>'.$nrdmaqui.'</nrdmaqui>';
	$xml .= '		<dsdcompl>'.$dsdcompl.'</dsdcompl>';
	$xml .= '		<vldocmto>'.$vldocmto.'</vldocmto>';
	$xml .= '		<cdhistor>'.$cdhistor.'</cdhistor>';
	$xml .= '		<nrdocmto>'.$nrdocmto.'</nrdocmto>';
	$xml .= '		<nrseqdig>'.$nrseqdig.'</nrseqdig>';
	$xml .= '       <operauto>'.$operauto.'</operauto>';
	$xml .= "  </Dados>";
	$xml .= "</Root>";	

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	$msgretor = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$nmdcampo			= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		$msgErro			= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$msgErro			= !empty($msgretor) ? $msgErro.'<br />'.$msgretor : $msgErro;
		if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " $('#".$nmdcampo."').focus();"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

	$msgsenha = $xmlObjeto->roottag->tags[0]->attributes['MSGSENHA'];
	$flgsemhi = $xmlObjeto->roottag->tags[0]->attributes['FLGSEMHI'];
	$vlrttcrd = $xmlObjeto->roottag->tags[0]->attributes['VLRTTCRD'];
	$vldsdfin = $xmlObjeto->roottag->tags[0]->attributes['VLDSDFIN'];
	$nrctadeb = $xmlObjeto->roottag->tags[0]->attributes['NRCTADEB'];
	$nrctacrd = $xmlObjeto->roottag->tags[0]->attributes['NRCTACRD'];
	$cdhistor = $xmlObjeto->roottag->tags[0]->attributes['CDHISTOR'];
	$dshistor = $xmlObjeto->roottag->tags[0]->attributes['DSHISTOR'];
	$indcompl = $xmlObjeto->roottag->tags[0]->attributes['INDCOMPL'];
	$dsdcompl = $xmlObjeto->roottag->tags[0]->attributes['DSDCOMPL'];
	$vldocmto = $xmlObjeto->roottag->tags[0]->attributes['VLDOCMTO'];
	$ndrrecid = $xmlObjeto->roottag->tags[0]->attributes['NDRRECID'];
	$nrdlacre = $xmlObjeto->roottag->tags[0]->attributes['NRDLACRE'];

	$registro = $xmlObjeto->roottag->tags[0]->tags[0]->tags;	
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Retorno
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( $cddopcao == 'F') {
		
		if ( $operacao == 'BD') {
			echo "cNrdmaqui.val('".getByTagName($registro,'nrdmaqui')."');";
			echo "cQtautent.val('".getByTagName($registro,'qtautent')."');";
			echo "cNrdlacre.val('".getByTagName($registro,'nrdlacre')."');";
			echo "cVldsdini.val('".formataMoeda(getByTagName($registro,'vldsdini'))."');";
		
			echo "flgsemhi='".$flgsemhi."';";

			// Caso seja retornado alguma mensagem de alerta/critica ou a data de referencia
			// for diferente do dia atual, vamos solicitar a senha do coordenador
			if (!empty($msgsenha) || ($dtrefere != $glbvars['dtmvtolt'])){
				if($dtrefere != $glbvars['dtmvtolt']) {
					echo "mostraSenha();";
				}else{
					exibirErro('inform',$msgsenha,'Alerta - Ayllos','mostraSenha();',false);
				}				
			} else {
				echo "controlaLayout('BD');";
			}
			
		} else if ( $operacao == 'VD' ) {
			echo "vldentra=cVldentra.val();";
			echo "cVldentra.val('".formataMoeda($vlrttcrd)."');";
			echo "cVldsdfin.val('".formataMoeda($vldsdfin)."');";
			echo "controlaLayout('VD');";
			
		} else if ( $operacao == 'GD' ) {
			echo "$('#ndrrecid','#frmImprimir').val('".$ndrrecid."');";
			echo "$('#nrdlacre','#frmImprimir').val('".$nrdlacre."');";
			echo "controlaLayout('GD');";
			
		}	
		
	} else if ( $cddopcao == 'I' ) {
	
		if ( $operacao == 'BD' ) {
			echo "controlaLayout('BD');";
			
		} else if ( $operacao == 'GD' ) {
			echo "$('#ndrrecid','#frmImprimir').val('".$ndrrecid."');";
			echo "$('#nrdlacre','#frmImprimir').val('".$nrdlacre."');";
			echo "controlaLayout('GD');";
			
		}
		
	} else if ( $cddopcao == 'L' or $cddopcao == 'K' ) {
	
		if ( $operacao == 'VH' and $cdoplanc == 'I' ) {
			echo "$('#dshistor', '#frmOpcaoLK').val('".$dshistor."');";
			echo "$('#nrctadeb', '#frmOpcaoLK').val('".$nrctadeb."');";
			echo "$('#nrctacrd', '#frmOpcaoLK').val('".$nrctacrd."');";
			echo "$('#cdhistox', '#frmOpcaoLK').val('".$cdhistor."');";

			if ( $indcompl != '0' ) {
				echo "$('#dsdcompl', '#frmOpcaoLK').habilitaCampo().focus();";
			}
			
			echo "controlaLayout('VH');";
		
		} else if ( $operacao == 'GD' and $cdoplanc == 'I' ) {
			echo "formataOpcaoLK('I');";

		} else if ( $operacao == 'VD' and $cdoplanc == 'E' ) {
			echo "$('#dshistor', '#frmOpcaoLK').val('".$dshistor."');";
			echo "$('#nrctadeb', '#frmOpcaoLK').val('".$nrctadeb."');";
			echo "$('#nrctacrd', '#frmOpcaoLK').val('".$nrctacrd."');";
			echo "$('#cdhistox', '#frmOpcaoLK').val('".$cdhistor."');";
			echo "$('#dsdcompl', '#frmOpcaoLK').val('".$dsdcompl."');";
			echo "$('#vldocmto', '#frmOpcaoLK').val('".formataMoeda($vldocmto)."');";
			echo "controlaLayout('VD');";

		} else if ( $operacao == 'GD' and $cdoplanc == 'E' ) {
			echo "formataOpcaoLK('E');";
			
		} else if ( $operacao == 'VD' and $cdoplanc == 'A' ) {
			echo "$('#dshistor', '#frmOpcaoLK').val('".$dshistor."');";
			echo "$('#nrctadeb', '#frmOpcaoLK').val('".$nrctadeb."');";
			echo "$('#nrctacrd', '#frmOpcaoLK').val('".$nrctacrd."');";
			echo "$('#cdhistox', '#frmOpcaoLK').val('".$cdhistor."');";
			echo "$('#dsdcompl', '#frmOpcaoLK').val('".$dsdcompl."');";
			echo "$('#vldocmto', '#frmOpcaoLK').val('".formataMoeda($vldocmto)."');";
			echo "controlaLayout('VD');";
			
		} else if ( $operacao == 'VH' and $cdoplanc == 'A' ) {
			if ( $indcompl != '0' ) {
				echo "$('#dsdcompl', '#frmOpcaoLK').habilitaCampo().focus();";
			}
			echo "$('#dshistor', '#frmOpcaoLK').val('".$dshistor."');";
			echo "$('#nrctadeb', '#frmOpcaoLK').val('".$nrctadeb."');";
			echo "$('#nrctacrd', '#frmOpcaoLK').val('".$nrctacrd."');";
			echo "$('#cdhistox', '#frmOpcaoLK').val('".$cdhistor."');";
			echo "$('#vldocmto', '#frmOpcaoLK').habilitaCampo();";
			echo "controlaLayout('VH');";
			
		} else if ( $operacao == 'GD' and $cdoplanc == 'A' ) {
			echo "formataOpcaoLK('A');";
		
		} else if ( $cddopcao == 'K' and $operacao == 'GD' and $cdoplanc == '' ) { // Reabrir o boletim de caixa.
			echo "controlaLayout('GD');";
			
		}
	
	}
?>