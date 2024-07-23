#Include 'Protheus.ch'

/*/{Protheus.doc} XAGSTRU
Rotina que serve para buscar dados dos dicionários de dados (SX2/SX3/SIX)
@author Leandro F Silveira
@example U_XAGSTRU("SB1", "B1_COD-B1_DESC-B1_LOCPAD", .F.)
@param _cTabela, varchar, Nome da tabela cujos campos se quer o array
@param _cCampos, varchar, Opcional, texto contendo os campos para filtro
@param _lViewUsad, boolean, Indica que devera considerar os campos que nao estao marcados como usado no dicionario de dados
@param _lVirtual, boolean, Indica que devera considerar os campos virtuais no dicionario de dados
@since 20/04/2020
@version 1.0
/*/
User Function XAGSX3(_cTabela, _cCampos, _lViewUsad, _lVirtual)

    Local _aRet      := {}
    Local _aStruct   := {}
    Local _bFiltSX3  := Nil

    Local _nX3Nome     := 1 // Posicao do campo X3_CAMPO no aFields do objeto retornado pelo FwFormStruct

    Default _lViewUsad := .T.
    Default _lVirtual  := .T.

    If (!Empty(_cCampos))
        _bFiltSX3 := { |cCampo| AllTrim(cCampo) $ _cCampos}
    EndIf

    _aStruct := FWFormStruct(2, _cTabela, _bFiltSX3, _lViewUsad, _lVirtual)
    aEval(_aStruct:aFields,{|x| aAdd(_aRet, x[_nX3Nome]) })

Return(_aRet)