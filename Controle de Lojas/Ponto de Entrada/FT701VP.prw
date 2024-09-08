#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} FT701VP
  (long_description)
  @type  FT701VP
  @author TOTVS NORDESTE (Elvis Siqueira)
  @since 22/04/2022
  @version 1.0
  @param 
  @return cVendedor(caracter)
  @example
    Vendedor que deve ser inicializado o atendimento.
    User Function FT701VP()
    Local cVendedor := '000002'
    Return cVendedor
  @see https://tdn.engpro.totvs.com.br/display/public/PROT/FT701VP+-+Troca+de+vendedor+ao+inicializar+atendimento
  /*/
User Function FT701VP()
  
Local cVendedor := SuperGetMV("MV_VENDPAD")

  DbSelectArea("SA3")
  SA3->(DbSetOrder(7))
  IF SA3->(Dbseek(xfilial("SA3")+__cUserId))
    cVendedor := SA3->A3_COD
  EndIf 

Return cVendedor
