<? 
/*!
 * FONTE            : busca_anos.php
 * CRIAÃ‡ÃƒO        : Maykon D. Granemann / ENVOLTI
 * DATA CRIAÇÃO     : 14/08/2018
 * OBJETIVO         : 
 * --------------
 * ALTERAÇÕES     :
 * --------------
 */
?> 
<?php
    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	
    require_once('../../../class/xmlfile.php');
    require_once('uteis/chama_servico.php');
    require_once('uteis/class_combo.php');
    require_once('uteis/xml_convert_values.php');
	isPostMethod();
	
	$aux = "";

    /******************************************************* Chama Serviço Fipe *****************************************************************/
    $idElementoHtml  	= (isset($_POST['idelhtml'])) ? $_POST['idelhtml'] : 0  ;
    $cdMarcaVeiculo		= (isset($_POST['cdmarfip'])) ? $_POST['cdmarfip'] : 0  ; 
    $cdModeloVeiculo	= (isset($_POST['cdmodfip'])) ? $_POST['cdmodfip'] : 0  ;
    $nrmodbem			= (isset($_POST['nrmodbem'])) ? $_POST['nrmodbem'] : 0  ;

    $urlServicoOperacao = $Url_SOA."/osb-soa/ListaDominioRestService/v1/ObterListaMarcaModeloAnosFipe";
    $data = '{
        "tabelaFIPE": {
            "marcaVeiculo": {
                "codigo": '.$cdMarcaVeiculo.'
            },
            "modeloVeiculo": {
                "codigo": '.$cdModeloVeiculo.'
            }
        },
        "paginacao": {
            "pagina": 1,
            "registrosPorPagina": 100
        }
    }';
    $arrayHeader = array("Content-Type:application/json","Accept-Charset:application/json","Authorization:".$Auth_SOA);
    $xmlReturn = ChamaServico($urlServicoOperacao, "POST", $arrayHeader, $data);
    /**************************************************** Fim Chamada Serviço Fipe ****************************************************************/

    /*************************************************** Tratamento dados retornados **************************************************************/
    $nameTagList = 'modeloAno';
    $nameTagItem = 'marcaModeloAnoVeiculo';
    $nameTagItemValue = 'codigo';
    $nameTagItemText = 'descricao';
    $arrayCombo = XmlToList($xmlReturn, $nameTagList, $nameTagItem, $nameTagItemValue, $nameTagItemText);

    foreach($arrayCombo as $comboItem)
    {
        echo  "$('#".$idElementoHtml."').append($('<option>', 
        {
          value: ".$comboItem->value.",
          text: '".utf8_decode(strtoupper($comboItem->text))."'
        }));";

		if (utf8_decode(strtoupper($comboItem->text)) == utf8_decode(strtoupper($nrmodbem))) {
			$aux = "$('#".$idElementoHtml." option').filter(function() { return $.trim( $(this).text() ) == '" . utf8_decode(strtoupper($comboItem->text)) . "'; }).attr('selected', 'selected');";
		}
    }
	echo $aux;
	echo "verificarTipoVeiculo();";
    /************************************************** Fim Tratamento dados retornados *************************************************************/
?>