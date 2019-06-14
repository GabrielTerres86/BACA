<? 
/*!
 * FONTE        : busca_arquivos_importacao.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 23/03/2016
 * OBJETIVO     : Rotina para importacao dos arquivos do bancoob
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : ''; 	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
	
	// Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	    
	$xml .= " </Dados>";
	$xml .= "</Root>";

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "IMPCAR", "IMPCAR_CONSULTAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObjeto->roottag->tags[0]->cdata;
        }
        exibirErro('error',$msgErro,'Alerta - Ayllos',"estadoInicial();",true);
	}
	
	$aTags0  	 = $xmlObjeto->roottag->tags[0];
	$aRegistros  = $xmlObjeto->roottag->tags[1]->tags;
	$situacao    = getByTagName($aTags0->tags,'SITUACAO');
	
	include("form_importacao_arquivo.php");
?>
<script>
	trocaBotao('showConfirmacao(\'Confirma a opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'importarArquivos();\',\' \',\'sim.gif\',\'nao.gif\')','btnVoltar()','Importar Arquivos');
</script>