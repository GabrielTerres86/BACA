<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Daniel Zimmermann       
 * DATA CRIAÇÃO : 20/03/2013
 * OBJETIVO     : Rotina para geração de relatorios da tela RELTAR.
 * --------------
 * ALTERAÇÕES   : 24/07/2013 - Alterado rotina de exibicao mensagem de
 *							   erro (Daniel). 								    			
 *                19/09/2013 - Implementada opcao AC da tela EXTRAT (Tiago).
 *
 *                02/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
 *                             departamento como parametros e passar o o código (Renato Darosci)
 *
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
	$cddopcao      = (isset($_POST['cddopcao1'])) ? $_POST['cddopcao1'] : '' ; 
	$nmarquiv      = (isset($_POST['nmarquiv1'])) ? $_POST['nmarquiv1'] : '' ; 	
	$nrdconta      = (isset($_POST['nrdconta1'])) ? $_POST['nrdconta1'] : 0  ; 
	$dtinimov      = (isset($_POST['dtinimov1'])) ? $_POST['dtinimov1'] : 0  ; 
	$dtfimmov      = (isset($_POST['dtfimmov1'])) ? $_POST['dtfimmov1'] : 0  ; 
	$nriniseq      = (isset($_POST['nriniseq1'])) ? $_POST['nriniseq1'] : 0  ; 
	$nrregist      = (isset($_POST['nrregist1'])) ? $_POST['nrregist1'] : 0  ; 
	
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	$flgoptmp = false;
	
	$nmendter = session_id();
	$dsiduser = session_id();
	
	// Verifica Procedure a ser executada		
	$procedure = 'Busca_Extrato'; 

	//$retornoAposErro = 'focaCampoErro(\'dtafinal\', \'frmRel\');';

	if($cddopcao == "AC"){
		$cddopcao = "A";
		$flgoptmp = true;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	if($flgoptmp == true){
		$cddopcao = "AC";
	}
	
	// exibeErro("Monta XML");
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0103.p</Bo>';
	$xml .= '		<Proc>Busca_Extrato</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
 	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmoperad>'.$glbvars['nmoperad'].'</nmoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
 	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cddepart>'.$glbvars['cddepart'].'</cddepart>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<dtinimov>'.$dtinimov.'</dtinimov>';
	$xml .= '		<dtfimmov>'.$dtfimmov.'</dtfimmov>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<nmarquiv>'.$nmarquiv.'</nmarquiv>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<nrregist>'.$nrregist.'</nrregist>';
	$xml .= '		<nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
    // Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	$xmlObjCarregaImpressao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjCarregaImpressao->roottag->tags[0]->name == "ERRO") {
	    exibeErro($xmlObjCarregaImpressao->roottag->tags[0]->tags[0]->tags[4]->cdata);		 
    }

	// exibeErro("visualizaPDF.");
	
	$pos = strpos($nmarquiv, ".pdf");
	
	if($pos === false){
		exibeErro("Arquivo gerado com sucesso!");
	}else{
		//Chama função para mostrar PDF do impresso gerado no browser	 	
		visualizaPDF($nmarquiv);		
	}
		
	
	// Função para exibir erros na tela através de javascript
    function exibeErro($msgErro) { 
	  echo '<script>alert("'.$msgErro.'");</script>';	
	  exit();
    }
	
?>