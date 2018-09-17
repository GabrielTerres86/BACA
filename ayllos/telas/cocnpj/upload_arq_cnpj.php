 <?php
/*!
 * FONTE        : upload_arq_cnpj.php
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : 16/09/2016
 * OBJETIVO     : Rotina para upload de arquivo COCNPJ
 * --------------
 * ALTERAÇÕES   : 
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
	
	// Ler parametros passados via POST
	$cddopcao     = (isset($_POST['cddopcao']))  ? $_POST['cddopcao']  : '';
	$file      = (isset($_FILES['userfile'])) ? $_FILES['userfile'] : '';

	// retorno sera de eval ou html
	$eval     = (isset($_POST['redirect'])) ? true : false;
    $tempo    = time();
    // Local de Upload do arquivo -  Antes de passar pelo "upload_file.php"
	$nmupload  = "../../upload_files/cocnpj." . $tempo . ".txt";

	$nmupload  = "cocnpj.txt";

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
		$arrCrit[] = "ATENCAO: Arquivo não encontrado.";
	}
	// Verificar o tamanho do arquivo
	if($file["size"] > (8 * (1024 * 1024))){
		$arrCrit[] = "ATENCAO: Tamanho do arquivo deve ser menor que 8 mb.";
	}
	// Validar o arquivo
	if(!is_uploaded_file($file["tmp_name"])){
		$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL1.";
	}
	if (!move_uploaded_file($file["tmp_name"], $nmupload)) {
		$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL2.";
	}
	
	// gerar erros criticos
	if(count($arrCrit) > 0){
		$funcao = "msgError('error','".$arrCrit[0]."','hideMsgAguardo();');";
		echo '<script> parent.framePrincipal.eval("'.$funcao.'"); </script>';
		exit();
	}

	$tempo     = time();
	// Nome do arquivo do upload - Depois de passar pelo "upload_file.php"
	$dirArqDne = "../../upload_files/";
	$filename  = "cocnpj.". $tempo . ".txt";
    $Arq       = $nmupload;

	//encriptacao e envio do arquivo
	require("../../includes/upload_file.php");

    // Caminho que deve ser enviado ao Mensageria / para ORACLE fazer exec do CURL
    $caminhoCompleto = $_SERVER['SERVER_NAME'].'/'.str_replace('../../','',$caminho);
    
    // Apaga o arquivo de UPLOAD que está sem Criptografia
    unlink($Arq);

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";	
	$xml .= "		<dsarquiv>".$NomeArq."</dsarquiv>";	 // Variável $NomeArq vem da gnuclient_upload_file.php
	$xml .= "		<dsdireto>".$caminhoCompleto."</dsdireto>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "COCNPJ", 'IMPORTAR_ARQ_CNPJ', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		$funcao = "msgError('error','".utf8ToHtml( removeCaracteresInvalidos($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata))."','hideMsgAguardo();');";
    }else{
		$registros = $xmlObjeto->roottag->tags[0]->tags;
		$arr = $xmlObjeto->roottag->tags[0];   // returns an array
		$funcao = "msgError('inform','".utf8ToHtml("Arquivo importado com sucesso.")."','hideMsgAguardo();');";
	}		

	echo '<script> parent.framePrincipal.eval("'.$funcao.'"); </script>';

?>