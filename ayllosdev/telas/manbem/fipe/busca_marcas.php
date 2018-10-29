<? 
/*!
 * FONTE            : busca_marcas.php
 * CRIAÇÃO        : Maykon D. Granemann / ENVOLTI
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
    require_once('../includes/utils.php');
	isPostMethod();
	
	$aux = "";

    /******************************************************* Chama Serviço Fipe *****************************************************************/
    $idElementoHtml  	= (isset($_POST['idelhtml'])) ? $_POST['idelhtml'] : 0  ;
    $cdTipoVeiculo		= (isset($_POST['tipveicu'])) ? $_POST['tipveicu'] : 0  ;
	$dsmarbem			= (isset($_POST['dsmarbem'])) ? $_POST['dsmarbem'] : 0  ;
	$dsbemfin			= (isset($_POST['dsbemfin'])) ? utf8_decode($_POST['dsbemfin']) : 0  ;
	$nrmodbem			= (isset($_POST['nrmodbem'])) ? utf8_decode($_POST['nrmodbem']) : 0  ;

    $urlServicoOperacao = $Url_SOA."/osb-soa/ListaDominioRestService/v1/ObterListaMarcasFipe";
    $data = '{
        "tabelaFIPE": {
            "tipoVeiculo": {
                "codigo":'.$cdTipoVeiculo.'
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
    $nameTagList = 'marca';
    $nameTagItem = 'marcaVeiculo';
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

		if (removeAcentos(removeCaracteresInvalidos(utf8_decode(mb_strtoupper($comboItem->text, 'UTF-8')))) == utf8_decode(strtoupper($dsmarbem))) {
			$aux = "$('#".$idElementoHtml." option').filter(function() { return $.trim( $(this).text() ) == '" . removeAcentos(removeCaracteresInvalidos(utf8_decode(mb_strtoupper($comboItem->text, 'UTF-8')))) . "'; }).attr('selected', 'selected');
						urlPagina= \"telas/manbem/fipe/busca_modelos.php\";
						cdMarcaFipe = ".$comboItem->value.";
						data = jQuery.param({ idelhtml:idElementModelo, cdmarfip: cdMarcaFipe , redirect: 'script_ajax', dsbemfin: '$dsbemfin', nrmodbem: '$nrmodbem' });
						buscaFipeServico(urlPagina,data);
			";
		}
    }
	echo $aux;
    /************************************************** Fim Tratamento dados retornados *************************************************************/
?>