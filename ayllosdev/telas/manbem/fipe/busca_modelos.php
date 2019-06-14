<? 
/*!
 * FONTE            : busca_modelos.php
 * CRIAÇÃO          : Maykon D. Granemann / ENVOLTI
 * DATA CRIAÇÃO     : 14/08/2018
 * OBJETIVO         : 
 * --------------
 * ALTERAÇÕES   :
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
    require_once('../includes/utils.php');
    isPostMethod();

	$aux = "";

    /******************************************************* Chama Servi�o Fipe *****************************************************************/
    $idElementoHtml  	= (isset($_POST['idelhtml'])) ? $_POST['idelhtml'] : 0  ;
    $cdTipoVeiculo		= (isset($_POST['tipveicu'])) ? $_POST['tipveicu'] : 0  ;
    $cdMarcaVeiculo		= (isset($_POST['cdmarfip'])) ? $_POST['cdmarfip'] : 0  ; 
	$dsbemfin			= (isset($_POST['dsbemfin'])) ? $_POST['dsbemfin'] : 0  ;
	$nrmodbem			= (isset($_POST['nrmodbem'])) ? $_POST['nrmodbem'] : 0  ;
    $urlServicoOperacao = $Url_SOA."/osb-soa/ListaDominioRestService/v1/ObterListaMarcaModelosFipe";
    $data = '{
        "tabelaFIPE": {
            "marcaVeiculo": {
                "codigo":'.$cdMarcaVeiculo.'
            },
            "tipoVeiculo": {
                "codigo":'.$cdTipoVeiculo.'
            }
        },
        "paginacao": {
            "posicaoPrimeiroRegistro": 0,
            "registrosPorPagina": 1000
        }
    }';

    $arrayHeader = array("Content-Type:application/json","Accept-Charset:application/json","Authorization:".$Auth_SOA);
    $xmlReturn = ChamaServico($urlServicoOperacao, "POST", $arrayHeader, $data);
    /**************************************************** Fim Chamada Serviço Fipe ****************************************************************/

    /*************************************************** Tratamento dados retornados **************************************************************/
    $nameTagList = 'modelo';
    $nameTagItem = 'modeloVeiculo';
    $nameTagItemValue = 'codigo';
    $nameTagItemText = 'descricao';
    $arrayCombo = XmlToList($xmlReturn, $nameTagList, $nameTagItem, $nameTagItemValue, $nameTagItemText);

    foreach($arrayCombo as $comboItem)
    {
        echo "$('#".$idElementoHtml."').append($('<option>', 
        {
          value: ".$comboItem->value.",
          text: '".removeAcentos(removeCaracteresInvalidos(utf8_decode(mb_strtoupper($comboItem->text, 'UTF-8'))))."'
        }));";

		if (removeAcentos(removeCaracteresInvalidos(utf8_decode(mb_strtoupper($comboItem->text, 'UTF-8')))) == utf8_decode(mb_strtoupper($dsbemfin, 'UTF-8'))) {
			$aux = "$('#".$idElementoHtml." option').filter(function() { return $.trim( $(this).text() ) == '" . removeAcentos(removeCaracteresInvalidos(utf8_decode(mb_strtoupper($comboItem->text, 'UTF-8')))) . "'; }).attr('selected', 'selected');
				urlPagina= \"telas/manbem/fipe/busca_anos.php\";
				cdMarcaFipe = $('#'+idElementMarca).val();
				cdModeloFipe = ".$comboItem->value.";
				data = jQuery.param({ idelhtml:idElementAno, cdmarfip: cdMarcaFipe , cdmodfip: cdModeloFipe, redirect: 'script_ajax', nrmodbem: '$nrmodbem' });
				buscaFipeServico(urlPagina,data);";
		}
    }
	echo $aux;
    /************************************************** Fim Tratamento dados retornados *************************************************************/
?>