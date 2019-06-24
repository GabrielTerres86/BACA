 <?php
/*!
 * FONTE        : upload_ted.php
 * CRIAÇÃO      : Anderson Schloegel - Mout's
 * DATA CRIAÇÃO : 15-05-2019
 * OBJETIVO     : Rotina para upload de arquivo de Transferências/Ted
 * --------------
 * ALTERAÇÕES   : 
 *
 *
 *
 *
 * --------------
 */
if( !ini_get('safe_mode') ){
		set_time_limit(300);
	}
	session_cache_limiter("private");
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	
	isPostMethod();
	
    $table_erros = "";
	
	// Ler parametros passados via POST
	$cddopcao = (isset($_POST['cddopcao']))  ? $_POST['cddopcao']  : '';
	$file     = (isset($_FILES['userfile'])) ? $_FILES['userfile'] : '';
	$flglimpa = (isset($_POST['flglimpa'])) ? $_POST['flglimpa'] : '0';
	$nudconta = (isset($_POST['nudconta'])) ? $_POST['nudconta'] : '0';
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '0';
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '0';
	$cdcooper = (isset($glbvars['cdcooper'])) ? $glbvars['cdcooper'] : '0';
	$flghomol = (isset($_POST['flghomol'])) ? $_POST['flghomol'] : '0';
	$cdagectl = (isset($_POST['cdagectl'])) ? $_POST['cdagectl'] : '0';
	$nrconven = '1';
	$aux_remessa = 0;

	// decode do INPESSOA - Se for 1 "PF" vai continuar com 1, caso contrario eh 2 -"PJ" 
	$inpessoa = ($inpessoa == 1) ? 1 : 2;

	// retorno sera de eval ou html
	$eval     = (isset($_POST['redirect'])) ? true : false;
    $tempo    = time();

	$nmupload  = "uppgto.txt";
	
    // CONVERTER STRING DO NOME PARA MAIUSCULO....
    $file["name"] = strtoupper($file["name"]);
	$aux_nmupload = "/tmp/".$cdcooper.".".$nrsdconta.".";

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		$msgError = "Erro ao validar permiss&atilde;o de acesso!";
		$funcao = "msgError('error','".$msgError."','hideMsgAguardo();');";
		echo '<script> parent.framePrincipal.eval("'.$funcao.'"); </script>';
		exit();
	}

	// Instanciar arrays....
	$arrCrit    = array();
	$arrStrFile = array();

	// se destinatario for por upload file
	if($file["error"] > 0){
		switch($file["error"]){
			case 1:	$arrCrit[] = "ATENCAO: Tamanho do arquivo excedeu o permitido.";		break;
			case 2:	$arrCrit[] = "ATENCAO: Tamanho do arquivo deve conter menos de 8 mb.";  break;
			case 3:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER3.";					break;
			case 4:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER4.";					break;
			case 6:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER6.";					break;
			case 7:	$arrCrit[] = "ATENCAO: Falha ao gravar arquivo ER7.";					break;
			case 8:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER8.";					break;
		}
	}

	// Se não encontrar o arquivo...
	if($file == ""){
		$arrCrit[] = "ATENCAO: Arquivo n&atilde;o encontrado.";
	}
	// Verificar o tamanho do arquivo
	if($file["size"] > (1 * (1024 * 1024))){
		$arrCrit[] = "ATENCAO: Tamanho do arquivo deve ser menor que 8 mb.";
	}
	// Validar o arquivo
	if(!is_uploaded_file($file["tmp_name"])){
		$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL1.";
	}
	if (!move_uploaded_file($file["tmp_name"], $nmupload)) {
		$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL2. - ".$_FILES["file"]["error"]." - TMP: ".$file["tmp_name"];
	}
	
	// gerar erros criticos
	if(count($arrCrit) > 0){
		$funcao = "msgError('error','".$arrCrit[0]."','hideMsgAguardo();');";
		echo '<script> parent.framePrincipal.eval("'.$funcao.'"); </script>';
		exit();
	}

    $strFile = file_get_contents($nmupload);	
	$aux_nmarquivo = $file["name"];	
	
	// Definir array dos caracteres a serem substituidos
    $caracteres = array();
    $caracteres[0] = "/\;/";
    $caracteres[1] = "/\"/";
    $caracteres[2] = "/\'/";
    $caracteres[3] = "/\>/";
    $caracteres[4] = "/\</";
    $caracteres[5] = "/\`/";
    $caracteres[6] = "/\´/";
     
    $substituto = array();
    $substituto[0] = ' ';
    $substituto[1] = ' ';
    $substituto[2] = ' ';
    $substituto[3] = ' ';
    $substituto[4] = ' ';
    $substituto[5] = ' ';
    $substituto[6] = ' ';
    
     /* Retirar caracteres especiais da linha do arquivo, pois causam problemas
        ao serem lidos no php ou ambiente unix. */
    $strFile = preg_replace($caracteres,$substituto,$strFile);
	
	// Verificar se os tres primeiros caracteres identificam o arquivo no formato UTF-8
	if ( substr( $strFile ,0 , 3) == "ï»¿") {
		// Descartar os três primeiros caracteres do UTF-8
		$strFile = substr( $strFile, 3);
	}

	// remover o caracter acentuado pelo caracter correspondente sem acento
	$strFile = strtr($strFile, "àáâãäåÀÁÂÃÄÅèéêëÈÉÊËìíîïÌÍÎÏòóôõöøÒÓÔÕÖØùúûüÙÚÛÜçÇñÑÿŸ", 
	                           "aaaaaaAAAAAAeeeeEEEEiiiiIIIIooooooOOOOOOuuuuUUUUcCnNyY");

    // Reescrever o arquivo que fez replace 
    file_put_contents($nmupload, $strFile);

	// Ler parametros passados via POST
	$file      = (isset($_FILES['userfile'])) ? $_FILES['userfile'] : '';
	$flglimpa  = (isset($_POST['flglimpa'])) ? $_POST['flglimpa'] : '0';

	// retorno sera de eval ou html
	$eval     = (isset($_POST['redirect'])) ? true : false;
    $tempo    = time();
    // Local de Upload do arquivo -  Antes de passar pelo "upload_file.php"
	//$nmupload  = "../../upload_files/cocnae." . $tempo . ".txt";

	$nmupload  = "uppgto.txt";

	// Nome do arquivo do upload - Depois de passar pelo "upload_file.php"
	//$dirArqDne = "//usr/coop/viacredi/upload/";
    $dirArqDne = "../../upload_files/";
	$filename  = $aux_nmarquivo;
    $Arq       = 'uppgto.txt';

	//encriptacao e envio do arquivo
	require("../../includes/upload_file_ted.php");

    // Caminho que deve ser enviado ao Mensageria / para ORACLE fazer exec do CURL
    $caminhoCompleto = $_SERVER['SERVER_NAME'].'/'.str_replace('../../','',$caminho);
    //$caminhoCompleto = "//usr/coop/viacredi/upload/";
    
    // Apaga o arquivo de UPLOAD que está sem Criptografia
    unlink($Arq);

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";	
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<nrdconta>".$nudconta."</nrdconta>";
	$xml .= "		<dsarquiv>".$NomeArq."</dsarquiv>";
	$xml .= "		<dsdireto>".$caminhoCompleto."</dsdireto>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "PGTA0001", 'IMPORTAARQTED', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	error_reporting(E_ALL);
	ini_set('display_errors', 1);

	$xml = simplexml_load_string($xmlResult);

	$criticas = '';
	$showNumber = 1;


	//print_r($xmlResult);

	// se tem criticas, exibe tabela de criticas
	if(strtoupper($xmlObjeto->roottag->tags[0]->tags[0]->name) === 'CRITICAS') {

		// exibe fieldset onde vai tabela
		$exibe_caixa = "$('#fCriticasTed').show();";

		// percorre vetor de criticas
		foreach ($xml->Dados as $key => $value) {
			foreach ($value as $key2 => $value2) {

				$criticas .= ' <tr>';
				$criticas .= '   <td>';
				$criticas .= 	   $showNumber;
				$criticas .= '   </td>';
				$criticas .= '   <td>';
				$criticas .=      utf8_decode($value2->dscritic);
				$criticas .= '   </td>';
				$criticas .= ' </tr>';

				$showNumber++;
			}
		}

		// monta tabela
		$table_erros  = '<table>';
		$table_erros .= '  <thead>';
		$table_erros .= '    <tr>';
		$table_erros .= '      <th>Seq.</th>';
		$table_erros .= '      <th>Cr&iacute;ticas</th>';
		$table_erros .= '    </tr>';
		$table_erros .= '  </thead>';
		$table_erros .= '  <tbody>';
		$table_erros .= $criticas;
		$table_erros .= '</tbody></table>';
		$texto = 'criticaOpcaoE(\"'.$table_erros.'\");';

		echo '<script>
					 parent.framePrincipal.eval("'.$exibe_caixa.'");
					 parent.framePrincipal.eval("'.$texto.'");
		 	  </script>';
		echo '';

		exit();


	} else if(strtoupper($xmlObjeto->roottag->tags[0]->name) === "ERRO") {

		//echo $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$funcao = "msgError('error','".utf8ToHtml( removeCaracteresInvalidos($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata))."','hideMsgAguardo();');";
		echo '<script> parent.framePrincipal.eval("'.$funcao.'"); </script>';
		exit;

	} else if(strtoupper($xmlObjeto->roottag->tags[0]->cdata) === "OK") {

		$funcao = "sucessoOpcaoE();";
		echo '<script> parent.framePrincipal.eval("'.$funcao.'"); </script>';
		// echo "<script>parent.framePrincipal.eval( 'showError('inform','Arquivo importado com sucesso (teste1).','Alerta - Ayllos','',false);' );</script>";
		exit;

	} else {

		$funcao = "sucessoOpcaoE();";
		echo '<script> parent.framePrincipal.eval("'.$funcao.'"); </script>';
		// echo "<script>parent.framePrincipal.eval( 'showError('inform','Arquivo importado com sucesso (teste2).','Alerta - Ayllos','',false);' );</script>";
		exit;

	}
	
	//echo '<script> parent.framePrincipal.eval("'.$funcao.'"); </script>';
	//exit();

?>