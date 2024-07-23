#include 'protheus.ch'
#include 'rwmake.ch'

/*/{Protheus.doc} XAG0067
//Função de Importação de Metas baseado em impmetas Shell
@author Leandro Spiller
@since 06/04/2020
@version 1 
@param  _xAuto (determina se a execução é automatica)
@type function
/*/

User Function XAG0067(_xAuto)

   Default _xAuto    := .F.
   Private _cArqPri := ""
   Private oDlgMeta    
   Private _lAuto := _xAuto 

   If !_lAuto //Rotina chamada via menu
      @ 200,001 TO 350,620 DIALOG oDlgMeta TITLE 'Importação de Metas'
      @ 025,003 Say "Arquivo de Meta: "
      @ 025,046 Get _cArqPri Size 200,10
      @ 025,260 BMPBUTTON TYPE 14 ACTION (_cArqPri := cGetFile())
      @ 055,210 BMPBUTTON TYPE 01 ACTION GProcMet()
      @ 055,240 BMPBUTTON TYPE 02 ACTION Close(oDlgMeta)
      ACTIVATE DIALOG oDlgMeta CENTERED
   Else
      RProcMet()
      Close(oDlgMeta)
   EndIf

Return

Static Function GProcMet()

   If !_lAuto

      if alltrim(_cArqPri) == ''
         Alert("Por favor selecione um arquivo!")
         Return
      Elseif !('.CSV' $ upper(_cArqPri))
         Alert("Permitido apenas arquivos .CSV!")
         Return
      Endif
   Endif

// Inicializa a regua de processamento
Processa({|| RProcMet() },"Importando Metas ...")

Return Nil

Static Function RProcMet

Local _nLinha      := 1
Local cBuffer      := ""
Local _aCampos     := {}
Local _i           := 0 
Local nAchouSX3    := 0 
Local cCpoInvalido := ""
Local aTipoCPO    := {}
Local cTipoCpo := ""//aTipoCpo[3]
Local nTam     := 0 
Local nDec     := 0
Local cFilSCT := ""
Local cDocSCT := ""

Private _aVetor := {}

If !File(_cArqPri)
   If !_lAuto
      MsgAlert("Arquivo texto: "+AllTrim(_cArqPri)+" não localizado",cCadastro)
   Else
      ConOut("Arquivo texto: "+AllTrim(_cArqPri)+" não localizado")
     // EditTxt("\system\IMPSTABS.log","Arquivo texto: "+AllTrim(_cArqPri)+" não localizado")
      //AAdd(_aMsgmail,"Arquivo texto: "+AllTrim(_cArqPri)+" não localizado")
      _lOkRet := .F.
   EndIf
   Return
Endif

FT_FUSE(_cArqPri)
FT_FGOTOP()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !_lAuto //Rotina chamada via menu
   ProcRegua(FT_FLASTREC())
EndIf

While !FT_FEOF()

   cBuffer := FT_FREADLN()
   _cTemp  := cBuffer

   _aTemp  := Separa(_cTemp,";",.T.) 

   //Desconsidera a primeira linha da planilha, pois é cabeçalhos
   If _nLinha <= 1

      DbSelectArea("SCT")

      //Valida cabeçalho
      For _i := 1 to len(_aTemp)
         
         If alltrim(_aTemp[_i]) <> ''
              If FieldPos(alltrim(_aTemp[_i])) > 0
                  nAchouSX3++ 
               Else  
                  cCpoInvalido += alltrim(_aTemp) + "  "
              Endif
         Endif
         
         aTipoCpo := TamSX3(alltrim(alltrim(_aTemp[_i])))
         If Len(aTipoCpo) > 0 
            cTipoCpo := aTipoCpo[3]
            nTam     := aTipoCpo[1] 
            nDec     := aTipoCpo[2] 
         Else
            cTipoCpo := ""
            nTam     := 0 
            nDec     := 0 
         Endif


         AADD(_aCampos,{alltrim(_aTemp[_i]) ,cTipoCpo ,nTam,nDec  }) 
         
         //AADD(_aTipoCPO


      Next _i 

      //valida campos
      If nAchouSX3 > 0 .and. alltrim(cCpoInvalido) <> ""
         Alert("Não Importado -> Campo(s) de cabeçalho inválido(s) :" + cCpoInvalido )
         Return 
      Elseif nAchouSX3 == 0 
         Alert("Não Importado -> Verifique o cabeçalho do seu arquivo, ele deve conter campos da tabela SCT")
         Return 
      Endif

      _cDoc := GETSXENUM("SCT","CT_DOC")
      ConfirmSx8()
      _cSeq := "001"
      //_aCampos  := aClone(_aTemp)
      _aAutoma  := {}

      _nLinha++
      FT_FSKIP()
      Loop
   EndIf
   
   _aVetor := {}

   //_nPosFil := aScan(_aCampos,"CT_FILIAL")
   _nPosFil := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_FILIAL"})
   _nPosDes := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_DESCRI"})
   _nPosVen := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_VEND"})
   _nPosDat := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_DATA"})
   _nPosTip := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_TIPO"})
   _nPosGrp := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_GRUPO"})
   _nPosPro := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_PRODUTO"})
   _nPosQtd := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_QUANT"})
   _nPosVal := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_VALOR"})
   _nPosCat := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_CATEGO"})
   _nPosFor := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_FORNECE"})
   _nPosDoc := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_DOC"})
   _nPosExp := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_ZZEXPOR"})
   _nPosSeg := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_PRODSIG"})
   _nPosGFo := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_ZZGRFOR"})
   _nPosDsc := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_ZZDSCGP"})
   _nPosPrc := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_ZZPROC"})
   _nPosLoj := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_ZZLOJA"})
   _nPosAme := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_ANOMES"})
   _nPosCli := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_ZZCLI"})
   _nPosLCl := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_ZZLOJCL"})
   _nPosTmk := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_ZZTMK"})
   _nPosSeq := aScan(_aCampos,{|x|Alltrim(x[1])=="CT_SEQUEN"})
   
   If _nPosVen <= 0 .or. _nPosDat <= 0 .or. _nPosQtd <= 0 .or. _nPosVal <= 0 .or. _nPosFor <= 0 .or. _nPosDes <= 0 .or. _nPosCat <= 0
      If !_lAuto
         Alert("Arquivo precisa ter os campos CT_CATEGO, CT_DESCRI, CT_VEND, CT_DATA, CT_QUANT, CT_VALOR e CT_FORNECE. Alguns destes campos não existe no arquivo, favor confirmar!!!")
      Else
         ConOut("Arquivo precisa ter os campos CT_CATEGO, CT_DESCRI, CT_VEND, CT_DATA, CT_QUANT, CT_VALOR e CT_FORNECE. Alguns destes campos não existe no arquivo, favor confirmar!!!")
         //EditTxt("\system\IMPSTABS.log","Arquivo precisa ter os campos CT_CATEGO, CT_DESCRI, CT_VEND, CT_DATA, CT_QUANT, CT_VALOR e CT_FORNECE. Alguns destes campos não existe no arquivo, favor confirmar!!!")
         //AAdd(_aMsgmail,"Arquivo precisa ter os campos CT_CATEGO, CT_DESCRI, CT_VEND, CT_DATA, CT_QUANT, CT_VALOR e CT_FORNECE. Alguns destes campos não existe no arquivo, favor confirmar!!!")
      EndIf
      FT_FUSE()
      Return
   EndIf
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Validações das informações do CSV³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //Validação do Vendedor
   If _nPosVen > 0
      SA3->(DbSetOrder(1))
      If SA3->(!DbSeek(xFilial("SA3")+AllTrim(_aTemp[_nPosVen])))
         Alert("Não encontrado o vendedor "+AllTrim(_aTemp[_nPosVen])+" da linha "+AllTrim(Str(_nLinha))+". A mesma não será importada!!!")
         _nLinha++
         FT_FSKIP()
         Loop
      EndIf
   EndIf
   //Validação do Produto
   If _nPosPro > 0
      SB1->(DbSetOrder(1))
      If SB1->(!DbSeek(xFilial("SB1")+AllTrim(_aTemp[_nPosPro])))
         Alert("Não encontrado o produto "+AllTrim(_aTemp[_nPosPro])+" da linha "+AllTrim(Str(_nLinha))+". A mesma não será importada!!!")
         _nLinha++
         FT_FSKIP()
         Loop
      EndIf
   EndIf
   //Validação do Fornecedor
   If _nPosFor > 0
      SA2->(DbSetOrder(1))
      If SA2->(!DbSeek(xFilial("SA2")+AllTrim(_aTemp[_nPosFor])))
         Alert("Não encontrado o fornecedor "+AllTrim(_aTemp[_nPosFor])+" da linha "+AllTrim(Str(_nLinha))+". A mesma não será importada!!!")
         _nLinha++
         FT_FSKIP()
         Loop
      EndIf
   EndIf
   //Validação do Grupo de Produto
   If _nPosGrp > 0
      SBM->(DbSetOrder(1))
      If SBM->(!DbSeek(xFilial("SBM")+AllTrim(_aTemp[_nPosGrp])))
         Alert("Não encontrado o grupo de produto "+AllTrim(_aTemp[_nPosGrp])+" da linha "+AllTrim(Str(_nLinha))+". A mesma não será importada!!!")
         _nLinha++
         FT_FSKIP()
         Loop
      EndIf
   EndIf
   //Validação do Tipo de Produto
   If _nPosTip > 0
      SX5->(DbSetOrder(1))
      If SX5->(!DbSeek(xFilial("SX5")+"02"+AllTrim(_aTemp[_nPosTip])))
         Alert("Não encontrado o tipo de produto "+AllTrim(_aTemp[_nPosTip])+" da linha "+AllTrim(Str(_nLinha))+". A mesma não será importada!!!")
         _nLinha++
         FT_FSKIP()
         Loop
      EndIf
   EndIf
   //Validação da categoria da Meta
   If _nPosCat > 0
      ACU->(DbSetOrder(1))
      If ACU->(!DbSeek(xFilial("ACU")+AllTrim(_aTemp[_nPosCat])))
         Alert("Não encontrado a Categoria "+AllTrim(_aTemp[_nPosCat])+" da linha "+AllTrim(Str(_nLinha))+". A mesma não será importada!!!")
         _nLinha++
         FT_FSKIP()
         Loop
      EndIf
   EndIf
   //Valida campo de exportação
   If _nPosExp > 0
      If !(AllTrim(_aTemp[_nPosExp]) $ "SNT")
         Alert("Preenchimento do campo exportação é inválido. Preenchido com "+AllTrim(_aTemp[_nPosExp])+" na linha "+AllTrim(Str(_nLinha))+". A mesma não será importada!!!")
         _nLinha++
         FT_FSKIP()
         Loop
      EndIf
   EndIf
   //Validação Segmento do Cliente
   If _nPosSeg > 0
      SX5->(DbSetOrder(1))
      If SX5->(!DbSeek(xFilial("SX5")+"T3"+AllTrim(_aTemp[_nPosSeg])))
         Alert("Não encontrado o tipo de produto "+AllTrim(_aTemp[_nPosSeg])+" da linha "+AllTrim(Str(_nLinha))+". A mesma não será importada!!!")
         _nLinha++
         FT_FSKIP()
         Loop
      EndIf
   EndIf

   DbSelectArea("SCT")
   /*If RecLock("SCT",.T.)
      SCT->CT_FILIAL  := If(_nPosFil > 0,AllTrim(_aTemp[_nPosFil]),xFilial("SCT"))
      SCT->CT_DOC     := If(_nPosDoc > 0,AllTrim(_aTemp[_nPosDoc]),_cDoc)
      SCT->CT_SEQUEN  := _cSeq
      SCT->CT_DESCRI  := AllTrim(_aTemp[_nPosDes])
      SCT->CT_VEND    := AllTrim(_aTemp[_nPosVen])
      SCT->CT_DATA    := CtoD(AllTrim(_aTemp[_nPosDat]))
      If _nPosTip > 0
         SCT->CT_TIPO    := AllTrim(_aTemp[_nPosTip])
      EndIf
      If _nPosGrp > 0
         SCT->CT_GRUPO   := AllTrim(_aTemp[_nPosGrp])
      EndIf
      If _nPosPro > 0
         SCT->CT_PRODUTO := AllTrim(_aTemp[_nPosPro])
      EndIf
      SCT->CT_QUANT   := Val(StrTran(StrTran(_aTemp[_nPosQtd],".",""),",","."))
      SCT->CT_VALOR   := Val(StrTran(StrTran(_aTemp[_nPosVal],".",""),",","."))
      SCT->CT_MOEDA   := 1
      SCT->CT_CATEGO  := AllTrim(_aTemp[_nPosCat])
      //SCT->CT_MOVIMEN := 0
      SCT->CT_MSBLQL  := "2"
      SCT->CT_FORNECE := AllTrim(_aTemp[_nPosFor])
      If _nPosExp > 0
         SCT->CT_ZZEXPOR := AllTrim(_aTemp[_nPosExp])
      EndIf
      If _nPosSeg > 0
         SCT->CT_PRODSIG := AllTrim(_aTemp[_nPosSeg])
      EndIf
      If _nPosGFo > 0
         SCT->CT_ZZGRFOR := AllTrim(_aTemp[_nPosGFo])
      EndIf
      If _nPosDsc > 0
         SCT->CT_ZZDSCGP := AllTrim(_aTemp[_nPosDsc])
      EndIf
      If _nPosPrc > 0
         SCT->CT_ZZPROC := AllTrim(_aTemp[_nPosPrc])
      EndIf
      If _nPosLoj > 0
         SCT->CT_ZZLOJA := AllTrim(_aTemp[_nPosLoj])
      EndIf
      If _nPosAme > 0
         SCT->CT_ANOMES := AllTrim(_aTemp[_nPosAme])
      EndIf
      If _nPosCli > 0
         SCT->CT_ZZCLI := AllTrim(_aTemp[_nPosCli])
      EndIf
      If _nPosLCl > 0
         SCT->CT_ZZLOJCL := AllTrim(_aTemp[_nPosLCl])
      EndIf
      If _nPosTmk > 0
         SCT->CT_ZZTMK := AllTrim(_aTemp[_nPosTmk])
      EndIf
      MsUnLock()
   EndIf
   */

   Dbselectarea('SCT')
   Dbsetorder(1)
   cFilSCT := If(_nPosFil > 0,PadL( AllTrim(_aTemp[_nPosFil]) , 2, '0'),xFilial("SCT"))
   cDocSCT := PADR( If(_nPosDoc > 0,AllTrim(_aTemp[_nPosDoc]),_cDoc),_aCampos[_nPosDoc][3] , '')

   if _nPosSeq >= 0 
      _cSeqCSV := STRZERO(val(AllTrim(_aTemp[_nPosSeq])) , 3)
   Else
      _cSeqCSV := "000"
   Endif 

   If !dbseek(cFilSCT + cDocSCT + iif( alltrim(_cSeqCSV) <> '000', _cSeqCSV, _cSeq ) )

      RecLock("SCT",.T.)
      
      SCT->CT_FILIAL  := cFilSCT
      SCT->CT_DOC     := cDocSCT
      SCT->CT_SEQUEN  := iif( alltrim(_cSeqCSV) <> '000', _cSeqCSV, _cSeq )//_cSeq
      SCT->CT_MSBLQL  := "2"

      For _i := 1 to len(_aCampos)

         //não executa para Campos com tratamentos específicos
         If ! (_aCampos[_i][1] $ "CT_FILIAL/CT_DOC/CT_SEQUEN/CT_MSBLQL")
            
            If _aCampos[_i][2] == 'C' //Se for caracter preencho com Espaços
               &(alltrim(_aCampos[_i][1])) := PadR( alltrim(_atemp[_i]) ,_aCampos[_i][3] , '')   
            Elseif _aCampos[_i][2] == 'N'//Se for numerico substituo os pontos e gravo como val
               &(alltrim(_aCampos[_i][1])) := Val(StrTran(StrTran(_aTemp[_i],".",""),",","."))
            Elseif _aCampos[_i][2] == 'D' 
               If   '/' $ _aTemp[_i]
                  &(alltrim(_aCampos[_i][1])) := cTod(_aTemp[_i])
               Else
                  &(alltrim(_aCampos[_i][1])) := stod(_aTemp[_i])
               Endif
            Else
                &(alltrim(_aCampos[_i][1])) := _aTemp[_i]  
            Endif
         Endif

      Next _i 
      
      SCT->(Msunlock())
      //Somente incrementa o sequencial se nao esta preenchido
      If alltrim(_cSeqCSV) <> '000'
         _cSeq := Soma1(_cSeq)
      Endif
   Endif
  

   If !_lAuto //Rotina chamada via menu
      IncProc("Processando linha: "+TransForm(_nLinha,"@E 999,999"))
   EndIf
   _nLinha++
   FT_FSKIP()
EndDo
FT_FUSE()

If !_lAuto
   MsgInfo("Importação finalizada!!!")
Else
   ConOut("Importação finalizada!!!")
   //EditTxt("\system\IMPSTABS.log","Importação finalizada!!!")
   //AAdd(_aMsgmail,"Importação finalizada!!!")
EndIf

Return

