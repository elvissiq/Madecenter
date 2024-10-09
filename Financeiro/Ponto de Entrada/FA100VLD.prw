#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} FA100VLD
  O ponto de entrada FA100VLD permite ao usu�rio criar valida��es quanto ao acesso 
  para exclus�o e cancelamento de movimento banc�rio.
@type function
@version 
@author Elvis Siqueira
@since 07/10/2024
@return Retorno l�gico
/*/

User Function FA100VLD()
  Local lRet := .F.
  Local lMovLoj := IIF(AllTrim(SE5->E5_TIPODOC) == 'TR', .T., .F.)

  IF lMovLoj
    If FWAlertYesNo("Esse registro � referente a um movimento de Sangria/Suprimento, deseja excluir ?", "Exluir movimento Sangria/Suprimento")
      RecLock("SE5",.F.)
        SE5->E5_TIPODOC := 'DH'
      SE5->(MSUnLock())
      lRet := .T.
    EndIf
  Else
    lRet := .T.
  EndIF 

Return lRet
