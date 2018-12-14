<?php
/*!
 * FONTE        : download_arquivo.php
 * CRIA��O      : Jonata - Mouts      
 * DATA CRIA��O : Outubro/2018
 * OBJETIVO     : realizar o download do arquivo
 * --------------
 * ALTERA��ES   : 
 * --------------
 */
 ?>
<?       
	session_cache_limiter("private");
	session_start();

	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$_POST['opcao'])) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Verifica se par�metros necess�rios foram informados
	if (!isset($_POST['nmarquiv'])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	
	
    $nmarquiv = $_POST['nmarquiv'];
	
	// Chama fun��o para realizar o download do arquivo
	visualizaCSV($nmarquiv);

?>