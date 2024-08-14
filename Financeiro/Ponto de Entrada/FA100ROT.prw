#include "protheus.ch"
#include "rwmake.ch"

/*/{Protheus.doc} FA100ROT
O ponto de entrada FA100ROT permite a inclus�o de bot�es customizados 
                na EnchoiceBar da rotina Movimento Banc�rio (FINA100).
@type function
@version 
@author Elvis Siqueira
@since 21/12/2021
@return Retorno Array
/*/

User Function FA100ROT()

Local aRotina := aClone(PARAMIXB[1])//Adiciona Rotina Customizada a EnchoiceBara

  aAdd( aRotina, { 'Imprimir Recibo' ,'U_PFINR001', 0 , 7 })
  
Return aRotina
