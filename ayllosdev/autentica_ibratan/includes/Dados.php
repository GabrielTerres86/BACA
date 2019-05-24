<?php
define("TIPO_ENTRADA_AUTENTICA",'homol_autentica');
define("TIPO_ENTRADA_NAO_AUTORIZADO",'NOK');

class Dados{

    

    public $cdcooper = "";
    public $cdagenci = "";
    public $cdoperad = "";
    public $nrcpfcgc = "";
    public $dstoken = "";
    public $nrdconta = "";
    public $tpproduto = "";
    public $nrproposta = "";
    public $tipoentrada = "";

    public function atribuiDados($post){

        foreach($post as $key => $value){
            if(isset($this->{$key}))
                $this->{$key} = $value;
        }

    }

    /**
     * @return string
     */
    public function getCdcooper()
    {
        return $this->cdcooper;
    }

    /**
     * @param string $cdcooper
     */
    public function setCdcooper($cdcooper)
    {
        $this->cdcooper = $cdcooper;
    }

    /**
     * @return string
     */
    public function getCdagenci()
    {
        return $this->cdagenci;
    }

    /**
     * @param string $cdagenci
     */
    public function setCdagenci($cdagenci)
    {
        $this->cdagenci = $cdagenci;
    }

    /**
     * @return string
     */
    public function getCdoperad()
    {
        return $this->cdoperad;
    }

    /**
     * @param string $cdoperad
     */
    public function setCdoperad($cdoperad)
    {
        $this->cdoperad = $cdoperad;
    }

    /**
     * @return string
     */
    public function getNrcpfcgc()
    {
        return $this->nrcpfcgc;
    }

    /**
     * @param string $nrcpfcgc
     */
    public function setNrcpfcgc($nrcpfcgc)
    {
        $this->nrcpfcgc = $nrcpfcgc;
    }

    /**
     * @return string
     */
    public function getDstoken()
    {
        return $this->dstoken;
    }

    /**
     * @param string $dstoken
     */
    public function setDstoken($dstoken)
    {
        $this->dstoken = $dstoken;
    }

    /**
     * @return string
     */
    public function getNrdconta()
    {
        return $this->nrdconta;
    }

    /**
     * @param string $nrdconta
     */
    public function setNrdconta($nrdconta)
    {
        $this->nrdconta = $nrdconta;
    }

    /**
     * @return string
     */
    public function getTpproduto()
    {
        return $this->tpproduto;
    }

    /**
     * @param string $tpproduto
     */
    public function setTpproduto($tpproduto)
    {
        $this->tpproduto = $tpproduto;
    }

    /**
     * @return string
     */
    public function getNrproposta()
    {
        return $this->nrproposta;
    }

    /**
     * @param string $nrproposta
     */
    public function setNrproposta($nrproposta)
    {
        $this->nrproposta = $nrproposta;
    }

    /**
     * @return string
     */
    public function getTipoEntrada()
    {
        return $this->tipoentrada;
    }

    /**
     * @param string $nrproposta
     */
    public function setTipoEntrada($tipoentrada)
    {
        $this->tipoentrada = $tipoentrada;
    }
 
    
    
}