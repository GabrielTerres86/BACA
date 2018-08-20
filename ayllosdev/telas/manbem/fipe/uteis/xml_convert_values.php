<?php
    require_once('class_combo.php');

    function XmlToList($xmlReturn, $nameTagList, $nameTagItem, $nameTagItemValue, $nameTagItemText)
    {
        $comboSelecione = new Combo();
        $comboSelecione->value=-1;
        $comboSelecione->text="Selecione ";
        $arrayCombo = array($comboSelecione);

        $dom = new DOMDocument('1.0', 'iso-8859-1');
        $dom->loadXML($xmlReturn);
        $elementsList = $dom->getElementsByTagName($nameTagList);
        foreach ($elementsList as $elementItem) 
        {
            $nodeList = $elementItem->getElementsByTagName($nameTagItem);
            $codigo = $nodeList->item(0)->getElementsByTagName($nameTagItemValue);
            $descricao = $nodeList->item(0)->getElementsByTagName($nameTagItemText);
            $comboItem = new Combo();
            $comboItem->value=$codigo->item(0)->nodeValue;
            $comboItem->text=$descricao->item(0)->nodeValue;
            array_push($arrayCombo, $comboItem);
        }
        return $arrayCombo;
    }

    function XmlToValue($xmlReturn, $nameTagItemValue)
    {
        $dom = new DOMDocument('1.0', 'iso-8859-1');
        $dom->loadXML($xmlReturn);
        $valueTag = $dom->getElementsByTagName($nameTagItemValue);
        
        return $valueTag->item(0)->nodeValue;
    }
?>