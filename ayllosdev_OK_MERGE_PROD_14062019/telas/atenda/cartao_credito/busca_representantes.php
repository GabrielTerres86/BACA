<? 
/*!
 * FONTE        : busca_representantes.php
 * CRIAÇÃO      : Jean Michel       
 * DATA CRIAÇÃO : 17/04/2014 
 * OBJETIVO     : Rotina para consulta de representates para tele de novos cartões de crédito
 * --------------
 * ALTERAÇÕES   : 
 *         22/10/2014 - Retirado validação de permissão para carregar combo de representantes ( Renato - Supero )
 *         13/10/2015 - Desenvolvimento do projeto 126. (James)
 * -------------- 
 */
	
    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa	
	$retornoAposErro= '';
	
	$retornoAposErro = 'focaCampoErro(\'cddopcao\', \'frmCab\');';
	
	/* RENATO - SUPERO - 22/10/2014
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}*/
	
	// Verifica se os parâmetros necessários foram informados	
	if(!isset($_POST["nrdconta"]) || !isset($_POST["tpctrato"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro,false);
	}else{
	
		$nrdconta = $_POST["nrdconta"];
		$tpctrato = $_POST["tpctrato"];
		$dsoutros = $_POST["dsoutros"];
		$cdadmcrd = $_POST['cdadmcrd'];
		$inpessoa = $_POST['inpessoa'];
		$idastcjt = $_POST['idastcjt'];
		
		$nrcpfcgc = !isset($_POST["nrcpfcgc"]) ? 0 : $_POST["nrcpfcgc"];
		
		// Verifica se número da conta ou tpctrato é um inteiro válido
		if (!validaInteiro($nrdconta) || !validaInteiro($tpctrato)) exibirErro('error','Op&ccedil;&atilde;o inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	}
			
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <tpctrato>".$tpctrato."</tpctrato>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "ATENDA", "CONPRO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);
	} else {
	
		$registros = $xmlObj->roottag->tags[0]->tags;		
		
		$i = 0;
		foreach ( $registros as $representantes ) {
				
		
			if (strtoupper($xmlObj->roottag->tags[0]->tags[$i]->name) != 'INF'){
				$i++;
				continue;
			}		
		?>				
				ObjRepresent = new Object(); 		
				ObjRepresent.nmdavali = '<? echo getByTagName($representantes->tags,'nmdavali') ?>'; 
				ObjRepresent.nrcpfcgc = '<? echo getByTagName($representantes->tags,'nrcpfcgc') ?>'; 		 
				ObjRepresent.tpdocttl = '<? echo getByTagName($representantes->tags,'tpdocttl') ?>'; 
				ObjRepresent.nrdocttl = '<? echo getByTagName($representantes->tags,'nrdocttl') ?>'; 
				ObjRepresent.dtnasttl = '<? echo getByTagName($representantes->tags,'dtnasttl') ?>'; 											
				ObjRepresent.floutros = 0;
				
				$('#dsrepinc','#frmNovoCartao').append('<option value="<? echo $i ?>"><? echo getByTagName($representantes->tags,'nmdavali') ?></option>');
				Representantes[<? echo $i ?>] = ObjRepresent;		
			
		<? 
		
			$i++;
		}			
		//empresa, assinatura conjunta e cartão múltiplo
		if( ($inpessoa == 2) && ($idastcjt == 1) && ($cdadmcrd == 15)){
			?>
				$("#flgdebit").removeAttr("checked");
				desativa("flgdebit");
				
			<?
		}

		
		if ($dsoutros == 'OUTROS' && $cdadmcrd == 15){ 
			?>				
				ObjRepresent = new Object(); 		
				ObjRepresent.nmdavali = '';
				ObjRepresent.nrcpfcgc = '';
				ObjRepresent.tpdocttl = '';
				ObjRepresent.nrdocttl = '';
				ObjRepresent.dtnasttl = '';
				ObjRepresent.floutros = 1;
				$('#dsrepinc','#frmNovoCartao').append('<option value="<? echo $i ?>">OUTROS</option>');
				Representantes[<? echo $i ?>] = ObjRepresent;
			<?
		}
	}	
?>