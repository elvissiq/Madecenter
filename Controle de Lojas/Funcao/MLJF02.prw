//Bibliotecas
#Include 'Protheus.ch'

//-------------------------------------------------------------------------------
/*/{PROTHEUS.DOC} MLJF02
Pergunta se o cliente irá retirar mercadorial parcial para posteriormente
ser utilizado no PE LJ7061 e preencher o campo LR_ENTREGA com o valor 3
@OWNER Bokus
@VERSION PROTHEUS 12
@SINCE 29/08/2024
/*/
//-------------------------------------------------------------------------------

User Function MLJF02(pCodCli)
  
  Public lEntreg := .F.

  If FWAlertNoYes('O cliente irá retirar a mercadoria de forma parcial ?','Entrega Parcial')
    lEntreg := .T.
  EndIF 

Return pCodCli 
