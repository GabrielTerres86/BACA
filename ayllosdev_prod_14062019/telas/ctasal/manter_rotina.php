<? 
/*!
   FONTE        : manter_rotina.php
   CRIAÇÃO      : Gabriel Capoia (DB1)
   DATA CRIAÇÃO : 11/01/2013
   OBJETIVO     : Rotina para manter as operações da tela MANCCF
   --------------
   ALTERAÇÕES   : 07/08/2017 - Ajuste realizado para gerar numero de conta automaticamente na
 						       inclusao, conforme solicitado no chamado 689996. (Kelvin)
							   
				  14/05/2018 - Incluido novo campo "Tipo de Conta" (tpctatrf) na tela CTASAL
                               Projeto 479-Catalogo de Servicos SPB (Mateus Z - Mouts)
                               
   -------------- 
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
	$operacao = (isset($_POST['operacao']))   ? $_POST['operacao']   : '';
	$nrdconta = (isset($_POST['nrdconta']))   ? $_POST['nrdconta']   : 0 ; 
	$cddopcao = (isset($_POST['cddopcao']))   ? $_POST['cddopcao']   : ''; 
	$cdagenca = (isset($_POST['cdagenca']))   ? $_POST['cdagenca']   : 0 ; 
	$cdempres = (isset($_POST['cdempres']))   ? $_POST['cdempres']   : 0 ; 
	$nmfuncio = (isset($_POST['nmfuncio']))   ? $_POST['nmfuncio']   : ''; 
	$cdagetrf = (isset($_POST['cdagetrf']))   ? $_POST['cdagetrf']   : 0 ; 
	$cdbantrf = (isset($_POST['cdbantrf']))   ? $_POST['cdbantrf']   : 0 ; 
	$nrdigtrf = (isset($_POST['nrdigtrf']))   ? $_POST['nrdigtrf']   : 0 ; 
	$nrctatrf = (isset($_POST['nrctatrf']))   ? $_POST['nrctatrf']   : 0 ; 
	$nrcpfcgc = (isset($_POST['nrcpfcgc']))   ? $_POST['nrcpfcgc']   : 0 ; 
	$tpctatrf = (isset($_POST['tpctatrf']))   ? $_POST['tpctatrf']   : 1 ; 
				
	switch ( $operacao ) {
		case 'grava'  : $procedure = 'Grava_Dados';  $retornoAposErro= ''; break;
		case 'valida' : $procedure = 'Valida_Dados'; $retornoAposErro= ''; break;		
	}
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0151.p</Bo>";
	$xml .= "        <Proc>".$procedure."</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';		
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';			
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';		
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';		
	$xml .= '       <cdagenca>'.$cdagenca.'</cdagenca>';		
	$xml .= '       <cdempres>'.$cdempres.'</cdempres>';		
	$xml .= '       <nmfuncio>'.$nmfuncio.'</nmfuncio>';		
	$xml .= '       <cdagetrf>'.$cdagetrf.'</cdagetrf>';		
	$xml .= '       <cdbantrf>'.$cdbantrf.'</cdbantrf>';		
	$xml .= '       <nrdigtrf>'.$nrdigtrf.'</nrdigtrf>';		
	$xml .= '       <nrctatrf>'.$nrctatrf.'</nrctatrf>';		
	$xml .= '       <nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';		
	$xml .= '       <tpctatrf>'.$tpctatrf.'</tpctatrf>';		
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
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];	
		if (!empty($nmdcampo)) { $mtdErro = " $('#".$nmdcampo."','#frmDados').focus();"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
	}
	
	$nrdconrt = $xmlObjeto->roottag->tags[0]->attributes['NRDCONRT'];
	
	// Busca os dados do contrato e os avalista
	if ( $operacao == 'valida' ) {
		
		echo "hideMsgAguardo();";
		echo "showConfirmacao('078 - Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina(\'grava\');','','sim.gif','nao.gif');";
	
	}else{
		if ( $cddopcao == "E" || $cddopcao == "I" || $cddopcao == "X" || $cddopcao == "S" ){
			if ($cddopcao == "I") {
				echo "showError('inform','Conta criada com sucesso. Conta: " . $nrdconrt . "','Alerta - Ayllos','');";
				echo "Gera_Impressao('" . $nrdconrt . "');";
			}
			else 
				echo "Gera_Impressao();";			
		}else{
			echo "showError('inform','Registro salvo com sucesso','Alerta - Ayllos','');";
		}
	}

	//echo "fechaRotina( $('#divRotina') );buscaContrato();";
	
	
?>