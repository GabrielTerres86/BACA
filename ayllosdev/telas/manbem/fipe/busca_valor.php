<? 
/*!
 * FONTE            : busca_valor.php
 * CRIA��O        	: Maykon D. Granemann / ENVOLTI
 * DATA CRIA��O     : 14/08/2018
 * OBJETIVO         : 
 * --------------
 * ALTERA��ES     :
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

    /******************************************************* Chama Servi�o Fipe *****************************************************************/
    $idElementoHtml  	        = (isset($_POST['idelhtml'])) ? $_POST['idelhtml'] : 0  ;
    $idElementoHtml2            = "vlrdobem";
    $cdMarcaVeiculo		        = (isset($_POST['cdmarfip'])) ? $_POST['cdmarfip'] : 0  ; 
    $cdModeloVeiculo	        = (isset($_POST['cdmodfip'])) ? $_POST['cdmodfip'] : 0  ; 
    $cdMarcaModeloAnoVeiculo    = (isset($_POST['cdanofip'])) ? $_POST['cdanofip'] : 0  ; 
	$cdCooperGlb				= (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 1 ;
    
	$cdMarcaModeloAnoVeiculo	= ($cdMarcaModeloAnoVeiculo <> 3200) ? $cdMarcaModeloAnoVeiculo : 32000 ; //diferente de ZERO KM, passamos vazio

    $urlServicoOperacao = $Url_SOA."/osb-soa/ListaDominioRestService/v1/ObterListaTabelasFipe";
    $data = '{
        "tabelaFIPE": {
            "marcaVeiculo": {
                "codigo": '.$cdMarcaVeiculo.'
            },
            "modeloVeiculo": {
                "codigo": '.$cdModeloVeiculo.'
            },
            "marcaModeloAnoVeiculo": {
                "sigla": "'.$cdMarcaModeloAnoVeiculo.'"
            }
        },
		"cooperativa": {
			"codigo": "'.$cdCooperGlb.'"
        }
    }';
    $arrayHeader = array("Content-Type:application/json","Accept-Charset:application/json","Authorization:".$Auth_SOA);
    $xmlReturn = ChamaServico($urlServicoOperacao, "POST", $arrayHeader, $data);
    /**************************************************** Fim Chamada Servi�o Fipe ****************************************************************/

    /*************************************************** Tratamento dados retornados **************************************************************/
    $nameTagItemValue = 'valorVeiculo'; 
    $valueTag = XmlToValue($xmlReturn, $nameTagItemValue);
    echo "$('#".$idElementoHtml."').val(".$valueTag.");";
    echo "$('#".$idElementoHtml2."').val(".$valueTag.");";
    echo "$('#".$idElementoHtml."').maskMoney();";
    echo "$('#".$idElementoHtml2."').maskMoney();";
    echo "$('#".$idElementoHtml."').val($('#".$idElementoHtml."').val()).trigger('mask.maskMoney');";
	echo "$('#".$idElementoHtml2."').val($('#".$idElementoHtml2."').val()).trigger('mask.maskMoney');";
    
    echo "$('#".$idElementoHtml."').prop('disabled', true);";
    /************************************************** Fim Tratamento dados retornados *************************************************************/
?>