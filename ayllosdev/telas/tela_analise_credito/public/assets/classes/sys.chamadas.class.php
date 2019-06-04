<?php
/**
 * User: Bruno Luiz Katjarowski
 * Date: 05/03/2019
 * Time: 13:22
 * Projeto: ailos_prj438_s8
 */
class Chamadas{ 

    /* URLS DE WEBSERVICE */
    const URL_WEBSERVICE_DEV2 = 'http://ayllosdev2.cecred.coop.br/telas/tela_analise_credito/public/chamadas/chamadas.php';

    /* TIPOS DE CHAMADA */
    const TIPO_CHAMADA_AUTENTICA_USUARIO = 'ATENTICA_USUARIO';
    const TIPO_CHAMADA_GET_XML = 'GET_XML';

    /* CONSTANTES */
    const IDORIGEM_CRM = '999';

    private $configCore = array();
    private $get = array();
    private $tipoChamada = "";
    private $debug = false;
    private $glbvars = null;

    public function __construct($configCore, $get = null){
        $this->setConfigCore($configCore);
        if(!is_null($get)){
            $this->setGet($get);
        }
    }

    /**
     * @param $get array Array contendo os valores de chamada
     * @return bool|string
     */
    public function webApiCall(){
        $url = self::URL_WEBSERVICE_DEV2;

        if($this->getTipoChamada() != ""){
            $this->get['tipoChamada'] = $this->getTipoChamada();
        }
        if(!is_null($this->glbvars)) {
            $this->get['glbvars'] = $this->glbvars;
        }
        if(isset($_SESSION['configCore'])){
            $this->get['configCore'] = $_SESSION['configCore'];
        }
        if(count($this->configCore) > 0){
            $this->get['configCore'] = $this->configCore;
        }

        $data = $this->getGet();

        // use key 'http' even if you send the request to https://...
        $options = array(
            'http' => array(
                'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
                'method'  => 'POST',
                'content' => http_build_query($data)
            )
        );
        $context  = stream_context_create($options);
        $result = file_get_contents($url, false, $context);

        if($this->configCore['debugMensageria']){
            echo " GLBVARS: RESULT: <br>";
            var_dump($this->glbvars);
            echo "<br> RETORNO CHAMADA: <br>";
            echo $this->getTipoChamada()." - RESULT: <br>";
            echo $result;
        }

        return $result;
    }

    /*--------------~~~~~~~~~~~~~~~~~~~~
     * GETTERS AND SETTERS
     * ---------------------------------*/

    /**
     * @return string
     */
    public function getTipoChamada()
    {
        return $this->tipoChamada;
    }

    /**
     * @param string $tipoChamada
     */
    public function setTipoChamada($tipoChamada)
    {
        $this->tipoChamada = $tipoChamada;
    }

    /**
     * @return array
     */
    public function getGet()
    {
        return $this->get;
    }

    /**
     * @param array $get
     */
    public function setGet($get)
    {
        $this->get = $get;
    }

    /**
     * @return array
     */
    public function getConfigCore()
    {
        return $this->configCore;
    }

    /**
     * @param array $configCore
     */
    public function setConfigCore($configCore)
    {
        $this->configCore = $configCore;
    }

    /**
     * @return bool
     */
    public function isDebug()
    {
        return $this->debug;
    }

    /**
     * @param bool $debug
     */
    public function setDebug($debug)
    {
        $this->debug = $debug;
    }

    /**
     * @return null
     */
    public function getGlbvars()
    {
        return $this->glbvars;
    }

    /**
     * @param null $glbvars
     */
    public function setGlbvars($glbvars)
    {
        $this->glbvars = $glbvars;
    }
}