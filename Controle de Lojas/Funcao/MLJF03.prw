//Bibliotecas
#Include 'Protheus.ch'
#Include "TOPCONN.ch"
#Include 'FWMVCDef.ch'

//----------------------------------------------------------------------
/*/{PROTHEUS.DOC} MLJF03
FUNÇÃO MLJF03 - Tela para confirmação de Produtos entregues ao cliente
@OWNER Bokus
@VERSION PROTHEUS 12
@SINCE 30/08/2024
/*/
//----------------------------------------------------------------------

User Function MLJF03()
  Local aButtons := {{.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.T.,"Fechar"},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,NIl}}
  
  If !(Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_RESERVA) .AND. Empty(SL1->L1_DOCPED) .AND. SL1->L1_STATUS <> "D" .AND. !Empty(SL1->L1_ORCRES))
    FWAlertWarning('Esse pedido não se aplica a essa operação.','Retira')
    Return
  EndIF 

  Private cAliasL1  := GetNextAlias()
  Private cAliasL2  := GetNextAlias()
  Private oTableL1  := Nil
  Private oTableL2  := Nil
  Private aFieldsL1 := {}
  Private aFieldsL2 := {}

  oTableL1  := FWTemporaryTable():New(cAliasL1)
    
  aAdd(aFieldsL1,{"L1_NUM"    ,"C", FWTamSX3("L1_NUM")[1]     , FWTamSX3("L1_NUM")[2]     , "No Orcamento"  ,"",""  })
  aAdd(aFieldsL1,{"L1_CLIENTE","C", FWTamSX3("L1_CLIENTE")[1] , FWTamSX3("L1_CLIENTE")[2] , "Cód. Cliente"  ,"",""  })
  aAdd(aFieldsL1,{"L1_NOME"   ,"C", FWTamSX3("A1_NOME")[1]    , FWTamSX3("A1_NOME")[2]    , "Nome Cliente"  ,"",""  })
  aAdd(aFieldsL1,{"L1_VEND"   ,"C", FWTamSX3("L1_VEND")[1]    , FWTamSX3("L1_VEND")[2]    , "Cod. Vendedor" ,"",""  })
  aAdd(aFieldsL1,{"L1_NOMVEND","C", FWTamSX3("A3_NOME")[1]    , FWTamSX3("A3_NOME")[2]    , "Nome Vendedor" ,"",""  })
  
  oTableL1:SetFields(aFieldsL1)
  oTableL1:Create()

  oTableL2  := FWTemporaryTable():New(cAliasL2)
    
  aAdd(aFieldsL2,{"L2_XOK"    ,"L", FWTamSX3("L2_XOK")[1]     , FWTamSX3("L2_XOK")[2]     , "Entregue"     ,"",""  })
  aAdd(aFieldsL2,{"L2_ITEM"   ,"C", FWTamSX3("L2_ITEM")[1]    , FWTamSX3("L2_ITEM")[2]    , "Nº Item"      ,"",""  })
  aAdd(aFieldsL2,{"L2_PRODUTO","C", FWTamSX3("L2_PRODUTO")[1] , FWTamSX3("L2_PRODUTO")[2] , "Produto"      ,"",""  })
  aAdd(aFieldsL2,{"L2_DESCRI" ,"C", FWTamSX3("L2_DESCRI")[1]  , FWTamSX3("L2_DESCRI")[2]  , "Descrição"    ,"",""  })
  aAdd(aFieldsL2,{"L2_QUANT"  ,"N", FWTamSX3("L2_QUANT")[1]   , FWTamSX3("L2_QUANT")[2]   , "Quantidade"   ,"",""  })
  aAdd(aFieldsL2,{"L2_VRUNIT" ,"N", FWTamSX3("L2_VRUNIT")[1]  , FWTamSX3("L2_VRUNIT")[2]  , "Preco Unit."  ,"",""  })
  aAdd(aFieldsL2,{"L2_VLRITEM","N", FWTamSX3("L2_VLRITEM")[1] , FWTamSX3("L2_VLRITEM")[2] , "Vlr.Item"     ,"",""  })
  aAdd(aFieldsL2,{"L2_LOCAL"  ,"C", FWTamSX3("L2_LOCAL")[1]   , FWTamSX3("L2_LOCAL")[2]   , "Armazem"      ,"",""  })
  aAdd(aFieldsL2,{"L2_LOCALIZ","C", FWTamSX3("L2_LOCALIZ")[1] , FWTamSX3("L2_LOCALIZ")[2] , "Endereco"     ,"",""  })
  
  oTableL2:SetFields(aFieldsL2)
  oTableL2:Create()

  FWExecView("",'MLJF03',4,,{||.T.},,,aButtons)

Return

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
  Local oModel
  Local oStrSL1 := fnM01TMP('1')
  Local oStrSL2 := fnM01TMP('2')
  Local bLinePre := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| fLinePreGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}

  oModel := MPFormModel():New('MLJF03M',/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
  oModel:AddFields('SL1MASTER',/*cOwner*/,oStrSL1,/*bPre*/,/*bPos*/,/*bLoad*/)
  oModel:AddGrid('SL2DETAIL', 'SL1MASTER', oStrSL2, bLinePre, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)

  oModel:SetPrimaryKey({})
  oModel:SetDescription("Produtos nao Entregues ao Cliente")
  oModel:GetModel('SL1MASTER'):SetDescription('Dados do Cliente')
  oModel:GetModel('SL2DETAIL'):SetDescription('Itens da Venda')

Return oModel

//-----------------------------------------
/*/ fnM01TMP
  Estrutura dos Parâmetros.								  
/*/
//-----------------------------------------
Static Function fnM01TMP(cTab)
  Local oStruct := FWFormModelStruct():New()
  Local cField := "aFieldsL"+cTab
  Local nId  

  oStruct:AddTable(&('cAliasL'+cTab),{},"Tabela "+cTab)

  For nId := 1 To Len(&(cField))
      oStruct:AddField(&(cField)[nId][5]; 
                      ,&(cField)[nId][5]; 
                      ,&(cField)[nId][1]; 
                      ,&(cField)[nId][2];
                      ,&(cField)[nId][3];
                      ,&(cField)[nId][4];
                      ,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  Next nId

  Return oStruct

Return oStruct

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
  Local oView 
  Local oModel   := FWLoadModel('MLJF03')
  Local oStrSL1  := fnV01TMP('1')
  Local oStrSL2  := fnV01TMP('2')

  oView := FWFormView():New()
  oView:SetModel(oModel)
  oView:SetProgressBar(.T.)
  oView:AddField('VIEW_SL1',oStrSL1,'SL1MASTER')
  oView:AddGrid('VIEW_SL2',oStrSL2,'SL2DETAIL')
    
  oView:CreateHorizontalBox('CABEC',020)
  oView:CreateHorizontalBox('GRID',080)
    
  oView:SetOwnerView('VIEW_SL1','CABEC')
  oView:SetOwnerView('VIEW_SL2','GRID')
    
  oView:EnableTitleView('VIEW_SL1','Dados do Cliente')
  oView:EnableTitleView('VIEW_SL2','Itens da Venda')
    
  oView:SetViewProperty("VIEW_SL2", "GRIDSEEK",   {.T.})
  oView:SetViewProperty("VIEW_SL2", "GRIDFILTER", {.T.})

  oView:SetAfterViewActivate({|oView| ViewActv(oView)})

  oView:SetViewAction("ASKONCANCELSHOW",{|| .F.}) // Tirar a mensagem do final "Há Alterações não..."

Return oView

//-------------------------------------------------------------------
/*/ Função fnV01TMP()
  Estrutura (View)	
/*/
//-------------------------------------------------------------------
Static Function fnV01TMP(cTab)
  Local oViewTMP := FWFormViewStruct():New() 
  Local cField := "aFieldsL"+cTab
  Local nId

  For nId := 1 To Len(&(cField))
      oViewTMP:AddField(&(cField)[nId][1],;     // 01 = Nome do Campo
                        StrZero(nId,2),;        // 02 = Ordem
                        &(cField)[nId][5],;     // 03 = Título do campo
                        &(cField)[nId][5],;     // 04 = Descrição do campo
                        Nil,;                   // 05 = Array com Help
                        &(cField)[nId][2],;     // 06 = Tipo do campo
                        &(cField)[nId][6],;     // 07 = Picture
                        Nil,;                   // 08 = Bloco de PictTre Var
                        &(cField)[nId][7],;     // 09 = Consulta F3
                        .T.,;                   // 10 = Indica se o campo é alterável
                        Nil,;                   // 11 = Pasta do Campo
                        Nil,;                   // 12 = Agrupamnento do campo
                        Nil,;                   // 13 = Lista de valores permitido do campo (Combo)
                        Nil,;                   // 14 = Tamanho máximo da opção do combo
                        Nil,;                   // 15 = Inicializador de Browse
                        .F.,;                   // 16 = Indica se o campo é virtual (.T. ou .F.)
                        Nil,;                   // 17 = Picture Variavel
                        Nil)                    // 18 = Indica pulo de linha após o campo (.T. ou .F.)
  Next nId

Return oViewTMP

/*---------------------------------------------------------------------*
 | Func:  ViewActv                                                     |
 | Desc:  Realiza o PUT nos campos para gravação na tabela SE1         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ViewActv(oView)
  Local oModel := FWModelActive() 
  Local oModelSL1 := oModel:GetModel("SL1MASTER")
  Local oModelSL2 := oModel:GetModel("SL2DETAIL")
  Local nLinL2 := 0

  oModelSL1:LoadValue("L1_NUM"    , SL1->L1_NUM     )
  oModelSL1:LoadValue("L1_CLIENTE", SL1->L1_CLIENTE )
  oModelSL1:LoadValue("L1_NOME"   , Alltrim(Posicione("SA1",1,xFilial("SA1") + SL1->L1_CLIENTE + SL1->L1_LOJA, "A1_NOME")) )
  oModelSL1:LoadValue("L1_VEND"   , SL1->L1_VEND )
  oModelSL1:LoadValue("L1_NOMVEND", Alltrim(Posicione("SA3",1,xFilial("SA3") + SL1->L1_VEND, "A3_NOME")) )

  oView:Refresh("VIEW_SL1")

  dbSelectArea("SL2")
  SL2->(MSSeek( xFilial("SL2") + SL1->L1_NUM ))

  While !SL2->(Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + SL1->L1_NUM
    
    nLinL2++

    IF nLinL2 > 1
      oModelSL2:AddLine()
      oModelSL2:GoLine(nLinL2)
    EndIF 

    oModelSL2:LoadValue("L2_XOK"    , SL2->L2_XOK     )
    oModelSL2:LoadValue("L2_ITEM"   , SL2->L2_ITEM    )
    oModelSL2:LoadValue("L2_PRODUTO", SL2->L2_PRODUTO )
    oModelSL2:LoadValue("L2_DESCRI" , SL2->L2_DESCRI  )
    oModelSL2:LoadValue("L2_QUANT"  , SL2->L2_QUANT   )
    oModelSL2:LoadValue("L2_VRUNIT" , SL2->L2_VRUNIT  )
    oModelSL2:LoadValue("L2_VLRITEM", SL2->L2_VLRITEM )
    oModelSL2:LoadValue("L2_LOCAL"  , SL2->L2_LOCAL   )
    oModelSL2:LoadValue("L2_LOCALIZ", SL2->L2_LOCALIZ )

    oView:Refresh("VIEW_SL2")

    SL2->(DbSkip())
  EndDo

  oModelSL2:GoLine(1)
  oView:Refresh("VIEW_SL2")

Return

/*---------------------------------------------------------------------*
 | Func:  fGrvSl2                                                      |
 | Desc:  Atualiza o campo L2_XOK                                      |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fLinePreGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
  Local lRet := .T.

  If cAction == "SETVALUE" .And. cIDField == "L2_XOK"
    dbSelectArea("SL2")
    MSSeek(xFilial("SL2") + SL1->L1_NUM + oGridModel:GetValue("L2_ITEM") + oGridModel:GetValue("L2_PRODUTO"))
    RecLock("SL2",.F.)
      SL2->L2_XOK := xValue
    SL2->(MsUnLock())
  EndIf

Return lRet

