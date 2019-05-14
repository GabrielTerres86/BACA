<?php
/**
 * @author Bruno Luiz Katzjarowki - Mout's
 * @date 07/03/2019
 * Classe de autorização do usuário no sistema
 * Bruxarias happens here
 * Class Auth
 */
class Auth {
    const KEY = 'macaco pula de galho em galho';
    const ALGO = 'tiger128,4';
    const DATA = 'nao pula nao';

    /* PARAMETROS OBRIGATORIOS NA CHAMADA DA TELA UNICA */
    private $arrParametrosRequeridos = Array(
        "cdcooper",    //Código da Cooperativa - Viacredi: 1 - Ailos: 3
        "cdagenci",    //Codigo da Agência - PA Trabalho
        "cdoperad",    //Código do Operador
        "nrcpfcgc",    //Número CPF ou CNPJ do Cooperado
        'nrdconta',    //Número da conta
        'tpproduto',    //Tipo do Produto
        'nrproposta',  //Número da proposta
        'dstoken'      //Token Ibratan do usuario que estiver logando
    );

    private $get = Array();
    private $configCore = Array();
    private $retornoValidacao = ""; //Retorna string Json

    //http://localhost/public/?cdcooper=1&cdagenci=1&cdoperad=1&nrcpfcgc=08085085984&dstoken=teste&nrdconta=xx&tpprodut=xx&nrproposta=xx&dstoken=xx
    //keyGerada: 76a9979b9d44305840f34f1c9b4dc96c

    function __construct($get = Array(), $configCore = Array()) {
        //Setar configurações do sistema
        $this->setConfigCore($configCore);

        //Validar se usuario tem acesso ao sistema.
        if(!$this->authenticationUser($get) && $configCore['localhost']){
            echo "Usuário não possui acesso";
            exit();
        }else{
            // inicializa session
            session_start();
            $_SESSION['configCore'] = $configCore;
        }
    }


    /**
     * Valida entrada do usuário
     * @param array $get
     * @return bool
     */
    private function authenticationUser($get){
        if(count($get) === 0 || !$this->validaGet($get)){
            return false;
        }else{
            //$key = hash_hmac(self::ALGO,self::DATA,self::KEY);
            $this->setGet($get);
            return $this->validarUsuario($get);
        }
    }

    public function validaGet($get){
        foreach($this->arrParametrosRequeridos as $key){
            if(!key_exists($key,$get))
                return false;
        }
        return true;
    }


    /**
     * Realizar a chamada para validação de usuário
     * @param $get
     * @return bool
     */
    private function validarUsuario($get){
        if($this->configCore['localhost']){
            $chamadas = new Chamadas($this->getConfigCore(),$get);
            $chamadas->setTipoChamada(Chamadas::TIPO_CHAMADA_AUTENTICA_USUARIO);
        }else{
            //Se não for localhost validar usuario usando o arquivo chamada.php ---> AUTH EM public/index.php;
            return true;
        }

        $this->setRetornoValidacao($chamadas->webApiCall());
        $retornoApi = json_decode($this->getRetornoValidacao());
        if(isset($retornoApi->error)){
            echo $retornoApi->error."<br>";
            exit();
        }else{
            if(is_null($retornoApi) || $retornoApi === ''){
                $errorLog = 'Chamada: '.$chamadas->getTipoChamada();
                echo 'Não foi possível concluir a requisição - '.$errorLog.'<br>';
                exit();
            }
        }
        return true;
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
     * @return string
     */
    public function getRetornoValidacao()
    {
        return $this->retornoValidacao;
    }

    /**
     * @param string $retornoValidacao
     */
    public function setRetornoValidacao($retornoValidacao)
    {
        $this->retornoValidacao = $retornoValidacao;
    }
}