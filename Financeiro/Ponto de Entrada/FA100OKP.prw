#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} FA100OKP
O ponto de entrada FA100OKP sera utilizado para bloquear a inclusao de movimentos a pagar
 na rotina Movimentos bancarios. Caso o retorno seja verdadeiro o movimento é feito normalmente, 
 caso contrario não se fará a inclusão do movimento.
@type function
@version 
@author Elvis Siqueira
@since 03/12/2021
@return Retorno lógico
/*/

User Function FA100OKP()

  If FWAlertYesNo("Deseja impimir o recibo ?", "Impressão de Recibo")
    U_PFINR001()
  EndIf 

Return .T.
