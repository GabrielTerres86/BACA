<? 
/*
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 19/01/2012 
 * OBJETIVO     : Rotina para manter as operações da tela DESCTO
 * --------------
 * ALTERAÇÕES   : 21/06/2012 - Adicionado confirmacao para impressao. (Jorge)
 * 					
 *			      03/05/2013 - Adicionado condicao de cdinstru == 7. (Jorge)
 *
 *			      30/12/2015 - Alterações Referente Projeto Negativação Serasa (Daniel)	
 *
 *                09/05/2016 - Controlar o foco dos campos de acordo com a pesquisa (Douglas - Chamado 441759)
 * 
 *				  01/02/2018 - Alterações referente ao PRJ352 - Nova solução de protesto
 *
 *                26/12/2017 - Ajustar o controle de critica para exibir corretamente as mensagens de erro devolvidas pelo Oracle (Douglas - Chamado 820998)
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Inicializa
	$procedure 		 = '';
	$retornoAposErro = '';
	$listaArquivos	 = array();
	
	// Recebe a operação que está sendo realizada
	$operacao		 = (isset($_POST['operacao'])) ? $_POST['operacao']   : '' ; 
	$cddopcao		 = (isset($_POST['cddopcao'])) ? $_POST['cddopcao']   : '' ; 
	$nrdconta		 = (isset($_POST['nrdconta'])) ? $_POST['nrdconta']   : 0  ; 
	$nrdcontx		 = (isset($_POST['nrdcontx'])) ? $_POST['nrdcontx'] : 0  ;
	$ininrdoc		 = (isset($_POST['ininrdoc'])) ? $_POST['ininrdoc'] : 0  ;
	$fimnrdoc		 = (isset($_POST['fimnrdoc'])) ? $_POST['fimnrdoc'] : 0  ;
	$nrinssac		 = (isset($_POST['nrinssac'])) ? $_POST['nrinssac'] : 0  ;
	$nmprimtl		 = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '' ;
	$nmprimtx		 = (isset($_POST['nmprimtx'])) ? $_POST['nmprimtx'] : '' ;
    $indsitua		 = (isset($_POST['indsitua'])) ? $_POST['indsitua'] : '' ;
	$numregis		 = (isset($_POST['numregis'])) ? $_POST['numregis'] : '' ;
	$iniseque		 = (isset($_POST['iniseque'])) ? $_POST['iniseque'] : '' ;
    $inidtven		 = (validaData($_POST['inidtven'])) ? $_POST['inidtven'] : '' ;
    $fimdtven		 = (validaData($_POST['fimdtven'])) ? $_POST['fimdtven'] : '' ;
    $inidtdpa		 = (validaData($_POST['inidtdpa'])) ? $_POST['inidtdpa'] : '' ;
	$fimdtdpa 		 = (validaData($_POST['fimdtdpa'])) ? $_POST['fimdtdpa'] : '' ;
	$inidtmvt 		 = (validaData($_POST['inidtmvt'])) ? $_POST['inidtmvt'] : '' ;
	$fimdtmvt 		 = (validaData($_POST['fimdtmvt'])) ? $_POST['fimdtmvt'] : '' ;
	$consulta 		 = (isset($_POST['consulta'])) ? $_POST['consulta'] : 0  ;
	$tpconsul 		 = (isset($_POST['tpconsul'])) ? $_POST['tpconsul'] : 0  ;
	$dsdoccop 		 = (isset($_POST['dsdoccop'])) ? $_POST['dsdoccop'] : ''  ;
	$flgregis 		 = (isset($_POST['flgregis'])) ? $_POST['flgregis'] : '' ;
	$nmarqint 		 = (isset($_POST['nmarqint'])) ? $_POST['nmarqint'] : '' ;
	$cdinstru 		 = (isset($_POST['cdinstru'])) ? $_POST['cdinstru'] : 0 ;
	$nrdcoaux 		 = (isset($_POST['nrdcoaux'])) ? $_POST['nrdcoaux'] : 0 ;
	$nrcnvcob 		 = (isset($_POST['nrcnvcob'])) ? $_POST['nrcnvcob'] : 0 ;
	$nrdocmto 		 = (isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : 0 ;
	$cdtpinsc 		 = (isset($_POST['cdtpinsc'])) ? $_POST['cdtpinsc'] : 0 ;
	$dtvencto 		 = (validaData($_POST['dtvencto'])) ? $_POST['dtvencto'] : '' ;
	$vrsarqvs 		 = (isset($_POST['vrsarqvs'])) ? $_POST['vrsarqvs'] : 0 ;
	$arquivos 		 = (isset($_POST['arquivos'])) ? $_POST['arquivos'] : '';
	$vlabatim 		 = (isset($_POST['vlabatim'])) ? $_POST['vlabatim'] : 0;
	$vldescto 		 = (isset($_POST['vldescto'])) ? $_POST['vldescto'] : 0;
	$qtdiaprt		 = (isset($_POST['qtdiaprt'])) ? $_POST['qtdiaprt'] : 0;
	
	$ls_nrdocmto     = (isset($_POST['ls_nrdocmto'])) ? $_POST['ls_nrdocmto'] : '';
		
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	switch( $operacao ) {
		case 'BA': $procedure = 'busca_associado'; 																						 	break;
		case 'EA': $procedure = 'exporta_boleto'; 		$dsiduser = $nmarqint;															 	break;
		case 'ER': $procedure = 'exporta_remessa'; 		$dsiduser = $nmarqint;															 	break;
		case 'VI': $procedure = 'valida_instrucoes'; 	$retornoAposErro = 'bloqueiaFundo($(\'#divRotina\'));';							 	break;
		case 'GI': $procedure = 'grava_instrucoes'; 	$retornoAposErro = 'bloqueiaFundo($(\'#divRotina\'));';	 $nrdconta = $nrdcoaux;  	break;
		case 'IA': $procedure = 'integra_arquivo'; 		$dsnmarqv = $nmarqint;	$dsiduser = session_id();	arrayArquivos($arquivos); 		break;							 break;
		
	}

	if ( $tpconsul == 1 or $tpconsul == 2 ) {
		$fimnrdoc = $ininrdoc;
	}

	if ( $consulta == 8 ) {
		$nrdconta = $nrdcontx;
	}
	
	// se for instrucao de desconto, passa o valor de desconto atraves do campo vlabatim
	if ( $cdinstru == 7 ) {
		$vlabatim = $vldescto;
	}
	
	// Monta o xml dinâmico de acordo com a operação 
	if ($operacao == 'ER') {
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Dados>";
		$xml .= "	 <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "	 <ls_nrdocmto>".$ls_nrdocmto."</ls_nrdocmto>";	
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "COBRAN", "GERA_REMESSA_CNAB240", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);

		//print_r($xmlObjeto);exit;

		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			if ($msgErro == "") {
				$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
			}
			if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " focaCampoErro('".$nmdcampo."','frmOpcao');"; }
			
			echo 'hideMsgAguardo();';
			echo 'showError("error", "' . $msgErro . '", "Alerta - Ayllos", "' . $retornoAposErro . '");';
			exit;
		}
		
		$nmarqrem = $xmlObjeto->roottag->tags[0]->cdata;
		visualizaCSV($nmarqrem);
		exit;

	} else {
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Cabecalho>";
		$xml .= "	    <Bo>b1wgen0010.p</Bo>";
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
		$xml .= "		<cdprogra>COBRAN</cdprogra>";	
		$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";	
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";	
		$xml .= '		<ininrdoc>'.$ininrdoc.'</ininrdoc>';	
		$xml .= '		<fimnrdoc>'.$fimnrdoc.'</fimnrdoc>';	
		$xml .= '		<nrinssac>'.$nrinssac.'</nrinssac>';	
		$xml .= '		<nmprimtl>'.$nmprimtl.'</nmprimtl>';	
		$xml .= '		<indsitua>'.$indsitua.'</indsitua>';	
		$xml .= '		<numregis>'.$numregis.'</numregis>';	
		$xml .= '		<iniseque>'.$iniseque.'</iniseque>';	
		$xml .= '		<inidtven>'.$inidtven.'</inidtven>';	
		$xml .= '		<fimdtven>'.$fimdtven.'</fimdtven>';	
		$xml .= '		<inidtdpa>'.$inidtdpa.'</inidtdpa>';	
		$xml .= '		<fimdtdpa>'.$fimdtdpa.'</fimdtdpa>';
		$xml .= '		<inidtmvt>'.$inidtmvt.'</inidtmvt>';
		$xml .= '		<fimdtmvt>'.$fimdtmvt.'</fimdtmvt>';
		$xml .= '		<consulta>'.$consulta.'</consulta>';
		$xml .= '		<tpconsul>'.$tpconsul.'</tpconsul>';
		$xml .= '		<dsdoccop>'.$dsdoccop.'</dsdoccop>';
		$xml .= '		<flgregis>'.$flgregis.'</flgregis>';
		$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
		$xml .= '		<cdinstru>'.$cdinstru.'</cdinstru>';
		$xml .= '		<nrcnvcob>'.$nrcnvcob.'</nrcnvcob>';
		$xml .= '		<nrdocmto>'.$nrdocmto.'</nrdocmto>';
		$xml .= '		<cdtpinsc>'.$cdtpinsc.'</cdtpinsc>';
		$xml .= '		<vlabatim>'.$vlabatim.'</vlabatim>';
		$xml .= '		<dtvencto>'.$dtvencto.'</dtvencto>';
		$xml .= '		<nmarqint>'.$nmarqint.'</nmarqint>';
		$xml .= '		<dsnmarqv>'.$dsnmarqv.'</dsnmarqv>';
		$xml .= '		<vrsarqvs>'.$vrsarqvs.'</vrsarqvs>';
		$xml .= '		<qtdiaprt>'.$qtdiaprt.'</qtdiaprt>';
		$xml .=			xmlFilho($listaArquivos,'Arquivos','Itens');
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

			if ( $operacao == 'IA' ) {
				$arquivo1	= $xmlObjeto->roottag->tags[0]->attributes['NMARQPDF'];
				$arquivo2	= $xmlObjeto->roottag->tags[0]->attributes['NMARQPD2'];
				if ( !empty($arquivo1) || !empty($arquivo2) ) 
					$retornoAposErro = "mostraImprimir('".$arquivo1."', '".$arquivo2."'); ";
			}	

			$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
			if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " focaCampoErro('".$nmdcampo."','frmOpcao');"; }
			
			echo 'hideMsgAguardo();';
			echo 'showError("error", "' . $msgErro . '", "Alerta - Ayllos", "' . $retornoAposErro . '");';
			
			exit();
		}

	}
	
	// Associado
	if ( $operacao == 'BA' ) {
		$associado = $xmlObjeto->roottag->tags[0]->tags[0]->tags; // dados associado
		if ( $cddopcao == 'C' and $consulta == 6 ) { // 6 - Nome do Pagador
			echo "$('#nmprimtx','#frmOpcao').val('".getByTagName($associado,'nmprimtl')."');";
		} else {
			echo "cNmprimtl.val('".getByTagName($associado,'nmprimtl')."');";
		}
			
		
		if ( $cddopcao == 'C' and $consulta == 2 ) { // 2 - Numero do Boleto
			echo "hideMsgAguardo();";
			echo "$('#ininrdoc','#frmOpcao').focus();";
		} else if ( $cddopcao == 'C' and $consulta == 3 ) { // 3 - Data de Emissao
			echo "hideMsgAguardo();";
			echo "$('#inidtmvt','#frmOpcao').focus();";
		} else if ( $cddopcao == 'C' and $consulta == 4 ) { // 4 - Data de Pagamento
			echo "hideMsgAguardo();";
			echo "$('#inidtdpa','#frmOpcao').focus();";
		} else if ( $cddopcao == 'C' and $consulta == 5 ) { // 5 - Data de Vencimento
			echo "hideMsgAguardo();";
			echo "$('#inidtven','#frmOpcao').focus();";
		} else if ( $cddopcao == 'C' and $consulta == 6 ) { // 6 - Nome do Pagador
			echo "hideMsgAguardo();";
			echo "$('#nmprimtl','#frmOpcao').focus();";
		} else if ( $cddopcao == 'C' and $consulta == 8 ) {
			echo "hideMsgAguardo();";
			echo "cNrdconta.desabilitaCampo();";
			echo "cDsdoccop.habilitaCampo().focus();";
			
		} else if ( $cddopcao == 'C' ) {
			echo "controlaOperacao('CB', nriniseq, nrregist);";
		
		} else if ( $cddopcao == 'R' ) {
			echo "cCdagenci.val('".getByTagName($associado,'cdagenci')."');";
			
			echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","Gera_Impressao();","hideMsgAguardo();","sim.gif","nao.gif");';
			exit();
		}		
		
	} else if ( $operacao == 'EA' || $operacao == 'ER' ) {
		exibirErro('inform','Arquivo gerado com sucesso!','Alerta - Ayllos','fechaRotina($(\'#divRotina\'));',false);
	
	} else if ( $operacao == 'VI' ) {
		echo "hideMsgAguardo();";
		
		if ( $cdinstru == 4 || $cdinstru == 6 || $cdinstru == 7 || $cdinstru == 80 /*Instrução automática de protesto (PRJ352)*/ ) {
			echo "buscaCampo();";
		} else {
			echo "msgConfirmacao();";
		}
		
	} else if ( $operacao == 'GI' ) {
		exibirErro('inform','Instrução efetuada com sucesso!','Alerta - Ayllos','',false);
		echo "hideMsgAguardo();";
		echo "fechaRotina($('#divUsoGenerico'));";
		echo "fechaRotina($('#divRotina'));";
		echo "controlaOperacao('CB', nriniseq, nrregist);";

	} else if ( $operacao == 'IA' ) {
		$arquivo1	= $xmlObjeto->roottag->tags[0]->attributes['NMARQPDF'];
		$arquivo2	= $xmlObjeto->roottag->tags[0]->attributes['NMARQPD2'];
		echo "mostraImprimir('".$arquivo1."', '".$arquivo2."'); ";
	}	

	
	//
	function arrayArquivos( $arquivos ) {
	
		global $listaArquivos;
		$a = explode(';',$arquivos);
		$i = 0;
		
		foreach( $a as $v ) {
			$listaArquivos[$i]['flginteg'] = 'yes';
			$listaArquivos[$i]['dsarquiv'] = $v;
			$i = $i + 1;
		}
		
	}
	
?>