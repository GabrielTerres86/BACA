<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Daniel Zimmermann       
 * DATA CRIAÇÃO : 20/03/2013
 * OBJETIVO     : Rotina para geração de relatorios da tela RELTAR.
 * --------------
 * ALTERAÇÕES   : 24/07/2013 - Alterado rotina de exibicao mensagem de
 *							   erro (Daniel). 								    			
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
	$tprelato      = (isset($_POST['tprelato1'])) ? $_POST['tprelato1'] : '' ; 
	$cdhistor	   = (isset($_POST['cdhistor1'])) ? $_POST['cdhistor1'] : 0  ; 	
	$cddgrupo	   = (isset($_POST['cddgrupo1'])) ? $_POST['cddgrupo1'] : 0  ; 	
	$cdsubgru	   = (isset($_POST['cdsubgru1'])) ? $_POST['cdsubgru1'] : 0  ; 	
	$cdhisest      = (isset($_POST['cdhisest1'])) ? $_POST['cdhisest1'] : 0  ; 
	$cdmotest      = (isset($_POST['cdmotest1'])) ? $_POST['cdmotest1'] : 0  ; 
	$cdcoptel      = (isset($_POST['cdcooper1'])) ? $_POST['cdcooper1'] : 0  ; 
	$cdagetel      = (isset($_POST['cdagenci1'])) ? $_POST['cdagenci1'] : 0  ; 
	$inpessoa      = (isset($_POST['inpessoa1'])) ? $_POST['inpessoa1'] : 0  ; 
	$nrdconta      = (isset($_POST['nrdconta1'])) ? $_POST['nrdconta1'] : 0  ; 	
	$dtinicio      = (isset($_POST['dtinicio'])) ? $_POST['dtinicio'] : '' ;
	$dtafinal      = (isset($_POST['dtafinal'])) ? $_POST['dtafinal'] : '' ;
	$cddopcao	   = 'C';

	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	$nmendter = session_id();
	
	// Verifica Procedure a ser executada	
	switch($tprelato) {
		case '1': { $procedure = 'rel-receita-tarifa'; 	} break;
		case '2': { $procedure = 'rel-estorno-tarifa';	} break;	
		case '3': { $procedure = 'rel-tarifa-baixada';	} break;	
		case '4': { $procedure = 'rel-tarifa-pendente';	} break;	
		case '5': { $procedure = 'rel-estouro-cc';	    } break;
		/*                   RESUMIDOS                       */
		case '6': { $procedure = 'rel-receita-tarifa-resumido';  } break;
		case '7': { $procedure = 'rel-estorno-tarifa-resumido';  } break;	
		case '8': { $procedure = 'rel-tarifa-baixada-resumido';	 } break;	
		case '9': { $procedure = 'rel-tarifa-pendente-resumido'; } break;	
		case '10': { $procedure = 'rel-estouro-cc-resumido';	 } break;		
	}		

	$retornoAposErro = 'focaCampoErro(\'dtafinal\', \'frmRel\');';
	
	$cddopcao = 'C';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0153.p</Bo>';
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
	$xml .= '		<tprelato>'.$tprelato.'</tprelato>';
	$xml .= '		<cdhistor>'.$cdhistor.'</cdhistor>';
	$xml .= '		<cddgrupo>'.$cddgrupo.'</cddgrupo>';
	$xml .= '		<cdsubgru>'.$cdsubgru.'</cdsubgru>';
	$xml .= '		<cdhisest>'.$cdhisest.'</cdhisest>';
	$xml .= '		<cdmotest>'.$cdmotest.'</cdmotest>';
	$xml .= '		<cdcoptel>'.$cdcoptel.'</cdcoptel>';
	$xml .= '		<cdagetel>'.$cdagetel.'</cdagetel>';
	$xml .= '		<inpessoa>'.$inpessoa.'</inpessoa>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<dtinicio>'.$dtinicio.'</dtinicio>';
	$xml .= '		<dtafinal>'.$dtafinal.'</dtafinal>';
	$xml .= '		<nmendter>'.$nmendter.'</nmendter>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
    // Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	$xmlObjCarregaImpressao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjCarregaImpressao->roottag->tags[0]->name == "ERRO") {
	    exibeErro($xmlObjCarregaImpressao->roottag->tags[0]->tags[0]->tags[4]->cdata);		 
    }
		
	//Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjCarregaImpressao->roottag->tags[0]->attributes["NMARQPDF"];
	
	//Chama função para mostrar PDF do impresso gerado no browser	 
	visualizaPDF($nmarqpdf);
	
	
	// Função para exibir erros na tela através de javascript
    function exibeErro($msgErro) { 
	  echo '<script>alert("'.$msgErro.'");</script>';	
	  exit();
    }
	
?>