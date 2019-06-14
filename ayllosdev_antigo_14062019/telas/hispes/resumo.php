<? 
    /*!
     * FONTE        : resumo.php
     * CRIAÇÃO      : Odirlei Busana(AMcom)
     * DATA CRIAÇÃO : Novembro/2017 
     * OBJETIVO     : Cabecalho tela HISPES
     * --------------
     * ALTERAÇÕES   :
     * --------------
     *
     */	
     
    session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (!isset($_POST["nrcpfcgc"]))  {
		exibeErro("Parâmetros incorretos.");
	}	
			
	$nrcpfcgc = $_POST["nrcpfcgc"] == "" ? 0 : $_POST["nrcpfcgc"];
    $cdcooper = $_POST["cdcooper"] == "" ? 0 : $_POST["cdcooper"];
    $nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
    $idseqttl = $_POST["idseqttl"] == "" ? 0 : $_POST["idseqttl"];
    $idpessoa = $_POST["idpessoa"] == "" ? 0 : $_POST["idpessoa"];
    
	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("Conta/dv inválida.");
	} 
 
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
    $xml .= "   <cdcoptel>".$cdcooper."</cdcoptel>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <idseqttl>".$idseqttl."</idseqttl>";
    $xml .= "   <idpessoa>".$idpessoa."</idpessoa>";    
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_HISPES", "LISTAR_RESUMO_HSTPES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErroNew($msgErro);
        exit();
    }

    $registros = $xmlObj->roottag->tags[0]->tags;

    function exibeErroNew($msgErro) {
        echo 'hideMsgAguardo();';
        echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
        exit();
    }
 
 
?>

<form name="frmResumo" id="frmResumo" class="formulario">
    <div class="divRegistros divRegistrosRes">
        <table>
            <thead>
                <tr><th><? echo utf8ToHtml('Descrição'); ?></th>
                    <th><? echo utf8ToHtml('Tipo de Operacão'); ?></th>
                    <th><? echo utf8ToHtml('Data de Operacão'); ?></th>
                    <th><? echo utf8ToHtml('Operador'); ?></th>
                </tr>
            </thead>		
            <tbody>
                <? foreach( $registros as $registro ) {?>
                    <tr onclick="acessaOpcaoAbaDados(999,'<? echo getByTagName($registro->tags,'nmtabela_oracle'); ?>','<? echo getByTagName($registro->tags,'dhalteracao'); ?>');">
                        <td><? echo getByTagName($registro->tags,'dsresumo'); ?>
                            <input type="hidden" id="nmtabela_oracle" name="nmtabela_oracle" value="<? echo getByTagName($registro->tags,'nmtabela_oracle') ?>" /></td>
                            <input type="hidden" id="tpoperacao" name="tpoperacao"           value="<? echo getByTagName($registro->tags,'tpoperacao') ?>" /></td>
                        <td> <? echo getByTagName($registro->tags,'dstpoperac') ?></td>
                        <td><? echo getByTagName($registro->tags,'dhalteracao') ?></td>
                        <td><? echo getByTagName($registro->tags,'nmoperad') ?></td>
                    </tr>
                <? } ?>			
            </tbody>
        </table>
    </div>
  
</form>
