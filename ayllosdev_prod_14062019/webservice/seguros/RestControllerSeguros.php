<?php
/*
 * Entrada - REST dos Seguros no Ayllos
 *
 * @autor: Lombardi / Renato(SUPERO)
 */
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');

// Busca do idServico via GET ou no conteudo do POST/PUT
$idservico = $_GET['idServico']; 

// Caso não seja numérico
if(!is_numeric($idservico)){
	echo json_encode(array('status' => 402,'dscritic' => 'Parametro idServico nao e um numero valido!'));
	die;
}

// Tratamento das requisições conforme o idServico
if ($idservico == 1) {
	// Solicitacao de informações do Cooperado
	require_once("class_rest_seguros_GET.php");
	$oRestSeguros = new RestSeguros();
	$oRestSeguros->processaRequisicao();
	
} else if ($idservico >= 2 && $idservico <= 6) {
	// Inclusão, Endosso, Cancelamento, Renovação e Vencimento (respectivamente)
	require_once("class_rest_seguros_PUT.php");
	$oRestSeguros = new RestSeguros();
	$oRestSeguros->processaRequisicao();
	
} else if ($idservico == 7) {
	// Recebimento de arquivo de convenio
	require_once("class_rest_convenios.php");
	
	if (isset($_FILES['fileArquiv'])) { 
		$filearquiv	= $_FILES['fileArquiv'];

		// O prefixo "003.0." é adicionado ao nome do arquivo para que o script de cópia do Oracle consiga localizar
		// os diretórios de origem e destino para mover o mesmo. Neste caso será sempre tratado como CECRED.
		$nomeArquivo = '003.0.' . $filearquiv['name'];
		move_uploaded_file ($filearquiv['tmp_name'], '../../upload_files/' . $nomeArquivo );
		
		// Atualiza o nome do arquivo nas referencias
		$_FILES['fileArquiv']['name'] = $nomeArquivo;
		$_POST['nmArquiv'] = $nomeArquivo;
	}
	$oRestConvenios = new RestConvenios();
	$oRestConvenios->processaRequisicao();
	
	// Remoção do arquivo criado pois ele já foi baixado no Oracle
	unlink('../../upload_files/' . $nomeArquivo);
	
} else if ($idservico >= 8 && $idservico <= 9) {
	// Retorno dos arquivos
	require_once("class_rest_convenios.php");
	$oRestConvenios = new RestConvenios();
	$oRestConvenios->processaRequisicao();
}
else{
	// Nenhuma das opções válidas
	echo json_encode(array('status' => 402,'dscritic' => 'idServico invalido! Somente utilizar o range de 1 a 9!'));
	die;
}
?>