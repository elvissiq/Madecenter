#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} FA100OKR
O ponto de entrada FA100OKR sera utilizado para bloquear a inclusao de movimentos a receber
 na rotina Movimentos bancarios.Caso o retorno seja verdadeiro o movimento � feito normalmente, 
 caso contrario n�o se far� a inclus�o do movimento.
@type function
@version 
@author Elvis Siqueira
@since 03/12/2021
@return Retorno l�gico
/*/

User Function FA100OKR()

  If FWAlertYesNo("Deseja impimir o recibo desse recebimento ?", "Impress�o de Recibo")
      
      U_PFINR001()

  EndIf 

Return .T.
