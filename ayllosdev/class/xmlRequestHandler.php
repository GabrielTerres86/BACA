<?php

/**
 * class XMLRequestHandler
 * 
 * Classe para manipulação das requisições em formato XML para execução de rotinas do BD
 * 
 * @author   Reginaldo Rubens da Silva
 * @date     11/01/2018
 * @version  1.0
 */

class XMLRequestHandler
{
    private $xmlRequestString;
    private $xmlResultString;
    private $xmlObject;

    public function __construct($bo, $proc, $params = array(), $legacy = false)
    {
         $xmlRequestString = $this->mountXMLRequestString($bo, $proc, $params, $legacy);

         $this->xmlResultString = $this->getXMLResult($xmlRequestString, $bo, $proc, $legacy);
         $this->xmlObject = getObjectXML($this->xmlResultString);
    }

    public function getByTagName($tagName, $level)
    {
        $baseNode = $this->getTagObjectByLevel($level);

        foreach ($baseNode->tags as $tag) {
            if ($tag->name == $tagName) {
                return $tag->cdata;
            }
        }

        throw new Exception('Tag name does not exists.');
    }

    public function getByTagLevel($level)
    {
        $tag = $this->getTagObjectByLevel($level);

        return $tag->cdata;
    }

    public function getTagAtribute($attributeName, $level)
    {
        $tag = $this->getTagObjectByLevel($level);

        if (!isset($tag->{$attributeName})) {
            throw new Exception('Attribute name does not exists.');
        }

        return $tag->{$attributeName};
    }

    public function getTagObjectByLevel($level)
    {
        if (!is_array($level)) {
            $level = array($level);
        }

        $currentTag = $this->xmlObject->roottag;

        foreach ($level as $currentLevel) {
            if (!in_array($currentLevel, array_keys($currentTag->tags))) {
                throw new Exception('Requested level does not exists.');
            }

            $currentTag = $currentTag->tags[$currentLevel];
        }

        return $currentTag;
    }

    public function hasError()
    {
        return strtoupper($this->xmlObject->roottag->tags[0]->name) == "ERRO";
    }

    public function getError()
    {
        if (!$this->hasError()) {
            return '';
        }
        
        return $this->xmlObject->roottag->tags[0]->cdata;
    }

    private function mountXMLRequestString($bo, $proc, array $params, $legacy)
    {
        $this->xmlRequestString = '<Root>';

        if ($legacy) {
            $this->xmlRequestString .= '    <Cabecalho>';
            $this->xmlRequestString .= '        <Bo>' . $bo . '</Bo>';
            $this->xmlRequestString .= '        <Proc>' . $proc . '</Proc>';
            $this->xmlRequestString .= '    </Cabecalho>';
        }

        $this->xmlRequestString .= '    <Dados>';

        foreach ($params as $paramName => $paramValue) {
            $this->xmlRequestString .= '        <' . $paramName . '>' . $paramValue . '</' . $paramName . '>';
        }

        $this->xmlRequestString .= '    </Dados>';
        $this->xmlRequestString .= '</Root>';

        return $this->xmlRequestString;
    }

    public function getRequestString()
    {
        return $this->xmlRequestString;
    }

    private function getXmlResult($xmlRequestString, $bo, $proc, $legacy)
    {
        global $glbvars;
        
        if ($legacy) {
            return getDataXml($xmlRequestString);
        }

        return mensageria($xmlRequestString, $bo, $proc, $glbvars['cdcooper'], 
            $glbvars['cdagenci'], $glbvars['nrdcaixa'], $glbvars['idorigem'],
            $glbvars['cdoperad'], '</Root>');
    }

    public function __toString()
    {
        return $this->xmlResultString;
    }
}
