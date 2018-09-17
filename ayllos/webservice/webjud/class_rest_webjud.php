<?php
/*
 * Classe Responsavel da requisicao REST da /webjud
 *
 * @autor: Guilherme/SUPERO
 */
require_once('../class/class_rest_server_json.php');
class RestWebjud extends RestServerJson{

    private $aParamsRequired;

    public function __construct(){
        $this->aParamsRequired = array('nrdocnpj','nrcpfcnpj','inpessoa');
    }

    public function __destruct(){
        unset($this->aParamsRequired);
    }

    // Classe sobrescrita
    protected function getDados() {
        return (object) $_GET;
    }

    /**
     * Método responsavel por enviar a mensagem de resposta a requisicao
     * @param String $status
     * @param String $mensagemDetalhe
     * @param String $numeroTransacao
     * @param String $cdcritic
     * @param String $dscritic
     * @return boolean
     */

    private function enviaRetornoSucesso($aRetorno){
        //echo '</br>enviaRetornoSucesso';
        $status = $aRetorno->status;

        // Setando o codigo do status no Header da resposta
        header("Cache-Control: no-cache, must-revalidate");
        header("Expires: 0");
        header('Content-Type: ' . RestFormat::$aRestFormat[$this->getTypeFormato()]);
        header('Status-Code: '.$status, true, intval($status));

        return $this->processaRetornoFormato((array) $aRetorno);
    }
    private function enviaRetornoErro($status, $dscritic, $nrcpfcgc,$inpessoa){

        $aRetorno = array();
        $aRetorno['status']      = $status;
        //$aRetorno['dscritic']    = $dscritic;// Critic era apenas para testes

        $aRetorno['Cooperado']['nrCpfCnpj']   = $nrcpfcgc;
        $aRetorno['Cooperado']['InPessoa']    = $inpessoa;
        $aRetorno['Cooperado']['flCooperado'] = 'N';


        // Setando o codigo do status no Header da resposta
        header("Cache-Control: no-cache, must-revalidate");
        header("Expires: 0");
        header('Content-Type: ' . RestFormat::$aRestFormat[$this->getTypeFormato()]);
        header('Status-Code: '.$status, true, intval($status));


        //echo '</br>enviaRetornoErro';
        // Enviando a resposta para o servico
        return $this->processaRetornoFormato($aRetorno);
        return true;
    }

    private function processaRetorno($status, $mensagemDetalhe, $numeroTransacao = '00000000000000000000', $cdcritic = '0', $dscritic = ''){
        //echo '</br>processaRetorno: ' . $this->getTypeFormato();

        $aRetorno = array();
        $aRetorno['status']      = $status;
        $aRetorno['dscritic']    = $mensagemDetalhe;

        $aRetorno['Cooperado']['nrcpfcnpj']   = $numeroTransacao;
        $aRetorno['Cooperado']['inpessoa']    = 'F';
        $aRetorno['Cooperado']['flcooperado'] = 'N';

        // Setando o codigo do status no Header da resposta
        header("Cache-Control: no-cache, must-revalidate");
        header("Expires: 0");
        header('Content-Type: ' . RestFormat::$aRestFormat[$this->getTypeFormato()]);
        header('Status-Code: '.$status, true, intval($status));


        // Enviando a resposta para o servico
        return $this->processaRetornoFormato($aRetorno);
        //return true;
    }

    /**
     * M�todo responsavel por enviar a mensagem de Exception
     * @param String Status
     * @param String Mensagem de detalhe
     * @return boolean
     */
    private function processaRetornoErro($status, $mensagemDetalhe){
        //echo '</br>processaRetornoErro';
        return $this->processaRetorno((string) $status,(string) $mensagemDetalhe);
    }

    /**
     * M�todo responsavel por enviar de sucesso
     * @param String $status
     * @param String $mensagemDetalhe
     * @param String $numeroTransacao
     * @param String $cdcritic
     * @param String $dscritic
     * @return boolean
     */
    private function processaRetornoSucesso($status,$mensagemDetalhe,$numeroTransacao,$cdcritic,$dscritic){
        //echo '</br>processaRetornoSucesso';
        return $this->processaRetorno((string) $status,(string) $mensagemDetalhe,(string) $numeroTransacao,(string) $cdcritic,(string) $dscritic);
    }

    /**
     * Valida se todos os parametros recebidos est�o corretos
     * @param Object $oDados
     * @return boolean
     */
    private function validaParametrosRecebidos($oDados){
        // Condicao para verificar se eh um objeto
        if (!is_object($oDados)){
            $this->processaRetornoErro(412,'Consulta nao foi efetuada, parametros incorretos.');
            return false;
        }

        // Verifica se todos os parametros foram recebidos
        foreach ($this->aParamsRequired as $sPametro){
            if (!isset($oDados->$sPametro)){
                $this->processaRetornoErro(412,'Consulta nao foi efetuada, parametros incorretos.');
                return false;
            }
        }
        return true;
    }



    public function processaMensagem(){
        try{
            //echo '</br>processaMensagem';
            $this->setMetodoRequisitado('GET');

            $this->processaRetornoSucesso(999,
                                          'Autenticacao invalida!',
                                          '031032033-34',
                                          0,
                                          '');
            return true;

        } catch(RestException $oException){
            $this->processaRetornoErro($oException->getCode(), $oException->getMessage());
            return false;
        } catch (Exception $oException){
            $this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.');
            return false;
        }
    }
    public function processaMensagemReverso($conteudo){
        try{
            //echo '</br>processaMensagemReverso';
            //$this->setMetodoRequisitado('GET');


            print_r(json_decode($conteudo,true));

            return true;

        } catch(RestException $oException){
            $this->processaRetornoErro($oException->getCode(), $oException->getMessage());
            return false;
        } catch (Exception $oException){
            $this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.');
            return false;
        }
    }

    /**
     * Processa os dados da Requisicao
     */
    public function processaRequisicao(){
        try{

            $this->setMetodoRequisitado('GET');

            // Valida os dados da requisicao
            if (!$this->validaRequisicao()){
                return false;
            }

            // Busca os dados da requisicao
            $oDados = $this->getDados();

            // Valida se veio todos os parametros obrigatorios
            if (!$this->validaParametrosRecebidos($oDados)){
                return false;
            }
            
            
            switch ($oDados->servico) {
                
                case 1: // WEBJUD - Consulta Cooperado
                        // Processa a informacao do banco de dados
                        $xml  = "<Root>";
                        $xml .= " <Dados>";
                        $xml .= "   <usuario>" .$this->getUsuario()."</usuario>";
                        $xml .= "   <senha>"   .$this->getSenha()."</senha>";
                        $xml .= "   <nrdocnpj>".$oDados->nrdocnpj."</nrdocnpj>";
                        $xml .= "   <nrcpfcgc>".$oDados->nrcpfcnpj."</nrcpfcgc>";
                        $xml .= "   <inpessoa>".$oDados->inpessoa."</inpessoa>";
                        $xml .= " </Dados>";
                        $xml .= "</Root>";
                        $sXmlResult = mensageria($xml, "WEBS0002", "WEBS0002_VERIFICA_COOPERADO", 0, 0, 0, 5, 0, "</Root>");

                        $oRetorno   = simplexml_load_string($sXmlResult);

                        // Vamos verificar se veio retorno
                        if ((!isset($oRetorno->status)) || ($oRetorno->status == 0) || ($oRetorno->status == '')){
                            $this->enviaRetornoErro(500,'Ocorreu um erro interno no sistema.',$oDados->nrcpfcnpj,$oDados->inpessoa);
                            return false;
                        }

                        // Retorna a resposta para o servico
                        $this->enviaRetornoSucesso($oRetorno);
                        break; //Fim CASE 1

                default: $this->enviaRetornoErro(500,'Ocorreu um erro interno no sistema.(Cod.Srv.:'.$oDados->servico .')',0,0);
                         return false;
                        
            }


        } catch(RestException $oException){
            $this->enviaRetornoErro($oException->getCode(), $oException->getMessage(),$oDados->nrcpfcnpj,$oDados->inpessoa);
            return false;
        } catch (Exception $oException){
            $this->enviaRetornoErro(500,'Ocorreu um erro interno no sistema.',$oDados->nrcpfcnpj,$oDados->inpessoa);
            return false;
        }
        return true;
    }
}
?>