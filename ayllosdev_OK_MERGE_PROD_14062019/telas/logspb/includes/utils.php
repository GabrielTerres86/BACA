<?
/*
Autor: Bruno Luiz Katzjarowski;
Data: 12/11/2018
Ultima alteração:

Alterações:
*/

function xmlToArray($xml, $options = array()) {
    $defaults = array(
        'namespaceSeparator' => ':',//you may want this to be something other than a colon
        'attributePrefix' => '@',   //to distinguish between attributes and nodes with the same name
        'alwaysArray' => array(),   //array of xml tag names which should always become arrays
        'autoArray' => true,        //only create arrays for tags which appear more than once
        'textContent' => '$',       //key used for the text content of elements
        'autoText' => true,         //skip textContent key if node has no attributes or child nodes
        'keySearch' => false,       //optional search and replace on tag and attribute names
        'keyReplace' => false       //replace values for above search values (as passed to str_replace())
    );
    $options = array_merge($defaults, $options);
    $namespaces = $xml->getDocNamespaces();
    $namespaces[''] = null; //add base (empty) namespace
 
    //get attributes from all namespaces
    $attributesArray = array();
    foreach ($namespaces as $prefix => $namespace) {
        foreach ($xml->attributes($namespace) as $attributeName => $attribute) {
            //replace characters in attribute name
            if ($options['keySearch']) $attributeName =
                    str_replace($options['keySearch'], $options['keyReplace'], $attributeName);
            $attributeKey = $options['attributePrefix']
                    . ($prefix ? $prefix . $options['namespaceSeparator'] : '')
                    . $attributeName;
            $attributesArray[$attributeKey] = (string)$attribute;
        }
    }
 
    //get child nodes from all namespaces
    $tagsArray = array();
    foreach ($namespaces as $prefix => $namespace) {
        foreach ($xml->children($namespace) as $childXml) {
            //recurse into child nodes
            $childArray = xmlToArray($childXml, $options);
            list($childTagName, $childProperties) = each($childArray);
 
            //replace characters in tag name
            if ($options['keySearch']) $childTagName =
                    str_replace($options['keySearch'], $options['keyReplace'], $childTagName);
            //add namespace prefix, if any
            if ($prefix) $childTagName = $prefix . $options['namespaceSeparator'] . $childTagName;
 
            if (!isset($tagsArray[$childTagName])) {
                //only entry with this key
                //test if tags of this type should always be arrays, no matter the element count
                $tagsArray[$childTagName] =
                        in_array($childTagName, $options['alwaysArray']) || !$options['autoArray']
                        ? array($childProperties) : $childProperties;
            } elseif (
                is_array($tagsArray[$childTagName]) && array_keys($tagsArray[$childTagName])
                === range(0, count($tagsArray[$childTagName]) - 1)
            ) {
                //key already exists and is integer indexed array
                $tagsArray[$childTagName][] = $childProperties;
            } else {
                //key exists so convert to integer indexed array with previous value in position 0
                $tagsArray[$childTagName] = array($tagsArray[$childTagName], $childProperties);
            }
        }
    }
 
    //get text content of node
    $textContentArray = array();
    $plainText = trim((string)$xml);
    if ($plainText !== '') $textContentArray[$options['textContent']] = $plainText;
 
    //stick it all together
    $propertiesArray = !$options['autoText'] || $attributesArray || $tagsArray || ($plainText === '')
            ? array_merge($attributesArray, $tagsArray, $textContentArray) : $plainText;
 
    //return node as array
    return array(
        $xml->getName() => $propertiesArray
    );
}


function getColunas($tipo, $cddopcao){
    $colunasTabelaPrincipal = Array(
        "colunas" => null,
        "keys" => null,
    );
    /* colunas no caso de tipo ser 'T' */

    if($cddopcao == "C"){
        switch($tipo){
            case 'E':
            case 'T':
                $colunasTabelaPrincipal["colunas"] = Array(
                    "Data", //datamsg
                    'Hora', //horamsg
                    "Mensagem", //dsmensagem
                    "Num. Controle", //numcontrole
                    "Valor", //valor
                    "Situação", //situacao
                    "Banco Remet", //bancoremet
                    "Agência Remet", //agenciaremet
                    "Conta Remet", //contaremet
                    "Nome Remet", //nomeremet
                    "CPF/CNPJ Remet", //cpfcnpjremet
                    "Banco Dest", //bancodest
                    "Agência Dest", //agenciadest
                    "Conta Dest", //contadest
                    "Nome Dest", //nomedest
                    "CPF/CNPJ Dest", //cpfcnpjdest
                    "Caixa", //caixa
                    "Origem", //origem
                    "Operador", //operador
                    "Crise", //crise
                    "Cooperativa", //cooperativa
                );
                $colunasTabelaPrincipal["keys"] = Array(
                        "datamsg","horamsg", "dsmensagem", "numcontrole", "valor", "situacao", "bancoremet", "agenciaremet", "contaremet",
                        "nomeremet", "cpfcnpjremet", "bancodest", "agenciadest", "contadest", "nomedest",
                        "cpfcnpjdest", "caixa", "origem", "operador", "crise", "cooperativa"
                );
            break;
            case 'R':
                $colunasTabelaPrincipal["colunas"] = Array(
                    "Data", //datamsg
                    'Hora', //horamsg
                    "Mensagem", //dsmensagem
                    "Num. Controle", //numcontrole
                    "Valor", //valor
                    "Situação", //situacao
                    "Banco Remet", //bancoremet
                    "Agência Remet", //agenciaremet
                    "Conta Remet", //contaremet
                    "Nome Remet", //nomeremet
                    "CPF/CNPJ Remet", //cpfcnpjremet
                    "Banco Dest", //bancodest
                    "Agência Dest", //agenciadest
                    "Conta Dest", //contadest
                    "Nome Dest", //nomedest
                    "CPF/CNPJ Dest", //cpfcnpjdest
                    "Crise", //crise
                    "Cooperativa", //cooperativa
                );
                $colunasTabelaPrincipal["keys"] = Array(
                        "datamsg","horamsg", "dsmensagem", "numcontrole", "valor", "situacao", "bancoremet", "agenciaremet", "contaremet",
                        "nomeremet", "cpfcnpjremet", "bancodest", "agenciadest", "contadest", "nomedest",
                        "cpfcnpjdest", "crise", "cooperativa"
                );
            break;
        };
    }else if($cddopcao == 'S'){
        $colunasTabelaPrincipal["colunas"] = Array(
            "Data", //dhtransa
			"Hora", //hrtransa
			"Mensagem", //vltransa
			"Num. Controle", //numcontrole
			"Valor", //valor
			//"Situa&ccedil;&atilde;o", //situacao
			"Banco Remet.", //cdbanren
			"ISPB Remet.", //cdispbren
			"Ag&ecirc;ncia Remet.", //agenciaremet
			"Conta Remet.", //contaremet
			"Nome Remet.", //dsnomrem
			"CPF/CNPJ Remet.", //dscpfrem
			"Banco Dest.", //cdbandst
			"ISPB Dest.", //cdispbdst
			"Ag&ecirc;ncia Dest.", //cdagedst
			"Conta Dest.", //nrctadst
			"Nome Dest.", //dsnomdst
			"CPF/CNPJ Dest.", //dscpfdst
			"Caixa",
			"JDSPB" //dstransa
        );

        $colunasTabelaPrincipal["keys"] = Array(
            "dhtransa", "hrtransa","nmevento", "nrctrlif", "vltransa", //"situacao", 
            "cdbanren", "cdispbren","cdagerem", "nrctarem",
            "dsnomrem", "dscpfrem", "cdbandst", "cdispbdst","cdagedst", "nrctadst",
            "dsnomdst", "dscpfdst", "caixa", "dstransa"//"crise", "cooperativa"
        );
    }else if($cddopcao == "M"){
        $colunasTabelaPrincipal["colunas"] = Array(
                    "Data", //datamsg
                    'Hora', //horamsg
                    "Mensagem", //dsmensagem
                    "Num. Controle", //numcontrole
                    "Valor", //valor
                    "Situação", //situacao
                    "Banco Remet", //bancoremet
                    "Agência Remet", //agenciaremet
                    "Conta Remet", //contaremet
                    "Nome Remet", //nomeremet
                    "CPF/CNPJ Remet", //cpfcnpjremet
                    "Banco Dest", //bancodest
                    "Agência Dest", //agenciadest
                    "Conta Dest", //contadest
                    "Nome Dest", //nomedest
                    "CPF/CNPJ Dest", //cpfcnpjdest
                    "Crise", //crise
                    "Cooperativa", //cooperativa
                    "Coop Migrada", //coopmigrada
                    "Conta Migrada", //nrcontamigrada
                );

        $colunasTabelaPrincipal["keys"] = Array(
                "datamsg","horamsg", "dsmensagem", "numcontrole", "valor", "situacao", "bancoremet", "agenciaremet", "contaremet",
                "nomeremet", "cpfcnpjremet", "bancodest", "agenciadest", "contadest", "nomedest",
                "cpfcnpjdest", "crise", "cooperativa", "coopmigrada", "nrcontamigrada"
        );
    }

    return $colunasTabelaPrincipal;
}
?>