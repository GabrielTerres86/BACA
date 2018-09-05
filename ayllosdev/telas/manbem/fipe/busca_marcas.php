<? 
/*!
 * FONTE            : busca_marcas.php
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

    /******************************************************* Chama Serviço Fipe *****************************************************************/
    $idElementoHtml  	= (isset($_POST['idelhtml'])) ? $_POST['idelhtml'] : 0  ;
    $cdTipoVeiculo		= (isset($_POST['tipveicu'])) ? $_POST['tipveicu'] : 0  ;    

    $urlServicoOperacao = $UrlFipe."ObterListaMarcasFipe";
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
    $arrayHeader = array("Content-Type:application/json","Accept-Charset:application/json","Authorization:".$AuthFipe);    
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
                text: '".utf8_decode($comboItem->text)."'
              }));";
    }
    /************************************************** Fim Tratamento dados retornados *************************************************************/
?>