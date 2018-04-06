<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Antonio R. Junior (Mouts)
 * DATA CRIAÇÃO : 08/11/2017
 * OBJETIVO     : Rotina tela PRVSAQ.
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */

	session_cache_limiter("private");
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			

	// Recebe a operação que está sendo realizada
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$cdcoptel = (isset($_POST['cdcoptel'])) ? $_POST['cdcoptel'] : $glbvars['cdcooper'];
	$rotina   = (isset($_POST['rotina'])) ? $_POST['rotina'] : '' ;
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 30 ; 
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1 ; 
	
	// Se cooperativa for Cecred "E" opção selecionada for Consulta "OU" Alteração, pega o código do post, se não pega coop logada
	$cdcooper = ( (($glbvars["cdcooper"] == 3) && ($cddopcao == "C" || $cddopcao == "A")) ? $_POST['cdcooper'] : $glbvars['cdcooper'] );	
	
	if ($rotina == "A!!" || $rotina == "I!!!"){
		$ind_grava = 1;
	}else{
		$ind_grava = 0;
	}

	//insere verificado 
	if($rotina == 'I!!' || $rotina == 'I!!!'){
		$rotina = 'I';
		$cddopcao = 'I';
	}

	if($rotina == 'PDF'){
		$cddopcao 	 = 'PDF';
		$dsprotocolo = (isset($_POST['dsprotocolo'])) ? $_POST['dsprotocolo'] : '' ;		
		$dtSaqPagto  = (isset($_POST['dtSaqPagto'])) ? $_POST['dtSaqPagto'] : 0 ;
		$hrSaqPagto  = (isset($_POST['hrSaqPagto'])) ? $_POST['hrSaqPagto'] : 0 ;
		$vlSaqPagto  = (isset($_POST['vlSaqPagto'])) ? $_POST['vlSaqPagto'] : 0 ;										
		$nrContTit   = (isset($_POST['nrContTit'])) ? $_POST['nrContTit'] : 0 ;
		$nrTit 		 = (isset($_POST['nrTit'])) 	 ? $_POST['nrTit'] : 0 ;
		$nrCpfCnpj   = (isset($_POST['nrCpfCnpj'])) ? $_POST['nrCpfCnpj'] : 0 ;
		$nmSolic 	 = (isset($_POST['nmSolic'])) 	 ? $_POST['nmSolic'] : '' ;
		$nrCpfSacPag = (isset($_POST['nrCpfSacPag']))? $_POST['nrCpfSacPag'] : 0 ;
		$nmSacPag 	 = (isset($_POST['nmSacPag'])) 	 ? $_POST['nmSacPag'] : '' ;
		$nrPA 		 = (isset($_POST['nrPA'])) 		 ? $_POST['nrPA'] : 0 ;
		$txtFinPagto = (isset($_POST['txtFinPagto']))? $_POST['txtFinPagto'] : '' ;
	}	

	if($rotina == 'I!' || $cddopcao == 'C' || $cddopcao == 'E' || $cddopcao == 'A' || $rotina =='A!' || $rotina =='A!!'){		
		if($rotina=='I!'){
			$cddopcao = 'I!';
		}

		if($rotina=='A!' || $rotina=='A!!'){
			$cddopcao = 'A!';
		}

		if($cddopcao == 'E'){
			//consulta exclusao		
			$nrpa    	= (isset($_POST['nrPAExc'])) ? $_POST['nrPAExc'] : '' ;		
			$dtSaqPagto  = (isset($_POST['dtDataExc'])) ? $_POST['dtDataExc'] : '' ;
			$nrCpfCnpj  = (isset($_POST['nrCpfCnpjExc'])) ? $_POST['nrCpfCnpjExc'] : '' ;			
			//array com os registros a serem excluidos
			$arrExc  	= (isset($_POST['arrExc'])) ? $_POST['arrExc'] : '' ;	
		}else if($cddopcao == 'A'){
			$nrpa    	 = (isset($_POST['nrPAAlt'])) ? $_POST['nrPAAlt'] : '' ;		
			$dtSaqPagto  = (isset($_POST['dtDataAlt'])) ? $_POST['dtDataAlt'] : '' ;
			$nrCpfCnpj   = (isset($_POST['nrCpfCnpjAlt'])) ? $_POST['nrCpfCnpjAlt'] : '' ;
			$dsprotocolo = (isset($_POST['dsProtAlt'])) ? $_POST['dsProtAlt'] : '' ;
		}else if($cddopcao =='A!'){			
			//valor alterado			  
			$dtSaqPagtoAlt  = (isset($_POST['dtSaqPagtoAlt'])) ? $_POST['dtSaqPagtoAlt'] : '' ;		
			$hrSaqPagtoAlt  = (isset($_POST['hrSaqPagtoAlt'])) ? $_POST['hrSaqPagtoAlt'] : '' ;
			$vlSaqPagtoAlt  = (isset($_POST['vlSaqPagtoAlt'])) ? $_POST['vlSaqPagtoAlt'] : '' ;
			$tpSituacaoAlt  = (isset($_POST['tpSituacaoAlt'])) ? $_POST['tpSituacaoAlt'] : '' ;
			//valor original
			$cdcooperOri 	= (isset($_POST['cdcooperOri'])) ? $_POST['cdcooperOri'] : '' ;
			$dtSaqPagtoOri 	= (isset($_POST['dtSaqPagtoOri'])) ? $_POST['dtSaqPagtoOri'] : '' ;
			$nrcpfcgcOri 	= (isset($_POST['nrcpfcgcOri'])) ? $_POST['nrcpfcgcOri'] : '' ;
			$nrdcontaOri 	= (isset($_POST['nrdcontaOri'])) ? $_POST['nrdcontaOri'] : '' ;
			$vlsaqpagtoOri 	= (isset($_POST['vlsaqpagtoOri'])) ? $_POST['vlsaqpagtoOri'] : '' ;
			$tpsituacaoOri 	= (isset($_POST['tpsituacaoOri'])) ? $_POST['tpsituacaoOri'] : '' ;						
		}else{
			$dtSaqPagto  = (isset($_POST['dtSaqPagto'])) ? $_POST['dtSaqPagto'] : '' ;
			$vlSaqPagto  = (isset($_POST['vlSaqPagto'])) ? $_POST['vlSaqPagto'] : '' ;		
			$nrCpfCnpj   = (isset($_POST['nrCpfCnpj'])) ? $_POST['nrCpfCnpj'] : '' ;
			$hrSaqPagto  = (isset($_POST['hrSaqPagto'])) ? $_POST['hrSaqPagto'] : '' ;

			$dtperiini 	  = (isset($_POST['dtPeriodoIni'])) ? $_POST['dtPeriodoIni'] : '' ;
			$dtperifim 	  = (isset($_POST['dtPeriodoFim'])) ? $_POST['dtPeriodoFim'] : '' ;
			$tpoperacao   = (isset($_POST['tpOperacao'])) ? $_POST['tpOperacao'] : '' ;
			$nrpa         = (isset($_POST['nrPA'])) ? $_POST['nrPA'] : '' ;
			$tpsituacao   = (isset($_POST['tpSituacao'])) ? $_POST['tpSituacao'] : '' ;
			$tporigem     = (isset($_POST['tpOrigem'])) ? $_POST['tpOrigem'] : '' ;
			$nriniseq     = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1 ;
		}
	}
		
	if($cddopcao == 'I'){ 				
		$dtSaqPagto  = (isset($_POST['dtSaqPagto'])) ? $_POST['dtSaqPagto'] : 0 ;
		$hrSaqPagto  = (isset($_POST['hrSaqPagto'])) ? $_POST['hrSaqPagto'] : 0 ;
		$vlSaqPagto  = (isset($_POST['vlSaqPagto'])) ? $_POST['vlSaqPagto'] : 0 ;
		$selSaqCheq  = (isset($_POST['selSaqCheq'])) ? $_POST['selSaqCheq'] : 0 ;
		if($selSaqCheq == 1){
			$nrBanco 	 = (isset($_POST['nrBanco'])) 	 ? $_POST['nrBanco'] : 0 ;
			$nrAgencia   = (isset($_POST['nrAgencia'])) ? $_POST['nrAgencia'] : 0 ;
		}	
		$nrContCheq  = (isset($_POST['nrContCheq'])) ? $_POST['nrContCheq'] : 0 ;
		$nrCheque 	 = (isset($_POST['nrCheque'])) 	 ? $_POST['nrCheque'] : 0 ;
		$nrContTit   = (isset($_POST['nrContTit'])) ? $_POST['nrContTit'] : 0 ;
		$nrTit 		 = (isset($_POST['nrTit'])) 	 ? $_POST['nrTit'] : 0 ;
		$nrCpfCnpj   = (isset($_POST['nrCpfCnpj'])) ? $_POST['nrCpfCnpj'] : 0 ;
		$nmSolic 	 = (isset($_POST['nmSolic'])) 	 ? $_POST['nmSolic'] : '' ;
		$nrCpfSacPag = (isset($_POST['nrCpfSacPag']))? $_POST['nrCpfSacPag'] : 0 ;
		$nmSacPag 	 = (isset($_POST['nmSacPag'])) 	 ? $_POST['nmSacPag'] : '' ;
		$nrPA 		 = (isset($_POST['nrPA'])) 		 ? $_POST['nrPA'] : 0 ;
		$txtFinPagto = (isset($_POST['txtFinPagto']))? $_POST['txtFinPagto'] : '' ;
		$txtObs 	 = (isset($_POST['txtObs'])) 	 ? $_POST['txtObs'] : '' ;
		$selQuais 	 = (isset($_POST['selQuais'])) 	 ? $_POST['selQuais'] : 0 ;
		$txtQuais 	 = (isset($_POST['txtQuais'])) 	 ? $_POST['txtQuais'] : '' ;
		$indPessoa 	 = (isset($_POST['indPessoa']))  ? $_POST['indPessoa'] : '' ;
	}

	if($rotina == 'T'){		
		$cddopcao = 'T';
	}

	if($rotina =='CT'){
		$cddopcao = 'CT';
		$nrContTit   = (isset($_POST['nrContTit'])) ? $_POST['nrContTit'] : 0 ;	
		$nrTit	     = trim((isset($_POST['nrTit'])) ? $_POST['nrTit'] : 0) ;	
	}	

	if($rotina =='CS'){
		$cddopcao = 'CS';
		$nrCpfSacPag   = (isset($_POST['nrCpfSacPag'])) ? $_POST['nrCpfSacPag'] : 0 ;	
	}		

	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	$realopcao      = '';
	
	$nmendter = session_id();

	// Verifica Procedure a ser executada	
	switch($cddopcao) {
		case 'I'   : { $realopcao = 'I'; $procedure = 'PRVSAQ_GRAVA'; break; }
		case 'T'   : { $realopcao = 'T'; $procedure = 'PRVSAQ_TELA'; break; }
		case 'CT'  : { $realopcao = 'CT'; $procedure = 'PRVSAQ_TELA'; break; }
		case 'CS'  : { $realopcao = 'CS'; $procedure = 'PRVSAQ_TELA'; break; }
		case 'I!'  : { $realopcao = 'I!'; $procedure = 'PRVSAQ_CONSULTA'; break; }
		case 'C'   : { $realopcao = 'C'; $procedure = 'PRVSAQ_CONSULTA'; break; }
		case 'PDF' : { $realopcao = 'PDF'; $procedure = 'PRVSAQ_IMPRIMIR'; break; }
		case 'E'  : { $realopcao = 'E'; $procedure = 'PRVSAQ_CONSULTA'; break; }
		case 'A'  : { $realopcao = 'A'; $procedure = 'PRVSAQ_CONSULTA'; break; }
		case 'A!'  : { $realopcao = 'A!'; $procedure = 'PRVSAQ_ALTERA'; break; }
		default    : { exibirErro('atencao','Op&ccedil;&atilde;o Invalida!','Alerta - Ayllos','',false); }
	}
		
	$vr_aux = $realopcao;

	if($realopcao == 'CT' || $realopcao == 'CS' || $realopcao == 'T'){
		$realopcao = 'C';
	}

	if($realopcao =='A!'){
		$realopcao = 'A';
	}

	if($realopcao == 'I!' || $realopcao == 'PDF'){
		$realopcao = 'I';
	}

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$realopcao)) <> '') {		
		exibirErro('atencao',$msgError,'Alerta - Ayllos','',false);
	}

	$realopcao = $vr_aux;
	
	if($cddopcao == "I"){
		$cdcoptel = implode("|",$cdcoptel);
	}
	
	if($cdcoptel == ''){
		$cdcoptel = $glbvars['cdcooper'];
		if($cdcoptel == "3"){
			$cdcoptel = "1";
		}
	}	

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	if($realopcao == 'I' ){					
		$dtSaqPagto	 	= str_replace('-','',str_replace(',','.',str_replace('.','',$dtSaqPagto)));
		$hrSaqPagto 	= str_replace('-','',str_replace(',','.',str_replace('.','',$hrSaqPagto)));		
		$vlSaqPagto 	= str_replace('-','',str_replace(',','.',str_replace('.','',$vlSaqPagto)));
		$selSaqCheq 	= str_replace('-','',str_replace(',','.',str_replace('.','',$selSaqCheq)));
		$nrBanco 		= str_replace('-','',str_replace(',','.',str_replace('.','',$nrBanco)));
		$nrAgencia  	= str_replace('-','',str_replace(',','.',str_replace('.','',$nrAgencia )));
		$nrContCheq 	= str_replace('-','',str_replace(',','.',str_replace('.','',$nrContCheq)));
		$nrCheque 		= str_replace('-','',str_replace(',','.',str_replace('.','',$nrCheque)));
		$nrContTit  	= str_replace('-','',str_replace(',','.',str_replace('.','',$nrContTit)));
		$nrTit 			= str_replace('-','',str_replace(',','.',str_replace('.','',$nrTit)));
		$nrCpfCnpj  	= str_replace('/','',str_replace('-','',str_replace(',','.',str_replace('.','',$nrCpfCnpj ))));
		$nmSolic 		= str_replace('-','',str_replace(',','.',str_replace('.','',$nmSolic)));
		$nrCpfSacPag 	= str_replace('-','',str_replace(',','.',str_replace('.','',$nrCpfSacPag)));
		$nmSacPag 		= str_replace('-','',str_replace(',','.',str_replace('.','',$nmSacPag)));
		$nrPA 			= str_replace('-','',str_replace(',','.',str_replace('.','',$nrPA)));	

		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";				
		$xml .= "   <dtsaqpagto>".$dtSaqPagto.' '.$hrSaqPagto."</dtsaqpagto>";		
		$xml .= "   <vlsaqpagto>".$vlSaqPagto."</vlsaqpagto>";
		$xml .= "   <selsaqcheq>".$selSaqCheq."</selsaqcheq>";
		$xml .= "   <nrbanco>".$nrBanco."</nrbanco>";
		$xml .= "   <nragencia>".$nrAgencia ."</nragencia>";
		$xml .= "   <nrcontcheq>".$nrContCheq."</nrcontcheq>";
		$xml .= "   <nrcheque>".$nrCheque."</nrcheque>";
		$xml .= "   <nrconttit>".$nrContTit ."</nrconttit>";
		$xml .= "   <nrtit>".$nrTit."</nrtit>";		
		$xml .= "   <nrcpfsacpag>".$nrCpfSacPag."</nrcpfsacpag>";
		$xml .= "   <nmsacpag>".$nmSacPag."</nmsacpag>";
		$xml .= "   <nrpa>".$nrPA."</nrpa>";
		$xml .= "   <txtfinpagto>".$txtFinPagto."</txtfinpagto>";
		$xml .= "   <txtobs>".$txtObs."</txtobs>";
		$xml .= "   <selquais>".$selQuais."</selquais>";
		$xml .= "   <txtquais>".$txtQuais."</txtquais>";
		$xml .= "   <nrcpfope>0</nrcpfope>";
		$xml .= "   <ind_grava>".$ind_grava."</ind_grava>";
		$xml .= " </Dados>";
		$xml .= "</Root>";			

		//var_dump($xml);exit;
		#echo 'alert("'.$procedure.'");';
		#echo 'console.log("'.$xml.'");';		
		$xmlResult = mensageria($xml, "TELA_PRVSAQ", $procedure, $cdcooper,1, 1, $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");				
		#echo 'alert("'.str_replace('"','',$xmlResult).'");';
		$xmlObj = simplexml_load_string($xmlResult);			

		//se ocorreu erro no retorno da proc
		$pedesenha = $xmlObj->Dados->inf->pedesenha;				
		if($pedesenha == 1){
			$msg =$xmlObj->Dados->inf->dscritic;					
			
			echo 'showConfirmacao("'.utf8ToHtml(substr($msg,0,strlen($msg))).'","Confirma&ccedil;&atilde;o - Ayllos","realizarLogin();","","sim.gif","nao.gif");';
			exit();					
		}		
	}

	if($realopcao =='T' || $realopcao=='CT' || $realopcao=='CS') {
		$nrContTit  	= str_replace('-','',str_replace(',','.',str_replace('.','',$nrContTit)));
		$nrCpfSacPag  	= str_replace('/','',str_replace('-','',str_replace(',','.',str_replace('.','',$nrCpfSacPag))));

		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
		$xml .= "   <nrconta>" . ($realopcao=='CT'?$nrContTit:'0') . "</nrconta>";
		$xml .= "   <nrcpfcnpj>".($realopcao=='CS'?$nrCpfSacPag:'0')."</nrcpfcnpj>";
		$xml .= "   <nrtit>".($realopcao=='CT'?$nrTit:'0')."</nrtit>";		
		$xml .= " </Dados>";
		$xml .= "</Root>";		
		#echo 'console.log("'.$realopcao.'");';	
		#echo 'console.log("'.$xml.'");';
		$xmlResult = mensageria($xml, "TELA_PRVSAQ", $procedure, $cdcooper,1, 1, $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
		#echo 'console.log("'.str_replace('"','',$xmlResult).'");';
		$xmlObj = getObjectXML($xmlResult);	
	}

	if($realopcao == 'PDF') {
		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
		$xml .= "   <nrpa>" . $nrPA . "</nrpa>";		
		$xml .= "   <vlsaquepagto>" . $vlSaqPagto . "</vlsaquepagto>";
		$xml .= "   <nrconttit>" . $nrContTit . "</nrconttit>";
		$xml .= "   <dstitularidade>" . $nmSolic.' - '.$nrCpfCnpj. "</dstitularidade>";
		$xml .= "   <dssacador>" . $nmSacPag.' - '.$nrCpfSacPag. "</dstitularidade>";
		$xml .= "   <txtfinalidade>" . $txtFinPagto. "</txtfinalidade>";
		$xml .= "   <dsprotocolo>" . $dsprotocolo . "</dsprotocolo>";
		$xml .= "   <dtSaqPagto>" . $dtSaqPagto.' '.$hrSaqPagto. "</dtSaqPagto>";
		$xml .= " </Dados>";
		$xml .= "</Root>";		
		#echo 'console.log("'.$realopcao.'");';	
		#echo 'console.log("'.$xml.'");';
		$xmlResult = mensageria($xml, "TELA_PRVSAQ", $procedure, $cdcooper, 1, 1, $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
		#echo 'console.log("'.str_replace('"','',$xmlResult).'");';
		$xmlObj = getObjectXML($xmlResult);
	}

	if($realopcao =='A!'){
		$vlSaqPagtoAlt 	= str_replace('-','',str_replace(',','.',str_replace('.','',$vlSaqPagtoAlt)));

		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$cdcooperOri."</cdcooper>";		
		$xml .= "   <dhsaqueori>".$dtSaqPagtoOri."</dhsaqueori>";
		$xml .= "   <nrcpfcnpjori>".$nrcpfcgcOri."</nrcpfcnpjori>";		
		$xml .= "   <nrdcontaori>".$nrdcontaOri ."</nrdcontaori>";			
		$xml .= "   <dtsaqpagtoalt>".$dtSaqPagtoAlt.' '.$hrSaqPagtoAlt ."</dtsaqpagtoalt>";
		$xml .= "   <vlsaqpagtoalt>".$vlSaqPagtoAlt ."</vlsaqpagtoalt>";
		$xml .= "   <tpsituacaoalt>".$tpSituacaoAlt ."</tpsituacaoalt>";
		$xml .= "   <ind_grava>".$ind_grava."</ind_grava>";		
		$xml .= " </Dados>";
		$xml .= "</Root>";				

		#echo 'console.log("'.$realopcao.'");';	
		#echo 'console.log("'.$xml.'");';
		$xmlResult = mensageria($xml, "TELA_PRVSAQ", $procedure, $glbvars['cdcooper'], 1, 1, $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
		#echo 'console.log("'.str_replace('"','',$xmlResult).'");';		
		$xmlObj = simplexml_load_string($xmlResult);

		//se ocorreu erro no retorno da proc
		$codError = $xmlObj->Erro->Registro->cdcritic;				
		if(isset($codError)){
			$msg = $xmlObj->Erro->Registro->dscritic;
			if(strlen($msg)>7 && substr($msg,0,6)=='383917'){
				echo 'showConfirmacao("'.utf8ToHtml(substr($msg,9,strlen($msg))).'","Confirma&ccedil;&atilde;o - Ayllos","realizarLogin();","btnVoltar();","sim.gif","nao.gif");';
				exit();		
			}else{
				echo "showError('error','".utf8ToHtml($xmlObj->Erro->Registro->dscritic)."','Alerta - Ayllos','btnVoltar();');";				
				exit();
			}
		}
		echo 'btnVoltar();manter_rotina("A");';
		exit();

		$procedure = 'PRVSAQ_CONSULTA';			
	}	

	if($realopcao == 'I!' || $realopcao == 'C' || $realopcao == 'E' || $realopcao == 'A' || $realopcao =='A!'){				
		$dtSaqPagto	 	= str_replace('-','',str_replace(',','.',str_replace('.','',$dtSaqPagto)));		
		$vlSaqPagto 	= str_replace('-','',str_replace(',','.',str_replace('.','',$vlSaqPagto)));		
		$nrCpfCnpj  	= str_replace('/','',str_replace('-','',str_replace(',','.',str_replace('.','',$nrCpfCnpj ))));

		if($nrCpfCnpj == 0){
			$nrCpfCnpj = '';
		}		
		//existe registros a serem excluidos antes da consulta	
		$xml='';
		if(isset($arrExc)){	
			foreach ($arrExc as $v) {																				
				$xml = "<Root>";
				$xml .= " <Dados>";
				$xml .= "   <cdcooper>" . $v[0] . "</cdcooper>";
				$xml .= "   <cdcoptel>" . $v[0] . "</cdcoptel>";
				$xml .= "   <dhsaque>".$v[1]."</dhsaque>";
				$xml .= "   <nrcpfcnpj>".$v[2]."</nrcpfcnpj>";		
				$xml .= "   <nrdconta>".$v[3] ."</nrdconta>";
				$xml .= " </Dados>";
				$xml .= "</Root>";					
								
				$xmlResult = mensageria($xml, "TELA_PRVSAQ", 'PRVSAQ_EXCLUI', $glbvars['cdcooper'], 1, 1, $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
				$xmlObj = simplexml_load_string($xmlResult);
				
				//se ocorreu erro no retorno da proc
				$codError = $xmlObj->Erro->Registro->cdcritic;		
				if(isset($codError)){
					echo "showError('error','".$xmlObj->Erro->Registro->dscritic."','Alerta - Ayllos','$(\'#nrCheque\',\'#frmInclusao\').focus();');";
					break;
				}
			}
		}

		$xml='';
		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
		$xml .= "   <cdcoptel>" . $cdcoptel . "</cdcoptel>";
		$xml .= "   <peri_ini>".$dtperiini."</peri_ini>";
		$xml .= "   <peri_fim>".$dtperifim."</peri_fim>";				
		$xml .= "   <cdagenci_saque>".$nrpa."</cdagenci_saque>";		
		$xml .= "   <insit_prov>".($realopcao == 'E' || $realopcao == 'A' ?1:$tpsituacao)."</insit_prov>";		
		$xml .= "   <dtsaqpagto>".trim($dtSaqPagto.' '.$hrSaqPagto)."</dtsaqpagto>";		
		$xml .= "   <idorigem>".$tporigem."</idorigem>";		
		$xml .= "   <vlsaqpagto>".$vlSaqPagto."</vlsaqpagto>";
		$xml .= "   <nrcpfcnpj>".$nrCpfCnpj ."</nrcpfcnpj>";
		$xml .= "   <dsprotocolo>".$dsprotocolo."</dsprotocolo>";
		$xml .= "   <cdopcao>".$realopcao."</cdopcao>";
		$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
		$xml .= "   <nrregist>".$nrregist."</nrregist>";		
		$xml .= " </Dados>";
		$xml .= "</Root>";	
		#echo 'console.log("'.$procedure.'");';	
		#echo 'console.log("'.$xml.'");';
		$xmlResult = mensageria($xml, "TELA_PRVSAQ", $procedure, $glbvars['cdcooper'],1, 1, $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
		#echo 'console.log("'.str_replace('"','',$xmlResult).'"); hideMsgAguardo();';
		$xmlObj = getObjectXML($xmlResult);
	}   
	
	$xmlObj = simplexml_load_string($xmlResult);

	if($cddopcao == "I"){
		$codError = $xmlObj->Erro->Registro->cdcritic;		
		if(!isset($codError)){
			$dsprotocolo = $xmlObj->Dados->inf->dsprotocolo;
			echo "$('#dsprotocolo','#frmInclusao').val('".$dsprotocolo."');";
			echo 'showConfirmacao("Aten&ccedil;&atilde;o, deseja imprimir o protocolo?","Confirma&ccedil;&atilde;o - Ayllos","imprimirProtocolo()","showError(\'inform\',\'Provis&atilde;o de Saque inserido com sucesso!\',\'Alerta - Ayllos\',\'estadoInicial();hideMsgAguardo();\');","sim.gif","nao.gif");';
		}else{
			$msg = $xmlObj->Erro->Registro->dscritic;
			if($codError == 13){
				echo "showError('error','".$msg."','Alerta - Ayllos','$(\'#dtSaqPagto\',\'#frmInclusao\').focus();');";	
			}else if($codError == 244){
				echo "showError('error','".$msg."','Alerta - Ayllos','$(\'#nrCheque\',\'#frmInclusao\').focus();');";	
			}else if($codError == 564){
				echo "showError('error','".$msg."','Alerta - Ayllos','$(\'#nrContCheq\',\'#frmInclusao\').focus();');";	
			}else if($codError == 27){
				echo "showError('error','".$msg."','Alerta - Ayllos','$(\'#nrCpfSacPag\',\'#frmInclusao\').focus();');";	
			}else if($msg == 'PA nao cadastrado.'){
				echo "showError('error','".$msg."','Alerta - Ayllos','$(\'#nrPA\',\'#frmInclusao\').focus();');";	
			}else if($msg == 'Titular nao encontrado.'){
				echo "showError('error','".$msg."','Alerta - Ayllos','$(\'#nrTit\',\'#frmInclusao\').focus()');";
			}else{
				echo "showError('error','".$msg."','Alerta - Ayllos','');";	
			}
		}		
		exit();
	}else if($cddopcao == 'I!'){
		$vlSaqPagto = empty($xmlObj->Dados->inf->vlsaque)?-1:$xmlObj->Dados->inf->vlsaque;		
		if($vlSaqPagto >0){			
			echo 'showConfirmacao("Aten&ccedil;&atilde;o, Provis&atilde;o de saque j&aacute; cadastrado, deseja realizar novo cadastro?","Confirma&ccedil;&atilde;o - Ayllos","manter_rotina(\'I!!\')","estadoInicial()","sim.gif","nao.gif");';
		}else{
			echo "manter_rotina('I!!');";
		}
	}else if($cddopcao =='T'){
		$nrBanco = empty($xmlObj->Dados->inf->nrbanco)?0:$xmlObj->Dados->inf->nrbanco;
		$nrAgencia = empty($xmlObj->Dados->inf->nragencia)?0:$xmlObj->Dados->inf->nragencia;
		echo "$('#nrBanco','#frmInclusao').val('".($nrBanco)."');";
		echo "$('#nrAgencia','#frmInclusao').val('".($nrAgencia)."');";

		echo "hideMsgAguardo();";
		exit();
	}else if($cddopcao == 'CT'){		
		$codError = $xmlObj->Erro->Registro->cdcritic;
		if(isset($codError)){
			$msg = $xmlObj->Erro->Registro->dscritic;		
			
			echo "$('#nrCpfCnpj','#frmInclusao').val('');";		
			echo "$('#nmSolic','#frmInclusao').val('');";
			echo "$('#indPessoa','#frmInclusao').val('');";
			 if($codError == 564){
				echo "showError('error','".$msg."','Alerta - Ayllos','$(\'#nrContTit\',\'#frmInclusao\').focus();');";	
			}else if($msg == 'Titular nao encontrado.'){				
				echo "showError('error','".$msg."','Alerta - Ayllos','$(\'#nrTit\',\'#frmInclusao\').focus()');";
			}else{				
				echo "showError('error','".$msg."','Alerta - Ayllos','');";
			}			
		}else{
			$inPessoa = $xmlObj->Dados->inf->inpessoa;
			$nrcpfcgc = $xmlObj->Dados->inf->nrcpfcgc;
			$nmprimtl = $xmlObj->Dados->inf->nmprimtl;			

			echo "$('#indPessoa','#frmInclusao').val('".$inPessoa."');";
			if($inPessoa != '1'){			
				echo "$('#nrTit','#frmInclusao').attr('disabled',true);";
				echo "$('#nrTit','#frmInclusao').val('');";
				echo "$('#nrCpfCnpj','#frmInclusao').val('".formatar($nrcpfcgc, 'cnpj')."');";								
				echo "$('#nmSolic','#frmInclusao').val('".$nmprimtl."');";				
				if($nriniseq == 1){					
					echo "$('#nrCpfSacPag','#frmInclusao').focus();";	
				}
			}else{				
				echo "$('#nrTit','#frmInclusao').attr('disabled',false);";								
				if(!empty($nrTit)){						
					echo "$('#nrCpfCnpj','#frmInclusao').val('".formatar($nrcpfcgc, 'cpf')."');";		
					echo "$('#nmSolic','#frmInclusao').val('".$nmprimtl."');";					
					if($nriniseq == 2){						
						echo "$('#nrCpfSacPag','#frmInclusao').focus();";
					}else{
						echo "$('#nrTit','#frmInclusao').focus();";
					}				
				}else{
					echo "$('#nrCpfCnpj','#frmInclusao').val('');";		
					echo "$('#nmSolic','#frmInclusao').val('');";					
					if($nriniseq == 1){				
						echo "$('#nrTit','#frmInclusao').focus();";
					}
				}																							
			}
		}
		echo "hideMsgAguardo();";
		exit();
	}else if($cddopcao =='CS'){
		$codError = $xmlObj->Erro->Registro->cdcritic;
		if(isset($codError)){
			echo "showError('error','".$xmlObj->Erro->Registro->dscritic."','Alerta - Ayllos','$(\'#nrCpfSacPag\',\'#frmInclusao\').focus();');";
			echo "$('#nmSacPag','#frmInclusao').val('');";
		}else{
			$nmextttl = $xmlObj->Dados->inf->nmextttl;				
			echo "$('#nmSacPag','#frmInclusao').val('".$nmextttl."');";			
		}
		exit();
	}else if($cddopcao == 'PDF'){
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
			echo "showError('error','".$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata."','Alerta - Ayllos','');";
			exit();
		}		
		// Chama função para mostrar PDF do impresso gerado no browser
		visualizaPDF(getByTagName($xmlObjeto->roottag->tags[0]->tags,'NMARQPDF'));
	}else if($cddopcao =='C' || $cddopcao == 'E' || $cddopcao == 'A' || $cddopcao=='A!'){		
		$codError = $xmlObj->Erro->Registro->cdcritic;	
		if(isset($codError)){
			echo "showError('error','".$xmlObj->Erro->Registro->dscritic."','Alerta - Ayllos','');";			
		}else{
			$registros 	= $xmlObj->Dados;
			$qtregist   = $xmlObj->Dados->qtregist[0];						
			include('form_consulta.php');	
		}
		exit();
	}
?>