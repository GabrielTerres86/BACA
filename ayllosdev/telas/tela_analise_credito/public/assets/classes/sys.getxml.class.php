<?php
/**
 * User: Bruno Luiz Katjarowski
 * Date: 15/03/2019
 * Time: 09:57
 * Projeto: ailos_prj438_s8
 */

class GetXml extends Chamadas {

    private $xml = "";

    public function __construct($configCore,$glbVars, $get = null)
    {
        $this->setTipoChamada(self::TIPO_CHAMADA_GET_XML);
        $this->setGet($configCore['getParameters']);
        $this->setGlbvars($glbVars);
        parent::__construct($configCore, $get);
    }

    public function retornaXml(){
        $configCore = $this->getConfigCore();
        if(!$configCore['localhost'])
            return ""; //Xml sendo carrego via chamadas.php no loading
        else{
            $this->setXml($this->webApiCall());
            return $this->getXml();
        }
    }


    /**
     * @return string
     */
    public function getXml()
    {
        return $this->xml;
    }

    /**
     * @param string $xml
     */
    public function setXml($xml)
    {
        $this->xml = $xml;
    }

}